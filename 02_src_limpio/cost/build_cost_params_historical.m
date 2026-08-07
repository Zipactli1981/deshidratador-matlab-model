function params_cost = build_cost_params_historical()
%BUILD_COST_PARAMS_HISTORICAL Cost parameters with explicit units.
%
% COST-B-001 / AUD-COST-AB-001
%
% Purpose:
%   Preserve the established function interface while centralizing the
%   coordinated June-2026 economic basis used by the active objective.
%
% The historical thesis-era values remain documented in COST-E2/COST-E3.
% They are not active constants in this coordinated implementation.

    params_cost.created_by_function = "build_cost_params_historical";
    params_cost.created_at = datetime("now");

    params_cost.exchange_rate_MXN_per_USD = 17.3819136364;

    params_cost.burner_efficiency = 0.78;
    params_cost.LPG_LHV_MJ_per_kg = 46.16;
    params_cost.LPG_price_MXN_per_kg = 19.46;
    params_cost.LPG_price_USD_per_kg = 1.1195545213;
    params_cost.C_solar_USD_per_MJ = 0.0126515761642454;
    params_cost.C_electricity_USD_per_kWh = 0.0717182253966247;
    params_cost.W_comp_kW = 1.03;

    % Established output fields retained with the coordinated basis.
    params_cost.C_electricity_MXN_per_kWh = ...
        params_cost.C_electricity_USD_per_kWh * ...
        params_cost.exchange_rate_MXN_per_USD;
    params_cost.C_GLP_MXN_per_MJ = ...
        params_cost.LPG_price_MXN_per_kg / params_cost.LPG_LHV_MJ_per_kg;
    params_cost.C_GLP_USD_per_MJ = ...
        params_cost.LPG_price_USD_per_kg / params_cost.LPG_LHV_MJ_per_kg;
    params_cost.C_solar_MXN_per_MJ = ...
        params_cost.C_solar_USD_per_MJ * ...
        params_cost.exchange_rate_MXN_per_USD;

    params_cost.internal_currency = "USD";
    params_cost.C_kWh_internal = params_cost.C_electricity_USD_per_kWh;
    % Compatibility alias only; the active LPG cost chain uses fuel mass.
    params_cost.C_esp_GLP_internal = params_cost.C_GLP_USD_per_MJ;
    params_cost.C_solar_internal = params_cost.C_solar_USD_per_MJ;

    params_cost.units.C_kWh_internal = "USD/kWh";
    params_cost.units.C_esp_GLP_internal = "USD/MJ";
    params_cost.units.C_solar_internal = "USD/MJ";
    params_cost.units.burner_efficiency = "dimensionless";
    params_cost.units.LPG_LHV_MJ_per_kg = "MJ/kg LPG";
    params_cost.units.LPG_price_MXN_per_kg = "MXN/kg LPG";
    params_cost.units.LPG_price_USD_per_kg = "USD/kg LPG";
    params_cost.units.W_comp_kW = "kW";
    params_cost.units.dry_time = "h";
    params_cost.units.Q_aux_tot = "MJ";
    params_cost.units.Irradiacion = "MJ";
    params_cost.units.water_removed_kg = "kg water";
    params_cost.denominator_definition = "(Mi - M_terminal) * md";

    assert(params_cost.exchange_rate_MXN_per_USD > 0);
    assert(params_cost.burner_efficiency > 0 && params_cost.burner_efficiency <= 1);
    assert(params_cost.LPG_LHV_MJ_per_kg > 0);
    assert(params_cost.W_comp_kW > 0);
end
