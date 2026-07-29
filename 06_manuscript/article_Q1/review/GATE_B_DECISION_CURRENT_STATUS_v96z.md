# Gate B decision: current status v96z

Estado: decisión documental vigente
Fecha: 2026-07-29

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
  comparación entre `hybrid` y `gasLP`, ni dióxido de carbono (CO2).

Este dictamen es exclusivamente documental. No autoriza ejecutar MATLAB,
`gamultiobj`, R1, R2 o R3, ni modificar scripts, modelo, física, objetivos,
límites, semillas, costos, factores CO2, datos o configuración del solver.

## Decisión Gate B vigente

Tras la integración de los PR #13, #15 y #17, Gate B registra:

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

`HOLD_FOR_CO2_FACTOR_VALIDATION -> PROTOCOL_DEFINED`

El protocolo de validación de factores CO2 quedó definido mediante
[`GATE_B_CO2_FACTOR_VALIDATION_PROTOCOL_v96z.md`](GATE_B_CO2_FACTOR_VALIDATION_PROTOCOL_v96z.md).
Este cambio levanta exclusivamente el bloqueo documental por ausencia de
protocolo de validación. No significa que los factores CO2 estén validados, que
las fichas estén completas, que las fuentes primarias hayan sido aprobadas, que
las conversiones hayan sido auditadas ni que los resultados ambientales sean
finales.

Gate B mantiene el siguiente bloqueo de evidencia:

`CO2_FACTOR_VALIDATION_EVIDENCE -> PENDING`

Aplica porque todavía no se han integrado ni aprobado las fichas documentales,
fuentes primarias, unidades, conversiones, base funcional, límites del sistema,
correspondencia con el modelo e incertidumbre de los factores CO2. Mientras
esta evidencia permanezca pendiente, CO2 no puede sustentar una selección
triobjetivo final ni claims ambientales finales.

## Estado resultante

Los tres protocolos metodológicos requeridos por Gate B están definidos
documentalmente:

- protocolo pareado `hybrid`/`gasLP`;
- protocolo de selección del punto representativo;
- protocolo de validación de factores CO2.

Sin embargo, Gate B no pasa todavía a ejecución. La razón es que el protocolo
CO2 está definido, pero la evidencia de validación CO2 aún está pendiente. Por
tanto, el estado operativo sigue siendo de espera documental antes de cualquier
corrida nueva.

Los estados `PROTOCOL_DEFINED` no autorizan por sí mismos la aplicación de los
protocolos sobre resultados nuevos ni la generación de resultados finales.

## Siguientes acciones documentales

Antes de reconsiderar Gate B para autorizar una ruta de ejecución debe
elaborarse y aprobarse la evidencia de validación CO2, incluyendo como mínimo:

1. tabla maestra de factores CO2;
2. ficha documental por factor;
3. tabla de conversiones;
4. tabla de correspondencia factor-flujo del modelo;
5. declaración de límites del sistema;
6. declaración de base funcional;
7. tratamiento de incertidumbre;
8. lista de fuentes y versiones;
9. dictamen por factor: `VALIDATED`, `PROVISIONAL` o `REJECTED`;
10. dictamen global de CO2 para Gate B.

Completar el protocolo CO2 no equivale a completar esta evidencia. Solo cuando
la evidencia sea aprobada podrá evaluarse si el estado cambia a:

`HOLD_FOR_CO2_FACTOR_VALIDATION -> VALIDATED`

o si permanece pendiente por factores provisionales, fuentes insuficientes,
conversiones no auditadas o límites del sistema incompatibles.

## Restricciones vigentes

Hasta una decisión Gate B posterior y explícita:

- no se autoriza ejecutar MATLAB;
- no se autoriza ejecutar `gamultiobj`;
- no se autoriza ejecutar R1, R2 ni R3;
- no se autoriza una minrep de 50 generaciones;
- no se autoriza una corrida formal de 400 generaciones;
- no se autoriza aplicar los protocolos sobre nuevos resultados;
- no se autoriza una selección triobjetivo final;
- no se autoriza una comparación ambiental final;
- no se autorizan claims finales de convergencia;
- no se autorizan claims finales de reproducibilidad;
- no se autorizan claims finales de superioridad `hybrid` frente a `gasLP`;
- no se autorizan claims finales de reducción de CO2;
- no se autoriza modificar scripts, modelo, física, objetivos, límites,
  semillas, costos, factores CO2, datos o configuración del solver.

Cualquier ejecución posterior requerirá una decisión Gate B independiente y una
autorización explícita de ejecución.

## Referencias

- [`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md)
- [`GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md`](GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md)
- [`GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md`](GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md)
- [`GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md`](GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md)
- [`GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md`](GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md)
- [`GATE_B_CO2_FACTOR_VALIDATION_PROTOCOL_v96z.md`](GATE_B_CO2_FACTOR_VALIDATION_PROTOCOL_v96z.md)