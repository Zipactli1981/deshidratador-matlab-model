# COST-E1: Economic constants inventory v96z

## 1. Purpose

COST-E1 inventories the economic constants and the internal traceability of
the current cost calculation. It does not validate external sources, change
code, or execute MATLAB.

COST-E1 does not update prices, does not update the exchange rate, and does not
authorize new runs. The values below are static evidence from the repository,
not approved final article factors.

## 2. Scope and restrictions

- no code changes;
- no MATLAB execution;
- no `gamultiobj` execution;
- no R1, R2, or R3 execution;
- no minrep execution;
- no 400-generation execution;
- no economic-factor updates;
- no final article claims;
- no `hybrid`/`gasLP` superiority claims;
- no convergence claims.

## 3. Current methodological status

| Item | Status |
|---|---|
| Gate A | R1 operational PASS |
| Gate B | protocols defined |
| EVIDENCE-E1 | GA variable/output dictionary documented |
| CO2-E4 | grid CO2 factor updated, no execution |
| COST-E1 | economic constants inventory only |
| MATLAB execution | blocked |

## 4. Search strategy

The static search covered the repository while excluding MAT files and run
directories where appropriate. Search patterns included:

- `16.85`;
- `0.0878338`;
- `0.0461721`;
- `tipo`, `cambio`, `exchange`, and `TC`;
- `USD` and `MXN`;
- `GLP`, `LPG`, `gasLP`, and `gas_lp`;
- `electricity`, `electricidad`, `kWh`, and `MJ`;
- `cost`, `costo`, and `detail.cost`;
- `cost_specific` and `cost_specific_USD_per_kgwater`.

The exact decimal strings `0.0878338` and `0.0461721` were not found as
economic literals in the static search. They are reproducible rounded values
derived from the MXN constants and exchange rate documented below.

The requested minimum-file inspection produced:

| Requested path or pattern | Result |
|---|---|
| `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2.m` | found and inspected |
| `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2_fix1.m` | found and inspected |
| `02_src_limpio/production/objective_productive_corrected_v96j.m` | `NOT_FOUND_IN_STATIC_SEARCH` |
| `02_src_limpio/production/cost_productive_corrected_v96j.m` | `NOT_FOUND_IN_STATIC_SEARCH` |
| `02_src_limpio/production/cost_productive*.m` | `NOT_FOUND_IN_STATIC_SEARCH` |
| `02_src_limpio/production/build_base_params.m` | `NOT_FOUND_IN_STATIC_SEARCH`; a configuration scaffold exists at `02_src_limpio/config/build_base_params.m` |
| `02_src_limpio/production/run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` | found and inspected |
| `06_manuscript/article_Q1/review/EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md` | found and inspected |

## 5. Inventory of economic constants

| ID | File | Line/context | Variable or literal | Value | Unit/status | Role in model | Source status |
|---|---|---|---|---:|---|---|---|
| COST-E1-01 | `02_src_limpio/cost/build_cost_params_historical.m` | line 31 | `exchange_rate_MXN_per_USD` | 16.85 | MXN/USD | Converts MXN economic constants to internal USD factors | External source, date, and applicable period absent |
| COST-E1-02 | `02_src_limpio/cost/build_cost_params_historical.m` | line 33 | `C_electricity_MXN_per_kWh` | 1.48 | MXN/kWh | Base electricity price before currency conversion | Tariff, region, date, and external source absent |
| COST-E1-03 | `02_src_limpio/cost/build_cost_params_historical.m` | line 34 | `C_GLP_MXN_per_MJ` | 0.778 | MXN/MJ | Base GLP price before currency conversion | Region, sales modality, date, and external source absent |
| COST-E1-04 | `02_src_limpio/cost/build_cost_params_historical.m` | line 35 | `C_solar_MXN_per_MJ` | 0.15 | MXN/MJ | Assigned solar-energy cost before currency conversion | Interpretation and external source absent |
| COST-E1-05 | `02_src_limpio/cost/build_cost_params_historical.m` | lines 37-39 | `C_electricity_USD_per_kWh` | 1.48 / 16.85 = 0.0878338278931751 | USD/kWh; rounds to 0.0878338 | Internal electricity price | Derived in code; source basis of inputs not validated |
| COST-E1-06 | `02_src_limpio/cost/build_cost_params_historical.m` | lines 41-43 | `C_GLP_USD_per_MJ` | 0.778 / 16.85 = 0.0461721068249258 | USD/MJ; rounds to 0.0461721 | Internal GLP price | Derived in code; source basis of inputs not validated |
| COST-E1-07 | `02_src_limpio/cost/build_cost_params_historical.m` | lines 45-47 | `C_solar_USD_per_MJ` | 0.15 / 16.85 = 0.00890207715133531 | USD/MJ | Internal assigned solar-energy price | Derived in code; source basis of inputs not validated |
| COST-E1-08 | `02_src_limpio/cost/build_cost_params_historical.m` | line 49 | `W_comp_kW` | 3 × 0.746 = 2.238 | kW | Compressor/electrical power used to reconstruct electricity consumption | Component basis and source absent |
| COST-E1-09 | `02_src_limpio/cost/build_cost_params_historical.m` | lines 52-54 | `C_kWh_internal`, `C_esp_GLP_internal`, `C_solar_internal` | aliases of converted USD factors | USD/kWh; USD/MJ; USD/MJ | Factors consumed by `calc_cost_breakdown` | Internal mapping explicit; external sources unvalidated |
| COST-E1-10 | `02_src_limpio/cost/calc_cost_breakdown.m` | lines 48-50 | `electric_energy_kWh`, `electric_cost_USD` | `W_comp_kW × dry_time`; energy × `C_kWh_internal` | kWh; USD | Electricity component of total cost | Formula explicit; factor source unvalidated |
| COST-E1-11 | `02_src_limpio/cost/calc_cost_breakdown.m` | lines 52-54 | `LPG_energy_MJ`, `LPG_cost_USD` | `Q_aux_tot`; energy × `C_esp_GLP_internal` | MJ; USD | GLP component of total cost | Formula explicit; input-unit consistency requires confirmation |
| COST-E1-12 | `02_src_limpio/cost/calc_cost_breakdown.m` | lines 56-58 | `solar_energy_MJ`, `solar_cost_USD` | `Irradiacion`; energy × `C_solar_internal` | MJ; USD | Solar component of total cost | Formula explicit; physical and economic basis requires confirmation |
| COST-E1-13 | `02_src_limpio/cost/calc_cost_breakdown.m` | lines 60-61 | `total_cost_USD` | electric + GLP + solar costs | USD | Numerator of specific cost | Directly feeds `f(2)` through normalization |
| COST-E1-14 | `02_src_limpio/cost/calc_cost_breakdown.m` | line 63 | `water_removed_kg` | `(Mi - M) × md` | kg water | Denominator of specific cost | Formula explicit |
| COST-E1-15 | `02_src_limpio/cost/calc_cost_breakdown.m` | lines 69-70 | `cost_specific_USD_per_kgwater` | `total_cost_USD / water_removed_kg` | USD/kg water | Economic objective value | Directly feeds `f(2)` |
| COST-E1-16 | `02_src_limpio/production/objective_productive_corrected_v95j_endpoint_TMAX_corrected.m` | lines 98-103, 117, 152-154 | `params_cost`, `cost`, `cost_specific`, `detail.cost`, `f(2)` | runtime values | traced structure | Active base objective constructs and stores the cost calculation | Static code evidence only |
| COST-E1-17 | `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2_fix1.m` | lines 29-30, 97, 121 | `f_base(2)` and `f(2)` | inherited from base objective | USD/kg water | Preserves base economic objective as tri-objective column 2 | Static code evidence only |
| COST-E1-18 | `02_src_limpio/production/run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` | lines 245, 324 | objective wrapper and `F(i,2)` | runtime output | USD/kg water | Calls active wrapper and records column 2 as `cost_specific_USD_per_kgwater` | Runner evidence; no execution performed |

The literal-status findings for the values supplied as search clues are:

| Search clue | Static result |
|---|---|
| 16.85 MXN/USD | Found as `exchange_rate_MXN_per_USD` |
| 0.0878338 USD/kWh | `NOT_FOUND_IN_STATIC_SEARCH` as a literal; confirmed as rounded `1.48 / 16.85` |
| 0.0461721 USD/MJ | `NOT_FOUND_IN_STATIC_SEARCH` as a literal; confirmed as rounded `0.778 / 16.85` |

## 6. Cost calculation traceability

The active formal runner identifies
`objective_productive_corrected_v96j_triobjective_CO2_fix1` as its objective.
That wrapper obtains `f_base` from
`objective_productive_corrected_v95j_endpoint_TMAX_corrected`, retains
`f_base(2)` as the second tri-objective component, and records it as
`cost_specific_USD_per_kgwater`.

| Step | Code element | Meaning | Unit/status | Evidence |
|---:|---|---|---|---|
| 1 | `build_cost_params_historical` | Defines MXN constants, exchange rate, USD conversions, and internal aliases | Mixed source units converted to USD units | `build_cost_params_historical.m`, lines 31-59 |
| 2 | `electric_energy_kWh = W_comp_kW * dry_time` | Reconstructs electrical energy | kWh | `calc_cost_breakdown.m`, line 48 |
| 3 | `electric_cost_USD` | Multiplies electrical energy by `C_kWh_internal` | USD | `calc_cost_breakdown.m`, lines 49-50 |
| 4 | `LPG_energy_MJ = Q_aux_tot` and `LPG_cost_USD` | Treats auxiliary energy as GLP energy and applies `C_esp_GLP_internal` | MJ and USD; input-unit confirmation pending | `calc_cost_breakdown.m`, lines 52-54 |
| 5 | `solar_energy_MJ = Irradiacion` and `solar_cost_USD` | Applies the assigned solar-energy factor | MJ and USD; physical/economic basis pending | `calc_cost_breakdown.m`, lines 56-58 |
| 6 | `total_cost_USD` | Sums electricity, GLP, and solar components | USD | `calc_cost_breakdown.m`, lines 60-61 |
| 7 | `water_removed_kg = (Mi - M) * md` | Establishes the normalization denominator | kg water | `calc_cost_breakdown.m`, line 63 |
| 8 | `cost_specific_USD_per_kgwater` | Divides total cost by water removed | USD/kg water | `calc_cost_breakdown.m`, lines 65-70 |
| 9 | `f = [MR, cost_specific]` | Places specific cost in base objective column 2 | `f(2)`, USD/kg water | base objective, line 117 |
| 10 | `detail.cost = cost` | Preserves the full economic breakdown | structured trace | base objective, line 152 |
| 11 | `f = [f_base(1), f_base(2), CO2_specific...]` | Carries the same cost into the active tri-objective wrapper | `f(2)`, USD/kg water | active wrapper/fix, line 97 |
| 12 | `row.cost_specific_USD_per_kgwater = F(i,2)` | Records the GA output column | USD/kg water | formal runner, line 324 |

`detail.cost` exposes, at minimum:

- input copies for `dry_time`, `Q_aux_tot`, `Irradiacion`, `Mi`, `M`, and
  `md`;
- the exchange rate and three internal unit-cost factors;
- electrical, GLP, and solar energy/cost components;
- `total_cost_USD`;
- `water_removed_kg`;
- `cost_specific_USD_per_kgwater`;
- units, denominator definition, and status.

The structure is visible statically, but its external source traceability,
temporal basis, geographic basis, and the unit correspondence of energy inputs
are not closed. Therefore:

`COST_STRUCTURE_REQUIRES_DEEPER_TRACEABILITY`

## 7. Identified risks

- The exchange rate has no documented base date, provider, or averaging rule.
- The GLP cost lacks a documented region, sales modality, market basis, and
  period.
- The electricity cost lacks a documented tariff class, region, date, and
  external source.
- The cost route mixes MXN/USD conversion with kWh and MJ factors; every
  conversion is explicit in code, but the source bases are not validated.
- `calc_cost_breakdown` declares `Q_aux_tot` as MJ, while EVIDENCE-E1 describes
  that output as kWh. This discrepancy must be resolved before final economic
  interpretation.
- `calc_cost_breakdown` treats `Irradiacion` as MJ, while EVIDENCE-E1 marks its
  physical basis as pending confirmation.
- Updating any exchange rate, tariff, or GLP factor would change `f(2)` and can
  change subsequent optimization results.
- Final economic comparison must remain blocked until COST-E2 source fiches
  and a COST-E3 decision memo close the applicable bases.

## 8. Current COST-E1 state

COST-E1 = ECONOMIC_CONSTANTS_INVENTORIED_NO_SOURCE_VALIDATION

ECONOMIC_FACTOR_UPDATE = PENDING_SOURCE_VALIDATION_AND_DECISION_MEMO

FORMAL_EXECUTION = STILL_BLOCKED_PENDING_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION

## 9. Next steps

1. COST-E2: source-validation fiches for exchange rate, LPG cost, and
   electricity cost.
2. COST-E3: economic-basis decision memo.
3. COST-E4: controlled code update only if required.
4. Do not run MATLAB until the economic-factor basis is resolved or explicitly
   waived.
