function out = patch_master_exitflag0_wording_v96z()
% PATCH_MASTER_EXITFLAG0_WORDING_v96z
%
% 9.6z-audit-a-fix
% PATCH-MASTER-EXITFLAG0-WORDING-001
%
% Objetivo:
%   Insertar una frase controlada en MASTER_manuscript_v01.md para que la
%   configuracion de reproducibilidad R1 preserve explicitamente:
%       exitflag 0
%   como terminacion por limite de generaciones, no como falla metodologica.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica resultados numericos.
% No modifica Section 7 si es detectable.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');
    lockDir = fullfile(articleRoot,'locked_sections');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');

    patchReport = fullfile(reviewDir,'PATCH_MASTER_EXITFLAG0_WORDING_v96z_report.md');
    patchChecks = fullfile(reviewDir,'PATCH_MASTER_EXITFLAG0_WORDING_v96z_Tchecks.csv');
    traceMat = fullfile(traceDir,'PATCH_MASTER_EXITFLAG0_WORDING_v96z.mat');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end

    masterBefore = fileread(masterFile);
    lowBefore = lower(string(masterBefore));
    section7Before = extract_section7_flexible(masterBefore);

    backupFile = fullfile(draftDir, ...
        ['MASTER_manuscript_v01_BEFORE_EXITFLAG0_PATCH_v96z_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);
    copyfile(masterFile,backupFile);

    targetPhrase = "The R1 run terminated with `exitflag 0`, corresponding to the prescribed generation limit rather than a convergence-failure interpretation.";
    alreadyPresent = contains(masterBefore,targetPhrase) || contains(lowBefore,"exitflag 0");

    if alreadyPresent
        patchAction = "NO_WRITE_EXITFLAG0_ALREADY_PRESENT";
        locationEvidence = "Detected exitflag 0 wording already present in MASTER.";
        masterAfter = masterBefore;
    else
        [idxInsert, locationEvidence] = find_exitflag_patch_insertion_point(masterBefore);

        patchBlock = newline + ...
            string(targetPhrase) + newline;

        prefix = masterBefore(1:idxInsert-1);
        suffix = masterBefore(idxInsert:end);

        masterAfter = [prefix(:).' char(patchBlock) suffix(:).'];

        fid = fopen(masterFile,'w');
        if fid < 0
            error('Could not open MASTER for writing: %s',masterFile);
        end
        fprintf(fid,'%s',masterAfter);
        fclose(fid);

        patchAction = "MASTER_UPDATED";
    end

    masterAfterRead = fileread(masterFile);
    lowAfter = lower(string(masterAfterRead));
    section7After = extract_section7_flexible(masterAfterRead);

    section7ProtectionOK = true;
    if strlength(string(section7Before)) > 0 && strlength(string(section7After)) > 0
        section7ProtectionOK = strcmp(section7Before,section7After);
    end

    checks = {};
    checks{end+1,1} = check_row("XFLG-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("XFLG-02","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("XFLG-03","Backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("XFLG-04","Patch action valid",patchAction=="MASTER_UPDATED" || patchAction=="NO_WRITE_EXITFLAG0_ALREADY_PRESENT",patchAction);
    checks{end+1,1} = check_row("XFLG-05","exitflag 0 phrase present",contains(lowAfter,"exitflag 0"),"Required audit anchor.");
    checks{end+1,1} = check_row("XFLG-06","Generation-limit interpretation present",contains(lowAfter,"generation limit"),"Generation-limit interpretation.");
    checks{end+1,1} = check_row("XFLG-07","No failure overclaim introduced",~contains(lowAfter,"convergence failure was demonstrated") && ~contains(lowAfter,"algorithm failed"),"No failure overclaim.");
    checks{end+1,1} = check_row("XFLG-08","Section 7 preserved when detectable",section7ProtectionOK,"Section 7 comparison flexible.");
    checks{end+1,1} = check_row("XFLG-09","No prohibited global optimum wording",~contains(lowAfter,"global optimum") && ~contains(lowAfter,"globally optimal"),"No prohibited wording.");
    checks{end+1,1} = check_row("XFLG-10","No prohibited global Pareto front wording",~contains(lowAfter,"global pareto front"),"No prohibited wording.");
    checks{end+1,1} = check_row("XFLG-11","No GA executed",true,"Text patch only.");
    checks{end+1,1} = check_row("XFLG-12","No model executed",true,"Text patch only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,patchChecks);

    if all(Tchecks.pass)
        diagnosis = "PATCH_MASTER_EXITFLAG0_WORDING_PASS";
        decision = "RERUN_MASTER_MANUSCRIPT_CONSISTENCY_AUDIT";
        next_step = "Re-run audit_master_manuscript_consistency_v96z.";
    else
        diagnosis = "PATCH_MASTER_EXITFLAG0_WORDING_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks before re-running master audit.";
    end

    fid = fopen(patchReport,'w');
    if fid < 0
        error('Could not open patch report: %s',patchReport);
    end

    fprintf(fid,'# PATCH_MASTER_EXITFLAG0_WORDING_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Patch action\n\n`%s`\n\n',patchAction);
    fprintf(fid,'## Location evidence\n\n`%s`\n\n',locationEvidence);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Checks: `%s`\n\n',patchChecks);

    fprintf(fid,'## Inserted/verified wording\n\n');
    fprintf(fid,'> %s\n\n',targetPhrase);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(traceMat,'masterFile','lockedSection7','backupFile','patchReport','patchChecks','traceMat','Tchecks','diagnosis','decision','next_step','patchAction','locationEvidence','targetPhrase');

    out = struct();
    out.status = "PATCH_MASTER_EXITFLAG0_WORDING_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.patchAction = patchAction;
    out.locationEvidence = locationEvidence;
    out.masterFile = masterFile;
    out.backupFile = backupFile;
    out.patchReport = patchReport;
    out.patchChecks = patchChecks;
    out.traceMat = traceMat;
    out.Tchecks = Tchecks;

    disp('=== PATCH MASTER EXITFLAG0 WORDING v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== ACTION ===')
    disp(out.patchAction)
    disp('=== LOCATION EVIDENCE ===')
    disp(out.locationEvidence)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.masterFile)
    disp(out.backupFile)
    disp(out.patchReport)
end

function [idxInsert, evidence] = find_exitflag_patch_insertion_point(txt)
    % Prefer immediately after the GA reproducibility heading/block.
    gaTitle = '### Reproducibility configuration of the formal multiobjective run';
    idxGa = strfind(txt,gaTitle);

    if ~isempty(idxGa)
        idxStart = idxGa(1) + length(gaTitle);
        laterHeadings = regexp(txt(idxStart:end),'(?m)^#{1,6}\s+.*$','start');
        if ~isempty(laterHeadings)
            idxInsert = idxStart + laterHeadings(1) - 2;
            evidence = "Inserted before next heading after GA reproducibility paragraph.";
        else
            idxInsert = length(txt) + 1;
            evidence = "Inserted at end after GA reproducibility paragraph.";
        end
        return
    end

    % Fallback: after first mention of gamultiobj paragraph.
    idxAlgo = strfind(lower(txt),'gamultiobj');
    if ~isempty(idxAlgo)
        paraEndRel = regexp(txt(idxAlgo(1):end),'\n\s*\n','once');
        if ~isempty(paraEndRel)
            idxInsert = idxAlgo(1) + paraEndRel;
            evidence = "Inserted after first gamultiobj paragraph.";
        else
            idxInsert = length(txt) + 1;
            evidence = "Inserted at end after gamultiobj mention.";
        end
        return
    end

    idxInsert = length(txt) + 1;
    evidence = "No GA block detected; inserted at end of MASTER.";
end

function s7 = extract_section7_flexible(txt)
    idxStart = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','once');
    if isempty(idxStart)
        s7 = '';
        return
    end

    rest = txt(idxStart+1:end);
    idxNext = regexp(rest,'(?m)^#{1,6}\s*(?:8[\.\)]?\s+|Discussion\b|Conclusions\b|Conclusion\b|Conclusiones\b|Limitations\b|References\b|Referencias\b).*$','once');

    if isempty(idxNext)
        s7 = txt(idxStart:end);
    else
        idxEnd = idxStart + idxNext - 1;
        s7 = txt(idxStart:idxEnd);
    end
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end
