# CURRENT STATE — Deshidratador MATLAB / Q1

## Baseline científico Git

```text
Repository = D:\CODE\deshidratador
Branch = main
CORRECTED_R1_POSTRUN_BASELINE_HEAD = 8a794c389edd10f9750e10a27eca0ec58c14da2d
Worktree = clean
git diff --check = PASS
origin/main divergence at CORRECTED_R1 postrun freeze = 0 behind / 2 ahead
```

Los dos commits locales que cerraron CORRECTED_R1 no habían sido publicados remotamente al cierre de esa fase.

El HEAD vivo, el estado del worktree y la divergencia con `origin/main` son datos dinámicos y deben consultarse directamente con Git al inicio de cada sesión. Este archivo conserva baselines científicos y documentales; no pretende fijar el HEAD vivo del repositorio.

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

## Protocolo comparativo congelado

```text
COMPARATIVE_PROTOCOL_VERSION = v1.0
PROTOCOL_STATUS = FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
SCIENTIFIC_ARCHITECTURE = PASS
OPEN_ESSENTIAL_METHODOLOGICAL_DECISIONS = 0
```

Artefacto canónico previsto en el repositorio:

```text
06_manuscript/article_Q1/review/CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md
```

SHA-256 del contenido congelado:

```text
8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
```

El protocolo aprueba la arquitectura metodológica, pero no constituye autorización operativa automática para ejecutar scripts.

Estado de implementación:

```text
COMPARATIVE_DATASET = BUILT_FROZEN_VALIDATED
COMPARATIVE_RESULTS = NOT_COMPUTED
SCIENTIFIC_INTERPRETATION = NOT_STARTED
MANUSCRIPT_CHANGES = NOT_STARTED
MATLAB_EXECUTION_AUTHORIZED = NO
CODEX_EXECUTION_AUTHORIZED = NO
GAMULTIOBJ_EXECUTION_AUTHORIZED = NO
```

Estado vigente de `CR1-COMP-01`:

```text
CR1_COMP_01_PROVENANCE_SEARCH = CLOSED_PASS
H_X_PROVENANCE = RESOLVED
H_F_CORRECTED_PROVENANCE = RESOLVED
H_F_CORRECTED_FULL_PRECISION_ARTIFACT_FOUND = NO
H_F_CORRECTED_DECIMAL_VALIDATED_SOURCE_FOUND = YES
H_F2_F3_DOCUMENTARY_RECOVERY_DECISION = APPROVED_CR1_COMP_01_D1
CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY = PASS
SOURCE_VALUE_RECOVERY_ARTIFACT = 06_manuscript/article_Q1/review/CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY_v96z.csv
SOURCE_VALUE_RECOVERY_ARTIFACT_SHA256 = 869A070F972319ABC0AC0BCD44EF6699E5C3BC92BAB53EB5328AEFB1275F7D2D
CR1_COMP_01_STATUS = CLOSED_PASS
CR1_COMP_01_DATASET_FREEZE = PASS
COMPARATIVE_DATASET = BUILT_FROZEN_VALIDATED
CANONICAL_COMPARATIVE_DATASET = 06_manuscript/article_Q1/review/CR1_COMP_01_CANONICAL_DATASET_v96z.csv
CANONICAL_COMPARATIVE_DATASET_SHA256 = B17B461FB04C9693FC9DA0C3450703C34E4538894AD232EF7138AE5E9882CD62
NEXT_COMPARATIVE_PHASE = CR1-COMP-02 — Within-set exact Pareto audit
```

El dataset canónico conserva 18 filas en orden H01…H09, C01…C09. La desviación documental D1 para H.f2/f3 permanece explícita. No se realizó comparación Pareto.

## Siguiente fase

```text
NEXT_PHASE = CR1-COMP-02_WITHIN_SET_EXACT_PARETO_AUDIT
```

CR1-COMP-02 requiere autorización separada.
