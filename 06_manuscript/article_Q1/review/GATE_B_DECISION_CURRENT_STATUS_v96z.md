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

- no se autoriza ejecutar MATLAB ni `gamultiobj`;
- no se autoriza ejecutar R2 ni R3;
- no se autoriza una minrep de 50 generaciones;
- no se autoriza una corrida formal de 400 generaciones;
- no se autoriza una selección triobjetivo final;
- no se autoriza una comparación ambiental final;
- no se autorizan claims finales de convergencia, reproducibilidad,
  comparación entre `hybrid` y `gasLP`, ni CO2.

Este dictamen es exclusivamente documental. No autoriza ejecutar MATLAB,
`gamultiobj`, R1, R2 o R3, ni modificar scripts, modelo, física, objetivos,
límites, semillas, costos, factores CO2, datos o configuración del solver.

## Decisión Gate B vigente

Tras la integración de los PR #13 y #15, Gate B registra:

`HOLD_FOR_CO2_FACTOR_VALIDATION`

Aplica porque los factores de emisión continúan marcados como provisionales y
no se ha cerrado la validación de sus fuentes primarias, unidades, conversiones,
base funcional, límites del sistema y trazabilidad. En este estado, CO2 no
puede sustentar una selección triobjetivo ni claims ambientales finales.

`HOLD_FOR_HYBRID_GASLP_PROTOCOL -> PROTOCOL_DEFINED`

El protocolo pareado quedó definido mediante
[`GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md`](GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md).
Este cambio levanta exclusivamente el bloqueo documental por ausencia de
protocolo. No significa que existan resultados pareados, que la comparación
haya pasado, que un modo sea superior ni que una ejecución esté autorizada.

`HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL -> PROTOCOL_DEFINED`

El protocolo de selección quedó definido mediante
[`GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md`](GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md).
Este cambio levanta exclusivamente el bloqueo documental por ausencia de una
regla reproducible. No significa que las anclas numéricas estén validadas, que
se haya seleccionado un punto, que la selección sea final ni que una ejecución
esté autorizada.

El único HOLD activo es `HOLD_FOR_CO2_FACTOR_VALIDATION` y tiene precedencia
sobre cualquier ruta de PASS mientras su condición permanezca abierta. Los
estados `PROTOCOL_DEFINED` de la comparación `hybrid`/`gasLP` y de la selección
del punto representativo no alteran esa precedencia ni autorizan ejecución.

## Siguientes acciones documentales

Antes de reconsiderar Gate B debe elaborarse y aprobarse:

1. una validación documentada de factores, unidades y fuentes de CO2.

Los protocolos pareado `hybrid`/`gasLP` y de selección del punto representativo
ya están definidos documentalmente. Su eventual aplicación requerirá una
autorización explícita e independiente y deberá respetar íntegramente los
diseños aprobados.

Completar la acción documental pendiente no autoriza por sí mismo ninguna
ejecución. MATLAB, R2/R3, una minrep de 50 generaciones o una corrida formal de
400 generaciones requerirán una decisión Gate B posterior y una autorización
explícita de ejecución. Tampoco se autorizan una selección triobjetivo final,
una comparación ambiental final ni claims finales.

## Referencias

- [`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md)
- [`GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md`](GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md)
- [`GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md`](GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md)
- [`GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md`](GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md)
- [`GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md`](GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md)
