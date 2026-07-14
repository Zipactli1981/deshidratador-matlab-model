# LOCATE_COLLECTOR_EFFICIENCY_BALANCE_v96z

## Diagnosis

`COLLECTOR_EFFICIENCY_AND_SOLAR_BALANCE_CANDIDATES_FOUND`

## Decision

`INSPECT_TOP_FILES_BEFORE_SURGICAL_MODIFICATION`

## Next step

`Open top-ranked files and identify exact eta_col/Qsolar/Tin/Tout/Tamb/G/mdot/cp variables.`

## Top candidate files

| rank | file | n_eta | n_Qsolar | n_temp | n_flowcp | score |
|---:|---|---:|---:|---:|---:|---:|
| 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\locate_collector_efficiency_balance_v96z.m` | 32 | 52 | 30 | 77 | 582 |
| 2 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v13_internal_state_trace.m` | 9 | 41 | 47 | 54 | 411 |
| 3 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\solar_daylight_one_day_replay_instrumented_v96nf.m` | 0 | 85 | 29 | 5 | 408 |
| 4 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v16_nonphysical_penalty.m` | 9 | 27 | 51 | 54 | 363 |
| 5 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v17_nonphysical_penalty.m` | 9 | 24 | 49 | 54 | 347 |
| 6 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v18_endpoint_TMAX_corrected.m` | 9 | 24 | 49 | 54 | 347 |
| 7 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v10_energy_mode_corrected.m` | 9 | 21 | 47 | 54 | 331 |
| 8 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v11_solar_tmax_closure_fixed.m` | 9 | 21 | 47 | 54 | 331 |
| 9 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v12_index_audit.m` | 9 | 21 | 47 | 54 | 331 |
| 10 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v14_full_workspace_trace.m` | 9 | 21 | 47 | 54 | 331 |
| 11 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v15_nonphysical_guard.m` | 9 | 21 | 47 | 54 | 331 |
| 12 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v06_data_controlled.m` | 9 | 20 | 47 | 54 | 327 |
| 13 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\implement_nonphysical_penalty_wrapper_v628.m` | 0 | 66 | 10 | 3 | 290 |
| 14 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\implement_nonphysical_penalty_wrapper_v628b.m` | 0 | 60 | 8 | 3 | 262 |
| 15 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_formal_ga_v93g.m` | 0 | 59 | 3 | 2 | 246 |
| 16 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\wrapper_internal_state_trace_v624.m` | 0 | 47 | 5 | 3 | 204 |
| 17 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\solar_nonphysical_state_guard_v626.m` | 0 | 45 | 7 | 4 | 202 |
| 18 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\package_triobjective_formal_results_v96q.m` | 0 | 39 | 13 | 8 | 198 |
| 19 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_smoke_ga_v91g.m` | 0 | 45 | 3 | 6 | 198 |
| 20 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\solar_hybrid_dominance_trace_v625.m` | 0 | 39 | 6 | 5 | 178 |

## Efficiency hits sample

| file | line | pattern | text |
|---|---:|---|---|
| `compare_operation_modes.m` | 23 | `0.5` | `[0; 0.5], ...` |
| `setup_v05_paths.m` | 2 | `0.5` | `%SETUP_V05_PATHS Configure the controlled v0.5/v0.6/v0.7/v0.8 MATLAB path.` |
| `capture_productive_ga_outputs_v614.m` | 18 | `0.5` | `0.11 55 0.50 3` |
| `implement_tmax_endpoint_correction_clone_v95j.m` | 319 | `0.5` | `reduction_Q_aux_pct > 1 && abs(delta_dry_time) <= 0.5 && abs(delta_MR) <= 0.02, ...` |
| `locate_collector_efficiency_balance_v96z.m` | 1 | `efficiency` | `function loc = locate_collector_efficiency_balance_v96z()` |
| `locate_collector_efficiency_balance_v96z.m` | 2 | `efficiency` | `% LOCATE_COLLECTOR_EFFICIENCY_BALANCE_v96z` |
| `locate_collector_efficiency_balance_v96z.m` | 5 | `efficiency` | `% LOCATE-FIXED-COLLECTOR-EFFICIENCY-AND-SOLAR-BALANCE-001` |
| `locate_collector_efficiency_balance_v96z.m` | 12 | `eta_col` | `%   1) eficiencia fija del colector, eta_col ~ 0.5` |
| `locate_collector_efficiency_balance_v96z.m` | 12 | `0.5` | `%   1) eficiencia fija del colector, eta_col ~ 0.5` |
| `locate_collector_efficiency_balance_v96z.m` | 12 | `eficiencia` | `%   1) eficiencia fija del colector, eta_col ~ 0.5` |
| `locate_collector_efficiency_balance_v96z.m` | 42 | `eta_col` | `"eta_col"` |
| `locate_collector_efficiency_balance_v96z.m` | 43 | `etha_col` | `"etha_col"` |
| `locate_collector_efficiency_balance_v96z.m` | 44 | `etaCollector` | `"etaCollector"` |
| `locate_collector_efficiency_balance_v96z.m` | 45 | `eta_col` | `"eta_collector"` |
| `locate_collector_efficiency_balance_v96z.m` | 45 | `eta_collector` | `"eta_collector"` |
| `locate_collector_efficiency_balance_v96z.m` | 46 | `eta_solar` | `"eta_solar"` |
| `locate_collector_efficiency_balance_v96z.m` | 47 | `etaSAH` | `"etaSAH"` |
| `locate_collector_efficiency_balance_v96z.m` | 48 | `eta_AH` | `"eta_AH"` |
| `locate_collector_efficiency_balance_v96z.m` | 49 | `eta = 0.5` | `"eta = 0.5"` |
| `locate_collector_efficiency_balance_v96z.m` | 49 | `0.5` | `"eta = 0.5"` |
| `locate_collector_efficiency_balance_v96z.m` | 50 | `eta=0.5` | `"eta=0.5"` |
| `locate_collector_efficiency_balance_v96z.m` | 50 | `0.5` | `"eta=0.5"` |
| `locate_collector_efficiency_balance_v96z.m` | 51 | `0.5` | `"0.5"` |
| `locate_collector_efficiency_balance_v96z.m` | 52 | `50%` | `"50%"` |
| `locate_collector_efficiency_balance_v96z.m` | 53 | `eficiencia` | `"eficiencia"` |

## Solar-energy hits sample

| file | line | pattern | text |
|---|---:|---|---|
| `audit_static_hybrid_irradiance.m` | 1 | `irradiance` | `function report = audit_static_hybrid_irradiance(project_root)` |
| `audit_static_hybrid_irradiance.m` | 2 | `irradiance` | `%AUDIT_STATIC_HYBRID_IRRADIANCE Static scan for irradiance nulling.` |
| `audit_static_hybrid_irradiance.m` | 7 | `irradiance` | `% This is diagnostic only. If hybrid irradiance is actually corrected, that` |
| `audit_static_hybrid_irradiance.m` | 15 | `irradiance` | `report.created_by_function = "audit_static_hybrid_irradiance";` |
| `audit_static_hybrid_irradiance.m` | 22 | `Irradiacion` | `patterns = ["I(i)=0", "I(i) = 0", "I = 0", "Irradiacion = 0", "I_effective = 0"];` |
| `audit_static_hybrid_irradiance.m` | 22 | `irradiacion` | `patterns = ["I(i)=0", "I(i) = 0", "I = 0", "Irradiacion = 0", "I_effective = 0"];` |
| `audit_static_hybrid_irradiance.m` | 22 | `radiacion` | `patterns = ["I(i)=0", "I(i) = 0", "I = 0", "Irradiacion = 0", "I_effective = 0"];` |
| `audit_static_hybrid_irradiance.m` | 46 | `irradiance` | `report.status = "NO_STATIC_IRRADIANCE_NULLING_PATTERN_FOUND";` |
| `audit_static_hybrid_irradiance.m` | 48 | `irradiance` | `report.status = "STATIC_IRRADIANCE_NULLING_PATTERN_FOUND";` |
| `audit_static_interface_tunel.m` | 5 | `G ` | `report.note="Inspect opt_tunel_mod2 and tunel_mod2. Full .mlx static parsing may require MATLAB local unzip/text review.";` |
| `compare_operation_modes.m` | 35 | `Irradiacion` | `out_Irradiacion = [];` |
| `compare_operation_modes.m` | 35 | `irradiacion` | `out_Irradiacion = [];` |
| `compare_operation_modes.m` | 35 | `radiacion` | `out_Irradiacion = [];` |
| `compare_operation_modes.m` | 62 | `Irradiacion` | `[Q_aux_tot, dry_time, M, MR, Irradiacion, irr_diag] = ...` |
| `compare_operation_modes.m` | 62 | `irradiacion` | `[Q_aux_tot, dry_time, M, MR, Irradiacion, irr_diag] = ...` |
| `compare_operation_modes.m` | 62 | `radiacion` | `[Q_aux_tot, dry_time, M, MR, Irradiacion, irr_diag] = ...` |
| `compare_operation_modes.m` | 82 | `Irradiacion` | `out_Irradiacion(end+1,1) = Irradiacion;` |
| `compare_operation_modes.m` | 82 | `irradiacion` | `out_Irradiacion(end+1,1) = Irradiacion;` |
| `compare_operation_modes.m` | 82 | `radiacion` | `out_Irradiacion(end+1,1) = Irradiacion;` |
| `compare_operation_modes.m` | 92 | `Irradiacion` | `out_Irradiacion, out_Q_aux_tot, out_dry_time, out_M, out_MR, out_status, ...` |
| `compare_operation_modes.m` | 92 | `irradiacion` | `out_Irradiacion, out_Q_aux_tot, out_dry_time, out_M, out_MR, out_status, ...` |
| `compare_operation_modes.m` | 92 | `radiacion` | `out_Irradiacion, out_Q_aux_tot, out_dry_time, out_M, out_MR, out_status, ...` |
| `compare_operation_modes.m` | 94 | `Irradiacion` | `'Irradiacion','Q_aux_tot','dry_time','M','MR','drying_status'} );` |
| `compare_operation_modes.m` | 94 | `irradiacion` | `'Irradiacion','Q_aux_tot','dry_time','M','MR','drying_status'} );` |
| `compare_operation_modes.m` | 94 | `radiacion` | `'Irradiacion','Q_aux_tot','dry_time','M','MR','drying_status'} );` |

## Temperature hits sample

| file | line | pattern | text |
|---|---:|---|---|
| `build_base_params.m` | 27 | `T_amb` | `params_base.weather.T_amb_column = [];` |
| `setup_v05_paths.m` | 7 | `Tin` | `%   - historical conflicting scripts` |
| `approve_guarded_formal_run_execution_v94g.m` | 274 | `Tin` | `row.condition = "Computer instability, overheating, sleep risk";` |
| `approve_guarded_formal_run_execution_v94g.m` | 291 | `Tin` | `Tinterrupt = struct2table(vertcat(interruptRows{:}));` |
| `approve_guarded_formal_run_execution_v94g.m` | 336 | `Tin` | `outInterruptCsv = fullfile(tablesDir,'GUARDED_FORMAL_RUN_EXECUTION_APPROVAL_v94g_interrupt_conditions.csv');` |
| `approve_guarded_formal_run_execution_v94g.m` | 339 | `Tin` | `writetable(Tinterrupt,outInterruptCsv);` |
| `approve_guarded_formal_run_execution_v94g.m` | 345 | `Tin` | `'Tchecklist','Tinterrupt','Tpending','preflightFlags', ...` |
| `approve_guarded_formal_run_execution_v94g.m` | 347 | `Tin` | `'outMd','outTxt','outMat','outChecklistCsv','outInterruptCsv');` |
| `approve_guarded_formal_run_execution_v94g.m` | 404 | `Tin` | `for i = 1:height(Tinterrupt)` |
| `approve_guarded_formal_run_execution_v94g.m` | 406 | `Tin` | `string(Tinterrupt.condition(i)), ...` |
| `approve_guarded_formal_run_execution_v94g.m` | 407 | `Tin` | `string(Tinterrupt.action(i)), ...` |
| `approve_guarded_formal_run_execution_v94g.m` | 408 | `Tin` | `string(Tinterrupt.severity(i)));` |
| `approve_guarded_formal_run_execution_v94g.m` | 462 | `Tin` | `fprintf(fid,'outInterruptCsv: %s\n', outInterruptCsv);` |
| `approve_guarded_formal_run_execution_v94g.m` | 483 | `Tin` | `approval.Tinterrupt = Tinterrupt;` |
| `approve_guarded_formal_run_execution_v94g.m` | 492 | `Tin` | `approval.outInterruptCsv = outInterruptCsv;` |
| `approve_guarded_formal_run_execution_v94g.m` | 507 | `Tin` | `disp(approval.Tinterrupt)` |
| `approve_triobjective_formal_run_execution_v96n.m` | 365 | `Tin` | `fprintf(fid,'Después de terminar, continuar con '9.6o — TRIOBJECTIVE-FORMAL-POSTRUN-CONSOLIDATION-001'.\n');` |
| `audit_ga_sufficiency_convergence_v96z.m` | 187 | `Tin` | `"No hay corridas formales adicionales con semillas distintas."; ...` |
| `audit_ga_sufficiency_convergence_v96z.m` | 244 | `Tin` | `recommended_if_article_target = "Ejecutar 2-3 réplicas con distinta semilla o una corrida media con PopulationSize=32 y MaxGenerations=80.";` |
| `audit_ga_sufficiency_convergence_v96z.m` | 491 | `Tin` | `lines(end+1) = "La selección de H2 debe entenderse como una decisión operativa dentro del frente calculado, no como una prueba de optimalidad global absoluta. Para fortalecer la robustez algorítmica de la selección, sería conveniente realizar corridas adicionales con semillas distintas o una evaluación de sensibilidad de parámetros del algoritmo genético.";` |
| `audit_internal_rng_v96m_v96z_rngfix.m` | 1 | `T_in` | `function audit = audit_internal_rng_v96m_v96z_rngfix()` |
| `audit_internal_rng_v96m_v96z_rngfix.m` | 2 | `T_in` | `% AUDIT_INTERNAL_RNG_v96m_v96z_rngfix` |
| `audit_internal_rng_v96m_v96z_rngfix.m` | 129 | `T_in` | `hitsCsv = fullfile(articleTablesDir,'audit_internal_rng_v96m_v96z_rngfix_hits.csv');` |
| `audit_internal_rng_v96m_v96z_rngfix.m` | 130 | `T_in` | `checksCsv = fullfile(articleTablesDir,'audit_internal_rng_v96m_v96z_rngfix_checks.csv');` |
| `audit_internal_rng_v96m_v96z_rngfix.m` | 135 | `T_in` | `reportMd = fullfile(articleReviewDir,'AUDIT_INTERNAL_RNG_v96m_v96z_rngfix.md');` |

## Flow/Cp hits sample

| file | line | pattern | text |
|---|---:|---|---|
| `compare_operation_modes.m` | 26 | `m_max` | `'VariableNames', {'case_id','m_max','T_min','r_div2','t_rec_ini','W0'} );` |
| `compare_operation_modes.m` | 43 | `m_max` | `m_max = cases.m_max(c);` |
| `compare_operation_modes.m` | 64 | `m_max` | `m_max, T_min, r_div2, t_rec_ini, ...` |
| `build_base_params.m` | 18 | `m_max` | `params_base.ga.decision_vector = ["m_max","T_min","r_div2","t_rec_ini"];` |
| `approve_triobjective_formal_run_execution_v96n.m` | 477 | `m_max` | `row.m_max = x(1);` |
| `audit_gaopts_v96z_before_formal_run.m` | 147 | `m_max` | `add_ga_row("decision_variables","4","m_max, T_min, r_div2, t_rec_ini.");` |
| `audit_gaopts_v96z_before_formal_run.m` | 196 | `m_max` | `varNames = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];` |
| `audit_gaopts_v96z_before_formal_run.m` | 204 | `flow` | `"Air mass flow or control variable used by model";` |
| `audit_gaopts_v96z_before_formal_run.m` | 219 | `flow` | `"Air mass flow or control variable used by model";` |
| `audit_gaopts_v96z_before_formal_run_BACKUP_BEFORE_SOURCE_EXTRACT_20260630_154613.m` | 147 | `m_max` | `add_ga_row("decision_variables","4","m_max, T_min, r_div2, t_rec_ini.");` |
| `audit_gaopts_v96z_before_formal_run_BACKUP_BEFORE_SOURCE_EXTRACT_20260630_154613.m` | 196 | `m_max` | `varNames = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];` |
| `audit_gaopts_v96z_before_formal_run_BACKUP_BEFORE_SOURCE_EXTRACT_20260630_154613.m` | 204 | `flow` | `"Air mass flow or control variable used by model";` |
| `audit_gaopts_v96z_before_formal_run_BACKUP_BEFORE_SOURCE_EXTRACT_20260630_154613.m` | 219 | `flow` | `"Air mass flow or control variable used by model";` |
| `audit_gaopts_v96z_before_formal_run_f2.m` | 101 | `m_max` | `addrow('decision_variables','4','m_max, T_min, r_div2, t_rec_ini.');` |
| `audit_gaopts_v96z_before_formal_run_f2.m` | 127 | `m_max` | `varNames = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];` |
| `audit_gaopts_v96z_before_formal_run_f2.m` | 129 | `flow` | `"Air mass flow or control variable used by model";` |
| `audit_gaopts_v96z_before_formal_run_f4.m` | 105 | `m_max` | `addrow('decision_variables','4','m_max, T_min, r_div2, t_rec_ini.');` |
| `audit_gaopts_v96z_before_formal_run_f4.m` | 139 | `m_max` | `variable = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];` |
| `audit_model_article_readiness_v96z.m` | 111 | `m_max` | `variable = ["m_max"; "T_min"; "r_div2"; "t_rec_ini"];` |
| `audit_model_article_readiness_v96z.m` | 113 | `flow` | `"Decision variable 1; air-flow/control variable as used by model."` |
| `audit_model_article_readiness_v96z.m` | 235 | `flow` | `figRows{end+1,1} = fig_row("Figure 1","Model/workflow schematic","Use source audit + narrative","Requires drawing","Methods.");` |
| `audit_solar_mode_wrapper_v619.m` | 90 | `m_max` | `x_selected = [Tsel.m_max(1), Tsel.T_min(1), Tsel.r_div2(1), Tsel.t_rec_ini(1)];` |
| `audit_solar_mode_wrapper_v619.m` | 112 | `m_max` | `row.m_max = x_selected(1);` |
| `audit_solar_mode_wrapper_v619.m` | 134 | `m_max` | `row.m_max = x_selected(1);` |
| `capture_productive_ga_outputs_v614b.m` | 61 | `m_max` | `'VariableNames', {'m_max','T_min','r_div2','t_rec_ini'});` |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `L01` | MATLAB source files found | 1 | `163` |
| `L02` | Efficiency-pattern hits found | 1 | `134` |
| `L03` | Solar-energy-pattern hits found | 1 | `2547` |
| `L04` | Temperature-pattern hits found | 1 | `953` |
| `L05` | Flow/Cp-pattern hits found | 1 | `930` |
| `L06` | Ranked candidate files available | 1 | `152` |
| `L07` | Top context extracted | 1 | `1200` |
| `L08` | No GA executed | 1 | `Static code inspection only.` |
| `L09` | No source modified | 1 | `Read-only audit.` |

## Interpretation

This audit only locates candidate code blocks. Do not modify the model until the exact algebraic solar balance has been identified.
