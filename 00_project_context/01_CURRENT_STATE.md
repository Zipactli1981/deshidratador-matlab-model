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
COMPARATIVE_RESULTS = THROUGH_CR1_COMP_11_HYPERVOLUME_SENSITIVITY_COMPUTED
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
NEXT_COMPARATIVE_PHASE = CR1-COMP-04 — Objective-space descriptive analysis
```

El dataset canónico conserva 18 filas en orden H01…H09, C01…C09. La desviación documental D1 para H.f2/f3 permanece explícita.

Estado vigente de `CR1-COMP-02`:

```text
CR1_COMP_02_STATUS = CLOSED_PASS
PARETO_DEFINITION = EXACT
DOMINANCE_TOLERANCE = NONE
H_INTERNAL_NONDOMINATED_COUNT = 9
H_INTERNAL_DOMINATED_COUNT = 0
C_INTERNAL_NONDOMINATED_COUNT = 9
C_INTERNAL_DOMINATED_COUNT = 0
HISTORICAL_NONDOMINATED_CORE = H01,H02,H03,H04,H05,H06,H07,H08,H09
CORRECTED_R1_NONDOMINATED_CORE = C01,C02,C03,C04,C05,C06,C07,C08,C09
CROSS_DOMINANCE_COMPUTED = NO
NEAR_TIE_DIAGNOSTIC_COMPUTED = NO
```

Los 36 pares internos de H y los 36 pares internos de C resultaron incomparables. No hubo relaciones de dominancia ni igualdades exactas. Esto permite denominar C como aproximación no dominada, pero no como frente Pareto verdadero, exacto o global. H permanece como conjunto histórico reevaluado, no como frente Pareto corregido.

Estado cerrado de `CR1-COMP-03`:

```text
CR1_COMP_03_STATUS = CLOSED_PASS
CR1_COMP_03_INITIAL_GATE = BLOCKED_DESCRIPTIVE_CONVENTION_UNSPECIFIED
D013_STATUS = VIGENTE
STD_CONVENTION = POPULATION_DDOF_0
IQR_CONVENTION = HYNDMAN_FAN_TYPE_7
BOUND_PROXIMITY_RULE = DISTANCES_ONLY_NO_THRESHOLD
RESULTS_OBSERVED_BEFORE_DECISION = NO
DESCRIPTIVE_RESULTS_COMPUTED = YES_AFTER_D013_FREEZE
DECISION_SPACE_DESCRIPTIVE_ANALYSIS = PASS
H_ROWS = 9
C_ROWS = 9
VARIABLE_COUNT = 4
ALL_X_FINITE = YES
BOUNDS_CHECK = PASS
INDEPENDENT_QC = PASS
NEXT_COMPARATIVE_PHASE = CR1-COMP-04 — Objective-space descriptive analysis
```

D013 resolvió las convenciones antes del cálculo. Los resultados son resúmenes descriptivos de conjuntos finitos, no inferencia poblacional, evidencia entre corridas ni conclusión de superioridad multiobjetivo.

Estado cerrado de `CR1-COMP-04`:

```text
CR1_COMP_04_STATUS = CLOSED_PASS
OBJECTIVE_SPACE_DESCRIPTIVE_ANALYSIS = PASS
ANALYSIS_DESIGNATION = DESCRIPTIVE_SUMMARIES_OF_FINITE_SOLUTION_SETS
STD_CONVENTION = POPULATION_DDOF_0
IQR_CONVENTION = HYNDMAN_FAN_TYPE_7
F1_DELTA_MEDIAN_C_MINUS_H = -0.01475349389602941
F1_DELTA_MEDIAN_PERCENT_C_MINUS_H = -33.807045718015644
F2_DELTA_MEDIAN_C_MINUS_H = 0.006738119067525805
F2_DELTA_MEDIAN_PERCENT_C_MINUS_H = 3.1995544935821214
F3_DELTA_MEDIAN_C_MINUS_H = 0.019106314903851396
F3_DELTA_MEDIAN_PERCENT_C_MINUS_H = 3.8585642103238946
INDEPENDENT_QC = PASS
CROSS_DOMINANCE_COMPUTED = NO
NEXT_COMPARATIVE_PHASE = CR1-COMP-05 — Exact cross-dominance matrix
```

Los desplazamientos son diferencias numéricas de medianas de dos conjuntos finitos. No constituyen superioridad multiobjetivo, significancia, robustez ni interpretación física, económica o ambiental.

Estado cerrado de `CR1-COMP-05`:

```text
CR1_COMP_05_STATUS = CLOSED_PASS
PARETO_DEFINITION = EXACT_FULL_PRECISION
DOMINANCE_TOLERANCE = NONE
CROSS_PAIR_COUNT = 81
C_DOMINATES_H_COUNT = 1
H_DOMINATES_C_COUNT = 2
INCOMPARABLE_COUNT = 78
EXACT_EQUAL_COUNT = 0
INDEPENDENT_QC = PASS
NEAR_TIE_COMPUTED = NO
COVERAGE_COMPUTED = NO
JOINT_SORTING_COMPUTED = NO
NEXT_COMPARATIVE_PHASE = CR1-COMP-06 — Numerical near-tie sensitivity audit
```

Los conteos son relaciones exactas entre las 81 parejas cartesianas H×C. No constituyen coverage, Rank 1 conjunto ni superioridad global.

Estado cerrado de `CR1-COMP-06`:

```text
CR1_COMP_06_STATUS = CLOSED_PASS
NUMERICAL_NEAR_TIE_THRESHOLD = 1e-12 * max(1,abs(a),abs(b))
NUMERICAL_THRESHOLD_ROLE = DIAGNOSTIC_ONLY
CROSS_PAIR_COUNT = 81
OBJECTIVE_COMPARISON_COUNT = 243
NEAR_TIE_OBJECTIVE_COUNT = 0
PAIR_WITH_NEAR_TIE_COUNT = 0
NUMERICALLY_FRAGILE_DOMINANCE_COUNT = 0
DOMINANCE_NUMERIC_SENSITIVITY = PASS_NO_FRAGILE_DOMINANCE
CR1_COMP_05_EXACT_DOMINANCE_PRESERVED = YES
EXACT_DOMINANCE_CLASSIFICATIONS_CHANGED = NO
INDEPENDENT_QC = PASS
COVERAGE_COMPUTED = NO
JOINT_SORTING_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
NEXT_COMPARATIVE_PHASE = CR1-COMP-07 — Set coverage
```

El umbral fue exclusivamente diagnóstico. No se transformaron desigualdades en igualdades ni se modificó clasificación exacta, Pareto rank o coverage futuro.

Estado cerrado de `CR1-COMP-07`:

```text
CR1_COMP_07_STATUS = CLOSED_PASS
N_H_COUNT = 9
N_C_COUNT = 9
N_H_DOMINATED_BY_C = 1
H_DOMINATED_BY_C_IDS = H05
N_C_DOMINATED_BY_H = 2
C_DOMINATED_BY_H_IDS = C06,C08
FULL_COVERAGE_C_OVER_H = 0.1111111111111111
FULL_COVERAGE_H_OVER_C = 0.2222222222222222
CORE_COVERAGE_NC_OVER_NH = 0.1111111111111111
CORE_COVERAGE_NH_OVER_NC = 0.2222222222222222
FULL_CORE_COVERAGE_EQUALITY_CHECK = PASS
INDEPENDENT_QC = PASS
COVERAGE_COMPUTED = YES
JOINT_SORTING_COMPUTED = NO
HYPERVOLUME_GATE_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
NEXT_COMPARATIVE_PHASE = CR1-COMP-08 — Joint exact nondominated sorting
```

Coverage se calculó sobre IDs objetivo distintos y es asimétrico. La igualdad full/core es específica de este dataset porque `N_H=H` y `N_C=C`. Los resultados no establecen superioridad global ni composición del Rank 1 conjunto. No se calculó CR1-COMP-08 ni ninguna fase posterior.

Estado cerrado de `CR1-COMP-08`:

```text
CR1_COMP_08_STATUS = CLOSED_PASS
JOINT_SORTING_COMPUTED = YES
JOINT_SOLUTION_COUNT = 18
JOINT_RANK_COUNT = 2
JOINT_RANK1_COUNT = 15
JOINT_RANK1_H = 8
JOINT_RANK1_C = 7
JOINT_RANK1_H_IDS = H01,H02,H03,H04,H06,H07,H08,H09
JOINT_RANK1_C_IDS = C01,C02,C03,C04,C05,C07,C09
JOINT_RANK2_COUNT = 3
JOINT_RANK2_H = 1
JOINT_RANK2_C = 2
JOINT_RANK2_H_IDS = H05
JOINT_RANK2_C_IDS = C06,C08
JOINT_NONDOMINATED_SET_NAME = JOINT_NONDOMINATED_SET_OF_18_EVALUATED_SOLUTIONS
INDEPENDENT_QC = PASS
CR1_COMP_09_COMPUTED = NO
OBJECTIVE_GEOMETRY_COMPUTED = NO
HYPERVOLUME_GATE_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
NEXT_COMPARATIVE_PHASE = CR1-COMP-09 — Objective-space geometry
```

El Rank 1 es el conjunto no dominado conjunto de las 18 soluciones evaluadas, no un frente Pareto verdadero, exacto, global o corregido. El sorting exacto produjo dos capas y fue coherente con las dominancias congeladas de CR1-COMP-02/05/06/07. No se calculó CR1-COMP-09 ni ninguna fase posterior.

Estado cerrado de `CR1-COMP-09`:

```text
CR1_COMP_09_STATUS = CLOSED_PASS
OBJECTIVE_GEOMETRY_COMPUTED = YES
ANALYSIS_DESIGNATION = DESCRIPTIVE_GEOMETRY_OF_FINITE_EVALUATED_SETS
F1_RANGE_H = 0.1464915338019719
F1_RANGE_C = 0.08251886009269793
F1_DELTA_RANGE_C_MINUS_H = -0.06397267370927398
F2_RANGE_H = 0.10145085302645257
F2_RANGE_C = 0.08648739344562398
F2_DELTA_RANGE_C_MINUS_H = -0.014963459580828592
F3_RANGE_H = 0.2835747323673442
F3_RANGE_C = 0.23780849103844187
F3_DELTA_RANGE_C_MINUS_H = -0.045766241328902335
NEW_EXTREMES_C = NONE
HISTORICAL_EXTREMES_NOT_REPRODUCED_BY_C = F1_MIN_H09,F1_MAX_H01,F2_MIN_H01,F2_MAX_H09,F3_MIN_H01,F3_MAX_H09
JOINT_RANK1_H = 8
JOINT_RANK1_C = 7
CROSS_SET_STRUCTURE = PREDOMINANTLY_INCOMPARABLE
TRADEOFF_RESTRUCTURING_OBSERVED = YES_DESCRIPTIVE_SYNTHESIS
GEOMETRY_METRIC_NOT_IN_PROTOCOL_INTRODUCED = NO
OBJECTIVE_NORMALIZATION_USED = NO
GLOBAL_MINIMUM_VISUALIZATION_SUITE_COMPLETE = NO
INDEPENDENT_QC = PASS
CR1_COMP_10_COMPUTED = NO
HYPERVOLUME_GATE_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
NEXT_COMPARATIVE_PHASE = CR1-COMP-10 — Hypervolume decision gate
```

Los intervalos observados de C son más estrechos y están contenidos dentro de los intervalos marginales de H en los tres objetivos. Esta descripción no se denomina contracción de un frente Pareto. La síntesis de reestructuración del trade-off combina rangos/extremos, desplazamientos de mediana ya congelados, contribuciones Rank 1 de ambos conjuntos y estructura cruzada predominantemente incomparable; no es una nueva métrica geométrica.

Estado cerrado de `CR1-COMP-10`:

```text
CR1_COMP_10_STATUS = CLOSED_PASS
HYPERVOLUME_GATE_COMPUTED = YES
FULL_COVERAGE_C_OVER_H = 0.1111111111111111
FULL_COVERAGE_H_OVER_C = 0.2222222222222222
GATE_TEST_C_OVER_H_EQUALS_1 = FALSE
GATE_TEST_H_OVER_C_EQUALS_0 = FALSE
GATE_FULL_DOMINANCE_CONDITION = FALSE
HYPERVOLUME_ANALYSIS = RECOMMENDED
HYPERVOLUME_COMPUTED = NO
CR1_COMP_11_COMPUTED = NO
JSON_CSV_COVERAGE_CONSISTENCY = PASS
GATE_IMPLEMENTATIONS_AGREE = PASS
INDEPENDENT_QC = PASS
NEXT_COMPARATIVE_PHASE = CR1-COMP-11 — Hypervolume and sensitivity
```

La cobertura no proporciona una sustitución completa y unidireccional de H por C bajo la condición congelada. El protocolo recomienda hypervolume como métrica secundaria adicional; el gate no establece superioridad de ningún conjunto ni anticipa el resultado de hypervolume. No se calculó hypervolume, normalización, anclajes, reference points o sensibilidad.

Estado cerrado de `CR1-COMP-11`:

```text
CR1_COMP_11_STATUS = CLOSED_PASS
HYPERVOLUME_COMPUTED = YES
HV_ANCHORS_FROZEN = YES
HV_SCALE_MIN = [0.01473445910295798,0.18030701050054604,0.4043097419600721]
HV_SCALE_MAX = [0.1612259929049299,0.2817578635269986,0.6878844743274163]
HV_SCALE_RANGE = [0.1464915338019719,0.10145085302645257,0.2835747323673442]
HV_H_R5 = 0.8214144073536221
HV_C_R5 = 0.8596538595095115
HV_DIRECTION_R5 = C_GT_H
HV_H_R10 = 0.9749820881940048
HV_C_R10 = 1.0099628901072748
HV_DIRECTION_R10 = C_GT_H
HV_H_R20 = 1.3323674498747686
HV_C_R20 = 1.3592107397484303
HV_DIRECTION_R20 = C_GT_H
HV_H = 0.9749820881940048
HV_C = 1.0099628901072748
HV_DIRECTION = C_GT_H
HV_SENSITIVITY_STATUS = ROBUST_DIRECTION
COMMON_NORMALIZATION_USED = YES
INDEPENDENT_QC = PASS
CR1_COMP_12_COMPUTED = NO
NEXT_COMPARATIVE_PHASE = CR1-COMP-12 — Common terminal-regime analysis
```

Con anclajes comunes derivados de `P=N_H∪N_C`, C presenta mayor cobertura del espacio objetivo anclado que H para los tres reference points preespecificados. La dirección `C_GT_H` es robusta dentro de esa rejilla de sensibilidad. Este resultado no demuestra proximidad al frente Pareto verdadero, convergencia, superioridad estadística, robustez frente a semillas ni superioridad física integral.

## Siguiente fase

```text
NEXT_PHASE = CR1-COMP-12_COMMON_TERMINAL_REGIME_ANALYSIS
```

CR1-COMP-12 requiere autorización separada.
