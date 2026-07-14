function params_cost = build_cost_params_historical()
%BUILD_COST_PARAMS_HISTORICAL Historical cost parameters with explicit units.
%
% COST-B-001 / AUD-COST-AB-001
%
% Purpose:
%   Centralize the historical economic constants used to reconstruct the
%   cost objective without changing the historical model.
%
% Historical MXN values:
%   Electricity: 1.48 MXN/kWh
%   LPG:         0.778 MXN/MJ
%   Solar:       0.15 MXN/MJ
%
% Historical internal objective values observed in workspace:
%   C_kWh     = 0.0878
%   C_esp_GLP = 0.0462
%   C_solar   = 0.0089
%
% These are consistent with division by:
%   exchange_rate_MXN_per_USD = 16.85
%
% Therefore the internal economic objective is documented as USD-based:
%   C_kWh     in USD/kWh
%   C_esp_GLP in USD/MJ
%   C_solar   in USD/MJ

    params_cost.created_by_function = "build_cost_params_historical";
    params_cost.created_at = datetime("now");

    params_cost.exchange_rate_MXN_per_USD = 16.85;

    params_cost.C_electricity_MXN_per_kWh = 1.48;
    params_cost.C_GLP_MXN_per_MJ = 0.778;
    params_cost.C_solar_MXN_per_MJ = 0.15;

    params_cost.C_electricity_USD_per_kWh = ...
        params_cost.C_electricity_MXN_per_kWh / ...
        params_cost.exchange_rate_MXN_per_USD;

    params_cost.C_GLP_USD_per_MJ = ...
        params_cost.C_GLP_MXN_per_MJ / ...
        params_cost.exchange_rate_MXN_per_USD;

    params_cost.C_solar_USD_per_MJ = ...
        params_cost.C_solar_MXN_per_MJ / ...
        params_cost.exchange_rate_MXN_per_USD;

    params_cost.W_comp_kW = 3 * 0.746;

    params_cost.internal_currency = "USD";
    params_cost.C_kWh_internal = params_cost.C_electricity_USD_per_kWh;
    params_cost.C_esp_GLP_internal = params_cost.C_GLP_USD_per_MJ;
    params_cost.C_solar_internal = params_cost.C_solar_USD_per_MJ;

    params_cost.units.C_kWh_internal = "USD/kWh";
    params_cost.units.C_esp_GLP_internal = "USD/MJ";
    params_cost.units.C_solar_internal = "USD/MJ";
    params_cost.units.W_comp_kW = "kW";
    params_cost.units.dry_time = "h";
    params_cost.units.Q_aux_tot = "MJ";
    params_cost.units.Irradiacion = "MJ";
    params_cost.units.water_removed_kg = "kg water";
    params_cost.denominator_definition = "(Mi - M) * md";

    assert(params_cost.exchange_rate_MXN_per_USD > 0);
    assert(params_cost.W_comp_kW > 0);
end
