# PATCH_SECTION07_v01_1_AUDIT_FAILURES_v96z report

## Diagnosis

`PATCH_SECTION07_v01_1_AUDIT_FAILURES_PASS`

## Decision

`READY_TO_RERUN_SECTION07_v01_1_AUDIT`

## Next step

`Rerun audit_results_section07_v01_1_hybrid_vs_gasLP_v96z.`

## Files

- Master: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01.md`
- Backup: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01_BACKUP_before_SEC07_v01_1_patch_20260702_105058.md`
- Checks: `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\review\PATCH_SECTION07_v01_1_AUDIT_FAILURES_v96z_Tchecks.csv`

## Patch notes

- Added explicit fully coupled collector model caveat if missing.
- Added explicit R1_solution_3 gas-LPG/hybrid kWh anchor if missing.
- Added explicit R1_solution_9 gas-LPG/hybrid kWh anchor if missing.
- No GA executed.
- No model executed.
- No numerical results modified.

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `P07-01` | Master exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01.md` |
| `P07-02` | Backup created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\draft_sections\MASTER_manuscript_v01_BACKUP_before_SEC07_v01_1_patch_20260702_105058.md` |
| `P07-03` | Master changed | 1 | `Patch modified MASTER text.` |
| `P07-04` | Fully coupled collector caveat present | 1 | `S0711-33 patch.` |
| `P07-05` | R1-3 baseline anchor present | 1 | `S0711-47 patch.` |
| `P07-06` | R1-9 baseline anchor present | 1 | `S0711-48 patch.` |
| `P07-07` | No GA executed | 1 | `Text patch only.` |
| `P07-08` | No model executed | 1 | `Text patch only.` |
| `P07-09` | No numeric results changed intentionally | 1 | `Only explicit anchor/unit text was inserted.` |
