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
LIVE_HEAD_OBSERVED = 258f6ad28e98ca095aeca5e41cd255df1cda91ad
ORIGIN_MAIN_OBSERVED = 258f6ad28e98ca095aeca5e41cd255df1cda91ad
AHEAD_BEHIND_OBSERVED = 0 / 0
```

Consulta local/remota: 2026-09-09. El commit de registro es un baseline, no un HEAD obligatorio futuro. Al entrar al versionado recovery no había cambios tracked ni staged; se preservan 36 untracked preexistentes ajenos. El paquete compacto HB200 está publicado; sus rutas, roles y hashes constan en ARTIFACT_INDEX.

## Evidencia cerrada que no debe reconstruirse

- Reevaluación HB200 PASS: 44 diseños finitos únicos; ND 16→9, 6 persistentes, 10 pérdidas, 3 ganancias; determinismo centinela EXACT.
- Timing completado: efecto material en T004/T009/T025, no monótono y dependiente del diseño/objetivo; t_rec=0 no elimina recirculación.
- T(9)–C(9): pares 2/6/73; contribución joint rank-1 7/7. T025: ND en T, joint rank 2, dominado por C05.
- OBJECTIVE_TRANSFORMATION_AUDIT = PASS / HIGH: sólo permutar objetivos preserva Pareto; transformación completa NO. Denominador de agua removida dependiente de diseño, términos energéticos/temporales y cambio de accounting basis permiten reordenamiento 16→9. Evidencia y límites causales en CURRENT_STATE; no atribución aislada al optimizador.
- HB200: baseline histórico trazable y núcleo ND recuperado, no Pareto global. C: piloto congelado y benchmark formulación/control con confounding parcial.

CORRECTED_R1/CR1-COMP son antecedentes cerrados, no fase vigente. El protocolo H(9)–C(9) v1.0 permanece intacto; no adaptarlo retrospectivamente a HB200 ni a la campaña nueva.

## Gate vigente — orquestación de recuperación ROR

```text
ORIGINAL_CAMPAIGN_ID = ROR_PRIMARY_20260907_REAUTHORIZED
ORIGINAL_VALID_SEEDS = 61001,61002
INTERRUPTED_SEED = 61003
INTERRUPTED_ATTEMPT_CLASS = INTERRUPTED_ATTEMPT_EVIDENCE
INTERRUPTED_ATTEMPT_INCLUDED_IN_PRIMARY_SET = NO
INTERRUPTED_ATTEMPT_RESUMABLE = NO
INTERRUPTION_CAUSE = EXTERNAL_WINDOWS_UPDATE_REBOOT
RECOVERY_ORCHESTRATION = PASS_IMPLEMENTED_NOT_EXECUTED
RECOVERY_CAMPAIGN_ID = ROR_PRIMARY_20260907_RECOVERY_FROM_61003_A1
RECOVERY_SEEDS = 61003,61004,61005
FINAL_PRIMARY_SEED_SET_IF_RECOVERY_COMPLETES = 61001,61002,61003,61004,61005
SYNTHETIC_TESTS = 6/6_PASS
MATLAB_DRY_VALIDATION = PASS
CHECKCODE = PASS_0_MESSAGES
GAMULTIOBJ_CALL_COUNT = 0
MODEL_CALL_COUNT = 0
OBJECTIVE_CALL_COUNT = 0
OPTIMIZATION_RUNS = 0
SCIENTIFIC_CONFIGURATION_UNCHANGED = YES
CURRENT_GATE = ROR_RECOVERY_ORCHESTRATION_VERSIONING
NEXT_GATE = ROR_RECOVERY_ORCHESTRATION_LOCAL_COMMIT
RECOVERY_EXECUTION_AUTHORIZED = NO
```

Protocolo congelado intacto: `06_manuscript/article_Q1/review/CURRENT_FORMULATION_ROBUST_OPERATING_REGION_PROTOCOL_v01.md`, SHA-256 `7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599`. Las seeds 61001 y 61002 están completas, persistidas y verificadas en la campaña original. El intento original de 61003 se conserva sin cambios, queda excluido de toda identidad primaria y no puede alimentar una continuación. La recuperación no es resume: 61003 se ejecutará desde cero junto con 61004 y 61005 mediante infraestructura fail-closed ya validada. Durante este gate no hubo optimizaciones, evaluaciones de modelo/objective ni outputs nuevos. Después de publicar la infraestructura se requiere autorización explícita separada para `ROR_RECOVERY_EXECUTION`.
