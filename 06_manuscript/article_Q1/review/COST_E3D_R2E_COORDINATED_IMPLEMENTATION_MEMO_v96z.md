# COST-E3D-R2E: Coordinated objective implementation memo v96z

## 1. Purpose

This memo records the static-only coordinated implementation of the accepted COST-E3D decisions for the economic and environmental objectives. It does not report a MATLAB execution, optimization result, convergence result, representative solution, or final scientific result.

## 2. Baseline

Implementation baseline:

`5b882c9023353404b2301a3323dc26a5577db580`

The active formal runner selects `objective_productive_corrected_v96j_triobjective_CO2_fix1` at line 245 of `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m`. No runner, physical wrapper, termination criterion, decision variable, bound, seed, population, generation count, or penalty vector was changed.

## 3. Files changed

| File | Modified region | Role |
|---|---:|---|
| `02_src_limpio/cost/build_cost_params_historical.m` | 1-62 | Centralized authorized constants while preserving the existing function interface |
| `02_src_limpio/cost/calc_cost_breakdown.m` | 1-102 | Reconciled cost activities, components, total, and canonical denominator |
| `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2_fix1.m` | 1-134 | Reused cost activities and denominator for the environmental objective |
| `06_manuscript/article_Q1/review/COST_E3D_R2E_COORDINATED_IMPLEMENTATION_MEMO_v96z.md` | complete file | Static implementation record |

## 4. Solar activity boundary resolution

`SOLAR_ACTIVITY_BOUNDARY = CONFIRMED_COMPATIBLE`

Repository evidence in `opt_tunel_mod2_v18_endpoint_TMAX_corrected.m` establishes the following chain:

1. Line 196 assigns environmental irradiance `I` in W/m2.
2. Lines 214-223 apply collector area and efficiency: `E_capt = I * A_cap * ETHA_capt / 1000`, yielding captured thermal power in kW per collector bank.
3. Lines 246-285 add the same `E_capt` term to the air enthalpy through AH1-AH8; it is therefore a modeled thermal input to the air system.
4. Lines 456-458 and 484-486 integrate `I * time * A_cap * 8 * efficiency / 1e6` into `Irradiacion` in MJ for both normal and TMAX endpoints.

Consequently, the activity used by the cost objective is not raw incident irradiation. It includes collector area, eight collector banks, collector efficiency, and the thermal transformation used by the modeled air-heating chain. Identity with heat absorbed by the product is neither asserted nor required by the accepted gate criterion.

## 5. Canonical denominator implementation

`calc_cost_breakdown.m` now defines one terminal basis:

```text
M_terminal = M
mw_terminal_kg = M_terminal * md
water_removed_kg = (Mi - M_terminal) * md
water_removed_kg_check = Mi * md - mw_terminal_kg
```

The base objective supplies `M` and `dry_time` from the same endpoint returned by the physical wrapper. The wrapper sets both values together for normal termination and TMAX. `f(2)` uses `detail.cost.water_removed_kg`; the CO2 wrapper reuses that exact stored instance for `f(3)`. Historical `mwf` remains in the base objective for its existing reference/MR role but is not the active denominator of `f(3)`.

## 6. LPG implementation

The previous active cost expression was `Q_aux_tot * C_esp_GLP_internal`, where useful supplementary heat was priced directly. The coordinated implementation is:

```text
Q_LPG_input_MJ = Q_aux_tot / 0.78
LPG_mass_kg = Q_LPG_input_MJ / 46.16
LPG_cost_USD = LPG_mass_kg * 1.1195545213
```

`Q_aux_tot` remains useful supplementary thermal energy. The compatibility field `LPG_energy_MJ` is retained but now aliases fuel-input energy; it is not an independent active cost chain.

## 7. Solar-cost implementation

The physical activity remains `solar_energy_MJ = Irradiacion`. The historical active factor is replaced by the authorized June-2026 factor:

```text
solar_cost_USD = solar_energy_MJ * 0.0126515761642454 USD/MJ
```

No sensitivity range is installed as an operating constant.

## 8. Electrical-cost implementation

The former nominal activity `2.238 kW * dry_time_h` is replaced by the measured air-impeller activity:

```text
E_air_impeller_kWh = 1.03 kW * dry_time_h
electricity_cost_USD = E_air_impeller_kWh * 0.0717182253966247 USD/kWh
```

The scope is air impeller only. No pump, hydraulic circuit, controls, fixed charge, capacity charge, demand charge, or inferred tax is included.

## 9. LPG CO2 implementation

The former primary expression multiplied useful `Q_aux_tot` directly by an energy factor. The new single primary chain is:

```text
LPG_mass_kg = detail.cost.LPG_mass_kg
CO2_LPG_kg = LPG_mass_kg * 3.00 kgCO2/kg LPG
```

The supplied `0.06508290 kgCO2/MJ fuel input` value is retained only as `CO2_LPG_kg_check`. It is not a second primary emissions chain. Because the supplied mass and energy factors have independent reported precision, exact numerical identity is not asserted.

## 10. Electricity CO2 implementation

The environmental objective reads `detail.cost.electric_energy_kWh`, the exact activity used for electricity cost:

```text
CO2_electricity_kg = E_air_impeller_kWh * 0.444 kgCO2e/kWh
```

No separate nominal-power electricity activity remains in the active CO2 path.

## 11. detail.cost reconciliation

`detail.cost` exposes useful supplementary heat, fuel-input energy, LPG mass, LPG cost, captured solar energy, solar cost, air-impeller electricity, electricity cost, component total, terminal moisture state, canonical water removed, its algebraic check, and the specific cost.

Static identities:

```text
total_cost_USD = electric_cost_USD + LPG_cost_USD + solar_cost_USD
f(2) = total_cost_USD / water_removed_kg
```

The existing public function signatures and established component field names are preserved. Added fields make the new bases explicit.

## 12. detail.CO2 reconciliation

`detail.CO2` reuses `detail.cost.LPG_mass_kg`, `detail.cost.LPG_fuel_input_MJ`, `detail.cost.electric_energy_kWh`, and `detail.cost.water_removed_kg`.

Static identities:

```text
CO2_total_kg = CO2_LPG_kg + CO2_electricity_kg
f(3) = CO2_total_kg / water_removed_kg
```

The former `EF_LPG_kgCO2_per_kWh` detail field is retained as an inactive `NaN` interface placeholder and is explicitly marked not active. The active factor is `EF_LPG_kgCO2_per_kg`.

## 13. Static dimensional audit

| Expression | Dimensional result |
|---|---|
| `MJ useful / efficiency` | MJ fuel input |
| `MJ fuel input / (MJ/kg LPG)` | kg LPG |
| `kg LPG * USD/kg LPG` | USD |
| `kg LPG * kgCO2/kg LPG` | kgCO2 |
| `kW * h` | kWh |
| `kWh * USD/kWh` | USD |
| `kWh * kgCO2e/kWh` | kgCO2e |
| `MJ solar * USD/MJ` | USD |
| `USD / kg water removed` | USD/kg water removed |
| `kgCO2e / kg water removed` | kgCO2e/kg water removed |

## 14. Legacy expressions removed from active path

Static searches of the active chain confirm:

- nominal `3 * 0.746` is no longer used for electricity cost or CO2;
- `mwi - mwf` is no longer the `f(3)` denominator;
- `Q_aux_tot` is not multiplied directly by an LPG price or LPG CO2 factor;
- `1.03` defines active electrical power;
- `0.0717182253966247` defines active electricity cost;
- `0.4440` defines grid CO2;
- `0.0126515761642454` defines active solar cost;
- the `water_removed_kg` stored by `detail.cost` is shared by `f(2)` and `f(3)`.

## 15. Remaining limitations

This is a static implementation only. Numerical equivalence, endpoint examples, penalty cases, and runtime behavior still require a separately authorized minimal dynamic validation. Formal optimization remains blocked. No solar lifecycle-emissions factor is introduced. No full electricity bill is reconstructed.

## 16. R1 consequences

`R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST`

`R1_ECONOMIC_OBJECTIVE_STATUS = RECALCULATION_REQUIRED`

`R1_ENVIRONMENTAL_OBJECTIVE_STATUS = RECALCULATION_REQUIRED`

`R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL`

`R1_F2_F3_RECALCULATION = REQUIRED_AFTER_MINIMAL_DYNAMIC_VALIDATION`

The implementation does not change or invalidate R1's operational audit record. It does require future authorized recalculation before interpreting R1 economic or environmental values.

## 17. Execution prohibition

No MATLAB, `gamultiobj`, R1, R2, R3, `minrep`, or 400-generation execution was performed. No MAT, result, or figure was generated. This pull request does not authorize any such execution.

## 18. Current state

`COST-E3D-R2E = COORDINATED_OBJECTIVE_IMPLEMENTATION_COMPLETE_STATIC_ONLY`

`SOLAR_ACTIVITY_BOUNDARY = CONFIRMED_COMPATIBLE`

`WATER_REMOVED_DENOMINATOR_IMPLEMENTATION = IMPLEMENTED_PENDING_DYNAMIC_VALIDATION`

`LPG_COST_IMPLEMENTATION = IMPLEMENTED_PENDING_DYNAMIC_VALIDATION`

`LPG_CO2_IMPLEMENTATION = IMPLEMENTED_PENDING_DYNAMIC_VALIDATION`

`SOLAR_COST_IMPLEMENTATION = IMPLEMENTED_PENDING_DYNAMIC_VALIDATION`

`ELECTRICITY_COST_IMPLEMENTATION = IMPLEMENTED_PENDING_DYNAMIC_VALIDATION`

`ELECTRICITY_CO2_ACTIVITY_IMPLEMENTATION = IMPLEMENTED_PENDING_DYNAMIC_VALIDATION`

`F2_F3_NORMALIZATION_STATUS = IMPLEMENTED_PENDING_DYNAMIC_VALIDATION`

`COST_OBJECTIVE_TRACEABILITY = STATICALLY_RECONCILED_PENDING_DYNAMIC_VALIDATION`

`ENVIRONMENTAL_OBJECTIVE_TRACEABILITY = STATICALLY_RECONCILED_PENDING_DYNAMIC_VALIDATION`

`ENERGY_COST_RECONCILIATION = STATIC_IMPLEMENTATION_COMPLETE_PENDING_DYNAMIC_VALIDATION`

`FORMAL_EXECUTION = BLOCKED_PENDING_EXPLICIT_RUN_AUTHORIZATION`

## 19. Next gate

The next gate is an explicitly authorized minimal dynamic validation of direct objective evaluations and trace fields. It is not authorized or performed by COST-E3D-R2E. Formal runs, convergence claims, representative-solution claims, hybrid/gasLP superiority claims, and global Pareto-front claims remain blocked.
