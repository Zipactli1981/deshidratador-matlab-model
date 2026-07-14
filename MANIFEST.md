# MANIFEST

## Módulos nuevos implementados

| Archivo | Ruta | Estado | Uso |
|---|---|---|---|
| build_base_params.m | 02_src_limpio/config/ | Implementado | params_base |
| build_mode_params.m | 02_src_limpio/config/ | Implementado | params por modo |
| checklist_rapido_pre_run.m | 02_src_limpio/validation/ | Implementado | pre-run |
| initialize_results.m | 02_src_limpio/results/ | Implementado | results |
| ga_history_output_controlado.m | 02_src_limpio/ga/ | Implementado | historial AG |
| post_run_report.m | 02_src_limpio/validation/ | Implementado | post-run |
| build_cost_params_historical.m | 02_src_limpio/cost/ | Implementado | costos históricos |
| calc_cost_breakdown.m | 02_src_limpio/cost/ | Implementado | desglose costo |
| audit_static_interface_tunel.m | 02_src_limpio/audit/ | Implementado | auditoría interfaz |
| audit_static_hybrid_irradiance.m | 02_src_limpio/audit/ | Implementado | auditoría irradiancia |
| audit_cost_trace_AB.m | 02_src_limpio/audit/ | Plantilla | A/B costo |

## Código original integrado

| Archivo | Ruta original | Ruta paquete | Categoría |
|---|---|---|---|
| opt_fun2.mlx | 2ndo modeloV(piña)/opt_fun2.mlx | 03_original_model/01_active_original/opt_fun2.mlx | active_original |
| temperature_AirH2O.m | 2ndo modeloV(piña)/temperature_AirH2O.m | 03_original_model/02_psychrometrics/temperature_AirH2O.m | psychrometrics |
| scores_HB200trec.mat | 2ndo modeloV(piña)/scores_HB200trec.mat | 03_original_model/05_outputs_historicos/scores_HB200trec.mat | historical_outputs |
| final_pop_GLP155final.mat | 2ndo modeloV(piña)/final_pop_GLP155final.mat | 03_original_model/05_outputs_historicos/final_pop_GLP155final.mat | historical_outputs |
| liveoptfun.mlx | 2ndo modeloV(piña)/liveoptfun.mlx | 03_original_model/99_legacy_do_not_run/liveoptfun.mlx | legacy_do_not_run |
| scores_377.mat | 2ndo modeloV(piña)/scores_377.mat | 03_original_model/05_outputs_historicos/scores_377.mat | historical_outputs |
| final_pop_GLP50.mat | 2ndo modeloV(piña)/final_pop_GLP50.mat | 03_original_model/05_outputs_historicos/final_pop_GLP50.mat | historical_outputs |
| scores_GLP50.mat | 2ndo modeloV(piña)/scores_GLP50.mat | 03_original_model/05_outputs_historicos/scores_GLP50.mat | historical_outputs |
| EDO_Hossain2.mlx | 2ndo modeloV(piña)/EDO_Hossain2.mlx | 03_original_model/99_legacy_do_not_run/EDO_Hossain2.mlx | legacy_do_not_run |
| run_Interpola.mlx | 2ndo modeloV(piña)/run_Interpola.mlx | 03_original_model/99_legacy_do_not_run/run_Interpola.mlx | legacy_do_not_run |
| Antoine_agua.m | 2ndo modeloV(piña)/Antoine_agua.m | 03_original_model/02_psychrometrics/Antoine_agua.m | psychrometrics |
| Mass_behavior.txt | 2ndo modeloV(piña)/Mass_behavior.txt | 03_original_model/04_data_original/Mass_behavior.txt | data_original |
| scores_HB50.mat | 2ndo modeloV(piña)/scores_HB50.mat | 03_original_model/05_outputs_historicos/scores_HB50.mat | historical_outputs |
| experimentsPineapple.txt | 2ndo modeloV(piña)/experimentsPineapple.txt | 03_original_model/04_data_original/experimentsPineapple.txt | data_original |
| ceros_rec1.m | 2ndo modeloV(piña)/ceros_rec1.m | 03_original_model/03_utilities/ceros_rec1.m | utilities |
| final_pop110.mat | 2ndo modeloV(piña)/final_pop110.mat | 03_original_model/05_outputs_historicos/final_pop110.mat | historical_outputs |
| run_Interpola2.mlx | 2ndo modeloV(piña)/run_Interpola2.mlx | 03_original_model/99_legacy_do_not_run/run_Interpola2.mlx | legacy_do_not_run |
| MR_2_B4_100621.mat | 2ndo modeloV(piña)/MR_2_B4_100621.mat | 03_original_model/05_outputs_historicos/MR_2_B4_100621.mat | historical_outputs |
| Thermal_dyn.txt | 2ndo modeloV(piña)/Thermal_dyn.txt | 03_original_model/99_legacy_do_not_run/Thermal_dyn.txt | legacy_do_not_run |
| MassFlowMR.txt | 2ndo modeloV(piña)/MassFlowMR.txt | 03_original_model/04_data_original/MassFlowMR.txt | data_original |
| Mapeo4_temp100621.txt | 2ndo modeloV(piña)/Mapeo4_temp100621.txt | 03_original_model/04_data_original/Mapeo4_temp100621.txt | data_original |
| scores_200.mat | 2ndo modeloV(piña)/scores_200.mat | 03_original_model/05_outputs_historicos/scores_200.mat | historical_outputs |
| scores_GLP100trec.mat | 2ndo modeloV(piña)/scores_GLP100trec.mat | 03_original_model/05_outputs_historicos/scores_GLP100trec.mat | historical_outputs |
| rma.mlx | 2ndo modeloV(piña)/rma.mlx | 03_original_model/99_legacy_do_not_run/rma.mlx | legacy_do_not_run |
| final_pop_GLP50trec.mat | 2ndo modeloV(piña)/final_pop_GLP50trec.mat | 03_original_model/05_outputs_historicos/final_pop_GLP50trec.mat | historical_outputs |
| wetbulb_AirH2O.m | 2ndo modeloV(piña)/wetbulb_AirH2O.m | 03_original_model/02_psychrometrics/wetbulb_AirH2O.m | psychrometrics |
| scores_GLP50trec.mat | 2ndo modeloV(piña)/scores_GLP50trec.mat | 03_original_model/05_outputs_historicos/scores_GLP50trec.mat | historical_outputs |
| run_tunel_mod2.mlx | 2ndo modeloV(piña)/run_tunel_mod2.mlx | 03_original_model/01_active_original/run_tunel_mod2.mlx | active_original |
| EDO_Hossain3.mlx | 2ndo modeloV(piña)/EDO_Hossain3.mlx | 03_original_model/99_legacy_do_not_run/EDO_Hossain3.mlx | legacy_do_not_run |
| run_tanque_alm.mlx | 2ndo modeloV(piña)/run_tanque_alm.mlx | 03_original_model/99_legacy_do_not_run/run_tanque_alm.mlx | legacy_do_not_run |
| fmin_planta.mlx | 2ndo modeloV(piña)/fmin_planta.mlx | 03_original_model/01_active_original/fmin_planta.mlx | active_original |
| run_ajuste_datos.mlx | 2ndo modeloV(piña)/run_ajuste_datos.mlx | 03_original_model/99_legacy_do_not_run/run_ajuste_datos.mlx | legacy_do_not_run |
| prueba_cin.m | 2ndo modeloV(piña)/prueba_cin.m | 03_original_model/99_legacy_do_not_run/prueba_cin.m | legacy_do_not_run |
| Peso_T.txt | 2ndo modeloV(piña)/Peso_T.txt | 03_original_model/04_data_original/Peso_T.txt | data_original |
| enthalpy_AirH2O.m | 2ndo modeloV(piña)/enthalpy_AirH2O.m | 03_original_model/02_psychrometrics/enthalpy_AirH2O.m | psychrometrics |
| pruebaTwoterms.mlx | 2ndo modeloV(piña)/pruebaTwoterms.mlx | 03_original_model/99_legacy_do_not_run/pruebaTwoterms.mlx | legacy_do_not_run |
| XR_EXP.txt | 2ndo modeloV(piña)/XR_EXP.txt | 03_original_model/04_data_original/XR_EXP.txt | data_original |
| ExpTunnelTemp.txt | 2ndo modeloV(piña)/ExpTunnelTemp.txt | 03_original_model/04_data_original/ExpTunnelTemp.txt | data_original |
| M_exp50.mat | 2ndo modeloV(piña)/M_exp50.mat | 03_original_model/05_outputs_historicos/M_exp50.mat | historical_outputs |
| opt_fun_conflict_copy_MacBook-Air-de-Humberto_2024_10_02.mlx | 2ndo modeloV(piña)/opt_fun_conflict_copy_MacBook-Air-de-Humberto_2024_10_02.mlx | 03_original_model/99_legacy_do_not_run/opt_fun_conflict_copy_MacBook-Air-de-Humberto_2024_10_02.mlx | legacy_do_not_run |
| MR_B4_100621.mat | 2ndo modeloV(piña)/MR_B4_100621.mat | 03_original_model/05_outputs_historicos/MR_B4_100621.mat | historical_outputs |
| final_pop70.mat | 2ndo modeloV(piña)/final_pop70.mat | 03_original_model/05_outputs_historicos/final_pop70.mat | historical_outputs |
| T_M7_sim.txt | 2ndo modeloV(piña)/T_M7_sim.txt | 03_original_model/04_data_original/T_M7_sim.txt | data_original |
| run_opt_GA.mlx | 2ndo modeloV(piña)/run_opt_GA.mlx | 03_original_model/01_active_original/run_opt_GA.mlx | active_original |
| preallocating.m | 2ndo modeloV(piña)/preallocating.m | 03_original_model/03_utilities/preallocating.m | utilities |
| final_pop.mat | 2ndo modeloV(piña)/final_pop.mat | 03_original_model/05_outputs_historicos/final_pop.mat | historical_outputs |
| final_pop_HB100trec.mat | 2ndo modeloV(piña)/final_pop_HB100trec.mat | 03_original_model/05_outputs_historicos/final_pop_HB100trec.mat | historical_outputs |
| final_pop_GLP100trec.mat | 2ndo modeloV(piña)/final_pop_GLP100trec.mat | 03_original_model/05_outputs_historicos/final_pop_GLP100trec.mat | historical_outputs |
| opt_fun.mlx | 2ndo modeloV(piña)/opt_fun.mlx | 03_original_model/01_active_original/opt_fun.mlx | active_original |
| final_pop200.mat | 2ndo modeloV(piña)/final_pop200.mat | 03_original_model/05_outputs_historicos/final_pop200.mat | historical_outputs |
| M_exp70.mat | 2ndo modeloV(piña)/M_exp70.mat | 03_original_model/05_outputs_historicos/M_exp70.mat | historical_outputs |
| simulationsPineapple.txt | 2ndo modeloV(piña)/simulationsPineapple.txt | 03_original_model/04_data_original/simulationsPineapple.txt | data_original |
| run_opt_tunel_mod2.mlx | 2ndo modeloV(piña)/run_opt_tunel_mod2.mlx | 03_original_model/01_active_original/run_opt_tunel_mod2.mlx | active_original |
| run_tunel_mod2_1.mlx | 2ndo modeloV(piña)/run_tunel_mod2_1.mlx | 03_original_model/01_active_original/run_tunel_mod2_1.mlx | active_original |
| final_pop_HB150trec.mat | 2ndo modeloV(piña)/final_pop_HB150trec.mat | 03_original_model/05_outputs_historicos/final_pop_HB150trec.mat | historical_outputs |
| XR_SIM.txt | 2ndo modeloV(piña)/XR_SIM.txt | 03_original_model/04_data_original/XR_SIM.txt | data_original |
| final_pop_HB200.mat | 2ndo modeloV(piña)/final_pop_HB200.mat | 03_original_model/05_outputs_historicos/final_pop_HB200.mat | historical_outputs |
| opt_fun3.mlx | 2ndo modeloV(piña)/opt_fun3.mlx | 03_original_model/01_active_original/opt_fun3.mlx | active_original |
| scores_GLP155.mat | 2ndo modeloV(piña)/scores_GLP155.mat | 03_original_model/05_outputs_historicos/scores_GLP155.mat | historical_outputs |
| TiempoP.txt | 2ndo modeloV(piña)/TiempoP.txt | 03_original_model/04_data_original/TiempoP.txt | data_original |
| Mapeo2_temp100621.txt | 2ndo modeloV(piña)/Mapeo2_temp100621.txt | 03_original_model/04_data_original/Mapeo2_temp100621.txt | data_original |
| M_exp60.mat | 2ndo modeloV(piña)/M_exp60.mat | 03_original_model/05_outputs_historicos/M_exp60.mat | historical_outputs |
| opt_tunel_mod2_conflict_copy_MacBook-Air-de-Humberto_2024_10_02.mlx | 2ndo modeloV(piña)/opt_tunel_mod2_conflict_copy_MacBook-Air-de-Humberto_2024_10_02.mlx | 03_original_model/99_legacy_do_not_run/opt_tunel_mod2_conflict_copy_MacBook-Air-de-Humberto_2024_10_02.mlx | legacy_do_not_run |
| scores_HB200.mat | 2ndo modeloV(piña)/scores_HB200.mat | 03_original_model/05_outputs_historicos/scores_HB200.mat | historical_outputs |
| Cp_agua.m | 2ndo modeloV(piña)/Cp_agua.m | 03_original_model/02_psychrometrics/Cp_agua.m | psychrometrics |
| humrat_AirH2O.m | 2ndo modeloV(piña)/humrat_AirH2O.m | 03_original_model/02_psychrometrics/humrat_AirH2O.m | psychrometrics |
| run_coef_aire_prod.mlx | 2ndo modeloV(piña)/run_coef_aire_prod.mlx | 03_original_model/99_legacy_do_not_run/run_coef_aire_prod.mlx | legacy_do_not_run |
| Coef_tank.mlx | 2ndo modeloV(piña)/Coef_tank.mlx | 03_original_model/99_legacy_do_not_run/Coef_tank.mlx | legacy_do_not_run |
| final_pop377.mat | 2ndo modeloV(piña)/final_pop377.mat | 03_original_model/05_outputs_historicos/final_pop377.mat | historical_outputs |
| EDO_Hossain.mlx | 2ndo modeloV(piña)/EDO_Hossain.mlx | 03_original_model/99_legacy_do_not_run/EDO_Hossain.mlx | legacy_do_not_run |
| scores_HB306.mat | 2ndo modeloV(piña)/scores_HB306.mat | 03_original_model/05_outputs_historicos/scores_HB306.mat | historical_outputs |
| modelo2simple.m | 2ndo modeloV(piña)/modelo2simple.m | 03_original_model/99_legacy_do_not_run/modelo2simple.m | legacy_do_not_run |
| tunel_mod2.mlx | 2ndo modeloV(piña)/tunel_mod2.mlx | 03_original_model/01_active_original/tunel_mod2.mlx | active_original |
| scores_HB50trec.mat | 2ndo modeloV(piña)/scores_HB50trec.mat | 03_original_model/05_outputs_historicos/scores_HB50trec.mat | historical_outputs |
| Mapeo3_temp100621.txt | 2ndo modeloV(piña)/Mapeo3_temp100621.txt | 03_original_model/04_data_original/Mapeo3_temp100621.txt | data_original |
| createfigure.m | 2ndo modeloV(piña)/createfigure.m | 03_original_model/03_utilities/createfigure.m | utilities |
| SimTunnelTemp.txt | 2ndo modeloV(piña)/SimTunnelTemp.txt | 03_original_model/04_data_original/SimTunnelTemp.txt | data_original |
| opt_tunel_mod2.mlx | 2ndo modeloV(piña)/opt_tunel_mod2.mlx | 03_original_model/01_active_original/opt_tunel_mod2.mlx | active_original |
| EDO_simple.m | 2ndo modeloV(piña)/EDO_simple.m | 03_original_model/99_legacy_do_not_run/EDO_simple.m | legacy_do_not_run |
| enthalpy_Water.m | 2ndo modeloV(piña)/enthalpy_Water.m | 03_original_model/02_psychrometrics/enthalpy_Water.m | psychrometrics |
| Cp_aire.m | 2ndo modeloV(piña)/Cp_aire.m | 03_original_model/02_psychrometrics/Cp_aire.m | psychrometrics |
| tunel_mod2_funcion_original.mlx | 2ndo modeloV(piña)/tunel_mod2_funcion_original.mlx | 03_original_model/01_active_original/tunel_mod2_funcion_original.mlx | active_original |
| modelo2.mlx | 2ndo modeloV(piña)/modelo2.mlx | 03_original_model/01_active_original/modelo2.mlx | active_original |
| final_pop_HB200trec.mat | 2ndo modeloV(piña)/final_pop_HB200trec.mat | 03_original_model/05_outputs_historicos/final_pop_HB200trec.mat | historical_outputs |
| mezclador_tunel.m | 2ndo modeloV(piña)/mezclador_tunel.m | 03_original_model/03_utilities/mezclador_tunel.m | utilities |
| final_pop90.mat | 2ndo modeloV(piña)/final_pop90.mat | 03_original_model/05_outputs_historicos/final_pop90.mat | historical_outputs |
| scores_HB100trec.mat | 2ndo modeloV(piña)/scores_HB100trec.mat | 03_original_model/05_outputs_historicos/scores_HB100trec.mat | historical_outputs |
| Graficas_pina.mlx | 2ndo modeloV(piña)/Graficas_pina.mlx | 03_original_model/99_legacy_do_not_run/Graficas_pina.mlx | legacy_do_not_run |
| Mapeo_temp100621.txt | 2ndo modeloV(piña)/Mapeo_temp100621.txt | 03_original_model/04_data_original/Mapeo_temp100621.txt | data_original |
| final_pop_HB306.mat | 2ndo modeloV(piña)/final_pop_HB306.mat | 03_original_model/05_outputs_historicos/final_pop_HB306.mat | historical_outputs |
| scores_110.mat | 2ndo modeloV(piña)/scores_110.mat | 03_original_model/05_outputs_historicos/scores_110.mat | historical_outputs |
| final_pop_HB50.mat | 2ndo modeloV(piña)/final_pop_HB50.mat | 03_original_model/05_outputs_historicos/final_pop_HB50.mat | historical_outputs |
| final_pop2.mat | 2ndo modeloV(piña)/final_pop2.mat | 03_original_model/05_outputs_historicos/final_pop2.mat | historical_outputs |
| MR_T.txt | 2ndo modeloV(piña)/MR_T.txt | 03_original_model/04_data_original/MR_T.txt | data_original |
| final_pop_HB50trec.mat | 2ndo modeloV(piña)/final_pop_HB50trec.mat | 03_original_model/05_outputs_historicos/final_pop_HB50trec.mat | historical_outputs |
| scores_HB150trec.mat | 2ndo modeloV(piña)/scores_HB150trec.mat | 03_original_model/05_outputs_historicos/scores_HB150trec.mat | historical_outputs |
| relhum_AirH2O.m | 2ndo modeloV(piña)/relhum_AirH2O.m | 03_original_model/02_psychrometrics/relhum_AirH2O.m | psychrometrics |
| density_AirH2O.m | 2ndo modeloV(piña)/density_AirH2O.m | 03_original_model/02_psychrometrics/density_AirH2O.m | psychrometrics |
| fmin_opt.mlx | 2ndo modeloV(piña)/fmin_opt.mlx | 03_original_model/01_active_original/fmin_opt.mlx | active_original |
| T_M7_exp.txt | 2ndo modeloV(piña)/T_M7_exp.txt | 03_original_model/04_data_original/T_M7_exp.txt | data_original |
| Solar_Qaux_100kg_20%m_02kgs.mat | 2ndo modeloV(piña)/Pruebas/14082022/Solar_Qaux_100kg_20%m_02kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_20%m_02kgs.mat | legacy_do_not_run |
| Qaux_100kg_20%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/14082022/Qaux_100kg_20%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_20%m_011kgs.mat | legacy_do_not_run |
| Qaux_100kg_20%m_02kgs.mat | 2ndo modeloV(piña)/Pruebas/14082022/Qaux_100kg_20%m_02kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_20%m_02kgs.mat | legacy_do_not_run |
| Qaux_100kg_20%m_005kgs.mat | 2ndo modeloV(piña)/Pruebas/14082022/Qaux_100kg_20%m_005kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_20%m_005kgs.mat | legacy_do_not_run |
| Qaux_100kg_80%m_02kgs.mat | 2ndo modeloV(piña)/Pruebas/14082022/Qaux_100kg_80%m_02kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_80%m_02kgs.mat | legacy_do_not_run |
| Solar_Qaux_100kg_80%m_02kgs.mat | 2ndo modeloV(piña)/Pruebas/14082022/Solar_Qaux_100kg_80%m_02kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_80%m_02kgs.mat | legacy_do_not_run |
| Solar_Qaux_100kg_20%m_005kgs.mat | 2ndo modeloV(piña)/Pruebas/14082022/Solar_Qaux_100kg_20%m_005kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_20%m_005kgs.mat | legacy_do_not_run |
| Solar_Qaux_100kg_20%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/14082022/Solar_Qaux_100kg_20%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_20%m_011kgs.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/290822/Solar_Qaux_100kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_011kgs.mat | legacy_do_not_run |
| Qaux_100kg_73%m_019kgs.mat | 2ndo modeloV(piña)/Pruebas/290822/Qaux_100kg_73%m_019kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_019kgs.mat | legacy_do_not_run |
| Qaux_100kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/290822/Qaux_100kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_011kgs.mat | legacy_do_not_run |
| Qaux_100kg_73%m_005kgs.mat | 2ndo modeloV(piña)/Pruebas/290822/Qaux_100kg_73%m_005kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_005kgs.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_005kgs.mat | 2ndo modeloV(piña)/Pruebas/290822/Solar_Qaux_100kg_73%m_005kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_005kgs.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_019kgs.mat | 2ndo modeloV(piña)/Pruebas/290822/Solar_Qaux_100kg_73%m_019kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_019kgs.mat | legacy_do_not_run |
| Qaux_500kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Qaux_500kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_500kg_73%m_011kgs.mat | legacy_do_not_run |
| Solar_Qaux_500kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Solar_Qaux_500kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_500kg_73%m_011kgs.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_005kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Solar_Qaux_100kg_73%m_005kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_005kgs__dup2.mat | legacy_do_not_run |
| Qaux_100kg_73%m_005kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Qaux_100kg_73%m_005kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_005kgs__dup2.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Solar_Qaux_100kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_011kgs__dup2.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_019kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Solar_Qaux_100kg_73%m_019kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_019kgs__dup2.mat | legacy_do_not_run |
| Qaux_100kg_73%m_019kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Qaux_100kg_73%m_019kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_019kgs__dup2.mat | legacy_do_not_run |
| Qaux_100kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Qaux_100kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_011kgs__dup2.mat | legacy_do_not_run |
| Solar_Qaux_200kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/300822/Solar_Qaux_200kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_200kg_73%m_011kgs.mat | legacy_do_not_run |
| Qaux_100kg_73%m_019kgs.mat | 2ndo modeloV(piña)/Pruebas/16102022/Qaux_100kg_73%m_019kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_019kgs__dup3.mat | legacy_do_not_run |
| Qaux_100kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/16102022/Qaux_100kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_011kgs__dup3.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_005kgs.mat | 2ndo modeloV(piña)/Pruebas/16102022/Solar_Qaux_100kg_73%m_005kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_005kgs__dup3.mat | legacy_do_not_run |
| Qaux_100kg_73%m_005kgs.mat | 2ndo modeloV(piña)/Pruebas/16102022/Qaux_100kg_73%m_005kgs.mat | 03_original_model/99_legacy_do_not_run/Qaux_100kg_73%m_005kgs__dup3.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_019kgs.mat | 2ndo modeloV(piña)/Pruebas/16102022/Solar_Qaux_100kg_73%m_019kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_019kgs__dup3.mat | legacy_do_not_run |
| Solar_Qaux_100kg_73%m_011kgs.mat | 2ndo modeloV(piña)/Pruebas/16102022/Solar_Qaux_100kg_73%m_011kgs.mat | 03_original_model/99_legacy_do_not_run/Solar_Qaux_100kg_73%m_011kgs__dup3.mat | legacy_do_not_run |

## v0.6 additions

| Archivo | Ruta | Tipo | Estado |
|---|---|---|---|
| setup_v05_paths.m | 02_src_limpio/main/ | MATLAB | Implementado |
| get_project_root_original.m | 03_original_model/03_utilities/ | MATLAB | Implementado |
| load_environmental_data_original.m | 03_original_model/03_utilities/ | MATLAB | Implementado |
| test_case_base_v05.m | 02_src_limpio/validation/ | MATLAB | Implementado |
| audit_cost_trace_AB.m | 02_src_limpio/validation/ | MATLAB | Plantilla ejecutable localmente |


## v0.7 additions

| Archivo | Ruta | Tipo | Estado |
|---|---|---|---|
| setup_v05_paths.m | 02_src_limpio/main/ | MATLAB | Actualizado |
| test_case_base_v05.m | 02_src_limpio/validation/ | MATLAB | Corregido TEST-B-002 |
| test_case_base_v06_minimal.m | 02_src_limpio/validation/ | MATLAB | Implementado |
| KNOW_06_06C_path_data_tests_minimos.md | 01_knowledge/06_implementacion/ | Markdown | Implementado |


## v0.8 additions

| Archivo | Ruta | Tipo | Estado |
|---|---|---|---|
| opt_tunel_mod2_v06_data_controlled.m | 02_src_limpio/wrappers/ | MATLAB | Implementado |
| load_environmental_data_original.m | 03_original_model/03_utilities/ | MATLAB | Actualizado |
| test_case_base_v06_minimal.m | 02_src_limpio/validation/ | MATLAB | Actualizado |
| KNOW_06_06D_cierre_estricto_DATA_B_001.md | 01_knowledge/06_implementacion/ | Markdown | Implementado |


## v0.9 additions

| Archivo | Ruta | Tipo | Estado |
|---|---|---|---|
| build_cost_params_historical.m | 02_src_limpio/cost/ | MATLAB | Actualizado |
| calc_cost_breakdown.m | 02_src_limpio/cost/ | MATLAB | Actualizado |
| audit_cost_trace_AB_v09.m | 02_src_limpio/validation/ | MATLAB | Implementado |
| KNOW_06_06E_COST_B_001_AUD_COST_AB_001.md | 01_knowledge/06_implementacion/ | Markdown | Implementado |


## v1.0-HYBRID-IRR additions

| Archivo | Ruta | Tipo | Estado |
|---|---|---|---|
| opt_tunel_mod2_v10_energy_mode_corrected.m | 02_src_limpio/wrappers/ | MATLAB | Implementado Tipo D |
| test_hybrid_irradiance_modes_v10.m | 02_src_limpio/validation/ | MATLAB | Implementado |
| HYBRID_IRR_001_DIAG_v09_manual.txt | 06_outputs/logs/ | TXT | Evidencia manual |
| HYBRID_IRR_001_DIAG_v09_manual.csv | 06_outputs/tables/ | CSV | Evidencia manual |
| KNOW_06_06H_HYBRID_IRR_001_TYPE_D.md | 01_knowledge/06_implementacion/ | Markdown | Implementado |


## v1.1-HYBRID-IRR additions

| Archivo | Ruta | Tipo | Estado |
|---|---|---|---|
| opt_tunel_mod2_v10_energy_mode_corrected.m | 02_src_limpio/wrappers/ | MATLAB | Parcheado AUD-HYBRID-B-002 |
| test_hybrid_irradiance_modes_v10.m | 02_src_limpio/validation/ | MATLAB | Parcheado con validación |
| AUD_HYBRID_B_002_PATCH_NOTE.txt | 06_outputs/logs/ | TXT | Nota de parche |


## v1.2-HYBRID-IRR_CONSOLIDADA additions

| Archivo | Ruta | Tipo | Estado |
|---|---|---|---|
| opt_tunel_mod2_v10_energy_mode_corrected.m | 02_src_limpio/wrappers/ | MATLAB | Consolidado |
| test_hybrid_irradiance_modes_v10.m | 02_src_limpio/validation/ | MATLAB | Consolidado |
| test_hybrid_irradiance_modes_v10_robustness.m | 02_src_limpio/validation/ | MATLAB | Implementado |
| HYBRID_IRR_MODE_AB_v10_USER_VALIDATED.txt | 06_outputs/logs/ | TXT | Evidencia validada |
| HYBRID_IRR_MODE_AB_v10_USER_VALIDATED.csv | 06_outputs/tables/ | CSV | Evidencia validada |
| HYBRID_IRR_MODE_AB_v10_ROBUSTNESS_USER_VALIDATED.txt | 06_outputs/logs/ | TXT | Evidencia validada |
| HYBRID_IRR_MODE_AB_v10_ROBUSTNESS_USER_VALIDATED.csv | 06_outputs/tables/ | CSV | Evidencia validada |
| KNOW_06_06I_HYBRID_IRR_MODE_ENERGY_CONSOLIDADO.md | 01_knowledge/06_implementacion/ | Markdown | Implementado |

## v1.3-HYBRID-IRR_COMPARE_CONSOLIDADA additions

| Archivo | Ruta | Tipo | Estado |
|---|---|---|---|
| compare_operation_modes.m | 02_src_limpio/comparison/ | MATLAB | Implementado |
| COMPARE_OPERATION_MODES_v67_USER_VALIDATED.txt | 06_outputs/logs/ | TXT | Evidencia validada |
| COMPARE_OPERATION_MODES_v67_USER_VALIDATED.csv | 06_outputs/tables/ | CSV | Evidencia validada |
| COMPARE_OPERATION_MODES_v67_USER_VALIDATED.mat | 06_outputs/comparisons/ | MAT | Evidencia validada |
| KNOW_06_07_compare_operation_modes.md | 01_knowledge/06_implementacion/ | Markdown | Implementado |
