# CR1-COMP-05 — Exact Cross-dominance Audit

## Objective and baseline

This phase classifies the complete Cartesian matrix H01...H09 × C01...C09 using only the three minimized objectives in the frozen canonical JSON.

- Baseline HEAD: `ae33626571c18000f37c3205dfc622f557c4d4fc` (`INPUT_BASELINE_CHECK = PASS`).
- Input: `06_manuscript/article_Q1/review/CR1_COMP_01_CANONICAL_DATASET_v96z.json`.
- Input SHA-256: `4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164` (`PASS`).
- Gate: 18 rows; H = 9; C = 9; three finite objectives per row; no penalty rows; IDs and order exact.

## Exact definition

All objectives are minimized. A dominates B iff every component of A is <= the corresponding component of B and at least one is strictly lower.

`PARETO_DEFINITION = EXACT_FULL_PRECISION`

`DOMINANCE_TOLERANCE = NONE`

`SOLVER_TOLERANCES_USED_FOR_DOMINANCE = NO`

No rounding, quantization, isclose, eps, absolute tolerance, relative tolerance, FunctionTolerance, or ConstraintTolerance was used.

## Global counts

| Category | Count |
|---|---:|
| C_DOMINATES_H | 1 |
| H_DOMINATES_C | 2 |
| INCOMPARABLE | 78 |
| EXACT_EQUAL | 0 |

The four mutually exclusive counts sum to 81 of 81 pairs.

## Direct per-solution observations

- Highest C→H dominance count: 1, attained by C04.
- Highest H→C dominance count: 1, attained by H02, H08.
- These are direct matrix counts, not coverage metrics or a selection of a best solution.

## Independent QC

A second classifier based on all/any boolean vectors reproduced all 81 classifications. Pair uniqueness, mutual exclusivity, category semantics, global-count sum, and per-solution marginal sums passed.

`INDEPENDENT_QC = PASS`

## Limitations and actions not executed

The matrix supports only exact pairwise statements. It does not establish global superiority, coverage, joint Rank 1, statistical significance, convergence, robustness, causality, or a best solution.

No near-tie or numerical-fragility audit, coverage, joint sorting, hypervolume, MATLAB, model/objective evaluation, replay, gamultiobj, optimization, or later CR1-COMP phase was executed.

`CR1_COMP_06_COMPUTED = NO`

`NEAR_TIE_COMPUTED = NO`

`COVERAGE_COMPUTED = NO`

## Output hashes

- `cr1_comp_05_exact_cross_dominance_v96z.py`: `A36FFE36EABEDB04DD595FE541C25277DC0732616ADA5A6802CEFCBBFEF64D18`
- `CR1_COMP_05_EXACT_CROSS_DOMINANCE_MATRIX_v96z.csv`: `C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329`
- `CR1_COMP_05_EXACT_CROSS_DOMINANCE_SUMMARY_v96z.csv`: `AA879302D099C4510FD99B1751E59A3C45B9C2FDA28F69439F66DF7E20F7D18F`
- `CR1_COMP_05_EXACT_CROSS_DOMINANCE_v96z.json`: `88EE7D86AFEE3A1C5E33D3BD2629995277481A2B65FDF03C83594888402D701A`

The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.
