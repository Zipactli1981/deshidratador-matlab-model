# MINREP_POSTPROCESS_SEED_REPLICATIONS_v96z

## Diagnosis

`MINREP_POSTPROCESS_PASS_WITH_RNG_INDEPENDENCE_WARNING`

## Decision

`H2_LIKE_RESULT_REPRODUCED_BUT_SEED_INDEPENDENCE_NOT_DEMONSTRATED`

## Robustness statement

The H2-like result is reproducible under repeated executions, but independent seed influence is not demonstrated because the fronts appear identical.

## Run directory

`C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\runs\MINREP_SEED_CONTROLLED_RUN_v96z_20260628_024351`

## Replicate summary

| Rep | Seed | Status | Runtime h | nFinite | minMR | minCost | minCO2 | H2-like |
|---|---:|---|---:|---:|---:|---:|---:|---|
| R1 | 61001 | OK | 11.6945 | 9 | 0.0156236 | 0.251596 | 0.85592 | true |
| R2 | 61002 | OK | 17.2252 | 9 | 0.0156236 | 0.251596 | 0.85592 | true |
| R3 | 61003 | OK | 21.2165 | 9 | 0.0156236 | 0.251596 | 0.85592 | true |

## Pairwise comparison

| Pair | F identical 12 digits | X identical 12 digits | maxAbsFDiff | maxAbsXDiff |
|---|---:|---:|---:|---:|
| R1_vs_R2 | true | true | 0 | 0 |
| R1_vs_R3 | true | true | 0 | 0 |
| R2_vs_R3 | true | true | 0 | 0 |

## Acceptance criteria

| ID | Criterion | Pass | Evidence |
|---|---|---:|---|
| C1 | All replicates completed without error | true | OK=3/3 |
| C2 | All replicates produced finite rows | true | min nFiniteRows=9 |
| C3 | Each replicate has at least one MR-admissible solution | true | admissible=3/3 |
| C4 | H2-like solution appears in at least 2 of 3 replicates | true | H2_like=3/3 |
| C5 | H2-like solution reduces cost vs gasLP | true | cost values: 0.29646, 0.29646, 0.29646 |
| C6 | H2-like solution reduces CO2 vs gasLP | true | CO2 values: 1.2908, 1.2908, 1.2908 |
| C7 | H2-like solution satisfies MR < 0.1 | true | MR values: 0.030266, 0.030266, 0.030266 |
| C8 | Do not claim global optimum | true | Global optimum claim remains blocked. |
| C9 | Seed independence not contradicted by identical fronts | false | Replicate fronts are identical at rounded numerical comparison; base runner likely resets RNG internally. |

## Next step

`9.6z-rngfix — AUDIT-AND-FIX-INTERNAL-RNG-RESET-IN-v96m-001`
