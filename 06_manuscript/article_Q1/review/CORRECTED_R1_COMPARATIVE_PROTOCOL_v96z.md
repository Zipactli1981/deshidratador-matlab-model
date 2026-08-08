# CORRECTED\_R1 COMPARATIVE PROTOCOL v96z

## v1.0 — FROZEN\_APPROVED\_FOR\_POSTRUN\_COMPARATIVE\_IMPLEMENTATION

**Proyecto:** Optimización multiobjetivo del deshidratador híbrido solar–GLP
**Fase:** COST-E3D → CORRECTED\_R1 — Revisión comparativa científica
**Versión:** v1.0
**Estado:** `FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION`
**Fecha:** 8 de agosto de 2026

---

# 1. Propósito

El presente protocolo establece la metodología congelada para contrastar:

1. las nueve soluciones generadas directamente por la ejecución `CORRECTED_R1`, utilizando la formulación COST-E3D corregida; y
2. los nueve vectores de decisión de la ejecución histórica R1, previamente reevaluados mediante la misma formulación COST-E3D corregida.

El protocolo busca determinar, de manera trazable y científicamente defendible:

- cómo difieren ambos conjuntos en el espacio de decisión;
- cómo difieren en el espacio de objetivos;
- qué relaciones de dominancia existen dentro de cada conjunto;
- qué relaciones de dominancia existen entre ambos conjuntos;
- cuáles soluciones permanecen no dominadas al considerar conjuntamente los 18 puntos;
- cómo se comparan los conjuntos completos y sus respectivos núcleos no dominados;
- si el hypervolume aporta información adicional;
- qué mecanismos físicos, económicos y ambientales explican los desplazamientos observados;
- y qué afirmaciones pueden incorporarse posteriormente al manuscrito.

Los criterios metodológicos se congelan **antes de calcular y emitir formalmente la comparación H-vs-C**, con el fin de reducir decisiones analíticas post hoc condicionadas por sus resultados.

---

# 2. Pregunta científica

La pregunta principal es:

> **¿Qué cambia cuando la formulación COST-E3D corregida se optimiza directamente, en comparación con los diseños generados históricamente bajo la formulación anterior y posteriormente reevaluados con COST-E3D?**

La comparación no constituye:

- una competición entre dos algoritmos;
- una comparación estadística entre dos configuraciones equivalentes;
- una prueba de convergencia global;
- ni una comparación entre dos campañas independientes con múltiples semillas.

Se comparan dos conjuntos finitos de diseños evaluados mediante la misma formulación actual, pero generados bajo procesos de optimización conceptualmente diferentes.

---

# 3. Definición de los conjuntos

Se define el conjunto histórico reevaluado:

[
H={(x\_i^H,F\_i^H)}\_{i=1}^{9},
]

y el conjunto generado directamente por CORRECTED\_R1:

[
C={(x\_j^C,F\_j^C)}\_{j=1}^{9}.
]

Para cada solución:

[
x=
[m\_{\max},T\_{\min},r\_{\mathrm{div2}},t\_{\mathrm{rec,ini}}],
]

y:

[
F=[f\_1,f\_2,f\_3].
]

El conjunto combinado será:

[
U=H\cup C,
]

con:

[
|U|=18.
]

Después de la auditoría de dominancia interna se definirán además:

[
N\_H=ND(H),
]

[
N\_C=ND(C),
]

donde `ND` representa el subconjunto no dominado bajo la definición exacta congelada en este protocolo.

---

# 4. Nomenclatura obligatoria

## 4.1 Conjunto histórico

Denominación recomendada:

**Historical R1 solutions reevaluated under corrected COST-E3D**

o:

**soluciones históricas R1 reevaluadas con COST-E3D corregido**.

No se utilizarán las expresiones:

- historical corrected Pareto front;
- frente Pareto histórico corregido;
- previous COST-E3D Pareto front;
- frente óptimo histórico reevaluado.

La reevaluación de los puntos históricos no implica que éstos hayan sido generados mediante optimización directa de COST-E3D.

---

## 4.2 Conjunto CORRECTED\_R1

Antes de verificar su dominancia interna, la denominación será:

**CORRECTED\_R1 solver-reported solution set**

o:

**conjunto de soluciones reportado por CORRECTED\_R1**.

Si las nueve soluciones resultan internamente no dominadas bajo el criterio exacto definido en este protocolo, podrá utilizarse:

**CORRECTED\_R1 nondominated approximation**

o:

**aproximación no dominada obtenida por CORRECTED\_R1**.

No se utilizarán:

- true Pareto front;
- exact Pareto front;
- global Pareto front.

---

# 5. Variables de decisión

El orden canónico del vector de decisión es:

[
x=
[m\_{\max},T\_{\min},r\_{\mathrm{div2}},t\_{\mathrm{rec,ini}}].
]

La implementación productiva asigna explícitamente los cuatro componentes del vector a `m_max`, `T_min`, `r_div2` y `t_rec_ini`.

| ÍndiceVariableInterpretación operativaUnidad |             |                                                            |              |
| -------------------------------------------- | ----------- | ---------------------------------------------------------- | ------------ |
| (x\_1)                                       | `m_max`     | parámetro base de flujo másico de aire del circuito        | kg/s         |
| (x\_2)                                       | `T_min`     | temperatura mínima antes de M9                             | °C           |
| (x\_3)                                       | `r_div2`    | fracción de la corriente de salida recirculada mediante D2 | adimensional |
| (x\_4)                                       | `t_rec_ini` | instante de inicio de la recirculación                     | h            |

El wrapper documenta `m_max` en kg/s, `T_min` en °C y convierte `t_rec_ini` de horas a segundos antes de usarlo internamente.

La interpretación de `r_div2` como fracción de recirculación está respaldada por:

[
m\_{D2}=m\_{\mathrm{DH,out}}r\_{\mathrm{div2}}
]

y:

# [ m\_{\mathrm{sink}}

m\_{\mathrm{DH,out}}(1-r\_{\mathrm{div2}}).
]

`m_max` no deberá interpretarse automáticamente como flujo efectivo constante durante toda la simulación, dado que el flujo en distintos tramos puede modificarse por la estrategia de recirculación.

---

# 6. Dominio de búsqueda congelado

[
lb=
[0.0540767982118,;
57.6832965028,;
0.422252618341,;
8.6517528081]
]

[
ub=
[0.0940767982118,;
67.6832965028,;
0.922252618341,;
14].
]

Estos límites pertenecen a la configuración formal congelada de CORRECTED\_R1.

Los límites se utilizarán únicamente para:

- verificar factibilidad;
- identificar proximidad a fronteras;
- normalizar desplazamientos en el espacio de decisión.

No se modificarán durante la fase comparativa.

---

# 7. Objetivos canónicos

El vector objetivo es:

[
F=[f\_1,f\_2,f\_3],
]

donde:

[
f\_1=MR\_{\mathrm{final}},
]

[
f\_2=
\frac{total\_cost\_USD}
{water\_removed\_kg},
]

y:

[
f\_3=
\frac{total\_CO2\_kg}
{water\_removed\_kg}.
]

La función objetivo formal utiliza explícitamente:

```
f(1) = MR_final
f(2) = cost_specific_USD_per_kgwater
f(3) = CO2_specific_kgCO2_per_kgwater

```

| ObjetivoNombre canónicoUnidadDirección |                                  |                           |           |
| -------------------------------------- | -------------------------------- | ------------------------- | --------- |
| (f\_1)                                 | `MR_final`                       | adimensional              | minimizar |
| (f\_2)                                 | `cost_specific_USD_per_kgwater`  | USD/kg de agua removida   | minimizar |
| (f\_3)                                 | `CO2_specific_kgCO2_per_kgwater` | kgCO₂/kg de agua removida | minimizar |

La documentación de diseño establece explícitamente los tres objetivos, sus unidades y su sentido de minimización.

---

# 8. Alcance económico y ambiental

El objetivo (f\_2) representa:

> **costo específico modelado de energía operativa por unidad de agua removida.**

No representa:

- costo total de propiedad;
- inversión;
- mantenimiento;
- mano de obra;
- costos fijos;
- cargos integrales de demanda o distribución;
- costo total comercial del proceso.

El handoff canónico indica que el componente eléctrico es un proxy de costo energético operativo y excluye distintos cargos adicionales.

El objetivo (f\_3) representa:

> **emisiones específicas operativas de CO₂ incluidas en la implementación actual.**

Incluye:

- CO₂ asociado al GLP;
- CO₂ asociado a la electricidad.

No incluye actualmente:

- emisiones de ciclo de vida;
- fabricación de equipos;
- infraestructura;
- transporte;
- mantenimiento;
- emisiones solares incorporadas.

La implementación actual no incluye un término de CO₂ asociado al componente solar.

La comparación relativa entre (H) y (C) sigue siendo válida porque ambos conjuntos utilizan exactamente la misma frontera del modelo.

---

## 8.1 Nomenclatura CO₂ / CO₂e

Durante esta fase se preservará el nombre computacional canónico:

```
CO2_specific_kgCO2_per_kgwater

```

La documentación de factores contiene simultáneamente:

- `LPG_CO2_FACTOR = 3.00 kgCO2/kg_LPG`;
- `GRID_CO2_FACTOR = 0.444 kgCO2e/kWh`.

Por tanto:

```
CO2_UNIT_LABEL_STATUS =
COMPUTATIONAL_NAME_PRESERVED_PENDING_MANUSCRIPT_EDITORIAL_RECONCILIATION

```

Esta cuestión no altera ninguna comparación numérica de la fase actual, pero deberá resolverse antes de la versión final del manuscrito.

---

# 9. Congelamiento del dataset comparativo

Antes de cualquier análisis se construirá una tabla canónica de exactamente 18 registros.

## 9.1 Estructura primaria

| CampoDescripción                 |                                       |
| -------------------------------- | ------------------------------------- |
| `solution_id`                    | `H01...H09` o `C01...C09`             |
| `source`                         | `HIST_R1_REEVAL` o `CORRECTED_R1`     |
| `source_index`                   | índice dentro del artefacto de origen |
| `m_max`                          | variable de decisión 1                |
| `T_min`                          | variable de decisión 2                |
| `r_div2`                         | variable de decisión 3                |
| `t_rec_ini`                      | variable de decisión 4                |
| `MR_final`                       | objetivo 1                            |
| `cost_specific_USD_per_kgwater`  | objetivo 2                            |
| `CO2_specific_kgCO2_per_kgwater` | objetivo 3                            |
| `source_artifact`                | artefacto canónico de origen          |
| `source_hash`                    | hash registrado                       |
| `source_row`                     | índice o fila fuente                  |
| `finite`                         | indicador de valores finitos          |
| `penalized`                      | indicador de penalización             |

---

## 9.2 Campos de descomposición

Los siguientes campos no son obligatorios para construir el dataset primario de dominancia:

- `dry_time_h`;
- `termination_class`;
- `water_removed_kg`;
- `total_cost_USD`;
- `total_CO2_kg`;
- componentes energéticos, económicos y ambientales.

Sin embargo:

> `water_removed_kg`, `total_cost_USD` y `total_CO2_kg` serán obligatorios para toda solución seleccionada posteriormente para interpretación física, económica o ambiental.

Dichos datos deberán recuperarse exclusivamente de:

- artefactos ya validados;
- detail replay previamente validado;
- tablas de auditoría canónicas ya existentes.

Si algún dato obligatorio de descomposición no está disponible:

```
INTERPRETATION_STATUS =
BLOCKED_MISSING_VALIDATED_DECOMPOSITION_DATA

```

No se ejecutará automáticamente una nueva evaluación del modelo.

La reevaluación histórica ya verificó para las nueve soluciones `detail.cost`, `detail.CO2` y las cadenas correspondientes.

---

## 9.3 Fuente numérica prioritaria

Los valores primarios deberán provenir de artefactos canónicos validados y conservar precisión completa.

La fuente preferida será el valor `double` almacenado en MAT cuando esté disponible.

No se utilizarán como fuente primaria valores redondeados copiados de:

- CSV;
- Markdown;
- consola;
- figuras;
- tablas del manuscrito;
- capturas de pantalla.

Los CSV podrán utilizarse para trazabilidad y representación tabular.

El requisito de control será:

```
ALL_PRIMARY_VALUES_FROM_CANONICAL_VALIDATED_ARTIFACTS = YES
FULL_PRECISION_PRIMARY_VALUES_USED = YES

```

---

## 9.4 Regla de identidad

No existe correspondencia implícita entre:

```
H01 ↔ C01
H02 ↔ C02
...
H09 ↔ C09

```

El índice sólo representa posición dentro del conjunto de origen.

Cualquier emparejamiento posterior deberá basarse en un criterio explícito y documentado.

---

# 10. Auditoría de dominancia interna

Antes de comparar (H) contra (C), se realizará una auditoría interna independiente de cada conjunto.

Se calcularán:

[
N\_H=ND(H),
]

y:

[
N\_C=ND(C).
]

Cada conjunto de nueve puntos contiene:

[
\binom{9}{2}=36
]

pares internos.

Por tanto:

```
H_INTERNAL_PAIR_COUNT = 36
C_INTERNAL_PAIR_COUNT = 36

```

La auditoría determinará:

```
H_INTERNAL_NONDOMINATED_COUNT
H_INTERNAL_DOMINATED_COUNT

C_INTERNAL_NONDOMINATED_COUNT
C_INTERNAL_DOMINATED_COUNT

```

También deberá identificar:

- qué soluciones son internamente dominadas;
- qué soluciones las dominan;
- si existen vectores objetivo exactamente iguales.

La reevaluación histórica anterior no realizó nondominated sorting sobre los nueve puntos.

---

# 11. Dominancia de Pareto exacta

La comparación principal utilizará los valores de precisión completa sin tolerancia insertada en la definición de Pareto.

Para minimización, una solución (a) domina a una solución (b) si:

[
f\_k(a)\le f\_k(b)
\quad
\forall k
]

y existe al menos un objetivo (j) tal que:

[
f\_j(a)\<f\_j(b).
]

Formalmente:

[
a\prec b
\iff
\left[
f\_k(a)\le f\_k(b);\forall k
\right]
\land
\left[
\exists j\:f\_j(a)\<f\_j(b)
\right].
]

Dos soluciones serán exactamente iguales en el espacio objetivo si:

[
f\_k(a)=f\_k(b)
\quad
\forall k.
]

La categoría se denominará:

```
EXACT_OBJECTIVE_VECTOR_EQUALITY

```

---

# 12. Diagnóstico de sensibilidad numérica

El valor (10^{-12}) no se utilizará para definir dominancia ni para asignar Pareto rank.

Se utilizará únicamente como diagnóstico de proximidad numérica:

# [ \tau\_k(a,b)

10^{-12}
\max
\left(
1,
|f\_k(a)|,
|f\_k(b)|
\right).
]

Para cada objetivo:

```
NUMERIC_NEAR_TIE_k = YES

```

si:

[
|f\_k(a)-f\_k(b)|\le\tau\_k.
]

---

## 12.1 Dominancia numéricamente frágil

Para cada relación exacta:

[
a\prec b,
]

se define el conjunto de mejoras estrictas:

[
S(a,b)=
{k\:f\_k(a)\<f\_k(b)}.
]

La relación se clasificará como:

```
DOMINANCE_RELATION_NUMERICALLY_FRAGILE = YES

```

si:

[
|f\_k(a)-f\_k(b)|\le\tau\_k
\quad
\forall k\in S(a,b).
]

Es decir, si **todas** las desigualdades estrictas que permiten establecer la dominancia se encuentran dentro del umbral de proximidad numérica.

Si existe al menos una mejora estricta (k\in S(a,b)) tal que:

[
|f\_k(a)-f\_k(b)|>\tau\_k,
]

entonces:

```
DOMINANCE_RELATION_NUMERICALLY_FRAGILE = NO

```

El Pareto rank no se modificará en ninguno de los dos casos.

---

## 12.2 Resultado agregado

Se registrarán:

```
NEAR_TIE_OBJECTIVE_COUNT
NUMERICALLY_FRAGILE_DOMINANCE_COUNT

```

Si:

```
NUMERICALLY_FRAGILE_DOMINANCE_COUNT = 0

```

entonces:

```
DOMINANCE_NUMERIC_SENSITIVITY =
PASS_NO_FRAGILE_DOMINANCE

```

En caso contrario:

```
DOMINANCE_NUMERIC_SENSITIVITY =
REVIEW_FRAGILE_RELATIONS_PRESENT

```

`FunctionTolerance=1e-5` y `ConstraintTolerance=1e-6` pertenecen al solver y no se utilizarán como criterios postrun de dominancia.

---

# 13. Análisis descriptivo del espacio de decisión

Para cada variable y conjunto se calcularán:

- mínimo;
- máximo;
- media;
- mediana;
- desviación estándar;
- rango;
- rango intercuartílico.

Estas cantidades se denominarán:

> **resúmenes descriptivos del conjunto de puntos**.

No se interpretarán como estimadores estadísticos de un frente continuo ni como propiedades poblacionales del algoritmo.

Se calculará:

# [ \Delta \tilde{x}\_k

## \tilde{x}\_{k,C}

\tilde{x}\_{k,H},
]

y:

# [ \Delta x\_{k,\mathrm{norm}}

## \frac{ \tilde{x}\_{k,C}

\tilde{x}\_{k,H}
}{
ub\_k-lb\_k
}.
]

También se evaluará:

- proximidad a `lb`;
- proximidad a `ub`;
- amplitud ocupada;
- aparición de regiones nuevas;
- concentración o dispersión relativa;
- regiones históricas no reproducidas.

La interpretación principal deberá apoyarse en geometría, rangos, extremos y dominancia, no exclusivamente en medias o medianas.

---

# 14. Análisis descriptivo del espacio objetivo

Para (f\_1,f\_2,f\_3), por conjunto:

- mínimo;
- máximo;
- media;
- mediana;
- desviación estándar;
- rango;
- rango intercuartílico.

Se calculará:

# [ \Delta\tilde f\_k

## \tilde f\_{k,C}

\tilde f\_{k,H}.
]

Cuando resulte interpretable:

# [ \Delta f\_{k,%}

## 100 \frac{ \tilde f\_{k,C}

\tilde f\_{k,H}
}{
\tilde f\_{k,H}
}.
]

Una mejora marginal de:

- media;
- mediana;
- mínimo;
- rango;

no constituirá por sí sola evidencia de superioridad multiobjetivo.

---

# 15. Pruebas estadísticas no autorizadas

Los nueve puntos de cada conjunto no son nueve réplicas independientes del experimento computacional.

Por tanto, no se realizarán sobre (H) y (C):

- t-test;
- Mann–Whitney;
- ANOVA;
- pruebas de significancia;
- intervalos de confianza interpretados como variabilidad entre corridas.

La estadística descriptiva tendrá exclusivamente una función de caracterización del conjunto finito de soluciones.

---

# 16. Matriz de dominancia cruzada

Después de la auditoría interna se construirán:

[
9\times9=81
]

comparaciones entre:

[
C\_i
\quad\text{y}\quad
H\_j.
]

Cada par recibirá exactamente una categoría:

```
C_DOMINATES_H
H_DOMINATES_C
INCOMPARABLE
EXACT_OBJECTIVE_VECTOR_EQUALITY

```

El diagnóstico de near-tie se registrará de manera independiente.

---

## 16.1 Resultados por solución

Para cada solución se calculará:

- número de soluciones del otro conjunto que domina;
- número de soluciones del otro conjunto por las que es dominada;
- número de relaciones incomparables;
- número de igualdades exactas;
- número de comparaciones con near-tie;
- número de relaciones de dominancia numéricamente frágiles.

---

## 16.2 Resultados agregados

Se calcularán:

```
C_DOMINATES_H_PAIR_COUNT
H_DOMINATES_C_PAIR_COUNT
INCOMPARABLE_PAIR_COUNT
EXACT_EQUAL_PAIR_COUNT

```

y:

[
N\_{H\leftarrow C}
]

número de soluciones históricas dominadas por al menos una solución CORRECTED\_R1, así como:

[
N\_{C\leftarrow H}
]

número de soluciones CORRECTED\_R1 dominadas por al menos una histórica.

---

# 17. Set coverage a dos niveles

La cobertura se reportará en dos niveles conceptualmente distintos.

---

## 17.1 Cobertura de conjuntos completos

Se calculará:

# [ C\_{\mathrm{full}}(C,H)

\frac{
|{h\in H:\exists c\in C,;c\prec h}|
}{
|H|
}
]

y:

# [ C\_{\mathrm{full}}(H,C)

\frac{
|{c\in C:\exists h\in H,;h\prec c}|
}{
|C|
}.
]

Estos indicadores responden:

> **¿qué proporción de los nueve diseños concretos de un conjunto es dominada por alguna solución del otro conjunto?**

Se reportarán como:

```
FULL_COVERAGE_C_OVER_H
FULL_COVERAGE_H_OVER_C

```

---

## 17.2 Cobertura de núcleos no dominados

También se calculará:

# [ C\_{\mathrm{core}}(N\_C,N\_H)

\frac{
|{h\in N\_H:\exists c\in N\_C,;c\prec h}|
}{
|N\_H|
}
]

y:

# [ C\_{\mathrm{core}}(N\_H,N\_C)

\frac{
|{c\in N\_C:\exists h\in N\_H,;h\prec c}|
}{
|N\_C|
}.
]

Se reportarán como:

```
CORE_COVERAGE_NC_OVER_NH
CORE_COVERAGE_NH_OVER_NC

```

Estos indicadores responden:

> **¿cómo se comparan las partes competitivas no dominadas de ambas aproximaciones?**

Para afirmaciones sobre mejora de la **aproximación no dominada**, la cobertura de los núcleos tendrá prioridad interpretativa sobre la cobertura de los nueve conjuntos completos.

---

# 18. Significado científico de la dominancia

Si:

[
c\prec h,
]

la afirmación permitida será:

> Bajo la misma formulación COST-E3D corregida, la solución CORRECTED\_R1 (c) es no peor en los tres objetivos y estrictamente mejor en al menos uno respecto de la solución histórica reevaluada (h).

También podrá afirmarse:

> La reoptimización directa de COST-E3D permitió encontrar una alternativa que domina ese diseño histórico.

Si la solución histórica ya era internamente dominada dentro de (H), ello deberá distinguirse de la dominancia de una solución perteneciente a (N\_H).

No podrá concluirse exclusivamente de una relación de dominancia que:

- el modelo físico sea más correcto;
- el sistema real haya mejorado;
- el algoritmo sea estadísticamente superior;
- CORRECTED\_R1 haya convergido al frente verdadero;
- COST-E3D sea inherentemente superior a toda formulación anterior.

---

# 19. Nondominated sorting conjunto

Se aplicará nondominated sorting exacto a:

[
U=H\cup C.
]

Cada solución recibirá:

```
ParetoRank = 1,2,3,...

```

Se determinará:

```
JOINT_RANK1_H
JOINT_RANK1_C
JOINT_RANK2_H
JOINT_RANK2_C
...

```

El análisis identificará:

- históricos que sobreviven en `Rank 1`;
- soluciones CORRECTED\_R1 fuera de `Rank 1`;
- regiones exclusivas de cada conjunto;
- extremos no reproducidos;
- compromisos presentes en ambos conjuntos.

El primer rango será denominado:

> **joint nondominated set of the 18 evaluated solutions**

o:

> **conjunto no dominado conjunto de las 18 soluciones evaluadas**.

No se denominará frente Pareto verdadero.

---

# 20. Geometría del espacio objetivo

Se analizarán:

[
f\_1-f\_2,
]

[
f\_1-f\_3,
]

[
f\_2-f\_3,
]

y:

[
f\_1-f\_2-f\_3.
]

Se buscará determinar si CORRECTED\_R1 produce:

- traslación;
- expansión;
- contracción;
- nuevos extremos;
- nuevos compromisos;
- pérdida de regiones históricas;
- predominio por dominancia;
- reestructuración del trade-off.

La geometría deberá interpretarse junto con:

- dominancia interna;
- dominancia cruzada;
- set coverage;
- Pareto rank.

---

# 21. Visualizaciones mínimas

Deberán generarse:

1. coordenadas paralelas de las cuatro variables de decisión;
2. coordenadas paralelas de los tres objetivos;
3. gráfico (f\_1-f\_2);
4. gráfico (f\_1-f\_3);
5. gráfico (f\_2-f\_3);
6. gráfico tridimensional (f\_1-f\_2-f\_3);
7. matriz o mapa de dominancia cruzada;
8. figura de Pareto rank conjunto.

Las primeras figuras descriptivas deberán incluir todos los puntos, dominados o no.

---

# 22. Hypervolume

El hypervolume será una métrica secundaria y condicional.

No sustituirá:

- dominancia cruzada;
- cobertura;
- nondominated sorting;
- interpretación física.

---

## 22.1 Gate de decisión

Se aplicará la siguiente regla:

```
IF:
    FULL_COVERAGE_C_OVER_H = 1
AND FULL_COVERAGE_H_OVER_C = 0

THEN:
    HYPERVOLUME_MAIN_ANALYSIS = NOT_REQUIRED

ELSE:
    HYPERVOLUME_ANALYSIS = RECOMMENDED

```

Si todos los históricos son dominados por al menos una solución CORRECTED\_R1 y ninguna nueva solución es dominada por históricos, la dominancia completa proporciona una respuesta comparativa suficientemente directa.

El hypervolume podrá calcularse en ese caso únicamente como análisis suplementario.

---

# 23. Conjunto de anclaje del hypervolume

Si se calcula hypervolume, se utilizarán:

[
N\_H=ND(H),
]

[
N\_C=ND(C),
]

y:

[
P=N\_H\cup N\_C.
]

La normalización y los anclajes se derivarán de (P), no automáticamente de los 18 puntos completos.

Para cada objetivo:

# [ f\_k^{\min,P}

\min\_{p\in P}f\_k(p),
]

# [ f\_k^{\max,P}

\max\_{p\in P}f\_k(p).
]

La transformación será:

# [ z\_k(f)

\frac{
f\_k-f\_k^{\min,P}
}{
f\_k^{\max,P}-f\_k^{\min,P}
}.
]

Los mismos límites se aplicarán a ambos conjuntos.

---

## 23.1 Caso de rango nulo

Si para algún objetivo:

[
f\_k^{\max,P}=f\_k^{\min,P},
]

el cálculo de hypervolume se bloqueará hasta definir un tratamiento explícito.

No se sustituirá automáticamente el denominador por un valor arbitrario.

---

# 24. Reference point

El punto principal normalizado será:

# [ r\_{10}

(1.10,1.10,1.10).
]

Se realizará sensibilidad con:

# [ r\_5

(1.05,1.05,1.05),
]

# [ r\_{10}

(1.10,1.10,1.10),
]

# [ r\_{20}

(1.20,1.20,1.20).
]

Estos valores constituyen una rejilla metodológica definida por este protocolo; no deberán presentarse como valores universales para problemas multiobjetivo.

Una vez calculados los anclajes deberán registrarse:

```
HV_SCALE_MIN
HV_SCALE_MAX
HV_REFERENCE_NORMALIZED
HV_REFERENCE_RAW

```

Si posteriormente se comparan nuevas corridas y se desea conservar comparabilidad longitudinal, estos parámetros no se recalcularán automáticamente.

---

# 25. Interpretación del hypervolume

Se calculará:

[
HV(N\_H)
]

y:

[
HV(N\_C).
]

Los puntos internamente dominados no formarán parte de cada conjunto de entrada.

El resultado se interpretará como:

> diferencia de cobertura del espacio objetivo definido por los anclajes de esta comparación.

No se interpretará como:

- prueba estadística de superioridad;
- estimación de distancia al frente verdadero;
- evaluación general del algoritmo;
- demostración de convergencia.

---

## 25.1 Sensibilidad al reference point

Si la dirección:

[
HV(N\_C)>HV(N\_H)
]

o:

[
HV(N\_C)\<HV(N\_H)
]

permanece igual para (r\_5), (r\_{10}) y (r\_{20}):

```
HV_SENSITIVITY_STATUS =
ROBUST_DIRECTION

```

Si cambia:

```
HV_SENSITIVITY_STATUS =
REFERENCE_POINT_SENSITIVE

```

En este último caso, el hypervolume no se utilizará como evidencia fuerte en el manuscrito.

---

# 26. Métricas no utilizadas

No se calcularán inicialmente:

- Generational Distance;
- Inverted Generational Distance;
- distancia a un supuesto frente verdadero;
- indicadores que requieran una referencia independiente inexistente;
- pruebas estadísticas sobre los nueve puntos;
- métricas de convergencia global.

No se construirá un “true front” utilizando los mismos 18 puntos.

---

# 27. Régimen terminal común

La condición terminal deberá analizarse de forma conjunta para (H) y (C).

La reevaluación histórica documentó:

```
Normal terminations = 0
TMAX terminations = 9

```

CORRECTED\_R1 produjo igualmente nueve soluciones con:

```
dry_time = 19.9 h

```

y `TMAX_REACHED` inferido de ese valor porque el objective detail no propaga directamente `termination_status`.

El análisis deberá verificar:

```
H_TMAX_COUNT
C_TMAX_COUNT

H_DRY_TIME_MIN
H_DRY_TIME_MAX

C_DRY_TIME_MIN
C_DRY_TIME_MAX

```

Si los 18 puntos comparten el mismo horizonte:

```
COMPARATIVE_TERMINAL_REGIME =
COMMON_TMAX_19P9H

```

La interpretación será:

> Los dos conjuntos se comparan bajo un régimen terminal común al horizonte máximo de simulación.

Esto mejora su comparabilidad temporal, pero limita el alcance de la conclusión:

> los compromisos observados corresponden al desempeño al horizonte fijado, no necesariamente a soluciones que alcanzan libremente una condición terminal normal antes del límite.

---

# 28. Descomposición obligatoria de f2 y f3

Antes de interpretar diferencias económicas o ambientales en cualquier solución representativa se deberán examinar por separado:

[
water\_removed\_kg,
]

[
total\_cost\_USD,
]

[
total\_CO2\_kg.
]

Esto es obligatorio porque:

[
f\_2=
\frac{total\_cost\_USD}
{water\_removed\_kg},
]

y:

[
f\_3=
\frac{total\_CO2\_kg}
{water\_removed\_kg}.
]

Ambos objetivos utilizan el mismo denominador corregido.
Por tanto, una mejora en (f\_2) o (f\_3) puede deberse a:

- reducción del numerador;
- aumento del agua removida;
- o ambos mecanismos.

No se afirmará automáticamente que una solución con menor (f\_2):

- consume menos energía;
- tiene menor costo total por lote;

ni que una solución con menor (f\_3):

- emite menos CO₂ total por lote.

---

## 28.1 Componentes adicionales

Para las soluciones representativas se analizarán, cuando estén disponibles en artefactos ya validados:

- `water_removed_kg`;
- `Q_aux_tot`;
- `Q_LPG_input`;
- `LPG_mass_kg`;
- `LPG_cost_USD`;
- `Irradiacion`;
- `solar_cost_USD`;
- `E_air_impeller_kWh`;
- `electricity_cost_USD`;
- `CO2_LPG_kg`;
- `CO2_electricity_kg`;
- `total_cost_USD`;
- `total_CO2_kg`.

La cadena interpretativa será:

[
x
\rightarrow
\text{respuesta física}
\rightarrow
\begin{cases}
water\ removed\\
energy\ components\\
cost\ components\\
CO\_2\ components
\end{cases}
\rightarrow
f\_1,f\_2,f\_3.
]

---

# 29. Interpretación física de las variables

## 29.1 `m_max`

Se evaluará su relación con:

- transporte de calor;
- transporte de masa;
- flujo efectivo del circuito;
- demanda eléctrica del movimiento de aire;
- aporte auxiliar;
- desempeño del captador;
- humedad final.

No se asumirá comportamiento monótono.

---

## 29.2 `T_min`

Se analizará su relación con:

- nivel térmico de operación;
- demanda de GLP;
- velocidad de secado;
- agua removida;
- humedad final;
- costo específico;
- emisiones específicas.

---

## 29.3 `r_div2`

Se interpretará como fracción de recirculación.

Su aumento puede afectar simultáneamente:

- recuperación térmica;
- descarga de aire húmedo;
- acumulación de humedad;
- demanda auxiliar;
- desempeño del secado.

No se interpretará aisladamente de `m_max`, `T_min` y `t_rec_ini`.

---

## 29.4 `t_rec_ini`

Se interpretará como instante de inicio de recirculación, no como duración total.

Se analizará cómo el inicio temprano o tardío modifica:

- aprovechamiento térmico;
- acumulación de humedad;
- evolución del producto;
- energía auxiliar;
- costo y emisiones.

---

# 30. Soluciones representativas

Después del sorting conjunto se seleccionarán, cuando existan:

- solución de mínimo (f\_1);
- solución de mínimo (f\_2);
- solución de mínimo (f\_3);
- una o más soluciones de compromiso;
- históricos pertenecientes a (N\_H) que permanezcan en `Rank 1`;
- históricos dominados por múltiples soluciones CORRECTED\_R1;
- CORRECTED\_R1 que dominen múltiples históricos;
- CORRECTED\_R1 dominadas por históricos;
- soluciones asociadas a dominancias numéricamente frágiles;
- soluciones próximas a límites de decisión.

No se elegirá anticipadamente una única “mejor solución”.

---

# 31. Referencia gasLP

La referencia `gasLP` tendrá exclusivamente función contextual.

```
GASLP_ROLE =
CONTEXTUAL_REFERENCE_ONLY

```

No se incluirá en:

- auditoría de dominancia interna;
- matriz cruzada 9×9;
- set coverage;
- nondominated sorting conjunto;
- hypervolume H-vs-C.

```
GASLP_INCLUDED_IN_COMPARATIVE_SORT = NO
GASLP_INCLUDED_IN_HYPERVOLUME = NO

```

Podrá utilizarse posteriormente para expresar:

- reducciones relativas de costo;
- reducciones relativas de CO₂;
- diferencias energéticas;
- contexto físico de soluciones representativas.

---

# 32. Veredicto comparativo cuantitativo

El resultado principal no será forzado a una clasificación categórica rígida.

Se emitirá el siguiente vector cuantitativo:

```
H_INTERNAL_NONDOMINATED_COUNT
C_INTERNAL_NONDOMINATED_COUNT

H_INTERNAL_DOMINATED_COUNT
C_INTERNAL_DOMINATED_COUNT

FULL_COVERAGE_C_OVER_H
FULL_COVERAGE_H_OVER_C

CORE_COVERAGE_NC_OVER_NH
CORE_COVERAGE_NH_OVER_NC

JOINT_RANK1_H
JOINT_RANK1_C

C_DOMINATES_H_PAIR_COUNT
H_DOMINATES_C_PAIR_COUNT
INCOMPARABLE_PAIR_COUNT
EXACT_EQUAL_PAIR_COUNT

NEAR_TIE_OBJECTIVE_COUNT
NUMERICALLY_FRAGILE_DOMINANCE_COUNT
DOMINANCE_NUMERIC_SENSITIVITY

HV_STATUS
HV_H
HV_C
HV_DIRECTION
HV_REFERENCE_SENSITIVITY

H_TMAX_COUNT
C_TMAX_COUNT
COMPARATIVE_TERMINAL_REGIME

```

A partir de este vector se redactará una descripción científica del patrón observado.

---

# 33. Patrones interpretativos posibles

Los siguientes escenarios son ejemplos narrativos, no clases formales obligatorias.

## Patrón A — Dominancia amplia de CORRECTED\_R1

Posible interpretación:

> La reoptimización directa de COST-E3D encontró soluciones que dominan ampliamente a los diseños históricos reevaluados.

---

## Patrón B — Mejora parcial con supervivencia histórica

Posible interpretación:

> CORRECTED\_R1 mejora parte del espacio objetivo, pero ciertos compromisos históricos permanecen no dominados.

---

## Patrón C — Reestructuración del trade-off

Posible interpretación:

> La reoptimización modifica la estructura de los compromisos y produce una combinación de nuevas regiones y soluciones históricas aún competitivas.

---

## Patrón D — Evidencia insuficiente de mejora

Posible interpretación:

> La ejecución CORRECTED\_R1 no proporciona evidencia suficiente para considerar que la nueva aproximación supera a las soluciones históricas reevaluadas.

Los datos podrán requerir una descripción intermedia diferente de estos ejemplos.

---

# 34. Limitaciones inferenciales

Existe una sola ejecución CORRECTED\_R1:

```
seed = 61001
PopulationSize = 24
MaxGenerations = 50

```

Por tanto, esta fase compara conjuntos específicos de soluciones.

No permite establecer:

- desempeño esperado de `gamultiobj`;
- variabilidad entre semillas;
- robustez estadística;
- probabilidad de convergencia;
- desempeño medio;
- superioridad estadística de configuraciones;
- suficiencia general de 50 generaciones.

Cualquier afirmación de este tipo requeriría múltiples corridas independientes.

---

# 35. Implicaciones para el manuscrito

Las modificaciones al manuscrito se realizarán después de completar el análisis.

Las afirmaciones deberán distinguir:

## Nivel 1 — Observación directa

Ejemplo:

> Seis de las nueve soluciones históricas reevaluadas fueron dominadas por al menos una solución CORRECTED\_R1.

---

## Nivel 2 — Estructura multiobjetivo

Ejemplo:

> El núcleo no dominado histórico fue parcialmente sustituido por soluciones obtenidas mediante reoptimización de COST-E3D.

---

## Nivel 3 — Interpretación mecanística

Ejemplo:

> El desplazamiento hacia determinada región de temperatura y recirculación fue consistente con cambios simultáneos en agua removida, demanda auxiliar y costo específico.

---

## Nivel 4 — Inferencia limitada

Ejemplo:

> Los resultados sugieren que la corrección del objetivo económico modificó la región del espacio de decisión favorecida por la optimización.

Los niveles no deberán mezclarse ni presentarse con el mismo grado de certeza.

---

# 36. Interpretaciones prohibidas

No se permitirá:

- llamar a (H) “corrected Pareto front”;
- llamar al `Rank 1` conjunto “true Pareto front”;
- emparejar (H\_i) con (C\_i) por índice;
- utilizar tolerancias del solver para definir dominancia;
- utilizar (10^{-12}) para modificar Pareto rank;
- omitir la auditoría interna de cada conjunto;
- interpretar `FULL_COVERAGE` como mejora automática del núcleo no dominado;
- omitir `CORE_COVERAGE` al formular conclusiones sobre la aproximación no dominada;
- interpretar medias como propiedades intrínsecas del frente;
- aplicar pruebas estadísticas a los nueve puntos;
- normalizar hypervolume independientemente;
- elegir el reference point después de observar qué opción favorece a un conjunto;
- ocultar sensibilidad del hypervolume;
- usar GD o IGD contra los mismos 18 puntos;
- incluir gasLP en la competencia H-vs-C;
- interpretar menor (f\_2) como menor costo total por lote sin descomposición;
- interpretar menor (f\_3) como menor CO₂ total por lote sin descomposición;
- presentar (f\_2) como costo económico integral;
- presentar (f\_3) como impacto ambiental total o huella de ciclo de vida;
- afirmar convergencia estadística;
- afirmar robustez frente a la semilla;
- afirmar superioridad estadística del algoritmo;
- interpretar `exitflag=0` por sí solo como fracaso;
- interpretar `TMAX` como anomalía exclusiva de CORRECTED\_R1;
- seleccionar una única “mejor solución” sin justificar preferencias.

---

# 37. Secuencia operativa congelada

## CR1-COMP-01 — Dataset freeze

Construcción, verificación y trazabilidad de las 18 soluciones.

## CR1-COMP-02 — Within-set exact Pareto audit

Auditoría interna de:

[
N\_H=ND(H)
]

y:

[
N\_C=ND(C).
]

## CR1-COMP-03 — Decision-space descriptive analysis

Análisis de las cuatro variables de decisión.

## CR1-COMP-04 — Objective-space descriptive analysis

Análisis de (f\_1,f\_2,f\_3).

## CR1-COMP-05 — Exact cross-dominance matrix

Construcción de las 81 comparaciones.

## CR1-COMP-06 — Numerical near-tie sensitivity audit

Diagnóstico de:

- near-ties;
- dominancias numéricamente frágiles.

Sin alterar la dominancia exacta.

## CR1-COMP-07 — Set coverage

### Full-set coverage

[
C\_{\mathrm{full}}(C,H)
]

[
C\_{\mathrm{full}}(H,C)
]

### Nondominated-core coverage

[
C\_{\mathrm{core}}(N\_C,N\_H)
]

[
C\_{\mathrm{core}}(N\_H,N\_C)
]

## CR1-COMP-08 — Joint exact nondominated sorting

Asignación de Pareto rank a las 18 soluciones.

## CR1-COMP-09 — Objective-space geometry

Análisis 2D y 3D.

## CR1-COMP-10 — Hypervolume decision gate

Aplicación de la regla formal congelada.

## CR1-COMP-11 — Hypervolume and sensitivity

Cálculo sólo si está justificado.

## CR1-COMP-12 — Common terminal-regime analysis

Comparación del régimen TMAX y `dry_time`.

## CR1-COMP-13 — Objective decomposition

Análisis de:

- denominadores;
- numeradores;
- componentes energéticos;
- componentes económicos;
- componentes ambientales.

## CR1-COMP-14 — Physical, economic and environmental interpretation

Interpretación de soluciones representativas.

## CR1-COMP-15 — Quantitative comparative verdict

Emisión del vector completo de resultados.

## CR1-COMP-16 — Manuscript implications

Traducción de resultados a:

- Results;
- Discussion;
- Limitations;
- Conclusions.

---

# 38. Reglas de ejecución

Durante esta fase:

```
GAMULTIOBJ_EXECUTION_AUTHORIZED = NO
NEW_OPTIMIZATION_RUN_AUTHORIZED = NO

```

No se modificarán:

- función objetivo;
- modelo físico;
- costos;
- factores ambientales;
- límites;
- configuración de CORRECTED\_R1;
- artefactos históricos canónicos.

La comparación utilizará exclusivamente resultados previamente generados y validados.

Podrán ejecutarse posteriormente scripts de análisis postrun que:

- lean artefactos existentes;
- construyan tablas;
- calculen dominancia;
- calculen métricas;
- generen figuras;
- no evalúen el modelo;
- no llamen a `gamultiobj`.

La ejecución de dichos scripts requerirá autorización separada posterior al congelamiento de este protocolo.

---

# 39. Control de calidad

Antes de aceptar resultados deberán cumplirse:

```
DATASET_ROWS = 18
HISTORICAL_ROWS = 9
CORRECTED_R1_ROWS = 9

DECISION_VARIABLES_PER_ROW = 4
OBJECTIVES_PER_ROW = 3

ALL_PRIMARY_VALUES_FROM_CANONICAL_VALIDATED_ARTIFACTS = YES
FULL_PRECISION_PRIMARY_VALUES_USED = YES

ALL_F_VALUES_FINITE = YES
PENALTY_ROWS_INCLUDED = NO
BOUNDS_CHECK = PASS

H_INTERNAL_PAIR_COUNT = 36
C_INTERNAL_PAIR_COUNT = 36
CROSS_PAIR_COUNT = 81

PARETO_DEFINITION = EXACT
SOLVER_TOLERANCES_USED_FOR_DOMINANCE = NO
NEAR_TIE_DIAGNOSTIC_SEPARATE = YES

FULL_SET_COVERAGE_BOTH_DIRECTIONS = COMPUTED
CORE_SET_COVERAGE_BOTH_DIRECTIONS = COMPUTED

JOINT_SORTING = COMPLETED

GASLP_EXCLUDED_FROM_COMPETITIVE_SET = YES

TERMINAL_REGIME_BOTH_SETS_CHECKED = YES

F2_F3_DECOMPOSITION_COMPLETED_FOR_INTERPRETED_SOLUTIONS = YES

HV_GATE_APPLIED = YES
HV_ANCHORS_FROZEN_IF_USED = YES
HV_SENSITIVITY_COMPLETED_IF_USED = YES

CANONICAL_SOURCE_TRACEABILITY = PASS

```

Cualquier incumplimiento bloqueará la interpretación científica final.

---

# 40. Referencias metodológicas

1. Deb, K., Pratap, A., Agarwal, S., & Meyarivan, T. A. (2002). *A fast and elitist multiobjective genetic algorithm: NSGA-II*. IEEE Transactions on Evolutionary Computation, 6(2), 182–197. DOI: 10.1109/4235.996017.
2. Zitzler, E., & Thiele, L. (1999). *Multiobjective evolutionary algorithms: A comparative case study and the strength Pareto approach*. IEEE Transactions on Evolutionary Computation, 3(4), 257–271. DOI: 10.1109/4235.797969.
3. Ishibuchi, H., Imada, R., Setoguchi, Y., & Nojima, Y. (2018). *How to specify a reference point in hypervolume calculation for fair performance comparison*. Evolutionary Computation, 26(3), 411–440. DOI: 10.1162/evco\_a\_00226.

---

# 41. Estado final congelado

```
COMPARATIVE_PROTOCOL_VERSION =
v1.0

PROTOCOL_STATUS =
FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION

SCIENTIFIC_ARCHITECTURE =
PASS

OPEN_ESSENTIAL_METHODOLOGICAL_DECISIONS =
0

VARIABLE_DEFINITIONS_STATUS =
FROZEN

OBJECTIVE_DEFINITIONS_STATUS =
FROZEN

PARETO_DOMINANCE =
EXACT_FULL_PRECISION

DOMINANCE_TOLERANCE =
NONE

NUMERICAL_NEAR_TIE_THRESHOLD =
1e-12 * max(1,abs(a),abs(b))

NUMERICAL_THRESHOLD_ROLE =
DIAGNOSTIC_ONLY

NUMERICALLY_FRAGILE_DOMINANCE_RULE =
FROZEN

WITHIN_SET_DOMINANCE_AUDIT =
REQUIRED

HISTORICAL_NONDOMINATED_CORE =
ND(H)

CORRECTED_R1_NONDOMINATED_CORE =
ND(C)

CROSS_DOMINANCE_MATRIX =
9x9 / 81 PAIRS

FULL_SET_COVERAGE =
REQUIRED_BOTH_DIRECTIONS

NONDOMINATED_CORE_COVERAGE =
REQUIRED_BOTH_DIRECTIONS

JOINT_NONDOMINATED_SORTING =
REQUIRED

HYPERVOLUME_ROLE =
SECONDARY_CONDITIONAL_METRIC

HV_ANCHOR_SET =
ND(H) UNION ND(C)

HV_REFERENCE_POINTS_NORMALIZED =
[1.05,1.05,1.05]
[1.10,1.10,1.10]
[1.20,1.20,1.20]

GASLP_ROLE =
CONTEXTUAL_REFERENCE_ONLY

TERMINAL_ANALYSIS =
COMMON_REGIME_COMPARISON

F2_F3_DECOMPOSITION =
MANDATORY_FOR_INTERPRETED_SOLUTIONS

ECONOMIC_CLAIM_SCOPE =
MODELED_OPERATING_ENERGY_COST

ENVIRONMENTAL_CLAIM_SCOPE =
MODELED_OPERATIONAL_CO2_AS_IMPLEMENTED

CO2_UNIT_LABEL_STATUS =
COMPUTATIONAL_NAME_PRESERVED_PENDING_MANUSCRIPT_EDITORIAL_RECONCILIATION

FORMAL_A_B_C_D_CLASSIFICATION =
NOT_USED

COMPARATIVE_VERDICT_FORMAT =
QUANTITATIVE_VECTOR_PLUS_NARRATIVE

MATLAB_EXECUTION_AUTHORIZED =
NO

CODEX_EXECUTION_AUTHORIZED =
NO

GAMULTIOBJ_EXECUTION_AUTHORIZED =
NO

POSTRUN_COMPARATIVE_IMPLEMENTATION =
AUTHORIZED_BY_PROTOCOL_BUT_NOT_YET_EXECUTED

COMPARATIVE_DATASET =
NOT_BUILT

COMPARATIVE_RESULTS =
NOT_COMPUTED

SCIENTIFIC_INTERPRETATION =
NOT_STARTED

MANUSCRIPT_CHANGES =
NOT_STARTED

```

---

# 42. Freeze declaration

```
CORRECTED_R1_COMPARATIVE_PROTOCOL_FREEZE = PASS

VERSION = v1.0

STATUS =
FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION

PROTOCOL_REDESIGN_REQUIRED = NO

NEXT_PHASE =
CR1-COMP-01_DATASET_FREEZE

MATLAB = NOT_EXECUTED

CODEX = NOT_EXECUTED

GAMULTIOBJ = NOT_EXECUTED

SCIENTIFIC_COMPARISON = NOT_YET_PERFORMED

```

A partir de este punto, cualquier cambio metodológico sustantivo deberá registrarse como desviación explícita respecto de `v1.0` y justificarse antes de utilizarse en la interpretación científica.