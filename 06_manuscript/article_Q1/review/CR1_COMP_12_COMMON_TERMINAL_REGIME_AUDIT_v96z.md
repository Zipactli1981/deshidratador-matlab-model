# CR1-COMP-12 — Common terminal-regime audit

## Status and scope

```text
CR1_COMP_12_STATUS = CLOSED_PASS
INPUT_BASELINE_HEAD = d3f202db57e98c848b942a8a50fc020a37caaf59
PROTOCOL_VERSION = v1.0
PROTOCOL_SHA256 = 8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
PROTOCOL_SHA256_CHECK = PASS
D014_STATUS = FROZEN_PASS
D014_COMMIT = d3f202db57e98c848b942a8a50fc020a37caaf59
D014_APPLICATION_CHECK = PASS
```

This phase reads only existing documentary sources. It does not evaluate any
solution, execute MATLAB, replay the objective/model, or run optimization.

## Preserved blocking history and resolution

```text
INITIAL_CR1_COMP_12_ATTEMPT = BLOCKED_TERMINAL_REGIME_NOT_MATCHING_FROZEN_EXPECTATION
INITIAL_BLOCK_REASON = EXACT_RAW_FLOAT_COMPARISON_19P900000000000006_VS_19P9
RESOLUTION = D014_FROZEN_IMPLEMENTATION_CONVENTION
```

D014 does not declare floating-point equality. It establishes documentary
horizon equivalence from common TMAX classification, the shared nominal
horizon of 19.9 h, and exact preservation of both source representations.

## Upstream sources and hashes

```text
H_SOURCE = 06_manuscript/article_Q1/review/COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md
H_SOURCE_SHA256 = 7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2
C_SOURCE = 06_manuscript/article_Q1/review/CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.md
C_SOURCE_SHA256 = 40C2F40B2FFE9DEB3B3318453DA0DDE3AD37358101DFB3CAA1C322EB0A8DE3F4
UPSTREAM_HASH_CHECKS = PASS
UPSTREAM_CONSISTENCY_CHECK = PASS
```

H records `TMAX` and `19.900000000000006 h` for all nine reevaluated historical
solutions. C records nine `TMAX_REACHED` classifications inferred from
`dry_time=19.9 h` because objective detail does not propagate the status.

## Results

```text
H_ROWS = 9
C_ROWS = 9
TOTAL_POINTS = 18
H_TMAX_COUNT = 9
C_TMAX_COUNT = 9
H_NORMAL_TERMINATION_COUNT = 0
C_NORMAL_TERMINATION_COUNT = 0
H_DRY_TIME_RAW_MIN = 19.900000000000006
H_DRY_TIME_RAW_MAX = 19.900000000000006
H_DRY_TIME_RAW_UNIQUE_COUNT = 1
C_DRY_TIME_RAW_MIN = 19.9
C_DRY_TIME_RAW_MAX = 19.9
C_DRY_TIME_RAW_UNIQUE_COUNT = 1
RAW_DRY_TIME_VALUES_IDENTICAL = NO
DOCUMENTARY_FLOAT_REPRESENTATION_MISMATCH = YES
SCIENTIFIC_TERMINAL_REGIME_DISCREPANCY = NO
NOMINAL_TERMINAL_HORIZON = 19.9 h
H_COMMON_NOMINAL_19P9H_UNDER_D014 = YES
C_COMMON_NOMINAL_19P9H_UNDER_D014 = YES
COMPARATIVE_TERMINAL_REGIME = COMMON_TMAX_19P9H
TEMPORAL_COMPARABILITY = COMMON_FIXED_HORIZON
TERMINAL_REGIME_LIMITATION = FIXED_HORIZON_NOT_FREE_NORMAL_TERMINATION
```

Los 18 puntos evaluados comparten un régimen terminal TMAX bajo el horizonte
nominal fijo de 19.9 h. Las diferencias H-vs-C en f1/f2/f3 no se explican por
una diferencia trivial del horizonte terminal nominal entre conjuntos.

## Independent QC

```text
H_TERMINAL_UPSTREAM_CONSISTENCY = PASS
C_TERMINAL_UPSTREAM_CONSISTENCY = PASS
H_DRY_TIME_UPSTREAM_CONSISTENCY = PASS
C_DRY_TIME_UPSTREAM_CONSISTENCY = PASS
D014_APPLICATION_CHECK = PASS
RAW_VALUES_PRESERVED_CHECK = PASS
NO_NUMERICAL_TOLERANCE_CHECK = PASS
INDEPENDENT_QC = PASS
```

No numerical tolerance, rounding, truncation, or decimal-place threshold was
used to classify the common horizon. The raw strings remain distinct.

## Limitations and concept separation

The observed trade-offs describe performance at the fixed maximum horizon,
not necessarily solutions that freely reach a normal terminal condition before
the limit. Equal terminal regime does not imply equal thermal trajectories,
energy, LPG, solar contribution, water removed, cost, emissions, or algorithm
convergence.

CORRECTED_R1 optimizer termination at `MaxGenerations` is separate from the
physical simulation termination evaluated here. CR1-COMP-12 addresses only the
latter.

```text
CR1_COMP_13_COMPUTED = NO
OBJECTIVE_DECOMPOSITION_COMPUTED = NO
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
NEW_OPTIMIZATION_RUNS = 0
```
