# Resultados — tesis

> Archivo maestro v2 generado por 9.6x. Fuente editable: `sections/01_resultados_optimizacion_triobjetivo_v2_editado.md`.

# Resultados de la optimización triobjetivo

## Alcance de los resultados

En esta sección se presentan los resultados de la optimización triobjetivo aplicada al modo de operación híbrido del túnel de deshidratación. La evaluación considera tres indicadores: la razón de humedad final (`MR`), el costo específico y las emisiones específicas de CO2. El modo con gas LP se utiliza como referencia directa de comparación, ya que permite contrastar el desempeño de la solución híbrida seleccionada con una operación basada exclusivamente en aporte auxiliar.

El modo solar puro no se incluye dentro del frente formal de Pareto. Esta decisión responde a una restricción metodológica: la operación solar está condicionada por la disponibilidad finita de irradiancia durante el día, por lo que requiere una formulación específica basada en una ventana solar. En consecuencia, su comparación directa con los modos híbrido y gas LP no sería equivalente dentro de la misma formulación de optimización.

## Solución híbrida recomendada

La solución seleccionada dentro del frente híbrido fue H2. Esta solución debe interpretarse como un compromiso operativo, no como un óptimo absoluto de una sola función objetivo. Su relevancia se debe a que cumple el criterio de secado y, simultáneamente, mejora los indicadores de costo y emisiones respecto a la referencia con gas LP.

Las variables de decisión asociadas con H2 fueron `m_max = 0.0735504`, `T_min = 65.8789`, `r_div2 = 0.61205` y `t_rec_ini = 12.385`. Con esta configuración se obtuvo una razón de humedad final `MR = 0.0473146`, menor que el umbral de aceptación establecido (`MR < 0.1`).

Además, H2 presentó un costo específico de `0.279042` y emisiones específicas de CO2 de `1.18439`. Estos valores permiten considerar la solución como operativamente admisible y, al mismo tiempo, favorable frente al modo de referencia.

## Comparación contra la referencia con gas LP

La referencia con gas LP produjo `MR = 0.0960086`, costo específico de `0.377878` y emisiones específicas de CO2 de `1.68103`. En comparación, H2 redujo la razón de humedad final en `50.72 %`, el costo específico en `26.16 %` y las emisiones específicas de CO2 en `29.54 %`.

La comparación se resume en la Tabla 1. Esta tabla concentra el resultado cuantitativo principal de la optimización formal, ya que muestra que la solución híbrida recomendada mejora simultáneamente los tres indicadores respecto al caso de gas LP.

**Tabla 1. Comparación entre la referencia con gas LP y la solución híbrida H2.**

| Indicador | Referencia gas LP | Solución H2 | Cambio relativo de H2 |
|---|---:|---:|---:|
| Razón de humedad final, `MR` | 0.0960086 | 0.0473146 | -50.72 % |
| Costo específico | 0.377878 | 0.279042 | -26.16 % |
| Emisiones específicas de CO2 | 1.68103 | 1.18439 | -29.54 % |

## Interpretación de soluciones representativas

La estructura del frente triobjetivo muestra que las soluciones extremas no son necesariamente las más convenientes para operación. H1 se ubica en la región de menor CO2 específico, pero no cumple el criterio de humedad. H4 corresponde a la región de menor costo específico, aunque también resulta inadmisible por humedad. H9 alcanza la menor razón de humedad final; sin embargo, esta mejora de secado se obtiene con mayor costo específico y mayores emisiones específicas de CO2 que la referencia con gas LP.

Por ello, H2 es la opción más defendible dentro del frente formal: no minimiza individualmente todos los objetivos, pero sí ofrece una condición admisible de secado con reducciones simultáneas de costo y CO2 respecto a la referencia.

**Tabla 2. Interpretación de soluciones representativas del frente híbrido.**

| Solución | Interpretación |
|---|---|
| `H1` | Región de menor CO2 específico; no recomendada porque no cumple el criterio MR < 0.1. |
| `H2` | Solución recomendada; compromiso admisible con reducción simultánea de MR, costo específico y CO2 específico frente a gas LP. |
| `H4` | Región de menor costo específico; no recomendada porque no cumple el criterio MR < 0.1. |
| `H9` | Región de menor MR; admisible por secado, pero con mayor costo específico y mayor CO2 específico que gas LP. |

## Interpretación gráfica

La Figura 1 presenta el frente triobjetivo del modo híbrido. En esta representación, la razón de humedad final y el costo específico se muestran en los ejes, mientras que las emisiones específicas de CO2 se incorporan mediante el tamaño del marcador. Esto permite comparar, en una sola gráfica, la condición de secado, el costo y la tendencia ambiental de las soluciones formales.

La Figura 2 compara la referencia con gas LP y la solución H2. Esta figura sintetiza el resultado más importante: la solución híbrida recomendada reduce simultáneamente `MR`, costo específico y emisiones específicas de CO2.

La Figura 3 muestra la ubicación de las soluciones en el espacio de variables de decisión definido por `T_min`, `r_div2` y `t_rec_ini`. Esta gráfica no debe leerse como una superficie de respuesta, sino como una representación del espacio operativo explorado por la optimización formal.

**Pies de figura sugeridos:**

| Figura | Pie de figura |
|---|---|
| Figura 1 | Frente triobjetivo del modo híbrido. La razón de humedad final y el costo específico se muestran en los ejes, mientras que el tamaño del marcador representa las emisiones específicas de CO2. |
| Figura 2 | Comparación entre la referencia con gas LP y la solución híbrida recomendada H2. Se muestran la razón de humedad final, el costo específico y las emisiones específicas de CO2. |
| Figura 3 | Espacio operativo de las soluciones formales del modo híbrido en función de T_min, r_div2 y t_rec_ini. La solución H2 se destaca como compromiso operativo recomendado. |

## Limitaciones

Los resultados de CO2 deben interpretarse como una comparación preliminar mientras los factores de emisión permanezcan pendientes de fijación bibliográfica definitiva. Por tanto, los porcentajes de reducción de CO2 son adecuados para comparar internamente las soluciones del frente y discutir la metodología, pero no deben presentarse como afirmaciones finales sin respaldar los factores de emisión empleados.

Asimismo, la exclusión del modo solar puro debe mantenerse como una limitación metodológica explícita. Su evaluación requiere una formulación específica basada en la ventana solar diaria, la irradiancia disponible y la humedad alcanzada durante ese intervalo.

## Síntesis

La optimización triobjetivo permitió identificar H2 como la solución híbrida recomendada. Esta solución cumple el criterio de secado y reduce simultáneamente la razón de humedad final, el costo específico y las emisiones específicas de CO2 respecto a la referencia con gas LP. El análisis de las soluciones representativas confirma que H1 y H4 corresponden a extremos no admisibles por humedad, mientras que H9 intensifica el secado a costa de mayores costo y emisiones. En conjunto, estos resultados justifican seleccionar H2 como compromiso operativo del sistema híbrido.

