# modelo_deshidratador_GA_chile_red_controlado v0.5

Paquete acumulativo MATLAB para implementación controlada del modelo de deshidratador.

## v0.5

Versión dedicada a trazabilidad antes de comparar modos:

- interfaz `opt_tunel_mod2` → `tunel_mod2`;
- costos históricos con unidades explícitas;
- desglose de costo específico;
- auditoría estática de irradiancia híbrida.

No declara resultados científicos nuevos.


## v0.6 — corrección para prueba limpia

Esta versión agrega:

- `setup_v05_paths.m` para configurar rutas sin `genpath(rootDir)`.
- Utilidades para carga robusta de datos ambientales desde `03_original_model/04_data_original`.
- `test_case_base_v05.m` para correr solo el caso base, no el AG completo.
- `audit_cost_trace_AB.m` en `02_src_limpio/validation`.
- `calc_cost_breakdown.m` con desglose y `exchange_rate_MXN_per_USD`.
- Diagnóstico estático ampliado de irradiancia híbrida.

No se modifican física ni cinética. No se declaran resultados finales para Fig. 17, Fig. 20 ni Fig. 21.


## v0.7 — cierre PATH/DATA/TEST

La v0.7 integra `03_original_model/04_data_original` en `setup_v05_paths.m`, corrige la instrumentación de `test_case_base_v05.m` y agrega `test_case_base_v06_minimal.m` para llamar directamente una sola combinación de `opt_tunel_mod2`.

No se modifica HYBRID-IRR-001 ni costo.


## v0.8 — cierre estricto DATA-B-001

Se agregó `opt_tunel_mod2_v06_data_controlled.m`, derivado de `opt_tunel_mod2.mlx`, para cargar datos ambientales mediante `load_environmental_data_original()` desde la ruta del proyecto.

`test_case_base_v06_minimal.m` ahora usa la versión controlada.

No se toca HYBRID-IRR-001, costo, física ni cinética.


## v0.9 — COST-B-001 y AUD-COST-AB-001

La v0.9 se enfoca únicamente en trazabilidad de costo específico.

Agrega o completa:

- `build_cost_params_historical.m`
- `calc_cost_breakdown.m`
- `audit_cost_trace_AB_v09.m`

No se toca HYBRID-IRR-001, no se corre AG y no se modifican física, cinética ni ecuaciones de secado.


## v1.0-HYBRID-IRR — HYBRID-IRR-001 Tipo D

Versión dedicada exclusivamente a `HYBRID-IRR-001`.

Se preserva el wrapper histórico y se agrega un wrapper corregido con selector explícito:

```text
gasLP  -> I_effective = 0
hybrid -> I_effective = I_busc
solar  -> I_effective = I_busc
```

No se modifica costo, no se corre AG y no se declaran resultados finales.


## v1.1-HYBRID-IRR — AUD-HYBRID-B-002

Corrige la condición de entrada del selector de modo energético.

Problema observado: `gasLP` salía con regla de `hybrid`.

Causa: el wrapper tiene 13 argumentos originales más `mode_operation`, es decir 14 argumentos. La condición de default estaba como `nargin < 15` y debía ser `nargin < 14`.

El test ahora valida explícitamente:

```text
gasLP  -> I_effective = 0, Irradiacion = 0
hybrid -> I_effective > 0, Irradiacion > 0
solar  -> I_effective > 0, Irradiacion > 0
```


## v1.2-HYBRID-IRR_CONSOLIDADA

Versión consolidada de `HYBRID-IRR-001` y `MODE-ENERGY-001`.

Regla final implementada:

```text
gasLP  -> I_effective = 0,      calor_aux = true
hybrid -> I_effective = I_busc, calor_aux = true
solar  -> I_effective = I_busc, calor_aux = false
```

Se conserva el wrapper histórico para comparación y se usa el wrapper corregido para pruebas por modo.

No se corrió AG, no se modificó costo y no se declaran resultados finales del artículo.


## v1.3-HYBRID-IRR_COMPARE_CONSOLIDADA

Integra `compare_operation_modes.m` como comparación diagnóstica de modos gasLP, hybrid y solar.

Estado: `COMPARE-OP-MODES-001` validado localmente con `COMPARISON_ONLY_NO_GA`.

No se corrió AG, no se modificó costo y no se declaran resultados finales del artículo.

## Nota sobre fuente de verdad operativa

La documentación principal de este repositorio describe principalmente la línea consolidada hasta `v1.3-HYBRID-IRR_COMPARE_CONSOLIDADA`, que debe conservarse como referencia histórica y metodológica.

Existe una propuesta documental en:

`01_knowledge/ADR_001_fuente_de_verdad_operativa_modelo_deshidratador.md`

Ese ADR identifica una cadena operativa candidata asociada con la evolución `v96m/v96z`, pero dicha cadena permanece en evaluación. No debe considerarse todavía la fuente oficial definitiva del modelo.

No debe ejecutarse una corrida formal ni interpretarse científicamente una salida de esa cadena hasta cerrar los bloqueos documentados en el ADR, incluyendo artefactos `.mat` no versionados, factores de CO2 provisionales, validación de semillas y conciliación documental.

