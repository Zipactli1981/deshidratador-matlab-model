# PHASE HANDOFF CURRENT
## CR1-COMP-01 Dataset Freeze → CR1-COMP-02 Within-set Exact Pareto Audit

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
COMPARATIVE_RESULTS = NOT_COMPUTED
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

## Autorización operativa

El protocolo está aprobado metodológicamente, pero la ejecución sigue bloqueada hasta autorización explícita:

```text
MATLAB_EXECUTION_AUTHORIZED = NO
CODEX_EXECUTION_AUTHORIZED = NO
GAMULTIOBJ_EXECUTION_AUTHORIZED = NO
```

Los scripts postrun, cuando se autoricen, sólo podrán leer artefactos existentes y realizar análisis comparativo; no podrán evaluar nuevamente el modelo ni llamar a `gamultiobj`.

## Próxima fase

```text
NEXT_PHASE = CR1-COMP-02_WITHIN_SET_EXACT_PARETO_AUDIT
```

### Estado del dataset canónico

La tabla canónica congelada contiene exactamente 18 registros:

```text
H01...H09
C01...C09
```

con:
- 4 variables de decisión;
- 3 objetivos;
- fuente;
- hash;
- fila/índice de origen;
- indicadores `finite` y `penalized`.

Requisitos:

```text
ALL_PRIMARY_VALUES_FROM_CANONICAL_VALIDATED_ARTIFACTS = YES
FULL_PRECISION_PRIMARY_VALUES_USED = PASS_WITH_DOCUMENTARY_RECOVERY_DEVIATION_CR1_COMP_01_D1
DATASET_ROWS = 18
HISTORICAL_ROWS = 9
CORRECTED_R1_ROWS = 9
```

Fuente inmediata: `CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY_v96z.json`, con preservación decimal y binary64 reproducible en el JSON canónico.

No existe emparejamiento implícito H01↔C01 por índice.

CR1-COMP-02 — Within-set exact Pareto audit — requiere autorización separada.

## Lo que todavía NO debe ejecutarse sin autorización separada

```text
NEW_MODEL_EVALUATION = NO
NEW_OBJECTIVE_REPLAY = NO
GAMULTIOBJ = NO
NEW_OPTIMIZATION = NO
```

La continuación con CR1-COMP-02 debe respetar la secuencia congelada en el protocolo v1.0 y requiere autorización separada.
