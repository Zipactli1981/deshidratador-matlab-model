function smoke = run_guarded_smoke_ga_v91g()
% RUN_GUARDED_SMOKE_GA_v91g
% 9.1g — GUARDED-SMOKE-RUN-001
%
% Objetivo:
%   Ejecutar una corrida de humo con la función objetivo guardada:
%       objective_productive_corrected_v628b_nonphysical_penalty
%
% La corrida de humo:
%   - No tiene valor científico.
%   - No sustituye una corrida formal.
%   - No debe usarse para conclusiones.
%   - Solo valida flujo, trazabilidad, guardado de outputs y penalización.
%
% Ejecuta:
%   1) Preflight directo en x seleccionado para gasLP, hybrid y solar.
%   2) Smoke GA mínimo para gasLP.
%   3) Smoke GA mínimo para hybrid.
%
% No modifica:
%   - opt_tunel_mod2_v10_energy_mode_corrected.m
%   - objective_productive_corrected_v611.m
%   - corrida productiva v614
%
% Salidas:
%   05_runs/guarded_smoke_v91g/GUARDED_SMOKE_GA_v91g_yyyymmdd_HHMMSS/
%       logs/
%       tables/
%       mat/
%
% Uso:
%   smoke = run_guarded_smoke_ga_v91g();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    objName = 'objective_productive_corrected_v628b_nonphysical_penalty';

    if exist(objName,'file') ~= 2
        error('No se encontró la función objetivo guardada: %s', objName);
    end

    % ---------------------------------------------------------------------
    % Configuración de humo
    % ---------------------------------------------------------------------
    rng(1,'twister');

    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    baseRunDir = fullfile(rootDir,'05_runs','guarded_smoke_v91g');
    runDir = fullfile(baseRunDir, ['GUARDED_SMOKE_GA_v91g_' timestamp]);

    logsDir   = fullfile(runDir,'logs');
    tablesDir = fullfile(runDir,'tables');
    matDir    = fullfile(runDir,'mat');

    if ~isfolder(baseRunDir), mkdir(baseRunDir); end
    if ~isfolder(runDir), mkdir(runDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    diaryFile = fullfile(logsDir,'GUARDED_SMOKE_GA_v91g_diary.txt');
    if isfile(diaryFile), delete(diaryFile); end
    diary(diaryFile);

    cleanupObj = onCleanup(@() diary('off'));

    fprintf('=== GUARDED_SMOKE_GA_v91g ===\n');
    fprintf('runDir: %s\n', runDir);
    fprintf('timestamp: %s\n', timestamp);
    fprintf('objective: %s\n\n', objName);

    % Solución seleccionada del paquete postrun cerrado.
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    varNames = ["m_max","T_min","r_div2","t_rec_ini"];

    % Caja local de humo alrededor de la solución seleccionada.
    % No representa una campaña formal. Solo prueba que el flujo corre.
    lb_global = [0.05, 55.0, 0.00, 8.0];
    ub_global = [0.12, 70.0, 0.95, 14.0];

    delta = [0.010, 3.0, 0.15, 2.0];

    lb = max(lb_global, x_selected - delta);
    ub = min(ub_global, x_selected + delta);

    nvars = numel(x_selected);

    smokeConfig = struct();
    smokeConfig.label = 'GUARDED_SMOKE_GA_v91g';
    smokeConfig.created_at = datestr(now,'yyyy-mm-dd HH:MM:SS');
    smokeConfig.rootDir = rootDir;
    smokeConfig.runDir = runDir;
    smokeConfig.objective = objName;
    smokeConfig.x_selected = x_selected;
    smokeConfig.lb = lb;
    smokeConfig.ub = ub;
    smokeConfig.nvars = nvars;
    smokeConfig.PopulationSize = 8;
    smokeConfig.MaxGenerations = 2;
    smokeConfig.FunctionTolerance = 1e-4;
    smokeConfig.ConstraintTolerance = 1e-6;
    smokeConfig.ParetoFraction = 0.35;
    smokeConfig.UseParallel = false;
    smokeConfig.note = 'Smoke run only. No scientific value. Do not use for conclusions.';

    fprintf('=== SMOKE CONFIG ===\n');
    disp(smokeConfig);

    % ---------------------------------------------------------------------
    % Guardar configuración
    % ---------------------------------------------------------------------
    Tconfig = table( ...
        string(varNames(:)), ...
        x_selected(:), ...
        lb(:), ...
        ub(:), ...
        'VariableNames', {'variable','x_selected','lb','ub'});

    writetable(Tconfig, fullfile(tablesDir,'GUARDED_SMOKE_GA_v91g_bounds.csv'));

    % ---------------------------------------------------------------------
    % Preflight directo en x_selected
    % ---------------------------------------------------------------------
    fprintf('\n=== PREFLIGHT DIRECT OBJECTIVE CHECK ===\n');

    preModes = ["gasLP","hybrid","solar"];
    preRows = {};

    for i = 1:numel(preModes)
        mode = preModes(i);

        [f, detail, status, errMsg] = local_eval_guarded_objective_v91g(x_selected, mode);

        row = local_detail_to_row_v91g(mode, x_selected, f, detail, status, errMsg);
        preRows{end+1,1} = row; %#ok<AGROW>

        fprintf('mode=%s | status=%s | f=[%.12g %.12g]\n', mode, status, f(1), f(2));
    end

    Tpreflight = struct2table(vertcat(preRows{:}));
    writetable(Tpreflight, fullfile(tablesDir,'GUARDED_SMOKE_GA_v91g_preflight.csv'));

    disp('=== PREFLIGHT TABLE ===');
    disp(Tpreflight);

    % ---------------------------------------------------------------------
    % Validaciones esperadas preflight
    % ---------------------------------------------------------------------
    gasPre = Tpreflight(strcmp(string(Tpreflight.mode),"gasLP"),:);
    hybPre = Tpreflight(strcmp(string(Tpreflight.mode),"hybrid"),:);
    solPre = Tpreflight(strcmp(string(Tpreflight.mode),"solar"),:);

    preflightFlags = struct();
    preflightFlags.gasLP_status_ok = strcmp(string(gasPre.eval_status(1)),"OK");
    preflightFlags.hybrid_status_ok = strcmp(string(hybPre.eval_status(1)),"OK");
    preflightFlags.solar_status_ok = strcmp(string(solPre.eval_status(1)),"OK");

    preflightFlags.gasLP_not_penalized = gasPre.MR_objective(1) < 1000 && gasPre.cost_objective(1) < 1e6;
    preflightFlags.hybrid_not_penalized = hybPre.MR_objective(1) < 1000 && hybPre.cost_objective(1) < 1e6;
    preflightFlags.solar_penalized = solPre.MR_objective(1) >= 1000 || solPre.cost_objective(1) >= 1e6;

    preflightFlags.hybrid_irradiacion_positive = hybPre.Irradiacion(1) > 0;
    preflightFlags.gasLP_irradiacion_zero = abs(gasPre.Irradiacion(1)) < 1e-9 || isnan(gasPre.Irradiacion(1));
    preflightFlags.solar_invalid_expected = preflightFlags.solar_penalized;

    fprintf('\n=== PREFLIGHT FLAGS ===\n');
    disp(preflightFlags);

    % ---------------------------------------------------------------------
    % Corridas de humo GA
    % ---------------------------------------------------------------------
    modesToRun = ["gasLP","hybrid"];
    gaSummaries = {};
    modeResults = struct();

    for m = 1:numel(modesToRun)
        mode = modesToRun(m);

        fprintf('\n=== STARTING SMOKE GA MODE: %s ===\n', mode);

        modeDir = fullfile(runDir, char(mode));
        modeMatDir = fullfile(modeDir,'mat');
        modeTablesDir = fullfile(modeDir,'tables');
        modeLogsDir = fullfile(modeDir,'logs');

        if ~isfolder(modeDir), mkdir(modeDir); end
        if ~isfolder(modeMatDir), mkdir(modeMatDir); end
        if ~isfolder(modeTablesDir), mkdir(modeTablesDir); end
        if ~isfolder(modeLogsDir), mkdir(modeLogsDir); end

        history = struct();
        history.mode = mode;
        history.generations = [];
        history.bestScore = {};
        history.population = {};
        history.score = {};
        history.timestamp = {};

        % Población inicial pequeña, forzada a incluir la solución seleccionada.
        initPop = local_make_initial_population_v91g(x_selected, lb, ub, smokeConfig.PopulationSize);

        options = optimoptions('gamultiobj', ...
            'PopulationSize', smokeConfig.PopulationSize, ...
            'MaxGenerations', smokeConfig.MaxGenerations, ...
            'FunctionTolerance', smokeConfig.FunctionTolerance, ...
            'ConstraintTolerance', smokeConfig.ConstraintTolerance, ...
            'ParetoFraction', smokeConfig.ParetoFraction, ...
            'UseParallel', smokeConfig.UseParallel, ...
            'Display','iter', ...
            'InitialPopulationMatrix', initPop, ...
            'OutputFcn', @local_output_fcn);

        objfun = @(x)local_objective_wrapper_v91g(x, mode);

        tStart = tic;

        gaStatus = "OK";
        gaErrMsg = "";

        try
            [xGA, fvalGA, exitflag, output, population, scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, options);
        catch ME
            xGA = NaN(1,nvars);
            fvalGA = NaN(1,2);
            exitflag = NaN;
            output = struct();
            population = NaN;
            scores = NaN;
            gaStatus = "ERROR";
            gaErrMsg = string(ME.message);
            fprintf('ERROR in smoke GA mode %s: %s\n', mode, ME.message);
        end

        runtime_seconds = toc(tStart);

        % Guardar resultados por modo
        save(fullfile(modeMatDir, sprintf('GUARDED_SMOKE_GA_v91g_%s_results.mat', mode)), ...
            'mode','xGA','fvalGA','exitflag','output','population','scores', ...
            'history','runtime_seconds','gaStatus','gaErrMsg','smokeConfig','lb','ub','x_selected');

        % Tablas finales
        try
            Tpop = array2table(population, 'VariableNames', cellstr(varNames));
            writetable(Tpop, fullfile(modeTablesDir, sprintf('GUARDED_SMOKE_GA_v91g_%s_final_population.csv', mode)));
        catch
        end

        try
            Tscores = array2table(scores, 'VariableNames', {'MR_objective','cost_objective'});
            writetable(Tscores, fullfile(modeTablesDir, sprintf('GUARDED_SMOKE_GA_v91g_%s_final_scores.csv', mode)));
        catch
        end

        row = struct();
        row.mode = mode;
        row.ga_status = gaStatus;
        row.ga_error = gaErrMsg;
        row.exitflag = exitflag;
        row.runtime_seconds = runtime_seconds;
        row.num_solutions = size(fvalGA,1);
        row.population_size = smokeConfig.PopulationSize;
        row.max_generations = smokeConfig.MaxGenerations;
        row.history_points = numel(history.generations);

        if isnumeric(fvalGA) && ~isempty(fvalGA) && all(size(fvalGA,2) >= 2)
            row.min_MR_objective = min(fvalGA(:,1),[],'omitnan');
            row.min_cost_objective = min(fvalGA(:,2),[],'omitnan');
            row.any_penalty = any(fvalGA(:,1) >= 1000 | fvalGA(:,2) >= 1e6);
        else
            row.min_MR_objective = NaN;
            row.min_cost_objective = NaN;
            row.any_penalty = true;
        end

        gaSummaries{end+1,1} = row; %#ok<AGROW>

        modeResults.(char(mode)).xGA = xGA;
        modeResults.(char(mode)).fvalGA = fvalGA;
        modeResults.(char(mode)).exitflag = exitflag;
        modeResults.(char(mode)).output = output;
        modeResults.(char(mode)).population = population;
        modeResults.(char(mode)).scores = scores;
        modeResults.(char(mode)).history = history;
        modeResults.(char(mode)).runtime_seconds = runtime_seconds;
        modeResults.(char(mode)).gaStatus = gaStatus;
        modeResults.(char(mode)).gaErrMsg = gaErrMsg;

        fprintf('=== FINISHED SMOKE GA MODE: %s ===\n', mode);
        fprintf('gaStatus=%s | runtime=%.3f s | exitflag=%.12g\n', gaStatus, runtime_seconds, exitflag);

    end

    Tga = struct2table(vertcat(gaSummaries{:}));
    writetable(Tga, fullfile(tablesDir,'GUARDED_SMOKE_GA_v91g_ga_summary.csv'));

    % ---------------------------------------------------------------------
    % Diagnóstico final
    % ---------------------------------------------------------------------
    smokeFlags = struct();

    smokeFlags.preflight_gasLP_ok = preflightFlags.gasLP_status_ok && preflightFlags.gasLP_not_penalized;
    smokeFlags.preflight_hybrid_ok = preflightFlags.hybrid_status_ok && preflightFlags.hybrid_not_penalized && preflightFlags.hybrid_irradiacion_positive;
    smokeFlags.preflight_solar_penalized = preflightFlags.solar_status_ok && preflightFlags.solar_penalized;

    smokeFlags.ga_gasLP_completed = any(strcmp(string(Tga.mode),"gasLP")) && strcmp(string(Tga.ga_status(strcmp(string(Tga.mode),"gasLP"))),"OK");
    smokeFlags.ga_hybrid_completed = any(strcmp(string(Tga.mode),"hybrid")) && strcmp(string(Tga.ga_status(strcmp(string(Tga.mode),"hybrid"))),"OK");

    smokeFlags.ga_gasLP_history_saved = modeResults.gasLP.history.generations(end) >= 0;
    smokeFlags.ga_hybrid_history_saved = modeResults.hybrid.history.generations(end) >= 0;

    smokeFlags.outputs_saved = ...
        isfile(fullfile(tablesDir,'GUARDED_SMOKE_GA_v91g_preflight.csv')) && ...
        isfile(fullfile(tablesDir,'GUARDED_SMOKE_GA_v91g_ga_summary.csv'));

    smokeFlags.diary_saved = isfile(diaryFile);

    smokeFlags.not_for_scientific_conclusions = true;
    smokeFlags.formal_guarded_GA_still_pending = true;

    if smokeFlags.preflight_gasLP_ok && ...
       smokeFlags.preflight_hybrid_ok && ...
       smokeFlags.preflight_solar_penalized && ...
       smokeFlags.ga_gasLP_completed && ...
       smokeFlags.ga_hybrid_completed && ...
       smokeFlags.outputs_saved && ...
       smokeFlags.diary_saved

        diagnosis = "GUARDED_SMOKE_GA_PASS";
    else
        diagnosis = "GUARDED_SMOKE_GA_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'GUARDED_SMOKE_GA_v91g.md');
    outTxt = fullfile(logsDir,'GUARDED_SMOKE_GA_v91g.txt');
    outMat = fullfile(matDir,'GUARDED_SMOKE_GA_v91g.mat');

    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# GUARDED_SMOKE_GA_v91g\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Corrida: `%s`\n\n', runDir);
    fprintf(fid,'Función objetivo guardada: `%s`\n\n', objName);

    fprintf(fid,'## Naturaleza de la corrida\n\n');
    fprintf(fid,'Esta es una corrida de humo. No tiene valor científico, no debe usarse para conclusiones y no sustituye una corrida formal. Su objetivo es verificar flujo, trazabilidad, guardado de outputs e integración de penalizaciones físicas.\n\n');

    fprintf(fid,'## Configuración\n\n');
    fprintf(fid,'| Parámetro | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| PopulationSize | %d |\n', smokeConfig.PopulationSize);
    fprintf(fid,'| MaxGenerations | %d |\n', smokeConfig.MaxGenerations);
    fprintf(fid,'| FunctionTolerance | %.12g |\n', smokeConfig.FunctionTolerance);
    fprintf(fid,'| ParetoFraction | %.12g |\n\n', smokeConfig.ParetoFraction);

    fprintf(fid,'## Caja local de búsqueda\n\n');
    fprintf(fid,'| Variable | x seleccionado | lb humo | ub humo |\n');
    fprintf(fid,'|---|---:|---:|---:|\n');
    for i = 1:numel(varNames)
        fprintf(fid,'| `%s` | %.12g | %.12g | %.12g |\n', varNames(i), x_selected(i), lb(i), ub(i));
    end
    fprintf(fid,'\n');

    fprintf(fid,'## Preflight directo\n\n');
    fprintf(fid,'| Modo | eval_status | MR objective | cost objective | Q_aux_tot | Irradiacion | dry_time | M | detail_status |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---|\n');

    for r = 1:height(Tpreflight)
        fprintf(fid,'| %s | %s | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %s |\n', ...
            string(Tpreflight.mode(r)), ...
            string(Tpreflight.eval_status(r)), ...
            Tpreflight.MR_objective(r), ...
            Tpreflight.cost_objective(r), ...
            Tpreflight.Q_aux_tot(r), ...
            Tpreflight.Irradiacion(r), ...
            Tpreflight.dry_time(r), ...
            Tpreflight.M(r), ...
            string(Tpreflight.detail_status(r)));
    end

    fprintf(fid,'\n## Resumen GA de humo\n\n');
    fprintf(fid,'| Modo | ga_status | exitflag | runtime [s] | n soluciones | min MR obj | min cost obj | any penalty | history points |\n');
    fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---:|\n');

    for r = 1:height(Tga)
        fprintf(fid,'| %s | %s | %.12g | %.12g | %.0f | %.12g | %.12g | %d | %.0f |\n', ...
            string(Tga.mode(r)), ...
            string(Tga.ga_status(r)), ...
            Tga.exitflag(r), ...
            Tga.runtime_seconds(r), ...
            Tga.num_solutions(r), ...
            Tga.min_MR_objective(r), ...
            Tga.min_cost_objective(r), ...
            Tga.any_penalty(r), ...
            Tga.history_points(r));
    end

    fprintf(fid,'\n## Flags\n\n');
    fn = fieldnames(smokeFlags);
    for i = 1:numel(fn)
        fprintf(fid,'- `%s`: `%d`\n', fn{i}, smokeFlags.(fn{i}));
    end

    fprintf(fid,'\n## Dictamen\n\n');
    fprintf(fid,'Si el diagnóstico es `GUARDED_SMOKE_GA_PASS`, el flujo está listo para diseñar una corrida formal guardada. La corrida formal sigue pendiente y deberá definirse en un micropaso separado.\n\n');

    fprintf(fid,'## Política de protección\n\n');
    fprintf(fid,'- No modificar `opt_tunel_mod2_v10_energy_mode_corrected.m`.\n');
    fprintf(fid,'- No modificar `objective_productive_corrected_v611.m`.\n');
    fprintf(fid,'- No sobrescribir corrida productiva v614.\n');
    fprintf(fid,'- No usar esta corrida de humo para resultados científicos.\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    fprintf(fid,'GUARDED-SMOKE-RUN-001\n');
    fprintf(fid,'status: GUARDED_SMOKE_GA_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'runDir: %s\n', runDir);
    fprintf(fid,'objective: %s\n', objName);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'PREFLIGHT FLAGS:\n');
    disp_to_file_v91g(fid, preflightFlags);

    fprintf(fid,'\nSMOKE FLAGS:\n');
    disp_to_file_v91g(fid, smokeFlags);

    fprintf(fid,'\nOUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'diaryFile: %s\n', diaryFile);
    fclose(fid);

    % ---------------------------------------------------------------------
    % MAT general
    % ---------------------------------------------------------------------
    save(outMat, ...
        'diagnosis','smokeFlags','preflightFlags','smokeConfig', ...
        'x_selected','lb','ub','Tconfig','Tpreflight','Tga','modeResults', ...
        'runDir','logsDir','tablesDir','matDir','outMd','outTxt','diaryFile');

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    smoke = struct();
    smoke.status = 'GUARDED_SMOKE_GA_COMPLETED';
    smoke.diagnosis = diagnosis;
    smoke.runDir = runDir;
    smoke.objective = objName;
    smoke.smokeConfig = smokeConfig;
    smoke.preflightFlags = preflightFlags;
    smoke.smokeFlags = smokeFlags;
    smoke.Tpreflight = Tpreflight;
    smoke.Tga = Tga;
    smoke.modeResults = modeResults;
    smoke.outMd = outMd;
    smoke.outTxt = outTxt;
    smoke.outMat = outMat;
    smoke.diaryFile = diaryFile;

    fprintf('\n=== GUARDED_SMOKE_GA_v91g COMPLETED ===\n');
    disp(smoke.status)
    disp('=== DIAGNOSIS ===')
    disp(smoke.diagnosis)
    disp('=== PREFLIGHT FLAGS ===')
    disp(smoke.preflightFlags)
    disp('=== SMOKE FLAGS ===')
    disp(smoke.smokeFlags)
    disp('=== PREFLIGHT TABLE ===')
    disp(smoke.Tpreflight)
    disp('=== GA SUMMARY ===')
    disp(smoke.Tga)
    disp('=== OUTPUT FILES ===')
    disp(smoke.outMd)
    disp(smoke.outTxt)
    disp(smoke.outMat)
    disp(smoke.diaryFile)

    % ---------------------------------------------------------------------
    % Funciones anidadas
    % ---------------------------------------------------------------------
    function [state,options,optchanged] = local_output_fcn(options,state,flag)
        optchanged = false;

        switch flag
            case {'init','iter','done'}
                try
                    history.generations(end+1,1) = state.Generation;
                    history.population{end+1,1} = state.Population;
                    history.score{end+1,1} = state.Score;
                    history.timestamp{end+1,1} = datestr(now,'yyyy-mm-dd HH:MM:SS');

                    if isfield(state,'Score') && ~isempty(state.Score)
                        history.bestScore{end+1,1} = min(state.Score,[],1,'omitnan');
                    else
                        history.bestScore{end+1,1} = [];
                    end

                    save(fullfile(modeMatDir, sprintf('GUARDED_SMOKE_GA_v91g_%s_history_live.mat', mode)), ...
                        'history','mode','flag','state');
                catch MEhist
                    fprintf('OutputFcn warning mode=%s flag=%s: %s\n', mode, flag, MEhist.message);
                end
        end
    end

end

% =========================================================================
% Funciones locales auxiliares
% =========================================================================

function F = local_objective_wrapper_v91g(x, mode)
    try
        [Fraw, ~] = objective_productive_corrected_v628b_nonphysical_penalty(x, mode);

        F = double(Fraw(:))';

        if numel(F) < 2
            F = [1000, 1e6];
        end

        F = F(1:2);

        if any(~isfinite(F)) || any(~isreal(F))
            F = [1000, 1e6];
        end

    catch
        F = [1000, 1e6];
    end
end

function [f, detail, status, errMsg] = local_eval_guarded_objective_v91g(x, mode)
    status = "OK";
    errMsg = "";
    detail = struct();

    try
        [f, detail] = objective_productive_corrected_v628b_nonphysical_penalty(x, mode);
        f = double(f(:))';

        if numel(f) < 2
            f = [1000, 1e6];
            status = "BAD_OBJECTIVE_SIZE";
        else
            f = f(1:2);
        end

        if any(~isfinite(f)) || any(~isreal(f))
            f = [1000, 1e6];
            status = "BAD_OBJECTIVE_VALUE";
        end

    catch ME
        f = [1000, 1e6];
        detail = struct();
        status = "ERROR";
        errMsg = string(ME.message);
    end
end

function row = local_detail_to_row_v91g(mode, x, f, detail, status, errMsg)

    row = struct();

    row.mode = string(mode);
    row.eval_status = string(status);
    row.error_message = string(errMsg);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.MR_objective = f(1);
    row.cost_objective = f(2);

    row.detail_status = local_get_string_v91g(detail, {'status','detail_status','execution_status'}, "UNKNOWN");

    row.Q_aux_tot = local_get_numeric_v91g(detail, {'outputs.Q_aux_tot','Q_aux_tot','outputs.Q_aux'}, NaN);
    row.Irradiacion = local_get_numeric_v91g(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v91g(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v91g(detail, {'outputs.M','M'}, NaN);
    row.MR = local_get_numeric_v91g(detail, {'outputs.MR','MR'}, NaN);

    row.cost_specific = local_get_numeric_v91g(detail, {'cost.cost_specific_USD_per_kgwater','cost_specific_USD_per_kgwater'}, NaN);
    row.total_cost = local_get_numeric_v91g(detail, {'cost.total_cost_USD','total_cost_USD'}, NaN);

    row.execution_message = local_get_string_v91g(detail, {'execution.message','message'}, "");

end

function val = local_get_numeric_v91g(S, paths, defaultVal)
    val = defaultVal;

    for i = 1:numel(paths)
        p = string(paths{i});
        parts = split(p,'.');

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
                val = tmp(1);
                return
            end
        catch
        end
    end
end

function val = local_get_string_v91g(S, paths, defaultVal)
    val = string(defaultVal);

    for i = 1:numel(paths)
        p = string(paths{i});
        parts = split(p,'.');

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

function initPop = local_make_initial_population_v91g(x0, lb, ub, n)
    nvars = numel(x0);
    initPop = zeros(n,nvars);

    initPop(1,:) = x0;

    for i = 2:n
        alpha = rand(1,nvars);
        initPop(i,:) = lb + alpha .* (ub - lb);
    end

    initPop = min(max(initPop, lb), ub);
end

function disp_to_file_v91g(fid, S)
    fn = fieldnames(S);
    for i = 1:numel(fn)
        v = S.(fn{i});
        if islogical(v)
            fprintf(fid,'%s: %d\n', fn{i}, v);
        elseif isnumeric(v)
            fprintf(fid,'%s: %.12g\n', fn{i}, v);
        elseif isstring(v) || ischar(v)
            fprintf(fid,'%s: %s\n', fn{i}, string(v));
        else
            fprintf(fid,'%s: [unsupported]\n', fn{i});
        end
    end
end