# CURRENT STATE — Deshidratador MATLAB / Q1

## Estado vigente y evidencia Git

Actualización documental: 2026-09-05. HB200 está cerrado científica y documentalmente; CORRECTED_R1/CR1-COMP no son la fase operativa actual.

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
LIVE_HEAD_OBSERVED = cc429c059807127063175a62ec3aa3fcff986edf
ORIGIN_MAIN_OBSERVED = cc429c059807127063175a62ec3aa3fcff986edf
AHEAD_BEHIND_OBSERVED = 0 / 0
```

El HEAD vigente registra la infraestructura de la campaña robusta; main y origin/main coinciden. Son observaciones de este micropaso, no requisitos para futuros HEAD. A la entrada de este gate: staging vacío, tres archivos tracked de implementación modificados y 37 untracked individuales: 36 preexistentes ajenos preservados más el nuevo helper ROR.

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

## Fase siguiente y límites

```text
CURRENT_PHASE = ROBUST_OPERATING_REGION_OPTIONS_REPAIR_VERSIONING
ROBUST_OPERATING_REGION_PROTOCOL_FREEZE = PASS
ROBUST_OPERATING_REGION_IMPLEMENTATION = PASS_STATIC_AND_SYNTHETIC
IMPLEMENTATION_INITIAL_AUDIT = BLOCKED
BLOCKING_FINDINGS = REPAIRED
REPAIR = HASH_PORTABILITY_PROVENANCE_TRANSACTIONAL_POSTRUN_AUDIT_SEED_COVERAGE
IMPLEMENTATION_REAUDIT = PASS
MATLAB_DRY_VALIDATION = PASS_WITH_RUNTIME_DEFAULTS_TRACED
MATLAB_RUNTIME = R2026a_UPDATE_4_GLOBAL_OPTIMIZATION_TOOLBOX_26_1
CREATION_FCN_EFFECTIVE = gacreationuniform
CROSSOVER_FCN_EFFECTIVE = crossoverintermediate
MUTATION_FCN_EFFECTIVE = mutationadaptfeasible
ROR_CAMPAIGN_EXECUTION_ATTEMPT = BLOCKED_PREEXECUTION_OPTIONS_REPRESENTATION_MISMATCH
RUNS_STARTED = 0
OPTIONS_MISMATCH_DIAGNOSIS = REPRESENTATION_ONLY
OPTIONS_REPAIR = PASS
FULL_PYTHON_REGRESSION = 34/34_PASS
MATLAB_PREEXECUTION_DRY_RECHECK = PASS
SCIENTIFIC_CONFIGURATION_UNCHANGED = YES
CURRENT_GATE = ROBUST_OPERATING_REGION_OPTIONS_REPAIR_VERSIONING
NEXT_GATE = ROBUST_OPERATING_REGION_OPTIONS_REPAIR_LOCAL_COMMIT
MATLAB_EXECUTION_AUTHORIZED = NO
GAMULTIOBJ_EXECUTION_AUTHORIZED = NO
OPTIMIZATION_AUTHORIZED = NO
NEW_OPTIMIZATION_AUTHORIZED = NO
CAMPAIGN_EXECUTION_AUTHORIZED = NO
```

Protocolo nuevo congelado: `06_manuscript/article_Q1/review/CURRENT_FORMULATION_ROBUST_OPERATING_REGION_PROTOCOL_v01.md`, SHA-256 `7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599`. Cinco semillas 61001–61005, población 24, máximo 200 generaciones, dominio completo COST-E3D; suficiencia y políticas preespecificadas. El intento de campaña no alcanzó solver/modelo/objective: MATLAB R2026a normalizó `PopulationType` de `doubleVector` a `doublevector` y el guard literal bloqueó antes de crear outputs. La reparación canonicaliza exclusivamente esas dos representaciones para comparar, preserva provenance cruda y mantiene estrictos los otros 27 campos. Helper MATLAB directo, dry preexecution, paridad postrun, source lock 53/53 y regresión Python completa 34/34 PASS. No hubo rerun; la campaña científica requiere una nueva autorización después del versionado/publicación de esta reparación.
