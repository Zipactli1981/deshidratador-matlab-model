"""Apply the frozen CR1-COMP-10 hypervolume decision gate.

This script reads the frozen CR1-COMP-07 JSON and CSV independently. It does
not calculate hypervolume, normalization, anchors, reference points, or
sensitivity, and it does not reconstruct coverage from dominance relations.
"""

from __future__ import annotations

import csv
import hashlib
import json
from pathlib import Path


BASELINE_HEAD = "c9e7b4d16d492fd06e7e2a600208d3d522f6225b"
PROTOCOL_VERSION = "v1.0"
PROTOCOL_STATUS = "FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION"
EXPECTED = {
    "protocol": (
        "CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md",
        "8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3",
    ),
    "coverage_json": (
        "CR1_COMP_07_SET_COVERAGE_v96z.json",
        "8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83",
    ),
    "coverage_csv": (
        "CR1_COMP_07_SET_COVERAGE_v96z.csv",
        "006DE140768490BF4903F266C2D205AAC8B2F1BF4A44E8F836179842825206FF",
    ),
}
OUTPUT_CSV = "CR1_COMP_10_HYPERVOLUME_DECISION_GATE_v96z.csv"
OUTPUT_JSON = "CR1_COMP_10_HYPERVOLUME_DECISION_GATE_v96z.json"
OUTPUT_AUDIT = "CR1_COMP_10_HYPERVOLUME_DECISION_GATE_AUDIT_v96z.md"
METRIC_C_OVER_H = "FULL_COVERAGE_C_OVER_H"
METRIC_H_OVER_C = "FULL_COVERAGE_H_OVER_C"
LIMITED_INTERPRETATION = (
    "La dominancia/cobertura no proporciona una sustitución completa y unidireccional "
    "de H por C bajo la condición congelada; por tanto, el protocolo recomienda "
    "utilizar hypervolume como métrica secundaria adicional."
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def gate(c_over_h: float, h_over_c: float) -> dict[str, object]:
    test_1 = c_over_h == 1
    test_2 = h_over_c == 0
    condition = test_1 and test_2
    return {
        "gate_test_c_over_h_equals_1": test_1,
        "gate_test_h_over_c_equals_0": test_2,
        "gate_full_dominance_condition": condition,
        "selected_branch": "THEN" if condition else "ELSE",
        "hypervolume_gate_outcome": "NOT_REQUIRED" if condition else "RECOMMENDED",
    }


def bool_text(value: bool) -> str:
    return "TRUE" if value else "FALSE"


def main() -> None:
    here = Path(__file__).resolve().parent
    paths = {key: here / filename for key, (filename, _) in EXPECTED.items()}
    hashes = {key: sha256(path) for key, path in paths.items()}
    for key, (_, expected_hash) in EXPECTED.items():
        if hashes[key] != expected_hash:
            raise RuntimeError(f"{key} SHA-256 mismatch: {hashes[key]} != {expected_hash}")

    with paths["coverage_json"].open("r", encoding="utf-8") as handle:
        upstream = json.load(handle)
    if upstream.get("cr1_comp_07_status") != "CLOSED_PASS":
        raise RuntimeError("CR1_COMP_07_STATUS is not CLOSED_PASS")
    if upstream.get("qc", {}).get("independent_qc") != "PASS":
        raise RuntimeError("CR1-COMP-07 INDEPENDENT_QC is not PASS")

    json_metrics = {row["metric"]: row for row in upstream["coverage"]}
    json_c = json_metrics[METRIC_C_OVER_H]
    json_h = json_metrics[METRIC_H_OVER_C]
    json_c_value = json_c["coverage"]
    json_h_value = json_h["coverage"]

    with paths["coverage_csv"].open("r", encoding="utf-8", newline="") as handle:
        csv_metrics = {row["metric"]: row for row in csv.DictReader(handle)}
    csv_c = csv_metrics[METRIC_C_OVER_H]
    csv_h = csv_metrics[METRIC_H_OVER_C]
    csv_c_value = float(csv_c["coverage"])
    csv_h_value = float(csv_h["coverage"])

    expected_memberships = {
        "H_dominated_by_C": ["H05"],
        "C_dominated_by_H": ["C06", "C08"],
    }
    documentary_qc = (
        len(upstream["sets"]["H"]) == 9
        and len(upstream["sets"]["C"]) == 9
        and json_c["numerator"] == 1
        and json_c["denominator"] == 9
        and json_c["fraction"] == "1/9"
        and json_c_value == 1 / 9
        and json_h["numerator"] == 2
        and json_h["denominator"] == 9
        and json_h["fraction"] == "2/9"
        and json_h_value == 2 / 9
        and upstream["dominated_target_ids"]["H_dominated_by_C"]
        == expected_memberships["H_dominated_by_C"]
        and upstream["dominated_target_ids"]["C_dominated_by_H"]
        == expected_memberships["C_dominated_by_H"]
        and int(csv_c["numerator"]) == 1
        and int(csv_c["denominator"]) == 9
        and csv_c["fraction"] == "1/9"
        and int(csv_h["numerator"]) == 2
        and int(csv_h["denominator"]) == 9
        and csv_h["fraction"] == "2/9"
    )
    if not documentary_qc:
        raise RuntimeError("CR1-COMP-07 documentary consistency check failed")

    json_result = gate(json_c_value, json_h_value)
    csv_result = gate(csv_c_value, csv_h_value)
    coverage_consistency = json_c_value == csv_c_value and json_h_value == csv_h_value
    implementations_agree = json_result == csv_result
    if not coverage_consistency:
        raise RuntimeError("BLOCKED_UPSTREAM_COVERAGE_INCONSISTENCY: JSON and CSV differ")
    if not implementations_agree:
        raise RuntimeError("CR1-COMP-10 gate implementations disagree")

    result = json_result
    independent_qc = coverage_consistency and implementations_agree and documentary_qc
    if not independent_qc:
        raise RuntimeError("CR1-COMP-10 independent QC failed")

    csv_row = {
        "full_coverage_c_over_h": json_c_value,
        "full_coverage_h_over_c": json_h_value,
        "gate_test_c_over_h_equals_1": bool_text(result["gate_test_c_over_h_equals_1"]),
        "gate_test_h_over_c_equals_0": bool_text(result["gate_test_h_over_c_equals_0"]),
        "gate_full_dominance_condition": bool_text(result["gate_full_dominance_condition"]),
        "hypervolume_gate_outcome": result["hypervolume_gate_outcome"],
        "hypervolume_computed": "NO",
    }
    with (here / OUTPUT_CSV).open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(csv_row), lineterminator="\n")
        writer.writeheader()
        writer.writerow(csv_row)

    output = {
        "artifact_role": "CR1_COMP_10_HYPERVOLUME_DECISION_GATE",
        "cr1_comp_10_status": "CLOSED_PASS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "protocol": {
            "path": f"06_manuscript/article_Q1/review/{EXPECTED['protocol'][0]}",
            "version": PROTOCOL_VERSION,
            "status": PROTOCOL_STATUS,
            "sha256": hashes["protocol"],
            "sha256_check": "PASS",
        },
        "inputs": {
            "coverage_json": {
                "path": f"06_manuscript/article_Q1/review/{EXPECTED['coverage_json'][0]}",
                "sha256": hashes["coverage_json"],
                "sha256_check": "PASS",
            },
            "coverage_csv": {
                "path": f"06_manuscript/article_Q1/review/{EXPECTED['coverage_csv'][0]}",
                "sha256": hashes["coverage_csv"],
                "sha256_check": "PASS",
            },
            "cr1_comp_07_status": upstream["cr1_comp_07_status"],
            "cr1_comp_07_independent_qc": upstream["qc"]["independent_qc"],
            "H_rows": len(upstream["sets"]["H"]),
            "C_rows": len(upstream["sets"]["C"]),
            "N_H_dominated_by_C": json_c["numerator"],
            "N_C_dominated_by_H": json_h["numerator"],
            "H_dominated_by_C_ids": upstream["dominated_target_ids"]["H_dominated_by_C"],
            "C_dominated_by_H_ids": upstream["dominated_target_ids"]["C_dominated_by_H"],
            "full_coverage_c_over_h": json_c_value,
            "full_coverage_c_over_h_percent": json_c["coverage_percent"],
            "full_coverage_h_over_c": json_h_value,
            "full_coverage_h_over_c_percent": json_h["coverage_percent"],
        },
        "frozen_rule": {
            "if": "FULL_COVERAGE_C_OVER_H == 1 AND FULL_COVERAGE_H_OVER_C == 0",
            "then": "HYPERVOLUME_MAIN_ANALYSIS = NOT_REQUIRED",
            "else": "HYPERVOLUME_ANALYSIS = RECOMMENDED",
            "tolerance_used": False,
            "core_coverage_used": False,
        },
        "gate_evaluation": result,
        "hypervolume_gate_computed": True,
        "hypervolume_computed": False,
        "cr1_comp_11_computed": False,
        "interpretation_limited": LIMITED_INTERPRETATION,
        "qc": {
            "json_csv_coverage_consistency": "PASS",
            "gate_implementations_agree": "PASS",
            "upstream_documentary_consistency": "PASS",
            "independent_qc": "PASS",
        },
        "excluded_computations": {
            "coverage_recalculated_from_dominance_matrix": False,
            "HV_H_computed": False,
            "HV_C_computed": False,
            "HV_anchors_computed": False,
            "HV_normalization_computed": False,
            "HV_reference_points_computed": False,
            "HV_sensitivity_computed": False,
            "terminal_regime_comparison_computed": False,
            "objective_decomposition_computed": False,
        },
        "execution": {
            "MATLAB_executed": False,
            "objective_evaluations": 0,
            "replays": 0,
            "gamultiobj_executions": 0,
        },
        "scope_integrity": {
            "protocol_v1_file_modified": False,
            "productive_code_modified": False,
            "decision_log_modified": False,
        },
        "next_recommended_step": "CR1-COMP-11 — Hypervolume and sensitivity; separate authorization required",
    }
    with (here / OUTPUT_JSON).open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(output, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    audit = f"""# CR1-COMP-10 — Hypervolume decision gate audit

## Purpose and scope

Apply the exact frozen hypervolume decision gate to the already validated
CR1-COMP-07 full-coverage values. This phase decides only whether hypervolume
is recommended as an additional secondary comparison. It does not calculate
hypervolume or execute CR1-COMP-11.

## Baseline and frozen protocol

```text
INPUT_BASELINE_HEAD = {BASELINE_HEAD}
INPUT_BASELINE_CHECK = PASS
PROTOCOL_VERSION = {PROTOCOL_VERSION}
PROTOCOL_STATUS = {PROTOCOL_STATUS}
PROTOCOL_SHA256 = {hashes['protocol']}
PROTOCOL_SHA256_CHECK = PASS
```

## Frozen upstream source

```text
COVERAGE_JSON_SHA256 = {hashes['coverage_json']}
COVERAGE_JSON_SHA256_CHECK = PASS
COVERAGE_CSV_SHA256 = {hashes['coverage_csv']}
COVERAGE_CSV_SHA256_CHECK = PASS
CR1_COMP_07_STATUS = {upstream['cr1_comp_07_status']}
CR1_COMP_07_INDEPENDENT_QC = {upstream['qc']['independent_qc']}
H_ROWS = {len(upstream['sets']['H'])}
C_ROWS = {len(upstream['sets']['C'])}
N_H_DOMINATED_BY_C = {json_c['numerator']}
H_DOMINATED_BY_C_IDS = H05
N_C_DOMINATED_BY_H = {json_h['numerator']}
C_DOMINATED_BY_H_IDS = C06,C08
FULL_COVERAGE_C_OVER_H = {json_c_value}
FULL_COVERAGE_H_OVER_C = {json_h_value}
```

The JSON route is primary. The CSV was read and evaluated independently. No
dominance matrix or coverage value was recomputed.

## Exact frozen rule

```text
IF FULL_COVERAGE_C_OVER_H = 1
AND FULL_COVERAGE_H_OVER_C = 0
THEN HYPERVOLUME_MAIN_ANALYSIS = NOT_REQUIRED
ELSE HYPERVOLUME_ANALYSIS = RECOMMENDED
```

Core coverage, geometry, Pareto rank, medians, dominance counts, near-ties,
visual judgment, and editorial preference were not used. No tolerance,
rounding, threshold, or approximate comparison was introduced.

## Boolean evaluation and result

```text
GATE_TEST_C_OVER_H_EQUALS_1 = {bool_text(result['gate_test_c_over_h_equals_1'])}
GATE_TEST_H_OVER_C_EQUALS_0 = {bool_text(result['gate_test_h_over_c_equals_0'])}
GATE_FULL_DOMINANCE_CONDITION = {bool_text(result['gate_full_dominance_condition'])}
SELECTED_BRANCH = {result['selected_branch']}
HYPERVOLUME_ANALYSIS = {result['hypervolume_gate_outcome']}
HYPERVOLUME_GATE_COMPUTED = YES
HYPERVOLUME_COMPUTED = NO
CR1_COMP_11_COMPUTED = NO
```

## Limited methodological meaning

{LIMITED_INTERPRETATION}

This result does not establish that either set is better, predict which set a
future hypervolume analysis would favor, or demonstrate convergence,
robustness, or approximation quality relative to a true Pareto front.

## Independent QC

```text
JSON_CSV_COVERAGE_CONSISTENCY = PASS
GATE_IMPLEMENTATIONS_AGREE = PASS
UPSTREAM_DOCUMENTARY_CONSISTENCY = PASS
INDEPENDENT_QC = PASS
```

## Separation from CR1-COMP-11

```text
COVERAGE_RECALCULATED_FROM_DOMINANCE_MATRIX = NO
HV_H_COMPUTED = NO
HV_C_COMPUTED = NO
HV_ANCHORS_COMPUTED = NO
HV_NORMALIZATION_COMPUTED = NO
HV_REFERENCE_POINTS_COMPUTED = NO
HV_SENSITIVITY_COMPUTED = NO
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
```

CR1-COMP-11 remains a separate phase requiring explicit authorization.
"""
    (here / OUTPUT_AUDIT).write_text(audit, encoding="utf-8", newline="\n")

    print("CR1_COMP_10_STATUS=CLOSED_PASS")
    print(f"FULL_COVERAGE_C_OVER_H={json_c_value}")
    print(f"FULL_COVERAGE_H_OVER_C={json_h_value}")
    print(f"GATE_FULL_DOMINANCE_CONDITION={bool_text(result['gate_full_dominance_condition'])}")
    print(f"HYPERVOLUME_ANALYSIS={result['hypervolume_gate_outcome']}")
    print("INDEPENDENT_QC=PASS")
    print("HYPERVOLUME_COMPUTED=NO")


if __name__ == "__main__":
    main()
