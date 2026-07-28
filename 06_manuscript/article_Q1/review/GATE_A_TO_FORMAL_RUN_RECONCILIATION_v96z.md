# Gate A to formal-run reconciliation v96z

Estado: conciliación metodológica documental
Fecha: 2026-07-28

## Propósito y alcance

Este documento concilia el alcance de la R1 seed-aware v96z ya ejecutada con
los requisitos de una eventual corrida formal de 400 generaciones. No autoriza
MATLAB, `gamultiobj`, R1, R2, R3 ni una corrida de 400 generaciones; tampoco
modifica o aprueba la cadena candidata v96z.

La R1 v96z se clasifica como:

`GATE_A_OPERATIONAL_SEEDAWARE_POSTRUN_PASS`

Esta clasificación es un PASS operativo de Gate A sujeto a las advertencias de
la auditoría postrun. Confirma la ejecución y consistencia básica de una corrida
seed-aware acotada, pero no constituye validación de resultados científicos.

La fuente vigente de evidencia para esta R1 es
[`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md).
Los resúmenes globales R1 marcados como históricos/stale no sustituyen dicho
reporte.

## Conciliación de la configuración

`PopulationSize=24` y `MaxGenerations=50` pertenecen a la configuración
observada de Gate A. No deben extrapolarse como configuración final ni
interpretarse como equivalentes a una corrida formal de 400 generaciones.

La evidencia vigente registra:

- semilla externa `61001`;
- control RNG `EXTERNAL_SEED_APPLIED`;
- `PopulationSize=24`;
- `MaxGenerations=50`;
- 50 generaciones ejecutadas;
- 9 soluciones finitas y 0 penalizadas;
- `exitflag=0`;
- mensaje de parada por exceder `options.MaxGenerations`.

La combinación de `exitflag=0`, 50 generaciones y el mensaje de parada indica
terminación por el límite configurado de generaciones. No demuestra
convergencia del frente de Pareto ni optimalidad global.

## Matriz de conciliación

| Control previo del proyecto | Evidencia v96z R1 | Estado conciliado | Alcance permitido |
|---|---|---|---|
| Identificación inequívoca de la corrida | Runner R1 seed-aware, semilla 61001 y artefactos anclados por hash en la auditoría postrun | Cumple para Gate A | Trazabilidad operativa de R1 |
| Aplicación de semilla externa | `rngControl=EXTERNAL_SEED_APPLIED` y `rngSeed_v96z=61001` | Cumple para una ejecución | Confirmar el control de esa corrida; no declarar reproducibilidad |
| Configuración del solver registrada | `PopulationSize=24`, `MaxGenerations=50` | Cumple para Gate A | Describir la configuración observada, no fijarla como protocolo formal |
| Persistencia de variables principales | `X`, `F`, `opts`, `population` y `scores` confirmados en los MAT auditados | Cumple para auditoría | Verificación postrun; los MAT permanecen fuera de Git |
| Objetivo triobjetivo | `F` tiene tres columnas | Cumple estructuralmente | Confirmar forma de salida, no validez científica final |
| Sanidad numérica del frente | 9 filas finitas y 0 penalizadas | PASS operativo | Evidencia de ejecución utilizable, no de convergencia |
| Criterio de parada | `exitflag=0` y paro al alcanzar `MaxGenerations=50` | Límite alcanzado | No interpretar como convergencia |
| Presupuesto formal de 400 generaciones | R1 ejecutó 50 generaciones | No equivalente | R1 no sustituye una corrida formal de 400 generaciones |
| Independencia y reproducibilidad entre semillas | Solo R1 vigente; R2/R3 no ejecutadas | No demostrada | No formular claims de reproducibilidad o robustez estadística |
| Comparabilidad de resultados finales | Gate A verifica una cadena acotada | Pendiente | No usar R1 como dataset final del manuscrito |
| Factores y resultados de CO2 | CO2 continúa marcado como provisional | Bloqueado para claims | Solo consistencia computacional; ningún claim ambiental final |
| Validación del modelo de producto | El antecedente validado corresponde a piña | Se conserva la precedencia del trabajo publicado | Citar el artículo 2024 como fuente del modelo previamente validado |
| Aplicación a chile rojo | Estudio computacional con cinética procedente de literatura | Evidencia experimental propia no establecida por R1 | Declarar el alcance computacional salvo evidencia experimental adicional |

## Relación con la corrida formal de 400 generaciones

R1 v96z no equivale a una corrida formal de 400 generaciones. El número de
generaciones, el tamaño de población, las réplicas, las semillas, el criterio
de convergencia y la política de almacenamiento de una futura corrida formal
requieren aprobación metodológica independiente. Este documento no decide
esos parámetros ni autoriza su ejecución.

| Aspecto | Gate A R1 v96z | Eventual corrida formal de 400 generaciones |
|---|---|---|
| Propósito | Verificación operativa seed-aware y postrun | Producción potencial de evidencia científica |
| Población | 24 | Pendiente de aprobación metodológica |
| Generaciones | 50 | 400 solo si el protocolo formal lo aprueba |
| Réplicas | R1 únicamente | Pendientes de definición y autorización |
| Convergencia | No demostrada | Requiere criterio explícito y evidencia |
| Uso en manuscrito | Trazabilidad y limitaciones metodológicas | Resultados solo después de auditoría y aprobación |
| Estado de ejecución | Completada; no repetir | No autorizada por este documento |

## Límites de interpretación científica

R1 no autoriza claims finales sobre:

- valores definitivos de resultados;
- convergencia u optimalidad global;
- reproducibilidad o independencia entre semillas;
- robustez estadística;
- superioridad definitiva entre modos energéticos;
- costo o CO2 definitivos;
- validación experimental del chile rojo.

El artículo de 2024 sigue siendo la fuente del modelo previamente validado con
piña. La aplicación a chile rojo sigue siendo un estudio computacional que usa
cinética de literatura, salvo que se incorpore y audite evidencia experimental
adicional.

## Dictamen

`R1_v96z_IS_GATE_A_OPERATIONAL_SEEDAWARE_POSTRUN_PASS`

`R1_v96z_IS_NOT_A_400_GENERATION_FORMAL_RUN`

`R1_v96z_DOES_NOT_AUTHORIZE_FINAL_SCIENTIFIC_OR_CO2_CLAIMS`

