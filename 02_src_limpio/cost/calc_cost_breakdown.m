function cost = calc_cost_breakdown(dry_time, Q_aux_tot, Irradiacion, Mi, M, md, params_cost)
%CALC_COST_BREAKDOWN Traceable reconstruction of the historical cost objective.
%
% COST-B-001
%
% Historical formula reproduced:
%
% f_obj = (W_comp*dry_time*C_kWh + ...
%          Q_aux_tot*C_esp_GLP + ...
%          Irradiacion*C_solar) / ((Mi-M)*md);
%
% where:
%   W_comp       [kW]
%   dry_time     [h]
%   C_kWh        [USD/kWh]
%   Q_aux_tot    [MJ]
%   C_esp_GLP    [USD/MJ]
%   Irradiacion  [MJ]
%   C_solar      [USD/MJ]
%   Mi, M        [kg water/kg dry solid]
%   md           [kg dry solid]
%
% Denominator:
%   water_removed_kg = (Mi - M) * md
%
% This function does not modify the physical model, kinetics or cost formula.

    cost.created_by_function = "calc_cost_breakdown";
    cost.created_at = datetime("now");

    cost.inputs.dry_time = dry_time;
    cost.inputs.Q_aux_tot = Q_aux_tot;
    cost.inputs.Irradiacion = Irradiacion;
    cost.inputs.Mi = Mi;
    cost.inputs.M = M;
    cost.inputs.md = md;

    cost.exchange_rate_MXN_per_USD = params_cost.exchange_rate_MXN_per_USD;

    cost.C_kWh_internal = params_cost.C_kWh_internal;
    cost.C_esp_GLP_internal = params_cost.C_esp_GLP_internal;
    cost.C_solar_internal = params_cost.C_solar_internal;

    cost.units.C_kWh_internal = params_cost.units.C_kWh_internal;
    cost.units.C_esp_GLP_internal = params_cost.units.C_esp_GLP_internal;
    cost.units.C_solar_internal = params_cost.units.C_solar_internal;

    cost.electric_energy_kWh = params_cost.W_comp_kW * dry_time;
    cost.electric_cost_USD = cost.electric_energy_kWh * ...
        params_cost.C_kWh_internal;

    cost.LPG_energy_MJ = Q_aux_tot;
    cost.LPG_cost_USD = cost.LPG_energy_MJ * ...
        params_cost.C_esp_GLP_internal;

    cost.solar_energy_MJ = Irradiacion;
    cost.solar_cost_USD = cost.solar_energy_MJ * ...
        params_cost.C_solar_internal;

    cost.total_cost_USD = cost.electric_cost_USD + ...
        cost.LPG_cost_USD + cost.solar_cost_USD;

    cost.water_removed_kg = (Mi - M) * md;

    if cost.water_removed_kg <= 0
        cost.cost_specific_USD_per_kgwater = NaN;
        cost.status = "INVALID_DENOMINATOR";
    else
        cost.cost_specific_USD_per_kgwater = ...
            cost.total_cost_USD / cost.water_removed_kg;
        cost.status = "OK";
    end

    cost.denominator_definition = "(Mi - M) * md";
    cost.units.electric_energy_kWh = "kWh";
    cost.units.electric_cost_USD = "USD";
    cost.units.LPG_energy_MJ = "MJ";
    cost.units.LPG_cost_USD = "USD";
    cost.units.solar_energy_MJ = "MJ";
    cost.units.solar_cost_USD = "USD";
    cost.units.total_cost_USD = "USD";
    cost.units.water_removed_kg = "kg water";
    cost.units.cost_specific_USD_per_kgwater = "USD/kg water";
end
