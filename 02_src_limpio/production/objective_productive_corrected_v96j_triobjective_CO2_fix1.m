function [f, detail] = objective_productive_corrected_v96j_triobjective_CO2_fix1(x, mode_operation)
% OBJECTIVE_PRODUCTIVE_CORRECTED_v96j_TRIOBJECTIVE_CO2_FIX1
%
% Función objetivo triobjetivo estable basada en v95j:
%   f(1) = MR_final
%   f(2) = cost_specific_USD_per_kgwater
%   f(3) = CO2_specific_kgCO2_per_kgwater
%
% Factores de emisión provisionales para validación computacional:
%   EF_LPG_kgCO2_per_kWh  = 0.2270
%   EF_grid_kgCO2_per_kWh = 0.4380
%
% No usar estos factores como definitivos para manuscrito sin referencia.

    penalty = [1000, 1e6, 1e6];
    f = penalty;
    detail = struct();
    detail.status = "UNINITIALIZED";
    detail.execution_status = "UNINITIALIZED";
    detail.objective_version = "v96j_triobjective_CO2_fix1";
    detail.base_objective = "objective_productive_corrected_v95j_endpoint_TMAX_corrected";

    EF_LPG_kgCO2_per_kWh = 0.2270;
    EF_grid_kgCO2_per_kWh = 0.4380;
    emission_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION";

    try
        [f_base, d_base] = objective_productive_corrected_v95j_endpoint_TMAX_corrected(x, mode_operation);
        f_base = double(f_base(:))';
    catch ME
        detail.status = "BASE_OBJECTIVE_ERROR";
        detail.execution_status = "ERROR";
        detail.error_message = string(ME.message);
        return
    end

    detail = d_base;
    detail.objective_version = "v96j_triobjective_CO2_fix1";
    detail.base_objective = "objective_productive_corrected_v95j_endpoint_TMAX_corrected";

    if numel(f_base) < 2 || any(~isfinite(f_base(1:2))) || any(~isreal(f_base(1:2)))
        f = penalty;
        detail.status = "INVALID_BASE_OBJECTIVE";
        detail.execution_status = "PENALIZED";
        detail.objectives = local_objectives_struct_v96j_fix1(f);
        return
    end

    base_status = local_get_string_v96j_fix1(detail, {"status","detail_status","execution_status"}, "UNKNOWN");
    base_penalized = f_base(1) >= 999.999 || f_base(2) >= 999999.999 || base_status == "INVALID_COST" || base_status == "NONPHYSICAL_TRAJECTORY";

    if base_penalized
        f = penalty;
        detail.status = base_status;
        detail.execution_status = "PENALIZED_BASE_OBJECTIVE";
        detail.objectives = local_objectives_struct_v96j_fix1(f);
        detail.CO2 = local_empty_CO2_v96j_fix1(EF_LPG_kgCO2_per_kWh, EF_grid_kgCO2_per_kWh, emission_factor_status, "BASE_PENALIZED");
        return
    end

    Q_aux_tot = local_get_numeric_v96j_fix1(detail, {"outputs.Q_aux_tot","Q_aux_tot"}, NaN);
    if ~isfinite(Q_aux_tot)
        Q_aux_tot = NaN;
    end

    water_removed_kg = NaN;
    mwi = local_get_numeric_v96j_fix1(detail, {"product.mwi","mwi"}, NaN);
    mwf = local_get_numeric_v96j_fix1(detail, {"product.mwf","mwf"}, NaN);
    if isfinite(mwi) && isfinite(mwf)
        water_removed_kg = mwi - mwf;
    end

    if ~isfinite(water_removed_kg) || water_removed_kg <= 0
        water_removed_kg = local_get_numeric_v96j_fix1(detail, {"product.water_removed_kg","water_removed_kg"}, NaN);
    end

    E_electricity_kWh = local_get_numeric_v96j_fix1(detail, {"cost.electricity_kWh","cost.electric_energy_kWh","electricity_kWh","electric_energy_kWh"}, NaN);
    if ~isfinite(E_electricity_kWh)
        E_electricity_kWh = 0;
        electricity_data_status = "NOT_EXPOSED_ASSUMED_ZERO_FOR_VALIDATION";
    else
        electricity_data_status = "EXTRACTED_FROM_DETAIL";
    end

    CO2_LPG_kg = Q_aux_tot * EF_LPG_kgCO2_per_kWh;
    CO2_electricity_kg = E_electricity_kWh * EF_grid_kgCO2_per_kWh;
    CO2_total_kg = CO2_LPG_kg + CO2_electricity_kg;
    CO2_specific_kgCO2_per_kgwater = CO2_total_kg / water_removed_kg;

    if ~isfinite(CO2_specific_kgCO2_per_kgwater) || ~isreal(CO2_specific_kgCO2_per_kgwater) || CO2_specific_kgCO2_per_kgwater < 0
        f = penalty;
        detail.status = "INVALID_CO2";
        detail.execution_status = "PENALIZED_INVALID_CO2";
        detail.objectives = local_objectives_struct_v96j_fix1(f);
    else
        f = [f_base(1), f_base(2), CO2_specific_kgCO2_per_kgwater];
        detail.status = "OK";
        detail.execution_status = "OK";
        detail.objectives = local_objectives_struct_v96j_fix1(f);
    end

    detail.CO2 = struct();
    detail.CO2.EF_LPG_kgCO2_per_kWh = EF_LPG_kgCO2_per_kWh;
    detail.CO2.EF_grid_kgCO2_per_kWh = EF_grid_kgCO2_per_kWh;
    detail.CO2.emission_factor_status = emission_factor_status;
    detail.CO2.electricity_data_status = electricity_data_status;
    detail.CO2.water_removed_kg = water_removed_kg;
    detail.CO2.E_electricity_kWh = E_electricity_kWh;
    detail.CO2.CO2_LPG_kg = CO2_LPG_kg;
    detail.CO2.CO2_electricity_kg = CO2_electricity_kg;
    detail.CO2.CO2_total_kg = CO2_total_kg;
    detail.CO2.CO2_specific_kgCO2_per_kgwater = CO2_specific_kgCO2_per_kgwater;
    detail.CO2.scope = "TRIOBJECTIVE_COMPUTATIONAL_VALIDATION_FACTORS_PROVISIONAL";

end

function objectives = local_objectives_struct_v96j_fix1(f)
    objectives = struct();
    objectives.MR_final = f(1);
    objectives.cost_specific_USD_per_kgwater = f(2);
    objectives.CO2_specific_kgCO2_per_kgwater = f(3);
end

function CO2 = local_empty_CO2_v96j_fix1(EF_LPG, EF_grid, factor_status, status)
    CO2 = struct();
    CO2.EF_LPG_kgCO2_per_kWh = EF_LPG;
    CO2.EF_grid_kgCO2_per_kWh = EF_grid;
    CO2.emission_factor_status = factor_status;
    CO2.electricity_data_status = string(status);
    CO2.water_removed_kg = NaN;
    CO2.E_electricity_kWh = NaN;
    CO2.CO2_LPG_kg = NaN;
    CO2.CO2_electricity_kg = NaN;
    CO2.CO2_total_kg = NaN;
    CO2.CO2_specific_kgCO2_per_kgwater = NaN;
    CO2.scope = "PENALIZED_NO_CO2_CLAIM";
end

function val = local_get_numeric_v96j_fix1(S, paths, defaultVal)
    val = defaultVal;
    for k = 1:numel(paths)
        parts = split(string(paths{k}),'.');
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
                val = double(tmp(1));
                return
            end
        catch
        end
    end
end

function val = local_get_string_v96j_fix1(S, paths, defaultVal)
    val = string(defaultVal);
    for k = 1:numel(paths)
        parts = split(string(paths{k}),'.');
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
