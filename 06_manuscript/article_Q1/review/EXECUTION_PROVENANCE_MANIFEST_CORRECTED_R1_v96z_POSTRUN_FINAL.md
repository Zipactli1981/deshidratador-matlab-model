# EXECUTION_PROVENANCE_MANIFEST — CORRECTED_R1 v96z — POSTRUN FINAL

`PROVENANCE_MANIFEST_STATUS = FINAL_POSTRUN_NOT_COMMITTED`

## Identidad

```text
repository = D:\CODE\deshidratador
branch = main
execution_head = 3aacb69ec5972aeb5d155c78462715bb3f1f981c
preexecution_base_head = e74e70ff7e87c9d9f19955b341ce152b11418f92
origin_divergence_at_execution = 0 1
preexecution_worktree_clean = YES
runner = 02_src_limpio/production/run_corrected_r1_cost_e3d_v96z.m
runner_blob = 075742ff72bc5b7a51e8c54b6122feea7a2fb345
runner_sha256 = AB481811872CA984F398D83A519C4C7A4584A2F1E401AE7F2F7CA9411EAE5B20
```

## Fingerprints productivos

| Componente | Git blob |
|---|---|
| Objective corregido | `d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc` |
| Diseño formal v96l | `2006fe8da06740c9bcf0bc1b1c7bdd7b85df0268` |
| Wrapper v18 | `b825a513c95f50ac105d16346650cfe48f7d0096` |
| Cost params | `4b1fbfb8554ba59a79ed7908f62b83b38e8947c8` |
| Cost breakdown | `e1c9a29df585c4f2016b07d5d1f28b71eb917f52` |

`POSTRUN_FINGERPRINTS_PASS = YES`

## Configuración ejecutada

```text
seed = 61001
RNG = twister
PopulationSize = 24
MaxGenerations = 50
nvars = 4
mode = hybrid
referenceMode = gasLP
lb = [0.0540767982118, 57.6832965028, 0.422252618341, 8.6517528081]
ub = [0.0940767982118, 67.6832965028, 0.922252618341, 14]
UseParallel = false
FunctionTolerance = 1e-5
ConstraintTolerance = 1e-6
PlotFcn = []
```

Los estados RNG completos anterior y posterior a la siembra no fueron
serializados por el runner. No se reconstruyen ni inventan; seed, algoritmo RNG
y configuración sí están verificados.

## Entorno

```text
MATLAB_VERSION = 26.1.0.3312084 (R2026a) Update 4
GLOBAL_OPTIM_VERSION = 26.1 (R2026a)
HISTORICAL_BUILD_EXACT = UNKNOWN
HISTORICAL_BUILD_UNCERTAINTY = DOCUMENTARY_NON_MATERIAL
FULL_SOLVER_DEFAULTS_AUDIT = PASS_WITH_DOCUMENTARY_BUILD_LIMITATION
```

## Ejecución

```text
execution_start_utc = 2026-08-08T06:57:19.365Z
execution_end_utc = 2026-08-08T10:23:29.629Z
runtime_s = 12302.9888139
runtime_h = 3.41749689275
MATLAB_ERROR = none
exitflag = 0
exitflag_basis = options.MaxGenerations=50 reached
output.generations = 50
output.funccount = 1200
n_solutions = 9
n_finite = 9
n_penalized = 0
F_shape = 9x3
X_shape = 9x4
GAMULTIOBJ_EXECUTIONS = 1
CORRECTED_R1_EXECUTIONS = 1
R2_EXECUTED = NO
R3_EXECUTED = NO
MINREP_EXECUTED = NO
400GEN_EXECUTED = NO
```

## Artefactos canónicos

| Artefacto | SHA-256 |
|---|---|
| `mat/CORRECTED_R1_COST_E3D_v96z.mat` | `0AE9D8C90EEE645EC5BAB843A18F59CC1E68E2D84B31CBFD7ADD498C81EBDB3B` |
| `mat/CORRECTED_R1_COST_E3D_v96z_raw.mat` | `C059CFED461E2F1C87149B96725BF0E510A3A3D324539A533FFC1EFC5D2D4293` |
| `tables/CORRECTED_R1_COST_E3D_v96z_solutions.csv` | `32EC4D9619693B62C6668417BB4A2A6A6AB310772C6BBEAEFCD457C3A1DAC49C` |
| `tables/CORRECTED_R1_COST_E3D_v96z_run_summary.csv` | `E3DAA44C6987971E0B7EA22A92BFF3562F363C148735C6D9FE4DD279756B656B` |
| `logs/CORRECTED_R1_COST_E3D_v96z_external_execution_diary.txt` | `6A17C98C5C12D86716F831E5C6C119C36BAF04084E4109C4E8E708FEB7527C30` |

Output canónico:

`D:\CODE\deshidratador\05_runs\triobjective_formal_ga_v96m\CORRECTED_R1_COST_E3D_v96z_20260808_005736`

## Auditoría postrun interna

```text
CORRECTED_R1_POSTRUN_INTERNAL_AUDIT = PASS
CORRECTED_R1_RESULTS_INTERNALLY_VALIDATED = YES
CORRECTED_R1_PARETO_FRONT_STATUS = INTERNAL_RUN_VALIDATED_COMPARATIVE_REVIEW_PENDING
DETAIL_REPLAY_EVALUATIONS = 9
GAMULTIOBJ_EXECUTIONS_ADDITIONAL = 0
F1_REPLAY_STATUS = PASS
F2_REPLAY_STATUS = PASS
F3_REPLAY_STATUS = PASS
X_BOUNDS_STATUS = PASS
MAT_CSV_LOG_CONSISTENCY = PASS
PENALTY_STATUS = PASS_NO_PENALTY_ROWS
PRODUCTIVE_CODE_MODIFIED = NO
```

Tolerancias: `absTol=1e-12`, `relTol=1e-10`. Los 27 valores reproducidos
coinciden exactamente con F (`abs=0`, `rel=0`). Las diferencias MAT↔CSV son de
serialización y quedan varios órdenes de magnitud bajo tolerancia.

La clasificación de terminación es `TMAX_REACHED` para las nueve filas,
inferida explícitamente desde `dry_time=19.9 h` porque el objective detail no
propaga la etiqueta del wrapper.

## Estado científico

Este manifest no denomina las nueve filas “frente Pareto corregido definitivo”.
La comparación contra la R1 histórica reevaluada, el sorting conjunto, el
hypervolume, la selección editorial y las conclusiones científicas permanecen
bloqueados y fuera de este micropaso.

No se realizó commit, push, merge ni publicación remota.
