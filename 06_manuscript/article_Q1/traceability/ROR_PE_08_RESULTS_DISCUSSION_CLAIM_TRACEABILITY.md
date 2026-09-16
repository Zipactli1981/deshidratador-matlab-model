# ROR PE_08 — Results/Discussion claim traceability

```text
GATE = ROR_PE_08_Q1_MANUSCRIPT_RESULTS_DISCUSSION_INTEGRATION
MANUSCRIPT_SOURCE = 06_manuscript/article_Q1/draft_sections/MASTER_manuscript_v01.md
EVIDENCE_SCOPE = CLOSED_PE04_TO_PE07_ONLY
NEW_SCIENTIFIC_CALCULATIONS = 0
PRIMARY_SUFFICIENCY = FAIL
GLOBAL_OPTIMALITY_CLAIM = NOT_MADE
PHYSICAL_CAUSALITY_CLAIM = NOT_MADE
```

## Source-artifact aliases

- `P-NPOOL`: `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_COMPOSITE_POSTRUN/tables/N_POOL.csv`.
- `P-DETAILS`: `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_REAUTHORIZED/seed_61001/EVALUATION_DETAILS.mat`; `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_REAUTHORIZED/seed_61002/EVALUATION_DETAILS.mat`; `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_RECOVERY_FROM_61003_A1/seed_61003/EVALUATION_DETAILS.mat`; `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_RECOVERY_FROM_61003_A1/seed_61004/EVALUATION_DETAILS.mat`; `05_runs/robust_operating_region_v01/ROR_PRIMARY_20260907_RECOVERY_FROM_61003_A1/seed_61005/EVALUATION_DETAILS.mat`.
- `P-OUTPUTS`: the five corresponding `PRIMARY_OUTPUT.mat` files in the same exact seed directories listed for `P-DETAILS`.
- `PE07-CONFIG`: `05_runs/robust_operating_region_v01/controlled_operational_sensitivity/ROR_PE07_CONTROLLED_SENSITIVITY_V01/FROZEN_PE07_CONFIG.json`.
- `PE07-BASELINE`: `05_runs/robust_operating_region_v01/controlled_operational_sensitivity/ROR_PE07_CONTROLLED_SENSITIVITY_V01/BASELINE_REPLAY_AUDIT.json`.
- `PE07-RESULTS`: `05_runs/robust_operating_region_v01/controlled_operational_sensitivity/ROR_PE07_CONTROLLED_SENSITIVITY_V01/PERTURBATION_RESULTS.json`.
- `PE07-REPORT`: `05_runs/robust_operating_region_v01/controlled_operational_sensitivity/ROR_PE07_CONTROLLED_SENSITIVITY_V01/POSTRUN_CORRECTED_V02/PE07_REPORT.json`.
- `PE07-FD`: `05_runs/robust_operating_region_v01/controlled_operational_sensitivity/ROR_PE07_CONTROLLED_SENSITIVITY_V01/POSTRUN_CORRECTED_V02/FINITE_DIFFERENCE_TABLE.csv`.
- `CANONICAL`: `00_project_context/01_CURRENT_STATE.md` and `00_project_context/05_PHASE_HANDOFF_CURRENT.md`.

The PE_04–PE_06 numerical summaries are closed derived results from the mapped PRIMARY artifacts above. They are not new calculations performed during PE_08. PE_07 uses the corrected V02 derived evidence; the superseded original postrun is not a claim source.

## Claim registry

| CLAIM_ID | MANUSCRIPT_SECTION | CLAIM_SUMMARY | EVIDENCE_PHASE | SOURCE_ARTIFACT | EVIDENCE_TYPE | SCOPE_QUALIFICATION | STATUS |
|---|---|---|---|---|---|---|---|
| PE08-C01 | 4.7 | Median LPG shares were 0.864877090576 for cost and 0.934992870940 for operational CO2. | PE_04 | P-NPOOL; P-DETAILS | Calculated accounting decomposition | Stored PRIMARY outputs only; operational boundary | SUPPORTED |
| PE08-C02 | 4.7 | LPG led all 229 cost reductions and all 230 CO2 reductions. | PE_04 | P-NPOOL; P-DETAILS | Pairwise additive decomposition | Accounting contribution, not physical causality | SUPPORTED_WITH_QUALIFICATION |
| PE08-C03 | 4.7 | Cost and operational CO2 ordering was concordant in 230/230 pairs. | PE_04 | P-NPOOL; P-DETAILS | Finite-set ordering | Does not prove objective redundancy | SUPPORTED_WITH_QUALIFICATION |
| PE08-C04 | 4.7 | Solar input was constant at 487.28052 MJ and electricity was a minor, weakly varying component. | PE_04 | P-NPOOL; P-DETAILS | Stored component characterization | No solar-displacement inference | SUPPORTED_WITH_QUALIFICATION |
| PE08-C05 | 4.8 | W and LPG had identical rank ordering; MR had the opposite ordering. | PE_05 | P-NPOOL; P-DETAILS | Descriptive finite-set association | MR and W are not independent evidence | SUPPORTED_WITH_QUALIFICATION |
| PE08-C06 | 4.8 | Median adjacent LPG secants increased from LOW to MID to HIGH. | PE_05 | P-NPOOL; P-DETAILS | Ordered adjacent secants | Discrete, irregularly spaced; not derivatives | SUPPORTED_WITH_QUALIFICATION |
| PE08-C07 | 4.9 | m_max and T_min had recurrent positive observational associations with W and LPG. | PE_06 | P-NPOOL; P-OUTPUTS; PE07-CONFIG | Rank association and per-seed recurrence | Observational optimizer-selected geometry | SUPPORTED_WITH_QUALIFICATION |
| PE08-C08 | 4.9 | All eight PE_06 relations remained ambiguous or confounded. | PE_06 | P-NPOOL; P-OUTPUTS; PE07-CONFIG; CANONICAL | Frozen interpretation class | No independent control effect inferred | SUPPORTED |
| PE08-C09 | 3.7, 4.10 | PE_07 reproduced 3/3 baselines and evaluated 47 valid perturbations. | PE_07 | PE07-BASELINE; PE07-RESULTS; PE07-REPORT | Execution-primary and corrected postrun | Deterministic model experiment | SUPPORTED |
| PE08-C10 | Abstract, 4.10, 6.2, 8 | Increasing m_max produced recurrent positive local W and LPG responses. | PE_07 | PE07-REPORT; PE07-FD | Controlled local model response | LOW/LARGE magnitude comparison unavailable | SUPPORTED_WITH_QUALIFICATION |
| PE08-C11 | Abstract, 4.10, 6.2, 8 | Increasing T_min produced recurrent positive local W and LPG responses. | PE_07 | PE07-REPORT; PE07-FD | Controlled local model response | Three anchors; local perturbations only | SUPPORTED_WITH_QUALIFICATION |
| PE08-C12 | Abstract, 4.10, 6.3, 8 | Increasing r_div2 produced recurrent negative local W and LPG responses. | PE_07 | PE07-REPORT; PE07-FD | Controlled local model response | Does not establish efficiency at fixed drying | SUPPORTED_WITH_QUALIFICATION |
| PE08-C13 | Abstract, 4.10, 6.3, 8 | Delaying recirculation onset produced recurrent positive local W and LPG responses. | PE_07 | PE07-REPORT; PE07-FD; `02_src_limpio/wrappers/opt_tunel_mod2_v19_eta_sensitivity.m` | Controlled local model response plus stored variable definition | No operating recommendation or physical causality | SUPPORTED_WITH_QUALIFICATION |
| PE08-C14 | 4.10 | All eight PE_07 relations had strong recurrence and Level A evidence, with no sign reversals. | PE_07 | PE07-REPORT; PE07-FD | Frozen recurrence classification | Direction only; not global sensitivity | SUPPORTED |
| PE08-C15 | 4.10 | PE_06 and PE_07 directions were consistent for m_max and T_min. | PE_06/PE_07 | PE07-CONFIG; PE07-REPORT | Frozen cross-phase comparison | PE_06 is not retroactively reclassified | SUPPORTED |
| PE08-C16 | 6.1 | The dominant modeled trade-off links stronger drying with greater LPG, cost, and operational CO2. | PE_04–PE_07 | P-NPOOL; P-DETAILS; PE07-REPORT | Cross-phase inference | Modeled system and evaluated finite approximation only | SUPPORTED_WITH_QUALIFICATION |
| PE08-C17 | 6.1 | The finite set is compatible with increasing incremental LPG requirements at high drying intensity. | PE_05 | P-NPOOL; P-DETAILS | Process-engineering inference | Secants; no saturation threshold or universal law | SUPPORTED_WITH_QUALIFICATION |
| PE08-C18 | 6.4 | PE_07 resolves local modeled response direction but not physical causality or global importance. | PE_06/PE_07 | PE07-CONFIG; PE07-REPORT; PE07-FD | Epistemic boundary | OFAT omits interactions and external validation | SUPPORTED_WITH_QUALIFICATION |

## Figure publication contracts

No figure was generated or inserted during PE_08. A future rendering gate may use only the frozen sources listed below.

### F1 — Drying intensity versus LPG

```text
FIGURE_F1_STATUS = READY_FROM_FROZEN_DATA
FIGURE_F1_PURPOSE = Show the finite-set W–LPG structure and identify the LOW/MID/HIGH PE07 anchors.
FIGURE_F1_SOURCE_ARTIFACTS = P-NPOOL; PE07-CONFIG
FIGURE_F1_REQUIRED_FIELDS = N_POOL_ID; W_kg; LPG_fuel_input_MJ; PE07_anchor_class
FIGURE_F1_FITTED_CURVE = NO
FIGURE_F1_NEW_CALCULATION_REQUIRED = NO
FIGURE_F1_NEW_RENDER_REQUIRED = YES
```

### F2 — PE07 response-direction matrix

```text
FIGURE_F2_STATUS = READY_FROM_FROZEN_DATA
FIGURE_F2_PURPOSE = Display control × context × magnitude response directions for W and LPG.
FIGURE_F2_SOURCE_ARTIFACTS = PE07-FD; PE07-REPORT
FIGURE_F2_REQUIRED_STATES = POSITIVE_MODEL_RESPONSE; NEGATIVE_MODEL_RESPONSE; NOT_EVALUABLE
FIGURE_F2_REQUIRED_EXCEPTION = N21 / m_max / LARGE = NOT_EVALUABLE
FIGURE_F2_ZERO_SUBSTITUTION = PROHIBITED
FIGURE_F2_NEW_CALCULATION_REQUIRED = NO
FIGURE_F2_NEW_RENDER_REQUIRED = YES
```

### F3 — Cost and operational-CO2 composition

```text
FIGURE_F3_STATUS = READY_FROM_FROZEN_DATA
FIGURE_F3_PURPOSE = Show stored LPG, solar, and electricity accounting components across N_POOL.
FIGURE_F3_SOURCE_ARTIFACTS = P-NPOOL; P-DETAILS
FIGURE_F3_REQUIRED_COST_COMPONENTS = LPG_cost_USD; solar_cost_USD; electric_cost_USD
FIGURE_F3_REQUIRED_CO2_COMPONENTS = CO2_LPG_kg; CO2_electricity_kg
FIGURE_F3_SOLAR_DISPLACEMENT_INFERENCE = PROHIBITED
FIGURE_F3_NEW_CALCULATION_REQUIRED = NO
FIGURE_F3_NEW_RENDER_REQUIRED = YES
```

### F4 — Evidence-chain schematic

```text
FIGURE_F4_STATUS = READY_FROM_FROZEN_EVIDENCE
FIGURE_F4_PURPOSE = Distinguish controlled-model response, accounting linkage, and process-engineering interpretation.
FIGURE_F4_SOURCE_ARTIFACTS = PE07-CONFIG; PE07-REPORT; claim registry PE08-C01–C18
FIGURE_F4_CHAIN = controls -> modeled drying response -> auxiliary/LPG demand -> operating cost + operational CO2
FIGURE_F4_VISUAL_BOUNDARY = controlled response != accounting identity != physical causality
FIGURE_F4_NEW_CALCULATION_REQUIRED = NO
FIGURE_F4_NEW_RENDER_REQUIRED = YES
```

## Table publication contracts

Publication tables should carry detailed counts and diagnostic values; the prose should retain only the dominant shares, the W–LPG ordering result, the LOW/MID/HIGH secant medians, and the four controlled-response directions needed to communicate the central argument.

| TABLE_ID | PURPOSE | UPSTREAM_SOURCE | REQUIRED_COLUMNS | NUMERICAL_VALUES_ALREADY_AVAILABLE | NEW_CALCULATION_REQUIRED | READY_FOR_FORMATTING |
|---|---|---|---|---|---|---|
| T1 | PE_04 accounting decomposition | P-NPOOL; P-DETAILS | metric; LPG; solar; electricity; pair_count; proportion; scope | YES | NO | YES |
| T2 | PE_05 marginal LPG diagnostics | P-NPOOL; P-DETAILS | diagnostic; LOW; MID; HIGH; units; interpretation_limit | YES | NO | YES |
| T3 | PE_06 observational/confounding summary | P-NPOOL; P-OUTPUTS; PE07-CONFIG | control; rho_W; rho_LPG; recurrence; selection_sensitivity; control_confounding; PE06_level | YES | NO | YES |
| T4 | PE_07 controlled-response summary | PE07-REPORT; PE07-FD | control; context; magnitude; W_direction; LPG_direction; magnitude_class; recurrence; PE07_level; PE06_comparison | YES | NO | YES |

Formatting these tables or figures is a future editorial rendering task. It is not authorization to recompute scientific results.

## Audit totals

```text
CLAIM_COUNT = 18
SUPPORTED_CLAIM_COUNT = 5
SUPPORTED_WITH_QUALIFICATION_COUNT = 13
UNSUPPORTED_CLAIM_COUNT = 0
FIGURE_TABLE_PLAN_CREATED = YES
SOURCE_ONLY_CONVERSATION_COUNT = 0
MANUSCRIPT_CLAIM_AUDIT = PASS
TRACEABILITY_AUDIT = PASS
```
