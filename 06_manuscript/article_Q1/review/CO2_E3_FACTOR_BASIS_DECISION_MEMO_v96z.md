# CO2-E3: Factor-basis decision memo v96z

## 1. Purpose

This document converts the CO2-E2 source inventory into a controlled
methodological decision about the environmental-factor basis to be used before
any code change or new run.

CO2-E3:

- does not modify code;
- does not execute MATLAB;
- does not validate final results;
- only establishes the recommended decision for a separate future
  implementation.

## 2. Scope and restrictions

This memo is subject to the following restrictions:

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

## 3. Current status before CO2-E3

| Item | Status before CO2-E3 |
|---|---|
| Gate A | R1 operational PASS |
| Gate B | protocols defined |
| EVIDENCE-E1 | GA variable/output dictionary documented |
| CO2-E2 | `SOURCES_INVENTORIED_NOT_FINAL_VALIDATED` |
| Code factors | unchanged and provisional |
| MATLAB execution | blocked |

## 4. Decision problem

The project must decide three items before executing any new run:

1. Which factor to use for LPG.
2. Which factor to use for grid electricity.
3. Whether the third objective will be reported as CO2 or CO2e.

## 5. Decision A: LPG / GLP factor basis

Current code value:

`EF_LPG_kgCO2_per_kWh = 0.2270`

Evidence:

- The IPCC 2006 default factor for Liquefied Petroleum Gases is
  63,100 kgCO2/TJ.
- `1 TJ = 277,777.7778 kWh`.
- Conversion:
  `63,100 / 277,777.7778 = 0.22716 kgCO2/kWh`.
- Therefore, the code value 0.2270 kgCO2/kWh is consistent with the IPCC
  default factor after rounding.

Decision:

`LPG_BASE_FACTOR_DECISION = RETAIN_CURRENT_CODE_VALUE_FOR_BASELINE_AS_IPCC_DEFAULT`

Rationale:

- It is traceable.
- It is methodologically defensible.
- It avoids changing the code before execution.
- It can be cited as an IPCC default combustion CO2 factor.

Reservation:

INECC Mexico-specific extraction remains useful, but it is not mandatory for
the baseline if the article explicitly declares IPCC default factors for GLP.

Required manuscript wording:

The LPG factor should be described as an IPCC default combustion CO2 factor,
converted from kgCO2/TJ to kgCO2/kWh.

Do not change the code in this PR.

## 6. Decision B: Grid-electricity factor basis

Current code value:

`EF_grid_kgCO2_per_kWh = 0.4380`

Evidence:

- SEMARNAT / RENE is the official Mexican source for the electricity emission
  factor used in reporting.
- FESEN 2024 was located as 0.444 tCO2e/MWh.
- Conversion: `0.444 tCO2e/MWh = 0.444 kgCO2e/kWh`.
- The current code value 0.4380 does not match the located FESEN 2024 value.

Decision:

`GRID_FACTOR_DECISION = REPLACE_IN_FUTURE_CODE_PR_WITH_0p444_KGCO2E_PER_KWH`

Rationale:

- The article is being prepared after the official FESEN 2024 value is
  available.
- The electricity factor should be tied to an official SEMARNAT/RENE source.
- A documented current official factor is preferable to an untraced 0.4380
  value.
- The change must occur only in a later code PR, not in this memo.

Reservation:

If the project later decides to match a different year basis, such as the year
of climatic data, year of simulated operation, or year of prior code
validation, then 0.4380 may only be retained if its official year and source
are documented.

Required manuscript wording:

The electricity factor should be described as the SEMARNAT/RENE Factor de
Emisión del Sistema Eléctrico Nacional, reported in tCO2e/MWh and converted to
kgCO2e/kWh.

Do not change the code in this PR.

## 7. Decision C: CO2 vs CO2e reporting basis

Problem:

The LPG factor is a combustion CO2 factor, while the electricity factor is
reported as CO2e.

Decision:

`REPORTING_BASIS_DECISION = REPORT_THIRD_OBJECTIVE_AS_KGCO2E_PER_KGWATER_WITH_BOUNDARY_NOTE`

Rationale:

- The electricity factor is officially reported as CO2e.
- Fossil CO2 can be expressed on a CO2e basis with GWP100 = 1 for the CO2
  component.
- The manuscript must make clear that the metric is not a complete life-cycle
  carbon footprint.
- The boundary is operational LPG combustion CO2 plus grid-electricity CO2e,
  normalized by water removed.

Required manuscript wording:

The third objective should be described as specific operational greenhouse-gas
emissions, expressed as kgCO2e per kg of water removed, including direct LPG
combustion CO2 and indirect grid-electricity CO2e. The method is not a full
life-cycle assessment.

Do not rename variables or code fields in this PR.

## 8. Decision matrix

| Decision item | Current code | CO2-E3 decision | Implementation status |
|---|---|---|---|
| LPG factor | 0.2270 kgCO2/kWh | retain as IPCC default baseline | no code change required |
| Grid factor | 0.4380 | replace later with 0.444 kgCO2e/kWh unless a different official year-basis is selected | future code PR required |
| Reporting basis | CO2 naming in code | report as operational kgCO2e/kg water removed with boundary note | manuscript wording and possibly later naming cleanup |
| MATLAB execution | blocked | remain blocked until code-factor decision is implemented or explicitly waived | no execution |

## 9. Future implementation rule

This memo does not authorize immediate MATLAB execution.

Before any new formal run, the project must choose one of two controlled paths:

### Path 1: No code-change path

- Keep GLP = 0.2270.
- Keep grid = 0.4380 only if the official source and year for 0.4380 are
  documented.
- Update manuscript wording accordingly.
- Requires a documentary justification PR.

### Path 2: Code-update path

- Keep GLP = 0.2270 as IPCC default.
- Replace grid = 0.4380 with grid = 0.444 kgCO2e/kWh.
- Update status strings and documentation.
- Requires a separate code PR.
- After the code PR, rerun only after explicit authorization.

Recommended path:

Path 2 is recommended because 0.444 kgCO2e/kWh has a located official
SEMARNAT/RENE basis, while 0.4380 remains untraced in the current documentary
chain.

## 10. Updated CO2-E3 state

CO2-E3 = FACTOR_BASIS_DECISION_MEMO_DOCUMENTED_NO_CODE_CHANGE

Recommended implementation state:

CO2_FACTOR_CODE_UPDATE = PENDING_SEPARATE_PR

MATLAB execution state:

FORMAL_EXECUTION = BLOCKED_PENDING_FACTOR_IMPLEMENTATION_OR_EXPLICIT_WAIVER

## 11. Next steps

1. Decide whether to accept the recommended Path 2.
2. If accepted, create a separate code PR to update the grid factor to
   0.444 kgCO2e/kWh and adjust documentation/status strings.
3. Keep the GLP factor at 0.2270 unless the project chooses to adopt an INECC
   Mexico-specific value.
4. After the code-factor basis is implemented or explicitly waived, revisit
   Gate B execution readiness.
5. Do not run MATLAB until explicitly authorized.

## 12. Official sources retained

- [SEMARNAT / Registro Nacional de Emisiones (RENE)](https://www.gob.mx/semarnat/acciones-y-programas/registro-nacional-de-emisiones-rene)
- [SEMARNAT / RENE regulations and agreements](https://www.gob.mx/semarnat/documentos/reglamento-y-acuerdos-secretariales-rene)
- [Aviso FESEN 2024](https://www.gob.mx/cms/uploads/attachment/file/980977/AvisoFESEN_2024.pdf):
  0.444 tCO2e/MWh = 0.444 kgCO2e/kWh.
- [INECC fossil-fuel emission factors for Mexico](https://www.gob.mx/inecc/documentos/factores-de-emision-para-los-diferentes-tipos-de-combustible-fosiles-que-se-consumen-en-mexico)
- [IPCC 2006 Guidelines](https://www.ipcc-nggip.iges.or.jp/public/2006gl/spanish/index.html):
  Liquefied Petroleum Gases = 63,100 kgCO2/TJ.

## 13. Documentary references

- [`EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md`](EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md)
- [`CO2_E2_FACTOR_VALIDATION_FICHES_v96z.md`](CO2_E2_FACTOR_VALIDATION_FICHES_v96z.md)
- [`GATE_B_CO2_FACTOR_VALIDATION_PROTOCOL_v96z.md`](GATE_B_CO2_FACTOR_VALIDATION_PROTOCOL_v96z.md)
- [`GATE_B_DECISION_CURRENT_STATUS_v96z.md`](GATE_B_DECISION_CURRENT_STATUS_v96z.md)
