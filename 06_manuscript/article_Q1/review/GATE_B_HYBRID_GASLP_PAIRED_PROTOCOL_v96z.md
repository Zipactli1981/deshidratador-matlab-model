# Gate B paired protocol for hybrid/gasLP v96z

Estado: protocolo metodológico documental propuesto
Fecha: 2026-07-28

## 1. Propósito y alcance

Este documento define el protocolo pareado requerido para levantar
`HOLD_FOR_HYBRID_GASLP_PROTOCOL` dentro de Gate B. Su propósito es asegurar que
una comparación futura entre los modos energéticos `hybrid` y `gasLP` sea
simétrica, reproducible y auditable.

Este protocolo no ejecuta ni autoriza MATLAB, `gamultiobj`, R1, R2, R3, una
minrep de 50 generaciones ni una corrida formal de 400 generaciones. Tampoco
modifica o aprueba scripts, modelo, física, objetivos, límites, semillas,
costos, factores CO2, datos o configuración del solver. Cualquier ejecución
posterior requerirá una autorización explícita e independiente.

## 2. Principio de comparación pareada

La comparación debe cambiar únicamente el modo energético. Cada par
`hybrid`/`gasLP` debe compartir:

- el mismo commit y la misma cadena de funciones;
- la misma versión de MATLAB y los mismos toolboxes;
- los mismos datos ambientales, cinética del producto y condiciones iniciales;
- los mismos límites y unidades de las variables de decisión;
- el mismo tamaño de población y número máximo de generaciones;
- las mismas opciones del solver y criterio de parada;
- las mismas funciones objetivo y reglas de penalización;
- la misma semilla externa y el mismo mecanismo de control RNG;
- el mismo presupuesto computacional;
- la misma política de outputs, auditoría y almacenamiento;
- las mismas métricas comparativas y, cuando corresponda, la misma regla de
  selección del punto representativo.

Toda diferencia distinta del modo energético invalida el carácter pareado,
salvo que haya sido predeclarada como una consecuencia física necesaria del
modo y documentada antes de ejecutar.

## 3. Unidad experimental y emparejamiento por semilla

La unidad de comparación es un par formado por:

```text
seed_i_hybrid
seed_i_gasLP
```

Para cada semilla externa predeclarada debe existir una corrida `hybrid` y una
corrida `gasLP`. Ambas deben registrar la semilla solicitada, la semilla
efectivamente aplicada y el estado de `rngControl`.

No se permite:

- sustituir una corrida formal `gasLP` por una referencia de preflight;
- comparar modos con semillas distintas;
- seleccionar retrospectivamente semillas favorables;
- reutilizar accidentalmente población o estado RNG entre modos o réplicas;
- excluir un miembro del par sin declarar el par incompleto.

Los resultados deben identificarse inequívocamente por modo, semilla, commit,
configuración y fecha. Un par incompleto puede conservarse como evidencia
diagnóstica, pero no puede sustentar una comparación entre modos.

## 4. Alternativas de presupuesto computacional

### 4.1 Minrep operativa de 50 generaciones

Una minrep a 50 generaciones puede evaluar repetibilidad operativa, integridad
de artefactos y sensibilidad inicial entre semillas. No demuestra convergencia
ni habilita resultados o claims finales del manuscrito.

Cada modo debe usar exactamente el mismo presupuesto de Gate B que se apruebe
para la minrep, incluido tamaño de población, generaciones, semillas y opciones.

### 4.2 Diseño formal de 400 generaciones

Una fase de 400 generaciones es un diseño distinto y solo puede considerarse
candidata a resultados publicables si:

- el número de generaciones y el tamaño de población están justificados;
- se aprueban previamente semillas, criterios de parada y convergencia;
- se definen checkpoints, recuperación y política de artefactos;
- se levantan o gestionan explícitamente los demás HOLD de Gate B;
- ambos modos reciben el mismo presupuesto computacional.

El valor de 400 generaciones no garantiza convergencia y este documento no lo
adopta ni autoriza automáticamente.

## 5. Outputs y evidencia mínima por modo y semilla

Cada miembro del par debe conservar, como mínimo:

- `X` y `F`;
- `population` y `scores`;
- `opts`, `lb` y `ub`;
- `rngSeed` y `rngControl`;
- `Tsummary` y `Tchecks`;
- tiempo de ejecución;
- `exitflag` y mensaje completo de `output`;
- identificación de modo, semilla, commit, MATLAB y toolboxes;
- entradas externas y sus hashes;
- hashes de artefactos MAT externos;
- registro de soluciones finitas, no penalizadas y penalizadas;
- evidencia suficiente para reconstruir la configuración sin modificarla.

Los artefactos deben almacenarse por separado y con nombres que impidan
sobrescrituras entre modos o semillas. La ausencia de un output obligatorio
debe marcar el miembro del par como incompleto.

## 6. Métricas comparativas predeclaradas

Las métricas, normalización, referencias y umbrales deben aprobarse antes de
observar nuevas corridas. Como mínimo, la comparación debe incluir:

| Dimensión | Métrica o evidencia | Condición pareada |
|---|---|---|
| Factibilidad | Número y proporción de soluciones finitas/no penalizadas | Misma penalización y mismo presupuesto |
| Calidad global | Hipervolumen | Mismo escalamiento y punto de referencia fijo |
| Distancia entre frentes | IGD o indicador epsilon | Mismo frente de referencia predefinido |
| Diversidad | Spacing o spread | Misma normalización |
| Rangos por objetivo | Mínimo, máximo, mediana e IQR | Reporte por semilla y agregado |
| Estabilidad | Variación entre semillas | No seleccionar solo la réplica más favorable |
| Variables de decisión | Dispersión de soluciones comparables | Mismas unidades, límites y emparejamiento |
| Punto representativo | Objetivos y variables seleccionados | Solo si existe protocolo de selección aprobado |

El análisis debe comparar los frentes completos por par y después resumir la
evidencia entre semillas. No es suficiente comparar únicamente dos puntos
seleccionados.

No debe interpretarse `exitflag=0`, la presencia de soluciones finitas ni una
ventaja en un solo indicador como evidencia aislada de convergencia o
superioridad global de un modo.

## 7. Reglas de invalidez

Un par es inválido para comparación final si ocurre cualquiera de las
siguientes condiciones:

- los modos usan diferente población, generaciones o presupuesto computacional;
- no comparten la misma semilla externa;
- cambian commit, solver, límites, datos, opciones, objetivos o penalizaciones;
- cambia la normalización o el punto de referencia entre modos;
- falta cualquiera de los outputs o metadatos obligatorios;
- un modo colapsa a penalizaciones o no produce soluciones finitas;
- `gasLP` existe solo como preflight o referencia no equivalente;
- se seleccionan o descartan semillas después de observar los resultados;
- la regla de selección difiere entre modos;
- no puede reconstruirse la configuración exacta de ambos miembros.

La invalidez no autoriza corregir retrospectivamente la corrida ni completar
datos por inferencia. Debe registrarse la causa y, si se propone repetir el
par, obtenerse una autorización separada.

## 8. Tratamiento provisional de CO2

El protocolo puede reservar y auditar una columna de CO2, pero
`HOLD_FOR_CO2_FACTOR_VALIDATION` permanece vigente. Mientras no se validen
factores, fuentes, unidades, conversiones, base funcional y límites del
sistema:

- CO2 no puede sustentar claims ambientales finales;
- CO2 no puede decidir una superioridad definitiva entre modos;
- no puede aprobarse una selección triobjetivo final basada en CO2;
- cualquier valor debe etiquetarse como provisional y diagnóstico.

La comparabilidad computacional de la columna no equivale a validez científica
de sus factores.

## 9. Relación con la selección del punto representativo

`HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL` permanece vigente. Hasta que se
aprueben anclas, normalización, pesos, distancia al punto ideal, desempate y
trazabilidad:

- deben priorizarse comparaciones de frentes completos;
- ningún punto puede llamarse óptimo global;
- un punto provisional solo puede usarse como diagnóstico claramente
  etiquetado;
- no puede afirmarse superioridad final a partir de puntos elegidos
  visualmente.

La aprobación futura del protocolo de selección deberá aplicarse sin cambios a
ambos modos.

## 10. Criterio documental para levantar el HOLD

`HOLD_FOR_HYBRID_GASLP_PROTOCOL` puede levantarse documentalmente cuando:

- este protocolo sea aprobado como diseño común;
- la unidad pareada por semilla esté definida;
- el presupuesto elegido esté predeclarado y sea idéntico entre modos;
- los outputs, metadatos y hashes obligatorios estén definidos;
- las métricas, referencias, normalización y umbrales estén aprobados;
- las reglas de invalidez y tratamiento de pares incompletos estén aceptadas;
- se confirme que una referencia `gasLP` de preflight no sustituirá una corrida
  comparable;
- quede registrada la autorización explícita del usuario para levantar solo
  este HOLD.

El levantamiento documental significa únicamente:

```text
HOLD_FOR_HYBRID_GASLP_PROTOCOL -> PROTOCOL_DEFINED
```

No significa que existan resultados pareados, que la comparación haya pasado,
que un modo sea superior ni que una ejecución esté autorizada.

## 11. Estado resultante y bloqueos remanentes

Si se aprueba este protocolo, Gate B puede registrar como levantado
exclusivamente `HOLD_FOR_HYBRID_GASLP_PROTOCOL`.

Permanecen vigentes:

- `HOLD_FOR_CO2_FACTOR_VALIDATION`;
- `HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL`.

Por tanto, aun después de levantar este HOLD:

- no se autoriza R2/R3;
- no se autoriza una corrida formal de 400 generaciones;
- no se autorizan claims finales de convergencia o reproducibilidad;
- no se autoriza una comparación ambiental final;
- no se autoriza seleccionar un punto representativo final.

Cualquier cambio de ese estado requiere una decisión Gate B posterior y una
autorización explícita e independiente.

## 12. Referencias

- [`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md)
- [`GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md`](GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md)
- [`GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md`](GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md)
- [`GATE_B_DECISION_CURRENT_STATUS_v96z.md`](GATE_B_DECISION_CURRENT_STATUS_v96z.md)
