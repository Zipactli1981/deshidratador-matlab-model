# Gate B decision: current status v96z

Estado: decisión documental vigente
Fecha: 2026-07-28

## Propósito y alcance

Este documento aplica los criterios de Gate B a la evidencia disponible de R1
v96z. R1 está clasificada como `GATE_A_OPERATIONAL_SEEDAWARE_POSTRUN_PASS`, lo
que confirma un PASS operativo de Gate A con advertencias, pero no constituye
evidencia suficiente para autorizar la siguiente fase ni para formular
conclusiones científicas finales.

Con la evidencia actual:

- no se autoriza ejecutar R2 ni R3;
- no se autoriza una corrida formal de 400 generaciones;
- no se autorizan claims finales de convergencia, reproducibilidad,
  comparación entre `hybrid` y `gasLP`, ni CO2.

Este dictamen es exclusivamente documental. No autoriza ejecutar MATLAB,
`gamultiobj`, R1, R2 o R3, ni modificar scripts, modelo, física, objetivos,
límites, semillas, costos, factores CO2, datos o configuración del solver.

## Decisión Gate B vigente

Gate B emite simultáneamente:

`HOLD_FOR_CO2_FACTOR_VALIDATION`

Aplica porque los factores de emisión continúan marcados como provisionales y
no se ha cerrado la validación de sus fuentes primarias, unidades, conversiones,
base funcional, límites del sistema y trazabilidad. En este estado, CO2 no
puede sustentar una selección triobjetivo ni claims ambientales finales.

`HOLD_FOR_HYBRID_GASLP_PROTOCOL`

Aplica porque no existe todavía un protocolo pareado aprobado que compare
`hybrid` y `gasLP` manteniendo iguales semillas, presupuesto computacional,
entradas, opciones del solver, penalizaciones, métricas y regla de selección.
La evidencia de R1 no permite afirmar superioridad ni comparabilidad final
entre ambos modos.

`HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL`

Aplica porque no se ha aprobado una regla determinista y reproducible para
seleccionar el punto representativo, incluidas las anclas de normalización,
pesos, criterio de desempate y trazabilidad completa de la selección. Por
tanto, ningún punto puede presentarse como óptimo o representativo final.

Los tres HOLD tienen precedencia sobre cualquier ruta de PASS mientras sus
condiciones permanezcan abiertas.

## Siguientes acciones documentales

Antes de reconsiderar Gate B deben elaborarse y aprobarse:

1. un protocolo pareado de comparación `hybrid`/`gasLP`;
2. un protocolo de selección reproducible del punto representativo;
3. una validación documentada de factores, unidades y fuentes de CO2.

Completar estas acciones documentales no autoriza por sí mismo ninguna
ejecución. Cualquier R2/R3 o corrida formal de 400 generaciones requerirá una
decisión Gate B posterior y una autorización explícita de ejecución.

## Referencias

- [`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md)
- [`GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md`](GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md)
- [`GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md`](GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md)
