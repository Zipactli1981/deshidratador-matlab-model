# EVIDENCE-E1: GA variable and output dictionary v96z

Status: documentary evidence inventory
Date: 2026-07-29
Repository HEAD inspected: 9285356

## Purpose

This document records the current traceability between the genetic-algorithm decision vector, the formal bounds, the objective vector, and the output structure recorded in `detail`.

This document does not validate final scientific results, CO2 factors, convergence, hybrid/gasLP superiority, representative-point selection, R2/R3, minrep, or 400-generation execution.

## Active execution chain

Active seed-aware runner:

`02_src_limpio/production/run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m`

The runner uses:

- `x_selected = Sdesign.x_selected`
- `lb = Sdesign.lb_formal`
- `ub = Sdesign.ub_formal`
- `nvars = Sdesign.nvars`
- `modeFormal = "hybrid"`
- `referenceMode = "gasLP"`

The active objective function passed to `gamultiobj` is:

`objective_productive_corrected_v96j_triobjective_CO2_fix1(x, modeFormal)`

The formal call is:

`[X,F,exitflag,output,population,scores] = gamultiobj(objfun, nvars, [], [], [], [], lb, ub, opts)`

## GA options

The inspected runner records:

- `PopulationSize = 24`
- `MaxGenerations = 50`
- `UseParallel = false`
- `FunctionTolerance = 1e-5`
- `ConstraintTolerance = 1e-6`
- `PlotFcn = []`

## Decision vector X

The decision vector has four variables:

| X column | Variable | Definition | Unit |
|---:|---|---|---|
| 1 | `m_max` | maximum drying-air mass flow rate | kg/s |
| 2 | `T_min` | minimum operating temperature / lower thermal setpoint | degC |
| 3 | `r_div2` | recirculation fraction or ratio used by the model | dimensionless |
| 4 | `t_rec_ini` | recirculation start time | h |

Evidence from `objective_productive_corrected_v96j_triobjective_CO2.m`:

- line 58: `Decision vector x must have four elements: [m_max T_min r_div2 t_rec_ini].`
- line 61: `m_max = x(1);`
- line 62: `T_min = x(2);`
- line 63: `r_div2 = x(3);`
- line 64: `t_rec_ini = x(4);`

## Internal objective guard bounds

The objective-level guard bounds are:

| Variable | Lower bound | Upper bound | Unit |
|---|---:|---:|---|
| `m_max` | 0.07 | 0.20 | kg/s |
| `T_min` | 45 | 70 | degC |
| `r_div2` | 0.00 | 0.99 | dimensionless |
| `t_rec_ini` | 0 | 19 | h |

Evidence from `objective_productive_corrected_v96j_triobjective_CO2.m`:

- line 66: `lb = [0.07 45 0.00 0];`
- line 67: `ub = [0.20 70 0.99 19];`

These are internal objective guards, not the formal runner bounds.

## Formal Sdesign bounds

The formal design source is:

`02_src_limpio/production/design_triobjective_formal_run_v96l.m`

The inspected design records:

`x_selected = [0.0740767982118, 62.6832965028, 0.672252618341, 11.6517528081]`

`lb_global = [0.05, 55, 0.00, 8.00]`

`ub_global = [0.12, 70, 0.95, 14.00]`

`delta_formal = [0.020, 5.0, 0.25, 3.0]`

`lb_formal = max(lb_global, x_selected - delta_formal)`

`ub_formal = min(ub_global, x_selected + delta_formal)`

`nvars = 4`

Calculated formal bounds:

| X column | Variable | Unit | `lb_formal` | `ub_formal` |
|---:|---|---|---:|---:|
| 1 | `m_max` | kg/s | 0.0540767982118 | 0.0940767982118 |
| 2 | `T_min` | degC | 57.6832965028 | 67.6832965028 |
| 3 | `r_div2` | dimensionless | 0.422252618341 | 0.922252618341 |
| 4 | `t_rec_ini` | h | 8.6517528081 | 14.0000000000 |

## Objective vector F

The objective vector has three columns:

| F column | Objective | Unit |
|---:|---|---|
| 1 | `MR_final` | dimensionless |
| 2 | `cost_specific_USD_per_kgwater` | USD/kg water removed |
| 3 | `CO2_specific_kgCO2_per_kgwater` | kgCO2/kg water removed |

Evidence from `objective_productive_corrected_v96j_triobjective_CO2.m`:

- line 215: `detail.objectives.MR_final = f(1);`
- line 216: `detail.objectives.cost_specific_USD_per_kgwater = f(2);`
- line 217: `detail.objectives.CO2_specific_kgCO2_per_kgwater = f(3);`

## Main detail fields

The objective records:

`detail.inputs`:

- `m_max`
- `T_min`
- `r_div2`
- `t_rec_ini`

`detail.product`:

- `W0`
- `m_i`
- `m_f`
- `m_des`
- `Mi`
- `Mf`
- `M_des`
- `md`
- `mwi`
- `mwf`

`detail.outputs`:

- `Q_aux_tot`: total auxiliary energy supplied by LPG, kWh
- `dry_time`: drying time, h
- `M`: dry-basis moisture content, kg water/kg dry solid
- `MR`: moisture ratio, dimensionless
- `Irradiacion`: accumulated solar irradiation during simulation, probably total kWh; pending physical-basis confirmation

`detail.cost`:

- stored as `detail.cost = cost`
- requires separate cost traceability inventory before final article tables

## CO2 fields and caveats

The current CO2 block records:

- `EF_LPG_kgCO2_per_kWh = 0.2270`
- `EF_grid_kgCO2_per_kWh = 0.4380`
- `emission_factor_status = "PROVISIONAL_FOR_CODE_VALIDATION"`
- `electricity_data_status = "EXTRACTED_FROM_DETAIL"` or `"NOT_EXPOSED_ASSUMED_ZERO_FOR_VALIDATION"`
- `water_removed_kg`
- `E_electricity_kWh`
- `CO2_LPG_kg`
- `CO2_electricity_kg`
- `CO2_total_kg`
- `CO2_specific_kgCO2_per_kgwater`
- `scope = "TRIOBJECTIVE_COMPUTATIONAL_VALIDATION_FACTORS_PROVISIONAL"`

The CO2 equations are:

`CO2_LPG_kg = Q_aux_tot * EF_LPG_kgCO2_per_kWh`

`CO2_electricity_kg = E_electricity_kWh * EF_grid_kgCO2_per_kWh`

`CO2_total_kg = CO2_LPG_kg + CO2_electricity_kg`

`CO2_specific_kgCO2_per_kgwater = CO2_total_kg / water_removed_kg`

Evidence from `objective_productive_corrected_v96j_triobjective_CO2.m`, lines 157-159 and 189-212.

If electricity use is not exposed in `detail.cost`, the current block sets `E_electricity_kWh = 0` and marks the case as `NOT_EXPOSED_ASSUMED_ZERO_FOR_VALIDATION`. This is a traceability risk before final environmental comparison.

## Current state

EVIDENCE-E1 supports:

- traceability of X;
- traceability of internal and formal bounds;
- traceability of F;
- traceability of main `detail` fields;
- identification of provisional CO2 variables and electricity-data caveat.

EVIDENCE-E1 does not support:

- final CO2 validation;
- final hybrid/gasLP superiority claims;
- convergence claims;
- global Pareto-front claims;
- final representative-point selection;
- R2/R3 execution;
- minrep execution;
- 400-generation execution;
- manuscript submission based on final results.

## Next required evidence

Pending before final article results:

1. CO2-E2 source-based validation fiches for `EF_LPG_kgCO2_per_kWh` and `EF_grid_kgCO2_per_kWh`.
2. Cost traceability inventory for `detail.cost`.
3. Explicit confirmation of the physical basis of `Irradiacion`.
4. Paired hybrid/gasLP execution evidence under the Gate B protocol.
5. Application of the objective-selection protocol after approved execution.
6. Stability or replication evidence if final claims require robustness beyond R1.
