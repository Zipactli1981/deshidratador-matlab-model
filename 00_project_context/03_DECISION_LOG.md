# DECISION LOG — Deshidratador MATLAB / Q1

## D001 — Alcance físico
Mantener calentamiento directo de aire; circuito de agua y bombas fuera del alcance.

## D002 — Potencia eléctrica
Usar 1.03 kW medidos para el impulsor/ventilador durante todo el tiempo de secado.

## D003 — Eficiencia de quemador
`eta_burner = 0.78`; energía GLP = `Q_aux_tot / 0.78`.

## D004 — Denominador de f2/f3
Usar:
```text
water_removed_kg = (Mi - M_terminal) * md
```
El mismo denominador se usa para costo y emisiones específicas.

## D005 — Comparabilidad CORRECTED_R1
Conservar la configuración histórica explícita:
```text
seed 61001
PopulationSize 24
MaxGenerations 50
hybrid
gasLP reference
formal v96l bounds
```

## D006 — Build histórico
El build exacto histórico permanece desconocido; la incertidumbre se clasifica como documental no material:
```text
FULL_SOLVER_DEFAULTS_AUDIT =
PASS_WITH_DOCUMENTARY_BUILD_LIMITATION
```

## D007 — Puntos históricos reevaluados
Son muestras históricas reevaluadas bajo COST-E3D, no un frente Pareto corregido.

## D008 — CORRECTED_R1 postrun
La corrida está internamente validada, pero la interpretación científica queda pendiente de revisión comparativa.

## D009 — Diseño del protocolo comparativo

**Estado:** SUPERSEDED_BY_D010.

La decisión original era diseñar primero el protocolo comparativo antes de ejecutar cálculos.

## D010 — Protocolo comparativo v1.0 congelado

**Decisión:** adoptar `CORRECTED_R1 COMPARATIVE PROTOCOL v96z`, versión `v1.0`, con estado:

```text
FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
```

La arquitectura congelada incluye:
1. dataset de 18 soluciones;
2. auditoría interna exacta de H y C;
3. análisis descriptivo;
4. matriz cruzada 9x9;
5. diagnóstico near-tie separado;
6. set coverage completo y de núcleos;
7. nondominated sorting conjunto;
8. geometría del espacio objetivo;
9. gate condicional de hypervolume;
10. régimen terminal;
11. descomposición de f2/f3;
12. interpretación física/económica/ambiental;
13. implicaciones posteriores para manuscrito.

**Estado:** vigente.

## D011 — Metodología aprobada ≠ ejecución autorizada

**Decisión:** el congelamiento del protocolo no autoriza por sí mismo ejecutar MATLAB, Codex, `gamultiobj` ni scripts comparativos.

Cada implementación operativa CR1-COMP requiere autorización separada.

**Estado:** vigente.

## D012 — Recuperación documental de H.f2/f3 corregidos

**Decisión:** aceptar explícitamente bajo `CR1-COMP-01-D1` la recuperación documental de `H.f2/f3` corregidos desde la única fuente persistida validada:

```text
06_manuscript/article_Q1/review/COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md
SHA-256 = 7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2
NUMERIC_REPRESENTATION = VALIDATED_17_SIGNIFICANT_DIGIT_DECIMAL_SERIALIZATION
```

La búsqueda exhaustiva determinó que no se persistió un MAT con los `double` corregidos. La excepción se limita al requisito de persistencia/precisión de `H.f2/f3`: los bits binary64 originales no están disponibles y su identidad no puede verificarse independientemente. `H.X` y `H.f1` conservan como fuente primaria el MAT histórico; la reevaluación documentó reproducción de `f1` en las nueve filas.

No se autoriza replay ni nueva evaluación del objective. No cambia la definición exacta de dominancia ni ninguna otra regla del protocolo comparativo v1.0.

**Estado:** VIGENTE.

## D013 — Convenciones numéricas descriptivas CR1-COMP-03/04

**Decisión:** adoptar las siguientes convenciones deterministas para las estadísticas descriptivas requeridas por CR1-COMP-03 y CR1-COMP-04:

```text
STD_CONVENTION = POPULATION
STD_DDOF = 0
```

La desviación estándar se define como:

```text
std = sqrt(sum((x_i - mean(x))^2) / n)
```

H y C se tratan en CR1-COMP como conjuntos finitos específicos de soluciones, no como muestras aleatorias para inferencia poblacional o variabilidad entre corridas. La desviación estándar tiene una función exclusivamente descriptiva.

```text
IQR_CONVENTION = HYNDMAN_FAN_TYPE_7
h = 1 + (n - 1)p
Q1 = quantile(p=0.25, Type 7)
Q3 = quantile(p=0.75, Type 7)
IQR = Q3 - Q1
```

Cuando `h` no sea entero se usará interpolación lineal entre las observaciones ordenadas adyacentes. Type 7 se adopta como convención determinista y reproducible; no se afirma que sea la única convención válida posible.

Para la relación con los bounds:

```text
BOUND_PROXIMITY_RULE = DISTANCES_ONLY_NO_THRESHOLD
distance_to_lb = x - lb
distance_to_ub = ub - x
normalized_distance_to_lb = (x - lb)/(ub - lb)
normalized_distance_to_ub = (ub - x)/(ub - lb)
```

No se define ningún umbral de “near bound” ni se permite clasificar soluciones como próximas a límites mediante thresholds no congelados.

```text
APPLIES_TO = CR1-COMP-03, CR1-COMP-04
PROTOCOL_V1_MODIFIED = NO
RESULTS_OBSERVED_BEFORE_DECISION = NO
DESCRIPTIVE_RESULTS_COMPUTED_BEFORE_DECISION = NO
```

D013 define sólo convenciones de implementación descriptiva. No modifica H, C, el dataset, objetivos, bounds, dominancia, near-tie, coverage, Pareto rank, hypervolume, selección de soluciones ni interpretación física, económica o ambiental. La decisión se congeló después de detectar la omisión y antes de calcular resultados dependientes de `std` o IQR.

**Estado:** VIGENTE.

## D014 — Terminal-horizon documentary representation convention

```text
DECISION_STATUS = VIGENTE
CONTEXT = CR1-COMP-12

RAW_VALUES_PRESERVED = YES
H_DRY_TIME_RAW = 19.900000000000006
C_DRY_TIME_RAW = 19.9
RAW_FLOAT_EQUALITY = FALSE
ABS_RAW_DIFFERENCE_H = 7.105427357601002e-15

TERMINAL_HORIZON_EQUIVALENCE_BASIS =
COMMON_TMAX_TERMINAL_REGIME_AND_SHARED_NOMINAL_HORIZON

FLOAT_EQUALITY_REQUIRED_FOR_COMMON_HORIZON = NO
NUMERICAL_TOLERANCE_INTRODUCED = NO
ROUNDING_APPLIED_TO_RAW_VALUES = NO
RAW_VALUES_REWRITTEN = NO

NOMINAL_TERMINAL_HORIZON = 19.9 h
H_TMAX_COUNT = 9
C_TMAX_COUNT = 9

PROTOCOL_V1_MODIFIED = NO
PROTOCOL_DEVIATION = NO
IMPLEMENTATION_CONVENTION = YES
```

**Fundamento:** el protocolo congelado requiere verificar un horizonte terminal común, no identidad binaria de representaciones floating-point procedentes de serializaciones documentales distintas.

La equivalencia de horizonte se establece por:

1. clasificación terminal común `TMAX`;
2. mismo horizonte máximo nominal documentado de `19.9 h`;
3. preservación íntegra de los valores raw de cada fuente.

D014 no declara que `19.900000000000006 == 19.9` como valores floating-point. Declara que ambas representaciones documentan el mismo horizonte terminal nominal bajo el régimen `TMAX` común.

**Alcance científico:** D014 sólo permite concluir, si CR1-COMP-12 verifica posteriormente el resto de condiciones:

```text
COMPARATIVE_TERMINAL_REGIME = COMMON_TMAX_19P9H
TEMPORAL_COMPARABILITY = COMMON_FIXED_HORIZON
```

No permite concluir igualdad de trayectorias térmicas, energía, consumo de GLP, irradiación, agua removida, costo o CO2, ni convergencia del optimizador. No introduce `1e-12`, `eps`, `isclose`, redondeo ni ningún umbral decimal como criterio de equivalencia.

**Estado:** VIGENTE.

## D015 — Canonical source for CR1-COMP-15 full verdict text

```text
D015_STATUS = VIGENTE
DECISION_SCOPE = DOCUMENTARY_CANONICALIZATION_ONLY
TRIGGER = CR1_COMP_16_BLOCKED_VERDICT_IDENTITY_MISMATCH
REPRESENTATION_DISCREPANCY_OBSERVED_BEFORE_D015 = YES

CR1_COMP_15_SCIENTIFIC_RESULT_CHANGED = NO
CR1_COMP_15_RECOMPUTED = NO
CR1_COMP_15_REOPENED = NO

FINAL_COMPARATIVE_VERDICT_FULL_TEXT_SOURCE = CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_v96z.json
FINAL_COMPARATIVE_VERDICT_AUDIT_SOURCE = CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_AUDIT_v96z.md
JSON_AUDIT_FULL_VERDICT_IDENTITY = PASS
VERDICT_IDENTITY_NORMALIZATION = WHITESPACE_ONLY

CURRENT_STATE_VERDICT_ROLE = CONDENSED_STATE_SUMMARY
PHASE_HANDOFF_VERDICT_ROLE = CONDENSED_HANDOFF_SUMMARY
CURRENT_STATE_FULL_VERBATIM_IDENTITY_REQUIRED = NO
PHASE_HANDOFF_FULL_VERBATIM_IDENTITY_REQUIRED = NO
CONDENSED_SUMMARIES_MUST_NOT_CONTRADICT_FULL_VERDICT = YES

CR1_COMP_16_VERDICT_SOURCE_RULE = READ_FULL_FROZEN_VERDICT_FROM_CR1_COMP_15_JSON_AND_VERIFY_AGAINST_AUDIT
ASSISTANT_PROMPT_PARAPHRASE_CANONICAL = NO

PROTOCOL_V1_MODIFIED = NO
PROTOCOL_DEVIATION = NO
NEW_METRIC = NO
NEW_INTERPRETATION = NO
NEW_SCIENTIFIC_RESULT = NO
```

CR1-COMP-15 congela un vector cuantitativo más una narrativa. CR1-COMP-16 debe traducir esa evidencia congelada a implicaciones para el manuscrito. Una paráfrasis operativa posterior no puede reemplazar el veredicto upstream congelado. `CURRENT_STATE` y `PHASE_HANDOFF_CURRENT` pueden conservar resúmenes compactos para gestión de estado siempre que no contradigan el veredicto completo.

**Estado:** VIGENTE.

## D016 — Scientific sufficiency of current limited manuscript claim package

```text
D016_STATUS = VIGENTE
DECISION_SCOPE = POST_COMPARATIVE_SCIENTIFIC_SUFFICIENCY
SOURCE_GATE = POST_COMPARATIVE_SCIENTIFIC_SUFFICIENCY_GATE
SOURCE_GATE_MODE = READ_ONLY_ANALYTICAL_GATE

SCIENTIFIC_SUFFICIENCY_GATE = PASS_FOR_CURRENT_LIMITED_CLAIMS
CURRENT_MANUSCRIPT_CLAIM_PACKAGE = SCIENTIFICALLY_SUFFICIENT_WITH_FROZEN_SCOPE_AND_MANDATORY_QUALIFIERS
BLOCKING_CORE_CLAIMS = NONE

TOTAL_MANUSCRIPT_CANDIDATE_CLAIMS = 40
SUFFICIENT_AS_WRITTEN_COUNT = 24
SUFFICIENT_WITH_MANDATORY_QUALIFIER_COUNT = 16
CLAIMS_REQUIRING_REMOVAL = 0
CLAIMS_REQUIRING_ADDITIONAL_EVIDENCE = 0
ADDITIONAL_EVIDENCE_REQUIRED_FOR_CURRENT_MANUSCRIPT = NO

MULTISEED_REQUIRED_FOR_CURRENT_FINITE_SET_CLAIMS = NO
MULTISEED_REQUIRED_FOR_OPTIMIZER_ROBUSTNESS_CLAIMS = YES
MULTISEED_CAMPAIGN_STATUS = USEFUL_BUT_NOT_REQUIRED
CONVERGENCE_EVIDENCE_REQUIRED_FOR_CURRENT_CORE_CLAIMS = NO
CURRENT_EVIDENCE_SUFFICIENT_FOR_REPRODUCIBLE_C_REGION_ACROSS_SEEDS = NO
CURRENT_EVIDENCE_SUFFICIENT_FOR_HV_BASED_GLOBAL_SUPERIORITY = NO

FINITE_SET_SCOPE = MANDATORY
HYPERVOLUME_SCOPE = FINITE_SETS_COMMON_FROZEN_NORMALIZATION_R5_R10_R20
HV_TRUE_FRONT_INFERENCE = PROHIBITED
MEDIAN_STATISTICAL_INFERENCE = PROHIBITED
H_PROVENANCE = REEVALUATED_NOT_REOPTIMIZED_UNDER_CORRECTED_COST_E3D
C_REGION_CLAIM = PARTIALLY_SUPPORTED_MULTIPLE_TRADEOFF_MECHANISMS
CONVERGENCE_CLAIM = NOT_SUPPORTED
BETWEEN_SEED_ROBUSTNESS_CLAIM = NOT_SUPPORTED
GLOBAL_OPTIMALITY_CLAIM = NOT_SUPPORTED
STATISTICAL_GAMULTIOBJ_SUPERIORITY_CLAIM = NOT_SUPPORTED

IRRADIACION_NOT_AVAILABLE = PRESERVED
C_CO2_COMPONENTS_NOT_PERSISTED = PRESERVED
CO2_CO2E_EDITORIAL_RECONCILIATION = PENDING
COMMON_TMAX_19P9H = FIXED_HORIZON_LIMITATION
ONE_CORRECTED_R1_RUN = YES
MAXGENERATIONS_REACHED = YES

PROJECT_CHARTER_STATUS_PARAGRAPH = HISTORICALLY_STALE_NONBLOCKING
MANUSCRIPT_READY = NOT_EVALUATED
FINAL_MANUSCRIPT_EDITED = NO
NEW_SCIENTIFIC_RESULT = NO
PROTOCOL_V1_MODIFIED = NO
CR1_COMP_01_TO_16_REOPENED = NO
```

The current manuscript thesis is limited to a traceable comparison of finite evaluated sets under corrected COST-E3D. The frozen evidence is sufficient for that limited claim package when the mandatory qualifiers established by CR1-COMP-16 and the scientific-sufficiency gate are preserved.

Claims regarding optimizer convergence, between-seed robustness, expected `gamultiobj` behavior, global optimality, statistical configuration superiority, reproducibility of the C concentration across seeds, total economic cost, life-cycle environmental impact, direct quantitative `Irradiacion` attribution, and C component-level CO2 attribution remain outside the supported claim package. A multiseed campaign would be scientifically useful for optimizer-level robustness and reproducibility claims, but it is not required for the currently limited finite-set manuscript thesis.

**Estado:** VIGENTE.

## D017 — Editorial nomenclature and insertion-control freeze

```text
D017_STATUS = VIGENTE
D017_FREEZE_ROLE = FROZEN_BY_THIS_CANONICAL_COMMIT
DECISION_SCOPE = POST_SUFFICIENCY_EDITORIAL_PREPARATION
SOURCE_GATE = POST_SUFFICIENCY_EDITORIAL_PREPARATION_GATE
SOURCE_GATE_STATUS = PASS
EDITORIAL_GATE_UPSTREAM_CHECK = PASS
EDITORIAL_GATE_RESULT_IDENTITY = PASS

NEW_SCIENTIFIC_RESULT = NO
COMPUTATIONAL_VALUES_CHANGED = NO
OBJECTIVE_FORMULATION_CHANGED = NO
ENVIRONMENTAL_MODEL_BOUNDARY_CHANGED = NO
PROTOCOL_V1_MODIFIED = NO
CR1_COMP_01_TO_16_REOPENED = NO

CO2_CO2E_RECONCILIATION_STATUS = PASS_OPTION_B
LPG_EMISSION_FACTOR_NAME = EF_LPG_kgCO2_per_kg
LPG_EMISSION_FACTOR_VALUE = 3.00
LPG_EMISSION_FACTOR_UNIT = kg CO2/kg LPG
LPG_EMISSION_METRIC_CLASS = DIRECT_CO2_MASS
GRID_EMISSION_FACTOR_NAME = EF_grid_kgCO2_per_kWh
GRID_EMISSION_FACTOR_VALUE = 0.444
GRID_EMISSION_FACTOR_UNIT = kg CO2e/kWh
GRID_EMISSION_METRIC_CLASS = CO2_EQUIVALENT_MASS
TOTAL_CO2_FORMULA_STATUS = VERIFIED
TOTAL_EMISSION_METRIC_CLASS = CO2_EQUIVALENT_MASS_UNDER_DECLARED_OPERATIONAL_REPORTING_CONVENTION

IMPLEMENTED_CHAIN =
CO2_LPG_kg = LPG_mass_kg * 3.00 kg CO2/kg LPG
CO2_electricity_kg = E_air_impeller_kWh * 0.444 kg CO2e/kWh
total_CO2_kg = CO2_LPG_kg + CO2_electricity_kg
f3 = total_CO2_kg / water_removed_kg

COMPUTATIONAL_F3_NAME = CO2_specific_kgCO2_per_kgwater
COMPUTATIONAL_F3_UNIT_STATUS = LEGACY_COMPUTATIONAL_LABEL_PRESERVED
MANUSCRIPT_F3_NAME = modeled specific operational greenhouse-gas emissions
MANUSCRIPT_F3_UNIT = kg CO2e/kg water removed
MANUSCRIPT_F3_SCOPE = DIRECT_LPG_COMBUSTION_CO2_PLUS_INDIRECT_GRID_ELECTRICITY_CO2E_NORMALIZED_BY_WATER_REMOVED
MANDATORY_F3_EDITORIAL_QUALIFIER = The metric covers only the modeled operational LPG-combustion CO2 and grid-electricity CO2e included in the implementation; it is not a life-cycle carbon footprint, complete GHG inventory, or total environmental-impact metric. For C, total emissions are available, but component-level CO2 values were not persisted.

NOMENCLATURE_AUDIT_STATUS = PASS
UNIT_AUDIT_STATUS = PASS
UNRESOLVED_UNIT_COUNT = 0
Q_AUX_TOT_UNIT = MJ
Q_AUX_TOT_HISTORICAL_KWH_DESCRIPTION = SUPERSEDED_BY_COST_E3D_AND_CR1_COMP_13

TOTAL_MANUSCRIPT_CANDIDATE_CLAIMS = 40
CORE_CLAIMS = 20
SUPPORTING_CLAIMS = 20
SUFFICIENT_AS_WRITTEN = 24
SUFFICIENT_WITH_MANDATORY_QUALIFIER = 16
CLAIMS_REQUIRING_REMOVAL = 0
CLAIM_TO_SECTION_MAP_STATUS = PASS_COMPLETE_40
CLAIM_TO_EVIDENCE_MAP_STATUS = PASS_COMPLETE_40

MANDATORY_QUALIFIER_CLAIM_COUNT = 16
MANDATORY_QUALIFIER_CLAIMS = R-02,R-03,R-04,R-08,R-09,R-10,R-11,D-01,D-02,D-04,D-05,D-06,D-07,D-08,C-02,C-04
QUALIFIER_LOCK_STATUS = PASS_LOCKED
QUALIFIER_INSERTION = MANDATORY
QUALIFIER_OMISSION_CLASS = EDITORIAL_SCIENTIFIC_SCOPE_VIOLATION

TABLE_FIGURE_EVIDENCE_MAP_STATUS = PASS_COMPLETE
MINIMUM_MANUSCRIPT_EVIDENCE_PACKAGE_STATUS = PASS_DEFINED
MANUSCRIPT_READY_TABLE_EXISTS = NO
MANUSCRIPT_READY_FIGURE_EXISTS = NO
CR1_COMP_09_FIGURE_F3_NOMENCLATURE = REQUIRES_EDITORIAL_RECONCILIATION_BEFORE_USE

PROHIBITED_CLAIM_REGISTRY_STATUS = PASS_COMPLETE_14
PROHIBITED_CLAIMS = TRUE_PARETO_FRONT,GLOBAL_PARETO_FRONT,GLOBAL_OPTIMALITY,CONVERGENCE_ESTABLISHED,BETWEEN_SEED_ROBUSTNESS,EXPECTED_GAMULTIOBJ_PERFORMANCE,STATISTICAL_SUPERIORITY,CORRECTED_R1_GLOBALLY_SUPERIOR,H_AS_CORRECTED_PARETO_FRONT,F2_AS_TOTAL_ECONOMIC_COST,F3_AS_LIFE_CYCLE_IMPACT,C_IRRADIACION_CAUSAL_ATTRIBUTION,C_COMPONENT_LEVEL_CO2_ATTRIBUTION,UNIQUE_C_REGION_CAUSAL_MECHANISM

READY_FOR_MANUSCRIPT_READY_GATE = YES
MANUSCRIPT_READY = NOT_EVALUATED
FINAL_MANUSCRIPT_EDITED = NO
LITERATURE_POSITIONING = NOT_EVALUATED_SEPARATE_GATE
NOVELTY_POSITIONING = NOT_EVALUATED_SEPARATE_GATE

ONE_CORRECTED_R1_RUN = YES
CONVERGENCE_ESTABLISHED = NO
BETWEEN_SEED_ROBUSTNESS_ESTABLISHED = NO
GLOBAL_OPTIMALITY_ESTABLISHED = NO
IRRADIACION_NOT_AVAILABLE = YES
C_CO2_COMPONENTS_NOT_PERSISTED = YES
COMMON_TMAX_19P9H = FIXED_HORIZON_LIMITATION

D016_STALE_FREEZE_LABEL_CORRECTED = YES
CORRECTION_TYPE = DOCUMENTARY_STATE_RECONCILIATION_ONLY
```

D017 freezes the read-only editorial-preparation result without changing the objective, computational values, protocol, comparative phases, manuscript, figures, or productive code. The manuscript display basis for `f3` is operational `kg CO2e/kg water removed` with the mandatory boundary qualifier above. Readiness to open a later gate is not a finding that the manuscript itself is ready.

**Estado:** VIGENTE.

## D018 — Conditional manuscript readiness and controlled editorial blueprint

```text
D018_STATUS = VIGENTE
D018_FREEZE_ROLE = FROZEN_BY_THIS_CANONICAL_COMMIT
DECISION_SCOPE = MANUSCRIPT_READY_GATE
SOURCE_GATE = MANUSCRIPT_READY_GATE
SOURCE_GATE_STATUS = PASS
MANUSCRIPT_READY = CONDITIONAL
INTERNAL_MANUSCRIPT_SCIENTIFIC_READINESS = CONDITIONAL_PASS_FOR_CONTROLLED_EDITORIAL_PHASE
CONTROLLED_EDITORIAL_PHASE_ALLOWED = YES_AFTER_SEPARATE_AUTHORIZATION
FINAL_MANUSCRIPT_EDITED = NO
NEW_SCIENTIFIC_RESULT = NO
PROTOCOL_V1_MODIFIED = NO
CR1_COMP_01_TO_16_REOPENED = NO
SCIENTIFIC_RECOMPUTATION_REQUIRED = NO

CANONICAL_MANUSCRIPT_SOURCE_STATUS = UNAMBIGUOUS
CANONICAL_MANUSCRIPT_SOURCE = 06_manuscript/article_Q1/draft_sections/MASTER_manuscript_v01.md
MANUSCRIPT_CANDIDATE_COUNT = 41
MANUSCRIPT_STRUCTURE_STATUS = INCOMPLETE

TITLE = STALE
ABSTRACT = REQUIRES_REWRITE
KEYWORDS = PARTIAL_NEEDS_EDITORIAL_REVISION
INTRODUCTION = STALE
SYSTEM_DESCRIPTION = PARTIAL
MATHEMATICAL_MODEL = STALE
METHODS = PARTIAL
RESULTS = STALE
DISCUSSION = STALE
LIMITATIONS = PARTIAL_STALE
CONCLUSIONS = STALE
NOMENCLATURE = STALE
REFERENCES = PARTIAL
SUPPLEMENT = PARTIAL
INTERNAL_TRACEABILITY_LOG = STALE_NONPUBLIC_REMOVE_OR_RELOCATE

METHODS_ALIGNMENT_STATUS = PASS_WITH_REQUIRED_EDITS
METHODS_CRITICAL_CONTRADICTION_COUNT = 0
METHODS_MANDATORY_CORRECTION_COUNT = 10
METHODS_MISSING_ITEM_COUNT = 9
METHODS_NEW_SCIENCE_REQUIRED = NO
METHODS_CORRECTIONS_DETERMINISTIC_FROM_D016_D017 = YES
METHODS_ALREADY_ALIGNED = D10_CORRECTED_RUN_CONFIGURATION;D11_MAXGENERATIONS_STOPPING_INTERPRETATION;D22_OPTIMIZER_INFERENCE_LIMITATIONS
MANDATORY_SCIENTIFIC_CORRECTION_01 = f1 = MR_final; dimensionless; minimized
MANDATORY_SCIENTIFIC_CORRECTION_02 = f2 = modeled specific operating-energy cost; USD/kg water removed
MANDATORY_SCIENTIFIC_CORRECTION_03 = f3 = modeled specific operational greenhouse-gas emissions; kg CO2e/kg water removed
MANDATORY_SCIENTIFIC_CORRECTION_04 = LPG factor = 3.00 kg CO2/kg LPG
MANDATORY_SCIENTIFIC_CORRECTION_05 = grid factor = 0.444 kg CO2e/kWh
MANDATORY_SCIENTIFIC_CORRECTION_06 = Q_aux_tot = MJ
MANDATORY_SCIENTIFIC_CORRECTION_07 = design variables and units = m_max_kg_per_s;T_min_degC;r_div2_dimensionless;t_rec_ini_h
MANDATORY_SCIENTIFIC_CORRECTION_08 = H provenance = historical solutions reevaluated, not reoptimized, under corrected COST-E3D
MANDATORY_SCIENTIFIC_CORRECTION_09 = C provenance = finite nondominated approximation / audited finite set
MANDATORY_SCIENTIFIC_CORRECTION_10 = exact dominance;diagnostic near-tie;ddof0/type7;asymmetric coverage;joint finite sorting;anchored HV r5/r10/r20;COMMON_TMAX_19P9H
MANDATORY_SCIENTIFIC_CORRECTION_11 = modeled operating-energy economic boundary and modeled operational-emissions environmental boundary
MANDATORY_SCIENTIFIC_CORRECTION_12 = Irradiacion unavailable and C component-level emissions not persisted

STALE_PRE_COST_E3D_F2F3_OCCURRENCE_COUNT = 2
STALE_ENVIRONMENTAL_FACTORS = 0.2270_kgCO2_per_kWh;0.4380_kgCO2_per_kWh
CANONICAL_ENVIRONMENTAL_FACTORS = LPG_3.00_kg_CO2_per_kg_LPG;GRID_0.444_kg_CO2e_per_kWh
Q_AUX_LEGACY_KWH_STATUS = STALE_REPLACE_WITH_MJ
R1_SOLUTION_7_H2_OLD_NARRATIVE_STATUS = STALE_REPLACE_AS_MAIN_COMPARATIVE_THESIS

TOTAL_CLAIMS = 40
CONCRETE_CLAIM_INSERTION_MAP_COUNT = 40
RESULTS_CLAIMS_MAPPED = 11
DISCUSSION_CLAIMS_MAPPED = 11
LIMITATIONS_MAPPED = 11
CONCLUSIONS_CLAIMS_MAPPED = 7
CLAIM_INSERTION_BLUEPRINT_STATUS = PASS_COMPLETE_40
CLAIM_REGISTRY = 06_manuscript/article_Q1/review/CR1_COMP_16_MANUSCRIPT_CLAIM_REGISTRY_v96z.csv

MANDATORY_QUALIFIER_CLAIM_COUNT = 16
QUALIFIER_CONCRETE_MAP_COUNT = 16
QUALIFIER_LOCK_STATUS = PASS_LOCKED
QUALIFIER_PLACEMENT_BLUEPRINT_STATUS = PASS_COMPLETE_16
MANDATORY_QUALIFIER_CLAIMS = R-02,R-03,R-04,R-08,R-09,R-10,R-11,D-01,D-02,D-04,D-05,D-06,D-07,D-08,C-02,C-04
QUALIFIER_OMISSION = EDITORIAL_SCIENTIFIC_SCOPE_VIOLATION

MINIMUM_MAIN_TABLE_COUNT = 2
MINIMUM_SUPPLEMENT_TABLE_COUNT = 4
MAIN_TABLE_T1_SOURCES = CR1-COMP-04;CR1-COMP-09;CR1-COMP-11;CR1-COMP-14
MAIN_TABLE_T1_ROLE = objective medians/ranges;geometry/extrema;hypervolume;representative interpretation
MAIN_TABLE_T2_SOURCES = CR1-COMP-05;CR1-COMP-06;CR1-COMP-07;CR1-COMP-08
MAIN_TABLE_T2_ROLE = cross-dominance;incomparability;coverage;joint Rank1;near-tie context
SUPPLEMENT_TABLE_S1_SOURCE = CR1-COMP-03
SUPPLEMENT_TABLE_S1_ROLE = decision-space descriptors
SUPPLEMENT_TABLE_S2_SOURCES = CR1-COMP-05...08
SUPPLEMENT_TABLE_S2_ROLE = full finite-set dominance and rank support
SUPPLEMENT_TABLE_S3_SOURCE = CR1-COMP-11
SUPPLEMENT_TABLE_S3_ROLE = HV anchors and normalized support
SUPPLEMENT_TABLE_S4_SOURCES = CR1-COMP-12;CR1-COMP-13;CR1-COMP-14
SUPPLEMENT_TABLE_S4_ROLE = terminal regime;objective decomposition;representative evidence
TABLE_CONVERSION_STATUS = REQUIRED_NOT_EXECUTED
OLD_R1_H2_ETA_TABLES_AS_PRIMARY_COMPARATIVE_EVIDENCE = PROHIBITED

MINIMUM_MAIN_FIGURE_COUNT = 1
MINIMUM_SUPPLEMENT_FIGURE_COUNT = 3
MAIN_FIGURE = CR1_COMP_09_F1_F2_F3_3D_v96z.png
SUPPLEMENT_FIGURES = CR1_COMP_09_F1_F2_v96z.png;CR1_COMP_09_F1_F3_v96z.png;CR1_COMP_09_F2_F3_v96z.png
FIGURE_CONVERSION_STATUS = REQUIRED_NOT_EXECUTED
LEGACY_F3_FIGURE_RELABELING_REQUIRED = YES
LEGACY_F3_FIGURE_COUNT = 3
REQUIRED_F3_DISPLAY = modeled specific operational greenhouse-gas emissions (kg CO2e/kg water removed)

MINIMUM_MANUSCRIPT_EVIDENCE_PACKAGE_STATUS = PASS_READY_AFTER_EDITORIAL_CONVERSION
MINIMUM_EVIDENCE_COMPONENTS = decision-space description;objective-space descriptive comparison;cross-dominance and incomparability;coverage;joint Rank1;objective-space geometry;hypervolume r5/r10/r20;common terminal regime;objective decomposition and representative interpretation;quantitative comparative verdict
SCIENTIFIC_SOURCE_MISSING_COUNT = 0
CANONICAL_DISCREPANCY_COUNT = 0
UNRESOLVED_EDITORIAL_DECISION_COUNT = 0
OPEN_SCIENTIFIC_ISSUES = 0_WITHIN_CURRENT_FROZEN_LIMITED_SCOPE

LIMITATION_PLACEMENT_COUNT = 11
LIMITATIONS_BLUEPRINT = L-01_ONE_CORRECTED_RUN;L-02_MAXGENERATIONS_NOT_CONVERGENCE;L-03_NO_TRUE_GLOBAL_FRONT;L-04_H_C_NOT_INDEPENDENT_REPLICATES;L-05_FIXED_COMMON_TMAX_19P9H;L-06_IRRADIACION_UNAVAILABLE;L-07_C_EMISSION_COMPONENTS_NOT_PERSISTED;L-08_ECONOMIC_BOUNDARY;L-09_ENVIRONMENTAL_LCA_BOUNDARY;L-10_CO2_CO2E_RECONCILIATION;L-11_HISTORICAL_H_PROVENANCE

PROHIBITED_POSITIVE_CLAIM_VIOLATION_COUNT = 0
PROHIBITED_CLAIM_REGISTRY_STATUS = PASS_COMPLETE_14
PROHIBITED_CLAIMS = TRUE_PARETO_FRONT;GLOBAL_PARETO_FRONT;GLOBAL_OPTIMALITY;CONVERGENCE_ESTABLISHED;BETWEEN_SEED_ROBUSTNESS;EXPECTED_GAMULTIOBJ_PERFORMANCE;STATISTICAL_SUPERIORITY;CORRECTED_R1_GLOBALLY_SUPERIOR;H_AS_CORRECTED_PARETO_FRONT;F2_AS_TOTAL_ECONOMIC_COST;F3_AS_LIFE_CYCLE_IMPACT;C_IRRADIACION_CAUSAL_ATTRIBUTION;C_COMPONENT_LEVEL_CO2_ATTRIBUTION;UNIQUE_C_REGION_CAUSAL_MECHANISM
LEGACY_TABLE_LABEL_ISSUE_COUNT = 3
LEGACY_FIGURE_LABEL_ISSUE_COUNT = 3
LEGACY_CAPTION_ISSUE_COUNT = 1
LEGACY_ISSUES_CLASS = DETERMINISTIC_EDITORIAL_CORRECTIONS
LEGACY_ISSUES_ARE_NEW_SCIENTIFIC_BLOCKERS = NO

EDIT_CLASS_1_COUNT = 12
EDIT_CLASS_2_COUNT = 16
EDIT_CLASS_3_COUNT = 11
EDIT_CLASS_4_COUNT = 11
EDIT_CLASS_5_COUNT = 11
EDIT_CLASS_6_COUNT = 7
EDIT_CLASS_7_COUNT = 19
EDIT_CLASS_8_COUNT = 6
EDIT_CLASS_9_COUNT = 4
EDIT_CLASS_10_COUNT = 60
EDIT_CLASS_COUNTS_MAY_OVERLAP = YES_EDITORIAL_UNITS_NOT_FILE_COUNTS

MANUSCRIPT_READY_CONDITION_COUNT = 10
MANUSCRIPT_READY_CONDITION_01 = Replace pre-COST-E3D narrative in Abstract, Introduction, Results, Discussion, Limitations and Conclusions.
MANUSCRIPT_READY_CONDITION_02 = Complete the 19 Methods items not currently aligned.
MANUSCRIPT_READY_CONDITION_03 = Insert all 40 claims at their mapped anchors.
MANUSCRIPT_READY_CONDITION_04 = Insert/preserve all 16 locked qualifiers.
MANUSCRIPT_READY_CONDITION_05 = Reconcile manuscript f3 display to modeled specific operational greenhouse-gas emissions in kg CO2e/kg water removed while preserving legacy computational naming only when technically required.
MANUSCRIPT_READY_CONDITION_06 = Correct Q_aux_tot to MJ and environmental factors to 3.00 / 0.444 under D017.
MANUSCRIPT_READY_CONDITION_07 = Convert the selected six tables and four figures; relabel the three f3 figures.
MANUSCRIPT_READY_CONDITION_08 = Remove/replace R1/H2/eta-sensitivity tables, captions and results as the primary manuscript thesis.
MANUSCRIPT_READY_CONDITION_09 = Perform structural housekeeping and remove/relocate the internal traceability log from the publishable body.
MANUSCRIPT_READY_CONDITION_10 = Preserve finite-set, single-run, MaxGenerations, COMMON_TMAX, Irradiacion and C-emission-component limitations.
MANUSCRIPT_READY_BLOCKERS = NONE_FOR_CONTROLLED_EDITORIAL_PHASE

SUBMISSION_READY = NOT_EVALUATED
LITERATURE_POSITIONING = NOT_EVALUATED_SEPARATE_GATE
NOVELTY_POSITIONING = NOT_EVALUATED_SEPARATE_GATE
JOURNAL_POSITIONING_READY = NOT_EVALUATED
```

`MASTER_manuscript_v01.md` is the current master source. Files marked `BACKUP` or `BEFORE` are historical snapshots, and files under `preliminary_review` are frozen review exports; none is to be edited as the primary source. D018 records the read-only gate result and the deterministic controlled-editorial blueprint. It does not execute the editorial phase, alter the manuscript, convert evidence, reopen scientific computation, or evaluate literature, novelty, journal positioning, or submission readiness.

**Estado:** VIGENTE.
