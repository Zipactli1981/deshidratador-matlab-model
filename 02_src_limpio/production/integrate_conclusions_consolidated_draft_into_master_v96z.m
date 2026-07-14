function out = integrate_conclusions_consolidated_draft_into_master_v96z()
% INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_INTO_MASTER_v96z
%
% 9.6z-conclusions-b
% INTEGRATE-CONCLUSIONS-CONSOLIDATED-DRAFT-INTO-MASTER-001
%
% Objetivo:
%   Integrar en MASTER_manuscript_v01.md la seccion Conclusions consolidada
%   aprobada en 9.6z-conclusions-a.
%
% Criterio de ubicacion:
%   - Despues de Discussion/Limitations si existen.
%   - Antes de References si es detectable.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica resultados numericos.
% Protege Section 7 si es detectable.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');
    lockDir = fullfile(articleRoot,'locked_sections');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');

    secFile = fullfile(draftDir,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z.md');
    secReport = fullfile(reviewDir,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z_report.md');
    secChecks = fullfile(reviewDir,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z_Tchecks.csv');

    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');
    afterDiscussionAudit = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z_report.md');
    discussionIntegrationReport = fullfile(reviewDir,'INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md');
    limitationsIntegrationReport = fullfile(reviewDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md');

    integrationReport = fullfile(reviewDir,'INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md');
    integrationChecks = fullfile(reviewDir,'INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_Tchecks.csv');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_conclusions_b.txt');
    traceMat = fullfile(traceDir,'INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_INTO_MASTER_v96z.mat');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end
    if ~isfile(secFile)
        error('Conclusions section file not found: %s',secFile);
    end
    if ~isfile(secReport)
        error('Conclusions report not found: %s',secReport);
    end

    secText = fileread(secFile);
    secReportText = fileread(secReport);

    sourcePass = contains(secReportText,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_PASS') && ...
                 contains(secReportText,'READY_FOR_CONCLUSIONS_INTEGRATION') && ...
                 contains(secText,'SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z_READY_FOR_CONCLUSIONS_INTEGRATION');

    if ~sourcePass
        error('Source Conclusions draft does not show PASS/READY status in report and section file.');
    end

    masterBefore = fileread(masterFile);
    section7Before = extract_section7_flexible(masterBefore);

    englishBlock = extract_between(secText, ...
        '## Manuscript text -- English', ...
        '## Version tecnica de control -- Espanol');

    englishBlock = strip(string(englishBlock));
    englishBlock = regexprep(englishBlock,"^\s*## Manuscript text -- English\s*","");

    insertionTitle = "### Conclusions";
    insertionKey = "This study developed a controlled multiobjective optimization and post-processing workflow";
    insertionBlock = newline + newline + string(englishBlock) + newline;

    if strlength(englishBlock) < 1200
        error('Extracted English Conclusions block is unexpectedly short. Check source file: %s',secFile);
    end

    write_headings_report(masterBefore,headingsReport);

    alreadyIntegrated = contains(string(masterBefore),insertionKey);

    backupFile = fullfile(draftDir, ...
        ['MASTER_manuscript_v01_BEFORE_CONCLUSIONS_BLOCK_v96z_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);

    copyfile(masterFile,backupFile);

    if alreadyIntegrated
        integrationAction = "NO_WRITE_ALREADY_INTEGRATED";
        locationEvidence = "Detected previous consolidated Conclusions block in MASTER; no new write performed.";
    else
        [idxInsert, locationEvidence] = find_conclusions_insertion_point(masterBefore);

        prefix = masterBefore(1:idxInsert-1);
        suffix = masterBefore(idxInsert:end);

        masterAfter = [prefix(:).' char(insertionBlock) suffix(:).'];

        fid = fopen(masterFile,'w');
        if fid < 0
            error('Could not open MASTER for writing: %s',masterFile);
        end
        fprintf(fid,'%s',masterAfter);
        fclose(fid);

        integrationAction = "MASTER_UPDATED";
    end

    masterAfterRead = fileread(masterFile);
    section7After = extract_section7_flexible(masterAfterRead);

    countConclusionsKey = count(string(masterAfterRead),insertionKey);
    countConclusionsTitle = count(string(masterAfterRead),insertionTitle);
    lowMasterAfter = lower(string(masterAfterRead));

    section7ProtectionOK = true;
    if strlength(string(section7Before)) > 0 && strlength(string(section7After)) > 0
        section7ProtectionOK = strcmp(section7Before,section7After);
    end

    afterDiscussionOrLimitationsOK = appears_after_discussion_or_limitations(masterAfterRead,insertionKey);
    beforeReferencesOK = appears_before_references(masterAfterRead,insertionKey);

    checks = {};
    checks{end+1,1} = check_row("CINT-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("CINT-02","Source Conclusions draft exists",isfile(secFile),secFile);
    checks{end+1,1} = check_row("CINT-03","Source Conclusions report exists",isfile(secReport),secReport);
    checks{end+1,1} = check_row("CINT-04","Source Conclusions checks file exists",isfile(secChecks),secChecks);
    checks{end+1,1} = check_row("CINT-05","Source Conclusions PASS verified",sourcePass,"PASS verified from report and section.");
    checks{end+1,1} = check_row("CINT-06","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("CINT-07","After-Discussion audit report exists",isfile(afterDiscussionAudit),afterDiscussionAudit);
    checks{end+1,1} = check_row("CINT-08","Discussion integration report exists",isfile(discussionIntegrationReport),discussionIntegrationReport);
    checks{end+1,1} = check_row("CINT-09","Limitations integration report exists",isfile(limitationsIntegrationReport),limitationsIntegrationReport);
    checks{end+1,1} = check_row("CINT-10","MASTER backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("CINT-11","MASTER headings diagnostic report created",isfile(headingsReport),headingsReport);
    checks{end+1,1} = check_row("CINT-12","Integration action valid",integrationAction=="MASTER_UPDATED" || integrationAction=="NO_WRITE_ALREADY_INTEGRATED",integrationAction);

    checks{end+1,1} = check_row("CINT-13","Conclusions block key present once",countConclusionsKey==1,"Key count = " + string(countConclusionsKey) + ".");
    checks{end+1,1} = check_row("CINT-14","Conclusions title present",countConclusionsTitle>=1,"Title count = " + string(countConclusionsTitle) + ".");
    checks{end+1,1} = check_row("CINT-15","No excessive Conclusions duplication",countConclusionsKey<=1,"Key count = " + string(countConclusionsKey) + ".");
    checks{end+1,1} = check_row("CINT-16","Section 7 preserved when Section 7 is detectable",section7ProtectionOK,"Section 7 comparison flexible.");
    checks{end+1,1} = check_row("CINT-17","Conclusions appears after Discussion/Limitations when detectable",afterDiscussionOrLimitationsOK,"Conclusions after Discussion/Limitations or no such heading detected.");
    checks{end+1,1} = check_row("CINT-18","Conclusions appears before References when detectable",beforeReferencesOK,"Conclusions before References or no References heading detected.");

    checks{end+1,1} = check_row("CINT-19","Hybrid energy-saving conclusion preserved",contains(lowMasterAfter,"hybrid") && contains(lowMasterAfter,"energy-saving"),"Hybrid conclusion.");
    checks{end+1,1} = check_row("CINT-20","R1_solution_7 conclusion preserved",contains(masterAfterRead,"R1_solution_7") && contains(lowMasterAfter,"energy-conservative"),"R1_solution_7.");
    checks{end+1,1} = check_row("CINT-21","R1_solution_3 conclusion preserved",contains(masterAfterRead,"R1_solution_3") && contains(lowMasterAfter,"balanced"),"R1_solution_3.");
    checks{end+1,1} = check_row("CINT-22","R1_solution_9 conclusion preserved",contains(masterAfterRead,"R1_solution_9") && contains(lowMasterAfter,"aggressive"),"R1_solution_9.");
    checks{end+1,1} = check_row("CINT-23","H2 historical reference preserved",contains(masterAfterRead,"H2") && contains(lowMasterAfter,"historical reference"),"H2.");
    checks{end+1,1} = check_row("CINT-24","H2 not-new-R1 caveat preserved",contains(lowMasterAfter,"rather than as a newly optimized r1 solution"),"H2 caveat.");

    checks{end+1,1} = check_row("CINT-25","Computed nondominated set wording preserved",contains(lowMasterAfter,"computed nondominated set"),"Computed nondominated set.");
    checks{end+1,1} = check_row("CINT-26","2-SAH conclusion preserved",contains(lowMasterAfter,"2-sah") && contains(lowMasterAfter,"sensitivity"),"2-SAH.");
    checks{end+1,1} = check_row("CINT-27","Collector limitation preserved",contains(lowMasterAfter,"fully coupled dynamic collector model") || contains(lowMasterAfter,"fully coupled dynamic collector simulation"),"Collector caveat.");
    checks{end+1,1} = check_row("CINT-28","Hybrid vs gas-LPG conclusion preserved",contains(lowMasterAfter,"hybrid versus gas-lpg") || (contains(lowMasterAfter,"hybrid") && contains(lowMasterAfter,"gas-lpg")),"Hybrid baseline.");
    checks{end+1,1} = check_row("CINT-29","Solar/fuel substitution conclusion preserved",contains(lowMasterAfter,"fuel substitution") || contains(lowMasterAfter,"solar substitution"),"Fuel substitution.");

    checks{end+1,1} = check_row("CINT-30","Cost/CO2 conditionality preserved",contains(lowMasterAfter,"conditional") && contains(lowMasterAfter,"emission-factor"),"Cost/CO2 conditionality.");
    checks{end+1,1} = check_row("CINT-31","Future seed replications preserved",contains(lowMasterAfter,"additional random seeds"),"Future seeds.");
    checks{end+1,1} = check_row("CINT-32","Future coupled collector preserved",contains(lowMasterAfter,"coupled collector"),"Future collector.");
    checks{end+1,1} = check_row("CINT-33","Future fan-power preserved",contains(lowMasterAfter,"fan-power"),"Future fan power.");
    checks{end+1,1} = check_row("CINT-34","Future pressure-drop preserved",contains(lowMasterAfter,"pressure-drop"),"Future pressure drop.");
    checks{end+1,1} = check_row("CINT-35","Future final factors preserved",contains(lowMasterAfter,"finalize the economic and emission factors"),"Future factors.");

    checks{end+1,1} = check_row("CINT-36","No prohibited global optimum phrase introduced",~contains(lowMasterAfter,"global optimum") && ~contains(lowMasterAfter,"globally optimal"),"No prohibited wording.");
    checks{end+1,1} = check_row("CINT-37","No prohibited global Pareto front phrase introduced",~contains(lowMasterAfter,"global pareto front"),"No prohibited wording.");
    checks{end+1,1} = check_row("CINT-38","No statistical robustness claim introduced",~contains(lowMasterAfter,"statistically robust") && ~contains(lowMasterAfter,"robust across seeds"),"No robustness overclaim.");
    checks{end+1,1} = check_row("CINT-39","Complete convergence caveat preserved",contains(lowMasterAfter,"should not be interpreted as proof of complete search-space convergence"),"Convergence caveat.");
    checks{end+1,1} = check_row("CINT-40","Complete equipment optimality caveat preserved",contains(lowMasterAfter,"complete equipment-level optimality"),"Equipment caveat.");

    checks{end+1,1} = check_row("CINT-41","No final CO2 claim introduced",~contains(lowMasterAfter,"final co2 reduction") && ~contains(lowMasterAfter,"final emission reduction") && ~contains(lowMasterAfter,"definitive emission reduction"),"No final CO2 claim.");
    checks{end+1,1} = check_row("CINT-42","No final cost claim introduced",~contains(lowMasterAfter,"final cost reduction") && ~contains(lowMasterAfter,"final economic saving") && ~contains(lowMasterAfter,"definitive economic saving"),"No final cost claim.");
    checks{end+1,1} = check_row("CINT-43","No GA executed",true,"Text integration only.");
    checks{end+1,1} = check_row("CINT-44","No model executed",true,"Text integration only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,integrationChecks);

    if all(Tchecks.pass)
        diagnosis = "INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_PASS";
        decision = "MASTER_UPDATED_WITH_CONCLUSIONS_CONSOLIDATED_DRAFT";
        next_step = "Run final MASTER manuscript consistency audit after Conclusions.";
    else
        diagnosis = "INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and headings diagnostic report.";
    end

    fid = fopen(integrationReport,'w');
    if fid < 0
        error('Could not open integration report for writing: %s',integrationReport);
    end

    fprintf(fid,'# INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_INTO_MASTER_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Integration action\n\n`%s`\n\n',integrationAction);
    fprintf(fid,'## Insertion evidence\n\n`%s`\n\n',locationEvidence);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Source Conclusions draft: `%s`\n',secFile);
    fprintf(fid,'- Source report: `%s`\n',secReport);
    fprintf(fid,'- Source checks file: `%s`\n',secChecks);
    fprintf(fid,'- Integration checks: `%s`\n',integrationChecks);
    fprintf(fid,'- Headings diagnostic report: `%s`\n',headingsReport);
    fprintf(fid,'- Locked Section 7: `%s`\n\n',lockedSection7);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(traceMat,'masterFile','backupFile','secFile','secReport','secChecks','lockedSection7','afterDiscussionAudit','discussionIntegrationReport','limitationsIntegrationReport','integrationReport','integrationChecks','headingsReport','traceMat','Tchecks','diagnosis','decision','next_step','integrationAction','locationEvidence','sourcePass');

    out = struct();
    out.status = "INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.integrationAction = integrationAction;
    out.locationEvidence = locationEvidence;
    out.masterFile = masterFile;
    out.backupFile = backupFile;
    out.secFile = secFile;
    out.integrationReport = integrationReport;
    out.integrationChecks = integrationChecks;
    out.headingsReport = headingsReport;
    out.traceMat = traceMat;
    out.Tchecks = Tchecks;

    disp('=== INTEGRATE CONCLUSIONS CONSOLIDATED DRAFT INTO MASTER v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== ACTION ===')
    disp(out.integrationAction)
    disp('=== INSERTION EVIDENCE ===')
    disp(out.locationEvidence)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.masterFile)
    disp(out.backupFile)
    disp(out.integrationReport)
    disp(out.headingsReport)
end

function [idxInsert, evidence] = find_conclusions_insertion_point(txt)
    % Prefer before References.
    refStarts = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:References|Referencias)\b.*$','start');
    if ~isempty(refStarts)
        idxInsert = refStarts(1);
        evidence = "Inserted before detected References heading.";
        return
    end

    % Otherwise after Limitations, if present.
    [headStarts, headMatches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');
    limIdx = [];
    for i = 1:numel(headMatches)
        h = lower(string(headMatches{i}));
        if contains(h,"limitations") || contains(h,"limitaciones")
            limIdx(end+1) = i; %#ok<AGROW>
        end
    end
    if ~isempty(limIdx)
        lastStart = headStarts(limIdx(end));
        laterHeadings = headStarts(headStarts > lastStart);
        if ~isempty(laterHeadings)
            idxInsert = laterHeadings(1);
            evidence = "Inserted before next heading after Limitations.";
        else
            idxInsert = length(txt) + 1;
            evidence = "Inserted at end of MASTER after Limitations.";
        end
        return
    end

    % Otherwise after Discussion, if present.
    discIdx = [];
    for i = 1:numel(headMatches)
        h = lower(string(headMatches{i}));
        if contains(h,"discussion") || contains(h,"discusion") || contains(h,"discusión")
            discIdx(end+1) = i; %#ok<AGROW>
        end
    end
    if ~isempty(discIdx)
        lastStart = headStarts(discIdx(end));
        laterHeadings = headStarts(headStarts > lastStart);
        if ~isempty(laterHeadings)
            idxInsert = laterHeadings(1);
            evidence = "Inserted before next heading after Discussion.";
        else
            idxInsert = length(txt) + 1;
            evidence = "Inserted at end of MASTER after Discussion.";
        end
        return
    end

    idxInsert = length(txt) + 1;
    evidence = "No References/Limitations/Discussion heading detected; inserted at end of MASTER.";
end

function block = extract_between(txt,startMarker,endMarker)
    idx1 = strfind(txt,startMarker);
    idx2 = strfind(txt,endMarker);

    if isempty(idx1)
        error('Start marker not found: %s',startMarker);
    end
    if isempty(idx2)
        error('End marker not found: %s',endMarker);
    end

    idx1 = idx1(1) + length(startMarker);
    idx2 = idx2(find(idx2 > idx1,1,'first'));

    if isempty(idx2)
        error('End marker occurs before start marker.');
    end

    block = txt(idx1:idx2-1);
end

function s7 = extract_section7_flexible(txt)
    idxStart = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','once');
    if isempty(idxStart)
        s7 = '';
        return
    end

    rest = txt(idxStart+1:end);
    idxNext = regexp(rest,'(?m)^#{1,6}\s*(?:8[\.\)]?\s+|Discussion\b|Limitations\b|Conclusions\b|Conclusion\b|Conclusiones\b|References\b|Referencias\b).*$','once');

    if isempty(idxNext)
        s7 = txt(idxStart:end);
    else
        idxEnd = idxStart + idxNext - 1;
        s7 = txt(idxStart:idxEnd);
    end
end

function tf = appears_after_discussion_or_limitations(txt,key)
    idxKey = strfind(txt,key);
    if isempty(idxKey)
        tf = false;
        return
    end

    starts = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Discussion|Discusion|Discusión|Limitations|Limitaciones)\b.*$','start');
    if isempty(starts)
        tf = true;
    else
        tf = idxKey(1) > starts(end);
    end
end

function tf = appears_before_references(txt,key)
    idxKey = strfind(txt,key);
    if isempty(idxKey)
        tf = false;
        return
    end

    refs = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:References|Referencias)\b.*$','start');
    if isempty(refs)
        tf = true;
    else
        tf = idxKey(1) < refs(1);
    end
end

function write_headings_report(txt,filename)
    [starts,matches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not write headings report: %s',filename);
    end
    fprintf(fid,'MASTER headings detected for Conclusions consolidated draft integration\n\n');
    if isempty(matches)
        fprintf(fid,'No Markdown headings detected.\n');
    else
        for i = 1:numel(matches)
            fprintf(fid,'%04d | char %08d | %s\n',i,starts(i),matches{i});
        end
    end
    fclose(fid);
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end
