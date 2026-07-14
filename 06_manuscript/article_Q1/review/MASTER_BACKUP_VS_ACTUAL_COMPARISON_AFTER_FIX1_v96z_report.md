# MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z report

## Identifier

`MASTER-BACKUP-VS-ACTUAL-COMPARISON-AFTER-FIX1-001`

## Mode

`READ_ONLY`

## Diagnosis

`MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_REVIEW_REQUIRED`

## Files

- Current MASTER: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01.md`
- Pre-fix1 backup: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01_BEFORE_SECTION_ORDER_PATCH_FIX1_v96z_20260703_161840.md`
- Current headings: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z_current_headings.txt`
- Backup headings: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z_backup_headings.txt`
- Checks CSV: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_BACKUP_VS_ACTUAL_COMPARISON_AFTER_FIX1_v96z_Tchecks.csv`

## Executive comparison

| item | current MASTER | pre-fix1 backup |
|---|---:|---:|
| Character count | 40156 | 40147 |
| Clean headings | 47 | 44 |
| References clean heading count | 0 | 0 |
| Residual `20#` prefix count | 2 | 5 |
| Discussion internal key count | 1 | 1 |
| Limitations internal key count | 1 | 1 |
| Conclusions internal key count | 1 | 1 |
| Minimum order valid | 0 | 0 |
| Internal key order valid | 0 | 0 |

## Key positions

### Current MASTER

| item | char position | evidence |
|---|---:|---|
| Results and discussion | 4150 | `line=195 char=4150 level=1 raw=# 7. Results and discussion` |
| Discussion heading | 32924 | `line=491 char=32924 level=2 raw=## Discussion` |
| Limitations heading | 29906 | `line=477 char=29906 level=2 raw=## Limitations` |
| Conclusions heading | 37252 | `line=505 char=37252 level=2 raw=## Conclusions` |
| References heading | NaN | `NOT_DETECTED` |
| Discussion internal key | 32939 | `count=1` |
| Limitations internal key | 29922 | `count=1` |
| Conclusions internal key | 37268 | `count=1` |

### Pre-fix1 backup

| item | char position | evidence |
|---|---:|---|
| Results and discussion | 4150 | `line=195 char=4150 level=1 raw=# 7. Results and discussion` |
| Discussion heading | NaN | `NOT_DETECTED` |
| Limitations heading | NaN | `NOT_DETECTED` |
| Conclusions heading | NaN | `NOT_DETECTED` |
| References heading | NaN | `NOT_DETECTED` |
| Discussion internal key | 32939 | `count=1` |
| Limitations internal key | 29922 | `count=1` |
| Conclusions internal key | 37268 | `count=1` |

## Current MASTER evidence

- Minimum order evidence: `Results=4150 | Discussion=32924 | Limitations=29906 | Conclusions=37252 | References=NaN`
- Internal key order evidence: `DiscussionKey=32939 | LimitationsKey=29922 | ConclusionsKey=37268`
- Blocks-before-References evidence: `References not detected as clean heading`
- Glued critical headings: ``
- Glued headings anywhere: `## Status | ## Micropaso | ## Identifier | ## Working title | ## Internal control note | ## 3.1 Context | ## 3.2 Problem | ## 3.3 Gap | ## 3.4 Contribution | ## 3.5 Scope and limitation | ## 5.1 Drying model | ## 5.2 Thermal model | ## 5.3 Solar collector representation | ## 5.4 Operational modes | ## 6.1 Decision variables | ## 6.2 Objective functions | ## 6.3 Constraints and feasibility criterion | ## 6.4 Seed-aware formal run | ## 7.1 Formal tri-objective run | ### Formal tri-objective run | ## 7.2 Collector-efficiency sensitivity | ### Tri-objective optimization results and collector-efficiency sensitivity | ### 7.2.1 Hybrid versus gas-LPG baseline comparison | ## 7.3 Operational interpretation | ### Operational interpretation | ## 7.4 Methodological implications | ### Methodological implications | ## Approved sections | ## Approved tables | ## Restrictions | 0### Reproducibility configuration of the formal multiobjective run | 0### Traceability of economic and CO2 factors | ## Limitations | ## Discussion | ## Conclusions`

## Backup evidence

- Minimum order evidence: `Results=4150 | Discussion=NaN | Limitations=NaN | Conclusions=NaN | References=NaN`
- Internal key order evidence: `DiscussionKey=32939 | LimitationsKey=29922 | ConclusionsKey=37268`
- Blocks-before-References evidence: `References not detected as clean heading`
- Glued critical headings: `0### Limitations | 0### Discussion | 0### Conclusions`
- Glued headings anywhere: `## Status | ## Micropaso | ## Identifier | ## Working title | ## Internal control note | ## 3.1 Context | ## 3.2 Problem | ## 3.3 Gap | ## 3.4 Contribution | ## 3.5 Scope and limitation | ## 5.1 Drying model | ## 5.2 Thermal model | ## 5.3 Solar collector representation | ## 5.4 Operational modes | ## 6.1 Decision variables | ## 6.2 Objective functions | ## 6.3 Constraints and feasibility criterion | ## 6.4 Seed-aware formal run | ## 7.1 Formal tri-objective run | ### Formal tri-objective run | ## 7.2 Collector-efficiency sensitivity | ### Tri-objective optimization results and collector-efficiency sensitivity | ### 7.2.1 Hybrid versus gas-LPG baseline comparison | ## 7.3 Operational interpretation | ### Operational interpretation | ## 7.4 Methodological implications | ### Methodological implications | ## Approved sections | ## Approved tables | ## Restrictions | 0### Reproducibility configuration of the formal multiobjective run | 0### Traceability of economic and CO2 factors | 0### Limitations | 0### Discussion | 0### Conclusions`

## Failed checks

| id | check | evidence |
|---|---|---|
| `CBFX1-13` | Current References clean heading detected | `count=0 pos=NaN summary=NOT_DETECTED` |
| `CBFX1-14` | Backup References clean heading detected | `count=0 pos=NaN summary=NOT_DETECTED` |
| `CBFX1-15` | Current minimum order valid | `Results=4150 | Discussion=32924 | Limitations=29906 | Conclusions=37252 | References=NaN` |
| `CBFX1-16` | Backup minimum order valid | `Results=4150 | Discussion=NaN | Limitations=NaN | Conclusions=NaN | References=NaN` |
| `CBFX1-17` | Current has no residual 20# prefixes | `20#_prefix_count=2` |
| `CBFX1-18` | Backup has no residual 20# prefixes | `20#_prefix_count=5` |
| `CBFX1-19` | Current developed blocks are before References | `References not detected as clean heading` |
| `CBFX1-20` | Backup developed blocks are before References | `References not detected as clean heading` |
| `CBFX1-21` | Current internal developed block order is Discussion -> Limitations -> Conclusions | `DiscussionKey=32939 | LimitationsKey=29922 | ConclusionsKey=37268` |
| `CBFX1-22` | Backup internal developed block order is Discussion -> Limitations -> Conclusions | `DiscussionKey=32939 | LimitationsKey=29922 | ConclusionsKey=37268` |

## Decision support

`RESTORE_PREFIX1_BACKUP_LIKELY_SAFER_BEFORE_FIX2`

The current MASTER shows a post-fix1 tail-insertion signature, while the backup contains the critical developed block keys. A conservative fix2 should preferably start from the pre-fix1 backup after explicit user approval.

## Next step

Do not modify MASTER yet. Review this report first. If restoration is approved, create a separate restoration script that copies the backup to MASTER only after creating a new backup of the current post-fix1 MASTER.
