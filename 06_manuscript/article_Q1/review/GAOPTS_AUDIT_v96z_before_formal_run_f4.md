# GAOPTS_AUDIT_v96z_before_formal_run_f4

## Diagnosis

`GAOPTS_AUDIT_F4_PASS`

## Decision

`GA_CONFIGURATION_TRACEABLE_BEFORE_FORMAL_RUN`

## Next step

`Decide formal seed-aware run scope: R1-only or R1/R2/R3.`

## GA configuration

| parameter | value | source/comment |
|---|---|---|
| `algorithm` | `gamultiobj` | Solver used for multiobjective genetic algorithm. |
| `objective_count` | `3` | Objectives: MR, specific cost, specific CO2. |
| `decision_variables` | `4` | m_max, T_min, r_div2, t_rec_ini. |
| `modeFormal` | `hybrid` | Formal optimization mode. |
| `referenceMode` | `gasLP` | Reference mode for comparative interpretation. |
| `popSize_seedaware_formal` | `24` | Explicit assignment in seed-aware formal clone. |
| `maxGen_seedaware_formal` | `50` | Explicit assignment in seed-aware formal clone. |
| `popSize_original_v96m` | `24` | Explicit assignment in original v96m. |
| `maxGen_original_v96m` | `50` | Explicit assignment in original v96m. |
| `popSize_smoke` | `8` | Smoke-only reduced population. |
| `maxGen_smoke` | `5` | Smoke-only reduced generations. |
| `rng_original_v96m` | `Internal fixed rng(614960,'twister')` | Reason for rngfix. |
| `rng_seedaware` | `External rngSeed if provided; legacy seed only if omitted` | Seed-aware clone behavior. |
| `rng_type` | `twister` | RNG type used in seed control. |
| `seeds_smoke` | `61001, 61002` | Used for seed-aware smoke. |
| `seeds_formal_planned` | `61001, 61002, 61003` | Planned formal independent-seed replicates. |
| `confirm_execute_policy` | `Required true for GA execution` | Guarded execution policy. |
| `emission_factors_status` | `PROVISIONAL_FOR_CODE_VALIDATION` | CO2 factors not final for manuscript claims. |
| `x_selected_raw` | `...         0.0740767982118, ...         62.6832965028, ...         0.672252618341, ...         11.6517528081` | From design_triobjective_formal_run_v96l.m. |
| `lb_global_raw` | `0.05, 55, 0.00, 8.00` | From design_triobjective_formal_run_v96l.m. |
| `ub_global_raw` | `0.12, 70, 0.95, 14.00` | From design_triobjective_formal_run_v96l.m. |
| `delta_formal_raw` | `0.020, 5.0, 0.25, 3.0` | From design_triobjective_formal_run_v96l.m. |
| `lb_formal_formula` | `max(lb_global, x_selected - delta_formal)` | Formal lower-bound formula. |
| `ub_formal_formula` | `min(ub_global, x_selected + delta_formal)` | Formal upper-bound formula. |
| `optimoptions_raw` | `opts = optimoptions('gamultiobj', ...         'PopulationSize', popSize, ...         'MaxGenerations', maxGen, ...         'Display', 'iter', ...         'UseParallel', false, ...         'FunctionTolerance', 1e-5, ...         'ConstraintTolerance', 1e-6, ...         'PlotFcn', []);` | Raw optimoptions block extracted from seed-aware clone. |

## Decision-variable bounds

| variable | x_selected | lb_global | ub_global | delta_formal | lb_formal | ub_formal |
|---|---:|---:|---:|---:|---:|---:|
| `m_max` | 0.0740767982118 | 0.05 | 0.12 | 0.02 | 0.0540767982118 | 0.0940767982118 |
| `T_min` | 62.6832965028 | 55 | 70 | 5 | 57.6832965028 | 67.6832965028 |
| `r_div2` | 0.672252618341 | 0 | 0.95 | 0.25 | 0.422252618341 | 0.922252618341 |
| `t_rec_ini` | 11.6517528081 | 8 | 14 | 3 | 8.6517528081 | 14 |

## Seed control

| context | seed | rng control | valid independent replication |
|---|---:|---|---:|
| `original_v96m` | 614960 | `INTERNAL_FIXED_SEED` | 0 |
| `seedaware_formal_clone_with_rngSeed` | NaN | `EXTERNAL_SEED_APPLIED` | 1 |
| `seedaware_formal_clone_without_rngSeed` | 614960 | `LEGACY_INTERNAL_SEED_614960_APPLIED` | 0 |
| `seedaware_smoke_S1` | 61001 | `EXTERNAL_SEED_APPLIED` | 1 |
| `seedaware_smoke_S2` | 61002 | `EXTERNAL_SEED_APPLIED` | 1 |
| `planned_formal_R1` | 61001 | `EXTERNAL_SEED_APPLIED` | 1 |
| `planned_formal_R2` | 61002 | `EXTERNAL_SEED_APPLIED` | 1 |
| `planned_formal_R3` | 61003 | `EXTERNAL_SEED_APPLIED` | 1 |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `F4_01` | Original formal runner exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m.m` |
| `F4_02` | Seed-aware formal clone exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` |
| `F4_03` | Design v96l exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\design_triobjective_formal_run_v96l.m` |
| `F4_04` | Original has gamultiobj | 1 | `gamultiobj found in original.` |
| `F4_05` | Seed-aware has gamultiobj | 1 | `gamultiobj found in seed-aware clone.` |
| `F4_06` | Seed-aware has optimoptions | 1 | `optimoptions/gamultiobj found.` |
| `F4_07` | Original fixed seed documented | 1 | `rng(614960,'twister') detected in original.` |
| `F4_08` | Seed-aware external branch present | 1 | `rngSeed + EXTERNAL_SEED_APPLIED present.` |
| `F4_09` | Seed metadata present | 1 | `rngSeed_v96z and rngControl_v96z present.` |
| `F4_10` | Formal popSize detected | 1 | `24` |
| `F4_11` | Formal maxGen detected | 1 | `50` |
| `F4_12` | x_selected extracted | 1 | `[0.0740767982118 62.6832965028 0.672252618341 11.6517528081]` |
| `F4_13` | lb_global extracted | 1 | `[0.05 55 0 8]` |
| `F4_14` | ub_global extracted | 1 | `[0.12 70 0.95 14]` |
| `F4_15` | delta_formal extracted | 1 | `[0.02 5 0.25 3]` |
| `F4_16` | lb_formal computed | 1 | `[0.0540767982118 57.6832965028 0.422252618341 8.6517528081]` |
| `F4_17` | ub_formal computed | 1 | `[0.0940767982118 67.6832965028 0.922252618341 14]` |
| `F4_18` | Bounds table complete | 1 | `Tbounds finite.` |
| `F4_19` | Runner uses Sdesign bounds | 1 | `lb/ub loaded from Sdesign.` |
| `F4_20` | Design saves bounds | 1 | `v96l saves x_selected/lb_global/ub_global/delta/lb_formal/ub_formal/nvars.` |
| `F4_21` | optimoptions block extracted | 1 | `optimoptions block captured.` |
| `F4_22` | opts saved by formal clone | 1 | `save list contains opts.` |
| `F4_23` | X/F saved by formal clone | 1 | `save list contains X and F.` |
| `F4_24` | output/population/scores saved | 1 | `save list contains output, population, scores.` |
| `F4_25` | lb/ub saved | 1 | `save list contains lb and ub.` |
| `F4_26` | No GA executed by audit | 1 | `Source-only audit; no gamultiobj call.` |
| `F4_27` | Protected original not modified | 1 | `Audit read-only for v96m.` |
