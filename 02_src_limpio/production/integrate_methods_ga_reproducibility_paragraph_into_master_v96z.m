function out = integrate_methods_ga_reproducibility_paragraph_into_master_v96z()
% INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z
%
% 9.6z-methods-d
% INTEGRATE-METHODS-GA-REPRODUCIBILITY-PARAGRAPH-INTO-MASTER-001
%
% FIX3:
%   Insercion robusta aunque MASTER no tenga encabezado "## 7" ni
%   "## Results". Busca encabezados con cualquier nivel Markdown (#..######),
%   Results/Resultados, Methods/Metodos/Methodology/Optimization/Model.
%   Si no encuentra un punto claro, inserta un bloque de Methods addendum al
%   final del MASTER y deja evidencia explicita.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica resultados numericos.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');
    lockDir = fullfile(articleRoot,'locked_sections');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
    secFile = fullfile(draftDir,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z.md');
    secReport = fullfile(reviewDir,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z_report.md');
    secChecks = fullfile(reviewDir,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z_Tchecks.csv');
    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');

    integrationReport = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md');
    integrationChecks = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_Tchecks.csv');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_methods_d_FIX3.txt');
    traceMat = fullfile(traceDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z.mat');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end
    if ~isfile(secFile)
        error('Methods GA reproducibility paragraph file not found: %s',secFile);
    end
    if ~isfile(secReport)
        error('Methods GA reproducibility report not found: %s',secReport);
    end

    secText = fileread(secFile);
    secReportText = fileread(secReport);

    sourcePass = contains(secReportText,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_PASS') && ...
                 contains(secReportText,'READY_FOR_METHODS_INTEGRATION') && ...
                 contains(secText,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z_READY_FOR_METHODS_INTEGRATION');

    if ~sourcePass
        error('Source Methods GA reproducibility paragraph does not show PASS/READY status in report and section file.');
    end

    masterBefore = fileread(masterFile);
    section7Before = extract_section7_flexible(masterBefore);

    englishBlock = extract_between(secText, ...
        '## Manuscript text -- English', ...
        '## Version tecnica de control -- Espanol');

    englishBlock = strip(string(englishBlock));
    englishBlock = regexprep(englishBlock,"^\s*## Manuscript text -- English\s*","");

    insertionTitle = "### Reproducibility configuration of the formal multiobjective run";
    insertionKey = "The formal multiobjective optimization run used to generate the selected candidate solutions";
    insertionBlock = newline + newline + string(englishBlock) + newline;

    if strlength(englishBlock) < 500
        error('Extracted English block is unexpectedly short. Check source file: %s',secFile);
    end

    write_headings_report(masterBefore,headingsReport);

    countBefore = count(string(masterBefore),insertionTitle);
    alreadyIntegrated = countBefore > 0 || contains(string(masterBefore),insertionKey);

    backupFile = fullfile(draftDir, ...
        ['MASTER_manuscript_v01_BEFORE_METHODS_GA_REPRO_v96z_FIX3_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.md']);

    copyfile(masterFile,backupFile);

    if alreadyIntegrated
        integrationAction = "NO_WRITE_ALREADY_INTEGRATED";
        locationEvidence = "Detected previous Methods GA reproducibility text in MASTER; no new write performed.";
    else
        [idxInsert, locationEvidence] = find_methods_insertion_point_flexible(masterBefore);

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

    beforeResultsText = extract_before_results_flexible(masterAfterRead);
    lowBeforeResults = lower(string(beforeResultsText));
    lowMasterAfter = lower(string(masterAfterRead));

    section7ProtectionOK = true;
    if strlength(string(section7Before)) > 0 && strlength(string(section7After)) > 0
        section7ProtectionOK = strcmp(section7Before,section7After);
    end

    checks = {};
    checks{end+1,1} = check_row("MINT-01","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("MINT-02","Source Methods paragraph exists",isfile(secFile),secFile);
    checks{end+1,1} = check_row("MINT-03","Source Methods paragraph audit report exists",isfile(secReport),secReport);
    checks{end+1,1} = check_row("MINT-04","Source Methods paragraph audit checks file exists",isfile(secChecks),secChecks);
    checks{end+1,1} = check_row("MINT-05","Source Methods paragraph PASS verified from report/section",sourcePass,"PASS verified without relying on malformed CSV pass column.");
    checks{end+1,1} = check_row("MINT-06","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("MINT-07","MASTER backup created",isfile(backupFile),backupFile);
    checks{end+1,1} = check_row("MINT-08","Integration action valid",integrationAction=="MASTER_UPDATED" || integrationAction=="NO_WRITE_ALREADY_INTEGRATED",integrationAction);
    checks{end+1,1} = check_row("MINT-09","MASTER headings diagnostic report created",isfile(headingsReport),headingsReport);

    checks{end+1,1} = check_row("MINT-10","Methods GA reproducibility title present once",countAfter==1,"Title count = " + string(countAfter) + ".");
    checks{end+1,1} = check_row("MINT-11","Inserted text appears before Results when Results heading exists", ...
        contains(lowBeforeResults,"reproducibility configuration of the formal multiobjective run") || ~has_results_heading(masterAfterRead), ...
        "Text before Results or no Results heading detected.");
    checks{end+1,1} = check_row("MINT-12","Section 7 preserved when Section 7 is detectable",section7ProtectionOK,"Section 7 comparison flexible.");

    checks{end+1,1} = check_row("MINT-13","gamultiobj preserved",contains(masterAfterRead,"gamultiobj"),"Algorithm.");
    checks{end+1,1} = check_row("MINT-14","Seed 61001 preserved",contains(masterAfterRead,"61001"),"Seed.");
    checks{end+1,1} = check_row("MINT-15","Population 24 preserved",contains(masterAfterRead,"population size of 24") || contains(masterAfterRead,"Population size | 24"),"Population.");
    checks{end+1,1} = check_row("MINT-16","Generation limit 50 preserved",contains(masterAfterRead,"50 generations") || contains(masterAfterRead,"Maximum generations | 50"),"Generations.");
    checks{end+1,1} = check_row("MINT-17","Exitflag 0 preserved",contains(masterAfterRead,"exitflag = 0"),"Exitflag.");
    checks{end+1,1} = check_row("MINT-18","Runtime 25.4 h preserved",contains(masterAfterRead,"25.4 h"),"Runtime.");
    checks{end+1,1} = check_row("MINT-19","MR threshold preserved",contains(masterAfterRead,"MR <= 0.1"),"MR threshold.");
    checks{end+1,1} = check_row("MINT-20","Decision variable m_dot preserved",contains(masterAfterRead,"m_dot"),"m_dot.");
    checks{end+1,1} = check_row("MINT-21","Decision variable T_min preserved",contains(masterAfterRead,"T_min"),"T_min.");
    checks{end+1,1} = check_row("MINT-22","Decision variable r_rec preserved",contains(masterAfterRead,"r_rec"),"r_rec.");
    checks{end+1,1} = check_row("MINT-23","Decision variable t_rec_ini preserved",contains(masterAfterRead,"t_rec_ini"),"t_rec_ini.");

    checks{end+1,1} = check_row("MINT-24","Computed nondominated set wording present",contains(lowMasterAfter,"computed nondominated set"),"Computed nondominated set.");
    checks{end+1,1} = check_row("MINT-25","No global optimum claim",~contains(lowMasterAfter,"global optimum") && ~contains(lowMasterAfter,"globally optimal"),"Avoids global optimum wording.");
    checks{end+1,1} = check_row("MINT-26","No global Pareto front claim",~contains(lowMasterAfter,"global pareto front"),"Avoids global Pareto front wording.");
    checks{end+1,1} = check_row("MINT-27","No statistical robustness claim",contains(lowMasterAfter,"no claim of statistical robustness") || contains(lowMasterAfter,"not established by r1 alone"),"Robustness caveat.");
    checks{end+1,1} = check_row("MINT-28","Solar-only exclusion preserved",contains(lowMasterAfter,"solar-only operation was not included") || contains(lowMasterAfter,"excluded from formal ga comparison"),"Solar-only caveat.");
    checks{end+1,1} = check_row("MINT-29","H2 historical reference preserved",contains(masterAfterRead,"H2") && contains(lowMasterAfter,"reference"),"H2 reference.");
    checks{end+1,1} = check_row("MINT-30","No GA executed",true,"Text integration only.");
    checks{end+1,1} = check_row("MINT-31","No model executed",true,"Text integration only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,integrationChecks);

    if all(Tchecks.pass)
        diagnosis = "INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_PASS";
        decision = "MASTER_UPDATED_WITH_METHODS_GA_REPRODUCIBILITY";
        next_step = "Proceed to cost/CO2 traceability matrix.";
    else
        diagnosis = "INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and headings diagnostic report.";
    end

    fid = fopen(integrationReport,'w');
    if fid < 0
        error('Could not open integration report for writing: %s',integrationReport);
    end

    fprintf(fid,'# INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Integration action\n\n`%s`\n\n',integrationAction);
    fprintf(fid,'## Insertion evidence\n\n`%s`\n\n',locationEvidence);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Backup: `%s`\n',backupFile);
    fprintf(fid,'- Source Methods paragraph: `%s`\n',secFile);
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

    save(traceMat,'masterFile','backupFile','secFile','secReport','secChecks','lockedSection7','integrationReport','integrationChecks','headingsReport','traceMat','Tchecks','diagnosis','decision','next_step','integrationAction','locationEvidence','sourcePass');

    out = struct();
    out.status = "INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_FIX3_DONE";
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

    disp('=== INTEGRATE METHODS GA REPRODUCIBILITY PARAGRAPH INTO MASTER v96z FIX3 ===')
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

function [idxInsert, evidence] = find_methods_insertion_point_flexible(txt)
    % 1) Results heading with any markdown level
    [resultStarts, resultMatches] = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Results|RESULTS|Resultados|RESULTADOS|Results section|Section 7|7\.)\b.*$','start','match');

    % 2) Methods-like headings with any markdown level
    [headStarts, headMatches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');

    methodIdx = [];
    for i = 1:numel(headMatches)
        h = lower(string(headMatches{i}));
        if contains(h,"method") || contains(h,"metod") || contains(h,"optimization") || contains(h,"optimiz") || contains(h,"model")
            methodIdx(end+1) = i; %#ok<AGROW>
        end
    end

    if ~isempty(methodIdx)
        lastMethodStart = headStarts(methodIdx(end));
        laterHeadings = headStarts(headStarts > lastMethodStart);

        if ~isempty(laterHeadings)
            idxInsert = laterHeadings(1);
            evidence = "Inserted before next heading after last detected Methods/Model/Optimization heading.";
            return
        end

        if ~isempty(resultStarts)
            idxInsert = resultStarts(1);
            evidence = "Inserted before detected Results heading after Methods-like heading.";
            return
        end

        idxInsert = length(txt) + 1;
        evidence = "Inserted at end of MASTER after detecting Methods-like heading but no following heading.";
        return
    end

    if ~isempty(resultStarts)
        idxInsert = resultStarts(1);
        evidence = "No Methods-like heading found; inserted before detected Results heading: " + string(resultMatches{1});
        return
    end

    idxInsert = length(txt) + 1;
    evidence = "No Methods or Results heading detected; inserted at end of MASTER as Methods reproducibility addendum.";
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
    fprintf(fid,'MASTER headings detected for Methods integration FIX3\n\n');
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
