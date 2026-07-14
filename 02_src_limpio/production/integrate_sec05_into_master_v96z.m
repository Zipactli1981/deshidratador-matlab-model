function out = integrate_sec05_into_master_v96z()
% INTEGRATE_SEC05_INTO_MASTER_v96z
%
% 9.6z-results-draft-e
% INTEGRATE-SEC-05-INTO-MASTER-MANUSCRIPT-v01-001
%
% Objetivo:
%   Integrar el texto aprobado de SEC_05_results_eta_sensitivity_v96z.md
%   dentro de MASTER_manuscript_v01.md, sección 7.2.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica tablas numéricas.

    rootDir = setup_v05_paths();

    draftDir = fullfile(rootDir,'06_manuscript','article_Q1','draft_sections');
    reviewDir = fullfile(rootDir,'06_manuscript','article_Q1','review');
    traceDir = fullfile(rootDir,'06_manuscript','article_Q1','traceability');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
    secFile = fullfile(draftDir,'SEC_05_results_eta_sensitivity_v96z.md');

    if ~isfile(masterFile)
        error('Master file not found: %s', masterFile);
    end

    if ~isfile(secFile)
        error('Section file not found: %s', secFile);
    end

    masterText = fileread(masterFile);
    secText = fileread(secFile);

    % ---------------------------------------------------------------
    % Extraer bloque en inglés aprobado desde SEC_05
    % ---------------------------------------------------------------
    startMarker = "## Manuscript text — English";
    endMarker = "## Versión técnica de control — Español";

    secStart = strfind(secText,startMarker);
    secEnd = strfind(secText,endMarker);

    if isempty(secStart)
        error('Start marker not found in SEC_05: %s', startMarker);
    end

    if isempty(secEnd)
        error('End marker not found in SEC_05: %s', endMarker);
    end

    secStart = secStart(1) + strlength(startMarker);
    secEnd = secEnd(1) - 1;

    englishBlock = strtrim(extractBetweenString(secText,secStart,secEnd));

    % Ajustar nivel de encabezado:
    % En SEC_05 aparece como "### Tri-objective..."
    % En MASTER se integrará bajo "## 7.2", así que se conserva como "###".
    integratedBlock = sprintf([ ...
        '## 7.2 Collector-efficiency sensitivity\n\n' ...
        '`STATUS: INTEGRATED_FROM_APPROVED_SECTION`\n\n' ...
        'Source section:\n\n' ...
        '`SEC_05_results_eta_sensitivity_v96z.md`\n\n' ...
        'Source tables:\n\n' ...
        '- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`\n' ...
        '- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`\n\n' ...
        'Approved internal verdict:\n\n' ...
        '`SEC_05_RESULTS_ETA_SENSITIVITY_v96z_READY_FOR_MASTER_MANUSCRIPT`\n\n' ...
        '%s\n\n'], englishBlock);

    % ---------------------------------------------------------------
    % Reemplazar bloque 7.2 en MASTER
    % ---------------------------------------------------------------
    blockStartMarker = "## 7.2 Collector-efficiency sensitivity";
    blockEndMarker = "## 7.3 Operational interpretation";

    blockStart = strfind(masterText,blockStartMarker);
    blockEnd = strfind(masterText,blockEndMarker);

    if isempty(blockStart)
        error('Block start marker not found in MASTER: %s', blockStartMarker);
    end

    if isempty(blockEnd)
        error('Block end marker not found in MASTER: %s', blockEndMarker);
    end

    blockStart = blockStart(1);
    blockEnd = blockEnd(1) - 1;

    newMasterText = [ ...
        extractBefore(masterText,blockStart), ...
        integratedBlock, ...
        extractAfter(masterText,blockEnd) ...
        ];

    % ---------------------------------------------------------------
    % Crear respaldo antes de sobrescribir
    % ---------------------------------------------------------------
    timestamp = string(datetime('now','Format','yyyyMMdd_HHmmss'));
    backupFile = fullfile(draftDir,"MASTER_manuscript_v01_BACKUP_before_SEC05_" + timestamp + ".md");

    copyfile(masterFile,backupFile);

    fid = fopen(masterFile,'w');
    if fid < 0
        error('Could not open master file for writing: %s', masterFile);
    end
    fwrite(fid,newMasterText);
    fclose(fid);

    % ---------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------
    updatedText = fileread(masterFile);

    checks = {};
    checks{end+1,1} = check_row("I01","Master file exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("I02","SEC_05 file exists",isfile(secFile),secFile);
    checks{end+1,1} = check_row("I03","Backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("I04","Section 7.2 integrated status present",contains(updatedText,"STATUS: INTEGRATED_FROM_APPROVED_SECTION"),"7.2 status marker.");
    checks{end+1,1} = check_row("I05","R1-7 numerical anchor present",contains(updatedText,"656.23 kWh"),"R1-7 Q_aux under 2-SAH.");
    checks{end+1,1} = check_row("I06","H2 numerical anchor present",contains(updatedText,"747.00 kWh"),"H2 Q_aux under 2-SAH.");
    checks{end+1,1} = check_row("I07","Fixed-efficiency caveat present",contains(updatedText,"not an artifact of the fixed-efficiency assumption"),"Methodological caveat.");
    checks{end+1,1} = check_row("I08","Future coupled collector model caveat present",contains(updatedText,"fully coupled solar collector model"),"Future work caveat.");
    checks{end+1,1} = check_row("I09","No GA executed",true,"Text integration only.");
    checks{end+1,1} = check_row("I10","No model executed",true,"Text integration only.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(reviewDir,'INTEGRATE_SEC05_INTO_MASTER_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "INTEGRATE_SEC05_INTO_MASTER_PASS";
        decision = "MASTER_v01_UPDATED_WITH_APPROVED_SEC05";
        next_step = "Draft or integrate Section 7.1 formal tri-objective run.";
    else
        diagnosis = "INTEGRATE_SEC05_INTO_MASTER_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review MASTER and Tchecks before continuing.";
    end

    reportMd = fullfile(reviewDir,'INTEGRATE_SEC05_INTO_MASTER_v96z_report.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open report for writing: %s', reportMd);
    end

    fprintf(fid,'# INTEGRATE_SEC05_INTO_MASTER_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Master: `%s`\n',masterFile);
    fprintf(fid,'- Section: `%s`\n',secFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Checks: `%s`\n',checksCsv);

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    outMat = fullfile(traceDir,'INTEGRATE_SEC05_INTO_MASTER_v96z.mat');
    save(outMat,'masterFile','secFile','backupFile','checksCsv','reportMd','Tchecks','diagnosis','decision','next_step');

    out = struct();
    out.status = "INTEGRATE_SEC05_INTO_MASTER_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.masterFile = masterFile;
    out.secFile = secFile;
    out.backupFile = backupFile;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;
    out.Tchecks = Tchecks;

    disp('=== INTEGRATE SEC05 INTO MASTER v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.masterFile)
    disp(out.backupFile)
    disp(out.reportMd)
end

function out = extractBetweenString(txt,startIdx,endIdx)
    chars = char(txt);
    out = string(chars(startIdx:endIdx));
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end