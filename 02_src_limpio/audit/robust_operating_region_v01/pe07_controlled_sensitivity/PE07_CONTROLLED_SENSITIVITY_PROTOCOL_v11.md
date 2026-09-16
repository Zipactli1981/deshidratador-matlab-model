# PE07 Controlled Operational-Variable Sensitivity Protocol v1.1

## Identity and scope

```text
MICROSTEP = ROR_PE_07_CONTROLLED_OPERATIONAL_VARIABLE_SENSITIVITY_EXPERIMENT
DESIGN_VERSION = v1.1
EXPERIMENT_CLASS = CONTROLLED_LOCAL_MODEL_SENSITIVITY
METHOD = ONE_FACTOR_AT_A_TIME
PRIMARY_SUFFICIENCY = FAIL
PRIMARY_FAILED_CONDITION = HV_RATIO
UPSTREAM_CANONICAL_BASELINE_HEAD = 17cc812780a92bb073bffbfab288c0f51986dea1
CAMPAIGN_ID = ROR_PE07_CONTROLLED_SENSITIVITY_V01
MODE_OPERATION = hybrid
```

This protocol materializes the previously approved PE07 v1.1 design. It does
not authorize execution. PE07 evaluates local deterministic model responses;
it does not establish physical causality, global sensitivity, convergence,
global optimality, or an operating policy.

## Controls, order, bounds and units

The frozen control order is `[m_max, T_min, r_div2, t_rec_ini]`.

| Control | Lower | Upper | Units | Small delta | Large delta |
|---|---:|---:|---|---:|---:|
| `m_max` | 0.07 | 0.20 | kg/s | 0.00325 | 0.00650 |
| `T_min` | 45 | 70 | degC | 0.625 | 1.25 |
| `r_div2` | 0 | 0.99 | dimensionless fraction | 0.02475 | 0.04950 |
| `t_rec_ini` | 0 | 19 | h | 0.475 | 0.950 |

Bounds are hard and inclusive. Perturbations are never clipped, replaced,
adapted or supplemented. A predefined point outside a bound is retained in
the domain audit and is not evaluated.

## Frozen anchors

The three anchors are full-precision doubles imported from the hash-verified
PRIMARY `N_POOL.mat`; chat-rendered values are not authoritative.

| Context | ID | Seed | PRIMARY returned row |
|---|---|---:|---:|
| LOW | N21 | 61004 | 7 |
| MID | N11 | 61003 | 3 |
| HIGH | N19 | 61004 | 4 |

The executable configuration freezes their exact `X`, `F`, `MR`,
`water_removed_kg`, `Q_aux_useful_MJ` and `LPG_fuel_input_MJ`, together with
artifact paths and hashes. Anchor order is N21, N11, N19.

## Frozen perturbation design and budget

For each anchor and control, propose in this order:

1. `x_j - delta_large`;
2. `x_j - delta_small`;
3. `x_j + delta_small`;
4. `x_j + delta_large`.

This yields 48 structural conditions. Exactly one is predefined out of
domain: `N21 / m_max / minus_large`. Therefore 47 perturbations are
executable. Three baseline replays give a maximum executable budget of 50.
The absolute structural cap is 51 and cannot be used to add a point.

```text
STRUCTURAL_PROPOSED_PERTURBATIONS = 48
PRECLASSIFIED_OUT_OF_DOMAIN = 1
VALID_PERTURBATIONS = 47
BASELINE_REPLAYS = 3
MAX_EXECUTABLE_EVALUATIONS = 50
ABSOLUTE_STRUCTURAL_CAP = 51
ADAPTIVE_EVALUATIONS = PROHIBITED
```

## Execution order and baseline gate

Execution order is fail-closed:

1. verify authorization, Git/source identity, configuration and budgets;
2. exclusively reserve the frozen execution root;
3. write frozen configuration, proposed matrix, anchor table, domain audit
   and initial provenance;
4. replay baseline N21, then N11, then N19;
5. compare exactly, with no tolerance, the stored and observed doubles for
   `MR`, `W`, `Q_aux_useful_MJ`, `LPG_fuel_input_MJ`, `f1`, `f2`, `f3`;
6. only if all 3/3 comparisons pass, evaluate the 47 valid perturbations in
   frozen condition order;
7. preserve every result, including invalid/penalized results, and finalize
   execution artifacts.

Timestamps and other transient metadata are excluded from baseline equality.
Any baseline mismatch produces `BASELINE_REPLAY_MISMATCH`, zero perturbation
evaluations, preserved evidence and immediate stop. There is no automatic
retry and no post-hoc tolerance.

## Productive entry point and deterministic state

The only scientific entry point is:

```matlab
[f, detail] = objective_productive_corrected_v96j_triobjective_CO2_fix1(x,'hybrid');
```

No productive code modification is permitted. Evaluations are sequential.
Before calls, `TRACE_V628B_DIR`, `TRACE_V628B_MODE` and `TRACE_V628B_TAG` are
cleared to prevent auxiliary trace writes. The execution records MATLAB
version/release, platform, authorized Git HEAD, protocol/config/source-lock
hashes, productive dependency lock identity, timestamps and condition IDs.

## Responses and invalid-point policy

Primary responses are `W` (kg water removed) and `LPG` (MJ fuel input).
Secondary responses are `MR`, `Q_aux_useful_MJ`, `f1`, `f2`, and `f3`.
MR/W and Q_aux/LPG are structurally/accounting related and are not independent
confirmations.

A condition is invalid if it is outside bounds, raises a caught evaluation
error, reports `NONPHYSICAL_TRAJECTORY`, `INVALID_MR`, `INVALID_COST` or
`INVALID_CO2`, has a penalized execution status, equals the penalty vector
`[1000,1e6,1e6]`, or has a required response that is nonfinite or nonreal.
Invalid points remain in the audit inventory but are excluded from finite
differences, signs and recurrence. They are never replaced.

## Finite differences and classifications

For each anchor, control and magnitude, a central response exists only when
both symmetric evaluations exist and are valid:

```text
CENTRAL_DELTA_Y = Y(x_j + delta) - Y(x_j - delta)
CENTRAL_SECANT_Y = CENTRAL_DELTA_Y / (2*delta)
```

Primary units are kg-water per control unit for W and MJ-fuel-input per
control unit for LPG. Exact numerical equality is ZERO. Positive and negative
signs describe only controlled model response.

SMALL/LARGE directions are `MAGNITUDE_DIRECTION_CONSISTENT` only when both
are evaluable and have the same nonzero sign; otherwise they are
`ZERO_OR_MIXED_MAGNITUDE_RESPONSE`. Opposite signs at one anchor flag
`LOCAL_MAGNITUDE_NONMONOTONICITY`.

Across LOW/MID/HIGH anchors:

- `STRONG_LOCAL_MODEL_RECURRENCE`: same nonzero direction at all three
  anchors for at least one common magnitude;
- `PARTIAL_LOCAL_MODEL_RECURRENCE`: same nonzero direction at two anchors;
- `CONTEXT_DEPENDENT_MODEL_RESPONSE`: directions differ across anchors;
- `INSUFFICIENT_DOMAIN_SUPPORT`: too few valid symmetric pairs.

A LOW/MID/HIGH direction change flags `CROSS_CONTEXT_DIRECTION_CHANGE`.

## PE06 comparison and evidence labels

Only after controlled results exist, compare the frozen PE06 observational
direction with PE07 using exactly:

- `OBSERVATIONAL_AND_CONTROLLED_DIRECTION_CONSISTENT`;
- `OBSERVATIONAL_ASSOCIATION_NOT_REPRODUCED_LOCALLY`;
- `CONTROLLED_RESPONSE_CONTEXT_DEPENDENT`;
- `OBSERVATIONAL_RESULT_TOO_AMBIGUOUS_FOR_DIRECTIONAL_COMPARISON`.

PE06 associations remain unchanged. Prospective PE07 evidence labels are:

- `PE07_LEVEL_A = CONTROLLED_LOCAL_MODEL_RESPONSE_RECURRENT_ACROSS_CONTEXTS`;
- `PE07_LEVEL_B = CONTROLLED_LOCAL_MODEL_RESPONSE_PARTIALLY_RECURRENT`;
- `PE07_LEVEL_C = CONTROLLED_LOCAL_MODEL_RESPONSE_CONTEXT_DEPENDENT`;
- `PE07_LEVEL_D = INSUFFICIENT_OR_INVALID_CONTROLLED_EVIDENCE`.

No causal ranking, normalized importance, elasticity, policy selection or
optimal-setting claim is permitted.

## Root, writes and artifact contract

The frozen execution root is
`05_runs/robust_operating_region_v01/controlled_operational_sensitivity/ROR_PE07_CONTROLLED_SENSITIVITY_V01`.
It is reserved exclusively and must not pre-exist. Files are written once via
temporary same-directory files and atomic rename where practical. Partial
evidence is preserved on failure; no overwrite or automatic rerun is allowed.

Pre-execution artifacts: frozen config, anchor table, proposed matrix,
initial provenance and domain audit. Execution artifacts: baseline audit,
perturbation results, invalid-point inventory, terminal status and execution
provenance. Postrun artifacts: finite-difference table, domain/feasibility
audit, PE07 report and SHA-256 manifest. PRIMARY artifacts are read-only.

## Claim boundary

Allowed wording is limited to controlled local modeled response around the
three evaluated PRIMARY contexts. PE07 cannot establish real-plant causality,
universal relationships, global sensitivity, convergence, global Pareto
optimality, optimizer sufficiency or a causal ranking of controls.
