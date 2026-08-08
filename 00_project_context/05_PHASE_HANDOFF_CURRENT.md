# PHASE HANDOFF CURRENT
## Comparative Protocol v1.0 → CR1-COMP-01 Dataset Freeze

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
COMPARATIVE_DATASET = NOT_BUILT
COMPARATIVE_RESULTS = NOT_COMPUTED
SCIENTIFIC_INTERPRETATION = NOT_STARTED
MANUSCRIPT_CHANGES = NOT_STARTED
```

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
NEXT_PHASE = CR1-COMP-01_DATASET_FREEZE
```

### Objetivo de CR1-COMP-01

Construir una tabla canónica de exactamente 18 registros:

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
FULL_PRECISION_PRIMARY_VALUES_USED = YES
DATASET_ROWS = 18
HISTORICAL_ROWS = 9
CORRECTED_R1_ROWS = 9
```

Fuente numérica preferida: valores `double` de MAT canónicos.

No existe emparejamiento implícito H01↔C01 por índice.

## Lo que todavía NO debe ejecutarse sin autorización separada

```text
NEW_MODEL_EVALUATION = NO
NEW_OBJECTIVE_REPLAY = NO
GAMULTIOBJ = NO
NEW_OPTIMIZATION = NO
```

Después del dataset freeze se continuará con la secuencia CR1-COMP congelada en el protocolo v1.0.
