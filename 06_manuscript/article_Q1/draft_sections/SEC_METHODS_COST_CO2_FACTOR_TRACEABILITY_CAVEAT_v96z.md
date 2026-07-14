# SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z

## Status

`DRAFT_READY_FOR_REVIEW`

## Micropaso

`9.6z-trace-b`

## Identifier

`DRAFT-COST-CO2-FACTOR-TRACEABILITY-CAVEAT-001`

## Intended master location

Methods or Limitations, after the description of economic and environmental objectives.

## Source traceability matrix

- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.md`
- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z.csv`
- `FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_v96z_report.md`

## Manuscript text -- English

### Traceability of economic and CO2 factors

Economic and environmental indicators were handled through a separate factor-traceability matrix in order to distinguish computed model outputs from source-dependent conversion factors. The auxiliary energy values reported for the selected operating points are treated as computed outputs of the drying model and post-processing workflow. In contrast, cost and CO2 indicators depend on external factors such as fuel price, electricity tariff, emission factor, source year, region, unit basis, and conversion assumptions.

For code validation and internal traceability control, the provisional CO2 factors `EF_LPG_kgCO2_per_kWh = 0.2270` and `EF_grid_kgCO2_per_kWh = 0.4380` were retained under the tag `PROVISIONAL_FOR_CODE_VALIDATION`. These factors are not treated as final manuscript-grade emission factors. Before submission, each final cost or CO2 claim must be linked to a definitive source, date, unit basis, and conversion procedure. Therefore, the present results should be interpreted primarily through the reported energy demand and relative comparisons unless the corresponding final economic and emission factors are explicitly cited and locked.

The same traceability control applies to equipment-level effects. Fan-power consumption and pressure-drop coupling were not fully included as optimization objectives; consequently, the present economic and environmental indicators should not be interpreted as complete equipment-level optimality claims. These effects are retained as methodological limitations and as future-work requirements for a fully coupled techno-economic and environmental assessment.

## Version tecnica de control -- Espanol

### Trazabilidad de factores economicos y de CO2

Los indicadores economicos y ambientales se manejaron mediante una matriz separada de trazabilidad de factores, con el fin de distinguir las salidas computadas del modelo de secado de los factores de conversion dependientes de fuentes externas. Los valores de energia auxiliar reportados para los puntos operativos seleccionados se tratan como salidas computadas del modelo y del flujo de postprocesamiento. En cambio, los indicadores de costo y CO2 dependen de factores externos como precio de combustible, tarifa electrica, factor de emision, ano de la fuente, region, base de unidades y supuestos de conversion.

Para validacion de codigo y control interno de trazabilidad, se conservaron los factores provisionales de CO2 `EF_LPG_kgCO2_per_kWh = 0.2270` y `EF_grid_kgCO2_per_kWh = 0.4380` bajo la etiqueta `PROVISIONAL_FOR_CODE_VALIDATION`. Estos factores no se tratan como factores de emision finales para afirmaciones definitivas del manuscrito. Antes del envio, toda afirmacion final de costo o CO2 debe estar vinculada a una fuente definitiva, fecha, base de unidades y procedimiento de conversion. Por tanto, los resultados actuales deben interpretarse principalmente mediante la demanda energetica reportada y las comparaciones relativas, salvo que los factores economicos y de emision finales correspondientes esten explicitamente citados y bloqueados.

El mismo control de trazabilidad aplica a los efectos a nivel de equipo. El consumo electrico de ventiladores y el acoplamiento con caida de presion no se incluyeron completamente como objetivos de optimizacion; en consecuencia, los indicadores economicos y ambientales actuales no deben interpretarse como afirmaciones de optimalidad completa a nivel de equipo. Estos efectos se conservan como limitaciones metodologicas y como requerimientos de trabajo futuro para una evaluacion tecnoeconomica y ambiental completamente acoplada.

## Traceability anchors

| Item | Value | Status |
|---|---:|---|
| `EF_LPG_kgCO2_per_kWh` | 0.2270 | `PROVISIONAL_FOR_CODE_VALIDATION` |
| `EF_grid_kgCO2_per_kWh` | 0.4380 | `PROVISIONAL_FOR_CODE_VALIDATION` |
| Fuel cost factor | pending final source/value | not final for manuscript claims |
| Electricity cost factor | pending final source/value | not final for manuscript claims |
| Fan-power coupling | not fully coupled | limitation/future work |
| Pressure-drop coupling | not fully coupled | limitation/future work |

## Internal verdict

`SEC_METHODS_COST_CO2_FACTOR_TRACEABILITY_CAVEAT_v96z_READY_FOR_REVIEW`
