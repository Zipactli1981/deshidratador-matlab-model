# MANUSCRIPT_R1_ASSETS_v96z

## Diagnosis

`MANUSCRIPT_R1_ASSETS_PASS`

## Decision

`R1_TABLES_AND_FIGURES_READY_FOR_MANUSCRIPT_DRAFT`

## Next step

`Draft Results subsection using Solution 7 and Solution 3 as operational and balanced candidates.`

## Generated tables

| table | path |
|---|---|
| Front compact | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\MANUSCRIPT_R1_v96z_Table_front_compact.csv` |
| Selected solutions | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\MANUSCRIPT_R1_v96z_Table_selected_solutions.csv` |
| Reference comparison | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\MANUSCRIPT_R1_v96z_Table_reference_comparison.csv` |
| R1 vs legacy summary | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\MANUSCRIPT_R1_v96z_Table_R1_vs_legacy_summary.csv` |

## Generated figures

| figure | PNG | FIG |
|---|---|---|
| Pareto 3D | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_Pareto3D.png` | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_Pareto3D.fig` |
| MR vs cost | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_MR_vs_cost.png` | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_MR_vs_cost.fig` |
| MR vs CO2 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_MR_vs_CO2.png` | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_MR_vs_CO2.fig` |
| Cost vs CO2 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_cost_vs_CO2.png` | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_cost_vs_CO2.fig` |
| Reference vs selected bars | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_reference_vs_selected_bars.png` | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_reference_vs_selected_bars.fig` |

## Selected solutions for manuscript

| selection | idx | MR | cost | CO2 | cost red vs gasLP % | CO2 red vs gasLP % |
|---|---:|---:|---:|---:|---:|---:|
| `min_cost_all` | 1 | 0.161225992905 | 0.246303839699 | 0.893115176232 | 34.8191 | 46.871 |
| `min_MR_all` | 9 | 0.014734459103 | 0.400134038182 | 1.81565093841 | -5.88986 | -8.00824 |
| `balanced_L2_all` | 3 | 0.0582807544013 | 0.277021807639 | 1.15999397854 | 26.6901 | 30.995 |
| `min_cost_MR_le_0p1` | 7 | 0.0761725501037 | 0.258768636265 | 1.05272232979 | 31.5205 | 37.3764 |
| `balanced_L2_MR_le_0p1` | 3 | 0.0582807544013 | 0.277021807639 | 1.15999397854 | 26.6901 | 30.995 |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `A01` | Postprocess MAT exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\traceability\POSTPROCESS_R1_vs_legacy_reference_v96z.mat` |
| `A02` | R1 front has rows | 1 | `9` |
| `A03` | Selected table has rows | 1 | `8` |
| `A04` | At least one MR<=0.1 solution | 1 | `7` |
| `A05` | Solution 7 available | 1 | `Candidate lowest cost/CO2 among MR-feasible.` |
| `A06` | Solution 3 available | 1 | `Candidate balanced L2 solution.` |
| `A07` | Front CSV written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\MANUSCRIPT_R1_v96z_Table_front_compact.csv` |
| `A08` | Selected CSV written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\MANUSCRIPT_R1_v96z_Table_selected_solutions.csv` |
| `A09` | Comparison CSV written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\MANUSCRIPT_R1_v96z_Table_reference_comparison.csv` |
| `A10` | Summary CSV written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\tables\MANUSCRIPT_R1_v96z_Table_R1_vs_legacy_summary.csv` |
| `A11` | Pareto 3D PNG written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_Pareto3D.png` |
| `A12` | MR-cost PNG written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_MR_vs_cost.png` |
| `A13` | MR-CO2 PNG written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_MR_vs_CO2.png` |
| `A14` | Cost-CO2 PNG written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_cost_vs_CO2.png` |
| `A15` | Reference bars PNG written | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\figures\MANUSCRIPT_R1_v96z_Fig_reference_vs_selected_bars.png` |
| `A16` | No GA executed | 1 | `Only postprocess and plotting.` |
| `A17` | No source modified | 1 | `Read-only with respect to model sources.` |

## Manuscript note

CO2 factors remain provisional for code validation. Manuscript-final environmental claims require definitive emission factors.
