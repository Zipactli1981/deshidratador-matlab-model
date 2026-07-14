function out = lock_results_section07_v01_1_hybrid_vs_gasLP_v96z()
% LOCK_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z
%
% 9.6z-sim-lite-f
% LOCK-RESULTS-SECTION-07-v01-1-WITH-HYBRID-vs-GASLP-001
%
% Objetivo:
%   Bloquear Results Section 7 como v01.1 después de integrar:
%   7.2.1 Hybrid versus gas-LPG baseline comparison.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica MASTER.
% No modifica resultados numéricos.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir   = fullfile(articleRoot,'draft_sections');
    reviewDir  = fullfile(articleRoot,'review');
    traceDir   = fullfile(articleRoot,'traceability');
    lockDir    = fullfile(articleRoot,'locked_sections');
    tablesDir  = fullfile(articleRoot,'tables');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end
    if ~isfolder(lockDir), mkdir(lockDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');

    auditReport = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_report.md');
    auditChecks = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_Tchecks.csv');
    extractedFile = fullfile(traceDir,'RESULTS_SECTION_07_v01_1_EXTRACTED_v96z.md');

    sec0701   = fullfile(draftDir,'SEC_07_01_formal_R1_run_v96z.md');
    sec0702   = fullfile(draftDir,'SEC_05_results_eta_sensitivity_v96z.md');
    sec070201 = fullfile(draftDir,'SEC_07_02_01_hybrid_vs_gasLP_baseline_v96z.md');
    sec0703   = fullfile(draftDir,'SEC_07_03_operational_interpretation_v96z.md');
    sec0704   = fullfile(draftDir,'SEC_07_04_methodological_implications_v96z.md');

    mainTable = fullfile(tablesDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md');
    suppEtaTable = fullfile(tablesDir,'SUPP_TABLE_ETA_SENSITIVITY_v96z.md');

    baselineFullCsv = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z.csv');
    baselineSummaryCsv = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.csv');
    baselineSummaryMd = fullfile(tablesDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md');
    baselineReport = fullfile(reviewDir,'SELECTED_POINTS_HYBRID_vs_GASLP_v96z_report.md');
    integrationReport = fullfile(reviewDir,'INTEGRATE_SEC070201_HYBRID_vs_GASLP_v96z_report.md');

    if ~isfile(masterFile)
        error('Master manuscript not found: %s', masterFile);
    end

    if ~isfile(auditChecks)
        error('Audit checks CSV not found. Run audit first: %s', auditChecks);
    end

    if ~isfile(extractedFile)
        error('Extracted Section 7 v01.1 not found. Run audit first: %s', extractedFile);
    end

    Taudit = readtable(auditChecks);

    if ~ismember('pass',Taudit.Properties.VariableNames)
        error('Audit checks table does not contain pass column: %s', auditChecks);
    end

    if ~all(Taudit.pass)
        error('Cannot lock Section 7 v01.1 because not all audit checks are PASS.');
    end

    section7Text = fileread(extractedFile);

    lockTimestamp = string(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
    lockId = "RESULTS_SECTION_07_v01_1_LOCKED";

    lockedFile = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');
    lockReport = fullfile(reviewDir,'LOCK_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_report.md');
    lockChecksCsv = fullfile(reviewDir,'LOCK_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_Tchecks.csv');
    lockMat = fullfile(traceDir,'RESULTS_SECTION_07_v01_1_LOCK.mat');

    % ---------------------------------------------------------------
    % Write locked section
    % ---------------------------------------------------------------
    fid = fopen(lockedFile,'w');
    if fid < 0
        error('Could not open locked section for writing: %s', lockedFile);
    end

    fprintf(fid,'# RESULTS_SECTION_07_v01_1_LOCKED\n\n');
    fprintf(fid,'## Lock status\n\n`%s`\n\n',lockId);
    fprintf(fid,'## Lock timestamp\n\n`%s`\n\n',lockTimestamp);
    fprintf(fid,'## Required audit diagnosis\n\n`RESULTS_SECTION_07_v01_1_WITH_HYBRID_vs_GASLP_PASS`\n\n');
    fprintf(fid,'## Required audit decision\n\n`SECTION_07_v01_1_READY_FOR_LOCK`\n\n');
    fprintf(fid,'## Source master\n\n`%s`\n\n',masterFile);
    fprintf(fid,'## Source audit\n\n');
    fprintf(fid,'- `%s`\n',auditReport);
    fprintf(fid,'- `%s`\n\n',auditChecks);
    fprintf(fid,'## Source extracted section\n\n`%s`\n\n',extractedFile);
    fprintf(fid,'---\n\n');
    fprintf(fid,'%s\n',section7Text);

    fclose(fid);

    lockedText = fileread(lockedFile);
    lockedLow = lower(lockedText);

    % ---------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------
    checks = {};

    checks{end+1,1} = check_row("L0711-01","Master manuscript exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("L0711-02","Audit report exists",isfile(auditReport),auditReport);
    checks{end+1,1} = check_row("L0711-03","Audit checks CSV exists",isfile(auditChecks),auditChecks);
    checks{end+1,1} = check_row("L0711-04","Extracted Section 7 v01.1 exists",isfile(extractedFile),extractedFile);
    checks{end+1,1} = check_row("L0711-05","Audit checks all PASS",all(Taudit.pass),"All audit checks are true.");

    checks{end+1,1} = check_row("L0711-06","Section 7.1 source exists",isfile(sec0701),sec0701);
    checks{end+1,1} = check_row("L0711-07","Section 7.2 source exists",isfile(sec0702),sec0702);
    checks{end+1,1} = check_row("L0711-08","Section 7.2.1 source exists",isfile(sec070201),sec070201);
    checks{end+1,1} = check_row("L0711-09","Section 7.3 source exists",isfile(sec0703),sec0703);
    checks{end+1,1} = check_row("L0711-10","Section 7.4 source exists",isfile(sec0704),sec0704);

    checks{end+1,1} = check_row("L0711-11","Main manuscript table exists",isfile(mainTable),mainTable);
    checks{end+1,1} = check_row("L0711-12","Supplementary eta table exists",isfile(suppEtaTable),suppEtaTable);
    checks{end+1,1} = check_row("L0711-13","Hybrid-vs-gasLP full CSV exists",isfile(baselineFullCsv),baselineFullCsv);
    checks{end+1,1} = check_row("L0711-14","Hybrid-vs-gasLP summary CSV exists",isfile(baselineSummaryCsv),baselineSummaryCsv);
    checks{end+1,1} = check_row("L0711-15","Hybrid-vs-gasLP summary MD exists",isfile(baselineSummaryMd),baselineSummaryMd);
    checks{end+1,1} = check_row("L0711-16","Hybrid-vs-gasLP report exists",isfile(baselineReport),baselineReport);
    checks{end+1,1} = check_row("L0711-17","Hybrid-vs-gasLP integration report exists",isfile(integrationReport),integrationReport);

    checks{end+1,1} = check_row("L0711-18","Locked file created",isfile(lockedFile),lockedFile);
    checks{end+1,1} = check_row("L0711-19","Locked Section 7.1 present",contains(lockedText,"## 7.1 Formal tri-objective run"),"7.1 heading.");
    checks{end+1,1} = check_row("L0711-20","Locked Section 7.2 present",contains(lockedText,"## 7.2 Collector-efficiency sensitivity"),"7.2 heading.");
    checks{end+1,1} = check_row("L0711-21","Locked Section 7.2.1 present",contains(lockedText,"### 7.2.1 Hybrid versus gas-LPG baseline comparison"),"7.2.1 heading.");
    checks{end+1,1} = check_row("L0711-22","Locked Section 7.3 present",contains(lockedText,"## 7.3 Operational interpretation"),"7.3 heading.");
    checks{end+1,1} = check_row("L0711-23","Locked Section 7.4 present",contains(lockedText,"## 7.4 Methodological implications"),"7.4 heading.");

    checks{end+1,1} = check_row("L0711-24","Computed nondominated set wording preserved",contains(lockedLow,"computed nondominated set"),"Core wording.");
    checks{end+1,1} = check_row("L0711-25","No global optimum claim", ...
        ~contains(lockedLow,"global optimum") && ~contains(lockedLow,"globally optimal"), ...
        "Avoids global optimum wording.");
    checks{end+1,1} = check_row("L0711-26","No global Pareto front claim", ...
        ~contains(lockedLow,"global pareto front"), ...
        "Avoids global Pareto claim.");
    checks{end+1,1} = check_row("L0711-27","Statistical robustness caveat preserved", ...
        contains(lockedLow,"statistical robustness"), ...
        "Seed robustness caveat.");

    checks{end+1,1} = check_row("L0711-28","R1-7 anchor preserved",contains(lockedText,"656.23") && contains(lockedText,"0.07057"),"R1-7 numerical anchor.");
    checks{end+1,1} = check_row("L0711-29","R1-3 anchor preserved",contains(lockedText,"723.36") && contains(lockedText,"0.05493"),"R1-3 numerical anchor.");
    checks{end+1,1} = check_row("L0711-30","H2 anchor preserved",contains(lockedText,"747.00") && contains(lockedText,"0.044483"),"H2 numerical anchor.");
    checks{end+1,1} = check_row("L0711-31","R1-9 anchor preserved",contains(lockedText,"1218.4") && contains(lockedText,"0.013876"),"R1-9 numerical anchor.");

    checks{end+1,1} = check_row("L0711-32","Hybrid-vs-gasLP reduction range preserved", ...
        contains(lockedText,"31.31%") && contains(lockedText,"45.05%"), ...
        "Hybrid-vs-gasLP reduction range.");
    checks{end+1,1} = check_row("L0711-33","H2 gasLP/hybrid anchor preserved", ...
        contains(lockedText,"1292.6 kWh") && contains(lockedText,"747.00 kWh") && contains(lockedText,"42.21%"), ...
        "H2 baseline anchor.");
    checks{end+1,1} = check_row("L0711-34","R1-7 gasLP/hybrid anchor preserved", ...
        contains(lockedText,"1194.1 kWh") && contains(lockedText,"656.23 kWh") && contains(lockedText,"45.05%"), ...
        "R1-7 baseline anchor.");
    checks{end+1,1} = check_row("L0711-35","R1-3 gasLP/hybrid anchor preserved", ...
        contains(lockedText,"1270.6 kWh") && contains(lockedText,"723.36 kWh") && contains(lockedText,"43.07%"), ...
        "R1-3 baseline anchor.");
    checks{end+1,1} = check_row("L0711-36","R1-9 gasLP/hybrid anchor preserved", ...
        contains(lockedText,"1773.9 kWh") && contains(lockedText,"1218.4 kWh") && contains(lockedText,"31.31%"), ...
        "R1-9 baseline anchor.");

    checks{end+1,1} = check_row("L0711-37","Fully coupled collector caveat preserved", ...
        contains(lockedLow,"fully coupled collector model"), ...
        "Collector model caveat.");
    checks{end+1,1} = check_row("L0711-38","Fan-power limitation preserved", ...
        contains(lockedLow,"fan") && contains(lockedLow,"power"), ...
        "Fan-power caveat.");
    checks{end+1,1} = check_row("L0711-39","Pressure-drop limitation preserved", ...
        contains(lockedLow,"pressure-drop") || contains(lockedLow,"pressure drop"), ...
        "Pressure-drop caveat.");

    checks{end+1,1} = check_row("L0711-40","Lock report path defined",strlength(string(lockReport))>0,lockReport);
    checks{end+1,1} = check_row("L0711-41","No GA executed",true,"Lock only.");
    checks{end+1,1} = check_row("L0711-42","No model executed",true,"Lock only.");
    checks{end+1,1} = check_row("L0711-43","MASTER not modified by lock",true,"Read/copy lock operation.");

    Tchecks = struct2table(vertcat(checks{:}));

    writetable(Tchecks,lockChecksCsv);

    if all(Tchecks.pass)
        diagnosis = "RESULTS_SECTION_07_v01_1_LOCK_PASS";
        decision = "RESULTS_SECTION_07_v01_1_LOCKED";
        next_step = "Proceed to Methods reproducibility table, final cost/CO2 traceability, or manuscript limitations.";
    else
        diagnosis = "RESULTS_SECTION_07_v01_1_LOCK_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_LOCK_CHECKS";
        next_step = "Inspect failed lock checks before treating Section 7 v01.1 as closed.";
    end

    % ---------------------------------------------------------------
    % Write lock report
    % ---------------------------------------------------------------
    fid = fopen(lockReport,'w');
    if fid < 0
        error('Could not open lock report for writing: %s', lockReport);
    end

    fprintf(fid,'# LOCK_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Lock timestamp\n\n`%s`\n\n',lockTimestamp);

    fprintf(fid,'## Locked section\n\n`%s`\n\n',lockedFile);

    fprintf(fid,'## Required audit status\n\n');
    fprintf(fid,'- Diagnosis: `RESULTS_SECTION_07_v01_1_WITH_HYBRID_vs_GASLP_PASS`\n');
    fprintf(fid,'- Decision: `SECTION_07_v01_1_READY_FOR_LOCK`\n\n');

    fprintf(fid,'## Source files\n\n');
    fprintf(fid,'- Master: `%s`\n',masterFile);
    fprintf(fid,'- Extracted Section 7 v01.1: `%s`\n',extractedFile);
    fprintf(fid,'- Audit report: `%s`\n',auditReport);
    fprintf(fid,'- Audit checks: `%s`\n',auditChecks);
    fprintf(fid,'- Section 7.1: `%s`\n',sec0701);
    fprintf(fid,'- Section 7.2: `%s`\n',sec0702);
    fprintf(fid,'- Section 7.2.1: `%s`\n',sec070201);
    fprintf(fid,'- Section 7.3: `%s`\n',sec0703);
    fprintf(fid,'- Section 7.4: `%s`\n',sec0704);
    fprintf(fid,'- Main table: `%s`\n',mainTable);
    fprintf(fid,'- Supplementary eta table: `%s`\n',suppEtaTable);
    fprintf(fid,'- Hybrid-vs-gasLP full CSV: `%s`\n',baselineFullCsv);
    fprintf(fid,'- Hybrid-vs-gasLP summary CSV: `%s`\n',baselineSummaryCsv);
    fprintf(fid,'- Hybrid-vs-gasLP summary MD: `%s`\n',baselineSummaryMd);
    fprintf(fid,'- Hybrid-vs-gasLP report: `%s`\n',baselineReport);
    fprintf(fid,'- Hybrid-vs-gasLP integration report: `%s`\n\n',integrationReport);

    fprintf(fid,'## Locked content summary\n\n');
    fprintf(fid,'Results Section 7 v01.1 includes:\n\n');
    fprintf(fid,'1. Formal tri-objective run.\n');
    fprintf(fid,'2. Collector-efficiency sensitivity.\n');
    fprintf(fid,'3. Hybrid versus gas-LPG baseline comparison.\n');
    fprintf(fid,'4. Operational interpretation.\n');
    fprintf(fid,'5. Methodological implications.\n\n');

    fprintf(fid,'## Lock checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    save(lockMat, ...
        'lockedFile','lockReport','lockChecksCsv','lockMat', ...
        'masterFile','auditReport','auditChecks','extractedFile', ...
        'sec0701','sec0702','sec070201','sec0703','sec0704', ...
        'mainTable','suppEtaTable','baselineFullCsv','baselineSummaryCsv','baselineSummaryMd','baselineReport','integrationReport', ...
        'Taudit','Tchecks','diagnosis','decision','next_step','lockTimestamp');

    out = struct();
    out.status = "LOCK_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.lockedFile = lockedFile;
    out.lockReport = lockReport;
    out.lockChecksCsv = lockChecksCsv;
    out.lockMat = lockMat;
    out.Tchecks = Tchecks;

    disp('=== LOCK RESULTS SECTION 07 v01.1 HYBRID vs GASLP v96z ===')
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
    disp(out.lockedFile)
    disp(out.lockReport)
    disp(out.lockChecksCsv)
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end