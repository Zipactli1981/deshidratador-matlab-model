# COST-E3D: Compressor-power and energy-reconciliation audit v96z

## 1. Purpose

COST-E3D performs a static, line-traceable audit of power, energy, economic
cost, and operational CO2 calculations in the active objective chain. It
determines how auxiliary heat, electricity, solar energy, `detail.cost`, and
water removal feed:

`f(2) = cost_specific_USD_per_kgwater`.

This audit does not modify code, constants, equations, or factors and does not
execute MATLAB. Findings identify required decisions; they do not implement
corrections or authorize new runs.

Repository HEAD used as the audit baseline:

`a6baca16aeba9c41e65e5b1c23dafdaeff4857a6`

## 2. Scope and restrictions

- no code changes;
- no MATLAB execution;
- no `gamultiobj` execution;
- no R1, R2, or R3 execution;
- no minrep execution;
- no 400-generation execution;
- no economic-factor changes;
- no CO2-factor changes;
- no equation corrections;
- no assumed values;
- no MAT files, results, or figures;
- no final article claims;
- no convergence claims;
- no `hybrid`/`gasLP` superiority claims;
- no global Pareto-front claims.

All conclusions below are static-code conclusions. A value labeled pending or
ambiguous remains unresolved.

## 3. Files inspected

| File | Status | Role |
|---|---|---|
| `06_manuscript/article_Q1/review/EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md` | FOUND / INSPECTED | Previous X, F, `detail`, and CO2 field inventory |
| `06_manuscript/article_Q1/review/COST_E1_ECONOMIC_CONSTANTS_INVENTORY_v96z.md` | FOUND / INSPECTED | Previous economic constants and cost-chain inventory |
| `06_manuscript/article_Q1/review/COST_E2_ECONOMIC_SOURCE_VALIDATION_FICHES_v96z.md` | FOUND / INSPECTED | Economic source and conversion holds |
| `06_manuscript/article_Q1/review/COST_E3_ECONOMIC_BASIS_DECISION_MEMO_v96z.md` | FOUND / INSPECTED | Route C, June 2026 basis, GDMTO decision, and current holds |
| `06_manuscript/article_Q1/review/CO2_E4_GRID_FACTOR_CODE_UPDATE_v96z.md` | FOUND / INSPECTED | Current grid factor and no-execution status |
| `06_manuscript/article_Q1/review/GATE_B_DECISION_CURRENT_STATUS_v96z.md` | FOUND / INSPECTED | Formal-execution and final-claim restrictions |
| `02_src_limpio/production/run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` | FOUND / INSPECTED | Active runner; selects the `fix1` objective and maps `F(:,2)` |
| `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2_fix1.m` | FOUND / INSPECTED | Active tri-objective wrapper and CO2 reconstruction |
| `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2.m` | FOUND / INSPECTED | Non-`fix1` tri-objective implementation used for comparison |
| `02_src_limpio/production/objective_productive_corrected_v95j_endpoint_TMAX_corrected.m` | FOUND / INSPECTED | Base objective called by the active `fix1` wrapper |
| `02_src_limpio/wrappers/opt_tunel_mod2_v18_endpoint_TMAX_corrected.m` | FOUND / INSPECTED | Active physical wrapper producing `Q_aux_tot`, `dry_time`, and `Irradiacion` |
| `03_original_model/03_utilities/preallocating.m` | FOUND / INSPECTED | Initializes `Q_aux` and other time-series arrays from a zero vector |
| `02_src_limpio/cost/build_cost_params_historical.m` | FOUND / INSPECTED | Defines historical economic factors and `W_comp_kW` |
| `02_src_limpio/cost/calc_cost_breakdown.m` | FOUND / INSPECTED | Builds electrical, LPG, solar, total, and specific costs |
| `02_src_limpio/config/build_base_params.m` | FOUND / INSPECTED | Controlled base configuration; not the active cost-factor source |
| `02_src_limpio/production/objective_productive_corrected_v611.m` and versioned descendants | FOUND / STATIC SEARCHED | Legacy objective family; generally maps wrapper outputs through the same cost functions |
| `02_src_limpio/production/objective_productive_corrected_v621_solarfix.m` | FOUND / INSPECTED BY TARGETED SEARCH | Legacy objective with a different argument order; not the active chain |
| `03_original_model/01_active_original/opt_tunel_mod2.mlx` | FOUND / BINARY REFERENCE ONLY | Original live-script model referenced by the controlled wrapper |
| `03_original_model/01_active_original/run_opt_tunel_mod2.mlx` | FOUND / BINARY REFERENCE ONLY | Original live-script runner |
| `02_src_limpio/production/objective_productive_corrected_v96j.m` | NOT_FOUND | Requested candidate path |
| `02_src_limpio/production/cost_productive_corrected_v96j.m` | NOT_FOUND | Requested candidate path |
| Any `cost_productive*.m` file | NOT_FOUND | No matching MATLAB source found |
| `02_src_limpio/production/build_base_params.m` | NOT_FOUND | Requested path; actual file is under `02_src_limpio/config/` |

The active chain for this audit is:

```text
run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix
  -> objective_productive_corrected_v96j_triobjective_CO2_fix1
  -> objective_productive_corrected_v95j_endpoint_TMAX_corrected
  -> opt_tunel_mod2_v18_endpoint_TMAX_corrected
  -> build_cost_params_historical
  -> calc_cost_breakdown
  -> detail.cost
  -> f_base(2)
  -> f(2)
```

## 4. Static-search strategy

The audit used repository-wide `rg` searches over MATLAB text sources for:

- equipment and power: `compressor`, `compresor`, `fan`, `ventilador`,
  `blower`, `pump`, `bomba`, `motor`, `power`, `potencia`, `W_comp`,
  `P_comp`, `P_fan`, `P_motor`, and `P_aux`;
- energy: `Q_aux_tot`, `Q_aux`, `LPG`, `GLP`, `gasLP`, `fuel`, `burner`,
  `efficiency`, `eta`, `PCI`, `PCS`, `LHV`, `HHV`, `MJ`, and `kWh`;
- cost and outputs: `detail.cost`, `cost_specific`, `electric_energy_kWh`,
  `electricity_kWh`, `total_cost`, and `water_removed`;
- integration and conversion: `trapz`, `cumtrapz`, `sum`, `integral`,
  `t_step`, `3600`, `1000`, `1e6`, and `3.6`.

Searches excluded `.git` by repository-search behavior and were restricted to
source/document paths and text extensions where relevant. Result folders and
binary artifacts were not used as evidence. `.mlx` files were inventoried but
not treated as line-readable evidence.

For each relevant match, the audit recorded the input, expression, output,
unit, conversion, downstream cost/CO2 use, certainty, and risk.

## 5. Q_aux_tot traceability

### Initialization and accumulation

| Stage | File and line | Expression | Input | Output | Unit/status | Certainty |
|---|---|---|---|---|---|---|
| Base vector | `opt_tunel_mod2_v18_endpoint_TMAX_corrected.m:102-104` | `mat=zeros(...)` | simulation grid | zero vector | dimensionless container | HIGH |
| Auxiliary array | `preallocating.m:78` | `Q_aux=mat` | zero vector | `Q_aux` | initialized to zero | HIGH |
| Heater disabled/not needed | active wrapper lines 333-347 | `Q_aux(i)=0` | temperature and mode tests | instantaneous auxiliary heat | zero | HIGH |
| Heater enabled | active wrapper lines 338-341 | `m_HE1_in(i)*(h_HE1_out(i)-h_HE1_in(i))` | dry-air mass flow and moist-air enthalpy rise | `Q_aux(i)` | kg/s × kJ/kg = kJ/s = kW thermal | HIGH |
| Time accumulation | active wrapper lines 455-458 and 483-486 | `sum(Q_aux*t_step*3600)/1000` | `Q_aux`, `t_step=0.1 h` | `Q_aux_tot` | kJ / 1000 = MJ | HIGH |

The integration is a rectangular sum over the simulated time steps. It is not
`trapz` or `cumtrapz`.

### Physical interpretation

`Q_aux(i)` is calculated from the enthalpy increase of the air across the
auxiliary-heater block. The active wrapper contains no burner efficiency,
combustion efficiency, fuel lower/higher-heating-value conversion, or fuel
mass/volume calculation in this chain.

Therefore, static evidence supports:

Q_AUX_TOT_BASIS = THERMAL_USEFUL_ENERGY

It is thermal energy added to the air at the modeled heater boundary. It is
not statically demonstrated to be chemical fuel-input energy. It is zero in
`solar` mode because `calor_aux=false`, and may be positive in `gasLP` and
`hybrid` modes.

### Storage and downstream use

| Destination | Evidence | Treatment |
|---|---|---|
| `detail.outputs.Q_aux_tot` | base objective line 138 | stores the wrapper scalar without conversion |
| `detail.cost.inputs.Q_aux_tot` | `calc_cost_breakdown.m:32` | input copy |
| `detail.cost.LPG_energy_MJ` | `calc_cost_breakdown.m:52` | direct assignment from `Q_aux_tot` |
| LPG cost | `calc_cost_breakdown.m:53-54` | multiplies by `C_esp_GLP_internal` in USD/MJ |
| Active `fix1` CO2 wrapper | `objective...fix1.m:62-65` | retrieves `outputs.Q_aux_tot` |
| LPG CO2 | `objective...fix1.m:86` | multiplies directly by `EF_LPG_kgCO2_per_kWh` |

No MJ-to-kWh conversion exists between `Q_aux_tot` and the LPG CO2 equation.
No burner efficiency exists between useful air heating and the LPG fuel
boundary.

## 6. Electrical-equipment inventory

| Equipment | Power variable | Power unit | Operating-time basis | Energy variable | Energy unit | Included in cost | Included in CO2 | Evidence |
|---|---|---|---|---|---|---|---|---|
| Historical compressor/electrical proxy | `W_comp_kW = 3 * 0.746` | kW, explicitly labeled | entire scalar `dry_time` | `cost.electric_energy_kWh` | kWh | Yes | Yes, retrieved by active `fix1` | `build_cost_params_historical.m:49,59`; `calc_cost_breakdown.m:48-50`; `objective...fix1.m:78-87` |
| Fan/blower | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | No separate term | No separate term | no active-chain variable found |
| Pump | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | No separate term | No separate term | no active-chain variable found |
| Motor/control auxiliaries | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | NOT_EXPOSED | No separate term | No separate term | no active-chain variable found |
| Auxiliary heater | `Q_aux(i)` | kW thermal by dimensional inference | active time steps only | `Q_aux_tot` | MJ thermal | Yes, as LPG | Yes, but unit/boundary mismatch | active wrapper lines 332-347 and 455-456 |
| Solar collector | `E_capt(i)` from irradiance | kW thermal by dimensional inference | simulation time steps | `Irradiacion` | MJ | Yes | No explicit solar term in active CO2 sum | active wrapper lines 214-223, 457/485; cost lines 56-61 |

`W_comp_kW` is fixed. It does not depend on mass flow, pressure drop,
recirculation, mode, or a calculated efficiency. The electricity calculation
uses:

```text
electric_energy_kWh = W_comp_kW * dry_time
```

The multiplication is dimensionally consistent for a fixed kW load operating
throughout a drying time expressed in hours. No separate temporal integration
is required for that fixed-load assumption.

The active base objective exposes `cost.electric_energy_kWh`; therefore the
active `fix1` wrapper normally retrieves the same energy for grid CO2. The
fallback:

`NOT_EXPOSED_ASSUMED_ZERO_FOR_VALIDATION`

exists at lines 78-83 of the active `fix1` wrapper, but the successful active
base-cost route contains the expected field.

EQUIPMENT_POWER_NOT_EXPOSED_IN_STATIC_CHAIN = FAN_BLOWER_PUMP_AND_CONTROL_AUXILIARIES

## 7. Compressor-power audit

The only compressor-like identifier in the active economic chain is
`W_comp_kW`. Static search did not find a full variable name `compressor` or
`compresor` in the active model/cost implementation.

Evidence supports:

- fixed expression: `3 * 0.746`;
- declared unit: kW;
- implied count: three units, but the physical component identity is not
  documented;
- no flow/pressure calculation;
- no mechanical or electrical efficiency;
- no mode-dependent switching;
- assumed operation for all `dry_time`;
- inclusion in electricity cost;
- inclusion in grid CO2 through `cost.electric_energy_kWh`;
- no separately modeled fan, blower, pump, or motor term;
- no static evidence that proves whether `W_comp_kW` represents a compressor,
  fan bank, refrigeration equipment, or a historical aggregate.

COMPRESSOR_POWER_BASIS = PENDING_MODEL_OWNER_CONFIRMATION

The numeric expression and declared unit are explicit, but the equipment
identity, source, count rationale, duty cycle, and relationship to airflow are
not traceable. No separate double count is demonstrated, but it also cannot be
excluded against equipment that may be physically implicit in the system.

## 8. detail.cost inventory

| Field | Meaning | Unit/status | Source expression | Feeds f(2)? | Feeds CO2? |
|---|---|---|---|---|---|
| `inputs.dry_time` | drying duration | h | wrapper output | Indirectly | Indirectly through electrical energy |
| `inputs.Q_aux_tot` | auxiliary useful thermal energy | MJ by code derivation | wrapper output | Indirectly | CO2 wrapper reads the parallel `detail.outputs` field |
| `inputs.Irradiacion` | accumulated captured solar energy | MJ by dimensional derivation | wrapper output | Indirectly | No explicit active CO2 term |
| `exchange_rate_MXN_per_USD` | historical conversion factor | MXN/USD | cost parameters | Indirectly | No |
| `C_kWh_internal` | electricity price | USD/kWh | historical MXN factor / exchange rate | Indirectly | No |
| `C_esp_GLP_internal` | LPG energy price | USD/MJ | historical MXN factor / exchange rate | Indirectly | No |
| `C_solar_internal` | assigned solar-energy price | USD/MJ | historical MXN factor / exchange rate | Indirectly | No |
| `electric_energy_kWh` | fixed electrical proxy energy | kWh | `W_comp_kW * dry_time` | Yes, through cost | Yes, directly retrieved |
| `electric_cost_USD` | electricity contribution | USD | electricity energy × USD/kWh | Yes | No |
| `LPG_energy_MJ` | alias of `Q_aux_tot` | MJ | direct assignment | Yes, through cost | No; CO2 reads `Q_aux_tot` separately |
| `LPG_cost_USD` | LPG contribution | USD | LPG energy × USD/MJ | Yes | No |
| `solar_energy_MJ` | alias of `Irradiacion` | MJ | direct assignment | Yes, through cost | No |
| `solar_cost_USD` | solar contribution | USD | solar energy × USD/MJ | Yes | No |
| `total_cost_USD` | economic numerator | USD | electric + LPG + solar | Yes | No |
| `water_removed_kg` | cost normalization mass | kg water | `(Mi - M) * md` | Yes | No; CO2 reconstructs another denominator |
| `cost_specific_USD_per_kgwater` | specific economic objective | USD/kg water | total cost / water removed | Direct value of `f(2)` | No |
| `status` | cost validity | `OK` or invalid denominator | denominator check | Guards f(2) | Indirectly through base-objective validity |

The base objective assigns `detail.cost = cost` and
`f_base(2) = cost.cost_specific_USD_per_kgwater`. The active `fix1` wrapper
preserves `f_base(2)` as `f(2)`.

## 9. Energy-cost-CO2 reconciliation matrix

| Energy component | Physical source | Model variable | Native unit | Cost factor | Cost contribution | CO2 factor | CO2 contribution | Reconciled? |
|---|---|---|---|---|---|---|---|---|
| GLP/auxiliary heat | air enthalpy rise across HE1 | `Q_aux_tot` | MJ useful thermal | USD/MJ | `LPG_cost_USD` | kgCO2/kWh fuel basis | `CO2_LPG_kg` uses direct multiplication | No |
| Electricity proxy | historical fixed power over `dry_time` | `electric_energy_kWh` | kWh | USD/kWh | `electric_cost_USD` | kgCO2e/kWh | same energy retrieved by `fix1` | Partially; mathematical field is shared, physical equipment basis is pending |
| Solar | captured irradiance integral | `Irradiacion` / `solar_energy_MJ` | MJ by dimensional derivation | USD/MJ | `solar_cost_USD` | no explicit active solar factor | absent from active CO2 sum | Partially; cost basis remains unsupported |
| Compressor | historical aggregate/proxy | `W_comp_kW` | kW | enters electricity price through energy | included in electricity cost | enters grid factor through energy | included in electricity CO2 | Partially; identity and source pending |
| Fan/blower | not exposed | NOT_EXPOSED | NOT_EXPOSED | none | none separate | none | none separate | No |
| Pump/control | not exposed | NOT_EXPOSED | NOT_EXPOSED | none | none separate | none | none separate | No |
| Recirculation/infiltration | modeled mass/enthalpy flows | `r_div2`, `m_D2`, related states | flow/state units | none explicit | no separate electrical cost | none explicit | no separate electrical CO2 | No explicit equipment-energy coupling |

### GLP reconciliation

The cost equation is dimensionally consistent only with the code-declared
historical interpretation:

```text
Q_aux_tot [MJ] * C_esp_GLP_internal [USD/MJ]
```

It does not establish that the price is expressed per MJ of useful heat rather
than per MJ of fuel input. The Route C LPG price-to-USD/MJ conversion remains
blocked because compatible heating value and heater efficiency boundaries are
unresolved.

The CO2 equation is not dimensionally reconciled:

```text
Q_aux_tot [MJ useful thermal]
* EF_LPG_kgCO2_per_kWh [kgCO2/kWh fuel basis]
```

No MJ-to-kWh conversion and no useful-heat-to-fuel-input conversion are
present.

### Electricity reconciliation

The economic and CO2 paths use the same successful-route energy field:

```text
electric_energy_kWh =
W_comp_kW * dry_time

electric_cost_USD =
electric_energy_kWh * C_kWh_internal

CO2_electricity_kg =
electric_energy_kWh * EF_grid_kgCO2e_per_kWh
```

The mathematical energy and temporal boundaries are aligned. Physical
equipment completeness is not aligned because the meaning of `W_comp_kW` and
the absence of explicit fan/pump/control terms remain unresolved.

### Total and specific cost

The code explicitly supports:

```text
total_cost_USD =
electric_cost_USD + LPG_cost_USD + solar_cost_USD

water_removed_kg =
(Mi - M) * md

cost_specific_USD_per_kgwater =
total_cost_USD / water_removed_kg
```

This scalar becomes `f(2)`.

The CO2 wrapper instead reconstructs `water_removed_kg = mwi - mwf` when those
fields are finite. That denominator is based on the prescribed final wet-basis
moisture, while the cost denominator uses the modeled terminal `M`. Static
code does not guarantee equality.

## 10. Unit-conversion audit

| Quantity | Source variable | Source unit | Conversion | Result unit | Evidence | Status |
|---|---|---|---|---|---|---|
| Solar instantaneous power | `I * A_cap * ETHA_capt` | W/m2 × m2 | `/1000` | kW thermal | active wrapper line 223 | CONSISTENT_WITH_INFERENCE |
| Auxiliary heat rate | `m_HE1_in * delta_h` | kg/s × kJ/kg | none | kJ/s = kW thermal | active wrapper line 340 | CONSISTENT |
| Auxiliary energy | `Q_aux` | kW = kJ/s | `* t_step * 3600 / 1000` | MJ | active wrapper lines 456/484 | CONSISTENT |
| Seconds to hours | `t(i)` | s | `/3600` | h | active wrapper lines 429, 458, 486 | CONSISTENT |
| Recirculation start | `t_rec_ini` | h input | `*3600` | s | active wrapper line 75 | CONSISTENT |
| Fixed electrical energy | `W_comp_kW`, `dry_time` | kW, h | multiplication | kWh | cost line 48 | CONSISTENT |
| Equipment W to kW | equipment rating | NOT_EXPOSED | `3 * 0.746` has no documented source-unit declaration | kW declared | cost-parameter line 49 | AMBIGUOUS |
| Solar energy | `I`, `t_step`, area, efficiency | W/m2, h, m2 | `*3600/1e6`, with `*8` configuration | MJ | active wrapper lines 457/485 | CONSISTENT_WITH_INFERENCE |
| MJ to kWh for LPG CO2 | `Q_aux_tot` | MJ | NOT_EXPOSED | kWh required by factor | active CO2 line 86 | INCONSISTENT |
| Useful heat to fuel input | `Q_aux_tot` | MJ useful thermal | efficiency conversion NOT_EXPOSED | MJ fuel input | active wrapper/cost/CO2 chain | NOT_EXPOSED |
| MXN to USD | cost factors | MXN per unit, MXN/USD | division by exchange rate | USD per unit | cost-parameter lines 37-47 | CONSISTENT |
| Energy to cost | electric/LPG/solar energies | kWh or MJ | multiply by matching historical price unit | USD | cost lines 48-58 | CONSISTENT_WITH_INFERENCE for LPG/solar boundary |
| Water removed for f(2) | `Mi`, terminal `M`, `md` | kg/kg dry solid, kg dry solid | `(Mi-M)*md` | kg water | cost line 63 | CONSISTENT |
| Specific cost | total cost, removed water | USD, kg | division | USD/kg water | cost lines 69-70 | CONSISTENT |
| CO2-specific denominator | `mwi`, `mwf` | kg water | subtraction | kg water | active `fix1` lines 67-76 | CONSISTENT internally; NOT_RECONCILED with f(2) denominator |

## 11. Findings and risks

| ID | Severity | Finding | Evidence | Consequence | Required resolution |
|---|---|---|---|---|---|
| COST-E3D-F01 | CRITICAL | `Q_aux_tot` is MJ of useful thermal energy but is multiplied directly by an LPG factor in kgCO2/kWh | active wrapper lines 340, 456/484; `fix1` line 86 | LPG CO2 is dimensionally and physically unreconciled | Approve one energy boundary, compatible unit conversion, and efficiency treatment before any execution or claim |
| COST-E3D-F02 | MAJOR | LPG cost treats useful heater output as LPG energy without a fuel-input or efficiency conversion | cost lines 52-54; no burner efficiency in active wrapper | A source-based fuel price in USD/MJ cannot yet replace the historical factor coherently | Define useful-heat versus fuel-input basis and document heater efficiency or an explicit waiver |
| COST-E3D-F03 | MAJOR | `W_comp_kW = 3 * 0.746` has an explicit declared kW unit but no component identity, source, efficiency, or duty-cycle evidence | cost-parameter lines 49 and 59; COST-E1/COST-E3 holds | Electricity cost and CO2 depend on an unvalidated equipment proxy | Obtain model-owner/equipment evidence before selecting the article electricity factor scope |
| COST-E3D-F04 | MAJOR | Fan, blower, pump, and control power are not separately exposed or coupled to airflow and pressure drop | repository static search; active cost chain contains only `W_comp_kW` | Equipment-level electricity, cost, and CO2 completeness cannot be claimed | Confirm whether these loads are absent, embedded in `W_comp_kW`, or require a separate future model |
| COST-E3D-F05 | MAJOR | f(2) uses `(Mi-M)*md` for removed water, while f(3) normally uses `mwi-mwf` | cost line 63; `fix1` lines 67-76 | Economic and CO2 specific objectives may use different functional denominators | Reconcile the functional-unit denominator in a separately authorized decision/code PR |
| COST-E3D-F06 | MODERATE | The CO2 wrapper contains a zero-electricity fallback when the energy field is missing | `fix1` lines 78-83 | An alternate or incomplete `detail` structure could silently omit grid emissions | Require the expected `detail.cost.electric_energy_kWh` field or fail closed in any future authorized correction |
| COST-E3D-F07 | MODERATE | Solar energy is monetized, while the `A_cap * 8` configuration and assigned solar cost lack an approved methodological source | active wrapper lines 214-223, 457/485; cost lines 56-61 | f(2) includes a solar term whose article basis remains unresolved | Resolve collector-area/configuration traceability and solar-cost scope |
| COST-E3D-F08 | MODERATE | The active runner uses `fix1`, not the similarly named non-`fix1` tri-objective file; the latter also references `penalty_CO2` before a visible definition | runner line 245; non-`fix1` objective line 39 | The two entry points must not be treated as interchangeable evidence | Retain the active-chain designation and review the alternate file only in a separate authorized code task |
| COST-E3D-F09 | MINOR | EVIDENCE-E1 labels `Q_aux_tot` as kWh and `Irradiacion` as probably kWh, while the active formulas resolve both accumulations to MJ | EVIDENCE-E1 lines 157/161; active wrapper lines 456-457 | Documentary unit labels can propagate incorrect interpretations | Correct documentation in a separate controlled documentation update |

No static evidence confirms a separate double-counted electrical term.
However, the unknown physical meaning of `W_comp_kW` prevents exclusion of
equipment-level overlap.

## 12. Readiness consequences

| Decision area | Audit consequence |
|---|---|
| GDMTO tariff class | The class remains selected, but the applicable final electricity cost cannot close until the energy-only tariff scope and equipment basis are approved |
| Final electricity USD/kWh | Remains pending; the model represents one variable USD/kWh multiplier and no demand/fixed-charge terms |
| LPG USD/MJ | Cannot close until fuel-input energy, heating value, and heater-efficiency boundary are reconciled |
| Solar cost | Cannot close because it feeds f(2) and its economic and physical configuration bases remain pending |
| Grid emissions | Mathematical energy reuse is visible, but equipment completeness and the zero fallback remain unresolved |
| LPG emissions | Cannot close because the active equation mixes MJ useful heat with kgCO2/kWh fuel basis |
| f(2) | Code path is traceable, but physical/economic completeness is insufficient |
| Formal execution | Remains blocked |

ELECTRICITY_COST_MODEL_SCOPE = ENERGY_ONLY_VARIABLE_CHARGE

LPG_ENERGY_BASIS = NOT_RECONCILED

ELECTRICITY_ENERGY_BASIS = PARTIALLY_RECONCILED

COST_OBJECTIVE_TRACEABILITY = PARTIAL

The electricity chain is partially reconciled because the successful active
route uses the same kWh scalar for cost and grid CO2. It is not fully
reconciled because `W_comp_kW` lacks equipment-level provenance and other
electrical auxiliaries are not exposed.

The cost objective is partial rather than complete because all arithmetic
links to f(2) are visible, but `Q_aux_tot`, solar monetization, compressor
identity, and equipment completeness are not publication-ready.

## 13. Current COST-E3D state

COST-E3D = COMPRESSOR_POWER_AND_ENERGY_RECONCILIATION_AUDITED_NO_CODE_CHANGE

ENERGY_COST_RECONCILIATION = CRITICAL_HOLD

ECONOMIC_FACTOR_CODE_UPDATE = BLOCKED_PENDING_COST_E3D_FINDINGS_RESOLUTION

FORMAL_EXECUTION = BLOCKED_PENDING_ECONOMIC_IMPLEMENTATION_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION

`COMPLETE` is not declared because the LPG CO2 equation has a direct unit and
boundary inconsistency, and because electrical-equipment and cost-objective
components remain only partially reconciled.

## 14. Next steps

1. Resolve critical and major findings with explicit, reviewable evidence.
2. Close the electrical model scope before fixing the applicable GDMTO rate.
3. Close the LPG energy boundary before converting the Route C price to
   USD/MJ.
4. Resolve the solar-cost basis because it directly feeds f(2).
5. Create a separate correction PR only if code changes are explicitly
   authorized.
6. Do not execute MATLAB until explicit authorization is granted.
