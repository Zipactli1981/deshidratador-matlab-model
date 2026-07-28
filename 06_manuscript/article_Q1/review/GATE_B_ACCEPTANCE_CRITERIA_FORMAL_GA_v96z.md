# Gate B acceptance criteria for formal GA v96z

Estado: propuesta metodológica documental
Fecha: 2026-07-28

## 1. Propósito y alcance

Gate B es el criterio documental de aceptación o rechazo que debe resolverse
antes de considerar cualquier R2/R3 o una corrida formal de 400 generaciones.
Evalúa si el propósito, la configuración, las métricas y la interpretación de
la siguiente fase están definidos de forma auditable.

Este documento no autoriza ejecutar MATLAB, `gamultiobj`, R1, R2, R3 ni una
corrida de 400 generaciones. Tampoco modifica o aprueba scripts, modelo,
física, objetivos, límites, semillas, costos, factores CO2, datos o
configuración del solver. Una salida PASS de Gate B requerirá además aprobación
explícita del usuario antes de cualquier ejecución.

Fuentes vigentes:

- [`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md):
  evidencia postrun vigente de R1;
- [`GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md`](GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md):
  separación metodológica entre Gate A y una eventual corrida formal.

## 2. Punto de partida: alcance de R1

R1 v96z es un `GATE_A_OPERATIONAL_SEEDAWARE_POSTRUN_PASS`. Su configuración
observada fue `PopulationSize=24`, `MaxGenerations=50` y semilla externa 61001.
El `exitflag=0` y el mensaje de parada por `options.MaxGenerations` confirman
que la corrida terminó al alcanzar 50 generaciones.

R1 demuestra que la cadena acotada produjo evidencia postrun consistente. No
demuestra convergencia del frente de Pareto, reproducibilidad entre semillas,
optimalidad global ni validez final de resultados o CO2.

## 3. Rutas que Gate B puede evaluar

### Ruta B1: minrep operativa a 50 generaciones

Esta ruta mantiene 50 generaciones exclusivamente para evaluar repetibilidad
operativa y sensibilidad a múltiples semillas bajo una configuración común.
No convierte las réplicas en una corrida formal de convergencia ni habilita
claims finales del manuscrito.

Antes de aceptarla deben quedar predeclarados:

- propósito estrictamente operativo de la minrep;
- conjunto de al menos tres semillas externas distintas, incluida R1, con
  evidencia de aplicación efectiva e independencia entre ejecuciones;
- configuración común y control de que no cambie entre réplicas;
- artefactos, variables, hashes y metadatos que debe conservar cada réplica;
- métricas y umbrales de estabilidad que se evaluarán después de las réplicas;
- regla de éxito, fallo, interrupción y tratamiento de corridas penalizadas.

La salida documental aplicable es `PASS_TO_MINREP_50GEN`. Esta etiqueta indica
que el diseño está completo; por sí sola no autoriza ejecutar R2/R3.

### Ruta B2: diseño formal de 400 generaciones

Esta ruta diseña una fase distinta de Gate A. El valor de 400 generaciones no
se adopta automáticamente por existir en antecedentes: debe justificarse y
quedar incorporado a un protocolo formal aprobado.

Antes de aceptarla deben quedar predeclarados:

- propósito científico y preguntas que responderá la corrida;
- `PopulationSize`, `MaxGenerations`, opciones del solver y criterio de parada;
- número de réplicas y conjunto de semillas externas independientes;
- criterio de convergencia y estabilidad del frente;
- normalización, punto de referencia y umbrales de las métricas;
- checkpoints, recuperación, estructura de outputs y política de artefactos;
- commit fuente, versión MATLAB, toolboxes, entradas externas y hashes;
- protocolo de selección de solución y comparación `hybrid` frente a `gasLP`;
- tratamiento de costo y CO2, incluidas sus limitaciones.

La salida documental aplicable es `PASS_TO_FORMAL_400GEN_DESIGN`. Indica que el
diseño puede someterse a aprobación de ejecución; no afirma que la corrida esté
autorizada ni que 400 generaciones garanticen convergencia.

## 4. Reproducibilidad y semillas

Una sola semilla permite trazabilidad de una ejecución, pero no demuestra
reproducibilidad. Gate B requiere múltiples semillas externas predeclaradas y
un protocolo que confirme para cada réplica:

- semilla solicitada, semilla aplicada y estado del control RNG;
- igualdad de código, entradas, límites y opciones;
- independencia de los estados RNG iniciales;
- ausencia de reutilización accidental de población o estado de una réplica;
- almacenamiento separado, identificación inequívoca y hash de artefactos;
- comparación conjunta de resultados sin seleccionar retrospectivamente la
  réplica más favorable.

El mínimo propuesto para la minrep operativa es tres semillas distintas. El
número requerido para una fase formal debe justificarse antes de ejecutarla y
no queda fijado definitivamente por este documento.

## 5. Estabilidad del frente de Pareto

El protocolo debe fijar antes de observar nuevas corridas las métricas,
normalización, referencias y umbrales de aceptación. Se propone evaluar:

| Dimensión | Métrica propuesta | Requisito de reproducibilidad |
|---|---|---|
| Factibilidad | Número y proporción de soluciones finitas/no penalizadas | Misma definición de penalización en todas las réplicas |
| Calidad global | Hipervolumen | Punto de referencia y escalamiento fijos y documentados |
| Distancia entre frentes | IGD o indicador epsilon respecto de un frente empírico combinado | Método de construcción del frente de referencia fijado antes del análisis |
| Diversidad | Spacing o spread | Misma normalización de objetivos |
| Extremos | Variación entre semillas de los mínimos por objetivo | Reportar mediana, rango e IQR; no elegir solo el mejor |
| Región de compromiso | Variación del punto seleccionado y sus objetivos | Aplicar una sola regla de selección predeclarada |
| Variables de decisión | Dispersión de las soluciones representativas | Mantener unidades, límites y criterio de emparejamiento |

No se declara estabilidad hasta que existan umbrales cuantitativos aprobados y
las réplicas los satisfagan. La presencia de soluciones finitas o un
`exitflag=0` no sustituye estas métricas.

## 6. Selección reproducible del punto representativo

Antes de cualquier fase de resultados debe aprobarse una única regla
determinista. La propuesta base es:

1. formar el conjunto factible no dominado usando todas las réplicas aprobadas;
2. normalizar MR, costo y CO2 con anclas externas fijas, documentadas antes de
   observar los nuevos resultados;
3. aplicar pesos predeclarados y seleccionar el punto con menor distancia
   ponderada al punto ideal;
4. resolver empates mediante un orden fijo: menor MR, menor costo, menor CO2 y,
   finalmente, orden lexicográfico de las variables de decisión;
5. conservar el índice, la réplica de origen, los valores sin normalizar, las
   anclas, los pesos y el cálculo completo.

Si no se aprueban anclas, pesos y desempate, Gate B debe emitir
`HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL`. La solución resultante solo podrá
denominarse óptima respecto de la regla aprobada, no óptimo global.

Mientras CO2 siga provisional, esta regla no puede sustentar una selección
triobjetivo final. Puede usarse únicamente para diagnóstico computacional
claramente etiquetado o debe mantenerse en HOLD.

## 7. Comparación defendible de `hybrid` frente a `gasLP`

La comparación debe ser pareada y cambiar únicamente el modo energético. Para
cada semilla deben mantenerse iguales:

- commit, cadena de funciones y versión MATLAB/toolboxes;
- datos ambientales, cinética del producto y condiciones iniciales;
- límites, población, generaciones, opciones y criterio de parada;
- normalización, penalizaciones y regla de selección;
- semillas y protocolo de almacenamiento.

El análisis debe comparar frentes completos y reportar, por semilla y de forma
agregada, factibilidad, hipervolumen, indicadores de distancia/diversidad,
distribución de objetivos y variación del punto representativo. No es
metodológicamente suficiente comparar solo dos puntos seleccionados o usar una
referencia `gasLP` obtenida con un presupuesto computacional distinto.

Si no existe un protocolo pareado aprobado, Gate B debe emitir
`HOLD_FOR_HYBRID_GASLP_PROTOCOL`.

## 8. Estado de CO2

CO2 permanece provisional hasta validar y aprobar:

- factores de emisión y fuente primaria de cada factor;
- unidades, conversiones y base funcional;
- límites del sistema y componentes incluidos/excluidos;
- correspondencia temporal y geográfica;
- tratamiento de electricidad, gas LP y demás portadores;
- incertidumbre, versión y trazabilidad de cualquier actualización.

Mientras estos elementos estén abiertos, ningún resultado de R1, minrep o
corrida formal puede sustentar claims ambientales finales. Si la ruta propuesta
depende de CO2 para selección, comparación o publicación, Gate B debe emitir
`HOLD_FOR_CO2_FACTOR_VALIDATION`.

## 9. Matriz de decisión Gate B

| Salida | Condiciones necesarias | Implicación | ¿Autoriza ejecución? |
|---|---|---|---|
| `PASS_TO_MINREP_50GEN` | Propósito operativo; mínimo tres semillas predeclaradas; configuración común; independencia RNG; artefactos y métricas definidos; sin claims de convergencia o CO2 | El diseño de minrep a 50 generaciones está documentalmente listo para aprobación separada | No |
| `PASS_TO_FORMAL_400GEN_DESIGN` | Justificación de 400 generaciones; configuración, semillas, convergencia, checkpoints, artefactos, selección y comparación definidos; bloqueos científicos identificados | El protocolo formal está listo para aprobación separada de ejecución | No |
| `HOLD_FOR_CO2_FACTOR_VALIDATION` | Factores, unidades, fuentes o límites del sistema CO2 no validados y la ruta pretende usar CO2 en decisiones o claims | Detener la ruta triobjetivo/publicable hasta cerrar trazabilidad CO2 | No |
| `HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL` | No hay anclas, pesos, regla determinista o desempate aprobados | No seleccionar ni presentar un punto como óptimo/representativo final | No |
| `HOLD_FOR_HYBRID_GASLP_PROTOCOL` | Los modos no comparten presupuesto, semillas, entradas, opciones o métricas comparables | No afirmar superioridad entre `hybrid` y `gasLP` | No |

Los HOLD tienen precedencia sobre los PASS cuando el bloqueo afecta el propósito
declarado de la ruta. Puede registrarse más de un HOLD simultáneo. La decisión
debe citar evidencia verificable para cada condición y ser aprobada
explícitamente por el usuario.

## 10. Criterio de aceptación y rechazo

Gate B acepta una ruta solo cuando:

- su propósito y alcance están definidos;
- todos los parámetros y semillas están predeclarados sin modificar código;
- las métricas, referencias y umbrales están fijados antes de nuevas corridas;
- existe una regla reproducible de selección;
- la comparación energética es pareada si forma parte del objetivo;
- los artefactos externos y su trazabilidad están inventariados;
- los bloqueos de CO2 son compatibles con el uso previsto o están cerrados;
- la aprobación explícita del usuario queda registrada por separado.

Gate B rechaza o mantiene en HOLD la ruta cuando falta cualquiera de esos
elementos, cuando se pretende inferir convergencia desde R1, cuando se propone
selección retrospectiva del mejor resultado o cuando se intenta formular un
claim no respaldado por el alcance de la evidencia.

## 11. Estado actual

Con la evidencia disponible:

- Gate A R1 está cerrado como PASS operativo con advertencias;
- R1 no demuestra convergencia;
- R2/R3 no han sido ejecutadas;
- la reproducibilidad multisemilla no está demostrada;
- CO2 continúa provisional;
- una corrida formal de 400 generaciones no está autorizada.

Por tanto, este documento define el mecanismo de Gate B, pero no asigna todavía
un PASS de ejecución a ninguna ruta.
