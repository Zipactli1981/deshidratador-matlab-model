# MASTER_manuscript_v01

## Status

`MASTER_SKELETON_CREATED`

## Micropaso

`9.6z-results-draft-d`

## Identifier

`CREATE-MASTER-MANUSCRIPT-SKELETON-v01-001`

## Working title

Multi-objective operational optimization of a hybrid solar–LPG tunnel dryer under controlled recirculation and collector-efficiency sensitivity

## Internal control note

This master manuscript is a controlled assembly file. Approved sections are integrated progressively from individual Markdown section files located in:

`06_manuscript/article_Q1/draft_sections`

Numerical tables are generated from MATLAB postprocessing scripts and stored in:

`06_manuscript/article_Q1/tables`

Review reports and checks are stored in:

`06_manuscript/article_Q1/review`

Traceability files are stored in:

`06_manuscript/article_Q1/traceability`

---

# 1. Abstract

`STATUS: PENDING`

Draft after Results and Discussion are stable.

Expected content:

- Hybrid solar–LPG tunnel dryer.
- Product drying model and operational variables.
- Tri-objective optimization.
- Seed-aware computed nondominated set.
- Selected operating candidates.
- Collector-efficiency sensitivity.
- Main result: energy-saving feasible candidate preserved under 2-SAH efficiency sensitivity.

---

# 2. Keywords

`STATUS: PENDING`

Candidate keywords:

- Hybrid solar dryer
- Tunnel drying
- Multi-objective optimization
- Moisture ratio
- Solar air heater
- Recirculation control
- LPG auxiliary heating
- Collector efficiency sensitivity

---

# 3. Introduction

`STATUS: PENDING`

Expected structure:

## 3.1 Context

Hybrid solar drying as an option to reduce fossil auxiliary energy in agro-industrial drying.

## 3.2 Problem

Operational control of tunnel dryers involves trade-offs between final moisture ratio, energy use, cost, and emissions.

## 3.3 Gap

Most optimization studies either simplify recirculation timing, assume fixed solar collector efficiency, or do not evaluate whether the collector-efficiency assumption changes the operational selection.

## 3.4 Contribution

This work evaluates a hybrid solar–LPG tunnel dryer using a tri-objective optimization framework with explicit recirculation timing and a controlled collector-efficiency sensitivity analysis.

## 3.5 Scope and limitation

The work reports a computed nondominated set from a controlled seed-aware formal run. It does not claim global optimality or statistical robustness across multiple independent seeds.

---

# 4. System description

`STATUS: PENDING`

Expected content:

- Hybrid solar–LPG tunnel dryer.
- Solar field: eight parallel batteries, each battery with two solar air heaters in series.
- Effective area per battery.
- Mixing of solar-heated air streams.
- Auxiliary LPG heating.
- Drying tunnel.
- Recirculation.

Expected figure:

`FIG_01_system_schematic`

---

# 5. Mathematical model

`STATUS: PENDING`

Expected content:

## 5.1 Drying model

- Product mass balance.
- Moisture ratio.
- Final moisture criterion.
- Time step.

## 5.2 Thermal model

- Air temperature.
- Product temperature.
- Structure temperature.
- Auxiliary energy.

## 5.3 Solar collector representation

- Original constant efficiency.
- Historical embedded efficiency expression.
- 2-SAH curve used for sensitivity.
- Clarify that fully coupled dynamic collector modeling is future work.

## 5.4 Operational modes

- Hybrid.
- Gas-LPG reference.
- Solar endpoint treated separately, not as equivalent formal GA comparison if numerically invalid.

---

# 6. Optimization methodology

`STATUS: PARTIAL`

Expected content:

## 6.1 Decision variables

- Air mass flow rate.
- Minimum process temperature.
- Recirculation ratio.
- Recirculation start time.

## 6.2 Objective functions

- Final moisture ratio.
- Specific cost or auxiliary-energy-related economic indicator.
- CO2-related environmental indicator.

## 6.3 Constraints and feasibility criterion

- MR ≤ 0.1.
- Operational bounds.
- Simulation validity.

## 6.4 Seed-aware formal run

- Seed-aware replication.
- Controlled GA configuration.
- Exitflag interpretation.
- Do not claim global optimum.

Expected table:

`TABLE_01_GA_configuration`

---

# 7. Results and discussion

`STATUS: PARTIAL`

## 7.1 Formal tri-objective run

`STATUS: PENDING_INTEGRATION`

Expected content:

- R1 computed nondominated set.
- Feasible and non-feasible solutions.
- H2 comparison.
- Selection rationale.

Expected table:

`TABLE_02_R1_selected_candidates`

## 7.2 Collector-efficiency sensitivity

`STATUS: APPROVED_SECTION_AVAILABLE`

Source section:

`SEC_05_results_eta_sensitivity_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`

Approved internal verdict:

`SEC_05_RESULTS_ETA_SENSITIVITY_v96z_READY_FOR_MASTER_MANUSCRIPT`

Main result:

Under the 2-SAH collector-efficiency curve, R1-7 remains the feasible candidate with the lowest auxiliary energy demand, while R1-3 remains a balanced feasible candidate and H2 remains a deeper-drying historical reference.

Insert approved English text here during integration step.

## 7.3 Operational interpretation

`STATUS: PENDING`

Expected content:

- Low airflow region.
- Temperature near 64–66 °C.
- High recirculation for selected energy-saving candidates.
- Recirculation onset in intermediate-late drying stage.
- Interpretation as operational tendency, not universal equipment-level optimum.

## 7.4 Methodological implications

`STATUS: PENDING`

Expected content:

- Fixed efficiency assumption affects absolute energy balance.
- Operational ranking preserved under 2-SAH sensitivity.
- Need for future coupled collector model.
- Need for additional independent seeds if statistical robustness is claimed.

---

# 8. Limitations

`STATUS: PENDING`

Expected content:

- Single formal external seed run.
- No claim of global optimality.
- Collector efficiency sensitivity is not a fully coupled dynamic collector model.
- Fan power and pressure drop may not be dynamically linked to mass flow rate.
- Solar-only mode excluded from formal GA comparison when not numerically equivalent.
- CO2 and cost factors must be finalized before publication.

---

# 9. Conclusions

`STATUS: PENDING`

Expected content:

- The computed nondominated set identified feasible alternatives to the historical H2 point.
- R1-7 reduced auxiliary energy demand while maintaining MR ≤ 0.1.
- R1-3 provided a balanced feasible alternative.
- Collector-efficiency sensitivity changed absolute auxiliary energy values but preserved the operational ranking.
- Fully coupled collector modeling and additional seed replications are recommended future work.

---

# 10. Nomenclature

`STATUS: PENDING`

Candidate symbols:

| Symbol | Meaning | Unit |
|---|---|---|
| MR | Moisture ratio | - |
| Q_aux | Auxiliary energy demand | kWh |
| m_dot | Air mass flow rate | kg/s |
| T_min | Minimum process temperature | °C |
| r_rec | Recirculation ratio | - |
| t_rec_ini | Recirculation start time | h |
| η | Solar air heater efficiency | - |
| SAH | Solar air heater | - |

---

# 11. References

`STATUS: PENDING`

Required references:

- Thesis/model reference.
- Solar air heater 2-SAH efficiency article.
- Drying kinetics references.
- Multi-objective optimization references.
- Energy/emissions factor references, once finalized.

---

# 12. Supplementary material

`STATUS: PARTIAL`

Expected files:

- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- Seed-aware GA configuration.
- Traceability reports.
- Sensitivity checks.
- Selected MATLAB scripts, if publication policy allows.

---

# Internal traceability log

## Approved sections

| Section file | Status | Notes |
|---|---|---|
| `SEC_05_results_eta_sensitivity_v96z.md` | Approved | Collector-efficiency sensitivity and R1 selected candidates |

## Approved tables

| Table file | Status | Use |
|---|---|---|
| `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md` | Approved | Main Results table |
| `SUPP_TABLE_ETA_SENSITIVITY_v96z.md` | Approved | Supplementary sensitivity table |

## Restrictions

- Do not claim global optimum.
- Do not claim statistical robustness from one seed-aware formal run.
- Use “computed nondominated set” instead of “global Pareto front”.
- Keep H2 as historical comparison, not as final optimum.
- Treat 2-SAH collector curve as sensitivity, not as fully coupled collector model.
- Keep cost and CO2 provisional until factors and calculation path are fully traced.