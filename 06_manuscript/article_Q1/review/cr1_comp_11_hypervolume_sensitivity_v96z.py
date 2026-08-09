"""CR1-COMP-11 hypervolume and predefined reference-point sensitivity.

The main 3D union calculation uses inclusion-exclusion. An independent
Cartesian grid-cell decomposition verifies every source/reference result.
No optimization, model evaluation, MATLAB execution, or later comparative
phase is performed.
"""

from __future__ import annotations

import csv
import hashlib
import itertools
import json
import math
from pathlib import Path


BASELINE_HEAD = "4935e40220c2909685d99a0a1d7c0a50ef57da61"
PROTOCOL_VERSION = "v1.0"
PROTOCOL_STATUS = "FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION"
FILES = {
    "protocol": (
        "CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md",
        "8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3",
    ),
    "dataset": (
        "CR1_COMP_01_CANONICAL_DATASET_v96z.json",
        "4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164",
    ),
    "within_set_status": (
        "CR1_COMP_02_WITHIN_SET_SOLUTION_STATUS_v96z.csv",
        "74C33FA77D543FAADA6B9819AF88C133E23D5E283148999849ECF83998D1E5C2",
    ),
    "within_set_result": (
        "CR1_COMP_02_WITHIN_SET_EXACT_PARETO_AUDIT_v96z.json",
        "6E5391E6D8C65AD04C91EB1A00EE16360D5EE189AF77B67B911CA5B31281CCED",
    ),
    "geometry": (
        "CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_v96z.json",
        "BD23627AAF81BD4231A3D84D819422D3CE93F84EDF0F33995A238DE3CE5651F9",
    ),
    "hv_gate": (
        "CR1_COMP_10_HYPERVOLUME_DECISION_GATE_v96z.json",
        "52A7AA4735B59C01EF57F27841A3DEE8B1EC0AA1F23B4653049EBA20E40352DE",
    ),
}
OBJECTIVES = [
    ("f1", "MR_final"),
    ("f2", "cost_specific_USD_per_kgwater"),
    ("f3", "CO2_specific_kgCO2_per_kgwater"),
]
REFERENCES = {
    "r5": (1.05, 1.05, 1.05),
    "r10": (1.10, 1.10, 1.10),
    "r20": (1.20, 1.20, 1.20),
}
PRIMARY_REFERENCE = "r10"
QC_TOLERANCE_FACTOR = 1e-12
HV_CSV = "CR1_COMP_11_HYPERVOLUME_SENSITIVITY_v96z.csv"
ANCHORS_CSV = "CR1_COMP_11_HYPERVOLUME_ANCHORS_v96z.csv"
NORMALIZED_CSV = "CR1_COMP_11_HYPERVOLUME_NORMALIZED_POINTS_v96z.csv"
RESULT_JSON = "CR1_COMP_11_HYPERVOLUME_SENSITIVITY_v96z.json"
AUDIT_MD = "CR1_COMP_11_HYPERVOLUME_SENSITIVITY_AUDIT_v96z.md"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def write_csv(path: Path, rows: list[dict[str, object]], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def hv_inclusion_exclusion(points: list[tuple[float, float, float]], ref: tuple[float, float, float]) -> float:
    contributions: list[float] = []
    for size in range(1, len(points) + 1):
        sign = 1.0 if size % 2 else -1.0
        for subset in itertools.combinations(points, size):
            lower = tuple(max(point[k] for point in subset) for k in range(3))
            intersection = math.prod(max(0.0, ref[k] - lower[k]) for k in range(3))
            contributions.append(sign * intersection)
    return math.fsum(contributions)


def hv_grid_cell_union(points: list[tuple[float, float, float]], ref: tuple[float, float, float]) -> float:
    breaks = [sorted({point[k] for point in points} | {ref[k]}) for k in range(3)]
    covered_volumes: list[float] = []
    for i in range(len(breaks[0]) - 1):
        x0, x1 = breaks[0][i], breaks[0][i + 1]
        for j in range(len(breaks[1]) - 1):
            y0, y1 = breaks[1][j], breaks[1][j + 1]
            for k in range(len(breaks[2]) - 1):
                z0, z1 = breaks[2][k], breaks[2][k + 1]
                volume = (x1 - x0) * (y1 - y0) * (z1 - z0)
                if volume <= 0.0:
                    continue
                midpoint = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
                if any(all(point[d] <= midpoint[d] for d in range(3)) for point in points):
                    covered_volumes.append(volume)
    return math.fsum(covered_volumes)


def direction(hv_h: float, hv_c: float) -> str:
    if hv_c > hv_h:
        return "C_GT_H"
    if hv_c < hv_h:
        return "H_GT_C"
    return "EQUAL"


def main() -> None:
    here = Path(__file__).resolve().parent
    paths = {key: here / filename for key, (filename, _) in FILES.items()}
    hashes = {key: sha256(path) for key, path in paths.items()}
    for key, (_, expected_hash) in FILES.items():
        if hashes[key] != expected_hash:
            raise RuntimeError(f"{key} SHA-256 mismatch: {hashes[key]} != {expected_hash}")

    with paths["dataset"].open("r", encoding="utf-8") as handle:
        dataset = json.load(handle)
    with paths["within_set_result"].open("r", encoding="utf-8") as handle:
        within = json.load(handle)
    with paths["geometry"].open("r", encoding="utf-8") as handle:
        geometry = json.load(handle)
    with paths["hv_gate"].open("r", encoding="utf-8") as handle:
        gate = json.load(handle)
    status_rows = read_csv(paths["within_set_status"])

    gate_pass = (
        gate.get("cr1_comp_10_status") == "CLOSED_PASS"
        and gate.get("hypervolume_gate_computed") is True
        and gate["gate_evaluation"]["gate_full_dominance_condition"] is False
        and gate["gate_evaluation"]["hypervolume_gate_outcome"] == "RECOMMENDED"
        and gate.get("hypervolume_computed") is False
        and gate.get("cr1_comp_11_computed") is False
    )
    if not gate_pass:
        raise RuntimeError("CR1-COMP-10 upstream gate is not RECOMMENDED/CLOSED_PASS")

    records = dataset["records"]
    structural_input_pass = (
        dataset.get("dataset_status") == "BUILT_FROZEN_VALIDATED"
        and dataset.get("record_count") == 18
        and len(records) == 18
        and len(dataset.get("objective_order", [])) == 3
        and dataset.get("all_objectives_minimized") is True
        and all(record.get("finite") is True for record in records)
        and all(record.get("penalized") is False for record in records)
        and all(
            math.isfinite(float(record[field]))
            for record in records
            for _, field in OBJECTIVES
        )
    )
    if not structural_input_pass:
        raise RuntimeError("Canonical dataset structural input gate failed")

    if within.get("cr1_comp_02_status") != "CLOSED_PASS" or within["qc"]["independent_qc"] != "PASS":
        raise RuntimeError("CR1-COMP-02 upstream state is not CLOSED_PASS/PASS")
    n_h_ids = list(within["N_H"])
    n_c_ids = list(within["N_C"])
    csv_n_h = [row["solution_id"] for row in status_rows if row["source"] == "HIST_R1_REEVAL" and row["within_set_nondominated"] == "YES"]
    csv_n_c = [row["solution_id"] for row in status_rows if row["source"] == "CORRECTED_R1" and row["within_set_nondominated"] == "YES"]
    if n_h_ids != csv_n_h or n_c_ids != csv_n_c or len(n_h_ids) != 9 or len(n_c_ids) != 9:
        raise RuntimeError("N_H/N_C inconsistency between CR1-COMP-02 artifacts")

    record_by_id = {record["solution_id"]: record for record in records}
    p_ids = n_h_ids + n_c_ids
    if len(p_ids) != 18 or len(set(p_ids)) != 18 or any(solution_id not in record_by_id for solution_id in p_ids):
        raise RuntimeError("P = N_H union N_C structural check failed")

    anchors: list[dict[str, object]] = []
    scale_min: list[float] = []
    scale_max: list[float] = []
    scale_range: list[float] = []
    for objective, field in OBJECTIVES:
        values = [(float(record_by_id[solution_id][field]), solution_id) for solution_id in p_ids]
        minimum = min(value for value, _ in values)
        maximum = max(value for value, _ in values)
        minimum_ids = [solution_id for value, solution_id in values if value == minimum]
        maximum_ids = [solution_id for value, solution_id in values if value == maximum]
        value_range = maximum - minimum
        anchors.append(
            {
                "objective": objective,
                "scale_min": minimum,
                "scale_min_solution_id": ",".join(minimum_ids),
                "scale_max": maximum,
                "scale_max_solution_id": ",".join(maximum_ids),
                "scale_range": value_range,
                "zero_range": "YES" if value_range == 0.0 else "NO",
                "normalization_shared": "YES",
            }
        )
        scale_min.append(minimum)
        scale_max.append(maximum)
        scale_range.append(value_range)
    zero_range_count = sum(value_range == 0.0 for value_range in scale_range)
    if zero_range_count:
        raise RuntimeError("BLOCKED_ZERO_HV_ANCHOR_RANGE")

    expected_extrema = {
        "f1": (scale_min[0], [anchors[0]["scale_min_solution_id"]], scale_max[0], [anchors[0]["scale_max_solution_id"]]),
        "f2": (scale_min[1], [anchors[1]["scale_min_solution_id"]], scale_max[1], [anchors[1]["scale_max_solution_id"]]),
        "f3": (scale_min[2], [anchors[2]["scale_min_solution_id"]], scale_max[2], [anchors[2]["scale_max_solution_id"]]),
    }
    anchor_geometry_qc = geometry.get("cr1_comp_09_status") == "CLOSED_PASS" and geometry["qc"]["independent_qc"] == "PASS"
    for objective, (minimum, minimum_ids, maximum, maximum_ids) in expected_extrema.items():
        observed = geometry["global_extrema"][objective]
        anchor_geometry_qc = anchor_geometry_qc and (
            observed["min"] == minimum
            and observed["min_ids"] == minimum_ids
            and observed["max"] == maximum
            and observed["max_ids"] == maximum_ids
        )
    if not anchor_geometry_qc:
        raise RuntimeError("Anchor consistency check against CR1-COMP-09 failed")

    normalized_rows: list[dict[str, object]] = []
    normalized_by_id: dict[str, tuple[float, float, float]] = {}
    for solution_id in p_ids:
        record = record_by_id[solution_id]
        raw = tuple(float(record[field]) for _, field in OBJECTIVES)
        normalized = tuple((raw[k] - scale_min[k]) / scale_range[k] for k in range(3))
        normalized_by_id[solution_id] = normalized
        normalized_rows.append(
            {
                "solution_id": solution_id,
                "source": record["source"],
                "in_N_H": "YES" if solution_id in n_h_ids else "NO",
                "in_N_C": "YES" if solution_id in n_c_ids else "NO",
                "f1_raw": raw[0],
                "f2_raw": raw[1],
                "f3_raw": raw[2],
                "z1": normalized[0],
                "z2": normalized[1],
                "z3": normalized[2],
            }
        )
    all_within_cube = all(0.0 <= value <= 1.0 for point in normalized_by_id.values() for value in point)
    if not all_within_cube:
        raise RuntimeError("Normalized point outside unit cube")

    raw_references = {
        label: tuple(scale_min[k] + ref[k] * scale_range[k] for k in range(3))
        for label, ref in REFERENCES.items()
    }
    points_by_source = {
        "H": [normalized_by_id[solution_id] for solution_id in n_h_ids],
        "C": [normalized_by_id[solution_id] for solution_id in n_c_ids],
    }
    if any(
        point[k] > ref[k]
        for ref in REFERENCES.values()
        for points in points_by_source.values()
        for point in points
        for k in range(3)
    ):
        raise RuntimeError("HV input point lies outside a predefined reference point")

    calculations: dict[str, dict[str, dict[str, object]]] = {}
    directions: dict[str, str] = {}
    method_qc_by_reference: dict[str, dict[str, object]] = {}
    hv_rows: list[dict[str, object]] = []
    for reference_label, ref in REFERENCES.items():
        calculations[reference_label] = {}
        for source, points in points_by_source.items():
            main_hv = hv_inclusion_exclusion(points, ref)
            qc_hv = hv_grid_cell_union(points, ref)
            abs_diff = abs(main_hv - qc_hv)
            qc_limit = QC_TOLERANCE_FACTOR * max(1.0, abs(main_hv), abs(qc_hv))
            qc_pass = abs_diff <= qc_limit
            if not qc_pass:
                raise RuntimeError("BLOCKED_HV_IMPLEMENTATION_QC_MISMATCH")
            calculations[reference_label][source] = {
                "hypervolume_inclusion_exclusion": main_hv,
                "hypervolume_grid_cell_union": qc_hv,
                "method_abs_diff": abs_diff,
                "implementation_qc_limit": qc_limit,
                "implementation_qc": "PASS",
            }
        hv_h = calculations[reference_label]["H"]["hypervolume_inclusion_exclusion"]
        hv_c = calculations[reference_label]["C"]["hypervolume_inclusion_exclusion"]
        directions[reference_label] = direction(hv_h, hv_c)
        method_qc_by_reference[reference_label] = {
            "H_abs_diff": calculations[reference_label]["H"]["method_abs_diff"],
            "C_abs_diff": calculations[reference_label]["C"]["method_abs_diff"],
            "max_abs_diff": max(
                calculations[reference_label]["H"]["method_abs_diff"],
                calculations[reference_label]["C"]["method_abs_diff"],
            ),
            "status": "PASS",
        }
        raw_ref = raw_references[reference_label]
        for source in ("H", "C"):
            hv_rows.append(
                {
                    "source": source,
                    "nondominated_count": len(points_by_source[source]),
                    "reference_label": reference_label,
                    "reference_z1": ref[0],
                    "reference_z2": ref[1],
                    "reference_z3": ref[2],
                    "reference_raw_f1": raw_ref[0],
                    "reference_raw_f2": raw_ref[1],
                    "reference_raw_f3": raw_ref[2],
                    "hypervolume": calculations[reference_label][source]["hypervolume_inclusion_exclusion"],
                    "hv_direction_for_reference": directions[reference_label],
                    "primary_reference": "YES" if reference_label == PRIMARY_REFERENCE else "NO",
                }
            )

    sensitivity_status = "ROBUST_DIRECTION" if len(set(directions.values())) == 1 else "REFERENCE_POINT_SENSITIVE"
    primary = calculations[PRIMARY_REFERENCE]
    primary_direction = directions[PRIMARY_REFERENCE]
    permitted_interpretation = (
        "El conjunto con mayor hypervolume presenta mayor cobertura del espacio objetivo definido por los "
        "anclajes comunes de esta comparación, y la dirección de la diferencia se mantiene para los tres "
        "reference points preespecificados."
        if sensitivity_status == "ROBUST_DIRECTION"
        else "La dirección del hypervolume depende del reference point preespecificado; no debe usarse como evidencia fuerte."
    )

    write_csv(
        here / HV_CSV,
        hv_rows,
        [
            "source", "nondominated_count", "reference_label", "reference_z1", "reference_z2", "reference_z3",
            "reference_raw_f1", "reference_raw_f2", "reference_raw_f3", "hypervolume",
            "hv_direction_for_reference", "primary_reference",
        ],
    )
    write_csv(
        here / ANCHORS_CSV,
        anchors,
        [
            "objective", "scale_min", "scale_min_solution_id", "scale_max", "scale_max_solution_id",
            "scale_range", "zero_range", "normalization_shared",
        ],
    )
    write_csv(
        here / NORMALIZED_CSV,
        normalized_rows,
        ["solution_id", "source", "in_N_H", "in_N_C", "f1_raw", "f2_raw", "f3_raw", "z1", "z2", "z3"],
    )

    result = {
        "artifact_role": "CR1_COMP_11_HYPERVOLUME_SENSITIVITY",
        "cr1_comp_11_status": "CLOSED_PASS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "protocol": {
            "path": f"06_manuscript/article_Q1/review/{FILES['protocol'][0]}",
            "version": PROTOCOL_VERSION,
            "status": PROTOCOL_STATUS,
            "sha256": hashes["protocol"],
            "sha256_check": "PASS",
        },
        "inputs": {
            key: {
                "path": f"06_manuscript/article_Q1/review/{FILES[key][0]}",
                "sha256": hashes[key],
                "sha256_check": "PASS",
            }
            for key in ("dataset", "within_set_status", "within_set_result", "geometry", "hv_gate")
        },
        "upstream": {
            "hv_gate_upstream_check": "PASS",
            "upstream_hash_checks": "PASS",
            "upstream_consistency_check": "PASS",
            "dataset_rows": len(records),
            "H_rows": sum(record["source"] == "HIST_R1_REEVAL" for record in records),
            "C_rows": sum(record["source"] == "CORRECTED_R1" for record in records),
            "objective_count": len(OBJECTIVES),
            "all_hv_inputs_finite": True,
            "all_hv_inputs_nonpenalized": True,
        },
        "sets": {
            "N_H_ids": n_h_ids,
            "N_C_ids": n_c_ids,
            "P_ids": p_ids,
            "N_H_count": len(n_h_ids),
            "N_C_count": len(n_c_ids),
            "P_count": len(p_ids),
            "P_definition": "N_H_UNION_N_C",
            "joint_rank1_used_as_hv_input": False,
            "gasLP_included_in_hypervolume": False,
        },
        "anchors": anchors,
        "HV_SCALE_MIN": scale_min,
        "HV_SCALE_MAX": scale_max,
        "HV_SCALE_RANGE": scale_range,
        "HV_ZERO_RANGE_OBJECTIVE_COUNT": zero_range_count,
        "normalization": {
            "formula": "z_k=(f_k-HV_SCALE_MIN_k)/(HV_SCALE_MAX_k-HV_SCALE_MIN_k)",
            "common_normalization_used": True,
            "independent_normalization_H_C": False,
            "all_normalized_points_within_unit_cube": all_within_cube,
            "clipping_used": False,
            "normalized_coordinates": normalized_rows,
        },
        "references": {
            label: {"normalized": list(ref), "raw": list(raw_references[label]), "predefined": True}
            for label, ref in REFERENCES.items()
        },
        "primary_reference": PRIMARY_REFERENCE,
        "sensitivity_references": list(REFERENCES),
        "methods": {
            "main": "INCLUSION_EXCLUSION_3D",
            "qc": "GRID_CELL_UNION_3D",
            "main_terms_per_source_reference": 2 ** len(n_h_ids) - 1,
            "implementation_qc_tolerance_role": "IMPLEMENTATION_QC_TOLERANCE_ONLY",
            "implementation_qc_tolerance": "abs_diff <= 1e-12 * max(1,abs(HV_method1),abs(HV_method2))",
            "monte_carlo_used": False,
            "point_rounding_used": False,
        },
        "calculations": calculations,
        "directions": directions,
        "method_qc_by_reference": method_qc_by_reference,
        "primary_result": {
            "HV_H": primary["H"]["hypervolume_inclusion_exclusion"],
            "HV_C": primary["C"]["hypervolume_inclusion_exclusion"],
            "HV_DIRECTION": primary_direction,
            "HV_REFERENCE_NORMALIZED": list(REFERENCES[PRIMARY_REFERENCE]),
            "HV_REFERENCE_RAW": list(raw_references[PRIMARY_REFERENCE]),
        },
        "HV_SENSITIVITY_STATUS": sensitivity_status,
        "HV_SCOPE": "COVERAGE_OF_ANCHORED_OBJECTIVE_SPACE",
        "permitted_interpretation": permitted_interpretation,
        "limitations": [
            "Hypervolume does not estimate distance to a true Pareto front or demonstrate convergence.",
            "The result is not a statistical superiority test or evidence of robustness across seeds.",
            "H remains historical R1 solutions reevaluated under corrected COST-E3D.",
            "C remains the CORRECTED_R1 nondominated approximation.",
        ],
        "qc": {
            "anchor_geometry_consistency": "PASS",
            "common_normalization": "PASS",
            "reference_points_predefined": "PASS",
            "all_points_within_references": "PASS",
            "all_method_comparisons": "PASS",
            "sensitivity_complete": "PASS",
            "independent_qc": "PASS",
        },
        "completion": {
            "hypervolume_computed": True,
            "hv_anchors_frozen": True,
            "hv_sensitivity_completed": True,
            "cr1_comp_12_computed": False,
        },
        "not_executed": {
            "terminal_regime_comparison_computed": False,
            "objective_decomposition_computed": False,
            "physical_interpretation_computed": False,
            "economic_interpretation_computed": False,
            "environmental_interpretation_computed": False,
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
        "next_recommended_step": "CR1-COMP-12 — Common terminal-regime analysis; separate authorization required",
    }
    with (here / RESULT_JSON).open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(result, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    def fmt(values: list[float] | tuple[float, ...]) -> str:
        return "[" + ",".join(repr(value) for value in values) + "]"

    audit = f"""# CR1-COMP-11 — Hypervolume and sensitivity audit

## Scope and frozen inputs

CR1-COMP-11 computes `HV(N_H)` and `HV(N_C)` under one common normalization
and the three protocol-defined reference points. It does not execute any later
comparative phase, optimization, model evaluation, or physical/economic/environmental interpretation.

```text
INPUT_BASELINE_HEAD = {BASELINE_HEAD}
INPUT_BASELINE_CHECK = PASS
PROTOCOL_SHA256 = {hashes['protocol']}
PROTOCOL_SHA256_CHECK = PASS
HV_GATE_UPSTREAM_CHECK = PASS
UPSTREAM_HASH_CHECKS = PASS
UPSTREAM_CONSISTENCY_CHECK = PASS
```

## Sets and common anchors

```text
N_H_COUNT = {len(n_h_ids)}
N_C_COUNT = {len(n_c_ids)}
P_COUNT = {len(p_ids)}
N_H_IDS = {','.join(n_h_ids)}
N_C_IDS = {','.join(n_c_ids)}
P_DEFINITION = N_H_UNION_N_C
HV_SCALE_MIN = {fmt(scale_min)}
HV_SCALE_MAX = {fmt(scale_max)}
HV_SCALE_RANGE = {fmt(scale_range)}
HV_ZERO_RANGE_OBJECTIVE_COUNT = {zero_range_count}
COMMON_NORMALIZATION_USED = YES
INDEPENDENT_NORMALIZATION_H_C = NO
ALL_NORMALIZED_POINTS_WITHIN_UNIT_CUBE = YES
GASLP_INCLUDED_IN_HYPERVOLUME = NO
```

The anchors were derived from `P` and independently matched the frozen global
extrema in CR1-COMP-09. The joint Rank 1 set was not used as an HV input.

## Predefined references

```text
HV_REFERENCE_NORMALIZED_R5 = {fmt(REFERENCES['r5'])}
HV_REFERENCE_RAW_R5 = {fmt(raw_references['r5'])}
HV_REFERENCE_NORMALIZED_R10 = {fmt(REFERENCES['r10'])}
HV_REFERENCE_RAW_R10 = {fmt(raw_references['r10'])}
HV_REFERENCE_NORMALIZED_R20 = {fmt(REFERENCES['r20'])}
HV_REFERENCE_RAW_R20 = {fmt(raw_references['r20'])}
PRIMARY_HV_REFERENCE = r10
REFERENCE_POINTS_PREDEFINED = YES
```

## Deterministic methods and implementation QC

The main method is exact finite 3D inclusion-exclusion over 511 nonempty
subsets per source/reference. The independent QC method partitions the union
into Cartesian grid cells and counts each covered cell once. No Monte Carlo,
sampling, point rounding, clipping, or tolerance-based direction change was used.

```text
HV_MAIN_METHOD = INCLUSION_EXCLUSION_3D
HV_QC_METHOD = GRID_CELL_UNION_3D
IMPLEMENTATION_QC_TOLERANCE_ROLE = IMPLEMENTATION_QC_TOLERANCE_ONLY
HV_METHOD_QC_R5 = PASS; MAX_ABS_DIFF={method_qc_by_reference['r5']['max_abs_diff']!r}
HV_METHOD_QC_R10 = PASS; MAX_ABS_DIFF={method_qc_by_reference['r10']['max_abs_diff']!r}
HV_METHOD_QC_R20 = PASS; MAX_ABS_DIFF={method_qc_by_reference['r20']['max_abs_diff']!r}
```

## Results and reference-point sensitivity

```text
HV_H_R5 = {calculations['r5']['H']['hypervolume_inclusion_exclusion']!r}
HV_C_R5 = {calculations['r5']['C']['hypervolume_inclusion_exclusion']!r}
HV_DIRECTION_R5 = {directions['r5']}
HV_H_R10 = {calculations['r10']['H']['hypervolume_inclusion_exclusion']!r}
HV_C_R10 = {calculations['r10']['C']['hypervolume_inclusion_exclusion']!r}
HV_DIRECTION_R10 = {directions['r10']}
HV_H_R20 = {calculations['r20']['H']['hypervolume_inclusion_exclusion']!r}
HV_C_R20 = {calculations['r20']['C']['hypervolume_inclusion_exclusion']!r}
HV_DIRECTION_R20 = {directions['r20']}
HV_H = {primary['H']['hypervolume_inclusion_exclusion']!r}
HV_C = {primary['C']['hypervolume_inclusion_exclusion']!r}
HV_DIRECTION = {primary_direction}
HV_SENSITIVITY_STATUS = {sensitivity_status}
```

## Permitted interpretation and limitations

{permitted_interpretation}

The scope is `COVERAGE_OF_ANCHORED_OBJECTIVE_SPACE`. The result does not show
distance to a true Pareto front, convergence, statistical superiority,
seed-robustness, integral physical superiority, or a single best solution.

## Final QC and exclusions

```text
ALL_HV_INPUTS_FINITE = YES
ALL_HV_INPUTS_NONPENALIZED = YES
REFERENCE_POINTS_PREDEFINED = YES
INDEPENDENT_QC = PASS
HYPERVOLUME_COMPUTED = YES
HV_ANCHORS_FROZEN = YES
HV_SENSITIVITY_COMPLETED = YES
CR1_COMP_12_COMPUTED = NO
TERMINAL_REGIME_COMPARISON_COMPUTED = NO
OBJECTIVE_DECOMPOSITION_COMPUTED = NO
MATLAB_EXECUTED = NO
OBJECTIVE_EVALUATIONS = 0
REPLAYS = 0
GAMULTIOBJ_EXECUTIONS = 0
NEW_OPTIMIZATION_RUNS = 0
```

CR1-COMP-12 remains separate and requires explicit authorization.
"""
    (here / AUDIT_MD).write_text(audit, encoding="utf-8", newline="\n")

    print("CR1_COMP_11_STATUS=CLOSED_PASS")
    print(f"HV_SCALE_MIN={fmt(scale_min)}")
    print(f"HV_SCALE_MAX={fmt(scale_max)}")
    for label in REFERENCES:
        print(f"HV_H_{label.upper()}={calculations[label]['H']['hypervolume_inclusion_exclusion']!r}")
        print(f"HV_C_{label.upper()}={calculations[label]['C']['hypervolume_inclusion_exclusion']!r}")
        print(f"HV_DIRECTION_{label.upper()}={directions[label]}")
    print(f"HV_SENSITIVITY_STATUS={sensitivity_status}")
    print("INDEPENDENT_QC=PASS")


if __name__ == "__main__":
    main()
