# BUILD_SEEDAWARE_MINREP_RUNNER_v96z_rngfix_d

## Diagnosis

`SEEDAWARE_MINREP_RUNNER_BUILD_PASS`

## Decision

`SEEDAWARE_MINREP_READY_FOR_APPROVAL_GATE`

## Next step

`9.6z-rngfix-e — APPROVE-SEEDAWARE-MINREP-EXECUTION-001`

## Runner

`C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_seedaware_minrep_formal_ga_v96z_rngfix.m`

## Approval gate

`C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\approve_seedaware_minrep_execution_v96z_rngfix.m`

## Seed-aware clone

`C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m`

## Expected runtime

`50.1363 h`

## Replicates

| Rep | Seed | Pop | Gen | Expected runtime h |
|---|---:|---:|---:|---:|
| R1 | 61001 | 24 | 50 | 16.7121 |
| R2 | 61002 | 24 | 50 | 16.7121 |
| R3 | 61003 | 24 | 50 | 16.7121 |

## Checks

| id | check | pass | evidence |
|---|---|---:|---|
| `RNG_D01` | Seed-aware clone exists | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` |
| `RNG_D02` | Runner created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\run_seedaware_minrep_formal_ga_v96z_rngfix.m` |
| `RNG_D03` | Approval gate created | 1 | `C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA\02_src_limpio\production\approve_seedaware_minrep_execution_v96z_rngfix.m` |
| `RNG_D04` | Runner calls seed-aware clone | 1 | `run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix` |
| `RNG_D05` | Runner passes seed into clone | 1 | `formal = clone(true, seed)` |
| `RNG_D06` | Runner has execution guard | 1 | `confirm_execute found.` |
| `RNG_D07` | Runner stores RngBefore/RngAfter | 1 | `RNG logs found.` |
| `RNG_D08` | Runner stores formal output | 1 | `formal output save found.` |
| `RNG_D09` | Approval gate returns command only | 1 | `Approval stores approvedCommand as text; no runner call is executed inside approval gate.` |
| `RNG_D10` | Three seeds designed | 1 | `61001, 61002, 61003` |
| `RNG_D11` | No GA executed | 1 | `Build script only.` |
| `RNG_D12` | No model executed | 1 | `Build script only.` |
| `RNG_D13` | Original v96m not modified | 1 | `Only new runner/approval files created.` |
