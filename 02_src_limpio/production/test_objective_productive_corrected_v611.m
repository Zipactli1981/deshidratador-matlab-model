function test = test_objective_productive_corrected_v611()
%TEST_OBJECTIVE_PRODUCTIVE_CORRECTED_V611 Single-point objective test.
%
% Micropaso 6.11 — OBJECTIVE-PRODUCTIVE-CORRECTED-001
%
% This test evaluates one objective point only.
% It does not run GA.

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    logDir  = fullfile(rootDir,'06_outputs','logs');
    tabDir  = fullfile(rootDir,'06_outputs','tables');
    compDir = fullfile(rootDir,'06_outputs','comparisons');

    if ~exist(logDir,'dir'), mkdir(logDir); end
    if ~exist(tabDir,'dir'), mkdir(tabDir); end
    if ~exist(compDir,'dir'), mkdir(compDir); end

    %% Controlled single test point
    x_test = [0.11 55 0.5 3];
    mode_operation = 'hybrid';

    [f, detail] = objective_productive_corrected_v611(x_test, mode_operation);

    %% Checks
    objective_size_ok = isnumeric(f) && numel(f) == 2;
    objective_finite_ok = all(isfinite(f));
    objective_positive_cost_ok = f(2) > 0;
    detail_status_ok = strcmp(detail.status,'OK');

    mode_rule_ok = contains(char(detail.irradiance.rule),'hybrid');

    if isfield(detail,'auxiliary')
        aux_rule_ok = contains(char(detail.auxiliary.rule),'hybrid') && ...
                      contains(char(detail.auxiliary.rule),'true');
    else
        aux_rule_ok = false;
    end

    if objective_size_ok && objective_finite_ok && ...
            objective_positive_cost_ok && detail_status_ok && ...
            mode_rule_ok && aux_rule_ok
        status = 'PASS';
    else
        status = 'FAIL';
    end

    %% Summary table
    item = {
        'objective_size_ok'
        'objective_finite_ok'
        'objective_positive_cost_ok'
        'detail_status_ok'
        'mode_rule_ok'
        'aux_rule_ok'
    };

    value = [
        objective_size_ok
        objective_finite_ok
        objective_positive_cost_ok
        detail_status_ok
        mode_rule_ok
        aux_rule_ok
    ];

    T_checks = table(item,value, ...
        'VariableNames', {'item','value'});

    T_eval = table( ...
        {mode_operation}, ...
        x_test(1), x_test(2), x_test(3), x_test(4), ...
        f(1), f(2), ...
        detail.outputs.Q_aux_tot, ...
        detail.outputs.Irradiacion, ...
        detail.outputs.dry_time, ...
        detail.outputs.M, ...
        detail.outputs.MR, ...
        {char(detail.irradiance.rule)}, ...
        {char(detail.auxiliary.rule)}, ...
        {detail.status}, ...
        'VariableNames', { ...
            'mode_operation', ...
            'm_max','T_min','r_div2','t_rec_ini', ...
            'objective_MR','objective_cost_USD_per_kgwater', ...
            'Q_aux_tot','Irradiacion','dry_time','M','MR', ...
            'irradiance_rule','aux_rule','detail_status'} );

    %% Output files
    txtFile = fullfile(logDir,'OBJECTIVE_PRODUCTIVE_CORRECTED_v611.txt');
    csvEval = fullfile(tabDir,'OBJECTIVE_PRODUCTIVE_CORRECTED_EVAL_v611.csv');
    csvChecks = fullfile(tabDir,'OBJECTIVE_PRODUCTIVE_CORRECTED_CHECKS_v611.csv');
    matFile = fullfile(compDir,'OBJECTIVE_PRODUCTIVE_CORRECTED_v611.mat');

    writetable(T_eval,csvEval);
    writetable(T_checks,csvChecks);

    test = struct();
    test.created_at = datetime('now');
    test.created_by_function = 'test_objective_productive_corrected_v611';
    test.status = status;
    test.x_test = x_test;
    test.mode_operation = mode_operation;
    test.f = f;
    test.detail = detail;
    test.txtFile = txtFile;
    test.csvEval = csvEval;
    test.csvChecks = csvChecks;
    test.matFile = matFile;

    save(matFile,'test','T_eval','T_checks','detail','f');

    fid = fopen(txtFile,'w');

    fprintf(fid,'OBJECTIVE_PRODUCTIVE_CORRECTED_v611\n\n');
    fprintf(fid,'status: %s\n',status);
    fprintf(fid,'mode_operation: %s\n',mode_operation);
    fprintf(fid,'x_test: %s\n\n',mat2str(x_test));

    fprintf(fid,'Objectives:\n');
    fprintf(fid,'f(1) MR_final = %.12g\n',f(1));
    fprintf(fid,'f(2) cost_specific_USD_per_kgwater = %.12g\n\n',f(2));

    fprintf(fid,'Model outputs:\n');
    fprintf(fid,'Q_aux_tot = %.12g\n',detail.outputs.Q_aux_tot);
    fprintf(fid,'Irradiacion = %.12g\n',detail.outputs.Irradiacion);
    fprintf(fid,'dry_time = %.12g\n',detail.outputs.dry_time);
    fprintf(fid,'M = %.12g\n',detail.outputs.M);
    fprintf(fid,'MR = %.12g\n\n',detail.outputs.MR);

    fprintf(fid,'Rules:\n');
    fprintf(fid,'irradiance_rule: %s\n',char(detail.irradiance.rule));
    fprintf(fid,'aux_rule: %s\n\n',char(detail.auxiliary.rule));

    fprintf(fid,'Scope:\n');
    fprintf(fid,'Single objective evaluation only.\n');
    fprintf(fid,'GA not executed.\n');
    fprintf(fid,'Fig. 20 not recalculated.\n');
    fprintf(fid,'Fig. 21 not recalculated.\n');
    fprintf(fid,'Emissions objective not included in v6.11.\n');

    fclose(fid);

    disp('=== OBJECTIVE_PRODUCTIVE_CORRECTED_v611 ===')
    disp(test.status)

    disp('=== OBJECTIVE VALUE ===')
    disp(f)

    disp('=== EVALUATION TABLE ===')
    disp(T_eval)

    disp('=== CHECKS ===')
    disp(T_checks)
end