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

## Gate vigente — interpretación y versionado del postrun primario

```text
ROR_PRIMARY_SET_INTEGRITY = PASS
VALID_RUNS = 5/5
PRIMARY_CAMPAIGN = COMPLETED_5x200
COMPOSITE_POSTRUN = COMPLETE_TRANSACTIONAL
POSTRUN_ARTIFACT_INTEGRITY = PASS_10_OF_10
PRIMARY_SUFFICIENCY = FAIL
FAILED_CONDITIONS = HV_RATIO_ONLY
MIN_HV_OVER_MAX_HV = 0.8013138164000172
MAX_IGD_PLUS = 0.07675334831002154
MEDIAN_IGD_PLUS = 0.02968353427953785
OBJECTIVE_EXTREMES = 5/5, 5/5, 5/5
FINAL_OPERATING_POLICIES = NONE
AUTOMATIC_CAMPAIGN_EXPANSION = NO
INTERRUPTED_ORIGINAL_61003_INCLUDED = NO
CURRENT_GATE = ROR_PRIMARY_POSTRUN_RESULTS_INTERPRETATION_AND_VERSIONING
NEXT_GATE = ROR_PRIMARY_POSTRUN_RESULTS_LOCAL_COMMIT
NEXT_SCIENTIFIC_DECISION = EXTENDED_BUDGET_DIAGNOSTIC_DESIGN
```

La campaña primaria 5×200 y el postrun están completos con integridad PASS. La suficiencia falla exclusivamente por variabilidad inter-run de HV; IGD+ y extremos pasan. No existen políticas operativas finales y no se abre automáticamente otra campaña. El hecho de que las cinco corridas alcanzaran MaxGenerations permite considerar el presupuesto como hipótesis, no como causa demostrada ni garantía de que 400 generaciones resuelvan el problema. La siguiente decisión científica es diseñar —sin ejecutar todavía— un diagnóstico de presupuesto extendido.
