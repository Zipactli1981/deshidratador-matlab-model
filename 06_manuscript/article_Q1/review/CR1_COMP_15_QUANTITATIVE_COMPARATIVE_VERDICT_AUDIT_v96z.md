# CR1-COMP-15 - Quantitative comparative verdict audit v96z

CR1_COMP_15_STATUS = CLOSED_PASS

## PROTOCOL_REQUIRED_VECTOR

COMPARATIVE_VERDICT_FORMAT = QUANTITATIVE_VECTOR_PLUS_NARRATIVE
FORMAL_A_B_C_D_CLASSIFICATION = NOT_USED
VECTOR_FIELD_COUNT = 25
HYPERVOLUME_ROLE = SECONDARY_CONDITIONAL_METRIC

## DIRECT_UPSTREAM_VALUES

H and C are internally nondominated 9/9. Exact cross-set relations are C-to-H=1, H-to-C=2, incomparable=78, exact equal=0. Full/core coverage is 1/9 C-over-H and 2/9 H-over-C. Joint Rank 1 contains H=8 and C=7. Primary r10 hypervolume is H=0.9749820881940048, C=1.0099628901072748, direction=C_GT_H; r5/r10/r20 all preserve C_GT_H. Both sets contain nine TMAX points under COMMON_TMAX_19P9H.

## DERIVED_SIMPLE_RATIOS

CROSS_SET_INCOMPARABLE_FRACTION = 78/81
CROSS_SET_INCOMPARABLE_PERCENT = 96.29629629629629
JOINT_RANK1_TOTAL = 15/18
H_JOINT_RANK1_RETENTION = 8/9
C_JOINT_RANK1_RETENTION = 7/9

These are direct arithmetic transforms of frozen counts, not composite metrics.

## MULTIOBJECTIVE_SYNTHESIS

The vector shows predominant incomparability, sparse bidirectional local dominance, substantial Rank 1 contributions from both sets, reciprocal coverage numerically favoring H, and anchored hypervolume favoring C under all three frozen reference points. H retains the observed marginal extremes; C occupies narrower marginal objective intervals. No single metric is treated as decisive.

## INTERPRETIVE_SYNTHESIS

QUANTITATIVE_VERDICT_PATTERN = TRADEOFF_RESTRUCTURING_WITH_PARTIAL_CORRECTED_R1_ADVANTAGE_AND_HISTORICAL_SURVIVAL
QUANTITATIVE_VERDICT_PATTERN_ROLE = DESCRIPTIVE_SYNTHESIS_NOT_FORMAL_CLASSIFICATION
C_REGION_CONCENTRATION_HYPOTHESIS = PARTIALLY_SUPPORTED
C_REGION_CONCENTRATION_INTERPRETATION = MULTIPLE_TRADEOFF_MECHANISMS

## INFERENTIAL_LIMITATIONS

ONE_CORRECTED_R1_RUN = YES
seed = 61001
PopulationSize = 24
MaxGenerations = 50
CORRECTED_R1_STOP_REASON = MAXGENERATIONS_REACHED
MAXGENERATIONS_REACHED DOES_NOT_IMPLY CONVERGENCE
EXPECTED_GAMULTIOBJ_PERFORMANCE = NOT_ESTABLISHED
BETWEEN_SEED_VARIABILITY = NOT_ESTABLISHED
STATISTICAL_ROBUSTNESS = NOT_ESTABLISHED
CONVERGENCE_PROBABILITY = NOT_ESTABLISHED
MEAN_PERFORMANCE = NOT_ESTABLISHED
STATISTICAL_CONFIGURATION_SUPERIORITY = NOT_ESTABLISHED
GENERAL_SUFFICIENCY_OF_50_GENERATIONS = NOT_ESTABLISHED
TERMINAL_REGIME_LIMITATION = FIXED_HORIZON_NOT_FREE_NORMAL_TERMINATION
IRRADIACION_NOT_AVAILABLE
C_CO2_COMPONENTS_NOT_PERSISTED

## FINAL_COMPARATIVE_VERDICT

Across the 18 evaluated solutions, direct optimization under corrected COST-E3D restructures rather than uniformly replaces the historical reevaluated set: both sets are internally nondominated (9/9), 78/81 cross-set pairs are incomparable, dominance is sparse and bidirectional (C-to-H 1; H-to-C 2), and joint Rank 1 retains 8 H and 7 C solutions. C has greater anchored hypervolume at r5, r10 and r20 and a substantially lower median f1 with modestly higher median f2/f3, while H retains all observed marginal objective extremes and has greater reciprocal coverage. This establishes finite-set trade-off restructuring under a common nominal TMAX horizon, not convergence, global optimality, between-seed robustness or statistical superiority of the algorithm.

## QC

VECTOR_FIELD_COUNT_CHECK = PASS
VECTOR_SOURCE_TRACEABILITY = PASS
VECTOR_VALUE_UPSTREAM_IDENTITY = PASS
STRUCTURAL_COUNT_CHECKS = PASS
COVERAGE_CONSISTENCY_CHECK = PASS
HV_UPSTREAM_IDENTITY_CHECK = PASS
TERMINAL_UPSTREAM_IDENTITY_CHECK = PASS
CR1_COMP_14_CLAIMS_CONSISTENCY = PASS
NARRATIVE_TRACEABILITY_CHECK = PASS
INFERENTIAL_SCOPE_CHECK = PASS
INDEPENDENT_QC = PASS

No MATLAB, objective/model evaluation, replay, optimization, dominance, coverage, sorting, hypervolume recomputation, new composite/statistical metric, manuscript editing, CR1-COMP-16, or remote operation was performed.
