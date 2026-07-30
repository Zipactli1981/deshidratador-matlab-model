# COST-E3D-R1: Technical resolution memo v96z

## 1. Purpose

This memo consolidates confirmed model-owner decisions and the available
primary-source data needed to resolve, at the documentary level, the physical
and electrical model boundary, the air-impeller identity and power basis, and
the LPG energy, cost, and emissions chains.

It also preserves the historical traceability of the solar cost and electricity
emission factor, audits the two water-removed expressions used by the active
objective chain, and identifies the HOLD items that must remain closed to
execution until a separate coordinated implementation is reviewed.

COST-E3D-R1 does not change code, constants, objective functions, wrappers, or
runners. It does not execute MATLAB or validate final scientific results.

## 2. Scope and restrictions

This is a documentation-only decision memo. Its scope is limited as follows:

- no MATLAB code changes;
- no objective-function, wrapper, or runner changes;
- no economic-constant or CO2-factor changes;
- no equation corrections;
- no MATLAB or `gamultiobj` execution;
- no R1, R2, R3, minrep, or 400-generation execution;
- no MAT files, results, figures, PDFs, or source files added;
- no final article results, convergence, global reproducibility, hybrid/gasLP
  superiority, or global Pareto-front claims;
- no authorization for formal execution; and
- no code implementation in this PR.

The technical chains described below are recommendations for a later,
separately authorized implementation. A documentary resolution does not mean
that the active code has already been updated.

## 3. Evidence base

| Source | File status | Evidence used | Reference period | Limitation |
|---|---|---|---|---|
| `COST_E3D_COMPRESSOR_ENERGY_RECONCILIATION_AUDIT_v96z.md` | FOUND / INSPECTED | Active-chain audit, unresolved energy boundaries, R1 validity boundary | Current repository state | Predates the model-owner resolutions consolidated here |
| `COST_E3_ECONOMIC_BASIS_DECISION_MEMO_v96z.md` | FOUND / INSPECTED | Route C, June 2026 period, FIX mean, monthly LPG price, GDMTO selection, and economic HOLDs | June 2026 | Electricity rate, LPG conversion, and solar update were not closed there |
| `COST_E2_ECONOMIC_SOURCE_VALIDATION_FICHES_v96z.md` | FOUND / INSPECTED | Source inventory, Route C, and historical thesis-basis separation | Historical and article-year candidates | Sources were inventoried, not finally implemented |
| `COST_E1_ECONOMIC_CONSTANTS_INVENTORY_v96z.md` | FOUND / INSPECTED | Static inventory of internal economic constants and cost-objective structure | Historical code basis | No external source validation |
| `CO2_E4_GRID_FACTOR_CODE_UPDATE_v96z.md` | FOUND / INSPECTED | Article grid factor already selected and implemented as 0.444 kgCO2e/kWh | FESEN 2024 basis | This memo does not reopen or modify CO2-E4 |
| `EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md` | FOUND / INSPECTED | Dictionary of `X`, `F`, and `detail` fields | Current documented active chain | Some energy-unit labels were already flagged by COST-E3D |
| Active objective, cost, and wrapper MATLAB files | FOUND / STATICALLY INSPECTED | Definitions and uses of `Mi`, `M`, `md`, `mwi`, `mwf`, `Q_aux_tot`, electrical energy, f(2), and f(3) | Current branch baseline | Static inspection only; no MATLAB execution |
| Doctoral thesis PDF | SOURCE_FILE_NOT_FOUND_IN_REPOSITORY | No PDF evidence used; thesis-era Markdown material was found only as secondary local context | Thesis era | The complete thesis PDF was not inspected locally |
| *Hybrid thermosolar-LPG dehydrating plant installed in Xochitepec, México. Case study: Pineapple* | SOURCE_FILE_NOT_FOUND_IN_REPOSITORY | Only the model-owner-supplied identity, measured power, and burner-efficiency data in this task are used | Xochitepec plant publication | Article file was not inspected locally |
| INECC/IMP, *Factores de emisión para los diferentes tipos de combustibles fósiles y alternativos que se consumen en México*, Table 18 (2014) | SOURCE_FILE_NOT_FOUND_IN_REPOSITORY | Only the expressly supplied values 46.16 MJ/kg, 3.00 kgCO2/kg LPG, and 65,082.90 kgCO2/TJ are used | 2014 | Source PDF was not inspected locally |
| SEMARNAT/RENE notice published in 2023 for reporting year 2022 | SOURCE_FILE_NOT_FOUND_IN_REPOSITORY | Only the expressly supplied historical value 0.435 tCO2e/MWh is used | Reporting year 2022 | Notice file was not inspected locally |
| Maximum LPG prices for 2026-07-26 through 2026-08-01 | SOURCE_FILE_NOT_FOUND_IN_REPOSITORY | Only the expressly supplied Xochitepec Region 130 values are used as a cross-check | 2026-07-26 to 2026-08-01 | Weekly document was not inspected locally |
| CONUEE/ANES/GIZ industrial solar-thermal market baseline study (2018) | SOURCE_FILE_NOT_FOUND_IN_REPOSITORY | Only the expressly supplied 0.130-0.285 MXN/MJ range and historical selection are used | 2018 | Source PDF and its price-index base month were not inspected locally |

No relevant source PDF was available for local inspection. No PDF was copied,
downloaded, or added to the repository. Bibliographic and numerical statements
for missing files are limited to the values expressly supplied for this task.

## 4. Model-owner decisions

The following decisions are recorded as direct model-owner decisions and are
not modified by inference.

| Decision item | Confirmed value | Evidence class | Status |
|---|---|---|---|
| Thermal model scope | Direct air-heating abstraction without a water circuit | Model-owner decision | CONFIRMED |
| Water-circuit equipment | Outside model scope | Model-owner decision | CONFIRMED |
| Electrical model scope | Air impeller only | Model-owner decision | CONFIRMED |
| Air-impeller identity | Three-hp axial suction fan with variable-frequency drive | Model-owner decision | CONFIRMED |
| Nominal air-impeller power | 2.238 kW | Model-owner decision | CONFIRMED |
| Measured air-impeller power | 1.03 kW | Model-owner decision | CONFIRMED |
| Recommended operational power | 1.03 kW | Model-owner decision | CONFIRMED FOR FUTURE IMPLEMENTATION |
| Air-impeller duty | Full `dry_time` | Model-owner decision | CONFIRMED |
| `Q_aux_tot` physical meaning | Supplementary LPG thermal energy required to reach the minimum temperature | Model-owner decision | CONFIRMED |
| `Q_aux_tot` basis | Useful supplementary thermal energy | Model-owner decision | CONFIRMED |
| Burner efficiency | 0.78, reported for the Xochitepec plant article | Model-owner decision with supplied bibliographic attribution | CONFIRMED FOR DOCUMENTARY CHAIN |
| Heat-exchanger efficiency | Not applied because the water-air subsystem is outside model scope | Model-owner decision | CONFIRMED |
| LPG fuel-input basis | `Q_aux_tot / 0.78` | Model-owner decision | CONFIRMED FOR FUTURE IMPLEMENTATION |
| Water-removed basis | Intended equivalent representations pending static proof | Model-owner decision and static audit | HOLD |

MODEL_THERMAL_SCOPE = DIRECT_AIR_HEATING_ABSTRACTION_WITHOUT_WATER_CIRCUIT

WATER_CIRCUIT_EQUIPMENT = OUTSIDE_MODEL_SCOPE

ELECTRICAL_MODEL_SCOPE = AIR_IMPELLER_ONLY

AIR_IMPELLER_IDENTITY = THREE_HP_AXIAL_SUCTION_FAN_WITH_VARIABLE_FREQUENCY_DRIVE

AIR_IMPELLER_NOMINAL_POWER = 2.238_KW

AIR_IMPELLER_MEASURED_POWER = 1.03_KW

AIR_IMPELLER_RECOMMENDED_MODEL_POWER = 1.03_KW

AIR_IMPELLER_OPERATION = FULL_DRY_TIME

Q_AUX_TOT_PHYSICAL_MEANING = SUPPLEMENTARY_LPG_THERMAL_ENERGY_REQUIRED_TO_REACH_MINIMUM_TEMPERATURE

Q_AUX_TOT_BASIS = USEFUL_SUPPLEMENTARY_THERMAL_ENERGY

BURNER_EFFICIENCY_VALUE = 0.78

BURNER_EFFICIENCY_STATUS = ARTICLE_REPORTED_FOR_XOCHITEPEC_PLANT

HEAT_EXCHANGER_EFFICIENCY = NOT_APPLIED_BECAUSE_OUTSIDE_MODEL_SCOPE

LPG_FUEL_INPUT_BASIS = Q_AUX_TOT_DIVIDED_BY_0.78

WATER_REMOVED_BASIS = INTENDED_EQUIVALENT_REPRESENTATIONS_PENDING_STATIC_PROOF

No inspected local source explicitly contradicts these owner decisions. The
active use of nominal power in the cost chain is an implementation gap, not a
source conflict with the distinction between nominal and measured power.

## 5. Model boundary

The model is a deliberate direct-air-heating abstraction. It represents:

- direct heating of process air;
- solar energy captured by the air-heating system; and
- supplementary LPG heat used to reach the minimum process temperature.

It does not represent the solar water circuit, thermal-storage tank, solar-field
water pump, heat-exchanger pump, water heater as a separate component, or the
water-air heat exchanger as an explicit subsystem. Lighting, instrumentation,
and food-processing loads are also outside the boundary.

The only electrical load included in the selected model boundary is the air
impeller. The reduced boundary is a deliberate model abstraction and is not
classified as a defect.

MODEL_BOUNDARY_STATUS = CONFIRMED_BY_MODEL_OWNER

## 6. Air-impeller resolution

The equipment represented by the historical `W_comp_kW` label is not a
compressor. The model owner identifies it as an axial suction fan driven by an
induction motor and a variable-frequency drive.

The 3 hp plate rating corresponds to the nominal value:

```text
3 hp × 0.746 kW/hp = 2.238 kW nominal
```

The reported measured operating electrical power is 1.03 kW. The model owner
selects this measured value for future cost and operational CO2 calculations,
with operation over the full drying time:

```text
E_air_impeller_kWh = 1.03 kW × dry_time_h
```

The 2.238 kW value must remain identifiable as nominal plate power, not as the
recommended operational consumption. Pumps remain outside the model boundary.

Static inspection located the current nominal-power use in the cost-parameter
chain and confirmed that the resulting electrical-energy field feeds both the
cost calculation and the active CO2 wrapper. A future implementation must
replace or relabel that use coherently in both objectives; this memo does not
perform the change.

COMPRESSOR_POWER_BASIS = NOT_APPLICABLE

AIR_IMPELLER_POWER_BASIS = MEASURED_OPERATIONAL_VALUE_FROM_XOCHITEPEC_PLANT

AIR_IMPELLER_COST_AND_CO2_POWER_BASIS = MEASURED_1.03_KW

ELECTRICITY_ENERGY_BASIS = RECONCILED_FOR_AIR_IMPELLER_ONLY

## 7. LPG fuel properties and emission factors

The primary documentary basis selected for LPG is INECC/IMP (2014), Table 18.
Because the source file is not in the repository, this memo uses only the
values supplied in the task:

| Property | Supplied average value | Basis |
|---|---:|---|
| Net heating value | 46.16 MJ/kg LPG | Fuel input |
| Mass emission factor | 3.00 kgCO2/kg LPG | LPG mass |
| Energy emission factor | 65,082.90 kgCO2/TJ | Fuel input |

The energy-factor conversion is:

```text
65,082.90 kgCO2/TJ ÷ 1,000,000 MJ/TJ
= 0.06508290 kgCO2/MJ fuel input
```

The mass and energy representations are consistent subject to the rounding of
the published average table values:

```text
3.00 kgCO2/kg ÷ 46.16 MJ/kg
= 0.0649913345 kgCO2/MJ
```

They are alternative representations and must not be added together. The
recommended primary implementation uses LPG mass; the energy factor is an
independent reasonableness check.

LPG_HEATING_VALUE_SOURCE = INECC_IMP_2014_TABLE_18

LPG_EMISSION_FACTOR_SOURCE = INECC_IMP_2014_TABLE_18

LPG_NET_HEATING_VALUE = 46.16_MJ_PER_KG

LPG_EMISSION_FACTOR_MASS = 3.00_KG_CO2_PER_KG_LPG

LPG_EMISSION_FACTOR_ENERGY = 0.06508290_KG_CO2_PER_MJ_FUEL_INPUT

## 8. LPG energy, cost and CO2 chain

The recommended physical chain separates useful thermal output from fuel input:

```text
Q_aux_tot_MJ = useful supplementary thermal energy

Q_LPG_input_MJ = Q_aux_tot_MJ / 0.78

m_LPG_kg = Q_LPG_input_MJ / (46.16 MJ/kg)

LPG_cost_USD = m_LPG_kg × LPG_price_USD_per_kg

CO2_LPG_kg = m_LPG_kg × 3.00 kgCO2/kg LPG
```

The alternative emissions cross-check is:

```text
CO2_LPG_kg = Q_LPG_input_MJ × 0.06508290 kgCO2/MJ fuel input
```

Dividing useful `Q_aux_tot` by 0.78 estimates fuel-input energy. Dividing that
input by 46.16 MJ/kg produces a common LPG mass activity datum for cost and
CO2. The active code must not multiply useful thermal MJ directly by a
kgCO2/kWh factor. No heat-exchanger efficiency is applied because that
subsystem is outside the confirmed model boundary.

LPG_ENERGY_BASIS = TECHNICALLY_RESOLVED_PENDING_CODE_IMPLEMENTATION

LPG_COST_CHAIN = RESOLVED_DOCUMENTALLY

LPG_CO2_CHAIN = RESOLVED_DOCUMENTALLY

LPG_COST_AND_CO2_COMMON_ACTIVITY_DATA = MASS_OF_LPG_KG

## 9. June 2026 LPG calculations

The already selected article reference period remains June 2026, the latest
complete month in COST-E3:

ARTICLE_ECONOMIC_REFERENCE_PERIOD = JUNE_2026_LATEST_COMPLETE_MONTH

LPG_PRICE_JUNE_2026_XOCHITEPEC = 19.46_MXN_PER_KG

BANXICO_FIX_JUNE_2026_MEAN = 17.3819136364_MXN_PER_USD

The currency and energy-basis calculations are:

```text
LPG price [USD/kg]
= 19.46 MXN/kg ÷ 17.3819136364 MXN/USD
= 1.11955452127251 USD/kg
→ recorded value: 1.1195545213 USD/kg

LPG cost [USD/MJ fuel input]
= 1.1195545213 USD/kg ÷ 46.16 MJ/kg
= 0.0242537807901 USD/MJ fuel input
→ recorded value: 0.0242537808 USD/MJ fuel input

LPG cost [USD/MJ useful]
= 1.1195545213 USD/kg ÷ (46.16 MJ/kg × 0.78 useful/input)
= 0.0310945907566 USD/MJ useful
→ recorded value: 0.0310945908 USD/MJ useful
```

The calculation trace retains at least ten significant digits. A manuscript
table may use a clearly stated, reasonable rounding such as 1.120 USD/kg,
0.02425 USD/MJ fuel input, and 0.03109 USD/MJ useful. The fuel-input and useful
thermal-output bases must remain explicitly distinguished.

LPG_PRICE_USD_PER_KG = 1.1195545213

LPG_COST_USD_PER_MJ_FUEL_INPUT = 0.0242537808

LPG_COST_USD_PER_MJ_USEFUL = 0.0310945908

## 10. Weekly LPG price cross-check

The supplied weekly document places Xochitepec, Morelos, in Region 130 and
reports 19.26 MXN/kg with VAT and 10.40 MXN/L with VAT for 2026-07-26 through
2026-08-01.

This period is later than the June 2026 article reference period. It is retained
only as an order-of-magnitude and temporal-continuity check and must not replace
the 19.46 MXN/kg June monthly basis. The 0.20 MXN/kg difference is not evidence
of an error in the monthly basis.

LPG_PRICE_CURRENT_CROSSCHECK = 19.26_MXN_PER_KG_WITH_VAT

LPG_PRICE_CURRENT_CROSSCHECK_LITER = 10.40_MXN_PER_LITER_WITH_VAT

LPG_PRICE_CURRENT_CROSSCHECK_PERIOD = 2026_07_26_TO_2026_08_01

LPG_PRICE_CURRENT_CROSSCHECK_LOCATION = XOCHITEPEC_MORELOS_REGION_130

LPG_PRICE_CURRENT_CROSSCHECK_USE = CONTEXT_ONLY_NOT_ARTICLE_REFERENCE_PERIOD

## 11. Historical electricity emission-factor traceability

The supplied SEMARNAT/RENE notice value for reporting year 2022 is:

```text
0.435 tCO2e/MWh = 0.435 kgCO2e/kWh
```

The numerical equality follows because both the numerator and denominator are
scaled by 1,000. This factor is preserved only to trace the thesis-era basis. It
does not replace the article grid factor already implemented in CO2-E4, and
this memo neither duplicates nor reverts that change.

GRID_EMISSION_FACTOR_2022 = 0.435_KGCO2E_PER_KWH

GRID_EMISSION_FACTOR_2022_CONVERTED = 0.435_KGCO2E_PER_KWH

GRID_EMISSION_FACTOR_2022_SOURCE = SEMARNAT_RENE_NOTICE_2023_FOR_REPORTING_YEAR_2022

GRID_EMISSION_FACTOR_2022_USE = HISTORICAL_THESIS_TRACEABILITY_ONLY

ARTICLE_GRID_EMISSION_FACTOR = AS_ALREADY_IMPLEMENTED_IN_CO2_E4

## 12. Solar-cost traceability and 2026 hold

The historical basis is the 2018 CONUEE/ANES/GIZ industrial solar-thermal
market baseline study. The supplied source range is 0.130-0.285 MXN/MJ as a
levelized cost of thermal energy.

The thesis selected 0.150 MXN/MJ, a value within and near the lower end of that
range:

```text
0.150 MXN/MJ ÷ 16.85 MXN/USD
= 0.0089020772 USD/MJ
≈ 0.0089021 USD/MJ
```

The 0.150 MXN/MJ value is not a commercial tariff or marginal cost. It is a
historical selection within a published levelized-cost range and must not be
presented as a unique verbatim source value.

The article-year update requires selection of the relevant 2018 base month and
an official Mexican National Consumer Price Index update through June 2026.
Neither step is implemented here. The preliminary plant-specific reconstruction
of 0.7518 MXN/MJ is not selected; if revisited, it must remain classified as
`ALTERNATIVE_PLANT_SPECIFIC_RECONSTRUCTION_NOT_SELECTED`.

SOLAR_COST_SOURCE = CONUEE_ANES_GIZ_2018_INDUSTRIAL_SOLAR_THERMAL_MARKET_BASELINE_STUDY

SOLAR_COST_METRIC = LEVELIZED_COST_OF_THERMAL_ENERGY

SOLAR_COST_HISTORICAL_BASIS = TRACEABLE_LEVELIZED_COST_OF_THERMAL_ENERGY

SOLAR_COST_SOURCE_RANGE_2018 = 0.130_TO_0.285_MXN_PER_MJ

THESIS_SELECTED_SOLAR_COST = 0.150_MXN_PER_MJ

THESIS_EXCHANGE_RATE = 16.85_MXN_PER_USD

THESIS_SOLAR_COST_USD = 0.0089021_USD_PER_MJ

SOLAR_COST_2026_UPDATE_METHOD = INFLATION_UPDATE_USING_OFFICIAL_MEXICAN_PRICE_INDEX_PENDING_BASE_MONTH_SELECTION

SOLAR_COST_2026_STATUS = HOLD_PENDING_INPC_BASE_MONTH_AND_UPDATE

## 13. GDMTO electricity boundary and hold

The selected article tariff class remains GDMTO. The economic abstraction uses
only a variable energy charge associated with the air impeller:

```text
E_air_impeller_kWh = 1.03 kW × dry_time_h

electricity_cost_USD
= E_air_impeller_kWh × electricity_cost_USD_per_kWh
```

The model does not attempt to reproduce a complete electricity bill. Maximum
demand, fixed charges, power factor, penalties, and additional taxes not
already contained in the selected source are outside this energy-only boundary.

The applicable June 2026 CFE region or division for Xochitepec and its exact
GDMTO energy charge still require source extraction. No final USD/kWh value is
set in this memo.

ELECTRICITY_TARIFF_CLASS = GDMTO

ELECTRICITY_TARIFF_CLASS_DECISION = USE_GDMTO_FOR_ARTICLE_BASIS

ELECTRICITY_COST_MODEL_SCOPE = ENERGY_ONLY_VARIABLE_CHARGE

ELECTRICITY_ENERGY_MODEL = 1.03_KW_TIMES_DRY_TIME_H

ELECTRICITY_GDMTO_JUNE_2026_RATE = HOLD_PENDING_APPLICABLE_CFE_REGION_OR_DIVISION_AND_RATE_EXTRACTION

ELECTRICITY_COST_FINAL_USD_PER_KWH = HOLD

## 14. Water-removed equivalence audit

Static inspection found the following active definitions:

| Symbol | Definition or use | Basis / unit | Objective use |
|---|---|---|---|
| `m_i` | 0.87 | Initial wet-basis moisture fraction | Constructs `Mi` and `mwi` |
| `Mi` | `m_i / (1 - m_i)` | kg water/kg dry solid | Initial dry-basis moisture ratio in f(2) |
| `mwi` | `W0 × m_i` | kg water initially | Initial water mass in f(3) |
| `md` | `mwi / Mi` | kg dry solid | Converts dry-basis moisture ratio to water mass |
| `m_f` | 0.08 | Specified final wet-basis fraction | Constructs `Mf` |
| `Mf` | `m_f / (1 - m_f)` | kg water/kg dry solid | Constructs `mwf` |
| `mwf` | `Mf × md` | kg water at specified `Mf` | Final water mass used in f(3) |
| `M` | Terminal `M_prod` returned by the active wrapper | kg water/kg dry solid | Terminal state used in f(2) |
| `M_des` | `0.10 / (1 - 0.10)` | kg water/kg dry solid | Active moisture termination threshold |

The f(2) denominator is:

```text
water_removed_f2 = (Mi - M) × md
```

The normal f(3) denominator is:

```text
water_removed_f3 = mwi - mwf
```

From the active definitions:

```text
md = mwi / Mi
therefore Mi × md = mwi

(Mi - M) × md
= Mi × md - M × md
= mwi - M × md
```

Because `mwf = Mf × md`, the two expressions are equal if and only if the same
terminal state is used and `M = Mf`:

```text
(Mi - M) × md = mwi - mwf
iff M × md = Mf × md
iff M = Mf, for md > 0
```

The units are compatible: dry-basis moisture ratio multiplied by kg dry solid
produces kg water. However, state equivalence is not established. The active
wrapper can terminate at the `M_des` threshold, where `m_des = 0.10` differs
from `m_f = 0.08`, or at its maximum-time endpoint. Consequently, static
evidence does not prove that returned `M` equals `Mf`.

WATER_REMOVED_EQUIVALENCE = NOT_PROVEN

WATER_REMOVED_BASIS = INTENDED_EQUIVALENT_REPRESENTATIONS_PENDING_STATIC_PROOF

No denominator equation is corrected in this memo.

## 15. Consequences for f(2)

The recommended conceptual cost chain is:

```text
total_cost_USD
= LPG_cost_USD
+ electricity_cost_USD
+ solar_cost_USD

cost_specific_USD_per_kgwater
= total_cost_USD / water_removed_kg
```

The LPG cost chain is resolved documentarily, and the air-impeller energy is
physically resolved as 1.03 kW over `dry_time`. The monetary GDMTO factor and
the June 2026 solar-cost update remain on HOLD. The specific-cost denominator
also remains subject to the unresolved water-state equivalence.

COST_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_REMAINING_HOLDS

This memo does not declare f(2) final.

## 16. Consequences for f(3)

The recommended operational-emissions chain is:

```text
CO2_total_kg = CO2_LPG_kg + CO2_electricity_kg

CO2_LPG_kg = m_LPG_kg × 3.00 kgCO2/kg LPG

CO2_electricity_kg
= E_air_impeller_kWh × ARTICLE_GRID_EMISSION_FACTOR
```

No direct operational emissions are assigned to captured solar energy. A
life-cycle boundary would require a separate explicit methodological decision
and is not introduced here. The chain remains pending coordinated code
implementation and denominator reconciliation.

ENVIRONMENTAL_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_CODE_IMPLEMENTATION

This memo does not declare f(3) final.

## 17. Consequences for R1

R1 remains valid as an operational test of the seed-aware runner and the
`gamultiobj` execution chain. The present resolution does not invalidate the
external seed, population and generation settings, returned `X`, `F`,
`population`, `scores`, `exitflag`, or `output`, or the artifact hashes and
operational audit trail.

The economic and environmental objective values remain methodologically
provisional. After a coordinated implementation, f(2) and f(3) must be
recalculated before scientific interpretation. R1 must not support final
scientific results, final hybrid/gasLP superiority, convergence, global
reproducibility, a final representative solution, or global Pareto-front
validity.

R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST

R1_ECONOMIC_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL

R1_ENVIRONMENTAL_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL

R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL

COST_E3D_FINDINGS_DO_NOT_INVALIDATE_R1_OPERATIONAL_RECORD

## 18. Resolved items

| ID | Classification | Finding or decision | Evidence | Consequence | Status |
|---|---|---|---|---|---|
| COST-E3D-R1-D01 | OWNER DECISION | The model is a direct-air-heating abstraction without a water circuit | Confirmed model-owner scope | Water equipment is excluded deliberately | RESOLVED DOCUMENTARILY |
| COST-E3D-R1-D02 | OWNER DECISION | The only modeled electrical load is the air impeller | Confirmed model-owner scope | Pumps and other plant loads are outside the model boundary | RESOLVED DOCUMENTARILY |
| COST-E3D-R1-D03 | OWNER DECISION | The air impeller is a 3 hp axial suction fan with VFD, not a compressor | Confirmed identity and active historical `W_comp_kW` trace | Terminology and equipment basis are fixed for future implementation | RESOLVED DOCUMENTARILY |
| COST-E3D-R1-D04 | OWNER DECISION | Use measured 1.03 kW over full `dry_time`; retain 2.238 kW as nominal plate power | Model-owner decision and supplied publication datum | Cost and CO2 must share the measured operational electricity basis | RESOLVED PENDING CODE IMPLEMENTATION |
| COST-E3D-R1-D05 | OWNER DECISION | `Q_aux_tot` is useful supplementary LPG thermal energy | Model-owner decision and static energy trace | Fuel input is `Q_aux_tot / 0.78` | RESOLVED PENDING CODE IMPLEMENTATION |
| COST-E3D-R1-D06 | TECHNICAL DECISION | LPG cost and CO2 use the same LPG mass derived with 46.16 MJ/kg | Supplied INECC/IMP Table 18 values | Prevents mixed useful-energy and fuel-input bases | RESOLVED DOCUMENTARILY |
| COST-E3D-R1-D07 | TECHNICAL DECISION | Primary LPG CO2 is mass-based at 3.00 kgCO2/kg; 0.06508290 kgCO2/MJ is a check | Supplied INECC/IMP Table 18 values | Avoids double counting alternative factor forms | RESOLVED DOCUMENTARILY |
| COST-E3D-R1-D08 | PRIOR DECISION | June 2026 remains the article economic reference period with 19.46 MXN/kg and FIX 17.3819136364 | COST-E3 and verified arithmetic | Produces traceable USD/kg and USD/MJ values | RESOLVED DOCUMENTARILY |
| COST-E3D-R1-D09 | TRACEABILITY DECISION | The 2022 grid factor is historical thesis context only | Supplied SEMARNAT/RENE value and CO2-E4 | Article factor remains governed by CO2-E4 | RESOLVED DOCUMENTARILY |
| COST-E3D-R1-D10 | TRACEABILITY DECISION | Historical solar cost is a selected levelized thermal cost within a published range | Supplied 2018 range and thesis conversion | Historical basis is preserved without treating it as the 2026 value | RESOLVED FOR HISTORICAL TRACEABILITY |
| COST-E3D-R1-D11 | OPERATIONAL BOUNDARY | COST-E3D findings do not invalidate the R1 operational record | COST-E3D audit and R1 boundary | Scientific interpretation remains provisional | RESOLVED DOCUMENTARILY |

## 19. Remaining holds

| ID | Classification | Finding or decision | Evidence | Consequence | Status |
|---|---|---|---|---|---|
| COST-E3D-R1-H01 | MAJOR HOLD | The June 2026 solar update lacks a selected 2018 INPC base month and calculation | Source file absent; prior COST-E3 hold | Article solar USD/MJ cannot be finalized | OPEN |
| COST-E3D-R1-H02 | MAJOR HOLD | The applicable Xochitepec CFE region/division and June 2026 GDMTO variable-energy rate have not been extracted | COST-E3 and confirmed energy-only boundary | Electricity USD/kWh cannot be finalized | OPEN |
| COST-E3D-R1-H03 | MAJOR HOLD | `(Mi-M)×md` and `mwi-mwf` do not have proven terminal-state equivalence | Active static definitions and termination paths | f(2) and f(3) may use different water denominators | OPEN |
| COST-E3D-R1-H04 | MAJOR HOLD | The resolved air-impeller and LPG chains are not implemented in active cost and CO2 code | Static active-chain audit | Existing f(2) and f(3) remain methodologically provisional | OPEN |
| COST-E3D-R1-H05 | PROCESS HOLD | Cost and CO2 changes require one coordinated, separate implementation PR and subsequent static review | Gate-control restrictions | No code or formal execution is authorized here | OPEN |
| COST-E3D-R1-H06 | EXECUTION HOLD | Explicit run authorization has not been issued after implementation review | Current Gate B status | MATLAB and formal GA execution remain blocked | OPEN |

## 20. Current COST-E3D-R1 state

COST-E3D-R1 = TECHNICAL_RESOLUTION_MEMO_DOCUMENTED_NO_CODE_CHANGE

MODEL_BOUNDARY_STATUS = CONFIRMED_BY_MODEL_OWNER

MODEL_THERMAL_SCOPE = DIRECT_AIR_HEATING_ABSTRACTION_WITHOUT_WATER_CIRCUIT

WATER_CIRCUIT_EQUIPMENT = OUTSIDE_MODEL_SCOPE

ELECTRICAL_MODEL_SCOPE = AIR_IMPELLER_ONLY

COMPRESSOR_POWER_BASIS = NOT_APPLICABLE

AIR_IMPELLER_IDENTITY = THREE_HP_AXIAL_SUCTION_FAN_WITH_VARIABLE_FREQUENCY_DRIVE

AIR_IMPELLER_NOMINAL_POWER = 2.238_KW

AIR_IMPELLER_MEASURED_POWER = 1.03_KW

AIR_IMPELLER_COST_AND_CO2_POWER_BASIS = MEASURED_1.03_KW

AIR_IMPELLER_OPERATION = FULL_DRY_TIME

Q_AUX_TOT_BASIS = USEFUL_SUPPLEMENTARY_THERMAL_ENERGY

BURNER_EFFICIENCY_VALUE = 0.78

LPG_NET_HEATING_VALUE = 46.16_MJ_PER_KG

LPG_EMISSION_FACTOR_MASS = 3.00_KG_CO2_PER_KG_LPG

LPG_EMISSION_FACTOR_ENERGY = 0.06508290_KG_CO2_PER_MJ_FUEL_INPUT

LPG_ENERGY_BASIS = TECHNICALLY_RESOLVED_PENDING_CODE_IMPLEMENTATION

LPG_COST_CHAIN = RESOLVED_DOCUMENTALLY

LPG_CO2_CHAIN = RESOLVED_DOCUMENTALLY

LPG_COST_AND_CO2_COMMON_ACTIVITY_DATA = MASS_OF_LPG_KG

LPG_PRICE_JUNE_2026_XOCHITEPEC = 19.46_MXN_PER_KG

LPG_PRICE_USD_PER_KG = 1.1195545213

LPG_COST_USD_PER_MJ_FUEL_INPUT = 0.0242537808

LPG_COST_USD_PER_MJ_USEFUL = 0.0310945908

LPG_PRICE_CURRENT_CROSSCHECK = 19.26_MXN_PER_KG_WITH_VAT

LPG_PRICE_CURRENT_CROSSCHECK_PERIOD = 2026_07_26_TO_2026_08_01

LPG_PRICE_CURRENT_CROSSCHECK_USE = CONTEXT_ONLY_NOT_ARTICLE_REFERENCE_PERIOD

GRID_EMISSION_FACTOR_2022 = 0.435_KGCO2E_PER_KWH

GRID_EMISSION_FACTOR_2022_USE = HISTORICAL_THESIS_TRACEABILITY_ONLY

SOLAR_COST_HISTORICAL_BASIS = TRACEABLE_LEVELIZED_COST_OF_THERMAL_ENERGY

SOLAR_COST_SOURCE_RANGE_2018 = 0.130_TO_0.285_MXN_PER_MJ

THESIS_SELECTED_SOLAR_COST = 0.150_MXN_PER_MJ

THESIS_SOLAR_COST_USD = 0.0089021_USD_PER_MJ

SOLAR_COST_2026_STATUS = HOLD_PENDING_INPC_BASE_MONTH_AND_UPDATE

ELECTRICITY_TARIFF_CLASS = GDMTO

ELECTRICITY_COST_MODEL_SCOPE = ENERGY_ONLY_VARIABLE_CHARGE

ELECTRICITY_ENERGY_MODEL = 1.03_KW_TIMES_DRY_TIME_H

ELECTRICITY_GDMTO_JUNE_2026_RATE = HOLD_PENDING_APPLICABLE_CFE_REGION_OR_DIVISION_AND_RATE_EXTRACTION

ELECTRICITY_COST_FINAL_USD_PER_KWH = HOLD

WATER_REMOVED_EQUIVALENCE = NOT_PROVEN

COST_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_REMAINING_HOLDS

ENVIRONMENTAL_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_CODE_IMPLEMENTATION

ENERGY_COST_RECONCILIATION = MAJOR_HOLD

ECONOMIC_FACTOR_CODE_UPDATE = BLOCKED_PENDING_REMAINING_HOLDS_AND_SEPARATE_IMPLEMENTATION_PR

FORMAL_EXECUTION = BLOCKED_PENDING_ECONOMIC_IMPLEMENTATION_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION

R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST

R1_ECONOMIC_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL

R1_ENVIRONMENTAL_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL

R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL

COST_E3D_FINDINGS_DO_NOT_INVALIDATE_R1_OPERATIONAL_RECORD

The overall reconciliation remains a major HOLD because the 2026 solar cost,
the exact GDMTO energy rate, coordinated code implementation, and the
water-removed equivalence are unresolved.

## 21. Next steps

1. Determine the applicable 2018 base month for the historical solar cost.
2. Update 0.150 MXN/MJ through the official Mexican National Consumer Price
   Index to June 2026.
3. Extract the June 2026 GDMTO variable-energy charge applicable to
   Xochitepec.
4. Close the water-removed equivalence using identical terminal-state
   definitions, without changing equations in this phase.
5. Prepare a separate coordinated implementation PR.
6. Modify cost and CO2 together in that separately authorized PR.
7. Perform a post-implementation static review.
8. Request explicit authorization before any MATLAB execution.

No code PR is opened or authorized by this memo.
