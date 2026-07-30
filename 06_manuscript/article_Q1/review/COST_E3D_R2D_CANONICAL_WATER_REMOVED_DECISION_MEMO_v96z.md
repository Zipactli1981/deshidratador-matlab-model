# COST-E3D-R2D: Canonical water-removed denominator decision memo v96z

## 1. Purpose

This memo resolves, at the documentary level, the canonical water-removed denominator to be used consistently by the future implementations of the specific cost objective `f(2)` and the specific environmental objective `f(3)`.

The selected denominator is based on the actual terminal state returned by the same simulation used to calculate both objective numerators. This memo does not modify code, constants, objective functions, wrappers, runners, termination criteria, or historical records. It does not execute MATLAB or authorize any new optimization run.

## 2. Scope and restrictions

This is a documentation-only decision. It:

- makes no MATLAB code change;
- makes no objective-function, wrapper, runner, model, physics, limit, seed, cost, or CO2-factor change;
- does not change the active normal termination target of 10 percent wet basis;
- does not adopt the historical 8 percent wet-basis target as the active termination criterion;
- preserves TMAX termination;
- does not execute MATLAB, `gamultiobj`, R1, R2, R3, `minrep`, or a 400-generation run;
- does not create MAT files, results, figures, or PDFs;
- does not validate final article results, convergence, reproducibility, hybrid/gasLP superiority, or a global Pareto front;
- records a decision for a future, separate, coordinated code pull request.

## 3. Evidence base

| Source | Status | Evidence used | Limitation |
|---|---|---|---|
| `COST_E3D_R2C_WATER_REMOVED_EQUIVALENCE_AUDIT_v96z.md` | Reviewed | Demonstrates that the active `f(2)` and `f(3)` denominators are not generally equivalent because one uses the simulated terminal moisture and the other a fixed 8 percent target | Audit only; no implementation |
| `COST_E3D_R1_TECHNICAL_RESOLUTION_MEMO_v96z.md` | Reviewed | Establishes the controlled technical-resolution context and remaining holds | Does not implement this denominator decision |
| `COST_E3D_COMPRESSOR_ENERGY_RECONCILIATION_AUDIT_v96z.md` | Reviewed | Preserves the energy/cost reconciliation hold and the R1 operational-validity boundary | Energy reconciliation remains incomplete |
| `EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md` | Reviewed | Provides the meanings and units of objective outputs and associated detail fields | Static dictionary, not a new run |
| Active objective, wrapper, parameter, cost-breakdown, and runner chain | Statically reviewed | Confirms the active formulas, endpoint return, normal 10 percent target, TMAX path, and selection of the `fix1` triobjective function | Static inspection only; MATLAB was not executed |

## 4. Prior audit finding

The prior equivalence audit established:

`WATER_REMOVED_EQUIVALENCE = NOT_EQUIVALENT`

The active specific-cost denominator is tied to the simulated terminal dry-basis moisture:

`(Mi - M) * md`

The active specific-CO2 denominator is tied to a fixed 8 percent wet-basis reference:

`mwi - mwf`

These expressions coincide only if the actual terminal moisture equals the fixed 8 percent wet-basis target. The active normal termination target is instead 10 percent wet basis, and TMAX can return another terminal moisture. Therefore, the two active objectives do not currently share a guaranteed common terminal boundary.

## 5. Variables and moisture conventions

| Variable | Meaning | Basis | Unit | Role |
|---|---|---|---|---|
| `Mi` | Initial product moisture ratio | Dry basis | kg water/kg dry solid | Initial state used by the simulation |
| `M_terminal` | Moisture ratio at the actual terminal state returned by the simulation | Dry basis | kg water/kg dry solid | Canonical terminal state |
| `md` | Constant dry-solid mass | Dry mass | kg dry solid | Converts dry-basis moisture ratio to water mass |
| `mwi` | Initial water mass | Water mass | kg water | Equivalent initial-state representation |
| `mw_terminal` | Water mass at the actual simulated terminal state | Water mass | kg water | Equivalent terminal-state representation |
| `mwf` | Water mass at the fixed 8 percent wet-basis target | Water mass | kg water | Legacy reference or target diagnostic only |
| `water_removed_kg` | Initial water mass minus water mass at the actual simulated endpoint | Water mass | kg water removed | Canonical common denominator for future `f(2)` and `f(3)` |

The documented values and meanings are:

`Mi = 6.6923076923_KG_WATER_PER_KG_DRY_SOLID`

`M = TERMINAL_SIMULATED_DRY_BASIS_MOISTURE`

`md = 26_KG_DRY_SOLID`

`mwi = 174_KG_INITIAL_WATER`

`mwf = 2.2608695652_KG_WATER_AT_FIXED_8_PERCENT_WET_BASIS_TARGET`

`ACTIVE_NORMAL_TERMINATION_TARGET = 10_PERCENT_WET_BASIS`

`ALTERNATIVE_TERMINATION = TMAX`

## 6. Decision alternatives

### Alternative A: retain the current different denominators

**REJECTED.** Retaining `(Mi - M_terminal) * md` for `f(2)` and `mwi - mwf` for `f(3)` would preserve different normalization boundaries whenever the actual terminal state differs from the fixed 8 percent wet-basis target.

### Alternative B: use the fixed 8 percent target for both objectives

**REJECTED_FOR_ACTIVE_CHAIN.** This would normalize both objectives against a theoretical target that is not the active normal termination boundary and may not be reached under either normal 10 percent termination or TMAX termination.

### Alternative C: use the actual terminal state for both objectives

**SELECTED.** This makes `f(2)` and `f(3)` use the same simulation, the same returned endpoint, and the same physically realized water removal while preserving all existing termination rules.

## 7. Selected canonical definition

The primary canonical definition is:

`water_removed_kg = (Mi - M_terminal) * md`

Its equivalent water-mass form is:

`mw_terminal_kg = M_terminal * md`

`water_removed_kg = mwi - mw_terminal_kg`

Decision states:

`CANONICAL_WATER_REMOVED_PRIMARY_FORM = (MI_MINUS_M_TERMINAL)_TIMES_MD`

`CANONICAL_WATER_REMOVED_EQUIVALENT_FORM = MWI_MINUS_MW_TERMINAL`

`MW_TERMINAL_DEFINITION = M_TERMINAL_TIMES_MD`

`CANONICAL_WATER_REMOVED_BASIS = ACTUAL_SIMULATED_TERMINAL_STATE`

`CANONICAL_WATER_REMOVED_UNIT = KG_WATER_REMOVED`

`CANONICAL_WATER_REMOVED_MOISTURE_BASIS = DRY_BASIS_INTERNAL_REPRESENTATION`

## 8. Algebraic equivalence of canonical forms

Under the existing definitions:

`Mi = mwi / md`

`M_terminal = mw_terminal / md`

with constant positive `md`, then:

`(Mi - M_terminal) * md`

`= (mwi / md - mw_terminal / md) * md`

`= mwi - mw_terminal`

Thus, the selected primary and equivalent forms are algebraically identical when both use the same initial state, the same actual terminal state, and the same constant dry mass. This equivalence does not make the legacy fixed-target expression `mwi - mwf` equivalent when `mwf` does not represent the actual terminal water mass.

## 9. Numerical example at 10 % wet basis

For an exact 10 percent wet-basis terminal state:

`M_terminal = 0.10 / (1 - 0.10) = 0.1111111111 kg water/kg dry solid`

`mw_terminal = 0.1111111111 * 26 = 2.8888888889 kg water`

Canonical actual-terminal water removal:

`water_removed_kg = 174 - 2.8888888889 = 171.1111111111 kg water`

Historical fixed 8 percent denominator:

`mwi - mwf = 174 - 2.2608695652 = 171.7391304348 kg water`

Difference:

`171.7391304348 - 171.1111111111 = 0.6280193237 kg water`

At an exact 10 percent terminal state, the fixed 8 percent denominator therefore overstates actual water removal by `0.6280193237 kg`. This numerical difference must not be generalized to TMAX termination because it depends on the actual returned `M_terminal`.

## 10. Treatment of TMAX termination

TMAX termination is preserved. When TMAX determines the endpoint, the canonical denominator must use the terminal moisture returned for that same endpoint. It must not substitute either the 10 percent normal target or the legacy 8 percent target.

`TERMINATION_CRITERION_DECISION = UNCHANGED`

`ACTIVE_NORMAL_TERMINATION_TARGET = 10_PERCENT_WET_BASIS`

`TMAX_TERMINATION = PRESERVED`

`EIGHT_PERCENT_WET_BASIS_TARGET = NOT_ADOPTED_AS_ACTIVE_TERMINATION_BY_THIS_MEMO`

## 11. Treatment of legacy mwf

The legacy `mwf` value is a valid theoretical water mass associated with a fixed 8 percent wet-basis target. This memo does not delete it or label its definition incorrect. It may remain available as a reference, target diagnostic, historical comparison, or input to another explicitly configured boundary.

It is not selected as the normalization denominator of the active objective chain when the simulated endpoint differs from that target.

`LEGACY_MWF_DEFINITION = WATER_MASS_AT_FIXED_8_PERCENT_WET_BASIS_TARGET`

`LEGACY_MWF_STATUS = NOT_SELECTED_FOR_ACTIVE_OBJECTIVE_NORMALIZATION`

`LEGACY_MWF_ALLOWED_USE = REFERENCE_OR_TARGET_DIAGNOSTIC_ONLY`

`LEGACY_MWF_PROHIBITED_USE = DENOMINATOR_OF_ACTIVE_F3_WHEN_TERMINAL_STATE_DIFFERS_FROM_8_PERCENT_WET_BASIS`

## 12. Future use in f(2)

In a future separate implementation:

`f2_cost_specific = total_cost_USD / water_removed_kg`

`F2_CANONICAL_DENOMINATOR = WATER_REMOVED_KG_AT_ACTUAL_TERMINAL_STATE`

The total-cost numerator is not changed by this decision. Implementation remains pending, and historical `f(2)` values require recalculation after the canonical denominator is implemented.

## 13. Future use in f(3)

In a future separate implementation:

`f3_CO2_specific = total_CO2_kg / water_removed_kg`

`F3_CANONICAL_DENOMINATOR = WATER_REMOVED_KG_AT_ACTUAL_TERMINAL_STATE`

`F2_F3_COMMON_DENOMINATOR = WATER_REMOVED_KG`

`F2_F3_NORMALIZATION_BOUNDARY = SAME_SIMULATION_SAME_TERMINAL_STATE`

The total-CO2 numerator and emission factors are not changed by this decision. Implementation remains pending, and historical `f(3)` values require recalculation after the canonical denominator is implemented.

## 14. Validity requirements and invalid cases

The canonical denominator is valid only when it is finite, positive, and calculated from the same simulation and terminal boundary as the corresponding numerator.

`CANONICAL_DENOMINATOR_VALIDITY_REQUIREMENTS = FINITE_POSITIVE_AND_SAME_TERMINAL_BOUNDARY`

This memo introduces no epsilon, replacement value, or new penalty rule. Invalid cases must remain subject to the existing objective penalty policy until the future implementation is statically reviewed.

`DENOMINATOR_INVALID_CASE_POLICY = USE_EXISTING_OBJECTIVE_PENALTY_POLICY_PENDING_IMPLEMENTATION_REVIEW`

## 15. Consequences for R1

R1 remains valid as an operational test of the seed-aware runner and the `gamultiobj` execution chain. This denominator decision does not invalidate its seed record, settings, returned arrays, artifacts, hashes, or Gate A operational audit trail.

However, R1 used the pre-decision objective implementation. Its economic and environmental objective values remain methodologically provisional and must be recalculated after the common canonical denominator is implemented.

`R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST`

`R1_ECONOMIC_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL`

`R1_ENVIRONMENTAL_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL`

`R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL`

`COST_E3D_FINDINGS_DO_NOT_INVALIDATE_R1_OPERATIONAL_RECORD`

`R1_F2_F3_RECALCULATION = REQUIRED_AFTER_CANONICAL_DENOMINATOR_IMPLEMENTATION`

## 16. Findings and decisions

| ID | Classification | Decision | Evidence | Consequence | Status |
|---|---|---|---|---|---|
| D01 | Denominator definition | Adopt `(Mi - M_terminal) * md` as the primary canonical water-removed form | Active `f(2)` proximity and endpoint-based physical boundary | Future `f(2)` and `f(3)` share the actual terminal state | ADOPTED |
| D02 | Equivalent representation | Adopt `mwi - mw_terminal`, with `mw_terminal = M_terminal * md`, as the equivalent form | Algebraic identity under constant positive dry mass | Allows consistent water-mass reporting | ADOPTED |
| D03 | Objective normalization | Use the canonical water removal for both future specific objectives | R2C non-equivalence finding | Removes the current cross-objective boundary mismatch | ADOPTED |
| D04 | Termination boundary | Preserve normal 10 percent wet-basis and TMAX termination rules | Static active-chain inspection | Denominator follows, but does not choose, the terminal state | UNCHANGED |
| D05 | Legacy target | Retain `mwf` only as a reference or target diagnostic in the active context | `mwf` represents fixed 8 percent wet basis | Prevents fixed-target substitution for an actual endpoint | ADOPTED |
| H01 | Code implementation | Implement the canonical denominator in both objectives | No code change is authorized in this memo | Current code remains inconsistent | OPEN |
| H02 | Economic source closure | Close solar INPC and exact June 2026 GDMTO inputs | COST-E3D evidence chain | Economic basis remains incomplete | OPEN |
| H03 | Coordinated implementation | Review cost and CO2 changes together, including units, boundaries, and penalty handling | Both objectives will share the denominator | Separate code PR required | OPEN |
| H04 | Historical objectives | Recalculate R1 `f(2)` and `f(3)` after implementation | R1 used the prior normalization | R1 scientific values remain non-final | OPEN |

## 17. Current state

`COST-E3D-R2D = CANONICAL_WATER_REMOVED_DENOMINATOR_DECISION_DOCUMENTED_NO_CODE_CHANGE`

`CANONICAL_WATER_REMOVED_PRIMARY_FORM = (MI_MINUS_M_TERMINAL)_TIMES_MD`

`CANONICAL_WATER_REMOVED_EQUIVALENT_FORM = MWI_MINUS_MW_TERMINAL`

`MW_TERMINAL_DEFINITION = M_TERMINAL_TIMES_MD`

`CANONICAL_WATER_REMOVED_BASIS = ACTUAL_SIMULATED_TERMINAL_STATE`

`CANONICAL_WATER_REMOVED_UNIT = KG_WATER_REMOVED`

`CANONICAL_WATER_REMOVED_MOISTURE_BASIS = DRY_BASIS_INTERNAL_REPRESENTATION`

`WATER_REMOVED_EQUIVALENCE = NOT_EQUIVALENT`

`WATER_REMOVED_DENOMINATOR_DECISION = RESOLVED_DOCUMENTALLY`

`WATER_REMOVED_DENOMINATOR_IMPLEMENTATION = PENDING_SEPARATE_CODE_PR`

`F2_F3_CANONICAL_NORMALIZATION_DECISION = ADOPTED`

`F2_F3_CANONICAL_NORMALIZATION_IMPLEMENTATION = PENDING`

`WATER_REMOVED_DENOMINATOR_STATUS = DECISION_RESOLVED_IMPLEMENTATION_PENDING`

`F2_F3_NORMALIZATION_STATUS = DECISION_RESOLVED_IMPLEMENTATION_PENDING`

`ENERGY_COST_RECONCILIATION = MAJOR_HOLD`

`COST_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_REMAINING_HOLDS`

`ENVIRONMENTAL_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_CODE_IMPLEMENTATION`

`R1_F2_F3_RECALCULATION = REQUIRED_AFTER_CANONICAL_DENOMINATOR_IMPLEMENTATION`

`ECONOMIC_FACTOR_CODE_UPDATE = BLOCKED_PENDING_REMAINING_HOLDS_AND_SEPARATE_IMPLEMENTATION_PR`

`FORMAL_EXECUTION = BLOCKED_PENDING_ECONOMIC_IMPLEMENTATION_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION`

## 18. Remaining holds

1. Implement `water_removed_kg` consistently for `f(2)` and `f(3)` in a separate authorized code pull request.
2. Close the solar-cost INPC basis.
3. Close the exact June 2026 GDMTO basis.
4. Prepare a coordinated cost-and-CO2 implementation.
5. Perform static review of the modified code, including units, endpoint boundaries, and existing penalty behavior.
6. Obtain explicit authorization before any minimal MATLAB test.
7. Recalculate R1 `f(2)` and `f(3)` after canonical-denominator implementation.

## 19. Next steps

1. Merge this documentary decision.
2. Close the solar-cost hold.
3. Close the GDMTO hold.
4. Prepare one coordinated code pull request for the approved cost and CO2 implementation.
5. Use `water_removed_kg` as the common denominator of `f(2)` and `f(3)`.
6. Statically review units, terminal boundaries, and existing penalty handling.
7. Request explicit authorization before executing MATLAB.

No code implementation is authorized or included in COST-E3D-R2D.
