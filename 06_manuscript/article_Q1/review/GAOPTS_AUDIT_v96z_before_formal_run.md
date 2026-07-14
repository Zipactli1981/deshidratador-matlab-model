# GAOPTS_AUDIT_v96z_before_formal_run

## Diagnosis

`GAOPTS_AUDIT_REQUIRES_REVIEW`

## Decision

`DO_NOT_RUN_LONG_FORMAL_REPLICATIONS`

## Next step

`Inspect failed GA checks before any formal run.`

## Core GA configuration

| parameter | value | source/comment |
|---|---|---|
| `algorithm` | `gamultiobj` | Solver used for multiobjective genetic algorithm. |
| `objective_count` | `3` | Objectives: MR, specific cost, specific CO2. |
| `decision_variables` | `4` | m_max, T_min, r_div2, t_rec_ini. |
| `modeFormal` | `` | Formal mode optimized. |
| `referenceMode` | `gasLP` | Reference mode for comparative interpretation. |
| `popSize_original_v96m` | `24` | Explicit value found in original v96m. |
| `maxGen_original_v96m` | `50` | Explicit value found in original v96m. |
| `popSize_seedaware_formal` | `24` | Explicit value found in seed-aware formal clone. |
| `maxGen_seedaware_formal` | `50` | Explicit value found in seed-aware formal clone. |
| `popSize_smoke` | `8` | Smoke-only reduced population. |
| `maxGen_smoke` | `5` | Smoke-only reduced generations. |
| `confirm_execute_policy` | `Required true for GA execution` | Guarded execution policy. |
| `rng_original_v96m` | `Internal fixed rng(614960,''twister'')` | Detected in original v96m; reason for rngfix. |
| `rng_seedaware` | `External rngSeed if provided; legacy seed only if omitted` | Seed-aware clone behavior. |
| `rng_type` | `twister` | RNG type used in seed control. |
| `seeds_smoke` | `61001, 61002` | Used for seed-aware smoke. |
| `seeds_formal_planned` | `61001, 61002, 61003` | Planned formal independent-seed replicates. |
| `emission_factors_status` | `PROVISIONAL_FOR_CODE_VALIDATION` | CO2 factors not final for manuscript claims. |
| `opts_status` | `NOT_AVAILABLE` | Could not extract opts from confirm_execute=false preview. |

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
| `GA01` | Original formal runner exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m.m` |
| `GA02` | Seed-aware formal clone exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` |
| `GA03` | Original has gamultiobj | 1 | `gamultiobj found in original.` |
| `GA04` | Seed-aware clone has gamultiobj | 1 | `gamultiobj found in seed-aware clone.` |
| `GA05` | Seed-aware clone has optimoptions | 1 | `optimoptions/gamultiobj found.` |
| `GA06` | Original fixed seed documented | 1 | `rng(614960,'twister') detected in original.` |
| `GA07` | Seed-aware external branch present | 1 | `rngSeed + EXTERNAL_SEED_APPLIED present.` |
| `GA08` | Seed metadata present | 1 | `rngSeed_v96z and rngControl_v96z present.` |
| `GA09` | Formal popSize detected | 1 | `24` |
| `GA10` | Formal maxGen detected | 1 | `50` |
| `GA11` | Smoke popSize detected | 1 | `8` |
| `GA12` | Smoke maxGen detected | 1 | `5` |
| `GA13` | Preview call did not execute GA | 1 | `OK ` |
| `GA14` | opts saved by formal clone | 1 | `save list contains opts.` |
| `GA15` | X/F saved by formal clone | 1 | `save list contains X and F.` |
| `GA16` | output/population/scores saved | 1 | `save list contains output, population, scores.` |
| `GA17` | lb/ub saved | 1 | `save list contains lb and ub.` |
| `GA18` | Bounds available | 0 | `lb/ub extracted.` |
| `GA19` | No GA executed by audit | 1 | `No gamultiobj call from this audit.` |
| `GA20` | Protected original not modified | 1 | `Audit read-only for v96m.` |

## Methodological note

This audit consolidates the genetic algorithm configuration before formal seed-aware runs. The smoke test validated that external seed control changes X/F fronts, but smoke results are not used as final optimization results.
