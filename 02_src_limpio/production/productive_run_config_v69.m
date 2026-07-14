function cfg = productive_run_config_v69()
%PRODUCTIVE_RUN_CONFIG_V69 Configure productive corrected runs without execution.
%
% Micropaso 6.9 — PRODUCTIVE-RUN-CONFIG-001
%
% Scope:
%   - Define productive run configuration.
%   - Define active corrected wrapper.
%   - Define mandatory outputs.
%   - Define GA parameters and traceability rules.
%
% This function does not run GA.
% This function does not run model simulations.
% This function does not modify costs.
% This function does not declare final article results.

    rootDir = setup_v05_paths();

    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    logDir  = fullfile(rootDir,'06_outputs','logs');
    tabDir  = fullfile(rootDir,'06_outputs','tables');
    compDir = fullfile(rootDir,'06_outputs','comparisons');
    runDir  = fullfile(rootDir,'05_runs','productive_v69');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(compDir,'dir'), mkdir(compDir); end
    if ~exist(runDir,'dir'), mkdir(runDir); end

    %% Active source files
    active_wrapper = fullfile(rootDir, ...
        '02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');

    historical_wrapper = fullfile(rootDir, ...
        '02_src_limpio','wrappers','opt_tunel_mod2_v06_data_controlled.m');

    cost_params_file = fullfile(rootDir, ...
        '02_src_limpio','cost','build_cost_params_historical.m');

    cost_breakdown_file = fullfile(rootDir, ...
        '02_src_limpio','cost','calc_cost_breakdown.m');

    ga_history_file = fullfile(rootDir, ...
        '02_src_limpio','ga','ga_history_output_controlado.m');

    %% Productive identity
    cfg = struct();

    cfg.created_at = datetime('now');
    cfg.created_by_function = 'productive_run_config_v69';
    cfg.config_status = 'PRODUCTIVE_CONFIGURATION_READY_NO_EXECUTION';

    cfg.version_base = 'v1.3-HYBRID-IRR_COMPARE_CONSOLIDADA';
    cfg.productive_run_id = ['PRODUCTIVE_CORRECTED_' datestr(now,'yyyymmdd_HHMMSS')];

    cfg.active_wrapper = active_wrapper;
    cfg.historical_wrapper_preserved = historical_wrapper;
    cfg.cost_params_file = cost_params_file;
    cfg.cost_breakdown_file = cost_breakdown_file;
    cfg.ga_history_output_function = ga_history_file;

    %% Corrected productive mode rules
    cfg.mode_rules.gasLP.I_effective = '0';
    cfg.mode_rules.gasLP.calor_aux = 'true';

    cfg.mode_rules.hybrid.I_effective = 'I_busc';
    cfg.mode_rules.hybrid.calor_aux = 'true';

    cfg.mode_rules.solar.I_effective = 'I_busc';
    cfg.mode_rules.solar.calor_aux = 'false';

    %% Product and model constants used in diagnostic line
    cfg.product.m_i = 0.87;
    cfg.product.m_f = 0.08;
    cfg.product.m_des = 0.10;

    cfg.simulation.t_step_h = 0.1;
    cfg.simulation.t_max_h = 20;
    cfg.simulation.stop_rule = 'model internal stop / max horizon';
    cfg.simulation.drying_target = 'MR <= 0.1';

    %% Decision variables
    cfg.decision_variables.names = {'m_max','T_min','r_div2','t_rec_ini'};
    cfg.decision_variables.lower_bounds = [0.07 45 0.00 0];
    cfg.decision_variables.upper_bounds = [0.20 70 0.99 19];

    %% GA configuration — declared only, not executed
    cfg.ga.algorithm = 'gamultiobj';
    cfg.ga.population_size = 50;
    cfg.ga.generations = 20;
    cfg.ga.seed_policy = 'set rng before productive run';
    cfg.ga.seed_recommended = 6901;
    cfg.ga.parallel_policy = 'declare explicitly before run';
    cfg.ga.history_required = true;
    cfg.ga.final_population_required = true;
    cfg.ga.final_scores_required = true;
    cfg.ga.exitflag_required = true;
    cfg.ga.output_required = true;

    %% Mandatory productive outputs
    cfg.outputs.run_folder = runDir;

    cfg.outputs.log_file = fullfile(logDir, ...
        'PRODUCTIVE_RUN_CONFIG_v69.txt');

    cfg.outputs.config_csv = fullfile(tabDir, ...
        'PRODUCTIVE_RUN_CONFIG_v69.csv');

    cfg.outputs.outputs_contract_csv = fullfile(tabDir, ...
        'PRODUCTIVE_RUN_OUTPUT_CONTRACT_v69.csv');

    cfg.outputs.mat_file = fullfile(compDir, ...
        'PRODUCTIVE_RUN_CONFIG_v69.mat');

    cfg.outputs.future_ga_history_mat = fullfile(runDir, ...
        'GA_HISTORY_CORRECTED_REQUIRED.mat');

    cfg.outputs.future_ga_final_population_csv = fullfile(runDir, ...
        'GA_FINAL_POPULATION_CORRECTED_REQUIRED.csv');

    cfg.outputs.future_ga_final_scores_csv = fullfile(runDir, ...
        'GA_FINAL_SCORES_CORRECTED_REQUIRED.csv');

    cfg.outputs.future_pareto_csv = fullfile(runDir, ...
        'PARETO_CORRECTED_REQUIRED.csv');

    cfg.outputs.future_selected_solution_csv = fullfile(runDir, ...
        'SELECTED_SOLUTION_CORRECTED_REQUIRED.csv');

    cfg.outputs.future_mode_comparison_csv = fullfile(runDir, ...
        'MODE_COMPARISON_CORRECTED_REQUIRED.csv');

    cfg.outputs.future_fig20_source_csv = fullfile(runDir, ...
        'FIG20_SOURCE_CORRECTED_REQUIRED.csv');

    cfg.outputs.future_fig21_source_csv = fullfile(runDir, ...
        'FIG21_SOURCE_CORRECTED_REQUIRED.csv');

    %% Traceability rules
    cfg.traceability.do_not_reuse = {
        'historical Fig. 20'
        'historical Fig. 21'
        'historical hybrid GA results before HYBRID-IRR-001'
        'historical mode comparisons before MODE-ENERGY-001'
        'outputs without corrected wrapper name'
        'outputs without timestamp'
        'outputs without GA history'
        'outputs without final population and scores'
    };

    cfg.traceability.required_tags = {
        'CORRECTED'
        'HYBRID_IRR_FIXED'
        'MODE_ENERGY_FIXED'
        'NO_HISTORICAL_MIXING'
        'GA_HISTORY_CAPTURED'
        'FINAL_POPULATION_CAPTURED'
        'FINAL_SCORES_CAPTURED'
    };

    %% Required source checks
    source_item = {
        'active_corrected_wrapper'
        'historical_wrapper_preserved'
        'cost_params_file'
        'cost_breakdown_file'
        'ga_history_output_function'
    };

    source_path = {
        active_wrapper
        historical_wrapper
        cost_params_file
        cost_breakdown_file
        ga_history_file
    };

    source_exists = false(numel(source_path),1);
    source_status = cell(numel(source_path),1);

    for k = 1:numel(source_path)
        source_exists(k) = isfile(source_path{k});
        if source_exists(k)
            source_status{k} = 'PASS';
        else
            source_status{k} = 'FAIL';
        end
    end

    T_sources = table(source_item, source_path, source_exists, source_status, ...
        'VariableNames', {'item','path','exists','status'});

    %% Output contract table
    output_item = {
        'ga_history'
        'final_population'
        'final_scores'
        'pareto_front'
        'selected_solution'
        'mode_comparison'
        'fig20_source'
        'fig21_source'
        'run_log'
        'config_mat'
    };

    output_required = true(numel(output_item),1);

    output_reason = {
        'convergence cannot be reconstructed after run'
        'required for reproducibility'
        'required for objective verification'
        'required for Pareto analysis'
        'required for selected operating point'
        'required for gasLP/hybrid/solar corrected comparison'
        'required to recalculate Fig. 20'
        'required to recalculate Fig. 21'
        'required for audit trail'
        'required for configuration reproducibility'
    };

    output_status = repmat({'DECLARED_NOT_GENERATED'},numel(output_item),1);

    T_outputs = table(output_item, output_required, output_reason, output_status, ...
        'VariableNames', {'item','required','reason','status'});

    %% Compact config table
    config_item = {
        'config_status'
        'version_base'
        'productive_run_id'
        'active_wrapper'
        'ga_algorithm'
        'population_size'
        'generations'
        'seed_recommended'
        'lower_bounds'
        'upper_bounds'
        'drying_target'
        'execution_status'
    };

    config_value = {
        cfg.config_status
        cfg.version_base
        cfg.productive_run_id
        cfg.active_wrapper
        cfg.ga.algorithm
        num2str(cfg.ga.population_size)
        num2str(cfg.ga.generations)
        num2str(cfg.ga.seed_recommended)
        mat2str(cfg.decision_variables.lower_bounds)
        mat2str(cfg.decision_variables.upper_bounds)
        cfg.simulation.drying_target
        'NOT_EXECUTED'
    };

    T_config = table(config_item, config_value, ...
        'VariableNames', {'item','value'});

    %% Final status
    if all(strcmp(T_sources.status,'PASS'))
        cfg.ready_for_productive_script = true;
    else
        cfg.ready_for_productive_script = false;
        cfg.config_status = 'PRODUCTIVE_CONFIGURATION_NOT_READY';
    end

    %% Write outputs
    writetable(T_config,cfg.outputs.config_csv);
    writetable(T_outputs,cfg.outputs.outputs_contract_csv);

    save(cfg.outputs.mat_file,'cfg','T_sources','T_outputs','T_config');

    fid = fopen(cfg.outputs.log_file,'w');

    fprintf(fid,'PRODUCTIVE_RUN_CONFIG_v69\n\n');
    fprintf(fid,'status: %s\n',cfg.config_status);
    fprintf(fid,'ready_for_productive_script: %d\n\n',cfg.ready_for_productive_script);

    fprintf(fid,'Scope:\n');
    fprintf(fid,'Configuration only.\n');
    fprintf(fid,'GA not executed.\n');
    fprintf(fid,'Model simulation not executed by this function.\n');
    fprintf(fid,'Costs not modified.\n');
    fprintf(fid,'Final article figures not declared.\n\n');

    fprintf(fid,'Active corrected wrapper:\n%s\n\n',cfg.active_wrapper);

    fprintf(fid,'Mode rules:\n');
    fprintf(fid,'gasLP  -> I_effective = 0,      calor_aux = true\n');
    fprintf(fid,'hybrid -> I_effective = I_busc, calor_aux = true\n');
    fprintf(fid,'solar  -> I_effective = I_busc, calor_aux = false\n\n');

    fprintf(fid,'GA declared configuration:\n');
    fprintf(fid,'algorithm: %s\n',cfg.ga.algorithm);
    fprintf(fid,'population_size: %d\n',cfg.ga.population_size);
    fprintf(fid,'generations: %d\n',cfg.ga.generations);
    fprintf(fid,'seed_recommended: %d\n\n',cfg.ga.seed_recommended);

    fprintf(fid,'Decision variables:\n');
    fprintf(fid,'names: m_max, T_min, r_div2, t_rec_ini\n');
    fprintf(fid,'lower_bounds: %s\n',mat2str(cfg.decision_variables.lower_bounds));
    fprintf(fid,'upper_bounds: %s\n\n',mat2str(cfg.decision_variables.upper_bounds));

    fprintf(fid,'Mandatory future outputs:\n');
    for k = 1:height(T_outputs)
        fprintf(fid,'- %s | %s\n',T_outputs.item{k},T_outputs.reason{k});
    end

    fprintf(fid,'\nTraceability prohibitions:\n');
    for k = 1:numel(cfg.traceability.do_not_reuse)
        fprintf(fid,'- %s\n',cfg.traceability.do_not_reuse{k});
    end

    fclose(fid);

    disp('=== PRODUCTIVE_RUN_CONFIG_v69 ===')
    disp(cfg.config_status)

    disp('=== SOURCE CHECKS ===')
    disp(T_sources)

    disp('=== OUTPUT CONTRACT ===')
    disp(T_outputs)

    disp('=== CONFIG SUMMARY ===')
    disp(T_config)
end