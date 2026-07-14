# MASTER_manuscript_v01

## Status

`MASTER_SKELETON_CREATED`

## Micropaso

`9.6z-results-draft-d`

## Identifier

`CREATE-MASTER-MANUSCRIPT-SKELETON-v01-001`

## Working title

Multi-objective operational optimization of a hybrid solar–LPG tunnel dryer under controlled recirculation and collector-efficiency sensitivity

## Internal control note

This master manuscript is a controlled assembly file. Approved sections are integrated progressively from individual Markdown section files located in:

`06_manuscript/article_Q1/draft_sections`

Numerical tables are generated from MATLAB postprocessing scripts and stored in:

`06_manuscript/article_Q1/tables`

Review reports and checks are stored in:

`06_manuscript/article_Q1/review`

Traceability files are stored in:

`06_manuscript/article_Q1/traceability`

---

# 1. Abstract

`STATUS: PENDING`

Draft after Results and Discussion are stable.

Expected content:

- Hybrid solar–LPG tunnel dryer.
- Product drying model and operational variables.
- Tri-objective optimization.
- Seed-aware computed nondominated set.
- Selected operating candidates.
- Collector-efficiency sensitivity.
- Main result: energy-saving feasible candidate preserved under 2-SAH efficiency sensitivity.

---

# 2. Keywords

`STATUS: PENDING`

Candidate keywords:

- Hybrid solar dryer
- Tunnel drying
- Multi-objective optimization
- Moisture ratio
- Solar air heater
- Recirculation control
- LPG auxiliary heating
- Collector efficiency sensitivity

---

# 3. Introduction

`STATUS: PENDING`

Expected structure:

## 3.1 Context

Hybrid solar drying as an option to reduce fossil auxiliary energy in agro-industrial drying.

## 3.2 Problem

Operational control of tunnel dryers involves trade-offs between final moisture ratio, energy use, cost, and emissions.

## 3.3 Gap

Most optimization studies either simplify recirculation timing, assume fixed solar collector efficiency, or do not evaluate whether the collector-efficiency assumption changes the operational selection.

## 3.4 Contribution

This work evaluates a hybrid solar–LPG tunnel dryer using a tri-objective optimization framework with explicit recirculation timing and a controlled collector-efficiency sensitivity analysis.

## 3.5 Scope and limitation

The work reports a computed nondominated set from a controlled seed-aware formal run. It does not claim global optimality or statistical robustness across multiple independent seeds.

---

# 4. System description

`STATUS: PENDING`

Expected content:

- Hybrid solar–LPG tunnel dryer.
- Solar field: eight parallel batteries, each battery with two solar air heaters in series.
- Effective area per battery.
- Mixing of solar-heated air streams.
- Auxiliary LPG heating.
- Drying tunnel.
- Recirculation.

Expected figure:

`FIG_01_system_schematic`

---

# 5. Mathematical model

`STATUS: PENDING`

Expected content:

## 5.1 Drying model

- Product mass balance.
- Moisture ratio.
- Final moisture criterion.
- Time step.

## 5.2 Thermal model

- Air temperature.
- Product temperature.
- Structure temperature.
- Auxiliary energy.

## 5.3 Solar collector representation

- Original constant efficiency.
- Historical embedded efficiency expression.
- 2-SAH curve used for sensitivity.
- Clarify that fully coupled dynamic collector modeling is future work.

## 5.4 Operational modes

- Hybrid.
- Gas-LPG reference.
- Solar endpoint treated separately, not as equivalent formal GA comparison if numerically invalid.

---

# 6. Optimization methodology

`STATUS: PARTIAL`

Expected content:

## 6.1 Decision variables

- Air mass flow rate.
- Minimum process temperature.
- Recirculation ratio.
- Recirculation start time.

## 6.2 Objective functions

- Final moisture ratio.
- Specific cost or auxiliary-energy-related economic indicator.
- CO2-related environmental indicator.

## 6.3 Constraints and feasibility criterion

- MR ≤ 0.1.
- Operational bounds.
- Simulation validity.

## 6.4 Seed-aware formal run

- Seed-aware replication.
- Controlled GA configuration.
- Exitflag interpretation.
- Do not claim global optimum.

Expected table:

`TABLE_01_GA_configuration`

---

# 7. Results and discussion

`STATUS: PARTIAL`

## 7.1 Formal tri-objective run

`STATUS: INTEGRATED_FROM_APPROVED_SECTION`

Source section:

`SEC_07_01_formal_R1_run_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

Approved internal verdict:

`SEC_07_01_FORMAL_R1_RUN_v96z_READY_FOR_MASTER_INTEGRATION`

### Formal tri-objective run

The formal seed-aware tri-objective run generated a computed nondominated set that represents the trade-off between final moisture ratio, auxiliary energy demand, and the economic/environmental indicators associated with the hybrid solar–LPG tunnel dryer operation. The term computed nondominated set is used deliberately, since the run corresponds to a controlled numerical realization of the multi-objective genetic algorithm and should not be interpreted as a proof of global optimality or statistical robustness over multiple independent seeds.

The evaluated solutions showed the expected conflict between deeper drying and lower auxiliary energy use. Solutions with lower final moisture ratio generally required higher thermal input, whereas energy-saving candidates accepted a higher final moisture ratio while remaining below the feasibility threshold. For this study, the operational feasibility criterion was defined as MR ≤ 0.1, which allows the analysis to distinguish between solutions that achieve sufficient drying and those that remain outside the acceptable final moisture range.

Among the evaluated candidates, R1_solution_7 was identified as the lowest-auxiliary-energy feasible solution. Under the 2-SAH collector-efficiency assumption used in the sensitivity evaluation, this solution reached MR = 0.07057 with Q_aux = 656.23 kWh. Its operating variables were m_dot = 0.070502 kg/s, T_min = 64.429 °C, r_rec = 0.74259, and t_rec_ini = 13.255 h. This combination indicates an energy-saving operating tendency characterized by relatively low airflow, a process temperature close to 65 °C, high recirculation, and recirculation activation during the intermediate-late drying stage.

R1_solution_3 represented a more balanced feasible candidate. It achieved MR = 0.05493 with Q_aux = 723.36 kWh under the same 2-SAH collector-efficiency assumption. Its operating variables were m_dot = 0.075518 kg/s, T_min = 65.054 °C, r_rec = 0.78863, and t_rec_ini = 12.874 h. Compared with R1_solution_7, this point provided deeper drying at the cost of higher auxiliary energy demand, making it useful as a compromise solution when a lower final moisture ratio is preferred.

The historical H2 solution was retained as a reference point because it achieved a lower final moisture ratio than both R1_solution_7 and R1_solution_3. Under the 2-SAH collector-efficiency assumption, H2 reached MR = 0.044483 with Q_aux = 747.00 kWh, using m_dot = 0.07355 kg/s, T_min = 65.879 °C, r_rec = 0.61205, and t_rec_ini = 12.385 h. Although H2 produced deeper drying, it did not correspond to the minimum auxiliary-energy candidate among the feasible solutions. Therefore, H2 should be interpreted as a historical comparison point rather than as the preferred energy-saving operating condition.

R1_solution_9 illustrated the opposite extreme of the trade-off. It achieved the lowest final moisture ratio among the selected points, MR = 0.013876, but required Q_aux = 1218.4 kWh under the 2-SAH collector-efficiency assumption. Its operating variables were m_dot = 0.092264 kg/s, T_min = 67.675 °C, r_rec = 0.43299, and t_rec_ini = 13.829 h. This point confirms that aggressive drying can be achieved, but only with a substantial auxiliary-energy penalty. Consequently, R1_solution_9 was not selected as a recommended operating point.

Overall, the formal R1 run indicates that the preferred operating region is not the deepest-drying condition, but rather a feasible compromise that satisfies MR ≤ 0.1 while reducing auxiliary energy demand. The selected candidates suggest a recurrent operating tendency around low-to-moderate airflow, minimum process temperatures near 64–66 °C, and recirculation activation after the initial drying period. However, this tendency should be interpreted as a result of the present model structure, operational bounds, and seed-aware computed run, not as a universal equipment-level optimum.

## 7.2 Collector-efficiency sensitivity

`STATUS: INTEGRATED_FROM_APPROVED_SECTION`

Source section:

`SEC_05_results_eta_sensitivity_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`

Approved internal verdict:

`SEC_05_RESULTS_ETA_SENSITIVITY_v96z_READY_FOR_MASTER_MANUSCRIPT`

### Tri-objective optimization results and collector-efficiency sensitivity

The seed-aware formal tri-objective run produced a computed nondominated set that captured the expected trade-off between final moisture ratio, auxiliary energy demand, and the associated economic/environmental indicators. Among the evaluated candidates, solution R1-7 was identified as the most attractive feasible operating point from an energy-saving perspective, whereas solution R1-3 represented a more balanced compromise between deeper drying and auxiliary energy demand. The historical H2 solution remained useful as a comparison point because it achieved a lower final moisture ratio, but it did not correspond to the lowest auxiliary energy requirement among the feasible candidates.

Under the selected feasibility criterion, MR ≤ 0.1, solution R1-7 achieved MR = 0.07057 with an auxiliary energy requirement of 656.23 kWh when the 2-SAH collector-efficiency curve was used. In contrast, the historical H2 point reached a lower MR = 0.04448 but required 747.00 kWh under the same collector-efficiency assumption. Solution R1-3 provided an intermediate behavior, with MR = 0.05493 and Q_aux = 723.36 kWh. These results indicate that the seed-aware run did not merely reproduce the historical H2 operating condition; rather, it identified feasible alternatives that reduce auxiliary energy demand while maintaining the final moisture ratio below the selected acceptability threshold.

A collector-efficiency sensitivity analysis was then performed to evaluate whether the use of a constant solar air heater efficiency could bias the operational selection. Three assumptions were compared: the original constant efficiency η = 0.50, the historical variable-efficiency expression embedded in the code, and the experimentally based 2-SAH efficiency curve, which is the configuration most consistent with the physical arrangement of the solar field batteries. The 2-SAH curve reduced the auxiliary energy demand by approximately 5–8% relative to the constant-efficiency case for the evaluated candidates. For example, Q_aux decreased from 807.02 to 747.00 kWh for H2, from 707.17 to 656.23 kWh for R1-7, from 787.59 to 723.36 kWh for R1-3, and from 1286.6 to 1218.4 kWh for R1-9.

Although the absolute auxiliary energy values were affected by the collector-efficiency assumption, the operational ranking was preserved. R1-7 remained the lowest-auxiliary-energy feasible candidate under MR ≤ 0.1, R1-3 remained the balanced feasible candidate, H2 remained a deeper-drying historical reference, and R1-9 remained an aggressive drying solution with high auxiliary demand. This result suggests that the main operational conclusion is not an artifact of the fixed-efficiency assumption. However, the analysis also shows that the collector model has a non-negligible effect on the energy balance; therefore, a fully coupled solar collector model remains a relevant improvement for future work.

## 7.3 Operational interpretation

`STATUS: INTEGRATED_FROM_APPROVED_SECTION`

Source section:

`SEC_07_03_operational_interpretation_v96z.md`

Source sections:

- `SEC_07_01_formal_R1_run_v96z.md`
- `SEC_05_results_eta_sensitivity_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

Approved internal verdict:

`SEC_07_03_OPERATIONAL_INTERPRETATION_v96z_READY_FOR_MASTER_INTEGRATION`

### Operational interpretation

The selected operating points suggest a consistent operational tendency for the hybrid solar–LPG tunnel dryer. The recommended feasible candidates are not located at the highest airflow or highest process temperature bounds. Instead, the most attractive solutions combine low-to-moderate airflow, minimum process temperatures close to 65 °C, high recirculation ratios, and recirculation activation after the initial drying period. This behavior is physically consistent with a drying process in which auxiliary energy demand can be reduced by avoiding excessive fresh-air heating while still maintaining enough thermal driving force for moisture removal.

R1_solution_7 is the clearest energy-saving candidate. Its airflow was the lowest among the selected feasible points, m_dot = 0.070502 kg/s, while its minimum process temperature remained close to 65 °C. The high recirculation ratio, r_rec = 0.74259, indicates that a large fraction of the process air was reused once recirculation was activated. Its recirculation start time, t_rec_ini = 13.255 h, suggests that the model favors allowing the early drying stage to proceed with lower recirculation influence and then increasing air reuse during a later stage, when the marginal benefit of heating fresh air becomes less favorable.

R1_solution_3 followed a similar operating pattern but shifted toward deeper drying. It used a slightly higher airflow, m_dot = 0.075518 kg/s, and a similar minimum process temperature, T_min = 65.054 °C, with an even higher recirculation ratio, r_rec = 0.78863. This combination produced a lower final moisture ratio than R1_solution_7, but required additional auxiliary energy. Therefore, R1_solution_3 can be interpreted as a balanced candidate when deeper drying is preferred over maximum auxiliary-energy reduction.

The historical H2 point occupied an intermediate position in terms of airflow and temperature, but it used a lower recirculation ratio than the R1 energy-saving candidates. Although H2 achieved a lower final moisture ratio, its auxiliary energy demand was higher than that of R1_solution_7. This suggests that the formal run did not simply reproduce the historical operating condition; rather, it identified operating combinations with greater air reuse that reduced auxiliary energy while maintaining acceptable final moisture.

R1_solution_9 represents a different regime. Its higher airflow and higher minimum temperature produced the deepest drying among the selected candidates, but this came with a substantial auxiliary-energy penalty. This point illustrates that increasing the thermal and airflow intensity can reduce the final moisture ratio, but the resulting operating condition may be unattractive from an energy-saving perspective. Therefore, R1_solution_9 is useful for understanding the trade-off boundary but should not be interpreted as a recommended operating condition.

Overall, the selected candidates indicate that the relevant operational trade-off is not simply between drying and no drying, but between sufficient drying and excessive thermal expenditure. Within the present model and operating bounds, the preferred region is characterized by maintaining the final moisture ratio below the feasibility threshold while avoiding unnecessarily aggressive drying. The resulting tendency toward low-to-moderate airflow, process temperatures near 64–66 °C, high recirculation, and delayed recirculation activation should be interpreted as a model-based operating recommendation. It should not be generalized without additional experimental validation, fan-power coupling, pressure-drop modeling, and independent optimization replications.

## 7.4 Methodological implications

`STATUS: INTEGRATED_FROM_APPROVED_SECTION`

Source section:

`SEC_07_04_methodological_implications_v96z.md`

Source sections:

- `SEC_07_01_formal_R1_run_v96z.md`
- `SEC_05_results_eta_sensitivity_v96z.md`
- `SEC_07_03_operational_interpretation_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

Approved internal verdict:

`SEC_07_04_METHODOLOGICAL_IMPLICATIONS_v96z_READY_FOR_MASTER_INTEGRATION`

### Methodological implications

The results have several methodological implications for the interpretation of the optimization framework. First, the selected operating condition should be understood as a model-based recommendation derived from a controlled computed nondominated set, not as a universal or experimentally proven optimum. The formal seed-aware run provided a structured comparison among feasible candidates and helped identify R1_solution_7 as the lowest-auxiliary-energy feasible point among the selected solutions. However, additional independent seed replications would be required before making claims about statistical robustness of the computed front.

Second, the collector-efficiency sensitivity analysis showed that the solar air heater representation has a measurable effect on the absolute auxiliary-energy balance. Replacing the constant efficiency assumption with the 2-SAH collector-efficiency curve reduced the auxiliary energy demand by approximately 5–8% for the evaluated candidates. Therefore, the fixed-efficiency assumption should not be treated as physically neutral. It affects the magnitude of the solar contribution and the auxiliary-energy requirement.

Nevertheless, the same sensitivity analysis also showed that the operational ranking was preserved. R1_solution_7 remained the lowest-auxiliary-energy feasible candidate, R1_solution_3 remained a balanced feasible alternative, H2 remained a deeper-drying historical reference, and R1_solution_9 remained an aggressive drying case with high auxiliary-energy demand. This indicates that the main operating conclusion is not merely an artifact of using a fixed collector efficiency. The conclusion is more appropriately stated as ranking-stable under the tested collector-efficiency assumptions, rather than universally robust.

Third, the results highlight the importance of distinguishing between process-level and equipment-level optimization. In the present model, the mass flow rate influences drying and thermal behavior, but fan power and pressure drop are not fully coupled to airflow. Consequently, the preference for low-to-moderate airflow should be interpreted as a process-model tendency, not as a complete equipment-level optimum. A more complete formulation should include fan performance, pressure losses, duct characteristics, and the electrical consumption associated with air movement.

Fourth, the recirculation strategy appears to be a relevant operational degree of freedom. The selected feasible candidates favored high recirculation ratios with activation after the initial drying period. This suggests that recirculation timing is not merely a secondary parameter, but an important mechanism for reducing auxiliary energy while maintaining sufficient drying. Future optimization studies should therefore avoid treating recirculation only as a fixed operating condition and should consider both its magnitude and activation time as decision variables.

Finally, the present results support using the R1 candidates as structured operating references for future experimental or simulation campaigns. R1_solution_7 is the primary energy-saving candidate, R1_solution_3 is the balanced feasible alternative, H2 is the historical comparison point, and R1_solution_9 is useful as an aggressive-drying boundary case. These candidates provide a compact experimental matrix for future validation, provided that the collector model, fan-power model, and cost/emissions factors are updated and fully traced before publication-level claims are made.

# 8. Limitations

`STATUS: PENDING`

Expected content:

- Single formal external seed run.
- No claim of global optimality.
- Collector efficiency sensitivity is not a fully coupled dynamic collector model.
- Fan power and pressure drop may not be dynamically linked to mass flow rate.
- Solar-only mode excluded from formal GA comparison when not numerically equivalent.
- CO2 and cost factors must be finalized before publication.

---

# 9. Conclusions

`STATUS: PENDING`

Expected content:

- The computed nondominated set identified feasible alternatives to the historical H2 point.
- R1-7 reduced auxiliary energy demand while maintaining MR ≤ 0.1.
- R1-3 provided a balanced feasible alternative.
- Collector-efficiency sensitivity changed absolute auxiliary energy values but preserved the operational ranking.
- Fully coupled collector modeling and additional seed replications are recommended future work.

---

# 10. Nomenclature

`STATUS: PENDING`

Candidate symbols:

| Symbol | Meaning | Unit |
|---|---|---|
| MR | Moisture ratio | - |
| Q_aux | Auxiliary energy demand | kWh |
| m_dot | Air mass flow rate | kg/s |
| T_min | Minimum process temperature | °C |
| r_rec | Recirculation ratio | - |
| t_rec_ini | Recirculation start time | h |
| η | Solar air heater efficiency | - |
| SAH | Solar air heater | - |

---

# 11. References

`STATUS: PENDING`

Required references:

- Thesis/model reference.
- Solar air heater 2-SAH efficiency article.
- Drying kinetics references.
- Multi-objective optimization references.
- Energy/emissions factor references, once finalized.

---

# 12. Supplementary material

`STATUS: PARTIAL`

Expected files:

- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- Seed-aware GA configuration.
- Traceability reports.
- Sensitivity checks.
- Selected MATLAB scripts, if publication policy allows.

---

# Internal traceability log

## Approved sections

| Section file | Status | Notes |
|---|---|---|
| `SEC_05_results_eta_sensitivity_v96z.md` | Approved | Collector-efficiency sensitivity and R1 selected candidates |

## Approved tables

| Table file | Status | Use |
|---|---|---|
| `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md` | Approved | Main Results table |
| `SUPP_TABLE_ETA_SENSITIVITY_v96z.md` | Approved | Supplementary sensitivity table |

## Restrictions

- Do not claim global optimum.
- Do not claim statistical robustness from one seed-aware formal run.
- Use “computed nondominated set” instead of “global Pareto front”.
- Keep H2 as historical comparison, not as final optimum.
- Treat 2-SAH collector curve as sensitivity, not as fully coupled collector model.
- Keep cost and CO2 provisional until factors and calculation path are fully traced.