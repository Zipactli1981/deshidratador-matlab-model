# MATRIZ DE CAMBIOS

| ID | Archivo | Tipo | Cambio | Estado |
|---|---|---|---|---|
| C-199 | build_base_params.m | C | Crear params_base | Implementado |
| C-200 | build_mode_params.m | C | Derivar modos | Implementado |
| C-201 | checklist_rapido_pre_run.m | B | Checklist pre-run | Implementado |
| C-202 | 2ndo modeloV(piña).zip | F | Integrar original protegido | Implementado |
| C-205 | initialize_results.m | B | Contenedor results | Implementado |
| C-207 | ga_history_output_controlado.m | B | Historial AG | Implementado |
| C-209 | post_run_report.m | B | Reporte post-run | Implementado |
| CODE-C-001 | opt_tunel_mod2.mlx | C | Verificar interfaz tunel_mod2 | En diagnóstico |
| TRACE-COST-001 | build_cost_params_historical.m | B | Trazabilidad unidades costo | Implementado |
| COST-B-001 | calc_cost_breakdown.m | B | Desglose de costo específico | Implementado |
| AUD-COST-001 | audit_cost_trace_AB.m | B | Plantilla A/B costo | Implementado como plantilla |
| HYBRID-IRR-001 | audit_static_hybrid_irradiance.m | Diagnóstico | Verificar anulación irradiancia | En diagnóstico |
| C-213 | KNOW_06_06B | A | Documentar microbloque | Implementado |


| DATA-B-001 | get_project_root_original.m / load_environmental_data_original.m | B | Carga robusta de datos ambientales desde ruta explícita del proyecto | Implementado |
| PATH-B-001 | setup_v05_paths.m | B | Script único de path sin genpath(rootDir) | Implementado |
| TEST-B-001 | test_case_base_v05.m | B | Prueba de integración de caso base sin AG | Implementado |
| AUD-COST-001 | validation/audit_cost_trace_AB.m | B | Evidencia A/B en logs/tables/comparisons | Plantilla implementada |


| PATH-B-001 | 02_src_limpio/main/setup_v05_paths.m | B | Agregar 03_original_model/04_data_original al path controlado | Implementado |
| DATA-B-001 | setup_v05_paths.m / load_environmental_data_original.m | B | Resolver carga de datos ambientales sin addpath manual externo | Implementado |
| TEST-B-002 | 02_src_limpio/validation/test_case_base_v05.m | B | Inicializar test_status.errors/warnings | Implementado |
| TEST-B-003 | 02_src_limpio/validation/test_case_base_v06_minimal.m | B | Prueba mínima de una sola combinación con opt_tunel_mod2 | Implementado |


| DATA-B-001 | 02_src_limpio/wrappers/opt_tunel_mod2_v06_data_controlled.m | B | Sustituir cargas ambientales relativas por load_environmental_data_original | Cerrado estrictamente |
| DATA-B-001B | 03_original_model/03_utilities/load_environmental_data_original.m | B | Loader por ruta explícita del proyecto | Implementado |


| COST-B-001 | 02_src_limpio/cost/calc_cost_breakdown.m | B | Desglose trazable completo del costo específico | Implementado |
| TRACE-COST-001B | 02_src_limpio/cost/build_cost_params_historical.m | B | Documentar unidades internas USD de C_kWh, C_esp_GLP y C_solar | Implementado |
| AUD-COST-AB-001 | 02_src_limpio/validation/audit_cost_trace_AB_v09.m | B | Comparar fórmula histórica vs desglose trazable | Implementado |
| C-214 | KNOW_06_06E_COST_B_001_AUD_COST_AB_001.md | A | Documentar auditoría A/B de costo | Implementado |


| HYBRID-IRR-001 | 02_src_limpio/wrappers/opt_tunel_mod2_v10_energy_mode_corrected.m | D | Selector explícito gasLP/hybrid/solar para I_effective | Implementado |
| HYBRID-IRR-001B | 02_src_limpio/validation/test_hybrid_irradiance_modes_v10.m | B | Prueba A/B por modo sin AG | Implementado |
| HYBRID-IRR-001C | Fig. 20 / Fig. 21 / resultados híbridos | D | Advertencia de impacto potencial; no declarar resultados finales | Registrado |
| C-217 | KNOW_06_06H_HYBRID_IRR_001_TYPE_D.md | A | Documentar corrección Tipo D | Implementado |


| AUD-HYBRID-B-002 | 02_src_limpio/wrappers/opt_tunel_mod2_v10_energy_mode_corrected.m | B | Corregir default de mode_operation: nargin < 15 a nargin < 14 | Implementado |
| AUD-HYBRID-B-002B | 02_src_limpio/validation/test_hybrid_irradiance_modes_v10.m | B | Validar gasLP/hybrid/solar y mostrar tabla en consola | Implementado |


| HYBRID-IRR-001 | 02_src_limpio/wrappers/opt_tunel_mod2_v10_energy_mode_corrected.m | D | Selector explícito de irradiancia por modo | Cerrado |
| MODE-ENERGY-001 | 02_src_limpio/wrappers/opt_tunel_mod2_v10_energy_mode_corrected.m | D | Selector explícito de auxiliar: gasLP/hybrid activo, solar apagado | Cerrado |
| AUD-HYBRID-B-002 | opt_tunel_mod2_v10_energy_mode_corrected.m | B | Corregir nargin de mode_operation de <15 a <14 | Cerrado |
| TEST-HYBRID-001 | test_hybrid_irradiance_modes_v10.m | B | Prueba principal gasLP/hybrid/solar PASS | Cerrado |
| TEST-HYBRID-002 | test_hybrid_irradiance_modes_v10_robustness.m | B | Microprueba de robustez PASS | Cerrado |
| IMPACT-HYBRID-001 | Fig. 20 / Fig. 21 / resultados híbridos | D | Recalcular antes de artículo | Pendiente productivo |
| C-218 | KNOW_06_06I_HYBRID_IRR_MODE_ENERGY_CONSOLIDADO.md | A | Documentación consolidada | Implementado |

| COMPARE-OP-MODES-001 | 02_src_limpio/comparison/compare_operation_modes.m | B | Comparación diagnóstica gasLP/hybrid/solar sin AG | Cerrado |
| COMPARE-OP-MODES-002 | 06_outputs/logs/tables/comparisons | B | Evidencia local validada de comparación de modos | Cerrado |
| C-219 | KNOW_06_07_compare_operation_modes.md | A | Documentación de Micropaso 6.7 | Implementado |
| IMPACT-HYBRID-002 | Fig. 20 / Fig. 21 / resultados productivos | D | Recalcular con lógica corregida antes de artículo | Pendiente productivo |
