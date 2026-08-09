# PHASE HANDOFF CURRENT
## CR1-COMP-11 Hypervolume and Sensitivity → CR1-COMP-12 Common Terminal-regime Analysis

## Fases cerradas

```text
CORRECTED_R1_PHASE = CLOSED_PASS
CORRECTED_R1_EXECUTION = PASS
CORRECTED_R1_POSTRUN_INTERNAL_AUDIT = PASS
CORRECTED_R1_RESULTS_INTERNALLY_VALIDATED = YES
```

CORRECTED_R1 validated postrun baseline HEAD:

```text
8a794c389edd10f9750e10a27eca0ec58c14da2d
```

El HEAD vivo del repositorio debe consultarse directamente con Git.

## Protocolo comparativo

```text
COMPARATIVE_PROTOCOL_VERSION = v1.0
PROTOCOL_STATUS = FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
SCIENTIFIC_ARCHITECTURE = PASS
OPEN_ESSENTIAL_METHODOLOGICAL_DECISIONS = 0
```

Artefacto:

```text
06_manuscript/article_Q1/review/CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md
```

SHA-256:

```text
8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
```

## Conjuntos que se compararán

### H — Historical R1 reevaluated

9 vectores históricos generados bajo la formulación anterior y reevaluados con COST-E3D corregido.

No constituyen un frente Pareto corregido.

### C — CORRECTED_R1

9 soluciones producidas directamente por `gamultiobj` bajo COST-E3D corregido y validadas internamente.

## Estado comparativo

```text
COMPARATIVE_DATASET = BUILT_FROZEN_VALIDATED
COMPARATIVE_RESULTS = THROUGH_CR1_COMP_11_HYPERVOLUME_SENSITIVITY_COMPUTED
SCIENTIFIC_INTERPRETATION = NOT_STARTED
MANUSCRIPT_CHANGES = NOT_STARTED
```

## Estado de CR1-COMP-01

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
```

La excepción D1 acepta como recuperación documental la serialización decimal validada de 17 dígitos de `H.f2/f3`, porque los `double` binary64 originales corregidos no fueron persistidos. La limitación permanece explícita: la identidad binary64 original no fue verificada independientemente. `H.X` y `H.f1` proceden del MAT histórico.

E1 recuperó y auditó los valores fuente en orden original, con 9 registros H y 9 registros C. El CSV/JSON E1 permanecen como artefactos derivados de recuperación.

CR1-COMP-01-F1 construyó y congeló el dataset canónico de 18 filas en orden H01…H09, C01…C09. D1 permanece como limitación explícita. No se ejecutó replay, dominancia, sorting Pareto, coverage, hypervolume ni otra comparación científica.

## CR1-COMP-02 cerrado

Baseline operativo:

```text
407e9589245e6a2bc7a167b150e7fa233df64201
chore: freeze CR1-COMP-01 comparative dataset
```

Resultado exacto dentro de cada conjunto:

```text
CR1_COMP_02_STATUS = CLOSED_PASS
H_INTERNAL_PAIR_COUNT = 36
H_INTERNAL_NONDOMINATED_COUNT = 9
H_INTERNAL_DOMINATED_COUNT = 0
HISTORICAL_NONDOMINATED_CORE = H01,H02,H03,H04,H05,H06,H07,H08,H09
C_INTERNAL_PAIR_COUNT = 36
C_INTERNAL_NONDOMINATED_COUNT = 9
C_INTERNAL_DOMINATED_COUNT = 0
CORRECTED_R1_NONDOMINATED_CORE = C01,C02,C03,C04,C05,C06,C07,C08,C09
INDEPENDENT_QC = PASS
CROSS_DOMINANCE_COMPUTED = NO
NEAR_TIE_DIAGNOSTIC_COMPUTED = NO
```

Los 72 pares internos fueron incomparables; no hubo dominancias ni igualdades exactas. `CORRECTED_R1` puede denominarse aproximación no dominada, no frente Pareto verdadero, exacto o global. H continúa siendo un conjunto histórico reevaluado.

No se ejecutaron MATLAB, objective/model, replay, `gamultiobj`, optimización ni ninguna fase CR1-COMP posterior.

## CR1-COMP-03 cerrado / D013 vigente

CR1-COMP-03 se detuvo inicialmente antes de cualquier cálculo descriptivo porque el protocolo no especificaba población vs. muestra para `std` ni el algoritmo de cuartiles/IQR.

D013 resolvió metodológicamente esas convenciones antes de observar resultados:

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
PROTOCOL_V1_MODIFIED = NO
CR1_COMP_04_COMPUTED = NO
```

CR1-COMP-01 y CR1-COMP-02 permanecen `CLOSED_PASS`. CR1-COMP-03 produjo únicamente resúmenes descriptivos del espacio de decisión de los conjuntos finitos H y C.

## CR1-COMP-04 cerrado

```text
CR1_COMP_04_STATUS = CLOSED_PASS
OBJECTIVE_SPACE_DESCRIPTIVE_ANALYSIS = PASS
ANALYSIS_DESIGNATION = DESCRIPTIVE_SUMMARIES_OF_FINITE_SOLUTION_SETS
H_ROWS = 9
C_ROWS = 9
OBJECTIVE_COUNT = 3
ALL_F_VALUES_FINITE = YES
PENALTY_ROWS_INCLUDED = NO
INDEPENDENT_QC = PASS
CROSS_DOMINANCE_COMPUTED = NO
CR1_COMP_05_COMPUTED = NO
```

CR1-COMP-04 realizó únicamente caracterización descriptiva del espacio de objetivos bajo D013. Los desplazamientos de medianas no son afirmaciones de superioridad multiobjetivo.

## CR1-COMP-05 cerrado

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
```

CR1-COMP-05 clasificó exclusivamente las 81 parejas cartesianas H×C mediante dominancia exacta sin tolerancia. Los conteos no son métricas de coverage ni establecen Rank 1 conjunto o superioridad global.

## CR1-COMP-06 cerrado

```text
CR1_COMP_06_STATUS = CLOSED_PASS
NUMERICAL_NEAR_TIE_THRESHOLD = 1e-12 * max(1,abs(a),abs(b))
NUMERICAL_THRESHOLD_ROLE = DIAGNOSTIC_ONLY
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
```

CR1-COMP-06 auditó únicamente sensibilidad numérica diagnóstica. No encontró near-ties ni dominancias exactas frágiles, y preservó las 81 clasificaciones CR1-COMP-05.

## CR1-COMP-07 cerrado

```text
CR1_COMP_07_STATUS = CLOSED_PASS
H_DOMINATED_BY_C_IDS = H05
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
```

CR1-COMP-07 calculó coverage exacto full/core sobre soluciones objetivo distintas. La igualdad full/core se debe a que `N_H=H` y `N_C=C`; coverage sigue siendo asimétrico y no determina la composición del Rank 1 conjunto. No se ejecutó joint sorting ni ninguna fase posterior.

## CR1-COMP-08 cerrado

```text
CR1_COMP_08_STATUS = CLOSED_PASS
JOINT_SORTING_COMPUTED = YES
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
INDEPENDENT_QC = PASS
CR1_COMP_09_COMPUTED = NO
OBJECTIVE_GEOMETRY_COMPUTED = NO
HYPERVOLUME_GATE_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
```

El Rank 1 es el conjunto no dominado conjunto de las 18 soluciones evaluadas. Ocho soluciones históricas y siete CORRECTED_R1 permanecen en Rank 1; H05, C06 y C08 forman Rank 2. Este resultado no establece un frente Pareto verdadero, exacto, global o corregido. No se ejecutó geometría objetivo, hypervolume ni ninguna fase posterior.

## CR1-COMP-09 cerrado

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
JOINT_RANK2_IDS = H05,C06,C08
CROSS_SET_STRUCTURE = PREDOMINANTLY_INCOMPARABLE
TRADEOFF_RESTRUCTURING_OBSERVED = YES_DESCRIPTIVE_SYNTHESIS
GEOMETRY_METRIC_NOT_IN_PROTOCOL_INTRODUCED = NO
INDEPENDENT_QC = PASS
GLOBAL_MINIMUM_VISUALIZATION_SUITE_COMPLETE = NO
CR1_COMP_10_COMPUTED = NO
HYPERVOLUME_GATE_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
```

Los intervalos observados de C están contenidos dentro de los intervalos marginales de H y son más estrechos en f1, f2 y f3. La geometría conserva contribuciones Rank 1 de ambos conjuntos y es coherente con una estructura cruzada predominantemente incomparable. `TRADEOFF_RESTRUCTURING_OBSERVED` es una síntesis descriptiva, no una métrica nueva. No se ejecutó el gate formal de hypervolume ni ninguna fase posterior.

Las cuatro figuras PNG están registradas por hash, pero coinciden con la regla global `*.png` de `.gitignore`; cualquier freeze local deberá incorporarlas mediante staging forzado explícito y selectivo.

## CR1-COMP-10 cerrado

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
```

CR1-COMP-10 aplicó exclusivamente el gate congelado a los valores full coverage de CR1-COMP-07. La condición de sustitución completa y unidireccional resultó falsa, por lo que hypervolume queda recomendado como métrica secundaria adicional. No se calculó hypervolume ni se ejecutó CR1-COMP-11.

## CR1-COMP-11 cerrado

```text
CR1_COMP_11_STATUS = CLOSED_PASS
HYPERVOLUME_COMPUTED = YES
HV_ANCHORS_FROZEN = YES
HV_SCALE_MIN = [0.01473445910295798,0.18030701050054604,0.4043097419600721]
HV_SCALE_MAX = [0.1612259929049299,0.2817578635269986,0.6878844743274163]
HV_H_R5 = 0.8214144073536221
HV_C_R5 = 0.8596538595095115
HV_DIRECTION_R5 = C_GT_H
HV_H_R10 = 0.9749820881940048
HV_C_R10 = 1.0099628901072748
HV_DIRECTION_R10 = C_GT_H
HV_H_R20 = 1.3323674498747686
HV_C_R20 = 1.3592107397484303
HV_DIRECTION_R20 = C_GT_H
HV_DIRECTION = C_GT_H
HV_SENSITIVITY_STATUS = ROBUST_DIRECTION
INDEPENDENT_QC = PASS
CR1_COMP_12_COMPUTED = NO
```

CR1-COMP-11 calculó `HV(N_H)` y `HV(N_C)` con una normalización común derivada de `P=N_H∪N_C`. Inclusión–exclusión 3D y la descomposición independiente por celdas coincidieron dentro del criterio QC. C obtuvo mayor hypervolume en r5, r10 y r20; esta dirección es robusta únicamente dentro de los tres reference points preespecificados y representa cobertura del espacio objetivo anclado, no proximidad al frente verdadero ni superioridad estadística o física integral.

## CR1-COMP-12 cerrado bajo D014

```text
CR1-COMP-11 = CLOSED_PASS / FROZEN
CR1-COMP-12 = CLOSED_PASS
D014 = FROZEN_PASS

INITIAL_BLOCKER_TYPE = DOCUMENTARY_FLOAT_REPRESENTATION_IMPLEMENTATION_ISSUE
INITIAL_BLOCK_RESOLUTION = D014_FROZEN_IMPLEMENTATION_CONVENTION
SCIENTIFIC_DISCREPANCY = NO

RAW_H_DRY_TIME = 19.900000000000006 h
RAW_C_DRY_TIME = 19.9 h
RAW_DRY_TIME_VALUES_IDENTICAL = NO
NOMINAL_TERMINAL_HORIZON = 19.9 h

TERMINAL_REGIME_UPSTREAM =
H: 9/9 TMAX
C: 9/9 TMAX

COMPARATIVE_TERMINAL_REGIME = COMMON_TMAX_19P9H
TEMPORAL_COMPARABILITY = COMMON_FIXED_HORIZON
TERMINAL_REGIME_LIMITATION = FIXED_HORIZON_NOT_FREE_NORMAL_TERMINATION
INDEPENDENT_QC = PASS

CR1_COMP_13_COMPUTED = NO
OBJECTIVE_DECOMPOSITION_COMPUTED = NO
NEXT = CR1-COMP-13 — Objective decomposition, requiring separate authorization
```

D014 preserva las representaciones raw, no introduce tolerancia numérica y no modifica el protocolo v1.0. CR1-COMP-12 verificó que los 18 puntos comparten el régimen físico `TMAX` al horizonte nominal fijo de `19.9 h`. La terminación del optimizador CORRECTED_R1 por `MaxGenerations` es un concepto separado y no forma parte de este gate.

## CR1-COMP-13 cerrado

```text
CR1-COMP-13 = CLOSED_PASS
OBJECTIVE_DECOMPOSITION_COMPUTED = YES
F2_F3_DECOMPOSITION_COMPLETED = YES
MANDATORY_DECOMPOSITION_COMPLETE_H = YES
MANDATORY_DECOMPOSITION_COMPLETE_C = YES

Q_AUX_TOT_AVAILABILITY = COMPLETE_18
Q_LPG_INPUT_AVAILABILITY = COMPLETE_18
LPG_MASS_AVAILABILITY = COMPLETE_18
LPG_COST_AVAILABILITY = COMPLETE_18
IRRADIACION_AVAILABILITY = NOT_AVAILABLE
SOLAR_COST_AVAILABILITY = COMPLETE_18
E_AIR_IMPELLER_AVAILABILITY = COMPLETE_18
ELECTRICITY_COST_AVAILABILITY = COMPLETE_18
CO2_LPG_AVAILABILITY = COMPLETE_H_ONLY
CO2_ELECTRICITY_AVAILABILITY = COMPLETE_H_ONLY

REPRESENTATIVE_SOLUTION_SELECTION = DEFERRED_TO_CR1_COMP_14
CR1_COMP_14_COMPUTED = NO
SCIENTIFIC_INTERPRETATION = NOT_YET_COMPLETED
NEXT = CR1-COMP-14 — Physical, economic and environmental interpretation, requiring separate authorization
```

CR1-COMP-13 construyó una capa documental completa para los numeradores de costo y CO2 y el denominador común de agua removida de las 18 soluciones. `Irradiacion` no se reconstruyó desde energía solar; los componentes desagregados de CO2 sólo están persistidos para H. No hubo pairing H↔C, selección representativa ni interpretación causal.
