function out = audit_master_after_conclusions_v96z()
% AUDIT_MASTER_AFTER_CONCLUSIONS_v96z
%
% 9.6z-audit-c
% MASTER-MANUSCRIPT-CONSISTENCY-AUDIT-AFTER-CONCLUSIONS-001
%
% Auditoria final de consistencia despues de integrar Conclusions.
% No ejecuta GA, no ejecuta modelo, no modifica MASTER.

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

    methodsReport = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md');
    costReport = fullfile(reviewDir,'INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_report.md');
    discussionReport = fullfile(reviewDir,'INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md');
    limitationsReport = fullfile(reviewDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md');
    conclusionsReport = fullfile(reviewDir,'INTEGRATE_CONCLUSIONS_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md');

    r1ReproTable = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');
    costCo2Matrix = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md');

    auditReport = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_v96z_report.md');
    auditChecks = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_v96z_Tchecks.csv');
    findingsMd = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_v96z_findings.md');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_audit_c_after_conclusions.txt');
    traceMat = fullfile(traceDir,'MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_v96z.mat');

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

    methodsKey = "Reproducibility configuration of the formal multiobjective run";
    costKey = "Traceability of economic and CO2 factors";
    discussionKey = "The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate";
    limitationsKey = "Several limitations must be considered when interpreting the optimization and baseline-comparison results";
    conclusionsKey = "This study developed a controlled multiobjective optimization and post-processing workflow";

    cntMethods = count(string(master),methodsKey);
    cntCost = count(string(master),costKey);
    cntDisc = count(string(master),discussionKey);
    cntLim = count(string(master),limitationsKey);
    cntConc = count(string(master),conclusionsKey);

    cntDiscTitle = count(string(master),"### Discussion");
    cntLimTitle = count(string(master),"### Limitations");
    cntConcTitle = count(string(master),"### Conclusions");

    s7 = extract_section7_flexible(master);
    section7Detectable = strlength(string(s7)) > 0;
    section7OK = true;
    if section7Detectable && strlength(lockedText) > 0
        section7OK = section_similarity_ok(string(s7),lockedText);
    end

    orderOK = section_order_ok(master,discussionKey,limitationsKey,conclusionsKey);

    forbiddenGlobalOptimum = contains(low,"global optimum") || contains(low,"globally optimal");
    forbiddenGlobalPareto = contains(low,"global pareto front");
    robustnessClaim = contains(low,"statistically robust") || contains(low,"robust across seeds") || contains(low,"statistical robustness was demonstrated");
    finalCO2Claim = contains(low,"final co2 reduction") || contains(low,"final emission reduction") || contains(low,"definitive emission reduction");
    finalCostClaim = contains(low,"final cost reduction") || contains(low,"final economic saving") || contains(low,"definitive economic saving");
    solarOnlyBad = contains(low,"solar-only was included in the formal multiobjective comparison") || contains(low,"solar only was included in the formal multiobjective comparison");
    h2Bad = contains(low,"h2 was selected as an r1 solution") || contains(low,"h2 is a newly optimized r1 solution");

    checks = {};
    checks{end+1,1} = row("MACC-001","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = row("MACC-002","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = row("MACC-003","Methods integration report exists",isfile(methodsReport),methodsReport);
    checks{end+1,1} = row("MACC-004","Cost/CO2 integration report exists",isfile(costReport),costReport);
    checks{end+1,1} = row("MACC-005","Discussion integration report exists",isfile(discussionReport),discussionReport);
    checks{end+1,1} = row("MACC-006","Limitations integration report exists",isfile(limitationsReport),limitationsReport);
    checks{end+1,1} = row("MACC-007","Conclusions integration report exists",isfile(conclusionsReport),conclusionsReport);
    checks{end+1,1} = row("MACC-008","R1 reproducibility table exists",isfile(r1ReproTable),r1ReproTable);
    checks{end+1,1} = row("MACC-009","Cost/CO2 traceability matrix exists",isfile(costCo2Matrix),costCo2Matrix);
    checks{end+1,1} = row("MACC-010","Headings diagnostic report created",isfile(headingsReport),headingsReport);

    checks{end+1,1} = row("MACC-011","Methods block present once",cntMethods==1,"Count = " + string(cntMethods));
    checks{end+1,1} = row("MACC-012","Cost/CO2 block present once",cntCost==1,"Count = " + string(cntCost));
    checks{end+1,1} = row("MACC-013","Discussion block present once",cntDisc==1,"Count = " + string(cntDisc));
    checks{end+1,1} = row("MACC-014","Limitations block present once",cntLim==1,"Count = " + string(cntLim));
    checks{end+1,1} = row("MACC-015","Conclusions block present once",cntConc==1,"Count = " + string(cntConc));
    checks{end+1,1} = row("MACC-016","Discussion title present once",cntDiscTitle==1,"Count = " + string(cntDiscTitle));
    checks{end+1,1} = row("MACC-017","Limitations title present once",cntLimTitle==1,"Count = " + string(cntLimTitle));
    checks{end+1,1} = row("MACC-018","Conclusions title present once",cntConcTitle==1,"Count = " + string(cntConcTitle));
    checks{end+1,1} = row("MACC-019","Minimum section order valid",orderOK,"Expected Results -> Discussion -> Limitations -> Conclusions -> References when detectable.");
    checks{end+1,1} = row("MACC-020","Section 7 detectable or locked fallback",section7Detectable || isfile(lockedSection7),"Section7Detectable=" + string(section7Detectable));
    checks{end+1,1} = row("MACC-021","Section 7 preserved against locked version when comparable",section7OK,"Flexible anchor comparison.");

    checks{end+1,1} = row("MACC-022","gamultiobj present",contains(master,"gamultiobj"),"Algorithm.");
    checks{end+1,1} = row("MACC-023","Seed 61001 present",contains(master,"61001"),"Seed.");
    checks{end+1,1} = row("MACC-024","exitflag 0 present",contains(low,"exitflag 0"),"Exitflag.");
    checks{end+1,1} = row("MACC-025","Runtime 25.4 h present",contains(master,"25.4"),"Runtime.");
    checks{end+1,1} = row("MACC-026","MR threshold present",contains(low,"mr") && contains(master,"0.1"),"MR threshold.");
    checks{end+1,1} = row("MACC-027","Decision variables present",contains(master,"m_dot") && contains(master,"T_min") && contains(master,"r_rec") && contains(master,"t_rec_ini"),"m_dot, T_min, r_rec, t_rec_ini.");

    checks{end+1,1} = row("MACC-028","Computed nondominated set wording present",contains(low,"computed nondominated set"),"Computed nondominated set.");
    checks{end+1,1} = row("MACC-029","No prohibited global optimum wording",~forbiddenGlobalOptimum,"No global optimum / globally optimal.");
    checks{end+1,1} = row("MACC-030","No prohibited global Pareto front wording",~forbiddenGlobalPareto,"No global Pareto front.");
    checks{end+1,1} = row("MACC-031","No statistical robustness claim",~robustnessClaim,"No robust-across-seeds claim.");
    checks{end+1,1} = row("MACC-032","Robustness caveat present",contains(low,"does not establish statistical robustness") || contains(low,"not be interpreted as evidence of statistical robustness"),"Robustness caveat.");

    checks{end+1,1} = row("MACC-033","R1_solution_7 preserved",contains(master,"R1_solution_7") && contains(low,"energy-conservative"),"R1-7.");
    checks{end+1,1} = row("MACC-034","R1_solution_3 preserved",contains(master,"R1_solution_3") && contains(low,"balanced"),"R1-3.");
    checks{end+1,1} = row("MACC-035","R1_solution_9 preserved",contains(master,"R1_solution_9") && contains(low,"aggressive"),"R1-9.");
    checks{end+1,1} = row("MACC-036","H2 historical reference preserved",contains(master,"H2") && contains(low,"historical reference"),"H2.");
    checks{end+1,1} = row("MACC-037","No H2 new-R1 contradiction",~h2Bad,"No H2 new-R1 claim.");

    checks{end+1,1} = row("MACC-038","2-SAH sensitivity present",contains(low,"2-sah") && contains(low,"sensitivity"),"2-SAH.");
    checks{end+1,1} = row("MACC-039","Collector caveat present",contains(low,"fully coupled dynamic collector model") || contains(low,"fully coupled dynamic collector simulation"),"Collector caveat.");
    checks{end+1,1} = row("MACC-040","Fan-power limitation present",contains(low,"fan-power") || contains(low,"fan power"),"Fan-power.");
    checks{end+1,1} = row("MACC-041","Pressure-drop limitation present",contains(low,"pressure-drop") || contains(low,"pressure drop"),"Pressure-drop.");

    checks{end+1,1} = row("MACC-042","Hybrid vs gas-LPG present",contains(low,"hybrid") && contains(low,"gas-lpg"),"Hybrid/gas-LPG.");
    checks{end+1,1} = row("MACC-043","Solar/fuel substitution present",contains(low,"solar substitution") || contains(low,"fuel substitution"),"Substitution.");
    checks{end+1,1} = row("MACC-044","Solar-only exclusion preserved",contains(low,"solar-only") && contains(low,"excluded"),"Solar-only.");
    checks{end+1,1} = row("MACC-045","No solar-only formal-comparison contradiction",~solarOnlyBad,"No solar-only contradiction.");

    checks{end+1,1} = row("MACC-046","LPG provisional factor present",contains(master,"EF_LPG_kgCO2_per_kWh = 0.2270"),"LPG factor.");
    checks{end+1,1} = row("MACC-047","Grid provisional factor present",contains(master,"EF_grid_kgCO2_per_kWh = 0.4380"),"Grid factor.");
    checks{end+1,1} = row("MACC-048","Provisional tag present",contains(master,"PROVISIONAL_FOR_CODE_VALIDATION"),"Provisional tag.");
    checks{end+1,1} = row("MACC-049","Final source requirement present",contains(low,"definitive source") || contains(low,"definitive cited sources") || contains(low,"definitively sourced"),"Source requirement.");
    checks{end+1,1} = row("MACC-050","Unit basis requirement present",contains(low,"unit-basis") || contains(low,"unit basis"),"Unit basis.");
    checks{end+1,1} = row("MACC-051","Conversion procedure/assumption requirement present",contains(low,"conversion procedure") || contains(low,"conversion assumptions"),"Conversion.");
    checks{end+1,1} = row("MACC-052","No final CO2 claim",~finalCO2Claim,"No final CO2 claim.");
    checks{end+1,1} = row("MACC-053","No final cost claim",~finalCostClaim,"No final cost claim.");

    checks{end+1,1} = row("MACC-054","Discussion avoids numeric table repetition",~block_has_nums(master,discussionKey,["### Limitations","## Limitations","# Limitations","### Conclusions","## Conclusions","# Conclusions","### References","## References","# References"]),"No excessive Discussion numeric repetition.");
    checks{end+1,1} = row("MACC-055","Conclusions avoids numeric table repetition",~block_has_nums(master,conclusionsKey,["### References","## References","# References"]),"No excessive Conclusions numeric repetition.");
    checks{end+1,1} = row("MACC-056","Future seed replications present",contains(low,"additional random seeds") || contains(low,"independent seed replications"),"Future seeds.");
    checks{end+1,1} = row("MACC-057","Future coupled collector present",contains(low,"coupled collector"),"Future collector.");
    checks{end+1,1} = row("MACC-058","Future final economic/emission factors present",contains(low,"finalize the economic and emission factors") || (contains(low,"final economic") && contains(low,"emission factors")),"Future factors.");
    checks{end+1,1} = row("MACC-059","No GA executed",true,"Audit only.");
    checks{end+1,1} = row("MACC-060","No model executed",true,"Audit only.");
    checks{end+1,1} = row("MACC-061","MASTER not modified",true,"Read-only audit.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,auditChecks);

    failed = Tchecks(~Tchecks.pass,:);
    nFail = height(failed);

    if nFail == 0
        diagnosis = "MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_PASS";
        decision = "MASTER_READY_FOR_FULL_DRAFT_ASSEMBLY_AUDIT";
        next_step = "Proceed to full manuscript assembly audit or editorial review.";
    else
        diagnosis = "MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and decide whether to patch wording or section placement.";
    end

    write_findings(findingsMd,Tchecks,diagnosis,decision,next_step,cntMethods,cntCost,cntDisc,cntLim,cntConc,cntDiscTitle,cntLimTitle,cntConcTitle,section7Detectable,section7OK,orderOK);

    fid = fopen(auditReport,'w');
    if fid < 0
        error('Could not open audit report: %s',auditReport);
    end

    fprintf(fid,'# MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Failed checks\n\n`%d`\n\n',nFail);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Locked Section 7: `%s`\n',lockedSection7);
    fprintf(fid,'- Conclusions integration report: `%s`\n',conclusionsReport);
    fprintf(fid,'- Checks: `%s`\n',auditChecks);
    fprintf(fid,'- Findings: `%s`\n',findingsMd);
    fprintf(fid,'- Headings: `%s`\n\n',headingsReport);

    fprintf(fid,'## Summary counts\n\n');
    fprintf(fid,'| Item | Count/status |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Methods GA block | %d |\n',cntMethods);
    fprintf(fid,'| Cost/CO2 block | %d |\n',cntCost);
    fprintf(fid,'| Discussion key | %d |\n',cntDisc);
    fprintf(fid,'| Limitations key | %d |\n',cntLim);
    fprintf(fid,'| Conclusions key | %d |\n',cntConc);
    fprintf(fid,'| Discussion title | %d |\n',cntDiscTitle);
    fprintf(fid,'| Limitations title | %d |\n',cntLimTitle);
    fprintf(fid,'| Conclusions title | %d |\n',cntConcTitle);
    fprintf(fid,'| Section 7 detectable | %d |\n',section7Detectable);
    fprintf(fid,'| Section 7 protection OK | %d |\n',section7OK);
    fprintf(fid,'| Minimum section order OK | %d |\n\n',orderOK);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n',string(Tchecks.id(i)),string(Tchecks.check(i)),Tchecks.pass(i),string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(traceMat,'masterFile','lockedSection7','methodsReport','costReport','discussionReport','limitationsReport','conclusionsReport','auditReport','auditChecks','findingsMd','headingsReport','traceMat','Tchecks','diagnosis','decision','next_step','cntMethods','cntCost','cntDisc','cntLim','cntConc','section7Detectable','section7OK','orderOK');

    out = struct();
    out.status = "AUDIT_MASTER_AFTER_CONCLUSIONS_v96z_DONE";
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

    disp('=== AUDIT MASTER AFTER CONCLUSIONS v96z ===')
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

function tf = section_order_ok(txt,discussionKey,limitationsKey,conclusionsKey)
    idxRes = regexp(txt,'(?m)^#{1,6}\s*(?:7[\.\)]?\s+|Section 7\b|Results\b|RESULTS\b|Resultados\b|RESULTADOS\b).*$','start');
    idxDisc = strfind(txt,discussionKey);
    idxLim = strfind(txt,limitationsKey);
    idxConc = strfind(txt,conclusionsKey);
    idxRef = regexp(txt,'(?m)^#{1,6}\s*(?:\d+[\.\)]?\s*)?(?:References|Referencias)\b.*$','start');

    tf = true;
    if ~isempty(idxRes) && ~isempty(idxDisc), tf = tf && idxRes(1) < idxDisc(1); end
    if ~isempty(idxDisc) && ~isempty(idxLim), tf = tf && idxDisc(1) < idxLim(1); end
    if ~isempty(idxLim) && ~isempty(idxConc), tf = tf && idxLim(1) < idxConc(1); end
    if ~isempty(idxConc) && ~isempty(idxRef), tf = tf && idxConc(1) < idxRef(1); end
end

function tf = block_has_nums(txt,key,endMarkers)
    idxKey = strfind(txt,key);
    if isempty(idxKey)
        tf = false;
        return
    end
    startIdx = idxKey(1);
    endIdx = length(txt);
    for i = 1:numel(endMarkers)
        k = strfind(txt(startIdx:end),endMarkers(i));
        if ~isempty(k)
            endIdx = min(endIdx,startIdx+k(1)-2);
        end
    end
    block = string(txt(startIdx:endIdx));
    nums = ["656.23","723.36","1218.4","747.00","1194.1","1270.6","1773.9"];
    tf = false;
    for i = 1:numel(nums)
        if contains(block,nums(i)), tf = true; return; end
    end
end

function tf = section_similarity_ok(a,b)
    a = normalize_for_compare(a);
    b = normalize_for_compare(b);
    if strlength(a)==0 || strlength(b)==0
        tf = true;
        return
    end
    anchors = ["r1_solution_7","r1_solution_3","r1_solution_9","h2","hybrid","gas","2-sah","computed nondominated set","mr","q_aux"];
    tf = true;
    for i = 1:numel(anchors)
        if contains(b,anchors(i)) && ~contains(a,anchors(i))
            tf = false;
        end
    end
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
    if fid < 0, error('Could not write headings report: %s',filename); end
    fprintf(fid,'MASTER headings detected for after-Conclusions consistency audit\n\n');
    if isempty(matches)
        fprintf(fid,'No Markdown headings detected.\n');
    else
        for i = 1:numel(matches)
            fprintf(fid,'%04d | char %08d | %s\n',i,starts(i),matches{i});
        end
    end
    fclose(fid);
end

function write_findings(filename,Tchecks,diagnosis,decision,next_step,cntMethods,cntCost,cntDisc,cntLim,cntConc,cntDiscTitle,cntLimTitle,cntConcTitle,section7Detectable,section7OK,orderOK)
    fid = fopen(filename,'w');
    if fid < 0, error('Could not open findings file: %s',filename); end

    fprintf(fid,'# MASTER manuscript consistency after Conclusions audit findings\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Summary\n\n');
    fprintf(fid,'| Control | Value |\n|---|---:|\n');
    fprintf(fid,'| Methods GA block | %d |\n',cntMethods);
    fprintf(fid,'| Cost/CO2 block | %d |\n',cntCost);
    fprintf(fid,'| Discussion key | %d |\n',cntDisc);
    fprintf(fid,'| Limitations key | %d |\n',cntLim);
    fprintf(fid,'| Conclusions key | %d |\n',cntConc);
    fprintf(fid,'| Discussion title | %d |\n',cntDiscTitle);
    fprintf(fid,'| Limitations title | %d |\n',cntLimTitle);
    fprintf(fid,'| Conclusions title | %d |\n',cntConcTitle);
    fprintf(fid,'| Section 7 detectable | %d |\n',section7Detectable);
    fprintf(fid,'| Section 7 protection OK | %d |\n',section7OK);
    fprintf(fid,'| Section order OK | %d |\n\n',orderOK);

    failed = Tchecks(~Tchecks.pass,:);
    fprintf(fid,'## Failed checks\n\n');
    if height(failed)==0
        fprintf(fid,'No failed checks.\n\n');
    else
        fprintf(fid,'| id | check | evidence |\n|---|---|---|\n');
        for i = 1:height(failed)
            fprintf(fid,'| `%s` | %s | `%s` |\n',string(failed.id(i)),string(failed.check(i)),string(failed.evidence(i)));
        end
        fprintf(fid,'\n');
    end

    if height(failed)==0
        fprintf(fid,'## Internal verdict\n\n`MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_PASS`\n');
    else
        fprintf(fid,'## Internal verdict\n\n`MASTER_MANUSCRIPT_CONSISTENCY_AFTER_CONCLUSIONS_REVIEW_REQUIRED`\n');
    end
    fclose(fid);
end

function r = row(id,checkName,passVal,evidence)
    r = struct();
    r.id = string(id);
    r.check = string(checkName);
    r.pass = logical(passVal);
    r.evidence = string(evidence);
end
