# ROR EXTENDED BUDGET DIAGNOSTIC PROTOCOL v01

## Estado y rol

`PROTOCOL_STATUS = FROZEN_BEFORE_EXECUTION`

`ROLE = SECONDARY_EXTENDED_BUDGET_DIAGNOSTIC`

`CAMPAIGN_ID = ROR_BUDGET_DIAGNOSTIC_61001_G400_V01`

Este protocolo no sustituye ni modifica la campaña primaria 5×200. La suficiencia primaria permanece `FAIL`, su condición fallida permanece `HV_RATIO`, y el `N_POOL` primario no puede recibir datos de esta corrida.

## Preguntas científicas congeladas

Pregunta principal: ¿una nueva ejecución desde cero de seed 61001, manteniendo la configuración científica primaria salvo `MaxGenerations=400`, muestra evolución relevante de su aproximación no dominada después de G200 o alcanza terminación interna válida antes de G400?

Pregunta secundaria: ¿el estado G200 de esa nueva ejecución reproduce exactamente la corrida primaria 61001×200?

No se inferirá convergencia u optimalidad global, suficiencia primaria, robustez multisemilla, ni que 400 generaciones resuelvan la insuficiencia primaria.

## Diseño congelado

- Seed: `61001`; RNG: `twister`.
- `PopulationSize=24`, `MaxGenerations=400`, `UseParallel=false`, `NVARS=4`.
- Inicialización: `FROM_SCRATCH`.
- `InitialPopulationMatrix=[]`; `InitialScoresMatrix=[]`.
- Warm starts HB200, C y primary-200: `NO`.
- Única diferencia científica autorizada frente a la configuración primaria: `MaxGenerations: 200 -> 400`.
- Única diferencia observacional autorizada: `OutputFcn: [] -> @ror_extended_snapshot_outputfcn`.
- Toda otra opción científica debe ser exactamente equivalente a la configuración primaria; cualquier diferencia bloquea.

## Referencias primarias inmutables

Referencia: `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_REAUTHORIZED/seed_61001/PRIMARY_OUTPUT.mat`.

SHA-256: `E227B1E0FA6C944C9A0F55DEC77C050239E5165C724F84BA075410B5E548A37E`.

Normalización primaria fija, que no se recalculará después de observar la corrida extendida:

```text
lo = (0.0035234386070778913, 0.18288767994676008, 0.4004048587704998)
hi = (0.2855208662368561, 0.6013407286569235, 1.54182299594184)
HV reference = (1.10, 1.10, 1.10)
```

Dominancia e igualdad usan doubles persistidos a precisión completa. El diagnóstico de near-tie `1e-12` es sólo informativo y nunca redefine igualdad ni dominancia.

## Snapshots pasivos

La OutputFcn es estrictamente observacional: devuelve `state` y `options` sin cambios, devuelve `optchanged=false`, no establece `StopFlag`, no cambia `Population`, `Score` ni operadores y no detiene el solver.

Checkpoints previstos: G50, G100, G150, G200, G250, G300, G350 y G400/final. Una llamada `flag="done"` siempre intenta persistir el estado final. Si la terminación ocurre entre checkpoints, ese snapshot `done` es el final. Si termina antes de G200, `G200 = NOT_REACHED`.

Cada snapshot registra, cuando MATLAB lo proporciona: `Generation`, `Population`, `Score`, `FunEval`, `isFeas`, `C`, `Ceq`, `maxLinInfeas`, `Rank`, `Distance`, `Spread` y `StopFlag`. La ausencia se representa explícitamente como `NOT_AVAILABLE`, sin inventar valores. También registra el estado RNG observacional, timestamp UTC, seed, campaign ID, configuración congelada, Git HEAD, SHA-256 del protocolo, hashes de dependencias/source lock, versión MATLAB e identidad del solver.

Los snapshots se escriben sólo en la raíz diagnóstica reservada. Se usa archivo temporal en el mismo directorio y rename, sin overwrite. El hash inventory se publica después de validar el archivo; un snapshot parcial no es válido.

## Comparaciones postrun preespecificadas

### Extended G200 vs primary 61001 G200

- Igualdad de `Population`: exacta, full precision y mismo orden, cuando las dimensiones son comparables.
- Igualdad de `Score`: exacta por fila y en el mismo orden.
- Igualdad del conjunto objetivo ND: exacta e independiente del orden.
- Si falla la igualdad exacta, se permite un reporte near-tie `1e-12` únicamente informativo.
- Si no reproduce exactamente: `TRAJECTORY_CLASS = ALTERNATIVE_400GEN_BUDGET_TRAJECTORY`; la corrida conserva validez para análisis within-run.

### Extended G200 vs extended final

Se reportan `N_G200_SIZE`, `N_FINAL_SIZE`, igualdad exacta de conjuntos objetivo ND, cobertura en ambos sentidos, puntos de G200 dominados por final, puntos finales dominados por G200, mejores F1/F2/F3, HV en G200 y final, cambio absoluto y relativo. El HV usa exclusivamente la normalización primaria fija y referencia `(1.10,1.10,1.10)`. Si `HV_G200=0`, el cambio relativo es `NOT_COMPARABLE`.

La cobertura `COVERAGE_A_TO_B` es la fracción de puntos de B estrictamente dominados por al menos un punto de A.

## Categorías interpretativas congeladas

`A = INTERNAL_TERMINATION_BEFORE_400` sólo si `exitflag=1`, `output.generations < 400` y la terminación corresponde a un criterio interno válido del solver. Excluye callback stop, error, interrupción, infeasibilidad y terminación externa.

`B = POST_200_EVOLUTION_OBSERVED` si se alcanza G400, el conjunto objetivo ND final difiere exactamente del de G200 y existe evidencia de mejora post-G200 por dominancia, cobertura o HV de referencia fija, sin señales contradictorias que impidan una dirección clara. Interpretación: sensibilidad al presupuesto soportada sólo para seed 61001.

`C = NO_DETECTABLE_POST_200_CHANGE` si los conjuntos objetivo ND G200/final son exactamente iguales y las métricas congeladas no muestran cambio detectable.

`D = MIXED_OR_AMBIGUOUS_POST_200_CHANGE` si se alcanza G400 pero hay cambios contrapuestos, degradación o las métricas no permiten conclusión limpia.

## Guards, cierre y relación con 5×200

Se bloquea ante seed distinta, opciones o NVARS no autorizados, warm start, hashes discordantes, callback distinta, raíz existente, ruta dentro de outputs primarios o cualquier diferencia científica inesperada. No hay restart ni overwrite automático.

Bajo A/B/C/D: `PRIMARY_SUFFICIENCY=FAIL`, `FAILED_CONDITION=HV_RATIO`, `PRIMARY_N_POOL_MODIFIED=NO`, `PRIMARY_HV_RATIO_RECALCULATED=NO`, `PRIMARY_POLICIES_SELECTED=NO`, `MULTISEED_CONCLUSION_SUPPORTED=NO`.

Regla de cierre: sólo un postrun íntegro, derivado de snapshots/final hash-valid y clasificado exactamente en A/B/C/D puede cerrar este diagnóstico. Fallos de integridad, falta de G200 cuando se requiere una comparación post-200, terminación inválida o ambigüedad de procedencia producen `BLOCKED`, no una categoría científica. La metodología sólo se incorporará al `DECISION_LOG` en un gate posterior de versionado si se adopta como vigente.
