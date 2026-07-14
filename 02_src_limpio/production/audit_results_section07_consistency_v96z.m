function out = audit_results_section07_consistency_v96z()
% AUDIT_RESULTS_SECTION07_CONSISTENCY_v96z
%
% 9.6z-results-draft-o
% AUDIT-RESULTS-SECTION-07-CONSISTENCY-001
%
% Objetivo:
%   Auditar consistencia de la Sección 7 Results and Discussion
%   dentro de MASTER_manuscript_v01.md.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica el manuscrito.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');
    tablesDir = fullfile(articleRoot,'tables');

    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    masterFile = fullfile(draftDir,'MASTER_manuscript_v01.md');

    if ~isfile(masterFile)
        error('Master file not found: %s', masterFile);
    end

    txt = fileread(masterFile);

    % ---------------------------------------------------------------
    % Extract Section 7
    % ---------------------------------------------------------------
    startMarker = "# 7. Results and discussion";
    endMarker = "# 8. Limitations";

    s = strfind(txt,startMarker);
    e = strfind(txt,endMarker);

    if isempty(s)
        error('Section 7 start marker not found: %s', startMarker);
    end

    if isempty(e)
        error('Section 8 marker not found: %s', endMarker);
    end

    s = s(1);
    e = e(1) - 1;

    section7 = char(txt);
    section7 = string(section7(s:e));

    % ---------------------------------------------------------------
    % Expected files
    % ---------------------------------------------------------------
    sec0701 = fullfile(draftDir,'SEC_07_01_formal_R1_run_v96z.md');
    sec0702 = fullfile(draftDir,'SEC_05_results_eta_sensitivity_v96z.md');
    sec0703 = fullfile(draftDir,'SEC_07_03_operational_interpretation_v96z.md');
    sec0704 = fullfile(draftDir,'SEC_07_04_methodological_implications_v96z.md');

    mainTable = fullfile(tablesDir,'MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md');
    suppTable = fullfile(tablesDir,'SUPP_TABLE_ETA_SENSITIVITY_v96z.md');

    % ---------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------
    checks = {};

    checks{end+1,1} = check_row("S07-01","Master manuscript exists",isfile(masterFile),masterFile);
    checks{end+1,1} = check_row("S07-02","Section 7 extracted",strlength(section7)>1000,"Section 7 length > 1000 chars.");

    checks{end+1,1} = check_row("S07-03","Subsection 7.1 present",contains(section7,"## 7.1 Formal tri-objective run"),"7.1 heading.");
    checks{end+1,1} = check_row("S07-04","Subsection 7.2 present",contains(section7,"## 7.2 Collector-efficiency sensitivity"),"7.2 heading.");
    checks{end+1,1} = check_row("S07-05","Subsection 7.3 present",contains(section7,"## 7.3 Operational interpretation"),"7.3 heading.");
    checks{end+1,1} = check_row("S07-06","Subsection 7.4 present",contains(section7,"## 7.4 Methodological implications"),"7.4 heading.");

    checks{end+1,1} = check_row("S07-07","SEC 7.1 source file exists",isfile(sec0701),sec0701);
    checks{end+1,1} = check_row("S07-08","SEC 7.2 source file exists",isfile(sec0702),sec0702);
    checks{end+1,1} = check_row("S07-09","SEC 7.3 source file exists",isfile(sec0703),sec0703);
    checks{end+1,1} = check_row("S07-10","SEC 7.4 source file exists",isfile(sec0704),sec0704);

    checks{end+1,1} = check_row("S07-11","Main manuscript table exists",isfile(mainTable),mainTable);
    checks{end+1,1} = check_row("S07-12","Supplementary sensitivity table exists",isfile(suppTable),suppTable);

    checks{end+1,1} = check_row("S07-13","Computed nondominated set wording present",contains(section7,"computed nondominated set"),"Required wording.");
    checks{end+1,1} = check_row("S07-14","No global optimum claim",~contains(lower(section7),"global optimum") && ~contains(lower(section7),"globally optimal"),"Avoids global optimum wording.");
    checks{end+1,1} = check_row("S07-15","No global Pareto front claim",~contains(lower(section7),"global pareto front"),"Avoids global Pareto claim.");
    checks{end+1,1} = check_row("S07-16","Statistical robustness caveat present",contains(section7,"statistical robustness"),"Seed robustness caveat.");
    checks{end+1,1} = check_row("S07-17","Additional seed replication caveat present",contains(section7,"additional independent seed replications"),"Replication caveat.");

    checks{end+1,1} = check_row("S07-18","R1-7 anchor present",contains(section7,"R1_solution_7") && contains(section7,"656.23 kWh") && contains(section7,"0.07057"),"R1-7 numerical anchor.");
    checks{end+1,1} = check_row("S07-19","R1-3 anchor present",contains(section7,"R1_solution_3") && contains(section7,"723.36 kWh") && contains(section7,"0.05493"),"R1-3 numerical anchor.");
    checks{end+1,1} = check_row("S07-20","H2 anchor present",contains(section7,"H2") && contains(section7,"747.00 kWh") && contains(section7,"0.044483"),"H2 numerical anchor.");
    checks{end+1,1} = check_row("S07-21","R1-9 anchor present",contains(section7,"R1_solution_9") && contains(section7,"1218.4 kWh") && contains(section7,"0.013876"),"R1-9 numerical anchor.");

    checks{end+1,1} = check_row("S07-22","MR feasibility criterion present",contains(section7,"MR ≤ 0.1") || contains(section7,"MR <= 0.1"),"Feasibility criterion.");
    checks{end+1,1} = check_row("S07-23","2-SAH curve present",contains(section7,"2-SAH"),"Collector-efficiency sensitivity.");
    checks{end+1,1} = check_row("S07-24","5-8 percent sensitivity magnitude present",contains(section7,"5–8%") || contains(section7,"5-8%"),"Sensitivity magnitude.");
    checks{end+1,1} = check_row("S07-25","Ranking-stable wording present",contains(section7,"ranking-stable") || contains(section7,"operational ranking was preserved"),"Ranking preservation.");
    checks{end+1,1} = check_row("S07-26","Fully coupled collector model caveat present",contains(section7,"fully coupled") && contains(section7,"collector"),"Collector model caveat.");

    checks{end+1,1} = check_row("S07-27","Fan-power limitation present",contains(section7,"fan power") || contains(section7,"fan-power"),"Fan-power caveat.");
    checks{end+1,1} = check_row("S07-28","Pressure-drop limitation present",contains(section7,"pressure drop") || contains(section7,"pressure-drop"),"Pressure-drop caveat.");
    checks{end+1,1} = check_row("S07-29","Process/equipment distinction present",contains(section7,"process-level") && contains(section7,"equipment-level"),"Process vs equipment distinction.");
    checks{end+1,1} = check_row("S07-30","Recirculation timing implication present",contains(section7,"recirculation timing"),"Recirculation timing.");

    checks{end+1,1} = check_row("S07-31","H2 treated as historical reference",contains(section7,"historical comparison") || contains(section7,"historical reference"),"H2 role.");
    checks{end+1,1} = check_row("S07-32","R1-7 treated as energy-saving candidate",contains(section7,"energy-saving") && contains(section7,"R1_solution_7"),"R1-7 role.");
    checks{end+1,1} = check_row("S07-33","R1-3 treated as balanced candidate",contains(section7,"balanced") && contains(section7,"R1_solution_3"),"R1-3 role.");
    checks{end+1,1} = check_row("S07-34","R1-9 treated as aggressive drying case",contains(section7,"aggressive drying") && contains(section7,"R1_solution_9"),"R1-9 role.");

    checks{end+1,1} = check_row("S07-35","No GA executed",true,"Audit only.");
    checks{end+1,1} = check_row("S07-36","No model executed",true,"Audit only.");

    Tchecks = struct2table(vertcat(checks{:}));

    % ---------------------------------------------------------------
    % Decision
    % ---------------------------------------------------------------
    nFail = sum(~Tchecks.pass);

    if nFail == 0
        diagnosis = "RESULTS_SECTION_07_CONSISTENCY_PASS";
        decision = "SECTION_07_READY_FOR_v01_LOCK";
        next_step = "Lock Results Section 7 as v01.";
    else
        diagnosis = "RESULTS_SECTION_07_CONSISTENCY_REVIEW_REQUIRED";
        decision = "FIX_FAILED_CHECKS_BEFORE_LOCK";
        next_step = "Inspect failed checks and patch Section 7.";
    end

    % ---------------------------------------------------------------
    % Write outputs
    % ---------------------------------------------------------------
    checksCsv = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_CONSISTENCY_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    section7File = fullfile(traceDir,'RESULTS_SECTION_07_EXTRACTED_v96z.md');
    fid = fopen(section7File,'w');
    if fid < 0
        error('Could not write extracted Section 7: %s', section7File);
    end
    fprintf(fid,'%s',section7);
    fclose(fid);

    reportMd = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_CONSISTENCY_v96z_report.md');
    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not write report: %s', reportMd);
    end

    fprintf(fid,'# AUDIT_RESULTS_SECTION07_CONSISTENCY_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Failed checks\n\n');

    if nFail == 0
        fprintf(fid,'No failed checks.\n\n');
    else
        Tfail = Tchecks(~Tchecks.pass,:);
        fprintf(fid,'| id | check | evidence |\n');
        fprintf(fid,'|---|---|---|\n');
        for i = 1:height(Tfail)
            fprintf(fid,'| `%s` | %s | `%s` |\n', ...
                string(Tfail.id(i)), string(Tfail.check(i)), string(Tfail.evidence(i)));
        end
        fprintf(fid,'\n');
    end

    fprintf(fid,'## All checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    outMat = fullfile(traceDir,'AUDIT_RESULTS_SECTION07_CONSISTENCY_v96z.mat');
    save(outMat,'masterFile','section7','Tchecks','diagnosis','decision','next_step','checksCsv','reportMd','section7File');

    out = struct();
    out.status = "AUDIT_RESULTS_SECTION07_CONSISTENCY_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.nFail = nFail;
    out.Tchecks = Tchecks;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.section7File = section7File;
    out.outMat = outMat;

    disp('=== AUDIT RESULTS SECTION 07 CONSISTENCY v96z ===')
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
    disp(out.section7File)
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end