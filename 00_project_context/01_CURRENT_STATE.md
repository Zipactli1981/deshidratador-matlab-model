# CURRENT STATE — Deshidratador MATLAB / Q1

## Estado vigente y evidencia Git

Actualización documental: 2026-09-13. HB200 está cerrado científica y documentalmente; CORRECTED_R1/CR1-COMP no son la fase operativa actual.

```text
PRIMARY_THESIS_LEGACY_BASELINE = HB200
HB200_PRINCIPAL_HISTORICAL_BASELINE = SUPPORTED
HB306_STATUS = RECOVERED_LATER_CHECKPOINT_PROVENANCE_UNRESOLVED
HB306_EQUIVALENT_TO_THESIS_GENERATION_316 = NOT_PROVEN
R1_50GEN_ROLE = AUXILIARY_REPRODUCIBILITY_CONTROL
HB200_ARTIFACT_REGISTRATION_LOCAL_COMMIT = PASS
HB200_PUSH = PASS
HB200_REGISTRATION_COMMIT = 0e1233041e36dc0bf01ab314def3baf9e1c8faa0
HB200_REGISTRATION_PARENT = aae8f34aa573f53cb3ad163f5565d08ce490e4c3
LIVE_BRANCH_OBSERVED = main
LIVE_HEAD_OBSERVED = 258f6ad28e98ca095aeca5e41cd255df1cda91ad
ORIGIN_MAIN_OBSERVED = 258f6ad28e98ca095aeca5e41cd255df1cda91ad
AHEAD_BEHIND_OBSERVED = 0 / 0
```

El HEAD vigente registra la infraestructura primaria ROR; main y origin/main coinciden. Son observaciones de este micropaso, no requisitos para futuros HEAD. A la entrada del gate de versionado recovery: staging y cambios tracked vacíos, cinco archivos recovery nuevos autorizados y 36 untracked preexistentes ajenos preservados.

## Cierre científico HB200

Fuentes verificables: paquete `06_manuscript/article_Q1/review/thesis_legacy_HB200/`, informe completo, auditoría de reproducibilidad, red-team, tablas T1–T6 e inventario registrado en `04_ARTIFACT_INDEX.md`. Los MAT primarios upstream/frozen permanecen fuera del paquete compacto, preservados por checksum; las tablas derivadas no los sustituyen.

```text
THESIS_LEGACY_ARTIFACT_REGISTRATION = CLOSED_PUBLISHED
THESIS_LEGACY_REEVALUATION_STATUS = PASS
UNIQUE_FINITE_THESIS_DESIGNS = 44
HISTORICALLY_ND_DESIGNS = 16
CURRENTLY_ND_THESIS_DESIGNS = 9
PERSISTENT_ND = 6
LOST_ND_STATUS = 10
GAINED_ND_STATUS = 3
DETERMINISM_CHECK = EXACT
TIMING_EXPERIMENT_COMPLETED = YES
T_REC_MATERIAL_EFFECT_DETECTED = YES_ALL_3_PRESPECIFIED_DESIGNS
T_REC_EFFECT_DIRECTION = NONMONOTONIC_AND_DESIGN_OBJECTIVE_DEPENDENT
```

La comparación de núcleos T(9)–C(9) registra 2 pares T→C, 6 C→T, 73 incomparables y contribuciones 7/7 al joint rank-1. T025 permanece ND dentro de T, pero ocupa joint rank 2 y es dominado por C05. El determinismo corresponde a las repeticiones centinela auditadas, no prueba convergencia. `t_rec=0` no significa ausencia de recirculación.

## Auditoría de transformación objetiva

```text
HB200_OBJECTIVE_TRANSFORMATION_AUDIT = PASS
EVIDENCE_LEVEL = HIGH
OBJECTIVE_ORDER_REORDERING_ALONE_PRESERVES_PARETO = YES
COMPLETE_HISTORICAL_TO_CURRENT_TRANSFORMATION_PRESERVES_PARETO = NO
DESIGN_DEPENDENT_DENOMINATORS_FOUND = YES
DESIGN_DEPENDENT_TERMS_FOUND = YES
ACCOUNTING_BASIS_CHANGE_FOUND = YES
CAN_OBJECTIVE_TRANSFORMATION_EXPLAIN_16_TO_9 = YES
HB200_GLOBAL_PARETO_OPTIMALITY_SUPPORTED = NO
C_AS_OPTIMIZER_SUPERIORITY_EVIDENCE = NO
C_AS_FORMULATION_CONTROL_SPACE_BENCHMARK = SUPPORTED_WITH_PARTIAL_CONFOUNDING
```

Base documental de esta conclusión: T1 (objetivos históricos), T2 (reevaluación), T3 (transiciones), informe HB200 y código COST-E3D: `objective_productive_corrected_v96j_triobjective_CO2_fix1`, su base `v95j_endpoint_TMAX_corrected` y `calc_cost_breakdown`. No se presupone un informe independiente versionado de la auditoría.

La permutación histórica [costo, MR, CO2 total] → actual [MR, costo específico, CO2 específico] por sí sola conserva dominancia. La transformación completa no: agua removida = (Mi−M_terminal(x))*md; costo y emisiones dependen de tiempo, energía auxiliar y estado terminal del diseño. Cambian la base contable y el tratamiento físico terminal. Las tablas muestran inversiones de orden entre diseños incluso tras emparejar objetivos por significado (MR: T003/T009; costo: T034/T037; emisiones: T027/T004). Por tanto no existe una simple transformación estrictamente creciente común que explique todos los valores. El 16→9 es compatible con estos mecanismos y está documentado; no se identifica una contribución causal aislada de cada término sin nuevas evaluaciones, que no están autorizadas.

HB200 es el principal baseline histórico trazable y una aproximación no dominada histórica recuperada (su núcleo histórico), no un frente global/exacto. C es un piloto congelado de formulación actual. Base objetiva y espacio de control están parcialmente confundidos en T–C; no prueban superioridad del optimizador.

## Antecedente y metodología histórica congelada

CORRECTED_R1 = CLOSED_PASS, postrun baseline `8a794c389edd10f9750e10a27eca0ec58c14da2d`; C conserva sus nueve soluciones y su configuración piloto de 50 generaciones. No se reabre esta campaña. `06_manuscript/article_Q1/review/CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md` v1.0 sigue congelado para H(9)–C(9), SHA-256 `8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3`; no se modifica retrospectivamente.

## ROR primario — postrun composite completado pero insuficiente

```text
ROR_PRIMARY_SET_INTEGRITY = PASS
ROR_PRIMARY_VALID_RUNS = 5/5
ROR_PRIMARY_CAMPAIGN = COMPLETED_5x200
ROR_PRIMARY_POSTRUN = COMPLETED_BUT_INSUFFICIENT
POSTRUN_EXECUTION_ATTEMPT = 2
POSTRUN_ARTIFACT_INTEGRITY = PASS_10_OF_10
PRIMARY_SUFFICIENCY = FAIL
FAILED_CONDITION = HV_RATIO
HV_RATIO = 0.8013138164000172
MAX_IGD_PLUS = 0.07675334831002154
MEDIAN_IGD_PLUS = 0.02968353427953785
OBJECTIVE_EXTREMES = 5/5, 5/5, 5/5
N_POOL_SIZE = 22
N_POOL_OBJECTIVE_COUNT = 21
N_POOL_DUPLICATE_CLASS = VALID_DECISION_DUPLICATE_OBJECTIVE_VECTOR
NO_OPERATIONAL_RECOMMENDATIONS = YES
EXTENDED_BUDGET_CAMPAIGN = NOT_AUTHORIZED
CURRENT_GATE = ROR_PRIMARY_POSTRUN_RESULTS_INTERPRETATION_AND_VERSIONING
```

El postrun composite publicó transaccionalmente diez derivados hash-valid. IGD+ y reproducibilidad de extremos satisfacen sus umbrales, pero la razón min/max de HV `0.8013138164000172` incumple el mínimo congelado `0.90`; ésta es la única causa del FAIL. La seed 61005 presenta simultáneamente el menor HV y el mayor IGD+, sin que ello constituya fallo de corrida. Las cinco alcanzaron MaxGenerations: un presupuesto de 200 puede ser una explicación plausible de la variabilidad, pero no está demostrado; no se afirma convergencia u optimalidad global ni se autoriza automáticamente una campaña extendida. N_POOL es una aproximación no dominada multi-seed: sus 22 decisiones contienen 21 vectores objetivo únicos porque dos decisiones distintas de 61001 comparten exactamente el mismo vector objetivo y, bajo dominancia exacta, ninguna domina a la otra.

## Diagnóstico secundario de presupuesto extendido — reparación de reserva validada, no reejecutado

```text
PRIMARY_ROR_CAMPAIGN = COMPLETED_BUT_INSUFFICIENT
PRIMARY_SUFFICIENCY = FAIL
PRIMARY_FAILED_CONDITION = HV_RATIO
EXTENDED_BUDGET_DIAGNOSTIC_ROLE = SECONDARY_EXTENDED_BUDGET_DIAGNOSTIC
EXTENDED_BUDGET_DIAGNOSTIC_STATUS = ROOT_RESERVATION_FIX_PASS_NOT_REEXECUTED
EXTENDED_BUDGET_CAMPAIGN_ID = ROR_BUDGET_DIAGNOSTIC_61001_G400_V01
DIAGNOSTIC_SEED = 61001
DIAGNOSTIC_MAX_GENERATIONS = 400
DIAGNOSTIC_INITIALIZATION = FROM_SCRATCH
DIAGNOSTIC_PROTOCOL_SHA256 = 4081B46D21D2EA4D7B4587A8AA40763F8BB718ECE20719C979CB5ABA7B6FBB5D
ROOT_RESERVATION_FIX = PASS
ROOT_RESERVATION_FIX_CLASS = INFRASTRUCTURE_ROOT_RESERVATION_FIX
SOURCE_LOCK_SHA256 = 358DDE5EE0077B4D0DDA618E2787C8213442681A41090F056F2603C4950482FB
DIAGNOSTIC_PROTOCOL_UNCHANGED = YES
DIAGNOSTIC_CONFIG_UNCHANGED = YES
SCIENTIFIC_EXECUTION_COMPLETED = NO
GAMULTIOBJ_EXECUTED = NO
MODEL_EVALUATIONS_EXECUTED = 0
NEW_DIAGNOSTIC_OPTIMIZATIONS_EXECUTED = 0
REAL_EXECUTION_ROOT = ABSENT
CURRENT_GATE = ROR_EXTENDED_BUDGET_DIAGNOSTIC_ROOT_RESERVATION_FIX_VERSIONING
```

El primer intento autorizado inició MATLAB pero se bloqueó antes de `gamultiobj`, con cero evaluaciones de modelo/objective y sin crear el execution root: la reserva usaba `java.io.File.mkdir()` sobre la raíz de campaña cuando faltaba su directorio padre fijo. La reparación mínima separa la creación idempotente del padre de la reserva exclusiva de la raíz; soporta parent ausente y conserva colisión fail-closed. Los seis casos sintéticos y MATLAB dry pasan, y el source lock actualizado valida 16/16. No se ha reejecutado la campaña.

El diagnóstico conserva `PopulationSize=24`, `UseParallel=false`, población/scores iniciales vacíos y ausencia total de warm start. Su única diferencia científica autorizada respecto de la configuración primaria es `MaxGenerations: 200 -> 400`; la OutputFcn pasiva constituye una diferencia observacional. La campaña primaria, su suficiencia, su HV ratio y su N_POOL permanecen sin cambios.
