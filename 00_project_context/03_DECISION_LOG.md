# DECISION LOG — Deshidratador MATLAB / Q1

## D001 — Alcance físico
Mantener calentamiento directo de aire; circuito de agua y bombas fuera del alcance.

## D002 — Potencia eléctrica
Usar 1.03 kW medidos para el impulsor/ventilador durante todo el tiempo de secado.

## D003 — Eficiencia de quemador
`eta_burner = 0.78`; energía GLP = `Q_aux_tot / 0.78`.

## D004 — Denominador de f2/f3
Usar:
```text
water_removed_kg = (Mi - M_terminal) * md
```
El mismo denominador se usa para costo y emisiones específicas.

## D005 — Comparabilidad CORRECTED_R1
Conservar la configuración histórica explícita:
```text
seed 61001
PopulationSize 24
MaxGenerations 50
hybrid
gasLP reference
formal v96l bounds
```

## D006 — Build histórico
El build exacto histórico permanece desconocido; la incertidumbre se clasifica como documental no material:
```text
FULL_SOLVER_DEFAULTS_AUDIT =
PASS_WITH_DOCUMENTARY_BUILD_LIMITATION
```

## D007 — Puntos históricos reevaluados
Son muestras históricas reevaluadas bajo COST-E3D, no un frente Pareto corregido.

## D008 — CORRECTED_R1 postrun
La corrida está internamente validada, pero la interpretación científica queda pendiente de revisión comparativa.

## D009 — Diseño del protocolo comparativo

**Estado:** SUPERSEDED_BY_D010.

La decisión original era diseñar primero el protocolo comparativo antes de ejecutar cálculos.

## D010 — Protocolo comparativo v1.0 congelado

**Decisión:** adoptar `CORRECTED_R1 COMPARATIVE PROTOCOL v96z`, versión `v1.0`, con estado:

```text
FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
```

La arquitectura congelada incluye:
1. dataset de 18 soluciones;
2. auditoría interna exacta de H y C;
3. análisis descriptivo;
4. matriz cruzada 9x9;
5. diagnóstico near-tie separado;
6. set coverage completo y de núcleos;
7. nondominated sorting conjunto;
8. geometría del espacio objetivo;
9. gate condicional de hypervolume;
10. régimen terminal;
11. descomposición de f2/f3;
12. interpretación física/económica/ambiental;
13. implicaciones posteriores para manuscrito.

**Estado:** vigente.

## D011 — Metodología aprobada ≠ ejecución autorizada

**Decisión:** el congelamiento del protocolo no autoriza por sí mismo ejecutar MATLAB, Codex, `gamultiobj` ni scripts comparativos.

Cada implementación operativa CR1-COMP requiere autorización separada.

**Estado:** vigente.

## D012 — Recuperación documental de H.f2/f3 corregidos

**Decisión:** aceptar explícitamente bajo `CR1-COMP-01-D1` la recuperación documental de `H.f2/f3` corregidos desde la única fuente persistida validada:

```text
06_manuscript/article_Q1/review/COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md
SHA-256 = 7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2
NUMERIC_REPRESENTATION = VALIDATED_17_SIGNIFICANT_DIGIT_DECIMAL_SERIALIZATION
```

La búsqueda exhaustiva determinó que no se persistió un MAT con los `double` corregidos. La excepción se limita al requisito de persistencia/precisión de `H.f2/f3`: los bits binary64 originales no están disponibles y su identidad no puede verificarse independientemente. `H.X` y `H.f1` conservan como fuente primaria el MAT histórico; la reevaluación documentó reproducción de `f1` en las nueve filas.

No se autoriza replay ni nueva evaluación del objective. No cambia la definición exacta de dominancia ni ninguna otra regla del protocolo comparativo v1.0.

**Estado:** VIGENTE.

## D013 — Convenciones numéricas descriptivas CR1-COMP-03/04

**Decisión:** adoptar las siguientes convenciones deterministas para las estadísticas descriptivas requeridas por CR1-COMP-03 y CR1-COMP-04:

```text
STD_CONVENTION = POPULATION
STD_DDOF = 0
```

La desviación estándar se define como:

```text
std = sqrt(sum((x_i - mean(x))^2) / n)
```

H y C se tratan en CR1-COMP como conjuntos finitos específicos de soluciones, no como muestras aleatorias para inferencia poblacional o variabilidad entre corridas. La desviación estándar tiene una función exclusivamente descriptiva.

```text
IQR_CONVENTION = HYNDMAN_FAN_TYPE_7
h = 1 + (n - 1)p
Q1 = quantile(p=0.25, Type 7)
Q3 = quantile(p=0.75, Type 7)
IQR = Q3 - Q1
```

Cuando `h` no sea entero se usará interpolación lineal entre las observaciones ordenadas adyacentes. Type 7 se adopta como convención determinista y reproducible; no se afirma que sea la única convención válida posible.

Para la relación con los bounds:

```text
BOUND_PROXIMITY_RULE = DISTANCES_ONLY_NO_THRESHOLD
distance_to_lb = x - lb
distance_to_ub = ub - x
normalized_distance_to_lb = (x - lb)/(ub - lb)
normalized_distance_to_ub = (ub - x)/(ub - lb)
```

No se define ningún umbral de “near bound” ni se permite clasificar soluciones como próximas a límites mediante thresholds no congelados.

```text
APPLIES_TO = CR1-COMP-03, CR1-COMP-04
PROTOCOL_V1_MODIFIED = NO
RESULTS_OBSERVED_BEFORE_DECISION = NO
DESCRIPTIVE_RESULTS_COMPUTED_BEFORE_DECISION = NO
```

D013 define sólo convenciones de implementación descriptiva. No modifica H, C, el dataset, objetivos, bounds, dominancia, near-tie, coverage, Pareto rank, hypervolume, selección de soluciones ni interpretación física, económica o ambiental. La decisión se congeló después de detectar la omisión y antes de calcular resultados dependientes de `std` o IQR.

**Estado:** VIGENTE.

## D014 — Terminal-horizon documentary representation convention

```text
DECISION_STATUS = VIGENTE
CONTEXT = CR1-COMP-12

RAW_VALUES_PRESERVED = YES
H_DRY_TIME_RAW = 19.900000000000006
C_DRY_TIME_RAW = 19.9
RAW_FLOAT_EQUALITY = FALSE
ABS_RAW_DIFFERENCE_H = 7.105427357601002e-15

TERMINAL_HORIZON_EQUIVALENCE_BASIS =
COMMON_TMAX_TERMINAL_REGIME_AND_SHARED_NOMINAL_HORIZON

FLOAT_EQUALITY_REQUIRED_FOR_COMMON_HORIZON = NO
NUMERICAL_TOLERANCE_INTRODUCED = NO
ROUNDING_APPLIED_TO_RAW_VALUES = NO
RAW_VALUES_REWRITTEN = NO

NOMINAL_TERMINAL_HORIZON = 19.9 h
H_TMAX_COUNT = 9
C_TMAX_COUNT = 9

PROTOCOL_V1_MODIFIED = NO
PROTOCOL_DEVIATION = NO
IMPLEMENTATION_CONVENTION = YES
```

**Fundamento:** el protocolo congelado requiere verificar un horizonte terminal común, no identidad binaria de representaciones floating-point procedentes de serializaciones documentales distintas.

La equivalencia de horizonte se establece por:

1. clasificación terminal común `TMAX`;
2. mismo horizonte máximo nominal documentado de `19.9 h`;
3. preservación íntegra de los valores raw de cada fuente.

D014 no declara que `19.900000000000006 == 19.9` como valores floating-point. Declara que ambas representaciones documentan el mismo horizonte terminal nominal bajo el régimen `TMAX` común.

**Alcance científico:** D014 sólo permite concluir, si CR1-COMP-12 verifica posteriormente el resto de condiciones:

```text
COMPARATIVE_TERMINAL_REGIME = COMMON_TMAX_19P9H
TEMPORAL_COMPARABILITY = COMMON_FIXED_HORIZON
```

No permite concluir igualdad de trayectorias térmicas, energía, consumo de GLP, irradiación, agua removida, costo o CO2, ni convergencia del optimizador. No introduce `1e-12`, `eps`, `isclose`, redondeo ni ningún umbral decimal como criterio de equivalencia.

**Estado:** VIGENTE.

## D015 — Canonical source for CR1-COMP-15 full verdict text

```text
D015_STATUS = VIGENTE
DECISION_SCOPE = DOCUMENTARY_CANONICALIZATION_ONLY
TRIGGER = CR1_COMP_16_BLOCKED_VERDICT_IDENTITY_MISMATCH
REPRESENTATION_DISCREPANCY_OBSERVED_BEFORE_D015 = YES

CR1_COMP_15_SCIENTIFIC_RESULT_CHANGED = NO
CR1_COMP_15_RECOMPUTED = NO
CR1_COMP_15_REOPENED = NO

FINAL_COMPARATIVE_VERDICT_FULL_TEXT_SOURCE = CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_v96z.json
FINAL_COMPARATIVE_VERDICT_AUDIT_SOURCE = CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_AUDIT_v96z.md
JSON_AUDIT_FULL_VERDICT_IDENTITY = PASS
VERDICT_IDENTITY_NORMALIZATION = WHITESPACE_ONLY

CURRENT_STATE_VERDICT_ROLE = CONDENSED_STATE_SUMMARY
PHASE_HANDOFF_VERDICT_ROLE = CONDENSED_HANDOFF_SUMMARY
CURRENT_STATE_FULL_VERBATIM_IDENTITY_REQUIRED = NO
PHASE_HANDOFF_FULL_VERBATIM_IDENTITY_REQUIRED = NO
CONDENSED_SUMMARIES_MUST_NOT_CONTRADICT_FULL_VERDICT = YES

CR1_COMP_16_VERDICT_SOURCE_RULE = READ_FULL_FROZEN_VERDICT_FROM_CR1_COMP_15_JSON_AND_VERIFY_AGAINST_AUDIT
ASSISTANT_PROMPT_PARAPHRASE_CANONICAL = NO

PROTOCOL_V1_MODIFIED = NO
PROTOCOL_DEVIATION = NO
NEW_METRIC = NO
NEW_INTERPRETATION = NO
NEW_SCIENTIFIC_RESULT = NO
```

CR1-COMP-15 congela un vector cuantitativo más una narrativa. CR1-COMP-16 debe traducir esa evidencia congelada a implicaciones para el manuscrito. Una paráfrasis operativa posterior no puede reemplazar el veredicto upstream congelado. `CURRENT_STATE` y `PHASE_HANDOFF_CURRENT` pueden conservar resúmenes compactos para gestión de estado siempre que no contradigan el veredicto completo.

**Estado:** VIGENTE.
