function smoke = run_guarded_triobjective_smoke_ga_v96k()
% RUN_GUARDED_TRIOBJECTIVE_SMOKE_GA_v96k
% 9.6k — GUARDED-TRIOBJECTIVE-SMOKE-GA-001
%
% Objetivo:
%   Ejecutar una corrida corta de gamultiobj para verificar que la ruta
%   triobjetivo funciona con:
%
%       f(1) = MR_final
%       f(2) = cost_specific_USD_per_kgwater
%       f(3) = CO2_specific_kgCO2_per_kgwater
%
% Función objetivo:
%   objective_productive_corrected_v96j_triobjective_CO2_fix1
%
% Este micropaso:
%   - NO ejecuta corrida formal.
%   - NO modifica v10/v17/v628b/v18/v95j.
%   - NO modifica objective v96j_fix1.
%   - Usa factores CO2 provisionales ya marcados en v96j_fix1.
%   - Ejecuta smoke GA corto para gasLP y hybrid.
%   - Mantiene solar excluido/penalizado.
%
% Uso:
%   smoke = run_guarded_triobjective_smoke_ga_v96k();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Verificar implementación triobjetivo 9.6j-b
    % ---------------------------------------------------------------------
    fixBaseDir = fullfile(rootDir,'05_runs','triobjective_CO2_objective_fix_v96j_b');

    if ~isfolder(fixBaseDir)
        error('No existe fixBaseDir: %s', fixBaseDir);
    end

    d = dir(fixBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'TRIOBJECTIVE_CO2_OBJECTIVE_FIX_v96j_b_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró salida de 9.6j-b.');
    end

    [~,idxFix] = max([d.datenum]);
    fixDir = fullfile(fixBaseDir,d(idxFix).name);
    fixMat = fullfile(fixDir,'mat','TRIOBJECTIVE_CO2_OBJECTIVE_FIX_v96j_b.mat');

    if ~isfile(fixMat)
        error('No existe MAT de 9.6j-b: %s', fixMat);
    end

    Sfix = load(fixMat);

    if ~strcmp(string(Sfix.diagnosis),"TRIOBJECTIVE_CO2_OBJECTIVE_FIX_PASS")
        error('9.6j-b no está aprobado. Diagnosis: %s', string(Sfix.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Archivos protegidos y función candidata
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

    smokeBaseDir = fullfile(rootDir,'05_runs','triobjective_smoke_ga_v96k');
    smokeDir = fullfile(smokeBaseDir,['TRIOBJECTIVE_SMOKE_GA_v96k_' timestamp]);

    logsDir = fullfile(smokeDir,'logs');
    tablesDir = fullfile(smokeDir,'tables');
    matDir = fullfile(smokeDir,'mat');

    if ~isfolder(smokeBaseDir), mkdir(smokeBaseDir); end
    if ~isfolder(smokeDir), mkdir(smokeDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Configuración smoke GA
    % ---------------------------------------------------------------------
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    lb_global = [0.05, 55, 0.00, 8.00];
    ub_global = [0.12, 70, 0.95, 14.00];

    delta = [0.020, 5.0, 0.25, 3.0];

    lb = max(lb_global, x_selected - delta);
    ub = min(ub_global, x_selected + delta);

    nvars = 4;
    popSize = 8;
    maxGen = 2;

    modesToRun = ["gasLP","hybrid"];
    modesPreflight = ["gasLP","hybrid","solar"];

    rng(61496,'twister');

    % ---------------------------------------------------------------------
    % Preflight directo
    % ---------------------------------------------------------------------
    preRows = {};

    for i = 1:numel(modesPreflight)
        mode = modesPreflight(i);

        [f, d, status, errMsg] = local_eval_triobjective_v96k(x_selected, mode);

        row = local_preflight_row_v96k(mode, x_selected, f, d, status, errMsg);
        preRows{end+1,1} = row; %#ok<AGROW>
    end

    Tpreflight = struct2table(vertcat(preRows{:}));

    outPreflightCsv = fullfile(tablesDir,'TRIOBJECTIVE_SMOKE_GA_v96k_preflight.csv');
    writetable(Tpreflight,outPreflightCsv);

    gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);
    hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);
    solPre = Tpreflight(strcmp(string(Tpreflight.mode),"solar"),:);

    preflight_pass = ...
        strcmp(string(gasPre.status(1)),"OK") && gasPre.nobj(1) == 3 && strcmp(string(gasPre.detail_status(1)),"OK") && ...
        strcmp(string(hybPre.status(1)),"OK") && hybPre.nobj(1) == 3 && strcmp(string(hybPre.detail_status(1)),"OK") && ...
        solPre.nobj(1) == 3 && solPre.f1(1) >= 999.999 && solPre.f2(1) >= 999999.999 && solPre.f3(1) >= 999999.999;

    if ~preflight_pass
        error('Preflight triobjetivo no pasó. No se ejecuta smoke GA.');
    end

    % ---------------------------------------------------------------------
    % Opciones gamultiobj
    % ---------------------------------------------------------------------
    opts = optimoptions('gamultiobj', ...
        'PopulationSize', popSize, ...
        'MaxGenerations', maxGen, ...
        'Display', 'iter', ...
        'UseParallel', false, ...
        'FunctionTolerance', 1e-4, ...
        'ConstraintTolerance', 1e-6, ...
        'PlotFcn', []);

    % ---------------------------------------------------------------------
    % Ejecutar smoke GA por modo
    % ---------------------------------------------------------------------
    runRows = {};
    allSolutionRows = {};

    for i = 1:numel(modesToRun)
        mode = modesToRun(i);

        fprintf('\n=== TRI_OBJECTIVE_SMOKE_GA_v96k MODE: %s ===\n', mode);

        objfun = @(x) objective_productive_corrected_v96j_triobjective_CO2_fix1(x, mode);

        tStart = tic;

        try
            [X,F,exitflag,output,population,scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts); %#ok<ASGLU>
            runtime_s = toc(tStart);
            run_status = "OK";
            errMsg = "";
        catch ME
            runtime_s = toc(tStart);
            X = NaN(0,nvars);
            F = NaN(0,3);
            exitflag = NaN;
            output = struct();
            population = NaN(0,nvars);
            scores = NaN(0,3);
            run_status = "ERROR";
            errMsg = string(ME.message);
        end

        if isempty(F)
            F = NaN(0,3);
        end

        if size(F,2) ~= 3
            F_fixed = NaN(size(F,1),3);
            cols = min(size(F,2),3);
            if cols > 0
                F_fixed(:,1:cols) = F(:,1:cols);
            end
            F = F_fixed;
        end

        if isempty(X)
            X = NaN(0,nvars);
        end

        nSolutions = size(F,1);

        nFiniteRows = 0;
        if nSolutions > 0
            nFiniteRows = sum(all(isfinite(F),2));
        end

        nPenaltyRows = 0;
        if nSolutions > 0
            nPenaltyRows = sum(F(:,1) >= 999.999 | F(:,2) >= 999999.999 | F(:,3) >= 999999.999);
        end

        minMR = local_min_or_nan(F,1);
        minCost = local_min_or_nan(F,2);
        minCO2 = local_min_or_nan(F,3);

        runRows{end+1,1} = local_run_row_v96k( ...
            mode, run_status, errMsg, runtime_s, exitflag, output, ...
            nSolutions, nFiniteRows, nPenaltyRows, minMR, minCost, minCO2); %#ok<AGROW>

        for j = 1:nSolutions
            solRow = struct();
            solRow.mode = string(mode);
            solRow.solution_index = j;

            solRow.m_max = X(j,1);
            solRow.T_min = X(j,2);
            solRow.r_div2 = X(j,3);
            solRow.t_rec_ini = X(j,4);

            solRow.MR = F(j,1);
            solRow.cost_specific_USD_per_kgwater = F(j,2);
            solRow.CO2_specific_kgCO2_per_kgwater = F(j,3);

            solRow.penalized = F(j,1) >= 999.999 || F(j,2) >= 999999.999 || F(j,3) >= 999999.999;

            allSolutionRows{end+1,1} = solRow; %#ok<AGROW>
        end

        outRunMat = fullfile(matDir,sprintf('TRIOBJECTIVE_SMOKE_GA_v96k_%s_raw.mat',mode));
        save(outRunMat,'mode','X','F','exitflag','output','population','scores','runtime_s','run_status','errMsg','lb','ub','opts');

    end

    Truns = struct2table(vertcat(runRows{:}));

    if isempty(allSolutionRows)
        Tsolutions = table();
    else
        Tsolutions = struct2table(vertcat(allSolutionRows{:}));
    end

    outRunsCsv = fullfile(tablesDir,'TRIOBJECTIVE_SMOKE_GA_v96k_runs.csv');
    outSolutionsCsv = fullfile(tablesDir,'TRIOBJECTIVE_SMOKE_GA_v96k_solutions.csv');

    writetable(Truns,outRunsCsv);
    writetable(Tsolutions,outSolutionsCsv);

    % ---------------------------------------------------------------------
    % Source scan
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row_v96k("objective_v96j_fix1_exists", objective_v96j_fix1, "", isfile(objective_v96j_fix1), "Triobjective objective fix1 exists.");
    sourceRows{end+1,1} = local_source_row_v96k("objective_v95j_preserved", objective_v95j, "", isfile(objective_v95j), "v95j preserved.");
    sourceRows{end+1,1} = local_source_row_v96k("wrapper_v10_preserved", wrapper_v10, "", isfile(wrapper_v10), "v10 preserved.");
    sourceRows{end+1,1} = local_source_row_v96k("wrapper_v17_preserved", wrapper_v17, "", isfile(wrapper_v17), "v17 preserved.");
    sourceRows{end+1,1} = local_source_row_v96k("wrapper_v18_preserved", wrapper_v18, "", isfile(wrapper_v18), "v18 preserved.");
    sourceRows{end+1,1} = local_source_row_v96k("objective_v628b_preserved", objective_v628b, "", isfile(objective_v628b), "v628b preserved.");

    sourceRows{end+1,1} = local_source_contains_v96k("fix1_calls_v95j", objective_v96j_fix1, "objective_productive_corrected_v95j_endpoint_TMAX_corrected", "fix1 calls validated v95j.");
    sourceRows{end+1,1} = local_source_contains_v96k("fix1_has_1x3_valid_f", objective_v96j_fix1, "f = [f_base(1), f_base(2), CO2_specific_kgCO2_per_kgwater];", "fix1 builds 1x3 objective.");
    sourceRows{end+1,1} = local_source_contains_v96k("fix1_has_1x3_penalty", objective_v96j_fix1, "penalty = [1000, 1e6, 1e6];", "fix1 has 1x3 penalty.");
    sourceRows{end+1,1} = local_source_contains_v96k("fix1_has_provisional_factors", objective_v96j_fix1, "PROVISIONAL_FOR_CODE_VALIDATION", "fix1 marks provisional factors.");

    Tsource = struct2table(vertcat(sourceRows{:}));

    outSourceCsv = fullfile(tablesDir,'TRIOBJECTIVE_SMOKE_GA_v96k_source_scan.csv');
    writetable(Tsource,outSourceCsv);

    % ---------------------------------------------------------------------
    % Checks
    % ---------------------------------------------------------------------
    checks = {};

    gasRun = Truns(strcmp(string(Truns.mode),"gasLP"),:);
    hybRun = Truns(strcmp(string(Truns.mode),"hybrid"),:);

    gas_ok = ~isempty(gasRun) && strcmp(string(gasRun.run_status(1)),"OK");
    hyb_ok = ~isempty(hybRun) && strcmp(string(hybRun.run_status(1)),"OK");

    gas_has_solutions = gas_ok && gasRun.nSolutions(1) > 0;
    hyb_has_solutions = hyb_ok && hybRun.nSolutions(1) > 0;

    gas_F_3cols = gas_has_solutions && gasRun.nFiniteRows(1) > 0;
    hyb_F_3cols = hyb_has_solutions && hybRun.nFiniteRows(1) > 0;

    no_all_penalty_gas = gas_has_solutions && gasRun.nPenaltyRows(1) < gasRun.nSolutions(1);
    no_all_penalty_hyb = hyb_has_solutions && hybRun.nPenaltyRows(1) < hybRun.nSolutions(1);

    smoke_pass_core = gas_ok && hyb_ok && gas_has_solutions && hyb_has_solutions && gas_F_3cols && hyb_F_3cols && no_all_penalty_gas && no_all_penalty_hyb;

    checks{end+1,1} = local_check_row_v96k( ...
        "S01", ...
        "Preflight triobjective", ...
        preflight_pass, ...
        sprintf("gas f=[%.6g %.6g %.6g]; hybrid f=[%.6g %.6g %.6g]; solar f=[%.6g %.6g %.6g]", ...
            gasPre.f1(1), gasPre.f2(1), gasPre.f3(1), ...
            hybPre.f1(1), hybPre.f2(1), hybPre.f3(1), ...
            solPre.f1(1), solPre.f2(1), solPre.f3(1)), ...
        "gasLP/hybrid valid 3obj; solar penalized.");

    checks{end+1,1} = local_check_row_v96k( ...
        "S02", ...
        "gamultiobj gasLP completed", ...
        gas_ok, ...
        local_run_evidence_v96k(gasRun), ...
        "gasLP smoke GA must complete without error.");

    checks{end+1,1} = local_check_row_v96k( ...
        "S03", ...
        "gamultiobj hybrid completed", ...
        hyb_ok, ...
        local_run_evidence_v96k(hybRun), ...
        "hybrid smoke GA must complete without error.");

    checks{end+1,1} = local_check_row_v96k( ...
        "S04", ...
        "gasLP finite triobjective solutions", ...
        gas_F_3cols, ...
        sprintf("gas nSolutions=%d; nFiniteRows=%d", gasRun.nSolutions(1), gasRun.nFiniteRows(1)), ...
        "gasLP F must contain finite 3-objective rows.");

    checks{end+1,1} = local_check_row_v96k( ...
        "S05", ...
        "hybrid finite triobjective solutions", ...
        hyb_F_3cols, ...
        sprintf("hybrid nSolutions=%d; nFiniteRows=%d", hybRun.nSolutions(1), hybRun.nFiniteRows(1)), ...
        "hybrid F must contain finite 3-objective rows.");

    checks{end+1,1} = local_check_row_v96k( ...
        "S06", ...
        "gasLP not all penalized", ...
        no_all_penalty_gas, ...
        sprintf("gas nPenaltyRows=%d of %d", gasRun.nPenaltyRows(1), gasRun.nSolutions(1)), ...
        "gasLP smoke must not collapse entirely to penalty.");

    checks{end+1,1} = local_check_row_v96k( ...
        "S07", ...
        "hybrid not all penalized", ...
        no_all_penalty_hyb, ...
        sprintf("hybrid nPenaltyRows=%d of %d", hybRun.nPenaltyRows(1), hybRun.nSolutions(1)), ...
        "hybrid smoke must not collapse entirely to penalty.");

    checks{end+1,1} = local_check_row_v96k( ...
        "S08", ...
        "Source preservation", ...
        all(Tsource.pass), ...
        "v10/v17/v628b/v18/v95j preserved; v96j_fix1 exists and marks 3 objectives.", ...
        "Protected sources must remain available.");

    Tchecks = struct2table(vertcat(checks{:}));

    outChecksCsv = fullfile(tablesDir,'TRIOBJECTIVE_SMOKE_GA_v96k_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    smokeFlags = struct();
    smokeFlags.preflight_pass = preflight_pass;
    smokeFlags.objective_v96j_fix1_used = true;
    smokeFlags.gasLP_smoke_ok = gas_ok;
    smokeFlags.hybrid_smoke_ok = hyb_ok;
    smokeFlags.gasLP_has_solutions = gas_has_solutions;
    smokeFlags.hybrid_has_solutions = hyb_has_solutions;
    smokeFlags.gasLP_finite_triobjective_rows = gas_F_3cols;
    smokeFlags.hybrid_finite_triobjective_rows = hyb_F_3cols;
    smokeFlags.gasLP_not_all_penalized = no_all_penalty_gas;
    smokeFlags.hybrid_not_all_penalized = no_all_penalty_hyb;
    smokeFlags.source_preservation_pass = all(Tsource.pass);
    smokeFlags.all_smoke_checks_pass = all(Tchecks.pass);
    smokeFlags.emission_factors_provisional = true;
    smokeFlags.no_formal_GA_executed = true;
    smokeFlags.formal_run_still_on_hold = true;
    smokeFlags.formal_triobjective_design_pending = true;

    if smokeFlags.all_smoke_checks_pass
        diagnosis = "GUARDED_TRIOBJECTIVE_SMOKE_GA_PASS";
    else
        diagnosis = "GUARDED_TRIOBJECTIVE_SMOKE_GA_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TRIOBJECTIVE_SMOKE_GA_v96k.md');
    outTxt = fullfile(logsDir,'TRIOBJECTIVE_SMOKE_GA_v96k.txt');
    outMat = fullfile(matDir,'TRIOBJECTIVE_SMOKE_GA_v96k.mat');

    save(outMat, ...
        'diagnosis','smokeFlags', ...
        'x_selected','lb','ub','popSize','maxGen','modesToRun','modesPreflight', ...
        'Tpreflight','Truns','Tsolutions','Tchecks','Tsource', ...
        'objective_v96j_fix1','objective_v95j','wrapper_v10','wrapper_v17','wrapper_v18','objective_v628b', ...
        'fixDir','smokeDir', ...
        'outMd','outTxt','outMat','outPreflightCsv','outRunsCsv','outSolutionsCsv','outChecksCsv','outSourceCsv');

    % Markdown
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_SMOKE_GA_v96k\n\n');
    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Función objetivo usada:\n\n```text\nobjective_productive_corrected_v96j_triobjective_CO2_fix1\n```\n\n');

    fprintf(fid,'## Configuración smoke GA\n\n');
    fprintf(fid,'| Parámetro | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| PopulationSize | %d |\n', popSize);
    fprintf(fid,'| MaxGenerations | %d |\n', maxGen);
    fprintf(fid,'| nvars | %d |\n\n', nvars);

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

    fprintf(fid,'\n## Runs\n\n');
    fprintf(fid,'| mode | status | runtime_s | exitflag | nSolutions | nFiniteRows | nPenaltyRows | minMR | minCost | minCO2 |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for i = 1:height(Truns)
        fprintf(fid,'| `%s` | `%s` | %.3f | %.0f | %d | %d | %d | %.12g | %.12g | %.12g |\n', ...
            string(Truns.mode(i)), ...
            string(Truns.run_status(i)), ...
            Truns.runtime_s(i), ...
            Truns.exitflag(i), ...
            Truns.nSolutions(i), ...
            Truns.nFiniteRows(i), ...
            Truns.nPenaltyRows(i), ...
            Truns.minMR(i), ...
            Truns.minCost(i), ...
            Truns.minCO2(i));
    end

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
    fprintf(fid,'- Esta corrida es smoke GA; no es corrida formal.\n');
    fprintf(fid,'- No usar resultados para conclusiones científicas.\n');
    fprintf(fid,'- Factores de emisión siguen provisionales.\n');
    fprintf(fid,'- La corrida formal sigue detenida.\n');
    fprintf(fid,'- Falta diseño de corrida formal triobjetivo.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'Si el diagnóstico es `GUARDED_TRIOBJECTIVE_SMOKE_GA_PASS`, continuar con `9.6l — TRIOBJECTIVE-FORMAL-RUN-DESIGN-001`.\n\n');

    fclose(fid);

    % TXT ejecutivo
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'GUARDED-TRIOBJECTIVE-SMOKE-GA-001\n');
    fprintf(fid,'status: GUARDED_TRIOBJECTIVE_SMOKE_GA_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'preflight_pass: %d\n', smokeFlags.preflight_pass);
    fprintf(fid,'objective_v96j_fix1_used: %d\n', smokeFlags.objective_v96j_fix1_used);
    fprintf(fid,'gasLP_smoke_ok: %d\n', smokeFlags.gasLP_smoke_ok);
    fprintf(fid,'hybrid_smoke_ok: %d\n', smokeFlags.hybrid_smoke_ok);
    fprintf(fid,'gasLP_has_solutions: %d\n', smokeFlags.gasLP_has_solutions);
    fprintf(fid,'hybrid_has_solutions: %d\n', smokeFlags.hybrid_has_solutions);
    fprintf(fid,'gasLP_finite_triobjective_rows: %d\n', smokeFlags.gasLP_finite_triobjective_rows);
    fprintf(fid,'hybrid_finite_triobjective_rows: %d\n', smokeFlags.hybrid_finite_triobjective_rows);
    fprintf(fid,'gasLP_not_all_penalized: %d\n', smokeFlags.gasLP_not_all_penalized);
    fprintf(fid,'hybrid_not_all_penalized: %d\n', smokeFlags.hybrid_not_all_penalized);
    fprintf(fid,'source_preservation_pass: %d\n', smokeFlags.source_preservation_pass);
    fprintf(fid,'all_smoke_checks_pass: %d\n', smokeFlags.all_smoke_checks_pass);
    fprintf(fid,'emission_factors_provisional: %d\n', smokeFlags.emission_factors_provisional);
    fprintf(fid,'no_formal_GA_executed: %d\n', smokeFlags.no_formal_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', smokeFlags.formal_run_still_on_hold);
    fprintf(fid,'formal_triobjective_design_pending: %d\n', smokeFlags.formal_triobjective_design_pending);
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida consola
    % ---------------------------------------------------------------------
    smoke = struct();
    smoke.status = 'GUARDED_TRIOBJECTIVE_SMOKE_GA_COMPLETED';
    smoke.diagnosis = diagnosis;
    smoke.smokeFlags = smokeFlags;
    smoke.Tpreflight = Tpreflight;
    smoke.Truns = Truns;
    smoke.Tsolutions = Tsolutions;
    smoke.Tchecks = Tchecks;
    smoke.Tsource = Tsource;
    smoke.smokeDir = smokeDir;
    smoke.outMd = outMd;
    smoke.outTxt = outTxt;
    smoke.outMat = outMat;

    disp('=== TRIOBJECTIVE_SMOKE_GA_v96k ===')
    disp(smoke.status)
    disp('=== DIAGNOSIS ===')
    disp(smoke.diagnosis)
    disp('=== SMOKE FLAGS ===')
    disp(smoke.smokeFlags)
    disp('=== PREFLIGHT ===')
    disp(smoke.Tpreflight)
    disp('=== RUNS ===')
    disp(smoke.Truns)
    disp('=== CHECKS ===')
    disp(smoke.Tchecks)
    disp('=== OUTPUT FILES ===')
    disp(smoke.outMd)
    disp(smoke.outTxt)
    disp(smoke.outMat)

end

% =========================================================================
% Helpers
% =========================================================================

function [f, detail, status, errMsg] = local_eval_triobjective_v96k(x, mode)
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

function row = local_preflight_row_v96k(mode, x, f, detail, status, errMsg)
    row = struct();

    row.mode = string(mode);
    row.status = string(status);
    row.error_message = string(errMsg);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.nobj = numel(f);
    row.f1 = local_vec_get_v96k(f,1,NaN);
    row.f2 = local_vec_get_v96k(f,2,NaN);
    row.f3 = local_vec_get_v96k(f,3,NaN);

    row.detail_status = local_get_string_v96k(detail, {'status','detail_status','execution_status'}, "UNKNOWN");
    row.Q_aux_tot = local_get_numeric_v96k(detail, {'outputs.Q_aux_tot','Q_aux_tot'}, NaN);
    row.Irradiacion = local_get_numeric_v96k(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v96k(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v96k(detail, {'outputs.M','M'}, NaN);
    row.CO2_total_kg = local_get_numeric_v96k(detail, {'CO2.CO2_total_kg'}, NaN);
    row.CO2_specific = local_get_numeric_v96k(detail, {'CO2.CO2_specific_kgCO2_per_kgwater'}, NaN);
    row.emission_factor_status = local_get_string_v96k(detail, {'CO2.emission_factor_status'}, "");
end

function row = local_run_row_v96k(mode, run_status, errMsg, runtime_s, exitflag, output, nSolutions, nFiniteRows, nPenaltyRows, minMR, minCost, minCO2)
    row = struct();

    row.mode = string(mode);
    row.run_status = string(run_status);
    row.error_message = string(errMsg);
    row.runtime_s = runtime_s;
    row.exitflag = double(exitflag);

    row.nSolutions = nSolutions;
    row.nFiniteRows = nFiniteRows;
    row.nPenaltyRows = nPenaltyRows;

    row.minMR = minMR;
    row.minCost = minCost;
    row.minCO2 = minCO2;

    if isstruct(output) && isfield(output,'generations')
        row.generations = double(output.generations);
    else
        row.generations = NaN;
    end

    if isstruct(output) && isfield(output,'funccount')
        row.funccount = double(output.funccount);
    else
        row.funccount = NaN;
    end

    if isstruct(output) && isfield(output,'message')
        row.output_message = string(output.message);
    else
        row.output_message = "";
    end
end

function val = local_min_or_nan(F, col)
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

function val = local_vec_get_v96k(v, idx, defaultVal)
    if numel(v) >= idx
        val = v(idx);
    else
        val = defaultVal;
    end
end

function val = local_get_numeric_v96k(S, paths, defaultVal)
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

function val = local_get_string_v96k(S, paths, defaultVal)
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

function row = local_source_row_v96k(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_contains_v96k(item, filePath, pattern, evidenceIfFound)
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

    row = local_source_row_v96k(item, filePath, pattern, passVal, evidence);
end

function row = local_check_row_v96k(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end

function msg = local_run_evidence_v96k(Trow)
    if isempty(Trow)
        msg = "run row missing";
    else
        msg = sprintf("status=%s; nSolutions=%d; nFiniteRows=%d; nPenaltyRows=%d; runtime=%.3f s", ...
            string(Trow.run_status(1)), ...
            Trow.nSolutions(1), ...
            Trow.nFiniteRows(1), ...
            Trow.nPenaltyRows(1), ...
            Trow.runtime_s(1));
    end
end