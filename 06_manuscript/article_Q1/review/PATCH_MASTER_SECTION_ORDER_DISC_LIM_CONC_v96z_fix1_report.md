# PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_fix1 report

## Diagnosis

`PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_FIX1_REVIEW_REQUIRED`

## Decision

`INSPECT_FAILED_CHECKS`

## Next step

`Inspect failed checks and headings reports before modifying again.`

## Patch action

`MASTER_UPDATED`

## Location evidence

`Reinserted Discussion -> Limitations -> Conclusions at end because References was not detected.`

## Root cause

Critical headings were present but glued to preceding text, e.g. `20### Discussion`; strict Markdown extraction failed.

## Files

- MASTER: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01.md`
- Backup: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01_BEFORE_SECTION_ORDER_PATCH_FIX1_v96z_20260703_161840.md`
- Checks: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\PATCH_MASTER_SECTION_ORDER_DISC_LIM_CONC_v96z_fix1_Tchecks.csv`
- Headings before: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_HEADINGS_DETECTED_v96z_section_order_patch_fix1_before.txt`
- Headings after: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_HEADINGS_DETECTED_v96z_section_order_patch_fix1_after.txt`

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `SFX1-01` | MASTER exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01.md` |
| `SFX1-02` | Locked Section 7 exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\locked_sections\RESULTS_SECTION_07_v01_1_LOCKED.md` |
| `SFX1-03` | Backup created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01_BEFORE_SECTION_ORDER_PATCH_FIX1_v96z_20260703_161840.md` |
| `SFX1-04` | Headings before report created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_HEADINGS_DETECTED_v96z_section_order_patch_fix1_before.txt` |
| `SFX1-05` | Headings after report created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\MASTER_HEADINGS_DETECTED_v96z_section_order_patch_fix1_after.txt` |
| `SFX1-06` | Discussion detected after normalization | 1 | `Discussion span` |
| `SFX1-07` | Limitations detected after normalization | 1 | `Limitations span` |
| `SFX1-08` | Conclusions detected after normalization | 1 | `Conclusions span` |
| `SFX1-09` | Patch action valid | 1 | `MASTER_UPDATED` |
| `SFX1-10` | Discussion key present once | 1 | `Discussion key count` |
| `SFX1-11` | Limitations key present once | 1 | `Limitations key count` |
| `SFX1-12` | Conclusions key present once | 1 | `Conclusions key count` |
| `SFX1-13` | Discussion title present once | 0 | `Discussion title count` |
| `SFX1-14` | Limitations title present once | 0 | `Limitations title count` |
| `SFX1-15` | Conclusions title present once | 0 | `Conclusions title count` |
| `SFX1-16` | No glued critical headings remain | 1 | `No text immediately before ### critical headings` |
| `SFX1-17` | Minimum section order valid | 0 | `Results -> Discussion -> Limitations -> Conclusions -> References` |
| `SFX1-18` | Section 7 preserved when detectable | 1 | `Section 7 comparison` |
| `SFX1-19` | No prohibited global optimum wording | 1 | `No prohibited wording` |
| `SFX1-20` | No prohibited global Pareto front wording | 1 | `No prohibited wording` |
| `SFX1-21` | No statistical robustness claim | 1 | `No overclaim` |
| `SFX1-22` | No final CO2 claim | 1 | `No final CO2 claim` |
| `SFX1-23` | No final cost claim | 1 | `No final cost claim` |
| `SFX1-24` | No GA executed | 1 | `Text normalization/reordering only` |
| `SFX1-25` | No model executed | 1 | `Text normalization/reordering only` |
