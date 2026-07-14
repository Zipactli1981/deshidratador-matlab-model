function out = lock_results_section07_v01_v96z()
% LOCK_RESULTS_SECTION07_v01_v96z
%
% 9.6z-results-draft-q
% LOCK-RESULTS-SECTION-07-v01-001
%
% Objetivo:
%   Bloquear Results and Discussion Section 7 como v01,
%   usando la auditoría aprobada:
%   RESULTS_SECTION_07_CONSISTENCY_PASS
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica resultados.
% No reescribe el MASTER.
%
% Salidas:
%   - RESULTS_SECTION_07_v01_LOCKED.md
%   - RESULTS_SECTION_07_v01_LOCK_REPORT.md
%   - RESULTS_SECTION_07_v01_LOCK_Tchecks.csv
%   - RESULTS_SECTION_07_v01_LOCK.mat

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');
    lockDir = fullfile(articleRoot,'locked_sections');
    tablesDir = fullfile(articleRoot,'tables');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end
    if ~isfolder(lockDir), mkdir(lockDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');
    section7Extracted = fullfile(traceDir,'RESULTS_SECTION_07_EXTRACTED_v96z.md');
    auditReport = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_CONSISTENCY_v96z_report.md');
    auditChecks = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_CONSISTENCY_v96z_Tchecks.csv');

    sec0701 = fullfile(draftDir,'SEC_07_01_formal_R1_run_v96z.md');
    sec0702 = fullfile(draftDir,'SEC_05_results_eta_sensitivity_v96z.md');
    sec0703 = fullfile(draftDir,'SEC_07_03_operational_interpretation_v96z.md');
    sec0704 = fullfile(draftDir,'SEC_07_04_methodological_implications_v96z.md');

    mainTable = fullfile(tablesDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md');
    suppTable = fullfile(tablesDir,'SUPP_TABLE_ETA_SENSITIVITY_v96z.md');

    if ~isfile(masterFile)
        error('Master file not found: %s', masterFile);
    end

    if ~isfile(section7Extracted)
        error('Extracted Section 7 file not found. Run audit_results_section07_consistency_v96z first: %s', section7Extracted);
    end

    if ~isfile(auditChecks)
        error('Audit checks CSV not found. Run audit_results_section07_consistency_v96z first: %s', auditChecks);
    end

    Taudit = readtable(auditChecks);

    if ~ismember('pass',Taudit.Properties.VariableNames)
        error('Audit checks table does not contain pass column: %s', auditChecks);
    end

    if ~all(Taudit.pass)
        error('Cannot lock Section 7 because audit checks are not all PASS.');
    end

    section7Text = fileread(section7Extracted);

    lockTimestamp = string(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
    lockId = "RESULTS_SECTION_07_v01_LOCKED";
    lockDecision = "SECTION_07_LOCKED_AS_v01";
    lockDiagnosis = "RESULTS_SECTION_07_CONSISTENCY_PASS";

    lockedFile = fullfile(lockDir,'RESULTS_SECTION_07_v01_LOCKED.md');
    lockReport = fullfile(reviewDir,'RESULTS_SECTION_07_v01_LOCK_REPORT.md');
    lockChecksCsv = fullfile(reviewDir,'RESULTS_SECTION_07_v01_LOCK_Tchecks.csv');
    lockMat = fullfile(traceDir,'RESULTS_SECTION_07_v01_LOCK.mat');

    % ---------------------------------------------------------------
    % Write locked section
    % ---------------------------------------------------------------
    fid = fopen(lockedFile,'w');
    if fid < 0
        error('Could not open locked section for writing: %s', lockedFile);
    end

    fprintf(fid,'# RESULTS_SECTION_07_v01_LOCKED\n\n');
    fprintf(fid,'## Lock status\n\n');
    fprintf(fid,'`%s`\n\n',lockId);
    fprintf(fid,'## Lock timestamp\n\n');
    fprintf(fid,'`%s`\n\n',lockTimestamp);
    fprintf(fid,'## Lock diagnosis\n\n');
    fprintf(fid,'`%s`\n\n',lockDiagnosis);
    fprintf(fid,'## Lock decision\n\n');
    fprintf(fid,'`%s`\n\n',lockDecision);
    fprintf(fid,'## Source master\n\n');
    fprintf(fid,'`%s`\n\n',masterFile);
    fprintf(fid,'## Source audit\n\n');
    fprintf(fid,'- `%s`\n',auditReport);
    fprintf(fid,'- `%s`\n\n',auditChecks);
    fprintf(fid,'---\n\n');
    fprintf(fid,'%s\n',section7Text);

    fclose(fid);

    % ---------------------------------------------------------------
    % Lock checks
    % ---------------------------------------------------------------
    checks = {};

    checks{end+1,1} = check_row("LOCK07-01","Master manuscript exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("LOCK07-02","Extracted Section 7 exists",isfile(section7Extracted),section7Extracted);
    checks{end+1,1} = check_row("LOCK07-03","Audit report exists",isfile(auditReport),auditReport);
    checks{end+1,1} = check_row("LOCK07-04","Audit checks exist",isfile(auditChecks),auditChecks);
    checks{end+1,1} = check_row("LOCK07-05","Audit checks all PASS",all(Taudit.pass),"All audit checks are true.");
    checks{end+1,1} = check_row("LOCK07-06","Section 7.1 source exists",isfile(sec0701),sec0701);
    checks{end+1,1} = check_row("LOCK07-07","Section 7.2 source exists",isfile(sec0702),sec0702);
    checks{end+1,1} = check_row("LOCK07-08","Section 7.3 source exists",isfile(sec0703),sec0703);
    checks{end+1,1} = check_row("LOCK07-09","Section 7.4 source exists",isfile(sec0704),sec0704);
    checks{end+1,1} = check_row("LOCK07-10","Main table exists",isfile(mainTable),mainTable);
    checks{end+1,1} = check_row("LOCK07-11","Supplementary table exists",isfile(suppTable),suppTable);
    checks{end+1,1} = check_row("LOCK07-12","Locked section file created",isfile(lockedFile),lockedFile);
    checks{end+1,1} = check_row("LOCK07-13","Locked section contains 7.1",contains(fileread(lockedFile),"## 7.1 Formal tri-objective run"),"7.1 heading.");
    checks{end+1,1} = check_row("LOCK07-14","Locked section contains 7.2",contains(fileread(lockedFile),"## 7.2 Collector-efficiency sensitivity"),"7.2 heading.");
    checks{end+1,1} = check_row("LOCK07-15","Locked section contains 7.3",contains(fileread(lockedFile),"## 7.3 Operational interpretation"),"7.3 heading.");
    checks{end+1,1} = check_row("LOCK07-16","Locked section contains 7.4",contains(fileread(lockedFile),"## 7.4 Methodological implications"),"7.4 heading.");
    checks{end+1,1} = check_row("LOCK07-17","R1-7 anchor preserved",contains(fileread(lockedFile),"656.23 kWh") && contains(fileread(lockedFile),"0.07057"),"R1-7 anchor.");
    checks{end+1,1} = check_row("LOCK07-18","H2 anchor preserved",contains(fileread(lockedFile),"747.00 kWh") && contains(fileread(lockedFile),"0.044483"),"H2 anchor.");
    checks{end+1,1} = check_row("LOCK07-19","No GA executed",true,"Lock only.");
    checks{end+1,1} = check_row("LOCK07-20","No model executed",true,"Lock only.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,lockChecksCsv);

    if all(Tchecks.pass)
        diagnosis = "RESULTS_SECTION_07_v01_LOCK_PASS";
        decision = "RESULTS_SECTION_07_LOCKED_AS_v01";
        next_step = "Proceed to next manuscript section or decide whether new simulations are required.";
    else
        diagnosis = "RESULTS_SECTION_07_v01_LOCK_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_LOCK_CHECKS";
        next_step = "Review lock checks before treating Section 7 as closed.";
    end

    % ---------------------------------------------------------------
    % Write lock report
    % ---------------------------------------------------------------
    fid = fopen(lockReport,'w');
    if fid < 0
        error('Could not open lock report for writing: %s', lockReport);
    end

    fprintf(fid,'# RESULTS_SECTION_07_v01_LOCK_REPORT\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Lock timestamp\n\n`%s`\n\n',lockTimestamp);

    fprintf(fid,'## Locked file\n\n`%s`\n\n',lockedFile);

    fprintf(fid,'## Source files\n\n');
    fprintf(fid,'- Master: `%s`\n',masterFile);
    fprintf(fid,'- Extracted Section 7: `%s`\n',section7Extracted);
    fprintf(fid,'- Audit report: `%s`\n',auditReport);
    fprintf(fid,'- Audit checks: `%s`\n',auditChecks);
    fprintf(fid,'- Section 7.1: `%s`\n',sec0701);
    fprintf(fid,'- Section 7.2: `%s`\n',sec0702);
    fprintf(fid,'- Section 7.3: `%s`\n',sec0703);
    fprintf(fid,'- Section 7.4: `%s`\n',sec0704);
    fprintf(fid,'- Main table: `%s`\n',mainTable);
    fprintf(fid,'- Supplementary table: `%s`\n\n',suppTable);

    fprintf(fid,'## Locked content summary\n\n');
    fprintf(fid,'Section 7 Results and Discussion v01 includes:\n\n');
    fprintf(fid,'1. Formal tri-objective run.\n');
    fprintf(fid,'2. Collector-efficiency sensitivity.\n');
    fprintf(fid,'3. Operational interpretation.\n');
    fprintf(fid,'4. Methodological implications.\n\n');

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
        'masterFile','section7Extracted','auditReport','auditChecks', ...
        'sec0701','sec0702','sec0703','sec0704','mainTable','suppTable', ...
        'Tchecks','Taudit','diagnosis','decision','next_step','lockTimestamp');

    out = struct();
    out.status = "LOCK_RESULTS_SECTION07_v01_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.lockedFile = lockedFile;
    out.lockReport = lockReport;
    out.lockChecksCsv = lockChecksCsv;
    out.lockMat = lockMat;
    out.Tchecks = Tchecks;

    disp('=== LOCK RESULTS SECTION 07 v01 v96z ===')
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