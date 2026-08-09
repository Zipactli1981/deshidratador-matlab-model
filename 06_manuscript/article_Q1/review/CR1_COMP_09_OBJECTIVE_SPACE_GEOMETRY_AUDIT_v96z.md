# CR1-COMP-09 — Objective-space Geometry Audit

## Purpose and scope

This phase characterizes the descriptive geometry of the finite H and C solution sets in the f1–f2, f1–f3, f2–f3, and f1–f2–f3 views.

- Baseline HEAD: `52cefdf4b1656a9f22903124ec4147b6ad671160` (`INPUT_BASELINE_CHECK = PASS`).
- protocol SHA-256: `8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3` (`PASS`).
- dataset SHA-256: `4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164` (`PASS`).
- objective_descriptive SHA-256: `CCA35B4E8983D075E9D3E4834949B2A2F330C5A8C0C5B4D1EA05E935AEE1D75D` (`PASS`).
- cross_dominance SHA-256: `C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329` (`PASS`).
- near_tie SHA-256: `227F88AB15A30A812F222E3608BF9512401A8775AA1CFE9886E6288326F6E3FA` (`PASS`).
- coverage SHA-256: `8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83` (`PASS`).
- sorting_csv SHA-256: `0E9AE69495E79648056143E2723B1C985380E3E11350EB6A58D1FCD0422C92A9` (`PASS`).
- sorting_json SHA-256: `59E39670F2E3627A752FE5017394D215C13F5D89770C2BE17924A01268317E54` (`PASS`).

## Methodological restriction

`ANALYSIS_DESIGNATION = DESCRIPTIVE_GEOMETRY_OF_FINITE_EVALUATED_SETS`

No objective normalization, hull area/volume, density, clustering, PCA, distance, overlap percentage, interpolation, regression, curvature, or new threshold was used. Pixel/axis mapping in figures is display-only and does not create an analytical metric.

## Observed numeric geometry

- `f1` [OBSERVED_NUMERIC_GEOMETRY]: H=[0.01473445910295798, 0.1612259929049299] (range=0.1464915338019719); C=[0.015163555853391462, 0.0976824159460894] (range=0.08251886009269793); delta range C−H=-0.06397267370927398. H extrema IDs=H09,H01; C extrema IDs=C01,C03.
- `f2` [OBSERVED_NUMERIC_GEOMETRY]: H=[0.18030701050054604, 0.2817578635269986] (range=0.10145085302645257); C=[0.18471976529485853, 0.2712071587404825] (range=0.08648739344562398); delta range C−H=-0.014963459580828592. H extrema IDs=H01,H09; C extrema IDs=C02,C01.
- `f3` [OBSERVED_NUMERIC_GEOMETRY]: H=[0.4043097419600721, 0.6878844743274163] (range=0.2835747323673442); C=[0.42177467537964236, 0.6595831664180842] (range=0.23780849103844187); delta range C−H=-0.045766241328902335. H extrema IDs=H01,H09; C extrema IDs=C03,C01.

C has no observed objective minimum or maximum outside the corresponding H interval. H extends below and above the C interval in each individual objective. Consequently all three C observed ranges are narrower; this is not called contraction of a Pareto front.

Frozen CR1-COMP-04 median shifts are consistent with lower median f1 for C and higher median f2/f3 for C. No translation score was defined.

## Projection and 3D observations

- `f1-f2` [QUALITATIVE_GEOMETRIC_OBSERVATION]: C occupies narrower marginal intervals nested within H on both axes; frozen medians shift toward lower f1 and higher f2.
- `f1-f3` [QUALITATIVE_GEOMETRIC_OBSERVATION]: C occupies narrower marginal intervals nested within H on both axes; frozen medians shift toward lower f1 and higher f3.
- `f2-f3` [QUALITATIVE_GEOMETRIC_OBSERVATION]: C occupies narrower marginal intervals nested within H on both axes; frozen medians are higher for both f2 and f3.
- `f1-f2-f3` [QUALITATIVE_GEOMETRIC_OBSERVATION]: The clouds are visually interleaved inside shared marginal ranges, while H retains observed low and high marginal extremes in all three objectives.

All 18 points, including Rank 2 H05, C06, and C08, appear in every applicable figure. Points are not connected, interpolated, smoothed, or treated as a continuous front.

## Dominance, rank, and descriptive synthesis

[OBSERVED_NUMERIC_GEOMETRY] Cross-set structure is predominantly incomparable: C→H=1, H→C=2, incomparable=78. Rank 1 contains eight H and seven C solutions; Rank 2 contains H05, C06, and C08.

[OBSERVED_NUMERIC_GEOMETRY] The seven C Rank 1 solutions are CORRECTED_R1 contributions to the joint nondominated set with no exact H duplicate. The eight H Rank 1 solutions are retained historical contributions.

[DESCRIPTIVE_SYNTHESIS] `TRADEOFF_RESTRUCTURING_OBSERVED = YES`: range/extreme and frozen-median changes coexist with Rank 1 contributions from both sets and an absence of uniform replacement by dominance.

This does not establish global/statistical superiority, convergence, robustness, approximation to a true Pareto front, causality, or a single best solution.

## Independent QC

Coordinate identity, ParetoRank identity, CR1-COMP-04 min/max/range identity, Rank 2 identity, figure point counts, absence of normalization, and upstream scope all passed.

`INDEPENDENT_QC = PASS`

`GLOBAL_MINIMUM_VISUALIZATION_SUITE_COMPLETE = NO`

## Actions not executed

No CR1-COMP-10 hypervolume gate, hypervolume, terminal-regime analysis, objective decomposition, physical/economic/environmental interpretation, MATLAB, objective evaluation, replay, gamultiobj, or optimization was executed.

## Output hashes

- `cr1_comp_09_objective_space_geometry_v96z.py`: `B78E1E4FB49148859B64C0AAE65172566549AFA400BA736F456278D38645C70B`
- `CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_v96z.csv`: `AA23DE51FA5F042E65531AFA7F1FE788AC3CC6C233014C8A93E8586D8946D3D6`
- `CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_SUMMARY_v96z.csv`: `1B56D53CADFEE52C4FC4180202D9D2933213767546C010DB0145131617D71459`
- `CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_v96z.json`: `BD23627AAF81BD4231A3D84D819422D3CE93F84EDF0F33995A238DE3CE5651F9`
- `CR1_COMP_09_F1_F2_v96z.png`: `55B2907831EA866125E96E3D497F298F6A91CD85239EFB8C53C72898BFB3EAC2`
- `CR1_COMP_09_F1_F3_v96z.png`: `05EE6663A057F67A381485E549156CB1A0768AD928AC52CFC42C5C5B04EF63AB`
- `CR1_COMP_09_F2_F3_v96z.png`: `572D5126ED046FF3F35B5DC771C20B8D5B814B06A0AA56864231DC0A29F04223`
- `CR1_COMP_09_F1_F2_F3_3D_v96z.png`: `7F58A45414766818E42948B52EECCD98B18EE327BE7C6F3378234B9A176E73AF`

The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.
