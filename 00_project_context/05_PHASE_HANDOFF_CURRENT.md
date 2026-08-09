# PHASE HANDOFF CURRENT
## CR1-COMP-04 Objective-space Descriptive Analysis → CR1-COMP-05 Exact Cross-dominance Matrix

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
COMPARATIVE_RESULTS = THROUGH_CR1_COMP_04_OBJECTIVE_SPACE_COMPUTED
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

CR1-COMP-04 realizó únicamente caracterización descriptiva del espacio de objetivos bajo D013. Los desplazamientos de medianas no son afirmaciones de superioridad multiobjetivo. No se realizó dominancia cruzada ni ninguna fase posterior.

## Próxima fase

```text
NEXT_PHASE = CR1-COMP-05_EXACT_CROSS_DOMINANCE_MATRIX
```

CR1-COMP-05 no está autorizada y requiere autorización separada.
