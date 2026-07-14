function out = integrate_discussion_consolidated_draft_into_master_v96z()
% INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z
%
% 9.6z-discussion-b
% INTEGRATE-DISCUSSION-CONSOLIDATED-DRAFT-INTO-MASTER-001
%
% Objetivo:
%   Integrar en MASTER_manuscript_v01.md la seccion Discussion consolidada
%   aprobada en 9.6z-discussion-a.
%
% Criterio de ubicacion:
%   - Despues de Results/Section 7.
%   - Antes de Limitations, Conclusions o References si son detectables.
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

    secFile = fullfile(draftDir,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z.md');
    secReport = fullfile(reviewDir,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z_report.md');
    secChecks = fullfile(reviewDir,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z_Tchecks.csv');

    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');
    masterAuditReport = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z_report.md');
    limitationsIntegrationReport = fullfile(reviewDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md');

    integrationReport = fullfile(reviewDir,'INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md');
    integrationChecks = fullfile(reviewDir,'INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_Tchecks.csv');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_discussion_b.txt');
    traceMat = fullfile(traceDir,'INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z.mat');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end
    if ~isfile(secFile)
        error('Discussion section file not found: %s',secFile);
    end
    if ~isfile(secReport)
        error('Discussion report not found: %s',secReport);
    end

    secText = fileread(secFile);
    secReportText = fileread(secReport);

    sourcePass = contains(secReportText,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_PASS') && ...
                 contains(secReportText,'READY_FOR_DISCUSSION_INTEGRATION') && ...
                 contains(secText,'SEC_DISCUSSION_CONSOLIDATED_DRAFT_v96z_READY_FOR_DISCUSSION_INTEGRATION');

    if ~sourcePass
        error('Source Discussion draft does not show PASS/READY status in report and section file.');
    end

    masterBefore = fileread(masterFile);
    section7Before = extract_section7_flexible(masterBefore);

    englishBlock = extract_between(secText, ...
        '## Manuscript text -- English', ...
        '## Version tecnica de control -- Espanol');

    englishBlock = strip(string(englishBlock));
    englishBlock = regexprep(englishBlock,"^\s*## Manuscript text -- English\s*","");

    insertionTitle = "### Discussion";
    insertionKey = "The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate";
    insertionBlock = newline + newline + string(englishBlock) + newline;

    if strlength(englishBlock) < 1200
        error('Extracted English Discussion block is unexpectedly short. Check source file: %s',secFile);
    end

    write_headings_report(masterBefore,headingsReport);

    alreadyIntegrated = contains(string(masterBefore),insertionKey);

    backupFile = fullfile(draftDir, ...
        ['MASTER_manuscript_v01_BEFORE_DISCUSSION_BLOCK_v96z_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);

    copyfile(masterFile,backupFile);

    if alreadyIntegrated
        integrationAction = "NO_WRITE_ALREADY_INTEGRATED";
        locationEvidence = "Detected previous consolidated Discussion block in MASTER; no new write performed.";
    else
        [idxInsert, locationEvidence] = find_discussion_insertion_point(masterBefore);

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

    countDiscussionKey = count(string(masterAfterRead),insertionKey);
    countDiscussionTitle = count(string(masterAfterRead),insertionTitle);
    lowMasterAfter = lower(string(masterAfterRead));

    section7ProtectionOK = true;
    if strlength(string(section7Before)) > 0 && strlength(string(section7After)) > 0
        section7ProtectionOK = strcmp(section7Before,section7After);
    end

    beforeLimitations = extract_before_heading(masterAfterRead,["### Limitations","## Limitations","# Limitations","### Conclusions","## Conclusions","# Conclusions","### References","## References","# References"]);
    afterResults = extract_after_results(masterAfterRead);

    checks = {};
    checks{end+1,1} = check_row("DINT-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("DINT-02","Source Discussion draft exists",isfile(secFile),secFile);
    checks{end+1,1} = check_row("DINT-03","Source Discussion report exists",isfile(secReport),secReport);
    checks{end+1,1} = check_row("DINT-04","Source Discussion checks file exists",isfile(secChecks),secChecks);
    checks{end+1,1} = check_row("DINT-05","Source Discussion PASS verified",sourcePass,"PASS verified from report and section.");
    checks{end+1,1} = check_row("DINT-06","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("DINT-07","MASTER audit report exists",isfile(masterAuditReport),masterAuditReport);
    checks{end+1,1} = check_row("DINT-08","Limitations integration report exists",isfile(limitationsIntegrationReport),limitationsIntegrationReport);
    checks{end+1,1} = check_row("DINT-09","MASTER backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("DINT-10","MASTER headings diagnostic report created",isfile(headingsReport),headingsReport);
    checks{end+1,1} = check_row("DINT-11","Integration action valid",integrationAction=="MASTER_UPDATED" || integrationAction=="NO_WRITE_ALREADY_INTEGRATED",integrationAction);

    checks{end+1,1} = check_row("DINT-12","Discussion block key present once",countDiscussionKey==1,"Key count = " + string(countDiscussionKey) + ".");
    checks{end+1,1} = check_row("DINT-13","Discussion title present",countDiscussionTitle>=1,"Title count = " + string(countDiscussionTitle) + ".");
    checks{end+1,1} = check_row("DINT-14","No excessive Discussion duplication",countDiscussionKey<=1,"Key count = " + string(countDiscussionKey) + ".");
    checks{end+1,1} = check_row("DINT-15","Section 7 preserved when Section 7 is detectable",section7ProtectionOK,"Section 7 comparison flexible.");
    checks{end+1,1} = check_row("DINT-16","Discussion appears after Results when Results detectable",contains(lower(string(afterResults)),lower(insertionKey)) || ~has_results_heading(masterAfterRead),"Discussion after Results or no Results heading detected.");
    checks{end+1,1} = check_row("DINT-17","Discussion appears before Limitations/Conclusions/References when detectable",contains(lower(string(beforeLimitations)),lower(insertionKey)) || ~has_post_discussion_heading(masterAfterRead),"Discussion before post-Discussion headings or no such heading detected.");

    checks{end+1,1} = check_row("DINT-18","R1_solution_7 interpretation preserved",contains(masterAfterRead,"R1_solution_7") && contains(lowMasterAfter,"energy-conservative"),"R1_solution_7.");
    checks{end+1,1} = check_row("DINT-19","R1_solution_3 interpretation preserved",contains(masterAfterRead,"R1_solution_3") && contains(lowMasterAfter,"balanced"),"R1_solution_3.");
    checks{end+1,1} = check_row("DINT-20","R1_solution_9 interpretation preserved",contains(masterAfterRead,"R1_solution_9") && contains(lowMasterAfter,"aggressive"),"R1_solution_9.");
    checks{end+1,1} = check_row("DINT-21","H2 historical reference preserved",contains(masterAfterRead,"H2") && contains(lowMasterAfter,"historical reference"),"H2.");
    checks{end+1,1} = check_row("DINT-22","H2 not-new-R1 caveat preserved",contains(lowMasterAfter,"not be interpreted as a newly optimized r1 solution"),"H2 caveat.");

    checks{end+1,1} = check_row("DINT-23","Computed nondominated set wording preserved",contains(lowMasterAfter,"computed nondominated set"),"Computed nondominated set.");
    checks{end+1,1} = check_row("DINT-24","No prohibited global optimum phrase introduced",~contains(lowMasterAfter,"global optimum") && ~contains(lowMasterAfter,"globally optimal"),"No prohibited wording.");
    checks{end+1,1} = check_row("DINT-25","No prohibited global Pareto front phrase introduced",~contains(lowMasterAfter,"global pareto front"),"No prohibited wording.");
    checks{end+1,1} = check_row("DINT-26","No statistical robustness claim introduced",~contains(lowMasterAfter,"statistically robust") && ~contains(lowMasterAfter,"robust across seeds"),"No robustness overclaim.");
    checks{end+1,1} = check_row("DINT-27","Statistical robustness caveat preserved",contains(lowMasterAfter,"not be interpreted as evidence of statistical robustness"),"Robustness caveat.");

    checks{end+1,1} = check_row("DINT-28","2-SAH sensitivity discussion preserved",contains(lowMasterAfter,"2-sah") && contains(lowMasterAfter,"sensitivity"),"2-SAH.");
    checks{end+1,1} = check_row("DINT-29","Collector caveat preserved",contains(lowMasterAfter,"fully coupled dynamic collector simulation") || contains(lowMasterAfter,"fully coupled dynamic collector model"),"Collector caveat.");
    checks{end+1,1} = check_row("DINT-30","Hybrid vs gas-LPG discussion preserved",contains(lowMasterAfter,"hybrid versus gas-lpg") || contains(lowMasterAfter,"hybrid") && contains(lowMasterAfter,"gas-lpg"),"Hybrid baseline.");
    checks{end+1,1} = check_row("DINT-31","Solar substitution interpretation preserved",contains(lowMasterAfter,"solar substitution"),"Solar substitution.");
    checks{end+1,1} = check_row("DINT-32","Cost/CO2 conditionality preserved",contains(lowMasterAfter,"conditional on") && contains(lowMasterAfter,"emission-factor"),"Cost/CO2 conditionality.");
    checks{end+1,1} = check_row("DINT-33","Fan-power limitation preserved",contains(lowMasterAfter,"fan-power") || contains(lowMasterAfter,"fan power"),"Fan-power.");
    checks{end+1,1} = check_row("DINT-34","Pressure-drop limitation preserved",contains(lowMasterAfter,"pressure-drop") || contains(lowMasterAfter,"pressure drop"),"Pressure-drop.");

    checks{end+1,1} = check_row("DINT-35","No final CO2 claim introduced",~contains(lowMasterAfter,"final co2 reduction") && ~contains(lowMasterAfter,"final emission reduction") && ~contains(lowMasterAfter,"definitive emission reduction"),"No final CO2 claim.");
    checks{end+1,1} = check_row("DINT-36","No final cost claim introduced",~contains(lowMasterAfter,"final cost reduction") && ~contains(lowMasterAfter,"final economic saving") && ~contains(lowMasterAfter,"definitive economic saving"),"No final cost claim.");
    checks{end+1,1} = check_row("DINT-37","No GA executed",true,"Text integration only.");
    checks{end+1,1} = check_row("DINT-38","No model executed",true,"Text integration only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,integrationChecks);

    if all(Tchecks.pass)
        diagnosis = "INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_PASS";
        decision = "MASTER_UPDATED_WITH_DISCUSSION_CONSOLIDATED_DRAFT";
        next_step = "Re-run MASTER manuscript consistency audit or proceed to Conclusions drafting.";
    else
        diagnosis = "INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and headings diagnostic report.";
    end

    fid = fopen(integrationReport,'w');
    if fid < 0
        error('Could not open integration report for writing: %s',integrationReport);
    end

    fprintf(fid,'# INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Integration action\n\n`%s`\n\n',integrationAction);
    fprintf(fid,'## Insertion evidence\n\n`%s`\n\n',locationEvidence);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Source Discussion draft: `%s`\n',secFile);
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

    save(traceMat,'masterFile','backupFile','secFile','secReport','secChecks','lockedSection7','masterAuditReport','limitationsIntegrationReport','integrationReport','integrationChecks','headingsReport','traceMat','Tchecks','diagnosis','decision','next_step','integrationAction','locationEvidence','sourcePass');

    out = struct();
    out.status = "INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_DONE";
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

    disp('=== INTEGRATE DISCUSSION CONSOLIDATED DRAFT INTO MASTER v96z ===')
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

function [idxInsert, evidence] = find_discussion_insertion_point(txt)
    [headStarts, headMatches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');

    % Prefer before Limitations/Conclusions/References.
    targetStarts = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Limitations|Conclusions|Conclusion|Conclusiones|References|Referencias)\b.*$','start');
    if ~isempty(targetStarts)
        idxInsert = targetStarts(1);
        evidence = "Inserted before detected Limitations/Conclusions/References heading.";
        return
    end

    % Otherwise insert after Results/Section 7 block.
    resultIdx = [];
    for i = 1:numel(headMatches)
        h = lower(string(headMatches{i}));
        if contains(h,"results") || contains(h,"resultados") || startsWith(strtrim(h),"## 7") || contains(h,"section 7")
            resultIdx(end+1) = i; %#ok<AGROW>
        end
    end

    if ~isempty(resultIdx)
        lastStart = headStarts(resultIdx(end));
        laterHeadings = headStarts(headStarts > lastStart);
        if ~isempty(laterHeadings)
            idxInsert = laterHeadings(1);
            evidence = "Inserted before next heading after Results.";
        else
            idxInsert = length(txt) + 1;
            evidence = "Inserted at end of MASTER after Results.";
        end
        return
    end

    idxInsert = length(txt) + 1;
    evidence = "No Results/Limitations/Conclusions/References heading detected; inserted at end of MASTER.";
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

function pre = extract_before_heading(txt,headings)
    idx = [];
    for i = 1:numel(headings)
        k = strfind(txt,headings(i));
        if ~isempty(k)
            idx(end+1) = k(1); %#ok<AGROW>
        end
    end
    if isempty(idx)
        pre = txt;
    else
        pre = txt(1:min(idx)-1);
    end
end

function post = extract_after_results(txt)
    idxStart = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','once');
    if isempty(idxStart)
        post = txt;
    else
        post = txt(idxStart:end);
    end
end

function tf = has_results_heading(txt)
    tf = ~isempty(regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','once'));
end

function tf = has_post_discussion_heading(txt)
    tf = ~isempty(regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Limitations|Conclusions|Conclusion|Conclusiones|References|Referencias)\b.*$','once'));
end

function write_headings_report(txt,filename)
    [starts,matches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not write headings report: %s',filename);
    end
    fprintf(fid,'MASTER headings detected for Discussion consolidated draft integration\n\n');
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
