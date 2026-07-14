function results = initialize_results(params)
%INITIALIZE_RESULTS Create standard empty results structure.
    results.meta.run_id = string(params.run_id);
    results.meta.product = string(params.project.product_label);
    results.meta.model_version = string(params.project.version);
    results.meta.created_at = datetime("now");
    results.operation = params.operation;
    results.ga.x=[]; results.ga.fval=[]; results.ga.population=[]; results.ga.scores=[]; results.ga.output=[]; results.ga.exitflag=[]; results.ga.history=[];
    results.ga.lb=params.ga.lb; results.ga.ub=params.ga.ub; results.ga.population_size=params.ga.population_size; results.ga.max_generations=params.ga.max_generations; results.ga.rng_seed=params.ga.rng_seed; results.ga.decision_vector=params.ga.decision_vector;
    results.energy.Q_aux_tot=[]; results.energy.Q_aux_enabled=params.operation.Q_aux_enabled; results.energy.dry_time=[]; results.energy.Irradiacion=[]; results.energy.E_capt_total=[]; results.energy.I_raw_profile=[]; results.energy.I_effective_profile=[];
    results.moisture.M_final=[]; results.moisture.MR_final=[]; results.moisture.M_des=params.product.M_des; results.moisture.Mf=params.product.Mf; results.moisture.water_removed_target_kg=params.product.water_removed_target_kg; results.moisture.water_removed_simulated_kg=[];
    results.moisture.stop_criterion=string(params.model.stop_criterion); results.moisture.stop_threshold=params.model.stop_threshold; results.moisture.stop_criterion_reached=false; results.moisture.stop_reason="not_evaluated"; results.moisture.evaluation_horizon_h=params.model.evaluation_horizon_h; results.moisture.allow_incomplete_drying=params.model.allow_incomplete_drying;
    results.moisture.fraction_of_target_water_removed=[]; results.moisture.moisture_gap_to_target=[]; results.moisture.MR_gap_to_target=[]; results.moisture.average_water_removal_rate_kg_h=[];
    results.cost.scenario=string(params.cost.scenario); results.cost.C_kWh_MXN=params.cost.C_kWh_MXN; results.cost.C_GLP_MXN_per_MJ=params.cost.C_GLP_MXN_per_MJ; results.cost.exchange_rate_MXN_per_USD=params.cost.exchange_rate_MXN_per_USD; results.cost.cost_total_MXN=[]; results.cost.cost_specific_USD_per_kg_water=[];
    results.environment.scope=string(params.environment.scope); results.environment.CO2_total=[]; results.environment.CO2_specific_per_kg_water=[];
    results.weather=params.weather; results.weather.T_amb_profile=[]; results.weather.RH_amb_profile=[]; results.weather.I_raw_profile=[]; results.weather.I_effective_profile=[];
    results.convergence.history=[]; results.convergence.n_nan_scores=[]; results.convergence.n_inf_scores=[];
    results.diagnostics.status="initialized"; results.diagnostics.errors={}; results.diagnostics.warnings={}; results.diagnostics.is_valid_for_article=false;
end
