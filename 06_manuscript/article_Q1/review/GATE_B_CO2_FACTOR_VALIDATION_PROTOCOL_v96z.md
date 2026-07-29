# Gate B CO2 factor validation protocol v96z

Estado: protocolo metodológico documental propuesto
Fecha: 2026-07-29

## 1. Propósito y alcance

Este documento define el protocolo requerido para atender
`HOLD_FOR_CO2_FACTOR_VALIDATION` dentro de Gate B. Su propósito es establecer
cómo deben validarse los factores de emisión de CO2 utilizados por el estudio
antes de permitir una selección triobjetivo final, una comparación ambiental
final o claims ambientales derivados de los resultados de optimización.

Este protocolo no ejecuta ni autoriza MATLAB, `gamultiobj`, R1, R2, R3, una
minrep de 50 generaciones ni una corrida formal de 400 generaciones. Tampoco
modifica scripts, modelo, física, funciones objetivo, límites, semillas,
costos, factores CO2, datos, archivos CSV, archivos MAT ni configuración del
solver.

Definir este protocolo no equivale a validar numéricamente los factores. La
validación requiere evidencia trazable, fuentes primarias, unidades
consistentes, conversiones auditables, límites del sistema definidos,
correspondencia con el modelo e incertidumbre documentada.

## 2. Estado de bloqueo

`HOLD_FOR_CO2_FACTOR_VALIDATION` permanece activo mientras no exista evidencia
suficiente para confirmar:

- fuente primaria de cada factor de emisión;
- año o periodo de vigencia;
- cobertura geográfica;
- unidad original;
- conversión a las unidades usadas por el modelo;
- base funcional;
- límites del sistema;
- correspondencia con los flujos energéticos modelados;
- tratamiento de incertidumbre;
- trazabilidad documental y computacional.

Mientras este HOLD permanezca activo:

- no se autoriza una selección triobjetivo final;
- no se autoriza una comparación ambiental final entre `hybrid` y `gasLP`;
- no se autorizan claims finales de reducción de emisiones;
- CO2 solo puede usarse como métrica provisional o diagnóstica;
- cualquier resultado que incluya CO2 debe etiquetarse explícitamente como
  provisional.

## 3. Factores sujetos a validación

Deben identificarse todos los factores de emisión que entren directa o
indirectamente en el cálculo de CO2 del estudio. Como mínimo, el inventario debe
cubrir:

- gas LP;
- electricidad de red, si aplica;
- energía solar, si se le asigna factor distinto de cero;
- cualquier energía auxiliar;
- cualquier conversión energética intermedia;
- cualquier factor heredado de versiones previas del código o manuscrito.

Para cada factor debe quedar claro si el modelo lo usa directamente o si se
obtiene mediante conversión desde otra unidad. No se permite tratar un factor
como validado solo porque el código lo ejecuta, porque aparece en una tabla
previa o porque produce valores numéricamente plausibles.

## 4. Ficha mínima por factor

Cada factor de emisión debe documentarse en una ficha con los siguientes campos
obligatorios:

| Campo | Requisito |
|---|---|
| Identificador | Nombre corto único del factor |
| Flujo asociado | Energía o insumo al que aplica |
| Valor original | Valor tal como aparece en la fuente |
| Unidad original | Unidad reportada por la fuente |
| Valor usado por el modelo | Valor después de conversión |
| Unidad usada por el modelo | Unidad final aplicada en cálculo |
| Fuente primaria | Documento, base de datos o norma de origen |
| Año o periodo | Vigencia temporal del factor |
| Geografía | País, región, sistema eléctrico o mercado aplicable |
| Límite del sistema | Alcance físico del factor |
| Base funcional | Magnitud respecto de la cual se emite CO2 |
| Conversión aplicada | Secuencia de conversión y constantes usadas |
| Incertidumbre | Rango, escenario o criterio conservador |
| Responsable | Persona que validó la ficha |
| Fecha | Fecha de validación documental |
| Estado | `VALIDATED`, `PROVISIONAL` o `REJECTED` |

Una ficha incompleta mantiene el factor en estado `PROVISIONAL`.

## 5. Unidades y conversiones

Todas las conversiones deben ser explícitas y reproducibles. No se aceptan
conversiones implícitas, redondeos no declarados ni mezcla de unidades
energéticas sin justificación.

La validación debe confirmar, según aplique:

- equivalencia entre kWh, MJ y otras unidades de energía;
- conversión de masa o volumen de combustible a energía útil o energía de
  entrada;
- poder calorífico usado para gas LP;
- si el poder calorífico es inferior o superior;
- densidad o composición del combustible, si se usa;
- correspondencia entre energía térmica, energía eléctrica y energía auxiliar;
- consistencia entre el denominador del factor y la variable usada por el
  modelo;
- número de cifras significativas conservadas.

Cuando el modelo use una unidad distinta a la fuente, debe conservarse la ruta
completa de conversión. El valor convertido debe poder recalcularse sin
consultar el código.

## 6. Límites del sistema

Cada factor debe clasificarse conforme a sus límites del sistema. Debe quedar
explícito si representa:

- combustión directa;
- ciclo de vida;
- extracción, procesamiento y transporte;
- generación eléctrica promedio;
- generación eléctrica marginal;
- mezcla nacional;
- mezcla regional;
- factor de sitio;
- factor de fuente;
- otro alcance específico.

No se permite comparar factores con límites del sistema incompatibles sin
declarar la diferencia y justificar su uso. Si `hybrid` y `gasLP` usan límites
distintos sin justificación, la comparación ambiental queda inválida para uso
final.

## 7. Correspondencia con el modelo

La validación debe confirmar que cada factor se aplica al flujo correcto del
modelo. En particular, debe verificarse:

- si el consumo energético reportado por el modelo corresponde a energía de
  entrada, energía útil, energía auxiliar o energía acumulada;
- si el factor de gas LP se multiplica por masa, volumen, energía química o
  energía térmica;
- si el factor eléctrico aplica a consumo eléctrico real y no a energía térmica;
- si la energía solar se contabiliza con factor cero, factor de ciclo de vida o
  exclusión explícita;
- si el modo `hybrid` combina factores sin doble conteo;
- si el modo `gasLP` usa la misma base funcional que `hybrid`.

Cualquier discrepancia entre el flujo físico modelado y la base del factor
mantiene el HOLD activo.

## 8. Base funcional

La comparación ambiental debe usar una base funcional única y explícita. La
base funcional debe declarar, como mínimo:

- producto o carga de secado considerada;
- condición inicial y final de humedad o MR;
- unidad de producción o lote;
- tiempo o ciclo de operación, si aplica;
- frontera energética del proceso;
- si se comparan modos energéticos bajo la misma tarea de secado.

No se permite afirmar reducción de CO2 entre modos si los resultados no están
normalizados a la misma base funcional.

## 9. Tratamiento de incertidumbre

Cada factor validado debe incluir al menos un tratamiento documental de
incertidumbre. Puede consistir en:

- rango de valores reportado por la fuente;
- escenario bajo, central y alto;
- comparación entre fuentes primarias compatibles;
- justificación de valor conservador;
- sensibilidad sobre el factor más influyente;
- criterio explícito para no propagar incertidumbre, si se justifica.

Cuando no exista incertidumbre cuantitativa disponible, debe declararse como
limitación. La ausencia de incertidumbre no invalida automáticamente el factor,
pero impide presentar claims ambientales con precisión excesiva.

## 10. Jerarquía de fuentes

Las fuentes deben priorizarse en este orden:

1. fuente oficial o regulatoria aplicable al país, región y periodo del estudio;
2. base de datos institucional o técnica reconocida;
3. publicación científica revisada por pares;
4. manual técnico o documentación de proveedor;
5. supuesto interno documentado, solo como estado provisional.

Si dos fuentes confiables producen factores incompatibles, debe registrarse la
discrepancia y adoptarse una regla predeclarada: valor central, escenario
conservador, análisis de sensibilidad o mantenimiento del HOLD.

No se permite seleccionar retrospectivamente la fuente que favorezca a un modo
energético.

## 11. Criterios de aceptación

Un factor puede pasar a `VALIDATED` solo si cumple simultáneamente:

- tiene fuente identificable y trazable;
- tiene unidad original clara;
- tiene conversión reproducible a la unidad usada por el modelo;
- corresponde al flujo físico que multiplica;
- es compatible con la geografía y periodo del estudio o justifica su uso;
- tiene límites del sistema explícitos;
- es compatible con la base funcional;
- no introduce doble conteo;
- conserva evidencia de incertidumbre o limitación;
- queda registrado en una tabla de validación.

Si cualquiera de estos puntos falta, el factor queda como `PROVISIONAL` o
`REJECTED`.

## 12. Reglas de invalidez

La validación CO2 es inválida si:

- no se puede identificar la fuente primaria;
- la unidad original no está documentada;
- la conversión energética no puede reproducirse;
- se mezclan poder calorífico inferior y superior sin control;
- se compara combustión directa contra ciclo de vida sin advertencia;
- se aplica un factor eléctrico a energía térmica o viceversa;
- se usa un factor geográfica o temporalmente incompatible sin justificación;
- se omite incertidumbre cuando la fuente la reporta;
- se ajusta el factor después de observar resultados de optimización;
- se elige una fuente para favorecer retrospectivamente a `hybrid` o `gasLP`;
- se modifica el código sin una decisión metodológica separada;
- se presentan claims ambientales finales con factores provisionales.

Una validación inválida debe registrarse y mantiene activo el HOLD.

## 13. Evidencia requerida

La validación debe producir, como mínimo:

- tabla maestra de factores CO2;
- ficha documental por factor;
- tabla de conversiones;
- tabla de correspondencia factor-flujo del modelo;
- declaración de límites del sistema;
- declaración de base funcional;
- tratamiento de incertidumbre;
- lista de fuentes y versiones;
- hashes o identificadores de documentos fuente cuando existan;
- dictamen por factor: `VALIDATED`, `PROVISIONAL` o `REJECTED`;
- dictamen global de CO2 para Gate B.

La evidencia debe ser suficiente para reconstruir el cálculo sin consultar
supuestos no documentados.

## 14. Relación con protocolos ya definidos

Este protocolo se aplica después de los documentos ya integrados:

- `GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md`;
- `GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md`.

Aunque ambos protocolos estén definidos, la selección triobjetivo final y la
comparación ambiental final permanecen bloqueadas mientras CO2 no esté
validado.

La validación CO2 no sustituye la necesidad de ejecutar comparaciones pareadas
ni de aplicar la regla de selección sobre resultados aprobados. Solo elimina el
bloqueo metodológico asociado a factores de emisión.

## 15. Criterio documental para levantar el HOLD

`HOLD_FOR_CO2_FACTOR_VALIDATION` puede levantarse documentalmente solo cuando:

- todos los factores CO2 usados por el estudio estén inventariados;
- cada factor tenga ficha completa;
- las unidades y conversiones estén auditadas;
- los límites del sistema estén definidos;
- la base funcional esté aprobada;
- la correspondencia con el modelo esté verificada;
- la incertidumbre esté documentada;
- no existan factores `PROVISIONAL` usados para claims finales;
- quede registrada la autorización explícita del usuario para levantar este
  HOLD.

El estado documental resultante será primero:

HOLD_FOR_CO2_FACTOR_VALIDATION -> PROTOCOL_DEFINED

Si además se integran fichas, fuentes y evidencias completas, el estado podrá
cambiar posteriormente a:

HOLD_FOR_CO2_FACTOR_VALIDATION -> VALIDATED

La distinción es obligatoria. Definir el protocolo no equivale a validar los
factores.

## 16. Estado posterior esperado

Si este protocolo se aprueba, Gate B podrá registrar que el método de validación
CO2 está definido, pero todavía deberá decidir si la evidencia disponible basta
para declarar los factores como validados.

Mientras no exista dictamen `VALIDATED`:

- no se autoriza selección triobjetivo final;
- no se autoriza comparación ambiental final;
- no se autorizan claims finales de CO2;
- no se autoriza ejecución de MATLAB, R2, R3, minrep o 400 generaciones por
  este solo documento.

Cualquier ejecución posterior requiere una decisión Gate B independiente y una
autorización explícita.

## 17. Referencias

- [`POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`](POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md)
- [`GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md`](GATE_A_TO_FORMAL_RUN_RECONCILIATION_v96z.md)
- [`GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md`](GATE_B_ACCEPTANCE_CRITERIA_FORMAL_GA_v96z.md)
- [`GATE_B_DECISION_CURRENT_STATUS_v96z.md`](GATE_B_DECISION_CURRENT_STATUS_v96z.md)
- [`GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md`](GATE_B_HYBRID_GASLP_PAIRED_PROTOCOL_v96z.md)
- [`GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md`](GATE_B_OBJECTIVE_SELECTION_PROTOCOL_v96z.md)
