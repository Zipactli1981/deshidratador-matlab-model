function out = build_R1_reproducibility_configuration_table_v96z()
% BUILD_R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z
%
% 9.6z-methods-a
% BUILD-R1-REPRODUCIBILITY-CONFIGURATION-TABLE-001
%
% Objetivo:
%   Construir una tabla metodologica de reproducibilidad para la corrida
%   formal R1 usada en Results Section 7.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica MASTER.
% No modifica resultados numericos.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    tablesDir  = fullfile(articleRoot,'tables');
    reviewDir  = fullfile(articleRoot,'review');
    traceDir   = fullfile(articleRoot,'traceability');
    lockDir    = fullfile(articleRoot,'locked_sections');

    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');
    lockReport = fullfile(reviewDir,'LOCK_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_report.md');
    auditReport = fullfile(reviewDir,'AUDIT_RESULTS_SECTION07_v01_1_HYBRID_vs_GASLP_v96z_report.md');

    item = strings(0,1);
    value = strings(0,1);
    category = strings(0,1);
    manuscript_use = strings(0,1);
    note = strings(0,1);

    add_row("Run identifier","R1 formal seed-aware tri-objective run","Run identity","Methods / Results reproducibility","Formal run used to select the computed nondominated candidates discussed in Section 7.");
    add_row("Random seed","61001","GA configuration","Methods","Seed used for the formal R1 run.");
    add_row("Population size","24","GA configuration","Methods","Population size used in the controlled formal run.");
    add_row("Maximum generations","50","GA configuration","Methods","Generation cap used for the formal run.");
    add_row("Exit flag","0","GA termination","Methods / Results caveat","Termination by maximum generations; not evidence of global convergence.");
    add_row("Approximate wall-clock time","25.4 h","Computational cost","Methods","Approximate runtime reported for the formal R1 execution.");
    add_row("Optimization algorithm","gamultiobj","GA configuration","Methods","MATLAB multiobjective genetic algorithm.");
    add_row("Number of objectives","3","Objective definition","Methods","Tri-objective optimization problem.");
    add_row("Objective 1","Final moisture ratio, MR","Objective definition","Methods","Drying-performance objective.");
    add_row("Objective 2","Specific cost / economic objective","Objective definition","Methods","Economic objective; final factor traceability still required before submission.");
    add_row("Objective 3","CO2 emissions objective","Objective definition","Methods","Environmental objective; final emission-factor traceability still required before submission.");
    add_row("Decision variable 1","m_dot","Decision variables","Methods","Air mass flow rate.");
    add_row("Decision variable 2","T_min","Decision variables","Methods","Minimum control temperature.");
    add_row("Decision variable 3","r_rec","Decision variables","Methods","Recirculation ratio.");
    add_row("Decision variable 4","t_rec_ini","Decision variables","Methods","Recirculation onset time.");
    add_row("Feasibility criterion","MR <= 0.1","Feasibility","Methods / Results","Selected feasible points satisfy the target final moisture-ratio threshold.");
    add_row("Operation mode in formal run","hybrid","Model configuration","Methods","Hybrid solar + gas-LPG operation.");
    add_row("Solar-only treatment","Excluded from formal GA comparison","Model configuration","Methods / Limitations","Solar-only endpoint is non-equivalent and should remain separate from the formal GA comparison.");
    add_row("Collector-efficiency treatment in Section 7","Sensitivity analysis using constant eta, historical embedded curve, and 2-SAH curve","Post-processing / sensitivity","Methods / Results","Collector efficiency was evaluated as a sensitivity analysis, not as a fully coupled collector model.");
    add_row("Main collector-efficiency sensitivity curve","eta_article_2SAH_curve","Post-processing / sensitivity","Methods / Results","Consistent with two solar air heaters in series per battery.");
    add_row("Selected candidate R1_solution_7","m_dot = 0.070502 kg/s; T_min = 64.429 C; r_rec = 0.74259; t_rec_ini = 13.255 h","Selected candidates","Results","Energy-saving feasible candidate.");
    add_row("Selected candidate R1_solution_3","m_dot = 0.075518 kg/s; T_min = 65.054 C; r_rec = 0.78863; t_rec_ini = 12.874 h","Selected candidates","Results","Balanced feasible candidate.");
    add_row("Selected candidate R1_solution_9","m_dot = 0.092264 kg/s; T_min = 67.675 C; r_rec = 0.43299; t_rec_ini = 13.829 h","Selected candidates","Results","Aggressive drying boundary case.");
    add_row("Historical reference H2","m_dot = 0.07355 kg/s; T_min = 65.879 C; r_rec = 0.61205; t_rec_ini = 12.385 h","Historical reference","Results","Historical deeper-drying reference, not a newly optimized R1 solution.");
    add_row("Statistical robustness statement","Not established by R1 alone","Interpretation constraint","Methods / Limitations","Additional independent seed replications would be required to claim statistical robustness.");
    add_row("Global optimality statement","Not claimed","Interpretation constraint","Methods / Limitations","The result is a computed nondominated set, not a proof of global optimality.");
    add_row("Equipment-level optimality statement","Not claimed","Interpretation constraint","Limitations","Fan power and pressure-drop coupling were not included as fully coupled equipment-level objectives.");
    add_row("Section 7 lock status","RESULTS_SECTION_07_v01_1_LOCKED","Traceability","Internal control","Results Section 7 was locked before building this Methods reproducibility table.");

    T = table(item,value,category,manuscript_use,note, ...
        'VariableNames',{'item','value','category','manuscript_use','note'});

    csvFile = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.csv');
    mdFile = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');

    writetable(T,csvFile);
    write_md_table(mdFile,T);

    checks = {};
    checks{end+1,1} = check_row("R1REP-01","Locked Section 7 v01.1 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("R1REP-02","Lock report exists",isfile(lockReport),lockReport);
    checks{end+1,1} = check_row("R1REP-03","Audit report exists",isfile(auditReport),auditReport);
    checks{end+1,1} = check_row("R1REP-04","CSV output created",isfile(csvFile),csvFile);
    checks{end+1,1} = check_row("R1REP-05","MD output created",isfile(mdFile),mdFile);
    checks{end+1,1} = check_row("R1REP-06","Seed documented",any(T.value=="61001"),"seed = 61001.");
    checks{end+1,1} = check_row("R1REP-07","Population documented",any(T.value=="24"),"population = 24.");
    checks{end+1,1} = check_row("R1REP-08","Generations documented",any(T.value=="50"),"generations = 50.");
    checks{end+1,1} = check_row("R1REP-09","Exitflag documented",any(T.value=="0"),"exitflag = 0.");
    checks{end+1,1} = check_row("R1REP-10","Runtime documented",any(contains(T.value,"25.4")), "runtime approx 25.4 h.");
    checks{end+1,1} = check_row("R1REP-11","Decision variable m_dot documented",any(contains(T.value,"m_dot")) || any(T.item=="Decision variable 1"),"m_dot.");
    checks{end+1,1} = check_row("R1REP-12","Decision variable T_min documented",any(contains(T.value,"T_min")) || any(T.item=="Decision variable 2"),"T_min.");
    checks{end+1,1} = check_row("R1REP-13","Decision variable r_rec documented",any(contains(T.value,"r_rec")) || any(T.item=="Decision variable 3"),"r_rec.");
    checks{end+1,1} = check_row("R1REP-14","Decision variable t_rec_ini documented",any(contains(T.value,"t_rec_ini")) || any(T.item=="Decision variable 4"),"t_rec_ini.");
    checks{end+1,1} = check_row("R1REP-15","Feasibility criterion documented",any(contains(T.value,"MR <= 0.1")),"MR <= 0.1.");
    checks{end+1,1} = check_row("R1REP-16","No global optimality claim documented",any(T.item=="Global optimality statement") && any(contains(T.value,"Not claimed")),"Global optimality not claimed.");
    checks{end+1,1} = check_row("R1REP-17","Statistical robustness caveat documented",any(T.item=="Statistical robustness statement"),"Robustness caveat.");
    checks{end+1,1} = check_row("R1REP-18","Collector sensitivity caveat documented",any(contains(T.note,"fully coupled collector model")),"Collector caveat.");
    checks{end+1,1} = check_row("R1REP-19","R1_solution_7 documented",any(T.item=="Selected candidate R1_solution_7"),"R1_solution_7.");
    checks{end+1,1} = check_row("R1REP-20","R1_solution_3 documented",any(T.item=="Selected candidate R1_solution_3"),"R1_solution_3.");
    checks{end+1,1} = check_row("R1REP-21","R1_solution_9 documented",any(T.item=="Selected candidate R1_solution_9"),"R1_solution_9.");
    checks{end+1,1} = check_row("R1REP-22","H2 documented as historical reference",any(T.item=="Historical reference H2"),"H2 reference.");
    checks{end+1,1} = check_row("R1REP-23","No GA executed",true,"Table construction only.");
    checks{end+1,1} = check_row("R1REP-24","No model executed",true,"Table construction only.");
    checks{end+1,1} = check_row("R1REP-25","MASTER not modified",true,"No master write operation.");

    Tchecks = struct2table(vertcat(checks{:}));

    checksCsv = fullfile(reviewDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z_Tchecks.csv');
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "R1_REPRODUCIBILITY_CONFIGURATION_TABLE_PASS";
        decision = "USE_TABLE_IN_METHODS";
        next_step = "Draft Methods GA reproducibility paragraph.";
    else
        diagnosis = "R1_REPRODUCIBILITY_CONFIGURATION_TABLE_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review failed checks before using table in Methods.";
    end

    reportMd = fullfile(reviewDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z_report.md');

    fid = fopen(reportMd,'w');
    if fid < 0
        error('Could not open report file: %s', reportMd);
    end

    fprintf(fid,'# R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);

    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- CSV: `%s`\n',csvFile);
    fprintf(fid,'- Markdown table: `%s`\n',mdFile);
    fprintf(fid,'- Checks: `%s`\n',checksCsv);
    fprintf(fid,'- Locked Section 7: `%s`\n\n',lockedSection7);

    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n', ...
            string(Tchecks.id(i)), string(Tchecks.check(i)), Tchecks.pass(i), string(Tchecks.evidence(i)));
    end

    fclose(fid);

    matFile = fullfile(traceDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.mat');

    save(matFile,'T','Tchecks','csvFile','mdFile','checksCsv','reportMd','matFile','diagnosis','decision','next_step');

    out = struct();
    out.status = "BUILD_R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.T = T;
    out.Tchecks = Tchecks;
    out.csvFile = csvFile;
    out.mdFile = mdFile;
    out.checksCsv = checksCsv;
    out.reportMd = reportMd;
    out.matFile = matFile;

    disp('=== BUILD R1 REPRODUCIBILITY CONFIGURATION TABLE v96z ===')
    disp(out.status)
    disp('=== DIAGNOSIS ===')
    disp(out.diagnosis)
    disp('=== DECISION ===')
    disp(out.decision)
    disp('=== NEXT STEP ===')
    disp(out.next_step)
    disp('=== TABLE ===')
    disp(out.T)
    disp('=== FAILED CHECKS ===')
    disp(out.Tchecks(~out.Tchecks.pass,:))
    disp('=== ALL CHECKS ===')
    disp(out.Tchecks)
    disp('=== FILES ===')
    disp(out.csvFile)
    disp(out.mdFile)
    disp(out.reportMd)

    function add_row(itemIn,valueIn,categoryIn,useIn,noteIn)
        item(end+1,1) = string(itemIn);
        value(end+1,1) = string(valueIn);
        category(end+1,1) = string(categoryIn);
        manuscript_use(end+1,1) = string(useIn);
        note(end+1,1) = string(noteIn);
    end
end

function write_md_table(filename,T)
    fid = fopen(filename,'w');
    if fid < 0
        error('Could not open Markdown table file: %s', filename);
    end

    fprintf(fid,'# R1 reproducibility configuration table\n\n');
    fprintf(fid,'Micropaso: `9.6z-methods-a`\n\n');
    fprintf(fid,'Identifier: `BUILD-R1-REPRODUCIBILITY-CONFIGURATION-TABLE-001`\n\n');
    fprintf(fid,'Status: `DRAFT_READY_FOR_METHODS`\n\n');
    fprintf(fid,'No GA was executed. No model was executed. This table documents the already completed R1 formal run.\n\n');

    fprintf(fid,'| Item | Value | Category | Manuscript use | Note |\n');
    fprintf(fid,'|---|---|---|---|---|\n');

    for i = 1:height(T)
        fprintf(fid,'| %s | %s | %s | %s | %s |\n', ...
            escape_md(T.item(i)), ...
            escape_md(T.value(i)), ...
            escape_md(T.category(i)), ...
            escape_md(T.manuscript_use(i)), ...
            escape_md(T.note(i)));
    end

    fclose(fid);
end

function s = escape_md(x)
    s = string(x);
    s = replace(s,"|","\|");
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end
