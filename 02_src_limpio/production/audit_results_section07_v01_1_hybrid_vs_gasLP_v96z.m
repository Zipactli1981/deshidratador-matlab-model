function out = audit_results_section07_v01_1_hybrid_vs_gasLP_v96z()
% AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z
%
% 9.6z-sim-lite-e
% AUDIT-RESULTS-SECTION-07-v01-1-WITH-HYBRID-vs-GASLP-001
%
% Objetivo:
%   Auditar Results Section 7 después de integrar la subsección:
%   7.2.1 Hybrid versus gas-LPG baseline comparison.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica MASTER.
%
% Salidas:
%   - AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_report.md
%   - AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_Tchecks.csv
%   - RESULTS_SECTION_07_v01_1_EXTRACTED_v96z.md
%   - AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z.mat

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    tablesDir = fullfile(articleRoot,'tables');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');

    sec0701 = fullfile(draftDir,'SEC_07_01_formal_R1_run_v96z.md');
    sec0702 = fullfile(draftDir,'SEC_05_results_eta_sensitivity_v96z.md');
    sec070201 = fullfile(draftDir,'SEC_07_02_01_hybrid_vs_gasLP_baseline_v96z.md');
    sec0703 = fullfile(draftDir,'SEC_07_03_operational_interpretation_v96z.md');
    sec0704 = fullfile(draftDir,'SEC_07_04_methodological_implications_v96z.md');

    mainTable = fullfile(tablesDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md');
    suppEtaTable = fullfile(tablesDir,'SUPP_TABLE_ETA_SENSITIVITY_v96z.md');

    baselineCsv = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z.csv');
    baselineSummaryCsv = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.csv');
    baselineSummaryMd = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md');
    baselineReport = fullfile(reviewDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_report.md');
    integrationReport = fullfile(reviewDir,'INTEGRATE_SEC070201_HYBRID_vs_GASLP_v96z_report.md');

    if ~isfile(masterFile)
        error('Master manuscript not found: %s', masterFile);
    end

    masterText = fileread(masterFile);

    % ---------------------------------------------------------------
    % Extract Section 7
    % ---------------------------------------------------------------
    startMarker = "# 7. Results and discussion";
    endMarker = "# 8. Limitations";

    idxStart = strfind(masterText,startMarker);
    idxEnd = strfind(masterText,endMarker);

    if isempty(idxStart)
        error('Section 7 start marker not found: %s', startMarker);
    end

    if isempty(idxEnd)
        error('Section 8 marker not found: %s', endMarker);
    end

    idxStart = idxStart(1);
    idxEnd = idxEnd(1) - 1;

    section7 = string(masterText(idxStart:idxEnd));

    extractedFile = fullfile(traceDir,'RESULTS_SECTION_07_v01_1_EXTRACTED_v96z.md');

    fid = fopen(extractedFile,'w');
    if fid < 0
        error('Could not write extracted Section 7: %s', extractedFile);
    end
    fprintf(fid,'%s\n',section7);
    fclose(fid);

    s7low = lower(section7);

    % ---------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------
    checks = {};

    checks{end+1,1} = check_row("S0711-01","Master manuscript exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("S0711-02","Section 7 extracted",strlength(section7)>1000,"Section 7 length > 1000 chars.");
    checks{end+1,1} = check_row("S0711-03","Subsection 7.1 present",contains(section7,"## 7.1 Formal tri-objective run"),"7.1 heading.");
    checks{end+1,1} = check_row("S0711-04","Subsection 7.2 present",contains(section7,"## 7.2 Collector-efficiency sensitivity"),"7.2 heading.");
    checks{end+1,1} = check_row("S0711-05","Subsection 7.2.1 present",contains(section7,"### 7.2.1 Hybrid versus gas-LPG baseline comparison"),"7.2.1 heading.");
    checks{end+1,1} = check_row("S0711-06","Subsection 7.3 present",contains(section7,"## 7.3 Operational interpretation"),"7.3 heading.");
    checks{end+1,1} = check_row("S0711-07","Subsection 7.4 present",contains(section7,"## 7.4 Methodological implications"),"7.4 heading.");

    checks{end+1,1} = check_row("S0711-08","SEC 7.1 source file exists",isfile(sec0701),sec0701);
    checks{end+1,1} = check_row("S0711-09","SEC 7.2 source file exists",isfile(sec0702),sec0702);
    checks{end+1,1} = check_row("S0711-10","SEC 7.2.1 source file exists",isfile(sec070201),sec070201);
    checks{end+1,1} = check_row("S0711-11","SEC 7.3 source file exists",isfile(sec0703),sec0703);
    checks{end+1,1} = check_row("S0711-12","SEC 7.4 source file exists",isfile(sec0704),sec0704);

    checks{end+1,1} = check_row("S0711-13","Main manuscript table exists",isfile(mainTable),mainTable);
    checks{end+1,1} = check_row("S0711-14","Supplementary eta sensitivity table exists",isfile(suppEtaTable),suppEtaTable);
    checks{end+1,1} = check_row("S0711-15","Hybrid-vs-gasLP full CSV exists",isfile(baselineCsv),baselineCsv);
    checks{end+1,1} = check_row("S0711-16","Hybrid-vs-gasLP summary CSV exists",isfile(baselineSummaryCsv),baselineSummaryCsv);
    checks{end+1,1} = check_row("S0711-17","Hybrid-vs-gasLP summary MD exists",isfile(baselineSummaryMd),baselineSummaryMd);
    checks{end+1,1} = check_row("S0711-18","Hybrid-vs-gasLP report exists",isfile(baselineReport),baselineReport);
    checks{end+1,1} = check_row("S0711-19","Integration report exists",isfile(integrationReport),integrationReport);

    checks{end+1,1} = check_row("S0711-20","Computed nondominated set wording present",contains(s7low,"computed nondominated set"),"Required wording.");
    checks{end+1,1} = check_row("S0711-21","No global optimum claim", ...
        ~contains(s7low,"global optimum") && ~contains(s7low,"globally optimal"), ...
        "Avoids global optimum wording.");
    checks{end+1,1} = check_row("S0711-22","No global Pareto front claim", ...
        ~contains(s7low,"global pareto front"), ...
        "Avoids global Pareto claim.");
    checks{end+1,1} = check_row("S0711-23","Statistical robustness caveat present", ...
        contains(s7low,"does not establish statistical robustness") || contains(s7low,"statistical robustness"), ...
        "Seed robustness caveat.");
    checks{end+1,1} = check_row("S0711-24","Additional seed replication caveat present", ...
        contains(s7low,"additional independent seed") || contains(s7low,"independent seed replication"), ...
        "Replication caveat.");

    checks{end+1,1} = check_row("S0711-25","R1-7 anchor present",contains(section7,"656.23") && contains(section7,"0.07057"),"R1-7 numerical anchor.");
    checks{end+1,1} = check_row("S0711-26","R1-3 anchor present",contains(section7,"723.36") && contains(section7,"0.05493"),"R1-3 numerical anchor.");
    checks{end+1,1} = check_row("S0711-27","H2 anchor present",contains(section7,"747.00") && contains(section7,"0.044483"),"H2 numerical anchor.");
    checks{end+1,1} = check_row("S0711-28","R1-9 anchor present",contains(section7,"1218.4") && contains(section7,"0.013876"),"R1-9 numerical anchor.");
    checks{end+1,1} = check_row("S0711-29","MR feasibility criterion present",contains(s7low,"mr") && contains(section7,"0.1"),"Feasibility criterion.");

    checks{end+1,1} = check_row("S0711-30","2-SAH curve present",contains(section7,"2-SAH"),"Collector-efficiency sensitivity.");
    checks{end+1,1} = check_row("S0711-31","5-8 percent sensitivity magnitude present", ...
        contains(section7,"5–8%") || contains(section7,"5-8%"), ...
        "Sensitivity magnitude.");
    checks{end+1,1} = check_row("S0711-32","Ranking-stable wording present", ...
        contains(s7low,"ranking") && (contains(s7low,"preserved") || contains(s7low,"stable")), ...
        "Ranking preservation.");
    checks{end+1,1} = check_row("S0711-33","Fully coupled collector model caveat present", ...
        contains(s7low,"fully coupled collector") || contains(s7low,"not a fully coupled collector"), ...
        "Collector model caveat.");
    checks{end+1,1} = check_row("S0711-34","Fan-power limitation present", ...
        contains(s7low,"fan") && contains(s7low,"power"), ...
        "Fan-power caveat.");
    checks{end+1,1} = check_row("S0711-35","Pressure-drop limitation present", ...
        contains(s7low,"pressure-drop") || contains(s7low,"pressure drop"), ...
        "Pressure-drop caveat.");
    checks{end+1,1} = check_row("S0711-36","Process/equipment distinction present", ...
        contains(s7low,"process-level") || contains(s7low,"equipment-level"), ...
        "Process vs equipment distinction.");
    checks{end+1,1} = check_row("S0711-37","Recirculation timing implication present", ...
        contains(s7low,"recirculation") && contains(s7low,"timing"), ...
        "Recirculation timing.");

    checks{end+1,1} = check_row("S0711-38","H2 treated as historical reference", ...
        contains(s7low,"historical") && contains(s7low,"h2"), ...
        "H2 role.");
    checks{end+1,1} = check_row("S0711-39","R1-7 treated as energy-saving candidate", ...
        contains(s7low,"r1_solution_7") && contains(s7low,"energy-saving"), ...
        "R1-7 role.");
    checks{end+1,1} = check_row("S0711-40","R1-3 treated as balanced candidate", ...
        contains(s7low,"r1_solution_3") && contains(s7low,"balanced"), ...
        "R1-3 role.");
    checks{end+1,1} = check_row("S0711-41","R1-9 treated as aggressive drying case", ...
        contains(s7low,"r1_solution_9") && contains(s7low,"aggressive"), ...
        "R1-9 role.");

    checks{end+1,1} = check_row("S0711-42","Hybrid-vs-gasLP caveat: not new optimization", ...
        contains(s7low,"not a new optimization run") || contains(s7low,"not a new optimization"), ...
        "Baseline comparison caveat.");
    checks{end+1,1} = check_row("S0711-43","Hybrid-vs-gasLP pointwise comparison wording present", ...
        contains(s7low,"pointwise baseline comparison"), ...
        "Pointwise baseline wording.");
    checks{end+1,1} = check_row("S0711-44","Hybrid-vs-gasLP reduction range present", ...
        contains(section7,"31.31%") && contains(section7,"45.05%"), ...
        "Reduction range.");
    checks{end+1,1} = check_row("S0711-45","H2 gasLP/hybrid baseline anchor present", ...
        contains(section7,"1292.6 kWh") && contains(section7,"747.00 kWh") && contains(section7,"42.21%"), ...
        "H2 baseline anchor.");
    checks{end+1,1} = check_row("S0711-46","R1-7 gasLP/hybrid baseline anchor present", ...
        contains(section7,"1194.1 kWh") && contains(section7,"656.23 kWh") && contains(section7,"45.05%"), ...
        "R1-7 baseline anchor.");
    checks{end+1,1} = check_row("S0711-47","R1-3 gasLP/hybrid baseline anchor present", ...
        contains(section7,"1270.6 kWh") && contains(section7,"723.36 kWh") && contains(section7,"43.07%"), ...
        "R1-3 baseline anchor.");
    checks{end+1,1} = check_row("S0711-48","R1-9 gasLP/hybrid baseline anchor present", ...
        contains(section7,"1773.9 kWh") && contains(section7,"1218.4 kWh") && contains(section7,"31.31%"), ...
        "R1-9 baseline anchor.");
    checks{end+1,1} = check_row("S0711-49","Solar substitution interpretation present", ...
        contains(s7low,"replacing part of the thermal requirement with solar contribution") || contains(s7low,"solar contribution"), ...
        "Solar substitution interpretation.");
    checks{end+1,1} = check_row("S0711-50","No drying-performance relaxation claim present", ...
        contains(s7low,"rather than by relaxing the drying performance") || contains(s7low,"without compromising"), ...
        "No drying-performance relaxation.");
    checks{end+1,1} = check_row("S0711-51","R1-7 lowest hybrid Q_aux statement present", ...
        contains(s7low,"lowest hybrid auxiliary-energy demand") || contains(s7low,"lowest hybrid q"), ...
        "R1-7 lowest hybrid energy statement.");

    checks{end+1,1} = check_row("S0711-52","No GA executed",true,"Audit only.");
    checks{end+1,1} = check_row("S0711-53","No model executed",true,"Audit only.");
    checks{end+1,1} = check_row("S0711-54","Master not modified by audit",true,"Read-only audit.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "RESULTS_SECTION_07_v01_1_WITH_HYBRID_vs_GASLP_PASS";
        decision = "SECTION_07_v01_1_READY_FOR_LOCK";
        next_step = "Lock Results Section 7 as v01.1.";
    else
        diagnosis = "RESULTS_SECTION_07_v01_1_WITH_HYBRID_vs_GASLP_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Patch Section 7 v01.1 or integration source before locking.";
    end

    reportMd = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_report.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open audit report for writing: %s', reportMd);
    end

    fprintf(fid,'# AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Extracted section\n\n`%s`\n\n',extractedFile);

    fprintf(fid,'## Files audited\n\n');
    fprintf(fid,'- Master: `%s`\n',masterFile);
    fprintf(fid,'- Section 7.1 source: `%s`\n',sec0701);
    fprintf(fid,'- Section 7.2 source: `%s`\n',sec0702);
    fprintf(fid,'- Section 7.2.1 source: `%s`\n',sec070201);
    fprintf(fid,'- Section 7.3 source: `%s`\n',sec0703);
    fprintf(fid,'- Section 7.4 source: `%s`\n',sec0704);
    fprintf(fid,'- Main table: `%s`\n',mainTable);
    fprintf(fid,'- Supplementary eta table: `%s`\n',suppEtaTable);
    fprintf(fid,'- Baseline summary: `%s`\n',baselineSummaryMd);
    fprintf(fid,'- Baseline report: `%s`\n',baselineReport);
    fprintf(fid,'- Integration report: `%s`\n\n',integrationReport);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    outMat = fullfile(traceDir,'AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z.mat');

    save(outMat, ...
        'masterFile','section7','extractedFile', ...
        'Tchecks','diagnosis','decision','next_step', ...
        'checksCsv','reportMd','outMat', ...
        'sec0701','sec0702','sec070201','sec0703','sec0704', ...
        'mainTable','suppEtaTable','baselineCsv','baselineSummaryCsv','baselineSummaryMd','baselineReport','integrationReport');

    out = struct();
    out.status = "AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.Tchecks = Tchecks;
    out.extractedFile = extractedFile;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.outMat = outMat;

    disp('=== AUDIT RESULTS SECTION 07 v01.1 HYBRID vs GASLP v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.reportMd)
    disp(out.extractedFile)
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end