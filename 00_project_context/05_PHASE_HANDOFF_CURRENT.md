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

## Gate vigente — infraestructura composite-postrun

```text
ROR_PRIMARY_SET_INTEGRITY = PASS
VALID_RUNS = 5/5
COMPOSITE_POSTRUN_ADAPTER = PASS_VALIDATED
COMPOSITE_SOURCE_MAP_VALID = YES
INTERRUPTED_ORIGINAL_61003_INCLUDED = NO
REAL_SCIENTIFIC_METRICS_COMPUTED = NO
CURRENT_GATE = ROR_COMPOSITE_POSTRUN_INFRASTRUCTURE_VERSIONING
NEXT_GATE_AFTER_PUBLICATION = ROR_COMPOSITE_PRIMARY_POSTRUN_AUTHORIZATION
```

El conjunto primario íntegro combina 61001/61002 de la campaña original con 61003/61004/61005 de recovery, exactamente una fuente por seed. `ror_composite_postrun.py` valida manifiesto, campañas, roles, rutas, hashes, configuración, provenance y estructura MAT; el intento parcial original 61003 permanece excluido. La validación sintética y la equivalencia con single-root están cerradas. No se calcularon N_POOL, IGD+, HV, suficiencia ni recomendaciones reales. Tras publicar esta infraestructura se requiere autorización separada para el postrun científico compuesto.
