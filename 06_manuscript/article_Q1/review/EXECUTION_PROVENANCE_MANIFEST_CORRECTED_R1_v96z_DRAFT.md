# EXECUTION_PROVENANCE_MANIFEST — CORRECTED_R1 v96z — PRE-EXECUTION

`STATUS = PRE_EXECUTION_FROZEN_NOT_EXECUTED`

## Identidad Git

| Campo | Valor congelado |
|---|---|
| Repository | `D:\CODE\deshidratador` |
| Branch | `main` |
| HEAD base anterior | `e74e70ff7e87c9d9f19955b341ce152b11418f92` |
| Commit que congela CORRECTED_R1 | `THIS_COMMIT` — el commit que contiene este manifest; resolver con `git rev-parse HEAD` |
| Commit message | `chore: freeze CORRECTED_R1 pre-execution baseline` |
| `git status --short` después del commit | Vacío; `WORKTREE_CLEAN = YES`, verificado inmediatamente después del commit |
| Divergence `origin/main...HEAD` antes del freeze | `0 0` |
| Divergence `origin/main...HEAD` después del freeze | `0 1`, verificado inmediatamente después del commit |
| `git diff --check` | `PASS`, verificado antes de staging y después del commit |
| Remote mutation | `NO_PUSH_NO_PR_NO_MERGE` |

## Paquete incluido en el freeze

1. `02_src_limpio/production/run_corrected_r1_cost_e3d_v96z.m`
2. `06_manuscript/article_Q1/review/CORRECTED_R1_STATIC_AUDIT_v96z.md`
3. `06_manuscript/article_Q1/review/CORRECTED_R1_STATIC_DIFF_v96z.patch`
4. `06_manuscript/article_Q1/review/CURRENT_ENVIRONMENT_COMPATIBILITY_INSPECTION_v96z.md`
5. `06_manuscript/article_Q1/review/CURRENT_ENVIRONMENT_COMPATIBILITY_MATLAB_EVIDENCE_v96z.txt`
6. `06_manuscript/article_Q1/review/EXECUTION_PROVENANCE_MANIFEST_CORRECTED_R1_v96z_DRAFT.md`
7. `06_manuscript/article_Q1/review/FULL_SOLVER_DEFAULTS_AUDIT_CORRECTED_R1_v96z.md`
8. `06_manuscript/article_Q1/review/inspect_current_environment_compatibility_v96z.m`

No se incluye ninguna modificación a archivos productivos existentes de
objective, modelo, costo o wrapper. El único archivo productivo nuevo es el
runner corregido enumerado arriba.

## Artefactos y fingerprints

| Artefacto | Ruta | Git blob | SHA-256 |
|---|---|---|---|
| Runner CORRECTED_R1 | `02_src_limpio/production/run_corrected_r1_cost_e3d_v96z.m` | `075742ff72bc5b7a51e8c54b6122feea7a2fb345` | `AB481811872CA984F398D83A519C4C7A4584A2F1E401AE7F2F7CA9411EAE5B20` |
| Runner histórico seed-aware | `02_src_limpio/production/run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` | `243554b3df9644a74c54d45472068557204d650c` | `5F181A4C76310A09A3D68F8A8C14CE6F31A95453B9F59DDA09F45FEFDC2B5253` |
| Objective triobjetivo corregido | `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2_fix1.m` | `d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc` | `932C334310D600748FA33ABAB32C1C04A7993CD7A28F35FC707389FA7AF9A642` |
| Diseño formal v96l | `02_src_limpio/production/design_triobjective_formal_run_v96l.m` | `2006fe8da06740c9bcf0bc1b1c7bdd7b85df0268` | `229E161B607A82FFC883FA8637F832D63D5DC982AEC49DB10BF2AAD3B1C3D8B4` |
| Wrapper v18 | `02_src_limpio/wrappers/opt_tunel_mod2_v18_endpoint_TMAX_corrected.m` | `b825a513c95f50ac105d16346650cfe48f7d0096` | `C74355CA5A6CD07D447EBA72A1FF57613051F78FCF327B09650DC58261E87DFD` |
| Cost params | `02_src_limpio/cost/build_cost_params_historical.m` | `4b1fbfb8554ba59a79ed7908f62b83b38e8947c8` | `8E20AD4797BBECFDCD3F77EF144B1ACF501FB1C1623DF7FE7E6211A9A3441B7E` |
| Cost breakdown | `02_src_limpio/cost/calc_cost_breakdown.m` | `e1c9a29df585c4f2016b07d5d1f28b71eb917f52` | `420E83A9A89A9659FB7867426F4C890AD4691B7D97B8734C960A285B0AB70368` |
| MAT histórico R1 | `06_manuscript/article_Q1/runs/SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat` | — | `A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0` |
| MAT raw histórico con `opts` | `05_runs/triobjective_formal_ga_v96m/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_20260727_185506/mat/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_raw.mat` | — | `92BEEC3F2FF6D26CDEEB7A4AB9ABC053F8178FE47B38B8C17AD3CA9F7AD59397` |

## Configuración congelada

```text
seed = 61001
RNG = twister
PopulationSize = 24
MaxGenerations = 50
nvars = 4
mode = hybrid
referenceMode = gasLP
x_selected = [0.0740767982118, 62.6832965028, 0.672252618341, 11.6517528081]
lb = [0.0540767982118, 57.6832965028, 0.422252618341, 8.6517528081]
ub = [0.0940767982118, 67.6832965028, 0.922252618341, 14]
```

## Opciones completas requeridas

```text
CreationFcn = [] -> effective @gacreationuniform
CrossoverFcn = [] -> effective @crossoverintermediate
CrossoverFraction = 0.8
Display = iter
DistanceMeasureFcn = {@distancecrowding,'phenotype'}
FunctionTolerance = 1e-5
HybridFcn = []
InitialPopulationMatrix = []
InitialPopulationRange = [-10,10] before bound correction
InitialScoresMatrix = []
MaxGenerations = 50
MaxStallGenerations = 100
MigrationDirection = forward
MigrationFraction = 0.2
MigrationInterval = 20
MutationFcn = [] -> effective @mutationadaptfeasible
OutputFcn = []
ParetoFraction = 0.35
PlotFcn = []
PlotInterval = 1
PopulationSize = 24
PopulationType = doubleVector
SelectionFcn = {@selectiontournament,2}
ConstraintTolerance = 1e-6
MaxTime = Inf
UseParallel = false
UseVectorized = off
IntegerTolerance = 1e-5
```

## Entorno actual verificado

| Campo | Valor PRE-EXECUTION |
|---|---|
| MATLAB version | `26.1.0.3312084 (R2026a) Update 4` |
| MATLAB release | `R2026a` |
| Current MATLAB build | `26.1.0.3312084`, Update 4 |
| Global Optimization Toolbox | `26.1 (R2026a)` |
| OS/computer | `PCWIN64` |
| `FULL_SOLVER_DEFAULTS_AUDIT` | `PASS_WITH_DOCUMENTARY_BUILD_LIMITATION` |
| `HISTORICAL_BUILD_EXACT` | `UNKNOWN` |
| `HISTORICAL_BUILD_UNCERTAINTY` | `DOCUMENTARY_NON_MATERIAL` |
| Execution start timestamp | `PENDING_EXECUTION` |
| Execution end timestamp | `PENDING_EXECUTION` |
| Runtime | `PENDING_EXECUTION` |
| Final output directory | `PENDING_EXECUTION` |
| RNG state before seeding | `PENDING_EXECUTION` |
| RNG state immediately after `rng(61001,'twister')` | `PENDING_EXECUTION` |
| Serialized complete `opts` | `PENDING_EXECUTION` |

## Resultado y alcance — completar después de una ejecución autorizada

```text
MATLAB_EXECUTED_AS_OF_FREEZE = NO
GAMULTIOBJ_EXECUTED_AS_OF_FREEZE = NO
CORRECTED_R1_EXECUTED_AS_OF_FREEZE = NO
CORRECTED_R1_EXECUTED = PENDING_EXECUTION
GAMULTIOBJ_EXECUTED = PENDING_EXECUTION
R2_EXECUTED = NO
R3_EXECUTED = NO
MINREP_EXECUTED = NO
400GEN_EXECUTED = NO
execution_timestamp = PENDING_EXECUTION
runtime = PENDING_EXECUTION
exitflag = PENDING_EXECUTION
generations = PENDING_EXECUTION
funccount = PENDING_EXECUTION
number_of_solutions = PENDING_EXECUTION
finite_solutions = PENDING_EXECUTION
penalty_solutions = PENDING_EXECUTION
results_F = PENDING_EXECUTION
final_output_directory = PENDING_EXECUTION
output_artifact_sha256 = PENDING_EXECUTION
```

Este manifest PRE-EXECUTION no autoriza ni inicia ninguna ejecución.
