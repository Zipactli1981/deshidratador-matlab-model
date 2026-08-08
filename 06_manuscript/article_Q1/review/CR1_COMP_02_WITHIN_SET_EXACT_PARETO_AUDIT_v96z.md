# CR1-COMP-02 — Within-set exact Pareto audit

## Purpose and scope

This postrun audit determines `N_H = ND(H)` and `N_C = ND(C)` independently within the two frozen nine-row sets. It performs no H-vs-C comparison and no model, objective, replay, MATLAB, `gamultiobj`, optimization, descriptive-statistics, near-tie, fragility, coverage, joint-sorting, hypervolume, figure, or interpretation step.

## Baseline and inputs

```text
BASELINE_BRANCH = main
BASELINE_HEAD = 407e9589245e6a2bc7a167b150e7fa233df64201
INPUT_BASELINE_CHECK = PASS

CANONICAL_DATASET_JSON_SHA256 = 4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164
CANONICAL_DATASET_JSON_SHA256_CHECK = PASS
CANONICAL_DATASET_CSV_SHA256 = B17B461FB04C9693FC9DA0C3450703C34E4538894AD232EF7138AE5E9882CD62
CANONICAL_DATASET_CSV_SHA256_CHECK = PASS
DATASET_FREEZE_AUDIT_SHA256 = 52F7E2E6DCEC6A6F6DD65D8BB21BF0B336DBF3981E78F239C6686EDF07254976
DATASET_FREEZE_AUDIT_SHA256_CHECK = PASS
```

The calculation read only `CR1_COMP_01_CANONICAL_DATASET_v96z.json`. Its 18 rows split exactly into nine finite, nonpenalized `HIST_R1_REEVAL` rows and nine finite, nonpenalized `CORRECTED_R1` rows.

## Exact method

All three objectives are minimized. For loaded binary64 objective vectors `a` and `b`, the frozen rule was applied directly:

```text
dominates(a,b) = all(a_k <= b_k) and any(a_j < b_j)
PARETO_DEFINITION = EXACT
DOMINANCE_TOLERANCE = NONE
SOLVER_TOLERANCES_USED_FOR_DOMINANCE = NO
```

Exact objective-vector equality requires equality of all three loaded values. No numerical tolerance or near-tie threshold was used or calculated.

## Results

| Set | Pairs | Nondominated | Dominated | Dominance relations | Incomparable | Exact equal |
|---|---:|---:|---:|---:|---:|---:|
| H | 36 | 9 | 0 | 0 | 36 | 0 |
| C | 36 | 9 | 0 | 0 | 36 | 0 |

```text
N_H = [H01,H02,H03,H04,H05,H06,H07,H08,H09]
N_C = [C01,C02,C03,C04,C05,C06,C07,C08,C09]
```

There are no internally dominated solutions and therefore no internal dominators to list in either set. The pair CSV records all 72 pair classifications explicitly.

## Nomenclature

Because `C_INTERNAL_DOMINATED_COUNT = 0`:

```text
CORRECTED_R1_SET_NOMENCLATURE = NONDOMINATED_APPROXIMATION_ALLOWED
```

This does not authorize the terms true, exact, or global Pareto front. Although all H rows are internally nondominated, H remains a historical reevaluated set and is not a corrected Pareto front.

## Independent QC

The primary predicate uses direct componentwise `<=` and `<`. A separate implementation classifies the sign pattern of the three component differences. Their classifications are identical for all 72 pairs.

For each set, QC also confirms exactly 36 unique unordered pairs, no reversed duplicate, one category per pair, nondominated rows with zero dominators, dominated rows (if any) with at least one dominator, revalidation of every listed dominator, and complement consistency between nondominated cores and dominated status.

```text
H_PAIR_CLASSIFICATION_COMPLETE = PASS
C_PAIR_CLASSIFICATION_COMPLETE = PASS
H_ND_CONSISTENCY = PASS
C_ND_CONSISTENCY = PASS
INDEPENDENT_QC = PASS
CR1_COMP_02_STATUS = CLOSED_PASS
```

## Artifact hashes

```text
cr1_comp_02_within_set_exact_pareto_audit_v96z.py
SHA-256 = 52F4847FAC6E7496BB9A5375B1E2D516AAEFA1FB95832FCDE949B38B1F88E392

CR1_COMP_02_WITHIN_SET_EXACT_PARETO_AUDIT_v96z.csv
SHA-256 = DFB1166421020DAFAEBCBC4117B9CC203BCB4F98154A367AA11D6D2C7762B51E

CR1_COMP_02_WITHIN_SET_SOLUTION_STATUS_v96z.csv
SHA-256 = 74C33FA77D543FAADA6B9819AF88C133E23D5E283148999849ECF83998D1E5C2

CR1_COMP_02_WITHIN_SET_EXACT_PARETO_AUDIT_v96z.json
SHA-256 = 6E5391E6D8C65AD04C91EB1A00EE16360D5EE189AF77B67B911CA5B31281CCED
```

The SHA-256 of this audit document is recorded externally in `00_project_context/04_ARTIFACT_INDEX.md`, avoiding a self-referential hash.

## Explicitly not executed

```text
NEAR_TIE_DIAGNOSTIC_COMPUTED = NO
NUMERIC_FRAGILITY_COMPUTED = NO
CROSS_DOMINANCE_COMPUTED = NO
COVERAGE_COMPUTED = NO
JOINT_SORTING_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
PROTOCOL_V1_FILE_MODIFIED = NO
PRODUCTIVE_CODE_MODIFIED = NO
```

## Limitation and next gate

This result describes only exact internal dominance among the stored objective vectors in each frozen set. It supplies no cross-set evidence and no comparative interpretation. CR1-COMP-03 — Decision-space descriptive analysis — requires separate authorization.
