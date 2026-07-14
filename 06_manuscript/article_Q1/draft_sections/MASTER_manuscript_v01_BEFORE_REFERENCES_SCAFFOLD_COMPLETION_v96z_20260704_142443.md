# MASTER_manuscript_v01

#

# Status

`MASTER_SKELETON_CREATED`

#

# Micropaso

`9.6z-results-draft-d`

#

# Identifier

`CREATE-MASTER-MANUSCRIPT-SKELETON-v01-001`

#

# Working title

Multi-objective operational optimization of a hybrid solar–LPG tunnel dryer under controlled recirculation and collector-efficiency sensitivity

#

# Internal control note

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

`STATUS: DRAFT_READY_FOR_REVIEW`

This study evaluates the operational optimization of a hybrid solar--LPG tunnel dryer with controlled air recirculation and collector-efficiency sensitivity. A multiobjective genetic-algorithm workflow was applied to a drying model of the hybrid system, using air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time as decision variables. The formal R1 run was treated as a controlled seed-aware numerical realization and its output is therefore reported as a computed nondominated set, not as evidence of global optimality or statistical robustness across independent seeds. Feasibility was assessed using a final moisture-ratio criterion of MR <= 0.1.

Among the selected operating points, R1_solution_7 was identified as the main energy-conservative feasible candidate, reaching MR = 0.07057 with Q_aux = 656.23 kWh under the 2-SAH collector-efficiency assumption. R1_solution_3 provided a balanced alternative with deeper drying and higher auxiliary-energy demand, whereas R1_solution_9 represented an aggressive drying case with a substantial energy penalty. The historical H2 point was retained only as a reference condition for comparison and was not treated as a newly optimized R1 solution.

The collector-efficiency sensitivity analysis showed that replacing the constant-efficiency assumption with the 2-SAH curve changed the absolute auxiliary-energy values but preserved the qualitative ranking of the selected operating points. A pointwise hybrid versus gas-LPG-only baseline comparison further indicated that hybrid operation reduced auxiliary-energy demand while maintaining feasible final moisture-ratio behavior. These results support the hybrid solar--LPG configuration as a promising energy-saving operating strategy under the modeled conditions. Final economic and CO2 claims remain conditional on definitive fuel-price, tariff, emission-factor, source-year, regional, unit-basis, and conversion assumptions.

# 2. Keywords

`STATUS: DRAFT_READY_FOR_REVIEW`

- Hybrid solar dryer
- LPG auxiliary heating
- Tunnel drying
- Multiobjective optimization
- Moisture ratio
- Solar air heater
- Collector-efficiency sensitivity
- Recirculation control

# 3. Introduction

`STATUS: DRAFT_READY_FOR_REVIEW`

Hybrid solar drying is a relevant route for reducing fossil auxiliary-energy demand in thermal processing of agricultural products, particularly when drying must be maintained under controlled temperature and airflow conditions. In tunnel dryers, the useful contribution of the solar field depends not only on the available solar resource, but also on how the process air is heated, mixed, recirculated, and supplemented by an auxiliary fuel system. For hybrid solar--LPG operation, the resulting control problem is therefore not a single-variable temperature-setting problem; it involves simultaneous decisions on airflow, minimum process temperature, recirculation ratio, and recirculation start time.

The operational challenge is that drying performance, auxiliary energy demand, economic indicators, and CO2-related indicators do not improve simultaneously. Deeper drying generally requires larger thermal input, while lower-energy operation may be acceptable only if the final moisture-ratio criterion remains satisfied. A useful optimization framework must therefore distinguish between excessive drying and sufficient drying, and it must identify feasible candidates that satisfy the selected moisture criterion without unnecessarily increasing auxiliary energy use. In this manuscript, feasibility is interpreted through the final moisture-ratio condition MR <= 0.1.

Solar air heater representation is another source of uncertainty in the interpretation of hybrid dryer performance. A constant collector-efficiency assumption can simplify the energy balance, but it may distort the estimated auxiliary-energy demand. Conversely, a more physically consistent efficiency representation can change the absolute magnitude of the solar contribution. For the present system, the solar field is represented by batteries with two solar air heaters in series, which motivates a collector-efficiency sensitivity analysis based on the 2-SAH curve. This sensitivity is used to assess whether the selected operating-point ranking is preserved when the collector-efficiency assumption is changed.

The present work addresses these issues by assembling a controlled multiobjective optimization and post-processing workflow for a hybrid solar--LPG tunnel dryer with explicit recirculation timing and collector-efficiency sensitivity. The optimization problem evaluates the trade-off among final moisture ratio, auxiliary-energy-related economic performance, and CO2-related environmental indicators. The formal R1 run is interpreted as a controlled seed-aware numerical realization, and its output is reported as a computed nondominated set rather than as proof of global optimality or statistical robustness. The selected R1 candidates are compared against the historical H2 reference point and against a pointwise gas-LPG-only baseline to separate optimization behavior from fuel-substitution effects.

The contribution of this manuscript is fourfold. First, it formalizes the operational selection of feasible hybrid dryer candidates using air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time as decision variables. Second, it identifies R1_solution_7 as the main energy-conservative feasible candidate and R1_solution_3 as a balanced alternative, while retaining R1_solution_9 as an aggressive drying boundary case and H2 as a historical reference. Third, it evaluates whether the 2-SAH collector-efficiency assumption changes the qualitative ranking of the selected points. Fourth, it compares the selected hybrid operating points against gas-LPG-only operation to quantify auxiliary-energy reduction under equivalent decision-variable settings.

The scope of the study is limited to the implemented drying model, the specified operational bounds, and one formal seed-aware R1 run. The analysis does not claim complete search-space convergence, statistical robustness across independent random seeds, or complete equipment-level optimality. Fan-power consumption, pressure-drop coupling, fully coupled dynamic collector modeling, and final source-locked cost and CO2 factors remain necessary extensions before publication-level techno-economic and environmental claims are made.

# 3.1 Context

Hybrid solar drying as an option to reduce fossil auxiliary energy in agro-industrial drying.

#

# 3.2 Problem

Operational control of tunnel dryers involves trade-offs between final moisture ratio, energy use, cost, and emissions.

#

# 3.3 Gap

Most optimization studies either simplify recirculation timing, assume fixed solar collector efficiency, or do not evaluate whether the collector-efficiency assumption changes the operational selection.

#

# 3.4 Contribution

This work evaluates a hybrid solar–LPG tunnel dryer using a tri-objective optimization framework with explicit recirculation timing and a controlled collector-efficiency sensitivity analysis.

#

# 3.5 Scope and limitation

The work reports a computed nondominated set from a controlled seed-aware formal run. It does not claim global optimality or statistical robustness across multiple independent seeds.

---

# 4. System description

`STATUS: DRAFT_READY_FOR_REVIEW`

The analyzed equipment is a hybrid solar--LPG tunnel dryer configured for forced-convection drying under controlled airflow, auxiliary heating, and air-recirculation conditions. The system combines a solar air-heating field with an LPG auxiliary heater so that the process-air temperature can be maintained when the instantaneous solar contribution is insufficient. The dryer is represented at the operational level by the main airflow path, the solar air-heater contribution, the auxiliary LPG heating stage, the drying chamber, and the recirculation branch.

The drying-air stream is driven by a forced-flow system and is heated before entering the tunnel chamber. Under hybrid operation, part of the required sensible heat is supplied by the solar air-heater field and the remaining demand is supplied by the LPG auxiliary heater whenever the process-air temperature must be lifted to the selected minimum operating level. The auxiliary-energy variable Q_aux is therefore interpreted as the thermal demand assigned to the LPG system after accounting for the modeled solar contribution.

The solar subsystem is represented through collector-efficiency assumptions rather than through a fully coupled dynamic collector model. In the baseline formulation, the solar contribution can be estimated with a simplified efficiency representation. In the sensitivity analysis, the solar field is represented using the 2-SAH collector-efficiency curve, consistent with batteries composed of two solar air heaters in series. This sensitivity is used to evaluate whether the selected operating-point ranking remains consistent when the solar-air-heater efficiency representation is changed.

The recirculation subsystem allows a fraction of the outlet air to be returned to the process stream after a specified recirculation start time. In the optimization workflow, the relevant operational decision variables are the air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time. These variables jointly define the thermal severity, residence-time effect, and energy-reuse behavior of each simulated operating condition. The recirculation start time is treated explicitly because early and delayed recirculation can affect both moisture removal and auxiliary-energy demand.

The drying chamber contains the agricultural product and is modeled through lumped dynamic states that represent the interaction between drying air, product moisture removal, and thermal response of the system. The final drying performance is evaluated using the final moisture ratio, with feasible operation defined in this manuscript by MR <= 0.1. The comparison between hybrid operation and gas-LPG-only operation is performed pointwise at selected operating conditions, so the difference in Q_aux reflects the modeled solar contribution under the same decision-variable settings.

Figure 1 should present a schematic of the hybrid solar--LPG dryer, including the solar air-heater field, auxiliary LPG heater, drying chamber, exhaust path, recirculation branch, controlled recirculation ratio, recirculation start-time logic, and main measured or simulated variables.

`FIG_01_system_schematic`: pending figure callout; schematic to be inserted during figure-preparation stage.

# 5. Mathematical model

`STATUS: DRAFT_READY_FOR_REVIEW`

The dryer is represented by a lumped-state dynamic model that links process-air heating, product drying, structural thermal response, and auxiliary-energy demand. The model is used as the simulation core for the optimization workflow; it is not modified in this manuscript section. The purpose of this section is to document the state variables, inputs, operating logic, and performance indicators used by the existing implementation.

The dynamic state vector includes four principal responses: process-air temperature, product temperature, product moisture ratio, and structural temperature. The air-temperature state represents the thermal condition of the drying stream entering and interacting with the product domain. The product-temperature state represents the thermal response of the material being dried. The moisture-ratio state is the drying-performance variable used to determine whether a simulated operating condition satisfies the final moisture criterion. The structural-temperature state accounts for the thermal inertia of the dryer structure and its interaction with the process air.

The model receives time-dependent environmental and operational inputs associated with solar availability, ambient conditions, and the selected operating policy. The decision variables imposed by the optimization workflow are the air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time. The air mass flow rate affects convective transport and residence-time behavior. The minimum process temperature defines the auxiliary-heating threshold. The recirculation ratio determines the fraction of outlet air returned to the process stream after recirculation begins. The recirculation start time determines when this air-reuse pathway is activated during the drying period.

Hybrid operation is represented by combining the useful solar-air-heater contribution with LPG auxiliary heating. At each simulated condition, the solar subsystem contributes useful heat according to the selected collector-efficiency representation, while the auxiliary LPG system supplies the remaining thermal demand required to maintain the imposed minimum process temperature. The auxiliary-energy indicator Q_aux is therefore accumulated from the modeled thermal contribution assigned to the LPG heater. In the collector-efficiency sensitivity analysis, the same drying model is evaluated with the 2-SAH efficiency representation to test whether the selected operating-point ranking is preserved when the solar-air-heater assumption changes.

The drying-performance criterion is based on the final moisture ratio. A candidate solution is considered feasible in this manuscript when the terminal value satisfies MR <= 0.1. Values substantially below this threshold indicate deeper drying, but not necessarily a preferable operating condition if the auxiliary-energy penalty is high. This distinction is important because the optimization and post-processing workflow compares feasible candidates by considering both moisture removal and energy demand rather than minimizing moisture ratio alone.

The model outputs used in the manuscript include the terminal moisture ratio, auxiliary energy demand, and derived economic and CO2-related indicators. Economic and CO2 quantities are treated as post-processing indicators whose final interpretation depends on source-locked assumptions for prices, tariffs, emission factors, regional scope, unit basis, and conversion factors. Consequently, the dynamic model supports the operational comparison among selected candidates, but definitive techno-economic and environmental claims require final source validation.

The mathematical model is used consistently for the R1 selected candidates, the historical H2 reference point, the collector-efficiency sensitivity, and the pointwise gas-LPG-only baseline comparison. The gas-LPG-only baseline preserves the selected decision-variable settings and suppresses the solar contribution, allowing Q_aux differences to be interpreted as the modeled auxiliary-energy reduction associated with hybrid operation under equivalent operating conditions.

# 5.1 Drying model

- Product mass balance.
- Moisture ratio.
- Final moisture criterion.
- Time step.

#

# 5.2 Thermal model

- Air temperature.
- Product temperature.
- Structure temperature.
- Auxiliary energy.

#

# 5.3 Solar collector representation

- Original constant efficiency.
- Historical embedded efficiency expression.
- 2-SAH curve used for sensitivity.
- Clarify that fully coupled dynamic collector modeling is future work.

#

# 5.4 Operational modes

- Hybrid.
- Gas-LPG reference.
- Solar endpoint treated separately, not as equivalent formal GA comparison if numerically invalid.

---

# 6. Optimization methodology

`STATUS: DRAFT_READY_FOR_REVIEW`

The optimization workflow couples the drying model described above with a multiobjective genetic-algorithm search and a controlled post-processing stage for candidate interpretation. The method is designed to identify feasible operating points for the hybrid solar--LPG dryer under simultaneous drying-performance, auxiliary-energy, economic, and CO2-related considerations. The optimization section reports the numerical procedure and its interpretation limits; the quantitative operating-point results are reported separately in the Results and discussion section.

## 6.1 Decision variables and operating bounds

The optimization problem uses four operational decision variables: air mass flow rate, minimum process temperature, recirculation ratio, and recirculation start time. These variables determine the airflow intensity, auxiliary-heating threshold, degree of outlet-air reuse, and timing of recirculation activation. The same decision-variable definitions are used for the R1 candidate evaluation, the historical H2 reference comparison, the collector-efficiency sensitivity analysis, and the pointwise gas-LPG-only baseline comparison.

## 6.2 Objective functions and feasibility criterion

The search evaluates competing objectives associated with terminal moisture ratio, auxiliary-energy-related economic performance, and CO2-related environmental indicators. The terminal moisture ratio is used to distinguish feasible from infeasible drying outcomes. In this manuscript, a candidate is treated as feasible when the terminal condition satisfies MR <= 0.1. The post-processing interpretation therefore separates sufficient drying from excessive drying: a lower moisture ratio is not automatically preferred if it is obtained with a disproportionate auxiliary-energy penalty.

Economic and CO2-related indicators are retained as conditional post-processing quantities. They are useful for ranking and interpretation within the controlled workflow, but final publication-level claims require source-locked assumptions for LPG price, electricity tariff if applicable, emission factors, regional scope, source year, unit basis, and conversion factors. For this reason, the manuscript emphasizes operational and auxiliary-energy behavior, while treating definitive economic and environmental claims as conditional until the final reference set is fixed.

## 6.3 Genetic-algorithm configuration and run interpretation

The formal R1 optimization run was executed using seed = 61001, population = 24, and generations = 50. The resulting exitflag = 0 is interpreted as termination by the prescribed generation limit, not as a failure of the simulation and not as proof of convergence to a global optimum. The R1 output is therefore described as a computed nondominated set obtained under the specified configuration, random seed, decision-variable bounds, and model assumptions.

`TABLE_01_GA_configuration`: pending table callout; the table should summarize the genetic-algorithm configuration, including seed = 61001, population = 24, generations = 50, termination criterion, decision variables, feasibility criterion MR <= 0.1, and interpretation notes for exitflag = 0.

## 6.4 Candidate selection and reference points

Candidate interpretation is performed after the R1 search by selecting representative feasible points from the computed nondominated set. R1_solution_7 is treated as the main energy-conservative feasible candidate, R1_solution_3 as a balanced alternative, and R1_solution_9 as an aggressive drying case with higher auxiliary-energy demand. These labels are used only for structured interpretation of the computed set and do not imply unique global optimality.

The H2 operating point is retained as a historical reference condition rather than as a newly optimized R1 solution. This distinction is important because H2 provides continuity with previous simulation and thesis-stage analysis, whereas the R1 candidates originate from the formal R1 search. Comparisons involving H2 are therefore interpreted as reference comparisons, not as evidence that H2 belongs to the same computed nondominated set as the R1 candidates.

## 6.5 Collector-efficiency sensitivity and baseline comparison

The collector-efficiency sensitivity evaluates whether the qualitative interpretation of selected candidates is preserved when the simplified solar-air-heater efficiency assumption is replaced by the 2-SAH efficiency representation. This step is not a new coupled dynamic collector model; it is a physically motivated sensitivity using the same selected operating points and the same drying-model framework.

The gas-LPG-only baseline comparison is performed pointwise at selected operating conditions. For each selected case, the decision-variable settings are preserved while the solar contribution is suppressed. The resulting difference in Q_aux between hybrid operation and gas-LPG-only operation is interpreted as the modeled auxiliary-energy reduction associated with hybrid solar contribution under equivalent operating conditions.

## 6.6 Reproducibility and interpretation limits

The methodology is intentionally reported with seed, population, generation count, termination flag, and candidate-selection rules to support traceability. However, the use of one formal R1 seed-aware run does not establish statistical robustness across independent seeds. Additional independent runs, convergence diagnostics, and equipment-level uncertainty analyses would be required before making stronger claims about global search-space coverage or robustness. Within the present scope, the appropriate interpretation is a controlled optimization realization and post-processing workflow that identifies and compares feasible operating candidates under explicitly stated assumptions.

# 6.1 Decision variables

- Air mass flow rate.
- Minimum process temperature.
- Recirculation ratio.
- Recirculation start time.

#

# 6.2 Objective functions

- Final moisture ratio.
- Specific cost or auxiliary-energy-related economic indicator.
- CO2-related environmental indicator.

#

# 6.3 Constraints and feasibility criterion

- MR ≤ 0.1.
- Operational bounds.
- Simulation validity.

#

# 6.4 Seed-aware formal run

- Seed-aware replication.
- Controlled GA configuration.
- Exitflag interpretation.
- Do not claim proof of global optimality.

Expected table:

`TABLE_01_GA_configuration`

---

# 7. Results and discussion

`STATUS: STRUCTURALLY_INTEGRATED_CONTENT_REVIEW_PENDING`

#

# 7.1 Formal tri-objective run

`STATUS: INTEGRATED_FROM_APPROVED_SECTION`

Source section:

`SEC_07_01_formal_R1_run_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

Approved internal verdict:

`SEC_07_01_FORMAL_R1_RUN_v96z_READY_FOR_MASTER_INTEGRATION`

#

## Formal tri-objective run

The formal seed-aware tri-objective run generated a computed nondominated set that represents the trade-off between final moisture ratio, auxiliary energy demand, and the economic/environmental indicators associated with the hybrid solar–LPG tunnel dryer operation. The term computed nondominated set is used deliberately, since the run corresponds to a controlled numerical realization of the multi-objective genetic algorithm and should not be interpreted as a proof of global optimality or statistical robustness over multiple independent seeds.

The evaluated solutions showed the expected conflict between deeper drying and lower auxiliary energy use. Solutions with lower final moisture ratio generally required higher thermal input, whereas energy-saving candidates accepted a higher final moisture ratio while remaining below the feasibility threshold. For this study, the operational feasibility criterion was defined as MR ≤ 0.1, which allows the analysis to distinguish between solutions that achieve sufficient drying and those that remain outside the acceptable final moisture range.

Among the evaluated candidates, R1_solution_7 was identified as the lowest-auxiliary-energy feasible solution. Under the 2-SAH collector-efficiency assumption used in the sensitivity evaluation, this solution reached MR = 0.07057 with Q_aux = 656.23 kWh. Its operating variables were m_dot = 0.070502 kg/s, T_min = 64.429 °C, r_rec = 0.74259, and t_rec_ini = 13.255 h. This combination indicates an energy-saving operating tendency characterized by relatively low airflow, a process temperature close to 65 °C, high recirculation, and recirculation activation during the intermediate-late drying stage.

R1_solution_3 represented a more balanced feasible candidate. It achieved MR = 0.05493 with Q_aux = 723.36 kWh under the same 2-SAH collector-efficiency assumption. Its operating variables were m_dot = 0.075518 kg/s, T_min = 65.054 °C, r_rec = 0.78863, and t_rec_ini = 12.874 h. Compared with R1_solution_7, this point provided deeper drying at the cost of higher auxiliary energy demand, making it useful as a compromise solution when a lower final moisture ratio is preferred.

The historical H2 solution was retained as a reference point because it achieved a lower final moisture ratio than both R1_solution_7 and R1_solution_3. Under the 2-SAH collector-efficiency assumption, H2 reached MR = 0.044483 with Q_aux = 747.00 kWh, using m_dot = 0.07355 kg/s, T_min = 65.879 °C, r_rec = 0.61205, and t_rec_ini = 12.385 h. Although H2 produced deeper drying, it did not correspond to the minimum auxiliary-energy candidate among the feasible solutions. Therefore, H2 should be interpreted as a historical comparison point rather than as the preferred energy-saving operating condition.

R1_solution_9 illustrated the opposite extreme of the trade-off. It achieved the lowest final moisture ratio among the selected points, MR = 0.013876, but required Q_aux = 1218.4 kWh under the 2-SAH collector-efficiency assumption. Its operating variables were m_dot = 0.092264 kg/s, T_min = 67.675 °C, r_rec = 0.43299, and t_rec_ini = 13.829 h. This point confirms that aggressive drying can be achieved, but only with a substantial auxiliary-energy penalty. Consequently, R1_solution_9 was not selected as a recommended operating point.

Overall, the formal R1 run indicates that the preferred operating region is not the deepest-drying condition, but rather a feasible compromise that satisfies MR ≤ 0.1 while reducing auxiliary energy demand. The selected candidates suggest a recurrent operating tendency around low-to-moderate airflow, minimum process temperatures near 64–66 °C, and recirculation activation after the initial drying period. However, this tendency should be interpreted as a result of the present model structure, operational bounds, and seed-aware computed run, not as a universal equipment-level optimum.

#

# 7.2 Collector-efficiency sensitivity

`STATUS: INTEGRATED_FROM_APPROVED_SECTION`

Source section:

`SEC_05_results_eta_sensitivity_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`

Approved internal verdict:

`SEC_05_RESULTS_ETA_SENSITIVITY_v96z_READY_FOR_MASTER_MANUSCRIPT`

#

## Tri-objective optimization results and collector-efficiency sensitivity

The seed-aware formal tri-objective run produced a computed nondominated set that captured the expected trade-off between final moisture ratio, auxiliary energy demand, and the associated economic/environmental indicators. Among the evaluated candidates, solution R1-7 was identified as the most attractive feasible operating point from an energy-saving perspective, whereas solution R1-3 represented a more balanced compromise between deeper drying and auxiliary energy demand. The historical H2 solution remained useful as a comparison point because it achieved a lower final moisture ratio, but it did not correspond to the lowest auxiliary energy requirement among the feasible candidates.

Under the selected feasibility criterion, MR ≤ 0.1, solution R1-7 achieved MR = 0.07057 with an auxiliary energy requirement of 656.23 kWh when the 2-SAH collector-efficiency curve was used. In contrast, the historical H2 point reached a lower MR = 0.04448 but required 747.00 kWh under the same collector-efficiency assumption. Solution R1-3 provided an intermediate behavior, with MR = 0.05493 and Q_aux = 723.36 kWh. These results indicate that the seed-aware run did not merely reproduce the historical H2 operating condition; rather, it identified feasible alternatives that reduce auxiliary energy demand while maintaining the final moisture ratio below the selected acceptability threshold.

A collector-efficiency sensitivity analysis was then performed to evaluate whether the use of a constant solar air heater efficiency could bias the operational selection. Three assumptions were compared: the original constant efficiency η = 0.50, the historical variable-efficiency expression embedded in the code, and the experimentally based 2-SAH efficiency curve, which is the configuration most consistent with the physical arrangement of the solar field batteries. The 2-SAH curve reduced the auxiliary energy demand by approximately 5–8% relative to the constant-efficiency case for the evaluated candidates. For example, Q_aux decreased from 807.02 to 747.00 kWh for H2, from 707.17 to 656.23 kWh for R1-7, from 787.59 to 723.36 kWh for R1-3, and from 1286.6 to 1218.4 kWh for R1-9.

Although the absolute auxiliary energy values were affected by the collector-efficiency assumption, the operational ranking was preserved. R1-7 remained the lowest-auxiliary-energy feasible candidate under MR ≤ 0.1, R1-3 remained the balanced feasible candidate, H2 remained a deeper-drying historical reference, and R1-9 remained an aggressive drying solution with high auxiliary demand. This result suggests that the main operational conclusion is not an artifact of the fixed-efficiency assumption. However, the analysis also shows that the collector model has a non-negligible effect on the energy balance; therefore, a fully coupled solar collector model remains a relevant improvement for future work.

This collector-efficiency analysis is a sensitivity test applied to the selected operating points. It should not be interpreted as a fully coupled collector model, because the collector subsystem, airflow-dependent heat-transfer coefficients, fan power, and pressure-drop effects were not re-optimized simultaneously.

#

## 7.2.1 Hybrid versus gas-LPG baseline comparison

`STATUS: INTEGRATED_FROM_APPROVED_SECTION_v01_1`

Source section:

`SEC_07_02_01_hybrid_vs_gasLP_baseline_v96z.md`

Source analysis:

- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z_summary.md`
- `SELECTED_POINTS_HYBRID_vs_GASLP_v96z_report.md`

Approved internal verdict:

`SEC_07_02_01_HYBRID_vs_GASLP_BASELINE_v96z_READY_FOR_MASTER_OR_SUPPLEMENTARY_INTEGRATION`

A pointwise baseline comparison was performed to quantify the auxiliary-energy reduction obtained by operating the selected candidates in hybrid mode instead of gas-LPG-only mode. This comparison was not a new optimization run. The same selected operating points were evaluated under both operation modes using the 2-SAH collector-efficiency curve for the hybrid case. The purpose was to isolate the contribution of the solar field to the auxiliary-energy balance while preserving the selected decision-variable combinations.

For all selected candidates, hybrid operation reduced the auxiliary energy demand relative to the gas-LPG-only case while maintaining the final moisture ratio below the feasibility threshold. The reduction in auxiliary energy ranged from 31.31% to 45.05%. For the historical H2 point, Q_aux decreased from 1292.6 kWh in gas-LPG-only mode to 747.00 kWh in hybrid mode, corresponding to a 42.21% reduction. For R1_solution_7, the energy-saving feasible candidate, Q_aux decreased from 1194.1 kWh to 656.23 kWh, corresponding to the largest relative reduction among the selected points, 45.05%. For R1_solution_3, Q_aux decreased from 1270.6 kWh in gas-LPG-only mode to 723.36 kWh in hybrid mode, corresponding to a 43.07% reduction. For R1_solution_3, Q_aux decreased from 1270.6 kWh in gas-LPG-only mode to 723.36 kWh in hybrid mode, corresponding to a 43.07% reduction. For R1_solution_9, Q_aux decreased from 1773.9 kWh in gas-LPG-only mode to 1218.4 kWh in hybrid mode, corresponding to a 31.31% reduction. The lower relative reduction observed for R1_solution_9 is consistent with its more aggressive drying condition and higher auxiliary-energy demand.

The final moisture ratios remained very similar between the hybrid and gas-LPG-only evaluations. This indicates that the hybrid configuration reduced auxiliary energy demand mainly by replacing part of the thermal requirement with solar contribution, rather than by relaxing the drying performance. In particular, R1_solution_7 remained feasible under both operation modes, with MR = 0.07057 in hybrid mode and MR = 0.071992 in gas-LPG-only mode. Therefore, the hybrid mode improved the energy balance of the selected operating points without compromising the moisture-ratio feasibility criterion.

These results provide a direct baseline interpretation of the selected candidates. They support the use of R1_solution_7 as the primary energy-saving operating point, since it combined the lowest hybrid auxiliary-energy demand with the largest relative reduction compared with the gas-LPG-only baseline. The comparison also reinforces the role of R1_solution_3 as a balanced feasible alternative and confirms that R1_solution_9, although technically feasible in terms of final moisture ratio, remains energetically unattractive.

#

# 7.3 Operational interpretation

`STATUS: INTEGRATED_FROM_APPROVED_SECTION`

Source section:

`SEC_07_03_operational_interpretation_v96z.md`

Source sections:

- `SEC_07_01_formal_R1_run_v96z.md`
- `SEC_05_results_eta_sensitivity_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

Approved internal verdict:

`SEC_07_03_OPERATIONAL_INTERPRETATION_v96z_READY_FOR_MASTER_INTEGRATION`

#

## Operational interpretation

The selected operating points suggest a consistent operational tendency for the hybrid solar–LPG tunnel dryer. The recommended feasible candidates are not located at the highest airflow or highest process temperature bounds. Instead, the most attractive solutions combine low-to-moderate airflow, minimum process temperatures close to 65 °C, high recirculation ratios, and recirculation activation after the initial drying period. This behavior is physically consistent with a drying process in which auxiliary energy demand can be reduced by avoiding excessive fresh-air heating while still maintaining enough thermal driving force for moisture removal.

R1_solution_7 is the clearest energy-saving candidate. Its airflow was the lowest among the selected feasible points, m_dot = 0.070502 kg/s, while its minimum process temperature remained close to 65 °C. The high recirculation ratio, r_rec = 0.74259, indicates that a large fraction of the process air was reused once recirculation was activated. Its recirculation start time, t_rec_ini = 13.255 h, suggests that the model favors allowing the early drying stage to proceed with lower recirculation influence and then increasing air reuse during a later stage, when the marginal benefit of heating fresh air becomes less favorable.

R1_solution_3 followed a similar operating pattern but shifted toward deeper drying. It used a slightly higher airflow, m_dot = 0.075518 kg/s, and a similar minimum process temperature, T_min = 65.054 °C, with an even higher recirculation ratio, r_rec = 0.78863. This combination produced a lower final moisture ratio than R1_solution_7, but required additional auxiliary energy. Therefore, R1_solution_3 can be interpreted as a balanced candidate when deeper drying is preferred over maximum auxiliary-energy reduction.

The historical H2 point occupied an intermediate position in terms of airflow and temperature, but it used a lower recirculation ratio than the R1 energy-saving candidates. Although H2 achieved a lower final moisture ratio, its auxiliary energy demand was higher than that of R1_solution_7. This suggests that the formal run did not simply reproduce the historical operating condition; rather, it identified operating combinations with greater air reuse that reduced auxiliary energy while maintaining acceptable final moisture.

R1_solution_9 represents a different regime. Its higher airflow and higher minimum temperature produced the deepest drying among the selected candidates, but this came with a substantial auxiliary-energy penalty. This point illustrates that increasing the thermal and airflow intensity can reduce the final moisture ratio, but the resulting operating condition may be unattractive from an energy-saving perspective. Therefore, R1_solution_9 is useful for understanding the trade-off boundary but should not be interpreted as a recommended operating condition.

Overall, the selected candidates indicate that the relevant operational trade-off is not simply between drying and no drying, but between sufficient drying and excessive thermal expenditure. Within the present model and operating bounds, the preferred region is characterized by maintaining the final moisture ratio below the feasibility threshold while avoiding unnecessarily aggressive drying. The resulting tendency toward low-to-moderate airflow, process temperatures near 64–66 °C, high recirculation, and delayed recirculation activation should be interpreted as a model-based operating recommendation. It should not be generalized without additional experimental validation, fan-power coupling, pressure-drop modeling, and independent optimization replications.

#

# 7.4 Methodological implications

`STATUS: INTEGRATED_FROM_APPROVED_SECTION`

Source section:

`SEC_07_04_methodological_implications_v96z.md`

Source sections:

- `SEC_07_01_formal_R1_run_v96z.md`
- `SEC_05_results_eta_sensitivity_v96z.md`
- `SEC_07_03_operational_interpretation_v96z.md`

Source tables:

- `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md`
- `SUPP_TABLE_ETA_SENSITIVITY_v96z.md`
- `ETA_SENSITIVITY_v96z_H2_R1_selected_consolidated.csv`

Approved internal verdict:

`SEC_07_04_METHODOLOGICAL_IMPLICATIONS_v96z_READY_FOR_MASTER_INTEGRATION`

#

## Methodological implications

The results have several methodological implications for the interpretation of the optimization framework. First, the selected operating condition should be understood as a model-based recommendation derived from a controlled computed nondominated set, not as a universal or experimentally proven optimum. The formal seed-aware run provided a structured comparison among feasible candidates and helped identify R1_solution_7 as the lowest-auxiliary-energy feasible point among the selected solutions. However, additional independent seed replications would be required before making claims about statistical robustness of the computed front.

Second, the collector-efficiency sensitivity analysis showed that the solar air heater representation has a measurable effect on the absolute auxiliary-energy balance. Replacing the constant efficiency assumption with the 2-SAH collector-efficiency curve reduced the auxiliary energy demand by approximately 5–8% for the evaluated candidates. Therefore, the fixed-efficiency assumption should not be treated as physically neutral. It affects the magnitude of the solar contribution and the auxiliary-energy requirement.

Nevertheless, the same sensitivity analysis also showed that the operational ranking was preserved. R1_solution_7 remained the lowest-auxiliary-energy feasible candidate, R1_solution_3 remained a balanced feasible alternative, H2 remained a deeper-drying historical reference, and R1_solution_9 remained an aggressive drying case with high auxiliary-energy demand. This indicates that the main operating conclusion is not merely an artifact of using a fixed collector efficiency. The conclusion is more appropriately stated as ranking-stable under the tested collector-efficiency assumptions, rather than universally robust.

Third, the results highlight the importance of distinguishing between process-level and equipment-level optimization. In the present model, the mass flow rate influences drying and thermal behavior, but fan power and pressure drop are not fully coupled to airflow. Consequently, the preference for low-to-moderate airflow should be interpreted as a process-model tendency, not as a complete equipment-level optimum. A more complete formulation should include fan performance, pressure losses, duct characteristics, and the electrical consumption associated with air movement.

Fourth, the recirculation strategy appears to be a relevant operational degree of freedom. The selected feasible candidates favored high recirculation ratios with activation after the initial drying period. This suggests that recirculation timing is not merely a secondary parameter, but an important mechanism for reducing auxiliary energy while maintaining sufficient drying. Future optimization studies should therefore avoid treating recirculation only as a fixed operating condition and should consider both its magnitude and activation time as decision variables.

Finally, the present results support using the R1 candidates as structured operating references for future experimental or simulation campaigns. R1_solution_7 is the primary energy-saving candidate, R1_solution_3 is the balanced feasible alternative, H2 is the historical comparison point, and R1_solution_9 is useful as an aggressive-drying boundary case. These candidates provide a compact experimental matrix for future validation, provided that the collector model, fan-power model, and cost/emissions factors are updated and fully traced before publication-level claims are made.

## 7.5 Discussion

The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate that the most relevant operating region is not defined by a single extreme drying condition, but by a trade-off between final moisture reduction, auxiliary energy demand, and the imposed process constraints. Within the computed nondominated set, R1_solution_7 represents the most energy-conservative feasible candidate among the selected R1 points, whereas R1_solution_3 provides a more balanced compromise between drying intensity and energy use. By contrast, R1_solution_9 illustrates the expected penalty of pursuing deeper drying through a more aggressive thermal strategy. This separation is useful because it avoids treating all feasible low-moisture solutions as operationally equivalent.

The comparison with the historical H2 operating point also clarifies the interpretation of the optimization results. H2 remains a useful reference because it reflects a previously identified low-moisture operating condition and provides continuity with earlier analysis. However, it should not be interpreted as a newly optimized R1 solution. The R1 candidates instead show that comparable feasibility can be reached with operating strategies that shift the balance toward lower auxiliary energy demand. This is particularly relevant for process operation, where the preferred condition is not necessarily the one producing the lowest final moisture ratio, but the one satisfying the drying target with the lowest practical energy penalty.

The collector-efficiency sensitivity analysis supports the qualitative stability of this interpretation. Using the 2-SAH efficiency curve, which is consistent with the physical arrangement of two solar air heaters in series per battery, changed the magnitude of the auxiliary-energy requirement but did not overturn the selected-point ranking. This suggests that the main operational conclusion is not solely an artifact of assuming a fixed collector efficiency. Nevertheless, the collector treatment remains a sensitivity model rather than a fully coupled dynamic collector simulation. The result should therefore be read as evidence of ranking stability under a more physically consistent efficiency assumption, not as complete collector-level validation.

The hybrid versus gas-LPG baseline comparison further shows that the hybrid configuration reduces the auxiliary-energy requirement for the selected feasible operating points. The reduction is mainly attributable to solar substitution rather than to a relaxation of the drying requirement, because the compared cases preserve feasible final moisture-ratio behavior. This reinforces the practical value of the hybrid system: the solar contribution can reduce fuel demand while maintaining drying feasibility. At the same time, the magnitude of any final economic or CO2 benefit remains conditional on the final fuel-price, electricity-tariff, emission-factor, date, region, unit-basis, and conversion assumptions.

From an operational standpoint, the results favor a moderate-to-low airflow range combined with high recirculation and an intermediate-late onset of recirculation for the feasible energy-saving candidates. This trend is physically plausible because recirculation can retain useful thermal energy in the drying loop while avoiding excessive fresh-air heating demand. However, this interpretation is bounded by the implemented model structure and by the absence of a fully coupled fan-power and pressure-drop formulation. Future optimization should therefore include airflow-distribution, fan-power, and pressure-drop penalties before making equipment-level design recommendations.

Overall, the computed results support the hybrid dryer as an energy-saving operating strategy under the modeled conditions, with R1_solution_7 as the main energy-conservative candidate and R1_solution_3 as a balanced alternative. The discussion should not be interpreted as evidence of statistical robustness across independent seeds, proof of complete convergence of the search space, or complete equipment-level optimality. Rather, it establishes a controlled, reproducible, and traceable basis for selecting candidate operating points for further validation and for future coupled techno-economic and environmental assessment.
20

# 8. Limitations

Several limitations must be considered when interpreting the optimization and baseline-comparison results. First, the formal multiobjective analysis was based on a single controlled seed-aware R1 execution of MATLAB's `gamultiobj` algorithm. Although this run produced a computed nondominated set under the specified configuration, it does not establish statistical robustness across independent random seeds, nor does it constitute proof of complete convergence of the search space. Additional independent seed replications would be required to quantify the sensitivity of the selected candidates to stochastic initialization and evolutionary-search variability.

Second, the collector-efficiency analysis was implemented as a sensitivity assessment rather than as a fully coupled dynamic collector model. The 2-SAH efficiency curve was used because it is consistent with the physical arrangement of two solar air heaters in series per battery; however, this treatment does not replace a fully coupled collector, airflow, pressure-drop, and thermal-network simulation. Consequently, the observed stability of the selected operating-point ranking across collector-efficiency assumptions should be interpreted as sensitivity evidence, not as complete equipment-level validation.

Third, fan-power consumption and pressure-drop effects were not fully coupled as optimization objectives. The current optimization therefore focuses on process-level drying performance, auxiliary energy demand, cost, and CO2 indicators as represented in the implemented model, but it should not be interpreted as a complete equipment-level optimum. A future coupled formulation should include fan power, pressure drop, and airflow-distribution effects to refine the techno-economic and environmental assessment.

Fourth, economic and CO2 indicators depend on external factors such as fuel price, electricity tariff, emission factor, source year, region, unit basis, and conversion assumptions. The provisional CO2 factors `EF_LPG_kgCO2_per_kWh = 0.2270` and `EF_grid_kgCO2_per_kWh = 0.4380` were retained only for code validation and internal traceability under the tag `PROVISIONAL_FOR_CODE_VALIDATION`. Final cost or CO2 claims require definitive cited sources and locked conversion bases before submission. Until those factors are finalized, the most robust interpretation is based on energy-demand trends and relative comparisons.

Finally, solar-only operation was excluded from the formal multiobjective comparison because it represents a non-equivalent operating mode relative to the hybrid and gas-LPG baseline cases. Likewise, the H2 point was retained as a historical reference and not treated as a newly optimized R1 solution. These distinctions were maintained to avoid mixing non-equivalent operating modes or historical references with the formal R1 candidate set.

The R1 run terminated with `exitflag 0`, corresponding to the prescribed generation limit rather than a convergence-failure interpretation.
20

# 9. Conclusions

This study developed a controlled multiobjective optimization and post-processing workflow for a hybrid solar--gas-LPG tunnel dryer, with explicit traceability between the formal R1 optimization, collector-efficiency sensitivity, and hybrid versus gas-LPG baseline comparison. Under the modeled conditions, the hybrid configuration showed a consistent ability to reduce auxiliary-energy demand while preserving feasible drying performance for the selected operating points.

Within the computed nondominated set, R1_solution_7 emerged as the main energy-conservative feasible candidate, whereas R1_solution_3 provided a balanced alternative between drying intensity and energy use. R1_solution_9 represented a more aggressive drying strategy with a larger energy penalty, and H2 was retained only as a historical reference rather than as a newly optimized R1 solution. This distinction supports an operational interpretation based on feasible trade-offs instead of selecting the deepest-drying point by default.

The collector-efficiency sensitivity analysis, particularly the 2-SAH curve consistent with the physical series arrangement of the solar air heaters, did not alter the qualitative ranking of the selected candidates. This supports the stability of the main operational interpretation under a more physically consistent collector-efficiency assumption. However, the collector treatment remains a sensitivity representation and not a fully coupled dynamic collector model.

The hybrid versus gas-LPG comparison indicated that the solar contribution can reduce auxiliary-energy demand mainly through fuel substitution, not by relaxing the drying requirement. Consequently, the hybrid system should be interpreted as a promising energy-saving operating strategy under the current model assumptions. Final economic or CO2 claims should remain conditional until fuel-price, electricity-tariff, emission-factor, date, region, unit-basis, and conversion assumptions are definitively sourced and locked.

The main methodological limitations are associated with the use of a single formal R1 seed-aware run, the absence of independent seed replications, the sensitivity-level collector treatment, and the lack of fully coupled fan-power and pressure-drop objectives. Future work should therefore evaluate additional random seeds, implement a coupled collector and airflow-network formulation, include fan-power and pressure-drop penalties, and finalize the economic and emission factors before making publication-grade cost or CO2 claims.

Overall, the results provide a reproducible and traceable basis for selecting candidate operating points for subsequent experimental or high-fidelity numerical validation. The conclusions should not be interpreted as proof of complete search-space convergence, statistical robustness across seeds, or complete equipment-level optimality.

# 10. Nomenclature

`STATUS: DRAFT_READY_FOR_REVIEW`

## Symbols

- `m_dot`: air mass flow rate used as an operational decision variable, kg/s.
- `MR`: moisture ratio; terminal drying-performance indicator used for feasibility assessment.
- `Q_aux`: auxiliary thermal energy demand assigned to the LPG heating system, kWh.
- `r_rec`: air recirculation ratio; fraction of outlet air returned to the process stream after recirculation starts.
- `T_min`: minimum process-air temperature imposed by the operating policy, °C.
- `t_rec_ini`: recirculation start time; time at which the recirculation branch is activated, h.
- `CO2`: carbon dioxide equivalent indicator used in conditional environmental post-processing.

## Abbreviations and labels

- `2-SAH`: two solar air heaters in series; collector-efficiency representation used in the sensitivity analysis.
- `GA`: genetic algorithm.
- `H2`: historical reference operating point retained for comparison; not a newly optimized R1 solution.
- `LPG`: liquefied petroleum gas used by the auxiliary heating system.
- `R1`: formal controlled optimization run used to generate the reported computed nondominated set.
- `R1_solution_3`: selected balanced feasible R1 candidate.
- `R1_solution_7`: selected energy-conservative feasible R1 candidate.
- `R1_solution_9`: selected aggressive drying R1 candidate with higher auxiliary-energy demand.
- `SAH`: solar air heater.

## Interpretation notes

- The notation `computed nondominated set` refers to the numerical set obtained under the specified GA configuration, seed, decision-variable bounds, and model assumptions; it is not used as a claim of a complete global Pareto front.
- Economic and CO2-related quantities remain conditional until final source-locked prices, tariffs, emission factors, regional scope, unit basis, source year, and conversion factors are fixed.

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

#

# Approved sections

| Section file | Status | Notes |
|---|---|---|
| `SEC_05_results_eta_sensitivity_v96z.md` | Approved | Collector-efficiency sensitivity and R1 selected candidates |

#

# Approved tables

| Table file | Status | Use |
|---|---|---|
| `MANUSCRIPT_TABLE_R1_ETA_2SAH_v96z.md` | Approved | Main Results table |
| `SUPP_TABLE_ETA_SENSITIVITY_v96z.md` | Approved | Supplementary sensitivity table |

#

# Restrictions

- Do not claim proof of global optimality.
- Do not claim statistical robustness from one seed-aware formal run.
- Use “computed nondominated set” instead of “complete Pareto-front characterization”.
- Keep H2 as historical comparison, not as final optimum.
- Treat 2-SAH collector curve as sensitivity, not as fully coupled collector model.
- Keep cost and CO2 provisional until factors and calculation path are fully traced.20

### Reproducibility configuration of the formal multiobjective run

The formal multiobjective optimization run used to generate the selected candidate solutions was configured as a controlled seed-aware execution of MATLAB's `gamultiobj` algorithm. The run, identified as R1, used a fixed random seed of 61001, a population size of 24 individuals, and a maximum generation limit of 50 generations. The algorithm terminated with `exitflag = 0`, corresponding to termination by the prescribed generation limit. Therefore, the resulting solution set is interpreted as a computed nondominated set obtained under the specified configuration, not as proof of global convergence or global optimality.

The optimization problem was formulated with three objectives: final moisture ratio, economic performance, and CO2 emissions. The decision variables were the air mass flow rate `m_dot`, the minimum control temperature `T_min`, the recirculation ratio `r_rec`, and the recirculation onset time `t_rec_ini`. Candidate feasibility was evaluated using the final moisture-ratio threshold MR <= 0.1. The formal run was performed for hybrid solar--gas-LPG operation; solar-only operation was not included in the formal multiobjective comparison because it represents a non-equivalent operating mode.

The R1 run required approximately 25.4 h of wall-clock computation. The selected operating points discussed in the Results section include R1_solution_7 as the energy-saving feasible candidate, R1_solution_3 as a balanced feasible candidate, and R1_solution_9 as an aggressive drying boundary case. The historical H2 point was retained only as a reference case and was not treated as a newly optimized R1 solution. Since the present manuscript is based on a single controlled seed-aware formal run, no claim of statistical robustness is made. Additional independent seed replications would be required to support such a claim.
20

### Traceability of economic and CO2 factors

Economic and environmental indicators were handled through a separate factor-traceability matrix in order to distinguish computed model outputs from source-dependent conversion factors. The auxiliary energy values reported for the selected operating points are treated as computed outputs of the drying model and post-processing workflow. In contrast, cost and CO2 indicators depend on external factors such as fuel price, electricity tariff, emission factor, source year, region, unit basis, and conversion assumptions.

For code validation and internal traceability control, the provisional CO2 factors `EF_LPG_kgCO2_per_kWh = 0.2270` and `EF_grid_kgCO2_per_kWh = 0.4380` were retained under the tag `PROVISIONAL_FOR_CODE_VALIDATION`. These factors are not treated as final manuscript-grade emission factors. Before submission, each final cost or CO2 claim must be linked to a definitive source, date, unit basis, and conversion procedure. Therefore, the present results should be interpreted primarily through the reported energy demand and relative comparisons unless the corresponding final economic and emission factors are explicitly cited and locked.

The same traceability control applies to equipment-level effects. Fan-power consumption and pressure-drop coupling were not fully included as optimization objectives; consequently, the present economic and environmental indicators should not be interpreted as complete equipment-level optimality claims. These effects are retained as methodological limitations and as future-work requirements for a fully coupled techno-economic and environmental assessment.
20
