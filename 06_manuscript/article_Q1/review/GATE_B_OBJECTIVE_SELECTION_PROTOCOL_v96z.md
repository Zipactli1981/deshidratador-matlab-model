# Gate B objective-selection protocol v96z

Estado: protocolo metodológico documental propuesto
Fecha: 2026-07-28

## 1. Propósito y alcance

Este documento define el protocolo reproducible requerido para levantar
`HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL` dentro de Gate B. Su propósito es fijar
antes de nuevas corridas una única regla determinista, auditable y común para
seleccionar un punto representativo de un frente de Pareto aprobado.

Este protocolo no ejecuta ni autoriza MATLAB, `gamultiobj`, R1, R2, R3, una
minrep de 50 generaciones ni una corrida formal de 400 generaciones. Tampoco
modifica o aprueba scripts, modelo, física, funciones objetivo, límites,
semillas, costos, factores CO2, datos o configuración del solver. No selecciona
ningún punto con la evidencia actual.

El levantamiento documental del HOLD significa únicamente que la regla de
selección queda definida. No demuestra convergencia, reproducibilidad,
optimalidad global, superioridad de un modo energético ni validez científica
de CO2.

## 2. Principios obligatorios

La selección debe cumplir simultáneamente:

- predeclaración: ninguna regla puede decidirse después de observar nuevas
  corridas;
- determinismo: las mismas entradas deben producir el mismo punto y la misma
  traza de selección;
- invariancia entre modos: `hybrid` y `gasLP` deben usar exactamente la misma
  regla, anclas, pesos, tolerancias y desempates;
- elegibilidad explícita: solo pueden competir soluciones factibles, finitas,
  no penalizadas y no dominadas provenientes de corridas aprobadas;
- trazabilidad: cada candidato y cada cálculo deben conservar su procedencia;
- separación entre protocolo y aplicación: definir la regla no autoriza
  ejecutarla sobre resultados nuevos;
- lenguaje limitado: el punto elegido es representativo respecto de la regla
  aprobada, no un óptimo global.

No se permite seleccionar visualmente un punto, escoger retrospectivamente la
réplica más favorable ni cambiar la regla para favorecer un modo o resultado.

## 3. Conjunto elegible

Antes de normalizar o calcular distancias debe construirse un conjunto elegible
con una secuencia fija:

1. incluir únicamente corridas y réplicas autorizadas para el análisis;
2. excluir pares `hybrid`/`gasLP` inválidos o incompletos cuando la selección
   forme parte de una comparación entre modos;
3. excluir filas con objetivos o variables no finitos;
4. excluir soluciones penalizadas o no factibles según la definición aprobada
   y común;
5. eliminar duplicados exactos conservando una regla estable de procedencia;
6. calcular el conjunto no dominado con las mismas direcciones de minimización
   y la misma tolerancia para todos los modos y semillas;
7. conservar el identificador original de modo, semilla, réplica, archivo,
   índice de fila y commit.

R1 v96z puede usarse únicamente como evidencia diagnóstica de la cadena
operativa. No puede por sí sola formar un conjunto elegible para una selección
final, porque no demuestra convergencia ni reproducibilidad multisemilla.

Cuando se comparen `hybrid` y `gasLP`, la regla se aplicará por separado a cada
modo sobre conjuntos construidos con el mismo diseño pareado. Una selección
sobre un frente combinado solo será admisible si ese uso se declara y aprueba
antes de las corridas; no puede sustituir la comparación de frentes completos.

## 4. Objetivos, sentido y unidades

El protocolo considera los tres objetivos declarados del estudio:

| Objetivo | Símbolo documental | Sentido | Condición |
|---|---|---|---|
| Métrica MR | `MR` | minimizar | Debe conservar definición y unidades aprobadas |
| Costo | `COST` | minimizar | Debe conservar base funcional, moneda, año y unidades |
| Emisiones de CO2 | `CO2` | minimizar | Permanece provisional mientras su HOLD siga activo |

Las unidades, transformaciones y direcciones no pueden inferirse desde los
resultados ni cambiar entre modos, semillas o réplicas.

## 5. Registro previo de anclas

Cada objetivo \(j\) debe tener dos anclas externas fijas:

- \(L_j\): ancla inferior o valor ideal documental;
- \(U_j\): ancla superior o valor de referencia adverso;
- con \(U_j > L_j\).

Las anclas deben registrarse y aprobarse antes de observar nuevas corridas. Para
cada una se conservarán:

- valor numérico y unidades;
- objetivo al que corresponde;
- fuente primaria o justificación física/metodológica;
- versión, fecha y responsable de aprobación;
- commit y documento donde quedó congelada;
- justificación de su aplicabilidad común a `hybrid` y `gasLP`.

No se permite usar como anclas primarias el mínimo y máximo observados en la
misma corrida o conjunto que se pretende evaluar. Ese escalamiento dependiente
de la muestra haría que la selección cambiara al agregar o retirar resultados.

Si una solución queda fuera del intervalo de anclas, el valor normalizado no
se recorta silenciosamente. Debe conservarse el valor extrapolado y registrarse
la incidencia. Si la extrapolación revela que las anclas no son científicamente
aplicables, la selección queda en HOLD; no se reajustan las anclas después de
ver los resultados.

## 6. Normalización

Para cada solución elegible \(i\) y objetivo de minimización \(j\), se define:

```text
z_ij = (f_ij - L_j) / (U_j - L_j)
```

El punto ideal normalizado es:

```text
z* = (0, 0, 0)
```

La normalización debe usar los mismos \(L_j\) y \(U_j\) para todos los modos,
semillas y réplicas incluidos en una misma comparación. Deben conservarse tanto
los valores originales como los normalizados.

## 7. Pesos primarios y análisis de sensibilidad

La regla primaria usa pesos iguales:

```text
w_MR = 1/3
w_COST = 1/3
w_CO2 = 1/3
```

Los pesos son no negativos y suman uno. Expresan una regla de compromiso
simétrica; no convierten objetivos con evidencia provisional en evidencia
validada.

Cualquier esquema alternativo de preferencias debe quedar aprobado antes de
las corridas y se reportará como análisis de sensibilidad, no como sustitución
retrospectiva de la regla primaria. Debe informarse si la identidad del punto
representativo cambia bajo escenarios predeclarados de pesos o anclas.

Mientras `HOLD_FOR_CO2_FACTOR_VALIDATION` permanezca activo, los pesos
triobjetivo anteriores solo definen el cálculo futuro y pueden usarse en
diagnóstico claramente etiquetado. No autorizan una selección triobjetivo final
ni claims ambientales.

## 8. Distancia al punto ideal y regla primaria

Para cada solución elegible se calcula la distancia euclidiana ponderada:

```text
d_i = sqrt(
    w_MR   * z_i,MR^2 +
    w_COST * z_i,COST^2 +
    w_CO2  * z_i,CO2^2
)
```

El punto representativo primario es la solución con el menor \(d_i\). La
distancia debe calcularse sin redondear los valores intermedios; el redondeo es
solo para presentación.

La misma ecuación, precisión numérica y biblioteca de cálculo deben aplicarse
a todos los modos y conjuntos comparados.

## 9. Empates y orden total reproducible

Dos distancias se consideran empatadas únicamente si cumplen una tolerancia
absoluta y relativa predeclarada y registrada con la implementación. Dentro de
ese conjunto empatado se aplica, en este orden:

1. menor `MR`;
2. menor `COST`;
3. menor `CO2`, solo cuando CO2 esté validado para selección final;
4. orden lexicográfico ascendente de las variables de decisión, en el orden
   aprobado del vector `X`;
5. orden estable por modo, semilla, réplica, archivo e índice de fila.

Mientras CO2 permanezca provisional, el paso 3 puede conservarse en una traza
diagnóstica, pero no decidir una selección final. Si el empate no puede
resolverse sin que CO2 decida, la salida será
`HOLD_FOR_CO2_FACTOR_VALIDATION`, no una elección arbitraria.

## 10. Aplicación por modo y entre semillas

Para evitar selección retrospectiva:

- todas las semillas aprobadas deben contribuir al conjunto elegible del modo;
- no se selecciona primero la mejor réplica para después descartar las demás;
- se conserva la semilla y réplica de origen del punto elegido;
- se reporta la frecuencia con que cada región del frente es representativa
  bajo las réplicas y análisis de sensibilidad;
- la regla se aplica de manera idéntica e independiente a `hybrid` y `gasLP`;
- la comparación principal sigue siendo entre frentes completos, no solo entre
  los dos puntos representativos.

Un punto representativo no corrige la falta de estabilidad entre semillas. Si
la estabilidad aprobada del frente no se cumple, el punto puede registrarse
solo como diagnóstico y no como resultado final.

## 11. Evidencia y traza obligatoria

Cada aplicación de la regla debe producir y conservar, sin modificar los
artefactos fuente:

- inventario de corridas incluidas y excluidas, con motivo;
- tabla de candidatos con valores originales y máscara de elegibilidad;
- máscara de factibilidad, penalización y no dominancia;
- modo, semilla, réplica, archivo, índice y commit de cada candidato;
- registro de anclas, unidades, fuentes, versiones y aprobación;
- pesos primarios y escenarios de sensibilidad predeclarados;
- objetivos normalizados;
- distancia de cada candidato y ranking completo;
- tolerancias numéricas y traza de desempate;
- identificación inequívoca del punto seleccionado;
- valores originales, normalizados y variables de decisión del punto;
- hashes de entradas y artefactos externos;
- versión del método y del entorno usado para el cálculo;
- incidencias, extrapolaciones y condiciones de HOLD.

Los resultados de selección deben poder reconstruirse a partir de esta
evidencia sin elegir manualmente una fila.

## 12. Reglas de invalidez

La selección es inválida para uso final si:

- las anclas o pesos se fijaron después de observar las corridas;
- se usaron mínimos o máximos de la muestra como anclas primarias;
- se mezclaron soluciones no factibles, penalizadas, dominadas o no finitas;
- se omitieron semillas o réplicas por conveniencia retrospectiva;
- `hybrid` y `gasLP` recibieron reglas, anclas o tolerancias distintas;
- faltan unidades, procedencia, hashes o la traza de cálculo;
- se modificaron objetivos, límites, datos o penalizaciones entre candidatos;
- se seleccionó visualmente un punto o se alteró el desempate;
- CO2 provisional decidió una selección presentada como final;
- el resultado se denominó óptimo global;
- no puede reproducirse exactamente el índice seleccionado.

Una selección inválida debe registrarse y permanecer en HOLD. No se permite
repararla por inferencia ni cambiar retrospectivamente la regla.

## 13. Tratamiento del HOLD de CO2

`HOLD_FOR_CO2_FACTOR_VALIDATION` permanece vigente. Hasta validar fuentes,
factores, unidades, conversiones, base funcional, límites del sistema,
correspondencia temporal/geográfica e incertidumbre:

- no se autoriza una selección triobjetivo final;
- CO2 no puede decidir claims ambientales ni superioridad definitiva;
- cualquier cálculo que incluya CO2 es provisional y diagnóstico;
- el protocolo puede quedar definido, pero su aplicación final permanece
  bloqueada.

La alternativa de excluir CO2 y hacer una selección biobjetivo no se adopta
automáticamente. Requeriría una decisión metodológica separada que justificara
el cambio de alcance y predeclarara nuevas anclas, pesos y lenguaje de claims.

## 14. Criterio documental para levantar el HOLD

`HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL` puede levantarse documentalmente
cuando:

- este protocolo sea aprobado como regla común;
- el conjunto elegible y la secuencia de filtrado estén definidos;
- el registro previo de anclas y sus fuentes sea obligatorio;
- la normalización y la distancia ponderada estén fijadas;
- los pesos primarios y la sensibilidad estén predeclarados;
- la tolerancia y el orden total de desempate estén definidos;
- la evidencia y las reglas de invalidez estén aceptadas;
- se confirme que la misma regla se aplicará a `hybrid` y `gasLP`;
- quede registrada la autorización explícita del usuario para levantar solo
  este HOLD.

El levantamiento documental significa únicamente:

```text
HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL -> PROTOCOL_DEFINED
```

No significa que las anclas numéricas ya estén validadas para una corrida
concreta, que un punto haya sido seleccionado, que la selección sea final ni
que una ejecución esté autorizada.

## 15. Estado resultante y bloqueos remanentes

Si se aprueba este protocolo, Gate B puede registrar como levantado
exclusivamente `HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL`.

Permanece vigente:

- `HOLD_FOR_CO2_FACTOR_VALIDATION`.

Ya está definido documentalmente:

- `HOLD_FOR_HYBRID_GASLP_PROTOCOL -> PROTOCOL_DEFINED`.

Por tanto, aun después de levantar este HOLD:

- no se autoriza MATLAB, R2 ni R3;
- no se autoriza una minrep de 50 generaciones;
- no se autoriza una corrida formal de 400 generaciones;
- no se autorizan claims finales de convergencia o reproducibilidad;
- no se autoriza una selección triobjetivo final;
- no se autoriza una comparación ambiental final.

Cualquier ejecución o cambio posterior del estado Gate B requiere una decisión
separada y autorización explícita.

## 16. Referencias

- [`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md)
- [`GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md`](GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md)
- [`GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md`](GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md)
- [`GATE_B_DECISION_CURRENT_STATUS_v96z.md`](GATE_B_DECISION_CURRENT_STATUS_v96z.md)
- [`GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md`](GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md)
