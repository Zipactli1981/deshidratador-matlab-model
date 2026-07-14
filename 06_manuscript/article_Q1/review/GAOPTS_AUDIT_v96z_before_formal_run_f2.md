# GAOPTS_AUDIT_v96z_before_formal_run_f2

## Diagnosis

`GAOPTS_AUDIT_F2_REQUIRES_REVIEW`

## Decision

`DO_NOT_RUN_LONG_FORMAL_REPLICATIONS`

## Next step

`Inspect failed F2 checks.`

## GA configuration

| parameter | value | source/comment |
|---|---|---|
| `algorithm` | `gamultiobj` | Solver used for multiobjective genetic algorithm. |
| `objective_count` | `3` | Objectives: MR, specific cost, specific CO2. |
| `decision_variables` | `4` | m_max, T_min, r_div2, t_rec_ini. |
| `modeFormal` | `hybrid` | Extracted from source when available. |
| `referenceMode` | `gasLP` | Reference mode for comparative interpretation. |
| `popSize_original_v96m` | `24` | Explicit assignment in original v96m. |
| `maxGen_original_v96m` | `50` | Explicit assignment in original v96m. |
| `popSize_seedaware_formal` | `24` | Explicit assignment in seed-aware formal clone. |
| `maxGen_seedaware_formal` | `50` | Explicit assignment in seed-aware formal clone. |
| `popSize_smoke` | `8` | Smoke-only reduced population. |
| `maxGen_smoke` | `5` | Smoke-only reduced generations. |
| `rng_original_v96m` | `Internal fixed rng(614960,'twister')` | Detected in original v96m. |
| `rng_seedaware` | `External rngSeed if provided; legacy seed only if omitted` | Seed-aware clone behavior. |
| `rng_type` | `twister` | RNG type used in seed control. |
| `seeds_smoke` | `61001, 61002` | Used for seed-aware smoke. |
| `seeds_formal_planned` | `61001, 61002, 61003` | Planned formal independent-seed replicates. |
| `confirm_execute_policy` | `Required true for GA execution` | Guarded execution policy. |
| `emission_factors_status` | `PROVISIONAL_FOR_CODE_VALIDATION` | CO2 factors not final for manuscript claims. |
| `lb_raw` | `` | Raw lb assignment extracted from source. |
| `ub_raw` | `` | Raw ub assignment extracted from source. |
| `optimoptions_raw` | `opts = optimoptions('gamultiobj', ...         'PopulationSize', popSize, ...         'MaxGenerations', maxGen, ...         'Display', 'iter', ...         'UseParallel', false, ...         'FunctionTolerance', 1e-5, ...         'ConstraintTolerance', 1e-6, ...         'PlotFcn', []);` | Raw optimoptions block extracted from source. |

## Decision-variable bounds

| variable | lb | ub | comment |
|---|---:|---:|---|
| `m_max` | NaN | NaN | Air mass flow or control variable used by model |
| `T_min` | NaN | NaN | Minimum temperature setpoint |
| `r_div2` | NaN | NaN | Recirculation fraction divided/encoded as in model |
| `t_rec_ini` | NaN | NaN | Initial recirculation time |

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
| `F2_01` | Original formal runner exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m.m` |
| `F2_02` | Seed-aware formal clone exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` |
| `F2_03` | Original has gamultiobj | 1 | `gamultiobj found in original.` |
| `F2_04` | Seed-aware has gamultiobj | 1 | `gamultiobj found in seed-aware clone.` |
| `F2_05` | Seed-aware has optimoptions | 1 | `optimoptions/gamultiobj found.` |
| `F2_06` | Original fixed seed documented | 1 | `rng(614960,'twister') detected in original.` |
| `F2_07` | Seed-aware external branch present | 1 | `rngSeed + EXTERNAL_SEED_APPLIED present.` |
| `F2_08` | Seed metadata present | 1 | `rngSeed_v96z and rngControl_v96z present.` |
| `F2_09` | Formal popSize detected | 1 | `24` |
| `F2_10` | Formal maxGen detected | 1 | `50` |
| `F2_11` | Smoke popSize detected | 1 | `8` |
| `F2_12` | Smoke maxGen detected | 1 | `5` |
| `F2_13` | lb extracted | 0 | `` |
| `F2_14` | ub extracted | 0 | `` |
| `F2_15` | Bounds table complete | 0 | `Tbounds finite.` |
| `F2_16` | optimoptions block extracted | 1 | `optimoptions block captured.` |
| `F2_17` | opts saved by formal clone | 1 | `save list contains opts.` |
| `F2_18` | X/F saved by formal clone | 1 | `save list contains X and F.` |
| `F2_19` | output/population/scores saved | 1 | `save list contains output, population, scores.` |
| `F2_20` | lb/ub saved | 1 | `save list contains lb and ub.` |
| `F2_21` | No GA executed by audit | 1 | `Source-only audit; no gamultiobj call.` |
| `F2_22` | Protected original not modified | 1 | `Audit read-only for v96m.` |
