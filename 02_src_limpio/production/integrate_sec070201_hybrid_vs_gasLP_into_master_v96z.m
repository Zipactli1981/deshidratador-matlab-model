function out = integrate_sec070201_hybrid_vs_gasLP_into_master_v96z()
% INTEGRATE_SEC070201_HYBRID_vs_GASLP_INTO_MASTER_v96z
%
% 9.6z-sim-lite-d
% INTEGRATE-HYBRID-vs-GASLP-AS-SEC-07-02-01-INTO-MASTER-v01-1-001
%
% Objetivo:
%   Insertar SEC_07_02_01_hybrid_vs_gasLP_baseline_v96z.md
%   como subseccion 7.2.1 dentro de MASTER_manuscript_v01.md.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica resultados numéricos.
%
% Nota:
%   Reabre Section 7 v01 para producir una versión v01.1.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
    secFile = fullfile(draftDir,'SEC_07_02_01_hybrid_vs_gasLP_baseline_v96z.md');

    if ~isfile(masterFile)
        error('Master file not found: %s', masterFile);
    end

    if ~isfile(secFile)
        error('Section file not found: %s', secFile);
    end

    masterText = fileread(masterFile);
    secText = fileread(secFile);

    % ---------------------------------------------------------------
    % Extraer bloque en inglés aprobado desde SEC_07_02_01
    % ---------------------------------------------------------------
    startMarker = "## Manuscript text — English";
    endMarker = "## Versión técnica de control — Español";

    secStart = strfind(secText,startMarker);
    secEnd = strfind(secText,endMarker);

    if isempty(secStart)
        error('Start marker not found in SEC_07_02_01: %s', startMarker);
    end

    if isempty(secEnd)
        error('End marker not found in SEC_07_02_01: %s', endMarker);
    end

    secStart = secStart(1) + strlength(startMarker);
    secEnd = secEnd(1) - 1;

    englishBlock = strtrim(extractBetweenString(secText,secStart,secEnd));

    % Convertir encabezado interno de "### Hybrid..." a "### 7.2.1 Hybrid..."
    englishBlock = replace(englishBlock, ...
        "### Hybrid versus gas-LPG baseline comparison", ...
        "### 7.2.1 Hybrid versus gas-LPG baseline comparison");

    integratedBlock = sprintf([ ...
        '\n### 7.2.1 Hybrid versus gas-LPG baseline comparison\n\n' ...
        '`STATUS: INTEGRATED_FROM_APPROVED_SECTION_v01_1`\n\n' ...
        'Source section:\n\n' ...
        '`SEC_07_02_01_hybrid_vs_gasLP_baseline_v96z.md`\n\n' ...
        'Source analysis:\n\n' ...
        '- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md`\n' ...
        '- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z_report.md`\n\n' ...
        'Approved internal verdict:\n\n' ...
        '`SEC_07_02_01_HYBRID_vs_GASLP_BASELINE_v96z_READY_FOR_MASTER_OR_SUPPLEMENTARY_INTEGRATION`\n\n' ...
        '%s\n\n'], remove_first_heading_if_duplicate(englishBlock));

    % ---------------------------------------------------------------
    % Insertar después del bloque 7.2 y antes de 7.3
    % ---------------------------------------------------------------
    insertBeforeMarker = "## 7.3 Operational interpretation";

    idxInsert = strfind(masterText,insertBeforeMarker);

    if isempty(idxInsert)
        error('Insertion marker not found in MASTER: %s', insertBeforeMarker);
    end

    idxInsert = idxInsert(1);

    % Evitar duplicado si ya se integró antes
    if contains(masterText,"### 7.2.1 Hybrid versus gas-LPG baseline comparison")
        error('Section 7.2.1 already appears to be integrated in MASTER. Abort to avoid duplication.');
    end

    newMasterText = [ ...
        extractBefore(masterText,idxInsert), ...
        integratedBlock, ...
        extractAfter(masterText,idxInsert-1) ...
        ];

    % ---------------------------------------------------------------
    % Crear respaldo antes de sobrescribir
    % ---------------------------------------------------------------
    timestamp = string(datetime('now','Format','yyyyMMdd_HHmmss'));
    backupFile = fullfile(draftDir,"MASTER_manuscript_v01_BACKUP_before_SEC070201_" + timestamp + ".md");

    copyfile(masterFile,backupFile);

    fid = fopen(masterFile,'w');
    if fid < 0
        error('Could not open master file for writing: %s', masterFile);
    end

    fwrite(fid,newMasterText);
    fclose(fid);

    updatedText = fileread(masterFile);

    % ---------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------
    checks = {};

    checks{end+1,1} = check_row("B01","Master file exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("B02","SEC 7.2.1 source file exists",isfile(secFile),secFile);
    checks{end+1,1} = check_row("B03","Backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("B04","Section 7.2.1 heading present",contains(updatedText,"### 7.2.1 Hybrid versus gas-LPG baseline comparison"),"7.2.1 heading.");
    checks{end+1,1} = check_row("B05","Integration status present",contains(updatedText,"STATUS: INTEGRATED_FROM_APPROVED_SECTION_v01_1"),"v01.1 status marker.");
    checks{end+1,1} = check_row("B06","Hybrid-vs-gasLP comparison wording present",contains(updatedText,"gas-LPG-only mode"),"Baseline comparison wording.");
    checks{end+1,1} = check_row("B07","H2 baseline anchor present",contains(updatedText,"1292.6 kWh") && contains(updatedText,"747.00 kWh"),"H2 hybrid/gasLP anchor.");
    checks{end+1,1} = check_row("B08","R1-7 baseline anchor present",contains(updatedText,"1194.1 kWh") && contains(updatedText,"656.23 kWh"),"R1-7 hybrid/gasLP anchor.");
    checks{end+1,1} = check_row("B09","Reduction range present",contains(updatedText,"31.31%") && contains(updatedText,"45.05%"),"Reduction range.");
    checks{end+1,1} = check_row("B10","Not-new-optimization caveat present",contains(updatedText,"not a new optimization run"),"No optimization caveat.");
    checks{end+1,1} = check_row("B11","No GA executed",true,"Text integration only.");
    checks{end+1,1} = check_row("B12","No model executed",true,"Text integration only.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(reviewDir,'INTEGRATE_SEC070201_HYBRID_vs_GASLP_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "INTEGRATE_SEC070201_HYBRID_vs_GASLP_PASS";
        decision = "MASTER_v01_UPDATED_TO_SECTION7_v01_1_CANDIDATE";
        next_step = "Audit Results Section 7 again and lock as v01.1.";
    else
        diagnosis = "INTEGRATE_SEC070201_HYBRID_vs_GASLP_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review MASTER and Tchecks before v01.1 audit.";
    end

    reportMd = fullfile(reviewDir,'INTEGRATE_SEC070201_HYBRID_vs_GASLP_v96z_report.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open report for writing: %s', reportMd);
    end

    fprintf(fid,'# INTEGRATE_SEC070201_HYBRID_vs_GASLP_v96z report\n\n');
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

    outMat = fullfile(traceDir,'INTEGRATE_SEC070201_HYBRID_vs_GASLP_v96z.mat');

    save(outMat,'masterFile','secFile','backupFile','checksCsv','reportMd','Tchecks','diagnosis','decision','next_step');

    out = struct();
    out.status = "INTEGRATE_SEC070201_HYBRID_vs_GASLP_v96z_DONE";
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

    disp('=== INTEGRATE SEC070201 HYBRID vs GASLP INTO MASTER v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
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

function out = remove_first_heading_if_duplicate(txt)
    txt = string(txt);
    lines = splitlines(txt);

    if ~isempty(lines) && startsWith(strtrim(lines(1)),"### 7.2.1 Hybrid versus gas-LPG baseline comparison")
        lines(1) = [];
    end

    out = strjoin(lines,newline);
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end