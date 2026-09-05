function summary = run_thesis_legacy_reevaluation_r1_v01(outputDir)
% Deterministic HB200 reevaluation. No optimizer or random-number use.

    if nargin ~= 1 || ~isfolder(outputDir)
        error('THESIS_LEGACY:OUTPUT_DIR', 'Existing campaign output directory is required.');
    end
    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir, '02_src_limpio')));
    rehash;

    tablesDir = fullfile(outputDir, 'tables');
    matDir = fullfile(outputDir, 'mat');
    auditDir = fullfile(outputDir, 'audit');
    logsDir = fullfile(outputDir, 'logs');
    diaryFile = fullfile(logsDir, 'THESIS_LEGACY_MATLAB_EXECUTION_DIARY.txt');
    diary(diaryFile);
    cleanupDiary = onCleanup(@() diary('off')); %#ok<NASGU>

    inputCsv = fullfile(tablesDir, 'THESIS_LEGACY_INPUT_FREEZE.csv');
    inputMat = fullfile(matDir, 'THESIS_LEGACY_INPUT_FREEZE.mat');
    if ~isfile(inputCsv) || ~isfile(inputMat)
        error('THESIS_LEGACY:INPUT_FREEZE_MISSING', 'Input freeze must exist before evaluation.');
    end
    Tin = readtable(inputCsv, 'TextType', 'string');
    Sin = load(inputMat);
    if height(Tin) ~= 44 || size(Sin.unique_X, 1) ~= 44
        error('THESIS_LEGACY:INPUT_FREEZE_COUNT', 'Expected 44 unique finite HB200 designs.');
    end
    if any(abs(double(Tin.mapped_t_rec)) > 0)
        error('THESIS_LEGACY:TIMING_MAPPING', 'Baseline mapping must use t_rec=0.');
    end

    objectivePath = fullfile(rootDir, '02_src_limpio', 'production', ...
        'objective_productive_corrected_v96j_triobjective_CO2_fix1.m');
    modelPath = fullfile(rootDir, '02_src_limpio', 'wrappers', ...
        'opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    costParamsPath = fullfile(rootDir, '02_src_limpio', 'cost', 'build_cost_params_historical.m');
    costBreakdownPath = fullfile(rootDir, '02_src_limpio', 'cost', 'calc_cost_breakdown.m');
    environmentalPath = fullfile(rootDir, '03_original_model', '04_data_original', 'Mapeo4_temp100621.txt');
    required = {objectivePath, modelPath, costParamsPath, costBreakdownPath, environmentalPath};
    if ~all(cellfun(@isfile, required))
        error('THESIS_LEGACY:IDENTITY_FILE_MISSING', 'A required productive input is missing.');
    end

    identity = struct();
    identity.MATLAB_RELEASE = string(version('-release'));
    identity.MATLAB_VERSION = string(version);
    gads = ver('gads');
    if isempty(gads)
        identity.GLOBAL_OPTIMIZATION_TOOLBOX_VERSION = "NOT_INSTALLED";
    else
        identity.GLOBAL_OPTIMIZATION_TOOLBOX_VERSION = string(gads.Version);
    end
    identity.PRODUCTIVE_MODEL_PATH = string(modelPath);
    identity.PRODUCTIVE_MODEL_HASH = local_sha256(modelPath);
    identity.CURRENT_OBJECTIVE_PATH = string(objectivePath);
    identity.CURRENT_OBJECTIVE_HASH = local_sha256(objectivePath);
    identity.COST_PARAMETER_PATH = string(costParamsPath);
    identity.COST_PARAMETER_HASH = local_sha256(costParamsPath);
    identity.COST_BREAKDOWN_PATH = string(costBreakdownPath);
    identity.COST_BREAKDOWN_HASH = local_sha256(costBreakdownPath);
    identity.ENVIRONMENTAL_DATA_PATH = string(environmentalPath);
    identity.ENVIRONMENTAL_DATA_HASH = local_sha256(environmentalPath);
    identity.ECONOMIC_PARAMETER_IDENTITY = "build_cost_params_historical coordinated June-2026 basis";
    identity.EMISSION_FACTOR_IDENTITY = "EF_LPG=3.00 kgCO2/kg; EF_grid=0.4440 kgCO2e/kWh";
    identity.GAMULTIOBJ_EXECUTED = false;
    identity.NEW_RANDOM_SEEDS = 0;
    identity.TIMING_MAPPING = "t_rec=0; within productive model physical bounds [0,19]";
    identityJson = jsonencode(identity, 'PrettyPrint', true);
    fid = fopen(fullfile(auditDir, 'THESIS_LEGACY_SOFTWARE_IDENTITY.json'), 'w');
    assert(fid >= 0); fprintf(fid, '%s\n', identityJson); fclose(fid);

    fprintf('Starting deterministic HB200 baseline: %d unique designs.\n', height(Tin));
    baselineRows = repmat(local_empty_row(), height(Tin), 1);
    baselineDetails = cell(height(Tin), 1);
    for i = 1:height(Tin)
        x = [Tin.m_max(i), Tin.T_min(i), Tin.r_rec(i), 0];
        [baselineRows(i), baselineDetails{i}] = local_evaluate(Tin.THESIS_ID(i), x, "hybrid", "BASELINE");
        fprintf('BASELINE %s %d/%d status=%s\n', Tin.THESIS_ID(i), i, height(Tin), baselineRows(i).status);
    end
    Tbaseline = struct2table(baselineRows);
    writetable(Tbaseline, fullfile(tablesDir, 'THESIS_LEGACY_CURRENT_RESULTS.csv'));
    save(fullfile(matDir, 'THESIS_LEGACY_CURRENT_RESULTS.mat'), 'Tbaseline', 'baselineDetails', 'identity', '-v7.3');
    writetable(Tbaseline, fullfile(tablesDir, 'THESIS_LEGACY_DECOMPOSITION.csv'));

    if ~all(Tbaseline.status == "OK")
        error('THESIS_LEGACY:BASELINE_FAILURE', 'At least one baseline evaluation failed.');
    end

    % Representative set is frozen before any timing result is generated.
    compromiseIdx = find(Tin.THESIS_ID == "T025", 1);
    [~, minF1] = min(Tbaseline.f1);
    [~, minF2] = min(Tbaseline.f2);
    [~, minF3] = min(Tbaseline.f3);
    repIdx = unique([compromiseIdx; minF1; minF2; minF3], 'stable');
    selection = strings(numel(repIdx), 1);
    for k = 1:numel(repIdx)
        labels = strings(0,1);
        if repIdx(k) == compromiseIdx, labels(end+1) = "THESIS_REPORTED_COMPROMISE"; end %#ok<AGROW>
        if repIdx(k) == minF1, labels(end+1) = "CURRENT_MIN_F1"; end %#ok<AGROW>
        if repIdx(k) == minF2, labels(end+1) = "CURRENT_MIN_F2"; end %#ok<AGROW>
        if repIdx(k) == minF3, labels(end+1) = "CURRENT_MIN_F3"; end %#ok<AGROW>
        selection(k) = join(labels, "|");
    end
    Trepresentatives = table(Tbaseline.THESIS_ID(repIdx), repIdx, selection, ...
        Tbaseline.m_max(repIdx), Tbaseline.T_min(repIdx), Tbaseline.r_rec(repIdx), ...
        'VariableNames', {'THESIS_ID','baseline_index','selection_basis','m_max','T_min','r_rec'});
    writetable(Trepresentatives, fullfile(tablesDir, 'THESIS_LEGACY_REPRESENTATIVE_FREEZE.csv'));
    save(fullfile(matDir, 'THESIS_LEGACY_REPRESENTATIVE_FREEZE.mat'), 'Trepresentatives', 'repIdx');

    % Three distinct deterministic sentinels.
    sentinelIdx = unique([compromiseIdx; minF1; minF2; minF3], 'stable');
    if numel(sentinelIdx) < 3
        [~, order] = sort(Tbaseline.f1, 'descend');
        sentinelIdx = unique([sentinelIdx; order], 'stable');
    end
    sentinelIdx = sentinelIdx(1:3);
    sentinelRows = repmat(local_empty_row(), 3, 1);
    sentinelDetails = cell(3,1);
    for k = 1:3
        i = sentinelIdx(k);
        x = [Tin.m_max(i), Tin.T_min(i), Tin.r_rec(i), 0];
        [sentinelRows(k), sentinelDetails{k}] = local_evaluate(Tin.THESIS_ID(i), x, "hybrid", "DETERMINISM_REPEAT");
    end
    Tsentinel = struct2table(sentinelRows);
    fields = {'MR_terminal','water_removed_kg','useful_auxiliary_heat_MJ','LPG_energy_input_MJ', ...
        'total_cost_USD','total_operational_emissions_kgCO2e','f1','f2','f3'};
    maxAbsDiff = 0;
    exact = true;
    for k = 1:3
        i = sentinelIdx(k);
        for j = 1:numel(fields)
            delta = abs(Tsentinel.(fields{j})(k) - Tbaseline.(fields{j})(i));
            maxAbsDiff = max(maxAbsDiff, delta);
            exact = exact && delta == 0;
        end
        exact = exact && Tsentinel.terminal_regime(k) == Tbaseline.terminal_regime(i);
    end
    if exact
        determinismStatus = "EXACT";
    elseif maxAbsDiff <= 1e-12
        determinismStatus = "NUMERICALLY_IDENTICAL_WITHIN_MACHINE_PRECISION";
    else
        determinismStatus = "FAIL";
    end
    writetable(Tsentinel, fullfile(tablesDir, 'THESIS_LEGACY_DETERMINISM_REPEATS.csv'));
    save(fullfile(matDir, 'THESIS_LEGACY_DETERMINISM_REPEATS.mat'), ...
        'Tsentinel', 'sentinelDetails', 'sentinelIdx', 'determinismStatus', 'maxAbsDiff');
    if determinismStatus == "FAIL"
        error('THESIS_LEGACY:DETERMINISM_FAILURE', 'Sentinel repeat failed determinism check.');
    end

    % Pointwise current gas-LPG context for the prespecified thesis representatives.
    gasRows = repmat(local_empty_row(), height(Trepresentatives), 1);
    gasDetails = cell(height(Trepresentatives),1);
    for k = 1:height(Trepresentatives)
        i = Trepresentatives.baseline_index(k);
        x = [Tin.m_max(i), Tin.T_min(i), Tin.r_rec(i), 0];
        [gasRows(k), gasDetails{k}] = local_evaluate(Tin.THESIS_ID(i), x, "gasLP", "GASLP_CONTEXT");
    end
    Tgas = struct2table(gasRows);
    writetable(Tgas, fullfile(tablesDir, 'THESIS_LEGACY_GASLP_CONTEXT_RAW.csv'));
    save(fullfile(matDir, 'THESIS_LEGACY_GASLP_CONTEXT_RAW.mat'), 'Tgas', 'gasDetails');

    % Prespecified paired one-factor timing experiment.
    timingLb = 8.6517528081;
    timingUb = 14.0;
    timingMid = (timingLb + timingUb) / 2;
    timingLevels = [0, timingLb, timingMid, timingUb];
    timingCategories = ["HISTORICALLY_FAITHFUL", "CURRENT_LOWER_BOUND", "CURRENT_BOUNDS_MIDPOINT", "CURRENT_UPPER_BOUND"];
    nTiming = height(Trepresentatives) * numel(timingLevels);
    timingRows = repmat(local_empty_row(), nTiming, 1);
    timingDetails = cell(nTiming,1);
    timingCategory = strings(nTiming,1);
    row = 0;
    for k = 1:height(Trepresentatives)
        i = Trepresentatives.baseline_index(k);
        for j = 1:numel(timingLevels)
            row = row + 1;
            x = [Tin.m_max(i), Tin.T_min(i), Tin.r_rec(i), timingLevels(j)];
            [timingRows(row), timingDetails{row}] = local_evaluate(Tin.THESIS_ID(i), x, "hybrid", "TIMING_EXPERIMENT");
            timingCategory(row) = timingCategories(j);
        end
    end
    Ttiming = struct2table(timingRows);
    Ttiming.timing_category = timingCategory;
    writetable(Ttiming, fullfile(tablesDir, 'THESIS_RECIRCULATION_TIMING_RESULTS.csv'));
    writetable(Ttiming, fullfile(tablesDir, 'THESIS_RECIRCULATION_TIMING_DECOMPOSITION.csv'));
    save(fullfile(matDir, 'THESIS_RECIRCULATION_TIMING_RESULTS.mat'), ...
        'Ttiming', 'timingDetails', 'timingLevels', 'timingCategories', '-v7.3');

    summary = struct();
    summary.unique_finite_thesis_designs = height(Tbaseline);
    summary.representative_designs = height(Trepresentatives);
    summary.timing_levels_per_design = numel(timingLevels);
    summary.baseline_evaluations = height(Tbaseline);
    summary.sentinel_repeat_evaluations = height(Tsentinel);
    summary.gasLP_context_evaluations = height(Tgas);
    summary.timing_evaluations = height(Ttiming);
    summary.total_model_evaluations = height(Tbaseline) + height(Tsentinel) + height(Tgas) + height(Ttiming);
    summary.determinism_check = determinismStatus;
    summary.max_abs_repeat_difference = maxAbsDiff;
    summary.gamultiobj_executed = false;
    summary.new_random_seeds = 0;
    summary.completed_at = string(datetime('now','TimeZone','UTC'));
    save(fullfile(matDir, 'THESIS_LEGACY_EXECUTION_SUMMARY.mat'), 'summary');
    fid = fopen(fullfile(auditDir, 'THESIS_LEGACY_EXECUTION_SUMMARY.json'), 'w');
    assert(fid >= 0); fprintf(fid, '%s\n', jsonencode(summary, 'PrettyPrint', true)); fclose(fid);
    fprintf('Completed deterministic campaign. Total model evaluations: %d\n', summary.total_model_evaluations);
end

function [row, detail] = local_evaluate(thesisId, x, mode, phase)
    [f, detail] = objective_productive_corrected_v96j_triobjective_CO2_fix1(x, mode);
    row = local_empty_row();
    row.THESIS_ID = string(thesisId);
    row.phase = string(phase);
    row.mode = string(mode);
    row.m_max = x(1); row.T_min = x(2); row.r_rec = x(3); row.t_rec_or_historical_equivalent = x(4);
    row.terminal_time = local_nested(detail, {'outputs','dry_time'}, NaN);
    row.M_terminal = local_nested(detail, {'outputs','M'}, NaN);
    row.MR_terminal = local_nested(detail, {'outputs','MR'}, NaN);
    row.water_removed_kg = local_nested(detail, {'cost','water_removed_kg'}, NaN);
    row.useful_auxiliary_heat_MJ = local_nested(detail, {'cost','Q_aux_useful_MJ'}, NaN);
    row.LPG_energy_input_MJ = local_nested(detail, {'cost','LPG_fuel_input_MJ'}, NaN);
    row.LPG_mass_kg = local_nested(detail, {'cost','LPG_mass_kg'}, NaN);
    row.LPG_cost_USD = local_nested(detail, {'cost','LPG_cost_USD'}, NaN);
    row.solar_cost_USD = local_nested(detail, {'cost','solar_cost_USD'}, NaN);
    row.impeller_electricity_kWh = local_nested(detail, {'cost','electric_energy_kWh'}, NaN);
    row.electricity_cost_USD = local_nested(detail, {'cost','electric_cost_USD'}, NaN);
    row.total_cost_USD = local_nested(detail, {'cost','total_cost_USD'}, NaN);
    row.total_operational_emissions_kgCO2e = local_nested(detail, {'CO2','CO2_total_kg'}, NaN);
    row.f1 = f(1); row.f2 = f(2); row.f3 = f(3);
    row.status = string(local_nested(detail, {'status'}, "UNKNOWN"));
    row.penalty_flag = f(1) >= 999.999 || f(2) >= 999999.999 || f(3) >= 999999.999;
    row.nonphysical_flag = contains(row.status, "NONPHYSICAL");
    mDes = local_nested(detail, {'product','M_des'}, NaN);
    if row.status == "OK" && isfinite(mDes) && row.M_terminal <= mDes
        row.terminal_regime = "M_DES_REACHED";
    elseif row.status == "OK" && row.terminal_time >= 19.9 - 1e-12
        row.terminal_regime = "TMAX_REACHED";
    else
        row.terminal_regime = "NOT_DETERMINABLE";
    end
    row.notes = "Productive objective v96j_fix1; no optimizer";
end

function row = local_empty_row()
    row = struct('THESIS_ID',"",'phase',"",'mode',"",'m_max',NaN,'T_min',NaN,'r_rec',NaN, ...
        't_rec_or_historical_equivalent',NaN,'terminal_time',NaN,'terminal_regime',"", ...
        'M_terminal',NaN,'MR_terminal',NaN,'water_removed_kg',NaN, ...
        'useful_auxiliary_heat_MJ',NaN,'LPG_energy_input_MJ',NaN,'LPG_mass_kg',NaN, ...
        'LPG_cost_USD',NaN,'solar_cost_USD',NaN,'impeller_electricity_kWh',NaN, ...
        'electricity_cost_USD',NaN,'total_cost_USD',NaN, ...
        'total_operational_emissions_kgCO2e',NaN,'f1',NaN,'f2',NaN,'f3',NaN, ...
        'penalty_flag',false,'nonphysical_flag',false,'status',"",'notes',"");
end

function value = local_nested(s, parts, defaultValue)
    value = defaultValue;
    try
        tmp = s;
        for i = 1:numel(parts)
            if ~isstruct(tmp) || ~isfield(tmp, parts{i}), return; end
            tmp = tmp.(parts{i});
        end
        if ~isempty(tmp), value = tmp(1); end
    catch
        value = defaultValue;
    end
end

function hex = local_sha256(path)
    md = java.security.MessageDigest.getInstance('SHA-256');
    stream = java.io.FileInputStream(java.io.File(path));
    cleaner = onCleanup(@() stream.close()); %#ok<NASGU>
    buffer = zeros(1, 1024*1024, 'int8');
    while true
        n = stream.read(buffer, 0, numel(buffer));
        if n < 0, break; end
        md.update(buffer(1:n));
    end
    digest = typecast(md.digest(), 'uint8');
    hex = upper(string(reshape(dec2hex(digest,2).',1,[])));
end

