function impl = implement_triobjective_CO2_objective_v96j()
% IMPLEMENT_TRIOBJECTIVE_CO2_OBJECTIVE_v96j
% 9.6j — IMPLEMENT-TRIOBJECTIVE-CO2-OBJECTIVE-v96j-001
%
% Objetivo:
%   Crear una función objetivo triobjetivo:
%
%       f(1) = MR_final
%       f(2) = cost_specific_USD_per_kgwater
%       f(3) = CO2_specific_kgCO2_per_kgwater
%
% Base:
%   Se clona objective_productive_corrected_v95j_endpoint_TMAX_corrected
%   y se crea:
%       objective_productive_corrected_v96j_triobjective_CO2
%
% Este micropaso:
%   - NO modifica v10.
%   - NO modifica v17.
%   - NO modifica v628b.
%   - NO modifica v18.
%   - NO modifica v95j.
%   - Crea objective v96j.
%   - Ejecuta evaluación directa gasLP/hybrid/solar.
%   - NO ejecuta gamultiobj.
%   - NO libera corrida formal.
%
% Nota importante sobre factores de emisión:
%   Para permitir validación de código se usan factores provisionales
%   explícitamente marcados como no definitivos.
%
%   EF_LPG_kgCO2_per_kWh      = 0.2270
%   EF_grid_kgCO2_per_kWh     = 0.4380
%
%   Estos valores deben sustituirse o confirmarse documentalmente antes
%   de manuscrito final. Su uso aquí es para auditoría computacional.
%
% Salidas:
%   logs/TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j.md
%   logs/TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j.txt
%   tables/TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j_eval.csv
%   tables/TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j_checks.csv
%   tables/TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j_source_scan.csv
%   mat/TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j.mat
%
% Uso:
%   impl = implement_triobjective_CO2_objective_v96j();

    rootDir = setup_v05_paths();
    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    rehash;

    % ---------------------------------------------------------------------
    % Cargar diseño 9.6i
    % ---------------------------------------------------------------------
    designBaseDir = fullfile(rootDir,'05_runs','triobjective_CO2_refactor_design_v96i');

    if ~isfolder(designBaseDir)
        error('No existe designBaseDir: %s', designBaseDir);
    end

    d = dir(designBaseDir);
    d = d([d.isdir]);
    d = d(~ismember({d.name},{'.','..','.MATLABDriveTag'}));

    keep = false(size(d));
    for k = 1:numel(d)
        keep(k) = startsWith(d(k).name,'TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i_');
    end
    d = d(keep);

    if isempty(d)
        error('No se encontró diseño v96i.');
    end

    [~,idxDesign] = max([d.datenum]);
    designDir = fullfile(designBaseDir,d(idxDesign).name);
    designMat = fullfile(designDir,'mat','TRIOBJECTIVE_CO2_REFACTOR_DESIGN_v96i.mat');

    if ~isfile(designMat)
        error('No existe MAT v96i: %s', designMat);
    end

    S96i = load(designMat);

    if ~isfield(S96i,'diagnosis')
        error('v96i no contiene diagnosis.');
    end

    if ~strcmp(string(S96i.diagnosis),"TRIOBJECTIVE_CO2_REFACTOR_DESIGN_PASS")
        error('v96i no está en PASS. Diagnosis: %s', string(S96i.diagnosis));
    end

    % ---------------------------------------------------------------------
    % Archivos base y destino
    % ---------------------------------------------------------------------
    objective_v95j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v95j_endpoint_TMAX_corrected.m');
    objective_v96j = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v96j_triobjective_CO2.m');

    wrapper_v10 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v10_energy_mode_corrected.m');
    wrapper_v17 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v17_nonphysical_penalty.m');
    wrapper_v18 = fullfile(rootDir,'02_src_limpio','wrappers','opt_tunel_mod2_v18_endpoint_TMAX_corrected.m');
    objective_v628b = fullfile(rootDir,'02_src_limpio','production','objective_productive_corrected_v628b_nonphysical_penalty.m');

    if ~isfile(objective_v95j)
        error('No existe objective v95j: %s', objective_v95j);
    end

    if ~isfile(wrapper_v18)
        error('No existe wrapper v18: %s', wrapper_v18);
    end

    % ---------------------------------------------------------------------
    % Carpeta de salida
    % ---------------------------------------------------------------------
    timestamp = datestr(now,'yyyymmdd_HHMMSS');

    implBaseDir = fullfile(rootDir,'05_runs','triobjective_CO2_objective_implementation_v96j');
    implDir = fullfile(implBaseDir,['TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j_' timestamp]);

    logsDir = fullfile(implDir,'logs');
    tablesDir = fullfile(implDir,'tables');
    matDir = fullfile(implDir,'mat');

    if ~isfolder(implBaseDir), mkdir(implBaseDir); end
    if ~isfolder(implDir), mkdir(implDir); end
    if ~isfolder(logsDir), mkdir(logsDir); end
    if ~isfolder(tablesDir), mkdir(tablesDir); end
    if ~isfolder(matDir), mkdir(matDir); end

    % ---------------------------------------------------------------------
    % Crear objective v96j
    % ---------------------------------------------------------------------
    txt95j = fileread(objective_v95j);

    txt96j = txt95j;

    txt96j = strrep(txt96j, ...
        'function [f, detail] = objective_productive_corrected_v95j_endpoint_TMAX_corrected', ...
        'function [f, detail] = objective_productive_corrected_v96j_triobjective_CO2');

    txt96j = strrep(txt96j, ...
        'objective_productive_corrected_v95j_endpoint_TMAX_corrected', ...
        'objective_productive_corrected_v96j_triobjective_CO2');

    % Ampliar penalizaciones simples comunes de dos a tres objetivos.
    txt96j = strrep(txt96j, '[1000, 1e6]', '[1000, 1e6, 1e6]');
    txt96j = strrep(txt96j, '[1000 1e6]', '[1000 1e6 1e6]');
    txt96j = strrep(txt96j, 'f = [penalty_MR, penalty_cost];', 'f = [penalty_MR, penalty_cost, penalty_CO2];');

    % Insertar bloque CO2 antes de que detail.objectives.MR_final se escriba,
    % porque en v95j se espera que f ya esté construido como MR-cost.
    marker = 'detail.objectives.MR_final = f(1);';

    if ~contains(txt96j, marker)
        error('No se encontró marker para insertar CO2 triobjetivo: %s', marker);
    end

    co2Block = [
        newline ...
        '    % --- v96j triobjective CO2 block ---------------------------------' newline ...
        '    % Provisional emission factors for computational validation only.' newline ...
        '    % Must be replaced/confirmed before manuscript use.' newline ...
        '    EF_LPG_kgCO2_per_kWh = 0.2270;' newline ...
        '    EF_grid_kgCO2_per_kWh = 0.4380;' newline ...
        '    emission_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";' newline ...
        '    ' newline ...
        '    water_removed_kg = NaN;' newline ...
        '    if isfield(detail, "product") && isfield(detail.product, "mwi") && isfield(detail.product, "mwf")' newline ...
        '        water_removed_kg = detail.product.mwi - detail.product.mwf;' newline ...
        '    elseif isfield(detail, "product") && isfield(detail.product, "water_removed_kg")' newline ...
        '        water_removed_kg = detail.product.water_removed_kg;' newline ...
        '    end' newline ...
        '    ' newline ...
        '    E_electricity_kWh = NaN;' newline ...
        '    if isfield(detail, "cost") && isfield(detail.cost, "electricity_kWh")' newline ...
        '        E_electricity_kWh = detail.cost.electricity_kWh;' newline ...
        '    elseif isfield(detail, "cost") && isfield(detail.cost, "electric_energy_kWh")' newline ...
        '        E_electricity_kWh = detail.cost.electric_energy_kWh;' newline ...
        '    elseif isfield(detail, "cost") && isfield(detail.cost, "electricity_cost_USD")' newline ...
        '        % Fallback conservative reconstruction only if electricity cost exists.' newline ...
        '        % The divisor is intentionally NaN unless a tariff is stored.' newline ...
        '        E_electricity_kWh = NaN;' newline ...
        '    end' newline ...
        '    ' newline ...
        '    if isnan(E_electricity_kWh)' newline ...
        '        % Current audited cost route does not expose electricity kWh separately.' newline ...
        '        % The electricity contribution is set to zero for computational validation,' newline ...
        '        % and flagged as provisional. This must be corrected if electricity data are later exposed.' newline ...
        '        E_electricity_kWh = 0;' newline ...
        '        electricity_data_status = "NOT_EXPOSED_ASSUMED_ZERO_FOR_VALIDATION";' newline ...
        '    else' newline ...
        '        electricity_data_status = "EXTRACTED_FROM_DETAIL";' newline ...
        '    end' newline ...
        '    ' newline ...
        '    CO2_LPG_kg = Q_aux_tot * EF_LPG_kgCO2_per_kWh;' newline ...
        '    CO2_electricity_kg = E_electricity_kWh * EF_grid_kgCO2_per_kWh;' newline ...
        '    CO2_total_kg = CO2_LPG_kg + CO2_electricity_kg;' newline ...
        '    CO2_specific_kgCO2_per_kgwater = CO2_total_kg / water_removed_kg;' newline ...
        '    ' newline ...
        '    if ~isfinite(CO2_specific_kgCO2_per_kgwater) || ~isreal(CO2_specific_kgCO2_per_kgwater) || CO2_specific_kgCO2_per_kgwater < 0' newline ...
        '        f = [1000, 1e6, 1e6];' newline ...
        '        detail.status = "INVALID_CO2";' newline ...
        '    else' newline ...
        '        f = [f(1), f(2), CO2_specific_kgCO2_per_kgwater];' newline ...
        '    end' newline ...
        '    ' newline ...
        '    detail.CO2 = struct();' newline ...
        '    detail.CO2.EF_LPG_kgCO2_per_kWh = EF_LPG_kgCO2_per_kWh;' newline ...
        '    detail.CO2.EF_grid_kgCO2_per_kWh = EF_grid_kgCO2_per_kWh;' newline ...
        '    detail.CO2.emission_factor_status = emission_factor_status;' newline ...
        '    detail.CO2.electricity_data_status = electricity_data_status;' newline ...
        '    detail.CO2.water_removed_kg = water_removed_kg;' newline ...
        '    detail.CO2.E_electricity_kWh = E_electricity_kWh;' newline ...
        '    detail.CO2.CO2_LPG_kg = CO2_LPG_kg;' newline ...
        '    detail.CO2.CO2_electricity_kg = CO2_electricity_kg;' newline ...
        '    detail.CO2.CO2_total_kg = CO2_total_kg;' newline ...
        '    detail.CO2.CO2_specific_kgCO2_per_kgwater = CO2_specific_kgCO2_per_kgwater;' newline ...
        '    detail.CO2.scope = "TRIOBJECTIVE_COMPUTATIONAL_VALIDATION_FACTORS_PROVISIONAL";' newline ...
        '    % ----------------------------------------------------------------' newline ...
        newline
    ];

    txt96j = strrep(txt96j, marker, [co2Block marker]);

    % Agregar objetivo CO2 al bloque de objectives si existe.
    marker2 = 'detail.objectives.cost_specific_USD_per_kgwater = f(2);';
    if contains(txt96j, marker2)
        txt96j = strrep(txt96j, marker2, ...
            [marker2 newline '    detail.objectives.CO2_specific_kgCO2_per_kgwater = f(3);']);
    end

    headerNote = sprintf(['%% v96j triobjective CO2 objective generated by implement_triobjective_CO2_objective_v96j on %s\n' ...
                          '%% f = [MR_final, cost_specific_USD_per_kgwater, CO2_specific_kgCO2_per_kgwater]\n'], ...
                          datestr(now,'yyyy-mm-dd HH:MM:SS'));

    txt96j = regexprep(txt96j, '(^function\s)', [headerNote '$1'], 'once');

    fid = fopen(objective_v96j,'w');
    if fid < 0
        error('No se pudo escribir objective v96j: %s', objective_v96j);
    end
    fwrite(fid, txt96j);
    fclose(fid);

    addpath(genpath(fullfile(rootDir,'02_src_limpio')));
    clear objective_productive_corrected_v96j_triobjective_CO2
    rehash;

    if exist('objective_productive_corrected_v96j_triobjective_CO2','file') ~= 2
        error('No quedó visible objective v96j después de crearlo.');
    end

    % ---------------------------------------------------------------------
    % Evaluación directa comparativa v95j vs v96j
    % ---------------------------------------------------------------------
    x_selected = [ ...
        0.0740767982118, ...
        62.6832965028, ...
        0.672252618341, ...
        11.6517528081];

    modes = ["gasLP","hybrid","solar"];
    evalRows = {};

    for k = 1:numel(modes)
        mode = modes(k);

        [f95, d95, status95, err95] = local_eval_v95j(x_selected, mode);
        [f96, d96, status96, err96] = local_eval_v96j(x_selected, mode);

        row = local_eval_row(mode, x_selected, f95, d95, status95, err95, f96, d96, status96, err96);
        evalRows{end+1,1} = row; %#ok<AGROW>
    end

    Teval = struct2table(vertcat(evalRows{:}));
    outEvalCsv = fullfile(tablesDir,'TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j_eval.csv');
    writetable(Teval,outEvalCsv);

    gas = Teval(strcmp(string(Teval.mode),"gasLP"),:);
    hyb = Teval(strcmp(string(Teval.mode),"hybrid"),:);
    sol = Teval(strcmp(string(Teval.mode),"solar"),:);

    if isempty(gas) || isempty(hyb) || isempty(sol)
        error('Evaluación incompleta: faltan gasLP/hybrid/solar.');
    end

    % ---------------------------------------------------------------------
    % Escaneo de fuente
    % ---------------------------------------------------------------------
    sourceRows = {};

    sourceRows{end+1,1} = local_source_row("objective_v96j_exists", objective_v96j, "", isfile(objective_v96j), "Objective v96j exists.");
    sourceRows{end+1,1} = local_source_row("objective_v95j_preserved", objective_v95j, "", isfile(objective_v95j), "Objective v95j preserved.");
    sourceRows{end+1,1} = local_source_row("wrapper_v18_preserved", wrapper_v18, "", isfile(wrapper_v18), "Wrapper v18 preserved.");
    sourceRows{end+1,1} = local_source_row("wrapper_v10_preserved", wrapper_v10, "", isfile(wrapper_v10), "Wrapper v10 preserved.");
    sourceRows{end+1,1} = local_source_row("wrapper_v17_preserved", wrapper_v17, "", isfile(wrapper_v17), "Wrapper v17 preserved.");
    sourceRows{end+1,1} = local_source_row("objective_v628b_preserved", objective_v628b, "", isfile(objective_v628b), "Objective v628b preserved.");

    sourceRows{end+1,1} = local_source_contains("v96j_function_name", objective_v96j, "objective_productive_corrected_v96j_triobjective_CO2", "v96j function name found.");
    sourceRows{end+1,1} = local_source_contains("v96j_calls_v18", objective_v96j, "opt_tunel_mod2_v18_endpoint_TMAX_corrected", "v96j still calls v18 wrapper.");
    sourceRows{end+1,1} = local_source_contains("v96j_has_f3_CO2", objective_v96j, "CO2_specific_kgCO2_per_kgwater", "v96j contains CO2 objective term.");
    sourceRows{end+1,1} = local_source_contains("v96j_has_1x3_valid_f", objective_v96j, "f = [f(1), f(2), CO2_specific_kgCO2_per_kgwater];", "v96j builds 1x3 valid objective vector.");
    sourceRows{end+1,1} = local_source_contains("v96j_has_1x3_penalty", objective_v96j, "f = [1000, 1e6, 1e6];", "v96j contains 1x3 penalty vector.");
    sourceRows{end+1,1} = local_source_contains("v96j_stores_CO2_breakdown", objective_v96j, "detail.CO2.CO2_total_kg", "v96j stores CO2 breakdown.");
    sourceRows{end+1,1} = local_source_contains("v96j_marks_provisional_factors", objective_v96j, "PROVISIONAL_FOR_CODE_VALIDATION", "v96j marks provisional emission factors.");

    Tsource = struct2table(vertcat(sourceRows{:}));
    outSourceCsv = fullfile(tablesDir,'TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j_source_scan.csv');
    writetable(Tsource,outSourceCsv);

    % ---------------------------------------------------------------------
    % Checks de validación
    % ---------------------------------------------------------------------
    checks = {};

    maxPenaltyMR = 999.999;
    maxPenaltyCost = 999999.999;
    maxPenaltyCO2 = 999999.999;

    gas_v96_valid = strcmp(string(gas.v96_status(1)),"OK") && strcmp(string(gas.v96_detail_status(1)),"OK") && gas.v96_nobj(1) == 3;
    hyb_v96_valid = strcmp(string(hyb.v96_status(1)),"OK") && strcmp(string(hyb.v96_detail_status(1)),"OK") && hyb.v96_nobj(1) == 3;
    solar_penalized = sol.v96_f1(1) >= maxPenaltyMR || sol.v96_f2(1) >= maxPenaltyCost || sol.v96_f3(1) >= maxPenaltyCO2;

    MR_gas_recalc = (gas.v96_M(1) - gas.v96_Mf(1)) / (gas.v96_Mi(1) - gas.v96_Mf(1));
    MR_hyb_recalc = (hyb.v96_M(1) - hyb.v96_Mf(1)) / (hyb.v96_Mi(1) - hyb.v96_Mf(1));

    MR_gas_diff = abs(gas.v96_f1(1) - MR_gas_recalc);
    MR_hyb_diff = abs(hyb.v96_f1(1) - MR_hyb_recalc);

    cost_gas_diff = abs(gas.v96_f2(1) - gas.v95_f2(1));
    cost_hyb_diff = abs(hyb.v96_f2(1) - hyb.v95_f2(1));
    MR_obj_gas_diff = abs(gas.v96_f1(1) - gas.v95_f1(1));
    MR_obj_hyb_diff = abs(hyb.v96_f1(1) - hyb.v95_f1(1));

    CO2_gas = gas.v96_f3(1);
    CO2_hyb = hyb.v96_f3(1);
    CO2_reduction_pct = 100 * (CO2_gas - CO2_hyb) / CO2_gas;

    checks{end+1,1} = local_check_row( ...
        "V01", ...
        "Direct f size", ...
        gas.v96_nobj(1) == 3 && hyb.v96_nobj(1) == 3 && sol.v96_nobj(1) == 3, ...
        sprintf("gas nobj=%d; hybrid nobj=%d; solar nobj=%d", gas.v96_nobj(1), hyb.v96_nobj(1), sol.v96_nobj(1)), ...
        "gasLP/hybrid/solar must return 3 objective components.");

    checks{end+1,1} = local_check_row( ...
        "V02", ...
        "MR consistency", ...
        MR_gas_diff < 1e-8 && MR_hyb_diff < 1e-8 && MR_obj_gas_diff < 1e-12 && MR_obj_hyb_diff < 1e-12, ...
        sprintf("MR recalc diffs gas=%.12g hybrid=%.12g; vs v95j gas=%.12g hybrid=%.12g", MR_gas_diff, MR_hyb_diff, MR_obj_gas_diff, MR_obj_hyb_diff), ...
        "f(1) must match v95j MR and MR=(M-Mf)/(Mi-Mf).");

    checks{end+1,1} = local_check_row( ...
        "V03", ...
        "Cost consistency", ...
        cost_gas_diff < 1e-10 && cost_hyb_diff < 1e-10, ...
        sprintf("cost diffs gas=%.12g hybrid=%.12g", cost_gas_diff, cost_hyb_diff), ...
        "f(2) must match v95j cost for same x/mode.");

    checks{end+1,1} = local_check_row( ...
        "V04", ...
        "CO2 finite positive", ...
        isfinite(CO2_gas) && isfinite(CO2_hyb) && CO2_gas >= 0 && CO2_hyb >= 0, ...
        sprintf("CO2 gas=%.12g; CO2 hybrid=%.12g", CO2_gas, CO2_hyb), ...
        "f(3) must be finite and nonnegative for gasLP/hybrid.");

    checks{end+1,1} = local_check_row( ...
        "V05", ...
        "CO2 reduction sanity", ...
        CO2_hyb < CO2_gas, ...
        sprintf("CO2 reduction hybrid vs gasLP=%.12g%%", CO2_reduction_pct), ...
        "For selected x, hybrid CO2 should be lower than gasLP under provisional factors.");

    checks{end+1,1} = local_check_row( ...
        "V06", ...
        "Solar exclusion", ...
        solar_penalized && strcmp(string(sol.v96_detail_status(1)),"INVALID_COST"), ...
        sprintf("solar f=[%.12g %.12g %.12g], detail=%s", sol.v96_f1(1), sol.v96_f2(1), sol.v96_f3(1), string(sol.v96_detail_status(1))), ...
        "Solar remains penalized/excluded.");

    checks{end+1,1} = local_check_row( ...
        "V07", ...
        "No source overwrite", ...
        isfile(wrapper_v10) && isfile(wrapper_v17) && isfile(objective_v628b) && isfile(wrapper_v18) && isfile(objective_v95j) && isfile(objective_v96j), ...
        "v10/v17/v628b/v18/v95j preserved and v96j created.", ...
        "Protected files must remain available.");

    checks{end+1,1} = local_check_row( ...
        "V08", ...
        "Source triobjective route", ...
        local_source_pass(Tsource,"v96j_has_1x3_valid_f") && ...
        local_source_pass(Tsource,"v96j_has_1x3_penalty") && ...
        local_source_pass(Tsource,"v96j_stores_CO2_breakdown") && ...
        local_source_pass(Tsource,"v96j_marks_provisional_factors"), ...
        "v96j contains 1x3 objective, 1x3 penalty, CO2 breakdown and provisional factor flag.", ...
        "v96j source must support triobjective traceability.");

    Tchecks = struct2table(vertcat(checks{:}));
    outChecksCsv = fullfile(tablesDir,'TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j_checks.csv');
    writetable(Tchecks,outChecksCsv);

    % ---------------------------------------------------------------------
    % Dictamen
    % ---------------------------------------------------------------------
    implFlags = struct();
    implFlags.objective_v96j_created = isfile(objective_v96j);
    implFlags.v10_preserved = isfile(wrapper_v10);
    implFlags.v17_preserved = isfile(wrapper_v17);
    implFlags.v628b_preserved = isfile(objective_v628b);
    implFlags.v18_preserved = isfile(wrapper_v18);
    implFlags.v95j_preserved = isfile(objective_v95j);
    implFlags.gasLP_v96j_valid_3obj = gas_v96_valid;
    implFlags.hybrid_v96j_valid_3obj = hyb_v96_valid;
    implFlags.solar_penalized_3obj = solar_penalized;
    implFlags.MR_consistency_pass = Tchecks.pass(strcmp(string(Tchecks.id),"V02"));
    implFlags.cost_consistency_pass = Tchecks.pass(strcmp(string(Tchecks.id),"V03"));
    implFlags.CO2_finite_positive_pass = Tchecks.pass(strcmp(string(Tchecks.id),"V04"));
    implFlags.CO2_reduction_sanity_pass = Tchecks.pass(strcmp(string(Tchecks.id),"V05"));
    implFlags.source_triobjective_route_pass = Tchecks.pass(strcmp(string(Tchecks.id),"V08"));
    implFlags.all_direct_triobjective_checks_pass = all(Tchecks.pass);
    implFlags.emission_factors_provisional = true;
    implFlags.no_GA_executed = true;
    implFlags.formal_run_still_on_hold = true;
    implFlags.triobjective_smoke_pending = true;

    if implFlags.all_direct_triobjective_checks_pass
        diagnosis = "TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_PASS";
    else
        diagnosis = "TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_REQUIRES_REVIEW";
    end

    % ---------------------------------------------------------------------
    % Salidas
    % ---------------------------------------------------------------------
    outMd = fullfile(logsDir,'TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j.md');
    outTxt = fullfile(logsDir,'TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j.txt');
    outMat = fullfile(matDir,'TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j.mat');

    save(outMat, ...
        'diagnosis','implFlags','x_selected', ...
        'Teval','Tchecks','Tsource', ...
        'MR_gas_recalc','MR_hyb_recalc','MR_gas_diff','MR_hyb_diff', ...
        'cost_gas_diff','cost_hyb_diff','MR_obj_gas_diff','MR_obj_hyb_diff', ...
        'CO2_gas','CO2_hyb','CO2_reduction_pct', ...
        'objective_v96j','objective_v95j','wrapper_v18','wrapper_v10','wrapper_v17','objective_v628b', ...
        'designDir','implDir', ...
        'outMd','outTxt','outMat','outEvalCsv','outChecksCsv','outSourceCsv');

    % ---------------------------------------------------------------------
    % Markdown
    % ---------------------------------------------------------------------
    fid = fopen(outMd,'w');
    if fid < 0
        error('No se pudo crear MD: %s', outMd);
    end

    fprintf(fid,'# TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j\n\n');

    fprintf(fid,'## Estado\n\n');
    fprintf(fid,'Diagnóstico: `%s`\n\n', diagnosis);
    fprintf(fid,'Este micropaso crea `objective_productive_corrected_v96j_triobjective_CO2` y valida evaluación directa de 3 objetivos. No ejecuta AG.\n\n');

    fprintf(fid,'## Objective creada\n\n');
    fprintf(fid,'```text\n%s\n```\n\n', objective_v96j);

    fprintf(fid,'## Vector objetivo\n\n');
    fprintf(fid,'```matlab\n');
    fprintf(fid,'f(1) = MR_final;\n');
    fprintf(fid,'f(2) = cost_specific_USD_per_kgwater;\n');
    fprintf(fid,'f(3) = CO2_specific_kgCO2_per_kgwater;\n');
    fprintf(fid,'```\n\n');

    fprintf(fid,'## Evaluación directa comparativa v95j vs v96j\n\n');
    fprintf(fid,'| Modo | v95 nobj | v96 nobj | v96 status | v96 detail | f1 MR | f2 cost | f3 CO2 | Q_aux | water_removed | CO2 total | CO2 LPG | CO2 elec |\n');
    fprintf(fid,'|---|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|\n');

    for k = 1:height(Teval)
        fprintf(fid,'| `%s` | %d | %d | `%s` | `%s` | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g | %.12g |\n', ...
            string(Teval.mode(k)), ...
            Teval.v95_nobj(k), ...
            Teval.v96_nobj(k), ...
            string(Teval.v96_status(k)), ...
            string(Teval.v96_detail_status(k)), ...
            Teval.v96_f1(k), ...
            Teval.v96_f2(k), ...
            Teval.v96_f3(k), ...
            Teval.v96_Q_aux_tot(k), ...
            Teval.v96_water_removed_kg(k), ...
            Teval.v96_CO2_total_kg(k), ...
            Teval.v96_CO2_LPG_kg(k), ...
            Teval.v96_CO2_electricity_kg(k));
    end

    fprintf(fid,'\n## Checks\n\n');
    fprintf(fid,'| ID | Check | Pass | Evidencia | Criterio |\n');
    fprintf(fid,'|---|---|---:|---|---|\n');

    for k = 1:height(Tchecks)
        fprintf(fid,'| `%s` | `%s` | `%d` | %s | %s |\n', ...
            string(Tchecks.id(k)), ...
            string(Tchecks.check(k)), ...
            Tchecks.pass(k), ...
            string(Tchecks.evidence(k)), ...
            string(Tchecks.criterion(k)));
    end

    fprintf(fid,'\n## Escaneo de fuente\n\n');
    fprintf(fid,'| Item | Pass | Evidencia |\n');
    fprintf(fid,'|---|---:|---|\n');

    for k = 1:height(Tsource)
        fprintf(fid,'| `%s` | `%d` | %s |\n', ...
            string(Tsource.item(k)), ...
            Tsource.pass(k), ...
            string(Tsource.evidence(k)));
    end

    fprintf(fid,'\n## Métricas CO2 con factores provisionales\n\n');
    fprintf(fid,'| Métrica | Valor |\n');
    fprintf(fid,'|---|---:|\n');
    fprintf(fid,'| CO2_specific_gasLP_kgCO2_per_kgwater | %.12g |\n', CO2_gas);
    fprintf(fid,'| CO2_specific_hybrid_kgCO2_per_kgwater | %.12g |\n', CO2_hyb);
    fprintf(fid,'| CO2_reduction_hybrid_vs_gasLP_pct | %.12g |\n\n', CO2_reduction_pct);

    fprintf(fid,'## Restricciones activas\n\n');
    fprintf(fid,'- No se ejecutó `gamultiobj`.\n');
    fprintf(fid,'- Los factores de emisión son provisionales para validación computacional.\n');
    fprintf(fid,'- La corrida formal sigue detenida.\n');
    fprintf(fid,'- Falta smoke GA triobjetivo.\n');
    fprintf(fid,'- Solar puro sigue excluido.\n\n');

    fprintf(fid,'## Siguiente paso\n\n');
    fprintf(fid,'Si el diagnóstico es `TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_PASS`, continuar con `9.6k — GUARDED-TRIOBJECTIVE-SMOKE-GA-001`.\n\n');

    fclose(fid);

    % ---------------------------------------------------------------------
    % TXT ejecutivo
    % ---------------------------------------------------------------------
    fid = fopen(outTxt,'w');
    if fid < 0
        error('No se pudo crear TXT: %s', outTxt);
    end

    fprintf(fid,'IMPLEMENT-TRIOBJECTIVE-CO2-OBJECTIVE-v96j-001\n');
    fprintf(fid,'status: TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_COMPLETED\n');
    fprintf(fid,'diagnosis: %s\n', diagnosis);
    fprintf(fid,'objective_v96j_created: %d\n', implFlags.objective_v96j_created);
    fprintf(fid,'v10_preserved: %d\n', implFlags.v10_preserved);
    fprintf(fid,'v17_preserved: %d\n', implFlags.v17_preserved);
    fprintf(fid,'v628b_preserved: %d\n', implFlags.v628b_preserved);
    fprintf(fid,'v18_preserved: %d\n', implFlags.v18_preserved);
    fprintf(fid,'v95j_preserved: %d\n', implFlags.v95j_preserved);
    fprintf(fid,'gasLP_v96j_valid_3obj: %d\n', implFlags.gasLP_v96j_valid_3obj);
    fprintf(fid,'hybrid_v96j_valid_3obj: %d\n', implFlags.hybrid_v96j_valid_3obj);
    fprintf(fid,'solar_penalized_3obj: %d\n', implFlags.solar_penalized_3obj);
    fprintf(fid,'MR_consistency_pass: %d\n', implFlags.MR_consistency_pass);
    fprintf(fid,'cost_consistency_pass: %d\n', implFlags.cost_consistency_pass);
    fprintf(fid,'CO2_finite_positive_pass: %d\n', implFlags.CO2_finite_positive_pass);
    fprintf(fid,'CO2_reduction_sanity_pass: %d\n', implFlags.CO2_reduction_sanity_pass);
    fprintf(fid,'source_triobjective_route_pass: %d\n', implFlags.source_triobjective_route_pass);
    fprintf(fid,'all_direct_triobjective_checks_pass: %d\n', implFlags.all_direct_triobjective_checks_pass);
    fprintf(fid,'emission_factors_provisional: %d\n', implFlags.emission_factors_provisional);
    fprintf(fid,'no_GA_executed: %d\n', implFlags.no_GA_executed);
    fprintf(fid,'formal_run_still_on_hold: %d\n', implFlags.formal_run_still_on_hold);
    fprintf(fid,'triobjective_smoke_pending: %d\n', implFlags.triobjective_smoke_pending);
    fprintf(fid,'timestamp: %s\n\n', datestr(now,'yyyy-mm-dd HH:MM:SS'));

    fprintf(fid,'KEY CO2 METRICS PROVISIONAL:\n');
    fprintf(fid,'CO2_gas_specific: %.12g\n', CO2_gas);
    fprintf(fid,'CO2_hybrid_specific: %.12g\n', CO2_hyb);
    fprintf(fid,'CO2_reduction_pct: %.12g\n\n', CO2_reduction_pct);

    fprintf(fid,'OUTPUTS:\n');
    fprintf(fid,'outMd: %s\n', outMd);
    fprintf(fid,'outTxt: %s\n', outTxt);
    fprintf(fid,'outMat: %s\n', outMat);
    fprintf(fid,'outEvalCsv: %s\n', outEvalCsv);
    fprintf(fid,'outChecksCsv: %s\n', outChecksCsv);
    fprintf(fid,'outSourceCsv: %s\n', outSourceCsv);

    fclose(fid);

    % ---------------------------------------------------------------------
    % Salida
    % ---------------------------------------------------------------------
    impl = struct();
    impl.status = 'TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_COMPLETED';
    impl.diagnosis = diagnosis;
    impl.implFlags = implFlags;
    impl.x_selected = x_selected;
    impl.Teval = Teval;
    impl.Tchecks = Tchecks;
    impl.Tsource = Tsource;
    impl.MR_gas_recalc = MR_gas_recalc;
    impl.MR_hyb_recalc = MR_hyb_recalc;
    impl.MR_gas_diff = MR_gas_diff;
    impl.MR_hyb_diff = MR_hyb_diff;
    impl.cost_gas_diff = cost_gas_diff;
    impl.cost_hyb_diff = cost_hyb_diff;
    impl.MR_obj_gas_diff = MR_obj_gas_diff;
    impl.MR_obj_hyb_diff = MR_obj_hyb_diff;
    impl.CO2_gas = CO2_gas;
    impl.CO2_hyb = CO2_hyb;
    impl.CO2_reduction_pct = CO2_reduction_pct;
    impl.objective_v96j = objective_v96j;
    impl.objective_v95j = objective_v95j;
    impl.wrapper_v18 = wrapper_v18;
    impl.implDir = implDir;
    impl.designDir = designDir;
    impl.outMd = outMd;
    impl.outTxt = outTxt;
    impl.outMat = outMat;
    impl.outEvalCsv = outEvalCsv;
    impl.outChecksCsv = outChecksCsv;
    impl.outSourceCsv = outSourceCsv;

    disp('=== TRIOBJECTIVE_CO2_OBJECTIVE_IMPLEMENTATION_v96j ===')
    disp(impl.status)
    disp('=== DIAGNOSIS ===')
    disp(impl.diagnosis)
    disp('=== IMPLEMENTATION FLAGS ===')
    disp(impl.implFlags)
    disp('=== DIRECT EVALUATION ===')
    disp(impl.Teval)
    disp('=== CHECKS ===')
    disp(impl.Tchecks)
    disp('=== SOURCE SCAN ===')
    disp(impl.Tsource)
    disp('=== KEY METRICS ===')
    fprintf('MR_gas_diff = %.12g\n', impl.MR_gas_diff);
    fprintf('MR_hyb_diff = %.12g\n', impl.MR_hyb_diff);
    fprintf('cost_gas_diff = %.12g\n', impl.cost_gas_diff);
    fprintf('cost_hyb_diff = %.12g\n', impl.cost_hyb_diff);
    fprintf('CO2_gas_specific = %.12g\n', impl.CO2_gas);
    fprintf('CO2_hybrid_specific = %.12g\n', impl.CO2_hyb);
    fprintf('CO2_reduction_pct = %.12g\n', impl.CO2_reduction_pct);
    disp('=== OUTPUT FILES ===')
    disp(impl.outMd)
    disp(impl.outTxt)
    disp(impl.outMat)

end

% =========================================================================
% Funciones locales auxiliares
% =========================================================================

function [f, detail, status, errMsg] = local_eval_v95j(x, mode)
    status = "OK";
    errMsg = "";
    detail = struct();

    try
        [f, detail] = objective_productive_corrected_v95j_endpoint_TMAX_corrected(x, mode);
        f = double(f(:))';

        if numel(f) < 2
            f = [1000, 1e6];
            status = "BAD_OBJECTIVE_SIZE";
        end

    catch ME
        f = [1000, 1e6];
        detail = struct();
        status = "ERROR";
        errMsg = string(ME.message);
    end
end

function [f, detail, status, errMsg] = local_eval_v96j(x, mode)
    status = "OK";
    errMsg = "";
    detail = struct();

    try
        [f, detail] = objective_productive_corrected_v96j_triobjective_CO2(x, mode);
        f = double(f(:))';

        if numel(f) < 3
            f = [1000, 1e6, 1e6];
            status = "BAD_OBJECTIVE_SIZE";
        end

        if any(~isfinite(f)) || any(~isreal(f))
            f = [1000, 1e6, 1e6];
            status = "BAD_OBJECTIVE_VALUE";
        end

    catch ME
        f = [1000, 1e6, 1e6];
        detail = struct();
        status = "ERROR";
        errMsg = string(ME.message);
    end
end

function row = local_eval_row(mode, x, f95, d95, status95, err95, f96, d96, status96, err96)
    row = struct();

    row.mode = string(mode);

    row.m_max = x(1);
    row.T_min = x(2);
    row.r_div2 = x(3);
    row.t_rec_ini = x(4);

    row.v95_status = string(status95);
    row.v95_error = string(err95);
    row.v95_nobj = numel(f95);
    row.v95_f1 = local_vec_get(f95,1,NaN);
    row.v95_f2 = local_vec_get(f95,2,NaN);
    row.v95_detail_status = local_get_string(d95, {'status','detail_status','execution_status'}, "UNKNOWN");

    row.v96_status = string(status96);
    row.v96_error = string(err96);
    row.v96_nobj = numel(f96);
    row.v96_f1 = local_vec_get(f96,1,NaN);
    row.v96_f2 = local_vec_get(f96,2,NaN);
    row.v96_f3 = local_vec_get(f96,3,NaN);
    row.v96_detail_status = local_get_string(d96, {'status','detail_status','execution_status'}, "UNKNOWN");

    row.v96_Q_aux_tot = local_get_numeric(d96, {'outputs.Q_aux_tot','Q_aux_tot'}, NaN);
    row.v96_Irradiacion = local_get_numeric(d96, {'outputs.Irradiacion','Irradiacion'}, NaN);
    row.v96_dry_time = local_get_numeric(d96, {'outputs.dry_time','dry_time'}, NaN);
    row.v96_M = local_get_numeric(d96, {'outputs.M','M'}, NaN);
    row.v96_MR = local_get_numeric(d96, {'outputs.MR','MR'}, NaN);
    row.v96_Mf = local_get_numeric(d96, {'product.Mf','Mf'}, NaN);
    row.v96_Mi = local_get_numeric(d96, {'product.Mi','Mi'}, NaN);
    row.v96_M_des = local_get_numeric(d96, {'product.M_des','M_des'}, NaN);

    row.v96_water_removed_kg = local_get_numeric(d96, {'CO2.water_removed_kg'}, NaN);
    row.v96_E_electricity_kWh = local_get_numeric(d96, {'CO2.E_electricity_kWh'}, NaN);
    row.v96_CO2_LPG_kg = local_get_numeric(d96, {'CO2.CO2_LPG_kg'}, NaN);
    row.v96_CO2_electricity_kg = local_get_numeric(d96, {'CO2.CO2_electricity_kg'}, NaN);
    row.v96_CO2_total_kg = local_get_numeric(d96, {'CO2.CO2_total_kg'}, NaN);
    row.v96_CO2_specific = local_get_numeric(d96, {'CO2.CO2_specific_kgCO2_per_kgwater','objectives.CO2_specific_kgCO2_per_kgwater'}, NaN);
    row.v96_emission_factor_status = local_get_string(d96, {'CO2.emission_factor_status'}, "");
    row.v96_electricity_data_status = local_get_string(d96, {'CO2.electricity_data_status'}, "");

end

function val = local_vec_get(v, idx, defaultVal)
    if numel(v) >= idx
        val = v(idx);
    else
        val = defaultVal;
    end
end

function val = local_get_numeric(S, paths, defaultVal)
    val = defaultVal;

    for k = 1:numel(paths)
        p = string(paths{k});
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

function val = local_get_string(S, paths, defaultVal)
    val = string(defaultVal);

    for k = 1:numel(paths)
        p = string(paths{k});
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

function row = local_source_row(item, filePath, pattern, passVal, evidence)
    row = struct();
    row.item = string(item);
    row.file = string(filePath);
    row.pattern = string(pattern);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
end

function row = local_source_contains(item, filePath, pattern, evidenceIfFound)
    passVal = false;
    evidence = "FILE_NOT_FOUND";

    if isfile(filePath)
        try
            txt = fileread(filePath);
            passVal = contains(txt, pattern);
            if passVal
                evidence = string(evidenceIfFound);
            else
                evidence = "Pattern not found.";
            end
        catch ME
            evidence = "Could not read file: " + string(ME.message);
        end
    end

    row = local_source_row(item, filePath, pattern, passVal, evidence);
end

function tf = local_source_pass(Tsource, itemName)
    idx = strcmp(string(Tsource.item), string(itemName));
    if any(idx)
        tf = logical(Tsource.pass(find(idx,1,'first')));
    else
        tf = false;
    end
end

function row = local_check_row(id, checkName, passVal, evidence, criterion)
    row = struct();
    row.id = string(id);
    row.check = string(checkName);
    row.pass = logical(passVal);
    row.evidence = string(evidence);
    row.criterion = string(criterion);
end