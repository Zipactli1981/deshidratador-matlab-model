function out = integrate_limitations_block_master_v96z()
% INTEGRATE_LIMITATIONS_BLOCK_MASTER_v96z
%
% 9.6z-limitations-b
% INTEGRATE-MANUSCRIPT-LIMITATIONS-CONSOLIDATED-BLOCK-INTO-MASTER-001
%
% Objetivo:
%   Integrar en MASTER_manuscript_v01.md el bloque consolidado de
%   Limitations aprobado en 9.6z-limitations-a.
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

    secFile = fullfile(draftDir,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z.md');
    secReport = fullfile(reviewDir,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z_report.md');
    secChecks = fullfile(reviewDir,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z_Tchecks.csv');

    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');
    costCo2IntegrationReport = fullfile(reviewDir,'INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_report.md');
    methodsGaIntegrationReport = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md');

    integrationReport = fullfile(reviewDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md');
    integrationChecks = fullfile(reviewDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_Tchecks.csv');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_limitations_b.txt');
    traceMat = fullfile(traceDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z.mat');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end
    if ~isfile(secFile)
        error('Limitations section file not found: %s',secFile);
    end
    if ~isfile(secReport)
        error('Limitations report not found: %s',secReport);
    end

    secText = fileread(secFile);
    secReportText = fileread(secReport);

    sourcePass = contains(secReportText,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_PASS') && ...
                 contains(secReportText,'READY_FOR_LIMITATIONS_INTEGRATION') && ...
                 contains(secText,'SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z_READY_FOR_LIMITATIONS_INTEGRATION');

    if ~sourcePass
        error('Source Limitations block does not show PASS/READY status in report and section file.');
    end

    masterBefore = fileread(masterFile);
    section7Before = extract_section7_flexible(masterBefore);

    englishBlock = extract_between(secText, ...
        '## Manuscript text -- English', ...
        '## Version tecnica de control -- Espanol');

    englishBlock = strip(string(englishBlock));
    englishBlock = regexprep(englishBlock,"^\s*## Manuscript text -- English\s*","");

    insertionTitle = "### Limitations";
    insertionKey = "Several limitations must be considered when interpreting the optimization and baseline-comparison results";
    insertionBlock = newline + newline + string(englishBlock) + newline;

    if strlength(englishBlock) < 700
        error('Extracted English Limitations block is unexpectedly short. Check source file: %s',secFile);
    end

    write_headings_report(masterBefore,headingsReport);

    alreadyIntegrated = contains(string(masterBefore),insertionKey) || ...
                        count(string(masterBefore),insertionTitle) > 0 && contains(lower(string(masterBefore)),"single controlled seed-aware r1");

    backupFile = fullfile(draftDir, ...
        ['MASTER_manuscript_v01_BEFORE_LIMITATIONS_BLOCK_v96z_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);

    copyfile(masterFile,backupFile);

    if alreadyIntegrated
        integrationAction = "NO_WRITE_ALREADY_INTEGRATED";
        locationEvidence = "Detected previous consolidated Limitations block in MASTER; no new write performed.";
    else
        [idxInsert, locationEvidence] = find_limitations_insertion_point(masterBefore);

        prefix = masterBefore(1:idxInsert-1);
        suffix = masterBefore(idxInsert:end);

        prefix = prefix(:).';
        suffix = suffix(:).';
        insertionBlockChar = char(insertionBlock);
        insertionBlockChar = insertionBlockChar(:).';

        masterAfter = [prefix insertionBlockChar suffix];

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

    countAfter = count(string(masterAfterRead),insertionTitle);
    lowMasterAfter = lower(string(masterAfterRead));

    section7ProtectionOK = true;
    if strlength(string(section7Before)) > 0 && strlength(string(section7After)) > 0
        section7ProtectionOK = strcmp(section7Before,section7After);
    end

    checks = {};
    checks{end+1,1} = check_row("LIMINT-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("LIMINT-02","Source Limitations block exists",isfile(secFile),secFile);
    checks{end+1,1} = check_row("LIMINT-03","Source Limitations report exists",isfile(secReport),secReport);
    checks{end+1,1} = check_row("LIMINT-04","Source Limitations checks file exists",isfile(secChecks),secChecks);
    checks{end+1,1} = check_row("LIMINT-05","Source Limitations PASS verified",sourcePass,"PASS verified from report and section.");
    checks{end+1,1} = check_row("LIMINT-06","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("LIMINT-07","Cost/CO2 integration report exists",isfile(costCo2IntegrationReport),costCo2IntegrationReport);
    checks{end+1,1} = check_row("LIMINT-08","Methods GA integration report exists",isfile(methodsGaIntegrationReport),methodsGaIntegrationReport);
    checks{end+1,1} = check_row("LIMINT-09","MASTER backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("LIMINT-10","MASTER headings diagnostic report created",isfile(headingsReport),headingsReport);
    checks{end+1,1} = check_row("LIMINT-11","Integration action valid",integrationAction=="MASTER_UPDATED" || integrationAction=="NO_WRITE_ALREADY_INTEGRATED",integrationAction);

    checks{end+1,1} = check_row("LIMINT-12","Limitations title present",countAfter>=1,"Title count = " + string(countAfter) + ".");
    checks{end+1,1} = check_row("LIMINT-13","Consolidated limitations text present",contains(masterAfterRead,insertionKey),"Consolidated Limitations block key sentence.");
    checks{end+1,1} = check_row("LIMINT-14","Section 7 preserved when Section 7 is detectable",section7ProtectionOK,"Section 7 comparison flexible.");

    checks{end+1,1} = check_row("LIMINT-15","Single R1 limitation preserved",contains(lowMasterAfter,"single controlled seed-aware r1"),"Single R1.");
    checks{end+1,1} = check_row("LIMINT-16","No statistical robustness caveat preserved",contains(lowMasterAfter,"does not establish statistical robustness"),"Statistical robustness caveat.");
    checks{end+1,1} = check_row("LIMINT-17","Computed nondominated set wording preserved",contains(lowMasterAfter,"computed nondominated set"),"Computed nondominated set.");
    checks{end+1,1} = check_row("LIMINT-18","No prohibited global optimum phrase introduced",~contains(lowMasterAfter,"global optimum") && ~contains(lowMasterAfter,"globally optimal"),"Avoids prohibited global optimum wording.");
    checks{end+1,1} = check_row("LIMINT-19","No prohibited global Pareto front phrase introduced",~contains(lowMasterAfter,"global pareto front"),"Avoids prohibited global Pareto wording.");

    checks{end+1,1} = check_row("LIMINT-20","2-SAH sensitivity limitation preserved",contains(lowMasterAfter,"2-sah") && contains(lowMasterAfter,"sensitivity"),"2-SAH sensitivity.");
    checks{end+1,1} = check_row("LIMINT-21","Fully coupled collector caveat preserved",contains(lowMasterAfter,"fully coupled dynamic collector model"),"Collector caveat.");
    checks{end+1,1} = check_row("LIMINT-22","Fan-power limitation preserved",contains(lowMasterAfter,"fan-power"),"Fan power.");
    checks{end+1,1} = check_row("LIMINT-23","Pressure-drop limitation preserved",contains(lowMasterAfter,"pressure-drop"),"Pressure drop.");

    checks{end+1,1} = check_row("LIMINT-24","CO2 provisional factors preserved",contains(masterAfterRead,"EF_LPG_kgCO2_per_kWh = 0.2270") && contains(masterAfterRead,"EF_grid_kgCO2_per_kWh = 0.4380"),"CO2 factors.");
    checks{end+1,1} = check_row("LIMINT-25","Provisional tag preserved",contains(masterAfterRead,"PROVISIONAL_FOR_CODE_VALIDATION"),"Provisional tag.");
    checks{end+1,1} = check_row("LIMINT-26","Final source requirement preserved",contains(lowMasterAfter,"definitive cited sources"),"Final source requirement.");
    checks{end+1,1} = check_row("LIMINT-27","Energy-demand interpretation preserved",contains(lowMasterAfter,"energy-demand trends"),"Energy-demand interpretation.");

    checks{end+1,1} = check_row("LIMINT-28","Solar-only exclusion preserved",contains(lowMasterAfter,"solar-only operation was excluded"),"Solar-only exclusion.");
    checks{end+1,1} = check_row("LIMINT-29","H2 historical reference preserved",contains(masterAfterRead,"H2") && contains(lowMasterAfter,"historical reference"),"H2 historical reference.");
    checks{end+1,1} = check_row("LIMINT-30","No GA executed",true,"Text integration only.");
    checks{end+1,1} = check_row("LIMINT-31","No model executed",true,"Text integration only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,integrationChecks);

    if all(Tchecks.pass)
        diagnosis = "INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_PASS";
        decision = "MASTER_UPDATED_WITH_LIMITATIONS_CONSOLIDATED_BLOCK";
        next_step = "Proceed to manuscript consistency audit or Discussion/Conclusions drafting.";
    else
        diagnosis = "INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and headings diagnostic report.";
    end

    fid = fopen(integrationReport,'w');
    if fid < 0
        error('Could not open integration report for writing: %s',integrationReport);
    end

    fprintf(fid,'# INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Integration action\n\n`%s`\n\n',integrationAction);
    fprintf(fid,'## Insertion evidence\n\n`%s`\n\n',locationEvidence);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Source Limitations block: `%s`\n',secFile);
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

    save(traceMat,'masterFile','backupFile','secFile','secReport','secChecks','lockedSection7','costCo2IntegrationReport','methodsGaIntegrationReport','integrationReport','integrationChecks','headingsReport','traceMat','Tchecks','diagnosis','decision','next_step','integrationAction','locationEvidence','sourcePass');

    out = struct();
    out.status = "INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_DONE";
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

    disp('=== INTEGRATE LIMITATIONS CONSOLIDATED BLOCK INTO MASTER v96z ===')
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

function [idxInsert, evidence] = find_limitations_insertion_point(txt)
    [headStarts, headMatches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');

    % Prefer before Conclusions or References.
    targetStarts = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Conclusions|Conclusion|Conclusiones|References|Referencias)\b.*$','start');
    if ~isempty(targetStarts)
        idxInsert = targetStarts(1);
        evidence = "Inserted before detected Conclusions/References heading.";
        return
    end

    % If Discussion exists, insert after Discussion block.
    discussionIdx = [];
    for i = 1:numel(headMatches)
        h = lower(string(headMatches{i}));
        if contains(h,"discussion") || contains(h,"discusion") || contains(h,"discusión")
            discussionIdx(end+1) = i; %#ok<AGROW>
        end
    end

    if ~isempty(discussionIdx)
        lastStart = headStarts(discussionIdx(end));
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

    % If Results exists, insert after Results block.
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
    evidence = "No Results/Discussion/Conclusions/References heading detected; inserted at end of MASTER.";
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
    idxNext = regexp(rest,'(?m)^#{1,6}\s*(?:8[\.\)]?\s+|Discussion\b|Conclusions\b|Conclusion\b|Conclusiones\b|References\b|Referencias\b).*$','once');

    if isempty(idxNext)
        s7 = txt(idxStart:end);
    else
        idxEnd = idxStart + idxNext - 1;
        s7 = txt(idxStart:idxEnd);
    end
end

function write_headings_report(txt,filename)
    [starts,matches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not write headings report: %s',filename);
    end
    fprintf(fid,'MASTER headings detected for Limitations consolidated block integration\n\n');
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
