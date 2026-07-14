# SEC_07_03_operational_interpretation_v96z

## Status

`DRAFT_READY_FOR_REVIEW`

## Micropaso

`9.6z-results-draft-j`

## Identifier

`SAVE-SEC-07-03-OPERATIONAL-INTERPRETATION-MD-001`

## Intended master location

`7.3 Operational interpretation`

## Source sections

- `SEC_07_01_formal_R1_run_v96z.md`
- `SEC_05_results_eta_sensitivity_v96z.md`

## Source tables

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

## Manuscript text — English

### Operational interpretation

The selected operating points suggest a consistent operational tendency for the hybrid solar–LPG tunnel dryer. The recommended feasible candidates are not located at the highest airflow or highest process temperature bounds. Instead, the most attractive solutions combine low-to-moderate airflow, minimum process temperatures close to 65 °C, high recirculation ratios, and recirculation activation after the initial drying period. This behavior is physically consistent with a drying process in which auxiliary energy demand can be reduced by avoiding excessive fresh-air heating while still maintaining enough thermal driving force for moisture removal.

R1_solution_7 is the clearest energy-saving candidate. Its airflow was the lowest among the selected feasible points, m_dot = 0.070502 kg/s, while its minimum process temperature remained close to 65 °C. The high recirculation ratio, r_rec = 0.74259, indicates that a large fraction of the process air was reused once recirculation was activated. Its recirculation start time, t_rec_ini = 13.255 h, suggests that the model favors allowing the early drying stage to proceed with lower recirculation influence and then increasing air reuse during a later stage, when the marginal benefit of heating fresh air becomes less favorable.

R1_solution_3 followed a similar operating pattern but shifted toward deeper drying. It used a slightly higher airflow, m_dot = 0.075518 kg/s, and a similar minimum process temperature, T_min = 65.054 °C, with an even higher recirculation ratio, r_rec = 0.78863. This combination produced a lower final moisture ratio than R1_solution_7, but required additional auxiliary energy. Therefore, R1_solution_3 can be interpreted as a balanced candidate when deeper drying is preferred over maximum auxiliary-energy reduction.

The historical H2 point occupied an intermediate position in terms of airflow and temperature, but it used a lower recirculation ratio than the R1 energy-saving candidates. Although H2 achieved a lower final moisture ratio, its auxiliary energy demand was higher than that of R1_solution_7. This suggests that the formal run did not simply reproduce the historical operating condition; rather, it identified operating combinations with greater air reuse that reduced auxiliary energy while maintaining acceptable final moisture.

R1_solution_9 represents a different regime. Its higher airflow and higher minimum temperature produced the deepest drying among the selected candidates, but this came with a substantial auxiliary-energy penalty. This point illustrates that increasing the thermal and airflow intensity can reduce the final moisture ratio, but the resulting operating condition may be unattractive from an energy-saving perspective. Therefore, R1_solution_9 is useful for understanding the trade-off boundary but should not be interpreted as a recommended operating condition.

Overall, the selected candidates indicate that the relevant operational trade-off is not simply between drying and no drying, but between sufficient drying and excessive thermal expenditure. Within the present model and operating bounds, the preferred region is characterized by maintaining the final moisture ratio below the feasibility threshold while avoiding unnecessarily aggressive drying. The resulting tendency toward low-to-moderate airflow, process temperatures near 64–66 °C, high recirculation, and delayed recirculation activation should be interpreted as a model-based operating recommendation. It should not be generalized without additional experimental validation, fan-power coupling, pressure-drop modeling, and independent optimization replications.

## Versión técnica de control — Español

### Interpretación operativa

Los puntos operativos seleccionados sugieren una tendencia operativa consistente para el secador híbrido solar–gas LP. Los candidatos factibles recomendados no se ubican en los límites superiores de flujo de aire ni de temperatura de proceso. En cambio, las soluciones más atractivas combinan flujo bajo a moderado, temperaturas mínimas de proceso cercanas a 65 °C, relaciones de recirculación altas y activación de la recirculación después del periodo inicial de secado. Este comportamiento es físicamente consistente con un proceso en el que la demanda de energía auxiliar puede reducirse al evitar el calentamiento excesivo de aire fresco, manteniendo al mismo tiempo una fuerza impulsora térmica suficiente para la remoción de humedad.

R1_solution_7 es el candidato de ahorro energético más claro. Su flujo de aire fue el menor entre los puntos factibles seleccionados, m_dot = 0.070502 kg/s, mientras que su temperatura mínima de proceso permaneció cercana a 65 °C. La relación de recirculación alta, r_rec = 0.74259, indica que una fracción elevada del aire de proceso se reutilizó una vez activada la recirculación. Su tiempo de inicio de recirculación, t_rec_ini = 13.255 h, sugiere que el modelo favorece permitir que la etapa inicial de secado avance con menor influencia de recirculación y posteriormente aumentar la reutilización de aire durante una etapa más tardía, cuando el beneficio marginal de calentar aire fresco se vuelve menos favorable.

R1_solution_3 siguió un patrón operativo similar, pero desplazado hacia un secado más profundo. Utilizó un flujo ligeramente mayor, m_dot = 0.075518 kg/s, y una temperatura mínima de proceso similar, T_min = 65.054 °C, con una relación de recirculación aún más alta, r_rec = 0.78863. Esta combinación produjo una razón de humedad final menor que R1_solution_7, pero requirió más energía auxiliar. Por tanto, R1_solution_3 puede interpretarse como un candidato balanceado cuando se prefiere mayor secado sobre la máxima reducción de energía auxiliar.

El punto histórico H2 ocupó una posición intermedia en términos de flujo y temperatura, pero utilizó una relación de recirculación menor que los candidatos de ahorro energético R1. Aunque H2 alcanzó una razón de humedad final menor, su demanda de energía auxiliar fue mayor que la de R1_solution_7. Esto sugiere que la corrida formal no simplemente reprodujo la condición histórica, sino que identificó combinaciones operativas con mayor reutilización de aire que redujeron la energía auxiliar manteniendo una humedad final aceptable.

R1_solution_9 representa un régimen distinto. Su mayor flujo y mayor temperatura mínima produjeron el secado más profundo entre los candidatos seleccionados, pero con una penalización sustancial en energía auxiliar. Este punto ilustra que incrementar la intensidad térmica y de flujo puede reducir la razón de humedad final, pero la condición operativa resultante puede ser poco atractiva desde una perspectiva de ahorro energético. Por tanto, R1_solution_9 es útil para comprender la frontera de compromiso, pero no debe interpretarse como una condición operativa recomendada.

En conjunto, los candidatos seleccionados indican que el compromiso operativo relevante no es simplemente entre secar y no secar, sino entre secado suficiente y gasto térmico excesivo. Dentro del modelo y los límites operativos presentes, la región preferente se caracteriza por mantener la razón de humedad final por debajo del umbral de factibilidad evitando un secado innecesariamente agresivo. La tendencia resultante hacia flujo bajo a moderado, temperaturas de proceso cercanas a 64–66 °C, recirculación alta y activación retardada de la recirculación debe interpretarse como una recomendación operativa basada en el modelo. No debe generalizarse sin validación experimental adicional, acoplamiento de potencia de ventilador, modelado de caída de presión y réplicas independientes de optimización.

## Traceability notes

### Operational roles

| Candidate | Role | Operational interpretation |
|---|---|---|
| R1_solution_7 | Energy-saving feasible candidate | Lowest auxiliary-energy candidate while satisfying MR ≤ 0.1 |
| R1_solution_3 | Balanced feasible candidate | Deeper drying than R1_solution_7 with moderate additional auxiliary energy |
| H2_historical | Historical comparison point | Deeper drying than R1_solution_7, but higher auxiliary energy demand |
| R1_solution_9 | Aggressive drying case | Lowest MR among selected points, but high auxiliary-energy penalty |

### Numerical anchors

| Candidate | m_dot kg/s | T_min °C | r_rec | t_rec_ini h | Q_aux kWh | MR_final |
|---|---:|---:|---:|---:|---:|---:|
| R1_solution_7 | 0.070502 | 64.429 | 0.74259 | 13.255 | 656.23 | 0.07057 |
| R1_solution_3 | 0.075518 | 65.054 | 0.78863 | 12.874 | 723.36 | 0.05493 |
| H2_historical | 0.07355 | 65.879 | 0.61205 | 12.385 | 747.00 | 0.044483 |
| R1_solution_9 | 0.092264 | 67.675 | 0.43299 | 13.829 | 1218.4 | 0.013876 |

### Methodological restrictions

- Do not generalize the selected tendency as a universal equipment-level optimum.
- Do not claim global optimality.
- Do not claim statistical robustness from one seed-aware formal run.
- Keep interpretation tied to the present model structure and operational bounds.
- Explicitly mention missing fan-power and pressure-drop coupling as limitations.
- Treat R1_solution_7 as the energy-saving feasible recommendation.
- Treat R1_solution_3 as the balanced feasible alternative.
- Treat H2_historical as a historical reference, not as the final preferred operating point.
- Treat R1_solution_9 as a trade-off boundary case, not as a recommended condition.
- No GA was executed in this drafting step.
- No model simulation was executed in this drafting step.

## Internal verdict

`SEC_07_03_OPERATIONAL_INTERPRETATION_v96z_READY_FOR_MASTER_INTEGRATION`