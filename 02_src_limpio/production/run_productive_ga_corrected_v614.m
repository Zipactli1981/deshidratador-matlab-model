function runinfo = run_productive_ga_corrected_v614(EXECUTE_GA)
%RUN_PRODUCTIVE_GA_CORRECTED_V614 Productive corrected GA execution script.
%
% Micropaso 6.15 — PRODUCTIVE-GA-EXECUTION-SCRIPT-v614
%
% Scope:
%   - Creates the first executable productive GA script after dry-run v612.
%   - Does not modify v612.
%   - Uses objective_productive_corrected_v611.m.
%   - Uses capture_productive_ga_outputs_v614b.m.
%   - Captures final population, final scores, Pareto, selected solution,
%     mode comparison, Fig. 20 source, Fig. 21 source, run log and MAT files.
%
% Safety:
%   - By default EXECUTE_GA = false.
%   - GA only runs when this function is called as:
%       run_productive_ga_corrected_v614(true)
%
% This script is the execution bridge. It should be validated first in
% non-execution mode.

    if nargin < 1
        EXECUTE_GA = false;
    end

    rootDir = setup_v05_paths();

    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    runinfo = struct();
    runinfo.created_at = datetime('now');
    runinfo.created_by_function = 'run_productive_ga_corrected_v614';
    runinfo.version = 'v614';
    runinfo.execute_ga = EXECUTE_GA;
    runinfo.rootDir = rootDir;

    %% Configuration
    cfg = productive_run_config_v69();

    run_id = ['PRODUCTIVE_GA_CORRECTED_v614_' datestr(now,'yyyymmdd_HHMMSS')];

    runinfo.run_id = run_id;
    runinfo.cfg = cfg;

    %% Required files
    files_required = struct();

    files_required.objective = fullfile(rootDir, ...
        '02_src_limpio','production','objective_productive_corrected_v611.m');

    files_required.capture = fullfile(rootDir, ...
        '02_src_limpio','production','capture_productive_ga_outputs_v614b.m');

    files_required.active_wrapper = fullfile(rootDir, ...
        '02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');

    files_required.cost_params = fullfile(rootDir, ...
        '02_src_limpio','cost','build_cost_params_historical.m');

    files_required.cost_breakdown = fullfile(rootDir, ...
        '02_src_limpio','cost','calc_cost_breakdown.m');

    required_names = fieldnames(files_required);
    required_exists = false(numel(required_names),1);
    required_status = cell(numel(required_names),1);
    required_path = cell(numel(required_names),1);

    for k = 1:numel(required_names)
        required_path{k} = files_required.(required_names{k});
        required_exists(k) = isfile(required_path{k});

        if required_exists(k)
            required_status{k} = 'PASS';
        else
            required_status{k} = 'FAIL';
        end
    end

    T_required_files = table(required_names,required_path,required_exists,required_status, ...
        'VariableNames', {'item','path','exists','status'});

    files_ok = all(strcmp(T_required_files.status,'PASS'));

    %% Function availability
    objective_available = exist('objective_productive_corrected_v611','file') == 2;
    capture_available = exist('capture_productive_ga_outputs_v614b','file') == 2;
    gamultiobj_available = exist('gamultiobj','file') == 2;

    %% GA settings
    numberOfVariables = 4;

    lb = [0.07 45 0.00 0];
    ub = [0.20 70 0.99 19];

    population_size = 50;
    generations = 20;
    seed = 6901;

    runinfo.numberOfVariables = numberOfVariables;
    runinfo.lb = lb;
    runinfo.ub = ub;
    runinfo.population_size = population_size;
    runinfo.generations = generations;
    runinfo.seed = seed;

    %% Objective probe before allowing real GA
    x_probe = [0.11 55 0.50 3];

    [f_probe, detail_probe] = objective_productive_corrected_v611(x_probe,'hybrid');

    objective_probe_ok = isnumeric(f_probe) && numel(f_probe) == 2 && ...
                         all(isfinite(f_probe)) && ...
                         isfield(detail_probe,'status') && ...
                         strcmp(detail_probe.status,'OK');

    runinfo.x_probe = x_probe;
    runinfo.f_probe = f_probe;
    runinfo.detail_probe = detail_probe;

    %% Preflight checks
    check_item = {
        'files_required_ok'
        'objective_function_available'
        'capture_function_available'
        'gamultiobj_available'
        'objective_probe_ok'
    };

    check_value = [
        files_ok
        objective_available
        capture_available
        gamultiobj_available
        objective_probe_ok
    ];

    check_status = cell(numel(check_item),1);

    for k = 1:numel(check_item)
        if check_value(k)
            check_status{k} = 'PASS';
        else
            check_status{k} = 'FAIL';
        end
    end

    T_checks = table(check_item,check_value,check_status, ...
        'VariableNames', {'item','value','status'});

    preflight_ok = all(strcmp(T_checks.status,'PASS'));

    runinfo.T_required_files = T_required_files;
    runinfo.T_checks = T_checks;
    runinfo.preflight_ok = preflight_ok;

    %% Output directories for v614 preflight
    logDir = fullfile(rootDir,'06_outputs','logs');
    tabDir = fullfile(rootDir,'06_outputs','tables');
    compDir = fullfile(rootDir,'06_outputs','comparisons');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(compDir,'dir'), mkdir(compDir); end

    txtFile = fullfile(logDir,'PRODUCTIVE_GA_EXECUTION_SCRIPT_v614.txt');
    csvChecks = fullfile(tabDir,'PRODUCTIVE_GA_EXECUTION_SCRIPT_CHECKS_v614.csv');
    csvRequiredFiles = fullfile(tabDir,'PRODUCTIVE_GA_EXECUTION_SCRIPT_REQUIRED_FILES_v614.csv');
    matFile = fullfile(compDir,'PRODUCTIVE_GA_EXECUTION_SCRIPT_v614.mat');

    runinfo.txtFile = txtFile;
    runinfo.csvChecks = csvChecks;
    runinfo.csvRequiredFiles = csvRequiredFiles;
    runinfo.matFile = matFile;

    writetable(T_checks,csvChecks);
    writetable(T_required_files,csvRequiredFiles);

    %% Dry-run branch
    if ~EXECUTE_GA
        runinfo.status = 'PRODUCTIVE_GA_EXECUTION_SCRIPT_READY_NO_GA';
        runinfo.execution_status = 'NOT_EXECUTED';
        runinfo.capture_status = 'NOT_APPLICABLE_NO_GA';

        fid = fopen(txtFile,'w');

        fprintf(fid,'PRODUCTIVE_GA_EXECUTION_SCRIPT_v614\n\n');
        fprintf(fid,'status: %s\n',runinfo.status);
        fprintf(fid,'execution_status: %s\n',runinfo.execution_status);
        fprintf(fid,'execute_ga: %d\n\n',runinfo.execute_ga);

        fprintf(fid,'Scope:\n');
        fprintf(fid,'Execution script created and preflighted.\n');
        fprintf(fid,'GA not executed because EXECUTE_GA = false.\n');
        fprintf(fid,'v612 remains unmodified.\n\n');

        fprintf(fid,'Activation:\n');
        fprintf(fid,'To execute real productive GA later, call:\n');
        fprintf(fid,'runinfo = run_productive_ga_corrected_v614(true);\n\n');

        fprintf(fid,'GA settings declared:\n');
        fprintf(fid,'numberOfVariables: %d\n',numberOfVariables);
        fprintf(fid,'population_size: %d\n',population_size);
        fprintf(fid,'generations: %d\n',generations);
        fprintf(fid,'seed: %d\n',seed);
        fprintf(fid,'lb: %s\n',mat2str(lb));
        fprintf(fid,'ub: %s\n\n',mat2str(ub));

        fprintf(fid,'Objective probe:\n');
        fprintf(fid,'x_probe: %s\n',mat2str(x_probe));
        fprintf(fid,'f_probe: %s\n',mat2str(f_probe));
        fprintf(fid,'detail_status: %s\n\n',detail_probe.status);

        fprintf(fid,'Preflight status:\n');
        for k = 1:height(T_checks)
            fprintf(fid,'- %s: %s\n',T_checks.item{k},T_checks.status{k});
        end

        fprintf(fid,'\nTraceability:\n');
        fprintf(fid,'This is not a productive result.\n');
        fprintf(fid,'No GA outputs were generated.\n');
        fprintf(fid,'No Fig. 20 or Fig. 21 source was generated from real GA.\n');

        fclose(fid);

        save(matFile,'runinfo','cfg','T_checks','T_required_files');

        disp('=== PRODUCTIVE_GA_EXECUTION_SCRIPT_v614 ===')
        disp(runinfo.status)

        disp('=== CHECKS ===')
        disp(T_checks)

        disp('=== REQUIRED FILES ===')
        disp(T_required_files)

        disp('=== OBJECTIVE PROBE ===')
        disp(f_probe)

        return
    end

    %% Real execution branch
    if ~preflight_ok
        runinfo.status = 'PRODUCTIVE_GA_EXECUTION_BLOCKED_PREFLIGHT_FAIL';
        runinfo.execution_status = 'NOT_EXECUTED';
        save(matFile,'runinfo','cfg','T_checks','T_required_files');
        error('run_productive_ga_corrected_v614:preflightFail', ...
            'Preflight checks failed. GA execution blocked.');
    end

    rng(seed,'twister');

    ga_history = struct();
    ga_history.created_by = 'run_productive_ga_corrected_v614.local_history_output';
    ga_history.note = 'Captured during corrected productive GA v614.';
    ga_history.generation = [];
    ga_history.min_MR = [];
    ga_history.min_cost = [];
    ga_history.feasible_MR_le_0p1_count = [];
    ga_history.population_size = [];
    ga_history.timestamp = {};

    objective_handle = @(x) objective_productive_corrected_v611(x,'hybrid');

    options = optimoptions('gamultiobj', ...
        'PopulationSize', population_size, ...
        'MaxGenerations', generations, ...
        'Display', 'iter', ...
        'OutputFcn', @local_history_output);

    fprintf('\n=== STARTING REAL PRODUCTIVE GA v614 ===\n')
    fprintf('run_id: %s\n',run_id)
    fprintf('This is the first corrected productive GA execution branch.\n\n')

    tic;
    [x,fval,exitflag,output,population,scores] = gamultiobj( ...
        objective_handle, numberOfVariables, [], [], [], [], lb, ub, options);
    elapsed_seconds = toc;

    %% Build mode comparison from selected solution
    T_pareto_tmp = [array2table(population, ...
        'VariableNames', {'m_max','T_min','r_div2','t_rec_ini'}), ...
        array2table(scores(:,1:2), ...
        'VariableNames', {'objective_MR','objective_cost_USD_per_kgwater'})];

    feasible_idx = find(T_pareto_tmp.objective_MR <= 0.1);

    if ~isempty(feasible_idx)
        [~,local_idx] = min(T_pareto_tmp.objective_cost_USD_per_kgwater(feasible_idx));
        selected_idx = feasible_idx(local_idx);
    else
        [~,selected_idx] = min(T_pareto_tmp.objective_MR);
    end

    x_selected = population(selected_idx,:);

    modes = {'gasLP'; 'hybrid'; 'solar'};
    m_max = zeros(3,1);
    T_min = zeros(3,1);
    r_div2 = zeros(3,1);
    t_rec_ini = zeros(3,1);

    objective_MR = zeros(3,1);
    objective_cost_USD_per_kgwater = zeros(3,1);
    Q_aux_tot = zeros(3,1);
    Irradiacion = zeros(3,1);
    dry_time = zeros(3,1);
    M = zeros(3,1);
    MR = zeros(3,1);
    detail_status = cell(3,1);
    irradiance_rule = cell(3,1);
    aux_rule = cell(3,1);

    for k = 1:numel(modes)
        [fk,dk] = objective_productive_corrected_v611(x_selected,modes{k});

        m_max(k) = x_selected(1);
        T_min(k) = x_selected(2);
        r_div2(k) = x_selected(3);
        t_rec_ini(k) = x_selected(4);

        objective_MR(k) = fk(1);
        objective_cost_USD_per_kgwater(k) = fk(2);

        if isfield(dk,'Q_aux_tot'), Q_aux_tot(k) = dk.Q_aux_tot; else, Q_aux_tot(k) = NaN; end
        if isfield(dk,'Irradiacion'), Irradiacion(k) = dk.Irradiacion; else, Irradiacion(k) = NaN; end
        if isfield(dk,'dry_time'), dry_time(k) = dk.dry_time; else, dry_time(k) = NaN; end
        if isfield(dk,'M'), M(k) = dk.M; else, M(k) = NaN; end
        if isfield(dk,'MR'), MR(k) = dk.MR; else, MR(k) = NaN; end

        if isfield(dk,'status'), detail_status{k} = dk.status; else, detail_status{k} = 'UNKNOWN'; end
        if isfield(dk,'irradiance_rule'), irradiance_rule{k} = dk.irradiance_rule; else, irradiance_rule{k} = 'UNKNOWN'; end
        if isfield(dk,'aux_rule'), aux_rule{k} = dk.aux_rule; else, aux_rule{k} = 'UNKNOWN'; end
    end

    T_mode = table(modes,m_max,T_min,r_div2,t_rec_ini, ...
        objective_MR,objective_cost_USD_per_kgwater, ...
        Q_aux_tot,Irradiacion,dry_time,M,MR, ...
        detail_status,irradiance_rule,aux_rule, ...
        'VariableNames', {'mode','m_max','T_min','r_div2','t_rec_ini', ...
        'objective_MR','objective_cost_USD_per_kgwater', ...
        'Q_aux_tot','Irradiacion','dry_time','M','MR', ...
        'detail_status','irradiance_rule','aux_rule'});

    %% Fig. 20 source from GA history
    generation = ga_history.generation(:);
    min_MR = ga_history.min_MR(:);
    min_cost_USD_per_kgwater = ga_history.min_cost(:);
    feasible_MR_le_0p1_count = ga_history.feasible_MR_le_0p1_count(:);
    population_size_history = ga_history.population_size(:);

    T_fig20 = table(generation,min_MR,min_cost_USD_per_kgwater, ...
        feasible_MR_le_0p1_count,population_size_history, ...
        'VariableNames', {'generation','min_MR','min_cost_USD_per_kgwater', ...
        'feasible_MR_le_0p1_count','population_size'});

    %% Fig. 21 source from final Pareto scores
    candidate_id = (1:size(scores,1))';
    m_max = population(:,1);
    T_min = population(:,2);
    r_div2 = population(:,3);
    t_rec_ini = population(:,4);
    objective_MR = scores(:,1);
    objective_cost_USD_per_kgwater = scores(:,2);

    T_fig21 = table(candidate_id,m_max,T_min,r_div2,t_rec_ini, ...
        objective_MR,objective_cost_USD_per_kgwater, ...
        'VariableNames', {'candidate_id','m_max','T_min','r_div2','t_rec_ini', ...
        'objective_MR','objective_cost_USD_per_kgwater'});

    %% Capture mandatory outputs
    runctx = struct();
    runctx.rootDir = rootDir;
    runctx.run_id = run_id;
    runctx.cfg = cfg;
    runctx.final_population = population;
    runctx.final_scores = scores;
    runctx.exitflag = exitflag;
    runctx.output = output;
    runctx.ga_history = ga_history;
    runctx.mode_comparison_table = T_mode;
    runctx.fig20_source_table = T_fig20;
    runctx.fig21_source_table = T_fig21;

    capture = capture_productive_ga_outputs_v614b(runctx);

    %% Final runinfo
    runinfo.status = 'PRODUCTIVE_GA_EXECUTION_COMPLETED';
    runinfo.execution_status = 'EXECUTED';
    runinfo.elapsed_seconds = elapsed_seconds;
    runinfo.exitflag = exitflag;
    runinfo.output = output;
    runinfo.x = x;
    runinfo.fval = fval;
    runinfo.population = population;
    runinfo.scores = scores;
    runinfo.ga_history = ga_history;
    runinfo.capture = capture;
    runinfo.x_selected = x_selected;
    runinfo.selected_idx = selected_idx;

    save(matFile,'runinfo','cfg','T_checks','T_required_files','capture');

    fid = fopen(txtFile,'w');

    fprintf(fid,'PRODUCTIVE_GA_EXECUTION_SCRIPT_v614\n\n');
    fprintf(fid,'status: %s\n',runinfo.status);
    fprintf(fid,'execution_status: %s\n',runinfo.execution_status);
    fprintf(fid,'run_id: %s\n',run_id);
    fprintf(fid,'elapsed_seconds: %.6f\n',elapsed_seconds);
    fprintf(fid,'exitflag: %s\n\n',mat2str(exitflag));

    fprintf(fid,'GA settings:\n');
    fprintf(fid,'numberOfVariables: %d\n',numberOfVariables);
    fprintf(fid,'population_size: %d\n',population_size);
    fprintf(fid,'generations: %d\n',generations);
    fprintf(fid,'seed: %d\n',seed);
    fprintf(fid,'lb: %s\n',mat2str(lb));
    fprintf(fid,'ub: %s\n\n',mat2str(ub));

    fprintf(fid,'Selected solution:\n');
    fprintf(fid,'selected_idx: %d\n',selected_idx);
    fprintf(fid,'x_selected: %s\n\n',mat2str(x_selected));

    fprintf(fid,'Capture:\n');
    fprintf(fid,'capture_status: %s\n',capture.status);
    fprintf(fid,'capture_outputs_ok: %d\n',capture.outputs_ok);
    fprintf(fid,'capture_runDir: %s\n\n',capture.runDir);

    fprintf(fid,'Traceability:\n');
    fprintf(fid,'This is a corrected productive GA execution branch.\n');
    fprintf(fid,'v612 was not modified.\n');
    fprintf(fid,'Outputs were captured by capture_productive_ga_outputs_v614b.m.\n');
    fprintf(fid,'Historical GA outputs must not be mixed with corrected v614 outputs.\n');

    fclose(fid);

    disp('=== PRODUCTIVE_GA_EXECUTION_SCRIPT_v614 ===')
    disp(runinfo.status)

    disp('=== CAPTURE STATUS ===')
    disp(capture.status)
    disp(capture.outputs_ok)

    disp('=== SELECTED SOLUTION X ===')
    disp(x_selected)

    disp('=== SELECTED MODE COMPARISON ===')
    disp(T_mode)

    %% Nested OutputFcn
    function [state,options,optchanged] = local_history_output(options,state,flag)
        optchanged = false;

        switch flag
            case {'init','iter','done'}
                if isfield(state,'Score') && ~isempty(state.Score)
                    score_now = state.Score;

                    if size(score_now,2) >= 2
                        ga_history.generation(end+1,1) = state.Generation;
                        ga_history.min_MR(end+1,1) = min(score_now(:,1));
                        ga_history.min_cost(end+1,1) = min(score_now(:,2));
                        ga_history.feasible_MR_le_0p1_count(end+1,1) = sum(score_now(:,1) <= 0.1);
                        ga_history.population_size(end+1,1) = size(score_now,1);
                        ga_history.timestamp{end+1,1} = datestr(now,'yyyy-mm-dd HH:MM:SS');
                    end
                end
        end
    end
end