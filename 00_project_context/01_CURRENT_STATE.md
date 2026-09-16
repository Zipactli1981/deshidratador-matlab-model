# CURRENT STATE — Deshidratador MATLAB / Q1

## Estado vigente y evidencia Git

Actualización documental: 2026-09-15. HB200 está cerrado científica y documentalmente; CORRECTED_R1/CR1-COMP no son la fase operativa actual.

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
LIVE_HEAD_OBSERVED = 4e2ad869c6bb66e2f9339360a18e21beaf4e2603
ORIGIN_MAIN_OBSERVED = 4e2ad869c6bb66e2f9339360a18e21beaf4e2603
AHEAD_BEHIND_OBSERVED = 0 / 0
```

El HEAD vivo incorpora la reparación publicada de reserva de raíz del diagnóstico extendido; `main` y `origin/main` coinciden. Son observaciones de este micropaso, no requisitos para futuros HEAD. A la entrada de la reconciliación canónica, staging y cambios tracked estaban vacíos; los untracked preexistentes ajenos se preservaron.

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
PRIMARY_N_POOL_MODIFIED = NO
MULTISEED_CONCLUSION_SUPPORTED = NO
CURRENT_SCIENTIFIC_PHASE = PRIMARY_RESULTS_PROCESS_ENGINEERING_INTERPRETATION
```

El postrun composite publicó transaccionalmente diez derivados hash-valid. IGD+ y reproducibilidad de extremos satisfacen sus umbrales, pero la razón min/max de HV `0.8013138164000172` incumple el mínimo congelado `0.90`; ésta es la única causa del FAIL. La seed 61005 presenta simultáneamente el menor HV y el mayor IGD+, sin que ello constituya fallo de corrida. Las cinco alcanzaron MaxGenerations: un presupuesto de 200 puede ser una explicación plausible de la variabilidad, pero no está demostrado; no se afirma convergencia u optimalidad global ni se autoriza automáticamente una campaña extendida. N_POOL es una aproximación no dominada multi-seed: sus 22 decisiones contienen 21 vectores objetivo únicos porque dos decisiones distintas de 61001 comparten exactamente el mismo vector objetivo y, bajo dominancia exacta, ninguna domina a la otra.

## Diagnóstico secundario de presupuesto extendido — ejecución y postrun cerrados

```text
PRIMARY_ROR_CAMPAIGN = COMPLETED_BUT_INSUFFICIENT
PRIMARY_SUFFICIENCY = FAIL
PRIMARY_FAILED_CONDITION = HV_RATIO
EXTENDED_BUDGET_DIAGNOSTIC_ROLE = SECONDARY_EXTENDED_BUDGET_DIAGNOSTIC
EXTENDED_BUDGET_DIAGNOSTIC = COMPLETED_POSTRUN
EXTENDED_BUDGET_CAMPAIGN_ID = ROR_BUDGET_DIAGNOSTIC_61001_G400_V01
DIAGNOSTIC_SEED = 61001
DIAGNOSTIC_MAX_GENERATIONS = 400
DIAGNOSTIC_INITIALIZATION = FROM_SCRATCH
DIAGNOSTIC_WARM_START = NO
EXTENDED_BUDGET_EXECUTION_INTEGRITY = PASS
EXTENDED_BUDGET_POSTRUN = PASS
EXECUTION_EXITFLAG = 0
EXECUTION_GENERATIONS = 400
EXECUTION_FUNCCOUNT = 9600
SOLVER_TERMINATION = MAX_GENERATIONS_REACHED
SNAPSHOT_INTEGRITY = PASS_8_OF_8
EXECUTION_HASH_INVENTORY = PASS_21_OF_21
EXTENDED_G200_RELATION_TO_PRIMARY = ALTERNATIVE_400GEN_BUDGET_TRAJECTORY
EXTENDED_DIAGNOSTIC_CATEGORY = D — MIXED_OR_AMBIGUOUS_POST_200_CHANGE
BUDGET_SENSITIVITY_FOR_SEED_61001 = AMBIGUOUS
POST_200_EVOLUTION = OBSERVED
POST_200_NET_IMPROVEMENT = NOT_SUPPORTED
PRIMARY_N_POOL_MODIFIED = NO
MULTISEED_CONCLUSION_SUPPORTED = NO
```

La reparación de reserva de raíz, publicada en `4e2ad869c6bb66e2f9339360a18e21beaf4e2603`, fue exclusivamente de infraestructura: no cambió protocolo, configuración científica, código productivo ni código científico compartido. Sobre ese HEAD se completó una sola trayectoria desde cero de la seed 61001 con `PopulationSize=24`, `UseParallel=false` y `MaxGenerations=400`. El manifest de ejecución conserva el estado histórico `COMPLETED_PENDING_POSTRUN`; el postrun posterior está cerrado y hash-valid.

La población, scores y conjunto ND observados en G200 de esta trayectoria no son exactamente iguales a la corrida primaria 61001×200: se clasifica como `ALTERNATIVE_400GEN_BUDGET_TRAJECTORY`. De G200 a G400 hubo evolución, pero los cambios fueron mixtos: mejoraron los tres extremos individuales, mientras el HV común disminuyó 5.6337% y la cobertura fue bidireccional. El veredicto congelado es categoría D y sensibilidad de presupuesto ambigua. No prueba convergencia, insuficiencia de 200 generaciones ni suficiencia de 400; no repara el FAIL primario ni aporta evidencia multisemilla.

## Fase científica vigente — interpretación de ingeniería de procesos

```text
CURRENT_SCIENTIFIC_PHASE = PRIMARY_RESULTS_PROCESS_ENGINEERING_INTERPRETATION
PE_04 = PASS
PE_05 = PASS_WITH_LIMITATION
PE_06 = PASS_WITH_LIMITATION
PE07_DESIGN_VERSION = v1.1
PE_07_DESIGN = PASS
PE07_DESIGN_STATUS = FROZEN_PASS
PE_07_EXECUTION = NOT_AUTHORIZED
PE07_EXECUTION_STATUS = NOT_AUTHORIZED
CANONICAL_RECONCILIATION_VERSIONING = COMPLETE
CANONICAL_EXECUTION_PREREQUISITE = SATISFIED_AND_VERSIONED
PE07_EXECUTION_PREFLIGHT = BLOCKED
PE07_PREFLIGHT_BLOCKERS = PE07_EXECUTABLE_CONFIG_NOT_FOUND; PE07_RUNNER_NOT_FOUND
CURRENT_OPERATIONAL_BLOCK = PE07_EXECUTION_INFRASTRUCTURE_NOT_FROZEN
CURRENT_PREFLIGHT_RESULT = BLOCKED_REQUIRES_PE07_EXECUTION_INFRASTRUCTURE_FREEZE
NEXT_GATE = ROR_PE_07_EXECUTION_INFRASTRUCTURE_FREEZE
PE07_BASELINE_REPLAY_EXECUTION = NOT_AUTHORIZED
PE07_PERTURBATION_EXECUTION = NOT_AUTHORIZED
```

PE_04 identificó al GLP como driver contable común principal del costo y CO2 operacionales. PE_05 encontró un patrón descriptivo compatible con requerimiento marginal creciente de GLP, limitado por secantes entre soluciones discretas. PE_06 mantuvo todas las asociaciones control-respuesta en nivel 4 por co-movimiento de controles, sensibilidad a selección y/o confusión residual por intensidad de secado. La reconciliación canónica quedó publicada en `004685b7c6a347558877da1af85db183b3757e5b`. El preflight PE_07 se completó read-only y quedó bloqueado porque no existen configuración ejecutable ni runner PE_07. PE_07 sólo está diseñado; no existen resultados ni autorización de baseline replay o perturbaciones.
