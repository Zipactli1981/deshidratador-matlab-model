# CO2-E2: Factor validation fiches v96z

## 1. Purpose

This document inventories official sources for the emission factors currently
used by the tri-objective CO2 objective. It does not validate final results and
does not change the code.

CO2-E2 only documents candidate sources, unit conversions, and pending
decisions. It is a preliminary source-validation record, not authorization to
adopt or publish either factor as final.

## 2. Scope and restrictions

This document is subject to the following restrictions:

- no code changes;
- no MATLAB execution;
- no `gamultiobj` execution;
- no R1, R2, or R3 execution;
- no minrep execution;
- no 400-generation execution;
- no final article claims;
- no `hybrid`/`gasLP` superiority claims;
- no convergence claims;
- no global Pareto-front claims.

## 3. Current code factors

| Code factor | Current value | Unit | Current status |
|---|---:|---|---|
| `EF_LPG_kgCO2_per_kWh` | 0.2270 | kgCO2/kWh | provisional |
| `EF_grid_kgCO2_per_kWh` | 0.4380 | kgCO2/kWh or kgCO2e/kWh pending scope clarification | provisional |

The code marks these factors as:

`PROVISIONAL_FOR_CODE_VALIDATION`

## 4. Official-source inventory

### 4.1 SEMARNAT / RENE

Source:
[Registro Nacional de Emisiones (RENE)](https://www.gob.mx/semarnat/acciones-y-programas/registro-nacional-de-emisiones-rene)

Use: official Mexican source for notices and documentation of the Registro
Nacional de Emisiones, including factors used for reporting.

### 4.2 SEMARNAT / RENE regulations and agreements

Source:
[Reglamento y acuerdos secretariales RENE](https://www.gob.mx/semarnat/documentos/reglamento-y-acuerdos-secretariales-rene)

Use: official page that brings together notices, fuel lists, heating values,
and factors applicable to the Registro Nacional de Emisiones.

### 4.3 Aviso FESEN 2024

Source:
[Aviso FESEN 2024](https://www.gob.mx/cms/uploads/attachment/file/980977/AvisoFESEN_2024.pdf)

Data: Factor de Emisión del Sistema Eléctrico Nacional 2024 =
0.444 tCO2e/MWh.

Conversion:

`0.444 tCO2e/MWh = 0.444 kgCO2e/kWh`

### 4.4 INECC

Source:
[Factores de emisión para los diferentes tipos de combustibles fósiles que se consumen en México](https://www.gob.mx/inecc/documentos/factores-de-emision-para-los-diferentes-tipos-de-combustible-fosiles-que-se-consumen-en-mexico)

Use: official Mexican source for emission factors for fossil fuels consumed in
Mexico, including liquefied petroleum gas.

### 4.5 IPCC 2006 Guidelines

Source:
[IPCC 2006 Guidelines](https://www.ipcc-nggip.iges.or.jp/public/2006gl/spanish/index.html)

Use: international methodological source supporting default fuel factors.

Methodological data: the default factor for Liquefied Petroleum Gases is
63,100 kgCO2/TJ.

Conversion:

`1 TJ = 277,777.7778 kWh`

`63,100 kgCO2/TJ / 277,777.7778 kWh/TJ = 0.22716 kgCO2/kWh`

## 5. CO2-E2-F1: LPG / GLP factor fiche

- Current code factor:
  `EF_LPG_kgCO2_per_kWh = 0.2270 kgCO2/kWh`.
- International source: IPCC 2006 Guidelines.
- Base factor: 63,100 kgCO2/TJ for Liquefied Petroleum Gases.
- Conversion: 63,100 kgCO2/TJ = 0.22716 kgCO2/kWh.
- Comparison: the code value, 0.2270 kgCO2/kWh, is consistent with the IPCC
  default factor converted to kgCO2/kWh.
- Finding: `CODE_VALUE_CONSISTENT_WITH_IPCC_DEFAULT`.
- Reservation: `HOLD_FOR_MEXICO_SPECIFIC_INECC_VALIDATION`.
- Reason: INECC provides an official national source for fossil fuels consumed
  in Mexico, including liquefied petroleum gas, but the exact value must be
  extracted from the official document before deciding whether the article
  retains the IPCC default or adopts a national factor.
- Action: do not change the code yet.

## 6. CO2-E2-F2: Grid electricity / SEN factor fiche

- Current code factor: `EF_grid_kgCO2_per_kWh = 0.4380`.
- Candidate official source: SEMARNAT / RENE / FESEN.
- Official data located: FESEN 2024 = 0.444 tCO2e/MWh.
- Conversion: 0.444 tCO2e/MWh = 0.444 kgCO2e/kWh.
- Comparison: the code value, 0.4380, does not match the FESEN 2024 factor
  located.
- Possible interpretation: 0.4380 could correspond to an earlier base year,
  but this must be documented before validation.
- Finding: `HOLD_FOR_YEAR_BASE_DECISION`.
- Pending action: define whether the article will use the year of the climate
  data, the simulated-operation year, the run year, the most recent available
  official factor, or a sensitivity analysis.
- Action: do not change the code yet.

## 7. CO2 vs CO2e caveat

- The LPG combustion factor is generally reported as CO2.
- The Sistema Eléctrico Nacional electricity factor is reported as CO2e.
- CO2 and CO2e must not be mixed without declaring the scope.
- The article must decide whether the third objective will be reported as
  kgCO2/kg water removed or kgCO2e/kg water removed.
- Until that decision is made, the status must remain provisional.

## 8. Conversion records

| Conversion | Result |
|---|---:|
| 1 TJ | 277,777.7778 kWh |
| 63,100 kgCO2/TJ | 0.22716 kgCO2/kWh |
| 0.444 tCO2e/MWh | 0.444 kgCO2e/kWh |

## 9. Decision matrix

| Factor | Current code value | Candidate source | Finding | Decision |
|---|---:|---|---|---|
| GLP | 0.2270 kgCO2/kWh | IPCC 2006; INECC Mexico-specific pending | consistent with IPCC default conversion | `CODE_VALUE_CONSISTENT_WITH_IPCC_DEFAULT`; `HOLD_FOR_INECC_MEXICO_SPECIFIC` |
| Grid electricity | 0.4380 | SEMARNAT/RENE/FESEN | FESEN 2024 official factor found as 0.444 kgCO2e/kWh | `HOLD_FOR_YEAR_BASE_DECISION` |

## 10. Current CO2-E2 state

CO2-E2 = SOURCES_INVENTORIED_NOT_FINAL_VALIDATED

- GLP factor is methodologically defensible against IPCC default, but
  Mexico-specific INECC extraction remains pending.
- Grid electricity factor is not final because 0.4380 must be tied to a
  specific official year or replaced by the applicable FESEN value.
- No factor should be changed in code until the project decides the article
  year-basis and CO2/CO2e reporting basis.

## 11. Next steps

1. Extract official INECC GLP value from the official document.
2. Decide year-basis for grid electricity.
3. Decide CO2 vs CO2e reporting basis.
4. Create a separate PR only if code factors must be changed.
5. Keep MATLAB execution blocked until factor basis is resolved.
