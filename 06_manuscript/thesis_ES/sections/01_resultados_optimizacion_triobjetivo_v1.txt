# Resultados de la optimización triobjetivo

## Alcance de la corrida formal

La corrida formal de optimización se consolidó para el modo de operación híbrido del túnel de deshidratación. La formulación consideró tres funciones objetivo: razón de humedad final (`MR`), costo específico y emisiones específicas de CO2. El caso de operación con gas LP se utilizó como referencia directa para comparar el desempeño de la solución híbrida recomendada.

El modo solar puro no se integró al frente formal de Pareto. Esta exclusión no representa una descalificación técnica del recurso solar, sino una decisión metodológica. La operación solar está limitada por la disponibilidad diaria de irradiancia y requiere una formulación específica de ventana solar para que la comparación sea equivalente con los modos híbrido y gas LP.

## Solución recomendada del frente híbrido

La solución seleccionada fue H2. Esta alternativa no corresponde a un extremo individual del frente de Pareto, sino a una solución de compromiso que cumple el criterio de secado y mejora simultáneamente los indicadores económico y ambiental frente a la referencia con gas LP.

Las variables de decisión de H2 fueron `m_max = 0.0735504`, `T_min = 65.8789`, `r_div2 = 0.61205` y `t_rec_ini = 12.385`. Con esta combinación se obtuvo `MR = 0.0473146`, valor inferior al criterio de aceptación `MR < 0.1`.

El costo específico de H2 fue `0.279042` y las emisiones específicas de CO2 fueron `1.18439`. En comparación con la referencia con gas LP, la solución H2 redujo la razón de humedad final en `50.72 %`, el costo específico en `26.16 %` y las emisiones específicas de CO2 en `29.54 %`.

## Comparación con la referencia de gas LP

La referencia con gas LP presentó `MR = 0.0960086`, costo específico de `0.377878` y emisiones específicas de CO2 de `1.68103`. Frente a estos valores, H2 mostró una mejora simultánea en los tres indicadores evaluados.

| Indicador | Referencia gas LP | Solución H2 | Cambio relativo de H2 |
|---|---:|---:|---:|
| Razón de humedad final, `MR` | 0.0960086 | 0.0473146 | -50.72 % |
| Costo específico | 0.377878 | 0.279042 | -26.16 % |
| Emisiones específicas de CO2 | 1.68103 | 1.18439 | -29.54 % |

## Lectura de las soluciones representativas

La selección de H2 se entiende con mayor claridad al comparar las soluciones representativas del frente. Las soluciones H1 y H4 describen regiones atractivas desde el punto de vista ambiental y económico, respectivamente, pero no cumplen el criterio de secado. H9 alcanza la menor razón de humedad final, por lo que intensifica el secado, pero lo hace con mayor costo específico y mayores emisiones específicas de CO2 que la referencia con gas LP.

Por tanto, H2 representa el compromiso operativo más defendible: cumple el criterio de humedad y, al mismo tiempo, reduce costo específico y emisiones específicas de CO2 frente al caso de gas LP.

| Solución | Interpretación para tesis |
|---|---|
| `H1` | Región de menor CO2 específico; no recomendada porque no cumple el criterio MR < 0.1. |
| `H2` | Solución recomendada; compromiso admisible con reducción simultánea de MR, costo específico y CO2 específico frente a gas LP. |
| `H4` | Región de menor costo específico; no recomendada porque no cumple el criterio MR < 0.1. |
| `H9` | Región de menor MR; admisible por secado, pero con mayor costo específico y mayor CO2 específico que gas LP. |

## Interpretación gráfica

La Figura 1 muestra el frente triobjetivo del modo híbrido. La razón de humedad final y el costo específico se presentan como ejes principales, mientras que el tamaño del marcador incorpora la información de emisiones específicas de CO2. Esta representación permite observar simultáneamente la condición de secado, el desempeño económico y la tendencia ambiental del frente.

La Figura 2 compara directamente la referencia con gas LP y la solución H2. Esta comparación resume el resultado principal de la optimización: H2 mejora la razón de humedad final, reduce el costo específico y disminuye las emisiones específicas de CO2 respecto a la referencia.

La Figura 3 muestra el espacio operativo de las soluciones formales del modo híbrido en función de `T_min`, `r_div2` y `t_rec_ini`. Esta figura no debe interpretarse como una superficie de respuesta, sino como una representación de la ubicación de las soluciones en el espacio de variables de decisión.

| Figura | Pie de figura sugerido |
|---|---|
| Figura 1 | Frente triobjetivo del modo híbrido. La razón de humedad final y el costo específico se muestran en los ejes, mientras que el tamaño del marcador representa las emisiones específicas de CO2. |
| Figura 2 | Comparación entre la referencia con gas LP y la solución híbrida recomendada H2. Se muestran la razón de humedad final, el costo específico y las emisiones específicas de CO2. |
| Figura 3 | Espacio operativo de las soluciones formales del modo híbrido en función de T_min, r_div2 y t_rec_ini. La solución H2 se destaca como compromiso operativo recomendado. |

## Limitaciones de interpretación

Los resultados asociados con CO2 deben interpretarse como una comparación preliminar mientras los factores de emisión permanezcan en condición provisional. Antes de utilizar estos porcentajes como afirmaciones finales, los factores de emisión deberán fijarse con referencias bibliográficas definitivas.

La exclusión del modo solar puro del frente formal también debe conservarse como una limitación metodológica explícita. Para evaluar adecuadamente dicho modo se requiere una formulación específica basada en la ventana solar diaria, la irradiancia disponible y la razón de humedad alcanzada durante ese intervalo.

## Síntesis de resultados

Los resultados de la optimización triobjetivo respaldan la selección de H2 como condición de operación híbrida recomendada. H2 no es un óptimo extremo, sino una solución balanceada que cumple el criterio de secado y mejora simultáneamente costo específico y emisiones específicas de CO2 respecto a la referencia con gas LP. Las soluciones H1 y H4 delimitan extremos no admisibles por humedad, mientras que H9 representa el extremo de secado con penalización económica y ambiental. Esta estructura del frente justifica la selección de H2 como compromiso operativo del sistema híbrido.
