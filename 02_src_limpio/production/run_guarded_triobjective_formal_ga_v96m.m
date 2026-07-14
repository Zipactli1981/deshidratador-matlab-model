function formal = run_guarded_triobjective_formal_ga_v96m(confirm_execute)
% RUN_GUARDED_TRIOBJECTIVE_FORMAL_GA_v96m
% 9.6m — CREATE-TRIOBJECTIVE-FORMAL-RUN-SCRIPT-001
%
% Objetivo:
%   Crear y ejecutar, solo con confirmación explícita, la corrida formal
%   triobjetivo:
%
%       f(1) = MR_final
%       f(2) = cost_specific_USD_per_kgwater
%       f(3) = CO2_specific_kgCO2_per_kgwater
%
% Función objetivo:
%   objective_productive_corrected_v96j_triobjective_CO2_fix1
%
% Escenario aprobado en 9.6l:
%   F1 — HYBRID_TRIOBJECTIVE_FORMAL_PLUS_GASLP_REFERENCE
%   Mode = hybrid
%   PopulationSize = 24
%   MaxGenerations = 50
%
% Seguridad:
%   confirm_execute = false por defecto.
%
% Uso preflight solamente:
%   formal = run_guarded_triobjective_formal_ga_v96m(false);
%
% Uso para ejecutar corrida formal:
%   formal = run_guarded_triobjective_formal_ga_v96m(true);
%
% Este script:
%   - NO modifica v10/v17/v628b/v18/v95j.
%   - NO modifica objective v96j_fix1.
%   - Ejecuta preflight siempre.
%   - Ejecuta gamultiobj solo si confirm_execute=true.
%   - Guarda MAT/CSV/MD/TXT.
%   - Mantiene solar excluido.
%   - Marca CO2 con factores provisionales.

    if nargin < 1
        confirm_execute = false;
    end

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar diseño formal 9.6l
    % ---------------------------------------------------------------------
    designBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_run_design_v96l');

    if ~isfolder(designBaseDir)
        error('No existe designBaseDir: %s', designBaseDir);
    end

    d = dir(designBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró diseño formal v96l.');
    end

    [~,idxDesign] = max([d.datenum]);
    designDir = fullfile(designBaseDir,d(idxDesign).name);
    designMat = fullfile(designDir,'mat','TRIOBJECTIVE_FORMAL_RUN_DESIGN_v96l.mat');

    if ~isfile(designMat)
        error('No existe MAT v96l: %s', designMat);
    end

    Sdesign = load(designMat);

    if ~strcmp(string(Sdesign.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_DESIGN_PASS")
        error('Diseño v96l no está en PASS. Diagnosis: %s', string(Sdesign.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Archivos protegidos y función objetivo
    % ---------------------------------------------------------------------
    objective_v96j_fix1 = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    if exist('objective_productive_corrected_v96j_triobjective_CO2_fix1','file') ~= 2
        error('No está visible objective_productive_corrected_v96j_triobjective_CO2_fix1.');
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    formalBaseDir = fullfile(rootDir,'05_runs','triobjective_formal_ga_v96m');
    formalDir = fullfile(formalBaseDir,['TRIOBJECTIVE_FORMAL_GA_v96m_' timestamp]);

    logsDir = fullfile(formalDir,'logs');
    tablesDir = fullfile(formalDir,'tables');
    matDir = fullfile(formalDir,'mat');

    if ~isfolder(formalBaseDir), mkdir(formalBaseDir); end
    if ~isfolder(formalDir), mkdir(formalDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Configuración formal F1
    % ---------------------------------------------------------------------
    x_selected = Sdesign.x_selected;
    lb = Sdesign.lb_formal;
    ub = Sdesign.ub_formal;
    nvars = Sdesign.nvars;

    modeFormal = "hybrid";
    referenceMode = "gasLP";

    popSize = 24;
    maxGen = 50;

    rng(614960,'twister');

    % ---------------------------------------------------------------------
    % Preflight directo
    % ---------------------------------------------------------------------
    modesPreflight = ["gasLP","hybrid","solar"];
    preRows = {};

    for i = 1:numel(modesPreflight)
        mode = modesPreflight(i);
        [f, d0, status, errMsg] = local_eval_triobjective_v96m(x_selected, mode);
        preRows{end+1,1} = local_preflight_row_v96m(mode, x_selected, f, d0, status, errMsg); %#ok<AGROW>
    end

    Tpreflight = struct2table(vertcat(preRows{:}));

    outPreflightCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_preflight.csv');
    writetable(Tpreflight,outPreflightCsv);

    gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);
    hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);
    solPre = Tpreflight(strcmp(string(Tpreflight.mode),"solar"),:);

    preflight_pass = ...
        strcmp(string(gasPre.status(1)),"OK") && gasPre.nobj(1)==3 && strcmp(string(gasPre.detail_status(1)),"OK") && ...
        strcmp(string(hybPre.status(1)),"OK") && hybPre.nobj(1)==3 && strcmp(string(hybPre.detail_status(1)),"OK") && ...
        solPre.nobj(1)==3 && solPre.f1(1)>=999.999 && solPre.f2(1)>=999999.999 && solPre.f3(1)>=999999.999;

    if ~preflight_pass
        error('Preflight formal triobjetivo no pasó. No se permite ejecución formal.');
    end

    % ---------------------------------------------------------------------
    % Source scan
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v96m("objective_v96j_fix1_exists", objective_v96j_fix1, "", isfile(objective_v96j_fix1), "Triobjective objective fix1 exists.");
    sourceRows{end+1,1} = local_source_row_v96m("objective_v95j_preserved", objective_v95j, "", isfile(objective_v95j), "v95j preserved.");
    sourceRows{end+1,1} = local_source_row_v96m("wrapper_v10_preserved", wrapper_v10, "", isfile(wrapper_v10), "v10 preserved.");
    sourceRows{end+1,1} = local_source_row_v96m("wrapper_v17_preserved", wrapper_v17, "", isfile(wrapper_v17), "v17 preserved.");
    sourceRows{end+1,1} = local_source_row_v96m("wrapper_v18_preserved", wrapper_v18, "", isfile(wrapper_v18), "v18 preserved.");
    sourceRows{end+1,1} = local_source_row_v96m("objective_v628b_preserved", objective_v628b, "", isfile(objective_v628b), "v628b preserved.");

    sourceRows{end+1,1} = local_source_contains_v96m("fix1_calls_v95j", objective_v96j_fix1, "objective_productive_corrected_v95j_endpoint_TMAX_corrected", "fix1 calls validated v95j.");
    sourceRows{end+1,1} = local_source_contains_v96m("fix1_has_1x3_valid_f", objective_v96j_fix1, "f = [f_base(1), f_base(2), CO2_specific_kgCO2_per_kgwater];", "fix1 builds 1x3 objective.");
    sourceRows{end+1,1} = local_source_contains_v96m("fix1_has_1x3_penalty", objective_v96j_fix1, "penalty = [1000, 1e6, 1e6];", "fix1 has 1x3 penalty.");
    sourceRows{end+1,1} = local_source_contains_v96m("fix1_has_provisional_factors", objective_v96j_fix1, "PROVISIONAL_FOR_CODE_VALIDATION", "fix1 marks provisional factors.");

    Tsource = struct2table(vertcat(sourceRows{:}));

    outSourceCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_source_scan.csv');
    writetable(Tsource,outSourceCsv);

    source_preservation_pass = all(Tsource.pass);

    if ~source_preservation_pass
        error('Source preservation falló. No se permite ejecución formal.');
    end

    % ---------------------------------------------------------------------
    % Opciones gamultiobj
    % ---------------------------------------------------------------------
    opts = optimoptions('gamultiobj', ...
        'PopulationSize', popSize, ...
        'MaxGenerations', maxGen, ...
        'Display', 'iter', ...
        'UseParallel', false, ...
        'FunctionTolerance', 1e-5, ...
        'ConstraintTolerance', 1e-6, ...
        'PlotFcn', []);

    % ---------------------------------------------------------------------
    % Estado inicial común
    % ---------------------------------------------------------------------
    X = NaN(0,nvars);
    F = NaN(0,3);
    exitflag = NaN;
    output = struct();
    population = NaN(0,nvars);
    scores = NaN(0,3);
    runtime_s = 0;
    run_status = "NOT_EXECUTED";
    run_error = "";

    % ---------------------------------------------------------------------
    % Ejecución formal condicionada
    % ---------------------------------------------------------------------
    if confirm_execute
        fprintf('\n=== EXECUTING TRIOBJECTIVE FORMAL GA v96m ===\n');
        fprintf('Mode: %s\n', modeFormal);
        fprintf('PopulationSize: %d\n', popSize);
        fprintf('MaxGenerations: %d\n', maxGen);
        fprintf('Estimated runtime from v96l: %.3f h\n', Sdesign.designFlags.recommended_estimated_runtime_h);

        objfun = @(x) objective_productive_corrected_v96j_triobjective_CO2_fix1(x, modeFormal);

        tStart = tic;

        try
            [X,F,exitflag,output,population,scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts); %#ok<ASGLU>
            runtime_s = toc(tStart);
            run_status = "OK";
            run_error = "";
        catch ME
            runtime_s = toc(tStart);
            run_status = "ERROR";
            run_error = string(ME.message);

            X = NaN(0,nvars);
            F = NaN(0,3);
            exitflag = NaN;
            output = struct();
            population = NaN(0,nvars);
            scores = NaN(0,3);
        end
    else
        fprintf('\n=== PRELIGHT ONLY: FORMAL GA NOT EXECUTED ===\n');
        fprintf('To execute later, run:\n');
        fprintf('formal = run_guarded_triobjective_formal_ga_v96m(true);\n');
    end

    % ---------------------------------------------------------------------
    % Normalizar F si hubo ejecución
    % ---------------------------------------------------------------------
    if isempty(F)
        F = NaN(0,3);
    end

    if size(F,2) ~= 3
        Ffixed = NaN(size(F,1),3);
        cols = min(size(F,2),3);
        if cols > 0
            Ffixed(:,1:cols) = F(:,1:cols);
        end
        F = Ffixed;
    end

    if isempty(X)
        X = NaN(0,nvars);
    end

    nSolutions = size(F,1);
    nFiniteRows = 0;
    nPenaltyRows = 0;

    if nSolutions > 0
        nFiniteRows = sum(all(isfinite(F),2));
        nPenaltyRows = sum(F(:,1) >= 999.999 | F(:,2) >= 999999.999 | F(:,3) >= 999999.999);
    end

    minMR = local_min_or_nan_v96m(F,1);
    minCost = local_min_or_nan_v96m(F,2);
    minCO2 = local_min_or_nan_v96m(F,3);

    outRawMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_GA_v96m_raw.mat');
    save(outRawMat,'X','F','exitflag','output','population','scores','runtime_s','run_status','run_error','lb','ub','opts','modeFormal','popSize','maxGen');

    % ---------------------------------------------------------------------
    % Soluciones
    % ---------------------------------------------------------------------
    solutionRows = {};

    for i = 1:nSolutions
        row = struct();
        row.mode = string(modeFormal);
        row.solution_index = i;

        row.m_max = X(i,1);
        row.T_min = X(i,2);
        row.r_div2 = X(i,3);
        row.t_rec_ini = X(i,4);

        row.MR = F(i,1);
        row.cost_specific_USD_per_kgwater = F(i,2);
        row.CO2_specific_kgCO2_per_kgwater = F(i,3);

        row.penalized = F(i,1) >= 999.999 || F(i,2) >= 999999.999 || F(i,3) >= 999999.999;

        solutionRows{end+1,1} = row; %#ok<AGROW>
    end

    if isempty(solutionRows)
        Tsolutions = table();
    else
        Tsolutions = struct2table(vertcat(solutionRows{:}));
    end

    outSolutionsCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_solutions.csv');
    writetable(Tsolutions,outSolutionsCsv);

    % ---------------------------------------------------------------------
    % Referencia gasLP para x_selected
    % ---------------------------------------------------------------------
    [f_ref, d_ref, ref_status, ref_err] = local_eval_triobjective_v96m(x_selected, referenceMode);
    Treference = struct2table(local_reference_row_v96m(referenceMode, x_selected, f_ref, d_ref, ref_status, ref_err));

    outReferenceCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_gasLP_reference.csv');
    writetable(Treference,outReferenceCsv);

    % ---------------------------------------------------------------------
    % Tabla resumen run
    % ---------------------------------------------------------------------
    runRow = struct();
    runRow.mode = string(modeFormal);
    runRow.run_status = string(run_status);
    runRow.run_error = string(run_error);
    runRow.confirm_execute = logical(confirm_execute);
    runRow.runtime_s = runtime_s;
    runRow.runtime_h = runtime_s / 3600;
    runRow.exitflag = double(exitflag);
    runRow.nSolutions = nSolutions;
    runRow.nFiniteRows = nFiniteRows;
    runRow.nPenaltyRows = nPenaltyRows;
    runRow.minMR = minMR;
    runRow.minCost = minCost;
    runRow.minCO2 = minCO2;

    if isstruct(output) && isfield(output,'generations')
        runRow.generations = double(output.generations);
    else
        runRow.generations = NaN;
    end

    if isstruct(output) && isfield(output,'funccount')
        runRow.funccount = double(output.funccount);
    else
        runRow.funccount = NaN;
    end

    if isstruct(output) && isfield(output,'message')
        runRow.output_message = string(output.message);
    else
        runRow.output_message = "";
    end

    Trun = struct2table(runRow);

    outRunCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_run_summary.csv');
    writetable(Trun,outRunCsv);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    checks{end+1,1} = local_check_row_v96m( ...
        "M01", ...
        "Design v96l pass", ...
        strcmp(string(Sdesign.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_DESIGN_PASS"), ...
        string(Sdesign.diagnosis), ...
        "Formal design must be PASS.");

    checks{end+1,1} = local_check_row_v96m( ...
        "M02", ...
        "Preflight pass", ...
        preflight_pass, ...
        sprintf("gas f=[%.6g %.6g %.6g]; hybrid f=[%.6g %.6g %.6g]; solar f=[%.6g %.6g %.6g]", ...
            gasPre.f1(1), gasPre.f2(1), gasPre.f3(1), ...
            hybPre.f1(1), hybPre.f2(1), hybPre.f3(1), ...
            solPre.f1(1), solPre.f2(1), solPre.f3(1)), ...
        "Preflight must validate gasLP/hybrid and penalize solar.");

    checks{end+1,1} = local_check_row_v96m( ...
        "M03", ...
        "Source preservation", ...
        source_preservation_pass, ...
        "Protected files preserved and objective fix1 available.", ...
        "No protected source may be overwritten.");

    checks{end+1,1} = local_check_row_v96m( ...
        "M04", ...
        "Execution policy", ...
        (~confirm_execute && strcmp(run_status,"NOT_EXECUTED")) || (confirm_execute && any(strcmp(run_status,["OK","ERROR"]))), ...
        sprintf("confirm_execute=%d; run_status=%s", confirm_execute, string(run_status)), ...
        "Script must not run unless confirm_execute=true.");

    checks{end+1,1} = local_check_row_v96m( ...
        "M05", ...
        "Formal run completed if requested", ...
        (~confirm_execute) || (confirm_execute && strcmp(run_status,"OK")), ...
        sprintf("confirm_execute=%d; run_status=%s; error=%s", confirm_execute, string(run_status), string(run_error)), ...
        "If execution is requested, gamultiobj must complete without error.");

    checks{end+1,1} = local_check_row_v96m( ...
        "M06", ...
        "Formal F has 3 columns if executed", ...
        (~confirm_execute) || (confirm_execute && size(F,2)==3 && nFiniteRows > 0), ...
        sprintf("F columns=%d; nFiniteRows=%d", size(F,2), nFiniteRows), ...
        "Formal output F must have three objectives.");

    checks{end+1,1} = local_check_row_v96m( ...
        "M07", ...
        "Not all penalized if executed", ...
        (~confirm_execute) || (confirm_execute && nSolutions > 0 && nPenaltyRows < nSolutions), ...
        sprintf("nPenaltyRows=%d of nSolutions=%d", nPenaltyRows, nSolutions), ...
        "Formal run must not collapse entirely to penalty.");

    checks{end+1,1} = local_check_row_v96m( ...
        "M08", ...
        "Emission factors provisional flag", ...
        true, ...
        "CO2 factors are provisional; manuscript-final CO2 claims blocked.", ...
        "Factor status must remain explicit.");

    Tchecks = struct2table(vertcat(checks{:}));

    outChecksCsv = fullfile(tablesDir,'TRIOBJECTIVE_FORMAL_GA_v96m_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    script_ready = preflight_pass && source_preservation_pass;

    if ~confirm_execute && script_ready
        diagnosis = "TRIOBJECTIVE_FORMAL_RUN_SCRIPT_READY_NO_EXECUTION";
    elseif confirm_execute && all(Tchecks.pass)
        diagnosis = "TRIOBJECTIVE_FORMAL_RUN_EXECUTION_COMPLETED_PASS";
    elseif confirm_execute && ~all(Tchecks.pass)
        diagnosis = "TRIOBJECTIVE_FORMAL_RUN_EXECUTION_REQUIRES_REVIEW";
    else
        diagnosis = "TRIOBJECTIVE_FORMAL_RUN_SCRIPT_REQUIRES_REVIEW";
    end

    formalFlags = struct();
    formalFlags.confirm_execute = logical(confirm_execute);
    formalFlags.design_v96l_pass = strcmp(string(Sdesign.diagnosis),"TRIOBJECTIVE_FORMAL_RUN_DESIGN_PASS");
    formalFlags.objective_v96j_fix1_used = true;
    formalFlags.preflight_pass = preflight_pass;
    formalFlags.source_preservation_pass = source_preservation_pass;
    formalFlags.population_size = popSize;
    formalFlags.max_generations = maxGen;
    formalFlags.modeFormal = string(modeFormal);
    formalFlags.referenceMode = string(referenceMode);
    formalFlags.run_status = string(run_status);
    formalFlags.nSolutions = nSolutions;
    formalFlags.nFiniteRows = nFiniteRows;
    formalFlags.nPenaltyRows = nPenaltyRows;
    formalFlags.F_has_3_columns = size(F,2)==3;
    formalFlags.emission_factors_provisional = true;
    formalFlags.formal_run_executed = logical(confirm_execute) && strcmp(run_status,"OK");
    formalFlags.formal_run_still_on_hold = ~logical(confirm_execute);
    formalFlags.postrun_consolidation_pending = logical(confirm_execute) && strcmp(run_status,"OK");

    % ---------------------------------------------------------------------
    % Salidas MAT
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_GA_v96m.md');
    outTxt = fullfile(logsDir,'TRIOBJECTIVE_FORMAL_GA_v96m.txt');
    outMat = fullfile(matDir,'TRIOBJECTIVE_FORMAL_GA_v96m.mat');

    save(outMat, ...
        'diagnosis','formalFlags', ...
        'x_selected','lb','ub','nvars','popSize','maxGen','modeFormal','referenceMode', ...
        'confirm_execute','run_status','run_error','runtime_s','exitflag','output', ...
        'X','F','population','scores', ...
        'Tpreflight','Trun','Tsolutions','Treference','Tsource','Tchecks', ...
        'objective_v96j_fix1','objective_v95j','wrapper_v10','wrapper_v17','wrapper_v18','objective_v628b', ...
        'designDir','formalDir', ...
        'outMd','outTxt','outMat','outRawMat','outPreflightCsv','outRunCsv','outSolutionsCsv','outReferenceCsv','outSourceCsv','outChecksCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_FORMAL_GA_v96m\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'confirm_execute: `%d`\n\n', confirm_execute);

    fprintf(fid,'## Función objetivo\n\n');
    fprintf(fid,'```text\nobjective_productive_corrected_v96j_triobjective_CO2_fix1\n```\n\n');

    fprintf(fid,'## Vector objetivo\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'f(1) = MR_final;\n');
    fprintf(fid,'f(2) = cost_specific_USD_per_kgwater;\n');
    fprintf(fid,'f(3) = CO2_specific_kgCO2_per_kgwater;\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'## Configuración formal\n\n');
    fprintf(fid,'| Parámetro | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| PopulationSize | %d |\n', popSize);
    fprintf(fid,'| MaxGenerations | %d |\n', maxGen);
    fprintf(fid,'| nvars | %d |\n', nvars);
    fprintf(fid,'| confirm_execute | %d |\n\n', confirm_execute);

    fprintf(fid,'## Preflight\n\n');
    fprintf(fid,'| mode | status | detail | nobj | f1 MR | f2 cost | f3 CO2 |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|---:|\n');

    for i = 1:height(Tpreflight)
        fprintf(fid,'| `%s` | `%s` | `%s` | %d | %.12g | %.12g | %.12g |\n', ...
            string(Tpreflight.mode(i)), ...
            string(Tpreflight.status(i)), ...
            string(Tpreflight.detail_status(i)), ...
            Tpreflight.nobj(i), ...
            Tpreflight.f1(i), ...
            Tpreflight.f2(i), ...
            Tpreflight.f3(i));
    end

    fprintf(fid,'\n## Resumen de corrida\n\n');
    fprintf(fid,'| mode | run_status | runtime_h | exitflag | nSolutions | nFiniteRows | nPenaltyRows | minMR | minCost | minCO2 |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');
    fprintf(fid,'| `%s` | `%s` | %.6f | %.0f | %d | %d | %d | %.12g | %.12g | %.12g |\n', ...
        string(Trun.mode(1)), ...
        string(Trun.run_status(1)), ...
        Trun.runtime_h(1), ...
        Trun.exitflag(1), ...
        Trun.nSolutions(1), ...
        Trun.nFiniteRows(1), ...
        Trun.nPenaltyRows(1), ...
        Trun.minMR(1), ...
        Trun.minCost(1), ...
        Trun.minCO2(1));

    fprintf(fid,'\n## Referencia gasLP en x_selected\n\n');
    fprintf(fid,'| mode | status | detail | f1 MR | f2 cost | f3 CO2 |\n');
    fprintf(fid,'|---|---|---|---:|---:|---:|\n');
    fprintf(fid,'| `%s` | `%s` | `%s` | %.12g | %.12g | %.12g |\n', ...
        string(Treference.mode(1)), ...
        string(Treference.status(1)), ...
        string(Treference.detail_status(1)), ...
        Treference.f1(1), ...
        Treference.f2(1), ...
        Treference.f3(1));

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| ID | Check | Pass | Evidencia | Criterio |\n');
    fprintf(fid,'|---|---|---:|---|---|\n');

    for i = 1:height(Tchecks)
        fprintf(fid,'| `%s` | `%s` | `%d` | %s | %s |\n', ...
            string(Tchecks.id(i)), ...
            string(Tchecks.check(i)), ...
            Tchecks.pass(i), ...
            string(Tchecks.evidence(i)), ...
            string(Tchecks.criterion(i)));
    end

    fprintf(fid,'\n## Restricciones activas\n\n');
    fprintf(fid,'- Factores de emisión provisionales.\n');
    fprintf(fid,'- No usar resultados directamente en manuscrito sin consolidación postrun.\n');
    fprintf(fid,'- Solar puro sigue excluido.\n');

    if ~confirm_execute
        fprintf(fid,'- La corrida formal NO fue ejecutada.\n');
        fprintf(fid,'- Para ejecutar: `formal = run_guarded_triobjective_formal_ga_v96m(true);`\n');
    else
        fprintf(fid,'- La corrida formal fue solicitada con `confirm_execute=true`.\n');
        fprintf(fid,'- Si el diagnóstico es PASS, continuar con consolidación postrun.\n');
    end

    fprintf(fid,'\n## Siguiente paso\n\n');
    if ~confirm_execute
        fprintf(fid,'`9.6n — TRIOBJECTIVE-FORMAL-RUN-EXECUTION-APPROVAL-001`\n');
    else
        fprintf(fid,'`9.6o — TRIOBJECTIVE-FORMAL-POSTRUN-CONSOLIDATION-001`\n');
    end

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'CREATE-TRIOBJECTIVE-FORMAL-RUN-SCRIPT-001\n');
    fprintf(fid,'status: TRIOBJECTIVE_FORMAL_GA_v96m_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'confirm_execute: %d\n', confirm_execute);
    fprintf(fid,'design_v96l_pass: %d\n', formalFlags.design_v96l_pass);
    fprintf(fid,'objective_v96j_fix1_used: %d\n', formalFlags.objective_v96j_fix1_used);
    fprintf(fid,'preflight_pass: %d\n', formalFlags.preflight_pass);
    fprintf(fid,'source_preservation_pass: %d\n', formalFlags.source_preservation_pass);
    fprintf(fid,'population_size: %d\n', formalFlags.population_size);
    fprintf(fid,'max_generations: %d\n', formalFlags.max_generations);
    fprintf(fid,'modeFormal: %s\n', formalFlags.modeFormal);
    fprintf(fid,'referenceMode: %s\n', formalFlags.referenceMode);
    fprintf(fid,'run_status: %s\n', formalFlags.run_status);
    fprintf(fid,'nSolutions: %d\n', formalFlags.nSolutions);
    fprintf(fid,'nFiniteRows: %d\n', formalFlags.nFiniteRows);
    fprintf(fid,'nPenaltyRows: %d\n', formalFlags.nPenaltyRows);
    fprintf(fid,'F_has_3_columns: %d\n', formalFlags.F_has_3_columns);
    fprintf(fid,'emission_factors_provisional: %d\n', formalFlags.emission_factors_provisional);
    fprintf(fid,'formal_run_executed: %d\n', formalFlags.formal_run_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', formalFlags.formal_run_still_on_hold);
    fprintf(fid,'postrun_consolidation_pending: %d\n', formalFlags.postrun_consolidation_pending);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida consola
    % ---------------------------------------------------------------------
    formal = struct();
    formal.status = 'TRIOBJECTIVE_FORMAL_GA_v96m_COMPLETED';
    formal.diagnosis = diagnosis;
    formal.formalFlags = formalFlags;
    formal.Tpreflight = Tpreflight;
    formal.Trun = Trun;
    formal.Tsolutions = Tsolutions;
    formal.Treference = Treference;
    formal.Tchecks = Tchecks;
    formal.Tsource = Tsource;
    formal.formalDir = formalDir;
    formal.outMd = outMd;
    formal.outTxt = outTxt;
    formal.outMat = outMat;

    disp('=== TRIOBJECTIVE_FORMAL_GA_v96m ===')
    disp(formal.status)
    disp('=== DIAGNOSIS ===')
    disp(formal.diagnosis)
    disp('=== FORMAL FLAGS ===')
    disp(formal.formalFlags)
    disp('=== PREFLIGHT ===')
    disp(formal.Tpreflight)
    disp('=== RUN SUMMARY ===')
    disp(formal.Trun)
    disp('=== CHECKS ===')
    disp(formal.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(formal.outMd)
    disp(formal.outTxt)
    disp(formal.outMat)

end

% =========================================================================
% Helpers
% =========================================================================

function [f, detail, status, errMsg] = local_eval_triobjective_v96m(x, mode)
    status = "OK";
    errMsg = "";
    detail = struct();

    try
        [f, detail] = objective_productive_corrected_v96j_triobjective_CO2_fix1(x, mode);
        f = double(f(:))';

        if numel(f) ~= 3
            status = "BAD_OBJECTIVE_SIZE";
            f = [1000, 1e6, 1e6];
        end

        if any(~isfinite(f)) || any(~isreal(f))
            status = "BAD_OBJECTIVE_VALUE";
            f = [1000, 1e6, 1e6];
        end

    catch ME
        f = [1000, 1e6, 1e6];
        detail = struct();
        status = "ERROR";
        errMsg = string(ME.message);
    end
end

function row = local_preflight_row_v96m(mode, x, f, detail, status, errMsg)
    row = struct();

    row.mode = string(mode);
    row.status = string(status);
    row.error_message = string(errMsg);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.nobj = numel(f);
    row.f1 = local_vec_get_v96m(f,1,NaN);
    row.f2 = local_vec_get_v96m(f,2,NaN);
    row.f3 = local_vec_get_v96m(f,3,NaN);

    row.detail_status = local_get_string_v96m(detail, {'status','detail_status','execution_status'}, "UNKNOWN");
    row.Q_aux_tot = local_get_numeric_v96m(detail, {'outputs.Q_aux_tot','Q_aux_tot'}, NaN);
    row.Irradiacion = local_get_numeric_v96m(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v96m(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v96m(detail, {'outputs.M','M'}, NaN);
    row.CO2_total_kg = local_get_numeric_v96m(detail, {'CO2.CO2_total_kg'}, NaN);
    row.CO2_specific = local_get_numeric_v96m(detail, {'CO2.CO2_specific_kgCO2_per_kgwater'}, NaN);
    row.emission_factor_status = local_get_string_v96m(detail, {'CO2.emission_factor_status'}, "");
end

function row = local_reference_row_v96m(mode, x, f, detail, status, errMsg)
    row = struct();

    row.mode = string(mode);
    row.status = string(status);
    row.error_message = string(errMsg);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.nobj = numel(f);
    row.f1 = local_vec_get_v96m(f,1,NaN);
    row.f2 = local_vec_get_v96m(f,2,NaN);
    row.f3 = local_vec_get_v96m(f,3,NaN);

    row.detail_status = local_get_string_v96m(detail, {'status','detail_status','execution_status'}, "UNKNOWN");
    row.Q_aux_tot = local_get_numeric_v96m(detail, {'outputs.Q_aux_tot','Q_aux_tot'}, NaN);
    row.Irradiacion = local_get_numeric_v96m(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v96m(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v96m(detail, {'outputs.M','M'}, NaN);
    row.CO2_total_kg = local_get_numeric_v96m(detail, {'CO2.CO2_total_kg'}, NaN);
    row.CO2_specific = local_get_numeric_v96m(detail, {'CO2.CO2_specific_kgCO2_per_kgwater'}, NaN);
    row.emission_factor_status = local_get_string_v96m(detail, {'CO2.emission_factor_status'}, "");
end

function row = local_source_row_v96m(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_contains_v96m(item, filePath, pattern, evidenceIfFound)
    passVal = false;
    evidence = "FILE_NOT_FOUND";

    if isfile(filePath)
        try
            txt = fileread(filePath);
            passVal = contains(txt, pattern);
            if passVal
                evidence = string(evidenceIfFound);
            else
                evidence = "Pattern not found.";
            end
        catch ME
            evidence = "Could not read file: " + string(ME.message);
        end
    end

    row = local_source_row_v96m(item, filePath, pattern, passVal, evidence);
end

function row = local_check_row_v96m(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function val = local_min_or_nan_v96m(F, col)
    if isempty(F) || size(F,2) < col
        val = NaN;
        return
    end

    v = F(:,col);
    v = v(isfinite(v));

    if isempty(v)
        val = NaN;
    else
        val = min(v);
    end
end

function val = local_vec_get_v96m(v, idx, defaultVal)
    if numel(v) >= idx
        val = v(idx);
    else
        val = defaultVal;
    end
end

function val = local_get_numeric_v96m(S, paths, defaultVal)
    val = defaultVal;

    for k = 1:numel(paths)
        parts = split(string(paths{k}),'.');

        try
            tmp = S;
            ok = true;

            for j = 1:numel(parts)
                part = char(parts(j));
                if isstruct(tmp) && isfield(tmp, part)
                    tmp = tmp.(part);
                else
                    ok = false;
                    break
                end
            end

            if ok && isnumeric(tmp) && ~isempty(tmp)
                val = double(tmp(1));
                return
            end
        catch
        end
    end
end

function val = local_get_string_v96m(S, paths, defaultVal)
    val = string(defaultVal);

    for k = 1:numel(paths)
        parts = split(string(paths{k}),'.');

        try
            tmp = S;
            ok = true;

            for j = 1:numel(parts)
                part = char(parts(j));
                if isstruct(tmp) && isfield(tmp, part)
                    tmp = tmp.(part);
                else
                    ok = false;
                    break
                end
            end

            if ok && ~isempty(tmp)
                val = string(tmp);
                return
            end
        catch
        end
    end
end