"""CR1-COMP-04 objective-space descriptive analysis under frozen D013."""

from __future__ import annotations

import csv
import hashlib
import json
import math
from pathlib import Path


BASELINE_HEAD = "354a9d40dc9803761e26910d306d14574dfa4f98"
INPUT_NAME = "CR1_COMP_01_CANONICAL_DATASET_v96z.json"
INPUT_SHA256 = "4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164"
DESCRIPTIVE_NAME = "CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_v96z.csv"
COMPARISON_NAME = "CR1_COMP_04_OBJECTIVE_SPACE_COMPARISON_v96z.csv"
RESULT_NAME = "CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_v96z.json"
AUDIT_NAME = "CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_AUDIT_v96z.md"

OBJECTIVES = (
    "MR_final",
    "cost_specific_USD_per_kgwater",
    "CO2_specific_kgCO2_per_kgwater",
)
SOURCES = ("HIST_R1_REEVAL", "CORRECTED_R1")
UNITS = {
    "MR_final": "dimensionless",
    "cost_specific_USD_per_kgwater": "USD/kgwater",
    "CO2_specific_kgCO2_per_kgwater": "kgCO2/kgwater",
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
    return lower + fraction * (ordered[lower_one_based] - lower)


def tied_ids(records: list[dict], objective: str, target: float) -> str:
    return ";".join(
        record["solution_id"]
        for record in records
        if float(record[objective]) == target
    )


def summarize(source: str, objective: str, records: list[dict]) -> dict:
    values = [float(record[objective]) for record in records]
    n = len(values)
    minimum, maximum = min(values), max(values)
    mean = math.fsum(values) / n
    q1 = quantile_type7(values, 0.25)
    q3 = quantile_type7(values, 0.75)
    return {
        "source": source,
        "objective": objective,
        "unit": UNITS[objective],
        "direction": "minimize",
        "n": n,
        "min": minimum,
        "min_solution_id": tied_ids(records, objective, minimum),
        "max": maximum,
        "max_solution_id": tied_ids(records, objective, maximum),
        "mean": mean,
        "median": quantile_type7(values, 0.5),
        "std": math.sqrt(math.fsum((x - mean) ** 2 for x in values) / n),
        "std_convention": "POPULATION_DDOF_0",
        "q1": q1,
        "q3": q3,
        "IQR": q3 - q1,
        "quartile_convention": "HYNDMAN_FAN_TYPE_7",
        "range": maximum - minimum,
    }


def independent_core(records: list[dict], objective: str) -> dict:
    """Independent ordered-list implementation for required QC quantities."""
    ordered = sorted(float(record[objective]) for record in records)
    return {
        "min": ordered[0],
        "max": ordered[-1],
        "median": ordered[len(ordered) // 2],
        "range": ordered[-1] - ordered[0],
    }


def write_csv(path: Path, rows: list[dict], fields: list[str]) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def fmt(value: float) -> str:
    return format(value, ".17g")


def write_audit(
    path: Path,
    summaries: list[dict],
    comparisons: list[dict],
    grouped: dict[str, list[dict]],
    output_hashes: dict[str, str],
) -> None:
    summary_by_key = {(row["source"], row["objective"]): row for row in summaries}
    lines = [
        "# CR1-COMP-04 — Objective-space Descriptive Analysis Audit",
        "",
        "## Purpose and status",
        "",
        "CR1-COMP-04 characterizes only the finite objective-space solution sets H and C. "
        "The result is `CLOSED_PASS` and is classified as "
        "`DESCRIPTIVE_SUMMARIES_OF_FINITE_SOLUTION_SETS`.",
        "",
        "## Baseline and canonical input",
        "",
        f"- Baseline HEAD: `{BASELINE_HEAD}` (`INPUT_BASELINE_CHECK = PASS`).",
        f"- Input: `06_manuscript/article_Q1/review/{INPUT_NAME}`.",
        f"- SHA-256: `{INPUT_SHA256}` (`INPUT_HASH_CHECK = PASS`).",
        "- Rows: H = 9; C = 9; objectives = 3; all objective values finite; penalty rows = 0.",
        "- H uses source `HIST_R1_REEVAL`; C uses source `CORRECTED_R1`.",
        "",
        "The D1 limitation remains in force for H.f2/f3: their corrected binary64 originals "
        "were not persisted, so the canonical dataset retains the approved validated 17-digit "
        "decimal documentary recovery. H is a historical reevaluated set, not a corrected Pareto front.",
        "",
        "## Frozen D013 conventions",
        "",
        "- `STD_CONVENTION = POPULATION_DDOF_0`: `sqrt(sum((x_i - mean(x))^2)/n)`.",
        "- `IQR_CONVENTION = HYNDMAN_FAN_TYPE_7`: `h=1+(n-1)p`, linear interpolation; `IQR=Q3-Q1`.",
        "- Median shift: `median_C - median_H`.",
        "- Percent median shift: `100 * (median_C - median_H) / median_H`; negative means C has a lower median and positive means C has a higher median.",
        "- All three objectives are minimized. No objective normalization was applied.",
        "",
        "## Results",
        "",
        "| Objective | Median H | Median C | Delta C-H | Delta % |",
        "|---|---:|---:|---:|---:|",
    ]
    for row in comparisons:
        lines.append(
            f"| {row['objective']} | {fmt(row['median_H'])} | {fmt(row['median_C'])} | "
            f"{fmt(row['delta_median_C_minus_H'])} | "
            f"{fmt(row['delta_median_percent_C_minus_H'])} |"
        )
    lines += [
        "",
        "These signs describe numerical median shifts only; they are not a multiobjective improvement claim.",
        "",
        "## Observed extrema",
        "",
        "| Source | Objective | Minimum solution ID(s) | Minimum |",
        "|---|---|---|---:|",
    ]
    for source in SOURCES:
        for objective in OBJECTIVES:
            row = summary_by_key[(source, objective)]
            lines.append(
                f"| {source} | {objective} | {row['min_solution_id']} | {fmt(row['min'])} |"
            )
    lines += [
        "",
        "The extrema are descriptive and do not select a best or representative solution.",
        "",
        "## Descriptive observations",
        "",
    ]
    for row in comparisons:
        relation = "lower" if row["delta_median_C_minus_H"] < 0 else "higher"
        h = summary_by_key[("HIST_R1_REEVAL", row["objective"])]
        c = summary_by_key[("CORRECTED_R1", row["objective"])]
        dispersion = "lower" if c["std"] < h["std"] else "higher"
        lines.append(
            f"- For `{row['objective']}`, C has a {relation} observed median than H and "
            f"{dispersion} descriptive population standard deviation."
        )
    lines += [
        "",
        "These statements concern only the two finite nine-point sets. No statistical significance, "
        "robustness, convergence, stochastic performance, causality, total batch cost, total energy, "
        "or total batch CO2 conclusion is supported here.",
        "",
        "## Independent QC",
        "",
        "An independent sorted-list implementation reproduced min, max, median, range, median delta, "
        "and percent median delta exactly in the numeric representation used. The identities "
        "`range=max-min` and `IQR=Q3-Q1` passed, as did percent/delta sign agreement for positive H medians.",
        "",
        "`INDEPENDENT_QC = PASS`",
        "",
        "## Actions not executed",
        "",
        "No MATLAB, objective/model evaluation, replay, gamultiobj, optimization, statistical test, "
        "cross-dominance, near-tie analysis, numeric-fragility analysis, coverage, joint sorting, "
        "hypervolume, figure, representative-solution selection, physical interpretation, or later "
        "CR1-COMP phase was executed. `CR1_COMP_05_COMPUTED = NO`.",
        "",
        "## Output hashes",
        "",
    ]
    for name, digest in output_hashes.items():
        lines.append(f"- `{name}`: `{digest}`")
    lines += [
        "",
        "The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` "
        "to avoid a self-referential hash.",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    here = Path(__file__).resolve().parent
    input_path = here / INPUT_NAME
    if sha256(input_path) != INPUT_SHA256:
        raise RuntimeError("Canonical dataset SHA-256 mismatch")
    dataset = json.loads(input_path.read_text(encoding="utf-8"))
    if (
        dataset.get("record_count") != 18
        or dataset.get("objective_order") != list(OBJECTIVES)
        or dataset.get("all_objectives_minimized") is not True
    ):
        raise RuntimeError("Unexpected canonical dataset structure")

    records = dataset.get("records", [])
    grouped = {source: [r for r in records if r.get("source") == source] for source in SOURCES}
    if any(len(rows) != 9 for rows in grouped.values()):
        raise RuntimeError("Expected exactly nine rows per source")
    if any(record.get("penalized") is not False for record in records):
        raise RuntimeError("Penalty row encountered")
    if any(
        not math.isfinite(float(record[objective]))
        for record in records
        for objective in OBJECTIVES
    ):
        raise RuntimeError("Nonfinite objective value encountered")

    summaries = [
        summarize(source, objective, grouped[source])
        for source in SOURCES
        for objective in OBJECTIVES
    ]
    summary_by_key = {(row["source"], row["objective"]): row for row in summaries}
    comparisons = []
    for objective in OBJECTIVES:
        h = summary_by_key[("HIST_R1_REEVAL", objective)]
        c = summary_by_key[("CORRECTED_R1", objective)]
        delta = c["median"] - h["median"]
        percent = 100.0 * delta / h["median"] if h["median"] != 0.0 else None
        comparisons.append(
            {
                "objective": objective,
                "unit": UNITS[objective],
                "median_H": h["median"],
                "median_C": c["median"],
                "delta_median_C_minus_H": delta,
                "delta_median_percent_C_minus_H": percent,
                "min_H": h["min"],
                "min_C": c["min"],
                "range_H": h["range"],
                "range_C": c["range"],
                "std_H": h["std"],
                "std_C": c["std"],
                "IQR_H": h["IQR"],
                "IQR_C": c["IQR"],
            }
        )

    checks = []
    for summary in summaries:
        independent = independent_core(grouped[summary["source"]], summary["objective"])
        checks.append(
            all(summary[field] == independent[field] for field in independent)
            and summary["range"] == summary["max"] - summary["min"]
            and summary["IQR"] == summary["q3"] - summary["q1"]
        )
    for comparison in comparisons:
        objective = comparison["objective"]
        h_core = independent_core(grouped["HIST_R1_REEVAL"], objective)
        c_core = independent_core(grouped["CORRECTED_R1"], objective)
        independent_delta = c_core["median"] - h_core["median"]
        independent_percent = 100.0 * independent_delta / h_core["median"]
        checks.append(
            comparison["delta_median_C_minus_H"] == independent_delta
            and comparison["delta_median_percent_C_minus_H"] == independent_percent
            and math.copysign(1.0, independent_percent) == math.copysign(1.0, independent_delta)
        )
    if not all(checks):
        raise RuntimeError("Independent QC failed")

    descriptive_fields = [
        "source", "objective", "unit", "direction", "n", "min", "min_solution_id",
        "max", "max_solution_id", "mean", "median", "std", "std_convention",
        "q1", "q3", "IQR", "quartile_convention", "range",
    ]
    comparison_fields = [
        "objective", "unit", "median_H", "median_C", "delta_median_C_minus_H",
        "delta_median_percent_C_minus_H", "min_H", "min_C", "range_H", "range_C",
        "std_H", "std_C", "IQR_H", "IQR_C",
    ]
    descriptive_path = here / DESCRIPTIVE_NAME
    comparison_path = here / COMPARISON_NAME
    result_path = here / RESULT_NAME
    audit_path = here / AUDIT_NAME
    write_csv(descriptive_path, summaries, descriptive_fields)
    write_csv(comparison_path, comparisons, comparison_fields)

    result = {
        "artifact_role": "CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_ANALYSIS",
        "cr1_comp_04_status": "CLOSED_PASS",
        "analysis_designation": "DESCRIPTIVE_SUMMARIES_OF_FINITE_SOLUTION_SETS",
        "baseline": {"head": BASELINE_HEAD, "input_baseline_check": "PASS"},
        "input": {
            "path": "06_manuscript/article_Q1/review/" + INPUT_NAME,
            "sha256": INPUT_SHA256,
            "sha256_check": "PASS",
            "D1_H_f2_f3_limitation": "VIGENTE",
        },
        "conventions": {
            "decision": "D013",
            "std": "POPULATION_DDOF_0",
            "std_formula": "sqrt(sum((x_i-mean(x))^2)/n)",
            "IQR": "HYNDMAN_FAN_TYPE_7",
            "quantile_formula": "h=1+(n-1)p; linear interpolation",
            "delta_median": "median_C-median_H",
            "delta_median_percent": "100*(median_C-median_H)/median_H",
            "percent_sign": "negative=C lower median; positive=C higher median",
            "objective_direction": "MINIMIZE_ALL_THREE",
            "objective_normalization": "NONE",
        },
        "summaries": summaries,
        "comparison": comparisons,
        "extrema": {
            source: {
                objective: {
                    "min_solution_ids": summary_by_key[(source, objective)]["min_solution_id"].split(";"),
                    "min_value": summary_by_key[(source, objective)]["min"],
                }
                for objective in OBJECTIVES
            }
            for source in SOURCES
        },
        "qc": {
            "H_rows": 9,
            "C_rows": 9,
            "objective_count": 3,
            "all_F_values_finite": True,
            "penalty_rows_included": False,
            "independent_qc": "PASS",
            "range_identity": "PASS",
            "IQR_identity": "PASS",
            "delta_percent_sign_identity": "PASS",
            "descriptive_csv_sha256": sha256(descriptive_path),
            "comparison_csv_sha256": sha256(comparison_path),
        },
        "limitations": [
            "Finite solution-set summaries only; points are not independent replicates.",
            "No superiority, Pareto improvement, significance, robustness, convergence, stochastic-performance, or causal claim.",
            "D1 documentary-recovery limitation remains applicable to H.f2/f3.",
        ],
        "not_computed": {
            "cr1_comp_05": True,
            "cross_dominance": True,
            "near_tie": True,
            "numeric_fragility": True,
            "coverage": True,
            "joint_sorting": True,
            "hypervolume": True,
            "figures": True,
            "hypothesis_tests": True,
        },
        "execution": {
            "MATLAB_executed": False,
            "objective_evaluations": 0,
            "replays": 0,
            "gamultiobj_executions": 0,
        },
    }
    result_path.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    output_hashes = {
        Path(__file__).name: sha256(Path(__file__)),
        DESCRIPTIVE_NAME: sha256(descriptive_path),
        COMPARISON_NAME: sha256(comparison_path),
        RESULT_NAME: sha256(result_path),
    }
    write_audit(audit_path, summaries, comparisons, grouped, output_hashes)


if __name__ == "__main__":
    main()
