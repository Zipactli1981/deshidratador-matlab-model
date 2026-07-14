# SEC_07_02_01_hybrid_vs_gasLP_baseline_v96z

## Status

`DRAFT_READY_FOR_REVIEW`

## Micropaso

`9.6z-sim-lite-c`

## Identifier

`SAVE-HYBRID-vs-GASLP-BASELINE-COMPARISON-MD-001`

## Intended master location

`7.2.1 Hybrid versus gas-LPG baseline comparison`

## Source analysis

- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z.csv`
- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.csv`
- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md`
- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z_report.md`

## Manuscript text — English

### Hybrid versus gas-LPG baseline comparison

A pointwise baseline comparison was performed to quantify the auxiliary-energy reduction obtained by operating the selected candidates in hybrid mode instead of gas-LPG-only mode. This comparison was not a new optimization run. The same selected operating points were evaluated under both operation modes using the 2-SAH collector-efficiency curve for the hybrid case. The purpose was to isolate the contribution of the solar field to the auxiliary-energy balance while preserving the selected decision-variable combinations.

For all selected candidates, hybrid operation reduced the auxiliary energy demand relative to the gas-LPG-only case while maintaining the final moisture ratio below the feasibility threshold. The reduction in auxiliary energy ranged from 31.31% to 45.05%. For the historical H2 point, Q_aux decreased from 1292.6 kWh in gas-LPG-only mode to 747.00 kWh in hybrid mode, corresponding to a 42.21% reduction. For R1_solution_7, the energy-saving feasible candidate, Q_aux decreased from 1194.1 kWh to 656.23 kWh, corresponding to the largest relative reduction among the selected points, 45.05%. R1_solution_3 showed a 43.07% reduction, while R1_solution_9 showed a lower relative reduction of 31.31%, consistent with its more aggressive drying condition and higher auxiliary-energy demand.

The final moisture ratios remained very similar between the hybrid and gas-LPG-only evaluations. This indicates that the hybrid configuration reduced auxiliary energy demand mainly by replacing part of the thermal requirement with solar contribution, rather than by relaxing the drying performance. In particular, R1_solution_7 remained feasible under both operation modes, with MR = 0.07057 in hybrid mode and MR = 0.071992 in gas-LPG-only mode. Therefore, the hybrid mode improved the energy balance of the selected operating points without compromising the moisture-ratio feasibility criterion.

These results provide a direct baseline interpretation of the selected candidates. They support the use of R1_solution_7 as the primary energy-saving operating point, since it combined the lowest hybrid auxiliary-energy demand with the largest relative reduction compared with the gas-LPG-only baseline. The comparison also reinforces the role of R1_solution_3 as a balanced feasible alternative and confirms that R1_solution_9, although technically feasible in terms of final moisture ratio, remains energetically unattractive.

## Versión técnica de control — Español

### Comparación base: operación híbrida contra operación solo gas LP

Se realizó una comparación base puntual para cuantificar la reducción de energía auxiliar obtenida al operar los candidatos seleccionados en modo híbrido en lugar de modo solo gas LP. Esta comparación no corresponde a una nueva optimización. Los mismos puntos operativos seleccionados se evaluaron bajo ambos modos de operación, usando la curva de eficiencia 2-SAH para el caso híbrido. El propósito fue aislar la contribución del campo solar al balance de energía auxiliar, manteniendo las mismas combinaciones de variables de decisión.

Para todos los candidatos seleccionados, la operación híbrida redujo la demanda de energía auxiliar respecto al caso solo gas LP, manteniendo la razón de humedad final por debajo del umbral de factibilidad. La reducción de energía auxiliar se ubicó entre 31.31% y 45.05%. Para el punto histórico H2, Q_aux disminuyó de 1292.6 kWh en modo solo gas LP a 747.00 kWh en modo híbrido, lo que corresponde a una reducción de 42.21%. Para R1_solution_7, el candidato factible de ahorro energético, Q_aux disminuyó de 1194.1 kWh a 656.23 kWh, correspondiente a la mayor reducción relativa entre los puntos seleccionados, 45.05%. R1_solution_3 mostró una reducción de 43.07%, mientras que R1_solution_9 presentó una reducción relativa menor, de 31.31%, consistente con su condición de secado más agresiva y mayor demanda de energía auxiliar.

Las razones de humedad finales se mantuvieron muy similares entre las evaluaciones híbridas y solo gas LP. Esto indica que la configuración híbrida redujo la demanda de energía auxiliar principalmente al sustituir parte del requerimiento térmico con contribución solar, no al relajar el desempeño de secado. En particular, R1_solution_7 permaneció factible bajo ambos modos de operación, con MR = 0.07057 en modo híbrido y MR = 0.071992 en modo solo gas LP. Por tanto, el modo híbrido mejoró el balance energético de los puntos seleccionados sin comprometer el criterio de factibilidad por razón de humedad.

Estos resultados proporcionan una interpretación base directa de los candidatos seleccionados. Apoyan el uso de R1_solution_7 como punto operativo primario de ahorro energético, ya que combinó la menor demanda auxiliar en modo híbrido con la mayor reducción relativa frente al caso solo gas LP. La comparación también refuerza el papel de R1_solution_3 como alternativa factible balanceada y confirma que R1_solution_9, aunque técnicamente factible en términos de razón de humedad final, sigue siendo poco atractivo desde el punto de vista energético.

## Traceability notes

### Baseline comparison table

| Case | Q_aux hybrid kWh | Q_aux gas-LPG kWh | Reduction kWh | Reduction % | MR hybrid | MR gas-LPG | Interpretation |
|---|---:|---:|---:|---:|---:|---:|---|
| H2_historical | 747.00 | 1292.6 | 545.56 | 42.21 | 0.044483 | 0.044483 | Historical deeper-drying reference |
| R1_solution_7 | 656.23 | 1194.1 | 537.89 | 45.05 | 0.07057 | 0.071992 | Energy-saving feasible candidate |
| R1_solution_3 | 723.36 | 1270.6 | 547.22 | 43.07 | 0.05493 | 0.054863 | Balanced feasible candidate |
| R1_solution_9 | 1218.4 | 1773.9 | 555.46 | 31.31 | 0.013876 | 0.013876 | Aggressive drying boundary case |

### Interpretation constraints

- This is a pointwise baseline comparison.
- This is not a new GA run.
- This is not a new optimization.
- The same selected decision-variable combinations were evaluated in hybrid and gas-LPG-only modes.
- The hybrid case used the 2-SAH collector-efficiency curve.
- The gas-LPG-only case used zero solar contribution.
- The comparison supports baseline energy reduction, not global optimality.
- All selected points remained feasible under MR ≤ 0.1.
- R1_solution_7 remained the lowest hybrid auxiliary-energy candidate.
- No GA was executed in this comparison.
- No optimization was executed in this comparison.

## Internal verdict

`SEC_07_02_01_HYBRID_vs_GASLP_BASELINE_v96z_READY_FOR_MASTER_OR_SUPPLEMENTARY_INTEGRATION`