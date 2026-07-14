function out = audit_master_after_discussion_v96z()
% AUDIT_MASTER_AFTER_DISCUSSION_v96z
%
% 9.6z-audit-b
% MASTER-MANUSCRIPT-CONSISTENCY-AUDIT-AFTER-DISCUSSION-001
%
% Objetivo:
%   Reauditar MASTER_manuscript_v01.md despues de integrar Discussion.
%
% Evalua:
%   - Discussion integrada una sola vez
%   - Results/Section 7 preservada
%   - Limitations preservadas
%   - Cautelas de reproducibilidad, costo/CO2 y equipo preservadas
%   - Ausencia de frases prohibidas o contradicciones nuevas
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica MASTER.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');
    lockDir = fullfile(articleRoot,'locked_sections');
    tablesDir = fullfile(articleRoot,'tables');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');

    discussionIntegrationReport = fullfile(reviewDir,'INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md');
    limitationsIntegrationReport = fullfile(reviewDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md');
    methodsGaIntegrationReport = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md');
    costCo2IntegrationReport = fullfile(reviewDir,'INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_report.md');
    previousAuditReport = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z_report.md');

    r1ReproTable = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');
    costCo2Matrix = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md');

    auditReport = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z_report.md');
    auditChecks = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z_Tchecks.csv');
    findingsMd = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z_findings.md');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_audit_b_after_discussion.txt');
    traceMat = fullfile(traceDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z.mat');

    if ~isfile(masterFile)
        error('MASTER not found: %s',masterFile);
    end

    master = fileread(masterFile);
    low = lower(string(master));

    lockedText = "";
    if isfile(lockedSection7)
        lockedText = string(fileread(lockedSection7));
    end

    write_headings_report(master,headingsReport);

    discussionKey = "The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate";
    limitationsKey = "Several limitations must be considered when interpreting the optimization and baseline-comparison results";
    methodsKey = "Reproducibility configuration of the formal multiobjective run";
    costCo2Key = "Traceability of economic and CO2 factors";

    cntDiscussionKey = count(string(master),discussionKey);
    cntDiscussionTitle = count(string(master),"### Discussion");
    cntLimitationsKey = count(string(master),limitationsKey);
    cntLimitationsTitle = count(string(master),"### Limitations");
    cntMethodsKey = count(string(master),methodsKey);
    cntCostCo2Key = count(string(master),costCo2Key);

    section7InMaster = extract_section7_flexible(master);
    section7Detectable = strlength(string(section7InMaster)) > 0;
    lockedSectionDetectable = strlength(lockedText) > 0;

    section7SimilarityOK = true;
    section7Evidence = "Section 7 comparison not strict because one side was not detectable.";
    if section7Detectable && lockedSectionDetectable
        section7SimilarityOK = section_similarity_ok(string(section7InMaster),lockedText);
        section7Evidence = "Flexible normalized comparison between MASTER Section 7 and locked Section 7.";
    end

    discussionAfterResultsOK = appears_after_results(master,discussionKey);
    discussionBeforeLimitationsOK = appears_before_post_discussion(master,discussionKey);

    forbiddenGlobalOptimum = contains(low,"global optimum") || contains(low,"globally optimal");
    forbiddenGlobalPareto = contains(low,"global pareto front");
    statisticalRobustnessClaim = contains(low,"statistically robust") || contains(low,"robust across seeds") || contains(low,"statistical robustness was demonstrated");
    finalCO2Claim = contains(low,"final co2 reduction") || contains(low,"final emission reduction") || contains(low,"definitive emission reduction");
    finalCostClaim = contains(low,"final cost reduction") || contains(low,"final economic saving") || contains(low,"definitive economic saving");
    solarOnlyFormalClaim = contains(low,"solar-only was included in the formal multiobjective comparison") || contains(low,"solar only was included in the formal multiobjective comparison");
    h2NewR1Claim = contains(low,"h2 was selected as an r1 solution") || contains(low,"h2 is a newly optimized r1 solution");
    numericRepetitionInDiscussion = discussion_contains_section7_numbers(master);

    checks = {};
    checks{end+1,1} = check_row("MADB-001","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("MADB-002","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("MADB-003","Discussion integration report exists",isfile(discussionIntegrationReport),discussionIntegrationReport);
    checks{end+1,1} = check_row("MADB-004","Limitations integration report exists",isfile(limitationsIntegrationReport),limitationsIntegrationReport);
    checks{end+1,1} = check_row("MADB-005","Methods GA integration report exists",isfile(methodsGaIntegrationReport),methodsGaIntegrationReport);
    checks{end+1,1} = check_row("MADB-006","Cost/CO2 integration report exists",isfile(costCo2IntegrationReport),costCo2IntegrationReport);
    checks{end+1,1} = check_row("MADB-007","Previous MASTER audit report exists",isfile(previousAuditReport),previousAuditReport);
    checks{end+1,1} = check_row("MADB-008","R1 reproducibility table exists",isfile(r1ReproTable),r1ReproTable);
    checks{end+1,1} = check_row("MADB-009","Cost/CO2 traceability matrix exists",isfile(costCo2Matrix),costCo2Matrix);
    checks{end+1,1} = check_row("MADB-010","Headings diagnostic report created",isfile(headingsReport),headingsReport);

    checks{end+1,1} = check_row("MADB-011","Discussion key present once",cntDiscussionKey==1,"Key count = " + string(cntDiscussionKey) + ".");
    checks{end+1,1} = check_row("MADB-012","Discussion title present once",cntDiscussionTitle==1,"Title count = " + string(cntDiscussionTitle) + ".");
    checks{end+1,1} = check_row("MADB-013","Limitations key present once",cntLimitationsKey==1,"Key count = " + string(cntLimitationsKey) + ".");
    checks{end+1,1} = check_row("MADB-014","Limitations title present once",cntLimitationsTitle==1,"Title count = " + string(cntLimitationsTitle) + ".");
    checks{end+1,1} = check_row("MADB-015","Methods GA reproducibility block present once",cntMethodsKey==1,"Key count = " + string(cntMethodsKey) + ".");
    checks{end+1,1} = check_row("MADB-016","Cost/CO2 traceability block present once",cntCostCo2Key==1,"Key count = " + string(cntCostCo2Key) + ".");

    checks{end+1,1} = check_row("MADB-017","Discussion appears after Results when Results detectable",discussionAfterResultsOK || ~has_results_heading(master),"Discussion after Results or no Results heading.");
    checks{end+1,1} = check_row("MADB-018","Discussion appears before Limitations/Conclusions/References when detectable",discussionBeforeLimitationsOK || ~has_post_discussion_heading(master),"Discussion before post-Discussion headings.");
    checks{end+1,1} = check_row("MADB-019","Section 7 detectable or locked fallback available",section7Detectable || isfile(lockedSection7),"Section7Detectable=" + string(section7Detectable) + ".");
    checks{end+1,1} = check_row("MADB-020","Section 7 preserved against locked version when comparable",section7SimilarityOK,section7Evidence);

    checks{end+1,1} = check_row("MADB-021","R1_solution_7 discussion preserved",contains(master,"R1_solution_7") && contains(low,"energy-conservative"),"R1_solution_7.");
    checks{end+1,1} = check_row("MADB-022","R1_solution_3 discussion preserved",contains(master,"R1_solution_3") && contains(low,"balanced"),"R1_solution_3.");
    checks{end+1,1} = check_row("MADB-023","R1_solution_9 discussion preserved",contains(master,"R1_solution_9") && contains(low,"aggressive"),"R1_solution_9.");
    checks{end+1,1} = check_row("MADB-024","H2 historical reference preserved",contains(master,"H2") && contains(low,"historical reference"),"H2 historical reference.");
    checks{end+1,1} = check_row("MADB-025","No H2 new-R1 contradiction",~h2NewR1Claim,"No H2 new-R1 contradiction.");

    checks{end+1,1} = check_row("MADB-026","gamultiobj present",contains(master,"gamultiobj"),"Algorithm.");
    checks{end+1,1} = check_row("MADB-027","Seed 61001 present",contains(master,"61001"),"Seed.");
    checks{end+1,1} = check_row("MADB-028","exitflag 0 present",contains(low,"exitflag 0"),"Exitflag 0.");
    checks{end+1,1} = check_row("MADB-029","Generation-limit interpretation present",contains(low,"generation limit"),"Generation limit.");
    checks{end+1,1} = check_row("MADB-030","Computed nondominated set wording present",contains(low,"computed nondominated set"),"Computed nondominated set.");

    checks{end+1,1} = check_row("MADB-031","No prohibited global optimum wording",~forbiddenGlobalOptimum,"No global optimum / globally optimal wording.");
    checks{end+1,1} = check_row("MADB-032","No prohibited global Pareto front wording",~forbiddenGlobalPareto,"No global Pareto front wording.");
    checks{end+1,1} = check_row("MADB-033","No statistical robustness claim",~statisticalRobustnessClaim,"No robust-across-seeds claim.");
    checks{end+1,1} = check_row("MADB-034","Statistical robustness caveat present",contains(low,"does not establish statistical robustness") || contains(low,"not be interpreted as evidence of statistical robustness"),"Robustness caveat.");

    checks{end+1,1} = check_row("MADB-035","2-SAH sensitivity wording present",contains(low,"2-sah") && contains(low,"sensitivity"),"2-SAH sensitivity.");
    checks{end+1,1} = check_row("MADB-036","Collector not fully coupled caveat present",contains(low,"fully coupled dynamic collector model") || contains(low,"fully coupled dynamic collector simulation"),"Collector caveat.");
    checks{end+1,1} = check_row("MADB-037","Fan-power limitation present",contains(low,"fan-power") || contains(low,"fan power"),"Fan-power.");
    checks{end+1,1} = check_row("MADB-038","Pressure-drop limitation present",contains(low,"pressure-drop") || contains(low,"pressure drop"),"Pressure-drop.");

    checks{end+1,1} = check_row("MADB-039","Hybrid vs gas-LPG baseline wording present",contains(low,"hybrid") && contains(low,"gas-lpg"),"Hybrid/gas-LPG.");
    checks{end+1,1} = check_row("MADB-040","Solar substitution interpretation present",contains(low,"solar substitution"),"Solar substitution.");
    checks{end+1,1} = check_row("MADB-041","Solar-only exclusion preserved",contains(low,"solar-only") && contains(low,"excluded"),"Solar-only exclusion.");
    checks{end+1,1} = check_row("MADB-042","No solar-only formal-comparison contradiction",~solarOnlyFormalClaim,"No contradictory solar-only inclusion claim.");

    checks{end+1,1} = check_row("MADB-043","LPG provisional factor present",contains(master,"EF_LPG_kgCO2_per_kWh = 0.2270"),"LPG factor.");
    checks{end+1,1} = check_row("MADB-044","Grid provisional factor present",contains(master,"EF_grid_kgCO2_per_kWh = 0.4380"),"Grid factor.");
    checks{end+1,1} = check_row("MADB-045","Provisional tag present",contains(master,"PROVISIONAL_FOR_CODE_VALIDATION"),"Provisional tag.");
    checks{end+1,1} = check_row("MADB-046","No final CO2 claim introduced",~finalCO2Claim,"No final CO2 claim.");
    checks{end+1,1} = check_row("MADB-047","No final cost claim introduced",~finalCostClaim,"No final cost claim.");
    checks{end+1,1} = check_row("MADB-048","Final source requirement present",contains(low,"definitive source") || contains(low,"definitive cited sources"),"Source requirement.");
    checks{end+1,1} = check_row("MADB-049","Unit-basis requirement present",contains(low,"unit basis"),"Unit basis.");
    checks{end+1,1} = check_row("MADB-050","Conversion procedure requirement present",contains(low,"conversion procedure"),"Conversion procedure.");

    checks{end+1,1} = check_row("MADB-051","Discussion avoids Section 7 numeric-table repetition",~numericRepetitionInDiscussion,"No excessive Discussion numeric repetition.");
    checks{end+1,1} = check_row("MADB-052","No GA executed",true,"Audit only.");
    checks{end+1,1} = check_row("MADB-053","No model executed",true,"Audit only.");
    checks{end+1,1} = check_row("MADB-054","MASTER not modified",true,"Read-only audit.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,auditChecks);

    failed = Tchecks(~Tchecks.pass,:);
    nFail = height(failed);

    if nFail == 0
        diagnosis = "MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_PASS";
        decision = "MASTER_READY_FOR_CONCLUSIONS_DRAFTING";
        next_step = "Proceed to Conclusions consolidated draft.";
    else
        diagnosis = "MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and decide whether to patch wording or section placement.";
    end

    write_findings(findingsMd,Tchecks,diagnosis,decision,next_step, ...
        cntDiscussionKey,cntDiscussionTitle,cntLimitationsKey,cntLimitationsTitle, ...
        cntMethodsKey,cntCostCo2Key,section7Detectable,section7SimilarityOK);

    fid = fopen(auditReport,'w');
    if fid < 0
        error('Could not open audit report: %s',auditReport);
    end

    fprintf(fid,'# MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Failed checks\n\n`%d`\n\n',nFail);

    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Locked Section 7: `%s`\n',lockedSection7);
    fprintf(fid,'- Discussion integration report: `%s`\n',discussionIntegrationReport);
    fprintf(fid,'- Checks: `%s`\n',auditChecks);
    fprintf(fid,'- Findings: `%s`\n',findingsMd);
    fprintf(fid,'- Headings: `%s`\n\n',headingsReport);

    fprintf(fid,'## Summary counts\n\n');
    fprintf(fid,'| Item | Count/status |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Discussion key | %d |\n',cntDiscussionKey);
    fprintf(fid,'| Discussion title | %d |\n',cntDiscussionTitle);
    fprintf(fid,'| Limitations key | %d |\n',cntLimitationsKey);
    fprintf(fid,'| Limitations title | %d |\n',cntLimitationsTitle);
    fprintf(fid,'| Methods GA block | %d |\n',cntMethodsKey);
    fprintf(fid,'| Cost/CO2 block | %d |\n',cntCostCo2Key);
    fprintf(fid,'| Section 7 detectable | %d |\n',section7Detectable);
    fprintf(fid,'| Section 7 protection OK | %d |\n\n',section7SimilarityOK);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(traceMat,'masterFile','lockedSection7','discussionIntegrationReport','limitationsIntegrationReport','methodsGaIntegrationReport','costCo2IntegrationReport','previousAuditReport','auditReport','auditChecks','findingsMd','headingsReport','traceMat','Tchecks','diagnosis','decision','next_step','cntDiscussionKey','cntDiscussionTitle','cntLimitationsKey','cntLimitationsTitle','section7Detectable','section7SimilarityOK');

    out = struct();
    out.status = "AUDIT_MASTER_AFTER_DISCUSSION_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.masterFile = masterFile;
    out.auditReport = auditReport;
    out.auditChecks = auditChecks;
    out.findingsMd = findingsMd;
    out.headingsReport = headingsReport;
    out.traceMat = traceMat;
    out.Tchecks = Tchecks;
    out.failedChecks = failed;

    disp('=== AUDIT MASTER AFTER DISCUSSION v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== FAILED CHECKS ===')
    disp(out.failedChecks)
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.masterFile)
    disp(out.auditReport)
    disp(out.findingsMd)
    disp(out.headingsReport)
end

function tf = appears_after_results(txt,key)
    idxKey = strfind(txt,key);
    if isempty(idxKey)
        tf = false;
        return
    end
    idxResults = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','start');
    if isempty(idxResults)
        tf = true;
    else
        tf = idxKey(1) > idxResults(1);
    end
end

function tf = appears_before_post_discussion(txt,key)
    idxKey = strfind(txt,key);
    if isempty(idxKey)
        tf = false;
        return
    end
    idxPost = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Limitations|Conclusions|Conclusion|Conclusiones|References|Referencias)\b.*$','start');
    if isempty(idxPost)
        tf = true;
    else
        tf = idxKey(1) < idxPost(1);
    end
end

function tf = has_results_heading(txt)
    tf = ~isempty(regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','once'));
end

function tf = has_post_discussion_heading(txt)
    tf = ~isempty(regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:Limitations|Conclusions|Conclusion|Conclusiones|References|Referencias)\b.*$','once'));
end

function tf = discussion_contains_section7_numbers(txt)
    key = "The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate";
    idxKey = strfind(txt,key);
    if isempty(idxKey)
        tf = false;
        return
    end

    idxEndCandidates = regexp(txt(idxKey(1):end),'(?m)^#{1,6}\s*(?:Limitations|Conclusions|Conclusion|References|Referencias)\b.*$','start');
    if isempty(idxEndCandidates)
        block = txt(idxKey(1):end);
    else
        block = txt(idxKey(1):idxKey(1)+idxEndCandidates(1)-2);
    end

    nums = ["656.23","723.36","1218.4","747.00","1194.1","1270.6","1773.9"];
    tf = false;
    for i = 1:numel(nums)
        if contains(block,nums(i))
            tf = true;
            return
        end
    end
end

function tf = section_similarity_ok(a,b)
    a = normalize_for_compare(a);
    b = normalize_for_compare(b);

    if strlength(a) == 0 || strlength(b) == 0
        tf = true;
        return
    end

    anchors = [
        "r1_solution_7"
        "r1_solution_3"
        "r1_solution_9"
        "h2"
        "hybrid"
        "gas"
        "2-sah"
        "computed nondominated set"
        "mr"
        "q_aux"
    ];

    ok = true;
    for i = 1:numel(anchors)
        if contains(b,anchors(i)) && ~contains(a,anchors(i))
            ok = false;
        end
    end
    tf = ok;
end

function y = normalize_for_compare(x)
    y = lower(string(x));
    y = regexprep(y,'\s+',' ');
    y = strip(y);
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

function write_headings_report(txt,filename)
    [starts,matches] = regexp(txt,'(?m)^#{1,6}\s+.*$','start','match');
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not write headings report: %s',filename);
    end
    fprintf(fid,'MASTER headings detected for after-Discussion consistency audit\n\n');
    if isempty(matches)
        fprintf(fid,'No Markdown headings detected.\n');
    else
        for i = 1:numel(matches)
            fprintf(fid,'%04d | char %08d | %s\n',i,starts(i),matches{i});
        end
    end
    fclose(fid);
end

function write_findings(filename,Tchecks,diagnosis,decision,next_step,cntDiscussionKey,cntDiscussionTitle,cntLimitationsKey,cntLimitationsTitle,cntMethodsKey,cntCostCo2Key,section7Detectable,section7SimilarityOK)
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not open findings file: %s',filename);
    end

    fprintf(fid,'# MASTER manuscript consistency after Discussion audit findings\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Summary\n\n');
    fprintf(fid,'| Control | Value |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Discussion key | %d |\n',cntDiscussionKey);
    fprintf(fid,'| Discussion title | %d |\n',cntDiscussionTitle);
    fprintf(fid,'| Limitations key | %d |\n',cntLimitationsKey);
    fprintf(fid,'| Limitations title | %d |\n',cntLimitationsTitle);
    fprintf(fid,'| Methods GA block | %d |\n',cntMethodsKey);
    fprintf(fid,'| Cost/CO2 block | %d |\n',cntCostCo2Key);
    fprintf(fid,'| Section 7 detectable | %d |\n',section7Detectable);
    fprintf(fid,'| Section 7 protection OK | %d |\n\n',section7SimilarityOK);

    failed = Tchecks(~Tchecks.pass,:);
    fprintf(fid,'## Failed checks\n\n');
    if isempty(failed) || height(failed)==0
        fprintf(fid,'No failed checks.\n\n');
    else
        fprintf(fid,'| id | check | evidence |\n');
        fprintf(fid,'|---|---|---|\n');
        for i = 1:height(failed)
            fprintf(fid,'| `%s` | %s | `%s` |\n',string(failed.id(i)),string(failed.check(i)),string(failed.evidence(i)));
        end
        fprintf(fid,'\n');
    end

    fprintf(fid,'## Internal verdict\n\n');
    if height(failed)==0
        fprintf(fid,'`MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_PASS`\n');
    else
        fprintf(fid,'`MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_REVIEW_REQUIRED`\n');
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
