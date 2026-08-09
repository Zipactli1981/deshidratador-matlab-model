# CR1-COMP-13 - Objective decomposition audit v96z

CR1_COMP_13_STATUS = CLOSED_PASS

The 18 stored f2/f3 objectives were decomposed into total_cost_USD / water_removed_kg and total_CO2_kg / water_removed_kg. H and C rows are not paired. H values retain DOCUMENTARY_SERIALIZATION provenance and their exact source decimal strings are preserved in dedicated raw-serialization columns; C values retain VALIDATED_JSON_SERIALIZATION_OF_BINARY64 provenance. D004 remains (Mi - M_terminal) * md. All upstream hashes and CR1-COMP-12 COMMON_TMAX_19P9H checks passed.

## Component availability

Q_AUX_TOT_AVAILABILITY = COMPLETE_18
Q_LPG_INPUT_AVAILABILITY = COMPLETE_18
LPG_MASS_AVAILABILITY = COMPLETE_18
LPG_COST_AVAILABILITY = COMPLETE_18
IRRADIACION_AVAILABILITY = NOT_AVAILABLE
SOLAR_COST_AVAILABILITY = COMPLETE_18
E_AIR_IMPELLER_AVAILABILITY = COMPLETE_18
ELECTRICITY_COST_AVAILABILITY = COMPLETE_18
CO2_LPG_AVAILABILITY = COMPLETE_H_ONLY
CO2_ELECTRICITY_AVAILABILITY = COMPLETE_H_ONLY

Irradiacion was not equated with solar energy. C CO2 components were not fabricated. Raw identity and component-sum differences are preserved without a new tolerance.

## QC and exclusions

H_ROWS = 9; C_ROWS = 9; TOTAL_ROWS = 18. Mandatory decomposition is complete and finite. INDEPENDENT_QC = PASS. REPRESENTATIVE_SOLUTION_SELECTION = DEFERRED_TO_CR1_COMP_14. GASLP_INCLUDED_IN_DECOMPOSITION_DATASET = NO.

No MATLAB, objective/model evaluation, replay, optimization, dominance, coverage, hypervolume, representative selection, H-C pairing, causal interpretation, productive-code change, protocol change, or decision-log change was performed. CR1-COMP-14 requires separate authorization.
