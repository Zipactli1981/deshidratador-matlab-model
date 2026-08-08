repoRoot = 'D:\CODE\deshidratador';
runDir = fullfile(repoRoot, '05_runs', 'triobjective_formal_ga_v96m', ...
    'CORRECTED_R1_COST_E3D_v96z_20260808_005736');
auditDir = fullfile(runDir, 'audit');
if ~isfolder(auditDir), mkdir(auditDir); end

diaryPath = fullfile(auditDir, 'CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z_diary.txt');
diary(diaryPath);
diaryCleanup = onCleanup(@() diary('off'));
fprintf('AUDIT_START_UTC = %s\n', char(datetime('now', 'TimeZone', 'UTC', ...
    'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSXXX')));
fprintf('AUTHORIZED_DETAIL_REPLAY_EVALUATIONS = 9\n');
fprintf('GAMULTIOBJ_EXECUTIONS_ADDITIONAL = 0\n');

try
    cd(repoRoot);
    addpath(genpath(fullfile(repoRoot, '02_src_limpio')));
    rehash;

    canonicalMat = fullfile(runDir, 'mat', 'CORRECTED_R1_COST_E3D_v96z.mat');
    rawMat = fullfile(runDir, 'mat', 'CORRECTED_R1_COST_E3D_v96z_raw.mat');
    solutionsCsv = fullfile(runDir, 'tables', 'CORRECTED_R1_COST_E3D_v96z_solutions.csv');
    runCsv = fullfile(runDir, 'tables', 'CORRECTED_R1_COST_E3D_v96z_run_summary.csv');
    checksCsv = fullfile(runDir, 'tables', 'CORRECTED_R1_COST_E3D_v96z_checks.csv');
    preflightCsv = fullfile(runDir, 'tables', 'CORRECTED_R1_COST_E3D_v96z_preflight.csv');
    sourceCsv = fullfile(runDir, 'tables', 'CORRECTED_R1_COST_E3D_v96z_source_scan.csv');
    runnerLog = fullfile(runDir, 'logs', 'CORRECTED_R1_COST_E3D_v96z.txt');
    executionDiary = fullfile(runDir, 'logs', 'CORRECTED_R1_COST_E3D_v96z_external_execution_diary.txt');

    fprintf('CHECKPOINT = LOAD_EXISTING_ARTIFACTS_BEGIN\n');
    C = load(canonicalMat);
    R = load(rawMat);
    TsolutionsCsv = readtable(solutionsCsv, 'VariableNamingRule', 'preserve');
    TrunCsv = readtable(runCsv, 'VariableNamingRule', 'preserve');
    TchecksCsv = readtable(checksCsv, 'VariableNamingRule', 'preserve');
    TpreflightCsv = readtable(preflightCsv, 'VariableNamingRule', 'preserve');
    TsourceCsv = readtable(sourceCsv, 'VariableNamingRule', 'preserve');
    runnerLogText = fileread(runnerLog);
    executionDiaryText = fileread(executionDiary);
    fprintf('CHECKPOINT = LOAD_EXISTING_ARTIFACTS_COMPLETE\n');

    expectedHead = "3aacb69ec5972aeb5d155c78462715bb3f1f981c";
    expectedLb = [0.0540767982118, 57.6832965028, 0.422252618341, 8.6517528081];
    expectedUb = [0.0940767982118, 67.6832965028, 0.922252618341, 14];
    absTol = 1e-12;
    relTol = 1e-10;
    boundsTol = 1e-12;

    artifactChecks = struct();
    artifactChecks.X_shape = isequal(size(C.X), [9 4]) && isequal(size(R.X), [9 4]);
    artifactChecks.F_shape = isequal(size(C.F), [9 3]) && isequal(size(R.F), [9 3]);
    artifactChecks.X_canonical_raw = isequaln(C.X, R.X);
    artifactChecks.F_canonical_raw = isequaln(C.F, R.F);
    artifactChecks.exitflag_canonical_raw = isequaln(C.exitflag, R.exitflag);
    artifactChecks.output_canonical_raw = isequaln(C.output, R.output);
    artifactChecks.population_canonical_raw = isequaln(C.population, R.population);
    artifactChecks.scores_canonical_raw = isequaln(C.scores, R.scores);
    artifactChecks.runtime_canonical_raw = isequaln(C.runtime_s, R.runtime_s);
    artifactChecks.bounds_canonical_raw = isequaln(C.lb, R.lb) && isequaln(C.ub, R.ub);
    artifactChecks.mode_canonical_raw = string(C.modeFormal) == string(R.modeFormal);
    artifactChecks.X_finite = all(isfinite(C.X), 'all');
    artifactChecks.F_finite = all(isfinite(C.F), 'all');
    artifactChecks.no_full_penalty = ~any(C.F(:,1) >= 999.999 | C.F(:,2) >= 999999.999 | C.F(:,3) >= 999999.999);
    artifactChecks.X_within_bounds = all(C.X >= C.lb - boundsTol, 'all') && all(C.X <= C.ub + boundsTol, 'all');
    artifactChecks.bounds_frozen = max(abs(double(C.lb(:)') - expectedLb)) <= boundsTol && ...
        max(abs(double(C.ub(:)') - expectedUb)) <= boundsTol;
    artifactChecks.X_unique = size(unique(C.X, 'rows'), 1) == size(C.X, 1);
    artifactChecks.XF_pairs_unique = size(unique([C.X C.F], 'rows'), 1) == size(C.X, 1);
    artifactChecks.exitflag_zero = double(C.exitflag) == 0;
    artifactChecks.output_generations = isfield(C.output, 'generations') && double(C.output.generations) == 50;
    artifactChecks.output_funccount = isfield(C.output, 'funccount') && double(C.output.funccount) == 1200;
    artifactChecks.exitflag_message_maxgen = isfield(C.output, 'message') && ...
        contains(string(C.output.message), "MaxGenerations");
    artifactChecks.run_error_empty = strlength(string(C.run_error)) == 0 && strlength(string(R.run_error)) == 0;
    artifactChecks.run_status_ok = string(C.run_status) == "OK" && string(R.run_status) == "OK";
    artifactChecks.runtime_csv = abs(double(C.runtime_s) - double(TrunCsv.runtime_s(1))) <= 1e-9;
    artifactChecks.exitflag_csv = double(TrunCsv.exitflag(1)) == double(C.exitflag);
    artifactChecks.generations_csv = double(TrunCsv.generations(1)) == double(C.output.generations);
    artifactChecks.funccount_csv = double(TrunCsv.funccount(1)) == double(C.output.funccount);
    artifactChecks.checks_all_pass = all(str2double(string(TchecksCsv{:,3})) == 1);
    artifactChecks.preflight_rows = height(TpreflightCsv) == 3;
    artifactChecks.source_scan_all_pass = all_numeric_ones(TsourceCsv{:,4});
    artifactChecks.runner_log_consistent = contains(runnerLogText, 'run_status: OK') && ...
        contains(runnerLogText, 'nSolutions: 9') && contains(runnerLogText, 'nPenaltyRows: 0') && ...
        contains(runnerLogText, 'F_has_3_columns: 1');
    artifactChecks.execution_diary_consistent = contains(executionDiaryText, 'EXECUTION_HEAD = ' + expectedHead) && ...
        contains(executionDiaryText, 'SEED = 61001') && contains(executionDiaryText, 'CORRECTED_R1_EXECUTION = PASS');
    artifactChecks.seed_provenance = double(C.formalFlags.corrected_r1_seed) == 61001;
    artifactChecks.mode_frozen = string(C.modeFormal) == "hybrid" && string(R.modeFormal) == "hybrid";
    artifactChecks.reference_frozen = string(C.referenceMode) == "gasLP";
    artifactChecks.nvars_frozen = double(C.nvars) == 4;
    artifactChecks.opts_population = isequal(R.opts.PopulationSize, 24);
    artifactChecks.opts_generations = isequal(R.opts.MaxGenerations, 50);
    artifactChecks.opts_function_tolerance = isequal(R.opts.FunctionTolerance, 1e-5);
    artifactChecks.opts_constraint_tolerance = isequal(R.opts.ConstraintTolerance, 1e-6);
    artifactChecks.opts_parallel = isequal(R.opts.UseParallel, false);
    artifactChecks.opts_plot = isempty(R.opts.PlotFcn);

    csvX = [TsolutionsCsv.m_max TsolutionsCsv.T_min TsolutionsCsv.r_div2 TsolutionsCsv.t_rec_ini];
    csvF = [TsolutionsCsv.MR TsolutionsCsv.cost_specific_USD_per_kgwater TsolutionsCsv.CO2_specific_kgCO2_per_kgwater];
    artifactChecks.X_csv = all(abs(double(C.X) - double(csvX)) <= ...
        absTol + relTol .* abs(double(C.X)), 'all');
    artifactChecks.F_csv = all(abs(double(C.F) - double(csvF)) <= ...
        absTol + relTol .* abs(double(C.F)), 'all');
    artifactChecks.penalty_csv = all(~logical(TsolutionsCsv.penalized));
    artifactChecks.canonical_table_X = isequaln(double(C.X), ...
        [C.Tsolutions.m_max C.Tsolutions.T_min C.Tsolutions.r_div2 C.Tsolutions.t_rec_ini]);
    artifactChecks.canonical_table_F = isequaln(double(C.F), ...
        [C.Tsolutions.MR C.Tsolutions.cost_specific_USD_per_kgwater C.Tsolutions.CO2_specific_kgCO2_per_kgwater]);

    checkNames = fieldnames(artifactChecks);
    artifactPassVector = false(numel(checkNames), 1);
    for k = 1:numel(checkNames)
        artifactPassVector(k) = logical(artifactChecks.(checkNames{k}));
        fprintf('ARTIFACT_CHECK|%s|pass=%d\n', checkNames{k}, artifactPassVector(k));
    end
    artifactConsistencyPass = all(artifactPassVector);

    if height(TsolutionsCsv) ~= 9 || size(C.X,1) ~= 9
        error('CORRECTED_R1_POSTRUN:ROW_COUNT', 'Expected exactly 9 stored final solutions.');
    end

    fprintf('CHECKPOINT = DETAIL_REPLAY_BEGIN\n');
    replayEvaluationCount = 0;
    replayRows = cell(9,1);
    detailReplay = cell(9,1);
    for i = 1:9
        x = double(C.X(i,:));
        fStored = double(C.F(i,:));
        [fReplay, detail] = objective_productive_corrected_v96j_triobjective_CO2_fix1(x, "hybrid");
        replayEvaluationCount = replayEvaluationCount + 1;
        fReplay = double(fReplay(:)');
        detailReplay{i} = detail;

        absDiff = abs(fReplay - fStored);
        relDiff = absDiff ./ max(abs(fStored), realmin('double'));
        componentPass = absDiff <= absTol + relTol .* abs(fStored);

        if string(detail.status) == "OK" && detail.outputs.M <= detail.product.M_des + 1e-12
            termination = "M_DES_REACHED";
            terminationBasis = "INFERRED_FROM_DETAIL_M_LE_M_DES";
        elseif string(detail.status) == "OK" && abs(double(detail.outputs.dry_time) - 19.9) <= 1e-9
            termination = "TMAX_REACHED";
            terminationBasis = "INFERRED_FROM_DETAIL_DRY_TIME_19_9H";
        else
            termination = string(detail.status);
            terminationBasis = "DETAIL_STATUS_FALLBACK";
        end

        row = struct();
        row.index = i;
        row.m_max = x(1);
        row.T_min = x(2);
        row.r_div2 = x(3);
        row.t_rec_ini = x(4);
        row.f1 = fStored(1);
        row.f2 = fStored(2);
        row.f3 = fStored(3);
        row.penalized = logical(fStored(1) >= 999.999 || fStored(2) >= 999999.999 || fStored(3) >= 999999.999);
        row.termination = termination;
        row.termination_basis = terminationBasis;
        row.dry_time_h = double(detail.outputs.dry_time);
        row.water_removed_kg = double(detail.cost.water_removed_kg);
        row.total_cost_USD = double(detail.cost.total_cost_USD);
        row.total_CO2_kg = double(detail.CO2.CO2_total_kg);
        row.Q_aux_tot_MJ = double(detail.outputs.Q_aux_tot);
        row.solar_energy_MJ = double(detail.cost.solar_energy_MJ);
        row.solar_cost_USD = double(detail.cost.solar_cost_USD);
        row.electric_energy_kWh = double(detail.cost.electric_energy_kWh);
        row.electric_cost_USD = double(detail.cost.electric_cost_USD);
        row.LPG_mass_kg = double(detail.cost.LPG_mass_kg);
        row.LPG_fuel_input_MJ = double(detail.cost.LPG_fuel_input_MJ);
        row.LPG_cost_USD = double(detail.cost.LPG_cost_USD);
        row.f1_replay = fReplay(1);
        row.f2_replay = fReplay(2);
        row.f3_replay = fReplay(3);
        row.f1_abs_diff = absDiff(1);
        row.f2_abs_diff = absDiff(2);
        row.f3_abs_diff = absDiff(3);
        row.f1_rel_diff = relDiff(1);
        row.f2_rel_diff = relDiff(2);
        row.f3_rel_diff = relDiff(3);
        row.f1_replay_pass = logical(componentPass(1));
        row.f2_replay_pass = logical(componentPass(2));
        row.f3_replay_pass = logical(componentPass(3));
        row.f1_detail_trace_abs_diff = abs(fReplay(1) - double(detail.outputs.MR));
        row.f2_detail_trace_abs_diff = abs(fReplay(2) - double(detail.cost.total_cost_USD) / double(detail.cost.water_removed_kg));
        row.f3_detail_trace_abs_diff = abs(fReplay(3) - double(detail.CO2.CO2_total_kg) / double(detail.CO2.water_removed_kg));
        row.detail_status = string(detail.status);
        replayRows{i} = row;

        fprintf('REPLAY|index=%d|f1_abs=%.17g|f2_abs=%.17g|f3_abs=%.17g|pass=%d%d%d|termination=%s\n', ...
            i, absDiff(1), absDiff(2), absDiff(3), componentPass(1), componentPass(2), componentPass(3), termination);
    end
    fprintf('CHECKPOINT = DETAIL_REPLAY_COMPLETE\n');

    Tpostrun = struct2table(vertcat(replayRows{:}));
    f1ReplayPass = replayEvaluationCount == 9 && all(Tpostrun.f1_replay_pass);
    f2ReplayPass = replayEvaluationCount == 9 && all(Tpostrun.f2_replay_pass);
    f3ReplayPass = replayEvaluationCount == 9 && all(Tpostrun.f3_replay_pass);
    detailTracePass = all(Tpostrun.f1_detail_trace_abs_diff <= absTol) && ...
        all(Tpostrun.f2_detail_trace_abs_diff <= absTol + relTol .* abs(Tpostrun.f2_replay)) && ...
        all(Tpostrun.f3_detail_trace_abs_diff <= absTol + relTol .* abs(Tpostrun.f3_replay));
    detailStatusPass = all(string(Tpostrun.detail_status) == "OK");
    penaltyPass = all(~Tpostrun.penalized);
    overallPass = artifactConsistencyPass && f1ReplayPass && f2ReplayPass && f3ReplayPass && ...
        detailTracePass && detailStatusPass && penaltyPass && replayEvaluationCount == 9;

    summary = struct();
    summary.CORRECTED_R1_POSTRUN_INTERNAL_AUDIT = string(ternary(overallPass, 'PASS', 'FAIL'));
    summary.CORRECTED_R1_RESULTS_INTERNALLY_VALIDATED = string(ternary(overallPass, 'YES', 'NO'));
    summary.CORRECTED_R1_PARETO_FRONT_STATUS = "INTERNAL_RUN_VALIDATED_COMPARATIVE_REVIEW_PENDING";
    summary.DETAIL_REPLAY_EVALUATIONS = replayEvaluationCount;
    summary.GAMULTIOBJ_EXECUTIONS_ADDITIONAL = 0;
    summary.F1_REPLAY_STATUS = string(ternary(f1ReplayPass, 'PASS', 'FAIL'));
    summary.F2_REPLAY_STATUS = string(ternary(f2ReplayPass, 'PASS', 'FAIL'));
    summary.F3_REPLAY_STATUS = string(ternary(f3ReplayPass, 'PASS', 'FAIL'));
    summary.X_BOUNDS_STATUS = string(ternary(artifactChecks.X_within_bounds && artifactChecks.bounds_frozen, 'PASS', 'FAIL'));
    summary.MAT_CSV_LOG_CONSISTENCY = string(ternary(artifactConsistencyPass, 'PASS', 'FAIL'));
    summary.PENALTY_STATUS = string(ternary(penaltyPass, 'PASS_NO_PENALTY_ROWS', 'FAIL'));
    summary.abs_tolerance = absTol;
    summary.rel_tolerance = relTol;
    summary.max_f1_abs_diff = max(Tpostrun.f1_abs_diff);
    summary.max_f2_abs_diff = max(Tpostrun.f2_abs_diff);
    summary.max_f3_abs_diff = max(Tpostrun.f3_abs_diff);
    summary.max_f1_rel_diff = max(Tpostrun.f1_rel_diff);
    summary.max_f2_rel_diff = max(Tpostrun.f2_rel_diff);
    summary.max_f3_rel_diff = max(Tpostrun.f3_rel_diff);
    summary.execution_head = expectedHead;
    summary.seed = 61001;
    summary.exitflag = double(C.exitflag);
    summary.generations = double(C.output.generations);
    summary.funccount = double(C.output.funccount);
    summary.runtime_h = double(C.runtime_s) / 3600;
    summary.n_solutions = size(C.X, 1);
    summary.n_finite = sum(all(isfinite(C.F), 2));
    summary.n_penalized = sum(C.F(:,1) >= 999.999 | C.F(:,2) >= 999999.999 | C.F(:,3) >= 999999.999);
    summary.termination_field_note = "Objective detail does not propagate wrapper termination_status; termination is explicitly inferred from returned M/M_des or dry_time=19.9 h.";

    outMat = fullfile(auditDir, 'CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.mat');
    outJson = fullfile(auditDir, 'CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.json');
    outTxt = fullfile(auditDir, 'CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.txt');
    save(outMat, 'summary', 'artifactChecks', 'artifactPassVector', 'checkNames', ...
        'Tpostrun', 'detailReplay', 'absTol', 'relTol', 'boundsTol', ...
        'replayEvaluationCount', 'canonicalMat', 'rawMat', 'solutionsCsv', 'runCsv');

    jsonPayload = struct();
    jsonPayload.summary = summary;
    jsonPayload.artifact_checks = artifactChecks;
    jsonPayload.rows = table2struct(Tpostrun);
    fid = fopen(outJson, 'w');
    fprintf(fid, '%s', jsonencode(jsonPayload, 'PrettyPrint', true));
    fclose(fid);

    fid = fopen(outTxt, 'w');
    summaryFields = fieldnames(summary);
    for k = 1:numel(summaryFields)
        value = summary.(summaryFields{k});
        if isnumeric(value)
            fprintf(fid, '%s = %.17g\n', summaryFields{k}, value);
        else
            fprintf(fid, '%s = %s\n', summaryFields{k}, string(value));
        end
    end
    fclose(fid);

    disp(summary);
    disp(Tpostrun);
    fprintf('PRODUCTIVE_CODE_MODIFIED = NO\n');
    fprintf('AUDIT_END_UTC = %s\n', char(datetime('now', 'TimeZone', 'UTC', ...
        'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSXXX')));
    fprintf('CHECKPOINT = POSTRUN_INTERNAL_AUDIT_COMPLETE\n');
    diary off;
catch ME
    fprintf('CHECKPOINT = POSTRUN_INTERNAL_AUDIT_ERROR\n');
    fprintf('ERROR_IDENTIFIER = %s\n', ME.identifier);
    fprintf('ERROR_MESSAGE = %s\n', ME.message);
    fprintf('%s\n', getReport(ME, 'extended', 'hyperlinks', 'off'));
    diary off;
    rethrow(ME);
end

function result = ternary(condition, trueValue, falseValue)
    if condition
        result = trueValue;
    else
        result = falseValue;
    end
end

function pass = all_numeric_ones(rawValues)
    if iscell(rawValues)
        values = NaN(numel(rawValues),1);
        for idx = 1:numel(rawValues)
            values(idx) = str2double(string(rawValues{idx}));
        end
    else
        values = str2double(string(rawValues));
    end
    pass = all(values == 1);
end
