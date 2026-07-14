# SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z

## Status

`DRAFT_READY_FOR_REVIEW`

## Micropaso

`9.6z-limitations-a`

## Identifier

`BUILD-MANUSCRIPT-LIMITATIONS-CONSOLIDATED-BLOCK-001`

## Intended master location

Limitations section, or final paragraph of Discussion if the journal format does not include a separate Limitations section.

## Source controls

- `RESULTS_SECTION_07_v01_1_LOCKED.md`
- `R1_REPRODUCIBILITY_CONFIGURATION_TABLE_v96z.md`
- `INTEGRATE_METHODS_GA_REPRODUCIBILITY_PARAGRAPH_INTO_MASTER_v96z_report.md`
- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md`
- `INTEGRATE_COST_CO2_TRACEABILITY_CAVEAT_INTO_MASTER_v96z_report.md`

## Manuscript text -- English

### Limitations

Several limitations must be considered when interpreting the optimization and baseline-comparison results. First, the formal multiobjective analysis was based on a single controlled seed-aware R1 execution of MATLAB's `gamultiobj` algorithm. Although this run produced a computed nondominated set under the specified configuration, it does not establish statistical robustness across independent random seeds, nor does it constitute proof of complete convergence of the search space. Additional independent seed replications would be required to quantify the sensitivity of the selected candidates to stochastic initialization and evolutionary-search variability.

Second, the collector-efficiency analysis was implemented as a sensitivity assessment rather than as a fully coupled dynamic collector model. The 2-SAH efficiency curve was used because it is consistent with the physical arrangement of two solar air heaters in series per battery; however, this treatment does not replace a fully coupled collector, airflow, pressure-drop, and thermal-network simulation. Consequently, the observed stability of the selected operating-point ranking across collector-efficiency assumptions should be interpreted as sensitivity evidence, not as complete equipment-level validation.

Third, fan-power consumption and pressure-drop effects were not fully coupled as optimization objectives. The current optimization therefore focuses on process-level drying performance, auxiliary energy demand, cost, and CO2 indicators as represented in the implemented model, but it should not be interpreted as a complete equipment-level optimum. A future coupled formulation should include fan power, pressure drop, and airflow-distribution effects to refine the techno-economic and environmental assessment.

Fourth, economic and CO2 indicators depend on external factors such as fuel price, electricity tariff, emission factor, source year, region, unit basis, and conversion assumptions. The provisional CO2 factors `EF_LPG_kgCO2_per_kWh = 0.2270` and `EF_grid_kgCO2_per_kWh = 0.4380` were retained only for code validation and internal traceability under the tag `PROVISIONAL_FOR_CODE_VALIDATION`. Final cost or CO2 claims require definitive cited sources and locked conversion bases before submission. Until those factors are finalized, the most robust interpretation is based on energy-demand trends and relative comparisons.

Finally, solar-only operation was excluded from the formal multiobjective comparison because it represents a non-equivalent operating mode relative to the hybrid and gas-LPG baseline cases. Likewise, the H2 point was retained as a historical reference and not treated as a newly optimized R1 solution. These distinctions were maintained to avoid mixing non-equivalent operating modes or historical references with the formal R1 candidate set.

## Version tecnica de control -- Espanol

### Limitaciones

Deben considerarse varias limitaciones al interpretar los resultados de optimizacion y comparacion de lineas base. Primero, el analisis multiobjetivo formal se baso en una sola ejecucion R1 controlada con semilla fija del algoritmo `gamultiobj` de MATLAB. Aunque esta corrida produjo un conjunto no dominado computado bajo la configuracion especificada, no establece robustez estadistica entre semillas aleatorias independientes ni constituye prueba de convergencia completa del espacio de busqueda. Serian necesarias replicas independientes con semillas adicionales para cuantificar la sensibilidad de los candidatos seleccionados a la inicializacion estocastica y a la variabilidad del algoritmo evolutivo.

Segundo, el analisis de eficiencia del colector se implemento como una evaluacion de sensibilidad y no como un modelo dinamico de colector completamente acoplado. La curva 2-SAH se uso porque es consistente con la configuracion fisica de dos calentadores solares de aire en serie por bateria; sin embargo, este tratamiento no sustituye una simulacion completamente acoplada de colector, flujo de aire, caida de presion y red termica. Por tanto, la estabilidad observada del ordenamiento de puntos operativos ante diferentes supuestos de eficiencia del colector debe interpretarse como evidencia de sensibilidad, no como validacion completa a nivel de equipo.

Tercero, el consumo electrico de ventiladores y los efectos de caida de presion no se acoplaron completamente como objetivos de optimizacion. La optimizacion actual se enfoca en el desempeno de secado a nivel de proceso, demanda de energia auxiliar, costo e indicadores de CO2 segun el modelo implementado, pero no debe interpretarse como una optimalidad completa a nivel de equipo. Una formulacion futura acoplada deberia incluir potencia de ventiladores, caida de presion y efectos de distribucion de flujo para refinar la evaluacion tecnoeconomica y ambiental.

Cuarto, los indicadores economicos y de CO2 dependen de factores externos como precio de combustible, tarifa electrica, factor de emision, ano de la fuente, region, base de unidades y supuestos de conversion. Los factores provisionales de CO2 `EF_LPG_kgCO2_per_kWh = 0.2270` y `EF_grid_kgCO2_per_kWh = 0.4380` se conservaron solamente para validacion de codigo y trazabilidad interna bajo la etiqueta `PROVISIONAL_FOR_CODE_VALIDATION`. Las afirmaciones finales de costo o CO2 requieren fuentes definitivas citadas y bases de conversion bloqueadas antes del envio. Hasta cerrar esos factores, la interpretacion mas robusta debe basarse en tendencias de demanda energetica y comparaciones relativas.

Finalmente, la operacion solo solar se excluyo de la comparacion multiobjetivo formal porque representa un modo operativo no equivalente respecto a los casos hibrido y gas LP. Asimismo, el punto H2 se conservo como referencia historica y no se trato como una solucion R1 recientemente optimizada. Estas distinciones se mantuvieron para evitar mezclar modos operativos no equivalentes o referencias historicas con el conjunto formal de candidatos R1.

## Limitation anchors

| Limitation | Required wording/control |
|---|---|
| Single R1 formal run | no statistical robustness claim |
| Search-space convergence | no complete/global convergence proof |
| Collector model | 2-SAH sensitivity, not fully coupled dynamic collector model |
| Equipment effects | fan power and pressure drop not fully coupled as objectives |
| Economic/CO2 factors | provisional factors require final cited sources before final claims |
| Solar-only mode | excluded from formal GA comparison as non-equivalent mode |
| H2 | historical reference, not newly optimized R1 solution |

## Internal verdict

`SEC_LIMITATIONS_CONSOLIDATED_BLOCK_v96z_READY_FOR_LIMITATIONS_INTEGRATION`
