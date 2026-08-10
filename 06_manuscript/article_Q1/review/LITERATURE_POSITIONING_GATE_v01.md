# LITERATURE POSITIONING GATE v01
## D020 — Literature positioning and novelty verification

**Project:** Deshidratador MATLAB / artículo Q1  
**Date:** 2026-08-09  
**Status:** `FROZEN_PASS_WITH_NOVELTY_NARROWING`  
**Documentary freeze:** `PASS_LOCAL_NOT_GIT_FROZEN`  
**Manuscript editing:** `NOT_EXECUTED`  
**MATLAB / gamultiobj / optimization:** `NOT_EXECUTED`  
**Git staging / commit / push:** `NOT_EXECUTED`

---

## 1. Purpose

Freeze the literature-positioning gate that follows D019 and determine, with explicit separation between external literature evidence and project-specific results:

1. whether candidate knowledge gap 1 remains open;
2. whether candidate knowledge gap 2 remains open;
3. which elements are already well covered by prior literature;
4. which elements remain insufficiently integrated or directly studied;
5. how the tri-objective formulation should be positioned;
6. how coupled thermal and air-management decisions should be positioned;
7. whether a direct precedent was identified for historical-solution survival after corrected cost–emissions reformulation;
8. which literature supports the physical interpretation;
9. which references should anchor Introduction, Methods and Discussion;
10. which novelty statement is defensible without universal-priority overclaiming.

The gate distinguishes throughout:

```text
LITERATURE_EVIDENCE
PROJECT_RESULT
INFERENCE
NOVELTY_CLAIM
```

---

## 2. Search scope and limitation

The literature search used multiple query families covering:

- hybrid solar dryers;
- solar-LPG / solar-LP-gas / solar-gas drying;
- multi-objective optimization of dryers;
- genetic algorithms / NSGA-II in drying;
- drying + energy + cost optimization;
- drying + emissions / carbon optimization;
- air recirculation optimization;
- temperature-airflow trade-offs;
- specific energy per water removed;
- operational emissions per water removed;
- multiobjective techno-economic-environmental drying;
- historical solutions, reevaluation, model correction and reoptimization.

Search date: `2026-08-09`.

This was a targeted scientific positioning search with repeated formulations and source triangulation. It is **not** a PRISMA systematic review, bibliometric census, Scopus/Web of Science exhaustive query, or proof of universal absence.

Therefore:

```text
UNIVERSAL_PRIORITY_ESTABLISHED = NO
ABSENCE_OF_PRECEDENT_PROVED = NO
DEFENSIBLE_POSITIONING_ESTABLISHED = YES_WITH_LIMITATIONS
```

---

## 3. Frozen verdict

```text
LITERATURE_POSITIONING_GATE = FROZEN_PASS_WITH_NOVELTY_NARROWING

CANDIDATE_KNOWLEDGE_GAP_1 = PARTIALLY_VERIFIED_GAP
CANDIDATE_KNOWLEDGE_GAP_2 = PARTIALLY_VERIFIED_GAP

INTEGRATED_TRIOBJECTIVE_FORMULATION = INCREMENTAL_NOVELTY
COUPLED_TEMPERATURE_AIRFLOW_RECIRCULATION_CHARACTERIZATION = INCREMENTAL_NOVELTY
GAMULTIOBJ_OR_GA_AS_NOVELTY = METHOD_APPLICATION_ONLY
SOLAR_LPG_AS_NOVELTY = NOT_NOVEL
MULTIOBJECTIVE_OPTIMIZATION_AS_NOVELTY = NOT_NOVEL

HISTORICAL_SOLUTION_SURVIVAL_AFTER_CORRECTED_REFORMULATION = STRONG_NOVELTY_CANDIDATE

OVERALL_PAPER_A_POSITIONING = INCREMENTAL_NOVELTY_WITH_STRONG_NARROW_SUBCONTRIBUTION
PHYSICAL_INTERPRETATION_LITERATURE_SUPPORT = PASS_WITH_CAUSALITY_LIMITATION
UNIVERSAL_FIRST_OF_ITS_KIND_CLAIM = NOT_SUPPORTED
```

---

## 4. Evidence matrix

| ID | Literature evidence | What it establishes | Relevance to project | Gate implication |
|---|---|---|---|---|
| E01 | Pereira, Joardder & Karim (2026), *Food Engineering Reviews*, DOI `10.1007/s12393-026-09446-9` | Current hybrid-drying literature remains fragmented; temperature, airflow, humidity and other operating conditions jointly affect drying time, SEC, cost and CO2 metrics; moisture-removal-normalized SEC is standard and CO2 can be expressed per kg H2O evaporated with boundary-sensitive emission factors. | Strong support for integrated trade-off framing and moisture-removal normalization; also supports strict boundary qualification for f3. | Gap 1 can be retained only as an integration gap, not as absence of prior work on individual variables or sustainability metrics. |
| E02 | Murali et al. (2020), *Renewable Energy* 147, 2417–2428, DOI `10.1016/j.renene.2019.10.002` | A solar-LPG hybrid dryer for shrimp drying was designed and experimentally evaluated. | Direct precedent for solar-LPG hybrid drying. | `SOLAR_LPG_AS_NOVELTY = NOT_NOVEL`. |
| E03 | Ortiz-Rodríguez et al. (2020), *Applied Thermal Engineering* 177, 115496, DOI `10.1016/j.applthermaleng.2020.115496` | Industrial solar-LP-gas food dehydration plant; thermal/energy analysis and economic comparison with conventional LP-gas drying. | Direct precedent for industrial solar-LP-gas drying plus economic analysis. | Solar-LPG + economics cannot be claimed as new in itself. |
| E04 | César-Munguía et al. (2023), *Applied Thermal Engineering* 225, 120171, DOI `10.1016/j.applthermaleng.2023.120171` | Experimental hybrid thermosolar-LPG dehydration plant with multiple operating modes and economic assessment. | Confirms continued development of solar-LPG systems. | Reinforces incremental rather than platform-level novelty. |
| E05 | Khater et al. (2024), *Scientific Reports* 14, 23922, DOI `10.1038/s41598-024-74751-4` | LPG hybrid solar dryer with controlled air circulation; experiments at 50/55/60 °C and multiple air-changing rates; higher temperature and air change affected drying kinetics. | Directly relevant to `T_min` and air-management interpretation. | Coupled temperature/air-management effects already have direct solar-LPG precedent. |
| E06 | Winiczenko et al. (2018), *Computers and Electronics in Agriculture* 145, 341–348, DOI `10.1016/j.compag.2018.01.006` | Multi-objective drying optimization using ANN + GA + NSGA-II with drying temperature and air velocity as decision variables. | Direct precedent for GA/NSGA-II and coupled thermal-air decisions in drying. | GA/NSGA-II and temperature-airflow MOO are not novelty claims. |
| E07 | El Ferouali et al. (2018), 21st International Drying Symposium, DOI `10.4995/IDS2018.2018.7521` | Hybrid solar-gas-electric dryer optimized with genetic algorithms. | Very close methodological/system precedent. | `GAMULTIOBJ_OR_GA_AS_NOVELTY = METHOD_APPLICATION_ONLY`. |
| E08 | Oviedo, Barán & Galeano (2021), *CLEI Electronic Journal* 24(2), DOI `10.19153/cleiej.24.2.1` | Three-objective NSGA-II dryer optimization: outlet moisture, heat released to environment and operating cost. | Shows tri-objective dryer optimization integrating drying and operating-cost/environment-related objectives. | Generic tri-objective dryer optimization is not novel; project novelty must be formulation/system specific. |
| E09 | Zhang et al. (2022), *Journal of Cleaner Production* 369, 133353, DOI `10.1016/j.jclepro.2022.133353` | Multi-objective spray-drying framework simultaneously considering environmental impact, life-cycle cost and product quality. | Strong precedent for integrated environment-economy-performance/quality optimization in drying. | Broad “first economic-environmental multiobjective dryer optimization” claim is prohibited. |
| E10 | Afzali, Darvishi & Behroozi-Khazaei (2019), *Applied Thermal Engineering* 154, 358–367, DOI `10.1016/j.applthermaleng.2019.03.096` | Air recirculation, drying temperature and heating power interact; drying time decreased with recirculation up to a point and then increased, while exergy efficiency improved. | Supports non-monotonic and coupled interpretation of recirculation. | Physical interpretation is supportable only as association/compatibility, not unique causation. |
| E11 | Zohrabi et al. (2020), *Journal of Cleaner Production* 257, 120394, DOI `10.1016/j.jclepro.2020.120394` | Exhaust-air recirculation control can substantially reduce energy needs; recirculation decisions depend on thermodynamic state. | Reinforces that air-management strategy affects energy performance and should not be isolated from other state variables. | Supports system-level coupled interpretation. |
| E12 | Targeted searches for drying + corrected objective/model + historical-candidate reevaluation + reoptimization did not identify a direct drying precedent matching the H-vs-C workflow. General optimization literature exists on historical information and dynamic/model-correction settings, but it is not equivalent to the project comparison. | No direct analogue was identified for preserving historical decision vectors, reevaluating them under a corrected cost–emissions formulation, directly reoptimizing that corrected formulation, and quantifying historical survival with exact finite-set dominance/coverage/rank/HV. | This is the most distinctive project-specific contribution located in the search. | `STRONG_NOVELTY_CANDIDATE`, but universal absence is not established. |

---

## 5. Refined knowledge gap 1

### Prior candidate

Insufficient quantitative understanding may remain regarding how coupled thermal and air-management decisions redistribute drying, operating-energy-cost and operational-emissions trade-offs in hybrid solar–LPG drying systems.

### Frozen refined form

> Although hybrid solar–LPG drying, thermal and airflow effects, and multiobjective drying optimization have each been investigated, limited evidence is available on the integrated finite-set characterization of how coupled thermal and air-management decisions redistribute drying-performance, modeled specific operating-energy-cost, and modeled specific operational greenhouse-gas-emission trade-offs in solar–LPG drying systems.

Classification:

```text
CANDIDATE_KNOWLEDGE_GAP_1 = PARTIALLY_VERIFIED_GAP
```

Rationale:

- solar-LPG drying exists (E02–E05);
- thermal/airflow effects exist (E05, E06, E10, E11);
- multiobjective drying optimization exists (E06–E09);
- economic/environmental integration exists in drying (E08, E09);
- the defensible gap is therefore the **specific integrated finite-set characterization** for the project system, objective definitions and coupled decisions, not absence of the component literatures.

---

## 6. Refined knowledge gap 2

### Prior candidate

It remains to be established how much design information from historical candidates survives comparison with candidates generated directly under a corrected cost–emissions formulation.

### Frozen refined form

> Within the drying literature identified in the present targeted search, no direct precedent was identified for explicitly preserving a historical candidate set, reevaluating those same decision vectors under a corrected cost–emissions formulation, and then quantifying which historical trade-offs remain competitive relative to candidates generated directly under that corrected formulation.

Classification:

```text
CANDIDATE_KNOWLEDGE_GAP_2 = PARTIALLY_VERIFIED_GAP
HISTORICAL_SOLUTION_SURVIVAL_AFTER_CORRECTED_REFORMULATION = STRONG_NOVELTY_CANDIDATE
```

Mandatory limitation:

```text
NO_DIRECT_PRECEDENT_IDENTIFIED != UNIVERSAL_ABSENCE_PROVED
```

This claim is bounded to the literature located by the targeted search and must not be rewritten as “the first study ever” without a separate systematic priority review.

---

## 7. Frozen novelty classification

### Not novel as standalone contributions

```text
HYBRID_SOLAR_LPG_DRYER = NOT_NOVEL
GENETIC_ALGORITHM_IN_DRYING = NOT_NOVEL
NSGA_II_OR_MULTI_OBJECTIVE_EVOLUTIONARY_OPTIMIZATION_IN_DRYING = NOT_NOVEL
TEMPERATURE_AIRFLOW_OPTIMIZATION_IN_DRYING = NOT_NOVEL
AIR_RECIRCULATION_ANALYSIS_IN_DRYING = NOT_NOVEL
GENERIC_ECONOMIC_ENVIRONMENTAL_MULTI_OBJECTIVE_DRYING = NOT_NOVEL
```

### Project-specific contribution positioning

```text
INTEGRATED_TRIOBJECTIVE_OPERATIONAL_FORMULATION = INCREMENTAL_NOVELTY
COUPLED_THERMAL_AIR_MANAGEMENT_FINITE_SET_CHARACTERIZATION = INCREMENTAL_NOVELTY
CORRECTED_FORMULATION_H_VS_C_COMPARISON = STRONG_NOVELTY_CANDIDATE
OVERALL_PAPER_A_POSITIONING = INCREMENTAL_NOVELTY_WITH_STRONG_NARROW_SUBCONTRIBUTION
```

### Algorithm role

```text
GAMULTIOBJ_PRIMARY_ROLE = SEARCH_INSTRUMENT_FOR_GENERATING_MULTI_OBJECTIVE_CANDIDATES
GAMULTIOBJ_SECONDARY_ROLE = TRACEABLE_REPRODUCIBLE_SEARCH_CONFIGURATION
ALGORITHM_PERFORMANCE_AS_CONTRIBUTION = NO
```

This preserves D019 `SYSTEM_FIRST` positioning.

---

## 8. Frozen manuscript novelty statement candidate

The following is approved as a **positioning statement candidate**, not yet inserted into the manuscript:

> The contribution of this study lies in a system-level, finite-set characterization of operational trade-offs in a hybrid solar–LPG dryer, in which coupled thermal and air-management decisions are evaluated against drying performance, modeled specific operating-energy cost, and modeled specific operational greenhouse-gas emissions. A further distinctive element is the traceable comparison of historical designs reevaluated under the corrected cost–emissions formulation with designs generated directly under that corrected formulation, allowing the survival and restructuring of previously identified trade-offs to be quantified without treating the historical set as a corrected Pareto front.

Prohibited escalation:

- “first-ever”;
- “first multiobjective solar-LPG dryer”;
- “novel GA/gamultiobj method”;
- “first economic-environmental optimization of drying”;
- “global behavior map”;
- “true/exact/global Pareto front”.

---

## 9. Physical interpretation support

### LITERATURE_EVIDENCE

- higher drying-air temperature commonly strengthens drying rate and moisture transport, while energy intensity can improve or worsen depending on the balance between shorter drying time and higher thermal/airflow demand (E01, E05);
- airflow/air-changing strategy influences moisture removal and thermal losses in solar-LPG drying (E05);
- recirculation can improve thermodynamic efficiency yet produce non-monotonic effects on drying time at high recycle fractions (E10, E11).

### PROJECT_RESULT

Frozen D019 descriptive median pattern:

```text
m_max ↓
T_min ↑
r_div2 ↓
t_rec_ini ↓

C-H median objective shifts:
f1 ≈ -33.807%
f2 ≈ +3.200%
f3 ≈ +3.859%
```

### INFERENCE

The observed C-vs-H pattern is physically compatible with a coupled heat-and-mass-transfer trade-off in which stronger drying can coexist with moderate penalties in modeled specific operating-energy cost and operational greenhouse-gas emissions.

### LIMITATION

```text
UNIQUE_CAUSAL_MECHANISM = NOT_ESTABLISHED
COMPONENT_LEVEL_CAUSAL_ATTRIBUTION = NOT_SUPPORTED
```

The literature supports plausibility and mechanism classes, not causal isolation of `T_min`, `m_max`, `r_div2` or `t_rec_ini` from the finite solution sets.

---

## 10. Core bibliography frozen for manuscript positioning

### Introduction / state of the art

1. Pereira, N. B., Joardder, M. U. H., & Karim, A. (2026). Optimization Strategies for Hybrid Drying Systems: Enhancing Energy Efficiency, Cost, and Quality in Food Processing. *Food Engineering Reviews*, 18, 19. DOI: `10.1007/s12393-026-09446-9`.
2. Murali, S., Amulya, P. R., Alfiya, P. V., Delfiya, D. S. A., & Samuel, M. P. (2020). Design and performance evaluation of solar-LPG hybrid dryer for drying of shrimps. *Renewable Energy*, 147, 2417–2428. DOI: `10.1016/j.renene.2019.10.002`.
3. Ortiz-Rodríguez, N. M., García-Valladares, O., Pilatowsky-Figueroa, I., & Menchaca-Valdez, A. C. (2020). Solar-LP gas hybrid plant for dehydration of food. *Applied Thermal Engineering*, 177, 115496. DOI: `10.1016/j.applthermaleng.2020.115496`.
4. César-Munguía, A. L., García-Valladares, O., Pérez-Espinosa, R., & Domínguez-Niño, A. (2023). Hybrid thermosolar-LPG dehydrating plant installed in Xochitepec, México. Case study: Pineapple. *Applied Thermal Engineering*, 225, 120171. DOI: `10.1016/j.applthermaleng.2023.120171`.
5. Khater, E.-S. G., Bahnasawy, A. H., Oraiath, A. A. T., et al. (2024). Assessment of a LPG hybrid solar dryer assisted with smart air circulation system for drying basil leaves. *Scientific Reports*, 14, 23922. DOI: `10.1038/s41598-024-74751-4`.

### Multiobjective optimization / positioning

6. Winiczenko, R., Górnicki, K., Kaleta, A., Martynenko, A., Janaszek-Mańkowska, M., & Trajer, J. (2018). Multi-objective optimization of convective drying of apple cubes. *Computers and Electronics in Agriculture*, 145, 341–348. DOI: `10.1016/j.compag.2018.01.006`.
7. El Ferouali, H., Gharafi, M., Zoukit, A., Doubabi, S., & Abdenouri, N. (2018). Hybrid solar-gas-electric dryer optimization with genetic algorithms. In *21st International Drying Symposium Proceedings*, 363–370. DOI: `10.4995/IDS2018.2018.7521`.
8. Oviedo, C., Barán, B., & Galeano, M. (2021). Multi-objective optimization of a steady-state rotary dryer. *CLEI Electronic Journal*, 24(2). DOI: `10.19153/cleiej.24.2.1`.
9. Zhang, Z., Zhang, J., Tian, W., Li, Y., Song, Y., & Zhang, P. (2022). Multi-objective optimization of milk powder spray drying system considering environmental impact, economy and product quality. *Journal of Cleaner Production*, 369, 133353. DOI: `10.1016/j.jclepro.2022.133353`.

### Discussion / thermal-air-management mechanisms

10. Afzali, F., Darvishi, H., & Behroozi-Khazaei, N. (2019). Optimizing exergetic performance of a continuous conveyor infrared-hot air dryer with air recycling system. *Applied Thermal Engineering*, 154, 358–367. DOI: `10.1016/j.applthermaleng.2019.03.096`.
11. Zohrabi, S., Aghbashlo, M., Seiiedlou, S. S., Scaar, H., & Mellmann, J. (2020). Energy saving in a convective dryer by using novel real-time exergy-based control schemes adjusting exhaust air recirculation. *Journal of Cleaner Production*, 257, 120394. DOI: `10.1016/j.jclepro.2020.120394`.

### Multiobjective methodology already frozen elsewhere

The methodological references for Pareto dominance, NSGA-II and hypervolume remain those frozen in `CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md`; D020 does not supersede or redesign that protocol.

---

## 11. Source URLs used for verification

- https://doi.org/10.1007/s12393-026-09446-9
- https://doi.org/10.1016/j.renene.2019.10.002
- https://doi.org/10.1016/j.applthermaleng.2020.115496
- https://doi.org/10.1016/j.applthermaleng.2023.120171
- https://doi.org/10.1038/s41598-024-74751-4
- https://doi.org/10.1016/j.compag.2018.01.006
- https://doi.org/10.4995/IDS2018.2018.7521
- https://doi.org/10.19153/cleiej.24.2.1
- https://doi.org/10.1016/j.jclepro.2022.133353
- https://doi.org/10.1016/j.applthermaleng.2019.03.096
- https://doi.org/10.1016/j.jclepro.2020.120394

---

## 12. Gate closure

```text
D020 = FROZEN_PASS
LITERATURE_POSITIONING_GATE = FROZEN_PASS_WITH_NOVELTY_NARROWING

GAP_1 = PARTIALLY_VERIFIED_GAP
GAP_2 = PARTIALLY_VERIFIED_GAP

DEFENSIBLE_NOVELTY_POSITIONING = YES_WITH_LIMITATIONS
UNIVERSAL_PRIORITY_ESTABLISHED = NO

OVERALL_PAPER_A_POSITIONING = INCREMENTAL_NOVELTY_WITH_STRONG_NARROW_SUBCONTRIBUTION
STRONGEST_NOVELTY_COMPONENT = TRACEABLE_FINITE_SET_HISTORICAL_SOLUTION_SURVIVAL_AFTER_CORRECTED_FORMULATION

SYSTEM_FIRST = PRESERVED
FINITE_SET_SCOPE = CONSTITUTIVE_NOT_OPTIONAL_DISCLAIMER

LITERATURE_POSITIONING_AND_NOVELTY_VERIFICATION = CLOSED_PASS
NEXT_PHASE = CONTROLLED_MANUSCRIPT_REWRITING
NEXT_PHASE_AUTHORIZED = NO
```

No manuscript text was modified in D020. Controlled manuscript rewriting requires separate authorization.
