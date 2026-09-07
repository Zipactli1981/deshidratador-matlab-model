# PHASE HANDOFF CURRENT

## HB200 cerrado → protocolo nuevo de región operativa robusta

```text
HB200_CANONICAL_STATE_COMPACT_UPDATE = PASS
PRIMARY_THESIS_LEGACY_BASELINE = HB200
HB306_STATUS = RECOVERED_LATER_CHECKPOINT_PROVENANCE_UNRESOLVED
R1_50GEN_ROLE = AUXILIARY_REPRODUCIBILITY_CONTROL
HB200_REGISTRATION_COMMIT = 0e1233041e36dc0bf01ab314def3baf9e1c8faa0
HB200_ARTIFACT_REGISTRATION_LOCAL_COMMIT = PASS
HB200_PUSH = PASS
LIVE_BRANCH_OBSERVED = main
LIVE_HEAD_OBSERVED = cc429c059807127063175a62ec3aa3fcff986edf
ORIGIN_MAIN_OBSERVED = cc429c059807127063175a62ec3aa3fcff986edf
AHEAD_BEHIND_OBSERVED = 0 / 0
```

Consulta local/remota: 2026-09-05. El commit de registro es un baseline, no un HEAD obligatorio futuro. Entrada sin cambios tracked/staged; cuatro preexistencias untracked agrupadas equivalen a 36 archivos. El paquete compacto HB200 está publicado; sus rutas, roles y hashes constan en ARTIFACT_INDEX.

## Evidencia cerrada que no debe reconstruirse

- Reevaluación HB200 PASS: 44 diseños finitos únicos; ND 16→9, 6 persistentes, 10 pérdidas, 3 ganancias; determinismo centinela EXACT.
- Timing completado: efecto material en T004/T009/T025, no monótono y dependiente del diseño/objetivo; t_rec=0 no elimina recirculación.
- T(9)–C(9): pares 2/6/73; contribución joint rank-1 7/7. T025: ND en T, joint rank 2, dominado por C05.
- OBJECTIVE_TRANSFORMATION_AUDIT = PASS / HIGH: sólo permutar objetivos preserva Pareto; transformación completa NO. Denominador de agua removida dependiente de diseño, términos energéticos/temporales y cambio de accounting basis permiten reordenamiento 16→9. Evidencia y límites causales en CURRENT_STATE; no atribución aislada al optimizador.
- HB200: baseline histórico trazable y núcleo ND recuperado, no Pareto global. C: piloto congelado y benchmark formulación/control con confounding parcial.

CORRECTED_R1/CR1-COMP son antecedentes cerrados, no fase vigente. El protocolo H(9)–C(9) v1.0 permanece intacto; no adaptarlo retrospectivamente a HB200 ni a la campaña nueva.

## Gate vigente tras reparación representacional de options

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
RERUNS_EXECUTED = 0
OPTIONS_MISMATCH_DIAGNOSIS = REPRESENTATION_ONLY
OPTIONS_REPAIR = PASS
FULL_PYTHON_REGRESSION = 34/34_PASS
MATLAB_PREEXECUTION_DRY_RECHECK = PASS
POSTRUN_DRY_INTEGRITY = PASS
SCIENTIFIC_CONFIGURATION_UNCHANGED = YES
CURRENT_GATE = ROBUST_OPERATING_REGION_OPTIONS_REPAIR_VERSIONING
NEXT_GATE = ROBUST_OPERATING_REGION_OPTIONS_REPAIR_LOCAL_COMMIT
MATLAB_EXECUTION_AUTHORIZED = NO
GAMULTIOBJ_EXECUTION_AUTHORIZED = NO
OPTIMIZATION_AUTHORIZED = NO
NEW_OPTIMIZATION_AUTHORIZED = NO
CAMPAIGN_EXECUTION_AUTHORIZED = NO
```

Protocolo congelado: `06_manuscript/article_Q1/review/CURRENT_FORMULATION_ROBUST_OPERATING_REGION_PROTOCOL_v01.md`, SHA-256 `7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599`; D014 permanece intacta. La campaña aún no se inició científicamente: cero seeds, cero llamadas a `gamultiobj`, modelo u objective y ningún output. El único bloqueo fue la normalización representacional `doubleVector`→`doublevector` de MATLAB R2026a. Runner y postrun ahora usan la misma equivalencia restringida a `PopulationType`, conservan el valor crudo y mantienen igualdad estricta del resto. Helper directo, dry preexecution, fixture MAT/postrun, source lock 53/53 y suite completa 34/34 PASS. No se realizó rerun. Tras versionado y publicación, el siguiente gate requiere una nueva autorización explícita de campaña.
