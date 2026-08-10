# Finite-set characterization of operational trade-offs in hybrid solar–LPG drying of red chilli under corrected cost–emissions objectives

## Abstract

Hybrid solar–LPG drying couples thermal supply with airflow and recirculation decisions, creating operational conflicts that cannot be represented by moisture removal alone. This computational study characterizes the finite-set trade-offs among final moisture ratio (`f1`), modeled specific operating-energy cost (`f2`, USD/kg water removed), and modeled specific operational greenhouse-gas emissions (`f3`, kg CO2e/kg water removed) for red chilli in a forced-convection dryer. Four operating variables were considered: the base air mass-flow parameter, minimum process-air temperature, recirculation fraction, and recirculation start time. Two nine-solution sets were evaluated under the same corrected COST-E3D formulation: historical R1 decision vectors reevaluated under the corrected formulation (H) and solutions generated directly under it (C).

All nine members of each set were internally nondominated. Of the 81 cross-set comparisons, 78 were incomparable, C dominated H in one pair, H dominated C in two pairs, and no objective vectors were exactly equal. Set coverage was 1/9 for C over H and 2/9 for H over C. Joint nondominated sorting retained eight H and seven C solutions in Rank 1. Relative to H, C had a 33.807% lower median `f1`, accompanied by 3.200% and 3.859% higher median `f2` and `f3`, respectively. C occupied narrower observed marginal intervals and introduced no new marginal extrema, whereas H retained all observed marginal extrema. At the primary normalized reference point, anchored hypervolume was 0.974982 for H and 1.009963 for C; the direction C > H was unchanged at the two additional prespecified reference points.

The results indicate trade-off restructuring rather than uniform replacement of the historical set. Lower final moisture in C was descriptively associated with a higher thermal setpoint and different airflow and recirculation management, with moderate penalties in modeled specific operating-energy cost and operational greenhouse-gas emissions. These conclusions apply only to the 18 evaluated solutions from one corrected run and a historical reevaluated set at a common fixed 19.9 h horizon. The emissions indicator includes direct LPG-combustion CO2 and indirect grid-electricity CO2e normalized by water removed; it is not a life-cycle carbon footprint, a complete greenhouse-gas inventory, or total environmental impact.

**Keywords:** hybrid solar–LPG dryer; operational trade-offs; finite solution sets; multiobjective optimization; air recirculation; operating-energy cost; operational greenhouse-gas emissions; historical-solution reevaluation

## 1. Introduction

Drying performance in hybrid solar–fuel systems depends on the interaction among solar availability, auxiliary heat, airflow, temperature control, and exhaust-air management. Hybridization can reduce reliance on auxiliary fuel, but the resulting operating problem is not resolved by maximizing solar input or minimizing final moisture in isolation. Temperature and airflow affect drying kinetics and energy demand, while recirculation changes the balance between heat recovery, moisture removal, and fresh-air heating. Recent reviews therefore emphasize integrated evaluation of energy, cost, product, and emissions indicators, together with explicit functional units and system boundaries (Pereira et al., 2026).

Solar–LPG drying is established in the literature. Experimental and industrial studies have reported solar–LPG or thermosolar–LPG dryers, their energy performance, and their economic context (Murali et al., 2020; Ortiz-Rodríguez et al., 2020; César-Munguía et al., 2023). Controlled air circulation and the combined effects of temperature and air-change rate have also been examined in solar–LPG equipment (Khater et al., 2024). Accordingly, neither the hybrid solar–LPG platform nor the study of temperature and airflow is treated here as a standalone novelty claim.

Multiobjective optimization is likewise established in drying. Previous work has combined drying temperature and air velocity with genetic or nondominated-sorting methods (Winiczenko et al., 2018), applied genetic algorithms to hybrid solar–gas–electric drying (El Ferouali et al., 2018), and considered three-objective dryer formulations involving moisture, operating cost, released heat, environmental impact, or product quality (Oviedo et al., 2021; Zhang et al., 2022). The contribution of the present study is therefore narrower: a system-level, finite-set characterization of the operational conflict among drying performance, modeled specific operating-energy cost, and modeled specific operational greenhouse-gas emissions under coupled thermal and air-management decisions.

A second, more distinctive question arises from correction of an objective formulation after historical candidates have already been generated. Within the drying literature identified by the targeted positioning search, no direct precedent was located for preserving historical decision vectors, reevaluating those same vectors under a corrected cost–emissions formulation, generating candidates directly under that corrected formulation, and quantifying the survival and restructuring of the historical trade-offs. This is a bounded literature finding, not proof that no precedent exists outside the targeted search.

The study addresses two questions:

1. How are drying performance, modeled specific operating-energy cost, and modeled specific operational greenhouse-gas emissions traded off across the evaluated combinations of thermal and air-management decisions in the hybrid solar–LPG dryer?
2. How does the observed finite-set trade-off structure change when historical solutions are reevaluated under corrected COST-E3D and compared with solutions obtained directly under that corrected formulation?

The working hypothesis is that stronger drying within the evaluated solutions is associated with moderately higher modeled specific operating-energy cost and operational greenhouse-gas emissions, and that direct corrected optimization restructures rather than uniformly replaces the historical reevaluated trade-offs. The finite-set scope is constitutive: the manuscript characterizes 18 evaluated solutions and does not generalize their geometry to the full decision space.

## 2. System description and model basis

### 2.1 Hybrid dryer architecture

The modeled equipment is a forced-convection tunnel dryer with direct air heating. The process-air circuit combines a solar air-heating field, an LPG auxiliary heater, a drying chamber, an exhaust path, and a controlled recirculation branch. The water circuit and pumps are outside the modeled boundary. The electrical scope is limited to the air impeller, represented by an active power of 1.03 kW throughout the drying period. The LPG burner efficiency is 0.78 (César-Munguía et al., 2023); therefore, `Q_aux_tot` denotes useful supplementary heat and the corresponding LPG fuel input is `Q_aux_tot/0.78`.

The four-state lumped tunnel model represents process-air temperature, product temperature, product moisture ratio, and an equivalent structural temperature. The plant architecture, component mass and energy balances, and four-equation tunnel formulation follow the integral model of González-Bravo et al. (2024), which was validated against pineapple experiments at the Xochitepec plant with reported average relative errors below 5% and a maximum relative error of 7%. The present red-chilli application replaces the product kinetics with literature-based single-layer drying kinetics (Hossain et al., 2007). It preserves the coupled heat- and mass-transfer structure required to compare operating policies under a common model, but it does not resolve local spatial gradients within the tunnel. The cited validation applies to the pineapple model antecedent; no experimental validation of the present red-chilli simulations is claimed. The corrected objectives and current comparative results are governed by COST-E3D and the frozen D016–D020 evidence.

### 2.2 Decision variables and bounds

The canonical decision vector is

$$
\mathbf{x}=[m_{\max},T_{\min},r_{\mathrm{div2}},t_{\mathrm{rec,ini}}].
$$

Here, `m_max` is the base air mass-flow parameter (kg/s), `T_min` is the minimum process-air temperature before the final operating stage (°C), `r_div2` is the recirculated fraction of the outlet stream, and `t_rec_ini` is the recirculation start time (h). Because recirculation changes flows within the circuit, `m_max` is not interpreted as a constant effective flow everywhere in the simulation.

The frozen lower and upper bounds were

$$
\mathbf{l}=[0.0540767982118,57.6832965028,0.422252618341,8.6517528081]
$$

and

$$
\mathbf{u}=[0.0940767982118,67.6832965028,0.922252618341,14].
$$

## 3. Methods

### 3.1 Corrected COST-E3D objective formulation

All objectives were minimized:

$$
f_1=MR_{\mathrm{final}},
$$

$$
f_2=\frac{\mathrm{total\_cost\_USD}}{\mathrm{water\_removed\_kg}},
$$

and

$$
f_3=\frac{\mathrm{total\_CO2\_kg}}{\mathrm{water\_removed\_kg}}.
$$

The common functional denominator was the water actually removed,

$$
\mathrm{water\_removed\_kg}=(M_i-M_{\mathrm{terminal}})m_d.
$$

In manuscript terminology, `f2` is the **modeled specific operating-energy cost** in USD/kg water removed. It includes the modeled operating-energy components and excludes capital investment, maintenance, labor, fixed charges, total cost of ownership, and comprehensive commercial process cost.

The computational name of `f3` is `CO2_specific_kgCO2_per_kgwater`. In manuscript terminology it is the **modeled specific operational greenhouse-gas emissions**, reported in kg CO2e/kg water removed. Its boundary comprises direct LPG-combustion CO2 plus indirect grid-electricity CO2e, normalized by water removed. It is not a life-cycle carbon footprint, a complete greenhouse-gas inventory, or total environmental impact. No embodied solar-equipment emissions are included.

The implemented emissions factors are 3.00 kg CO2/kg LPG for direct combustion, based on the Mexican fuel-factor study of INECC and IMP (2014), and 0.444 kg CO2e/kWh for grid electricity, corresponding to the official 2024 National Electric System factor (SEMARNAT, 2025). The June 2026 economic basis comprises 19.46 MXN/kg LPG for Xochitepec, 46.16 MJ/kg LPG lower heating value, 0.0717182253966247 USD/kWh for the GDMTO energy-only variable charge in CFE Division Centro Sur, 0.0126515761642454 USD/MJ for the INPC-restated solar-thermal proxy, and a Banco de México FIX mean of 17.3819136364 MXN/USD. The official bases are the June 2026 LPG-price series of the Comisión Nacional de Energía (CNE), the June 2026 CFE/CNE tariff annex, the Banco de México FIX series, the 2018 CONUEE/ANES/GIZ solar-thermal report, and the June 2026 INPC (CNE, 2026; Comisión Federal de Electricidad & Comisión Nacional de Energía, 2026; Banco de México, 2026; Ortega, 2018; INEGI, 2026). These are controlled model inputs, not a complete plant bill, commercial quotation, or life-cycle costing exercise.

Table 1 summarizes the objective definitions and interpretation boundaries.

### 3.2 Construction of the finite comparison sets

The historical set

$$
H=\{(\mathbf{x}_i^H,\mathbf{F}_i^H)\}_{i=1}^{9}
$$

contains the nine historical R1 decision vectors reevaluated under corrected COST-E3D. These vectors were not generated by direct optimization of the corrected formulation. The corrected set

$$
C=\{(\mathbf{x}_j^C,\mathbf{F}_j^C)\}_{j=1}^{9}
$$

contains nine solutions generated directly under corrected COST-E3D. The combined dataset `U=H∪C` therefore contains 18 evaluated solutions. Index equality does not imply pairing between `H_i` and `C_i`.

The corrected run used MATLAB `gamultiobj` as a search instrument with seed 61001 (`twister`), population size 24, maximum generations 50, four decision variables, `UseParallel=false`, function tolerance `1e-5`, and constraint tolerance `1e-6`. It stopped after reaching the specified generation limit (`exitflag=0`) after 50 generations and 1200 function evaluations; solver runtime was 3.4175 h. The run yielded nine finite, unpenalized solutions. Reaching the generation limit is not evidence of convergence.

### 3.3 Descriptive finite-set analysis

Decision and objective spaces were summarized separately for H and C using minima, maxima, means, medians, population standard deviations (`ddof=0`), ranges, and Hyndman–Fan type-7 quartiles. Differences between medians describe these two finite sets only. The nine members of each set are not independent optimizer or experimental replicates; consequently, no significance tests or confidence intervals were applied.

### 3.4 Dominance, coverage, and joint sorting

For minimization, solution `a` dominated solution `b` when `a` was no worse in all three objectives and strictly better in at least one. Dominance was evaluated at full stored precision without tolerance. A separate numerical diagnostic used

$$
\tau_k(a,b)=10^{-12}\max(1,|f_k(a)|,|f_k(b)|)
$$

to identify near ties and potentially fragile strict inequalities; it did not alter dominance or rank.

Internal dominance was evaluated independently within H and C. Cross-set analysis classified all 81 H×C pairs as C-dominates-H, H-dominates-C, incomparable, or exactly equal. Directional set coverage was computed as the fraction of a target set dominated by at least one member of the source set, following the asymmetric coverage concept of Zitzler and Thiele (1999). Exact nondominated sorting was then applied to the 18-member union to identify joint Rank 1 and subsequent layers (Deb et al., 2002). These citations define the analysis concepts; they do not identify MATLAB `gamultiobj` as a literal implementation of NSGA-II.

### 3.5 Objective-space geometry and anchored hypervolume

Observed marginal intervals and extrema were compared for all three objectives. Hypervolume was used only as a secondary metric because neither directional coverage equaled complete one-way replacement. H and C were normalized with common objective anchors derived from the union of their internally nondominated members. Hypervolume was evaluated at the prespecified normalized reference points `r5=(1.05,1.05,1.05)`, `r10=(1.10,1.10,1.10)`, and `r20=(1.20,1.20,1.20)`, with `r10` designated as primary. Hypervolume here measures anchored coverage of the normalized objective region (Zitzler and Thiele, 1999). Because hypervolume values depend on the reference point, the common anchors and three prespecified references were applied identically to H and C, and the directional result was checked across all three (Ishibuchi et al., 2018). The metric does not measure distance to an independently established reference front and does not demonstrate convergence.

### 3.6 Common terminal regime and decomposition evidence

All 18 evaluations reached the common nominal maximum horizon of 19.9 h. Historical files serialize this as `19.900000000000006 h`, whereas corrected files serialize it as `19.9 h`; the frozen D014 convention treats both as the same nominal TMAX regime without introducing a numerical tolerance into dominance. This establishes a common fixed horizon, not identical temporal trajectories or free normal termination.

Validated decomposition evidence was available for all 18 solutions for useful auxiliary heat, LPG input energy and mass, LPG cost, solar cost, air-impeller electricity, electricity cost, water removed, total modeled cost, and total modeled emissions. Physical irradiance was not unambiguously persisted. Separate LPG and electricity emissions components were persisted for H but not for C; environmental comparison of C is therefore limited to total modeled operational emissions and the persisted energy inputs.

## 4. Results

### 4.1 Decision-space shifts

The finite C set shifted toward lower median `m_max`, higher median `T_min`, lower median `r_div2`, and earlier median recirculation start relative to H. Median `m_max` decreased from 0.0790661 to 0.0745256 kg/s, median `T_min` increased from 65.6963 to 67.3130 °C, median `r_div2` decreased from 0.768305 to 0.638580, and median `t_rec_ini` decreased from 13.2180 to 12.6029 h. These shifts correspond to `C−H` differences of −0.00454057 kg/s, +1.61673 °C, −0.129725, and −0.615121 h, respectively.

These medians characterize the two evaluated sets; they do not isolate the effect of any one decision variable. The decision-space values and objective shifts are provided together in Supplementary Table S1.

### 4.2 Objective-space shifts

Median `f1` decreased from 0.0436403 in H to 0.0288868 in C, a difference of −0.0147535 or −33.807%. This stronger median drying outcome was accompanied by moderate increases in the other two minimized objectives. Median `f2` increased from 0.210596 to 0.217334 USD/kg water removed (+3.200%), and median `f3` increased from 0.495166 to 0.514273 kg CO2e/kg water removed (+3.859%). Thus, the median shifts do not establish uniform improvement: they describe a movement toward lower final moisture with higher modeled specific operating-energy cost and operational greenhouse-gas emissions.

### 4.3 Internal and cross-set dominance

All nine H solutions and all nine C solutions were internally nondominated within their respective finite sets. Cross-set dominance was sparse and bidirectional. Of 81 comparisons, 78 (96.296%) were incomparable, C04 dominated H05, H02 dominated C06, and H08 dominated C08; no exact objective-vector equalities occurred. The numerical near-tie diagnostic found no near-tie objective comparisons among the 243 objectivewise comparisons and no fragile dominance relations.

Directional coverage reflected the same sparse structure. C covered 1/9 of H (11.111%), whereas H covered 2/9 of C (22.222%). Because each complete set was internally nondominated, the corresponding core-coverage values were numerically identical. Coverage is asymmetric and applies only to the evaluated solutions; neither direction indicates broad replacement.

Joint sorting of all 18 solutions produced two layers. Rank 1 contained 15 solutions: H01, H02, H03, H04, H06, H07, H08, H09, C01, C02, C03, C04, C05, C07, and C09. Rank 2 contained H05, C06, and C08. The contributions of eight H and seven C solutions to joint Rank 1 show that direct corrected optimization preserved substantial nondominated information from both sources.

### 4.4 Objective-space geometry

C occupied narrower observed marginal intervals than H in every objective. The observed ranges were 0.146492 (H) and 0.0825189 (C) for `f1`, 0.101451 and 0.0864874 for `f2`, and 0.283575 and 0.237808 for `f3`. C neither extended below nor above the H marginal interval in any objective. H retained the observed low and high extrema of `f1`, `f2`, and `f3`, while C introduced no new marginal extrema.

The objective clouds were therefore interleaved within shared marginal bounds rather than separated into uniformly superior and inferior regions. Figure 1 presents the three-objective geometry, and Figures S1–S3 show the pairwise projections.

### 4.5 Anchored hypervolume

At the primary `r10` reference, anchored hypervolume was 0.9749820881940048 for H and 1.0099628901072748 for C. The same direction occurred at `r5` (H=0.8214144073536221; C=0.8596538595095115) and `r20` (H=1.3323674498747686; C=1.3592107397484303). C consequently covered more of the particular normalized objective region defined by the common anchors and each of the three prespecified references.

This metric does not overturn the dominance and coverage findings. It neither removes the 78 incomparable cross-set pairs nor the greater reciprocal H-over-C coverage, and it does not imply algorithmic superiority, convergence, or global optimality.

### 4.6 Common horizon and objective decomposition

All nine H and all nine C solutions reached the common nominal TMAX horizon of 19.9 h. The lower median `f1` in C therefore cannot be attributed simply to a longer nominal simulation horizon, although the thermal, moisture, and energy trajectories need not be identical.

For both sets, `f2` and `f3` share water removed as their denominator. Interpretation of their differences must consequently account for both numerator and denominator. The frozen decomposition confirms complete availability of total modeled cost, total modeled operational emissions, water removed, LPG input, solar-cost, and impeller-electricity information for all 18 solutions. It does not support direct attribution to physical irradiance, and it does not support a separate LPG-versus-electricity emissions attribution within C.

Table 2 consolidates the principal H-vs-C results.

## 5. Physical, economic, and environmental interpretation

### 5.1 Physical interpretation

The C median pattern combines a higher minimum thermal setpoint with lower `m_max`, lower recirculation fraction, and earlier recirculation onset. Together with the 33.807% lower median final moisture ratio, this pattern is physically compatible with a coordinated heat-and-mass-transfer trade-off. Literature on solar–LPG drying supports the relevance of temperature and air-change rate (Khater et al., 2024), while recirculation studies show that air reuse can interact non-monotonically with temperature, drying time, and energy performance (Afzali et al., 2019; Zohrabi et al., 2020).

The present evidence supports association and physical plausibility, not isolated causality. Median changes cannot identify the independent contribution of `T_min`, `m_max`, `r_div2`, or `t_rec_ini`, and the three observed cross-dominance relations follow different decision-variable pathways. No unique mechanism is established.

### 5.2 Economic interpretation

The 3.200% increase in median `f2` for C is a moderate penalty accompanying the lower median final moisture ratio. Because `f2` divides total modeled operating-energy cost by actual water removed, it reflects both the modeled energy-cost numerator and the achieved moisture-removal denominator. It is not an equipment purchase metric, profitability analysis, total process cost, or total cost of ownership.

### 5.3 Environmental interpretation

The 3.859% increase in median `f3` for C is likewise a moderate operational-emissions penalty accompanying lower median final moisture. The indicator combines direct LPG-combustion CO2 and indirect grid-electricity CO2e under the implemented boundary and normalizes the total by water removed. It is not a life-cycle carbon footprint, a complete greenhouse-gas inventory, or total environmental impact. Because separate LPG and electricity emissions components were not persisted for C, the C–H difference cannot be assigned quantitatively to one emissions component.

## 6. Discussion

The primary result is a restructuring of the observed operational trade-offs rather than uniform replacement of the historical reevaluated set. C contributes useful new compromise information: seven of its nine solutions remain in joint Rank 1, C04 dominates H05, and C has greater anchored hypervolume at all three prespecified reference points. At the same time, H retains substantial scientific and design value: eight of its nine solutions remain in joint Rank 1, H02 and H08 locally dominate C solutions, H-over-C coverage is greater than the reciprocal value, and H retains all observed marginal extrema.

The predominance of incomparability is central. With 78 of 81 cross-set pairs incomparable, neither set can be summarized by a single directional ranking. The lower median `f1` in C comes with higher median `f2` and `f3`; the larger C hypervolume concerns coverage relative to frozen anchors, while the historical set preserves wider marginal reach and more reciprocal coverage. These findings jointly explain why no single metric supports a global superiority statement.

The system-first interpretation is consistent with the literature positioning. Solar–LPG drying, airflow control, recirculation, and multiobjective dryer optimization have direct precedents (Murali et al., 2020; Ortiz-Rodríguez et al., 2020; César-Munguía et al., 2023; Khater et al., 2024; Winiczenko et al., 2018; El Ferouali et al., 2018; Oviedo et al., 2021; Zhang et al., 2022). The incremental contribution lies in integrating the three corrected operational objectives with coupled thermal and air-management decisions for this system. The narrower distinctive contribution is the traceable survival analysis of historical candidates after reevaluation under a corrected cost–emissions formulation. The targeted search found no direct drying precedent for that complete workflow, but universal priority is not claimed.

The common TMAX regime strengthens comparability by removing unequal nominal horizon as a trivial explanation. It also narrows interpretation: the study characterizes fixed-horizon operating outcomes rather than free normal termination. Similarly, the single corrected run provides a reproducible candidate set but no evidence about the distribution of outcomes over random seeds or the expected performance of `gamultiobj`.

## 7. Limitations

The conclusions are subject to the following constitutive limitations:

1. H and C are finite evaluated sets. Their geometry does not establish global optimality or an independently verified reference trade-off surface.
2. Only one corrected run was performed, using seed 61001. Between-seed variability, expected solver performance, statistical robustness, and configuration superiority are not established.
3. The corrected run stopped at `MaxGenerations=50`; this stop condition does not establish convergence or the general sufficiency of 50 generations.
4. The nine H and nine C points are not independent experimental or optimizer replicates. Descriptive medians, ranges, and percentages do not support population inference or significance testing.
5. All 18 solutions share a fixed nominal TMAX horizon of 19.9 h. The result does not characterize free normal termination or identical temporal trajectories.
6. H contains historical solutions generated under an earlier formulation and later reevaluated, not reoptimized, under corrected COST-E3D.
7. `f2` is limited to modeled operating-energy cost and excludes capital, maintenance, labor, fixed charges, total ownership cost, and comprehensive commercial cost.
8. `f3` is limited to modeled operational emissions under the LPG/grid boundary. It excludes life-cycle, infrastructure, manufacturing, transport, maintenance, and total-impact terms.
9. Physical irradiance was not unambiguously available in the persisted comparative evidence, preventing direct irradiance attribution.
10. Separate LPG and electricity emissions components were not persisted for C, preventing component-level emissions attribution for that set.
11. The lumped model does not resolve all spatial gradients, and the electrical scope is limited to the implemented air-impeller representation. The upstream model validation used pineapple data; the present red-chilli application uses literature kinetics and has not been experimentally validated as an integrated plant simulation. Equipment-level extrapolation requires product-specific physical validation and uncertainty analysis.

## 8. Conclusions

The evaluated hybrid solar–LPG dryer solutions exhibit a three-objective operational conflict. Direct optimization under corrected COST-E3D produced a C set with substantially lower median final moisture, but this shift was accompanied by moderately higher median modeled specific operating-energy cost and modeled specific operational greenhouse-gas emissions. The corresponding decision medians indicate coordinated changes in thermal setpoint, airflow, recirculation fraction, and recirculation timing; they do not establish an isolated causal mechanism.

Direct corrected optimization restructured rather than uniformly replaced the historical reevaluated set. Both H and C were internally nondominated, 78 of 81 cross-set pairs were incomparable, dominance was sparse and bidirectional, and both sources contributed substantially to joint Rank 1. C had greater anchored hypervolume at all three frozen reference points, whereas H retained all observed marginal extrema and greater reciprocal coverage.

The scientific contribution is therefore a finite-set physical and multiobjective characterization of operational trade-offs in the dryer, together with a traceable assessment of which historical trade-offs survive corrected reformulation. The evidence supports incremental system-specific novelty and a strong narrow historical-survival contribution, not universal priority. These conclusions do not establish convergence, between-seed robustness, statistical superiority, or global optimality, and they do not identify a unique recommended operating solution.

## 9. Nomenclature

| Symbol or label | Definition | Unit or scope |
|---|---|---|
| `C` | Nine solutions generated directly under corrected COST-E3D | finite evaluated set |
| `f1` | Final moisture ratio, `MR_final` | dimensionless |
| `f2` | Modeled specific operating-energy cost | USD/kg water removed |
| `f3` | Modeled specific operational greenhouse-gas emissions | kg CO2e/kg water removed |
| `H` | Nine historical R1 solutions reevaluated under corrected COST-E3D | finite evaluated set |
| `m_max` | Base air mass-flow parameter | kg/s |
| `MR` | Moisture ratio | dimensionless |
| `Q_aux_tot` | Useful supplementary heat assigned to LPG heating | MJ |
| `r_div2` | Fraction of outlet flow recirculated through branch D2 | dimensionless |
| `T_min` | Minimum process-air temperature before the final operating stage | °C |
| `t_rec_ini` | Recirculation start time | h |
| `TMAX` | Fixed nominal maximum simulation horizon | 19.9 h |
| `C(A,B)` | Fraction of set B dominated by at least one member of set A | dimensionless |
| `HV` | Commonly normalized, reference-point-anchored hypervolume | normalized volume |
| Rank 1 | Joint nondominated set of the 18 evaluated solutions | finite-set rank |

## 10. Tables and figures

- **Table 1.** Corrected COST-E3D objectives and interpretation boundaries.
- **Table 2.** Principal quantitative comparison of H and C.
- **Table S1.** Decision- and objective-space descriptive summaries.
- **Figure 1.** Three-objective geometry of H and C.
- **Figures S1–S3.** Pairwise `f1–f2`, `f1–f3`, and `f2–f3` projections.

## 11. References

Afzali, F., Darvishi, H., & Behroozi-Khazaei, N. (2019). Optimizing exergetic performance of a continuous conveyor infrared-hot air dryer with air recycling system. *Applied Thermal Engineering, 154*, 358–367. https://doi.org/10.1016/j.applthermaleng.2019.03.096

Banco de México. (2026). *Tipo de cambio para solventar obligaciones denominadas en moneda extranjera: fecha de determinación (FIX)* [SIE exchange-rate series]. https://www.banxico.org.mx/SieInternet/consultarDirectorioInternetAction.do?accion=consultarCuadro&idCuadro=CF102&locale=es&sector=7

César-Munguía, A. L., García-Valladares, O., Pérez-Espinosa, R., & Domínguez-Niño, A. (2023). Hybrid thermosolar-LPG dehydrating plant installed in Xochitepec, México. Case study: Pineapple. *Applied Thermal Engineering, 225*, 120171. https://doi.org/10.1016/j.applthermaleng.2023.120171

Comisión Federal de Electricidad, & Comisión Nacional de Energía. (2026). *Tarifas finales del suministro básico aplicables a partir del 1 de junio de 2026* [Official tariff annex]. https://sidof.segob.gob.mx/notas/docFuente/5791865

Comisión Nacional de Energía. (2026). *Precios máximos de gas LP* [Weekly June 2026 publications for Xochitepec, Morelos]. https://www.gob.mx/cne/articulos/precios-maximos-de-gas-lp-399035

Deb, K., Pratap, A., Agarwal, S., & Meyarivan, T. (2002). A fast and elitist multiobjective genetic algorithm: NSGA-II. *IEEE Transactions on Evolutionary Computation, 6*(2), 182–197. https://doi.org/10.1109/4235.996017

El Ferouali, H., Gharafi, M., Zoukit, A., Doubabi, S., & Abdenouri, N. (2018). Hybrid solar-gas-electric dryer optimization with genetic algorithms. In *21st International Drying Symposium Proceedings* (pp. 363–370). https://doi.org/10.4995/IDS2018.2018.7521

González-Bravo, H. E., Romero-Campos, H. E., López-Yáñez, A., García-Valladares, O., & Ramírez-Muñoz, J. (2024). Modeling a hybrid solar-gas dehydrating plant for agro-industrial products. *Applied Thermal Engineering, 253*, 123725. https://doi.org/10.1016/j.applthermaleng.2024.123725

Hossain, M. A., Woods, J. L., & Bala, B. K. (2007). Single-layer drying characteristics and colour kinetics of red chilli. *International Journal of Food Science & Technology, 42*(11), 1367–1375. https://doi.org/10.1111/j.1365-2621.2006.01414.x

Instituto Nacional de Ecología y Cambio Climático, & Instituto Mexicano del Petróleo. (2014). *Factores de emisión para los diferentes tipos de combustibles fósiles y alternativos que se consumen en México*. https://www.gob.mx/inecc/documentos/factores-de-emision-para-los-diferentes-tipos-de-combustible-fosiles-que-se-consumen-en-mexico

Instituto Nacional de Estadística y Geografía. (2026). *Índice nacional de precios al consumidor: junio de 2026* (Comunicado de prensa 417/26). https://www.inegi.org.mx/contenidos/saladeprensa/boletines/2026/inpc/inpc_2q2026_07.pdf

Ishibuchi, H., Imada, R., Setoguchi, Y., & Nojima, Y. (2018). How to specify a reference point in hypervolume calculation for fair performance comparison. *Evolutionary Computation, 26*(3), 411–440. https://doi.org/10.1162/evco_a_00226

Khater, E.-S. G., Bahnasawy, A. H., Oraiath, A. A. T., Alhag, S. K., Al-Shuraym, L. A., Moustapha, M. E., Elwakeel, A. E., Elbeltagi, A., Salem, A., Metwally, K. A., Abdalla, M. A. I., Hussein, M. M., & Abdeen, M. A. (2024). Assessment of a LPG hybrid solar dryer assisted with smart air circulation system for drying basil leaves. *Scientific Reports, 14*, 23922. https://doi.org/10.1038/s41598-024-74751-4

Murali, S., Amulya, P. R., Alfiya, P. V., Delfiya, D. S. A., & Samuel, M. P. (2020). Design and performance evaluation of solar-LPG hybrid dryer for drying of shrimps. *Renewable Energy, 147*, 2417–2428. https://doi.org/10.1016/j.renene.2019.10.002

Ortiz-Rodríguez, N. M., García-Valladares, O., Pilatowsky-Figueroa, I., & Menchaca-Valdez, A. C. (2020). Solar-LP gas hybrid plant for dehydration of food. *Applied Thermal Engineering, 177*, 115496. https://doi.org/10.1016/j.applthermaleng.2020.115496

Ortega, H. (2018). *Energía solar térmica para procesos industriales en México: Estudio base de mercado*. CONUEE, ANES, & GIZ. https://www.giz.de/de/downloads/EnergiaSolarTermica_02_LOWRES.pdf

Oviedo, C., Barán, B., & Galeano, M. (2021). Multi-objective optimization of a steady-state rotary dryer. *CLEI Electronic Journal, 24*(2). https://doi.org/10.19153/cleiej.24.2.1

Pereira, N. B., Joardder, M. U. H., & Karim, A. (2026). Optimization strategies for hybrid drying systems: Enhancing energy efficiency, cost, and quality in food processing. *Food Engineering Reviews, 18*, 19. https://doi.org/10.1007/s12393-026-09446-9

Secretaría de Medio Ambiente y Recursos Naturales. (2025). *Aviso: Factor de emisión del Sistema Eléctrico Nacional 2024*. https://www.gob.mx/cms/uploads/attachment/file/980977/AvisoFESEN_2024.pdf

Winiczenko, R., Górnicki, K., Kaleta, A., Martynenko, A., Janaszek-Mańkowska, M., & Trajer, J. (2018). Multi-objective optimization of convective drying of apple cubes. *Computers and Electronics in Agriculture, 145*, 341–348. https://doi.org/10.1016/j.compag.2018.01.006

Zhang, Z., Zhang, J., Tian, W., Li, Y., Song, Y., & Zhang, P. (2022). Multi-objective optimization of milk powder spray drying system considering environmental impact, economy and product quality. *Journal of Cleaner Production, 369*, 133353. https://doi.org/10.1016/j.jclepro.2022.133353

Zohrabi, S., Aghbashlo, M., Seiiedlou, S. S., Scaar, H., & Mellmann, J. (2020). Energy saving in a convective dryer by using novel real-time exergy-based control schemes adjusting exhaust air recirculation. *Journal of Cleaner Production, 257*, 120394. https://doi.org/10.1016/j.jclepro.2020.120394

Zitzler, E., & Thiele, L. (1999). Multiobjective evolutionary algorithms: A comparative case study and the strength Pareto approach. *IEEE Transactions on Evolutionary Computation, 3*(4), 257–271. https://doi.org/10.1109/4235.797969

## 12. Supplementary material

The supplementary material contains the canonical 18-row dataset; full decision- and objective-space summaries; the 81-pair cross-dominance matrix; numerical near-tie audit; coverage membership; joint sorting; objective-space geometry; hypervolume anchors, normalized points, and reference sensitivity; terminal-regime evidence; objective decomposition; and the claim-to-evidence registry. These materials document the finite-set analysis and do not represent independent experimental replicates or additional optimization runs.
