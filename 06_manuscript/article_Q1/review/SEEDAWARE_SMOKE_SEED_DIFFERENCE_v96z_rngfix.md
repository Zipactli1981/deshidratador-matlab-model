# SEEDAWARE_SMOKE_SEED_DIFFERENCE_v96z_rngfix

## Diagnosis

`SEEDAWARE_SMOKE_PASS_SEEDS_PRODUCE_DIFFERENT_FRONTS`

## Decision

`RNGFIX_VALIDATED_FOR_SEED_DIFFERENCE`

## Next step

`Decide whether to run formal seed-aware R1/R2/R3.`

## Smoke parameters

- PopulationSize: `8`
- MaxGenerations: `5`
- Seeds: `61001, 61002`

## Pairwise comparison

| pair | F identical | X identical | maxAbsFDiff | maxAbsXDiff |
|---|---:|---:|---:|---:|
| S1_vs_S2 | 0 | 0 | NaN | NaN |

## Smoke summary

| rep | seed | status | rngControl | nSolutions | minMR | minCost | minCO2 | runtime h |
|---|---:|---|---|---:|---:|---:|---:|---:|
| S1 | 61001 | OK | EXTERNAL_SEED_APPLIED | 3 | 0.0292811 | 0.291152 | 1.184 | 0.819392 |
| S2 | 61002 | OK | EXTERNAL_SEED_APPLIED | 5 | 0.0298748 | 0.264962 | 0.915374 | 0.770188 |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `SMK01` | Formal seed-aware clone exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` |
| `SMK02` | Smoke clone created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\v96z_rngfix_smoke.m` |
| `SMK03` | Smoke population reduced | 1 | `popSize = 8` |
| `SMK04` | Smoke generations reduced | 1 | `maxGen = 5` |
| `SMK05` | Seed-aware argument present | 1 | `rngSeed argument present` |
| `SMK06` | External seed branch present | 1 | `EXTERNAL_SEED_APPLIED` |
| `SMK07` | gamultiobj preserved | 1 | `gamultiobj exists in smoke clone` |
| `SMK08` | Execution explicitly controlled | 1 | `confirm_execute=1` |
| `SMK09` | Both smoke runs OK | 1 | `statuses=OK,OK` |
| `SMK10` | Both smoke runs used external seed | 1 | `rng=EXTERNAL_SEED_APPLIED,EXTERNAL_SEED_APPLIED` |
| `SMK11` | Smoke fronts compared | 1 | `S1_vs_S2` |
| `SMK12` | Smoke fronts differ | 1 | `F_identical=0; X_identical=0` |
| `SMK13` | Original v96m not modified | 1 | `Only smoke clone created.` |
| `SMK14` | Formal seed-aware clone not modified | 1 | `Smoke clone is separate.` |
