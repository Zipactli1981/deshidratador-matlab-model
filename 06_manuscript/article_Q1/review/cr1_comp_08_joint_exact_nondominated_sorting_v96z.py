"""CR1-COMP-08 joint exact nondominated sorting of the frozen 18-row dataset."""

from __future__ import annotations

import csv
import hashlib
import json
import math
from collections import Counter
from pathlib import Path


BASELINE_HEAD = "03bf1eb491627407191e9f6f610af5f794a8dd58"
DATASET_NAME = "CR1_COMP_01_CANONICAL_DATASET_v96z.json"
DATASET_SHA256 = "4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164"
STATUS_NAME = "CR1_COMP_02_WITHIN_SET_SOLUTION_STATUS_v96z.csv"
STATUS_SHA256 = "74C33FA77D543FAADA6B9819AF88C133E23D5E283148999849ECF83998D1E5C2"
CROSS_MATRIX_NAME = "CR1_COMP_05_EXACT_CROSS_DOMINANCE_MATRIX_v96z.csv"
CROSS_MATRIX_SHA256 = "C783CDD1214598643F1A46F6A6E1EC144220D2BFB2FC8D67F53293A3B7ACC329"
NEAR_TIE_NAME = "CR1_COMP_06_NUMERICAL_NEAR_TIE_SENSITIVITY_v96z.json"
NEAR_TIE_SHA256 = "227F88AB15A30A812F222E3608BF9512401A8775AA1CFE9886E6288326F6E3FA"
COVERAGE_NAME = "CR1_COMP_07_SET_COVERAGE_v96z.json"
COVERAGE_SHA256 = "8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83"
SORTING_NAME = "CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.csv"
SUMMARY_NAME = "CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_SUMMARY_v96z.csv"
RESULT_NAME = "CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.json"
AUDIT_NAME = "CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_AUDIT_v96z.md"
OBJECTIVE_FIELDS = (
    "MR_final",
    "cost_specific_USD_per_kgwater",
    "CO2_specific_kgCO2_per_kgwater",
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def write_csv(path: Path, rows: list[dict], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def dominates(a: tuple[float, float, float], b: tuple[float, float, float]) -> bool:
    """Exact minimization dominance: no tolerance, rounding, or near-tie rule."""
    return all(x <= y for x, y in zip(a, b)) and any(x < y for x, y in zip(a, b))


def layered_sort(
    ids: list[str], objectives: dict[str, tuple[float, float, float]]
) -> tuple[dict[str, int], list[list[str]], dict[str, list[str]]]:
    """Primary route: recompute exact residual dominators for simultaneous layers."""
    remaining = set(ids)
    ranks: dict[str, int] = {}
    layers: list[list[str]] = []
    layer_dominators: dict[str, list[str]] = {}
    rank = 1
    while remaining:
        residual_dominators = {
            sid: sorted(
                other
                for other in remaining
                if other != sid and dominates(objectives[other], objectives[sid])
            )
            for sid in remaining
        }
        layer = [sid for sid in ids if sid in remaining and not residual_dominators[sid]]
        if not layer:
            raise RuntimeError("No zero-indegree layer found; dominance graph is cyclic")
        for sid in layer:
            ranks[sid] = rank
            layer_dominators[sid] = residual_dominators[sid]
        layers.append(layer)
        remaining.difference_update(layer)
        rank += 1
    return ranks, layers, layer_dominators


def graph_sort(
    ids: list[str], dominators: dict[str, list[str]], dominates_ids: dict[str, list[str]]
) -> tuple[dict[str, int], list[list[str]]]:
    """Independent route: iterative zero-indegree removal from a directed graph."""
    remaining = set(ids)
    indegree = {sid: len(dominators[sid]) for sid in ids}
    ranks: dict[str, int] = {}
    layers: list[list[str]] = []
    rank = 1
    while remaining:
        layer = [sid for sid in ids if sid in remaining and indegree[sid] == 0]
        if not layer:
            raise RuntimeError("Independent graph route found no zero-indegree layer")
        for sid in layer:
            ranks[sid] = rank
        layers.append(layer)
        for sid in layer:
            remaining.remove(sid)
        for sid in layer:
            for target in dominates_ids[sid]:
                if target in remaining:
                    indegree[target] -= 1
        rank += 1
    return ranks, layers


def main() -> None:
    here = Path(__file__).resolve().parent
    paths = {
        "dataset": here / DATASET_NAME,
        "status": here / STATUS_NAME,
        "cross_matrix": here / CROSS_MATRIX_NAME,
        "near_tie": here / NEAR_TIE_NAME,
        "coverage": here / COVERAGE_NAME,
    }
    expected_hashes = {
        "dataset": DATASET_SHA256,
        "status": STATUS_SHA256,
        "cross_matrix": CROSS_MATRIX_SHA256,
        "near_tie": NEAR_TIE_SHA256,
        "coverage": COVERAGE_SHA256,
    }
    actual_hashes = {key: sha256(path) for key, path in paths.items()}
    if actual_hashes != expected_hashes:
        raise RuntimeError(f"Frozen input SHA-256 mismatch: {actual_hashes}")

    dataset = json.loads(paths["dataset"].read_text(encoding="utf-8"))
    statuses = read_csv(paths["status"])
    cross_matrix = read_csv(paths["cross_matrix"])
    near_tie = json.loads(paths["near_tie"].read_text(encoding="utf-8"))
    coverage = json.loads(paths["coverage"].read_text(encoding="utf-8"))

    expected_ids = [f"H{i:02d}" for i in range(1, 10)] + [f"C{i:02d}" for i in range(1, 10)]
    records = dataset.get("records", [])
    ids = [row.get("solution_id") for row in records]
    if dataset.get("record_count") != 18 or ids != expected_ids or dataset.get("canonical_order") != expected_ids:
        raise RuntimeError("Canonical 18-row ID/order gate failed")
    if dataset.get("objective_order") != list(OBJECTIVE_FIELDS) or dataset.get("all_objectives_minimized") is not True:
        raise RuntimeError("Canonical objective-definition gate failed")
    if any(row.get("source") not in {"HIST_R1_REEVAL", "CORRECTED_R1"} for row in records):
        raise RuntimeError("Unexpected source in canonical dataset")
    if any(row.get("finite") is not True or row.get("penalized") is not False for row in records):
        raise RuntimeError("Finite/penalty gate failed")
    if any("gasLP" in json.dumps(row, ensure_ascii=False) for row in records):
        raise RuntimeError("gasLP unexpectedly included in comparative records")

    objectives = {
        row["solution_id"]: tuple(float(row[field]) for field in OBJECTIVE_FIELDS)
        for row in records
    }
    if any(len(vector) != 3 or not all(math.isfinite(value) for value in vector) for vector in objectives.values()):
        raise RuntimeError("Objective finiteness/dimensionality gate failed")

    if [row["solution_id"] for row in statuses] != expected_ids:
        raise RuntimeError("CR1-COMP-02 membership/order mismatch")
    if any(row["within_set_nondominated"] != "YES" or row["dominated_internal"] != "NO" for row in statuses):
        raise RuntimeError("CR1-COMP-02 internal nondominance mismatch")
    if len(cross_matrix) != 81 or len({(row["h_id"], row["c_id"]) for row in cross_matrix}) != 81:
        raise RuntimeError("CR1-COMP-05 matrix structure mismatch")
    cross_counts = Counter(row["classification"] for row in cross_matrix)
    if cross_counts != Counter({"INCOMPARABLE": 78, "H_DOMINATES_C": 2, "C_DOMINATES_H": 1}):
        raise RuntimeError("CR1-COMP-05 classification-count mismatch")
    frozen_relations = {
        (row["h_id"], row["c_id"], row["classification"])
        for row in cross_matrix
        if row["classification"] != "INCOMPARABLE"
    }
    expected_relations = {
        ("H02", "C06", "H_DOMINATES_C"),
        ("H05", "C04", "C_DOMINATES_H"),
        ("H08", "C08", "H_DOMINATES_C"),
    }
    if frozen_relations != expected_relations:
        raise RuntimeError("CR1-COMP-05 relation-identity mismatch")
    if near_tie["cr1_comp_05_integrity"]["exact_classifications_changed"] is not False:
        raise RuntimeError("CR1-COMP-06 reports changed exact classifications")
    if near_tie["aggregates"]["numerically_fragile_dominance_count"] != 0:
        raise RuntimeError("CR1-COMP-06 fragile-dominance gate failed")
    if coverage["dominated_target_ids"]["H_dominated_by_C"] != ["H05"]:
        raise RuntimeError("CR1-COMP-07 H membership mismatch")
    if coverage["dominated_target_ids"]["C_dominated_by_H"] != ["C06", "C08"]:
        raise RuntimeError("CR1-COMP-07 C membership mismatch")
    coverage_values = {row["metric"]: row["coverage"] for row in coverage["coverage"]}
    if coverage_values["FULL_COVERAGE_C_OVER_H"] != 0.1111111111111111:
        raise RuntimeError("CR1-COMP-07 C-over-H coverage mismatch")
    if coverage_values["FULL_COVERAGE_H_OVER_C"] != 0.2222222222222222:
        raise RuntimeError("CR1-COMP-07 H-over-C coverage mismatch")

    dominators = {
        sid: [other for other in ids if other != sid and dominates(objectives[other], objectives[sid])]
        for sid in ids
    }
    dominates_ids = {
        sid: [other for other in ids if other != sid and dominates(objectives[sid], objectives[other])]
        for sid in ids
    }
    direct_relations = {
        (source, target)
        for source in ids
        for target in dominates_ids[source]
    }
    expected_direct_relations = {("C04", "H05"), ("H02", "C06"), ("H08", "C08")}
    if direct_relations != expected_direct_relations:
        raise RuntimeError(f"Direct dataset relations contradict upstream: {sorted(direct_relations)}")

    ranks, layers, layer_dominators = layered_sort(ids, objectives)
    qc_ranks, qc_layers = graph_sort(ids, dominators, dominates_ids)
    if ranks != qc_ranks or layers != qc_layers:
        raise RuntimeError("Independent sorting routes disagree")
    if set(ranks) != set(ids) or len(ranks) != 18 or sum(len(layer) for layer in layers) != 18:
        raise RuntimeError("Rank membership completeness failed")
    if any(not isinstance(rank, int) or rank < 1 for rank in ranks.values()):
        raise RuntimeError("Invalid ParetoRank")
    if any(dominators[sid] for sid in layers[0]):
        raise RuntimeError("Rank 1 contains a dominated solution")
    if any(not any(ranks[parent] < ranks[sid] for parent in dominators[sid]) for sid in ids if ranks[sid] > 1):
        raise RuntimeError("A later-rank solution lacks an earlier-layer dominator")
    if any(ranks[source] > ranks[target] for source, target in direct_relations):
        raise RuntimeError("Dominance/rank monotonicity failed")
    if any(layer_dominators[sid] for sid in ids):
        raise RuntimeError("Assigned layer contains residual dominance")

    initial_dominated = [sid for sid in ids if dominators[sid]]
    if initial_dominated != ["H05", "C06", "C08"] or len(layers[0]) != 15:
        raise RuntimeError("Initial upstream sorting expectation failed")
    if coverage["dominated_target_ids"]["H_dominated_by_C"] + coverage["dominated_target_ids"]["C_dominated_by_H"] != initial_dominated:
        raise RuntimeError("Coverage/joint Rank 1 exclusion inconsistency")

    sorting_rows = []
    record_by_id = {row["solution_id"]: row for row in records}
    for sid in ids:
        row = record_by_id[sid]
        sorting_rows.append({
            "solution_id": sid,
            "source": row["source"],
            "f1": row[OBJECTIVE_FIELDS[0]],
            "f2": row[OBJECTIVE_FIELDS[1]],
            "f3": row[OBJECTIVE_FIELDS[2]],
            "ParetoRank": ranks[sid],
            "is_joint_rank1": ranks[sid] == 1,
            "dominated_by_count_full_U": len(dominators[sid]),
            "dominated_by_solution_ids_full_U": ";".join(dominators[sid]),
            "dominates_count_full_U": len(dominates_ids[sid]),
            "dominates_solution_ids_full_U": ";".join(dominates_ids[sid]),
            "rank_layer_dominator_count": len(layer_dominators[sid]),
            "rank_layer_dominator_ids": ";".join(layer_dominators[sid]),
        })

    summary_rows = []
    for rank, layer in enumerate(layers, start=1):
        h_ids = [sid for sid in layer if sid.startswith("H")]
        c_ids = [sid for sid in layer if sid.startswith("C")]
        summary_rows.append({
            "pareto_rank": rank,
            "solution_count": len(layer),
            "H_count": len(h_ids),
            "C_count": len(c_ids),
            "H_solution_ids": ";".join(h_ids),
            "C_solution_ids": ";".join(c_ids),
            "all_solution_ids": ";".join(layer),
        })

    sorting_path = here / SORTING_NAME
    summary_path = here / SUMMARY_NAME
    result_path = here / RESULT_NAME
    audit_path = here / AUDIT_NAME
    write_csv(sorting_path, sorting_rows, list(sorting_rows[0]))
    write_csv(summary_path, summary_rows, list(summary_rows[0]))

    relation_rows = [
        {"dominant_solution_id": source, "dominated_solution_id": target}
        for source, target in sorted(direct_relations)
    ]
    result = {
        "artifact_role": "CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING",
        "cr1_comp_08_status": "CLOSED_PASS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "inputs": {
            key: {"path": f"06_manuscript/article_Q1/review/{paths[key].name}", "sha256": actual_hashes[key], "check": "PASS"}
            for key in paths
        },
        "dataset_qc": {
            "dataset_rows": 18,
            "H_rows": 9,
            "C_rows": 9,
            "objectives_per_row": 3,
            "all_f_values_finite": True,
            "penalty_rows_included": False,
            "gasLP_included_in_comparative_sort": False,
        },
        "method": {
            "all_objectives": "MINIMIZATION",
            "pareto_definition": "EXACT_FULL_PRECISION",
            "dominance_tolerance": "NONE",
            "solver_tolerances_used_for_dominance": False,
            "numerical_near_tie_used_for_rank": False,
            "primary_route": "simultaneous residual nondominated layers from direct exact comparisons",
            "independent_route": "18x18 directed dominance graph with simultaneous zero-indegree removal",
        },
        "solution_ranks": sorting_rows,
        "rank_summary": summary_rows,
        "full_U_dominance_relations": relation_rows,
        "initial_dominated_ids": initial_dominated,
        "initial_nondominated_count": len(layers[0]),
        "upstream_consistency": {
            "check": "PASS",
            "cr1_comp_02_internal_dominance_relation_count": 0,
            "cr1_comp_05_relation_identity": "PASS",
            "cr1_comp_06_exact_classifications_changed": False,
            "cr1_comp_06_numerically_fragile_dominance_count": 0,
            "cr1_comp_07_exclusion_identity": "PASS",
        },
        "qc": {
            "independent_qc": "PASS",
            "rank_identity_18": "PASS",
            "rank_layer_membership_identity": "PASS",
            "unique_complete_assignment": "PASS",
            "rank_count_sum": "PASS",
            "rank_integer_domain": "PASS",
            "rank1_indegree_zero_full_U": "PASS",
            "later_rank_earlier_dominator": "PASS",
            "dominance_rank_monotonicity": "PASS",
            "simultaneous_layer_removal": "PASS",
            "sorting_csv_sha256": sha256(sorting_path),
            "summary_csv_sha256": sha256(summary_path),
        },
        "nomenclature": "JOINT_NONDOMINATED_SET_OF_18_EVALUATED_SOLUTIONS",
        "limitations": [
            "Rank 1 is the joint nondominated set of the 18 evaluated solutions, not a true, exact, global, or corrected Pareto front.",
            "The result does not establish global or statistical superiority, convergence, robustness, expected gamultiobj performance, or a physical mechanism.",
        ],
        "not_computed": {
            "cr1_comp_09": True,
            "objective_geometry": True,
            "hypervolume_gate": True,
            "hypervolume": True,
            "terminal_regime_comparison": True,
            "objective_decomposition": True,
            "physical_interpretation": True,
        },
        "execution": {
            "MATLAB_executed": False,
            "objective_evaluations": 0,
            "replays": 0,
            "gamultiobj_executions": 0,
        },
    }
    result_path.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    output_hashes = {
        Path(__file__).name: sha256(Path(__file__)),
        SORTING_NAME: sha256(sorting_path),
        SUMMARY_NAME: sha256(summary_path),
        RESULT_NAME: sha256(result_path),
    }
    rank_lines = []
    for row in summary_rows:
        rank_lines.append(
            f"- Rank {row['pareto_rank']}: {row['solution_count']} solutions "
            f"(H={row['H_count']}, C={row['C_count']}); IDs: {row['all_solution_ids'].replace(';', ',')}."
        )
    audit_lines = [
        "# CR1-COMP-08 — Joint Exact Nondominated Sorting Audit",
        "",
        "## Purpose and baseline",
        "",
        "This phase assigns exact Pareto ranks to the union of the nine historical reevaluated solutions and the nine CORRECTED_R1 solutions.",
        "",
        f"- Baseline HEAD: `{BASELINE_HEAD}` (`INPUT_BASELINE_CHECK = PASS`).",
        f"- Canonical dataset SHA-256: `{DATASET_SHA256}` (`PASS`).",
        f"- CR1-COMP-02 solution-status SHA-256: `{STATUS_SHA256}` (`PASS`).",
        f"- CR1-COMP-05 matrix SHA-256: `{CROSS_MATRIX_SHA256}` (`PASS`).",
        f"- CR1-COMP-06 result SHA-256: `{NEAR_TIE_SHA256}` (`PASS`).",
        f"- CR1-COMP-07 result SHA-256: `{COVERAGE_SHA256}` (`PASS`).",
        "",
        "## Exact dominance and sorting method",
        "",
        "All three objectives are minimized. A dominates B exactly iff every objective of A is less than or equal to B and at least one is strictly lower. No tolerance, rounding, quantization, solver tolerance, or near-tie rule was used for rank assignment.",
        "",
        "The primary route repeatedly identified all zero-dominator solutions in the current residual and removed each complete layer simultaneously. The independent route built the full 18×18 directed dominance graph (excluding the diagonal) and removed zero-indegree layers simultaneously.",
        "",
        "## Complete rank composition",
        "",
        *rank_lines,
        "",
        f"Rank 1 contains {summary_rows[0]['H_count']} historical and {summary_rows[0]['C_count']} CORRECTED_R1 solutions.",
        "",
        "The Rank 1 name is **joint nondominated set of the 18 evaluated solutions** (conjunto no dominado conjunto de las 18 soluciones evaluadas).",
        "",
        "## Upstream consistency and independent QC",
        "",
        "Direct comparison of the canonical objective vectors produced only C04→H05, H02→C06, and H08→C08. Thus H05, C06, and C08 are the only initial exclusions from Rank 1, consistent with CR1-COMP-02/05/06/07.",
        "",
        "The two sorting routes produced identical ranks and layer memberships for all 18 solutions. Assignment completeness, layer-count sum, integer ranks, Rank 1 indegree, later-rank explanation, dominance/rank monotonicity, and simultaneous layer removal all passed.",
        "",
        "`INDEPENDENT_QC = PASS`",
        "",
        "## Limited interpretation",
        "",
        "When the 18 evaluated solutions are considered jointly under corrected COST-E3D, eight historical and seven CORRECTED_R1 solutions remain nondominated. Historical solutions retain nondominated tradeoffs not replaced by CORRECTED_R1, while CORRECTED_R1 also contributes nondominated tradeoffs absent from the historical set.",
        "",
        "This finite-set result does not establish global or statistical superiority, convergence, robustness across seeds, approximation to the true front, expected gamultiobj performance, a single best solution, or physical/economic/environmental mechanisms.",
        "",
        "## Actions not executed",
        "",
        "No CR1-COMP-09 geometry, figure generation, hypervolume gate, hypervolume, representative-solution decomposition, MATLAB, objective/model evaluation, replay, gamultiobj, optimization, or manuscript modification was executed.",
        "",
        "## Output hashes",
        "",
        *[f"- `{name}`: `{digest}`" for name, digest in output_hashes.items()],
        "",
        "The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.",
        "",
    ]
    audit_path.write_text("\n".join(audit_lines), encoding="utf-8")


if __name__ == "__main__":
    main()
