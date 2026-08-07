# COST-E3D-R2A: Solar-cost June 2026 INPC monetary restatement memo v96z

## 1. Purpose

This memo closes, at the documentary level only, the June 2026 monetary restatement of the historical thesis-selected solar thermal cost:

`THESIS_SELECTED_SOLAR_COST = 0.150_MXN_PER_MJ`

The historical Mexican-peso value is restated with official Mexican National Consumer Price Index (INPC) data and then converted to United States dollars with the June 2026 Banco de México FIX mean already documented in COST-E3.

This is a general-price-level monetary restatement of a historical levelized thermal-energy cost. It is not a new plant-specific levelized-cost calculation, commercial tariff, marginal cost, current vendor quotation, or technology-specific escalation.

## 2. Scope and restrictions

COST-E3D-R2A is documentation only. It:

- makes no MATLAB code, objective-function, wrapper, runner, configuration, constant, or CO2-factor change;
- does not implement the restated solar cost;
- does not reconstruct plant-specific CAPEX, OPEX, lifetime, discount rate, or energy yield;
- does not select the preliminary `0.7518 MXN/MJ` alternative;
- does not execute MATLAB, `gamultiobj`, R1, R2, R3, `minrep`, or a 400-generation run;
- creates no MAT file, result, figure, or PDF;
- does not recalculate `f(2)`, `f(3)`, or R1;
- does not validate final article results, convergence, reproducibility, hybrid/gasLP superiority, or a global Pareto front; and
- does not authorize formal execution or a code implementation PR.

## 3. Evidence base

| Source | Status | Evidence used | Reference period | Limitation |
|---|---|---|---|---|
| Fused local COST-E1, COST-E2, COST-E3, COST-E3D-R1, and COST-E3D-R2D documents | FOUND / INSPECTED | Historical solar value and range, thesis exchange rate, Route C, June 2026 FIX, active HOLDs, and canonical-denominator decision | Thesis era through June 2026 | Documentary chain; no new execution |
| CONUEE/ANES/GIZ, *Energía solar térmica para procesos industriales en México. Estudio base de mercado* ([official GIZ PDF](https://www.giz.de/en/downloads/EnergiaSolarTermica_02_LOWRES.pdf)) | OFFICIAL_REPORT_VERIFIED | Publication page; Section 4.4.1 and pp. 91-94: 130-285 MXN/GJ range and LCOE method | Published May 2018 | Exact underlying price month of the general solar-cost range is not explicitly identified |
| INEGI/DOF historical rebased INPC series ([DOF notice](https://www.dof.gob.mx/nota_detalle_popup.php?codigo=5538666)) | OFFICIAL_HISTORICAL_SERIES_VERIFIED | 2018 monthly table: May = 98.994080173087; base second half of July 2018 = 100 | May 2018 | Publication-month proxy is a methodological decision, not a source claim about the price month |
| INEGI, INPC June 2026, Indicator Bulletin 417/26 ([official bulletin](https://www.inegi.org.mx/contenidos/saladeprensa/boletines/2026/inpc/inpc_2q2026_07.pdf)) | OFFICIAL_DEFINITIVE_MONTHLY_INDEX_VERIFIED | Page 1: June 2026 monthly index = 145.131 | June 2026 | General consumer-price index, not a solar-technology cost index |
| `COST_E3_ECONOMIC_BASIS_DECISION_MEMO_v96z.md` and `COST_E3D_R1_TECHNICAL_RESOLUTION_MEMO_v96z.md` | FOUND / INSPECTED | `BANXICO_FIX_JUNE_2026_MEAN = 17.3819136364_MXN_PER_USD` | June 2026 | Previously fused value retained without selecting another currency basis |
| Express model-owner decisions for COST-E3D-R2A | CONFIRMED | Preserve 0.150 MXN/MJ as the thesis selection; use May 2018 publication month as transparent proxy; apply INPC first in MXN and June 2026 FIX second | May 2018 proxy to June 2026 | Documentary authorization only; no code implementation |
| Independently reproduced arithmetic in this memo | VERIFIED | INPC factor, cumulative change, selected-cost update, range update, and FIX conversion | May 2018 to June 2026 | Derived values depend on the selected publication-month proxy |
| Active MATLAB cost chain | STATICALLY INSPECTED | `Irradiacion` accumulation, `solar_energy_MJ`, `solar_cost_USD`, `total_cost_USD`, and path to `f(2)` | Repository baseline `89f0c72` | Static inspection only; activity-boundary compatibility remains partial |

No external PDF was added to the repository.

## 4. Historical solar-cost basis

The fused documentary chain preserves:

`SOLAR_COST_HISTORICAL_BASIS = TRACEABLE_LEVELIZED_COST_OF_THERMAL_ENERGY`

`SOLAR_COST_SOURCE_RANGE_2018 = 0.130_TO_0.285_MXN_PER_MJ`

`THESIS_SELECTED_SOLAR_COST = 0.150_MXN_PER_MJ`

`THESIS_EXCHANGE_RATE = 16.85_MXN_PER_USD`

`THESIS_SOLAR_COST_USD = 0.0089021_USD_PER_MJ`

Independent confirmation of the historical conversion is:

```text
0.150 MXN/MJ / 16.85 MXN/USD
= 0.00890207715133531 USD/MJ
approximately 0.0089021 USD/MJ
```

The selected `0.150 MXN/MJ` lies inside and near the lower bound of the published `0.130-0.285 MXN/MJ` range. It is a thesis selection within that range; it is not presented as a unique value quoted by the external report.

## 5. Source report and temporal-basis limitation

The official report identifies CONUEE, ANES, and GIZ and states on its publication page:

`SOURCE_REPORT_PUBLICATION = MAY_2018`

`SOURCE_REPORT_PUBLICATION_MONTH = MAY_2018`

Pages 91-92 report that levelized energy costs for solar thermal projects were generally estimated in a range of `130-285 MXN/GJ`, equivalent to `0.130-0.285 MXN/MJ`. Section 4.4.1 and pages 92-94 identify the source terminology as LCOE for thermal generation and describe a life-cycle metric containing initial project cost, fixed and variable O&M, annual generated thermal energy, a discount/reference rate, and years of use.

The report does not assign one explicit original price month to the general `130-285 MXN/GJ` range. Some surrounding comparative inputs have their own periods, including April 2017 gas-price information, but that does not establish April 2017 as the price month of the general solar range.

`SOLAR_COST_EXACT_ORIGINAL_PRICE_MONTH = NOT_EXPLICITLY_IDENTIFIED`

The statement “the solar cost is a May 2018 price” is therefore not adopted.

`THE_SOLAR_COST_IS_A_MAY_2018_MARKET_PRICE = PROHIBITED`

## 6. INPC base-period decision

May 2018 is selected as a transparent and reproducible publication-month proxy because:

- the report is dated May 2018;
- no single explicit month is assigned to the underlying general solar-cost range;
- a reproducible temporal reference is required for monetary restatement; and
- the publication month is the most transparent documented proxy available.

This is a methodological assumption, not a textual source datum about when every technical or economic input was priced.

`SOLAR_COST_INPC_BASE_PERIOD = MAY_2018`

`SOLAR_COST_INPC_BASE_PERIOD_STATUS = TRANSPARENT_PUBLICATION_MONTH_PROXY`

`SOLAR_COST_INPC_BASE_PERIOD_LIMITATION = EXACT_UNDERLYING_COST_PRICE_MONTH_NOT_EXPLICITLY_IDENTIFIED`

January 2018, annual-average 2018, December 2018, the second half of July 2018, the PDF hosting date, and the web-access date are not selected as the economic base period.

## 7. INPC source and target indices

The official INEGI/DOF rebased historical table records:

`INPC_SOURCE_INDEX = 98.994080173087`

`INPC_SOURCE_PERIOD = MAY_2018`

`INPC_SOURCE_INDEX_STATUS = OFFICIAL_HISTORICAL_SERIES`

`INPC_SOURCE_INDEX_REFERENCE = INEGI_DOF_HISTORICAL_REBASED_SERIES`

`INPC_BASE = SECOND_HALF_OF_JULY_2018_EQUALS_100`

INEGI Indicator Bulletin 417/26, published 9 July 2026, records the definitive monthly June index:

`INPC_TARGET_INDEX = 145.131`

`INPC_TARGET_PERIOD = JUNE_2026`

`INPC_TARGET_INDEX_STATUS = OFFICIAL_DEFINITIVE_MONTHLY_INDEX`

Both indices use the same official base and are suitable for the selected general monetary-restatement calculation.

## 8. Monetary-restatement calculation

The update factor is independently recalculated:

```text
INPC_UPDATE_FACTOR
= INPC_JUNE_2026 / INPC_MAY_2018
= 145.131 / 98.994080173087
= 1.4660573616750066
```

The cumulative general-price-level change is:

```text
INPC_CUMULATIVE_CHANGE
= (1.4660573616750066 - 1) * 100
= 46.6057361675007 percent
```

`INPC_UPDATE_FACTOR = 1.4660573616750066`

`INPC_CUMULATIVE_CHANGE = 46.6057361675007_PERCENT`

## 9. Updated selected solar cost in MXN

```text
SOLAR_COST_JUNE_2026_MXN_PER_MJ
= 0.150 * 1.4660573616750066
= 0.219908604251251 MXN/MJ
```

`SOLAR_COST_HISTORICAL_MXN_PER_MJ = 0.150`

`SOLAR_COST_JUNE_2026_MXN_PER_MJ = 0.219908604251251`

The full traceable value is retained. `0.2199 MXN/MJ` or `0.220 MXN/MJ` may be used only as a clearly rounded presentation value.

## 10. June 2026 conversion to USD

The required sequence is:

```text
HISTORICAL_MXN_COST
    -> INPC_MONETARY_RESTATEMENT
    -> JUNE_2026_MXN_COST
    -> JUNE_2026_FIX
    -> JUNE_2026_USD_COST
```

The already fused FIX mean is retained:

`BANXICO_FIX_JUNE_2026_MEAN = 17.3819136364_MXN_PER_USD`

```text
SOLAR_COST_JUNE_2026_USD_PER_MJ
= 0.219908604251251 / 17.3819136364
= 0.0126515761642454 USD/MJ
```

`SOLAR_COST_HISTORICAL_USD_PER_MJ = 0.0089021`

`SOLAR_COST_JUNE_2026_USD_PER_MJ = 0.0126515761642454`

`SOLAR_COST_UPDATE_CURRENCY_SEQUENCE = UPDATE_MXN_FIRST_THEN_CONVERT_WITH_JUNE_2026_FIX`

The historical USD value is not multiplied directly by the INPC factor as the primary method because INPC restates the Mexican-peso price; conversion to USD belongs after restatement and uses the target-period FIX.

## 11. Updated historical range

The historical range is restated uniformly for sensitivity traceability:

```text
LOW_MXN  = 0.130 * 1.4660573616750066
         = 0.190587457017751 MXN/MJ

HIGH_MXN = 0.285 * 1.4660573616750066
         = 0.417826348077377 MXN/MJ
```

`SOLAR_COST_SOURCE_RANGE_JUNE_2026_MXN = 0.190587457017751_TO_0.417826348077377_MXN_PER_MJ`

Using the June 2026 FIX:

```text
LOW_USD  = 0.190587457017751 / 17.3819136364
         = 0.0109646993423460 USD/MJ

HIGH_USD = 0.417826348077377 / 17.3819136364
         = 0.0240379947120663 USD/MJ
```

`SOLAR_COST_SOURCE_RANGE_JUNE_2026_USD = 0.0109646993423460_TO_0.0240379947120663_USD_PER_MJ`

Uniform INPC restatement preserves the relative position of the selected `0.150 MXN/MJ` value within the historical range.

## 12. Static audit of solar-energy activity basis

| Variable | File | Meaning | Unit | Energy boundary | Used in cost? | Certainty |
|---|---|---|---|---|---|---|
| `I(i)` | `02_src_limpio/wrappers/opt_tunel_mod2_v18_endpoint_TMAX_corrected.m:196` | Effective solar irradiance input | W/m2 | Incident irradiance after mode selection | Indirectly | CONFIRMED |
| `A_cap` | same wrapper, line 215 | Capture area per configured battery (`2.5 * serie`) | m2 | Collector aperture/configuration input | Indirectly | CONFIRMED |
| `ETHA_capt(i)` | same wrapper, lines 219-221 | Collector capture efficiency | dimensionless | Incident-to-captured conversion | Indirectly | CONFIRMED |
| `E_capt(i)` | same wrapper, line 223 | Instantaneous captured solar thermal power | kW thermal by dimensional derivation | Captured at the solar air-heater contribution | Indirectly through accumulated energy | CONSISTENT_WITH_STATIC_INFERENCE |
| `Irradiacion` | same wrapper, lines 457 and 485 | Time-integrated irradiance times area, eight-unit configuration, and mean capture efficiency | MJ | Accumulated captured solar energy to the modeled air-heating system | Yes, passed to cost | CONSISTENT_WITH_STATIC_INFERENCE |
| `solar_energy_MJ` | `02_src_limpio/cost/calc_cost_breakdown.m:56` | Direct alias of `Irradiacion` | MJ | Same accumulated captured-energy boundary | Yes | CONFIRMED |
| `solar_cost_USD` | same cost file, lines 57-58 | `solar_energy_MJ * C_solar_internal` | USD | Economic solar term | Yes | CONFIRMED |
| `total_cost_USD` | same cost file, lines 60-61 | Electric + LPG + solar cost | USD | Economic numerator | Yes | CONFIRMED |
| `cost_specific_USD_per_kgwater` | same cost file, lines 69-70; active base objective lines 100-117 | Total cost divided by water removed | USD/kg water | `f(2)` | Yes, direct objective | CONFIRMED |

The code labels and dimensional arithmetic support an accumulated captured solar-energy interpretation. However, the external LCOE denominator is generated thermal energy, and the static evidence does not fully demonstrate that `Irradiacion` has exactly the same delivered/useful-energy boundary under every modeled cap, recirculation, and endpoint condition. The `A_cap * 8` configuration also remains an implementation-review item.

`SOLAR_ENERGY_ACTIVITY_VARIABLE = IRRADIACION`

`SOLAR_ENERGY_ACTIVITY_UNIT = MJ`

`SOLAR_ENERGY_ACTIVITY_PHYSICAL_BOUNDARY = ACCUMULATED_CAPTURED_SOLAR_ENERGY_TO_MODELED_AIR_HEATING_SYSTEM`

`SOLAR_ENERGY_ACTIVITY_BASIS = PARTIALLY_RECONCILED`

## 13. Methodological interpretation

`SOLAR_COST_UPDATE_METHOD = GENERAL_INPC_MONETARY_RESTATEMENT`

`SOLAR_COST_UPDATED_METRIC = INFLATION_RESTATED_HISTORICAL_LEVELIZED_COST_OF_THERMAL_ENERGY`

`SOLAR_COST_2026_INTERPRETATION = ARTICLE_ECONOMIC_PROXY_BASED_ON_HISTORICAL_LEVELIZED_THERMAL_COST`

`SOLAR_COST_2026_EXCLUDED_INTERPRETATIONS = PLANT_SPECIFIC_RECALCULATED_LCOE;COMMERCIAL_TARIFF;SHORT_RUN_MARGINAL_COST;CURRENT_VENDOR_QUOTATION`

The source terminology remains LCOE (*costo nivelado de energía*) applied to thermal generation. “Levelized cost of thermal energy” is used here as an explanatory English rendering without silently replacing the source metric with another methodology.

## 14. Limitations

`SOLAR_COST_2026_LIMITATION = GENERAL_PRICE_LEVEL_UPDATE_NOT_TECHNOLOGY_SPECIFIC_ESCALATION`

INPC measures general changes in consumer prices. It is not a solar-thermal technology index and does not directly represent:

- collector prices;
- steel, pumps, or insulation prices;
- industrial installation costs;
- solar-specific O&M or financing costs;
- technology learning or economies of scale;
- a changed discount rate or useful life;
- site irradiation changes; or
- reconstructed Xochitepec CAPEX, OPEX, or energy yield.

The second limitation is temporal: May 2018 is a reproducible publication-month proxy, not a claim that all economic inputs in the report correspond exactly to May 2018.

## 15. Decision alternatives

### Alternative A: retain nominal 0.150 MXN/MJ

`STATUS = REJECTED_FOR_ROUTE_C`

`REASON = MIXES_HISTORICAL_NOMINAL_SOLAR_COST_WITH_JUNE_2026_PRICE_BASIS`

### Alternative B: restate with INPC using May 2018 as proxy

`STATUS = SELECTED`

`REASON = TRANSPARENT_REPRODUCIBLE_OFFICIAL_MONETARY_RESTATEMENT`

### Alternative C: reconstruct plant-specific thermal LCOE

`STATUS = NOT_SELECTED_FOR_CURRENT_IMPLEMENTATION`

`REASON = REQUIRES_SEPARATE_CAPEX_OPEX_LIFETIME_DISCOUNT_RATE_AND_ENERGY_YIELD_MODEL`

### Alternative D: use preliminary 0.7518 MXN/MJ

`STATUS = REJECTED`

`REASON = NOT_THE_SELECTED_HISTORICAL_MODEL_METHOD_AND_NOT_FULLY_RECONCILED`

## 16. Consequences for future f(2)

The documentary monetary factor is resolved, but code implementation remains pending. Because the solar-energy activity basis is only partially reconciled, this memo does not adopt the following multiplication as final code behavior.

Subject to closure of the activity-boundary review, the future candidate relation is:

```text
solar_cost_USD
= Q_solar_MJ * 0.0126515761642454 USD/MJ
```

In the current chain, the candidate `Q_solar_MJ` maps to `Irradiacion`/`solar_energy_MJ`, but compatibility with the levelized generated/delivered thermal-energy boundary must be confirmed during coordinated implementation design.

`SOLAR_COST_FACTOR_IMPLEMENTATION = PENDING_COORDINATED_CODE_PR`

`F2_SOLAR_ACTIVITY_MULTIPLICATION = CONDITIONAL_PENDING_ACTIVITY_BOUNDARY_REVIEW`

`SOLAR_COST_FACTOR = RESOLVED`

`SOLAR_ACTIVITY_BOUNDARY = PARTIALLY_RECONCILED`

No current `f(2)` value is final or recalculated by COST-E3D-R2A.

## 17. Consequences for R1

R1 remains a valid Gate A operational test. Its pre-implementation economic and environmental values remain methodologically provisional.

`R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST`

`R1_ECONOMIC_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL`

`R1_ENVIRONMENTAL_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL`

`R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL`

`R1_F2_F3_RECALCULATION = REQUIRED_AFTER_COORDINATED_IMPLEMENTATION`

`COST_E3D_FINDINGS_DO_NOT_INVALIDATE_R1_OPERATIONAL_RECORD`

R1 was not recalculated.

## 18. Findings and decisions

| ID | Classification | Decision or finding | Evidence | Consequence | Status |
|---|---|---|---|---|---|
| COST-E3D-R2A-D01 | TEMPORAL-PROXY DECISION | Use May 2018 publication month as the INPC base proxy | Report publication page and absence of an explicit underlying price month | Reproducible base with explicit limitation | SELECTED |
| COST-E3D-R2A-D02 | MONETARY METHOD DECISION | Restate the historical MXN cost with official INPC | INEGI/DOF May 2018 and INEGI June 2026 indices | General-price-level update only | ADOPTED |
| COST-E3D-R2A-D03 | CURRENCY-SEQUENCE DECISION | Update MXN first, then convert with June 2026 FIX | Route C and currency dimensional consistency | Produces target-period USD/MJ | ADOPTED |
| COST-E3D-R2A-D04 | INTERPRETATION DECISION | Classify the value as an inflation-restated historical levelized thermal-energy proxy | Source LCOE method and owner decision | Excludes plant-specific and market-price claims | ADOPTED |
| COST-E3D-R2A-D05 | ALTERNATIVE DECISION | Reject 0.7518 MXN/MJ for this route | Not the selected historical method and not fully reconciled | Prevents method substitution | REJECTED |
| COST-E3D-R2A-F01 | SOURCE FINDING | Report published in Mexico City in May 2018 | Official report publication page | Establishes proxy candidate, not original price month | VERIFIED |
| COST-E3D-R2A-F02 | RANGE FINDING | Report gives approximately 130-285 MXN/GJ | Report pp. 91-92 | Equivalent to 0.130-0.285 MXN/MJ | VERIFIED |
| COST-E3D-R2A-F03 | ARITHMETIC FINDING | Selected restated value is 0.219908604251251 MXN/MJ and 0.0126515761642454 USD/MJ | Independently reproduced arithmetic | Monetary factor resolved documentarily | VERIFIED |
| COST-E3D-R2A-F04 | STATIC FINDING | `Irradiacion` is accumulated captured solar energy in MJ and enters `f(2)` through `solar_cost_USD` | Wrapper, cost parameters, cost breakdown, and active objective | Code path and unit are traceable | VERIFIED |
| COST-E3D-R2A-H01 | ACTIVITY-BOUNDARY HOLD | Exact compatibility between captured `Irradiacion` and source LCOE generated/delivered thermal-energy boundary is not fully established | Static audit and source LCOE definition | Review required before final multiplication | OPEN |
| COST-E3D-R2A-H02 | GDMTO HOLD | Exact June 2026 GDMTO rate remains pending | COST-E3D-R1 | Cost basis remains incomplete | OPEN |
| COST-E3D-R2A-H03 | IMPLEMENTATION HOLD | Monetary factor and canonical denominator are not implemented | Current repository state | Existing `f(2)` remains provisional | OPEN |

## 19. Current COST-E3D-R2A state

`COST-E3D-R2A = SOLAR_INPC_MONETARY_RESTATEMENT_DOCUMENTED_NO_CODE_CHANGE`

`SOLAR_COST_HISTORICAL_MXN_PER_MJ = 0.150`

`SOLAR_COST_HISTORICAL_USD_PER_MJ = 0.0089021`

`SOURCE_REPORT_PUBLICATION_MONTH = MAY_2018`

`SOLAR_COST_EXACT_ORIGINAL_PRICE_MONTH = NOT_EXPLICITLY_IDENTIFIED`

`SOLAR_COST_INPC_BASE_PERIOD = MAY_2018`

`SOLAR_COST_INPC_BASE_PERIOD_STATUS = TRANSPARENT_PUBLICATION_MONTH_PROXY`

`INPC_SOURCE_INDEX = 98.994080173087`

`INPC_SOURCE_PERIOD = MAY_2018`

`INPC_TARGET_INDEX = 145.131`

`INPC_TARGET_PERIOD = JUNE_2026`

`INPC_UPDATE_FACTOR = 1.4660573616750066`

`INPC_CUMULATIVE_CHANGE = 46.6057361675007_PERCENT`

`SOLAR_COST_JUNE_2026_MXN_PER_MJ = 0.219908604251251`

`BANXICO_FIX_JUNE_2026_MEAN = 17.3819136364_MXN_PER_USD`

`SOLAR_COST_JUNE_2026_USD_PER_MJ = 0.0126515761642454`

`SOLAR_COST_SOURCE_RANGE_JUNE_2026_MXN = 0.190587457017751_TO_0.417826348077377_MXN_PER_MJ`

`SOLAR_COST_SOURCE_RANGE_JUNE_2026_USD = 0.0109646993423460_TO_0.0240379947120663_USD_PER_MJ`

`SOLAR_COST_UPDATE_METHOD = GENERAL_INPC_MONETARY_RESTATEMENT`

`SOLAR_COST_UPDATED_METRIC = INFLATION_RESTATED_HISTORICAL_LEVELIZED_COST_OF_THERMAL_ENERGY`

`SOLAR_COST_2026_INTERPRETATION = ARTICLE_ECONOMIC_PROXY_BASED_ON_HISTORICAL_LEVELIZED_THERMAL_COST`

`SOLAR_COST_2026_LIMITATION = GENERAL_PRICE_LEVEL_UPDATE_NOT_TECHNOLOGY_SPECIFIC_ESCALATION`

`SOLAR_ENERGY_ACTIVITY_BASIS = PARTIALLY_RECONCILED`

`SOLAR_COST_2026_STATUS = RESOLVED_DOCUMENTALLY_PENDING_CODE_IMPLEMENTATION`

`WATER_REMOVED_DENOMINATOR_DECISION = RESOLVED_DOCUMENTALLY`

`WATER_REMOVED_DENOMINATOR_IMPLEMENTATION = PENDING_SEPARATE_CODE_PR`

`ENERGY_COST_RECONCILIATION = MAJOR_HOLD`

`COST_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_GDMTO_AND_IMPLEMENTATION`

`ECONOMIC_FACTOR_CODE_UPDATE = BLOCKED_PENDING_GDMTO_AND_COORDINATED_IMPLEMENTATION_PR`

`FORMAL_EXECUTION = BLOCKED_PENDING_ECONOMIC_IMPLEMENTATION_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION`

## 20. Remaining holds

1. Extract the exact June 2026 GDMTO rate applicable to Xochitepec.
2. Implement the canonical `water_removed_kg` denominator.
3. Implement the restated solar cost.
4. Implement the documented LPG chain.
5. Implement the electricity and CO2 chains.
6. Resolve the remaining compatibility question for the `Irradiacion` solar-energy activity boundary.
7. Perform post-implementation static review.
8. Obtain explicit authorization for a minimal test.
9. Recalculate `f(2)`, `f(3)`, and R1 after coordinated implementation.

## 21. Next steps

1. Review and merge COST-E3D-R2A.
2. Perform COST-E3D-R2B for the exact June 2026 GDMTO basis.
3. Prepare one coordinated implementation pull request.
4. Resolve the remaining `Q_solar` boundary issue in that design.
5. Use `water_removed_kg` as the common denominator.
6. Statically review units and boundaries.
7. Request explicit authorization before any MATLAB execution.

No code PR is created or authorized by this memo.
