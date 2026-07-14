function formal = run_guarded_formal_ga_v93g(confirm_execute)
% RUN_GUARDED_FORMAL_GA_v93g
% 9.3g — GUARDED-FORMAL-RUN-SCRIPT-001
%
% Objetivo:
%   Construir y controlar la corrida formal guardada.
%
% Seguridad:
%   Si confirm_execute no es true, NO ejecuta gamultiobj.
%
% Uso seguro de preflight:
%   formal = run_guarded_formal_ga_v93g(false);
%
% Uso para ejecutar formalmente:
%   formal = run_guarded_formal_ga_v93g(true);
%
% Alcance aprobado desde 9.2g:
%   - Escenario recomendado: F1_MINIMAL_DEFENSIBLE
%   - Optimizar modo hybrid con objetivo guardado
%   - gasLP se conserva como referencia postrun/controlada
%   - solar permanece excluido
%
% No modifica:
%   - opt_tunel_mod2_v10_energy_mode_corrected.m
%   - objective_productive_corrected_v611.m
%   - corrida productiva v614
%
% Salidas:
%   05_runs/guarded_formal_v93g/GUARDED_FORMAL_GA_v93g_yyyymmdd_HHMMSS/
%       logs/
%       tables/
%       mat/
%       hybrid/
%
% Nota:
%   CO2 no se reclama aquí. La estimación de CO2 queda como pendiente
%   metodológico separado.

    if nargin < 1
        confirm_execute = false;
    end

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    objName = 'objective_productive_corrected_v628b_nonphysical_penalty';

    if exist(objName,'file') ~= 2
        error('No se encontró la función objetivo guardada: %s', objName);
    end

    % ---------------------------------------------------------------------
    % Cargar diseño aprobado v92g
    % ---------------------------------------------------------------------
    designBaseDir = fullfile(rootDir,'05_runs','guarded_formal_design_v92g');

    if ~isfolder(designBaseDir)
        error('No existe designBaseDir: %s', designBaseDir);
    end

    d = dir(designBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for i = 1:numel(d)
        keep(i) = startsWith(d(i).name,'GUARDED_FORMAL_RUN_DESIGN_v92g_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró diseño formal v92g.');
    end

    [~,idxDesign] = max([d.datenum]);
    designDir = fullfile(designBaseDir,d(idxDesign).name);
    designMat = fullfile(designDir,'mat','GUARDED_FORMAL_RUN_DESIGN_v92g.mat');

    if ~isfile(designMat)
        error('No existe MAT de diseño formal: %s', designMat);
    end

    Sdesign = load(designMat);

    if ~isfield(Sdesign,'diagnosis')
        error('El MAT v92g no contiene diagnosis.');
    end

    if ~strcmp(string(Sdesign.diagnosis),"GUARDED_FORMAL_RUN_DESIGN_PASS")
        error('El diseño formal v92g no está en PASS. Diagnosis: %s', string(Sdesign.diagnosis));
    end

    formalDesign = Sdesign.formalDesign;

    % ---------------------------------------------------------------------
    % Validar que se está usando el escenario esperado
    % ---------------------------------------------------------------------
    if ~strcmp(string(formalDesign.scenario),"F1_MINIMAL_DEFENSIBLE")
        error('El escenario aprobado no es F1_MINIMAL_DEFENSIBLE. Revisar v92g.');
    end

    if ~strcmp(string(formalDesign.primary_mode_to_optimize),"hybrid")
        error('El modo primario aprobado no es hybrid. Revisar v92g.');
    end

    if formalDesign.PopulationSize <= 0 || formalDesign.MaxGenerations <= 0
        error('PopulationSize/MaxGenerations inválidos en formalDesign.');
    end

    % ---------------------------------------------------------------------
    % Crear carpeta de corrida formal
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    baseRunDir = fullfile(rootDir,'05_runs','guarded_formal_v93g');
    runDir = fullfile(baseRunDir, ['GUARDED_FORMAL_GA_v93g_' timestamp]);

    logsDir   = fullfile(runDir,'logs');
    tablesDir = fullfile(runDir,'tables');
    matDir    = fullfile(runDir,'mat');

    mode = "hybrid";
    modeDir = fullfile(runDir,char(mode));
    modeLogsDir = fullfile(modeDir,'logs');
    modeTablesDir = fullfile(modeDir,'tables');
    modeMatDir = fullfile(modeDir,'mat');

    if ~isfolder(baseRunDir), mkdir(baseRunDir); end
    if ~isfolder(runDir), mkdir(runDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end
    if ~isfolder(modeDir), mkdir(modeDir); end
    if ~isfolder(modeLogsDir), mkdir(modeLogsDir); end
    if ~isfolder(modeTablesDir), mkdir(modeTablesDir); end
    if ~isfolder(modeMatDir), mkdir(modeMatDir); end

    diaryFile = fullfile(logsDir,'GUARDED_FORMAL_GA_v93g_diary.txt');
    if isfile(diaryFile), delete(diaryFile); end
    diary(diaryFile);
    cleanupObj = onCleanup(@() diary('off'));

    fprintf('=== GUARDED_FORMAL_GA_v93g ===\n');
    fprintf('runDir: %s\n', runDir);
    fprintf('designDir: %s\n', designDir);
    fprintf('objective: %s\n', objName);
    fprintf('confirm_execute: %d\n\n', logical(confirm_execute));

    % ---------------------------------------------------------------------
    % Configuración formal
    % ---------------------------------------------------------------------
    rng(1,'twister');

    formalConfig = struct();
    formalConfig.label = 'GUARDED_FORMAL_GA_v93g';
    formalConfig.created_at = datestr(now,'yyyy-mm-dd HH:MM:SS');
    formalConfig.rootDir = rootDir;
    formalConfig.runDir = runDir;
    formalConfig.designDir = designDir;
    formalConfig.objective = objName;
    formalConfig.scenario = string(formalDesign.scenario);
    formalConfig.mode = mode;
    formalConfig.reference_mode = string(formalDesign.reference_mode);
    formalConfig.excluded_mode = string(formalDesign.excluded_mode);
    formalConfig.reason_solar_excluded = string(formalDesign.reason_solar_excluded);
    formalConfig.PopulationSize = formalDesign.PopulationSize;
    formalConfig.MaxGenerations = formalDesign.MaxGenerations;
    formalConfig.FunctionTolerance = formalDesign.FunctionTolerance;
    formalConfig.ConstraintTolerance = formalDesign.ConstraintTolerance;
    formalConfig.ParetoFraction = formalDesign.ParetoFraction;
    formalConfig.UseParallel = formalDesign.UseParallel;
    formalConfig.rng = formalDesign.rng;
    formalConfig.confirm_execute = logical(confirm_execute);
    formalConfig.not_for_CO2_claims = true;
    formalConfig.CO2_pending = true;
    formalConfig.physics_operation_review_pending = true;
    formalConfig.solar_branch_revalidation_pending = true;

    % Solución seleccionada v614 para referencia e inicialización.
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    varNames = ["m_max","T_min","r_div2","t_rec_ini"];

    % Caja formal F1.
    % Se mantiene controlada alrededor de la región ya validada.
    lb_global = [0.05, 55.0, 0.00, 8.0];
    ub_global = [0.12, 70.0, 0.95, 14.0];

    delta = [0.020, 5.0, 0.25, 3.0];

    lb = max(lb_global, x_selected - delta);
    ub = min(ub_global, x_selected + delta);

    nvars = numel(x_selected);

    formalConfig.x_selected = x_selected;
    formalConfig.lb = lb;
    formalConfig.ub = ub;
    formalConfig.nvars = nvars;

    Tbounds = table( ...
        string(varNames(:)), ...
        x_selected(:), ...
        lb(:), ...
        ub(:), ...
        'VariableNames', {'variable','x_selected','lb','ub'});

    writetable(Tbounds, fullfile(tablesDir,'GUARDED_FORMAL_GA_v93g_bounds.csv'));

    % ---------------------------------------------------------------------
    % Preflight obligatorio
    % ---------------------------------------------------------------------
    fprintf('=== PREFLIGHT DIRECT OBJECTIVE CHECK ===\n');

    preModes = ["gasLP","hybrid","solar"];
    preRows = {};

    for i = 1:numel(preModes)
        preMode = preModes(i);
        [f, detail, status, errMsg] = local_eval_guarded_objective_v93g(x_selected, preMode);
        row = local_detail_to_row_v93g(preMode, x_selected, f, detail, status, errMsg);
        preRows{end+1,1} = row; %#ok<AGROW>

        fprintf('mode=%s | status=%s | f=[%.12g %.12g]\n', preMode, status, f(1), f(2));
    end

    Tpreflight = struct2table(vertcat(preRows{:}));
    writetable(Tpreflight, fullfile(tablesDir,'GUARDED_FORMAL_GA_v93g_preflight.csv'));

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
    preflightFlags.preflight_pass = ...
        preflightFlags.gasLP_status_ok && ...
        preflightFlags.hybrid_status_ok && ...
        preflightFlags.solar_status_ok && ...
        preflightFlags.gasLP_not_penalized && ...
        preflightFlags.hybrid_not_penalized && ...
        preflightFlags.solar_penalized && ...
        preflightFlags.hybrid_irradiacion_positive;

    disp('=== PREFLIGHT FLAGS ===');
    disp(preflightFlags);

    if ~preflightFlags.preflight_pass
        executionStatus = "PREFLIGHT_FAILED_NO_GA_EXECUTED";
        diagnosis = "GUARDED_FORMAL_GA_PREFLIGHT_FAILED";
        xGA = NaN;
        fvalGA = NaN;
        exitflag = NaN;
        output = struct();
        population = NaN;
        scores = NaN;
        history = struct();
        runtime_seconds = NaN;
        gaStatus = "NOT_EXECUTED";
        gaErrMsg = "Preflight failed.";
        formal = local_finalize_v93g();
        return
    end

    % ---------------------------------------------------------------------
    % Seguro de ejecución
    % ---------------------------------------------------------------------
    if ~logical(confirm_execute)
        executionStatus = "CONFIG_READY_NO_EXECUTION";
        diagnosis = "GUARDED_FORMAL_GA_SCRIPT_READY_NO_EXECUTION";
        xGA = NaN;
        fvalGA = NaN;
        exitflag = NaN;
        output = struct();
        population = NaN;
        scores = NaN;
        history = struct();
        runtime_seconds = NaN;
        gaStatus = "NOT_EXECUTED";
        gaErrMsg = "confirm_execute=false. No GA executed.";
        formal = local_finalize_v93g();
        return
    end

    % ---------------------------------------------------------------------
    % Ejecutar corrida formal hybrid
    % ---------------------------------------------------------------------
    fprintf('\n=== STARTING GUARDED FORMAL GA MODE: hybrid ===\n');
    fprintf('PopulationSize: %.0f\n', formalConfig.PopulationSize);
    fprintf('MaxGenerations: %.0f\n', formalConfig.MaxGenerations);
    fprintf('Estimated evaluations: %.0f\n', formalConfig.PopulationSize * formalConfig.MaxGenerations);

    history = struct();
    history.mode = mode;
    history.generations = [];
    history.bestScore = {};
    history.population = {};
    history.score = {};
    history.timestamp = {};

    initPop = local_make_initial_population_v93g(x_selected, lb, ub, formalConfig.PopulationSize);

    Tinit = array2table(initPop, 'VariableNames', cellstr(varNames));
    writetable(Tinit, fullfile(modeTablesDir,'GUARDED_FORMAL_GA_v93g_hybrid_initial_population.csv'));

    options = optimoptions('gamultiobj', ...
        'PopulationSize', formalConfig.PopulationSize, ...
        'MaxGenerations', formalConfig.MaxGenerations, ...
        'FunctionTolerance', formalConfig.FunctionTolerance, ...
        'ConstraintTolerance', formalConfig.ConstraintTolerance, ...
        'ParetoFraction', formalConfig.ParetoFraction, ...
        'UseParallel', formalConfig.UseParallel, ...
        'Display','iter', ...
        'InitialPopulationMatrix', initPop, ...
        'OutputFcn', @local_output_fcn);

    objfun = @(x)local_objective_wrapper_v93g(x, mode);

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
        fprintf('ERROR in formal GA mode hybrid: %s\n', ME.message);
    end

    runtime_seconds = toc(tStart);

    executionStatus = "FORMAL_GA_EXECUTED";

    if strcmp(gaStatus,"OK")
        diagnosis = "GUARDED_FORMAL_GA_EXECUTION_COMPLETED";
    else
        diagnosis = "GUARDED_FORMAL_GA_EXECUTION_ERROR";
    end

    % Guardar tablas finales
    try
        Tpop = array2table(population, 'VariableNames', cellstr(varNames));
        writetable(Tpop, fullfile(modeTablesDir,'GUARDED_FORMAL_GA_v93g_hybrid_final_population.csv'));
    catch
    end

    try
        Tscores = array2table(scores, 'VariableNames', {'MR_objective','cost_objective'});
        writetable(Tscores, fullfile(modeTablesDir,'GUARDED_FORMAL_GA_v93g_hybrid_final_scores.csv'));
    catch
    end

    try
        Tsol = array2table(xGA, 'VariableNames', cellstr(varNames));
        Tsol.MR_objective = fvalGA(:,1);
        Tsol.cost_objective = fvalGA(:,2);
        writetable(Tsol, fullfile(modeTablesDir,'GUARDED_FORMAL_GA_v93g_hybrid_pareto_solutions.csv'));
    catch
    end

    save(fullfile(modeMatDir,'GUARDED_FORMAL_GA_v93g_hybrid_results.mat'), ...
        'mode','xGA','fvalGA','exitflag','output','population','scores', ...
        'history','runtime_seconds','gaStatus','gaErrMsg','formalConfig','lb','ub','x_selected');

    formal = local_finalize_v93g();

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

                    save(fullfile(modeMatDir,'GUARDED_FORMAL_GA_v93g_hybrid_history_live.mat'), ...
                        'history','mode','flag','state');
                catch MEhist
                    fprintf('OutputFcn warning mode=%s flag=%s: %s\n', mode, flag, MEhist.message);
                end
        end
    end

    function formal = local_finalize_v93g()

        outMd = fullfile(logsDir,'GUARDED_FORMAL_GA_v93g.md');
        outTxt = fullfile(logsDir,'GUARDED_FORMAL_GA_v93g.txt');
        outMat = fullfile(matDir,'GUARDED_FORMAL_GA_v93g.mat');

        formalFlags = struct();
        formalFlags.preflight_pass = preflightFlags.preflight_pass;
        formalFlags.confirm_execute = logical(confirm_execute);
        formalFlags.formal_GA_executed = strcmp(executionStatus,"FORMAL_GA_EXECUTED");
        formalFlags.hybrid_mode_only = true;
        formalFlags.gasLP_reference_only = true;
        formalFlags.solar_excluded = true;
        formalFlags.CO2_claims_blocked = true;
        formalFlags.physics_operation_review_pending = true;
        formalFlags.solar_branch_revalidation_pending = true;
        formalFlags.outputs_saved = true;
        formalFlags.diary_saved = isfile(diaryFile);

        summaryRow = struct();
        summaryRow.mode = mode;
        summaryRow.executionStatus = executionStatus;
        summaryRow.gaStatus = gaStatus;
        summaryRow.gaErrMsg = string(gaErrMsg);
        summaryRow.exitflag = exitflag;
        summaryRow.runtime_seconds = runtime_seconds;
        summaryRow.PopulationSize = formalConfig.PopulationSize;
        summaryRow.MaxGenerations = formalConfig.MaxGenerations;

        if isnumeric(fvalGA) && ~isempty(fvalGA) && size(fvalGA,2) >= 2
            summaryRow.num_solutions = size(fvalGA,1);
            summaryRow.min_MR_objective = min(fvalGA(:,1),[],'omitnan');
            summaryRow.min_cost_objective = min(fvalGA(:,2),[],'omitnan');
            summaryRow.any_penalty = any(fvalGA(:,1) >= 1000 | fvalGA(:,2) >= 1e6);
        else
            summaryRow.num_solutions = NaN;
            summaryRow.min_MR_objective = NaN;
            summaryRow.min_cost_objective = NaN;
            summaryRow.any_penalty = NaN;
        end

        Tsummary = struct2table(summaryRow);
        writetable(Tsummary, fullfile(tablesDir,'GUARDED_FORMAL_GA_v93g_summary.csv'));

        save(outMat, ...
            'diagnosis','executionStatus','formalFlags','formalConfig', ...
            'preflightFlags','Tpreflight','Tsummary','Tbounds', ...
            'x_selected','lb','ub','xGA','fvalGA','exitflag','output','population','scores', ...
            'history','runtime_seconds','gaStatus','gaErrMsg', ...
            'runDir','designDir','modeDir','logsDir','tablesDir','matDir', ...
            'outMd','outTxt','outMat','diaryFile');

        % Markdown
        fid = fopen(outMd,'w');
        if fid < 0
            error('No se pudo crear MD: %s', outMd);
        end

        fprintf(fid,'# GUARDED_FORMAL_GA_v93g\n\n');

        fprintf(fid,'## Estado\n\n');
        fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
        fprintf(fid,'Execution status: `%s`\n\n', executionStatus);
        fprintf(fid,'confirm_execute: `%d`\n\n', logical(confirm_execute));
        fprintf(fid,'Corrida: `%s`\n\n', runDir);

        fprintf(fid,'## Alcance\n\n');
        fprintf(fid,'Esta corrida formal está diseñada para optimizar únicamente el modo `hybrid` con función objetivo guardada. `gasLP` se conserva como referencia postrun/controlada. `solar` puro permanece excluido por trayectoria no física bajo la formulación actual.\n\n');

        fprintf(fid,'## Configuración\n\n');
        fprintf(fid,'| Parámetro | Valor |\n');
        fprintf(fid,'|---|---:|\n');
        fprintf(fid,'| PopulationSize | %.0f |\n', formalConfig.PopulationSize);
        fprintf(fid,'| MaxGenerations | %.0f |\n', formalConfig.MaxGenerations);
        fprintf(fid,'| FunctionTolerance | %.12g |\n', formalConfig.FunctionTolerance);
        fprintf(fid,'| ConstraintTolerance | %.12g |\n', formalConfig.ConstraintTolerance);
        fprintf(fid,'| ParetoFraction | %.12g |\n\n', formalConfig.ParetoFraction);

        fprintf(fid,'## Bounds\n\n');
        fprintf(fid,'| Variable | x seleccionado | lb formal | ub formal |\n');
        fprintf(fid,'|---|---:|---:|---:|\n');
        for ii = 1:numel(varNames)
            fprintf(fid,'| `%s` | %.12g | %.12g | %.12g |\n', varNames(ii), x_selected(ii), lb(ii), ub(ii));
        end

        fprintf(fid,'\n## Preflight\n\n');
        fprintf(fid,'| Modo | eval_status | MR objective | cost objective | Q_aux_tot | Irradiacion | dry_time | M | detail_status |\n');
        fprintf(fid,'|---|---|---:|---:|---:|---:|---:|---:|---|\n');

        for rr = 1:height(Tpreflight)
            fprintf(fid,'| %s | %s | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %s |\n', ...
                string(Tpreflight.mode(rr)), ...
                string(Tpreflight.eval_status(rr)), ...
                Tpreflight.MR_objective(rr), ...
                Tpreflight.cost_objective(rr), ...
                Tpreflight.Q_aux_tot(rr), ...
                Tpreflight.Irradiacion(rr), ...
                Tpreflight.dry_time(rr), ...
                Tpreflight.M(rr), ...
                string(Tpreflight.detail_status(rr)));
        end

        fprintf(fid,'\n## Resultado de ejecución\n\n');
        fprintf(fid,'| Campo | Valor |\n');
        fprintf(fid,'|---|---:|\n');
        fprintf(fid,'| gaStatus | `%s` |\n', gaStatus);
        fprintf(fid,'| exitflag | %.12g |\n', exitflag);
        fprintf(fid,'| runtime_seconds | %.12g |\n', runtime_seconds);
        fprintf(fid,'| num_solutions | %.12g |\n', summaryRow.num_solutions);
        fprintf(fid,'| min_MR_objective | %.12g |\n', summaryRow.min_MR_objective);
        fprintf(fid,'| min_cost_objective | %.12g |\n', summaryRow.min_cost_objective);
        fprintf(fid,'| any_penalty | %.12g |\n\n', summaryRow.any_penalty);

        fprintf(fid,'## Restricciones interpretativas\n\n');
        fprintf(fid,'- No reclamar CO2 en esta corrida.\n');
        fprintf(fid,'- No presentar `solar` puro como comparación de desempeño.\n');
        fprintf(fid,'- No concluir manuscrito hasta consolidar y auditar la corrida formal.\n');
        fprintf(fid,'- La revisión de física de operación del modelo permanece pendiente.\n');
        fprintf(fid,'- La estimación de CO2 permanece pendiente.\n\n');

        fprintf(fid,'## Archivos\n\n');
        fprintf(fid,'- `%s`\n', outMat);
        fprintf(fid,'- `%s`\n', diaryFile);
        fprintf(fid,'- `%s`\n', fullfile(modeMatDir,'GUARDED_FORMAL_GA_v93g_hybrid_results.mat'));

        fclose(fid);

        % TXT
        fid = fopen(outTxt,'w');
        if fid < 0
            error('No se pudo crear TXT: %s', outTxt);
        end

        fprintf(fid,'GUARDED-FORMAL-RUN-SCRIPT-001\n');
        fprintf(fid,'status: GUARDED_FORMAL_GA_SCRIPT_COMPLETED\n');
        fprintf(fid,'diagnosis: %s\n', diagnosis);
        fprintf(fid,'executionStatus: %s\n', executionStatus);
        fprintf(fid,'confirm_execute: %d\n', logical(confirm_execute));
        fprintf(fid,'runDir: %s\n', runDir);
        fprintf(fid,'objective: %s\n', objName);
        fprintf(fid,'mode: %s\n', mode);
        fprintf(fid,'PopulationSize: %.0f\n', formalConfig.PopulationSize);
        fprintf(fid,'MaxGenerations: %.0f\n', formalConfig.MaxGenerations);
        fprintf(fid,'gaStatus: %s\n', gaStatus);
        fprintf(fid,'runtime_seconds: %.12g\n', runtime_seconds);
        fprintf(fid,'CO2_claims_blocked: 1\n');
        fprintf(fid,'physics_operation_review_pending: 1\n');
        fprintf(fid,'solar_branch_revalidation_pending: 1\n');
        fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));
        fprintf(fid,'OUTPUTS:\n');
        fprintf(fid,'outMd: %s\n', outMd);
        fprintf(fid,'outTxt: %s\n', outTxt);
        fprintf(fid,'outMat: %s\n', outMat);
        fprintf(fid,'diaryFile: %s\n', diaryFile);
        fclose(fid);

        formal = struct();
        formal.status = 'GUARDED_FORMAL_GA_SCRIPT_COMPLETED';
        formal.diagnosis = diagnosis;
        formal.executionStatus = executionStatus;
        formal.confirm_execute = logical(confirm_execute);
        formal.formalFlags = formalFlags;
        formal.formalConfig = formalConfig;
        formal.preflightFlags = preflightFlags;
        formal.Tpreflight = Tpreflight;
        formal.Tsummary = Tsummary;
        formal.Tbounds = Tbounds;
        formal.xGA = xGA;
        formal.fvalGA = fvalGA;
        formal.exitflag = exitflag;
        formal.output = output;
        formal.population = population;
        formal.scores = scores;
        formal.history = history;
        formal.runtime_seconds = runtime_seconds;
        formal.gaStatus = gaStatus;
        formal.gaErrMsg = gaErrMsg;
        formal.runDir = runDir;
        formal.designDir = designDir;
        formal.modeDir = modeDir;
        formal.outMd = outMd;
        formal.outTxt = outTxt;
        formal.outMat = outMat;
        formal.diaryFile = diaryFile;

        disp('=== GUARDED_FORMAL_GA_v93g ===')
        disp(formal.status)
        disp('=== DIAGNOSIS ===')
        disp(formal.diagnosis)
        disp('=== EXECUTION STATUS ===')
        disp(formal.executionStatus)
        disp('=== CONFIRM EXECUTE ===')
        disp(formal.confirm_execute)
        disp('=== PREFLIGHT FLAGS ===')
        disp(formal.preflightFlags)
        disp('=== SUMMARY ===')
        disp(formal.Tsummary)
        disp('=== OUTPUT FILES ===')
        disp(formal.outMd)
        disp(formal.outTxt)
        disp(formal.outMat)
        disp(formal.diaryFile)
    end

end

% =========================================================================
% Funciones locales auxiliares
% =========================================================================

function F = local_objective_wrapper_v93g(x, mode)
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

function [f, detail, status, errMsg] = local_eval_guarded_objective_v93g(x, mode)
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

function row = local_detail_to_row_v93g(mode, x, f, detail, status, errMsg)

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

    row.detail_status = local_get_string_v93g(detail, {'status','detail_status','execution_status'}, "UNKNOWN");

    row.Q_aux_tot = local_get_numeric_v93g(detail, {'outputs.Q_aux_tot','Q_aux_tot','outputs.Q_aux'}, NaN);
    row.Irradiacion = local_get_numeric_v93g(detail, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.dry_time = local_get_numeric_v93g(detail, {'outputs.dry_time','dry_time'}, NaN);
    row.M = local_get_numeric_v93g(detail, {'outputs.M','M'}, NaN);
    row.MR = local_get_numeric_v93g(detail, {'outputs.MR','MR'}, NaN);

    row.cost_specific = local_get_numeric_v93g(detail, {'cost.cost_specific_USD_per_kgwater','cost_specific_USD_per_kgwater'}, NaN);
    row.total_cost = local_get_numeric_v93g(detail, {'cost.total_cost_USD','total_cost_USD'}, NaN);

    row.execution_message = local_get_string_v93g(detail, {'execution.message','message'}, "");

end

function val = local_get_numeric_v93g(S, paths, defaultVal)
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

function val = local_get_string_v93g(S, paths, defaultVal)
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

function initPop = local_make_initial_population_v93g(x0, lb, ub, n)
    nvars = numel(x0);
    initPop = zeros(n,nvars);

    initPop(1,:) = x0;

    for i = 2:n
        alpha = rand(1,nvars);
        initPop(i,:) = lb + alpha .* (ub - lb);
    end

    initPop = min(max(initPop, lb), ub);
end