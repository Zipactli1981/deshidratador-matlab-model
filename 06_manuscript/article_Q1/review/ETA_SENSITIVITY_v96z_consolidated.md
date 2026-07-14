# ETA_SENSITIVITY_v96z consolidated

## Diagnosis

`ETA_SENSITIVITY_CONSOLIDATION_PASS`

## Decision

`USE_AS_MANUSCRIPT_SENSITIVITY_RESULT`

## Next step

`Draft Results/Discussion paragraph for collector efficiency sensitivity.`

## Main interpretation

The 2-SAH collector efficiency curve changes the auxiliary energy balance, but it does not change the qualitative operational ranking of the evaluated solutions. R1_solution_7 remains the lowest-auxiliary-energy feasible candidate under MR <= 0.1, R1_solution_3 remains a balanced feasible candidate, H2 remains a historical comparison point, and R1_solution_9 remains an aggressive drying solution with high auxiliary demand.

## Consolidated table

| case | eta mode | Q_aux | dry time | MR | Irradiation | eta positive mean | dQ vs constant % | dQ vs H2 same eta % | feasible | verdict |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `H2_historical` | `eta_constant_0p50` | 807.024 | 19.9 | 0.0444828 | 314.296 | 0.5 | 0 | 0 | 1 | `useful_reference_more_drying_not_minimum_auxiliary_energy` |
| `H2_historical` | `eta_historical_code_curve` | 705.171 | 19.9 | 0.0444828 | 412.064 | 0.655535 | 12.6208 | 0 | 1 | `useful_reference_more_drying_not_minimum_auxiliary_energy` |
| `H2_historical` | `eta_article_2SAH_curve` | 746.999 | 19.9 | 0.0444828 | 357.848 | 0.569285 | 7.43787 | 0 | 1 | `useful_reference_more_drying_not_minimum_auxiliary_energy` |
| `R1_solution_7` | `eta_constant_0p50` | 707.175 | 19.9 | 0.0719758 | 314.296 | 0.5 | 0 | 12.3725 | 1 | `recommended_energy_saving_candidate` |
| `R1_solution_7` | `eta_historical_code_curve` | 618.256 | 19.9 | 0.069928 | 412.064 | 0.655535 | 12.5738 | 12.3255 | 1 | `recommended_energy_saving_candidate` |
| `R1_solution_7` | `eta_article_2SAH_curve` | 656.226 | 19.9 | 0.0705698 | 357.848 | 0.569285 | 7.20459 | 12.1517 | 1 | `recommended_energy_saving_candidate` |
| `R1_solution_3` | `eta_constant_0p50` | 787.594 | 19.9 | 0.054864 | 314.296 | 0.5 | 0 | 2.40768 | 1 | `recommended_balanced_candidate` |
| `R1_solution_3` | `eta_historical_code_curve` | 676.245 | 19.9 | 0.055007 | 412.064 | 0.655535 | 14.1378 | 4.10204 | 1 | `recommended_balanced_candidate` |
| `R1_solution_3` | `eta_article_2SAH_curve` | 723.36 | 19.9 | 0.0549302 | 357.848 | 0.569285 | 8.15562 | 3.16443 | 1 | `recommended_balanced_candidate` |
| `R1_solution_9` | `eta_constant_0p50` | 1286.59 | 19.9 | 0.0138763 | 314.296 | 0.5 | 0 | -59.4235 | 1 | `not_recommended_due_to_high_auxiliary_energy` |
| `R1_solution_9` | `eta_historical_code_curve` | 1134.58 | 19.9 | 0.0138763 | 412.064 | 0.655535 | 11.8146 | -60.8943 | 1 | `not_recommended_due_to_high_auxiliary_energy` |
| `R1_solution_9` | `eta_article_2SAH_curve` | 1218.41 | 19.9 | 0.0138763 | 357.848 | 0.569285 | 5.29926 | -63.107 | 1 | `not_recommended_due_to_high_auxiliary_energy` |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `E01` | Input CSV exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\ETA_SENSITIVITY_v96z_H2_R1_selected.csv` |
| `E02` | All expected eta modes present | 1 | `eta_article_2SAH_curve; eta_constant_0p50; eta_historical_code_curve` |
| `E03` | All expected cases present | 1 | `H2_historical; R1_solution_3; R1_solution_7; R1_solution_9` |
| `E04` | R1 solution 7 feasible under article curve | 1 | `MR<=0.1 check.` |
| `E05` | R1 solution 7 lower Q_aux than H2 under article curve | 1 | `Q_aux R1-7 vs H2, same eta mode.` |
| `E06` | No GA executed | 1 | `Postprocess only.` |
| `E07` | No model executed | 1 | `Read CSV only.` |
