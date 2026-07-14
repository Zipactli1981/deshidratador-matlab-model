# SEC_07_04_methodological_implications_v96z

## Status

`DRAFT_READY_FOR_REVIEW`

## Micropaso

`9.6z-results-draft-m`

## Identifier

`SAVE-SEC-07-04-METHODOLOGICAL-IMPLICATIONS-MD-001`

## Intended master location

`7.4 Methodological implications`

## Source sections

- `SEC_07_01_formal_R1_run_v96z.md`
- `SEC_05_results_eta_sensitivity_v96z.md`
- `SEC_07_03_operational_interpretation_v96z.md`

## Source tables

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

## Manuscript text — English

### Methodological implications

The results have several methodological implications for the interpretation of the optimization framework. First, the selected operating condition should be understood as a model-based recommendation derived from a controlled computed nondominated set, not as a universal or experimentally proven optimum. The formal seed-aware run provided a structured comparison among feasible candidates and helped identify R1_solution_7 as the lowest-auxiliary-energy feasible point among the selected solutions. However, additional independent seed replications would be required before making claims about statistical robustness of the computed front.

Second, the collector-efficiency sensitivity analysis showed that the solar air heater representation has a measurable effect on the absolute auxiliary-energy balance. Replacing the constant efficiency assumption with the 2-SAH collector-efficiency curve reduced the auxiliary energy demand by approximately 5–8% for the evaluated candidates. Therefore, the fixed-efficiency assumption should not be treated as physically neutral. It affects the magnitude of the solar contribution and the auxiliary-energy requirement.

Nevertheless, the same sensitivity analysis also showed that the operational ranking was preserved. R1_solution_7 remained the lowest-auxiliary-energy feasible candidate, R1_solution_3 remained a balanced feasible alternative, H2 remained a deeper-drying historical reference, and R1_solution_9 remained an aggressive drying case with high auxiliary-energy demand. This indicates that the main operating conclusion is not merely an artifact of using a fixed collector efficiency. The conclusion is more appropriately stated as ranking-stable under the tested collector-efficiency assumptions, rather than universally robust.

Third, the results highlight the importance of distinguishing between process-level and equipment-level optimization. In the present model, the mass flow rate influences drying and thermal behavior, but fan power and pressure drop are not fully coupled to airflow. Consequently, the preference for low-to-moderate airflow should be interpreted as a process-model tendency, not as a complete equipment-level optimum. A more complete formulation should include fan performance, pressure losses, duct characteristics, and the electrical consumption associated with air movement.

Fourth, the recirculation strategy appears to be a relevant operational degree of freedom. The selected feasible candidates favored high recirculation ratios with activation after the initial drying period. This suggests that recirculation timing is not merely a secondary parameter, but an important mechanism for reducing auxiliary energy while maintaining sufficient drying. Future optimization studies should therefore avoid treating recirculation only as a fixed operating condition and should consider both its magnitude and activation time as decision variables.

Finally, the present results support using the R1 candidates as structured operating references for future experimental or simulation campaigns. R1_solution_7 is the primary energy-saving candidate, R1_solution_3 is the balanced feasible alternative, H2 is the historical comparison point, and R1_solution_9 is useful as an aggressive-drying boundary case. These candidates provide a compact experimental matrix for future validation, provided that the collector model, fan-power model, and cost/emissions factors are updated and fully traced before publication-level claims are made.

## Versión técnica de control — Español

### Implicaciones metodológicas

Los resultados tienen varias implicaciones metodológicas para la interpretación del marco de optimización. Primero, la condición operativa seleccionada debe entenderse como una recomendación basada en modelo, derivada de un conjunto no dominado computado bajo condiciones controladas, no como un óptimo universal ni experimentalmente probado. La corrida formal con control explícito de semilla permitió comparar de manera estructurada candidatos factibles e identificar a R1_solution_7 como el punto factible de menor demanda auxiliar entre las soluciones seleccionadas. Sin embargo, se requerirían réplicas adicionales con semillas independientes antes de formular afirmaciones de robustez estadística del frente computado.

Segundo, la sensibilidad a la eficiencia de captadores mostró que la representación del calentador solar de aire tiene un efecto medible sobre el balance absoluto de energía auxiliar. Sustituir el supuesto de eficiencia constante por la curva de eficiencia 2-SAH redujo la demanda de energía auxiliar aproximadamente entre 5 y 8% para los candidatos evaluados. Por tanto, el supuesto de eficiencia fija no debe tratarse como físicamente neutro. Este supuesto afecta la magnitud de la contribución solar y el requerimiento de energía auxiliar.

Sin embargo, el mismo análisis de sensibilidad mostró que el orden operativo se preservó. R1_solution_7 permaneció como el candidato factible de menor demanda auxiliar, R1_solution_3 permaneció como alternativa factible balanceada, H2 se mantuvo como referencia histórica de secado más profundo y R1_solution_9 permaneció como caso de secado agresivo con alta demanda de energía auxiliar. Esto indica que la conclusión operativa principal no es simplemente un artefacto del uso de eficiencia fija de captadores. La conclusión debe formularse con mayor precisión como estable en ranking bajo los supuestos de eficiencia de captadores evaluados, no como universalmente robusta.

Tercero, los resultados resaltan la importancia de distinguir entre optimización a nivel de proceso y optimización a nivel de equipo. En el modelo actual, el flujo másico influye sobre el secado y el comportamiento térmico, pero la potencia de ventilador y la caída de presión no están completamente acopladas al flujo de aire. En consecuencia, la preferencia por flujo bajo a moderado debe interpretarse como una tendencia del modelo de proceso, no como un óptimo completo a nivel de equipo. Una formulación más completa debería incluir desempeño del ventilador, pérdidas de presión, características de ductos y consumo eléctrico asociado al movimiento de aire.

Cuarto, la estrategia de recirculación aparece como un grado de libertad operativo relevante. Los candidatos factibles seleccionados favorecieron relaciones de recirculación altas con activación posterior al periodo inicial de secado. Esto sugiere que el tiempo de inicio de recirculación no es simplemente un parámetro secundario, sino un mecanismo importante para reducir energía auxiliar manteniendo secado suficiente. Por tanto, futuros estudios de optimización deberían evitar tratar la recirculación solo como una condición fija y deberían considerar tanto su magnitud como su tiempo de activación como variables de decisión.

Finalmente, los resultados apoyan el uso de los candidatos R1 como referencias operativas estructuradas para futuras campañas experimentales o de simulación. R1_solution_7 es el candidato primario de ahorro energético, R1_solution_3 es la alternativa factible balanceada, H2 es el punto histórico de comparación y R1_solution_9 es útil como caso límite de secado agresivo. Estos candidatos proporcionan una matriz experimental compacta para validación futura, siempre que el modelo de captadores, el modelo de potencia de ventilador y los factores de costo/emisiones se actualicen y queden completamente trazados antes de formular afirmaciones de nivel publicable.

## Traceability notes

### Methodological implications captured

| Topic | Manuscript treatment |
|---|---|
| Global optimality | Explicitly avoided |
| Statistical robustness | Not claimed; additional seeds required |
| Collector efficiency | Affects absolute auxiliary-energy balance |
| Ranking stability | Preserved under tested collector-efficiency assumptions |
| Process vs equipment optimization | Explicitly distinguished |
| Fan power | Identified as missing coupling |
| Pressure drop | Identified as missing coupling |
| Recirculation timing | Treated as relevant decision variable |
| Future validation | R1 candidates proposed as compact validation matrix |

### Candidate roles for future validation

| Candidate | Role |
|---|---|
| R1_solution_7 | Primary energy-saving candidate |
| R1_solution_3 | Balanced feasible alternative |
| H2_historical | Historical comparison point |
| R1_solution_9 | Aggressive-drying boundary case |

### Methodological restrictions

- Do not claim global optimum.
- Do not claim statistical robustness from one seed-aware formal run.
- Use “computed nondominated set” or “computed front”.
- State that the result is ranking-stable under tested assumptions, not universally robust.
- Treat the 2-SAH collector curve as a sensitivity model, not as a fully coupled collector model.
- Keep process-level and equipment-level interpretation separate.
- Do not infer fan-energy optimality until fan power and pressure drop are coupled.
- Keep cost and CO2 claims provisional until factors and calculation paths are fully traced.
- No GA was executed in this drafting step.
- No model simulation was executed in this drafting step.

## Internal verdict

`SEC_07_04_METHODOLOGICAL_IMPLICATIONS_v96z_READY_FOR_MASTER_INTEGRATION`