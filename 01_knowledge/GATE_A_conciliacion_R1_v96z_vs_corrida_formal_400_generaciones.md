# Conciliación metodológica: Gate A R1 v96z vs corrida formal de 400 generaciones

Estado: Decisión metodológica documental  
Fecha: 2026-07-28  
Repositorio: `Zipactli1981/deshidratador-matlab-model`  
Relación: Complementa ADR-001, la clasificación Gate A/Gate B v96z y la auditoría postrun R1  

No autoriza:

- ejecutar MATLAB, `gamultiobj`, R1, R2 o R3;
- modificar modelo, física, objetivos, límites, semillas, costos, factores de CO2 o datos;
- tratar la cadena candidata v96z como fuente oficial definitiva;
- usar resultados de R1 como evidencia de convergencia, reproducibilidad o resultado científico final.

## 1. Propósito

Este documento concilia dos niveles metodológicos que no deben confundirse:

1. la corrida R1 seed-aware v96z ya ejecutada con `PopulationSize=24` y
   `MaxGenerations=50`; y
2. la corrida formal de 400 generaciones planteada en el contexto previo del
   doctorado y del artículo.

La conciliación define el uso permitido de R1, identifica los controles ya
cerrados y conserva abiertos los requisitos necesarios antes de producir
resultados científicamente reportables.

## 2. Fuentes vigentes y precedencia

Para la R1 actual, la fuente de evidencia vigente es:

`06_manuscript/article_Q1/review/POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`

El archivo global:

`06_manuscript/article_Q1/review/SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.md`

y sus CSV asociados conservan evidencia histórica de una corrida anterior.
Están marcados como históricos/stale y no deben usarse para describir la R1
actual.

El ADR-001 mantiene la cadena v96z como candidata, no oficial. Este documento no
cambia ese estado.

## 3. Decisión central

La R1 v96z debe clasificarse como:

`GATE_A_OPERATIONAL_SEEDAWARE_POSTRUN_PASS_WITH_WARNINGS`

Su función es verificar que la cadena computacional corregida puede:

- recibir una semilla externa explícita;
- ejecutar el modo formal `hybrid` con referencia `gasLP`;
- producir candidatos finitos y no penalizados;
- guardar las variables principales de optimización;
- conservar evidencia postrun identificable por ruta y hash;
- sostener una auditoría reproducible sin volver a ejecutar el solver.

R1 no es equivalente ni sustituye la corrida formal de 400 generaciones. Puede
relacionarse con ella únicamente como ensayo controlado de instrumentación,
trazabilidad y sanidad computacional.

## 4. Evidencia confirmada de R1

La auditoría postrun vigente confirmó:

| Elemento | Valor verificado |
|---|---:|
| Semilla | 61001 |
| Control RNG | `EXTERNAL_SEED_APPLIED` |
| `PopulationSize` | 24 |
| `MaxGenerations` | 50 |
| Modo formal | `hybrid` |
| Referencia | `gasLP` |
| Tamaño de `X` | 9 x 4 |
| Tamaño de `F` | 9 x 3 |
| Soluciones | 9 |
| Filas finitas | 9 |
| Filas penalizadas | 0 |
| Generaciones | 50 |
| Evaluaciones de función | 1200 |
| `exitflag` | 0 |

El mensaje de parada fue:

`gamultiobj stopped because it exceeded options.MaxGenerations.`

Este mensaje es consistente con una terminación por límite de generaciones. No
es evidencia de convergencia del frente de Pareto.

Los valores mínimos de humedad residual, costo y CO2 almacenados en R1 son datos
de consistencia de esa corrida. Permanecen provisionales y no se adoptan aquí
como resultados finales del manuscrito.

## 5. Matriz de conciliación

| Control o criterio | Requerimiento metodológico | Estado en R1 v96z | Dictamen | Uso permitido |
|---|---|---|---|---|
| Trazabilidad previa y postrun | Identificar runner, configuración, outputs, tiempo y artefactos | Auditoría postrun y hashes disponibles | Cumple para Gate A | Evidencia operativa |
| Identificación de corrida | Evitar ambigüedad de producto, modo y versión | Runner R1 v96z, `hybrid`, referencia `gasLP`, seed 61001 | Cumple para R1 | Describir la prueba, no una corrida final |
| Semilla controlada | Aplicar y registrar una semilla externa | `EXTERNAL_SEED_APPLIED`, seed 61001 | Cumple para una corrida | Repetibilidad puntual, no reproducibilidad estadística |
| Captura de resultados | Conservar `X`, `F`, población, scores y opciones | Confirmados en MAT formal/raw | Cumple para Gate A | Auditoría y diagnóstico |
| Soluciones numéricamente utilizables | Evitar frente totalmente penalizado | 9 filas finitas, 0 penalizadas | PASS operativo | Sanidad numérica, no optimalidad global |
| Convergencia | Evidencia explícita de estabilidad o criterio satisfecho | `exitflag=0`, paro en 50 generaciones | No cumple | Prohibido declarar convergencia |
| Presupuesto de 400 generaciones | Alinear la corrida con el protocolo formal previo | R1 usó 50 generaciones | No equivalente | R1 no sustituye la corrida de 400 |
| Tamaño de población | Conciliar el valor formal esperado | R1 usó 24; antecedentes mencionan otros valores | Requiere decisión | Reportar solo como configuración de Gate A |
| Reproducibilidad multisemilla | Comparar réplicas independientes | Solo R1 actual; R2/R3 no ejecutadas | Abierto | Prohibido declarar robustez estadística |
| Historial de convergencia | Conservar evolución por generación y métricas del frente | No cerrado por la auditoría postrun actual | Parcial | Requisito antes de una corrida final |
| Checkpoints | Permitir recuperación y trazabilidad durante corridas largas | No confirmado para la cadena final | Abierto | Requisito operativo por definir |
| Selección de solución representativa | Definir criterio reproducible sobre el frente | No cerrado como decisión metodológica final | Abierto | No publicar un “óptimo” sin regla aprobada |
| Irradiancia híbrida | Confirmar que el modo híbrido no anula irradiancia | Preflight y cadena corregida aportan evidencia operativa | Parcial/condicionado | Conservar evidencia en la corrida formal |
| Comparación `hybrid` vs `gasLP` | Aplicar protocolo comparable a ambos modos | `hybrid` fue formal; `gasLP` fue referencia/preflight | Parcial | No afirmar superioridad final entre modos |
| CO2 | Usar factores, unidades y formulación aprobados | Marcado `PROVISIONAL_FOR_CODE_VALIDATION` | No cumple para claims | Solo verificación computacional |
| Fuente oficial de la cadena | Declarar una cadena metodológica aprobada | ADR-001 permanece como propuesta | Abierto | No llamar v96z “fuente definitiva” |

## 6. Relación entre Gate A y la corrida de 400 generaciones

| Aspecto | R1 v96z, 50 generaciones | Corrida formal de 400 generaciones |
|---|---|---|
| Propósito | Verificación operativa y de trazabilidad | Producción potencial de resultados reportables |
| Estado | Gate A PASS con advertencias | No ejecutada ni autorizada por este documento |
| Semillas | Una semilla documentada | Protocolo de réplicas por aprobar |
| Convergencia | No demostrada | Debe evaluarse con criterio explícito |
| Comparación de modos | Parcial | Debe usar protocolo comparable |
| Historial/checkpoints | Parcial o pendiente | Deben definirse antes de ejecutar |
| CO2 | Provisional | Solo reportable tras validar factores y unidades |
| Uso en manuscrito | Descripción interna/metodológica preliminar | Resultados, únicamente si pasa auditoría y criterios científicos |

El número 400 no debe adoptarse por inercia. Antes de autorizar una corrida de
esa longitud deben quedar documentados su origen metodológico, la población, las
semillas, el criterio de convergencia, el criterio de interrupción, los
checkpoints, el almacenamiento de resultados y la regla de selección de
soluciones. Si el manuscrito declara 400 generaciones, los resultados finales
deben provenir de una configuración coherente con esa declaración.

## 7. Implicaciones para el manuscrito

### Materials and Methods

- Tratar el modelo térmico como previamente desarrollado y validado con piña,
  citando el trabajo publicado correspondiente.
- Presentar el chile rojo como estudio numérico con cinética tomada de la
  literatura, salvo que se incorpore evidencia experimental adicional.
- No presentar R1 como el dataset formal definitivo.
- Reportar sin ambigüedad población, generaciones, semillas, modos y criterios
  de parada de cualquier corrida que finalmente sustente resultados.

### Results

- No usar los mínimos de R1 como valores finales del artículo.
- No interpretar las 9 soluciones finitas como prueba de convergencia u óptimo
  global.
- No declarar reproducibilidad a partir de una sola semilla.

### Discussion and limitations

- No afirmar superioridad final de `hybrid` frente a `gasLP` hasta disponer de
  corridas comparables.
- No formular claims ambientales finales mientras CO2 siga provisional.
- Declarar que una corrida detenida por `MaxGenerations` no demuestra
  convergencia.
- Mantener explícita la naturaleza computacional del estudio de chile rojo.

## 8. Requisitos antes de autorizar una fase posterior

Antes de R2/R3 o de una corrida de 400 generaciones debe aprobarse
documentalmente:

1. el rol exacto de Gate B y su relación con la corrida formal;
2. `PopulationSize` y `MaxGenerations`;
3. las semillas y el número de réplicas;
4. el criterio de convergencia y estabilidad del frente;
5. el criterio de éxito, fallo e interrupción;
6. el historial por generación que debe conservarse;
7. la política de checkpoints y recuperación;
8. la regla reproducible para seleccionar soluciones representativas;
9. el protocolo comparable para `hybrid` y `gasLP`;
10. los factores y unidades de CO2, o la exclusión temporal de claims de CO2;
11. el commit, entorno MATLAB, toolboxes, entradas y hashes;
12. el contrato de almacenamiento de resultados no versionados.

## 9. Decisiones que este documento no toma

Este documento no decide:

- que deban ejecutarse inmediatamente R2/R3;
- que 400 sea automáticamente el presupuesto correcto;
- que `PopulationSize=24` sea la configuración final;
- que la cadena candidata v96z sea oficial;
- que R1 sea evidencia científica;
- que los factores de CO2 sean válidos para publicación;
- que exista convergencia o reproducibilidad.

## 10. Próximo paso recomendado

El siguiente paso debe seguir siendo documental y no computacional: preparar y
aprobar un protocolo de Gate B/corrida formal que cierre los doce requisitos de
la sección 8.

Solo después de esa aprobación debe considerarse una ejecución. Cualquier
resultado futuro debe auditarse contra el protocolo aprobado y mantenerse
separado de la evidencia histórica.

## 11. Dictamen final

`R1_v96z_50_GENERATIONS_IS_GATE_A_OPERATIONAL_EVIDENCE`

`R1_v96z_IS_NOT_EQUIVALENT_TO_THE_400_GENERATION_FORMAL_RUN`

`DO_NOT_RUN_R2_R3_OR_400_GENERATIONS_WITHOUT_AN_APPROVED_PROTOCOL`

