"""CR1-COMP-03 decision-space descriptive analysis under frozen D013."""

from __future__ import annotations

import csv
import hashlib
import json
import math
import statistics
from pathlib import Path


BASELINE_HEAD = "790c176c08b8260def410776d72f73e44fd6b27f"
INPUT_NAME = "CR1_COMP_01_CANONICAL_DATASET_v96z.json"
INPUT_SHA256 = "4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164"
DESCRIPTIVE_NAME = "CR1_COMP_03_DECISION_SPACE_DESCRIPTIVE_v96z.csv"
COMPARISON_NAME = "CR1_COMP_03_DECISION_SPACE_COMPARISON_v96z.csv"
RESULT_NAME = "CR1_COMP_03_DECISION_SPACE_DESCRIPTIVE_v96z.json"

VARIABLES = ("m_max", "T_min", "r_div2", "t_rec_ini")
SOURCES = ("HIST_R1_REEVAL", "CORRECTED_R1")
UNITS = {
    "m_max": "kg/s",
    "T_min": "degC",
    "r_div2": "dimensionless",
    "t_rec_ini": "h",
}
LB = {
    "m_max": 0.0540767982118,
    "T_min": 57.6832965028,
    "r_div2": 0.422252618341,
    "t_rec_ini": 8.6517528081,
}
UB = {
    "m_max": 0.0940767982118,
    "T_min": 67.6832965028,
    "r_div2": 0.922252618341,
    "t_rec_ini": 14.0,
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def quantile_type7(values: list[float], p: float) -> float:
    """Hyndman-Fan Type 7: h=1+(n-1)p with linear interpolation."""
    ordered = sorted(values)
    h = 1.0 + (len(ordered) - 1) * p
    lower_one_based = math.floor(h)
    fraction = h - lower_one_based
    lower = ordered[lower_one_based - 1]
    if fraction == 0.0:
        return lower
    upper = ordered[lower_one_based]
    return lower + fraction * (upper - lower)


def summarize(source: str, variable: str, values: list[float]) -> dict:
    n = len(values)
    lower, upper = LB[variable], UB[variable]
    width = upper - lower
    minimum, maximum = min(values), max(values)
    mean = math.fsum(values) / n
    median = quantile_type7(values, 0.5)
    q1 = quantile_type7(values, 0.25)
    q3 = quantile_type7(values, 0.75)
    population_std = math.sqrt(math.fsum((x - mean) ** 2 for x in values) / n)
    occupied = maximum - minimum
    return {
        "source": source,
        "variable": variable,
        "unit": UNITS[variable],
        "n": n,
        "min": minimum,
        "max": maximum,
        "mean": mean,
        "median": median,
        "std": population_std,
        "std_convention": "POPULATION_DDOF_0",
        "range": occupied,
        "q1": q1,
        "q3": q3,
        "IQR": q3 - q1,
        "quartile_convention": "HYNDMAN_FAN_TYPE_7",
        "lb": lower,
        "ub": upper,
        "occupied_range": occupied,
        "occupied_range_normalized": occupied / width,
        "min_distance_to_lb": minimum - lower,
        "max_distance_to_lb": maximum - lower,
        "min_distance_to_ub": upper - maximum,
        "max_distance_to_ub": upper - minimum,
        "min_normalized_distance_to_lb": (minimum - lower) / width,
        "max_normalized_distance_to_lb": (maximum - lower) / width,
        "min_normalized_distance_to_ub": (upper - maximum) / width,
        "max_normalized_distance_to_ub": (upper - minimum) / width,
    }


def independent_core(values: list[float]) -> dict:
    """Independent ordered-list implementation for required QC quantities."""
    ordered = sorted(values)
    n = len(ordered)
    middle = ordered[n // 2]
    return {
        "min": ordered[0],
        "max": ordered[-1],
        "median": middle,
        "range": ordered[-1] - ordered[0],
    }


def write_csv(path: Path, rows: list[dict], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    here = Path(__file__).resolve().parent
    input_path = here / INPUT_NAME
    if sha256(input_path) != INPUT_SHA256:
        raise RuntimeError("Canonical dataset SHA-256 mismatch")
    dataset = json.loads(input_path.read_text(encoding="utf-8"))
    if (
        dataset.get("record_count") != 18
        or dataset.get("decision_variable_order") != list(VARIABLES)
    ):
        raise RuntimeError("Unexpected canonical dataset structure")

    records = dataset.get("records", [])
    grouped = {source: [r for r in records if r.get("source") == source] for source in SOURCES}
    if any(len(rows) != 9 for rows in grouped.values()):
        raise RuntimeError("Expected exactly nine rows per source")
    if any(
        not math.isfinite(float(record[variable]))
        for record in records
        for variable in VARIABLES
    ):
        raise RuntimeError("Nonfinite decision variable encountered")
    bounds_check = all(
        LB[variable] <= float(record[variable]) <= UB[variable]
        for record in records
        for variable in VARIABLES
    )
    if not bounds_check:
        raise RuntimeError("Decision variable outside frozen bounds")

    summaries = []
    values_by_key = {}
    for source in SOURCES:
        for variable in VARIABLES:
            values = [float(record[variable]) for record in grouped[source]]
            values_by_key[(source, variable)] = values
            summaries.append(summarize(source, variable, values))

    summary_by_key = {(row["source"], row["variable"]): row for row in summaries}
    comparisons = []
    for variable in VARIABLES:
        h = summary_by_key[("HIST_R1_REEVAL", variable)]
        c = summary_by_key[("CORRECTED_R1", variable)]
        delta = c["median"] - h["median"]
        comparisons.append(
            {
                "variable": variable,
                "unit": UNITS[variable],
                "median_H": h["median"],
                "median_C": c["median"],
                "delta_median_C_minus_H": delta,
                "delta_median_normalized": delta / (UB[variable] - LB[variable]),
                "range_H": h["range"],
                "range_C": c["range"],
                "occupied_range_normalized_H": h["occupied_range_normalized"],
                "occupied_range_normalized_C": c["occupied_range_normalized"],
            }
        )

    independent_checks = []
    for summary in summaries:
        key = (summary["source"], summary["variable"])
        independent = independent_core(values_by_key[key])
        independent_checks.append(
            all(summary[field] == independent[field] for field in independent)
            and summary["range"] == summary["max"] - summary["min"]
            and summary["IQR"] == summary["q3"] - summary["q1"]
        )
    for comparison in comparisons:
        variable = comparison["variable"]
        h_values = sorted(values_by_key[("HIST_R1_REEVAL", variable)])
        c_values = sorted(values_by_key[("CORRECTED_R1", variable)])
        independent_delta = c_values[4] - h_values[4]
        independent_checks.append(
            comparison["delta_median_C_minus_H"] == independent_delta
            and comparison["delta_median_normalized"]
            == independent_delta / (UB[variable] - LB[variable])
        )
    independent_qc = all(independent_checks)
    if not independent_qc:
        raise RuntimeError("Independent QC failed")

    descriptive_fields = [
        "source", "variable", "unit", "n", "min", "max", "mean", "median",
        "std", "std_convention", "range", "q1", "q3", "IQR",
        "quartile_convention", "lb", "ub", "occupied_range",
        "occupied_range_normalized", "min_distance_to_lb", "max_distance_to_lb",
        "min_distance_to_ub", "max_distance_to_ub",
        "min_normalized_distance_to_lb", "max_normalized_distance_to_lb",
        "min_normalized_distance_to_ub", "max_normalized_distance_to_ub",
    ]
    comparison_fields = [
        "variable", "unit", "median_H", "median_C", "delta_median_C_minus_H",
        "delta_median_normalized", "range_H", "range_C",
        "occupied_range_normalized_H", "occupied_range_normalized_C",
    ]
    descriptive_path = here / DESCRIPTIVE_NAME
    comparison_path = here / COMPARISON_NAME
    write_csv(descriptive_path, summaries, descriptive_fields)
    write_csv(comparison_path, comparisons, comparison_fields)

    result = {
        "artifact_role": "CR1_COMP_03_DECISION_SPACE_DESCRIPTIVE_ANALYSIS",
        "cr1_comp_03_status": "CLOSED_PASS",
        "analysis_designation": "DESCRIPTIVE_SUMMARIES_OF_FINITE_SOLUTION_SETS",
        "baseline_commit": BASELINE_HEAD,
        "input": {
            "path": "06_manuscript/article_Q1/review/" + INPUT_NAME,
            "sha256": INPUT_SHA256,
            "sha256_check": "PASS",
        },
        "conventions": {
            "decision": "D013",
            "std": "POPULATION_DDOF_0",
            "std_formula": "sqrt(sum((x_i-mean(x))^2)/n)",
            "IQR": "HYNDMAN_FAN_TYPE_7",
            "quantile_formula": "h=1+(n-1)p; linear interpolation",
            "bound_proximity": "DISTANCES_ONLY_NO_THRESHOLD",
        },
        "bounds": {variable: {"lb": LB[variable], "ub": UB[variable]} for variable in VARIABLES},
        "summaries": summaries,
        "comparison": comparisons,
        "qc": {
            "H_rows": len(grouped["HIST_R1_REEVAL"]),
            "C_rows": len(grouped["CORRECTED_R1"]),
            "variable_count": len(VARIABLES),
            "all_X_finite": True,
            "bounds_check": "PASS",
            "independent_qc": "PASS",
            "range_identity": "PASS",
            "IQR_identity": "PASS",
            "normalized_delta_uses_frozen_bounds": "PASS",
            "descriptive_csv_sha256": sha256(descriptive_path),
            "comparison_csv_sha256": sha256(comparison_path),
        },
        "not_computed": {
            "objective_space_descriptive_analysis": True,
            "cross_dominance": True,
            "near_tie": True,
            "coverage": True,
            "joint_sorting": True,
            "hypervolume": True,
            "hypothesis_tests": True,
        },
    }
    (here / RESULT_NAME).write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


if __name__ == "__main__":
    main()
