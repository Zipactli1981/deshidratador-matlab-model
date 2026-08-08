# CURRENT STATE — Deshidratador MATLAB / Q1

## Git canónico

```text
Repository = D:\CODE\deshidratador
Branch = main
HEAD = 8a794c389edd10f9750e10a27eca0ec58c14da2d
Worktree = clean
git diff --check = PASS
origin/main divergence = 0 behind / 2 ahead
```

Los dos commits locales de CORRECTED_R1 no han sido publicados remotamente.

## Commits de cierre

Pre-execution freeze:
```text
3aacb69ec5972aeb5d155c78462715bb3f1f981c
chore: freeze CORRECTED_R1 pre-execution baseline
```

Postrun freeze:
```text
8a794c389edd10f9750e10a27eca0ec58c14da2d
docs: freeze CORRECTED_R1 validated postrun
```

## Histórico R1

```text
Seed = 61001
PopulationSize = 24
MaxGenerations = 50
Mode = hybrid
Reference = gasLP
Finite solutions = 9
Exitflag = 0 (MaxGenerations)
Runtime ≈ 3.882 h
```

Artefacto histórico:
```text
SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/
SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat
```

SHA-256:
```text
A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0
```

Los 9 vectores históricos ya fueron reevaluados bajo COST-E3D.

```text
R1_EXISTING_POINTS_STATUS =
REEVALUATED_SAMPLES_NOT_A_REOPTIMIZED_PARETO_FRONT
```

## CORRECTED_R1

Runner:
```text
02_src_limpio/production/run_corrected_r1_cost_e3d_v96z.m
```

Git blob:
```text
075742ff72bc5b7a51e8c54b6122feea7a2fb345
```

SHA-256:
```text
AB481811872CA984F398D83A519C4C7A4584A2F1E401AE7F2F7CA9411EAE5B20
```

Configuración:
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

## Solver

```text
MATLAB = 26.1.0.3312084 (R2026a) Update 4
Global Optimization Toolbox = 26.1 (R2026a)
CURRENT_ENVIRONMENT_COMPATIBILITY = PASS
HISTORICAL_BUILD_EXACT = UNKNOWN
HISTORICAL_BUILD_UNCERTAINTY = DOCUMENTARY_NON_MATERIAL
FULL_SOLVER_DEFAULTS_AUDIT =
PASS_WITH_DOCUMENTARY_BUILD_LIMITATION
```

## Ejecución

```text
CORRECTED_R1_EXECUTION = PASS
Execution HEAD = 3aacb69ec5972aeb5d155c78462715bb3f1f981c
Seed = 61001
Exitflag = 0
Generations = 50
Funccount = 1200
Runtime_h = 3.41749689275
N_SOLUTIONS = 9
N_FINITE = 9
N_PENALIZED = 0
MATLAB_ERROR = none
```

Motivo de parada:
```text
gamultiobj stopped because it exceeded options.MaxGenerations.
```

Output:
```text
D:\CODE\deshidratador\05_runs\triobjective_formal_ga_v96m\
CORRECTED_R1_COST_E3D_v96z_20260808_005736
```

## Postrun

```text
CORRECTED_R1_POSTRUN_INTERNAL_AUDIT = PASS
CORRECTED_R1_RESULTS_INTERNALLY_VALIDATED = YES
DETAIL_REPLAY_EVALUATIONS = 9
F1_REPLAY_STATUS = PASS
F2_REPLAY_STATUS = PASS
F3_REPLAY_STATUS = PASS
X_BOUNDS_STATUS = PASS
MAT_CSV_LOG_CONSISTENCY = PASS
PENALTY_STATUS = PASS_NO_PENALTY_ROWS
ALL_REGISTERED_HASHES_PASS = YES
```

Replay:
```text
max_abs_diff_f1 = 0
max_abs_diff_f2 = 0
max_abs_diff_f3 = 0
```

Las diferencias MAT↔CSV son de representación decimal.

Las 9 soluciones terminaron con `dry_time = 19.9 h`. `TMAX_REACHED` fue inferido de ese valor porque el objective detail no propaga directamente `termination_status`.

## Estado científico

```text
CORRECTED_R1_PARETO_FRONT_STATUS =
INTERNAL_RUN_VALIDATED_COMPARATIVE_REVIEW_PENDING

SCIENTIFIC_INTERPRETATION =
BLOCKED_PENDING_COMPARATIVE_REVIEW
```

## Siguiente fase

Diseñar primero el protocolo de comparación científica entre:
1. las 9 soluciones nuevas `CORRECTED_R1`;
2. los mismos 9 vectores históricos reevaluados bajo COST-E3D.
