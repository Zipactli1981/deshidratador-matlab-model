"""CR1-COMP-06 numerical near-tie sensitivity audit (diagnostic only)."""

from __future__ import annotations

import csv
import hashlib
import json
import math
from pathlib import Path


BASELINE_HEAD = "4843af1ebe91290fb1c255d947329ce488198ab1"
DATASET_NAME = "CR1_COMP_01_CANONICAL_DATASET_v96z.json"
DATASET_SHA256 = "4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164"
CROSS_MATRIX_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_MATRIX_v96z.csv"
CROSS_MATRIX_SHA256 = "C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329"
CROSS_RESULT_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_v96z.json"
CROSS_RESULT_SHA256 = "88EE7D86AFEE3A1C5E33D3BD2629995277481A2B65FDF03C83594888402D701A"
MATRIX_NAME = "CR1_COMP_06_NUMERICAL_NEAR_TIE_MATRIX_v96z.csv"
SUMMARY_NAME = "CR1_COMP_06_NUMERICAL_NEAR_TIE_SUMMARY_v96z.csv"
RESULT_NAME = "CR1_COMP_06_NUMERICAL_NEAR_TIE_SENSITIVITY_v96z.json"
AUDIT_NAME = "CR1_COMP_06_NUMERICAL_NEAR_TIE_SENSITIVITY_AUDIT_v96z.md"
OBJECTIVES = (
    "MR_final",
    "cost_specific_USD_per_kgwater",
    "CO2_specific_kgCO2_per_kgwater",
)
F_LABELS = ("f1", "f2", "f3")
DOMINANCE_CLASSES = ("C_DOMINATES_H", "H_DOMINATES_C")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def vector(record: dict) -> tuple[float, float, float]:
    return tuple(float(record[name]) for name in OBJECTIVES)


def exact_classify(h: tuple[float, ...], c: tuple[float, ...]) -> str:
    if all(h[k] == c[k] for k in range(3)):
        return "EXACT_EQUAL"
    if all(c[k] <= h[k] for k in range(3)) and any(c[k] < h[k] for k in range(3)):
        return "C_DOMINATES_H"
    if all(h[k] <= c[k] for k in range(3)) and any(h[k] < c[k] for k in range(3)):
        return "H_DOMINATES_C"
    return "INCOMPARABLE"


def tau_main(a: float, b: float) -> float:
    return 1e-12 * max(1.0, abs(a), abs(b))


def analyze_pair(h_record: dict, c_record: dict, classification: str) -> dict:
    h, c = vector(h_record), vector(c_record)
    deltas = [c[k] - h[k] for k in range(3)]
    abs_deltas = [abs(value) for value in deltas]
    taus = [tau_main(h[k], c[k]) for k in range(3)]
    near = [abs_deltas[k] <= taus[k] for k in range(3)]
    if classification == "C_DOMINATES_H":
        strict = [k for k in range(3) if c[k] < h[k]]
    elif classification == "H_DOMINATES_C":
        strict = [k for k in range(3) if h[k] < c[k]]
    else:
        strict = []
    fragile: str | bool = all(near[k] for k in strict) if strict else "NOT_APPLICABLE"
    return {
        "h_id": h_record["solution_id"], "c_id": c_record["solution_id"],
        "exact_classification": classification,
        "h_f1": h[0], "h_f2": h[1], "h_f3": h[2],
        "c_f1": c[0], "c_f2": c[1], "c_f3": c[2],
        "delta_f1_C_minus_H": deltas[0], "delta_f2_C_minus_H": deltas[1], "delta_f3_C_minus_H": deltas[2],
        "abs_delta_f1": abs_deltas[0], "abs_delta_f2": abs_deltas[1], "abs_delta_f3": abs_deltas[2],
        "tau_f1": taus[0], "tau_f2": taus[1], "tau_f3": taus[2],
        "near_tie_f1": near[0], "near_tie_f2": near[1], "near_tie_f3": near[2],
        "near_tie_objective_count_pair": sum(near),
        "pair_has_near_tie": any(near),
        "strict_improvement_objectives": ";".join(F_LABELS[k] for k in strict),
        "dominance_relation_numerically_fragile": fragile,
    }


def independent_diagnostic(h: tuple[float, ...], c: tuple[float, ...], classification: str) -> tuple[list[bool], bool, str | bool]:
    """Independent scalar-loop implementation used only for QC."""
    flags = []
    for left, right in ((h[0], c[0]), (h[1], c[1]), (h[2], c[2])):
        scale = abs(left)
        if abs(right) > scale:
            scale = abs(right)
        if scale < 1.0:
            scale = 1.0
        threshold = scale / 1_000_000_000_000
        difference = left - right
        if difference < 0.0:
            difference = -difference
        flags.append(difference <= threshold)
    strict_flags = []
    if classification == "C_DOMINATES_H":
        strict_flags = [flags[k] for k in range(3) if c[k] < h[k]]
    elif classification == "H_DOMINATES_C":
        strict_flags = [flags[k] for k in range(3) if h[k] < c[k]]
    fragile: str | bool = all(strict_flags) if strict_flags else "NOT_APPLICABLE"
    return flags, any(flags), fragile


def write_csv(path: Path, rows: list[dict], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def blank_summary_row() -> dict:
    return {field: "" for field in SUMMARY_FIELDS}


SUMMARY_FIELDS = [
    "scope", "solution_id", "counterpart_id", "exact_classification",
    "cross_comparisons", "comparisons_with_near_tie", "fragile_dominance_relations_involving_solution",
    "near_tie_objective_count", "pair_with_near_tie_count", "numerically_fragile_dominance_count",
    "dominance_numeric_sensitivity", "strict_improvement_objectives",
    "abs_delta_f1", "abs_delta_f2", "abs_delta_f3", "tau_f1", "tau_f2", "tau_f3",
    "near_tie_f1", "near_tie_f2", "near_tie_f3", "dominance_relation_numerically_fragile",
]


def build_summary(matrix: list[dict], h_ids: list[str], c_ids: list[str], near_count: int, pair_count: int, fragile_count: int, sensitivity: str) -> list[dict]:
    global_row = blank_summary_row()
    global_row.update({"scope": "GLOBAL", "near_tie_objective_count": near_count, "pair_with_near_tie_count": pair_count, "numerically_fragile_dominance_count": fragile_count, "dominance_numeric_sensitivity": sensitivity})
    rows = [global_row]
    for scope, ids, field in (("H_SOLUTION", h_ids, "h_id"), ("C_SOLUTION", c_ids, "c_id")):
        for sid in ids:
            selected = [row for row in matrix if row[field] == sid]
            out = blank_summary_row()
            out.update({"scope": scope, "solution_id": sid, "cross_comparisons": 9, "comparisons_with_near_tie": sum(bool(row["pair_has_near_tie"]) for row in selected), "fragile_dominance_relations_involving_solution": sum(row["dominance_relation_numerically_fragile"] is True for row in selected)})
            rows.append(out)
    for row in matrix:
        if row["exact_classification"] not in DOMINANCE_CLASSES:
            continue
        out = blank_summary_row()
        out.update({"scope": "EXACT_DOMINANCE_RELATION", "solution_id": row["c_id"] if row["exact_classification"] == "C_DOMINATES_H" else row["h_id"], "counterpart_id": row["h_id"] if row["exact_classification"] == "C_DOMINATES_H" else row["c_id"], "exact_classification": row["exact_classification"], "strict_improvement_objectives": row["strict_improvement_objectives"], "abs_delta_f1": row["abs_delta_f1"], "abs_delta_f2": row["abs_delta_f2"], "abs_delta_f3": row["abs_delta_f3"], "tau_f1": row["tau_f1"], "tau_f2": row["tau_f2"], "tau_f3": row["tau_f3"], "near_tie_f1": row["near_tie_f1"], "near_tie_f2": row["near_tie_f2"], "near_tie_f3": row["near_tie_f3"], "dominance_relation_numerically_fragile": row["dominance_relation_numerically_fragile"]})
        rows.append(out)
    return rows


def write_audit(path: Path, near_count: int, pair_count: int, fragile_count: int, sensitivity: str, dominance_rows: list[dict], hashes: dict) -> None:
    lines = [
        "# CR1-COMP-06 — Numerical Near-tie Sensitivity Audit", "",
        "## Purpose, protocol, and baseline", "",
        "This phase audits numerical proximity in the frozen 81-pair CR1-COMP-05 matrix without changing any exact classification.", "",
        f"- Protocol: `CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md`, v1.0, frozen.",
        f"- Baseline HEAD: `{BASELINE_HEAD}` (`INPUT_BASELINE_CHECK = PASS`).",
        f"- Canonical dataset SHA-256: `{DATASET_SHA256}` (`PASS`).",
        f"- CR1-COMP-05 matrix SHA-256: `{CROSS_MATRIX_SHA256}` (`PASS`).",
        f"- CR1-COMP-05 result SHA-256: `{CROSS_RESULT_SHA256}` (`PASS`).", "",
        "## Diagnostic rule", "",
        "For each pair and objective, `tau = 1e-12 * max(1, abs(a), abs(b))`; a near-tie is recorded iff `abs(a-b) <= tau`.", "",
        "`NUMERICAL_THRESHOLD_ROLE = DIAGNOSTIC_ONLY`", "",
        "The threshold was not used for dominance, equality, rank, or any future coverage calculation.", "",
        "## Global results", "",
        f"- Objective-level near-ties: {near_count} of 243.",
        f"- Pairs with one or more near-ties: {pair_count} of 81.",
        f"- Numerically fragile exact dominance relations: {fragile_count} of 3.",
        f"- `DOMINANCE_NUMERIC_SENSITIVITY = {sensitivity}`.", "",
        "## Exact dominance relations", "",
        "| Relation | Strict improvement objectives | abs deltas (f1;f2;f3) | taus (f1;f2;f3) | near-ties (f1;f2;f3) | Fragile |",
        "|---|---|---|---|---|---|",
    ]
    for row in dominance_rows:
        relation = f"{row['c_id']} → {row['h_id']}" if row["exact_classification"] == "C_DOMINATES_H" else f"{row['h_id']} → {row['c_id']}"
        lines.append(f"| {relation} | {row['strict_improvement_objectives']} | {row['abs_delta_f1']}; {row['abs_delta_f2']}; {row['abs_delta_f3']} | {row['tau_f1']}; {row['tau_f2']}; {row['tau_f3']} | {row['near_tie_f1']}; {row['near_tie_f2']}; {row['near_tie_f3']} | {row['dominance_relation_numerically_fragile']} |")
    lines += [
        "", "All three exact dominance relations remain unchanged.", "",
        "## Integrity and independent QC", "",
        "Exact dominance was recomputed read-only from the canonical dataset and matched all 81 frozen CR1-COMP-05 classifications, including the three exact relations. A separate scalar-loop route reproduced all 243 near-tie flags, all 81 pair flags, and all fragility results.", "",
        "`CR1_COMP_05_EXACT_DOMINANCE_PRESERVED = YES`", "",
        "`INDEPENDENT_QC = PASS`", "",
        "## Limitations and actions not executed", "",
        "A near-tie is not equality, experimental uncertainty, model error, or evidence for tolerant dominance. No classification, Pareto status, or scientific interpretation was changed.", "",
        "No coverage, joint sorting, hypervolume, MATLAB, objective/model evaluation, replay, gamultiobj, optimization, or CR1-COMP-07+ phase was executed.", "",
        "## Output hashes", "",
    ]
    lines.extend(f"- `{name}`: `{digest}`" for name, digest in hashes.items())
    lines += ["", "The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.", ""]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    here = Path(__file__).resolve().parent
    paths = {"dataset": here / DATASET_NAME, "matrix": here / CROSS_MATRIX_NAME, "result": here / CROSS_RESULT_NAME}
    expected = {"dataset": DATASET_SHA256, "matrix": CROSS_MATRIX_SHA256, "result": CROSS_RESULT_SHA256}
    if any(sha256(paths[key]) != expected[key] for key in paths):
        raise RuntimeError("Input SHA-256 mismatch")
    data = json.loads(paths["dataset"].read_text(encoding="utf-8"))
    with paths["matrix"].open("r", encoding="utf-8", newline="") as handle:
        frozen_rows = list(csv.DictReader(handle))
    frozen_result = json.loads(paths["result"].read_text(encoding="utf-8"))
    records = data.get("records", [])
    h_records = [r for r in records if r.get("source") == "HIST_R1_REEVAL"]
    c_records = [r for r in records if r.get("source") == "CORRECTED_R1"]
    h_ids, c_ids = [f"H{i:02d}" for i in range(1, 10)], [f"C{i:02d}" for i in range(1, 10)]
    if len(frozen_rows) != 81 or [r.get("solution_id") for r in h_records] != h_ids or [r.get("solution_id") for r in c_records] != c_ids:
        raise RuntimeError("Unexpected input membership or pair count")
    if any(not r.get("finite") or r.get("penalized") or not all(math.isfinite(v) for v in vector(r)) for r in records):
        raise RuntimeError("Nonfinite or penalized row encountered")
    h_by_id, c_by_id = {r["solution_id"]: r for r in h_records}, {r["solution_id"]: r for r in c_records}
    frozen_by_pair = {(r["h_id"], r["c_id"]): r for r in frozen_rows}
    if len(frozen_by_pair) != 81:
        raise RuntimeError("Frozen pair keys are not unique")
    recomputed = {(hid, cid): exact_classify(vector(h_by_id[hid]), vector(c_by_id[cid])) for hid in h_ids for cid in c_ids}
    if any(frozen_by_pair[key]["classification"] != classification for key, classification in recomputed.items()):
        raise RuntimeError("CR1-COMP-05 classification integrity mismatch")
    integrity_counts = {category: sum(value == category for value in recomputed.values()) for category in ("C_DOMINATES_H", "H_DOMINATES_C", "INCOMPARABLE", "EXACT_EQUAL")}
    expected_counts = {"C_DOMINATES_H": 1, "H_DOMINATES_C": 2, "INCOMPARABLE": 78, "EXACT_EQUAL": 0}
    relations = {(hid, cid, cls) for (hid, cid), cls in recomputed.items() if cls in DOMINANCE_CLASSES}
    expected_relations = {("H05", "C04", "C_DOMINATES_H"), ("H02", "C06", "H_DOMINATES_C"), ("H08", "C08", "H_DOMINATES_C")}
    if integrity_counts != expected_counts or relations != expected_relations or frozen_result.get("global_counts", {}).get("cross_pair_count") != 81:
        raise RuntimeError("CR1-COMP-05 aggregate integrity mismatch")

    matrix = [analyze_pair(h_by_id[hid], c_by_id[cid], recomputed[(hid, cid)]) for hid in h_ids for cid in c_ids]
    independent_flags, independent_pairs, independent_fragile = [], [], []
    for row in matrix:
        h, c = vector(h_by_id[row["h_id"]]), vector(c_by_id[row["c_id"]])
        flags, pair_flag, fragile = independent_diagnostic(h, c, row["exact_classification"])
        independent_flags.extend(flags)
        independent_pairs.append(pair_flag)
        if row["exact_classification"] in DOMINANCE_CLASSES:
            independent_fragile.append((row["h_id"], row["c_id"], fragile))
    main_flags = [bool(row[f"near_tie_{label}"]) for row in matrix for label in F_LABELS]
    main_pairs = [bool(row["pair_has_near_tie"]) for row in matrix]
    main_fragile = [(row["h_id"], row["c_id"], row["dominance_relation_numerically_fragile"]) for row in matrix if row["exact_classification"] in DOMINANCE_CLASSES]
    if main_flags != independent_flags or main_pairs != independent_pairs or main_fragile != independent_fragile:
        raise RuntimeError("Independent near-tie QC mismatch")
    for row in matrix:
        for label in F_LABELS:
            condition = row[f"abs_delta_{label}"] <= row[f"tau_{label}"]
            if bool(row[f"near_tie_{label}"]) != condition:
                raise RuntimeError("Near-tie threshold semantic check failed")
        if row["exact_classification"] in DOMINANCE_CLASSES:
            strict_indices = [F_LABELS.index(label) for label in row["strict_improvement_objectives"].split(";")]
            if not strict_indices:
                raise RuntimeError("Dominance has no strict improvement")
            expected_fragile = all(row[f"near_tie_{F_LABELS[k]}"] for k in strict_indices)
            if row["dominance_relation_numerically_fragile"] is not expected_fragile:
                raise RuntimeError("Fragility semantic check failed")

    near_count, pair_count = sum(main_flags), sum(main_pairs)
    fragile_count = sum(value is True for _, _, value in main_fragile)
    sensitivity = "PASS_NO_FRAGILE_DOMINANCE" if fragile_count == 0 else "REVIEW_FRAGILE_RELATIONS_PRESENT"
    summary = build_summary(matrix, h_ids, c_ids, near_count, pair_count, fragile_count, sensitivity)
    matrix_fields = list(matrix[0].keys())
    matrix_path, summary_path = here / MATRIX_NAME, here / SUMMARY_NAME
    result_path, audit_path = here / RESULT_NAME, here / AUDIT_NAME
    write_csv(matrix_path, matrix, matrix_fields)
    write_csv(summary_path, summary, SUMMARY_FIELDS)
    result = {
        "artifact_role": "CR1_COMP_06_NUMERICAL_NEAR_TIE_SENSITIVITY_AUDIT",
        "cr1_comp_06_status": "CLOSED_PASS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "inputs": {"canonical_dataset": {"path": "06_manuscript/article_Q1/review/" + DATASET_NAME, "sha256": DATASET_SHA256, "check": "PASS"}, "cr1_comp_05_matrix": {"path": "06_manuscript/article_Q1/review/" + CROSS_MATRIX_NAME, "sha256": CROSS_MATRIX_SHA256, "check": "PASS"}, "cr1_comp_05_result": {"path": "06_manuscript/article_Q1/review/" + CROSS_RESULT_NAME, "sha256": CROSS_RESULT_SHA256, "check": "PASS"}},
        "method": {"pareto_definition": "EXACT_FULL_PRECISION", "dominance_tolerance": "NONE", "solver_tolerances_used_for_dominance": False, "numerical_near_tie_threshold": "1e-12 * max(1,abs(a),abs(b))", "comparison_operator": "<=", "numerical_threshold_role": "DIAGNOSTIC_ONLY", "fragility_rule": "all strict dominance improvements are near-ties"},
        "cr1_comp_05_integrity": {"classification_integrity_check": "PASS", "exact_classifications_changed": False, "cross_pair_count": 81, "counts": integrity_counts, "relations": sorted([{"h_id": h, "c_id": c, "classification": cls} for h, c, cls in relations], key=lambda x: (x["h_id"], x["c_id"]))},
        "matrix": matrix,
        "aggregates": {"cross_pair_count": 81, "objective_comparison_count": 243, "near_tie_objective_count": near_count, "pair_with_near_tie_count": pair_count, "numerically_fragile_dominance_count": fragile_count, "dominance_numeric_sensitivity": sensitivity},
        "dominance_relations": [row for row in matrix if row["exact_classification"] in DOMINANCE_CLASSES],
        "solution_summary": summary[1:19],
        "qc": {"independent_qc": "PASS", "exact_classification_identity_81": "PASS", "near_tie_flag_identity_243": "PASS", "pair_flag_identity_81": "PASS", "fragile_relation_identity": "PASS", "threshold_semantics": "PASS", "fragility_semantics": "PASS", "matrix_csv_sha256": sha256(matrix_path), "summary_csv_sha256": sha256(summary_path)},
        "limitations": ["Diagnostic numerical proximity only; near-tie is not equality.", "No exact dominance classification, Pareto status, coverage, or rank was changed."],
        "not_computed": {"cr1_comp_07": True, "coverage": True, "joint_sorting": True, "hypervolume": True},
        "execution": {"MATLAB_executed": False, "objective_evaluations": 0, "replays": 0, "gamultiobj_executions": 0},
    }
    result_path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    hashes = {Path(__file__).name: sha256(Path(__file__)), MATRIX_NAME: sha256(matrix_path), SUMMARY_NAME: sha256(summary_path), RESULT_NAME: sha256(result_path)}
    write_audit(audit_path, near_count, pair_count, fragile_count, sensitivity, result["dominance_relations"], hashes)


if __name__ == "__main__":
    main()
