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

MINIMAL_DYNAMIC_TEST_AUTHORIZATION = GRANTED_BY_MODEL_OWNER

AUTHORIZED_SCOPE = DIRECT_OBJECTIVE_EVALUATION_ONLY

PROHIBITED_EXECUTIONS = GAMULTIOBJ; R1; R2; R3; MINREP; 400GEN

DIRECT_OBJECTIVE_EVALUATIONS = 1

TEST_POINT_PROVENANCE = EXISTING_PREVIOUSLY_EVALUATED_R1_POINT

MATLAB_PROCESS_COUNT_BEFORE_TEST = 0

MATLAB_PROCESSES_STARTED = 1

MATLAB_VERSION = 26.1.0.3312084

MATLAB_RELEASE = R2026a_UPDATE_4

GAMULTIOBJ_EXECUTED = NO

R1_EXECUTED = NO

R2_EXECUTED = NO

R3_EXECUTED = NO

MINREP_EXECUTED = NO

400GEN_EXECUTED = NO

PRODUCTIVE_CODE_MODIFIED = NO

REPOSITORY_SIDE_EFFECT = NONE

The R1 point was used only as an existing historical test input. `R1_EXECUTED = NO` means that the R1 optimization itself was not rerun.

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

TERMINATION_TYPE = TMAX

TMAX_DYNAMIC_PATH = EXERCISED_BY_MINIMAL_TEST

F1_CURRENT = 0.058280754401313577

F1_HISTORICAL = 0.058280754401325401

F1_ABSOLUTE_DIFFERENCE = 1.18238752122579e-14

## 5. Equations and tolerance

All numerical comparisons used:

```text
abs(a - b) <= 1e-10 + 1e-9 * max(abs(a), abs(b))
```

ABS_TOL = 1e-10

REL_TOL = 1e-9

NUMERICAL_COMPARISON_CRITERION = ABS_A_MINUS_B_LE_ABS_TOL_PLUS_REL_TOL_TIMES_MAX_ABS_A_ABS_B

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

OBJECTIVE_FINITE_CHECK = PASS

UNEXPECTED_PENALTY_CHECK = PASS

POSITIVE_ACTIVITY_CHECK = PASS

CANONICAL_DENOMINATOR_DYNAMIC_CHECK = PASS

SHARED_DENOMINATOR_DYNAMIC_CHECK = PASS

LPG_USEFUL_TO_FUEL_CHECK = PASS

LPG_MASS_CHECK = PASS

LPG_COST_CHECK = PASS

LPG_CO2_CHECK = PASS

SOLAR_COST_DYNAMIC_CHECK = PASS

AIR_IMPELLER_ACTIVITY_CHECK = PASS

ELECTRICITY_COST_CHECK = PASS

ELECTRICITY_CO2_CHECK = PASS

SHARED_ELECTRICITY_ACTIVITY_DYNAMIC_CHECK = PASS

TOTAL_COST_CHECK = PASS

F2_IDENTITY_CHECK = PASS

TOTAL_CO2_CHECK = PASS

F3_IDENTITY_CHECK = PASS

DETAIL_COST_OBJECTIVE_CONSISTENCY = PASS

DETAIL_CO2_OBJECTIVE_CONSISTENCY = PASS

ACTIVE_CHAIN_NAN_INF_CHECK = PASS

F1_HISTORICAL_REPRODUCTION = PASS

ACTIVE_CHAIN_NAN_INF = NONE

UNEXPECTED_PENALTY = NO

The retained legacy field `detail.CO2.EF_LPG_kgCO2_per_kWh` was `NaN` and was explicitly reported by the implementation as `RETAINED_AS_NAN_INTERFACE_PLACEHOLDER_NOT_ACTIVE`. It did not feed any active objective chain and therefore did not invalidate the test.

LEGACY_INACTIVE_NAN = detail.CO2.EF_LPG_kgCO2_per_kWh

LEGACY_INACTIVE_NAN_STATUS = LEGACY_INACTIVE

LEGACY_INACTIVE_NAN_AFFECTS_OBJECTIVES = NO

The `detail.cost.total_cost_USD` field is the numerator of `f(2)`, and `detail.cost.water_removed_kg` is its denominator. The `detail.CO2.CO2_total_kg` field is the numerator of `f(3)`, and `detail.CO2.water_removed_kg` is the same canonical denominator used by `f(2)`.

F1_HISTORICAL_EQUALITY_EXPECTATION = EXPECTED_BECAUSE_F1_AND_PHYSICAL_MODEL_WERE_NOT_CHANGED

F2_HISTORICAL_EQUALITY_EXPECTATION = NOT_EXPECTED

F3_HISTORICAL_EQUALITY_EXPECTATION = NOT_EXPECTED

Historical equality was expected for `f(1)` because neither `f(1)` nor the physical model was changed. The methodologies for `f(2)` and `f(3)` were corrected, so their historical values were not equality references for COST-E3D-R2F and were neither compared nor recalculated in this memo.

## 7. Interpretation boundary

This minimal direct evaluation demonstrates only that the active energy, cost, CO2, and normalization chains are internally consistent at the recorded test point under the implemented equations. It does not demonstrate convergence, optimization reproducibility, Pareto-front validity, optimality, or final scientific results. It does not replace R1, R2, R3, `minrep`, or a formal 400-generation execution.

CONVERGENCE_VALIDATION = NOT_PERFORMED

OPTIMIZATION_REPRODUCIBILITY_VALIDATION = NOT_PERFORMED

PARETO_FRONT_VALIDATION = NOT_PERFORMED

OPTIMALITY_VALIDATION = NOT_PERFORMED

SENSITIVITY_VALIDATION = NOT_PERFORMED

R1_RECALCULATION = NOT_PERFORMED

R2_EXECUTION = NOT_PERFORMED

R3_EXECUTION = NOT_PERFORMED

MINIMAL_TEST_RESULT_SCOPE = ONLY_THE_SINGLE_TESTED_R1_POINT

GENERALIZATION_TO_ALL_SOLUTIONS = PROHIBITED

GENERALIZATION_TO_PARETO_FRONT = PROHIBITED

SCIENTIFIC_RESULT_STATUS = NOT_FINAL

The direct evaluation validates only the implemented identities at the single tested R1 point. It is not a sensitivity analysis or a statistical sample, does not demonstrate behavior over the population, and cannot be generalized to the solution set. It does not prove convergence or optimization reproducibility, validate a Pareto front, or prove optimality. The new `f(2)` and `f(3)` values apply exclusively to the single tested point.

R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST

R1_ECONOMIC_OBJECTIVE_STATUS = RECALCULATION_REQUIRED

R1_ENVIRONMENTAL_OBJECTIVE_STATUS = RECALCULATION_REQUIRED

R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL

R1_F2_F3_RECALCULATION = READY_FOR_EXPLICIT_OWNER_AUTHORIZATION

FORMAL_EXECUTION = BLOCKED_PENDING_EXPLICIT_RUN_AUTHORIZATION

No claim of hybrid/gasLP superiority, convergence, global Pareto-front validity, reproducibility beyond the documented operational scope, or final article results is authorized by COST-E3D-R2F.
