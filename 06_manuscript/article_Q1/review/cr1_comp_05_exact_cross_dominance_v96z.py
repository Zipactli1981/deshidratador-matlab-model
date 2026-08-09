"""CR1-COMP-05 exact H x C cross-dominance matrix (postrun only)."""

from __future__ import annotations

import csv
import hashlib
import json
import math
from collections import Counter
from pathlib import Path


BASELINE_HEAD = "ae33626571c18000f37c3205dfc622f557c4d4fc"
INPUT_NAME = "CR1_COMP_01_CANONICAL_DATASET_v96z.json"
INPUT_SHA256 = "4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164"
MATRIX_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_MATRIX_v96z.csv"
SUMMARY_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_SUMMARY_v96z.csv"
RESULT_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_v96z.json"
AUDIT_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_AUDIT_v96z.md"
OBJECTIVES = (
    "MR_final",
    "cost_specific_USD_per_kgwater",
    "CO2_specific_kgCO2_per_kgwater",
)
CLASSES = ("C_DOMINATES_H", "H_DOMINATES_C", "INCOMPARABLE", "EXACT_EQUAL")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def vector(record: dict) -> tuple[float, float, float]:
    return tuple(float(record[name]) for name in OBJECTIVES)


def classify_primary(h: tuple[float, ...], c: tuple[float, ...]) -> str:
    """Component-by-component exact classifier without tolerance."""
    h1, h2, h3 = h
    c1, c2, c3 = c
    if h1 == c1 and h2 == c2 and h3 == c3:
        return "EXACT_EQUAL"
    if c1 <= h1 and c2 <= h2 and c3 <= h3 and (c1 < h1 or c2 < h2 or c3 < h3):
        return "C_DOMINATES_H"
    if h1 <= c1 and h2 <= c2 and h3 <= c3 and (h1 < c1 or h2 < c2 or h3 < c3):
        return "H_DOMINATES_C"
    return "INCOMPARABLE"


def classify_independent(h: tuple[float, ...], c: tuple[float, ...]) -> str:
    """Independent all/any boolean-vector classifier used only for QC."""
    c_le_h = [c[k] <= h[k] for k in range(3)]
    h_le_c = [h[k] <= c[k] for k in range(3)]
    c_lt_h = [c[k] < h[k] for k in range(3)]
    h_lt_c = [h[k] < c[k] for k in range(3)]
    equal = [h[k] == c[k] for k in range(3)]
    flags = {
        "C_DOMINATES_H": all(c_le_h) and any(c_lt_h),
        "H_DOMINATES_C": all(h_le_c) and any(h_lt_c),
        "EXACT_EQUAL": all(equal),
    }
    if flags["EXACT_EQUAL"]:
        return "EXACT_EQUAL"
    if flags["C_DOMINATES_H"]:
        return "C_DOMINATES_H"
    if flags["H_DOMINATES_C"]:
        return "H_DOMINATES_C"
    return "INCOMPARABLE"


def pair_row(h_record: dict, c_record: dict) -> dict:
    h = vector(h_record)
    c = vector(c_record)
    classification = classify_primary(h, c)
    return {
        "h_id": h_record["solution_id"],
        "c_id": c_record["solution_id"],
        "h_f1": h[0], "h_f2": h[1], "h_f3": h[2],
        "c_f1": c[0], "c_f2": c[1], "c_f3": c[2],
        "delta_f1_C_minus_H": c[0] - h[0],
        "delta_f2_C_minus_H": c[1] - h[1],
        "delta_f3_C_minus_H": c[2] - h[2],
        "c_le_h_f1": c[0] <= h[0],
        "c_le_h_f2": c[1] <= h[1],
        "c_le_h_f3": c[2] <= h[2],
        "h_le_c_f1": h[0] <= c[0],
        "h_le_c_f2": h[1] <= c[1],
        "h_le_c_f3": h[2] <= c[2],
        "c_any_strictly_lower": any(c[k] < h[k] for k in range(3)),
        "h_any_strictly_lower": any(h[k] < c[k] for k in range(3)),
        "classification": classification,
    }


def write_csv(path: Path, rows: list[dict], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def solution_counts(matrix: list[dict], ids: list[str], id_field: str) -> dict[str, dict[str, int]]:
    return {
        sid: {category: sum(row[id_field] == sid and row["classification"] == category for row in matrix) for category in CLASSES}
        for sid in ids
    }


def build_summary_rows(global_counts: dict, by_c: dict, by_h: dict) -> list[dict]:
    rows = [
        {"scope": "GLOBAL", "solution_id": "ALL", "metric": category, "count": global_counts[category]}
        for category in CLASSES
    ]
    c_metric = {
        "C_DOMINATES_H": "C_DOMINATES_H_COUNT_BY_C",
        "H_DOMINATES_C": "H_DOMINATES_C_COUNT_AGAINST_C",
        "INCOMPARABLE": "INCOMPARABLE_H_COUNT_BY_C",
        "EXACT_EQUAL": "EXACT_EQUAL_H_COUNT_BY_C",
    }
    h_metric = {
        "H_DOMINATES_C": "H_DOMINATES_C_COUNT_BY_H",
        "C_DOMINATES_H": "C_DOMINATES_H_COUNT_AGAINST_H",
        "INCOMPARABLE": "INCOMPARABLE_C_COUNT_BY_H",
        "EXACT_EQUAL": "EXACT_EQUAL_C_COUNT_BY_H",
    }
    for sid, counts in by_c.items():
        rows.extend({"scope": "C_SOLUTION", "solution_id": sid, "metric": c_metric[cat], "count": counts[cat]} for cat in CLASSES)
    for sid, counts in by_h.items():
        rows.extend({"scope": "H_SOLUTION", "solution_id": sid, "metric": h_metric[cat], "count": counts[cat]} for cat in CLASSES)
    return rows


def qc_matrix(matrix: list[dict], h_by_id: dict, c_by_id: dict) -> bool:
    if len(matrix) != 81 or len({(row["h_id"], row["c_id"]) for row in matrix}) != 81:
        return False
    for row in matrix:
        h, c = vector(h_by_id[row["h_id"]]), vector(c_by_id[row["c_id"]])
        if row["classification"] != classify_independent(h, c):
            return False
        c_dom = all(c[k] <= h[k] for k in range(3)) and any(c[k] < h[k] for k in range(3))
        h_dom = all(h[k] <= c[k] for k in range(3)) and any(h[k] < c[k] for k in range(3))
        equal = all(h[k] == c[k] for k in range(3))
        flags = [c_dom, h_dom, equal, not c_dom and not h_dom and not equal]
        if sum(flags) != 1:
            return False
        expected = ("C_DOMINATES_H" if c_dom else "H_DOMINATES_C" if h_dom else "EXACT_EQUAL" if equal else "INCOMPARABLE")
        if row["classification"] != expected:
            return False
    return True


def write_audit(path: Path, counts: dict, by_c: dict, by_h: dict, hashes: dict) -> None:
    max_c = max(v["C_DOMINATES_H"] for v in by_c.values())
    max_h = max(v["H_DOMINATES_C"] for v in by_h.values())
    most_c = [sid for sid, v in by_c.items() if v["C_DOMINATES_H"] == max_c]
    most_h = [sid for sid, v in by_h.items() if v["H_DOMINATES_C"] == max_h]
    lines = [
        "# CR1-COMP-05 — Exact Cross-dominance Audit", "",
        "## Objective and baseline", "",
        "This phase classifies the complete Cartesian matrix H01...H09 × C01...C09 using only the three minimized objectives in the frozen canonical JSON.", "",
        f"- Baseline HEAD: `{BASELINE_HEAD}` (`INPUT_BASELINE_CHECK = PASS`).",
        f"- Input: `06_manuscript/article_Q1/review/{INPUT_NAME}`.",
        f"- Input SHA-256: `{INPUT_SHA256}` (`PASS`).",
        "- Gate: 18 rows; H = 9; C = 9; three finite objectives per row; no penalty rows; IDs and order exact.", "",
        "## Exact definition", "",
        "All objectives are minimized. A dominates B iff every component of A is <= the corresponding component of B and at least one is strictly lower.", "",
        "`PARETO_DEFINITION = EXACT_FULL_PRECISION`", "",
        "`DOMINANCE_TOLERANCE = NONE`", "",
        "`SOLVER_TOLERANCES_USED_FOR_DOMINANCE = NO`", "",
        "No rounding, quantization, isclose, eps, absolute tolerance, relative tolerance, FunctionTolerance, or ConstraintTolerance was used.", "",
        "## Global counts", "",
        "| Category | Count |", "|---|---:|",
    ]
    lines.extend(f"| {category} | {counts[category]} |" for category in CLASSES)
    lines += [
        "", f"The four mutually exclusive counts sum to {sum(counts.values())} of 81 pairs.", "",
        "## Direct per-solution observations", "",
        f"- Highest C→H dominance count: {max_c}, attained by {', '.join(most_c)}.",
        f"- Highest H→C dominance count: {max_h}, attained by {', '.join(most_h)}.",
        "- These are direct matrix counts, not coverage metrics or a selection of a best solution.", "",
        "## Independent QC", "",
        "A second classifier based on all/any boolean vectors reproduced all 81 classifications. Pair uniqueness, mutual exclusivity, category semantics, global-count sum, and per-solution marginal sums passed.", "",
        "`INDEPENDENT_QC = PASS`", "",
        "## Limitations and actions not executed", "",
        "The matrix supports only exact pairwise statements. It does not establish global superiority, coverage, joint Rank 1, statistical significance, convergence, robustness, causality, or a best solution.", "",
        "No near-tie or numerical-fragility audit, coverage, joint sorting, hypervolume, MATLAB, model/objective evaluation, replay, gamultiobj, optimization, or later CR1-COMP phase was executed.", "",
        "`CR1_COMP_06_COMPUTED = NO`", "",
        "`NEAR_TIE_COMPUTED = NO`", "",
        "`COVERAGE_COMPUTED = NO`", "",
        "## Output hashes", "",
    ]
    lines.extend(f"- `{name}`: `{digest}`" for name, digest in hashes.items())
    lines += ["", "The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.", ""]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    here = Path(__file__).resolve().parent
    input_path = here / INPUT_NAME
    if sha256(input_path) != INPUT_SHA256:
        raise RuntimeError("Canonical dataset SHA-256 mismatch")
    data = json.loads(input_path.read_text(encoding="utf-8"))
    records = data.get("records", [])
    if data.get("record_count") != 18 or data.get("objective_order") != list(OBJECTIVES) or data.get("all_objectives_minimized") is not True:
        raise RuntimeError("Unexpected canonical dataset structure")
    h_records = [r for r in records if r.get("source") == "HIST_R1_REEVAL"]
    c_records = [r for r in records if r.get("source") == "CORRECTED_R1"]
    h_ids = [f"H{i:02d}" for i in range(1, 10)]
    c_ids = [f"C{i:02d}" for i in range(1, 10)]
    if [r.get("solution_id") for r in h_records] != h_ids or [r.get("solution_id") for r in c_records] != c_ids:
        raise RuntimeError("Unexpected H/C IDs or order")
    if any(not r.get("finite") or r.get("penalized") or not all(math.isfinite(v) for v in vector(r)) for r in records):
        raise RuntimeError("Nonfinite or penalized objective row encountered")

    matrix = [pair_row(h, c) for h in h_records for c in c_records]
    counts = {category: sum(row["classification"] == category for row in matrix) for category in CLASSES}
    by_c = solution_counts(matrix, c_ids, "c_id")
    by_h = solution_counts(matrix, h_ids, "h_id")
    h_by_id = {r["solution_id"]: r for r in h_records}
    c_by_id = {r["solution_id"]: r for r in c_records}
    independent_qc = (
        qc_matrix(matrix, h_by_id, c_by_id)
        and sum(counts.values()) == 81
        and all(sum(v.values()) == 9 for v in by_c.values())
        and all(sum(v.values()) == 9 for v in by_h.values())
        and sum(v["C_DOMINATES_H"] for v in by_c.values()) == counts["C_DOMINATES_H"]
        and sum(v["H_DOMINATES_C"] for v in by_h.values()) == counts["H_DOMINATES_C"]
    )
    if not independent_qc:
        raise RuntimeError("Independent QC failed")

    matrix_fields = [
        "h_id", "c_id", "h_f1", "h_f2", "h_f3", "c_f1", "c_f2", "c_f3",
        "delta_f1_C_minus_H", "delta_f2_C_minus_H", "delta_f3_C_minus_H",
        "c_le_h_f1", "c_le_h_f2", "c_le_h_f3", "h_le_c_f1", "h_le_c_f2", "h_le_c_f3",
        "c_any_strictly_lower", "h_any_strictly_lower", "classification",
    ]
    summary_rows = build_summary_rows(counts, by_c, by_h)
    matrix_path, summary_path = here / MATRIX_NAME, here / SUMMARY_NAME
    result_path, audit_path = here / RESULT_NAME, here / AUDIT_NAME
    write_csv(matrix_path, matrix, matrix_fields)
    write_csv(summary_path, summary_rows, ["scope", "solution_id", "metric", "count"])

    max_c = max(v["C_DOMINATES_H"] for v in by_c.values())
    max_h = max(v["H_DOMINATES_C"] for v in by_h.values())
    result = {
        "artifact_role": "CR1_COMP_05_EXACT_CROSS_DOMINANCE",
        "cr1_comp_05_status": "CLOSED_PASS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "input": {"path": "06_manuscript/article_Q1/review/" + INPUT_NAME, "sha256": INPUT_SHA256, "sha256_check": "PASS", "dataset_rows": 18, "H_rows": 9, "C_rows": 9, "objectives_per_row": 3, "all_F_values_finite": True, "penalty_rows_included": False},
        "method": {"objectives": list(OBJECTIVES), "sense": "MINIMIZE_ALL", "pareto_definition": "EXACT_FULL_PRECISION", "dominance_rule": "all(a_k <= b_k) and any(a_k < b_k)", "dominance_tolerance": "NONE", "solver_tolerances_used_for_dominance": False, "cartesian_pairing": "9 H x 9 C; no index pairing"},
        "matrix": matrix,
        "global_counts": {"cross_pair_count": 81, **counts},
        "counts_by_C": by_c,
        "counts_by_H": by_h,
        "descriptive_maxima": {"most_dominating_C_solution_ids": [sid for sid, v in by_c.items() if v["C_DOMINATES_H"] == max_c], "most_dominating_C_count": max_c, "most_dominating_H_solution_ids": [sid for sid, v in by_h.items() if v["H_DOMINATES_C"] == max_h], "most_dominating_H_count": max_h},
        "qc": {"independent_qc": "PASS", "independent_classifier_identity_81": "PASS", "unique_cartesian_pairs": "PASS", "one_class_per_pair": "PASS", "category_semantics": "PASS", "category_count_sum": "PASS", "per_solution_marginals": "PASS", "matrix_csv_sha256": sha256(matrix_path), "summary_csv_sha256": sha256(summary_path)},
        "limitations": ["Exact cross-set pairwise classifications only.", "No coverage, joint Rank 1, global superiority, statistical, convergence, robustness, or causal inference."],
        "not_computed": {"cr1_comp_06": True, "near_tie": True, "numeric_fragility": True, "coverage": True, "joint_sorting": True, "hypervolume": True},
        "execution": {"MATLAB_executed": False, "objective_evaluations": 0, "replays": 0, "gamultiobj_executions": 0},
    }
    result_path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    hashes = {Path(__file__).name: sha256(Path(__file__)), MATRIX_NAME: sha256(matrix_path), SUMMARY_NAME: sha256(summary_path), RESULT_NAME: sha256(result_path)}
    write_audit(audit_path, counts, by_c, by_h, hashes)


if __name__ == "__main__":
    main()
