function out = integrate_cost_co2_traceability_caveat_into_master_v96z()
% INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z
%
% 9.6z-trace-c
% INTEGRATE-COST-CO2-TRACEABILITY-CAVEAT-INTO-MASTER-001
%
% Objetivo:
%   Integrar en MASTER_manuscript_v01.md el caveat metodologico de
%   trazabilidad de factores economicos y de CO2.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica resultados numericos.
% No cambia Section 7 si es detectable.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');
    lockDir = fullfile(articleRoot,'locked_sections');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');

    secFile = fullfile(draftDir,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z.md');
    secReport = fullfile(reviewDir,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z_report.md');
    secChecks = fullfile(reviewDir,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z_Tchecks.csv');

    methodsGaReport = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md');
    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');

    integrationReport = fullfile(reviewDir,'INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_report.md');
    integrationChecks = fullfile(reviewDir,'INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_Tchecks.csv');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_trace_c.txt');
    traceMat = fullfile(traceDir,'INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z.mat');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end
    if ~isfile(secFile)
        error('Cost/CO2 caveat section file not found: %s',secFile);
    end
    if ~isfile(secReport)
        error('Cost/CO2 caveat report not found: %s',secReport);
    end

    secText = fileread(secFile);
    secReportText = fileread(secReport);

    sourcePass = contains(secReportText,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_PASS') && ...
                 contains(secReportText,'READY_FOR_METHODS_OR_LIMITATIONS_INTEGRATION') && ...
                 contains(secText,'SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z_READY_FOR_REVIEW');

    if ~sourcePass
        error('Source Cost/CO2 caveat does not show PASS/READY status in report and section file.');
    end

    masterBefore = fileread(masterFile);
    section7Before = extract_section7_flexible(masterBefore);

    englishBlock = extract_between(secText, ...
        '## Manuscript text -- English', ...
        '## Version tecnica de control -- Espanol');

    englishBlock = strip(string(englishBlock));
    englishBlock = regexprep(englishBlock,"^\s*## Manuscript text -- English\s*","");

    insertionTitle = "### Traceability of economic and CO2 factors";
    insertionKey = "Economic and environmental indicators were handled through a separate factor-traceability matrix";
    insertionBlock = newline + newline + string(englishBlock) + newline;

    if strlength(englishBlock) < 500
        error('Extracted English block is unexpectedly short. Check source file: %s',secFile);
    end

    write_headings_report(masterBefore,headingsReport);

    countBefore = count(string(masterBefore),insertionTitle);
    alreadyIntegrated = countBefore > 0 || contains(string(masterBefore),insertionKey);

    backupFile = fullfile(draftDir, ...
        ['MASTER_manuscript_v01_BEFORE_COST_CO2_TRACE_CAVEAT_v96z_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);

    copyfile(masterFile,backupFile);

    if alreadyIntegrated
        integrationAction = "NO_WRITE_ALREADY_INTEGRATED";
        locationEvidence = "Detected previous Cost/CO2 traceability caveat in MASTER; no new write performed.";
    else
        [idxInsert, locationEvidence] = find_trace_c_insertion_point(masterBefore);

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
    beforeResultsText = extract_before_results_flexible(masterAfterRead);
    lowBeforeResults = lower(string(beforeResultsText));

    section7ProtectionOK = true;
    if strlength(string(section7Before)) > 0 && strlength(string(section7After)) > 0
        section7ProtectionOK = strcmp(section7Before,section7After);
    end

    checks = {};
    checks{end+1,1} = check_row("TRCI-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("TRCI-02","Source Cost/CO2 caveat exists",isfile(secFile),secFile);
    checks{end+1,1} = check_row("TRCI-03","Source Cost/CO2 caveat report exists",isfile(secReport),secReport);
    checks{end+1,1} = check_row("TRCI-04","Source Cost/CO2 caveat checks file exists",isfile(secChecks),secChecks);
    checks{end+1,1} = check_row("TRCI-05","Source Cost/CO2 caveat PASS verified",sourcePass,"PASS verified from report and section.");
    checks{end+1,1} = check_row("TRCI-06","Methods GA integration report exists",isfile(methodsGaReport),methodsGaReport);
    checks{end+1,1} = check_row("TRCI-07","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("TRCI-08","MASTER backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("TRCI-09","MASTER headings diagnostic report created",isfile(headingsReport),headingsReport);
    checks{end+1,1} = check_row("TRCI-10","Integration action valid",integrationAction=="MASTER_UPDATED" || integrationAction=="NO_WRITE_ALREADY_INTEGRATED",integrationAction);

    checks{end+1,1} = check_row("TRCI-11","Cost/CO2 caveat title present once",countAfter==1,"Title count = " + string(countAfter) + ".");
    checks{end+1,1} = check_row("TRCI-12","Inserted text appears before Results when Results heading exists", ...
        contains(lowBeforeResults,"traceability of economic and co2 factors") || ~has_results_heading(masterAfterRead), ...
        "Text before Results or no Results heading detected.");
    checks{end+1,1} = check_row("TRCI-13","Section 7 preserved when Section 7 is detectable",section7ProtectionOK,"Section 7 comparison flexible.");

    checks{end+1,1} = check_row("TRCI-14","LPG factor preserved",contains(masterAfterRead,"EF_LPG_kgCO2_per_kWh = 0.2270"),"LPG factor.");
    checks{end+1,1} = check_row("TRCI-15","Grid factor preserved",contains(masterAfterRead,"EF_grid_kgCO2_per_kWh = 0.4380"),"Grid factor.");
    checks{end+1,1} = check_row("TRCI-16","Provisional tag preserved",contains(masterAfterRead,"PROVISIONAL_FOR_CODE_VALIDATION"),"Provisional tag.");
    checks{end+1,1} = check_row("TRCI-17","Not final manuscript-grade caveat preserved",contains(lowMasterAfter,"not treated as final") || contains(lowMasterAfter,"not final"),"Not-final caveat.");
    checks{end+1,1} = check_row("TRCI-18","Definitive source requirement preserved",contains(lowMasterAfter,"definitive source") || contains(lowMasterAfter,"source, date, unit basis"),"Source requirement.");
    checks{end+1,1} = check_row("TRCI-19","Date requirement preserved",contains(lowMasterAfter,"date"),"Date requirement.");
    checks{end+1,1} = check_row("TRCI-20","Unit-basis requirement preserved",contains(lowMasterAfter,"unit basis"),"Unit basis.");
    checks{end+1,1} = check_row("TRCI-21","Conversion-procedure requirement preserved",contains(lowMasterAfter,"conversion procedure"),"Conversion procedure.");
    checks{end+1,1} = check_row("TRCI-22","Energy-demand-first interpretation preserved",contains(lowMasterAfter,"energy demand"),"Energy demand interpretation.");
    checks{end+1,1} = check_row("TRCI-23","Fan-power limitation preserved",contains(lowMasterAfter,"fan-power") || contains(lowMasterAfter,"fan-power consumption"),"Fan-power limitation.");
    checks{end+1,1} = check_row("TRCI-24","Pressure-drop limitation preserved",contains(lowMasterAfter,"pressure-drop") || contains(lowMasterAfter,"pressure-drop coupling"),"Pressure-drop limitation.");

    checks{end+1,1} = check_row("TRCI-25","No final CO2 claim introduced",~contains(lowMasterAfter,"final co2 reduction") && ~contains(lowMasterAfter,"final emission reduction"),"No final CO2 claim.");
    checks{end+1,1} = check_row("TRCI-26","No final cost claim introduced",~contains(lowMasterAfter,"final cost reduction") && ~contains(lowMasterAfter,"final economic saving"),"No final cost claim.");
    checks{end+1,1} = check_row("TRCI-27","No GA executed",true,"Text integration only.");
    checks{end+1,1} = check_row("TRCI-28","No model executed",true,"Text integration only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,integrationChecks);

    if all(Tchecks.pass)
        diagnosis = "INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_PASS";
        decision = "MASTER_UPDATED_WITH_COST_CO2_TRACEABILITY_CAVEAT";
        next_step = "Proceed to final cited factor selection or manuscript limitations consolidation.";
    else
        diagnosis = "INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and headings diagnostic report.";
    end

    fid = fopen(integrationReport,'w');
    if fid < 0
        error('Could not open integration report for writing: %s',integrationReport);
    end

    fprintf(fid,'# INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Integration action\n\n`%s`\n\n',integrationAction);
    fprintf(fid,'## Insertion evidence\n\n`%s`\n\n',locationEvidence);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Source Cost/CO2 caveat: `%s`\n',secFile);
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

    save(traceMat,'masterFile','backupFile','secFile','secReport','secChecks','methodsGaReport','lockedSection7','integrationReport','integrationChecks','headingsReport','traceMat','Tchecks','diagnosis','decision','next_step','integrationAction','locationEvidence','sourcePass');

    out = struct();
    out.status = "INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_DONE";
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

    disp('=== INTEGRATE COST CO2 TRACEABILITY CAVEAT INTO MASTER v96z ===')
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

function [idxInsert, evidence] = find_trace_c_insertion_point(txt)
    [headStarts, headMatches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');

    % Prefer insertion after GA reproducibility paragraph if present.
    gaTitle = strfind(txt,'### Reproducibility configuration of the formal multiobjective run');
    if ~isempty(gaTitle)
        afterGa = gaTitle(1) + length('### Reproducibility configuration of the formal multiobjective run');
        laterHeadings = headStarts(headStarts > afterGa);
        if ~isempty(laterHeadings)
            idxInsert = laterHeadings(1);
            evidence = "Inserted before next heading after GA reproducibility paragraph.";
            return
        else
            idxInsert = length(txt) + 1;
            evidence = "Inserted at end of MASTER after GA reproducibility paragraph.";
            return
        end
    end

    % Otherwise insert after the last Methods/Limitations/Model/Optimization-like heading.
    methodIdx = [];
    for i = 1:numel(headMatches)
        h = lower(string(headMatches{i}));
        if contains(h,"method") || contains(h,"metod") || contains(h,"limitation") || ...
           contains(h,"limitacion") || contains(h,"optimization") || contains(h,"model")
            methodIdx(end+1) = i; %#ok<AGROW>
        end
    end

    if ~isempty(methodIdx)
        lastStart = headStarts(methodIdx(end));
        laterHeadings = headStarts(headStarts > lastStart);
        if ~isempty(laterHeadings)
            idxInsert = laterHeadings(1);
            evidence = "Inserted before next heading after last Methods/Limitations/Model/Optimization heading.";
        else
            idxInsert = length(txt) + 1;
            evidence = "Inserted at end of MASTER after last Methods/Limitations/Model/Optimization heading.";
        end
        return
    end

    % Otherwise before Results, if detectable.
    resultStarts = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Results|RESULTS|Resultados|RESULTADOS|Results section|Section 7|7\.)\b.*$','start');
    if ~isempty(resultStarts)
        idxInsert = resultStarts(1);
        evidence = "Inserted before detected Results heading.";
        return
    end

    idxInsert = length(txt) + 1;
    evidence = "No Methods/Limitations/Results heading detected; inserted at end of MASTER.";
end

function tf = has_results_heading(txt)
    starts = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Results|RESULTS|Resultados|RESULTADOS|Results section|Section 7|7\.)\b.*$','start');
    tf = ~isempty(starts);
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

function pre = extract_before_results_flexible(txt)
    idxStart = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Results|RESULTS|Resultados|RESULTADOS|Results section|Section 7|7\.)\b.*$','once');
    if isempty(idxStart)
        pre = txt;
    else
        pre = txt(1:idxStart-1);
    end
end

function write_headings_report(txt,filename)
    [starts,matches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not write headings report: %s',filename);
    end
    fprintf(fid,'MASTER headings detected for Cost/CO2 traceability caveat integration\n\n');
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
