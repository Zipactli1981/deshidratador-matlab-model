# SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z

## Status

`DRAFT_READY_FOR_REVIEW`

## Micropaso

`9.6z-conclusions-a`

## Identifier

`BUILD-CONCLUSIONS-CONSOLIDATED-DRAFT-001`

## Intended master location

Conclusions section, after Discussion/Limitations and before References.

## Source controls

- `RESULTS_SECTION_07_v01_1_LOCKED.md`
- `MASTER_MANUSCRIPT_CONSISTENCY_AFTER_DISCUSSION_v96z_report.md`
- `INTEGRATE_DISCUSSION_CONSOLIDATED_DRAFT_INTO_MASTER_v96z_report.md`
- `INTEGRATE_LIMITATIONS_CONSOLIDATED_BLOCK_INTO_MASTER_v96z_report.md`
- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md`
- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md`

## Manuscript text -- English

### Conclusions

This study developed a controlled multiobjective optimization and post-processing workflow for a hybrid solar--gas-LPG tunnel dryer, with explicit traceability between the formal R1 optimization, collector-efficiency sensitivity, and hybrid versus gas-LPG baseline comparison. Under the modeled conditions, the hybrid configuration showed a consistent ability to reduce auxiliary-energy demand while preserving feasible drying performance for the selected operating points.

Within the computed nondominated set, R1_solution_7 emerged as the main energy-conservative feasible candidate, whereas R1_solution_3 provided a balanced alternative between drying intensity and energy use. R1_solution_9 represented a more aggressive drying strategy with a larger energy penalty, and H2 was retained only as a historical reference rather than as a newly optimized R1 solution. This distinction supports an operational interpretation based on feasible trade-offs instead of selecting the deepest-drying point by default.

The collector-efficiency sensitivity analysis, particularly the 2-SAH curve consistent with the physical series arrangement of the solar air heaters, did not alter the qualitative ranking of the selected candidates. This supports the stability of the main operational interpretation under a more physically consistent collector-efficiency assumption. However, the collector treatment remains a sensitivity representation and not a fully coupled dynamic collector model.

The hybrid versus gas-LPG comparison indicated that the solar contribution can reduce auxiliary-energy demand mainly through fuel substitution, not by relaxing the drying requirement. Consequently, the hybrid system should be interpreted as a promising energy-saving operating strategy under the current model assumptions. Final economic or CO2 claims should remain conditional until fuel-price, electricity-tariff, emission-factor, date, region, unit-basis, and conversion assumptions are definitively sourced and locked.

The main methodological limitations are associated with the use of a single formal R1 seed-aware run, the absence of independent seed replications, the sensitivity-level collector treatment, and the lack of fully coupled fan-power and pressure-drop objectives. Future work should therefore evaluate additional random seeds, implement a coupled collector and airflow-network formulation, include fan-power and pressure-drop penalties, and finalize the economic and emission factors before making publication-grade cost or CO2 claims.

Overall, the results provide a reproducible and traceable basis for selecting candidate operating points for subsequent experimental or high-fidelity numerical validation. The conclusions should not be interpreted as proof of complete search-space convergence, statistical robustness across seeds, or complete equipment-level optimality.

## Version tecnica de control -- Espanol

### Conclusiones

Este estudio desarrollo un flujo controlado de optimizacion multiobjetivo y postprocesamiento para un secador de tunel hibrido solar--gas LP, con trazabilidad explicita entre la optimizacion formal R1, la sensibilidad de eficiencia del colector y la comparacion hibrido contra linea base gas LP. Bajo las condiciones modeladas, la configuracion hibrida mostro capacidad consistente para reducir la demanda de energia auxiliar, preservando desempeno de secado factible en los puntos operativos seleccionados.

Dentro del conjunto no dominado computado, R1_solution_7 surgio como el principal candidato factible conservador de energia, mientras que R1_solution_3 ofrecio una alternativa balanceada entre intensidad de secado y uso de energia. R1_solution_9 represento una estrategia de secado mas agresiva con mayor penalizacion energetica, y H2 se conservo solamente como referencia historica, no como solucion R1 nuevamente optimizada. Esta distincion respalda una interpretacion operativa basada en compromisos factibles y no en seleccionar por defecto el punto de secado mas profundo.

El analisis de sensibilidad de eficiencia del colector, particularmente la curva 2-SAH consistente con el arreglo fisico en serie de los calentadores solares de aire, no altero cualitativamente el ordenamiento de los candidatos seleccionados. Esto respalda la estabilidad de la interpretacion operativa principal bajo una suposicion de eficiencia de colector fisicamente mas consistente. Sin embargo, el tratamiento del colector sigue siendo una representacion de sensibilidad y no un modelo dinamico de colector completamente acoplado.

La comparacion hibrido contra gas LP indico que la contribucion solar puede reducir la demanda de energia auxiliar principalmente mediante sustitucion de combustible, no mediante relajacion del requisito de secado. En consecuencia, el sistema hibrido debe interpretarse como una estrategia operativa prometedora de ahorro energetico bajo los supuestos actuales del modelo. Las afirmaciones economicas o de CO2 finales deben permanecer condicionadas hasta que los supuestos de precio de combustible, tarifa electrica, factor de emision, fecha, region, base de unidades y conversion esten definitivamente documentados y bloqueados.

Las principales limitaciones metodologicas se asocian con el uso de una sola corrida formal R1 con semilla controlada, la ausencia de replicas independientes con otras semillas, el tratamiento del colector a nivel de sensibilidad y la falta de objetivos completamente acoplados de potencia de ventiladores y caida de presion. El trabajo futuro deberia evaluar semillas aleatorias adicionales, implementar una formulacion acoplada de colector y red de flujo de aire, incluir penalizaciones por potencia de ventiladores y caida de presion, y cerrar los factores economicos y de emisiones antes de formular afirmaciones de costo o CO2 con grado de publicacion.

En conjunto, los resultados proporcionan una base reproducible y trazable para seleccionar puntos operativos candidatos para validacion experimental o numerica de mayor fidelidad. Las conclusiones no deben interpretarse como prueba de convergencia completa del espacio de busqueda, robustez estadistica entre semillas ni optimalidad completa a nivel de equipo.

## Conclusions anchors

| Anchor | Required conclusion |
|---|---|
| Hybrid dryer | energy-saving operating strategy under modeled conditions |
| R1_solution_7 | main energy-conservative feasible candidate |
| R1_solution_3 | balanced alternative |
| R1_solution_9 | aggressive drying with larger energy penalty |
| H2 | historical reference only |
| 2-SAH | qualitative ranking stability; sensitivity representation |
| Hybrid vs gas-LPG | auxiliary-energy reduction through solar fuel substitution |
| Cost/CO2 | conditional on final cited and locked factors |
| Future work | seeds, coupled collector, fan power, pressure drop, final factors |
| Overclaim control | no statistical robustness, no complete convergence proof, no complete equipment-level optimality |

## Internal verdict

`SEC_CONCLUSIONS_CONSOLIDATED_DRAFT_v96z_READY_FOR_CONCLUSIONS_INTEGRATION`
