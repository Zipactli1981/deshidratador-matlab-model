# CR1-COMP-08 — Joint Exact Nondominated Sorting Audit

## Purpose and baseline

This phase assigns exact Pareto ranks to the union of the nine historical reevaluated solutions and the nine CORRECTED_R1 solutions.

- Baseline HEAD: `03bf1eb491627407191e9f6f610af5f794a8dd58` (`INPUT_BASELINE_CHECK = PASS`).
- Canonical dataset SHA-256: `4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164` (`PASS`).
- CR1-COMP-02 solution-status SHA-256: `74C33FA77D543FAADA6B9819AF88C133E23D5E283148999849ECF83998D1E5C2` (`PASS`).
- CR1-COMP-05 matrix SHA-256: `C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329` (`PASS`).
- CR1-COMP-06 result SHA-256: `227F88AB15A30A812F222E3608BF9512401A8775AA1CFE9886E6288326F6E3FA` (`PASS`).
- CR1-COMP-07 result SHA-256: `8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83` (`PASS`).

## Exact dominance and sorting method

All three objectives are minimized. A dominates B exactly iff every objective of A is less than or equal to B and at least one is strictly lower. No tolerance, rounding, quantization, solver tolerance, or near-tie rule was used for rank assignment.

The primary route repeatedly identified all zero-dominator solutions in the current residual and removed each complete layer simultaneously. The independent route built the full 18×18 directed dominance graph (excluding the diagonal) and removed zero-indegree layers simultaneously.

## Complete rank composition

- Rank 1: 15 solutions (H=8, C=7); IDs: H01,H02,H03,H04,H06,H07,H08,H09,C01,C02,C03,C04,C05,C07,C09.
- Rank 2: 3 solutions (H=1, C=2); IDs: H05,C06,C08.

Rank 1 contains 8 historical and 7 CORRECTED_R1 solutions.

The Rank 1 name is **joint nondominated set of the 18 evaluated solutions** (conjunto no dominado conjunto de las 18 soluciones evaluadas).

## Upstream consistency and independent QC

Direct comparison of the canonical objective vectors produced only C04→H05, H02→C06, and H08→C08. Thus H05, C06, and C08 are the only initial exclusions from Rank 1, consistent with CR1-COMP-02/05/06/07.

The two sorting routes produced identical ranks and layer memberships for all 18 solutions. Assignment completeness, layer-count sum, integer ranks, Rank 1 indegree, later-rank explanation, dominance/rank monotonicity, and simultaneous layer removal all passed.

`INDEPENDENT_QC = PASS`

## Limited interpretation

When the 18 evaluated solutions are considered jointly under corrected COST-E3D, eight historical and seven CORRECTED_R1 solutions remain nondominated. Historical solutions retain nondominated tradeoffs not replaced by CORRECTED_R1, while CORRECTED_R1 also contributes nondominated tradeoffs absent from the historical set.

This finite-set result does not establish global or statistical superiority, convergence, robustness across seeds, approximation to the true front, expected gamultiobj performance, a single best solution, or physical/economic/environmental mechanisms.

## Actions not executed

No CR1-COMP-09 geometry, figure generation, hypervolume gate, hypervolume, representative-solution decomposition, MATLAB, objective/model evaluation, replay, gamultiobj, optimization, or manuscript modification was executed.

## Output hashes

- `cr1_comp_08_joint_exact_nondominated_sorting_v96z.py`: `45F70AC56A627ECBD546A07E17799069ABF430A4CA3DD6B358F2002D49439F33`
- `CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.csv`: `0E9AE69495E79648056143E2723B1C985380E3E11350EB6A58D1FCD0422C92A9`
- `CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_SUMMARY_v96z.csv`: `8ABADBC9DDEE9D00D6718FE778A0E3675386CBBB19ED2A922D75E765ED9D3FFD`
- `CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.json`: `59E39670F2E3627A752FE5017394D215C13F5D89770C2BE17924A01268317E54`

The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.
