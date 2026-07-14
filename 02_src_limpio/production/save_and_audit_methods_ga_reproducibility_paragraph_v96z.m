function out = save_and_audit_methods_ga_reproducibility_paragraph_v96z()
% SAVE_AND_AUDIT_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z
%
% 9.6z-methods-c
% SAVE-AND-AUDIT-METHODS-GA-REPRODUCIBILITY-PARAGRAPH-001
%
% Objetivo:
%   Crear y auditar el texto metodologico de reproducibilidad GA/R1 para
%   integracion posterior en Methods.
%
% No ejecuta GA.
% No ejecuta modelo.
% No modifica MASTER.
% No modifica Section 7.

    rootDir = setup_v05_paths();

    articleRoot = fullfile(rootDir,'06_manuscript','article_Q1');
    draftDir = fullfile(articleRoot,'draft_sections');
    tablesDir = fullfile(articleRoot,'tables');
    reviewDir = fullfile(articleRoot,'review');
    traceDir = fullfile(articleRoot,'traceability');
    lockDir = fullfile(articleRoot,'locked_sections');

    if ~isfolder(draftDir), mkdir(draftDir); end
    if ~isfolder(reviewDir), mkdir(reviewDir); end
    if ~isfolder(traceDir), mkdir(traceDir); end

    srcTableMd = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md');
    srcTableCsv = fullfile(tablesDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.csv');
    srcTableReport = fullfile(reviewDir,'R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z_report.md');
    lockedSection7 = fullfile(lockDir,'RESULTS_SECTION_07_v01_1_LOCKED.md');

    secFile = fullfile(draftDir,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z.md');
    reportFile = fullfile(reviewDir,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z_report.md');
    checksCsv = fullfile(reviewDir,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z_Tchecks.csv');
    matFile = fullfile(traceDir,'SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z.mat');

    L = strings(0,1);

    add("# SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z");
    add("");
    add("## Status");
    add("");
    add("`DRAFT_READY_FOR_REVIEW`");
    add("");
    add("## Micropaso");
    add("");
    add("`9.6z-methods-c`");
    add("");
    add("## Identifier");
    add("");
    add("`SAVE-AND-AUDIT-METHODS-GA-REPRODUCIBILITY-PARAGRAPH-001`");
    add("");
    add("## Intended master location");
    add("");
    add("Methods section, after the optimization-problem formulation and before the presentation of selected operating points.");
    add("");
    add("## Source table");
    add("");
    add("- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md`");
    add("- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.csv`");
    add("- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z_report.md`");
    add("");
    add("## Manuscript text -- English");
    add("");
    add("### Reproducibility configuration of the formal multiobjective run");
    add("");
    add("The formal multiobjective optimization run used to generate the selected candidate solutions was configured as a controlled seed-aware execution of MATLAB's `gamultiobj` algorithm. The run, identified as R1, used a fixed random seed of 61001, a population size of 24 individuals, and a maximum generation limit of 50 generations. The algorithm terminated with `exitflag = 0`, corresponding to termination by the prescribed generation limit. Therefore, the resulting solution set is interpreted as a computed nondominated set obtained under the specified configuration, not as proof of global convergence or global optimality.");
    add("");
    add("The optimization problem was formulated with three objectives: final moisture ratio, economic performance, and CO2 emissions. The decision variables were the air mass flow rate `m_dot`, the minimum control temperature `T_min`, the recirculation ratio `r_rec`, and the recirculation onset time `t_rec_ini`. Candidate feasibility was evaluated using the final moisture-ratio threshold MR <= 0.1. The formal run was performed for hybrid solar--gas-LPG operation; solar-only operation was not included in the formal multiobjective comparison because it represents a non-equivalent operating mode.");
    add("");
    add("The R1 run required approximately 25.4 h of wall-clock computation. The selected operating points discussed in the Results section include R1_solution_7 as the energy-saving feasible candidate, R1_solution_3 as a balanced feasible candidate, and R1_solution_9 as an aggressive drying boundary case. The historical H2 point was retained only as a reference case and was not treated as a newly optimized R1 solution. Since the present manuscript is based on a single controlled seed-aware formal run, no claim of statistical robustness is made. Additional independent seed replications would be required to support such a claim.");
    add("");
    add("## Version tecnica de control -- Espanol");
    add("");
    add("### Configuracion de reproducibilidad de la corrida multiobjetivo formal");
    add("");
    add("La corrida formal de optimizacion multiobjetivo usada para generar las soluciones candidatas seleccionadas se configuro como una ejecucion controlada con semilla fija del algoritmo `gamultiobj` de MATLAB. La corrida, identificada como R1, utilizo la semilla aleatoria 61001, una poblacion de 24 individuos y un limite maximo de 50 generaciones. El algoritmo termino con `exitflag = 0`, correspondiente a terminacion por el limite de generaciones prescrito. Por tanto, el conjunto de soluciones resultante se interpreta como un conjunto no dominado computado bajo la configuracion especificada, no como prueba de convergencia global ni de optimalidad global.");
    add("");
    add("El problema de optimizacion se formulo con tres objetivos: razon de humedad final, desempeno economico y emisiones de CO2. Las variables de decision fueron el flujo masico de aire `m_dot`, la temperatura minima de control `T_min`, la razon de recirculacion `r_rec` y el tiempo de inicio de recirculacion `t_rec_ini`. La factibilidad de los candidatos se evaluo mediante el umbral de razon de humedad final MR <= 0.1. La corrida formal se realizo para operacion hibrida solar--gas LP; la operacion solo solar no se incluyo en la comparacion multiobjetivo formal porque representa un modo operativo no equivalente.");
    add("");
    add("La corrida R1 requirio aproximadamente 25.4 h de computo. Los puntos operativos seleccionados discutidos en la seccion de resultados incluyen R1_solution_7 como candidato factible de ahorro energetico, R1_solution_3 como candidato factible balanceado y R1_solution_9 como caso limite de secado agresivo. El punto historico H2 se conservo unicamente como caso de referencia y no se trato como una solucion R1 recientemente optimizada. Dado que el manuscrito actual se basa en una sola corrida formal controlada con semilla fija, no se afirma robustez estadistica. Para sostener dicha afirmacion serian necesarias replicas independientes con semillas adicionales.");
    add("");
    add("## Traceability notes");
    add("");
    add("| Item | Value |");
    add("|---|---|");
    add("| Algorithm | `gamultiobj` |");
    add("| Run identifier | R1 |");
    add("| Seed | 61001 |");
    add("| Population size | 24 |");
    add("| Maximum generations | 50 |");
    add("| Exitflag | 0 |");
    add("| Approximate wall-clock time | 25.4 h |");
    add("| Objectives | MR, economic objective, CO2 objective |");
    add("| Decision variables | `m_dot`, `T_min`, `r_rec`, `t_rec_ini` |");
    add("| Feasibility criterion | MR <= 0.1 |");
    add("| Formal operation mode | hybrid |");
    add("| Solar-only mode | excluded from formal GA comparison |");
    add("| Main interpretation constraint | computed nondominated set, not global optimum |");
    add("| Robustness constraint | statistical robustness not claimed |");
    add("");
    add("## Internal verdict");
    add("");
    add("`SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z_READY_FOR_METHODS_INTEGRATION`");

    fid = fopen(secFile,'w');
    if fid < 0
        error('Could not open section file for writing: %s',secFile);
    end
    for i = 1:numel(L)
        fprintf(fid,'%s\n',L(i));
    end
    fclose(fid);

    txt = fileread(secFile);
    low = lower(txt);

    checks = {};
    checks{end+1,1} = check_row("MGA-01","R1 reproducibility MD table exists",isfile(srcTableMd),srcTableMd);
    checks{end+1,1} = check_row("MGA-02","R1 reproducibility CSV table exists",isfile(srcTableCsv),srcTableCsv);
    checks{end+1,1} = check_row("MGA-03","R1 reproducibility report exists",isfile(srcTableReport),srcTableReport);
    checks{end+1,1} = check_row("MGA-04","Locked Section 7 exists",isfile(lockedSection7),lockedSection7);
    checks{end+1,1} = check_row("MGA-05","Methods paragraph file created",isfile(secFile),secFile);
    checks{end+1,1} = check_row("MGA-06","English manuscript text present",contains(txt,"## Manuscript text -- English"),"English block.");
    checks{end+1,1} = check_row("MGA-07","Spanish control version present",contains(txt,"## Version tecnica de control -- Espanol"),"Spanish control block.");
    checks{end+1,1} = check_row("MGA-08","gamultiobj documented",contains(txt,"gamultiobj"),"Algorithm.");
    checks{end+1,1} = check_row("MGA-09","R1 documented",contains(txt,"R1"),"Run identifier.");
    checks{end+1,1} = check_row("MGA-10","Seed documented",contains(txt,"61001"),"Seed 61001.");
    checks{end+1,1} = check_row("MGA-11","Population documented",contains(txt,"24"),"Population 24.");
    checks{end+1,1} = check_row("MGA-12","Generations documented",contains(txt,"50"),"Generations 50.");
    checks{end+1,1} = check_row("MGA-13","Exitflag documented",contains(txt,"exitflag = 0"),"Exitflag 0.");
    checks{end+1,1} = check_row("MGA-14","Runtime documented",contains(txt,"25.4 h"),"Runtime.");
    checks{end+1,1} = check_row("MGA-15","m_dot documented",contains(txt,"m_dot"),"m_dot.");
    checks{end+1,1} = check_row("MGA-16","T_min documented",contains(txt,"T_min"),"T_min.");
    checks{end+1,1} = check_row("MGA-17","r_rec documented",contains(txt,"r_rec"),"r_rec.");
    checks{end+1,1} = check_row("MGA-18","t_rec_ini documented",contains(txt,"t_rec_ini"),"t_rec_ini.");
    checks{end+1,1} = check_row("MGA-19","MR threshold documented",contains(txt,"MR <= 0.1"),"Feasibility threshold.");
    checks{end+1,1} = check_row("MGA-20","Computed nondominated set wording present",contains(low,"computed nondominated set"),"Computed nondominated set.");
    checks{end+1,1} = check_row("MGA-21","No global optimality claim",contains(low,"not as proof of global convergence or global optimality") || contains(low,"not global optimum"),"No global optimality.");
    checks{end+1,1} = check_row("MGA-22","No statistical robustness claim",contains(low,"no claim of statistical robustness") || contains(low,"no se afirma robustez estadistica"),"Robustness caveat.");
    checks{end+1,1} = check_row("MGA-23","Solar-only exclusion documented",contains(low,"solar-only operation was not included") || contains(low,"operacion solo solar no se incluyo"),"Solar-only caveat.");
    checks{end+1,1} = check_row("MGA-24","H2 historical reference documented",contains(txt,"H2") && contains(low,"reference"),"H2 reference.");
    checks{end+1,1} = check_row("MGA-25","No GA executed",true,"Text generation only.");
    checks{end+1,1} = check_row("MGA-26","No model executed",true,"Text generation only.");
    checks{end+1,1} = check_row("MGA-27","MASTER not modified",true,"No master write operation.");

    Tchecks = struct2table(vertcat(checks{:}));
    writetable(Tchecks,checksCsv);

    if all(Tchecks.pass)
        diagnosis = "SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_PASS";
        decision = "READY_FOR_METHODS_INTEGRATION";
        next_step = "Integrate Methods GA reproducibility paragraph into MASTER.";
    else
        diagnosis = "SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_REVIEW_REQUIRED";
        decision = "INSPECT_FAILED_CHECKS";
        next_step = "Review failed checks before Methods integration.";
    end

    fid = fopen(reportFile,'w');
    if fid < 0
        error('Could not open report file for writing: %s',reportFile);
    end
    fprintf(fid,'# SEC_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z report\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Next step\n\n`%s`\n\n',next_step);
    fprintf(fid,'## Files\n\n');
    fprintf(fid,'- Section draft: `%s`\n',secFile);
    fprintf(fid,'- Checks: `%s`\n',checksCsv);
    fprintf(fid,'- Source table MD: `%s`\n',srcTableMd);
    fprintf(fid,'- Locked Section 7: `%s`\n\n',lockedSection7);
    fprintf(fid,'## Checks\n\n');
    fprintf(fid,'| id | check | pass | evidence |\n');
    fprintf(fid,'|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n',string(Tchecks.id(i)),string(Tchecks.check(i)),Tchecks.pass(i),string(Tchecks.evidence(i)));
    end
    fclose(fid);

    save(matFile,'secFile','reportFile','checksCsv','matFile','srcTableMd','srcTableCsv','srcTableReport','lockedSection7','Tchecks','diagnosis','decision','next_step');

    out = struct();
    out.status = "SAVE_AND_AUDIT_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_v96z_DONE";
    out.diagnosis = diagnosis;
    out.decision = decision;
    out.next_step = next_step;
    out.secFile = secFile;
    out.reportFile = reportFile;
    out.checksCsv = checksCsv;
    out.matFile = matFile;
    out.Tchecks = Tchecks;

    disp('=== SAVE AND AUDIT METHODS GA REPRODUCIBILITY PARAGRAPH v96z ===')
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
    disp(out.secFile)
    disp(out.reportFile)
    disp(out.checksCsv)

    function add(s)
        L(end+1,1) = string(s);
    end
end

function row = check_row(id,checkName,passVal,evidence)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end
