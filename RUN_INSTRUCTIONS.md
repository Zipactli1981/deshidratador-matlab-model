# RUN_INSTRUCTIONS

Abrir MATLAB en la raíz del paquete:

```matlab
addpath(genpath("02_src_limpio"));
params_base = build_base_params();
params_solar = build_mode_params(params_base,"solar");
results_solar = initialize_results(params_solar);
```

## Trazabilidad de costos

```matlab
params_cost = build_cost_params_historical();
cost = calc_cost_breakdown(10,100,50,6.6923,0.5,26,params_cost);
disp(cost)
```

## Auditorías estáticas

```matlab
audit_static_interface_tunel(pwd);
audit_static_hybrid_irradiance(pwd);
audit_cost_trace_AB(pwd);
```

`audit_cost_trace_AB` es plantilla. No declara PASS/FAIL hasta completar la llamada real a `opt_fun`.


## v0.7 — prueba mínima recomendada

En MATLAB, desde la raíz del paquete:

```matlab
addpath(fullfile(pwd,'02_src_limpio','main'));
rootDir = setup_v05_paths();

test_status = test_case_base_v06_minimal();
disp(test_status.status)
```

La prueba mínima no corre `run_opt_GA.mlx` ni barre temperaturas/recirculaciones.

Para verificar paths:

```matlab
which opt_tunel_mod2 -all
which tunel_mod2 -all
which preallocating -all
which humrat_AirH2O -all
which Mapeo4_temp100621.txt -all
```


## v0.8 — prueba mínima con carga ambiental estricta

En MATLAB, desde la raíz del paquete:

```matlab
addpath(fullfile(pwd,'02_src_limpio','main'));
rootDir = setup_v05_paths();

test_status = test_case_base_v06_minimal();
disp(test_status.status)
```

La prueba debe usar:

```matlab
which opt_tunel_mod2_v06_data_controlled -all
which load_environmental_data_original -all
```

No correr todavía `run_opt_GA.mlx`.


## v0.9 — auditoría A/B de costo

En MATLAB, desde la raíz del paquete:

```matlab
addpath(fullfile(pwd,'02_src_limpio','main'));
rootDir = setup_v05_paths();

audit = audit_cost_trace_AB_v09();
disp(audit.status)
disp(audit.max_relative_error)
```

Debe guardar:

```text
06_outputs/logs/AUD_COST_TRACE_AB_v09.txt
06_outputs/tables/AUD_COST_TRACE_AB_v09.csv
06_outputs/comparisons/AUD_COST_TRACE_AB_v09.mat
```

Esta auditoría no corre el AG ni modifica el modelo.


## v1.0-HYBRID-IRR — prueba A/B por modo

En MATLAB, desde la raíz del paquete:

```matlab
addpath(fullfile(pwd,'02_src_limpio','main'));
rootDir = setup_v05_paths();

diag = test_hybrid_irradiance_modes_v10();
```

Evidencia esperada:

```text
06_outputs/logs/HYBRID_IRR_MODE_AB_v10.txt
06_outputs/tables/HYBRID_IRR_MODE_AB_v10.csv
06_outputs/comparisons/HYBRID_IRR_MODE_AB_v10.mat
```

No correr todavía `run_opt_GA.mlx`.


## v1.1-HYBRID-IRR — repetir prueba del selector

En MATLAB:

```matlab
addpath(fullfile(pwd,'02_src_limpio','main'));
rootDir = setup_v05_paths();

diag = test_hybrid_irradiance_modes_v10();
disp(diag.status)
```

Esperado:

```text
PASS
```

y la tabla debe mostrar:

```text
gasLP  -> I_effective = 0, Irradiacion = 0
hybrid -> I_effective > 0, Irradiacion > 0
solar  -> I_effective > 0, Irradiacion > 0
```


## v1.2-HYBRID-IRR_CONSOLIDADA — pruebas locales

En MATLAB, desde la raíz del paquete:

```matlab
addpath(fullfile(pwd,'02_src_limpio','main'));
rootDir = setup_v05_paths();

diag1 = test_hybrid_irradiance_modes_v10();
diag2 = test_hybrid_irradiance_modes_v10_robustness();

disp(diag1.status)
disp(diag2.status)
```

Esperado:

```text
PASS
PASS
```

Evidencia:

```text
06_outputs/logs/HYBRID_IRR_MODE_AB_v10.txt
06_outputs/tables/HYBRID_IRR_MODE_AB_v10.csv
06_outputs/comparisons/HYBRID_IRR_MODE_AB_v10.mat

06_outputs/logs/HYBRID_IRR_MODE_AB_v10_ROBUSTNESS.txt
06_outputs/tables/HYBRID_IRR_MODE_AB_v10_ROBUSTNESS.csv
06_outputs/comparisons/HYBRID_IRR_MODE_AB_v10_ROBUSTNESS.mat
```

No correr todavía `run_opt_GA.mlx`.


## v1.3-HYBRID-IRR_COMPARE_CONSOLIDADA — comparación de modos

En MATLAB, desde la raíz del paquete:

```matlab
addpath(fullfile(pwd,'02_src_limpio','main'));
rootDir = setup_v05_paths();
addpath(fullfile(rootDir,'02_src_limpio','comparison'));
report = compare_operation_modes();
disp(report.status)
```

Esperado: `COMPARISON_ONLY_NO_GA`.

No correr todavía `run_opt_GA.mlx`.

## Advertencia sobre runners v96m/v96z

Estas instrucciones cubren principalmente la línea de trabajo documentada hasta `v1.3`.

Los runners `v96m/v96z` y la cadena seed-aware están en evaluación documental mediante `ADR-001`. No deben considerarse todavía flujo oficial ni ejecutarse formalmente sin aprobación explícita del usuario y sin cerrar los bloqueos del ADR.

En particular, no debe ejecutarse `gamultiobj` ni una corrida formal asociada a esos runners hasta verificar artefactos externos, entorno MATLAB, control de semillas, factores de CO2 y trazabilidad de resultados.

