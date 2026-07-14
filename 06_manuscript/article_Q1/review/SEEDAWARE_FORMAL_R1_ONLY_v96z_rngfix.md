# SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix

## Diagnosis

`SEEDAWARE_FORMAL_R1_ONLY_PASS`

## Decision

`POSTPROCESS_R1_VS_LEGACY_BEFORE_R2_R3`

## Next step

`Run postprocess R1-only comparison.`

## Plan

| rep | seed | PopulationSize | MaxGenerations | confirm_execute |
|---|---:|---:|---:|---:|
| R1 | 61001 | 24 | 50 | 1 |

## Summary

| rep | seed | status | rngControl | nSolutions | finite | penalized | minMR | minCost | minCO2 | runtime h |
|---|---:|---|---|---:|---:|---:|---:|---:|---:|---:|
| R1 | 61001 | OK | EXTERNAL_SEED_APPLIED | 9 | 9 | 0 | 0.014734459103 | 0.246303839699 | 0.893115176232 | 25.4052023541 |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `R1_01` | Seed-aware clone exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` |
| `R1_02` | External seed branch present | 1 | `rngSeed + EXTERNAL_SEED_APPLIED.` |
| `R1_03` | Formal PopulationSize remains 24 | 1 | `popSize = 24.` |
| `R1_04` | Formal MaxGenerations remains 50 | 1 | `maxGen = 50.` |
| `R1_05` | gamultiobj present | 1 | `gamultiobj found.` |
| `R1_06` | X/F saved by clone | 1 | `save list contains X and F.` |
| `R1_07` | opts saved by clone | 1 | `save list contains opts.` |
| `R1_08` | lb/ub saved by clone | 1 | `save list contains lb and ub.` |
| `R1_09` | GAOPTS F4 audit available | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\traceability\GAOPTS_AUDIT_v96z_before_formal_run_f4.mat` |
| `R1_10` | Runner limited to R1 only | 1 | `No loop over R2/R3.` |
| `R1_11` | Execution explicitly controlled | 1 | `confirm_execute=1` |
| `R1_12` | Original v96m not modified | 1 | `Only calls seed-aware clone.` |
| `R1_13` | R1 formal run completed | 1 | `OK ` |
| `R1_14` | External seed applied | 1 | `EXTERNAL_SEED_APPLIED` |
| `R1_15` | Seed is 61001 | 1 | `61001` |
| `R1_16` | F has finite rows | 1 | `9` |
| `R1_17` | Not all penalized | 1 | `nPenaltyRows=0; nSolutions=9` |
