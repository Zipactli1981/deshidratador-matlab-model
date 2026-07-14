# KNOW 06.06E — COST-B-001 y AUD-COST-AB-001

## Propósito

La v0.9 se enfoca exclusivamente en trazabilidad del costo específico y auditoría A/B algebraica.

No toca:

```text
HYBRID-IRR-001
run_opt_GA.mlx
física térmica
cinética de secado
ecuaciones del modelo
figuras finales del artículo
```

## Archivos principales

```text
02_src_limpio/cost/build_cost_params_historical.m
02_src_limpio/cost/calc_cost_breakdown.m
02_src_limpio/validation/audit_cost_trace_AB_v09.m
```

## Unidad interna del costo

Los valores internos usados para la reconstrucción son USD:

```text
C_kWh     = 1.48 / 16.85     USD/kWh
C_esp_GLP = 0.778 / 16.85    USD/MJ
C_solar   = 0.15 / 16.85     USD/MJ
```

Por tanto:

```text
exchange_rate_MXN_per_USD = 16.85
```

## Fórmula histórica reproducida

```matlab
f_old = (W_comp*dry_time*C_kWh + ...
         Q_aux_tot*C_esp_GLP + ...
         Irradiacion*C_solar) / ((Mi-M)*md);
```

## Desglose trazable

`calc_cost_breakdown.m` devuelve:

```text
electric_energy_kWh
electric_cost_USD
LPG_energy_MJ
LPG_cost_USD
solar_energy_MJ
solar_cost_USD
total_cost_USD
water_removed_kg
cost_specific_USD_per_kgwater
exchange_rate_MXN_per_USD
```

## Auditoría A/B

`audit_cost_trace_AB_v09.m` compara `f_old` contra el costo trazable.

Criterio:

```text
relative_error <= 1e-10
```

Evidencia:

```text
06_outputs/logs/AUD_COST_TRACE_AB_v09.txt
06_outputs/tables/AUD_COST_TRACE_AB_v09.csv
06_outputs/comparisons/AUD_COST_TRACE_AB_v09.mat
```

## Clasificación

```text
COST-B-001 | Tipo B — trazabilidad de costo | ¿Cambia resultados?: No
AUD-COST-AB-001 | Tipo B — prueba A/B algebraica | ¿Cambia resultados?: No
```
