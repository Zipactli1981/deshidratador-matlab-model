# CO2-E4: Grid-factor code update v96z

## 1. Purpose

This PR minimally implements the CO2-E3 methodological decision to update the
grid-electricity emission factor. The change is limited to the base
tri-objective CO2 function and its active wrapper/fix so that their factor
definitions remain aligned.

This PR does not execute or validate the objective and does not authorize a
formal run or final article claims.

## 2. Authorized change

| Factor | Previous value | New value | Unit | Reason |
|---|---:|---:|---|---|
| `EF_grid_kgCO2_per_kWh` | 0.4380 | 0.4440 | kgCO2e/kWh | SEMARNAT/RENE FESEN 2024 year-basis decision |

## 3. Unchanged items

- `EF_LPG_kgCO2_per_kWh` remains 0.2270.
- No physical model equations changed.
- No cost equations changed.
- No MR equations changed.
- No GA bounds changed.
- No seed changed.
- No `PopulationSize` changed.
- No `MaxGenerations` changed.
- No MATLAB execution.
- No `gamultiobj` execution.
- No R1, R2, R3, minrep, or 400-generation execution.

## 4. Source basis

SEMARNAT/RENE FESEN 2024:

`0.444 tCO2e/MWh = 0.444 kgCO2e/kWh`

The electricity factor is interpreted as CO2e. The third objective should be
documented as specific operational emissions in kgCO2e/kg water removed, with
a boundary note covering direct LPG combustion CO2 and indirect
grid-electricity CO2e. This is not a complete life-cycle assessment.

## 5. Implementation status

CO2-E4 = GRID_FACTOR_CODE_UPDATE_IMPLEMENTED_NO_EXECUTION

FORMAL_EXECUTION = STILL_BLOCKED_PENDING_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION

## 6. Next steps

1. Review and merge this code PR.
2. After merge, update `main`.
3. Decide whether a static post-change audit is required before execution.
4. Do not run MATLAB until explicit authorization is given.
