# FINAL_GATE_BEFORE_R1_FORMAL_v96z

## Diagnosis

`FINAL_R1_FORMAL_GATE_PASS`

## Decision

`SAFE_TO_EXECUTE_R1_ONLY`

## Next step

`R1 = run_seedaware_formal_R1_only_v96z_rngfix(true);`

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `GATE01` | Seed-aware clone exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` |
| `GATE02` | R1-only runner exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_seedaware_formal_R1_only_v96z_rngfix.m` |
| `GATE03` | GAOPTS F4 audit exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\traceability\GAOPTS_AUDIT_v96z_before_formal_run_f4.mat` |
| `GATE04` | Model/article audit exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\traceability\MODEL_ARTICLE_AUDIT_v96z.mat` |
| `GATE05` | R1 preparation MAT exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\traceability\SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.mat` |
| `GATE06` | Clone has external seed branch | 1 | `EXTERNAL_SEED_APPLIED + rngSeed.` |
| `GATE07` | Clone formal pop/gen unchanged | 1 | `popSize=24; maxGen=50.` |
| `GATE08` | Clone uses gamultiobj | 1 | `gamultiobj present.` |
| `GATE09` | Clone saves reproducibility outputs | 1 | `X/F/opts/lb/ub/population/scores saved.` |
| `GATE10` | Runner seed fixed to R1 seed 61001 | 1 | `seed = 61001.` |
| `GATE11` | Runner does not include R2/R3 seeds | 1 | `No 61002/61003 in runner.` |
| `GATE12` | Runner calls seed-aware clone | 1 | `Calls seed-aware clone with true, seed.` |
| `GATE13` | Runner keeps execution guard | 1 | `confirm_execute guard present.` |
| `GATE14` | GAOPTS audit is PASS | 1 | `GAOPTS_AUDIT_F4_PASS \| GA_CONFIGURATION_TRACEABLE_BEFORE_FORMAL_RUN` |
| `GATE15` | Model/article audit is PASS | 1 | `MODEL_ARTICLE_AUDIT_PASS \| ARTICLE_METADATA_READY_BEFORE_R1_FORMAL` |
| `GATE16` | R1 prep is ready and not executed | 1 | `SEEDAWARE_FORMAL_R1_ONLY_READY_NO_EXECUTION \| READY_TO_EXECUTE_R1_ONLY_IF_APPROVED \| NOT_EXECUTED` |
| `GATE17` | Run folder writable | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\06_manuscript\article_Q1\runs` |
| `GATE18` | No GA executed by final gate | 1 | `No gamultiobj call.` |
| `GATE19` | Original v96m not modified | 1 | `Read-only gate.` |
