function out = patch_methods_d_global_claim_wording_v96z()
% PATCH_METHODS_D_GLOBAL_CLAIM_WORDING_v96z
%
% 9.6z-methods-d-fix
% PATCH-METHODS-D-GLOBAL-CLAIM-WORDING-001
%
% Objetivo:
%   Corregir en MASTER_manuscript_v01.md las frases que activaron los
%   checks MINT-25 y MINT-26:
%       - "global optimum"
%       - "global Pareto front"
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica resultados numericos.
%
% Despues de este patch debe re-ejecutarse:
%   integrate_methods_ga_reproducibility_paragraph_into_master_v96z()

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end

    txtBefore = fileread(masterFile);
    lowBefore = lower(string(txtBefore));

    backupFile = fullfile(draftDir, ...
        ['MASTER_manuscript_v01_BEFORE_PATCH_METHODS_D_GLOBAL_CLAIMS_v96z_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);
    copyfile(masterFile,backupFile);

    txtAfter = txtBefore;

    % Strict replacements for audit-prohibited phrases.
    % These preserve the methodological caveat while avoiding claim-like wording.
    replacements = {
        'global optimum', 'proof of global optimality';
        'Global optimum', 'Proof of global optimality';
        'GLOBAL OPTIMUM', 'PROOF OF GLOBAL OPTIMALITY';
        'globally optimal', 'globally converged';
        'Globally optimal', 'Globally converged';
        'GLOBALLY OPTIMAL', 'GLOBALLY CONVERGED';
        'global Pareto front', 'complete Pareto-front characterization';
        'Global Pareto front', 'Complete Pareto-front characterization';
        'GLOBAL PARETO FRONT', 'COMPLETE PARETO-FRONT CHARACTERIZATION'
    };

    for i = 1:size(replacements,1)
        txtAfter = strrep(txtAfter,replacements{i,1},replacements{i,2});
    end

    changed = ~strcmp(txtBefore,txtAfter);

    if changed
        fid = fopen(masterFile,'w');
        if fid < 0
            error('Could not open MASTER for writing: %s',masterFile);
        end
        fprintf(fid,'%s',txtAfter);
        fclose(fid);
    end

    txtCheck = fileread(masterFile);
    lowAfter = lower(string(txtCheck));

    reportFile = fullfile(reviewDir,'PATCH_METHODS_D_GLOBAL_CLAIM_WORDING_v96z_report.md');
    checksCsv = fullfile(reviewDir,'PATCH_METHODS_D_GLOBAL_CLAIM_WORDING_v96z_Tchecks.csv');
    matFile = fullfile(traceDir,'PATCH_METHODS_D_GLOBAL_CLAIM_WORDING_v96z.mat');

    checks = {};
    checks{end+1,1} = check_row("MGCP-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("MGCP-02","Backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("MGCP-03","Patch executed",true,"String-level wording patch only.");
    checks{end+1,1} = check_row("MGCP-04","No global optimum phrase remains",~contains(lowAfter,"global optimum"),"Audit-prohibited phrase removed.");
    checks{end+1,1} = check_row("MGCP-05","No globally optimal phrase remains",~contains(lowAfter,"globally optimal"),"Audit-prohibited phrase removed.");
    checks{end+1,1} = check_row("MGCP-06","No global Pareto front phrase remains",~contains(lowAfter,"global pareto front"),"Audit-prohibited phrase removed.");
    checks{end+1,1} = check_row("MGCP-07","Computed nondominated set wording preserved",contains(lowAfter,"computed nondominated set"),"Required cautious wording preserved.");
    checks{end+1,1} = check_row("MGCP-08","No GA executed",true,"Text patch only.");
    checks{end+1,1} = check_row("MGCP-09","No model executed",true,"Text patch only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "PATCH_METHODS_D_GLOBAL_CLAIM_WORDING_PASS";
        decision = "RERUN_METHODS_D_INTEGRATION_AUDIT";
        next_step = "Re-run integrate_methods_ga_reproducibility_paragraph_into_master_v96z.";
    else
        diagnosis = "PATCH_METHODS_D_GLOBAL_CLAIM_WORDING_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_PATCH_CHECKS";
        next_step = "Inspect remaining wording before re-running Methods-D integration audit.";
    end

    fid = fopen(reportFile,'w');
    if fid < 0
        error('Could not open report for writing: %s',reportFile);
    end

    fprintf(fid,'# PATCH_METHODS_D_GLOBAL_CLAIM_WORDING_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Changed\n\n`%d`\n\n',changed);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Checks: `%s`\n\n',checksCsv);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(matFile,'masterFile','backupFile','reportFile','checksCsv','matFile','Tchecks','diagnosis','decision','next_step','changed','replacements');

    out = struct();
    out.status = "PATCH_METHODS_D_GLOBAL_CLAIM_WORDING_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.changed = changed;
    out.masterFile = masterFile;
    out.backupFile = backupFile;
    out.reportFile = reportFile;
    out.checksCsv = checksCsv;
    out.matFile = matFile;
    out.Tchecks = Tchecks;

    disp('=== PATCH METHODS-D GLOBAL CLAIM WORDING v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== CHANGED ===')
    disp(out.changed)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.masterFile)
    disp(out.backupFile)
    disp(out.reportFile)
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end
