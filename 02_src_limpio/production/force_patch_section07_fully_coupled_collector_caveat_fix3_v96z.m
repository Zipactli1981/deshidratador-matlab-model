function out = force_patch_section07_fully_coupled_collector_caveat_fix3_v96z()
% FORCE_PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX3_v96z
%
% 9.6z-sim-lite-e-fix3
% FORCE-PATCH-FULLY-COUPLED-COLLECTOR-CAVEAT-INSIDE-SECTION-07-001
%
% Objetivo:
%   Forzar la inserción del caveat "fully coupled collector model"
%   dentro de Section 7, aunque la frase exista en otra parte del MASTER.
%
% No ejecuta GA.
% No ejecuta modelo.
% No cambia resultados numéricos.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');

    if ~isfile(masterFile)
        error('Master file not found: %s', masterFile);
    end

    txt = fileread(masterFile);

    timestamp = string(datetime('now','Format','yyyyMMdd_HHmmss'));
    backupFile = fullfile(draftDir,"MASTER_manuscript_v01_BACKUP_before_fully_coupled_collector_fix3_" + timestamp + ".md");
    copyfile(masterFile,backupFile);

    startMarker = '# 7. Results and discussion';
    endMarker = '# 8. Limitations';
    insertMarker = '### 7.2.1 Hybrid versus gas-LPG baseline comparison';

    idxStart = strfind(txt,startMarker);
    idxEnd = strfind(txt,endMarker);
    idxInsert = strfind(txt,insertMarker);

    if isempty(idxStart)
        error('Section 7 start marker not found: %s', startMarker);
    end

    if isempty(idxEnd)
        error('Section 8 marker not found: %s', endMarker);
    end

    if isempty(idxInsert)
        error('Insertion marker not found: %s', insertMarker);
    end

    idxStart = idxStart(1);
    idxEnd = idxEnd(1);
    idxInsert = idxInsert(1);

    if ~(idxInsert > idxStart && idxInsert < idxEnd)
        error('Insertion marker exists, but is not inside Section 7.');
    end

    section7_before = txt(idxStart:idxEnd-1);
    section7_before_low = lower(section7_before);

    caveat = sprintf('%s%s', ...
        'This collector-efficiency analysis is a sensitivity test applied to the selected operating points. ', ...
        'It should not be interpreted as a fully coupled collector model, because the collector subsystem, airflow-dependent heat-transfer coefficients, fan power, and pressure-drop effects were not re-optimized simultaneously.');

    % Insertar solo si la frase exacta NO está dentro de Section 7.
    if ~contains(section7_before_low,'fully coupled collector model')
        txt = [ ...
            txt(1:idxInsert-1), ...
            caveat, sprintf('\n\n'), ...
            txt(idxInsert:end) ...
            ];
    end

    fid = fopen(masterFile,'w');
    if fid < 0
        error('Could not open MASTER for writing: %s', masterFile);
    end
    fwrite(fid,txt);
    fclose(fid);

    patchedTxt = fileread(masterFile);

    idxStart2 = strfind(patchedTxt,startMarker);
    idxEnd2 = strfind(patchedTxt,endMarker);

    if isempty(idxStart2) || isempty(idxEnd2)
        error('Could not extract Section 7 after patch.');
    end

    section7_after = patchedTxt(idxStart2(1):idxEnd2(1)-1);
    section7_after_string = string(section7_after);
    s7low = lower(section7_after);

    extractedFile = fullfile(traceDir,'RESULTS_SECTION_07_v01_1_AFTER_FULLY_COUPLED_FIX3_EXTRACTED_v96z.md');

    fid = fopen(extractedFile,'w');
    if fid < 0
        error('Could not write extracted Section 7: %s', extractedFile);
    end
    fprintf(fid,'%s\n',section7_after);
    fclose(fid);

    checks = {};
    checks{end+1,1} = check_row("FC3-01","Master exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("FC3-02","Backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("FC3-03","Section 7 extracted after patch",strlength(section7_after_string)>1000,"Section 7 extracted.");
    checks{end+1,1} = check_row("FC3-04","Insertion marker remains inside Section 7",contains(section7_after,insertMarker),"7.2.1 marker.");
    checks{end+1,1} = check_row("FC3-05","Fully coupled collector model phrase exists inside Section 7", ...
        contains(s7low,'fully coupled collector model'), ...
        "Exact audit phrase present inside Section 7.");
    checks{end+1,1} = check_row("FC3-06","Caveat sentence exists inside Section 7", ...
        contains(section7_after,caveat), ...
        "Exact caveat present inside Section 7.");
    checks{end+1,1} = check_row("FC3-07","No GA executed",true,"Text patch only.");
    checks{end+1,1} = check_row("FC3-08","No model executed",true,"Text patch only.");
    checks{end+1,1} = check_row("FC3-09","No numerical results modified",true,"Caveat-only patch.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(reviewDir,'FORCE_PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX3_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "FORCE_PATCH_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX3_PASS";
        decision = "READY_TO_RERUN_SECTION07_v01_1_AUDIT";
        next_step = "Rerun audit_results_section07_v01_1_hybrid_vs_gasLP_v96z.";
    else
        diagnosis = "FORCE_PATCH_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX3_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_PATCH_CHECKS";
        next_step = "Inspect failed fix3 checks before rerunning audit.";
    end

    reportMd = fullfile(reviewDir,'FORCE_PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX3_v96z_report.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open patch report: %s', reportMd);
    end

    fprintf(fid,'# FORCE_PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX3_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Master: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Extracted Section 7 after patch: `%s`\n',extractedFile);
    fprintf(fid,'- Checks: `%s`\n\n',checksCsv);

    fprintf(fid,'## Inserted caveat\n\n');
    fprintf(fid,'%s\n\n',caveat);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    outMat = fullfile(traceDir,'FORCE_PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX3_v96z.mat');

    save(outMat, ...
        'masterFile','backupFile','extractedFile','checksCsv','reportMd', ...
        'Tchecks','diagnosis','decision','next_step','section7_after');

    out = struct();
    out.status = "FORCE_PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX3_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.masterFile = masterFile;
    out.backupFile = backupFile;
    out.extractedFile = extractedFile;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;
    out.Tchecks = Tchecks;

    disp('=== FORCE PATCH SECTION 07 FULLY COUPLED COLLECTOR CAVEAT FIX3 v96z ===')
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
    disp(out.extractedFile)
    disp(out.reportMd)
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end