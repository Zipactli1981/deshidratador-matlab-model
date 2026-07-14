function runinfo = run_productive_ga_corrected_v610()
%RUN_PRODUCTIVE_GA_CORRECTED_V610 Official productive GA script scaffold.
%
% Micropaso 6.10 — PRODUCTIVE-GA-SCRIPT-001
%
% Scope:
%   - Define the official corrected GA entry point.
%   - Bind productive configuration v69.
%   - Declare GA options and mandatory outputs.
%   - Prevent accidental execution of gamultiobj.
%
% This function does not execute gamultiobj.
% This function does not generate final article results.
% This function does not recalculate Fig. 20 or Fig. 21.

    rootDir = setup_v05_paths();

    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    %% Hard execution guard
    EXECUTE_GA = false;

    if EXECUTE_GA
        error(['PRODUCTIVE-GA-SCRIPT-001 is a dry-run scaffold only. ', ...
               'Do not execute gamultiobj in Micropaso 6.10.']);
    end

    %% Required configuration
    cfg = productive_run_config_v69();

    logDir  = fullfile(rootDir,'06_outputs','logs');
    tabDir  = fullfile(rootDir,'06_outputs','tables');
    compDir = fullfile(rootDir,'06_outputs','comparisons');
    runDir  = fullfile(rootDir,'05_runs','productive_v610');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(compDir,'dir'), mkdir(compDir); end
    if ~exist(runDir,'dir'), mkdir(runDir); end

    %% Official productive identity
    runinfo = struct();
    runinfo.created_at = datetime('now');
    runinfo.created_by_function = 'run_productive_ga_corrected_v610';
    runinfo.status = 'PRODUCTIVE_GA_SCRIPT_READY_DRY_RUN_NO_GA';

    runinfo.version_base = cfg.version_base;
    runinfo.productive_run_id = ['PRODUCTIVE_GA_CORRECTED_' datestr(now,'yyyymmdd_HHMMSS')];

    runinfo.execute_ga = EXECUTE_GA;
    runinfo.execution_status = 'NOT_EXECUTED';
    runinfo.reason_not_executed = 'Micropaso 6.10 defines script only; GA execution is blocked.';

    %% Official active files
    runinfo.active_wrapper = cfg.active_wrapper;
    runinfo.cost_params_file = cfg.cost_params_file;
    runinfo.cost_breakdown_file = cfg.cost_breakdown_file;
    runinfo.ga_history_output_function = cfg.ga_history_output_function;

    %% GA declaration
    runinfo.ga.algorithm = 'gamultiobj';
    runinfo.ga.population_size = cfg.ga.population_size;
    runinfo.ga.generations = cfg.ga.generations;
    runinfo.ga.seed = cfg.ga.seed_recommended;
    runinfo.ga.nvars = 4;
    runinfo.ga.lower_bounds = cfg.decision_variables.lower_bounds;
    runinfo.ga.upper_bounds = cfg.decision_variables.upper_bounds;

    runinfo.ga.decision_variables = cfg.decision_variables.names;
    runinfo.ga.objective_function_required = 'objective_productive_corrected_v611.m';
    runinfo.ga.objective_function_status = 'DECLARED_NOT_IMPLEMENTED_IN_v610';

    %% Mandatory future output files
    runinfo.outputs.runDir = runDir;

    runinfo.outputs.ga_history_mat = fullfile(runDir,'GA_HISTORY_CORRECTED_v610_REQUIRED.mat');
    runinfo.outputs.final_population_csv = fullfile(runDir,'GA_FINAL_POPULATION_CORRECTED_v610_REQUIRED.csv');
    runinfo.outputs.final_scores_csv = fullfile(runDir,'GA_FINAL_SCORES_CORRECTED_v610_REQUIRED.csv');
    runinfo.outputs.pareto_csv = fullfile(runDir,'PARETO_CORRECTED_v610_REQUIRED.csv');
    runinfo.outputs.selected_solution_csv = fullfile(runDir,'SELECTED_SOLUTION_CORRECTED_v610_REQUIRED.csv');
    runinfo.outputs.mode_comparison_csv = fullfile(runDir,'MODE_COMPARISON_CORRECTED_v610_REQUIRED.csv');
    runinfo.outputs.fig20_source_csv = fullfile(runDir,'FIG20_SOURCE_CORRECTED_v610_REQUIRED.csv');
    runinfo.outputs.fig21_source_csv = fullfile(runDir,'FIG21_SOURCE_CORRECTED_v610_REQUIRED.csv');
    runinfo.outputs.run_log = fullfile(runDir,'PRODUCTIVE_GA_RUN_CORRECTED_v610_REQUIRED.txt');

    %% Check MATLAB function availability
    gamultiobj_available = exist('gamultiobj','file') == 2;
    ga_history_available = isfile(runinfo.ga_history_output_function);
    wrapper_available = isfile(runinfo.active_wrapper);
    cost_params_available = isfile(runinfo.cost_params_file);
    cost_breakdown_available = isfile(runinfo.cost_breakdown_file);

    check_item = {
        'gamultiobj_available'
        'ga_history_output_function'
        'active_corrected_wrapper'
        'cost_params_file'
        'cost_breakdown_file'
        'execution_guard_false'
        'objective_function_declared_for_next_step'
    };

    check_value = [
        gamultiobj_available
        ga_history_available
        wrapper_available
        cost_params_available
        cost_breakdown_available
        ~EXECUTE_GA
        true
    ];

    check_status = cell(numel(check_item),1);

    for k = 1:numel(check_item)
        if check_value(k)
            check_status{k} = 'PASS';
        else
            check_status{k} = 'FAIL';
        end
    end

    T_checks = table(check_item, check_value, check_status, ...
        'VariableNames', {'item','value','status'});

    %% Planned GA options table
    option_item = {
        'Algorithm'
        'PopulationSize'
        'MaxGenerations'
        'Seed'
        'NumberOfVariables'
        'LowerBounds'
        'UpperBounds'
        'OutputFcn'
        'ObjectiveFunction'
        'Execution'
    };

    option_value = {
        runinfo.ga.algorithm
        num2str(runinfo.ga.population_size)
        num2str(runinfo.ga.generations)
        num2str(runinfo.ga.seed)
        num2str(runinfo.ga.nvars)
        mat2str(runinfo.ga.lower_bounds)
        mat2str(runinfo.ga.upper_bounds)
        'ga_history_output_controlado'
        runinfo.ga.objective_function_required
        'DRY_RUN_ONLY_NO_GA'
    };

    T_options = table(option_item, option_value, ...
        'VariableNames', {'item','value'});

    %% Mandatory outputs table
    output_item = {
        'ga_history_mat'
        'final_population_csv'
        'final_scores_csv'
        'pareto_csv'
        'selected_solution_csv'
        'mode_comparison_csv'
        'fig20_source_csv'
        'fig21_source_csv'
        'run_log'
    };

    output_path = {
        runinfo.outputs.ga_history_mat
        runinfo.outputs.final_population_csv
        runinfo.outputs.final_scores_csv
        runinfo.outputs.pareto_csv
        runinfo.outputs.selected_solution_csv
        runinfo.outputs.mode_comparison_csv
        runinfo.outputs.fig20_source_csv
        runinfo.outputs.fig21_source_csv
        runinfo.outputs.run_log
    };

    output_status = repmat({'DECLARED_NOT_GENERATED'},numel(output_item),1);

    T_outputs = table(output_item, output_path, output_status, ...
        'VariableNames', {'item','path','status'});

    %% Final script readiness
    checks_ok = all(strcmp(T_checks.status,'PASS'));

    if checks_ok
        runinfo.status = 'PRODUCTIVE_GA_SCRIPT_READY_DRY_RUN_NO_GA';
    else
        runinfo.status = 'PRODUCTIVE_GA_SCRIPT_NOT_READY';
    end

    %% Write evidence
    txtFile = fullfile(logDir,'PRODUCTIVE_GA_SCRIPT_v610.txt');
    csvChecks = fullfile(tabDir,'PRODUCTIVE_GA_SCRIPT_CHECKS_v610.csv');
    csvOptions = fullfile(tabDir,'PRODUCTIVE_GA_SCRIPT_OPTIONS_v610.csv');
    csvOutputs = fullfile(tabDir,'PRODUCTIVE_GA_SCRIPT_OUTPUTS_v610.csv');
    matFile = fullfile(compDir,'PRODUCTIVE_GA_SCRIPT_v610.mat');

    writetable(T_checks,csvChecks);
    writetable(T_options,csvOptions);
    writetable(T_outputs,csvOutputs);

    runinfo.txtFile = txtFile;
    runinfo.csvChecks = csvChecks;
    runinfo.csvOptions = csvOptions;
    runinfo.csvOutputs = csvOutputs;
    runinfo.matFile = matFile;

    save(matFile,'runinfo','cfg','T_checks','T_options','T_outputs');

    fid = fopen(txtFile,'w');

    fprintf(fid,'PRODUCTIVE_GA_SCRIPT_v610\n\n');
    fprintf(fid,'status: %s\n',runinfo.status);
    fprintf(fid,'execution_status: %s\n',runinfo.execution_status);
    fprintf(fid,'execute_ga: %d\n\n',runinfo.execute_ga);

    fprintf(fid,'Scope:\n');
    fprintf(fid,'Official productive GA script scaffold only.\n');
    fprintf(fid,'gamultiobj not executed.\n');
    fprintf(fid,'Objective function not executed.\n');
    fprintf(fid,'Fig. 20 not recalculated.\n');
    fprintf(fid,'Fig. 21 not recalculated.\n\n');

    fprintf(fid,'Active corrected wrapper:\n%s\n\n',runinfo.active_wrapper);

    fprintf(fid,'Corrected mode rules:\n');
    fprintf(fid,'gasLP  -> I_effective = 0,      calor_aux = true\n');
    fprintf(fid,'hybrid -> I_effective = I_busc, calor_aux = true\n');
    fprintf(fid,'solar  -> I_effective = I_busc, calor_aux = false\n\n');

    fprintf(fid,'GA declaration:\n');
    fprintf(fid,'algorithm: %s\n',runinfo.ga.algorithm);
    fprintf(fid,'population_size: %d\n',runinfo.ga.population_size);
    fprintf(fid,'generations: %d\n',runinfo.ga.generations);
    fprintf(fid,'seed: %d\n',runinfo.ga.seed);
    fprintf(fid,'nvars: %d\n',runinfo.ga.nvars);
    fprintf(fid,'lower_bounds: %s\n',mat2str(runinfo.ga.lower_bounds));
    fprintf(fid,'upper_bounds: %s\n\n',mat2str(runinfo.ga.upper_bounds));

    fprintf(fid,'Objective function status:\n');
    fprintf(fid,'%s: %s\n\n', ...
        runinfo.ga.objective_function_required, ...
        runinfo.ga.objective_function_status);

    fprintf(fid,'Mandatory future outputs:\n');
    for k = 1:height(T_outputs)
        fprintf(fid,'- %s | %s | %s\n', ...
            T_outputs.item{k}, T_outputs.status{k}, T_outputs.path{k});
    end

    fprintf(fid,'\nTraceability rule:\n');
    fprintf(fid,'Do not mix historical GA outputs with corrected productive outputs.\n');
    fprintf(fid,'Do not use historical Fig. 20 or Fig. 21 as final.\n');
    fprintf(fid,'All productive outputs must contain CORRECTED and timestamped run identity.\n');

    fclose(fid);

    disp('=== PRODUCTIVE_GA_SCRIPT_v610 ===')
    disp(runinfo.status)

    disp('=== CHECKS ===')
    disp(T_checks)

    disp('=== GA OPTIONS DECLARED ===')
    disp(T_options)

    disp('=== OUTPUTS DECLARED ===')
    disp(T_outputs)
end