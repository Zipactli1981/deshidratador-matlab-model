"""CR1-COMP-02: exact within-set Pareto audit (postrun, no model calls)."""

from __future__ import annotations

import csv
import hashlib
import itertools
import json
import math
from pathlib import Path


BASELINE_HEAD = "407e9589245e6a2bc7a167b150e7fa233df64201"
INPUT_NAME = "CR1_COMP_01_CANONICAL_DATASET_v96z.json"
INPUT_SHA256 = "4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164"
PAIR_NAME = "CR1_COMP_02_WITHIN_SET_EXACT_PARETO_AUDIT_v96z.csv"
STATUS_NAME = "CR1_COMP_02_WITHIN_SET_SOLUTION_STATUS_v96z.csv"
RESULT_NAME = "CR1_COMP_02_WITHIN_SET_EXACT_PARETO_AUDIT_v96z.json"
OBJECTIVES = (
    "MR_final",
    "cost_specific_USD_per_kgwater",
    "CO2_specific_kgCO2_per_kgwater",
)
SETS = {"H": "HIST_R1_REEVAL", "C": "CORRECTED_R1"}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def objective_vector(record: dict) -> tuple[float, float, float]:
    return tuple(record[name] for name in OBJECTIVES)


def dominates(a: tuple[float, ...], b: tuple[float, ...]) -> bool:
    """Frozen exact minimization rule: all(a <= b) and any(a < b)."""
    return all(x <= y for x, y in zip(a, b)) and any(
        x < y for x, y in zip(a, b)
    )


def classify(a: tuple[float, ...], b: tuple[float, ...]) -> str:
    if a == b:
        return "EXACT_OBJECTIVE_VECTOR_EQUALITY"
    if dominates(a, b):
        return "A_DOMINATES_B"
    if dominates(b, a):
        return "B_DOMINATES_A"
    return "INCOMPARABLE"


def independent_classify(a: tuple[float, ...], b: tuple[float, ...]) -> str:
    """Independent sign-pattern implementation used only for QC."""
    signs = tuple((x > y) - (x < y) for x, y in zip(a, b))
    if signs == (0, 0, 0):
        return "EXACT_OBJECTIVE_VECTOR_EQUALITY"
    if max(signs) <= 0 and min(signs) < 0:
        return "A_DOMINATES_B"
    if min(signs) >= 0 and max(signs) > 0:
        return "B_DOMINATES_A"
    return "INCOMPARABLE"


def audit_set(label: str, records: list[dict]) -> tuple[list[dict], list[dict], dict]:
    status = {
        r["solution_id"]: {"dominators": [], "dominates": [], "equals": []}
        for r in records
    }
    pairs = []
    independent_match = True
    for a, b in itertools.combinations(records, 2):
        av = objective_vector(a)
        bv = objective_vector(b)
        relation = classify(av, bv)
        independent_match &= relation == independent_classify(av, bv)
        aid, bid = a["solution_id"], b["solution_id"]
        if relation == "A_DOMINATES_B":
            status[aid]["dominates"].append(bid)
            status[bid]["dominators"].append(aid)
        elif relation == "B_DOMINATES_A":
            status[bid]["dominates"].append(aid)
            status[aid]["dominators"].append(bid)
        elif relation == "EXACT_OBJECTIVE_VECTOR_EQUALITY":
            status[aid]["equals"].append(bid)
            status[bid]["equals"].append(aid)
        pairs.append(
            {
                "set": label,
                "solution_a": aid,
                "solution_b": bid,
                "a_f1": av[0],
                "a_f2": av[1],
                "a_f3": av[2],
                "b_f1": bv[0],
                "b_f2": bv[1],
                "b_f3": bv[2],
                "relation": relation,
            }
        )

    solution_rows = []
    by_id = {r["solution_id"]: r for r in records}
    for record in records:
        sid = record["solution_id"]
        entry = status[sid]
        dominated = bool(entry["dominators"])
        solution_rows.append(
            {
                "solution_id": sid,
                "source": record["source"],
                "dominated_internal": "YES" if dominated else "NO",
                "dominator_count": len(entry["dominators"]),
                "dominators_internal": ";".join(entry["dominators"]),
                "dominates_count": len(entry["dominates"]),
                "dominates_internal": ";".join(entry["dominates"]),
                "exact_equal_count": len(entry["equals"]),
                "exact_equals_internal": ";".join(entry["equals"]),
                "within_set_nondominated": "NO" if dominated else "YES",
            }
        )

    unique_keys = {(p["solution_a"], p["solution_b"]) for p in pairs}
    reversed_absent = all((b, a) not in unique_keys for a, b in unique_keys)
    listed_dominators_valid = all(
        dominates(objective_vector(by_id[d]), objective_vector(by_id[sid]))
        for sid, entry in status.items()
        for d in entry["dominators"]
    )
    state_consistent = all(
        (row["dominated_internal"] == "NO" and row["dominator_count"] == 0)
        or (row["dominated_internal"] == "YES" and row["dominator_count"] > 0)
        for row in solution_rows
    )
    counts = {
        relation: sum(p["relation"] == relation for p in pairs)
        for relation in (
            "A_DOMINATES_B",
            "B_DOMINATES_A",
            "INCOMPARABLE",
            "EXACT_OBJECTIVE_VECTOR_EQUALITY",
        )
    }
    aggregate = {
        "pair_count": len(pairs),
        "nondominated_count": sum(
            row["within_set_nondominated"] == "YES" for row in solution_rows
        ),
        "dominated_count": sum(
            row["dominated_internal"] == "YES" for row in solution_rows
        ),
        "dominance_relation_count": counts["A_DOMINATES_B"]
        + counts["B_DOMINATES_A"],
        "incomparable_pair_count": counts["INCOMPARABLE"],
        "exact_equal_pair_count": counts["EXACT_OBJECTIVE_VECTOR_EQUALITY"],
        "nondominated_core": [
            row["solution_id"]
            for row in solution_rows
            if row["within_set_nondominated"] == "YES"
        ],
        "relation_counts": counts,
        "qc": {
            "exactly_36_unique_pairs": len(pairs) == len(unique_keys) == 36,
            "no_reversed_duplicates": reversed_absent,
            "one_category_per_pair": sum(counts.values()) == len(pairs) == 36,
            "solution_state_consistency": state_consistent,
            "listed_dominators_revalidated": listed_dominators_valid,
            "independent_implementation_identity": independent_match,
        },
    }
    aggregate["qc"]["nondominated_complement_consistency"] = (
        aggregate["nondominated_count"] + aggregate["dominated_count"] == 9
        and aggregate["nondominated_core"]
        == [
            row["solution_id"]
            for row in solution_rows
            if row["dominated_internal"] == "NO"
        ]
    )
    return pairs, solution_rows, aggregate


def write_csv(path: Path, rows: list[dict], fieldnames: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    here = Path(__file__).resolve().parent
    input_path = here / INPUT_NAME
    if sha256(input_path) != INPUT_SHA256:
        raise RuntimeError("Canonical JSON SHA-256 mismatch")
    data = json.loads(input_path.read_text(encoding="utf-8"))
    if (
        data.get("record_count") != 18
        or data.get("objective_order") != list(OBJECTIVES)
        or data.get("all_objectives_minimized") is not True
    ):
        raise RuntimeError("Unexpected canonical dataset structure")

    records = data.get("records", [])
    if any(
        not r.get("finite")
        or r.get("penalized")
        or not all(math.isfinite(v) for v in objective_vector(r))
        for r in records
    ):
        raise RuntimeError("Nonfinite or penalized row encountered")

    all_pairs, all_status, aggregates = [], [], {}
    set_records = {}
    for label, source in SETS.items():
        selected = [r for r in records if r.get("source") == source]
        expected_ids = [f"{label}{i:02d}" for i in range(1, 10)]
        if len(selected) != 9 or [r["solution_id"] for r in selected] != expected_ids:
            raise RuntimeError(f"Unexpected {label} membership/order")
        set_records[label] = selected
        pairs, statuses, aggregate = audit_set(label, selected)
        all_pairs.extend(pairs)
        all_status.extend(statuses)
        aggregates[label] = aggregate

    pair_fields = [
        "set", "solution_a", "solution_b", "a_f1", "a_f2", "a_f3",
        "b_f1", "b_f2", "b_f3", "relation",
    ]
    status_fields = [
        "solution_id", "source", "dominated_internal", "dominator_count",
        "dominators_internal", "dominates_count", "dominates_internal",
        "exact_equal_count", "exact_equals_internal", "within_set_nondominated",
    ]
    write_csv(here / PAIR_NAME, all_pairs, pair_fields)
    write_csv(here / STATUS_NAME, all_status, status_fields)

    independent_qc = all(
        value for aggregate in aggregates.values() for value in aggregate["qc"].values()
    )
    result = {
        "artifact_role": "CR1_COMP_02_WITHIN_SET_EXACT_PARETO_AUDIT",
        "cr1_comp_02_status": "CLOSED_PASS" if independent_qc else "BLOCKED",
        "baseline_commit": BASELINE_HEAD,
        "input": {
            "dataset_path": "06_manuscript/article_Q1/review/" + INPUT_NAME,
            "dataset_sha256": INPUT_SHA256,
            "dataset_sha256_check": "PASS",
            "row_count": 18,
            "H_rows": 9,
            "C_rows": 9,
            "all_finite": True,
            "penalty_rows_included": False,
        },
        "method": {
            "objectives": list(OBJECTIVES),
            "sense": "MINIMIZE_ALL",
            "pareto_definition": "EXACT",
            "dominance_rule": "all(a_k <= b_k) and any(a_j < b_j)",
            "dominance_tolerance": "NONE",
            "solver_tolerances_used_for_dominance": False,
            "near_tie_diagnostic_computed": False,
            "numeric_fragility_computed": False,
        },
        "pairs": all_pairs,
        "solutions": all_status,
        "N_H": aggregates["H"]["nondominated_core"],
        "N_C": aggregates["C"]["nondominated_core"],
        "aggregates": aggregates,
        "qc": {
            "independent_qc": "PASS" if independent_qc else "FAIL",
            "pair_csv_sha256": sha256(here / PAIR_NAME),
            "solution_status_csv_sha256": sha256(here / STATUS_NAME),
        },
        "not_computed": {
            "cross_dominance": True,
            "coverage": True,
            "joint_sorting": True,
            "hypervolume": True,
            "decision_space_statistics": True,
            "objective_space_statistics": True,
        },
    }
    (here / RESULT_NAME).write_text(
        json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    if not independent_qc:
        raise RuntimeError("Independent QC failed")


if __name__ == "__main__":
    main()
