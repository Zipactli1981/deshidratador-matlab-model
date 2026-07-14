# SELECTED_POINTS_HYBRID_vs_GASLP_v96z report

## Diagnosis

`SELECTED_POINTS_HYBRID_vs_GASLP_PASS`

## Decision

`USE_AS_BASELINE_COMPARISON_FOR_MANUSCRIPT`

## Next step

`Draft baseline comparison paragraph or integrate table into Results/Supplementary Material.`

## Files

- Full CSV: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\SELECTED_POINTS_HYBRID_vs_GASLP_v96z.csv`
- Summary CSV: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.csv`
- Summary MD: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md`
- Checks CSV: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\SELECTED_POINTS_HYBRID_vs_GASLP_v96z_Tchecks.csv`

## Summary table

| case | Q hybrid kWh | Q gasLP kWh | reduction kWh | reduction % | MR hybrid | MR gasLP | interpretation |
|---|---:|---:|---:|---:|---:|---:|---|
| `H2_historical` | 746.999 | 1292.56 | 545.561 | 42.2078 | 0.0444828 | 0.0444828 | Historical deeper-drying reference |
| `R1_solution_7` | 656.226 | 1194.11 | 537.886 | 45.0448 | 0.0705698 | 0.0719922 | Energy-saving feasible candidate |
| `R1_solution_3` | 723.36 | 1270.58 | 547.218 | 43.0684 | 0.0549302 | 0.0548629 | Balanced feasible candidate |
| `R1_solution_9` | 1218.41 | 1773.87 | 555.46 | 31.3135 | 0.0138763 | 0.0138763 | Aggressive drying boundary case |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `HG-01` | Wrapper found | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\wrappers\opt_tunel_mod2_v19_eta_sensitivity.m` |
| `HG-02` | Full table has eight rows | 1 | `8` |
| `HG-03` | Summary table has four rows | 1 | `4` |
| `HG-04` | All hybrid rows present | 1 | `hybrid row count.` |
| `HG-05` | All gasLP rows present | 1 | `gasLP row count.` |
| `HG-06` | All hybrid points feasible MR<=0.1 | 1 | `Hybrid feasibility.` |
| `HG-07` | All gasLP points feasible MR<=0.1 | 1 | `gasLP feasibility.` |
| `HG-08` | Hybrid Q_aux lower than gasLP for all points | 1 | `Hybrid energy reduction.` |
| `HG-09` | R1-7 remains lowest hybrid Q_aux | 1 | `R1-7 hybrid Q_aux minimum.` |
| `HG-10` | Output full CSV created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\SELECTED_POINTS_HYBRID_vs_GASLP_v96z.csv` |
| `HG-11` | Output summary CSV created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.csv` |
| `HG-12` | Output summary MD created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md` |
| `HG-13` | No GA executed | 1 | `Fixed-point comparison only.` |
| `HG-14` | No optimization executed | 1 | `Fixed-point comparison only.` |
