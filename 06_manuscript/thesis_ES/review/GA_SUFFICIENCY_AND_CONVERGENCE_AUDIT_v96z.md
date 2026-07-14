# GA_SUFFICIENCY_AND_CONVERGENCE_AUDIT_v96z

## Dictamen

- Dictamen para tesis: `SUFICIENTE_PARA_TESIS_CON_ALCANCE_CONDICIONADO`
- Dictamen para artículo fuerte: `NO_SUFFICIENTE_PARA_ARTICULO_FUERTE_SIN_VALIDACION_ADICIONAL`

## Configuración auditada

| Campo | Valor |
|---|---:|
| Modo formal | `hybrid` |
| Referencia | `gasLP` |
| PopulationSize | 24 |
| MaxGenerations | 50 |
| Evaluaciones | 1200 |
| Soluciones del frente | 9 |
| Filas finitas | 9 |
| Filas penalizadas | 0 |
| Exitflag | 0 |
| Terminación | `maximum number of generations exceeded` |
| Tiempo de ejecución [h] | 7.1301 |

## Afirmación permitida

H2 puede reportarse como solución de compromiso admisible dentro del frente formal obtenido para el modo híbrido.

## Afirmación bloqueada

No afirmar que H2 es óptimo global absoluto ni que el AG convergió plenamente.

## Auditoría

| Criterio | Estado | Evidencia | Riesgo | Recomendación |
|---|---|---|---|---|
| Corrida formal completada | cumple | La corrida formal híbrida terminó y produjo frente triobjetivo. | bajo | Usar resultados, conservando trazabilidad. |
| Resultados finitos | cumple | nFiniteRows = 9 y nPenaltyRows = 0. | bajo | Reportar que no hubo penalizaciones en el frente formal. |
| Solución recomendada admisible | cumple | H2 cumple MR < 0.1. | bajo | Mantener H2 como solución recomendada. |
| Mejora simultánea vs gas LP | cumple | H2 reduce MR, costo específico y CO2 específico frente a gas LP. | bajo | Mantener comparación contra gas LP. |
| Frente con soluciones representativas | cumple | H1, H2, H4 y H9 permiten interpretar extremos y compromiso. | medio | Usar H1/H4/H9 como anclas interpretativas. |
| Terminación por convergencia | no cumple | exitflag = 0; terminó por máximo de generaciones. | alto | No afirmar convergencia plena. |
| Replicación con semillas | no realizado | No hay corridas formales adicionales con semillas distintas. | alto | Agregar replicación mínima si se quiere robustecer. |
| Sensibilidad de parámetros AG | no realizado | No hay barrido formal de PopulationSize, MaxGenerations u otros parámetros. | alto | Agregar sensibilidad si el objetivo es publicación fuerte. |
| Tamaño del frente | limitado | nSolutions = 9; útil para discusión, limitado para robustez algorítmica. | medio | Evitar conclusiones de optimalidad global. |
| Justificación fuerte de parámetros AG | limitado | La configuración está documentada, pero no optimizada por sensibilidad. | alto | Declarar parámetros como configuración computacional adoptada. |
| Suficiencia para tesis | cumple condicionado | Defendible si se declara como frente obtenido y solución de compromiso. | medio | Redactar conclusiones condicionadas. |
| Suficiencia para artículo fuerte | no suficiente | Requiere replicación/sensibilidad adicional antes de afirmaciones fuertes. | alto | No enviar como artículo fuerte sin validación adicional. |

## Nivel de afirmaciones

| Afirmación | Permitida | Redacción |
|---|---:|---|
| Se obtuvo un frente triobjetivo formal para el modo híbrido. | true | Permitido: frente formal obtenido con la configuración computacional adoptada. |
| H2 es solución recomendada dentro del frente obtenido. | true | Permitido: solución de compromiso admisible del frente obtenido. |
| H2 mejora simultáneamente MR, costo y CO2 frente a gas LP. | true | Permitido: comparación interna con referencia gas LP. |
| H2 es el óptimo global del sistema. | false | No permitido: requiere análisis de convergencia/robustez. |
| El AG alcanzó convergencia plena. | false | No permitido: exitflag=0 por máximo de generaciones. |
| Los parámetros del AG están exhaustivamente justificados. | false | No permitido: falta sensibilidad de parámetros AG. |
| Los resultados sustentan conclusiones de tesis. | true | Permitido con alcance condicionado y caveats. |
| Los resultados sustentan publicación fuerte sin más validación. | false | No permitido sin réplicas o sensibilidad adicional. |

## Recomendación

- Validación adicional mínima recomendada: `MINIMAL_SEED_REPLICATION_2_OR_3_RUNS`
- Si el tiempo es limitado: Mantener resultados actuales y redactar conclusiones condicionadas.
- Si el objetivo es artículo: Ejecutar 2-3 réplicas con distinta semilla o una corrida media con PopulationSize=32 y MaxGenerations=80.

## Texto sugerido para tesis

# Texto sugerido — suficiencia del AG para resultados de tesis

La optimización triobjetivo se resolvió mediante una configuración formal del algoritmo genético multiobjetivo aplicada al modo híbrido. La corrida utilizó una población de 24 individuos y 50 generaciones, con un total de 1200 evaluaciones de la función objetivo. La terminación ocurrió al alcanzarse el número máximo de generaciones establecido, por lo que los resultados deben interpretarse como el frente obtenido bajo la configuración computacional adoptada, y no como una demostración de convergencia global absoluta.

Dentro del frente obtenido, la solución H2 fue seleccionada como compromiso operativo. Esta solución cumple el criterio de secado, con `MR = 0.0473146`, inferior al umbral `MR < 0.1`, y presenta simultáneamente menor costo específico y menores emisiones específicas de CO2 que la referencia con gas LP.

La referencia con gas LP presentó `MR = 0.0960086`, costo específico `0.377878` y CO2 específico `1.68103`. En comparación, H2 alcanzó `MR = 0.0473146`, costo específico `0.279042` y CO2 específico `1.18439`, lo que equivale a reducciones de `50.72 %` en razón de humedad final, `26.16 %` en costo específico y `29.54 %` en CO2 específico.

Por lo anterior, los resultados son suficientes para discutir la estructura del frente, comparar el modo híbrido contra la referencia con gas LP y justificar la selección de una solución de compromiso para tesis. Sin embargo, no se afirma que la solución seleccionada sea el óptimo global absoluto ni que los parámetros del algoritmo genético constituyan una configuración exhaustivamente optimizada.


## Texto sugerido para conclusiones

# Texto sugerido — alcance de conclusiones

Los resultados permiten concluir que, bajo la configuración formal del algoritmo genético utilizada, el modo híbrido ofrece una solución de compromiso capaz de cumplir el criterio de secado y reducir simultáneamente el costo específico y las emisiones específicas de CO2 respecto a la referencia con gas LP. Esta conclusión se limita al frente obtenido y a las condiciones de simulación consideradas.

La selección de H2 debe entenderse como una decisión operativa dentro del frente calculado, no como una prueba de optimalidad global absoluta. Para fortalecer la robustez algorítmica de la selección, sería conveniente realizar corridas adicionales con semillas distintas o una evaluación de sensibilidad de parámetros del algoritmo genético.

