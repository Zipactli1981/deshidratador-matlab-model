# R1 reproducibility configuration table

Micropaso: `9.6z-methods-a`

Identifier: `BUILD-R1-REPRODUCIBILITY-CONFIGURATION-TABLE-001`

Status: `DRAFT_READY_FOR_METHODS`

No GA was executed. No model was executed. This table documents the already completed R1 formal run.

| Item | Value | Category | Manuscript use | Note |
|---|---|---|---|---|
| Run identifier | R1 formal seed-aware tri-objective run | Run identity | Methods / Results reproducibility | Formal run used to select the computed nondominated candidates discussed in Section 7. |
| Random seed | 61001 | GA configuration | Methods | Seed used for the formal R1 run. |
| Population size | 24 | GA configuration | Methods | Population size used in the controlled formal run. |
| Maximum generations | 50 | GA configuration | Methods | Generation cap used for the formal run. |
| Exit flag | 0 | GA termination | Methods / Results caveat | Termination by maximum generations; not evidence of global convergence. |
| Approximate wall-clock time | 25.4 h | Computational cost | Methods | Approximate runtime reported for the formal R1 execution. |
| Optimization algorithm | gamultiobj | GA configuration | Methods | MATLAB multiobjective genetic algorithm. |
| Number of objectives | 3 | Objective definition | Methods | Tri-objective optimization problem. |
| Objective 1 | Final moisture ratio, MR | Objective definition | Methods | Drying-performance objective. |
| Objective 2 | Specific cost / economic objective | Objective definition | Methods | Economic objective; final factor traceability still required before submission. |
| Objective 3 | CO2 emissions objective | Objective definition | Methods | Environmental objective; final emission-factor traceability still required before submission. |
| Decision variable 1 | m_dot | Decision variables | Methods | Air mass flow rate. |
| Decision variable 2 | T_min | Decision variables | Methods | Minimum control temperature. |
| Decision variable 3 | r_rec | Decision variables | Methods | Recirculation ratio. |
| Decision variable 4 | t_rec_ini | Decision variables | Methods | Recirculation onset time. |
| Feasibility criterion | MR <= 0.1 | Feasibility | Methods / Results | Selected feasible points satisfy the target final moisture-ratio threshold. |
| Operation mode in formal run | hybrid | Model configuration | Methods | Hybrid solar + gas-LPG operation. |
| Solar-only treatment | Excluded from formal GA comparison | Model configuration | Methods / Limitations | Solar-only endpoint is non-equivalent and should remain separate from the formal GA comparison. |
| Collector-efficiency treatment in Section 7 | Sensitivity analysis using constant eta, historical embedded curve, and 2-SAH curve | Post-processing / sensitivity | Methods / Results | Collector efficiency was evaluated as a sensitivity analysis, not as a fully coupled collector model. |
| Main collector-efficiency sensitivity curve | eta_article_2SAH_curve | Post-processing / sensitivity | Methods / Results | Consistent with two solar air heaters in series per battery. |
| Selected candidate R1_solution_7 | m_dot = 0.070502 kg/s; T_min = 64.429 C; r_rec = 0.74259; t_rec_ini = 13.255 h | Selected candidates | Results | Energy-saving feasible candidate. |
| Selected candidate R1_solution_3 | m_dot = 0.075518 kg/s; T_min = 65.054 C; r_rec = 0.78863; t_rec_ini = 12.874 h | Selected candidates | Results | Balanced feasible candidate. |
| Selected candidate R1_solution_9 | m_dot = 0.092264 kg/s; T_min = 67.675 C; r_rec = 0.43299; t_rec_ini = 13.829 h | Selected candidates | Results | Aggressive drying boundary case. |
| Historical reference H2 | m_dot = 0.07355 kg/s; T_min = 65.879 C; r_rec = 0.61205; t_rec_ini = 12.385 h | Historical reference | Results | Historical deeper-drying reference, not a newly optimized R1 solution. |
| Statistical robustness statement | Not established by R1 alone | Interpretation constraint | Methods / Limitations | Additional independent seed replications would be required to claim statistical robustness. |
| Global optimality statement | Not claimed | Interpretation constraint | Methods / Limitations | The result is a computed nondominated set, not a proof of global optimality. |
| Equipment-level optimality statement | Not claimed | Interpretation constraint | Limitations | Fan power and pressure-drop coupling were not included as fully coupled equipment-level objectives. |
| Section 7 lock status | RESULTS_SECTION_07_v01_1_LOCKED | Traceability | Internal control | Results Section 7 was locked before building this Methods reproducibility table. |
