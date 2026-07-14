# MODEL_ARTICLE_AUDIT_v96z

## Diagnosis

`MODEL_ARTICLE_AUDIT_PASS`

## Decision

`ARTICLE_METADATA_READY_BEFORE_R1_FORMAL`

## Next step

`Proceed to R1 formal only, then postprocess R1 vs legacy.`

## Model decision variables and formal bounds

| variable | x_selected | lb_global | ub_global | delta_formal | lb_formal | ub_formal |
|---|---:|---:|---:|---:|---:|---:|
| `m_max` | 0.0740767982118 | 0.05 | 0.12 | 0.02 | 0.0540767982118 | 0.0940767982118 |
| `T_min` | 62.6832965028 | 55 | 70 | 5 | 57.6832965028 | 67.6832965028 |
| `r_div2` | 0.672252618341 | 0 | 0.95 | 0.25 | 0.422252618341 | 0.922252618341 |
| `t_rec_ini` | 11.6517528081 | 8 | 14 | 3 | 8.6517528081 | 14 |

## Objective definitions

| id | name | direction | article role |
|---|---|---|---|
| `f1` | `MR` | `Minimize` | Primary quality/drying endpoint metric. |
| `f2` | `cost_specific_USD_per_kgwater` | `Minimize` | Economic objective. |
| `f3` | `CO2_specific_kgCO2_per_kgwater` | `Minimize` | Environmental objective; factors provisional. |
| `detail` | `Q_aux_tot` | `Interpret` | Energy-basis variable for hybrid/gasLP comparison. |
| `detail` | `Irradiacion` | `Interpret` | Used to distinguish hybrid/solar contribution. |
| `detail` | `dry_time` | `Interpret` | Operational performance variable. |
| `detail` | `M` | `Interpret` | Denominator for specific cost and emissions. |
| `detail` | `CO2_total_kg` | `Interpret` | Environmental total before specific normalization. |
| `status` | `solar_INVALID_COST` | `Exclude from formal GA comparison` | Avoids non-equivalent continuous-time comparison. |

## Reference preflight evaluation

| mode | status | MR | cost specific | CO2 specific | Q_aux_tot | Irradiacion | dry_time | M | CO2_total |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `gasLP` | `OK` | 0.096008649173 | 0.37787758471 | 1.681 | 1185.9 | 0 | 19.9 | 0.72113 | 288.7 |
| `hybrid` | `OK` | 0.0959172010556 | 0.265706336789 | 1.0584 | 714.84 | 487.28 | 19.9 | 0.72052 | 181.78 |
| `solar` | `INVALID_COST` | 1000 | 1000000 | 1000000 | NaN | NaN | NaN | NaN | NaN |

## Candidate article assets

| item | title | data source | status | manuscript section |
|---|---|---|---|---|
| `Table 1` | Decision variables and bounds | Use Tmodel_parameters / Tbounds | `Ready` | Methods. |
| `Table 2` | GA configuration and seed control | Use Tgaopts / Tseed | `Ready` | Methods / reproducibility. |
| `Table 3` | Reference mode evaluation | Use Treference_preflight | `Ready with provisional CO2 caveat` | Results baseline. |
| `Figure 1` | Model/workflow schematic | Use source audit + narrative | `Requires drawing` | Methods. |
| `Figure 2` | Pareto front projections | Requires formal R1 or full R1/R2/R3 | `Pending formal run` | Results. |
| `Figure 3` | Hybrid vs gasLP reductions | Use reference + formal selected solution | `Partly ready` | Results/discussion. |
| `Figure 4` | Seed sensitivity / robustness | Requires R1/R2/R3 or at least R1 vs legacy | `Pending formal run` | Robustness. |
| `Supplementary Table S1` | Available MAT files and variables | Use Tavailable_outputs | `Ready` | Reproducibility supplement. |

## Available MAT outputs

| file | variables | article value |
|---|---|---|
| `SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.mat` | `F, Tchecks, Tplan, Tsummary, X, checksCsv, decision, diagnosis, formal, gaAuditPath, next_step, outMat, planCsv, repDir, reportMd, rootDir, runDir, seedawarePath, summaryCsv` | Formal R1-only candidate output. |
| `GAOPTS_AUDIT_v96z_before_formal_run_f4.mat` | `Tbounds, Tchecks, Tgaopts, Tseed, articleRoot, boundsCsv, checksCsv, decision, delta_formal, designPath, diagnosis, gaoptsCsv, lb_formal, lb_global, matlabInfo, next_step, optsRaw, originalPath, outMat, productionDir, reportMd, rootDir, seedawarePath, seedsCsv, smokeClonePath, ub_formal, ub_global, x_selected` | GA configuration / reproducibility. |
| `INSPECT_BOUNDS_SOURCE_v96z_f3.mat` | `T, files, outCsv, outMat, patterns, reportMd` | Optimization/front data candidate. |
| `GAOPTS_AUDIT_v96z_before_formal_run_f2.mat` | `Tbounds, Tchecks, Tgaopts, Tseed, articleRoot, boundsCsv, checksCsv, decision, diagnosis, gaoptsCsv, lbRaw, matlabInfo, next_step, optsRaw, originalPath, outMat, productionDir, reportMd, rootDir, seedawarePath, seedsCsv, smokeClonePath, ubRaw` | GA configuration / reproducibility. |
| `GAOPTS_AUDIT_v96z_before_formal_run.mat` | `Tbounds, Tchecks, Tfiles, Tgaopts, Tseed, articleRoot, boundsCsv, checksCsv, decision, diagnosis, filesCsv, formalOriginalPath, formalPreview, gaoptsCsv, matlabInfo, next_step, outMat, previewError, previewStatus, productionDir, reportMd, rootDir, seedawarePath, seedsCsv, smokeClonePath, smokeRunnerPath` | GA configuration / reproducibility. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix.mat` | `F, Tchecks, Tpreflight, Treference, Trun, Tsolutions, Tsource, X, confirm_execute, designDir, diagnosis, exitflag, formalDir, formalFlags, lb, maxGen, modeFormal, nvars, objective_v628b, objective_v95j, objective_v96j_fix1, outChecksCsv, outMat, outMd, outPreflightCsv, outRawMat, outReferenceCsv, outRunCsv, outSolutionsCsv, outSourceCsv, outTxt, output, popSize, population, referenceMode, run_error, run_status, runtime_s, scores, ub, wrapper_v10, wrapper_v17, wrapper_v18, x_selected` | Optimization/front data candidate. |
| `TRACE_v628b_solar_selected_solution_tmax.mat` | `A_cap, A_sec, ETHA_capt, E_capt, FV_DH_in, HR_DH_in, HR_DH_out, HR_M7, HR_amb, HR_amb_real, HR_busc, HR_sink, I, I_amb_real, I_busc, I_raw_current, Irradiacion, LT_AH, MR, MR_fin, M_des, M_prod, M_prod_fin, Mf, Mi, P_amb, Q_aux, Q_aux_tot, Q_perd_ducto, TRACE_V628B_DIR, TRACE_V628B_MODE, TRACE_V628B_TAG, T_AH1, T_AH2, T_AH3, T_AH4, T_AH5, T_AH6, T_AH7, T_AH8, T_D1, T_D2, T_DH_in, T_DH_out, T_HE1_in, T_HE1_out, T_M1, T_M2, T_M3, T_M4, T_M5, T_M6, T_M7, T_M8, T_M9, T_amb, T_amb_real, T_busc, T_gab, T_ini, T_min, T_prod, T_sink, Tw_vap, Twb, W0, bHR, bI, bT, break_i_v628b, calor_aux, cond_amb, data, dry_time, etha_capt, f_per, guard_diag_v628b, h_AH1, h_AH2, h_AH3, h_AH4, h_AH5, h_AH6, h_AH7, h_AH8, h_D1, h_D2, h_DH_in, h_DH_out, h_HE1_in, h_HE1_out, h_M1, h_M2, h_M3, h_M4, h_M5, h_M6, h_M7, h_M8, h_M9, h_ent, hw_vap, i, irr_diag, j, k, long1, mHR, mI, mT, m_AH1, m_AH2, m_AH3, m_AH4, m_AH5, m_AH6, m_AH7, m_AH8, m_D1, m_D2, m_DH_in, m_DH_out, m_HE1, m_HE1_in, m_HE1_out, m_M1, m_M2, m_M3, m_M4, m_M5, m_M6, m_M7, m_M8, m_M9, m_agua, m_f, m_i, m_max, m_sink, mat, md, mode_operation, mw_DH_in, mw_DH_out, mw_vap, mwf, mwi, nonphysical_v628b, r, r_div1, r_div2, safeMode_v628b, safeTag_v628b, serie, t, t_ant, t_busc, t_ini, t_max, t_post, t_real, t_rec_fin, t_rec_ini, t_step, termination_status_v628b, tiempo, trace_file_v628b, v_DH_in, w_D1, w_D2, w_DH_in, w_DH_out, w_HE1_in, w_M7, w_M8, w_M9, w_amb, w_sink` | Optimization/front data candidate. |
| `TRACE_v628b_solar_selected_solution_nonphysical.mat` | `A_cap, A_sec, ETHA_capt, E_capt, FV_DH_in, HR_DH_in, HR_DH_out, HR_M7, HR_amb, HR_amb_real, HR_busc, HR_sink, I, I_amb_real, I_busc, I_raw_current, Irradiacion, LT_AH, MR, MR_fin, M_des, M_prod, M_prod_fin, Mf, Mi, P_amb, Q_aux, Q_aux_tot, Q_perd_ducto, TRACE_V628B_DIR, TRACE_V628B_MODE, TRACE_V628B_TAG, T_AH1, T_AH2, T_AH3, T_AH4, T_AH5, T_AH6, T_AH7, T_AH8, T_D1, T_D2, T_DH_in, T_DH_out, T_HE1_in, T_HE1_out, T_M1, T_M2, T_M3, T_M4, T_M5, T_M6, T_M7, T_M8, T_M9, T_amb, T_amb_real, T_busc, T_gab, T_ini, T_min, T_prod, T_sink, Tw_vap, Twb, W0, bHR, bI, bT, break_i_v628b, calor_aux, cond_amb, data, dry_time, etha_capt, f_per, guard_diag_saved_v628b, guard_diag_v628b, h_AH1, h_AH2, h_AH3, h_AH4, h_AH5, h_AH6, h_AH7, h_AH8, h_D1, h_D2, h_DH_in, h_DH_out, h_HE1_in, h_HE1_out, h_M1, h_M2, h_M3, h_M4, h_M5, h_M6, h_M7, h_M8, h_M9, h_ent, hw_vap, i, irr_diag, j, k, long1, mHR, mI, mT, m_AH1, m_AH2, m_AH3, m_AH4, m_AH5, m_AH6, m_AH7, m_AH8, m_D1, m_D2, m_DH_in, m_DH_out, m_HE1, m_HE1_in, m_HE1_out, m_M1, m_M2, m_M3, m_M4, m_M5, m_M6, m_M7, m_M8, m_M9, m_agua, m_f, m_i, m_max, m_sink, mat, md, mode_operation, mw_DH_in, mw_DH_out, mw_vap, mwf, mwi, nonphysical_v628b, r, r_div1, r_div2, safeMode_v628b, safeTag_v628b, serie, t, t_ant, t_busc, t_ini, t_max, t_post, t_real, t_rec_fin, t_rec_ini, t_step, termination_status_v628b, tiempo, trace_file_v628b, v_DH_in, w_D1, w_D2, w_DH_in, w_DH_out, w_HE1_in, w_M7, w_M8, w_M9, w_amb, w_sink` | Optimization/front data candidate. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_raw.mat` | `F, X, exitflag, lb, maxGen, modeFormal, opts, output, popSize, population, run_error, run_status, runtime_s, scores, ub` | Optimization/front data candidate. |
| `SEEDAWARE_SMOKE_SEED_DIFFERENCE_v96z_rngfix.mat` | `Pairwise, Tchecks, Tsmoke, allF, allFormal, allX, checksCsv, decision, diagnosis, formalClonePath, next_step, outMat, pairCsv, reportMd, rootDir, runDir, smokeClonePath, smokeCsv` | Seed-control smoke validation; not final optimization result. |
| `SEEDAWARE_SMOKE_S2_seed_61002_output.mat` | `F, X, elapsed, formal, repID, seed` | Seed-control smoke validation; not final optimization result. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_SMOKE.mat` | `F, Tchecks, Tpreflight, Treference, Trun, Tsolutions, Tsource, X, confirm_execute, designDir, diagnosis, exitflag, formalDir, formalFlags, lb, maxGen, modeFormal, nvars, objective_v628b, objective_v95j, objective_v96j_fix1, outChecksCsv, outMat, outMd, outPreflightCsv, outRawMat, outReferenceCsv, outRunCsv, outSolutionsCsv, outSourceCsv, outTxt, output, popSize, population, referenceMode, run_error, run_status, runtime_s, scores, ub, wrapper_v10, wrapper_v17, wrapper_v18, x_selected` | Seed-control smoke validation; not final optimization result. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_SMOKE_raw.mat` | `F, X, exitflag, lb, maxGen, modeFormal, opts, output, popSize, population, run_error, run_status, runtime_s, scores, ub` | Seed-control smoke validation; not final optimization result. |
| `SEEDAWARE_SMOKE_S1_seed_61001_output.mat` | `F, X, elapsed, formal, repID, seed` | Seed-control smoke validation; not final optimization result. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_SMOKE.mat` | `F, Tchecks, Tpreflight, Treference, Trun, Tsolutions, Tsource, X, confirm_execute, designDir, diagnosis, exitflag, formalDir, formalFlags, lb, maxGen, modeFormal, nvars, objective_v628b, objective_v95j, objective_v96j_fix1, outChecksCsv, outMat, outMd, outPreflightCsv, outRawMat, outReferenceCsv, outRunCsv, outSolutionsCsv, outSourceCsv, outTxt, output, popSize, population, referenceMode, run_error, run_status, runtime_s, scores, ub, wrapper_v10, wrapper_v17, wrapper_v18, x_selected` | Seed-control smoke validation; not final optimization result. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_SMOKE_raw.mat` | `F, X, exitflag, lb, maxGen, modeFormal, opts, output, popSize, population, run_error, run_status, runtime_s, scores, ub` | Seed-control smoke validation; not final optimization result. |
| `FIX_SMOKE_SHORTNAME_v96z_rngfix_s1.mat` | `Tchecks, backupPath, checksCsv, decision, diagnosis, next_step, outMat, smokeRunnerPath` | Seed-control smoke validation; not final optimization result. |
| `BUILD_SEEDAWARE_MINREP_RUNNER_v96z_rngfix_d.mat` | `Tchecks, Treplicates, approvalPath, checksCsv, clonePath, decision, designCsv, diagnosis, expected_runtime_h_total, next_step, outMat, reportMd, rootDir, runnerPath` | Seed replication / robustness trace. |
| `FIX_BUILD_SEEDAWARE_RUNNER_CHECK_v96z_rngfix_d1.mat` | `Tchecks, backupPath, buildPath, checksCsv, decision, diagnosis, next_step, outMat` | Optimization/front data candidate. |
| `PREFLIGHT_SEEDAWARE_CLONE_v96z_rngfix_c.mat` | `Tchecks, checksCsv, clonePath, decision, diagnosis, formal, next_step, originalPath, outMat, reportMd, rngAfter, rngBefore, rootDir, testSeed` | Optimization/front data candidate. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix.mat` | `F, Tchecks, Tpreflight, Treference, Trun, Tsolutions, Tsource, X, confirm_execute, designDir, diagnosis, exitflag, formalDir, formalFlags, lb, maxGen, modeFormal, nvars, objective_v628b, objective_v95j, objective_v96j_fix1, outChecksCsv, outMat, outMd, outPreflightCsv, outRawMat, outReferenceCsv, outRunCsv, outSolutionsCsv, outSourceCsv, outTxt, output, popSize, population, referenceMode, run_error, run_status, runtime_s, scores, ub, wrapper_v10, wrapper_v17, wrapper_v18, x_selected` | Optimization/front data candidate. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_raw.mat` | `F, X, exitflag, lb, maxGen, modeFormal, opts, output, popSize, population, run_error, run_status, runtime_s, scores, ub` | Optimization/front data candidate. |
| `CREATE_SEEDAWARE_v96m_CLONE_v96z_rngfix_b.mat` | `Tchecks, backupPath, checksCsv, clonePath, decision, diagnosis, newSignature, next_step, oldSignature, outMat, reportMd, srcPath` | Optimization/front data candidate. |
| `AUDIT_INTERNAL_RNG_v96m_v96z_rngfix.mat` | `Tchecks, auditMat, checksCsv, decision, diagnosis, has_Tsolutions, has_gamultiobj, has_optimoptions, has_rng, hits, hitsCsv, n_rng_hits, next_step, reportMd, rootDir, v96mPath` | Optimization/front data candidate. |
| `MINREP_POSTPROCESS_SEED_REPLICATIONS_v96z.mat` | `C, Pairwise, RepSummary, Tchecks, Treplicates, allF, allFormal, allX, all_F_identical, all_X_identical, articleRoot, articleTextMd, at_least_some_variation, checksCsv, criteriaCsv, decision, diagnosis, nAdmissible, nH2like, nOK, next_step, pairCsv, postMat, repCsv, reportMd, reportTxt, rngAfterSeed, rngBeforeSeed, robustness_statement, rootDir, runDir, runMat` | Seed replication / robustness trace. |
| `MINREP_POST_SELECTH2_FIX3_v96z.mat` | `Tchecks, backupPath, checksCsv, decision, diagnosis, fixMat, next_step, postPath` | Seed replication / robustness trace. |
| `MINREP_POST_TSOLUTION_FIX2_v96z.mat` | `Tchecks, backupPath, checksCsv, decision, diagnosis, fixMat, next_step, postPath` | Seed replication / robustness trace. |
| `INSPECT_MINREP_FORMAL_STRUCT_v96z_diag1.mat` | `Tchecks, Tscan, decision, diagMat, diagnosis, next_step, outMat, reportMd, runDir, runMat, scanCsv` | Seed replication / robustness trace. |
| `MINREP_POST_EXTRACT_XF_FIX1_v96z.mat` | `Tchecks, backupPath, checksCsv, decision, diagnosis, fixMat, next_step, postPath` | Seed replication / robustness trace. |
| `MINREP_R3_seed_61003_formal_output.mat` | `RngAfter, RngBefore, elapsed, formal, repID, seed` | Seed replication / robustness trace. |
| `MINREP_SEED_CONTROLLED_RUN_v96z.mat` | `RepOutputs, RngAfter, RngBefore, Tchecks, Treplicates, base_has_gamultiobj, base_has_rng_call, confirm_execute, decision, diagnosis, next_step, runDir, totalElapsed_h, totalElapsed_s` | Seed replication / robustness trace. |
| `TRIOBJECTIVE_FORMAL_GA_v96m.mat` | `F, Tchecks, Tpreflight, Treference, Trun, Tsolutions, Tsource, X, confirm_execute, designDir, diagnosis, exitflag, formalDir, formalFlags, lb, maxGen, modeFormal, nvars, objective_v628b, objective_v95j, objective_v96j_fix1, outChecksCsv, outMat, outMd, outPreflightCsv, outRawMat, outReferenceCsv, outRunCsv, outSolutionsCsv, outSourceCsv, outTxt, output, popSize, population, referenceMode, run_error, run_status, runtime_s, scores, ub, wrapper_v10, wrapper_v17, wrapper_v18, x_selected` | Optimization/front data candidate. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_raw.mat` | `F, X, exitflag, lb, maxGen, modeFormal, opts, output, popSize, population, run_error, run_status, runtime_s, scores, ub` | Optimization/front data candidate. |
| `MINREP_R2_seed_61002_formal_output.mat` | `RngAfter, RngBefore, elapsed, formal, repID, seed` | Seed replication / robustness trace. |
| `TRIOBJECTIVE_FORMAL_GA_v96m.mat` | `F, Tchecks, Tpreflight, Treference, Trun, Tsolutions, Tsource, X, confirm_execute, designDir, diagnosis, exitflag, formalDir, formalFlags, lb, maxGen, modeFormal, nvars, objective_v628b, objective_v95j, objective_v96j_fix1, outChecksCsv, outMat, outMd, outPreflightCsv, outRawMat, outReferenceCsv, outRunCsv, outSolutionsCsv, outSourceCsv, outTxt, output, popSize, population, referenceMode, run_error, run_status, runtime_s, scores, ub, wrapper_v10, wrapper_v17, wrapper_v18, x_selected` | Optimization/front data candidate. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_raw.mat` | `F, X, exitflag, lb, maxGen, modeFormal, opts, output, popSize, population, run_error, run_status, runtime_s, scores, ub` | Optimization/front data candidate. |
| `MINREP_R1_seed_61001_formal_output.mat` | `RngAfter, RngBefore, elapsed, formal, repID, seed` | Seed replication / robustness trace. |
| `TRIOBJECTIVE_FORMAL_GA_v96m.mat` | `F, Tchecks, Tpreflight, Treference, Trun, Tsolutions, Tsource, X, confirm_execute, designDir, diagnosis, exitflag, formalDir, formalFlags, lb, maxGen, modeFormal, nvars, objective_v628b, objective_v95j, objective_v96j_fix1, outChecksCsv, outMat, outMd, outPreflightCsv, outRawMat, outReferenceCsv, outRunCsv, outSolutionsCsv, outSourceCsv, outTxt, output, popSize, population, referenceMode, run_error, run_status, runtime_s, scores, ub, wrapper_v10, wrapper_v17, wrapper_v18, x_selected` | Optimization/front data candidate. |
| `TRIOBJECTIVE_FORMAL_GA_v96m_raw.mat` | `F, X, exitflag, lb, maxGen, modeFormal, opts, output, popSize, population, run_error, run_status, runtime_s, scores, ub` | Optimization/front data candidate. |
| `SEED_CONTROLLED_MINREP_RUNNER_FIX1_v96z_minrep.mat` | `Tchecks, backupPath, checksCsv, decision, diagnosis, fixMat, nApplied, next_step, runnerPath` | Seed replication / robustness trace. |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `MA01` | Production directory exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production` |
| `MA02` | Article directory exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1` |
| `MA03` | Triobjective objective source exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\objective_productive_corrected_v96j_triobjective_CO2_fix1.m` |
| `MA04` | Design v96l source exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\design_triobjective_formal_run_v96l.m` |
| `MA05` | GAOPTS F4 audit found | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\traceability\GAOPTS_AUDIT_v96z_before_formal_run_f4.mat` |
| `MA06` | x_selected extracted | 1 | `[0.0740767982118 62.6832965028 0.672252618341 11.6517528081]` |
| `MA07` | Formal bounds finite | 1 | `lb_formal/ub_formal computed.` |
| `MA08` | Objective definitions consolidated | 1 | `9` |
| `MA09` | Reference preflight table available | 1 | `gasLP/hybrid/solar rows.` |
| `MA10` | Available outputs inventoried | 1 | `135` |
| `MA11` | Article assets proposed | 1 | `8` |
| `MA12` | No GA executed | 1 | `No gamultiobj call.` |
| `MA13` | No source modified | 1 | `Read-only audit.` |

## Methodological note

This audit is read-only and does not execute gamultiobj. It prepares article-facing metadata before the formal R1 seed-aware run.
