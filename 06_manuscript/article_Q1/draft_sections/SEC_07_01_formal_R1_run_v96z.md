# SEC_07_01_formal_R1_run_v96z

## Status

`DRAFT_READY_FOR_REVIEW`

## Micropaso

`9.6z-results-draft-g`

## Identifier

`SAVE-SEC-07-01-FORMAL-R1-RUN-MD-001`

## Intended master location

`7.1 Formal tri-objective run`

## Source tables

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

## Manuscript text — English

### Formal tri-objective run

The formal seed-aware tri-objective run generated a computed nondominated set that represents the trade-off between final moisture ratio, auxiliary energy demand, and the economic/environmental indicators associated with the hybrid solar–LPG tunnel dryer operation. The term computed nondominated set is used deliberately, since the run corresponds to a controlled numerical realization of the multi-objective genetic algorithm and should not be interpreted as a proof of global optimality or statistical robustness over multiple independent seeds.

The evaluated solutions showed the expected conflict between deeper drying and lower auxiliary energy use. Solutions with lower final moisture ratio generally required higher thermal input, whereas energy-saving candidates accepted a higher final moisture ratio while remaining below the feasibility threshold. For this study, the operational feasibility criterion was defined as MR ≤ 0.1, which allows the analysis to distinguish between solutions that achieve sufficient drying and those that remain outside the acceptable final moisture range.

Among the evaluated candidates, R1_solution_7 was identified as the lowest-auxiliary-energy feasible solution. Under the 2-SAH collector-efficiency assumption used in the sensitivity evaluation, this solution reached MR = 0.07057 with Q_aux = 656.23 kWh. Its operating variables were m_dot = 0.070502 kg/s, T_min = 64.429 °C, r_rec = 0.74259, and t_rec_ini = 13.255 h. This combination indicates an energy-saving operating tendency characterized by relatively low airflow, a process temperature close to 65 °C, high recirculation, and recirculation activation during the intermediate-late drying stage.

R1_solution_3 represented a more balanced feasible candidate. It achieved MR = 0.05493 with Q_aux = 723.36 kWh under the same 2-SAH collector-efficiency assumption. Its operating variables were m_dot = 0.075518 kg/s, T_min = 65.054 °C, r_rec = 0.78863, and t_rec_ini = 12.874 h. Compared with R1_solution_7, this point provided deeper drying at the cost of higher auxiliary energy demand, making it useful as a compromise solution when a lower final moisture ratio is preferred.

The historical H2 solution was retained as a reference point because it achieved a lower final moisture ratio than both R1_solution_7 and R1_solution_3. Under the 2-SAH collector-efficiency assumption, H2 reached MR = 0.044483 with Q_aux = 747.00 kWh, using m_dot = 0.07355 kg/s, T_min = 65.879 °C, r_rec = 0.61205, and t_rec_ini = 12.385 h. Although H2 produced deeper drying, it did not correspond to the minimum auxiliary-energy candidate among the feasible solutions. Therefore, H2 should be interpreted as a historical comparison point rather than as the preferred energy-saving operating condition.

R1_solution_9 illustrated the opposite extreme of the trade-off. It achieved the lowest final moisture ratio among the selected points, MR = 0.013876, but required Q_aux = 1218.4 kWh under the 2-SAH collector-efficiency assumption. Its operating variables were m_dot = 0.092264 kg/s, T_min = 67.675 °C, r_rec = 0.43299, and t_rec_ini = 13.829 h. This point confirms that aggressive drying can be achieved, but only with a substantial auxiliary-energy penalty. Consequently, R1_solution_9 was not selected as a recommended operating point.

Overall, the formal R1 run indicates that the preferred operating region is not the deepest-drying condition, but rather a feasible compromise that satisfies MR ≤ 0.1 while reducing auxiliary energy demand. The selected candidates suggest a recurrent operating tendency around low-to-moderate airflow, minimum process temperatures near 64–66 °C, and recirculation activation after the initial drying period. However, this tendency should be interpreted as a result of the present model structure, operational bounds, and seed-aware computed run, not as a universal equipment-level optimum.

## Versión técnica de control — Español

### Corrida formal triobjetivo

La corrida formal triobjetivo con control explícito de semilla generó un conjunto no dominado computado que representa el compromiso entre la razón de humedad final, la demanda de energía auxiliar y los indicadores económico-ambientales asociados con la operación del secador híbrido solar–gas LP. El término conjunto no dominado computado se usa deliberadamente, ya que la corrida corresponde a una realización numérica controlada del algoritmo genético multiobjetivo y no debe interpretarse como prueba de optimalidad global ni de robustez estadística sobre múltiples semillas independientes.

Las soluciones evaluadas mostraron el conflicto esperado entre mayor secado y menor uso de energía auxiliar. Las soluciones con menor razón de humedad final generalmente requirieron mayor entrada térmica, mientras que los candidatos de ahorro energético aceptaron una razón de humedad final más alta, pero todavía por debajo del umbral de factibilidad. En este estudio, el criterio de factibilidad operativa se definió como MR ≤ 0.1, lo que permite distinguir entre soluciones con secado suficiente y soluciones fuera del intervalo aceptable de humedad final.

Entre los candidatos evaluados, R1_solution_7 se identificó como la solución factible de menor demanda auxiliar. Bajo el supuesto de eficiencia de captadores 2-SAH utilizado en la sensibilidad, esta solución alcanzó MR = 0.07057 con Q_aux = 656.23 kWh. Sus variables de operación fueron m_dot = 0.070502 kg/s, T_min = 64.429 °C, r_rec = 0.74259 y t_rec_ini = 13.255 h. Esta combinación indica una tendencia operativa de ahorro energético caracterizada por flujo de aire relativamente bajo, temperatura de proceso cercana a 65 °C, recirculación alta y activación de la recirculación durante una etapa intermedia-tardía del secado.

R1_solution_3 representó un candidato factible más balanceado. Alcanzó MR = 0.05493 con Q_aux = 723.36 kWh bajo el mismo supuesto de eficiencia 2-SAH. Sus variables de operación fueron m_dot = 0.075518 kg/s, T_min = 65.054 °C, r_rec = 0.78863 y t_rec_ini = 12.874 h. En comparación con R1_solution_7, este punto proporcionó mayor secado a costa de una mayor demanda de energía auxiliar, por lo que resulta útil como solución de compromiso cuando se prefiere una menor razón de humedad final.

La solución histórica H2 se conservó como punto de referencia porque alcanzó una razón de humedad final menor que R1_solution_7 y R1_solution_3. Bajo el supuesto de eficiencia 2-SAH, H2 alcanzó MR = 0.044483 con Q_aux = 747.00 kWh, usando m_dot = 0.07355 kg/s, T_min = 65.879 °C, r_rec = 0.61205 y t_rec_ini = 12.385 h. Aunque H2 produjo mayor secado, no correspondió al candidato de menor energía auxiliar entre las soluciones factibles. Por tanto, H2 debe interpretarse como referencia histórica de comparación, no como la condición operativa preferente desde la perspectiva de ahorro energético.

R1_solution_9 ilustró el extremo opuesto del compromiso. Alcanzó la menor razón de humedad final entre los puntos seleccionados, MR = 0.013876, pero requirió Q_aux = 1218.4 kWh bajo el supuesto de eficiencia 2-SAH. Sus variables de operación fueron m_dot = 0.092264 kg/s, T_min = 67.675 °C, r_rec = 0.43299 y t_rec_ini = 13.829 h. Este punto confirma que es posible lograr un secado agresivo, pero con una penalización sustancial en energía auxiliar. En consecuencia, R1_solution_9 no se seleccionó como punto operativo recomendado.

En conjunto, la corrida formal R1 indica que la región operativa preferente no corresponde a la condición de secado más profundo, sino a un compromiso factible que satisface MR ≤ 0.1 mientras reduce la demanda de energía auxiliar. Los candidatos seleccionados sugieren una tendencia operativa recurrente alrededor de flujo bajo a moderado, temperaturas mínimas de proceso cercanas a 64–66 °C y activación de la recirculación después del periodo inicial de secado. Sin embargo, esta tendencia debe interpretarse como resultado de la estructura del modelo, los límites operativos y la corrida computada con control de semilla, no como un óptimo universal a nivel de equipo.

## Traceability notes

### Approved numerical anchors

| Candidate | m_dot kg/s | T_min °C | r_rec | t_rec_ini h | Q_aux kWh | MR_final | Role |
|---|---:|---:|---:|---:|---:|---:|---|
| H2_historical | 0.07355 | 65.879 | 0.61205 | 12.385 | 747.00 | 0.044483 | Historical deeper-drying reference |
| R1_solution_7 | 0.070502 | 64.429 | 0.74259 | 13.255 | 656.23 | 0.07057 | Lowest auxiliary-energy feasible candidate |
| R1_solution_3 | 0.075518 | 65.054 | 0.78863 | 12.874 | 723.36 | 0.05493 | Balanced feasible candidate |
| R1_solution_9 | 0.092264 | 67.675 | 0.43299 | 13.829 | 1218.4 | 0.013876 | Aggressive drying, high auxiliary demand |

### Methodological restrictions

- Do not claim global optimum.
- Do not claim statistical robustness from a single seed-aware formal run.
- Use “computed nondominated set” instead of “global Pareto front”.
- Use R1_solution_7 as the energy-saving feasible candidate.
- Use R1_solution_3 as the balanced feasible candidate.
- Use H2_historical as a historical comparison point.
- Use R1_solution_9 as an aggressive drying case with high auxiliary-energy penalty.
- Interpret the selected operating tendency as model- and bounds-dependent, not as a universal equipment-level optimum.
- No GA was executed in this drafting step.
- No model simulation was executed in this drafting step.

## Internal verdict

`SEC_07_01_FORMAL_R1_RUN_v96z_READY_FOR_MASTER_INTEGRATION`