# CHANGELOG

## v0.6

Agregado / actualizado:

- DATA-B-001: utilidades para carga robusta de datos ambientales.
- PATH-B-001: `setup_v05_paths.m`.
- TEST-B-001: `test_case_base_v05.m`.
- COST-B-001: `calc_cost_breakdown.m` reforzado con `exchange_rate_MXN_per_USD`.
- AUD-COST-001: `audit_cost_trace_AB.m` reubicado en `02_src_limpio/validation`.
- HYBRID-IRR-001: auditoría estática ampliada.

No se ejecutó MATLAB ni AG completo en esta generación.


## v0.5

Agregado microbloque 6.6B:

- build_cost_params_historical.m
- calc_cost_breakdown.m
- audit_static_interface_tunel.m
- audit_static_hybrid_irradiance.m
- audit_cost_trace_AB.m
- KNOW_06_06B_trazabilidad_interfaz_costo_irradiancia.md

Compare_operation_modes se pospone para v0.6.


## v0.7

Agregado / corregido:

- PATH-B-001: `setup_v05_paths.m` ahora agrega `03_original_model/04_data_original`.
- DATA-B-001: se integra el `addpath(data_original)` temporal dentro del setup.
- TEST-B-002: `test_case_base_v05.m` inicializa `errors` y `warnings`.
- TEST-B-003: nuevo `test_case_base_v06_minimal.m` con una sola llamada a `opt_tunel_mod2`.

No se tocó costo ni HYBRID-IRR-001.


## v0.8

Agregado / actualizado:

- DATA-B-001 cerrado estrictamente.
- Nuevo `02_src_limpio/wrappers/opt_tunel_mod2_v06_data_controlled.m`.
- `test_case_base_v06_minimal.m` ahora llama la versión controlada.
- `load_environmental_data_original.m` queda como loader formal de datos ambientales.
- `setup_v05_paths.m` agrega wrappers y data original.

No se toca costo ni HYBRID-IRR-001.


## v0.9

Agregado / actualizado:

- COST-B-001: `calc_cost_breakdown.m` completo.
- COST-B-001: `build_cost_params_historical.m` con unidades internas explícitas en USD.
- AUD-COST-AB-001: `audit_cost_trace_AB_v09.m`.
- KNOW_06_06E_COST_B_001_AUD_COST_AB_001.md.

No se tocó HYBRID-IRR-001 ni se corrió AG.


## v1.0-HYBRID-IRR

Agregado:

- HYBRID-IRR-001 clasificado como Tipo D.
- `opt_tunel_mod2_v10_energy_mode_corrected.m`.
- `test_hybrid_irradiance_modes_v10.m`.
- Evidencia manual `HYBRID_IRR_001_DIAG_v09_manual`.
- Registro de impacto potencial sobre Fig. 20, Fig. 21 y resultados híbridos.

No se modifica costo ni se corre AG.


## v1.1-HYBRID-IRR

Corregido:

- AUD-HYBRID-B-002.
- `opt_tunel_mod2_v10_energy_mode_corrected.m`: `nargin < 15` cambiado a `nargin < 14`.
- `test_hybrid_irradiance_modes_v10.m`: agrega validación de selector y muestra tabla en consola.

No se corrió AG y no se modificó costo.


## v1.2-HYBRID-IRR_CONSOLIDADA

Consolidado:

- HYBRID-IRR-001 cerrado como Tipo D.
- MODE-ENERGY-001 cerrado como Tipo D.
- AUD-HYBRID-B-002 cerrado como Tipo B.
- `opt_tunel_mod2_v10_energy_mode_corrected.m` incluye selector de irradiancia y selector de auxiliar.
- `test_hybrid_irradiance_modes_v10.m` valida la prueba principal.
- `test_hybrid_irradiance_modes_v10_robustness.m` valida la microprueba de robustez.
- Evidencia validada por usuario incorporada en logs/tables/comparisons.

No se corrió AG.
No se declararon Fig. 20 ni Fig. 21 como resultados finales.


## v1.3-HYBRID-IRR_COMPARE_CONSOLIDADA

Agregado / consolidado:

- `02_src_limpio/comparison/compare_operation_modes.m`.
- Evidencia validada por usuario de `COMPARE_OPERATION_MODES_v67`.
- `KNOW_06_07_compare_operation_modes.md`.
- Registro de `COMPARE-OP-MODES-001`.

No se corrió AG. No se declararon Fig. 20 ni Fig. 21 como resultados finales.
