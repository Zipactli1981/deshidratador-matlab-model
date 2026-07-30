# COST-E3: Economic-basis decision memo v96z

## 1. Purpose

COST-E3 converts the COST-E1 inventory and the COST-E2 source-validation
fiches into controlled methodological decisions about:

1. the economic reference period;
2. the exchange-rate basis;
3. the electricity-cost basis;
4. the LPG-cost basis;
5. the treatment of historical thesis values;
6. additional economic factors, including the solar cost; and
7. rules for a future, separate code implementation.

This memo does not modify code, does not change economic constants, and does
not execute MATLAB. It records verified official extractions where the
evidence is complete and uses `PENDING_OFFICIAL_EXTRACTION` or a HOLD wherever
the available evidence does not support a final numeric or scope decision.

## 2. Scope and restrictions

- no code changes;
- no MATLAB execution;
- no `gamultiobj` execution;
- no R1, R2, or R3 execution;
- no minrep execution;
- no 400-generation execution;
- no economic-factor implementation;
- no CO2-factor modification;
- no final article claims;
- no `hybrid`/`gasLP` superiority claims;
- no convergence claims;
- no global Pareto-front claims.

## 3. Status before COST-E3

| Item | Status before COST-E3 |
|---|---|
| Gate A | R1 operational PASS |
| Gate B | protocols defined |
| CO2-E4 | grid CO2 factor updated, no execution |
| COST-E1 | economic constants inventoried |
| COST-E2 | `ECONOMIC_SOURCES_INVENTORIED_NOT_FINAL_VALIDATED` |
| Economic route | `ROUTE_C_UPDATED_ARTICLE_YEAR_BASIS` |
| Historical thesis basis | `PRESERVED_FOR_TRACEABILITY` |
| Economic-factor code update | pending |
| MATLAB execution | blocked |

## 4. Decision 1: Economic reference period

ARTICLE_ECONOMIC_REFERENCE_PERIOD = JUNE_2026_LATEST_COMPLETE_MONTH

Rationale:

- June 2026 is the latest complete calendar month available before the
  COST-E3 decision.
- A complete month is preferable to a partial July 2026 cut-off.
- A common monthly basis improves consistency between exchange rate,
  electricity tariff, and LPG price.
- The choice implements Route C while preserving the historical thesis basis
  separately.

ARTICLE_ECONOMIC_REFERENCE_GEOGRAPHY = XOCHITEPEC_MORELOS_MEXICO

This geography applies whenever the official source is regional, particularly
for LPG and electricity.

## 5. Historical thesis economic basis

| Item | Historical thesis value | Unit | Role |
|---|---:|---|---|
| Exchange rate | 16.85 | MXN/USD | preserve for thesis traceability |
| Electricity cost | 0.0878338 | USD/kWh | preserve for thesis traceability |
| LPG cost | 0.0461721 | USD/MJ | preserve for thesis traceability |
| Solar/other factors | values recorded in COST-E1 | as documented | preserve for thesis traceability |

HISTORICAL_THESIS_ECONOMIC_BASIS = PRESERVED_FOR_TRACEABILITY

HISTORICAL_VALUES_NOT_SELECTED_AS_MAIN_ARTICLE_BASIS

These values must not be deleted, overwritten in the documentary record, or
presented as current article-year values. They remain available for
traceability, reproduction of thesis-era calculations, and a possible future
sensitivity comparison.

## 6. Decision 2: Exchange-rate basis

EXCHANGE_RATE_RULE = JUNE_2026_BANXICO_FIX_ARITHMETIC_MEAN

Official sources:

- [Banco de Mexico exchange-rate consultation](https://www.banxico.org.mx/tipcamb/tipCamMIAction.do?idioma=es)
- [Banco de Mexico SIE table CF102](https://www.banxico.org.mx/SieInternet/consultarDirectorioInternetAction.do?accion=consultarCuadro&idCuadro=CF102&locale=es&sector=7)

Required procedure:

1. Extract all FIX values whose determination date is between 2026-06-01 and
   2026-06-30.
2. Exclude Saturdays, Sundays, `N/E` dates, and values that are not FIX.
3. Record the observation count, arithmetic mean, minimum, maximum, first
   valid date, and last valid date.
4. Retain sufficient calculation precision and apply controlled rounding only
   for a future implementation.

Formula:

```text
TC_average_MXN_per_USD =
sum(FIX values for valid June 2026 banking days)
/
number of valid observations
```

Use:

```text
USD cost = MXN cost / TC_average_MXN_per_USD
```

The official Banxico consultation returned 22 valid FIX determination values.
The verified sum is 382.4021 MXN/USD and the resulting arithmetic mean is:

```text
382.4021 / 22 = 17.3819136364 MXN/USD
```

| Metric | Verified value |
|---|---:|
| Number of valid FIX observations | 22 |
| Arithmetic mean | 17.3819136364 MXN/USD |
| Minimum | 17.1892 MXN/USD |
| Maximum | 17.6213 MXN/USD |
| First valid date | 2026-06-01 |
| Last valid date | 2026-06-30 |

For reproducibility, the valid observations were:

| Determination date | FIX MXN/USD |
|---|---:|
| 2026-06-01 | 17.3780 |
| 2026-06-02 | 17.2945 |
| 2026-06-03 | 17.3328 |
| 2026-06-04 | 17.2888 |
| 2026-06-05 | 17.4755 |
| 2026-06-08 | 17.4453 |
| 2026-06-09 | 17.4312 |
| 2026-06-10 | 17.3898 |
| 2026-06-11 | 17.3833 |
| 2026-06-12 | 17.2067 |
| 2026-06-15 | 17.2008 |
| 2026-06-16 | 17.2023 |
| 2026-06-17 | 17.1892 |
| 2026-06-18 | 17.3688 |
| 2026-06-19 | 17.3247 |
| 2026-06-22 | 17.3480 |
| 2026-06-23 | 17.5505 |
| 2026-06-24 | 17.6213 |
| 2026-06-25 | 17.5260 |
| 2026-06-26 | 17.4700 |
| 2026-06-29 | 17.5053 |
| 2026-06-30 | 17.4693 |

ARTICLE_EXCHANGE_RATE_MXN_PER_USD = 17.3819136364

A future COST-E4 implementation may use `17.3819 MXN/USD`, rounded to the
same four-decimal precision as the official daily observations, but this memo
does not implement that value.

EXCHANGE_RATE_DECISION = USE_JUNE_2026_BANXICO_FIX_MONTHLY_MEAN

A single daily value must not replace the monthly average.

## 7. Decision 3: Electricity-cost basis

User-confirmed tariff designation:

PDMTO.

Official sources:

- [DOF tariffs applicable from 1 June 2026](https://sidof.segob.gob.mx/notas/docFuente/5791865)
- [CFE current industrial-tariff portal](https://app.cfe.mx/Aplicaciones/CCFE/Tarifas/TarifasCREIndustria/Tarifas/GranDemandaMTO.aspx)

The user clarified that the applicable tariff is PDMTO. The official sources
consulted for June 2026 did not expose an unambiguous PDMTO category,
definition, geographic mapping, or charge table. In particular, the available
CFE page identifies GDMTO, not PDMTO. This memo therefore does not substitute
GDMTO for PDMTO and does not transfer GDMTO charges to the PDMTO basis.

ELECTRICITY_TARIFF_CLASS = PDMTO

ELECTRICITY_TARIFF_CLASS_PROVENANCE = USER_CONFIRMED

ELECTRICITY_TARIFF_OFFICIAL_MAPPING = PENDING_OFFICIAL_EXTRACTION

ELECTRICITY_TARIFF_PERIOD = JUNE_2026

ELECTRICITY_TARIFF_LOCATION = APPLICABLE_CFE_REGION_OR_DIVISION_FOR_XOCHITEPEC_MORELOS

ELECTRICITY_COST_CURRENCY_CONVERSION = JUNE_2026_BANXICO_FIX_MONTHLY_MEAN

Static inspection of `build_cost_params_historical.m` and
`calc_cost_breakdown.m` confirms that the model only multiplies reconstructed
electricity consumption by one USD/kWh factor. It does not represent demand
charges, fixed monthly charges, time-of-use charges, or a complete bill.

ELECTRICITY_COST_MODEL_SCOPE = ENERGY_ONLY_VARIABLE_CHARGE

| Element | Value/status |
|---|---|
| Tariff class | PDMTO, user confirmed |
| Official category definition | PENDING_OFFICIAL_EXTRACTION |
| Previous-category equivalence | PENDING_OFFICIAL_EXTRACTION |
| CFE region/division | PENDING_OFFICIAL_EXTRACTION for the PDMTO basis |
| Month | June 2026 |
| Energy-only variable charge | PENDING_OFFICIAL_EXTRACTION |
| Demand charge | PENDING_OFFICIAL_EXTRACTION; not represented in current model |
| Fixed charge | PENDING_OFFICIAL_EXTRACTION; not represented in current model |
| Exchange rate | 17.3819136364 MXN/USD, June 2026 Banxico FIX mean |
| Resulting USD/kWh | PENDING_OFFICIAL_EXTRACTION; not implemented |

The current model scope is known, but the official PDMTO tariff mapping,
applicable June 2026 charges, geographic basis, and the article's acceptance
of an energy-only representation are not yet confirmed. Therefore:

ELECTRICITY_COST_DECISION = HOLD_FOR_PDMTO_OFFICIAL_TARIFF_AND_MODEL_SCOPE_CONFIRMATION

No GDMTO value, arbitrary full-bill average, or undocumented PDMTO value may
be substituted.

## 8. Decision 4: LPG-cost basis

LPG_PRICE_LOCATION = XOCHITEPEC_MORELOS_OR_OFFICIAL_APPLICABLE_REGION

LPG_PRICE_PERIOD = JUNE_2026

LPG_PRICE_SOURCE = CNE_MAXIMUM_CONSUMER_PRICE

LPG_PRICE_PRIMARY_UNIT = MXN_PER_KG

The mass price is preferred over MXN/L so that a density assumption is not
introduced. The five official weekly publications intersecting June 2026 were
identified and the Xochitepec row was extracted.

Official source inventory:

- [CNE LPG price publications](https://www.gob.mx/cne/articulos/precios-maximos-de-gas-lp-399035)
- [31 May to 6 June 2026](https://www.gob.mx/cms/uploads/attachment/file/1081544/PRECIOS_MA_XIMOS_VIGENTES_DEL_31_DE_MAYO_AL_06_DE_JUNIO__DE_2026.pdf)
- [7 to 13 June 2026](https://www.gob.mx/cms/uploads/attachment/file/1082786/PRECIOS_MA_XIMOS_VIGENTES_DEL_07_AL_13_DE_JUNIO_DE_2026.pdf)
- [14 to 20 June 2026](https://www.gob.mx/cms/uploads/attachment/file/1083870/PRECIOS_MA_XIMOS_VIGENTES_DEL_14_AL_20_DE_JUNIO_DE_2026.pdf)
- [21 to 27 June 2026](https://www.gob.mx/cms/uploads/attachment/file/1085056/PRECIOS_MA_XIMOS_VIGENTES_DEL_21_AL_27_DE_JUNIO_DE_2026.pdf)
- [28 June to 4 July 2026](https://www.gob.mx/cms/uploads/attachment/file/1086413/PRECIOS_MA_XIMOS_VIGENTES_DEL_28_DE_JUNIO_AL_04_DE_JULIO_DE_2026.pdf)

| Weekly validity | Applicable geography | MXN/kg | June days represented | Contribution to monthly mean |
|---|---|---:|---:|---:|
| 2026-05-31 to 2026-06-06 | Region 130, Xochitepec, Morelos | 19.56 | 6 | 3.912 |
| 2026-06-07 to 2026-06-13 | Region 130, Xochitepec, Morelos | 19.56 | 7 | 4.564 |
| 2026-06-14 to 2026-06-20 | Region 130, Xochitepec, Morelos | 19.56 | 7 | 4.564 |
| 2026-06-21 to 2026-06-27 | Region 130, Xochitepec, Morelos | 19.26 | 7 | 4.494 |
| 2026-06-28 to 2026-07-04 | Region 130, Xochitepec, Morelos | 19.26 | 3 | 1.926 |

Formula:

```text
Monthly_LPG_price_MXN_per_kg =
sum(weekly_price_i * number_of_June_days_i) / 30
```

Verified calculation:

```text
[(19.56 x 6) + (19.56 x 7) + (19.56 x 7)
 + (19.26 x 7) + (19.26 x 3)] / 30
= 19.46 MXN/kg
```

ARTICLE_MONTHLY_LPG_PRICE_MXN_PER_KG = 19.46

This verified monthly price is not sufficient by itself to produce USD/MJ.

## 9. LPG energy conversion

Preferred official source:

- [CONUEE fuel and heating-value lists](https://www.gob.mx/conuee/documentos/listas-de-combustibles-y-sus-poderes-calorificos)
- [CONUEE List of Fuels and Heating Values 2026](https://www.gob.mx/cms/uploads/attachment/file/1057719/Lista_de_Combustibles_2026.pdf)

The 2026 CONUEE list was inspected. It identifies:

| Field | Verified value/status |
|---|---|
| Exact fuel name | Gas licuado de petroleo |
| Heating-value type | poder calorifico neto |
| Verified value | 4,153 |
| Verified unit | MJ/bbl |
| List year | 2026 |
| Official source | CONUEE |

The official value is volume-based (`MJ/bbl`), while the selected CNE source
basis is mass-based (`MXN/kg`). No official density or direct CONUEE
`MJ/kg` value was verified in the inspected source. Automatically treating
4,153 MJ/bbl as MJ/kg, or converting it without an approved density basis,
would be invalid.

LPG_NET_HEATING_VALUE_MJ_PER_KG = PENDING_OFFICIAL_EXTRACTION

Required conversion after a compatible official net heating value is verified:

```text
LPG_cost_MXN_per_MJ =
Monthly_LPG_price_MXN_per_kg
/
LPG_net_heating_value_MJ_per_kg

LPG_cost_USD_per_MJ =
LPG_cost_MXN_per_MJ
/
June_2026_average_FIX_MXN_per_USD
```

| Input | Verified value/status |
|---|---|
| Monthly LPG price MXN/kg | 19.46, verified CNE weighted extraction |
| Net heating value MJ/kg | `PENDING_OFFICIAL_EXTRACTION` |
| Exchange rate MXN/USD | 17.3819136364, June 2026 Banxico FIX mean |
| Resulting LPG cost MXN/MJ | pending compatible heating value |
| Resulting LPG cost USD/MJ | pending compatible heating value |

COST-E1 also records a unit discrepancy: `calc_cost_breakdown.m` treats
`Q_aux_tot` as MJ, while EVIDENCE-E1 describes it as kWh. This must be
reconciled before a final economic implementation.

LPG_MODEL_ENERGY_UNIT_RECONCILIATION = HOLD_FOR_Q_AUX_TOT_KWH_VS_MJ

LPG_COST_DECISION = HOLD_FOR_OFFICIAL_PRICE_OR_HEATING_VALUE_EXTRACTION

The official monthly price is verified; the HOLD remains because the
compatible mass-based net heating value and model energy-unit correspondence
are unresolved.

## 10. Decision 5: Solar and additional economic factors

Static inspection of COST-E1 and the active economic functions produced:

| Factor | Historical value | Unit | Role in f(2) | Source status | COST-E3 decision |
|---|---:|---|---|---|---|
| Solar cost | 0.15 MXN/MJ; 0.00890207715133531 USD/MJ | MXN/MJ; USD/MJ | multiplies `Irradiacion` and contributes to total cost | no external source or interpretation | HOLD |
| Compressor power | 2.238 | kW | reconstructs electricity consumption from drying time | component count and rating source absent | HOLD |
| Maintenance factors | not found in COST-E1 active chain | not applicable | not represented in current f(2) trace | `NOT_FOUND_IN_STATIC_SEARCH` | no silent addition |
| Capital-cost factors | not found in COST-E1 active chain | not applicable | not represented in current f(2) trace | `NOT_FOUND_IN_STATIC_SEARCH` | no silent addition |
| Depreciation | not found in COST-E1 active chain | not applicable | not represented in current f(2) trace | `NOT_FOUND_IN_STATIC_SEARCH` | no silent addition |

The solar value must not be ignored because it directly feeds `f(2)`. It also
must not be updated silently. COST-E1 does not provide a source or a clear
methodological interpretation for the assigned solar-energy price, and the
physical basis of `Irradiacion` remains pending.

SOLAR_COST_DECISION = HOLD_FOR_SOURCE_AND_SCOPE_VALIDATION

COMPRESSOR_POWER_BASIS_DECISION = HOLD_FOR_SOURCE_VALIDATION

Because factors that feed `f(2)` remain unresolved:

ECONOMIC_BASIS_COMPLETENESS = PARTIAL_HOLD

Formal execution remains blocked.

## 11. Decision matrix

| Item | Historical thesis basis | Article Route C basis | Decision |
|---|---|---|---|
| Reference period | thesis-era | June 2026 | use June 2026 |
| Exchange rate | 16.85 MXN/USD | June 2026 Banxico FIX monthly mean: 17.3819136364 MXN/USD | update later with verified value |
| Electricity | 0.0878338 USD/kWh | PDMTO; June 2026 official mapping and charges pending | hold for PDMTO official tariff and model-scope confirmation |
| LPG | 0.0461721 USD/MJ | CNE Xochitepec/Morelos monthly price: 19.46 MXN/kg; compatible heating value pending | hold for heating value and model-unit reconciliation |
| Solar/other | historical COST-E1 values | source-based decision required | retain historically; hold article basis according to evidence |

## 12. Implementation rule

This PR does not modify code.

Any later change must be made in a separate COST-E4 PR. The future COST-E4
must:

- explicitly preserve the historical thesis values;
- implement only COST-E3 values that have an approved decision;
- update documentation and status strings;
- not execute MATLAB;
- show the exact diff for every constant; and
- require review before merge.

No partial implementation should combine the verified exchange rate with
unresolved electricity, LPG, or solar factors without a new controlled
decision.

## 13. Updated COST-E3 state

COST-E3 = ECONOMIC_BASIS_DECISION_MEMO_DOCUMENTED_NO_CODE_CHANGE

ARTICLE_ECONOMIC_BASIS = ROUTE_C_UPDATED_ARTICLE_YEAR_BASIS

ARTICLE_ECONOMIC_REFERENCE_PERIOD = JUNE_2026_LATEST_COMPLETE_MONTH

HISTORICAL_THESIS_ECONOMIC_BASIS = PRESERVED_FOR_TRACEABILITY

ECONOMIC_FACTOR_CODE_UPDATE = PENDING_SEPARATE_COST_E4_PR

FORMAL_EXECUTION = BLOCKED_PENDING_ECONOMIC_IMPLEMENTATION_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION

ECONOMIC_BASIS_COMPLETENESS = PARTIAL_HOLD

`READY_FOR_CONTROLLED_CODE_UPDATE` is not declared because the solar factor,
the compatible LPG heating-value basis, the LPG model energy unit, and the
official PDMTO mapping and applicable charges remain unresolved.

## 14. Next steps

1. Review and merge COST-E3.
2. Resolve any `PARTIAL_HOLD` items.
3. Create COST-E4 only after all factors affecting `f(2)` have a documented
   decision.
4. Preserve thesis-era values in documentation.
5. Do not execute MATLAB until COST-E4 is reviewed and explicit run
   authorization is granted.

## 15. Documentary references

- [`COST_E1_ECONOMIC_CONSTANTS_INVENTORY_v96z.md`](COST_E1_ECONOMIC_CONSTANTS_INVENTORY_v96z.md)
- [`COST_E2_ECONOMIC_SOURCE_VALIDATION_FICHES_v96z.md`](COST_E2_ECONOMIC_SOURCE_VALIDATION_FICHES_v96z.md)
- [`EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md`](EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md)
- [`CO2_E3_FACTOR_BASIS_DECISION_MEMO_v96z.md`](CO2_E3_FACTOR_BASIS_DECISION_MEMO_v96z.md)
- [`CO2_E4_GRID_FACTOR_CODE_UPDATE_v96z.md`](CO2_E4_GRID_FACTOR_CODE_UPDATE_v96z.md)
- [`GATE_B_DECISION_CURRENT_STATUS_v96z.md`](GATE_B_DECISION_CURRENT_STATUS_v96z.md)
