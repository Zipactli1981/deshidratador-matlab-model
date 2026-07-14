# MANUSCRIPT_GAP_AND_SIMULATION_DECISION_MATRIX_v96z

## Status

`DRAFT_DECISION_MATRIX`

## Micropaso

`9.6z-planning-a`

## Identifier

`MANUSCRIPT-GAP-AND-SIMULATION-DECISION-MATRIX-001`

## Purpose

This document defines which additional simulations or analyses are needed before advancing the manuscript, which ones are optional, and which ones should be deferred to future work.

The purpose is to avoid running long GA simulations without a clear manuscript-level need.

## Current locked basis

The current Results Section 7 is based on:

- Formal seed-aware R1 run.
- Selected candidates: H2, R1_solution_7, R1_solution_3, R1_solution_9.
- Collector-efficiency sensitivity using:
  - constant efficiency η = 0.50,
  - historical embedded variable-efficiency expression,
  - 2-SAH collector-efficiency curve.
- Manuscript table:
  - `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- Supplementary table:
  - `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- Locked/audited Results Section 7:
  - `RESULTS_SECTION_07_CONSISTENCY_PASS`
  - `SECTION_07_READY_FOR_v01_LOCK`

## Decision categories

| Category | Meaning |
|---|---|
| `CLOSED` | Already done; no additional simulation needed |
| `RECOMMENDED_BEFORE_SUBMISSION` | Should be done before journal submission |
| `RECOMMENDED_BEFORE_FULL_DRAFT` | Useful before expanding the manuscript further |
| `OPTIONAL_AFTER_v01` | Useful, but not required for manuscript v01 |
| `DEFER_TO_FUTURE_WORK` | Better reported as limitation/future work |
| `DO_NOT_RUN_NOW` | Not worth running at this stage |

## Simulation and analysis decision matrix

| ID | Simulation / analysis | Question answered | Manuscript value | Computational cost | Risk if omitted | Decision |
|---|---|---|---|---:|---|---|
| SIM-01 | R2/R3 GA runs with independent seeds | Do R1-7/R1-3 recur under other seeds? | Supports statistical robustness | High | Cannot claim statistical robustness | `OPTIONAL_AFTER_v01` |
| SIM-02 | Pointwise η sensitivity for H2/R1-7/R1-3/R1-9 | Does collector efficiency change ranking? | Supports Section 7.2 | Low | Already resolved | `CLOSED` |
| SIM-03 | Full GA using 2-SAH efficiency curve as base model | Does the computed front change when η variable is embedded in the objective? | Strong but opens new study | Very high | Cannot claim front robustness to collector model | `DO_NOT_RUN_NOW` |
| SIM-04 | Dynamic collector sensitivity using ΔT/G coupling | Does a more physical collector model change energy balance? | Useful methodological extension | Medium-high | Must keep collector model caveat | `DEFER_TO_FUTURE_WORK` |
| SIM-05 | Fan-power coupling with mass flow rate | Does low airflow remain attractive at equipment level? | Important for equipment-level optimization | Medium | Must avoid equipment-level optimality claim | `DEFER_TO_FUTURE_WORK` |
| SIM-06 | Pressure-drop / duct / fan curve model | Are airflow recommendations aerodynamically valid? | Important for design-level claim | Medium-high | Must keep pressure-drop limitation | `DEFER_TO_FUTURE_WORK` |
| SIM-07 | Final cost and CO2 recalculation with fully traced factors | Are economic/environmental metrics publishable? | Required for complete tri-objective article | Low-medium | Cost/CO2 claims remain provisional | `RECOMMENDED_BEFORE_SUBMISSION` |
| SIM-08 | Hybrid vs gas-LPG pointwise comparison for H2/R1-7/R1-3/R1-9 | How much does hybrid operation reduce auxiliary demand relative to gas-LPG? | High; strengthens results with low cost | Low | Article lacks clear baseline comparison | `RECOMMENDED_BEFORE_FULL_DRAFT` |
| SIM-09 | Solar-only endpoint pointwise test | What happens without LPG support? | Supplementary only | Low-medium | Solar-only must remain non-equivalent | `OPTIONAL_AFTER_v01` |
| SIM-10 | Local neighborhood sweep around R1-7 | Is R1-7 a stable local operating region or isolated point? | High; cheaper than GA | Medium-low | R1-7 may look point-specific | `RECOMMENDED_BEFORE_FULL_DRAFT` |
| SIM-11 | Validation consistency check with thesis/pineapple case | Does the model retain consistency with the validated historical case? | Useful for Methods credibility | Low | Validation narrative remains weaker | `RECOMMENDED_BEFORE_SUBMISSION` |
| SIM-12 | R1 reproducibility/configuration table | Are seed, population, generations, time, and exitflag fully reported? | Required for reproducibility | Low | Methods section incomplete | `RECOMMENDED_BEFORE_FULL_DRAFT` |
| SIM-13 | Rebuild cost/CO2 table for selected points only | Can selected candidates be compared economically without rerunning GA? | Useful if factors are traceable | Low | Results remain energy-centered | `RECOMMENDED_BEFORE_SUBMISSION` |
| SIM-14 | Compare R1 selected points under constant η vs 2-SAH in manuscript-ready plot | Can sensitivity be visualized compactly? | Useful figure/supplement | Low | Not critical | `OPTIONAL_AFTER_v01` |
| SIM-15 | Compute relative reductions vs H2 for selected points | How much does R1-7 improve relative to H2? | High; simple communication | Low | Discussion less quantitative | `RECOMMENDED_BEFORE_FULL_DRAFT` |

## Prioritized action list

### Priority 1 — Do before expanding manuscript beyond Results

| Priority | ID | Action | Reason |
|---:|---|---|---|
| 1 | SIM-12 | Build R1 reproducibility/configuration table | Needed for Methods and reproducibility |
| 2 | SIM-08 | Hybrid vs gas-LPG pointwise comparison | Provides clear baseline comparison |
| 3 | SIM-10 | Local neighborhood sweep around R1-7 | Tests whether R1-7 is locally stable |
| 4 | SIM-15 | Relative reductions vs H2 | Strengthens interpretation with simple metrics |

### Priority 2 — Do before journal submission

| Priority | ID | Action | Reason |
|---:|---|---|---|
| 5 | SIM-07 | Final cost and CO2 recalculation | Required if tri-objective claims include cost/CO2 |
| 6 | SIM-13 | Cost/CO2 table for selected points | Useful publication table |
| 7 | SIM-11 | Validation consistency check | Strengthens model credibility |

### Priority 3 — Optional after manuscript v01

| Priority | ID | Action | Reason |
|---:|---|---|---|
| 8 | SIM-01 | R2/R3 independent seed GA runs | Needed only for statistical robustness claims |
| 9 | SIM-09 | Solar-only endpoint | Supplementary, non-equivalent mode |
| 10 | SIM-14 | Sensitivity visualization | Improves presentation, not essential |

### Future work

| ID | Deferred work | Reason |
|---|---|---|
| SIM-03 | Full GA with 2-SAH curve as base | Too costly; becomes a new optimization study |
| SIM-04 | Dynamic collector model with ΔT/G coupling | Better as model extension |
| SIM-05 | Fan-power coupling | Needed for equipment-level optimality, not current claim |
| SIM-06 | Pressure-drop / duct / fan model | Needed for design-level claim, not current process-level claim |

## Editorial implications

The current manuscript should not claim:

- global optimum,
- global Pareto front,
- statistical robustness,
- complete equipment-level optimality,
- fan-energy optimality,
- fully coupled collector-model optimality.

The current manuscript can claim:

- a controlled seed-aware computed nondominated set,
- a feasible energy-saving candidate, R1_solution_7,
- a balanced feasible candidate, R1_solution_3,
- H2 as historical deeper-drying reference,
- R1_solution_9 as aggressive drying with high auxiliary-energy penalty,
- ranking stability under tested collector-efficiency assumptions,
- non-negligible effect of collector efficiency on absolute auxiliary-energy balance.

## Recommended next micropaso

`9.6z-sim-lite-a`

`SELECTED-POINTS-HYBRID-vs-GASLP-COMPARISON-001`

Reason:

This is the highest-value next analysis because it is not a long GA run and it gives the manuscript a clear baseline comparison between hybrid and gas-LPG operation for the selected points.

## Internal verdict

`SIMULATION_DECISION_MATRIX_v96z_CREATED`

Recommended decision:

`NO_NEW_GA_NOW`

Immediate next action:

`RUN_POINTWISE_HYBRID_vs_GASLP_COMPARISON`