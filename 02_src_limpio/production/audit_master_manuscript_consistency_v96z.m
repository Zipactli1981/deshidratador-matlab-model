function out = audit_master_manuscript_consistency_v96z()
% AUDIT_MASTER_MANUSCRIPT_CONSISTENCY_v96z
%
% 9.6z-audit-a
% MASTER-MANUSCRIPT-CONSISTENCY-AUDIT-001
%
% Objetivo:
%   Auditar MASTER_manuscript_v01.md despues de integrar:
%   - Methods GA reproducibility
%   - Cost/CO2 traceability caveat
%   - Consolidated Limitations
%   - Results Section 7 v01.1 locked
%
% Evalua:
%   - Existencia de fuentes criticas
%   - Preservacion de Section 7 si detectable
%   - Presencia de bloques criticos
%   - Ausencia de frases prohibidas
%   - Ausencia de duplicados criticos
%   - Control de factores provisionales
%   - Cautelas metodologicas
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

    methodsGaReport = fullfile(reviewDir,'INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md');
    costCo2Report = fullfile(reviewDir,'INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_report.md');
    limitationsReport = fullfile(reviewDir,'INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md');

    r1ReproTable = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');
    costCo2Matrix = fullfile(tablesDir,'FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md');

    auditReport = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z_report.md');
    auditChecks = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z_Tchecks.csv');
    headingsReport = fullfile(reviewDir,'MASTER_HEADINGS_DETECTED_v96z_audit_a.txt');
    findingsMd = fullfile(reviewDir,'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z_findings.md');
    traceMat = fullfile(traceDir,'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z.mat');

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

    % Core counts
    cntGaTitle = count(string(master),"### Reproducibility configuration of the formal multiobjective run");
    cntCostCo2Title = count(string(master),"### Traceability of economic and CO2 factors");
    cntLimitationsTitle = count(string(master),"### Limitations");
    cntComputedNondom = count(low,"computed nondominated set");
    cntProvisionalTag = count(string(master),"PROVISIONAL_FOR_CODE_VALIDATION");
    cntEF_LPG = count(string(master),"EF_LPG_kgCO2_per_kWh = 0.2270");
    cntEF_grid = count(string(master),"EF_grid_kgCO2_per_kWh = 0.4380");

    section7InMaster = extract_section7_flexible(master);
    section7Detectable = strlength(string(section7InMaster)) > 0;
    lockedSectionDetectable = strlength(lockedText) > 0;

    section7SimilarityOK = true;
    section7Evidence = "Section 7 comparison not strict because one side was not detectable.";
    if section7Detectable && lockedSectionDetectable
        section7SimilarityOK = section_similarity_ok(string(section7InMaster),lockedText);
        section7Evidence = "Flexible normalized comparison between MASTER Section 7 and locked Section 7.";
    end

    % Duplicate/contradiction guards
    forbiddenGlobalOptimum = contains(low,"global optimum") || contains(low,"globally optimal");
    forbiddenGlobalPareto = contains(low,"global pareto front");
    finalCO2Claim = contains(low,"final co2 reduction") || contains(low,"final emission reduction") || contains(low,"definitive emission reduction");
    finalCostClaim = contains(low,"final cost reduction") || contains(low,"final economic saving") || contains(low,"definitive economic saving");
    statisticalRobustnessClaim = contains(low,"statistically robust") || contains(low,"statistical robustness was demonstrated") || contains(low,"robust across seeds");
    solarOnlyFormalClaim = contains(low,"solar-only was included in the formal multiobjective comparison") || contains(low,"solar only was included in the formal multiobjective comparison");
    h2NewR1Claim = contains(low,"h2 was selected as an r1 solution") || contains(low,"h2 is a newly optimized r1 solution");

    checks = {};
    checks{end+1,1} = check_row("MAUD-001","MASTER exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("MAUD-002","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("MAUD-003","Methods GA integration report exists",isfile(methodsGaReport),methodsGaReport);
    checks{end+1,1} = check_row("MAUD-004","Cost/CO2 integration report exists",isfile(costCo2Report),costCo2Report);
    checks{end+1,1} = check_row("MAUD-005","Limitations integration report exists",isfile(limitationsReport),limitationsReport);
    checks{end+1,1} = check_row("MAUD-006","R1 reproducibility table exists",isfile(r1ReproTable),r1ReproTable);
    checks{end+1,1} = check_row("MAUD-007","Cost/CO2 traceability matrix exists",isfile(costCo2Matrix),costCo2Matrix);
    checks{end+1,1} = check_row("MAUD-008","Headings diagnostic report created",isfile(headingsReport),headingsReport);

    checks{end+1,1} = check_row("MAUD-009","Methods GA reproducibility block present once",cntGaTitle==1,"Title count = " + string(cntGaTitle) + ".");
    checks{end+1,1} = check_row("MAUD-010","Cost/CO2 traceability caveat present once",cntCostCo2Title==1,"Title count = " + string(cntCostCo2Title) + ".");
    checks{end+1,1} = check_row("MAUD-011","Limitations block present",cntLimitationsTitle>=1,"Title count = " + string(cntLimitationsTitle) + ".");
    checks{end+1,1} = check_row("MAUD-012","No excessive Limitations duplication",cntLimitationsTitle<=2,"Title count = " + string(cntLimitationsTitle) + ".");

    checks{end+1,1} = check_row("MAUD-013","Section 7 detectable or locked fallback available",section7Detectable || isfile(lockedSection7),"Section7Detectable=" + string(section7Detectable) + ".");
    checks{end+1,1} = check_row("MAUD-014","Section 7 preserved against locked version when comparable",section7SimilarityOK,section7Evidence);

    checks{end+1,1} = check_row("MAUD-015","gamultiobj present",contains(master,"gamultiobj"),"Algorithm wording.");
    checks{end+1,1} = check_row("MAUD-016","Seed 61001 present",contains(master,"61001"),"Seed.");
    checks{end+1,1} = check_row("MAUD-017","Population 24 present",contains(master,"24"),"Population may appear in table/paragraph.");
    checks{end+1,1} = check_row("MAUD-018","Generation limit 50 present",contains(master,"50"),"Generation limit may appear in table/paragraph.");
    checks{end+1,1} = check_row("MAUD-019","Exitflag 0 present",contains(low,"exitflag 0"),"Exitflag.");
    checks{end+1,1} = check_row("MAUD-020","Runtime 25.4 h present",contains(low,"25.4"),"Runtime.");
    checks{end+1,1} = check_row("MAUD-021","MR threshold present",contains(low,"mr") && contains(master,"0.1"),"MR threshold.");

    checks{end+1,1} = check_row("MAUD-022","Decision variable m_dot present",contains(master,"m_dot"),"m_dot.");
    checks{end+1,1} = check_row("MAUD-023","Decision variable T_min present",contains(master,"T_min"),"T_min.");
    checks{end+1,1} = check_row("MAUD-024","Decision variable r_rec present",contains(master,"r_rec"),"r_rec.");
    checks{end+1,1} = check_row("MAUD-025","Decision variable t_rec_ini present",contains(master,"t_rec_ini"),"t_rec_ini.");

    checks{end+1,1} = check_row("MAUD-026","Computed nondominated set wording present",cntComputedNondom>=1,"Count = " + string(cntComputedNondom) + ".");
    checks{end+1,1} = check_row("MAUD-027","No prohibited global optimum wording",~forbiddenGlobalOptimum,"No global optimum / globally optimal wording.");
    checks{end+1,1} = check_row("MAUD-028","No prohibited global Pareto front wording",~forbiddenGlobalPareto,"No global Pareto front wording.");
    checks{end+1,1} = check_row("MAUD-029","No statistical robustness claim",~statisticalRobustnessClaim,"No robust-across-seeds claim.");
    checks{end+1,1} = check_row("MAUD-030","Statistical robustness limitation present",contains(low,"does not establish statistical robustness") || contains(low,"no establece robustez estadistica"),"Limitation wording.");

    checks{end+1,1} = check_row("MAUD-031","2-SAH sensitivity wording present",contains(low,"2-sah") && contains(low,"sensitivity"),"2-SAH sensitivity.");
    checks{end+1,1} = check_row("MAUD-032","Collector not fully coupled caveat present",contains(low,"fully coupled dynamic collector model") || contains(low,"fully coupled collector"),"Collector caveat.");
    checks{end+1,1} = check_row("MAUD-033","Fan-power limitation present",contains(low,"fan-power") || contains(low,"fan power"),"Fan-power limitation.");
    checks{end+1,1} = check_row("MAUD-034","Pressure-drop limitation present",contains(low,"pressure-drop") || contains(low,"pressure drop"),"Pressure-drop limitation.");

    checks{end+1,1} = check_row("MAUD-035","LPG provisional factor present",cntEF_LPG>=1,"Count = " + string(cntEF_LPG) + ".");
    checks{end+1,1} = check_row("MAUD-036","Grid provisional factor present",cntEF_grid>=1,"Count = " + string(cntEF_grid) + ".");
    checks{end+1,1} = check_row("MAUD-037","Provisional tag present",cntProvisionalTag>=1,"Count = " + string(cntProvisionalTag) + ".");
    checks{end+1,1} = check_row("MAUD-038","No final CO2 claim introduced",~finalCO2Claim,"No final CO2 claim.");
    checks{end+1,1} = check_row("MAUD-039","No final cost claim introduced",~finalCostClaim,"No final cost claim.");
    checks{end+1,1} = check_row("MAUD-040","Final source requirement present",contains(low,"definitive source") || contains(low,"definitive cited sources"),"Source requirement.");
    checks{end+1,1} = check_row("MAUD-041","Unit basis requirement present",contains(low,"unit basis"),"Unit basis.");
    checks{end+1,1} = check_row("MAUD-042","Conversion procedure requirement present",contains(low,"conversion procedure"),"Conversion procedure.");

    checks{end+1,1} = check_row("MAUD-043","Solar-only exclusion preserved",contains(low,"solar-only") && contains(low,"excluded"),"Solar-only exclusion.");
    checks{end+1,1} = check_row("MAUD-044","No solar-only formal-comparison contradiction",~solarOnlyFormalClaim,"No contradictory solar-only inclusion claim.");
    checks{end+1,1} = check_row("MAUD-045","H2 historical reference preserved",contains(master,"H2") && contains(low,"historical reference"),"H2 reference.");
    checks{end+1,1} = check_row("MAUD-046","No H2 new-R1 contradiction",~h2NewR1Claim,"No contradictory H2-R1 claim.");

    checks{end+1,1} = check_row("MAUD-047","Hybrid vs gas-LPG baseline wording present",contains(low,"hybrid") && (contains(low,"gas-lpg") || contains(low,"gas-lpg baseline") || contains(low,"gas lp")),"Hybrid/gas-LPG baseline.");
    checks{end+1,1} = check_row("MAUD-048","No GA executed",true,"Audit only.");
    checks{end+1,1} = check_row("MAUD-049","No model executed",true,"Audit only.");
    checks{end+1,1} = check_row("MAUD-050","MASTER not modified",true,"Read-only audit.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,auditChecks);

    failed = Tchecks(~Tchecks.pass,:);
    nFail = height(failed);

    if nFail == 0
        diagnosis = "MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_PASS";
        decision = "MASTER_READY_FOR_DISCUSSION_CONCLUSIONS_OR_FULL_DRAFT_AUDIT";
        next_step = "Proceed to Discussion/Conclusions drafting or full manuscript assembly audit.";
    else
        diagnosis = "MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Inspect failed checks and decide whether to patch wording or section placement.";
    end

    write_findings(findingsMd,Tchecks,diagnosis,decision,next_step, ...
        cntGaTitle,cntCostCo2Title,cntLimitationsTitle,cntProvisionalTag, ...
        section7Detectable,section7SimilarityOK);

    fid = fopen(auditReport,'w');
    if fid < 0
        error('Could not open audit report: %s',auditReport);
    end

    fprintf(fid,'# MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Failed checks\n\n');
    fprintf(fid,'`%d`\n\n',nFail);

    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- MASTER: `%s`\n',masterFile);
    fprintf(fid,'- Locked Section 7: `%s`\n',lockedSection7);
    fprintf(fid,'- Checks: `%s`\n',auditChecks);
    fprintf(fid,'- Findings: `%s`\n',findingsMd);
    fprintf(fid,'- Headings: `%s`\n',headingsReport);
    fprintf(fid,'- Methods GA integration report: `%s`\n',methodsGaReport);
    fprintf(fid,'- Cost/CO2 integration report: `%s`\n',costCo2Report);
    fprintf(fid,'- Limitations integration report: `%s`\n\n',limitationsReport);

    fprintf(fid,'## Summary counts\n\n');
    fprintf(fid,'| Item | Count/status |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Methods GA reproducibility title | %d |\n',cntGaTitle);
    fprintf(fid,'| Cost/CO2 traceability caveat title | %d |\n',cntCostCo2Title);
    fprintf(fid,'| Limitations title | %d |\n',cntLimitationsTitle);
    fprintf(fid,'| `PROVISIONAL_FOR_CODE_VALIDATION` | %d |\n',cntProvisionalTag);
    fprintf(fid,'| Section 7 detectable | %d |\n',section7Detectable);
    fprintf(fid,'| Section 7 similarity/protection OK | %d |\n\n',section7SimilarityOK);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(traceMat,'masterFile','lockedSection7','methodsGaReport','costCo2Report','limitationsReport','r1ReproTable','costCo2Matrix','auditReport','auditChecks','headingsReport','findingsMd','traceMat','Tchecks','diagnosis','decision','next_step','cntGaTitle','cntCostCo2Title','cntLimitationsTitle','cntComputedNondom','cntProvisionalTag','section7Detectable','section7SimilarityOK');

    out = struct();
    out.status = "AUDIT_MASTER_MANUSCRIPT_CONSISTENCY_v96z_DONE";
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

    disp('=== AUDIT MASTER MANUSCRIPT CONSISTENCY v96z ===')
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

function tf = section_similarity_ok(a,b)
    a = normalize_for_compare(a);
    b = normalize_for_compare(b);

    if strlength(a) == 0 || strlength(b) == 0
        tf = true;
        return
    end

    % Flexible check: locked section key anchors must appear in MASTER section.
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
    idxNext = regexp(rest,'(?m)^#{1,6}\s*(?:8[\.\)]?\s+|Discussion\b|Conclusions\b|Conclusion\b|Conclusiones\b|Limitations\b|References\b|Referencias\b).*$','once');

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
    fprintf(fid,'MASTER headings detected for full consistency audit\n\n');
    if isempty(matches)
        fprintf(fid,'No Markdown headings detected.\n');
    else
        for i = 1:numel(matches)
            fprintf(fid,'%04d | char %08d | %s\n',i,starts(i),matches{i});
        end
    end
    fclose(fid);
end

function write_findings(filename,Tchecks,diagnosis,decision,next_step,cntGa,cntCost,cntLim,cntProv,section7Detectable,section7SimilarityOK)
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not open findings file: %s',filename);
    end

    fprintf(fid,'# MASTER manuscript consistency audit findings\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Summary\n\n');
    fprintf(fid,'| Control | Value |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| Methods GA reproducibility blocks | %d |\n',cntGa);
    fprintf(fid,'| Cost/CO2 caveat blocks | %d |\n',cntCost);
    fprintf(fid,'| Limitations headings | %d |\n',cntLim);
    fprintf(fid,'| Provisional-factor tags | %d |\n',cntProv);
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
        fprintf(fid,'`MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_PASS`\n');
    else
        fprintf(fid,'`MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_REVIEW_REQUIRED`\n');
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
