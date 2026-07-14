function out = patch_section07_v01_1_audit_failures_v96z()
% PATCH_SECTION07_v01_1_AUDIT_FAILURES_v96z
%
% 9.6z-sim-lite-e-fix1
% PATCH-SECTION-07-v01-1-AUDIT-FAILURES-001
%
% Objetivo:
%   Corregir fallas menores de auditoría en Section 7 v01.1:
%   - S0711-33: caveat explícito de fully coupled collector model.
%   - S0711-47: ancla R1-3 con unidades kWh.
%   - S0711-48: ancla R1-9 con unidades kWh.
%
% No ejecuta GA.
% No ejecuta modelo.
% No cambia resultados numéricos.
% Solo inserta/ajusta texto en MASTER_manuscript_v01.md.

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
    backupFile = fullfile(draftDir,"MASTER_manuscript_v01_BACKUP_before_SEC07_v01_1_patch_" + timestamp + ".md");
    copyfile(masterFile,backupFile);

    originalTxt = txt;

    % ---------------------------------------------------------------
    % PATCH 1:
    % Fully coupled collector model caveat.
    % Insertar después de la frase de ranking/captador, o antes de 7.2.1
    % si no se encuentra un punto más fino.
    % ---------------------------------------------------------------
    caveatSentence = ...
        "This sensitivity analysis should therefore be interpreted as a collector-efficiency sensitivity test, not as a fully coupled collector model or a complete redesign of the solar-air-heater subsystem.";

    if ~contains(lower(txt),"fully coupled collector model") && ...
       ~contains(lower(txt),"not a fully coupled collector")

        anchor1 = "The ranking of the selected candidates was preserved under the tested efficiency assumptions.";
        anchor2 = "### 7.2.1 Hybrid versus gas-LPG baseline comparison";

        if contains(txt,anchor1)
            txt = replace(txt,anchor1,anchor1 + newline + newline + caveatSentence);
        elseif contains(txt,anchor2)
            txt = replace(txt,anchor2,caveatSentence + newline + newline + anchor2);
        else
            error('Could not locate insertion point for fully coupled collector caveat.');
        end
    end

    % ---------------------------------------------------------------
    % PATCH 2:
    % R1-3 baseline anchor with explicit kWh units.
    % ---------------------------------------------------------------
    r13Sentence = ...
        "For R1_solution_3, Q_aux decreased from 1270.6 kWh in gas-LPG-only mode to 723.36 kWh in hybrid mode, corresponding to a 43.07% reduction.";

    if ~(contains(txt,"1270.6 kWh") && contains(txt,"723.36 kWh") && contains(txt,"43.07%"))
        anchorR13 = "R1_solution_3 showed a 43.07% reduction";

        if contains(txt,anchorR13)
            txt = replace(txt,anchorR13, ...
                r13Sentence + " R1_solution_3 showed a 43.07% reduction");
        else
            anchorBeforeR19 = "R1_solution_9 showed a lower relative reduction of 31.31%";
            if contains(txt,anchorBeforeR19)
                txt = replace(txt,anchorBeforeR19, ...
                    r13Sentence + " " + anchorBeforeR19);
            else
                error('Could not locate insertion point for R1_solution_3 baseline anchor.');
            end
        end
    end

    % ---------------------------------------------------------------
    % PATCH 3:
    % R1-9 baseline anchor with explicit kWh units.
    % ---------------------------------------------------------------
    r19Sentence = ...
        "For R1_solution_9, Q_aux decreased from 1773.9 kWh in gas-LPG-only mode to 1218.4 kWh in hybrid mode, corresponding to a 31.31% reduction.";

    if ~(contains(txt,"1773.9 kWh") && contains(txt,"1218.4 kWh") && contains(txt,"31.31%"))
        anchorR19 = "R1_solution_9 showed a lower relative reduction of 31.31%";

        if contains(txt,anchorR19)
            txt = replace(txt,anchorR19, ...
                r19Sentence + " R1_solution_9 showed a lower relative reduction of 31.31%");
        else
            anchorAfterR13 = "consistent with its more aggressive drying condition and higher auxiliary-energy demand.";
            if contains(txt,anchorAfterR13)
                txt = replace(txt,anchorAfterR13, ...
                    r19Sentence + " " + anchorAfterR13);
            else
                error('Could not locate insertion point for R1_solution_9 baseline anchor.');
            end
        end
    end

    % ---------------------------------------------------------------
    % Write patched MASTER
    % ---------------------------------------------------------------
    fid = fopen(masterFile,'w');
    if fid < 0
        error('Could not open master for writing: %s', masterFile);
    end
    fwrite(fid,txt);
    fclose(fid);

    patchedTxt = fileread(masterFile);
    s7low = lower(patchedTxt);

    % ---------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------
    checks = {};

    checks{end+1,1} = check_row("P07-01","Master exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("P07-02","Backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("P07-03","Master changed",~strcmp(originalTxt,patchedTxt),"Patch modified MASTER text.");
    checks{end+1,1} = check_row("P07-04","Fully coupled collector caveat present", ...
        contains(s7low,"fully coupled collector model") || contains(s7low,"not a fully coupled collector"), ...
        "S0711-33 patch.");
    checks{end+1,1} = check_row("P07-05","R1-3 baseline anchor present", ...
        contains(patchedTxt,"1270.6 kWh") && contains(patchedTxt,"723.36 kWh") && contains(patchedTxt,"43.07%"), ...
        "S0711-47 patch.");
    checks{end+1,1} = check_row("P07-06","R1-9 baseline anchor present", ...
        contains(patchedTxt,"1773.9 kWh") && contains(patchedTxt,"1218.4 kWh") && contains(patchedTxt,"31.31%"), ...
        "S0711-48 patch.");
    checks{end+1,1} = check_row("P07-07","No GA executed",true,"Text patch only.");
    checks{end+1,1} = check_row("P07-08","No model executed",true,"Text patch only.");
    checks{end+1,1} = check_row("P07-09","No numeric results changed intentionally",true,"Only explicit anchor/unit text was inserted.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(reviewDir,'PATCH_SECTION07_v01_1_AUDIT_FAILURES_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "PATCH_SECTION07_v01_1_AUDIT_FAILURES_PASS";
        decision = "READY_TO_RERUN_SECTION07_v01_1_AUDIT";
        next_step = "Rerun audit_results_section07_v01_1_hybrid_vs_gasLP_v96z.";
    else
        diagnosis = "PATCH_SECTION07_v01_1_AUDIT_FAILURES_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_PATCH_CHECKS";
        next_step = "Inspect failed patch checks before rerunning audit.";
    end

    reportMd = fullfile(reviewDir,'PATCH_SECTION07_v01_1_AUDIT_FAILURES_v96z_report.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open patch report: %s', reportMd);
    end

    fprintf(fid,'# PATCH_SECTION07_v01_1_AUDIT_FAILURES_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Master: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Checks: `%s`\n\n',checksCsv);

    fprintf(fid,'## Patch notes\n\n');
    fprintf(fid,'- Added explicit fully coupled collector model caveat if missing.\n');
    fprintf(fid,'- Added explicit R1_solution_3 gas-LPG/hybrid kWh anchor if missing.\n');
    fprintf(fid,'- Added explicit R1_solution_9 gas-LPG/hybrid kWh anchor if missing.\n');
    fprintf(fid,'- No GA executed.\n');
    fprintf(fid,'- No model executed.\n');
    fprintf(fid,'- No numerical results modified.\n\n');

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    outMat = fullfile(traceDir,'PATCH_SECTION07_v01_1_AUDIT_FAILURES_v96z.mat');

    save(outMat,'masterFile','backupFile','checksCsv','reportMd','Tchecks','diagnosis','decision','next_step');

    out = struct();
    out.status = "PATCH_SECTION07_v01_1_AUDIT_FAILURES_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.masterFile = masterFile;
    out.backupFile = backupFile;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;
    out.Tchecks = Tchecks;

    disp('=== PATCH SECTION 07 v01.1 AUDIT FAILURES v96z ===')
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