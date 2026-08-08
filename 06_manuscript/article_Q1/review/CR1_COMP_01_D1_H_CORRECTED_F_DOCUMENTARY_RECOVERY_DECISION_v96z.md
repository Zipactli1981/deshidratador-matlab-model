# CR1-COMP-01-D1 — H corrected-F documentary recovery decision

## 1. Propósito

Registrar la decisión metodológica estrecha que permite recuperar documentalmente los valores corregidos `H.f2` y `H.f3` sin ejecutar nuevamente el objective y sin construir todavía el dataset comparativo.

## 2. Evidencia observada

La inspección local exhaustiva cerró con:

```text
H_F_CORRECTED_FULL_PRECISION_ARTIFACT_FOUND = NO
H_F_CORRECTED_DECIMAL_VALIDATED_SOURCE_FOUND = YES
```

Se inspeccionaron 1,746 archivos, incluidos 1,002 ignorados y 323 contenedores MATLAB. Ningún MAT contiene los 18 valores corregidos `f2/f3`; ningún ZIP/XLSX los contiene; y las búsquedas textual, UTF-8, UTF-16 y numérica localizaron esos valores únicamente en el memo de reevaluación. No existe un harness R2G persistido ni un MAT, CSV, XLSX, log, package o checkpoint producido por esa reevaluación.

El memo registra nueve reproducciones PASS de `f1`, nueve verificaciones PASS de denominador canónico y compartido, nueve objetivos finitos, cero penalizaciones inesperadas y checks PASS de las cadenas de costo, CO2, GLP, solar y electricidad.

## 3. Problema de persistencia

Los `double` MATLAB originales de `H.f2/f3` corregidos no fueron persistidos. La única fuente corregida persistida es una serialización decimal validada con 17 dígitos significativos. Por tanto, no puede afirmarse que los bits binary64 originales estén disponibles ni que su identidad haya sido verificada independientemente.

## 4. Relación con el protocolo v1.0 §9.3

El protocolo comparativo v1.0 permanece congelado y sin modificación. Su §9.3 prefiere valores `double` de MAT canónicos y exige fuentes primarias validadas con precisión completa. D1 registra una excepción visible y limitada al control de persistencia/precisión de `H.f2/f3`; no sustituye silenciosamente el requisito ni crea una versión v1.1.

## 5. Decisión

```text
CR1_COMP_01_D1 = H_CORRECTED_F_DOCUMENTARY_RECOVERY_DECISION

H_X_PRIMARY_SOURCE = HISTORICAL_R1_MAT_MATLAB_DOUBLE
H_F1_PRIMARY_SOURCE = HISTORICAL_R1_MAT_MATLAB_DOUBLE
H_F2_F3_CORRECTED_SOURCE = 06_manuscript/article_Q1/review/COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md
H_F2_F3_SOURCE_SHA256 = 7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2
H_F2_F3_NUMERIC_REPRESENTATION = VALIDATED_17_SIGNIFICANT_DIGIT_DECIMAL_SERIALIZATION

ORIGINAL_H_F2_F3_BINARY64_BITS_PERSISTED = NO
ORIGINAL_H_F2_F3_BINARY64_IDENTITY_INDEPENDENTLY_VERIFIED = NO
NEW_OBJECTIVE_EVALUATION_REQUIRED = NO
NEW_OBJECTIVE_REPLAY_AUTHORIZED = NO
PROTOCOL_DEVIATION_SCOPE = DOCUMENTARY_NUMERIC_RECOVERY_ONLY
```

`H.f1` conserva como fuente primaria el MAT histórico porque su formulación no cambió y la reevaluación documentó reproducción de las nueve filas.

Control de precisión:

```text
H_X_FULL_PRECISION_SOURCE = YES
H_F1_FULL_PRECISION_SOURCE = YES
H_F2_F3_ORIGINAL_BINARY64_PERSISTED = NO
H_F2_F3_PRECISION_RECOVERY = 17_DIGIT_DECIMAL_SERIALIZATION
H_F2_F3_ORIGINAL_BINARY64_IDENTITY_INDEPENDENTLY_VERIFIED = NO
FULL_PRECISION_PRIMARY_VALUES_USED = PASS_WITH_DOCUMENTARY_RECOVERY_DEVIATION_CR1_COMP_01_D1
```

## 6. Alcance exacto de la desviación

D1 no modifica las definiciones de `f1/f2/f3`, dominancia exacta, near-tie, bounds, H, C ni las reglas CR1-COMP-02...16. No introduce tolerancia Pareto, puntos nuevos ni evidencia física nueva, y no convierte H en un frente Pareto corregido. La correspondencia documental conserva el orden original: `H01 = R1 idx 1`, ..., `H09 = R1 idx 9`.

## 7. Fuentes y SHA-256

Fuente primaria de `H.X` y `H.f1`:

```text
06_manuscript/article_Q1/runs/SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat
SHA-256 = A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0
```

Fuente documental validada de `H.f2/f3` corregidos:

```text
06_manuscript/article_Q1/review/COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md
SHA-256 = 7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2
```

Protocolo congelado no modificado:

```text
06_manuscript/article_Q1/review/CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md
SHA-256 = 8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
```

## 8. Limitaciones

```text
ORIGINAL_H_CORRECTED_DOUBLE_PRECISION_VERIFIED = NO
```

La serialización de 17 dígitos es la mejor evidencia numérica persistida disponible, pero D1 no afirma identidad bit a bit con los `double` originales no persistidos.

## 9. Acciones prohibidas

Esta decisión no autoriza MATLAB, `gamultiobj`, evaluaciones del modelo/objective, replay, scripts comparativos, dominancia, Pareto sorting, coverage, hypervolume, figuras, cambios de código productivo ni construcción del dataset de 18 filas.

## 10. Estado final

```text
CR1_COMP_01_D1_STATUS = PASS
H_F_CORRECTED_PROVENANCE = RESOLVED_WITH_DOCUMENTARY_RECOVERY_DEVIATION
COMPARATIVE_DATASET = NOT_BUILT
```

## 11. Siguiente micropaso — no autorizado todavía

`CR1-COMP-01` source-value recovery/freeze, sujeto a autorización separada.
