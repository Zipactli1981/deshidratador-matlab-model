# CR1-COMP-01-F1 — Canonical Dataset Freeze Audit

## Purpose and scope

This audit records the deterministic construction and freeze of the canonical 18-row H-vs-C comparative dataset. It performs only source parsing, serialization, provenance, dimensional, finiteness, penalty-flag, identifier, and decision-variable bounds controls. It does not perform Pareto or scientific comparative analysis.

```text
CR1_COMP_01_F1_STATUS = PASS
CR1_COMP_01_DATASET_FREEZE = PASS
COMPARATIVE_DATASET = BUILT_FROZEN_VALIDATED
CR1_COMP_01_STATUS = CLOSED_PASS
```

## Governing protocol

```text
COMPARATIVE_PROTOCOL_VERSION = v1.0
PROTOCOL_STATUS = FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
PROTOCOL = 06_manuscript/article_Q1/review/CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md
PROTOCOL_SHA256 = 8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
PROTOCOL_MODIFIED = NO
```

## Authorized source chain

### D1 decision

```text
Artifact = 06_manuscript/article_Q1/review/CR1_COMP_01_D1_H_CORRECTED_F_DOCUMENTARY_RECOVERY_DECISION_v96z.md
SHA-256 = 01F3232ED40303C29F64C1970BE1EF0FAD11394609C6D489FA9D97E1474DBA0F
Status = PASS
```

### E1 immediate frozen source

| Role | Artifact | SHA-256 | Verified |
|---|---|---|---|
| Immediate numeric source | `06_manuscript/article_Q1/review/CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY_v96z.json` | `E3F591E154E686BB81D28EF8D02A0A13C3DD300C8A2E36181E2B765FCCC2DAAF` | PASS |
| Cross-evidence/readability | `06_manuscript/article_Q1/review/CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY_v96z.csv` | `869A070F972319ABC0AC0BCD44EF6699E5C3BC92BAB53EB5328AEFB1275F7D2D` | PASS |
| E1 audit | `06_manuscript/article_Q1/review/CR1_COMP_01_E1_SOURCE_VALUE_RECOVERY_AUDIT_v96z.md` | `FB7716B3ED45E8A7C297FF01EEB67D128A1D836E46F4B0F8DB9AA33534BEA852` | PASS |

All three hashes were reverified before dataset construction.

### Upstream provenance

| Dataset values | Upstream artifact | SHA-256 |
|---|---|---|
| H.X and H.f1 | `06_manuscript/article_Q1/runs/SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat` | `A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0` |
| H.f2 and H.f3 | `06_manuscript/article_Q1/review/COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md` | `7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2` |
| C.X and C.F | `05_runs/triobjective_formal_ga_v96m/CORRECTED_R1_COST_E3D_v96z_20260808_005736/mat/CORRECTED_R1_COST_E3D_v96z.mat` | `0AE9D8C90EEE645EC5BAB843A18F59CC1E68E2D84B31CBFD7ADD498C81EBDB3B` |

H.f2/f3 are not represented as originating from the historical MAT. Their validated 17-significant-digit decimal serialization comes from the COST-E3D-R2G memo under D1.

Every canonical row records the immediate E1 JSON as `source_artifact`, its verified SHA-256 as `source_hash`, and its 1-based E1 record position as `source_row`. The upstream dual provenance for H is preserved explicitly in the JSON metadata and this audit.

## Dataset structure

Canonical row order is fixed as `H01`…`H09`, then `C01`…`C09`. No objective or variable sort was performed. `solution_id` and `source_index` record only original within-source position; H and C records are not paired by index.

Decision-variable order:

```text
x = [m_max, T_min, r_div2, t_rec_ini]
units = [kg/s, degC, dimensionless, h]
```

Objective order:

```text
F = [MR_final, cost_specific_USD_per_kgwater, CO2_specific_kgCO2_per_kgwater]
all objectives = minimized
```

Required fields are present in both primary serializations:

```text
solution_id
source
source_index
m_max
T_min
r_div2
t_rec_ini
MR_final
cost_specific_USD_per_kgwater
CO2_specific_kgCO2_per_kgwater
source_artifact
source_hash
source_row
finite
penalized
```

The JSON additionally preserves, per record, `values_decimal` in canonical seven-value order and `binary64_hex`. Direct invariant-culture parsing of every preserved decimal lexeme reproduced its E1 IEEE-754 binary64 hex value. The CSV values, JSON `values_decimal`, and E1 `values_decimal` matched character-for-character for all 126 primary scalar values.

## Bounds control

The frozen CORRECTED_R1 decision-variable bounds were used only for a direct inclusion check:

```text
lb = [0.0540767982118, 57.6832965028, 0.422252618341, 8.6517528081]
ub = [0.0940767982118, 67.6832965028, 0.922252618341, 14]
BOUNDS_CHECK = PASS
```

No objective or model was evaluated.

## Control results

| Control | Result |
|---|---|
| `DATASET_ROWS = 18` | PASS |
| `HISTORICAL_ROWS = 9` | PASS |
| `CORRECTED_R1_ROWS = 9` | PASS |
| `DECISION_VARIABLES_PER_ROW = 4` | PASS |
| `OBJECTIVES_PER_ROW = 3` | PASS |
| `ALL_PRIMARY_VALUES_FROM_CANONICAL_VALIDATED_ARTIFACTS = YES` | PASS |
| `FULL_PRECISION_PRIMARY_VALUES_USED = PASS_WITH_DOCUMENTARY_RECOVERY_DEVIATION_CR1_COMP_01_D1` | PASS |
| `ALL_F_VALUES_FINITE = YES` | PASS |
| `PENALTY_ROWS_INCLUDED = NO` | PASS |
| `BOUNDS_CHECK = PASS` | PASS |
| `CANONICAL_SOURCE_TRACEABILITY = PASS` | PASS |
| `SOLUTION_IDS_UNIQUE = YES` | PASS |
| `SOURCE_INDEX_H = 1..9` | PASS |
| `SOURCE_INDEX_C = 1..9` | PASS |
| `NO_IMPLICIT_H_C_PAIRING = PASS` | PASS |
| Canonical order H01…H09, C01…C09 | PASS |
| E1/CSV/JSON decimal lexemes identical | PASS |
| Decimal lexemes reproduce registered binary64 hex | PASS |

## Frozen artifacts

```text
CANONICAL_DATASET_CSV = 06_manuscript/article_Q1/review/CR1_COMP_01_CANONICAL_DATASET_v96z.csv
CANONICAL_DATASET_CSV_SHA256 = B17B461FB04C9693FC9DA0C3450703C34E4538894AD232EF7138AE5E9882CD62

CANONICAL_DATASET_JSON = 06_manuscript/article_Q1/review/CR1_COMP_01_CANONICAL_DATASET_v96z.json
CANONICAL_DATASET_JSON_SHA256 = 4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164
```

## Limitations

The original corrected H.f2/f3 binary64 values were not persisted independently. D1 therefore remains an explicit documentary limitation: the dataset uses the validated 17-significant-digit decimal source and its deterministic binary64 parsing, without claiming independent recovery of the original in-memory bits. H.X and H.f1 retain their historical MAT provenance. Historical H records remain reevaluated samples, not a corrected Pareto front.

## Actions not executed

```text
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
DOMINANCE_COMPUTED = NO
PARETO_SORTING_COMPUTED = NO
NEAR_TIE_ANALYSIS = NO
COVERAGE_COMPUTED = NO
HYPERVOLUME_COMPUTED = NO
OBJECTIVE_SPACE_GEOMETRY = NO
COMPARATIVE_DESCRIPTIVE_ANALYSIS = NO
FIGURES_CREATED = NO
SCIENTIFIC_INTERPRETATION = NO
PRODUCTIVE_CODE_MODIFIED = NO
```

No internal-pair, cross-pair, dominance-matrix, Pareto-rank, coverage, or hypervolume value was computed or recorded.

## Final status

All required dataset-freeze controls passed.

```text
CR1_COMP_01_F1_STATUS = PASS
CR1_COMP_01_DATASET_FREEZE = PASS
COMPARATIVE_DATASET = BUILT_FROZEN_VALIDATED
CR1_COMP_01_STATUS = CLOSED_PASS
NEXT_COMPARATIVE_PHASE = CR1-COMP-02 — Within-set exact Pareto audit
```

CR1-COMP-02 requires separate authorization.
