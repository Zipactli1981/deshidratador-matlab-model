function capture = capture_productive_ga_outputs_v614b(runctx)
%CAPTURE_PRODUCTIVE_GA_OUTPUTS_V614B Clean mandatory output capture.
%
% Micropaso 6.14 — PRODUCTIVE-GA-OUTPUT-CAPTURE-001B
%
% This function does not execute gamultiobj.
% It only writes mandatory outputs from an already available runctx.

    required_fields = {
        'rootDir'
        'run_id'
        'cfg'
        'final_population'
        'final_scores'
        'exitflag'
        'output'
        'ga_history'
        'mode_comparison_table'
        'fig20_source_table'
        'fig21_source_table'
    };

    for k = 1:numel(required_fields)
        if ~isfield(runctx,required_fields{k})
            error('capture_v614b:missingField', ...
                'Missing required field: %s', required_fields{k});
        end
    end

    rootDir = runctx.rootDir;
    run_id = runctx.run_id;

    runDir = fullfile(rootDir,'05_runs','productive_v614b',run_id);
    logDir = fullfile(runDir,'logs');
    tabDir = fullfile(runDir,'tables');
    matDir = fullfile(runDir,'mat');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(matDir,'dir'), mkdir(matDir); end

    final_population = runctx.final_population;
    final_scores = runctx.final_scores;

    if ~isnumeric(final_population) || size(final_population,2) ~= 4
        error('capture_v614b:invalidPopulation', ...
            'final_population must be numeric with 4 columns.');
    end

    if ~isnumeric(final_scores) || size(final_scores,2) < 2
        error('capture_v614b:invalidScores', ...
            'final_scores must be numeric with at least 2 columns.');
    end

    if size(final_population,1) ~= size(final_scores,1)
        error('capture_v614b:dimensionMismatch', ...
            'population and scores must have same number of rows.');
    end

    T_population = array2table(final_population, ...
        'VariableNames', {'m_max','T_min','r_div2','t_rec_ini'});

    T_scores = array2table(final_scores(:,1:2), ...
        'VariableNames', {'objective_MR','objective_cost_USD_per_kgwater'});

    T_pareto = [T_population T_scores];

    feasible_idx = find(T_pareto.objective_MR <= 0.1);

    if ~isempty(feasible_idx)
        [~,local_idx] = min(T_pareto.objective_cost_USD_per_kgwater(feasible_idx));
        selected_idx = feasible_idx(local_idx);
        selected_status = 'FEASIBLE_SELECTED';
        selected_rule = 'MR <= 0.1 and minimum cost among feasible solutions';
    else
        [~,selected_idx] = min(T_pareto.objective_MR);
        selected_status = 'NO_FEASIBLE_SELECTED_DIAGNOSTIC';
        selected_rule = 'No MR <= 0.1 solution; selected minimum MR for diagnostic only';
    end

    T_selected = T_pareto(selected_idx,:);
    T_selected.selected_index = selected_idx;
    T_selected.selected_status = {selected_status};
    T_selected.selected_rule = {selected_rule};
    T_selected.run_id = {run_id};

    T_mode = runctx.mode_comparison_table;
    T_fig20 = runctx.fig20_source_table;
    T_fig21 = runctx.fig21_source_table;

    if ~istable(T_mode), error('capture_v614b:invalidModeTable','mode_comparison_table must be table.'); end
    if ~istable(T_fig20), error('capture_v614b:invalidFig20Table','fig20_source_table must be table.'); end
    if ~istable(T_fig21), error('capture_v614b:invalidFig21Table','fig21_source_table must be table.'); end

    files = struct();
    files.ga_history_mat = fullfile(matDir,'GA_HISTORY_CORRECTED_v614b.mat');
    files.final_population_csv = fullfile(tabDir,'GA_FINAL_POPULATION_CORRECTED_v614b.csv');
    files.final_scores_csv = fullfile(tabDir,'GA_FINAL_SCORES_CORRECTED_v614b.csv');
    files.pareto_csv = fullfile(tabDir,'PARETO_CORRECTED_v614b.csv');
    files.selected_solution_csv = fullfile(tabDir,'SELECTED_SOLUTION_CORRECTED_v614b.csv');
    files.mode_comparison_csv = fullfile(tabDir,'MODE_COMPARISON_CORRECTED_v614b.csv');
    files.fig20_source_csv = fullfile(tabDir,'FIG20_SOURCE_CORRECTED_v614b.csv');
    files.fig21_source_csv = fullfile(tabDir,'FIG21_SOURCE_CORRECTED_v614b.csv');
    files.run_log_txt = fullfile(logDir,'PRODUCTIVE_GA_RUN_CORRECTED_v614b.txt');
    files.configuration_mat = fullfile(matDir,'PRODUCTIVE_GA_CONFIGURATION_CORRECTED_v614b.mat');
    files.capture_mat = fullfile(matDir,'PRODUCTIVE_GA_CAPTURE_CORRECTED_v614b.mat');

    writetable(T_population,files.final_population_csv);
    writetable(T_scores,files.final_scores_csv);
    writetable(T_pareto,files.pareto_csv);
    writetable(T_selected,files.selected_solution_csv);
    writetable(T_mode,files.mode_comparison_csv);
    writetable(T_fig20,files.fig20_source_csv);
    writetable(T_fig21,files.fig21_source_csv);

    cfg = runctx.cfg;
    ga_history = runctx.ga_history;
    output = runctx.output;
    exitflag = runctx.exitflag;

    save(files.ga_history_mat,'ga_history');
    save(files.configuration_mat,'cfg','runctx');

    fid = fopen(files.run_log_txt,'w');
    fprintf(fid,'PRODUCTIVE_GA_RUN_CORRECTED_v614b\n\n');
    fprintf(fid,'run_id: %s\n',run_id);
    fprintf(fid,'capture_status: OUTPUT_CAPTURE_EXECUTED_SYNTHETIC_TEST\n');
    fprintf(fid,'gamultiobj executed here: false\n\n');
    fprintf(fid,'selected_index: %d\n',selected_idx);
    fprintf(fid,'selected_status: %s\n',selected_status);
    fprintf(fid,'selected_rule: %s\n\n',selected_rule);
    fprintf(fid,'Traceability:\n');
    fprintf(fid,'Do not mix corrected outputs with historical GA outputs.\n');
    fprintf(fid,'Do not use historical Fig. 20 or Fig. 21 as final.\n');
    fclose(fid);

    %% CAPTURE-MAT-ORDER-B-001:
    %% Save capture MAT once before checking required output existence.
    %% It will be overwritten later with the final capture struct.
    save(files.capture_mat, ...
    'runctx','cfg','ga_history','final_population','final_scores', ...
    'T_population','T_scores','T_pareto','T_selected','T_mode','T_fig20','T_fig21', ...
    'output','exitflag','files');

    required_output = fieldnames(files);
    required_path = cell(numel(required_output),1);
    required_exists = false(numel(required_output),1);
    required_status = cell(numel(required_output),1);

    for k = 1:numel(required_output)
        required_path{k} = files.(required_output{k});
        required_exists(k) = isfile(required_path{k});
        if required_exists(k)
            required_status{k} = 'PASS';
        else
            required_status{k} = 'FAIL';
        end
    end

    T_required = table(required_output,required_path,required_exists,required_status, ...
        'VariableNames', {'item','path','exists','status'});

    capture = struct();
    capture.created_at = datetime('now');
    capture.created_by_function = 'capture_productive_ga_outputs_v614b';
    capture.run_id = run_id;
    capture.runDir = runDir;
    capture.files = files;
    capture.selected_idx = selected_idx;
    capture.selected_status = selected_status;
    capture.selected_rule = selected_rule;
    capture.T_required = T_required;
    capture.outputs_ok = all(strcmp(T_required.status,'PASS'));

    if capture.outputs_ok
        capture.status = 'PRODUCTIVE_GA_OUTPUT_CAPTURE_READY';
    else
        capture.status = 'PRODUCTIVE_GA_OUTPUT_CAPTURE_INCOMPLETE';
    end

    save(files.capture_mat, ...
        'capture','runctx','cfg','ga_history','final_population','final_scores', ...
        'T_population','T_scores','T_pareto','T_selected','T_mode','T_fig20','T_fig21', ...
        'T_required','output','exitflag','files');

    disp('=== PRODUCTIVE_GA_OUTPUT_CAPTURE_v614b ===')
    disp(capture.status)
    disp('=== REQUIRED OUTPUT CHECKS ===')
    disp(T_required)
    disp('=== SELECTED SOLUTION ===')
    disp(T_selected)
end