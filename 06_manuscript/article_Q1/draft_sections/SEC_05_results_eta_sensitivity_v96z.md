# SEC_05_results_eta_sensitivity_v96z

## Status

`APPROVED_DRAFT_SECTION`

## Micropaso

`9.6z-results-draft-c`

## Identifier

`SAVE-SEC-05-RESULTS-ETA-SENSITIVITY-MD-001`

## Source tables

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z_report.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

## Manuscript text — English

### Tri-objective optimization results and collector-efficiency sensitivity

The seed-aware formal tri-objective run produced a computed nondominated set that captured the expected trade-off between final moisture ratio, auxiliary energy demand, and the associated economic/environmental indicators. Among the evaluated candidates, solution R1-7 was identified as the most attractive feasible operating point from an energy-saving perspective, whereas solution R1-3 represented a more balanced compromise between deeper drying and auxiliary energy demand. The historical H2 solution remained useful as a comparison point because it achieved a lower final moisture ratio, but it did not correspond to the lowest auxiliary energy requirement among the feasible candidates.

Under the selected feasibility criterion, MR ≤ 0.1, solution R1-7 achieved MR = 0.07057 with an auxiliary energy requirement of 656.23 kWh when the 2-SAH collector-efficiency curve was used. In contrast, the historical H2 point reached a lower MR = 0.04448 but required 747.00 kWh under the same collector-efficiency assumption. Solution R1-3 provided an intermediate behavior, with MR = 0.05493 and Q_aux = 723.36 kWh. These results indicate that the seed-aware run did not merely reproduce the historical H2 operating condition; rather, it identified feasible alternatives that reduce auxiliary energy demand while maintaining the final moisture ratio below the selected acceptability threshold.

A collector-efficiency sensitivity analysis was then performed to evaluate whether the use of a constant solar air heater efficiency could bias the operational selection. Three assumptions were compared: the original constant efficiency η = 0.50, the historical variable-efficiency expression embedded in the code, and the experimentally based 2-SAH efficiency curve, which is the configuration most consistent with the physical arrangement of the solar field batteries. The 2-SAH curve reduced the auxiliary energy demand by approximately 5–8% relative to the constant-efficiency case for the evaluated candidates. For example, Q_aux decreased from 807.02 to 747.00 kWh for H2, from 707.17 to 656.23 kWh for R1-7, from 787.59 to 723.36 kWh for R1-3, and from 1286.6 to 1218.4 kWh for R1-9.

Although the absolute auxiliary energy values were affected by the collector-efficiency assumption, the operational ranking was preserved. R1-7 remained the lowest-auxiliary-energy feasible candidate under MR ≤ 0.1, R1-3 remained the balanced feasible candidate, H2 remained a deeper-drying historical reference, and R1-9 remained an aggressive drying solution with high auxiliary demand. This result suggests that the main operational conclusion is not an artifact of the fixed-efficiency assumption. However, the analysis also shows that the collector model has a non-negligible effect on the energy balance; therefore, a fully coupled solar collector model remains a relevant improvement for future work.

## Versión técnica de control — Español

### Resultados de la optimización triobjetivo y sensibilidad a la eficiencia de captadores

La corrida formal triobjetivo con control explícito de semilla produjo un conjunto no dominado computado que capturó el compromiso esperado entre la razón de humedad final, la demanda de energía auxiliar y los indicadores económico-ambientales asociados. Entre los candidatos evaluados, la solución R1-7 se identificó como el punto operativo factible más atractivo desde la perspectiva de ahorro energético, mientras que la solución R1-3 representó un compromiso más balanceado entre mayor secado y menor demanda auxiliar. La solución histórica H2 se mantuvo como un punto de comparación útil, ya que alcanzó una menor razón de humedad final, pero no correspondió al menor requerimiento de energía auxiliar entre los candidatos factibles.

Bajo el criterio de factibilidad seleccionado, MR ≤ 0.1, la solución R1-7 alcanzó MR = 0.07057 con una demanda auxiliar de 656.23 kWh cuando se empleó la curva de eficiencia para 2 SAHs. En contraste, el punto histórico H2 alcanzó una menor razón de humedad, MR = 0.04448, pero requirió 747.00 kWh bajo el mismo supuesto de eficiencia de captadores. La solución R1-3 presentó un comportamiento intermedio, con MR = 0.05493 y Q_aux = 723.36 kWh. Estos resultados indican que la corrida con semilla externa no solo reprodujo la condición histórica H2, sino que identificó alternativas factibles que reducen la demanda auxiliar manteniendo la razón de humedad final por debajo del umbral de aceptación seleccionado.

Posteriormente se realizó una sensibilidad a la eficiencia de captadores para evaluar si el uso de una eficiencia constante podía sesgar la selección operativa. Se compararon tres supuestos: la eficiencia constante original η = 0.50, la expresión variable histórica embebida en el código y la curva experimental para 2 SAHs, que corresponde de manera más consistente con el arreglo físico de cada batería del campo solar. La curva 2-SAH redujo la demanda auxiliar aproximadamente entre 5 y 8% respecto al caso de eficiencia constante para los candidatos evaluados. Por ejemplo, Q_aux disminuyó de 807.02 a 747.00 kWh para H2, de 707.17 a 656.23 kWh para R1-7, de 787.59 a 723.36 kWh para R1-3, y de 1286.6 a 1218.4 kWh para R1-9.

Aunque los valores absolutos de energía auxiliar se modificaron por el supuesto de eficiencia de captadores, el orden operativo se preservó. R1-7 permaneció como el candidato factible de menor demanda auxiliar bajo MR ≤ 0.1; R1-3 permaneció como el candidato factible balanceado; H2 se mantuvo como referencia histórica de secado más profundo; y R1-9 continuó siendo una solución de secado agresivo con alta demanda auxiliar. Este resultado sugiere que la conclusión operativa principal no es un artefacto del supuesto de eficiencia fija. Sin embargo, el análisis también muestra que el modelo de captadores tiene un efecto no despreciable sobre el balance energético; por tanto, un modelo de captadores solares completamente acoplado sigue siendo una mejora relevante para trabajo futuro.

## Traceability notes

### Approved numerical anchors

| Case | Eta assumption | m_dot kg/s | T_min °C | r_rec | t_rec_ini h | Q_aux kWh | MR_final | Interpretation |
|---|---|---:|---:|---:|---:|---:|---:|---|
| H2_historical | 2-SAH efficiency curve | 0.07355 | 65.879 | 0.61205 | 12.385 | 747.00 | 0.044483 | Historical deeper-drying reference |
| R1_solution_7 | 2-SAH efficiency curve | 0.070502 | 64.429 | 0.74259 | 13.255 | 656.23 | 0.07057 | Lowest auxiliary-energy feasible candidate |
| R1_solution_3 | 2-SAH efficiency curve | 0.075518 | 65.054 | 0.78863 | 12.874 | 723.36 | 0.05493 | Balanced feasible candidate |
| R1_solution_9 | 2-SAH efficiency curve | 0.092264 | 67.675 | 0.43299 | 13.829 | 1218.4 | 0.013876 | Aggressive drying, high auxiliary demand |

### Collector-efficiency sensitivity summary

| Case | Q_aux eta=0.50 kWh | Q_aux 2-SAH curve kWh | Delta Q_aux % | MR eta=0.50 | MR 2-SAH curve | Ranking preserved |
|---|---:|---:|---:|---:|---:|---|
| H2_historical | 807.02 | 747.00 | -7.4379 | 0.044483 | 0.044483 | Yes |
| R1_solution_7 | 707.17 | 656.23 | -7.2046 | 0.071976 | 0.07057 | Yes |
| R1_solution_3 | 787.59 | 723.36 | -8.1556 | 0.054864 | 0.05493 | Yes |
| R1_solution_9 | 1286.6 | 1218.4 | -5.2993 | 0.013876 | 0.013876 | Yes |

### Methodological restrictions

- Do not claim global optimum.
- Do not claim statistical robustness from a single formal seed-aware run.
- Use “computed nondominated set” or “computed front”, not “global Pareto front”.
- Do not use the historical embedded efficiency expression as the validated collector curve.
- Use the 2-SAH curve only as a sensitivity assumption consistent with the physical battery configuration.
- State that a fully coupled solar collector model remains future work.
- No GA was executed in this manuscript-table generation step.
- No model simulation was executed in this manuscript-table generation step.

## Internal verdict

`SEC_05_RESULTS_ETA_SENSITIVITY_v96z_READY_FOR_MASTER_MANUSCRIPT`