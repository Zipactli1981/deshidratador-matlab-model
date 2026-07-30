# COST-E3D-R2C: Water-removed equivalence audit v96z

## 1. Purpose

This document performs a focused static audit of the two water-removed
denominators used by the active objective chain:

```text
(Mi - M) × md
```

and:

```text
mwi - mwf
```

The audit reconstructs every participating variable, moisture convention,
unit, initial state, final state, temporal boundary, fallback, and downstream
use. It then tests algebraic equivalence and records the consequences for f(2),
f(3), COST-E3D-R1, and R1.

## 2. Scope and restrictions

This is a static, documentation-only audit.

- No MATLAB code, objective, wrapper, runner, constant, CO2 factor, or formula
  is modified.
- MATLAB and `gamultiobj` are not executed.
- R1, R2, R3, minrep, and 400-generation execution are not run.
- No MAT file, result, figure, PDF, or additional source file is created.
- Variable meaning is not inferred from a name alone.
- Owner intention is not used as proof of equivalence.
- No final scientific result, convergence, hybrid/gasLP superiority, or global
  Pareto-front claim is made.
- Formal execution remains blocked.

The audit concerns the active R1 objective route selected by the seed-aware
formal runner. Other configurations are examined only to identify corroboration
or divergence; they do not replace the active-chain evidence.

## 3. Files inspected

| File | Status | Role |
|---|---|---|
| `06_manuscript/article_Q1/review/COST_E3D_R1_TECHNICAL_RESOLUTION_MEMO_v96z.md` | FOUND / INSPECTED | Prior water-equivalence HOLD, conditional derivation, and current Gate state |
| `06_manuscript/article_Q1/review/COST_E3D_COMPRESSOR_ENERGY_RECONCILIATION_AUDIT_v96z.md` | FOUND / INSPECTED | First identification of the f(2)/f(3) denominator mismatch |
| `06_manuscript/article_Q1/review/EVIDENCE_E1_GA_VARIABLE_OUTPUT_DICTIONARY_v96z.md` | FOUND / INSPECTED | Units and `detail` field dictionary |
| `06_manuscript/article_Q1/review/GATE_B_DECISION_CURRENT_STATUS_v96z.md` | FOUND / INSPECTED | Gate restrictions and formal-execution block |
| `02_src_limpio/production/run_seedaware_formal_R1_only_v96z_rngfix.m` | FOUND / INSPECTED | R1 entry point and seed-aware runner selection |
| `02_src_limpio/production/run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m` | FOUND / INSPECTED | Active `gamultiobj` objective selection at line 245; read only |
| `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2_fix1.m` | FOUND / INSPECTED | Active tri-objective wrapper and f(3) denominator |
| `02_src_limpio/production/objective_productive_corrected_v95j_endpoint_TMAX_corrected.m` | FOUND / INSPECTED | Active base objective, product definitions, and f(2) call |
| `02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2.m` | FOUND / INSPECTED | Non-`fix1` comparison; it uses the same primary f(3) denominator |
| `02_src_limpio/wrappers/opt_tunel_mod2_v18_endpoint_TMAX_corrected.m` | FOUND / INSPECTED | Active state propagation, termination boundaries, and returned `M` |
| `02_src_limpio/cost/calc_cost_breakdown.m` | FOUND / INSPECTED | f(2) denominator and units |
| `02_src_limpio/config/build_base_params.m` | FOUND / INSPECTED / NOT ACTIVE IN R1 OBJECTIVE ROUTE | Alternative controlled configuration with `M_des = Mf` |
| `03_original_model/03_utilities/preallocating.m` | FOUND / INSPECTED | Storage allocation for `M_prod` and `MR`; no semantic conversion |
| `03_original_model/01_active_original/tunel_mod2.mlx` | FOUND / STATICALLY INSPECTED | Live-script code cells defining dynamic `M`, `mwf = Mf*md`, and dry-basis state use |
| `03_original_model/01_active_original/opt_tunel_mod2.mlx` | FOUND / STATICALLY INSPECTED | Original initialization, state update, `MR`, and termination structure |
| `03_original_model/99_legacy_do_not_run/EDO_simple.m` | FOUND / INSPECTED AS SEMANTIC SUPPORT ONLY | Explicit comments defining initial wet basis, dry-basis conversion, dry-product mass, and water mass |

The `.mlx` files were inspected read-only through their internal
`matlab/document.xml` code cells. MATLAB was not opened or executed. Live
scripts do not expose stable text-line numbers, so their evidence is cited by
file and code-cell expression. No required file was missing.

## 4. Static-search strategy

The repository search excluded `.git`, result directories, run artifacts,
binary outputs, and backup copies. Text searches covered `.m`, `.md`, and
`.txt` files using the following terms and close variants:

```text
Mi
M
md
mwi
mwf
water_removed
water removed
moisture
humedad
dry matter
materia seca
wet basis
dry basis
base húmeda
base seca
MR
XR
kgwater
kg water
moisture_content
initial moisture
final moisture
m0
mf
```

The broad search produced 396 text files with at least one lexical match. Those
matches were triaged by execution relevance:

1. the formal R1 runner was followed to the seed-aware guarded runner;
2. the guarded runner selects
   `objective_productive_corrected_v96j_triobjective_CO2_fix1`;
3. `fix1` calls
   `objective_productive_corrected_v95j_endpoint_TMAX_corrected`;
4. the base objective calls the v18 physical wrapper and
   `calc_cost_breakdown`;
5. definitions, units, temporal indices, and fallbacks were then traced
   backward and forward along that active chain; and
6. auxiliary, legacy, and documentary matches were used only as corroboration
   or divergence evidence.

No call to `build_base_params` was found in the active R1 runner, active
tri-objective wrapper, or active base objective. Its `M_des = Mf` convention
therefore does not govern the active denominator evaluated by R1.

## 5. Variable-definition inventory

| Variable | File and line / code cell | Exact expression | Semantic definition | Explicit unit | Inferred unit | Moisture basis | State / time | Downstream use | Certainty |
|---|---|---|---|---|---|---|---|---|---|
| `W0` | base objective line 78 | `W0 = 200` | Initial wet-product batch mass | Not stated on that line | kg wet product | Not a moisture ratio | Initial, fixed | Constructs `mwi`; with `m_i`, determines `md` | HIGH, supported by mass identities |
| `m_i` | base objective line 80 | `m_i = 0.87` | Initial moisture mass fraction | Not stated on that line | dimensionless kg water/kg wet product | Wet basis | Initial, fixed | Constructs `Mi` and `mwi` | HIGH, conversion and legacy comments explicit |
| `Mi` | base objective line 81 | `Mi = m_i/(1-m_i)` | Initial moisture content per dry solid | Cost file line 20: kg water/kg dry solid | kg water/kg dry solid | Dry basis | Initial, fixed | Initializes `M_prod`; f(2) denominator; `MR` | HIGH |
| `mwi` | base objective line 82 | `mwi = W0*m_i` | Initial water mass | Legacy source: initial water mass | kg water | Mass, not moisture basis | Initial, fixed | Constructs `md`; f(3) denominator | HIGH |
| `md` | base objective line 83 | `md = mwi/Mi` | Dry-solid mass of the batch | Cost file line 21: kg dry solid | kg dry solid | Not a moisture ratio | Fixed for the batch | Converts dry-basis moisture content to water mass | HIGH |
| `m_f` | base objective line 85 | `m_f = 0.08` | Prescribed target final moisture fraction | Not stated on that line | dimensionless kg water/kg wet product | Wet basis | Target, not simulated terminal state | Constructs `Mf` | HIGH |
| `Mf` | base objective line 87 | `Mf = m_f/(1-m_f)` | Prescribed target final dry-basis moisture content | Wrapper uses it in `MR` | kg water/kg dry solid | Dry basis | Target reference | Constructs `mwf`; equilibrium/reference term in model and `MR` | HIGH |
| `mwf` | base objective line 89 | `mwf = Mf*md` | Water mass at prescribed target `Mf` | Not stated on that line | kg water | Mass, not moisture basis | Target reference; no time index | Primary f(3) denominator term | HIGH |
| `m_des` | base objective line 86 | `m_des = 0.10` | Moisture fraction used to construct the active stopping threshold | Not stated on that line | dimensionless kg water/kg wet product | Wet basis | Termination target | Constructs `M_des` | HIGH |
| `M_des` | base objective line 88 | `M_des = m_des/(1-m_des)` | Active dry-basis stopping threshold | Same convention as `Mi`, `Mf` | kg water/kg dry solid | Dry basis | Termination boundary | Wrapper test at line 455 | HIGH |
| `M_prod(i)` | wrapper lines 118, 379, 455-460 | initialized as `Mi`, updated by `tunel_mod2`, returned as `M_prod_fin=M_prod(i)` | Dynamic product moisture content | Live-script evidence and cost interface | kg water/kg dry solid | Dry basis | Instantaneous state at index `i` | Returned as active base-objective `M` | HIGH |
| `M` | base objective lines 92-101 and 140 | v18 wrapper output passed to cost | Modeled terminal moisture content | Cost file line 20 | kg water/kg dry solid | Dry basis | Returned checked state or `TMAX` state | f(2) denominator | HIGH |
| `MR` | wrapper lines 395, 460, 488 | `(M_prod-Mf)/(Mi-Mf)` | Normalized moisture ratio relative to `Mf` and `Mi` | EVIDENCE-E1: dimensionless | dimensionless | Normalized from dry-basis values | Dynamic and terminal | f(1), not either water-mass denominator | HIGH |
| `cost.water_removed_kg` | cost lines 63, 74, 82 | `(Mi-M)*md` | Simulated water removed to returned terminal `M` | kg water | kg water | Derived from dry basis | Initial state to simulated terminal state | f(2) | HIGH |
| `detail.CO2.water_removed_kg` | `fix1` lines 67-75, 108 | normally `mwi-mwf` | Target water removal to prescribed `Mf` | Field name implies kg; objective unit confirms | kg water | Direct mass subtraction | Initial state to fixed target state | f(3) | HIGH |

For the active constants:

```text
W0 = 200 kg
m_i = 0.87 wet basis
Mi = 0.87 / 0.13 = 6.69230769230769 kg water/kg dry solid
mwi = 200 × 0.87 = 174 kg water
md = 174 / 6.69230769230769 = 26 kg dry solid

m_f = 0.08 wet basis
Mf = 0.08 / 0.92 = 0.0869565217391304 kg water/kg dry solid
mwf = 0.0869565217391304 × 26 = 2.26086956521739 kg water

m_des = 0.10 wet basis
M_des = 0.10 / 0.90 = 0.111111111111111 kg water/kg dry solid
```

## 6. Moisture-basis audit

The active formulation uses two moisture conventions deliberately:

```text
X_wb = m_water / (m_water + m_dry)

X_db = m_water / m_dry

X_db = X_wb / (1 - X_wb)
```

| Variable | Meaning | Moisture basis | Formula | Unit | Evidence | Certainty |
|---|---|---|---|---|---|---|
| `m_i` | Initial moisture fraction | Wet basis | fixed at 0.87 | dimensionless | base line 80; `Mi=m_i/(1-m_i)` line 81; legacy comment | HIGH |
| `Mi` | Initial moisture content | Dry basis | `m_i/(1-m_i)` | kg water/kg dry solid | base line 81; cost line 20; legacy explicit comment | HIGH |
| `M` / `M_prod` | Dynamic or terminal moisture content | Dry basis | state propagated from initial `Mi` | kg water/kg dry solid | wrapper lines 118, 379; live-script state; cost line 20 | HIGH |
| `m_f` | Prescribed target moisture fraction | Wet basis | fixed at 0.08 | dimensionless | base line 85 and conversion at line 87 | HIGH |
| `Mf` | Prescribed target moisture content | Dry basis | `m_f/(1-m_f)` | kg water/kg dry solid | base line 87; wrapper `MR` formula | HIGH |
| `m_des` | Active stopping moisture fraction | Wet basis | fixed at 0.10 | dimensionless | base line 86 and conversion at line 88 | HIGH |
| `M_des` | Active stopping threshold | Dry basis | `m_des/(1-m_des)` | kg water/kg dry solid | base line 88; wrapper line 455 | HIGH |
| `mwi` | Initial water mass | Not a ratio | `W0*m_i` | kg water | base line 82; legacy explicit comment | HIGH |
| `mwf` | Target final water mass | Not a ratio | `Mf*md` | kg water | base line 89; live-script code cell | HIGH |
| `md` | Constant dry-solid mass | Not a ratio | `mwi/Mi` | kg dry solid | base line 83; cost line 21; legacy explicit comment | HIGH |
| `MR` | Normalized moisture ratio | Normalized dry-basis state | `(M-Mf)/(Mi-Mf)` | dimensionless | wrapper lines 395 and 488 | HIGH |

There is no active-chain switch in the moisture convention of `Mi`, `M`, or
`Mf`: all three are dry-basis quantities. The material problem is instead a
final-boundary mismatch. The separate `build_base_params` configuration sets
`M_des = Mf`; however, the active base objective explicitly sets
`m_des = 0.10` and `m_f = 0.08`, and it does not consume that configuration.

## 7. Algebraic derivation

### Case A: dry-basis `Mi` and `M`, with `md` as dry-solid mass

The active definitions explicitly support:

```text
Mi = mwi / md
```

because `md = mwi/Mi`, and for any dynamic dry-basis state `M`:

```text
m_water_at_M = M × md
```

Therefore:

```text
(Mi - M) × md
= Mi×md - M×md
= mwi - m_water_at_M
```

This is an exact expression for water removed from the initial state to the
modeled terminal state `M`.

The active f(3) expression is:

```text
mwi - mwf
= mwi - Mf×md
```

Subtracting the two denominators gives:

```text
(mwi - mwf) - ((Mi - M)×md)
= (mwi - Mf×md) - (mwi - M×md)
= (M - Mf)×md
```

Thus:

```text
(Mi - M)×md = mwi - mwf
if and only if
M = Mf
```

for the positive batch dry mass `md = 26 kg`.

The condition `M = Mf` is not imposed by the active formulation. The active
stopping threshold is:

```text
M_des = 0.111111111111111 kg water/kg dry solid
Mf    = 0.0869565217391304 kg water/kg dry solid
```

Even in the illustrative limiting case where the returned state were exactly
`M_des`, the denominators would be:

```text
f(2) denominator at exact M_des
= (6.69230769230769 - 0.111111111111111) × 26
= 171.111111111111 kg water

f(3) target denominator
= 174 - 2.26086956521739
= 171.739130434783 kg water

difference
= 0.628019323671481 kg water
```

The wrapper does not interpolate to exact `M_des`. It returns `M_prod(i)` when
the checked state is at or below `M_des`, or it returns the current state at
`TMAX`. Therefore the actual f(2) denominator is solution-dependent, whereas
the normal f(3) denominator is the same target mass for every valid solution.

### Case B: wet-basis `Mi` and `M`

This case does not describe the active variables named `Mi` and `M`. If it did,
the correct conversion would be:

```text
m_water = X_wb × md / (1 - X_wb)

water_removed
= md × [Mi/(1-Mi) - M/(1-M)]
```

and `(Mi-M)×md` would not generally be a water mass. The active evidence rules
out this case because `Mi`, `M`, and `Mf` are dry-basis quantities.

### Case C: normalized `MR` or `XR`

This case also does not describe active `Mi` or `M`. `MR` is a separate
dimensionless output:

```text
MR = (M - Mf) / (Mi - Mf)
```

Neither denominator substitutes `MR` for `M`. No active `XR` participates in
f(2) or f(3).

### Case D: mixed or ambiguous definitions

The active definitions are not ambiguous or mixed. They are sufficiently
explicit to prove the conditional identity and to prove that the active
expressions use different final boundaries.

## 8. Dimensional audit

| Expression | Variable units | Resulting unit | Expected physical quantity | Status |
|---|---|---|---|---|
| `(Mi-M)×md` | `(kg water/kg dry solid) × kg dry solid` | kg water | Actual water removed to simulated terminal `M` | DIMENSIONALLY_CONSISTENT |
| `mwi-mwf` | `kg water - kg water` | kg water | Target water removal to prescribed `Mf` | DIMENSIONALLY_CONSISTENT |
| f(2) denominator | kg water | kg water | Water removed | DIMENSIONALLY_CONSISTENT |
| f(3) denominator | kg water | kg water | Water removed | DIMENSIONALLY_CONSISTENT |
| `cost.water_removed_kg` | kg water | kg water | Actual simulated removal | DIMENSIONALLY_CONSISTENT |
| `detail.CO2.water_removed_kg` | direct mass subtraction; unit not separately stored as a `detail.CO2` unit field | kg water by construction | Target removal | DIMENSIONALLY_CONSISTENT_WITH_ASSUMPTIONS |

Both expressions are dimensionally valid. Dimensional consistency does not
establish equivalence because they use different final states.

## 9. Temporal-boundary audit

| Quantity | Initial state | Final state | Time index | Source | Same boundary? |
|---|---|---|---|---|---|
| f(2) water removed | `Mi` at batch initialization | Returned modeled `M = M_prod(i)` | Checked index `i` at `M_DES_REACHED`, or current index `i` at `TMAX_REACHED` | base lines 92-101; wrapper lines 455-460 and 486-488 | No, relative to f(3) |
| f(3) water removed | `mwi = W0*m_i` | `mwf = Mf*md`, prescribed target | No simulated time index | base lines 82, 87, 89; `fix1` lines 68-71 | No, relative to f(2) |
| `MR` returned with normal moisture termination | `Mi` and `Mf` references | `MR(i)` corresponding to returned `M_prod(i)` | index `i` | wrapper lines 455-460 | Same as f(2), not f(3) target |
| `MR` returned at `TMAX` | `Mi` and `Mf` references | recomputed from `M_prod(i)` | current `i` at maximum-time boundary | wrapper lines 486-488 | Same as f(2), not f(3) target |
| `mwf` | same initial batch parameters | fixed 8% wet-basis target | none | base lines 85, 87, 89 | Target only |

The wrapper computes `M_prod(i+1)` and then evaluates the termination test using
`M_prod(i)`. It returns `M_prod(i)` and `MR(i)` together for normal threshold
termination, so f(2) uses a coherent checked state, but no interpolation to
`M_des` or `Mf` is performed.

For a valid objective evaluation, f(2) and f(3) come from the same base call,
decision vector, batch, initial mass, and constant dry mass. They differ in the
final boundary only. A nonphysical trajectory returns a penalized base
objective; `fix1` then returns the penalty vector rather than a valid specific
objective.

## 10. f(2) denominator traceability

The active base objective receives modeled `M` from the v18 wrapper and calls:

```text
cost = calc_cost_breakdown(
    dry_time, Q_aux_tot, Irradiacion, Mi, M, md, params_cost)
```

The cost function constructs:

```text
electric_cost_USD = electric_energy_kWh × electricity_factor
LPG_cost_USD      = Q_aux_tot × LPG_cost_factor
solar_cost_USD    = Irradiacion × solar_cost_factor

total_cost_USD
= electric_cost_USD
+ LPG_cost_USD
+ solar_cost_USD

water_removed_f2_kg = (Mi-M)×md

f(2)
= total_cost_USD / water_removed_f2_kg
```

If the denominator is nonpositive, the cost function returns `NaN` and
`INVALID_DENOMINATOR`; the base objective then retains or returns a penalty
path. For a valid path, the denominator means actual modeled water removal from
the initial dry-basis state to returned terminal `M`.

| Objective | Numerator | Denominator | Denominator meaning | Unit | Evidence |
|---|---|---|---|---|---|
| f(2) | Total modeled operating cost | `(Mi-M)×md` | Simulated water removed to returned terminal `M` | USD/kg water | base lines 92-103; cost lines 48-70 |

## 11. f(3) denominator traceability

The active `fix1` wrapper calls the base objective once and retrieves `mwi` and
`mwf` from `detail.product`:

```text
water_removed_f3_kg = mwi - mwf

f(3)
= CO2_total_kg / water_removed_f3_kg
```

The primary path is used whenever both values are finite, which they are for a
valid base-objective result. If that mass is invalid or nonpositive, `fix1`
tries `detail.product.water_removed_kg` or a top-level `water_removed_kg`.
The active base objective does not populate either fallback field; it stores
the actual denominator under `detail.cost.water_removed_kg`, a path not queried
by the fallback. Consequently, the fallback does not reconcile f(3) with f(2).

| Objective | Numerator | Denominator | Denominator meaning | Unit | Evidence |
|---|---|---|---|---|---|
| f(3) | `CO2_LPG_kg + CO2_electricity_kg` | `mwi-mwf` | Target water removal from initial state to prescribed 8% wet-basis target | kgCO2/kg water | `fix1` lines 67-75 and 86-89 |

The non-`fix1` objective inspected for comparison uses the same primary
`mwi-mwf` construction. It is not the selected formal objective and does not
alter this determination.

## 12. Equivalence determination

The audit establishes all of the following:

- `Mi`, `M`, and `Mf` use the same dry-basis moisture convention;
- `md` is the same constant dry-solid mass for both expressions;
- `mwi = Mi×md`;
- `mwf = Mf×md`;
- both expressions have units of kg water;
- both use the same batch and initial state;
- `(Mi-M)×md` represents removal to simulated terminal `M`;
- `mwi-mwf` represents removal to prescribed target `Mf`;
- the expressions are equal if and only if `M=Mf`;
- the active formulation does not impose `M=Mf`;
- the normal stop uses `M_des` constructed from 10% wet basis, while `Mf` is
  constructed from 8% wet basis; and
- `TMAX` can provide another modeled terminal `M`.

This is positive evidence of different final quantities in the active
formulation, not merely an absence of proof.

WATER_REMOVED_EQUIVALENCE = NOT_EQUIVALENT

WATER_REMOVED_DENOMINATOR_STATUS = UNRECONCILED

F2_F3_NORMALIZATION_STATUS = INCONSISTENT

The conditional algebraic identity remains valid only under the explicit
counterfactual condition `M=Mf`. That condition is not the active termination
rule and therefore does not justify
`PROVEN_WITH_EXPLICIT_ASSUMPTIONS` for the current implementation.

## 13. Findings and risks

| ID | Severity | Finding | Evidence | Consequence | Required resolution |
|---|---|---|---|---|---|
| COST-E3D-R2C-F01 | MAJOR | f(2) and f(3) use different final-state boundaries: modeled terminal `M` versus prescribed target `Mf` | base lines 85-101; cost line 63; `fix1` lines 68-71 | The specific objectives are not normalized by the same water mass | Define one canonical `water_removed_kg` for both objectives in a later coordinated PR |
| COST-E3D-R2C-F02 | MAJOR | The active stopping target is 10% wet basis, while `mwf` represents 8% wet basis; `TMAX` can introduce a third terminal condition | base lines 85-89; wrapper lines 455-460 and 486-488 | `mwi-mwf` does not represent the modeled endpoint for general valid evaluations | Select and document the intended functional-unit endpoint before implementation |
| COST-E3D-R2C-F03 | MODERATE | `fix1` does not query `detail.cost.water_removed_kg` in its fallback | `fix1` lines 74-75; cost line 63 and base `detail.cost` assignment | The available actual-removal field is not reused by f(3) | Route both objectives through an explicitly exposed canonical field in a later PR |
| COST-E3D-R2C-F04 | MODERATE | `build_base_params` sets `M_des=Mf`, but the active objective hardcodes `m_des=0.10` and `m_f=0.08` and does not call that builder | config lines 8-17; active base lines 78-89; no active-chain call found | Parallel configuration can create false confidence about endpoint equality | Reconcile configuration ownership documentarily before code implementation |
| COST-E3D-R2C-F05 | MODERATE | The wrapper updates `M_prod(i+1)` but tests and returns `M_prod(i)` without endpoint interpolation | wrapper lines 379, 455-460 | The actual returned state can differ from both exact `M_des` and `Mf` | Preserve the actual returned state in the canonical denominator or explicitly define an interpolation policy later |

No active variable changes between wet and dry basis without conversion. The
major risk is boundary inconsistency, not dimensional invalidity.

## 14. Consequences for COST-E3D-R1

COST-E3D-R1 classified the equivalence as `NOT_PROVEN`. The focused audit now
resolves that uncertainty for the current active chain:
the expressions are conditionally identical at `M=Mf`, but the active code
assigns them different final states. COST-E3D-R2C therefore records
`NOT_EQUIVALENT`, `UNRECONCILED`, and `INCONSISTENT`.

This document does not edit or retroactively rewrite COST-E3D-R1. It supplies
the controlled follow-up evidence needed for a later documentation and
implementation decision. Because the denominator remains unreconciled, and
solar cost, GDMTO, and coordinated implementation HOLDs remain open,
`ENERGY_COST_RECONCILIATION` cannot be reduced.

COST_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_REMAINING_HOLDS

ENVIRONMENTAL_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_CODE_IMPLEMENTATION

ENERGY_COST_RECONCILIATION = MAJOR_HOLD

## 15. Consequences for R1

R1 remains a valid Gate A operational test of the seed-aware runner and
`gamultiobj` chain. This audit does not invalidate its seed, settings, returned
arrays, solver outputs, hashes, or operational trail.

The denominator inconsistency limits scientific interpretation of f(2) and
f(3). Their values require recalculation after one canonical water-removed
boundary is selected and implemented. R1 does not establish final scientific
results, convergence, global reproducibility, hybrid/gasLP superiority, or a
global Pareto front.

R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST

R1_ECONOMIC_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL

R1_ENVIRONMENTAL_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL

R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL

COST_E3D_FINDINGS_DO_NOT_INVALIDATE_R1_OPERATIONAL_RECORD

## 16. Current COST-E3D-R2C state

COST-E3D-R2C = WATER_REMOVED_EQUIVALENCE_STATIC_AUDIT_COMPLETED_NO_CODE_CHANGE

WATER_REMOVED_EQUIVALENCE = NOT_EQUIVALENT

WATER_REMOVED_DENOMINATOR_STATUS = UNRECONCILED

F2_F3_NORMALIZATION_STATUS = INCONSISTENT

COST_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_REMAINING_HOLDS

ENVIRONMENTAL_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_CODE_IMPLEMENTATION

ENERGY_COST_RECONCILIATION = MAJOR_HOLD

ECONOMIC_FACTOR_CODE_UPDATE = BLOCKED_PENDING_REMAINING_HOLDS_AND_SEPARATE_IMPLEMENTATION_PR

FORMAL_EXECUTION = BLOCKED_PENDING_ECONOMIC_IMPLEMENTATION_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION

No `COMPLETE` state is authorized.

## 17. Next steps

1. A documentation correction for a proven equivalence is not applicable
   because this audit determines `NOT_EQUIVALENT` for the active chain.
2. Define one canonical
   `water_removed_kg` variable in a later coordinated PR.
3. Do not modify code yet.
4. Close the June 2026 solar cost through the official INPC method.
5. Close the applicable June 2026 GDMTO energy charge.
6. Prepare the coordinated cost-and-CO2 implementation only after the
   functional-unit boundary is approved.
7. Request explicit authorization before executing MATLAB.
