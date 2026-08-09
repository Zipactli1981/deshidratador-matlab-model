# CR1-COMP-03 — Decision-space descriptive analysis audit

## Purpose and scope

This audit records descriptive summaries of the four decision variables in the finite nine-row H and C solution sets. It does not analyze `f1/f2/f3`, perform inference, compare repeated runs, evaluate the model, or execute any later CR1-COMP phase.

```text
ANALYSIS_DESIGNATION = DESCRIPTIVE_SUMMARIES_OF_FINITE_SOLUTION_SETS
BASELINE_HEAD = 790c176c08b8260def410776d72f73e44fd6b27f
INPUT_BASELINE_CHECK = PASS
```

## Canonical input

```text
06_manuscript/article_Q1/review/CR1_COMP_01_CANONICAL_DATASET_v96z.json
SHA-256 = 4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164
CANONICAL_DATASET_SHA256_CHECK = PASS
```

The input contains nine `HIST_R1_REEVAL` and nine `CORRECTED_R1` rows. All four decision variables are finite and inside the frozen bounds.

## D013 numerical conventions

```text
STD_CONVENTION = POPULATION_DDOF_0
std = sqrt(sum((x_i - mean(x))^2) / n)

IQR_CONVENTION = HYNDMAN_FAN_TYPE_7
h = 1 + (n - 1)p
Q1 = quantile(p=0.25, Type 7)
Q3 = quantile(p=0.75, Type 7)
IQR = Q3 - Q1

BOUND_PROXIMITY_RULE = DISTANCES_ONLY_NO_THRESHOLD
```

Type 7 uses linear interpolation between adjacent ordered observations when `h` is not an integer. Bound reporting uses only exact continuous distances and normalized distances. No “near-bound” threshold or class is introduced.

## Median comparison

| Variable | Unit | Median H | Median C | Delta C-H | Normalized delta |
|---|---|---:|---:|---:|---:|
| `m_max` | kg/s | 0.0790661252821967 | 0.0745255561018371 | -0.00454056918035960 | -0.113514229508990 |
| `T_min` | degC | 65.6962846117637 | 67.3130166294735 | 1.61673201770972 | 0.161673201770972 |
| `r_div2` | dimensionless | 0.768305386189501 | 0.638580452778592 | -0.129724933410909 | -0.259449866821818 |
| `t_rec_ini` | h | 13.2180156463987 | 12.6028947102446 | -0.615120936154099 | -0.115013557541938 |

Normalized deltas use exactly `(median_C - median_H)/(ub-lb)` with the frozen bounds.

## Occupied intervals and dispersion

| Variable | H min–max | C min–max | Normalized occupied H | Normalized occupied C | Population std H | Population std C |
|---|---|---|---:|---:|---:|---:|
| `m_max` | 0.0700461425280302–0.0922636604667417 | 0.0703062220788765–0.0919657511022433 | 0.555437948467788 | 0.541488225584170 | 0.00796884057415922 | 0.00785724701414224 |
| `T_min` | 60.1565917725028–67.6750763699670 | 63.4402751227315–67.6575511065566 | 0.751848459746422 | 0.421727598382512 | 2.66375628392234 | 1.67885947260843 |
| `r_div2` | 0.432994031553454–0.788632420409064 | 0.475903977237828–0.757046405475655 | 0.711276777711221 | 0.562284856475653 | 0.107571391732114 | 0.103423329769759 |
| `t_rec_ini` | 12.8744680049588–13.8289200623230 | 12.0497331287218–13.2050964487692 | 0.178460722385794 | 0.216026537030157 | 0.290417514626877 | 0.368851609350096 |

The complete CSV preserves mean, quartiles, IQR, ranges, bounds, and minimum/maximum raw and normalized distances to each bound.

## Permitted descriptive observations

- The C median is lower for `m_max`, `r_div2`, and `t_rec_ini`, and higher for `T_min`, relative to the corresponding H medians.
- C occupies narrower observed intervals for `m_max`, `T_min`, and `r_div2`; it occupies a wider interval for `t_rec_ini`.
- Population standard deviation is descriptively lower in C for the first three variables and higher for `t_rec_ini`.
- The observed C intervals for `m_max`, `T_min`, and `r_div2` lie inside the corresponding H min/max intervals.
- For `t_rec_ini`, C includes observed values below the H minimum, while H includes observed values above the C maximum. This is interval geometry only; no formal “new region” class, clustering, or threshold is asserted.

These are descriptions of the stored finite solution sets. They are not population parameters, between-run statistics, optimizer robustness, convergence evidence, statistical significance, or evidence by themselves of multiobjective superiority.

## QC

An independent ordered-list implementation rechecked min, max, median, range, median delta, and normalized median delta. It agreed exactly with the primary implementation. The audit also verifies `range = max-min`, `IQR = Q3-Q1`, and use of frozen bound widths.

```text
H_ROWS = 9
C_ROWS = 9
VARIABLE_COUNT = 4
ALL_X_FINITE = YES
BOUNDS_CHECK = PASS
INDEPENDENT_QC = PASS
CR1_COMP_03_STATUS = CLOSED_PASS
```

## Output hashes

```text
cr1_comp_03_decision_space_descriptive_v96z.py
SHA-256 = B9FED1F0579001302F8B7F56DA012407B4E377255E5FD5569759BEC6A39DEC11

CR1_COMP_03_DECISION_SPACE_DESCRIPTIVE_v96z.csv
SHA-256 = 46A979A07467D09B7106F887095D3B083165D86681E915F99F77FA98E2995464

CR1_COMP_03_DECISION_SPACE_COMPARISON_v96z.csv
SHA-256 = 07605047C3C5B469A747652BC04FDF82BB2275B6C03842C2765E2C183ACB2CC0

CR1_COMP_03_DECISION_SPACE_DESCRIPTIVE_v96z.json
SHA-256 = 7C0EC833A5BE05148C4B08793A382B7F069B36267C77B97A52959659DBE2A8E8
```

The SHA-256 of this audit document is recorded externally in `00_project_context/04_ARTIFACT_INDEX.md`.

## Explicitly not executed

```text
CR1_COMP_04_COMPUTED = NO
CROSS_DOMINANCE_COMPUTED = NO
NEAR_TIE_COMPUTED = NO
COVERAGE_COMPUTED = NO
JOINT_SORTING_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
HYPOTHESIS_TESTS_COMPUTED = NO
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
PROTOCOL_V1_FILE_MODIFIED = NO
PRODUCTIVE_CODE_MODIFIED = NO
```

CR1-COMP-04 — Objective-space descriptive analysis — requires separate authorization.
