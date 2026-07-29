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

Tras la integración del PR #13, Gate B registra:

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

`HOLD_FOR_OBJECTIVE_SELECTION_PROTOCOL`

Aplica porque no se ha aprobado una regla determinista y reproducible para
seleccionar el punto representativo, incluidas las anclas de normalización,
pesos, criterio de desempate y trazabilidad completa de la selección. Por
tanto, ningún punto puede presentarse como óptimo o representativo final.

Los dos HOLD activos tienen precedencia sobre cualquier ruta de PASS mientras
sus condiciones permanezcan abiertas. El estado `PROTOCOL_DEFINED` de la
comparación `hybrid`/`gasLP` no altera esa precedencia ni autoriza ejecución.

## Siguientes acciones documentales

Antes de reconsiderar Gate B deben elaborarse y aprobarse:

1. un protocolo de selección reproducible del punto representativo;
2. una validación documentada de factores, unidades y fuentes de CO2.

El protocolo pareado `hybrid`/`gasLP` ya está definido documentalmente. Su
eventual aplicación requerirá una autorización explícita e independiente y
deberá respetar íntegramente el diseño aprobado.

Completar estas acciones documentales no autoriza por sí mismo ninguna
ejecución. Cualquier R2/R3 o corrida formal de 400 generaciones requerirá una
decisión Gate B posterior y una autorización explícita de ejecución.

## Referencias

- [`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md)
- [`GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md`](GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md)
- [`GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md`](GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md)
- [`GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md`](GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md)
