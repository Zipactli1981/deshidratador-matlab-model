# CR1-COMP-11 — Hypervolume and sensitivity audit

## Scope and frozen inputs

CR1-COMP-11 computes `HV(N_H)` and `HV(N_C)` under one common normalization
and the three protocol-defined reference points. It does not execute any later
comparative phase, optimization, model evaluation, or physical/economic/environmental interpretation.

```text
INPUT_BASELINE_HEAD = 4935e40220c2909685d99a0a1d7c0a50ef57da61
INPUT_BASELINE_CHECK = PASS
PROTOCOL_SHA256 = 8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
PROTOCOL_SHA256_CHECK = PASS
HV_GATE_UPSTREAM_CHECK = PASS
UPSTREAM_HASH_CHECKS = PASS
UPSTREAM_CONSISTENCY_CHECK = PASS
```

## Sets and common anchors

```text
N_H_COUNT = 9
N_C_COUNT = 9
P_COUNT = 18
N_H_IDS = H01,H02,H03,H04,H05,H06,H07,H08,H09
N_C_IDS = C01,C02,C03,C04,C05,C06,C07,C08,C09
P_DEFINITION = N_H_UNION_N_C
HV_SCALE_MIN = [0.01473445910295798,0.18030701050054604,0.4043097419600721]
HV_SCALE_MAX = [0.1612259929049299,0.2817578635269986,0.6878844743274163]
HV_SCALE_RANGE = [0.1464915338019719,0.10145085302645257,0.2835747323673442]
HV_ZERO_RANGE_OBJECTIVE_COUNT = 0
COMMON_NORMALIZATION_USED = YES
INDEPENDENT_NORMALIZATION_H_C = NO
ALL_NORMALIZED_POINTS_WITHIN_UNIT_CUBE = YES
GASLP_INCLUDED_IN_HYPERVOLUME = NO
```

The anchors were derived from `P` and independently matched the frozen global
extrema in CR1-COMP-09. The joint Rank 1 set was not used as an HV input.

## Predefined references

```text
HV_REFERENCE_NORMALIZED_R5 = [1.05,1.05,1.05]
HV_REFERENCE_RAW_R5 = [0.16855056959502848,0.28683040617832123,0.7020632109457835]
HV_REFERENCE_NORMALIZED_R10 = [1.1,1.1,1.1]
HV_REFERENCE_RAW_R10 = [0.1758751462851271,0.29190294882964385,0.7162419475641507]
HV_REFERENCE_NORMALIZED_R20 = [1.2,1.2,1.2]
HV_REFERENCE_RAW_R20 = [0.19052429966532428,0.3020480341322891,0.744599420800885]
PRIMARY_HV_REFERENCE = r10
REFERENCE_POINTS_PREDEFINED = YES
```

## Deterministic methods and implementation QC

The main method is exact finite 3D inclusion-exclusion over 511 nonempty
subsets per source/reference. The independent QC method partitions the union
into Cartesian grid cells and counts each covered cell once. No Monte Carlo,
sampling, point rounding, clipping, or tolerance-based direction change was used.

```text
HV_MAIN_METHOD = INCLUSION_EXCLUSION_3D
HV_QC_METHOD = GRID_CELL_UNION_3D
IMPLEMENTATION_QC_TOLERANCE_ROLE = IMPLEMENTATION_QC_TOLERANCE_ONLY
HV_METHOD_QC_R5 = PASS; MAX_ABS_DIFF=2.220446049250313e-16
HV_METHOD_QC_R10 = PASS; MAX_ABS_DIFF=2.220446049250313e-16
HV_METHOD_QC_R20 = PASS; MAX_ABS_DIFF=2.220446049250313e-16
```

## Results and reference-point sensitivity

```text
HV_H_R5 = 0.8214144073536221
HV_C_R5 = 0.8596538595095115
HV_DIRECTION_R5 = C_GT_H
HV_H_R10 = 0.9749820881940048
HV_C_R10 = 1.0099628901072748
HV_DIRECTION_R10 = C_GT_H
HV_H_R20 = 1.3323674498747686
HV_C_R20 = 1.3592107397484303
HV_DIRECTION_R20 = C_GT_H
HV_H = 0.9749820881940048
HV_C = 1.0099628901072748
HV_DIRECTION = C_GT_H
HV_SENSITIVITY_STATUS = ROBUST_DIRECTION
```

## Permitted interpretation and limitations

El conjunto con mayor hypervolume presenta mayor cobertura del espacio objetivo definido por los anclajes comunes de esta comparación, y la dirección de la diferencia se mantiene para los tres reference points preespecificados.

The scope is `COVERAGE_OF_ANCHORED_OBJECTIVE_SPACE`. The result does not show
distance to a true Pareto front, convergence, statistical superiority,
seed-robustness, integral physical superiority, or a single best solution.

## Final QC and exclusions

```text
ALL_HV_INPUTS_FINITE = YES
ALL_HV_INPUTS_NONPENALIZED = YES
REFERENCE_POINTS_PREDEFINED = YES
INDEPENDENT_QC = PASS
HYPERVOLUME_COMPUTED = YES
HV_ANCHORS_FROZEN = YES
HV_SENSITIVITY_COMPLETED = YES
CR1_COMP_12_COMPUTED = NO
TERMINAL_REGIME_COMPARISON_COMPUTED = NO
OBJECTIVE_DECOMPOSITION_COMPUTED = NO
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
NEW_OPTIMIZATION_RUNS = 0
```

CR1-COMP-12 remains separate and requires explicit authorization.
