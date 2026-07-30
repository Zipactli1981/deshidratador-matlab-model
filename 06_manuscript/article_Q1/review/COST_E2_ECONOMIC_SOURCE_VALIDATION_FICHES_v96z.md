# COST-E2: Economic source-validation fiches v96z

## 1. Purpose

COST-E2 documents official or primary economic-source candidates for the
exchange rate, electricity cost, and LPG cost that feed
`f(2) = cost_specific_USD_per_kgwater`. It does not update code or validate
final results.

COST-E2 converts the COST-E1 inventory into fiches for sources, units,
required conversions, validation questions, and pending decisions. Locating
an official source does not establish that a current model value matches the
applicable date, tariff, region, or sale modality.

## 2. Scope and restrictions

- no code changes;
- no MATLAB execution;
- no `gamultiobj` execution;
- no R1, R2, or R3 execution;
- no minrep execution;
- no 400-generation execution;
- no economic-factor updates;
- no CO2-factor updates;
- no final article claims;
- no `hybrid`/`gasLP` superiority claims;
- no convergence claims;
- no global Pareto-front claims.

## 3. Current status before COST-E2

| Item | Status before COST-E2 |
|---|---|
| Gate A | R1 operational PASS |
| Gate B | protocols defined |
| CO2-E4 | grid CO2 factor updated, no execution |
| COST-E1 | `ECONOMIC_CONSTANTS_INVENTORIED_NO_SOURCE_VALIDATION` |
| Economic factors | unchanged and not externally validated |
| MATLAB execution | blocked |

## User-selected economic-basis route for COST-E3

The user selected Route C as the preferred economic-basis route for the article.

ROUTE_C = UPDATED_ARTICLE_YEAR_ECONOMIC_BASIS

This means that the project should not preserve the June 2022 economic basis as
the main route unless later required for sensitivity or historical comparison.

Under Route C, the economic constants should be updated together using a single
documented article-year cut-off date.

Preliminary cut-off date:
2026-07-29

This cut-off date is provisional and must be confirmed in COST-E3 before any
code update.

Implications for COST-E3:

1. Exchange rate:
   Use Banco de México / Banxico FIX for the selected cut-off date or a
   documented averaging period around that date.
   For 2026-07-29, the Banxico FIX candidate value identified is 17.5133
   MXN/USD.
   This value must be confirmed in COST-E3 before implementation.

2. Electricity cost:
   Use the current CFE tariff basis corresponding to the former OM tariff,
   preferably the current GDMTO structure if applicable.
   COST-E3 must select month, region/division, tariff class and whether a simple
   energy charge or an averaged operational cost is used.

3. LPG cost:
   Use official Government of Mexico / CNE maximum LPG prices for Morelos,
   preferably Xochitepec or the applicable LPG region, for the period closest
   to the selected cut-off date.
   COST-E3 must select whether the model uses MXN/kg or MXN/L as source basis,
   then convert to USD/MJ.

4. Historical 2022 basis:
   Values close to June 2022, OM electricity tariff and Morelos LPG prices may
   be preserved only as historical context or sensitivity, not as the primary
   article-basis route.

5. Current code values:
   Existing economic constants remain unchanged in COST-E2.
   Any update must occur only in a later COST-E4 code PR after COST-E3.

## Historical thesis economic-basis preservation note

The user clarified that the current economic constants may correspond to the
thesis-era calculations. Therefore, even though Route C was selected as the
preferred article-year economic basis, the current economic constants should
be preserved as the historical thesis economic basis for traceability and
reproducibility.

This historical basis should not be treated as the main article-year basis
unless COST-E3 explicitly changes the route. Instead, it should be preserved to
explain and reproduce thesis-era economic results.

Historical values to preserve if confirmed in COST-E1:

| Item | Historical value | Unit/status | Preservation role |
|---|---:|---|---|
| Exchange rate | 16.85 | MXN/USD, thesis-era candidate | preserve for thesis traceability |
| Electricity cost | 0.0878338 | USD/kWh, thesis-era candidate | preserve for thesis traceability |
| LPG cost | 0.0461721 | USD/MJ, thesis-era candidate | preserve for thesis traceability |

The updated article-year basis and the historical thesis basis should be kept
distinct.

- Historical thesis basis: preserved for traceability and reproducibility of
  previous thesis-era calculations.
- Updated article-year basis: selected as the main route for future
  article-oriented economic factors.
- Sensitivity or comparison: may later compare both bases if needed.

## 4. Economic constants from COST-E1

| Cost item | Current code/documented value | Unit | Location from COST-E1 | Source status before COST-E2 |
|---|---:|---|---|---|
| Exchange rate | 16.85 | MXN/USD | `build_cost_params_historical.m`, line 31 | External source and date absent |
| Electricity base price | 1.48 | MXN/kWh | `build_cost_params_historical.m`, line 33 | Tariff, region, date, and source absent |
| Electricity internal price | 1.48 / 16.85 = 0.0878338278931751 | USD/kWh | `build_cost_params_historical.m`, lines 37-39 | Derived internally; external bases not validated |
| LPG base price | 0.778 | MXN/MJ | `build_cost_params_historical.m`, line 34 | Region, modality, period, and source absent |
| LPG internal price | 0.778 / 16.85 = 0.0461721068249258 | USD/MJ | `build_cost_params_historical.m`, lines 41-43 | Derived internally; external and conversion bases not validated |
| Solar base price | 0.15 | MXN/MJ | `build_cost_params_historical.m`, line 35 | Interpretation and source absent |
| Solar internal price | 0.15 / 16.85 = 0.00890207715133531 | USD/MJ | `build_cost_params_historical.m`, lines 45-47 | Derived internally; external basis not validated |
| Compressor/electrical power | 3 × 0.746 = 2.238 | kW | `build_cost_params_historical.m`, line 49 | Component basis and source absent |
| Electricity cost | `electric_energy_kWh × C_kWh_internal` | USD | `detail.cost` via `calc_cost_breakdown.m`, lines 48-50 | Formula traced; factor basis pending |
| LPG cost | `Q_aux_tot × C_esp_GLP_internal` | USD | `detail.cost` via `calc_cost_breakdown.m`, lines 52-54 | Formula traced; energy-unit basis pending |
| Solar cost | `Irradiacion × C_solar_internal` | USD | `detail.cost` via `calc_cost_breakdown.m`, lines 56-58 | Formula traced; physical/economic basis pending |
| Specific cost | `total_cost_USD / water_removed_kg` | USD/kg water | `detail.cost` via `calc_cost_breakdown.m`, lines 60-70 | Direct source of `f(2)` |

The rounded strings `0.0878338` and `0.0461721` were
`NOT_FOUND_IN_COST_E1_STATIC_SEARCH` as literals; COST-E1 reproduced them from
the documented divisions shown above.

## 5. COST-E2-F1: Exchange-rate fiche

Current value from COST-E1: 16.85 MXN/USD.

Candidate official source:
[Banco de México, Sistema de Información Económica, cuadro CF102](https://www.banxico.org.mx/SieInternet/consultarDirectorioInternetAction.do?accion=consultarCuadro&idCuadro=CF102&locale=es&sector=7).

The official table identifies daily exchange-rate series in pesos per dollar
and distinguishes the FIX determination date. The required basis is a specific
date or a predeclared averaging period.

Validation question: does 16.85 match a specific Banxico FIX date or a
documented average that is appropriate for the study?

Required conversion:

`MXN cost / (MXN per USD) = USD cost`

Decision categories:

- `VALIDATED_IF_DATE_MATCHES_BANXICO_FIX`;
- `HOLD_FOR_DATE_BASIS_DECISION`;
- `REPLACE_CANDIDATE_IF_VALUE_UNTRACED`.

Because COST-E1 does not associate 16.85 with a specific date or period:

`EXCHANGE_RATE_DECISION = HOLD_FOR_DATE_BASIS_DECISION`

Do not update code.

## 6. COST-E2-F2: Electricity-cost fiche

Current values from COST-E1:

- 1.48 MXN/kWh;
- 0.0878338278931751 USD/kWh after division by 16.85 MXN/USD.

Candidate official sources:

- [CFE business tariff portal](https://app.cfe.mx/Aplicaciones/CCFE/Tarifas/TarifasCRENegocio/Negocio.aspx);
- [CFE Gran Demanda Media Tensión Ordinaria](https://app.cfe.mx/Aplicaciones/CCFE/Tarifas/TarifasCREIndustria/Tarifas/GranDemandaMTO.aspx);
- [CFE Gran Demanda Media Tensión Horaria](https://app.cfe.mx/Aplicaciones/CCFE/Tarifas/TarifasCRENegocio/Tarifas/GranDemandaMTH.aspx);
- [DOF tariffs applicable from 1 March 2026](https://sidof.segob.gob.mx/notas/docFuente/5784039);
- [DOF tariffs applicable from 1 June 2026](https://sidof.segob.gob.mx/notas/docFuente/5791865).

The model unit is USD/kWh. The likely official source unit is MXN/kWh, but the
applicable total may depend on tariff class, month, region/division, demand
category, and multiple tariff components. The project must decide whether the
model uses an average energy price or a time-dependent tariff.

Required conversion:

`official MXN/kWh / selected MXN/USD = USD/kWh`

Validation question: does the current value match an official CFE tariff,
including its class, month, region/division, components, and the selected
Banxico exchange-rate basis?

Decision categories:

- `VALIDATED_IF_TARIFF_AND_DATE_MATCH`;
- `HOLD_FOR_TARIFF_CLASS_PERIOD_DECISION`;
- `REPLACE_CANDIDATE_IF_VALUE_UNTRACED`.

No tariff class or period is explicit in COST-E1:

`ELECTRICITY_COST_DECISION = HOLD_FOR_TARIFF_CLASS_PERIOD_DECISION`

The DOF notices are relevant normative support in addition to the operational
CFE portal because they publish final basic-supply tariffs and their
application periods. The applicable notice and tariff table remain pending.

Do not update code.

## 7. COST-E2-F3: LPG-cost fiche

Current values from COST-E1:

- 0.778 MXN/MJ;
- 0.0461721068249258 USD/MJ after division by 16.85 MXN/USD.

Candidate official sources:

- [CNE maximum applicable LPG prices, documents](https://www.gob.mx/cne/documentos/precios-maximos-aplicables-de-gas-lp-399897);
- [CNE maximum applicable LPG prices, article and current publications](https://www.gob.mx/cne/articulos/precios-maximos-de-gas-lp-399035).

The CNE inventory publishes maximum final-consumer LPG prices by region and
sale modality for defined weekly periods. The model unit is USD/MJ; official
tables are expected in MXN/kg and/or MXN/L.

Required basis:

- region and municipality;
- week or other applicable period;
- sale modality;
- preferably Xochitepec, Morelos, if the article represents the Xochitepec
  drying plant.

Required conversion paths:

Path A, mass-based price:

`MXN/kg GLP -> MXN/MJ -> USD/MJ`

Path B, volume-based price:

`MXN/L GLP -> MXN/MJ -> USD/MJ`

Additional physical constants required:

- lower or higher heating value of LPG, consistent with the model convention;
- LPG density when the official price is in MXN/L;
- the selected Banxico exchange rate.

Validation question: does the current code value match an official LPG price,
the selected region/period/modality, a controlled energy conversion, and the
selected Banxico exchange-rate basis?

Decision categories:

- `VALIDATED_IF_REGION_PERIOD_MODALITY_AND_CONVERSIONS_MATCH`;
- `HOLD_FOR_REGION_PERIOD_MODALITY_DECISION`;
- `REPLACE_CANDIDATE_IF_VALUE_UNTRACED`.

The required region, period, modality, heating value, density, and exchange
rate are not jointly explicit:

`LPG_COST_DECISION = HOLD_FOR_REGION_PERIOD_MODALITY_AND_CONVERSION_DECISION`

Do not update code.

## 8. COST-E2-F4: Additional economic factor fiche

### Solar-energy cost

- Current value: 0.15 MXN/MJ, converted internally to
  0.00890207715133531 USD/MJ.
- Code location: `build_cost_params_historical.m`, lines 35 and 45-47.
- Source status: no external source or interpretation is documented.
- Physical-basis caveat: COST-E1 records that the unit of `Irradiacion`
  requires confirmation.
- Decision: `HOLD_FOR_SOURCE_VALIDATION`.

### Compressor/electrical power

- Current value: 2.238 kW, defined as `3 × 0.746`.
- Code location: `build_cost_params_historical.m`, line 49.
- Source status: the component count, rating basis, and source are absent.
- Cost role: multiplies drying time to reconstruct electrical energy.
- Decision: `HOLD_FOR_SOURCE_VALIDATION`.

## 9. Conversion requirements table

| Conversion | Required inputs | Current status |
|---|---|---|
| MXN to USD | Banxico FIX date or period | pending |
| MXN/kWh to USD/kWh | CFE tariff + Banxico FIX | pending |
| MXN/kg GLP to USD/MJ | LPG price, heating value, Banxico FIX | pending |
| MXN/L GLP to USD/MJ | LPG price, density, heating value, Banxico FIX | pending |

## 10. Risk assessment

- Economic factors are time-sensitive.
- The exchange rate requires a date or averaging rule.
- The LPG price requires a region, period, and sale modality.
- The electricity price requires a tariff class, month, and region/division.
- Updating economic constants can change `f(2)`, Pareto ranking, and selected
  solutions.
- No final economic comparison should be claimed until COST-E3 and any needed
  COST-E4 are complete.
- The physical unit of `Q_aux_tot` and `Irradiacion` must be reconciled with
  the cost calculation before validating unit conversions.

## 11. Decision matrix

| Factor | Current status | Official source candidate | COST-E2 finding | Decision |
|---|---|---|---|---|
| Exchange rate | 16.85 MXN/USD from COST-E1 | Banxico FIX | Source located; date basis pending | `HOLD_FOR_DATE_BASIS_DECISION` |
| Electricity cost | 1.48 MXN/kWh; derived 0.0878338278931751 USD/kWh | CFE / DOF | Source located; tariff class and period pending | `HOLD_FOR_TARIFF_CLASS_PERIOD_DECISION` |
| LPG cost | 0.778 MXN/MJ; derived 0.0461721068249258 USD/MJ | CNE Gas LP prices | Source located; region, period, modality, and conversion pending | `HOLD_FOR_REGION_PERIOD_MODALITY_AND_CONVERSION_DECISION` |
| Solar cost | 0.15 MXN/MJ; derived 0.00890207715133531 USD/MJ | Not selected | Source and physical basis pending | `HOLD_FOR_SOURCE_VALIDATION` |
| Compressor/electrical power | 2.238 kW | Not selected | Component basis and source pending | `HOLD_FOR_SOURCE_VALIDATION` |

## 12. Current COST-E2 state

COST-E2 = ECONOMIC_SOURCES_INVENTORIED_NOT_FINAL_VALIDATED

ECONOMIC_ROUTE_SELECTED_FOR_COST_E3 = ROUTE_C_UPDATED_ARTICLE_YEAR_BASIS

ECONOMIC_CUTOFF_DATE_CANDIDATE = 2026-07-29

HISTORICAL_2022_BASIS = NOT_PRIMARY_ROUTE_UNLESS_USED_FOR_SENSITIVITY

HISTORICAL_THESIS_ECONOMIC_BASIS = PRESERVED_FOR_TRACEABILITY

ARTICLE_ECONOMIC_BASIS = ROUTE_C_UPDATED_ARTICLE_YEAR_BASIS

HISTORICAL_VALUES_NOT_SELECTED_AS_MAIN_ARTICLE_BASIS

ECONOMIC_FACTOR_UPDATE = PENDING_COST_E3_DECISION_MEMO

FORMAL_EXECUTION = STILL_BLOCKED_PENDING_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION

## 13. Next steps

1. COST-E3: decide economic-basis rules.
2. For the exchange rate, select a date or averaging period.
3. For electricity, select a tariff class, month, and region/division.
4. For LPG, select a region, period, sale modality, heating value, and
   exchange-rate basis.
5. COST-E4: create a controlled code update only if required.
6. Do not run MATLAB until the economic-factor basis is resolved or explicitly
   waived.
