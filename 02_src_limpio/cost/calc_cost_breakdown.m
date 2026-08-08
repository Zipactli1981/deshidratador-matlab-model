function cost = calc_cost_breakdown(dry_time, Q_aux_tot, Irradiacion, Mi, M, md, params_cost)
%CALC_COST_BREAKDOWN Traceable coordinated cost-objective calculation.
%
% COST-B-001
%
% Active coordinated formula:
%
% Q_LPG_input_MJ = Q_aux_tot / burner_efficiency
% LPG_mass_kg = Q_LPG_input_MJ / LPG_LHV_MJ_per_kg
% f_obj = (W_comp*dry_time*C_kWh + ...
%          LPG_mass_kg*LPG_price_USD_per_kg + ...
%          Irradiacion*C_solar) / ((Mi-M_terminal)*md);
%
% where:
%   W_comp       [kW]
%   dry_time     [h]
%   C_kWh        [USD/kWh]
%   Q_aux_tot    [MJ useful supplementary thermal energy]
%   Irradiacion  [MJ]
%   C_solar      [USD/MJ]
%   Mi, M        [kg water/kg dry solid]
%   md           [kg dry solid]
%
% Denominator:
%   water_removed_kg = (Mi - M_terminal) * md
%
% M and dry_time are supplied by the same normal/TMAX terminal endpoint.

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

    cost.Q_aux_useful_MJ = Q_aux_tot;
    cost.LPG_fuel_input_MJ = cost.Q_aux_useful_MJ / ...
        params_cost.burner_efficiency;
    cost.LPG_mass_kg = cost.LPG_fuel_input_MJ / ...
        params_cost.LPG_LHV_MJ_per_kg;
    cost.LPG_cost_USD = cost.LPG_mass_kg * ...
        params_cost.LPG_price_USD_per_kg;
    % Compatibility name retained; its basis is now fuel-input energy.
    cost.LPG_energy_MJ = cost.LPG_fuel_input_MJ;

    cost.solar_energy_MJ = Irradiacion;
    cost.solar_cost_USD = cost.solar_energy_MJ * ...
        params_cost.C_solar_internal;

    cost.total_cost_USD = cost.electric_cost_USD + ...
        cost.LPG_cost_USD + cost.solar_cost_USD;

    cost.M_terminal = M;
    cost.mwi_kg = Mi * md;
    cost.mw_terminal_kg = cost.M_terminal * md;
    cost.water_removed_kg = (Mi - cost.M_terminal) * md;
    cost.water_removed_kg_check = cost.mwi_kg - cost.mw_terminal_kg;

    if cost.water_removed_kg <= 0
        cost.cost_specific_USD_per_kgwater = NaN;
        cost.status = "INVALID_DENOMINATOR";
    else
        cost.cost_specific_USD_per_kgwater = ...
            cost.total_cost_USD / cost.water_removed_kg;
        cost.status = "OK";
    end

    cost.denominator_definition = "(Mi - M_terminal) * md";
    cost.units.electric_energy_kWh = "kWh";
    cost.units.electric_cost_USD = "USD";
    cost.units.LPG_energy_MJ = "MJ";
    cost.units.Q_aux_useful_MJ = "MJ useful thermal";
    cost.units.LPG_fuel_input_MJ = "MJ fuel input";
    cost.units.LPG_mass_kg = "kg LPG";
    cost.units.LPG_cost_USD = "USD";
    cost.units.solar_energy_MJ = "MJ";
    cost.units.solar_cost_USD = "USD";
    cost.units.total_cost_USD = "USD";
    cost.units.water_removed_kg = "kg water";
    cost.units.M_terminal = "kg water/kg dry solid";
    cost.units.mwi_kg = "kg water";
    cost.units.mw_terminal_kg = "kg water";
    cost.units.water_removed_kg_check = "kg water";
    cost.units.cost_specific_USD_per_kgwater = "USD/kg water";
end
