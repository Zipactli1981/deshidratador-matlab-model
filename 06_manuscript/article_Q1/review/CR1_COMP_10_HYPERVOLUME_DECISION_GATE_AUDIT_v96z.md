# CR1-COMP-10 — Hypervolume decision gate audit

## Purpose and scope

Apply the exact frozen hypervolume decision gate to the already validated
CR1-COMP-07 full-coverage values. This phase decides only whether hypervolume
is recommended as an additional secondary comparison. It does not calculate
hypervolume or execute CR1-COMP-11.

## Baseline and frozen protocol

```text
INPUT_BASELINE_HEAD = c9e7b4d16d492fd06e7e2a600208d3d522f6225b
INPUT_BASELINE_CHECK = PASS
PROTOCOL_VERSION = v1.0
PROTOCOL_STATUS = FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
PROTOCOL_SHA256 = 8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
PROTOCOL_SHA256_CHECK = PASS
```

## Frozen upstream source

```text
COVERAGE_JSON_SHA256 = 8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83
COVERAGE_JSON_SHA256_CHECK = PASS
COVERAGE_CSV_SHA256 = 006DE140768490BF4903F266C2D205AAC8B2F1BF4A44E8F836179842825206FF
COVERAGE_CSV_SHA256_CHECK = PASS
CR1_COMP_07_STATUS = CLOSED_PASS
CR1_COMP_07_INDEPENDENT_QC = PASS
H_ROWS = 9
C_ROWS = 9
N_H_DOMINATED_BY_C = 1
H_DOMINATED_BY_C_IDS = H05
N_C_DOMINATED_BY_H = 2
C_DOMINATED_BY_H_IDS = C06,C08
FULL_COVERAGE_C_OVER_H = 0.1111111111111111
FULL_COVERAGE_H_OVER_C = 0.2222222222222222
```

The JSON route is primary. The CSV was read and evaluated independently. No
dominance matrix or coverage value was recomputed.

## Exact frozen rule

```text
IF FULL_COVERAGE_C_OVER_H = 1
AND FULL_COVERAGE_H_OVER_C = 0
THEN HYPERVOLUME_MAIN_ANALYSIS = NOT_REQUIRED
ELSE HYPERVOLUME_ANALYSIS = RECOMMENDED
```

Core coverage, geometry, Pareto rank, medians, dominance counts, near-ties,
visual judgment, and editorial preference were not used. No tolerance,
rounding, threshold, or approximate comparison was introduced.

## Boolean evaluation and result

```text
GATE_TEST_C_OVER_H_EQUALS_1 = FALSE
GATE_TEST_H_OVER_C_EQUALS_0 = FALSE
GATE_FULL_DOMINANCE_CONDITION = FALSE
SELECTED_BRANCH = ELSE
HYPERVOLUME_ANALYSIS = RECOMMENDED
HYPERVOLUME_GATE_COMPUTED = YES
HYPERVOLUME_COMPUTED = NO
CR1_COMP_11_COMPUTED = NO
```

## Limited methodological meaning

La dominancia/cobertura no proporciona una sustitución completa y unidireccional de H por C bajo la condición congelada; por tanto, el protocolo recomienda utilizar hypervolume como métrica secundaria adicional.

This result does not establish that either set is better, predict which set a
future hypervolume analysis would favor, or demonstrate convergence,
robustness, or approximation quality relative to a true Pareto front.

## Independent QC

```text
JSON_CSV_COVERAGE_CONSISTENCY = PASS
GATE_IMPLEMENTATIONS_AGREE = PASS
UPSTREAM_DOCUMENTARY_CONSISTENCY = PASS
INDEPENDENT_QC = PASS
```

## Separation from CR1-COMP-11

```text
COVERAGE_RECALCULATED_FROM_DOMINANCE_MATRIX = NO
HV_H_COMPUTED = NO
HV_C_COMPUTED = NO
HV_ANCHORS_COMPUTED = NO
HV_NORMALIZATION_COMPUTED = NO
HV_REFERENCE_POINTS_COMPUTED = NO
HV_SENSITIVITY_COMPUTED = NO
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
```

CR1-COMP-11 remains a separate phase requiring explicit authorization.
