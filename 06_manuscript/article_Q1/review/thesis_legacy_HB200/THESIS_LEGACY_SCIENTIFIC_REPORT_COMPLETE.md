# THESIS-LEGACY-REEVALUATION-R1 — Complete scientific report

## Scope and identity

This campaign deterministically reevaluated all unique finite physical designs recoverable from the HB200 thesis-era checkpoint. It did not execute an optimizer, introduce a random seed, change C, edit the manuscript, or claim convergence/global Pareto status.

- Source rows: 50 finite rows, comprising 44 exact unique designs and six repeated rows.
- Source population SHA-256: `CA40083629C97A7851A15219F46ACF22C7C5AFE4EC09190E5BBA9618106977B9`.
- Source scores SHA-256: `F1D4A1AD85A533CE41D87FEAA04651B9604607E3D3F527EA5A3FCDA11971FD9B`.
- MATLAB: 26.1.0.3312084, R2026a Update 4.
- Global Optimization Toolbox: 26.1 (present but not invoked).
- Productive model SHA-256: `F89728AC6624E1008B101A6F9A1F3D9B4E42618512C50D0FF8A429960F845D15`.
- Current objective SHA-256: `9BA3741DA0E079BF784CEE3EA8B965516800DED9562D7C733CDD29EDA47F3D34`.
- Environment data SHA-256: `AD1FBD0F2E1B75F0EAFE752D24A5764306CA6DEABB975BFDD8D4371402A6F6F0`.

## Recirculation mapping

The thesis-era objective implementation fixes `t_rec_ini=0`. The historical wrapper converts this input from hours to seconds and activates the recirculation branch for `t>t_rec_ini`, with an initial time node at zero. Its physical meaning is therefore recirculation without a scheduled delay, active immediately after the initial node; it is not recirculation disabled.

The current productive objective accepts `t_rec=0` within its physical evaluation bounds `[0,19]`. The narrower C search interval does not define physical validity, and no bound check or productive equation had to be bypassed.

## Complete-cohort reevaluation

All 44 unique designs were evaluated before any current-objective filtering. Every case returned `status=OK`; 31 terminated at the 19.9 h horizon and 13 reached the target-moisture stopping condition.

Current objective ranges over all T designs:

| Objective | Minimum | Maximum | Minimum ID |
|---|---:|---:|---|
| `f1`, terminal MR | 0.0035320102535161 | 0.859633406693637 | T009 |
| `f2`, USD/kg water removed | 0.190871677239541 | 0.722326072492117 | T004 |
| `f3`, kg CO2e/kg water removed | 0.417328193734770 | 1.56832750102671 | T004 |

Recovered decision ranges were `m_max=0.0716575–0.190087`, `T_min=45.1630–69.9302 °C`, and `r_rec=0.0004756–0.830656`. These are properties of the recovered HB200 portfolio, not current C search bounds.

## Evaluation-basis persistence

Historical nondominance was recomputed independently from the stored HB200 score vectors. Raw historical magnitudes were not mixed with current objective magnitudes.

| Transition | Count | Exact identities |
|---|---:|---|
| Persistent nondominated | 6 | T004, T015, T025, T028, T035, T036 |
| Lost nondominated status | 10 | T003, T006, T014, T017, T018, T021, T027, T029, T030, T044 |
| Gained nondominated status | 3 | T009, T012, T038 |
| Dominated in both | 25 | See TABLE_T3 |

Thus 9/44 thesis designs are nondominated under the current formulation: `T004, T009, T012, T015, T025, T028, T035, T036, T038`.

The 10 losses and three gains demonstrate that operating-design attractiveness depends materially on the evaluation/accounting basis. The six persistent designs support physically persistent multiobjective merit within the evaluated finite portfolio. Neither statement establishes optimizer robustness or behavior outside the evaluated designs.

## Thesis-reported compromise

The thesis-reported compromise is `T025`, source row 28:

```text
X = [0.0772835810847959, 66.8394741224401, 0.335274383504255]
t_rec = 0 h
F_current = [0.0337092930359653, 0.219375216857587, 0.519403503839552]
```

It remains nondominated within the reevaluated thesis set and is one of the six persistent designs. In the combined T-current-ND plus C portfolio it has joint rank 2 because `C05` dominates it. It is therefore still competitive within its historical-design cohort, but not retained in the joint first nondominated layer.

## T versus frozen current C

The comparison uses the nine current-nondominated thesis designs and the nine frozen C designs on the same current objective basis.

```text
T-dominates-C pairs = 2
C-dominates-T pairs = 6
Incomparable pairs  = 73
Exact-equality pairs = 0
```

Exact dominance links:

- `T036` dominates `C01` and `C08`.
- `C02`, `C03`, `C04`, `C05`, and `C09` dominate `T012`.
- `C05` dominates `T025`.

The joint first nondominated layer contains seven T designs (`T004, T009, T015, T028, T035, T036, T038`) and seven C designs (`C02, C03, C04, C05, C06, C07, C09`). The high incomparability, reciprocal dominance, and contributions from both provenances rule out uniform replacement of one portfolio by the other.

T and C were generated in different decision spaces. T used three optimized controls and fixed timing; C used four controls. Direct T-versus-C differences therefore remain partially confounded between search provenance/control-space expansion and portfolio composition, even though every displayed objective uses one common current basis.

## Current gas-LPG context

Three unique representative designs were prespecified because the minimum-`f2` and minimum-`f3` categories coincide at `T004`: `T025` (reported compromise), `T009` (minimum `f1`), and `T004` (minimum `f2/f3`). Gas-LPG remains contextual and was excluded from T/C dominance.

Hybrid-minus-gas-LPG changes under current accounting:

| ID | Δf1 | Δf2 | Δf3 | Δwater removed, kg | Δuseful auxiliary heat, MJ | ΔLPG input, MJ | Δtotal cost, USD | Δemissions, kg CO2e |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| T025 | 0 | -0.0438541 | -0.217059 | 0 | -432.308 | -554.241 | -7.27758 | -36.0209 |
| T009 | 0 | -0.0525144 | -0.237251 | 0 | -487.281 | -624.719 | -8.98692 | -40.6013 |
| T004 | -0.0453565 | -0.0707238 | -0.329386 | +7.78948 | -407.150 | -521.987 | -6.49528 | -33.9246 |

For all three representatives, hybrid operation reduces current cost and emissions. For T025 and T009 this occurs without changing terminal MR or water removal; for T004, hybrid operation also produces deeper drying and greater water removal.

## Prespecified recirculation-timing experiment

The fixed variables were `m_max`, `T_min`, and `r_rec`. Timing levels were frozen before inspection at `0`, `8.6517528081`, `11.32587640405`, and `14 h`. Twelve timing evaluations were executed.

Materiality was prespecified as any of: `|Δf1|≥0.001`, `|Δf2/f2_ref|≥1%`, `|Δf3/f3_ref|≥1%`, or `|ΔQaux/Qaux_ref|≥1%`. All three representative designs met this criterion.

- T004: delaying recirculation lowered MR substantially, while cost/emissions and auxiliary heat responded nonmonotonically; none of the delayed levels uniformly improved all objectives.
- T009: delayed recirculation increased cost, emissions, and auxiliary heat; MR changed slightly and nonmonotonically.
- T025: later recirculation progressively lowered MR, but generally increased cost, emissions, and auxiliary heat, with a small local nonmonotonicity in cost.

The observed campaign-level direction is `NONMONOTONIC`. Timing is a meaningful additional control degree of freedom because it changes otherwise identical physical designs, but the effect is a design-dependent trade-off. No optimum, global monotonicity, causal trajectory mechanism, or global sensitivity is claimed.

## Determinism and decomposition audit

Three distinct sentinel designs were reevaluated with identical inputs. MR, water removal, auxiliary heat, LPG use, total cost, emissions, `f1/f2/f3`, and terminal regime were exactly equal; maximum absolute difference was zero.

The current objectives reproduce from persisted decomposition. CSV reconstruction differences were at most `7.11×10⁻¹⁵`; the red-team threshold was set to `10⁻¹³` solely to accommodate decimal serialization, while canonical MAT data retain full precision.

```text
DETERMINISM_CHECK = EXACT
RED_TEAM_STATUS = PASS
TOTAL_MODEL_EVALUATIONS = 62
```

The 62 evaluations comprise 44 baseline cases, three sentinel repeats, three gas-LPG contextual cases, and 12 timing cases.

## Answers to the 24 scientific questions

1. **Unique finite HB200 designs:** 44.
2. **Historically nondominated:** 16.
3. **Currently nondominated:** 9.
4. **Persistent historical ND:** T004, T015, T025, T028, T035, T036.
5. **Lost historical ND:** T003, T006, T014, T017, T018, T021, T027, T029, T030, T044.
6. **Historically dominated that gained ND status:** T009, T012, T038.
7. **Does the thesis compromise remain competitive?** Yes within T; it is joint rank 2 against C.
8. **Compromise current status:** `F=[0.0337092930, 0.2193752169, 0.5194035038]`, T-rank 1, joint rank 2.
9. **Thesis designs dominating C:** T036 dominates C01 and C08.
10. **C designs dominating thesis designs:** C02/C03/C04/C05/C09 dominate T012; C05 dominates T025.
11. **T/C incomparability:** 73 of 81 pairs.
12. **T contribution to joint Rank 1:** seven designs.
13. **Physically persistent merit:** supported for six persistent designs, within the finite-set scope.
14. **Evaluation-basis-dependent attractiveness:** supported by 10 losses and three gains.
15. **Historical timing implementation:** fixed `t_rec_ini=0`, converted to seconds, with recirculation conditions active after the initial node.
16. **Timing category:** effectively fixed from the beginning/no scheduled delay.
17. **Material timing effect:** yes for all three prespecified representative designs.
18. **Effect direction:** nonmonotonic overall and design/objective dependent.
19. **Meaningful added control:** yes, as a trade-off-shaping control; no optimum is inferred.
20. **Can both effects be fully separated?** Same-design status changes isolate an evaluation-basis effect; paired timing isolates local timing effects, but direct T/C portfolio differences are not fully separable.
21. **Remaining confounding:** different search provenance, three- versus four-variable generation spaces, and finite portfolio composition.
22. **Preferred legacy baseline:** HB200 is scientifically preferable because it is thesis-era and the full unique cohort was reevaluated consistently.
23. **Role of R1 50-generation set:** retain only as an auxiliary controlled/comparability portfolio, not historical operating evidence.
24. **v04 redesign:** scientifically justified around gas-LPG context → thesis-era designs → common-basis reevaluation → current C → recirculation-timing insight, subject to explicit future manuscript authorization.

## Scientific decision

HB200 should replace the later R1 50-generation set as the primary legacy scientific provenance in a future authorized manuscript redesign. The R1 set remains useful only as an auxiliary controlled reference. This conclusion does not require resolving HB200 as generation 316 or as a globally final front; its defensible identity is a recovered thesis-era optimization checkpoint containing the thesis-reported compromise.

No unresolved issue blocks scientific review of this deterministic campaign.

```text
HUMAN_REVIEW_REQUIRED = NO
```
