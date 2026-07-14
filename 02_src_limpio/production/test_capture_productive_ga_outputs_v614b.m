function test = test_capture_productive_ga_outputs_v614b()
%TEST_CAPTURE_PRODUCTIVE_GA_OUTPUTS_V614B Synthetic output capture test.
%
% Does not execute gamultiobj.

    rootDir = setup_v05_paths();

    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    cfg = productive_run_config_v69();

    final_population = [
        0.11 55 0.50 3
        0.12 60 0.40 2
        0.13 65 0.70 5
        0.10 58 0.30 1
    ];

    final_scores = [
        0.18984 0.33344
        0.12000 0.31000
        0.09500 0.38000
        0.15000 0.29000
    ];

    ga_history = struct();
    ga_history.note = 'Synthetic GA history for capture test only.';
    ga_history.generations = (0:3)';
    ga_history.best_MR = [0.20; 0.16; 0.12; 0.095];
    ga_history.best_cost = [0.40; 0.36; 0.34; 0.38];

    output = struct();
    output.message = 'Synthetic output only. gamultiobj not executed.';
    output.generations = 3;
    output.funccount = 4;

    exitflag = NaN;

    mode = {'gasLP'; 'hybrid'; 'solar'};
    I_effective = [0; 67677.85; 67677.85];
    Irradiacion = [0; 487.28; 487.28];
    Q_aux_tot = [1277.9; 828.42; 0];
    MR = [0.18984; 0.18984; 0.72261];
    mode_status = {'SYNTHETIC_CAPTURE_TEST'; 'SYNTHETIC_CAPTURE_TEST'; 'SYNTHETIC_CAPTURE_TEST'};

    T_mode = table(mode,I_effective,Irradiacion,Q_aux_tot,MR,mode_status, ...
        'VariableNames', {'mode','I_effective','Irradiacion','Q_aux_tot','MR','status'});

    generation = (0:3)';
    best_MR = ga_history.best_MR;
    best_cost = ga_history.best_cost;

    T_fig20 = table(generation,best_MR,best_cost, ...
        'VariableNames', {'generation','best_MR','best_cost_USD_per_kgwater'});

    candidate_id = (1:size(final_scores,1))';
    objective_MR = final_scores(:,1);
    objective_cost_USD_per_kgwater = final_scores(:,2);

    T_fig21 = table(candidate_id,objective_MR,objective_cost_USD_per_kgwater, ...
        'VariableNames', {'candidate_id','objective_MR','objective_cost_USD_per_kgwater'});

    runctx = struct();
    runctx.rootDir = rootDir;
    runctx.run_id = ['SYNTHETIC_CAPTURE_TEST_' datestr(now,'yyyymmdd_HHMMSS')];
    runctx.cfg = cfg;
    runctx.final_population = final_population;
    runctx.final_scores = final_scores;
    runctx.exitflag = exitflag;
    runctx.output = output;
    runctx.ga_history = ga_history;
    runctx.mode_comparison_table = T_mode;
    runctx.fig20_source_table = T_fig20;
    runctx.fig21_source_table = T_fig21;

    capture = capture_productive_ga_outputs_v614b(runctx);

    test = struct();
    test.created_at = datetime('now');
    test.created_by_function = 'test_capture_productive_ga_outputs_v614b';
    test.capture = capture;

    if strcmp(capture.status,'PRODUCTIVE_GA_OUTPUT_CAPTURE_READY') && capture.outputs_ok
        test.status = 'PASS';
    else
        test.status = 'FAIL';
    end

    disp('=== TEST_CAPTURE_PRODUCTIVE_GA_OUTPUTS_v614b ===')
    disp(test.status)
    disp(capture.status)
    disp(capture.outputs_ok)
end