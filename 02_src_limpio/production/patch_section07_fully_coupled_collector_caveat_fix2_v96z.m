function out = patch_section07_fully_coupled_collector_caveat_fix2_v96z()
% PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX2_v96z
%
% 9.6z-sim-lite-e-fix2
% PATCH-FULLY-COUPLED-COLLECTOR-CAVEAT-IN-SECTION-07-001
%
% Objetivo:
%   Insertar explícitamente el caveat "fully coupled collector model"
%   dentro de Section 7, antes de la subsección 7.2.1.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica resultados numéricos.

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
    backupFile = fullfile(draftDir,"MASTER_manuscript_v01_BACKUP_before_fully_coupled_collector_fix2_" + timestamp + ".md");
    copyfile(masterFile,backupFile);

    caveat = [ ...
        "This collector-efficiency analysis is a sensitivity test applied to the selected operating points. " + ...
        "It should not be interpreted as a fully coupled collector model, because the collector subsystem, airflow-dependent heat-transfer coefficients, fan power, and pressure-drop effects were not re-optimized simultaneously." ...
        ];

    marker = "### 7.2.1 Hybrid versus gas-LPG baseline comparison";

    if ~contains(txt,marker)
        error('Insertion marker not found in MASTER: %s', marker);
    end

    if ~contains(lower(txt),"fully coupled collector model")
        txt = replace(txt,marker,caveat + newline + newline + marker);
    end

    fid = fopen(masterFile,'w');
    if fid < 0
        error('Could not open MASTER for writing: %s', masterFile);
    end
    fwrite(fid,txt);
    fclose(fid);

    patchedTxt = fileread(masterFile);

    % Extract Section 7 only, to verify the phrase is inside the audited block.
    startMarker = "# 7. Results and discussion";
    endMarker = "# 8. Limitations";

    idxStart = strfind(patchedTxt,startMarker);
    idxEnd = strfind(patchedTxt,endMarker);

    if isempty(idxStart) || isempty(idxEnd)
        error('Could not extract Section 7 from MASTER.');
    end

    section7 = string(patchedTxt(idxStart(1):idxEnd(1)-1));
    s7low = lower(section7);

    checks = {};
    checks{end+1,1} = check_row("FC-01","Master exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("FC-02","Backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("FC-03","Section 7 extracted",strlength(section7)>1000,"Section 7 extracted from MASTER.");
    checks{end+1,1} = check_row("FC-04","Fully coupled collector model phrase exists in Section 7", ...
        contains(s7low,"fully coupled collector model"), ...
        "Exact audit phrase present inside Section 7.");
    checks{end+1,1} = check_row("FC-05","Caveat inserted before Section 7.2.1", ...
        contains(section7,caveat) && contains(section7,marker), ...
        "Caveat before 7.2.1.");
    checks{end+1,1} = check_row("FC-06","No GA executed",true,"Text patch only.");
    checks{end+1,1} = check_row("FC-07","No model executed",true,"Text patch only.");
    checks{end+1,1} = check_row("FC-08","No numerical results modified",true,"Caveat-only patch.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(reviewDir,'PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX2_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "PATCH_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX2_PASS";
        decision = "READY_TO_RERUN_SECTION07_v01_1_AUDIT";
        next_step = "Rerun audit_results_section07_v01_1_hybrid_vs_gasLP_v96z.";
    else
        diagnosis = "PATCH_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX2_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_PATCH_CHECKS";
        next_step = "Inspect failed patch checks before rerunning audit.";
    end

    reportMd = fullfile(reviewDir,'PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX2_v96z_report.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open patch report: %s', reportMd);
    end

    fprintf(fid,'# PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX2_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Master: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
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

    outMat = fullfile(traceDir,'PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX2_v96z.mat');
    save(outMat,'masterFile','backupFile','checksCsv','reportMd','Tchecks','diagnosis','decision','next_step','section7');

    out = struct();
    out.status = "PATCH_SECTION07_FULLY_COUPLED_COLLECTOR_CAVEAT_FIX2_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.masterFile = masterFile;
    out.backupFile = backupFile;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;
    out.Tchecks = Tchecks;

    disp('=== PATCH SECTION 07 FULLY COUPLED COLLECTOR CAVEAT FIX2 v96z ===')
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

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end