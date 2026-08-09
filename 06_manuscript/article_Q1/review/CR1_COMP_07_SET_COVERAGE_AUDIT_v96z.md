# CR1-COMP-07 — Set Coverage Audit

## Purpose and baseline

This phase calculates asymmetric full-set and internally nondominated-core coverage using only frozen exact cross-dominance relations and audited CR1-COMP-02 memberships.

- Baseline HEAD: `2b22bf342c3ec0e2d5c22ab4da33c566f6521c93` (`INPUT_BASELINE_CHECK = PASS`).
- CR1-COMP-05 matrix SHA-256: `C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329` (`PASS`).
- CR1-COMP-05 result SHA-256: `88EE7D86AFEE3A1C5E33D3BD2629995277481A2B65FDF03C83594888402D701A` (`PASS`).
- CR1-COMP-02 solution-status SHA-256: `74C33FA77D543FAADA6B9819AF88C133E23D5E283148999849ECF83998D1E5C2` (`PASS`).

## Definitions

For coverage C(A,B), the numerator is the number of distinct target solutions in B dominated exactly by at least one source solution in A; the denominator is the number of target solutions. Multiple pairwise dominances of one target count once.

Full coverage uses all nine solutions per set. Core coverage restricts source and target membership to `N_C` and `N_H` from CR1-COMP-02. Exact full-precision dominance is used without tolerance or near-tie reclassification.

## Memberships

- Historical solutions dominated by at least one C: H05.
- CORRECTED_R1 solutions dominated by at least one H: C06, C08.
- `N_H = H01...H09` and `N_C = C01...C09`; therefore full/core equality is an expected structural check for this dataset.

## Results

| Metric | Fraction | Coverage | Percent |
|---|---:|---:|---:|
| FULL_COVERAGE_C_OVER_H | 1/9 | 0.1111111111111111 | 11.11111111111111 |
| FULL_COVERAGE_H_OVER_C | 2/9 | 0.2222222222222222 | 22.22222222222222 |
| CORE_COVERAGE_NC_OVER_NH | 1/9 | 0.1111111111111111 | 11.11111111111111 |
| CORE_COVERAGE_NH_OVER_NC | 2/9 | 0.2222222222222222 | 22.22222222222222 |

`FULL_CORE_COVERAGE_EQUALITY_CHECK = PASS`

Core coverage has interpretive priority for statements about the internally nondominated approximations, but these asymmetric metrics do not establish a true Pareto front, convergence, global superiority, or joint Rank 1 composition.

## Independent QC

The primary route formed unique dominated-ID sets from matrix relations. An independent route evaluated, for every target solution, whether at least one exact relation from the other set exists. Both routes produced identical memberships, numerators, denominators, and four coverage values.

`INDEPENDENT_QC = PASS`

## Actions not executed

No joint nondominated sorting, ParetoRank, hypervolume gate, hypervolume, MATLAB, objective/model evaluation, replay, gamultiobj, optimization, or CR1-COMP-08+ phase was executed.

## Output hashes

- `cr1_comp_07_set_coverage_v96z.py`: `1509A7DBF0EC40672002A80136CAFB18735C60A790C5949ED43B1D3E9A993DAB`
- `CR1_COMP_07_SET_COVERAGE_v96z.csv`: `006DE140768490BF4903F266C2D205AAC8B2F1BF4A44E8F836179842825206FF`
- `CR1_COMP_07_SET_COVERAGE_MEMBERSHIP_v96z.csv`: `66A04A61A1D4854267A17C92F7CC3F5E7050C85AF896B75BB038171E32920500`
- `CR1_COMP_07_SET_COVERAGE_v96z.json`: `8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83`

The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.
