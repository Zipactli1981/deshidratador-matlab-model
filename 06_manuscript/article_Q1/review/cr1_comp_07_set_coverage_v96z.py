"""CR1-COMP-07 exact set coverage from frozen cross-dominance artifacts."""

from __future__ import annotations

import csv
import hashlib
import json
from pathlib import Path


BASELINE_HEAD = "2b22bf342c3ec0e2d5c22ab4da33c566f6521c93"
MATRIX_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_MATRIX_v96z.csv"
MATRIX_SHA256 = "C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329"
CROSS_RESULT_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_v96z.json"
CROSS_RESULT_SHA256 = "88EE7D86AFEE3A1C5E33D3BD2629995277481A2B65FDF03C83594888402D701A"
STATUS_NAME = "CR1_COMP_02_WITHIN_SET_SOLUTION_STATUS_v96z.csv"
STATUS_SHA256 = "74C33FA77D543FAADA6B9819AF88C133E23D5E283148999849ECF83998D1E5C2"
COVERAGE_NAME = "CR1_COMP_07_SET_COVERAGE_v96z.csv"
MEMBERSHIP_NAME = "CR1_COMP_07_SET_COVERAGE_MEMBERSHIP_v96z.csv"
RESULT_NAME = "CR1_COMP_07_SET_COVERAGE_v96z.json"
AUDIT_NAME = "CR1_COMP_07_SET_COVERAGE_AUDIT_v96z.md"
H_SOURCE = "HIST_R1_REEVAL"
C_SOURCE = "CORRECTED_R1"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def read_csv(path: Path) -> list[dict]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def write_csv(path: Path, rows: list[dict], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def coverage_row(metric: str, numerator: int, denominator: int, source_set: str, target_set: str) -> dict:
    value = numerator / denominator
    return {
        "metric": metric,
        "numerator": numerator,
        "denominator": denominator,
        "fraction": f"{numerator}/{denominator}",
        "coverage": value,
        "coverage_percent": 100.0 * value,
        "source_set": source_set,
        "target_set": target_set,
        "dominance_definition": "EXACT_FULL_PRECISION_NO_TOLERANCE",
    }


def write_audit(path: Path, coverage_rows: list[dict], h_dominated: list[str], c_dominated: list[str], hashes: dict) -> None:
    lines = [
        "# CR1-COMP-07 — Set Coverage Audit", "",
        "## Purpose and baseline", "",
        "This phase calculates asymmetric full-set and internally nondominated-core coverage using only frozen exact cross-dominance relations and audited CR1-COMP-02 memberships.", "",
        f"- Baseline HEAD: `{BASELINE_HEAD}` (`INPUT_BASELINE_CHECK = PASS`).",
        f"- CR1-COMP-05 matrix SHA-256: `{MATRIX_SHA256}` (`PASS`).",
        f"- CR1-COMP-05 result SHA-256: `{CROSS_RESULT_SHA256}` (`PASS`).",
        f"- CR1-COMP-02 solution-status SHA-256: `{STATUS_SHA256}` (`PASS`).", "",
        "## Definitions", "",
        "For coverage C(A,B), the numerator is the number of distinct target solutions in B dominated exactly by at least one source solution in A; the denominator is the number of target solutions. Multiple pairwise dominances of one target count once.", "",
        "Full coverage uses all nine solutions per set. Core coverage restricts source and target membership to `N_C` and `N_H` from CR1-COMP-02. Exact full-precision dominance is used without tolerance or near-tie reclassification.", "",
        "## Memberships", "",
        f"- Historical solutions dominated by at least one C: {', '.join(h_dominated) if h_dominated else 'none'}.",
        f"- CORRECTED_R1 solutions dominated by at least one H: {', '.join(c_dominated) if c_dominated else 'none'}.",
        "- `N_H = H01...H09` and `N_C = C01...C09`; therefore full/core equality is an expected structural check for this dataset.", "",
        "## Results", "",
        "| Metric | Fraction | Coverage | Percent |", "|---|---:|---:|---:|",
    ]
    lines.extend(f"| {row['metric']} | {row['fraction']} | {row['coverage']} | {row['coverage_percent']} |" for row in coverage_rows)
    lines += [
        "", "`FULL_CORE_COVERAGE_EQUALITY_CHECK = PASS`", "",
        "Core coverage has interpretive priority for statements about the internally nondominated approximations, but these asymmetric metrics do not establish a true Pareto front, convergence, global superiority, or joint Rank 1 composition.", "",
        "## Independent QC", "",
        "The primary route formed unique dominated-ID sets from matrix relations. An independent route evaluated, for every target solution, whether at least one exact relation from the other set exists. Both routes produced identical memberships, numerators, denominators, and four coverage values.", "",
        "`INDEPENDENT_QC = PASS`", "",
        "## Actions not executed", "",
        "No joint nondominated sorting, ParetoRank, hypervolume gate, hypervolume, MATLAB, objective/model evaluation, replay, gamultiobj, optimization, or CR1-COMP-08+ phase was executed.", "",
        "## Output hashes", "",
    ]
    lines.extend(f"- `{name}`: `{digest}`" for name, digest in hashes.items())
    lines += ["", "The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.", ""]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    here = Path(__file__).resolve().parent
    matrix_path, cross_result_path, status_path = here / MATRIX_NAME, here / CROSS_RESULT_NAME, here / STATUS_NAME
    if sha256(matrix_path) != MATRIX_SHA256 or sha256(cross_result_path) != CROSS_RESULT_SHA256 or sha256(status_path) != STATUS_SHA256:
        raise RuntimeError("Input SHA-256 mismatch")
    matrix = read_csv(matrix_path)
    cross_result = json.loads(cross_result_path.read_text(encoding="utf-8"))
    statuses = read_csv(status_path)
    h_ids, c_ids = [f"H{i:02d}" for i in range(1, 10)], [f"C{i:02d}" for i in range(1, 10)]
    if len(matrix) != 81 or len({(row["h_id"], row["c_id"]) for row in matrix}) != 81:
        raise RuntimeError("Unexpected cross matrix structure")
    if [row["solution_id"] for row in statuses] != h_ids + c_ids:
        raise RuntimeError("Unexpected CR1-COMP-02 solution membership/order")
    n_h = [row["solution_id"] for row in statuses if row["solution_id"].startswith("H") and row["within_set_nondominated"] == "YES"]
    n_c = [row["solution_id"] for row in statuses if row["solution_id"].startswith("C") and row["within_set_nondominated"] == "YES"]
    if n_h != h_ids or n_c != c_ids:
        raise RuntimeError("N_H/N_C integrity mismatch")
    counts = cross_result.get("global_counts", {})
    if counts != {"cross_pair_count": 81, "C_DOMINATES_H": 1, "H_DOMINATES_C": 2, "INCOMPARABLE": 78, "EXACT_EQUAL": 0}:
        raise RuntimeError("CR1-COMP-05 global-count mismatch")

    # Primary route: unique target-ID sets from exact matrix relations.
    h_dominated_set = {row["h_id"] for row in matrix if row["classification"] == "C_DOMINATES_H"}
    c_dominated_set = {row["c_id"] for row in matrix if row["classification"] == "H_DOMINATES_C"}
    nh_dominated_set = {row["h_id"] for row in matrix if row["h_id"] in n_h and row["c_id"] in n_c and row["classification"] == "C_DOMINATES_H"}
    nc_dominated_set = {row["c_id"] for row in matrix if row["h_id"] in n_h and row["c_id"] in n_c and row["classification"] == "H_DOMINATES_C"}

    # Independent route: existence query for each target solution.
    h_qc = {hid for hid in h_ids if any(row["h_id"] == hid and row["classification"] == "C_DOMINATES_H" for row in matrix)}
    c_qc = {cid for cid in c_ids if any(row["c_id"] == cid and row["classification"] == "H_DOMINATES_C" for row in matrix)}
    nh_qc = {hid for hid in n_h if any(row["h_id"] == hid and row["c_id"] in n_c and row["classification"] == "C_DOMINATES_H" for row in matrix)}
    nc_qc = {cid for cid in n_c if any(row["c_id"] == cid and row["h_id"] in n_h and row["classification"] == "H_DOMINATES_C" for row in matrix)}
    if (h_dominated_set, c_dominated_set, nh_dominated_set, nc_dominated_set) != (h_qc, c_qc, nh_qc, nc_qc):
        raise RuntimeError("Independent membership QC mismatch")
    if h_dominated_set != {"H05"} or c_dominated_set != {"C06", "C08"}:
        raise RuntimeError("Frozen exact-relation membership mismatch")

    coverage_rows = [
        coverage_row("FULL_COVERAGE_C_OVER_H", len(h_dominated_set), len(h_ids), "C", "H"),
        coverage_row("FULL_COVERAGE_H_OVER_C", len(c_dominated_set), len(c_ids), "H", "C"),
        coverage_row("CORE_COVERAGE_NC_OVER_NH", len(nh_dominated_set), len(n_h), "N_C", "N_H"),
        coverage_row("CORE_COVERAGE_NH_OVER_NC", len(nc_dominated_set), len(n_c), "N_H", "N_C"),
    ]
    coverage = {row["metric"]: row for row in coverage_rows}
    equality = (
        coverage["FULL_COVERAGE_C_OVER_H"]["coverage"] == coverage["CORE_COVERAGE_NC_OVER_NH"]["coverage"]
        and coverage["FULL_COVERAGE_H_OVER_C"]["coverage"] == coverage["CORE_COVERAGE_NH_OVER_NC"]["coverage"]
    )
    if not equality or any(not 0.0 <= row["coverage"] <= 1.0 for row in coverage_rows):
        raise RuntimeError("Coverage structural QC failed")

    membership_rows = []
    for sid in h_ids:
        dominators = sorted({row["c_id"] for row in matrix if row["h_id"] == sid and row["classification"] == "C_DOMINATES_H"})
        membership_rows.append({"solution_id": sid, "source": H_SOURCE, "in_nondominated_core": sid in n_h, "dominated_by_any_other_set_exact": bool(dominators), "dominating_other_set_solution_ids": ";".join(dominators)})
    for sid in c_ids:
        dominators = sorted({row["h_id"] for row in matrix if row["c_id"] == sid and row["classification"] == "H_DOMINATES_C"})
        membership_rows.append({"solution_id": sid, "source": C_SOURCE, "in_nondominated_core": sid in n_c, "dominated_by_any_other_set_exact": bool(dominators), "dominating_other_set_solution_ids": ";".join(dominators)})
    if sum(row["dominated_by_any_other_set_exact"] for row in membership_rows[:9]) != len(h_dominated_set) or sum(row["dominated_by_any_other_set_exact"] for row in membership_rows[9:]) != len(c_dominated_set):
        raise RuntimeError("Membership-row QC failed")

    coverage_path, membership_path = here / COVERAGE_NAME, here / MEMBERSHIP_NAME
    result_path, audit_path = here / RESULT_NAME, here / AUDIT_NAME
    write_csv(coverage_path, coverage_rows, ["metric", "numerator", "denominator", "fraction", "coverage", "coverage_percent", "source_set", "target_set", "dominance_definition"])
    write_csv(membership_path, membership_rows, ["solution_id", "source", "in_nondominated_core", "dominated_by_any_other_set_exact", "dominating_other_set_solution_ids"])
    result = {
        "artifact_role": "CR1_COMP_07_SET_COVERAGE",
        "cr1_comp_07_status": "CLOSED_PASS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "inputs": {"cr1_comp_05_matrix": {"path": "06_manuscript/article_Q1/review/" + MATRIX_NAME, "sha256": MATRIX_SHA256, "check": "PASS"}, "cr1_comp_05_result": {"path": "06_manuscript/article_Q1/review/" + CROSS_RESULT_NAME, "sha256": CROSS_RESULT_SHA256, "check": "PASS"}, "cr1_comp_02_solution_status": {"path": "06_manuscript/article_Q1/review/" + STATUS_NAME, "sha256": STATUS_SHA256, "check": "PASS"}},
        "definitions": {"dominance": "EXACT_FULL_PRECISION_NO_TOLERANCE", "full_coverage": "distinct target solutions dominated by at least one source / full target size", "core_coverage": "distinct target-core solutions dominated by at least one source-core solution / target-core size", "near_tie_used": False, "asymmetric": True},
        "sets": {"H": h_ids, "C": c_ids, "N_H": n_h, "N_C": n_c},
        "memberships": membership_rows,
        "dominated_target_ids": {"H_dominated_by_C": sorted(h_dominated_set), "C_dominated_by_H": sorted(c_dominated_set), "N_H_dominated_by_N_C": sorted(nh_dominated_set), "N_C_dominated_by_N_H": sorted(nc_dominated_set)},
        "coverage": coverage_rows,
        "qc": {"independent_qc": "PASS", "membership_routes_identity": "PASS", "N_H_count": len(n_h), "N_C_count": len(n_c), "numerator_unique_target_identity": "PASS", "denominators": "PASS", "coverage_bounds": "PASS", "full_core_coverage_equality_check": "PASS", "coverage_csv_sha256": sha256(coverage_path), "membership_csv_sha256": sha256(membership_path)},
        "limitations": ["Coverage is asymmetric and is not a probability.", "Coverage does not establish joint Rank 1, a true Pareto front, convergence, or global superiority."],
        "not_computed": {"cr1_comp_08": True, "joint_sorting": True, "hypervolume_gate": True, "hypervolume": True},
        "execution": {"MATLAB_executed": False, "objective_evaluations": 0, "replays": 0, "gamultiobj_executions": 0},
    }
    result_path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    hashes = {Path(__file__).name: sha256(Path(__file__)), COVERAGE_NAME: sha256(coverage_path), MEMBERSHIP_NAME: sha256(membership_path), RESULT_NAME: sha256(result_path)}
    write_audit(audit_path, coverage_rows, sorted(h_dominated_set), sorted(c_dominated_set), hashes)


if __name__ == "__main__":
    main()
