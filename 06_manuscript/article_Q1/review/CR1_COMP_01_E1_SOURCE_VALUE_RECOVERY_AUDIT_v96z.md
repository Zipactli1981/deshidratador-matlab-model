# CR1-COMP-01-E1 — Source Value Recovery Audit

## 1. Propósito

Documentar la recuperación, verificación y congelamiento reproducible de los valores fuente H y C que podrán alimentar un micropaso posterior de construcción del dataset comparativo. Los artefactos E1 contienen 18 registros de recuperación, pero su rol es exclusivamente `SOURCE_VALUE_RECOVERY_ARTIFACT`; no constituyen el dataset comparativo canónico.

## 2. Fuentes y hashes verificados

```text
H_X_F1_ARTIFACT = 06_manuscript/article_Q1/runs/SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat
H_X_F1_SHA256 = A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0
H_MAT_SHA256_CHECK = PASS

H_F2_F3_ARTIFACT = 06_manuscript/article_Q1/review/COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md
H_F2_F3_SHA256 = 7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2
H_MEMO_SHA256_CHECK = PASS

C_X_F_ARTIFACT = 05_runs/triobjective_formal_ga_v96m/CORRECTED_R1_COST_E3D_v96z_20260808_005736/mat/CORRECTED_R1_COST_E3D_v96z.mat
C_X_F_SHA256 = 0AE9D8C90EEE645EC5BAB843A18F59CC1E68E2D84B31CBFD7ADD498C81EBDB3B
C_MAT_SHA256_CHECK = PASS

D1_ARTIFACT = 06_manuscript/article_Q1/review/CR1_COMP_01_D1_H_CORRECTED_F_DOCUMENTARY_RECOVERY_DECISION_v96z.md
D1_SHA256 = 01F3232ED40303C29F64C1970BE1EF0FAD11394609C6D489FA9D97E1474DBA0F
D1_SHA256_CHECK = PASS
```

Los cuatro hashes se verificaron antes de crear cualquier artefacto derivado E1.

## 3. Método de lectura y parsing

Los MAT se leyeron sin MATLAB mediante un lector determinista local del formato MAT v5. El lector:

1. verificó la cabecera y endianness del MAT;
2. descomprimió elementos `miCOMPRESSED` con `zlib`;
3. seleccionó matrices numéricas `mxDOUBLE_CLASS` por nombre;
4. leyó sus buffers `miDOUBLE` como IEEE-754 binary64 en orden column-major;
5. verificó que la reserialización column-major reproduce exactamente los bytes fuente.

```text
MAT_READER_EXACT_DOUBLE_STATUS = PASS_MAT_V5_RAW_MI_DOUBLE_BYTE_ROUNDTRIP
```

Del MAT histórico se tomaron únicamente `X(:,1:4)` y `F(:,1)`. `F(:,2:3)` histórico no se incorporó. Del MAT C se tomaron `X` y `F` directamente, sin ordenar, deduplicar ni emparejar filas H↔C.

Para H corregido, las columnas `f1 new`, `f2 new` y `f3 new` se extrajeron de la tabla de reevaluación del memo mediante parsing estricto de sus celdas Markdown. Los strings fuente de `f2 new` y `f3 new` se conservaron sin reformatear y se convirtieron mediante el parser binary64 estándar determinista; se registró simultáneamente cada string y su patrón hexadecimal IEEE-754.

## 4. Dimensiones, filas y finitud

```text
H_X_SHAPE = 9x4
H_F_HISTORICAL_SHAPE = 9x3
C_X_SHAPE = 9x4
C_F_SHAPE = 9x3

H_ROWS = 9
C_ROWS = 9

H_X_FINITE = YES
H_F1_FINITE = YES
H_RECOVERED_F2_F3_FINITE = YES
C_X_FINITE = YES
C_F_FINITE = YES
```

La correspondencia preservada es `H01 = R1 idx 1`, ..., `H09 = R1 idx 9`, y `C01 = source row 1`, ..., `C09 = source row 9`.

## 5. Bounds

Se verificaron ambos conjuntos contra:

```text
lb = [0.0540767982118, 57.6832965028, 0.422252618341, 8.6517528081]
ub = [0.0940767982118, 67.6832965028, 0.922252618341, 14]

H_BOUNDS_CHECK = PASS
C_BOUNDS_CHECK = PASS
```

## 6. Identidad de H.f1

La comparación de procedencia entre `F(:,1)` del MAT histórico y `f1 new` del memo, fila por fila, produjo:

```text
H_F1_MEMO_MAX_ABS_DIFF = 0
H_F1_IDENTITY_CHECK = PASS
```

Esto no fue un replay ni una evaluación del objective.

## 7. Precisión, procedencia y limitación D1

```text
H_X_F1_SOURCE = DIRECT_HISTORICAL_MAT_BINARY64
C_X_F_SOURCE = DIRECT_CORRECTED_R1_MAT_BINARY64
H_F2_F3_SOURCE_DECIMAL_PRESERVED = YES
H_F2_F3_RECOVERED_FROM_VALIDATED_17_DIGIT_DECIMAL = YES
H_F2_F3_RECOVERED_BINARY64_HEX_RECORDED = YES
H_F2_F3_ORIGINAL_BINARY64_PERSISTED = NO
```

La recuperación H.f2/f3 se rige por D1. El binary64 recuperado no se presenta como el `double` original persistido ni como identidad bit a bit independientemente verificada.

Los estados de penalización no se infirieron numéricamente: para C, la evidencia postrun validada registra cero filas penalizadas; para H, el memo registra `R1_UNEXPECTED_PENALTY_COUNT = 0`. E1 no ejecutó el objective para comprobarlos.

## 8. Artefactos derivados E1

```text
SOURCE_VALUE_RECOVERY_CSV = 06_manuscript/article_Q1/review/CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY_v96z.csv
SOURCE_VALUE_RECOVERY_CSV_SHA256 = 869A070F972319ABC0AC0BCD44EF6699E5C3BC92BAB53EB5328AEFB1275F7D2D

SOURCE_VALUE_RECOVERY_JSON = 06_manuscript/article_Q1/review/CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY_v96z.json
SOURCE_VALUE_RECOVERY_JSON_SHA256 = E3F591E154E686BB81D28EF8D02A0A13C3DD300C8A2E36181E2B765FCCC2DAAF

CSV_JSON_SCHEMA_VALIDATION = PASS
SOURCE_VALUE_RECOVERY_RECORDS = 18
```

Los valores MAT se serializaron como strings decimales round-trip de 17 dígitos y hex binary64. Para H.f2/f3 se conservaron además los strings decimales exactos del memo. Para C no se inventaron strings fuente documentales de f2/f3; esos campos se dejaron vacíos/null porque C procede directamente del MAT.

## 9. Exclusiones verificadas

```text
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
DOMINANCE_COMPUTED = NO
PARETO_SORTING_COMPUTED = NO
COVERAGE_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
COMPARATIVE_DESCRIPTIVE_STATISTICS_COMPUTED = NO
FIGURES_CREATED = NO
PRODUCTIVE_CODE_MODIFIED = NO
```

## 10. Estado final

```text
CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY = PASS
SOURCE_VALUE_RECOVERY_ARTIFACT_ROLE = SOURCE_VALUE_RECOVERY_ARTIFACT
COMPARATIVE_DATASET = NOT_BUILT
CR1_COMP_01_DATASET_FREEZE = NOT_YET_PASS
NEXT_CR1_COMP_01_STEP = CANONICAL_18_ROW_DATASET_CONSTRUCTION_AND_FREEZE
```

El siguiente micropaso requiere autorización separada.
