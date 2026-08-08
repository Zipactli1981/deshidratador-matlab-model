# COST-E3D-R2F: Minimal dynamic objective validation memo v96z

## 1. Purpose

This memo records the authorized minimal dynamic validation of the productive tri-objective function after the coordinated COST-E3D implementation. The validation consisted of one direct objective evaluation at an existing, previously evaluated R1 point. It did not execute an optimizer, rerun R1, or establish optimization-level scientific evidence.

COST-E3D-R2F = MINIMAL_DYNAMIC_OBJECTIVE_VALIDATION_PASS

DYNAMIC_VALIDATION_STATUS = MINIMAL_DIRECT_OBJECTIVE_EVALUATION_PASS

ENERGY_COST_RECONCILIATION = IMPLEMENTED_AND_MINIMALLY_VALIDATED

COST_OBJECTIVE_TRACEABILITY = DYNAMICALLY_CHECKED_AT_MINIMAL_TEST_POINT

ENVIRONMENTAL_OBJECTIVE_TRACEABILITY = DYNAMICALLY_CHECKED_AT_MINIMAL_TEST_POINT

F2_F3_NORMALIZATION_STATUS = IMPLEMENTED_AND_MINIMALLY_VALIDATED

## 2. Authorized execution boundary

The model owner authorized only a direct evaluation of the productive objective. The test used one MATLAB batch session and exactly one objective evaluation. It did not call `gamultiobj`, an optimization runner, or a population loop, and it did not execute R1, R2, R3, `minrep`, or a 400-generation run.

| Control | Recorded value |
|---|---|
| MATLAB process count before test | 0 |
| MATLAB sessions initiated | 1 |
| MATLAB version | 26.1.0.3312084 (R2026a) Update 4 |
| Platform | PCWIN64 |
| Direct objective evaluations | 1 |
| Objective | `objective_productive_corrected_v96j_triobjective_CO2_fix1` |
| Start | 2026-08-07 19:44:57 -0600 |
| End | 2026-08-07 19:45:23 -0600 |
| Repository side effect | NONE |

## 3. Deterministic R1 test point

The test point was not newly selected or optimized. It was R1 solution index 3 from `POSTPROCESS_R1_v96z_Tsolutions_enriched.csv`, retained from the pre-execution preparation because existing evidence showed positive LPG, solar, and electrical activity.

MINIMAL_TEST_POINT_SOURCE = POSTPROCESS_R1_v96z_Tsolutions_enriched.csv

MINIMAL_TEST_POINT_INDEX = 3

MINIMAL_TEST_DECISION_VECTOR = [0.0755184246822468, 65.0538554446214, 0.788632420409064, 12.8744680049588]

MINIMAL_TEST_MODE = hybrid

TEST_POINT_PROVENANCE = EXISTING_PREVIOUSLY_EVALUATED_R1_POINT

DIRECT_OBJECTIVE_EVALUATIONS = 1

## 4. Observed dynamic values

| Quantity | Observed value |
|---|---:|
| Termination type | TMAX |
| `detail.status` | OK |
| `f(1)` | 0.058280754401313577 |
| `f(2)` | 0.19941617063834177 |
| `f(3)` | 0.46413468947682840 |
| Historical `f(1)` for the same R1 point and mode | 0.058280754401325401 |
| `dry_time` | 19.900000000000006 h |
| `Mi` | 6.6923076923076916 dry basis |
| `md` | 26.000000000000004 kg |
| `M_terminal` | 0.47192137104546589 dry basis |
| `water_removed_kg` | 161.73004435281791 kg |
| `Q_aux_tot` | 791.67181314668949 MJ |
| `Q_LPG_input` | 1014.9638630085763 MJ |
| LPG mass | 21.987951971589609 kg |
| LPG cost | 24.616711043920397 USD |
| LPG emissions | 65.963855914768828 kg CO2e |
| `Irradiacion` / solar energy | 487.28052000000002 MJ |
| Solar cost | 6.1648666121331042 USD |
| Electric energy | 20.497000000000007 kWh |
| Electricity cost | 1.4700084659546171 USD |
| Electricity emissions | 9.1006680000000024 kg CO2e |
| Total cost | 32.251586122008121 USD |
| Total emissions | 75.064523914768827 kg CO2e |

The trajectory reached `TMAX`; this real termination type was retained. No alternative termination was forced.

TMAX_DYNAMIC_PATH = EXERCISED_BY_MINIMAL_TEST

## 5. Equations and tolerance

All numerical comparisons used:

```text
abs(a - b) <= 1e-10 + 1e-9 * max(abs(a), abs(b))
```

The dynamic checks covered the following identities:

```text
water_removed_kg = (Mi - M_terminal) * md
Q_LPG_input = Q_aux_tot / 0.78
LPG_mass = Q_LPG_input / 46.16
LPG_cost = LPG_mass * 1.1195545213
CO2_LPG = LPG_mass * 3.00
solar_cost = Irradiacion * 0.0126515761642454
electric_energy_kWh = 1.03 * dry_time_h
electricity_cost = electric_energy_kWh * 0.0717182253966247
CO2_electricity = electric_energy_kWh * 0.444
total_cost = electricity_cost + LPG_cost + solar_cost
f(2) = total_cost / water_removed_kg
total_CO2 = CO2_LPG + CO2_electricity
f(3) = total_CO2 / water_removed_kg
```

## 6. Check results

| Dynamic check | Result |
|---|---|
| Objective finitude (`f(1:3)`) | PASS |
| Unexpected penalty absence | PASS |
| Positive active-chain activity | PASS |
| Historical `f(1)` reproduction | PASS |
| Canonical denominator | PASS |
| LPG useful-energy-to-fuel conversion | PASS |
| LPG mass | PASS |
| LPG cost | PASS |
| LPG CO2 | PASS |
| Solar cost | PASS |
| Air-impeller electrical activity | PASS |
| Electricity cost | PASS |
| Electricity CO2 | PASS |
| Shared electricity activity for cost and CO2 | PASS |
| Total cost | PASS |
| `f(2)` identity | PASS |
| Total CO2 | PASS |
| `f(3)` identity | PASS |
| `detail.cost.specific` consistency with `f(2)` | PASS |
| `detail.CO2.specific` consistency with `f(3)` | PASS |
| Shared cost/CO2 denominator | PASS |
| Active-chain finite real values | PASS |

F1_HISTORICAL_REPRODUCTION = PASS

ACTIVE_CHAIN_NAN_INF = NONE

UNEXPECTED_PENALTY = NO

The retained legacy field `detail.CO2.EF_LPG_kgCO2_per_kWh` was `NaN` and was explicitly reported by the implementation as `RETAINED_AS_NAN_INTERFACE_PLACEHOLDER_NOT_ACTIVE`. It did not feed any active objective chain and therefore did not invalidate the test.

## 7. Interpretation boundary

This minimal direct evaluation demonstrates only that the active energy, cost, CO2, and normalization chains are internally consistent at the recorded test point under the implemented equations. It does not demonstrate convergence, optimization reproducibility, Pareto-front validity, optimality, or final scientific results. It does not replace R1, R2, R3, `minrep`, or a formal 400-generation execution.

R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST

R1_ECONOMIC_OBJECTIVE_STATUS = RECALCULATION_REQUIRED

R1_ENVIRONMENTAL_OBJECTIVE_STATUS = RECALCULATION_REQUIRED

R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL

R1_F2_F3_RECALCULATION = READY_FOR_EXPLICIT_OWNER_AUTHORIZATION

FORMAL_EXECUTION = BLOCKED_PENDING_EXPLICIT_RUN_AUTHORIZATION

No claim of hybrid/gasLP superiority, convergence, global Pareto-front validity, reproducibility beyond the documented operational scope, or final article results is authorized by COST-E3D-R2F.
