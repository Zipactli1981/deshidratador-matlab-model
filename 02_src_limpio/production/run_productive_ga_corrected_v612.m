function runinfo = run_productive_ga_corrected_v612()
%RUN_PRODUCTIVE_GA_CORRECTED_V612 Productive GA dry-run integration.
%
% Micropaso 6.12 — PRODUCTIVE-GA-DRYRUN-INTEGRATION-001
%
% Scope:
%   - Integrate objective_productive_corrected_v611.m into productive GA script.
%   - Verify objective availability.
%   - Evaluate one controlled objective point.
%   - Keep gamultiobj blocked.
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
        error(['PRODUCTIVE-GA-DRYRUN-INTEGRATION-001 blocks GA execution. ', ...
               'Do not execute gamultiobj in Micropaso 6.12.']);
    end

    %% Load productive configuration
    cfg = productive_run_config_v69();

    logDir  = fullfile(rootDir,'06_outputs','logs');
    tabDir  = fullfile(rootDir,'06_outputs','tables');
    compDir = fullfile(rootDir,'06_outputs','comparisons');
    runDir  = fullfile(rootDir,'05_runs','productive_v612');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(compDir,'dir'), mkdir(compDir); end
    if ~exist(runDir,'dir'), mkdir(runDir); end

    %% Official objective
    objective_file = fullfile(rootDir, ...
        '02_src_limpio','production','objective_productive_corrected_v611.m');

    objective_function_name = 'objective_productive_corrected_v611';

    objective_available = isfile(objective_file) && ...
        exist(objective_function_name,'file') == 2;

    %% Controlled objective probe
    x_probe = [0.11 55 0.5 3];
    mode_probe = 'hybrid';

    if objective_available
        [f_probe, detail_probe] = objective_productive_corrected_v611(x_probe, mode_probe);
    else
        f_probe = [NaN NaN];
        detail_probe = struct();
        detail_probe.status = 'OBJECTIVE_NOT_AVAILABLE';
    end

    %% Objective probe checks
    objective_size_ok = isnumeric(f_probe) && numel(f_probe) == 2;
    objective_finite_ok = all(isfinite(f_probe));
    objective_positive_cost_ok = objective_size_ok && f_probe(2) > 0;

    if isfield(detail_probe,'status')
        detail_status_ok = strcmp(detail_probe.status,'OK');
    else
        detail_status_ok = false;
    end

    if isfield(detail_probe,'irradiance')
        mode_rule_ok = contains(char(detail_probe.irradiance.rule),'hybrid');
    else
        mode_rule_ok = false;
    end

    if isfield(detail_probe,'auxiliary')
        aux_rule_ok = contains(char(detail_probe.auxiliary.rule),'hybrid') && ...
                      contains(char(detail_probe.auxiliary.rule),'true');
    else
        aux_rule_ok = false;
    end

    %% Availability checks
    gamultiobj_available = exist('gamultiobj','file') == 2;
    ga_history_available = isfile(cfg.ga_history_output_function);
    wrapper_available = isfile(cfg.active_wrapper);
    cost_params_available = isfile(cfg.cost_params_file);
    cost_breakdown_available = isfile(cfg.cost_breakdown_file);

    check_item = {
        'gamultiobj_available'
        'ga_history_output_function'
        'active_corrected_wrapper'
        'cost_params_file'
        'cost_breakdown_file'
        'objective_file_available'
        'objective_function_available'
        'objective_size_ok'
        'objective_finite_ok'
        'objective_positive_cost_ok'
        'objective_detail_status_ok'
        'objective_mode_rule_ok'
        'objective_aux_rule_ok'
        'execution_guard_false'
    };

    check_value = [
        gamultiobj_available
        ga_history_available
        wrapper_available
        cost_params_available
        cost_breakdown_available
        isfile(objective_file)
        objective_available
        objective_size_ok
        objective_finite_ok
        objective_positive_cost_ok
        detail_status_ok
        mode_rule_ok
        aux_rule_ok
        ~EXECUTE_GA
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

    %% GA dry-run declaration
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
        'ObjectiveProbeX'
        'ObjectiveProbeMode'
        'Execution'
    };

    option_value = {
        cfg.ga.algorithm
        num2str(cfg.ga.population_size)
        num2str(cfg.ga.generations)
        num2str(cfg.ga.seed_recommended)
        '4'
        mat2str(cfg.decision_variables.lower_bounds)
        mat2str(cfg.decision_variables.upper_bounds)
        'ga_history_output_controlado'
        objective_function_name
        mat2str(x_probe)
        mode_probe
        'DRY_RUN_ONLY_NO_GA'
    };

    T_options = table(option_item, option_value, ...
        'VariableNames', {'item','value'});

    %% Objective probe table
    T_probe = table( ...
        {mode_probe}, ...
        x_probe(1), x_probe(2), x_probe(3), x_probe(4), ...
        f_probe(1), f_probe(2), ...
        {detail_probe.status}, ...
        'VariableNames', { ...
            'mode_operation', ...
            'm_max','T_min','r_div2','t_rec_ini', ...
            'objective_MR','objective_cost_USD_per_kgwater', ...
            'detail_status'} );

    if isfield(detail_probe,'outputs')
        T_probe.Q_aux_tot = detail_probe.outputs.Q_aux_tot;
        T_probe.Irradiacion = detail_probe.outputs.Irradiacion;
        T_probe.dry_time = detail_probe.outputs.dry_time;
        T_probe.M = detail_probe.outputs.M;
        T_probe.MR = detail_probe.outputs.MR;
    end

    if isfield(detail_probe,'irradiance')
        T_probe.irradiance_rule = {char(detail_probe.irradiance.rule)};
    end

    if isfield(detail_probe,'auxiliary')
        T_probe.aux_rule = {char(detail_probe.auxiliary.rule)};
    end

    %% Mandatory future output files
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
        fullfile(runDir,'GA_HISTORY_CORRECTED_v612_REQUIRED.mat')
        fullfile(runDir,'GA_FINAL_POPULATION_CORRECTED_v612_REQUIRED.csv')
        fullfile(runDir,'GA_FINAL_SCORES_CORRECTED_v612_REQUIRED.csv')
        fullfile(runDir,'PARETO_CORRECTED_v612_REQUIRED.csv')
        fullfile(runDir,'SELECTED_SOLUTION_CORRECTED_v612_REQUIRED.csv')
        fullfile(runDir,'MODE_COMPARISON_CORRECTED_v612_REQUIRED.csv')
        fullfile(runDir,'FIG20_SOURCE_CORRECTED_v612_REQUIRED.csv')
        fullfile(runDir,'FIG21_SOURCE_CORRECTED_v612_REQUIRED.csv')
        fullfile(runDir,'PRODUCTIVE_GA_RUN_CORRECTED_v612_REQUIRED.txt')
    };

    output_status = repmat({'DECLARED_NOT_GENERATED'},numel(output_item),1);

    T_outputs = table(output_item, output_path, output_status, ...
        'VariableNames', {'item','path','status'});

    %% Final status
    checks_ok = all(strcmp(T_checks.status,'PASS'));

    runinfo = struct();
    runinfo.created_at = datetime('now');
    runinfo.created_by_function = 'run_productive_ga_corrected_v612';
    runinfo.version_base = cfg.version_base;
    runinfo.productive_run_id = ['PRODUCTIVE_GA_CORRECTED_DRYRUN_' datestr(now,'yyyymmdd_HHMMSS')];

    runinfo.execute_ga = EXECUTE_GA;
    runinfo.execution_status = 'NOT_EXECUTED';
    runinfo.objective_function = objective_function_name;
    runinfo.objective_file = objective_file;
    runinfo.x_probe = x_probe;
    runinfo.mode_probe = mode_probe;
    runinfo.f_probe = f_probe;
    runinfo.detail_probe = detail_probe;

    if checks_ok
        runinfo.status = 'PRODUCTIVE_GA_DRYRUN_INTEGRATION_READY_NO_GA';
    else
        runinfo.status = 'PRODUCTIVE_GA_DRYRUN_INTEGRATION_NOT_READY';
    end

    %% Write evidence
    txtFile = fullfile(logDir,'PRODUCTIVE_GA_DRYRUN_INTEGRATION_v612.txt');
    csvChecks = fullfile(tabDir,'PRODUCTIVE_GA_DRYRUN_CHECKS_v612.csv');
    csvOptions = fullfile(tabDir,'PRODUCTIVE_GA_DRYRUN_OPTIONS_v612.csv');
    csvProbe = fullfile(tabDir,'PRODUCTIVE_GA_DRYRUN_OBJECTIVE_PROBE_v612.csv');
    csvOutputs = fullfile(tabDir,'PRODUCTIVE_GA_DRYRUN_OUTPUTS_v612.csv');
    matFile = fullfile(compDir,'PRODUCTIVE_GA_DRYRUN_INTEGRATION_v612.mat');

    writetable(T_checks,csvChecks);
    writetable(T_options,csvOptions);
    writetable(T_probe,csvProbe);
    writetable(T_outputs,csvOutputs);

    runinfo.txtFile = txtFile;
    runinfo.csvChecks = csvChecks;
    runinfo.csvOptions = csvOptions;
    runinfo.csvProbe = csvProbe;
    runinfo.csvOutputs = csvOutputs;
    runinfo.matFile = matFile;

    save(matFile,'runinfo','cfg','T_checks','T_options','T_probe','T_outputs');

    fid = fopen(txtFile,'w');

    fprintf(fid,'PRODUCTIVE_GA_DRYRUN_INTEGRATION_v612\n\n');
    fprintf(fid,'status: %s\n',runinfo.status);
    fprintf(fid,'execution_status: %s\n',runinfo.execution_status);
    fprintf(fid,'execute_ga: %d\n\n',runinfo.execute_ga);

    fprintf(fid,'Scope:\n');
    fprintf(fid,'Dry-run integration only.\n');
    fprintf(fid,'gamultiobj not executed.\n');
    fprintf(fid,'Objective function evaluated once at controlled point.\n');
    fprintf(fid,'Fig. 20 not recalculated.\n');
    fprintf(fid,'Fig. 21 not recalculated.\n\n');

    fprintf(fid,'Objective function:\n%s\n\n',objective_function_name);
    fprintf(fid,'Objective file:\n%s\n\n',objective_file);

    fprintf(fid,'Objective probe:\n');
    fprintf(fid,'mode: %s\n',mode_probe);
    fprintf(fid,'x_probe: %s\n',mat2str(x_probe));
    fprintf(fid,'f_probe(1) MR = %.12g\n',f_probe(1));
    fprintf(fid,'f_probe(2) cost = %.12g\n\n',f_probe(2));

    if isfield(detail_probe,'irradiance')
        fprintf(fid,'irradiance_rule: %s\n',char(detail_probe.irradiance.rule));
    end

    if isfield(detail_probe,'auxiliary')
        fprintf(fid,'aux_rule: %s\n',char(detail_probe.auxiliary.rule));
    end

    fprintf(fid,'\nGA declaration:\n');
    fprintf(fid,'algorithm: %s\n',cfg.ga.algorithm);
    fprintf(fid,'population_size: %d\n',cfg.ga.population_size);
    fprintf(fid,'generations: %d\n',cfg.ga.generations);
    fprintf(fid,'seed: %d\n',cfg.ga.seed_recommended);
    fprintf(fid,'lower_bounds: %s\n',mat2str(cfg.decision_variables.lower_bounds));
    fprintf(fid,'upper_bounds: %s\n\n',mat2str(cfg.decision_variables.upper_bounds));

    fprintf(fid,'Mandatory future outputs:\n');
    for k = 1:height(T_outputs)
        fprintf(fid,'- %s | %s | %s\n', ...
            T_outputs.item{k}, T_outputs.status{k}, T_outputs.path{k});
    end

    fprintf(fid,'\nTraceability rule:\n');
    fprintf(fid,'Do not mix historical GA outputs with corrected productive outputs.\n');
    fprintf(fid,'Do not use historical Fig. 20 or Fig. 21 as final.\n');

    fclose(fid);

    disp('=== PRODUCTIVE_GA_DRYRUN_INTEGRATION_v612 ===')
    disp(runinfo.status)

    disp('=== CHECKS ===')
    disp(T_checks)

    disp('=== OBJECTIVE PROBE ===')
    disp(T_probe)

    disp('=== GA OPTIONS DECLARED ===')
    disp(T_options)

    disp('=== OUTPUTS DECLARED ===')
    disp(T_outputs)
end