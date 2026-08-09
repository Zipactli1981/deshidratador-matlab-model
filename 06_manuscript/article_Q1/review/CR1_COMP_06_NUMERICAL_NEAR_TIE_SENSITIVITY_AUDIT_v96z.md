# CR1-COMP-06 — Numerical Near-tie Sensitivity Audit

## Purpose, protocol, and baseline

This phase audits numerical proximity in the frozen 81-pair CR1-COMP-05 matrix without changing any exact classification.

- Protocol: `CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md`, v1.0, frozen.
- Baseline HEAD: `4843af1ebe91290fb1c255d947329ce488198ab1` (`INPUT_BASELINE_CHECK = PASS`).
- Canonical dataset SHA-256: `4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164` (`PASS`).
- CR1-COMP-05 matrix SHA-256: `C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329` (`PASS`).
- CR1-COMP-05 result SHA-256: `88EE7D86AFEE3A1C5E33D3BD2629995277481A2B65FDF03C83594888402D701A` (`PASS`).

## Diagnostic rule

For each pair and objective, `tau = 1e-12 * max(1, abs(a), abs(b))`; a near-tie is recorded iff `abs(a-b) <= tau`.

`NUMERICAL_THRESHOLD_ROLE = DIAGNOSTIC_ONLY`

The threshold was not used for dominance, equality, rank, or any future coverage calculation.

## Global results

- Objective-level near-ties: 0 of 243.
- Pairs with one or more near-ties: 0 of 81.
- Numerically fragile exact dominance relations: 0 of 3.
- `DOMINANCE_NUMERIC_SENSITIVITY = PASS_NO_FRAGILE_DOMINANCE`.

## Exact dominance relations

| Relation | Strict improvement objectives | abs deltas (f1;f2;f3) | taus (f1;f2;f3) | near-ties (f1;f2;f3) | Fragile |
|---|---|---|---|---|---|
| H02 → C06 | f1;f2;f3 | 0.0026729267746133482; 0.002918940886006749; 0.007637238460506235 | 1e-12; 1e-12; 1e-12 | False; False; False | False |
| C04 → H05 | f1;f2;f3 | 0.008130878637494142; 0.011012615435194495; 0.02892683693892467 | 1e-12; 1e-12; 1e-12 | False; False; False | False |
| H08 → C08 | f1;f2;f3 | 0.000910260210038271; 0.0026730272903455754; 0.007100345897755211 | 1e-12; 1e-12; 1e-12 | False; False; False | False |

All three exact dominance relations remain unchanged.

## Integrity and independent QC

Exact dominance was recomputed read-only from the canonical dataset and matched all 81 frozen CR1-COMP-05 classifications, including the three exact relations. A separate scalar-loop route reproduced all 243 near-tie flags, all 81 pair flags, and all fragility results.

`CR1_COMP_05_EXACT_DOMINANCE_PRESERVED = YES`

`INDEPENDENT_QC = PASS`

## Limitations and actions not executed

A near-tie is not equality, experimental uncertainty, model error, or evidence for tolerant dominance. No classification, Pareto status, or scientific interpretation was changed.

No coverage, joint sorting, hypervolume, MATLAB, objective/model evaluation, replay, gamultiobj, optimization, or CR1-COMP-07+ phase was executed.

## Output hashes

- `cr1_comp_06_numerical_near_tie_sensitivity_v96z.py`: `F2E30CE9C8224E2DDC223871B6D2729A4438B1F91E583A3FA1361C9B730B2CB4`
- `CR1_COMP_06_NUMERICAL_NEAR_TIE_MATRIX_v96z.csv`: `7C3BABCBCFF4BD431FBA0AE13713D7CF6A73F5B8F11EC1A0F67F57D80ECD456E`
- `CR1_COMP_06_NUMERICAL_NEAR_TIE_SUMMARY_v96z.csv`: `0798A891A2E58350D036E297FBB8D7B7A85B669C41166CCBE15BA83580FE1D8C`
- `CR1_COMP_06_NUMERICAL_NEAR_TIE_SENSITIVITY_v96z.json`: `227F88AB15A30A812F222E3608BF9512401A8775AA1CFE9886E6288326F6E3FA`

The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.
