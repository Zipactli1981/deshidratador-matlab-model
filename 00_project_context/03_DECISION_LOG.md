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
La corrida quedó internamente validada y, en ese momento, la interpretación científica permanecía pendiente de revisión comparativa.

**Estado:** SUPERSEDED_BY_COMPLETED_COMPARATIVE_REVIEW.

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

## D016 — Suficiencia científica del paquete de claims

**Decisión:** el paquete actual de afirmaciones del manuscrito es científicamente suficiente para el alcance finito congelado, siempre que se mantengan los calificadores obligatorios.

```text
D016 = FROZEN_PASS
CURRENT_MANUSCRIPT_CLAIM_PACKAGE = SCIENTIFICALLY_SUFFICIENT_WITH_FROZEN_SCOPE_AND_MANDATORY_QUALIFIERS
TOTAL_MANUSCRIPT_CANDIDATE_CLAIMS = 40
SUFFICIENT_AS_WRITTEN = 24
SUFFICIENT_WITH_MANDATORY_QUALIFIER = 16
CLAIMS_REQUIRING_REMOVAL = 0
BLOCKING_CORE_CLAIMS = NONE
MULTISEED_REQUIRED_FOR_CURRENT_FINITE_SET_CLAIMS = NO
MULTISEED_REQUIRED_FOR_OPTIMIZER_ROBUSTNESS_CLAIMS = YES
```

**Estado:** vigente.

## D017 — Reconciliación CO2 / CO2e y bloqueo de calificadores

**Decisión:** adoptar la reconciliación editorial `PASS_OPTION_B`.

Se conserva el nombre computacional:

```text
CO2_specific_kgCO2_per_kgwater
```

Para manuscrito se utilizará:

```text
modeled specific operational greenhouse-gas emissions
unit = kg CO2e/kg water removed
```

Alcance: CO2 directo de combustión de GLP + CO2e indirecto de electricidad de red, normalizado por agua removida.

Calificador obligatorio: no es huella de ciclo de vida, inventario GHG completo ni impacto ambiental total.

```text
D017 = FROZEN_PASS
CO2_CO2E_RECONCILIATION_STATUS = PASS_OPTION_B
LPG_FACTOR = 3.00 kg CO2/kg LPG
GRID_FACTOR = 0.444 kg CO2e/kWh
Q_aux_tot = MJ
NOMENCLATURE_AUDIT = PASS
UNIT_AUDIT = PASS
MANDATORY_QUALIFIER_CLAIM_COUNT = 16
QUALIFIER_LOCK_STATUS = PASS_LOCKED
```

**Estado:** vigente.

## D018 — Manuscript-ready gate

**Decisión:** la evidencia científica y documental es suficiente para permitir una fase editorial controlada posterior, pero el manuscrito aún requiere reescritura determinista y esa edición necesita autorización separada.

```text
D018 = FROZEN_PASS
MANUSCRIPT_READY_GATE_STATUS = PASS
MANUSCRIPT_READY = CONDITIONAL
CANONICAL_MANUSCRIPT_SOURCE = 06_manuscript/article_Q1/draft_sections/MASTER_manuscript_v01.md
CANONICAL_MANUSCRIPT_SOURCE_STATUS = UNAMBIGUOUS
SCIENTIFIC_SOURCE_MISSING_COUNT = 0
CANONICAL_DISCREPANCY_COUNT = 0
UNRESOLVED_EDITORIAL_DECISION_COUNT = 0
CONTROLLED_EDITORIAL_PHASE_ALLOWED = YES_AFTER_SEPARATE_AUTHORIZATION
MANUSCRIPT_FILES_MODIFIED = NO
```

**Estado:** vigente.

## D019 — Arquitectura narrativa científica

**Decisión:** adoptar arquitectura `A` con posicionamiento `SYSTEM_FIRST`. El protagonista científico es el secador híbrido solar–GLP y sus compromisos operativos; `gamultiobj` actúa como instrumento de búsqueda y configuración reproducible, no como contribución de desempeño algorítmico.

```text
D019 = FROZEN_PASS
SCIENTIFIC_NARRATIVE_GATE_STATUS = PASS
RECOMMENDED_MANUSCRIPT_ARCHITECTURE = A
RECOMMENDED_POSITIONING = SYSTEM_FIRST
SYSTEM_PROTAGONIST = HYBRID_SOLAR_LPG_DRYER_AND_OPERATIONAL_TRADEOFFS
METHOD_PROTAGONIST = NO
GAMULTIOBJ_PRIMARY_ROLE = SEARCH_INSTRUMENT_FOR_GENERATING_MULTI_OBJECTIVE_CANDIDATES
GAMULTIOBJ_SECONDARY_ROLE = TRACEABLE_REPRODUCIBLE_SEARCH_CONFIGURATION
ALGORITHM_PERFORMANCE_CLAIMS_SUPPORTED = NO
PRIMARY_RESEARCH_QUESTION_STATUS = SUPPORTED
SECONDARY_RESEARCH_QUESTION_STATUS = SUPPORTED
PRIMARY_HYPOTHESIS_SUPPORT_STATUS = SUPPORTED
MANUSCRIPT_THESIS_STATUS = SUPPORTED
FINITE_SET_SCOPE = CONSTITUTIVE_NOT_OPTIONAL_DISCLAIMER
```

Contribución primaria:

```text
FINITE_SET_PHYSICAL_AND_MULTIOBJECTIVE_CHARACTERIZATION_OF_OPERATIONAL_TRADEOFFS
```

Contribuciones secundarias:

```text
CORRECTED_FORMULATION_H_VS_C_COMPARISON
INTEGRATED_TRIOBJECTIVE_OPERATIONAL_FORMULATION
```

Los dos knowledge gaps definidos en D019 son candidatos internos y permanecen pendientes de verificación bibliográfica externa:

```text
AT_D019_CANDIDATE_KNOWLEDGE_GAPS = PENDING_EXTERNAL_VERIFICATION
AT_D019_NOVELTY_ESTABLISHED = NO
```

La condición bibliográfica anterior fue posteriormente resuelta por D020. D019 permanece vigente para arquitectura narrativa y `SYSTEM_FIRST`; D020 prevalece para posicionamiento bibliográfico y clasificación de novedad.

**Estado:** vigente, con estado de literatura supersedido por D020.

### Nota de trazabilidad D012–D015

Este micropaso no reconstruye ni inventa entradas D012–D015 porque sus textos canónicos individuales no forman parte del paquete de evidencia disponible en esta conversación. El handoff D019 sí registra que `CR1-COMP-01...16 = CLOSED_PASS`; esa condición se conserva en `01_CURRENT_STATE.md` y `05_PHASE_HANDOFF_CURRENT.md` sin fabricar decisiones faltantes.

## D020 — Literature positioning and novelty verification

**Decisión:** cerrar el gate bibliográfico con estrechamiento explícito de la novedad. La literatura externa invalida como claims de novedad independientes el uso de solar–LPG, GA/NSGA-II, optimización multiobjetivo genérica y el estudio aislado de temperatura/flujo/recirculación.

Se adopta:

```text
D020 = FROZEN_PASS
LITERATURE_POSITIONING_GATE = FROZEN_PASS_WITH_NOVELTY_NARROWING
CANDIDATE_KNOWLEDGE_GAP_1 = PARTIALLY_VERIFIED_GAP
CANDIDATE_KNOWLEDGE_GAP_2 = PARTIALLY_VERIFIED_GAP
DEFENSIBLE_NOVELTY_POSITIONING = YES_WITH_LIMITATIONS
UNIVERSAL_PRIORITY_ESTABLISHED = NO
```

Clasificación vigente:

```text
INTEGRATED_TRIOBJECTIVE_OPERATIONAL_FORMULATION = INCREMENTAL_NOVELTY
COUPLED_THERMAL_AIR_MANAGEMENT_FINITE_SET_CHARACTERIZATION = INCREMENTAL_NOVELTY
HISTORICAL_SOLUTION_SURVIVAL_AFTER_CORRECTED_REFORMULATION = STRONG_NOVELTY_CANDIDATE
OVERALL_PAPER_A_POSITIONING = INCREMENTAL_NOVELTY_WITH_STRONG_NARROW_SUBCONTRIBUTION
GAMULTIOBJ_OR_GA_AS_NOVELTY = METHOD_APPLICATION_ONLY
SOLAR_LPG_AS_NOVELTY = NOT_NOVEL
MULTIOBJECTIVE_OPTIMIZATION_AS_NOVELTY = NOT_NOVEL
UNIVERSAL_FIRST_OF_ITS_KIND_CLAIM = NOT_SUPPORTED
```

Regla obligatoria para Gap 2:

```text
NO_DIRECT_PRECEDENT_IDENTIFIED != UNIVERSAL_ABSENCE_PROVED
```

D020 no modifica el protocolo H-vs-C, no cambia resultados D016–D019 y preserva `SYSTEM_FIRST` y `FINITE_SET_SCOPE = CONSTITUTIVE_NOT_OPTIONAL_DISCLAIMER`.

Artefactos del freeze local:

```text
LITERATURE_POSITIONING_GATE_v01.md
SHA256 = 3114FDC9A6188C450D499B424D147DB4B6BC3077E424CD8D0BAEA23DA7C3F83F

LITERATURE_POSITIONING_EVIDENCE_MATRIX_v01.csv
SHA256 = E68DB197170910D17A02046830BEC0A1469181DD22AFF3B5829D51774268E5A2
```

**Estado:** vigente.
