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
INTERNAL_RUN_VALIDATED
```

La interpretación de `CORRECTED_R1` ya no debe quedar condicionada exclusivamente a la comparación histórica R1 de 50 generaciones. La recuperación posterior de diseños de época de tesis cambia la procedencia histórica preferida para el manuscrito.

## Recuperación histórica de tesis — HB200

Decisión canónica vigente:

```text
PRIMARY_THESIS_LEGACY_BASELINE = HB200
HB306_STATUS = RECOVERED_LATER_CHECKPOINT_PROVENANCE_UNRESOLVED
HB306_EQUIVALENT_TO_THESIS_GENERATION_316 = NOT_PROVEN
R1_50GEN_ROLE = AUXILIARY_REPRODUCIBILITY_CONTROL
```

La campaña HB200 fue reportada en la conversación activa como `THESIS_LEGACY_REEVALUATION_STATUS = PASS`, sin nueva optimización, sin `gamultiobj`, sin modificación de `C`, del manuscrito ni del código productivo. El reporte activo declara 44 diseños físicos únicos, reevaluación determinística bajo el modelo y objetivos actuales, y determinismo exacto en repeticiones centinela.

Los resultados cuantitativos reportados incluyen:

```text
UNIQUE_FINITE_THESIS_DESIGNS = 44
HISTORICALLY_ND_DESIGNS = 16
CURRENTLY_ND_THESIS_DESIGNS = 9
PERSISTENT_ND = 6
LOST_ND_STATUS = 10
GAINED_ND_STATUS = 3
THESIS_REPORTED_COMPROMISE_ID = T025
T_DOMINATES_C_PAIRS = 2
C_DOMINATES_T_PAIRS = 6
T_C_INCOMPARABLE_PAIRS = 73
T_C_EXACT_EQUAL_PAIRS = 0
T_CONTRIBUTION_TO_JOINT_RANK1 = 7
C_CONTRIBUTION_TO_JOINT_RANK1 = 7
DETERMINISM_CHECK = EXACT
GAMULTIOBJ_EXECUTED = NO
NEW_OPTIMIZATION_RUNS = 0
PRODUCTIVE_CODE_CHANGED = NO
FROZEN_C_CHANGED = NO
MANUSCRIPT_CHANGED = NO
```

Compromiso de tesis reportado:

```text
T025_CURRENT_F = [0.0337092930359653, 0.219375216857587, 0.519403503839552]
T025_STATUS_WITHIN_T = PERSISTENT_ND
T025_JOINT_RANK = 2
T025_DOMINATED_BY = C05
```

**Limitación documental actual:** los artefactos primarios de esta campaña (`THESIS_LEGACY_SCIENTIFIC_REPORT_COMPLETE.md`, manifest, auditoría de reproducibilidad, red-team, inventario SHA-256 y tablas/figuras asociadas) no están montados en el contexto activo de este Project. Por tanto, sus rutas y hashes no se inventan y los resultados anteriores se conservan explícitamente como `REPORTED_IN_ACTIVE_CONVERSATION_PENDING_ARTIFACT_REGISTRATION`.

```text
THESIS_LEGACY_ARTIFACT_REGISTRATION = PENDING
THESIS_LEGACY_NUMERIC_EVIDENCE_CANONICALLY_VERIFIED_IN_ACTIVE_CONTEXT = NO
```

## Protocolo comparativo R1-50gen v1.0

```text
COMPARATIVE_PROTOCOL_VERSION = v1.0
PROTOCOL_STATUS = FROZEN_HISTORICAL_PROTOCOL
PROTOCOL_ARTIFACT = 06_manuscript/article_Q1/review/CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md
PROTOCOL_SHA256 = 8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
```

El protocolo v1.0 permanece congelado como registro metodológico de la comparación `H(9)-vs-C(9)`. **No se modifica retrospectivamente** para convertirlo en el análisis HB200. La arquitectura científica posterior constituye un rediseño separado.

## Arquitectura científica propuesta para manuscrito v04

```text
V04_REDESIGN_JUSTIFIED = YES
PROPOSED_V04_SCIENTIFIC_ARCHITECTURE =
Gas-LPG context -> thesis-era HB200 physical designs -> deterministic common-basis reevaluation -> frozen current C portfolio -> paired recirculation-timing insight
```

Calificaciones obligatorias:
- comparación de conjuntos finitos, no demostración de frente Pareto verdadero/global;
- HB200 se usa por procedencia histórica, no como garantía de convergencia;
- el efecto de cambio de base objetiva y la ampliación del espacio de control están parcialmente confundidos para atribución directa `T-vs-C`;
- `HB306` no se identifica retrospectivamente con la generación 316 de la tesis.

## Siguiente fase

```text
NEXT_PHASE = THESIS_LEGACY_ARTIFACT_REGISTRATION_AND_V04_HANDOFF
```

Objetivo inmediato: registrar y verificar rutas, hashes y roles de los artefactos HB200 ya producidos. Una vez completado ese registro, podrá abrirse la edición del manuscrito v04. No se autoriza implícitamente ninguna nueva ejecución de MATLAB, `gamultiobj`, replays, optimización, cambio de código productivo, staging, commit, push, PR o merge.
