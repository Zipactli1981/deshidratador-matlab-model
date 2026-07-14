# Final cost and CO2 factor traceability matrix

Micropaso: `9.6z-trace-a`

Identifier: `FINAL-COST-CO2-FACTOR-TRACEABILITY-MATRIX-001`

Status: `TRACEABILITY_CONTROL_READY`

This matrix does not create final cost or CO2 claims. It separates provisional factors used for code validation from factors that still require final source traceability before manuscript submission.

## Controlled provisional factors

| Factor | Current value | Units | Status |
|---|---:|---|---|
| `EF_LPG_kgCO2_per_kWh` | 0.2270 | kgCO2/kWh | `PROVISIONAL_FOR_CODE_VALIDATION` |
| `EF_grid_kgCO2_per_kWh` | 0.4380 | kgCO2/kWh | `PROVISIONAL_FOR_CODE_VALIDATION` |

## Traceability matrix

| Item | Symbol | Current value | Units | Role | Current status | Manuscript readiness | Source status | Required action before submission | Permitted current use | Note |
|---|---|---|---|---|---|---|---|---|---|---|
| LPG CO2 emission factor | EF_LPG_kgCO2_per_kWh | 0.2270 | kgCO2/kWh | Environmental objective / CO2 calculation | PROVISIONAL_FOR_CODE_VALIDATION | Not final for manuscript claims | Pending final bibliographic or institutional source | Replace or confirm with cited final source before submission | Internal code validation, sensitivity, traceability draft | Current value retained as provisional factor only. |
| Grid electricity CO2 emission factor | EF_grid_kgCO2_per_kWh | 0.4380 | kgCO2/kWh | Auxiliary electricity / indirect emissions if used | PROVISIONAL_FOR_CODE_VALIDATION | Not final for manuscript claims | Pending final bibliographic or institutional source | Replace or confirm with cited final source before submission | Internal code validation, sensitivity, traceability draft | Current value retained as provisional factor only. |
| Gas-LPG auxiliary energy | Q_aux | Computed by model/post-processing | kWh | Energy metric for hybrid and gas-LPG baseline comparison | Computed result already used in locked Results Section 7 | Usable as computed model output | Traceable to selected-point comparison files and locked Section 7 | Ensure cost/CO2 factors attached to Q_aux are final before final claims | Results interpretation and baseline comparison | Energy values are locked; factor-based emissions/cost claims remain source-dependent. |
| Fuel cost factor | C_LPG or equivalent | Pending final source/value | currency/kWh or currency/kg | Economic objective / specific cost calculation | Requires final traceability | Not final for manuscript claims | Pending final price source, date, region, and conversion basis | Define final source, date, lower heating value basis if needed, and unit conversion | Planning only | Do not treat as final until unit basis and source date are documented. |
| Electricity cost factor | C_grid or equivalent | Pending final source/value | currency/kWh | Economic objective if electrical consumption is included | Requires final traceability | Not final for manuscript claims | Pending final tariff/source, date, and tariff class | Define tariff source, date, region, tariff class, and applicability | Planning only | Needed only if electricity/fan or auxiliary electrical use enters final economic metric. |
| Fan-power treatment | P_fan / pressure-drop coupling | Not fully coupled in current optimization | W, kWh, Pa | Equipment-level limitation | Explicit limitation | Usable as limitation, not as optimized equipment claim | Documented as methodological caveat | Keep as limitation/future work unless fan power is explicitly modeled | Limitations and future work | Prevents overclaiming equipment-level optimality. |
| Pressure-drop treatment | DeltaP | Not fully coupled in current optimization | Pa | Equipment-level limitation | Explicit limitation | Usable as limitation, not as optimized equipment claim | Documented as methodological caveat | Keep as limitation/future work unless pressure drop is explicitly modeled | Limitations and future work | Prevents overclaiming equipment-level optimality. |
| Solar-only operation | solar_only | Excluded from formal GA comparison | mode | Boundary/endpoint operating mode | Excluded from formal comparison | Usable only as separate endpoint if discussed | Documented as non-equivalent mode | Do not mix with hybrid/gas-LPG formal GA comparison | Methods caveat | Protects comparability of the formal optimization. |

## Internal verdict

`FINAL_COST_CO2_FACTOR_TRACEABILITY_MATRIX_READY_FOR_CONTROL_USE`
