# Gate A — Reconciliación de rutas históricas v96z

Estado: Dictamen documental  
Fecha: 2026-07-15  
Repositorio: Zipactli1981/deshidratador-matlab-model  
Relación: Complementa ADR-001, Gate A/Gate B y la inspección tabular Gate A  
No autoriza: ejecución MATLAB, `gamultiobj`, corrida formal, uso científico de resultados ni modificación de código.

## 1. Propósito

Este documento registra la reconciliación entre la ruta histórica del proyecto y la ruta local actual.

Ruta histórica detectada en artefactos auxiliares:

`C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA`

Ruta local actual:

`D:\CODE\deshidratador`

El objetivo es distinguir si las rutas históricas son evidencia documental o si bloquean operativamente la cadena candidata Gate A.

## 2. Alcance de la búsqueda

Primero se inspeccionó `02_src_limpio/production`, donde aparecieron rutas históricas en scripts auxiliares.

Después se filtró exclusivamente la cadena candidata crítica:

- `run_seedaware_formal_R1_only_v96z_rngfix.m`
- `run_seedaware_minrep_formal_ga_v96z_rngfix.m`
- `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m`
- `objective_productive_corrected_v96j_triobjective_CO2_fix1.m`
- `objective_productive_corrected_v95j_endpoint_TMAX_corrected.m`
- `opt_tunel_mod2_v18_endpoint_TMAX_corrected.m`
- `setup_v05_paths.m`
- `build_cost_params_historical.m`
- `calc_cost_breakdown.m`

## 3. Resultado en `02_src_limpio/production`

En la búsqueda amplia dentro de `02_src_limpio/production` se detectaron apariciones de la ruta histórica en scripts auxiliares de auditoría, comparación, diagnóstico, exportación y parcheo de manuscrito.

Ejemplos de familias afectadas:

- `audit_master_*`
- `compare_master_*`
- `diagnose_master_*`
- `export_master_*`
- `patch_master_*`

Estos hallazgos deben tratarse como deuda documental o auxiliar. No deben ignorarse, pero no prueban por sí mismos que la cadena formal Gate A esté amarrada a la ruta histórica.

## 4. Resultado en la cadena candidata crítica

En la inspección focalizada sobre la cadena candidata crítica no se detectaron hits de:

- `C:\Users\PC\MATLAB Drive`
- `modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA`
- `D:\CODE\deshidratador`

La sección de hits de rutas absolutas salió vacía.

## 5. Conteo de patrones en la cadena candidata

La búsqueda focalizada detectó:

| Patrón | Conteo |
|---|---:|
| `rootDir` | 36 |
| `addpath` | 16 |
| `genpath` | 5 |
| `rng(` | 2 |
| `rngSeed` | 14 |
| `gamultiobj` | 9 |
| `optimoptions` | 1 |
| `confirm_execute` | 49 |

Estos resultados son consistentes con una cadena que gestiona rutas internas, semillas, solver y guardas de ejecución. No constituyen por sí mismos un bloqueo, pero requieren revisión semántica antes de ejecutar.

## 6. Dictamen

No se detectó bloqueo operativo por rutas absolutas históricas dentro de la cadena candidata Gate A/Gate B.

La ruta histórica queda clasificada como:

`Bloqueo documental / auxiliar`

No como:

`Bloqueo operativo directo de Gate A`

## 7. Restricciones vigentes

Este dictamen no autoriza ejecución porque siguen pendientes:

- validación de factores CO2;
- inspección de productor y consumidor de artefactos `.mat`;
- revisión semántica de `confirm_execute`;
- prueba mínima sin `gamultiobj`;
- confirmación de entorno MATLAB/toolboxes;
- reconciliación de scripts auxiliares con rutas históricas;
- decisión humana explícita para cualquier corrida.

## 8. Próximo paso recomendado

El siguiente paso recomendado es revisar semánticamente la cadena candidata, sin ejecutar MATLAB:

1. Verificar cómo `setup_v05_paths.m` define `rootDir`.
2. Verificar si los runners agregan rutas con `genpath(rootDir)` o rutas específicas.
3. Verificar que `confirm_execute` bloquee ejecución por defecto.
4. Verificar que `rngSeed` llegue al runner seed-aware.
5. Verificar que el runner cargue artefactos `.mat` por rutas relativas o derivadas de `rootDir`.

No debe ejecutarse MATLAB ni `gamultiobj` en esta fase.
