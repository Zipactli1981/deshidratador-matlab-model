# COST-E3D-R2B: GDMTO June 2026 energy-only rate memo v96z

## 1. Purpose

This memo resolves, at the documentary level, the June 2026 electricity-cost
factor selected for the model. It uses the GDMTO category, CFE Division Centro
Sur, Xochitepec, Morelos, and only the official tariff components expressed in
MXN/kWh that are compatible with the previously selected
`ENERGY_ONLY_VARIABLE_CHARGE` boundary.

The resulting variable charge is converted to USD/kWh with the documented
June 2026 Banco de Mexico FIX arithmetic mean. This memo does not change code
or constants, does not calculate a complete electricity bill, and does not
authorize execution.

## 2. Scope and restrictions

This is a documentary resolution only. It:

- does not modify MATLAB code, objective functions, wrappers, or runners;
- does not modify economic constants or CO2 factors;
- does not implement the selected tariff;
- does not execute MATLAB, `gamultiobj`, R1, R2, R3, `minrep`, or a
  400-generation run;
- does not create MAT files, results, figures, or PDFs;
- does not model fixed, demand, capacity, tax, power-factor, penalty, or
  facility-wide billing components;
- does not declare `f(2)` final and does not recalculate R1; and
- does not validate final article results, convergence, reproducibility,
  hybrid/gasLP superiority, or a global Pareto front.

## 3. Evidence base

| Evidence | Verification | Use in this memo | Limitation |
|---|---|---|---|
| CFE, [Tarifa GDMTO](https://app.cfe.mx/Aplicaciones/CCFE/Tarifas/TarifasCREIndustria/Tarifas/GranDemandaMTO.aspx) | Official CFE page reviewed | GDMTO name and general application | Does not verify the actual plant contract |
| CFE/CNE, [Tarifas Finales del Suministro Basico aplicables a partir del 1 de junio de 2026](https://sidof.segob.gob.mx/notas/docFuente/5791865), published in the DOF on 2026-06-26 | Official primary publication reviewed | Effective date and June 2026 tariff components | The HTML conversion must be read using the table headers and units together |
| Official geographic assignment, [DOF/CFE division tables](https://sidof.segob.gob.mx/notas/docFuente/5626590), Table 19 | Official table reviewed | Morelos and Xochitepec assignment to Division Centro Sur | Geographic assignment is not proof of a plant utility contract |
| `COST_E3D_R1_TECHNICAL_RESOLUTION_MEMO_v96z.md` | Local document reviewed | Air-impeller identity, measured power, full-duty decision, and prior GDMTO hold | Documentary decisions pending code implementation |
| `COST_E3D_R2A_SOLAR_INPC_UPDATE_MEMO_v96z.md` | Local document reviewed | June 2026 FIX and current solar boundary | Solar activity boundary remains partial |
| `COST_E3_ECONOMIC_BASIS_DECISION_MEMO_v96z.md` | Local document reviewed | Route C, June 2026 period, GDMTO selection, and energy-only scope | GDMTO rate was previously on hold |
| `COST_E2_ECONOMIC_SOURCE_VALIDATION_FICHES_v96z.md` | Local document reviewed | Source inventory and separation from the thesis-era basis | Inventory did not implement factors |
| `COST_E1_ECONOMIC_CONSTANTS_INVENTORY_v96z.md` | Local document reviewed | Historical constants and `f(2)` trace | Historical electricity value remains unchanged in this PR |
| `CO2_E4_GRID_FACTOR_CODE_UPDATE_v96z.md` | Local document reviewed | Electricity activity relationship to operational CO2 | CO2-E4 is not reopened or modified |
| `COST_E3D_R2D_CANONICAL_WATER_REMOVED_DECISION_MEMO_v96z.md` | Local document reviewed | Common terminal endpoint for `dry_time` and the future canonical denominator | Denominator implementation remains pending |
| Active cost, objective, wrapper, and CO2-wrapper MATLAB files | Statically inspected | `W_comp_kW`, `dry_time`, electricity cost, `f(2)`, and shared kWh trace | No MATLAB execution |

The June tariff source identifies the applicable period in its title and
introductory text (source lines 0-26), defines the Anexo II column structure at
lines 69-91, and gives the Division Centro Sur table at lines 1082-1280. The
GDMTO Centro Sur row is at lines 1195-1207: the monthly supplier-operation
charge, per-kWh components, distribution demand charge, and generation
capacity charge must be associated with their respective headers and units.

## 4. GDMTO category and model-basis decision

The official CFE category page defines GDMTO as *Gran Demanda en Media Tension
Ordinaria* and states that it applies to services supplied at medium voltage
with demand below 100 kW.

ELECTRICITY_TARIFF_CLASS = GDMTO

GDMTO_FULL_NAME = GRAN_DEMANDA_EN_MEDIA_TENSION_ORDINARIA

GDMTO_APPLICATION = MEDIUM_VOLTAGE_DEMAND_BELOW_100_KW

GDMTO_TARIFF_CLASS_STATUS = MODEL_ECONOMIC_BASIS_DECISION

GDMTO_ACTUAL_PLANT_CONTRACT_STATUS = NOT_VERIFIED_FROM_UTILITY_BILL

The measured 1.03 kW air-impeller power is not used to infer that the actual
plant contract necessarily belongs to GDMTO. GDMTO is an existing
methodological decision for the article economic basis. A real utility bill is
not required to close this documented proxy, but the proxy must not be
presented as a verified plant contract.

## 5. Xochitepec geographic tariff assignment

The official CFE/DOF geographic table identifies Table 19 as Division Centro
Sur and lists Xochitepec among the municipalities in the entity of Morelos.

ENTITY = MORELOS

MUNICIPALITY = XOCHITEPEC

CFE_DIVISION = CENTRO_SUR

GDMTO_LOCATION = XOCHITEPEC_MORELOS

GDMTO_CFE_DIVISION = CENTRO_SUR

GDMTO_DIVISION_STATUS = OFFICIAL_GEOGRAPHIC_ASSIGNMENT

## 6. June 2026 official tariff source

The primary source is the CFE publication reproducing CNE oficio
`F00.06.UE/1636/2026` and its annexes in the DOF. It states that the tariffs
apply from 2026-06-01 and remain applicable until modified or replaced. Anexo
II is titled as the basic-supply final tariffs applicable from June 2026.

TARIFF_EFFECTIVE_DATE = 2026_06_01

TARIFF_REFERENCE_MONTH = JUNE_2026

CFE_DIVISION = CENTRO_SUR

CATEGORY = GDMTO

The values below were reconstructed from the Anexo II header and the GDMTO row
for Division Centro Sur, rather than copied without checking column and unit
associations.

## 7. GDMTO Centro Sur component reconstruction

| Component | Official unit | June 2026 value | Included in model? | Reason |
|---|---:|---:|---|---|
| Operacion de la Suministradora de Servicios Basicos | MXN/month | 264.38 | EXCLUDED | Fixed monthly supplier-operation charge is outside the incremental energy-only boundary |
| Transmission | MXN/kWh | 0.1801 | INCLUDED | Variable per-kWh component |
| Distribution | MXN/kW | 221.09 | EXCLUDED | Demand charge requires a demand/billing model |
| CENACE operation | MXN/kWh | 0.0076 | INCLUDED | Variable per-kWh component |
| Servicios Conexos no MEM | MXN/kWh | 0.0069 | INCLUDED | Variable per-kWh component |
| Generation energy | MXN/kWh | 1.052 | INCLUDED | Variable energy component for June 2026 |
| Generation capacity | MXN/kW | 257.66 | EXCLUDED | Capacity charge requires a demand/billing model |

Independent row reconstruction:

OPERACION_SUMINISTRADOR = 264.38_MXN_PER_MONTH

TRANSMISSION = 0.1801_MXN_PER_KWH

DISTRIBUTION = 221.09_MXN_PER_KW

CENACE_OPERATION = 0.0076_MXN_PER_KWH

SERVICIOS_CONEXOS_NO_MEM = 0.0069_MXN_PER_KWH

GENERATION_ENERGY = 1.052_MXN_PER_KWH

GENERATION_CAPACITY = 257.66_MXN_PER_KW

## 8. Energy-only model boundary

ELECTRICITY_COST_MODEL_SCOPE = ENERGY_ONLY_VARIABLE_CHARGE

GDMTO_ENERGY_ONLY_INCLUDED_COMPONENTS = TRANSMISSION; CENACE_OPERATION; SERVICIOS_CONEXOS_NO_MEM; GENERATION_ENERGY

GDMTO_ENERGY_ONLY_EXCLUDED_COMPONENTS = DISTRIBUTION_DEMAND_CHARGE; GENERATION_CAPACITY_CHARGE; FIXED_SUPPLIER_OPERATION_CHARGE

The model values the incremental variable cost of electricity consumed by the
air impeller during a drying trajectory. It does not reconstruct the complete
plant bill, contracted or maximum demand, capacity, fixed supplier charges,
power factor, penalties, taxes, or electricity consumed by other equipment.

## 9. Variable-charge calculation in MXN/kWh

The independently recalculated aggregate is:

```text
GDMTO_ENERGY_ONLY_VARIABLE_CHARGE_MXN_PER_KWH
= 0.1801 + 0.0076 + 0.0069 + 1.052
= 1.2466 MXN/kWh
```

GDMTO_ENERGY_ONLY_VARIABLE_CHARGE_MXN_PER_KWH = 1.2466

The calculation excludes `221.09 MXN/kW`, `257.66 MXN/kW`, and
`264.38 MXN/month` because their activity bases are absent from the selected
model boundary.

## 10. Tax-basis limitation

The primary Anexo II table and surrounding tariff text inspected for this memo
do not explicitly state whether the displayed values include or exclude VAT.
No tax treatment is inferred and no 16 percent adjustment is added.

GDMTO_TAX_BASIS = NOT_EXPLICITLY_STATED_IN_PRIMARY_TABLE

GDMTO_TAX_ADJUSTMENT = NONE_APPLIED_PENDING_EXPLICIT_TAX_BASIS

This limitation does not prevent use of the published tariff values as the
documented energy-only proxy, but it must accompany their interpretation.

## 11. Conversion to USD/kWh

The already documented June 2026 arithmetic mean is:

BANXICO_FIX_JUNE_2026_MEAN = 17.3819136364_MXN_PER_USD

Independent conversion:

```text
GDMTO_ENERGY_ONLY_VARIABLE_CHARGE_USD_PER_KWH
= 1.2466 MXN/kWh / 17.3819136364 MXN/USD
= 0.0717182253966247189010800417 USD/kWh
```

The traceability value is recorded to the precision requested by the project:

GDMTO_ENERGY_ONLY_VARIABLE_CHARGE_USD_PER_KWH = 0.0717182253966247

Presentation value: `0.07172 USD/kWh`.

## 12. Air-impeller activity chain

The model-owner decision selects the measured air-impeller power and operation
over the complete drying duration:

AIR_IMPELLER_MEASURED_POWER = 1.03_KW

AIR_IMPELLER_OPERATION = FULL_DRY_TIME

AIR_IMPELLER_COST_AND_CO2_POWER_BASIS = MEASURED_1.03_KW

ELECTRICITY_ENERGY_MODEL = 1.03_KW_TIMES_DRY_TIME_H

Future coordinated implementation must use:

```text
E_air_impeller_kWh = 1.03 kW * dry_time_h

electricity_cost_USD
= E_air_impeller_kWh * 0.0717182253966247 USD/kWh
= 1.03 * dry_time_h * 0.0717182253966247
```

An independent derived check gives:

```text
1.03 * 0.0717182253966247
= 0.0738697721585 USD/hour
```

ELECTRICITY_VARIABLE_COST_RATE_PER_DRYING_HOUR = 0.0738697721585_USD_PER_HOUR_DERIVED_CHECK_ONLY

This derived value is not selected as a separate implementation constant.

## 13. Temporal-boundary static audit

Static inspection found that `build_cost_params_historical.m` declares the
`dry_time` unit as hours; `opt_tunel_mod2_v18_endpoint_TMAX_corrected.m`
constructs it from simulation time divided by 3600; and
`calc_cost_breakdown.m` multiplies `W_comp_kW` by `dry_time` to produce kWh.
The R2D decision requires `dry_time` and the future canonical denominator to
come from the same terminal simulation index or endpoint, including TMAX.

| Variable | Meaning | Unit | Boundary | Status |
|---|---|---|---|---|
| `dry_time_h` | Duration returned by the drying simulation | h | Actual terminal simulation endpoint | STATIC_UNIT_AND_ENDPOINT_TRACE_CONFIRMED |
| `AIR_IMPELLER_MEASURED_POWER` | Measured operating power selected by the model owner | kW | Air impeller only | DOCUMENTED_PENDING_IMPLEMENTATION |
| `E_air_impeller_kWh` | Air-impeller electrical activity | kWh | 1.03 kW over full `dry_time_h` | DOCUMENTED_PENDING_IMPLEMENTATION |
| `water_removed_kg` | Future common normalization denominator | kg water removed | Same actual terminal endpoint as `dry_time_h` | DECIDED_PENDING_IMPLEMENTATION |

AIR_IMPELLER_OPERATION_BOUNDARY = FULL_DRY_TIME

ELECTRICITY_TIME_BOUNDARY = SAME_TERMINAL_SIMULATION_ENDPOINT_AS_DRY_TIME

The temporal boundary is documentarily reconciled. The coordinated code
implementation of the 1.03 kW power and canonical denominator remains pending.

## 14. Relationship to electricity CO2

ELECTRICITY_ACTIVITY_DATA_FOR_COST_AND_CO2 = AIR_IMPELLER_KWH

ELECTRICITY_ACTIVITY_DATA = AIR_IMPELLER_KWH

Both cost and operational electricity CO2 must use:

`E_air_impeller_kWh = 1.03 * dry_time_h`

The activity is multiplied by different factors: USD/kWh for cost and
kgCO2e/kWh for electricity emissions. This memo does not modify CO2-E4 and
does not recalculate emissions.

## 15. Methodological interpretation

GDMTO_RATE_TYPE = ENERGY_ONLY_VARIABLE_COMPONENT_AGGREGATE

GDMTO_RATE_INTERPRETATION = MODEL_OPERATING_ENERGY_COST_PROXY

GDMTO_EXCLUDED_INTERPRETATIONS = FULL_BILL; CONTRACTED_DEMAND_COST; TOTAL_PLANT_ELECTRICITY_COST

The selected rate is a controlled operating-energy proxy for the model. It is
not a complete invoice, a contracted-demand cost, or the total electricity
cost of the Xochitepec plant.

## 16. Alternatives considered

### Alternative A: generation energy only

Status: `REJECTED`

Reason: `OMITS_OTHER_VARIABLE_PER_KWH_COMPONENTS_OF_FINAL_SUPPLY_TARIFF`

### Alternative B: all components expressed in MXN/kWh

Status: `SELECTED`

Result: `1.2466 MXN/kWh`

Reason: `MATCHES_ENERGY_ONLY_VARIABLE_CHARGE_BOUNDARY`

### Alternative C: include MXN/kW and MXN/month charges

Status: `REJECTED_FOR_CURRENT_MODEL_SCOPE`

Reason: `WOULD_REQUIRE_DEMAND_AND_BILLING_PERIOD_MODEL_NOT_PRESENT`

### Alternative D: reconstruct the actual Xochitepec bill

Status: `NOT_SELECTED`

Reason: `OUTSIDE_CURRENT_OBJECTIVE_BOUNDARY_AND_REQUIRES_ACTUAL_UTILITY_CONTRACT_DATA`

## 17. Consequences for future f(2)

The future coordinated implementation must replace the historical electricity
factor with the documented `0.0717182253966247 USD/kWh` rate and replace the
historical nominal-power expression with the selected measured 1.03 kW basis.
It must preserve electricity as one component of `total_cost_USD` and use the
canonical terminal-state `water_removed_kg` denominator selected by R2D.

This memo does not make those changes. Therefore, existing `f(2)` values remain
methodologically provisional and require recalculation after coordinated
implementation and review.

## 18. Consequences for R1

R1_OPERATIONAL_STATUS = VALID_AS_GATE_A_OPERATIONAL_TEST

R1_ECONOMIC_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL

R1_ENVIRONMENTAL_OBJECTIVE_STATUS = METHODOLOGICALLY_PROVISIONAL

R1_SCIENTIFIC_RESULT_STATUS = NOT_FINAL

R1_F2_F3_RECALCULATION = REQUIRED_AFTER_COORDINATED_IMPLEMENTATION

R1 was not executed or recalculated. Its operational audit record remains
valid within Gate A scope, while its economic and environmental values must
not be treated as final scientific results.

## 19. Findings and decisions

| ID | Classification | Decision or finding | Evidence | Consequence | Status |
|---|---|---|---|---|---|
| COST-E3D-R2B-D01 | DECISION | Retain GDMTO as the article economic-basis tariff class | COST-E3 and model-owner decision | No inference from 1.03 kW or a utility bill | CONFIRMED |
| COST-E3D-R2B-F01 | FINDING | GDMTO means Gran Demanda en Media Tension Ordinaria and applies to medium-voltage demand below 100 kW | Official CFE GDMTO page | Defines category scope | VERIFIED |
| COST-E3D-R2B-F02 | FINDING | Xochitepec, Morelos is assigned to Division Centro Sur | Official CFE/DOF geographic Table 19 | Select Centro Sur tariff table | VERIFIED |
| COST-E3D-R2B-F03 | FINDING | June 2026 GDMTO Centro Sur contains four MXN/kWh and three non-energy components | Official June 2026 Anexo II, lines 1082-1207 | Enables unit-controlled reconstruction | VERIFIED |
| COST-E3D-R2B-D02 | DECISION | Include all and only the four MXN/kWh components | Existing energy-only model boundary | Produces 1.2466 MXN/kWh | SELECTED |
| COST-E3D-R2B-D03 | DECISION | Exclude monthly, demand, and capacity charges | Units and absent billing activity bases | Prevents full-bill interpretation | SELECTED |
| COST-E3D-R2B-F04 | FINDING | Primary table does not explicitly state VAT treatment | Text search and table inspection | No tax adjustment applied | LIMITATION_RECORDED |
| COST-E3D-R2B-F05 | FINDING | June FIX conversion produces 0.0717182253966247 USD/kWh | Independent decimal calculation | Future electricity cost factor | RESOLVED_DOCUMENTALLY |
| COST-E3D-R2B-F06 | FINDING | Static cost chain uses kW times `dry_time` in hours and feeds electricity cost into `f(2)` | Active MATLAB files, static inspection | Future 1.03 kW implementation is traceable | VERIFIED_NO_EXECUTION |
| COST-E3D-R2B-D04 | DECISION | Cost and electricity CO2 share `E_air_impeller_kWh` | R1 technical resolution and CO2 wrapper trace | Coordinated implementation required | CONFIRMED_PENDING_IMPLEMENTATION |
| COST-E3D-R2B-H01 | HOLD | Solar boundary and coordinated economic/CO2 implementation remain incomplete | R2A, R2D, and current code state | Formal execution remains blocked | OPEN |

## 20. Current COST-E3D-R2B state

COST-E3D-R2B = GDMTO_JUNE_2026_ENERGY_ONLY_RATE_DOCUMENTED_NO_CODE_CHANGE

GDMTO_LOCATION = XOCHITEPEC_MORELOS

GDMTO_CFE_DIVISION = CENTRO_SUR

ELECTRICITY_TARIFF_CLASS = GDMTO

GDMTO_TARIFF_REFERENCE_MONTH = JUNE_2026

GDMTO_TRANSMISSION_MXN_PER_KWH = 0.1801

GDMTO_CENACE_OPERATION_MXN_PER_KWH = 0.0076

GDMTO_SERVICIOS_CONEXOS_NO_MEM_MXN_PER_KWH = 0.0069

GDMTO_GENERATION_ENERGY_MXN_PER_KWH = 1.052

GDMTO_DISTRIBUTION_MXN_PER_KW = 221.09

GDMTO_GENERATION_CAPACITY_MXN_PER_KW = 257.66

GDMTO_SUPPLIER_OPERATION_MXN_PER_MONTH = 264.38

GDMTO_ENERGY_ONLY_VARIABLE_CHARGE_MXN_PER_KWH = 1.2466

BANXICO_FIX_JUNE_2026_MEAN = 17.3819136364_MXN_PER_USD

GDMTO_ENERGY_ONLY_VARIABLE_CHARGE_USD_PER_KWH = 0.0717182253966247

AIR_IMPELLER_MEASURED_POWER = 1.03_KW

ELECTRICITY_VARIABLE_COST_RATE_PER_DRYING_HOUR = 0.0738697721585_USD_PER_HOUR_DERIVED_CHECK_ONLY

ELECTRICITY_COST_MODEL_SCOPE = ENERGY_ONLY_VARIABLE_CHARGE

ELECTRICITY_ACTIVITY_DATA = AIR_IMPELLER_KWH

ELECTRICITY_GDMTO_JUNE_2026_RATE = RESOLVED_DOCUMENTALLY_PENDING_CODE_IMPLEMENTATION

ELECTRICITY_COST_FINAL_USD_PER_KWH = 0.0717182253966247

GDMTO_RATE_TYPE = ENERGY_ONLY_VARIABLE_COMPONENT_AGGREGATE

GDMTO_TAX_BASIS = NOT_EXPLICITLY_STATED_IN_PRIMARY_TABLE

EXTERNAL_ECONOMIC_FACTORS_STATUS = DOCUMENTALLY_RESOLVED

SOLAR_COST_FACTOR = RESOLVED

SOLAR_ACTIVITY_BOUNDARY = PARTIALLY_RECONCILED

WATER_REMOVED_DENOMINATOR_IMPLEMENTATION = PENDING_SEPARATE_CODE_PR

ENERGY_COST_RECONCILIATION = MAJOR_HOLD

COST_OBJECTIVE_TRACEABILITY = PARTIAL_PENDING_COORDINATED_IMPLEMENTATION

ECONOMIC_FACTOR_CODE_UPDATE = READY_FOR_COORDINATED_IMPLEMENTATION_PR_AFTER_R2B_REVIEW

FORMAL_EXECUTION = BLOCKED_PENDING_ECONOMIC_IMPLEMENTATION_REVIEW_AND_EXPLICIT_RUN_AUTHORIZATION

The external GLP, solar, electricity, and FIX factors are now resolved at the
documentary level. This does not make the energy-cost reconciliation complete
and does not authorize implementation or execution.

## 21. Remaining holds

1. Final reconciliation of the solar activity boundary.
2. Implementation of the canonical water-removed denominator.
3. Implementation of the documented LPG chain.
4. Implementation of the documented solar cost.
5. Implementation of the documented electricity cost and 1.03 kW basis.
6. Coordinated implementation of electricity and LPG CO2 activity chains.
7. Static post-implementation review of units, factors, and boundaries.
8. An explicitly authorized minimal test.
9. Recalculation of `f(2)`, `f(3)`, and R1 after reviewed implementation.

## 22. Next steps

1. Review and merge COST-E3D-R2B.
2. Prepare a coordinated implementation PR only after that review.
3. Reconcile the exact `Irradiacion` boundary in the implementation design.
4. Implement the common canonical `water_removed_kg` denominator.
5. Implement the LPG, solar, and electricity chains coherently.
6. Use the same electrical activity for cost and CO2.
7. Perform a static post-implementation audit.
8. Request explicit authorization before executing MATLAB.

No code PR is created or authorized by this memo.
