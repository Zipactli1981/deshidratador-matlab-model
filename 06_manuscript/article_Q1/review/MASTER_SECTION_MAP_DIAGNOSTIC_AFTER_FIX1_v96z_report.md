# MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_v96z report

## Identifier

`MASTER-SECTION-MAP-DIAGNOSTIC-AFTER-FIX1-001`

## Mode

`READ_ONLY`

## Diagnosis

`MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_REVIEW_REQUIRED`

## Files

- MASTER: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01.md`
- Headings report: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_v96z_headings.txt`
- Checks CSV: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_v96z_Tchecks.csv`

## Key positions

| item | char position | evidence |
|---|---:|---|
| Results and discussion | 4150 | `line=195 char=4150 level=1 raw=# 7. Results and discussion` |
| Discussion | 32924 | `line=491 char=32924 level=2 raw=## Discussion` |
| Limitations | 29906 | `line=477 char=29906 level=2 raw=## Limitations` |
| Conclusions | 37252 | `line=505 char=37252 level=2 raw=## Conclusions` |
| References | NaN | `NOT_DETECTED` |

## Internal key positions

| block | char position | count |
|---|---:|---:|
| Discussion key | 32939 | 1 |
| Limitations key | 29922 | 1 |
| Conclusions key | 37268 | 1 |

## Placeholder status

| placeholder | present | char position |
|---|---:|---:|
| # 8. Limitations pending | 1 | 23589 |
| # 9. Conclusions pending | 1 | 24028 |

## Glued heading evidence

- Glued critical headings: ``
- Glued headings anywhere: `## Status | ## Micropaso | ## Identifier | ## Working title | ## Internal control note | ## 3.1 Context | ## 3.2 Problem | ## 3.3 Gap | ## 3.4 Contribution | ## 3.5 Scope and limitation | ## 5.1 Drying model | ## 5.2 Thermal model | ## 5.3 Solar collector representation | ## 5.4 Operational modes | ## 6.1 Decision variables | ## 6.2 Objective functions | ## 6.3 Constraints and feasibility criterion | ## 6.4 Seed-aware formal run | ## 7.1 Formal tri-objective run | ### Formal tri-objective run | ## 7.2 Collector-efficiency sensitivity | ### Tri-objective optimization results and collector-efficiency sensitivity | ### 7.2.1 Hybrid versus gas-LPG baseline comparison | ## 7.3 Operational interpretation | ### Operational interpretation | ## 7.4 Methodological implications | ### Methodological implications | ## Approved sections | ## Approved tables | ## Restrictions | 0### Reproducibility configuration of the formal multiobjective run | 0### Traceability of economic and CO2 factors | ## Limitations | ## Discussion | ## Conclusions`
- Residual `20#` prefix count: `2`

## Failed checks

| id | check | evidence |
|---|---|---|
| `DIAFX1-05` | No glued headings anywhere | `## Status | ## Micropaso | ## Identifier | ## Working title | ## Internal control note | ## 3.1 Context | ## 3.2 Problem | ## 3.3 Gap | ## 3.4 Contribution | ## 3.5 Scope and limitation | ## 5.1 Drying model | ## 5.2 Thermal model | ## 5.3 Solar collector representation | ## 5.4 Operational modes | ## 6.1 Decision variables | ## 6.2 Objective functions | ## 6.3 Constraints and feasibility criterion | ## 6.4 Seed-aware formal run | ## 7.1 Formal tri-objective run | ### Formal tri-objective run | ## 7.2 Collector-efficiency sensitivity | ### Tri-objective optimization results and collector-efficiency sensitivity | ### 7.2.1 Hybrid versus gas-LPG baseline comparison | ## 7.3 Operational interpretation | ### Operational interpretation | ## 7.4 Methodological implications | ### Methodological implications | ## Approved sections | ## Approved tables | ## Restrictions | 0### Reproducibility configuration of the formal multiobjective run | 0### Traceability of economic and CO2 factors | ## Limitations | ## Discussion | ## Conclusions` |
| `DIAFX1-06` | No residual 20# heading prefixes | `20#_prefix_count=2` |
| `DIAFX1-10` | Clean References heading count | `count=0 | NOT_DETECTED` |
| `DIAFX1-11` | Discussion heading level is ### | `level=2` |
| `DIAFX1-12` | Limitations heading level is ### | `level=2` |
| `DIAFX1-13` | Conclusions heading level is ### | `level=2` |
| `DIAFX1-14` | Minimum section order valid: Results -> Discussion -> Limitations -> Conclusions -> References | `Results=4150 | Discussion=32924 | Limitations=29906 | Conclusions=37252 | References=NaN` |
| `DIAFX1-20` | Internal key order: Discussion -> Limitations -> Conclusions | `DiscussionKey=32939 | LimitationsKey=29922 | ConclusionsKey=37268` |
| `DIAFX1-21` | Developed Discussion/Limitations/Conclusions headings are before References | `References not detected as clean heading` |

## Interpretation guide

If internal keys are present once but heading/order checks fail, the problem is structural Markdown assembly rather than missing technical content.

If developed Discussion, Limitations, or Conclusions are after References, fix1 inserted blocks in the wrong manuscript region.

If placeholders remain, a future fix must decide whether to replace placeholders or remove them after relocating developed blocks.

If residual `20###` or glued headings remain, a future fix must normalize line breaks globally before section-order validation.

## Next-step recommendation

`DO_NOT_PATCH_BLINDLY`

Recommended next step: inspect this diagnostic report and decide whether to restore the pre-fix1 backup before applying a conservative fix2.

