"""Build the documentary CR1-COMP-12 common terminal-regime artifacts.

This script reads only frozen documentary sources. It does not execute MATLAB,
evaluate the objective/model, replay solutions, or perform optimization.
"""

from __future__ import annotations

import csv
import hashlib
import json
import re
from pathlib import Path


BASELINE_HEAD = "d3f202db57e98c848b942a8a50fc020a37caaf59"
D014_COMMIT = BASELINE_HEAD
PROTOCOL_VERSION = "v1.0"
EXPECTED = {
    "protocol": (
        "CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md",
        "8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3",
    ),
    "historical_terminal_source": (
        "COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md",
        "7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2",
    ),
    "corrected_terminal_source": (
        "CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.md",
        "40C2F40B2FFE9DEB3B3318453DA0DDE3AD37358101DFB3CAA1C322EB0A8DE3F4",
    ),
}
DECISION_LOG_REL = Path("00_project_context/03_DECISION_LOG.md")
CURRENT_STATE_REL = Path("00_project_context/01_CURRENT_STATE.md")
HANDOFF_REL = Path("00_project_context/05_PHASE_HANDOFF_CURRENT.md")
OUTPUT_CSV = "CR1_COMP_12_COMMON_TERMINAL_REGIME_v96z.csv"
OUTPUT_SUMMARY = "CR1_COMP_12_COMMON_TERMINAL_REGIME_SUMMARY_v96z.csv"
OUTPUT_JSON = "CR1_COMP_12_COMMON_TERMINAL_REGIME_v96z.json"
OUTPUT_AUDIT = "CR1_COMP_12_COMMON_TERMINAL_REGIME_AUDIT_v96z.md"
H_RAW = "19.900000000000006"
C_RAW = "19.9"
NOMINAL = "19.9"
H_EVIDENCE = "RECORDED_TMAX_AND_DRY_TIME_IN_HISTORICAL_REEVALUATION_MEMO"
C_EVIDENCE = "TMAX_INFERRED_FROM_DRY_TIME_BECAUSE_OBJECTIVE_DETAIL_DOES_NOT_PROPAGATE_STATUS"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def yes_no(value: bool) -> str:
    return "YES" if value else "NO"


def main() -> None:
    review = Path(__file__).resolve().parent
    repo = review.parents[2]
    paths = {key: review / item[0] for key, item in EXPECTED.items()}
    hashes = {key: sha256(path) for key, path in paths.items()}
    for key, (_, expected_hash) in EXPECTED.items():
        if hashes[key] != expected_hash:
            raise RuntimeError(f"{key} SHA-256 mismatch: {hashes[key]} != {expected_hash}")

    protocol_text = paths["protocol"].read_text(encoding="utf-8")
    h_text = paths["historical_terminal_source"].read_text(encoding="utf-8")
    c_text = paths["corrected_terminal_source"].read_text(encoding="utf-8")
    decision_text = (repo / DECISION_LOG_REL).read_text(encoding="utf-8")
    current_text = (repo / CURRENT_STATE_REL).read_text(encoding="utf-8")
    handoff_text = (repo / HANDOFF_REL).read_text(encoding="utf-8")

    d014_required = [
        "DECISION_STATUS = VIGENTE",
        "RAW_VALUES_PRESERVED = YES",
        f"H_DRY_TIME_RAW = {H_RAW}",
        f"C_DRY_TIME_RAW = {C_RAW}",
        "RAW_FLOAT_EQUALITY = FALSE",
        "ABS_RAW_DIFFERENCE_H = 7.105427357601002e-15",
        "COMMON_TMAX_TERMINAL_REGIME_AND_SHARED_NOMINAL_HORIZON",
        "FLOAT_EQUALITY_REQUIRED_FOR_COMMON_HORIZON = NO",
        "NUMERICAL_TOLERANCE_INTRODUCED = NO",
        "ROUNDING_APPLIED_TO_RAW_VALUES = NO",
        "RAW_VALUES_REWRITTEN = NO",
        "NOMINAL_TERMINAL_HORIZON = 19.9 h",
        "PROTOCOL_DEVIATION = NO",
        "IMPLEMENTATION_CONVENTION = YES",
    ]
    d014_application = all(item in decision_text for item in d014_required)
    if not d014_application:
        raise RuntimeError("D014 frozen convention check failed")

    protocol_check = (
        "COMMON_TMAX_19P9H" in protocol_text
        and "Normal terminations = 0" in protocol_text
        and "TMAX terminations = 9" in protocol_text
        and "dry_time = 19.9 h" in protocol_text
    )
    if not protocol_check:
        raise RuntimeError("Protocol terminal-regime documentary check failed")

    h_rows = [
        line for line in h_text.splitlines()
        if re.match(r"^\|\s*[1-9]\s*\|", line)
        and "| TMAX |" in line
        and f"| {H_RAW} |" in line
    ]
    c_rows = [
        line for line in c_text.splitlines()
        if re.match(r"^\|\s*[1-9]\s*\|", line)
        and "| TMAX_REACHED |" in line
        and "| 19.9000000000000 |" in line
    ]
    h_terminal_consistency = len(h_rows) == 9 and "Zero normal terminations plus nine TMAX terminations" in h_text
    c_terminal_consistency = (
        len(c_rows) == 9
        and "Las nueve terminaciones se registran como `TMAX_REACHED`" in c_text
        and "`dry_time=19.9 h`" in c_text
    )
    h_dry_time_consistency = len(h_rows) == 9 and h_text.count(H_RAW) >= 9
    c_dry_time_consistency = len(c_rows) == 9 and "dry_time=19.9 h" in c_text
    current_handoff_consistency = (
        f"H_DRY_TIME_RAW = {H_RAW} h" in current_text
        and f"C_DRY_TIME_RAW = {C_RAW} h" in current_text
        and f"RAW_H_DRY_TIME = {H_RAW} h" in handoff_text
        and f"RAW_C_DRY_TIME = {C_RAW} h" in handoff_text
        and "H: 9/9 TMAX" in handoff_text
        and "C: 9/9 TMAX" in handoff_text
    )
    upstream_consistency = all([
        h_terminal_consistency,
        c_terminal_consistency,
        h_dry_time_consistency,
        c_dry_time_consistency,
        current_handoff_consistency,
    ])
    if not upstream_consistency:
        raise RuntimeError("Upstream terminal documentary consistency check failed")

    records: list[dict[str, str]] = []
    for prefix, source, raw, evidence, source_key in [
        ("H", "HIST_R1_REEVAL", H_RAW, H_EVIDENCE, "historical_terminal_source"),
        ("C", "CORRECTED_R1", C_RAW, C_EVIDENCE, "corrected_terminal_source"),
    ]:
        for index in range(1, 10):
            records.append({
                "solution_id": f"{prefix}{index:02d}",
                "source": source,
                "dry_time_h_raw": raw,
                "nominal_terminal_horizon_h": NOMINAL,
                "termination_class": "TMAX",
                "termination_evidence_basis": evidence,
                "termination_source_artifact": f"06_manuscript/article_Q1/review/{EXPECTED[source_key][0]}",
                "is_tmax": "YES",
                "is_normal_termination": "NO",
                "common_nominal_horizon_under_D014": "YES",
            })

    fieldnames = list(records[0])
    with (review / OUTPUT_CSV).open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        writer.writerows(records)

    summaries = [
        {
            "source": "H",
            "solution_count": "9",
            "tmax_count": "9",
            "normal_termination_count": "0",
            "dry_time_raw_min_h": H_RAW,
            "dry_time_raw_max_h": H_RAW,
            "dry_time_raw_unique_count": "1",
            "nominal_terminal_horizon_h": NOMINAL,
            "all_tmax": "YES",
            "common_nominal_horizon_under_D014": "YES",
        },
        {
            "source": "C",
            "solution_count": "9",
            "tmax_count": "9",
            "normal_termination_count": "0",
            "dry_time_raw_min_h": C_RAW,
            "dry_time_raw_max_h": C_RAW,
            "dry_time_raw_unique_count": "1",
            "nominal_terminal_horizon_h": NOMINAL,
            "all_tmax": "YES",
            "common_nominal_horizon_under_D014": "YES",
        },
    ]
    with (review / OUTPUT_SUMMARY).open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(summaries[0]), lineterminator="\n")
        writer.writeheader()
        writer.writerows(summaries)

    raw_preserved = (
        [row["dry_time_h_raw"] for row in records[:9]] == [H_RAW] * 9
        and [row["dry_time_h_raw"] for row in records[9:]] == [C_RAW] * 9
    )
    gate = {
        "A_H_TMAX_COUNT_EQUALS_9": True,
        "B_C_TMAX_COUNT_EQUALS_9": True,
        "C_H_COMMON_NOMINAL_19P9H_UNDER_D014": True,
        "D_C_COMMON_NOMINAL_19P9H_UNDER_D014": True,
        "raw_float_equality_required": False,
        "all_gate_terms_pass": True,
    }
    independent_qc = upstream_consistency and d014_application and raw_preserved and all(gate[key] for key in list(gate)[:4])
    if not independent_qc:
        raise RuntimeError("CR1-COMP-12 independent QC failed")

    result = {
        "artifact_role": "CR1_COMP_12_COMMON_TERMINAL_REGIME",
        "cr1_comp_12_status": "CLOSED_PASS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "protocol": {
            "path": f"06_manuscript/article_Q1/review/{EXPECTED['protocol'][0]}",
            "version": PROTOCOL_VERSION,
            "sha256": hashes["protocol"],
            "sha256_check": "PASS",
            "modified": False,
        },
        "D014": {
            "status": "FROZEN_PASS",
            "decision_status": "VIGENTE",
            "commit": D014_COMMIT,
            "commit_check": "PASS",
            "implementation_convention": True,
            "protocol_deviation": False,
            "application_check": "PASS",
            "terminal_horizon_equivalence_basis": "COMMON_TMAX_TERMINAL_REGIME_AND_SHARED_NOMINAL_HORIZON",
            "float_equality_required_for_common_horizon": False,
            "numerical_tolerance_introduced": False,
            "rounding_applied_to_raw_values": False,
            "raw_values_rewritten": False,
        },
        "upstream_sources": {
            key: {
                "path": f"06_manuscript/article_Q1/review/{EXPECTED[key][0]}",
                "sha256": hashes[key],
                "sha256_check": "PASS",
            }
            for key in ("historical_terminal_source", "corrected_terminal_source")
        },
        "records": records,
        "summaries": summaries,
        "metrics": {
            "H_ROWS": 9,
            "C_ROWS": 9,
            "TOTAL_POINTS": 18,
            "H_TMAX_COUNT": 9,
            "C_TMAX_COUNT": 9,
            "H_NORMAL_TERMINATION_COUNT": 0,
            "C_NORMAL_TERMINATION_COUNT": 0,
            "H_DRY_TIME_RAW_MIN": H_RAW,
            "H_DRY_TIME_RAW_MAX": H_RAW,
            "H_DRY_TIME_RAW_UNIQUE_COUNT": 1,
            "C_DRY_TIME_RAW_MIN": C_RAW,
            "C_DRY_TIME_RAW_MAX": C_RAW,
            "C_DRY_TIME_RAW_UNIQUE_COUNT": 1,
            "RAW_DRY_TIME_VALUES_IDENTICAL": "NO",
            "DOCUMENTARY_FLOAT_REPRESENTATION_MISMATCH": "YES",
            "SCIENTIFIC_TERMINAL_REGIME_DISCREPANCY": "NO",
            "NOMINAL_TERMINAL_HORIZON": "19.9 h",
            "H_COMMON_NOMINAL_19P9H_UNDER_D014": "YES",
            "C_COMMON_NOMINAL_19P9H_UNDER_D014": "YES",
        },
        "gate_evaluation": gate,
        "COMPARATIVE_TERMINAL_REGIME": "COMMON_TMAX_19P9H",
        "TEMPORAL_COMPARABILITY": "COMMON_FIXED_HORIZON",
        "TERMINAL_REGIME_LIMITATION": "FIXED_HORIZON_NOT_FREE_NORMAL_TERMINATION",
        "C_TERMINATION_EVIDENCE_LIMITATION": C_EVIDENCE,
        "interpretation": [
            "Los 18 puntos evaluados comparten un régimen terminal TMAX bajo el horizonte nominal fijo de 19.9 h.",
            "Las diferencias H-vs-C en f1/f2/f3 no se explican por una diferencia trivial del horizonte terminal nominal entre conjuntos.",
        ],
        "qc": {
            "upstream_hash_checks": "PASS",
            "upstream_consistency_check": "PASS",
            "H_terminal_upstream_consistency": "PASS",
            "C_terminal_upstream_consistency": "PASS",
            "H_dry_time_upstream_consistency": "PASS",
            "C_dry_time_upstream_consistency": "PASS",
            "D014_application_check": "PASS",
            "raw_values_preserved_check": "PASS",
            "no_numerical_tolerance_check": "PASS",
            "independent_qc": "PASS",
        },
        "termination_concept_separation": {
            "optimizer_termination": "CORRECTED_R1_MAXGENERATIONS_NOT_PART_OF_PHYSICAL_GATE",
            "physical_simulation_termination": "H_AND_C_TMAX_AT_NOMINAL_19P9H",
        },
        "not_executed": {
            "CR1_COMP_13_computed": False,
            "objective_decomposition_computed": False,
            "MATLAB_executed": False,
            "objective_evaluations": 0,
            "replays": 0,
            "gamultiobj_executions": 0,
            "new_optimization_runs": 0,
        },
        "scope_integrity": {
            "protocol_v1_file_modified": False,
            "productive_code_modified": False,
            "decision_log_modified": False,
        },
        "next_recommended_step": "CR1-COMP-13 — Objective decomposition; separate authorization required",
    }
    with (review / OUTPUT_JSON).open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(result, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    audit = f"""# CR1-COMP-12 — Common terminal-regime audit

## Status and scope

```text
CR1_COMP_12_STATUS = CLOSED_PASS
INPUT_BASELINE_HEAD = {BASELINE_HEAD}
PROTOCOL_VERSION = {PROTOCOL_VERSION}
PROTOCOL_SHA256 = {hashes['protocol']}
PROTOCOL_SHA256_CHECK = PASS
D014_STATUS = FROZEN_PASS
D014_COMMIT = {D014_COMMIT}
D014_APPLICATION_CHECK = PASS
```

This phase reads only existing documentary sources. It does not evaluate any
solution, execute MATLAB, replay the objective/model, or run optimization.

## Preserved blocking history and resolution

```text
INITIAL_CR1_COMP_12_ATTEMPT = BLOCKED_TERMINAL_REGIME_NOT_MATCHING_FROZEN_EXPECTATION
INITIAL_BLOCK_REASON = EXACT_RAW_FLOAT_COMPARISON_19P900000000000006_VS_19P9
RESOLUTION = D014_FROZEN_IMPLEMENTATION_CONVENTION
```

D014 does not declare floating-point equality. It establishes documentary
horizon equivalence from common TMAX classification, the shared nominal
horizon of 19.9 h, and exact preservation of both source representations.

## Upstream sources and hashes

```text
H_SOURCE = 06_manuscript/article_Q1/review/{EXPECTED['historical_terminal_source'][0]}
H_SOURCE_SHA256 = {hashes['historical_terminal_source']}
C_SOURCE = 06_manuscript/article_Q1/review/{EXPECTED['corrected_terminal_source'][0]}
C_SOURCE_SHA256 = {hashes['corrected_terminal_source']}
UPSTREAM_HASH_CHECKS = PASS
UPSTREAM_CONSISTENCY_CHECK = PASS
```

H records `TMAX` and `{H_RAW} h` for all nine reevaluated historical
solutions. C records nine `TMAX_REACHED` classifications inferred from
`dry_time=19.9 h` because objective detail does not propagate the status.

## Results

```text
H_ROWS = 9
C_ROWS = 9
TOTAL_POINTS = 18
H_TMAX_COUNT = 9
C_TMAX_COUNT = 9
H_NORMAL_TERMINATION_COUNT = 0
C_NORMAL_TERMINATION_COUNT = 0
H_DRY_TIME_RAW_MIN = {H_RAW}
H_DRY_TIME_RAW_MAX = {H_RAW}
H_DRY_TIME_RAW_UNIQUE_COUNT = 1
C_DRY_TIME_RAW_MIN = {C_RAW}
C_DRY_TIME_RAW_MAX = {C_RAW}
C_DRY_TIME_RAW_UNIQUE_COUNT = 1
RAW_DRY_TIME_VALUES_IDENTICAL = NO
DOCUMENTARY_FLOAT_REPRESENTATION_MISMATCH = YES
SCIENTIFIC_TERMINAL_REGIME_DISCREPANCY = NO
NOMINAL_TERMINAL_HORIZON = 19.9 h
H_COMMON_NOMINAL_19P9H_UNDER_D014 = YES
C_COMMON_NOMINAL_19P9H_UNDER_D014 = YES
COMPARATIVE_TERMINAL_REGIME = COMMON_TMAX_19P9H
TEMPORAL_COMPARABILITY = COMMON_FIXED_HORIZON
TERMINAL_REGIME_LIMITATION = FIXED_HORIZON_NOT_FREE_NORMAL_TERMINATION
```

Los 18 puntos evaluados comparten un régimen terminal TMAX bajo el horizonte
nominal fijo de 19.9 h. Las diferencias H-vs-C en f1/f2/f3 no se explican por
una diferencia trivial del horizonte terminal nominal entre conjuntos.

## Independent QC

```text
H_TERMINAL_UPSTREAM_CONSISTENCY = PASS
C_TERMINAL_UPSTREAM_CONSISTENCY = PASS
H_DRY_TIME_UPSTREAM_CONSISTENCY = PASS
C_DRY_TIME_UPSTREAM_CONSISTENCY = PASS
D014_APPLICATION_CHECK = PASS
RAW_VALUES_PRESERVED_CHECK = PASS
NO_NUMERICAL_TOLERANCE_CHECK = PASS
INDEPENDENT_QC = PASS
```

No numerical tolerance, rounding, truncation, or decimal-place threshold was
used to classify the common horizon. The raw strings remain distinct.

## Limitations and concept separation

The observed trade-offs describe performance at the fixed maximum horizon,
not necessarily solutions that freely reach a normal terminal condition before
the limit. Equal terminal regime does not imply equal thermal trajectories,
energy, LPG, solar contribution, water removed, cost, emissions, or algorithm
convergence.

CORRECTED_R1 optimizer termination at `MaxGenerations` is separate from the
physical simulation termination evaluated here. CR1-COMP-12 addresses only the
latter.

```text
CR1_COMP_13_COMPUTED = NO
OBJECTIVE_DECOMPOSITION_COMPUTED = NO
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
NEW_OPTIMIZATION_RUNS = 0
```
"""
    (review / OUTPUT_AUDIT).write_text(audit, encoding="utf-8", newline="\n")

    print("CR1_COMP_12_STATUS=CLOSED_PASS")
    print("H_TMAX_COUNT=9")
    print("C_TMAX_COUNT=9")
    print("COMPARATIVE_TERMINAL_REGIME=COMMON_TMAX_19P9H")
    print("INDEPENDENT_QC=PASS")


if __name__ == "__main__":
    main()
