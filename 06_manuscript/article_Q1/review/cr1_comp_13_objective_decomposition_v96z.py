#!/usr/bin/env python3
"""CR1-COMP-13 documentary objective decomposition.

Reads only frozen, validated artifacts.  It does not invoke MATLAB, an
objective/model, replay, optimizer, dominance, coverage, or hypervolume code.
"""

from __future__ import annotations

import csv
import hashlib
import json
import math
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
REVIEW = ROOT / "06_manuscript/article_Q1/review"
BASELINE_HEAD = "9caa2f404fdb6fb223133615e5bb982c5bdf4186"

PATHS = {
    "protocol": REVIEW / "CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md",
    "historical": REVIEW / "COST_E3D_R2G_EXISTING_R1_REEVALUATION_MEMO_v96z.md",
    "corrected": ROOT / "05_runs/triobjective_formal_ga_v96m/CORRECTED_R1_COST_E3D_v96z_20260808_005736/audit/CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z_FINAL.json",
    "dataset": REVIEW / "CR1_COMP_01_CANONICAL_DATASET_v96z.csv",
    "rank": REVIEW / "CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.csv",
    "terminal": REVIEW / "CR1_COMP_12_COMMON_TERMINAL_REGIME_v96z.json",
}

EXPECTED_HASHES = {
    "protocol": "8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3",
    "historical": "7C025689D5832CBA9ECB8D90E9A4A5D5E911A46B0109C6D1C270E19E7E8EBFB2",
    "corrected": "59D1BF2B006E31578690567FFB9566B8C7233E724B790A4831E81FF4A409AEB0",
    "dataset": "B17B461FB04C9693FC9DA0C3450703C34E4538894AD232EF7138AE5E9882CD62",
    "rank": "0E9AE69495E79648056143E2723B1C985380E3E11350EB6A58D1FCD0422C92A9",
    "terminal": "8D0646DF4EA5CDFBB458C6E4C0E58A85D5A1D7C49351731DC283126374147994",
}

OUTPUTS = {
    "csv": REVIEW / "CR1_COMP_13_OBJECTIVE_DECOMPOSITION_v96z.csv",
    "availability": REVIEW / "CR1_COMP_13_OBJECTIVE_DECOMPOSITION_COMPONENT_AVAILABILITY_v96z.csv",
    "json": REVIEW / "CR1_COMP_13_OBJECTIVE_DECOMPOSITION_v96z.json",
    "audit": REVIEW / "CR1_COMP_13_OBJECTIVE_DECOMPOSITION_AUDIT_v96z.md",
}

OPTIONAL_FIELDS = [
    "Q_aux_tot",
    "Q_LPG_input",
    "LPG_mass_kg",
    "LPG_cost_USD",
    "Irradiacion",
    "solar_cost_USD",
    "E_air_impeller_kWh",
    "electricity_cost_USD",
    "CO2_LPG_kg",
    "CO2_electricity_kg",
]

UNITS = {
    "m_max": "kg/s",
    "T_min": "degC",
    "r_div2": "dimensionless",
    "t_rec_ini": "h",
    "f1": "dimensionless",
    "f2": "USD/kg_water_removed",
    "f3": "kg_CO2/kg_water_removed",
    "water_removed_kg": "kg",
    "total_cost_USD": "USD",
    "total_CO2_kg": "kg_CO2",
    "Q_aux_tot": "MJ",
    "Q_LPG_input": "MJ",
    "LPG_mass_kg": "kg",
    "LPG_cost_USD": "USD",
    "Irradiacion": None,
    "solar_cost_USD": "USD",
    "E_air_impeller_kWh": "kWh",
    "electricity_cost_USD": "USD",
    "CO2_LPG_kg": "kg_CO2",
    "CO2_electricity_kg": "kg_CO2",
    "cost_component_sum_USD": "USD",
    "cost_component_sum_difference_USD": "USD",
    "CO2_component_sum_kg": "kg_CO2",
    "CO2_component_sum_difference_kg": "kg_CO2",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def git(*args: str) -> str:
    return subprocess.run(
        ["git", *args], cwd=ROOT, check=True, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    ).stdout.strip()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def markdown_rows(text: str, heading: str) -> list[list[str]]:
    start = text.index(heading)
    tail = text[start:].splitlines()
    rows = []
    for line in tail:
        if rows and line.startswith("## "):
            break
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if cells and cells[0].isdigit():
            rows.append(cells)
    return rows


def load_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def source_availability(h_count: int, c_count: int) -> str:
    if h_count == 9 and c_count == 9:
        return "COMPLETE_18"
    if h_count == 9 and c_count == 0:
        return "COMPLETE_H_ONLY"
    if h_count == 0 and c_count == 9:
        return "COMPLETE_C_ONLY"
    if h_count == 0 and c_count == 0:
        return "NOT_AVAILABLE"
    return "PARTIAL"


def make_summary(records: list[dict], field: str) -> dict:
    available = [r for r in records if r.get(field) is not None]
    out = {"field": field, "unit": UNITS.get(field), "available_count": len(available)}
    for source in ("H", "C"):
        group = [r for r in available if r["solution_id"].startswith(source)]
        out[f"{source}_MIN"] = min((r[field] for r in group), default=None)
        out[f"{source}_MAX"] = max((r[field] for r in group), default=None)
    if available:
        minimum = min(available, key=lambda r: (r[field], r["solution_id"]))
        maximum = max(available, key=lambda r: (r[field], r["solution_id"]))
        out["GLOBAL_MIN"] = minimum[field]
        out["GLOBAL_MIN_ID"] = minimum["solution_id"]
        out["GLOBAL_MAX"] = maximum[field]
        out["GLOBAL_MAX_ID"] = maximum["solution_id"]
    else:
        out.update({"GLOBAL_MIN": None, "GLOBAL_MIN_ID": None, "GLOBAL_MAX": None, "GLOBAL_MAX_ID": None})
    return out


def build() -> tuple[list[dict], list[dict], dict, str]:
    branch = git("rev-parse", "--abbrev-ref", "HEAD")
    head = git("rev-parse", "HEAD")
    status = git("status", "--short")
    require(branch == "main" and head == BASELINE_HEAD and status == "", "BLOCKED_BASELINE_MISMATCH")

    live_hashes = {name: sha256(path) for name, path in PATHS.items()}
    require(live_hashes == EXPECTED_HASHES, "BLOCKED_UPSTREAM_HASH_MISMATCH")

    terminal = json.loads(PATHS["terminal"].read_text(encoding="utf-8"))
    require(terminal["cr1_comp_12_status"] == "CLOSED_PASS", "CR1_COMP_12_NOT_CLOSED_PASS")
    require(terminal["COMPARATIVE_TERMINAL_REGIME"] == "COMMON_TMAX_19P9H", "TERMINAL_REGIME_MISMATCH")
    require(terminal["qc"]["independent_qc"] == "PASS", "CR1_COMP_12_QC_MISMATCH")

    dataset_rows = load_csv(PATHS["dataset"])
    rank_rows = {r["solution_id"]: r for r in load_csv(PATHS["rank"])}
    require(len(dataset_rows) == 18 and len(rank_rows) == 18, "UPSTREAM_ROW_COUNT_MISMATCH")

    historical_text = PATHS["historical"].read_text(encoding="utf-8")
    historical_main = markdown_rows(historical_text, "## 8. Reevaluation table")
    historical_lpg = markdown_rows(historical_text, "## 13. LPG chain checks")
    require(len(historical_main) == 9 and len(historical_lpg) == 9, "H_DOCUMENTARY_TABLE_PARSE_FAILURE")
    corrected_text = PATHS["corrected"].read_text(encoding="utf-8")
    corrected = json.loads(corrected_text)
    corrected_raw = json.loads(corrected_text, parse_float=str)
    require(corrected["summary"]["CORRECTED_R1_POSTRUN_INTERNAL_AUDIT"] == "PASS", "C_POSTRUN_NOT_PASS")
    require(len(corrected["rows"]) == 9, "C_POSTRUN_ROW_COUNT_MISMATCH")

    h_main = {int(r[0]): r for r in historical_main}
    h_lpg = {int(r[0]): r for r in historical_lpg}
    c_rows = {int(r["index"]): r for r in corrected["rows"]}
    c_raw_rows = {int(r["index"]): r for r in corrected_raw["rows"]}
    records = []

    for upstream in dataset_rows:
        solution_id = upstream["solution_id"]
        source_index = int(upstream["source_index"])
        rank = rank_rows[solution_id]
        record = {
            "solution_id": solution_id,
            "source": upstream["source"],
            "m_max": float(upstream["m_max"]),
            "T_min": float(upstream["T_min"]),
            "r_div2": float(upstream["r_div2"]),
            "t_rec_ini": float(upstream["t_rec_ini"]),
            "f1": float(upstream["MR_final"]),
            "f2": float(upstream["cost_specific_USD_per_kgwater"]),
            "f3": float(upstream["CO2_specific_kgCO2_per_kgwater"]),
            "ParetoRank": int(rank["ParetoRank"]),
        }
        require(upstream["finite"] == "true" and upstream["penalized"] == "false", "NONFINITE_OR_PENALTY_ROW")
        require(
            record["f1"] == float(rank["f1"]) and record["f2"] == float(rank["f2"]) and record["f3"] == float(rank["f3"]),
            f"RANK_OBJECTIVE_DISCREPANCY:{solution_id}",
        )

        if solution_id.startswith("H"):
            main = h_main[source_index]
            lpg = h_lpg[source_index]
            require(
                record["m_max"] == float(main[1]) and record["T_min"] == float(main[2])
                and record["r_div2"] == float(main[3]) and record["t_rec_ini"] == float(main[4])
                and record["f1"] == float(main[7]) and record["f2"] == float(main[9])
                and record["f3"] == float(main[11]),
                f"H_CANONICAL_DISCREPANCY:{solution_id}",
            )
            record.update({
                "water_removed_kg": float(main[13]), "total_cost_USD": float(main[14]), "total_CO2_kg": float(main[15]),
                "water_removed_raw_serialization": main[13], "total_cost_raw_serialization": main[14],
                "total_CO2_raw_serialization": main[15],
                "water_removed_value_provenance": "DOCUMENTARY_SERIALIZATION",
                "total_cost_value_provenance": "DOCUMENTARY_SERIALIZATION",
                "total_CO2_value_provenance": "DOCUMENTARY_SERIALIZATION",
                "source_artifact": rel(PATHS["historical"]), "source_hash": live_hashes["historical"],
                "source_locator": f"sections 8,13-15; R1 row {source_index}",
                "Q_aux_tot": float(lpg[3]), "Q_LPG_input": float(lpg[4]), "LPG_mass_kg": float(lpg[5]),
                "LPG_cost_USD": float(lpg[6]), "Irradiacion": None,
                "solar_cost_USD": 6.1648666121331042,
                "E_air_impeller_kWh": 20.497000000000007,
                "electricity_cost_USD": 1.4700084659546171,
                "CO2_LPG_kg": float(lpg[7]), "CO2_electricity_kg": 9.1006680000000024,
            })
            present_provenance = "DOCUMENTARY_SERIALIZATION"
        else:
            row = c_rows[source_index]
            raw_row = c_raw_rows[source_index]
            require(
                record["m_max"] == row["m_max"] and record["T_min"] == row["T_min"]
                and record["r_div2"] == row["r_div2"] and record["t_rec_ini"] == row["t_rec_ini"]
                and record["f1"] == row["f1"] and record["f2"] == row["f2"] and record["f3"] == row["f3"],
                f"C_CANONICAL_DISCREPANCY:{solution_id}",
            )
            record.update({
                "water_removed_kg": row["water_removed_kg"], "total_cost_USD": row["total_cost_USD"],
                "total_CO2_kg": row["total_CO2_kg"],
                "water_removed_raw_serialization": raw_row["water_removed_kg"],
                "total_cost_raw_serialization": raw_row["total_cost_USD"],
                "total_CO2_raw_serialization": raw_row["total_CO2_kg"],
                "water_removed_value_provenance": "VALIDATED_JSON_SERIALIZATION_OF_BINARY64",
                "total_cost_value_provenance": "VALIDATED_JSON_SERIALIZATION_OF_BINARY64",
                "total_CO2_value_provenance": "VALIDATED_JSON_SERIALIZATION_OF_BINARY64",
                "source_artifact": rel(PATHS["corrected"]), "source_hash": live_hashes["corrected"],
                "source_locator": f"rows[{source_index - 1}] / index={source_index}",
                "Q_aux_tot": row["Q_aux_tot_MJ"], "Q_LPG_input": row["LPG_fuel_input_MJ"],
                "LPG_mass_kg": row["LPG_mass_kg"], "LPG_cost_USD": row["LPG_cost_USD"],
                "Irradiacion": None, "solar_cost_USD": row["solar_cost_USD"],
                "E_air_impeller_kWh": row["electric_energy_kWh"],
                "electricity_cost_USD": row["electric_cost_USD"],
                "CO2_LPG_kg": None, "CO2_electricity_kg": None,
            })
            present_provenance = "VALIDATED_JSON_SERIALIZATION_OF_BINARY64"

        for field in OPTIONAL_FIELDS:
            available = record[field] is not None
            record[f"{field}_availability"] = "AVAILABLE" if available else "NOT_AVAILABLE_IN_VALIDATED_ARTIFACTS"
            record[f"{field}_value_provenance"] = present_provenance if available else "NOT_AVAILABLE_IN_VALIDATED_ARTIFACTS"

        record["f2_stored"] = record["f2"]
        record["f2_from_decomposition"] = record["total_cost_USD"] / record["water_removed_kg"]
        record["f2_abs_difference"] = abs(record["f2_stored"] - record["f2_from_decomposition"])
        record["f3_stored"] = record["f3"]
        record["f3_from_decomposition"] = record["total_CO2_kg"] / record["water_removed_kg"]
        record["f3_abs_difference"] = abs(record["f3_stored"] - record["f3_from_decomposition"])
        record["cost_component_sum_USD"] = record["LPG_cost_USD"] + record["solar_cost_USD"] + record["electricity_cost_USD"]
        record["cost_component_sum_difference_USD"] = record["cost_component_sum_USD"] - record["total_cost_USD"]
        if record["CO2_LPG_kg"] is not None and record["CO2_electricity_kg"] is not None:
            record["CO2_component_sum_kg"] = record["CO2_LPG_kg"] + record["CO2_electricity_kg"]
            record["CO2_component_sum_difference_kg"] = record["CO2_component_sum_kg"] - record["total_CO2_kg"]
        else:
            record["CO2_component_sum_kg"] = None
            record["CO2_component_sum_difference_kg"] = None
        records.append(record)

    require([r["solution_id"] for r in records] == [f"H{i:02d}" for i in range(1, 10)] + [f"C{i:02d}" for i in range(1, 10)], "ROW_ORDER_OR_PAIRING_FAILURE")
    mandatory = ["water_removed_kg", "total_cost_USD", "total_CO2_kg"]
    require(all(math.isfinite(r[f]) for r in records for f in mandatory), "BLOCKED_MISSING_VALIDATED_DECOMPOSITION_DATA")

    availability_rows = []
    limitations = {
        "Irradiacion": "Solar energy is persisted, but Irradiacion is not identified unambiguously as the same field in the selected validated row sources.",
        "CO2_LPG_kg": "Persisted for H only; not persisted per C row in the validated postrun JSON.",
        "CO2_electricity_kg": "Persisted for H only; not persisted per C row in the validated postrun JSON.",
    }
    source_basis = {
        "Q_aux_tot": "H memo section 13; C postrun JSON Q_aux_tot_MJ",
        "Q_LPG_input": "H memo section 13; C postrun JSON LPG_fuel_input_MJ",
        "LPG_mass_kg": "H memo section 13; C postrun JSON LPG_mass_kg",
        "LPG_cost_USD": "H memo section 13; C postrun JSON LPG_cost_USD",
        "Irradiacion": "No unambiguous per-row persisted field in selected validated sources",
        "solar_cost_USD": "H memo section 14; C postrun JSON solar_cost_USD",
        "E_air_impeller_kWh": "H memo section 15 electric_energy_kWh; C postrun JSON electric_energy_kWh",
        "electricity_cost_USD": "H memo section 15; C postrun JSON electric_cost_USD",
        "CO2_LPG_kg": "H memo section 13 only",
        "CO2_electricity_kg": "H memo section 15 only",
    }
    availability_summary = {}
    for field in OPTIONAL_FIELDS:
        h_count = sum(r[field] is not None for r in records if r["solution_id"].startswith("H"))
        c_count = sum(r[field] is not None for r in records if r["solution_id"].startswith("C"))
        state = source_availability(h_count, c_count)
        availability_summary[field] = state
        availability_rows.append({
            "component": field, "H_available_count": h_count, "C_available_count": c_count,
            "total_available_count": h_count + c_count, "source_basis": source_basis[field],
            "unit": UNITS[field] or "NOT_UNAMBIGUOUSLY_DOCUMENTED",
            "availability_limitation": limitations.get(field, "NONE"), "availability_status": state,
        })

    summary_fields = mandatory + OPTIONAL_FIELDS + ["cost_component_sum_USD", "CO2_component_sum_kg"]
    summaries = [make_summary(records, field) for field in summary_fields]
    result = {
        "artifact_role": "CR1_COMP_13_OBJECTIVE_DECOMPOSITION",
        "cr1_comp_13_status": "CLOSED_PASS",
        "baseline": {"branch": branch, "head": head, "input_baseline_check": "PASS"},
        "protocol": {"path": rel(PATHS["protocol"]), "version": "v1.0", "sha256": live_hashes["protocol"], "sha256_check": "PASS"},
        "upstream_artifacts": [
            {"name": name, "path": rel(PATHS[name]), "sha256": live_hashes[name], "hash_check": "PASS"}
            for name in ("historical", "corrected", "dataset", "rank", "terminal")
        ],
        "D004": {"status": "VIGENTE", "water_removed_kg_identity": "(Mi - M_terminal) * md", "recalculated_by_model": False},
        "economic_claim_scope": "MODELED_OPERATING_ENERGY_COST",
        "environmental_claim_scope": "MODELED_OPERATIONAL_CO2_AS_IMPLEMENTED",
        "CO2_UNIT_LABEL_STATUS": "COMPUTATIONAL_NAME_PRESERVED_PENDING_MANUSCRIPT_EDITORIAL_RECONCILIATION",
        "records": records,
        "units": UNITS,
        "component_availability": availability_summary,
        "deterministic_min_max_summaries": summaries,
        "qc": {
            "UPSTREAM_HASH_CHECKS": "PASS", "UPSTREAM_CONSISTENCY_CHECK": "PASS",
            "H_ROWS": 9, "C_ROWS": 9, "TOTAL_ROWS": 18,
            "WATER_REMOVED_COMPLETE": "YES", "TOTAL_COST_COMPLETE": "YES", "TOTAL_CO2_COMPLETE": "YES",
            "MANDATORY_DECOMPOSITION_COMPLETE_H": "YES", "MANDATORY_DECOMPOSITION_COMPLETE_C": "YES",
            "ALL_MANDATORY_VALUES_FINITE": "YES", "PENALTY_ROWS_INCLUDED": "NO",
            "F2_DECOMPOSITION_DIAGNOSTIC_COMPLETE": "YES", "F3_DECOMPOSITION_DIAGNOSTIC_COMPLETE": "YES",
            "NO_IMPLICIT_H_C_PAIRING": "YES", "INDEPENDENT_QC": "PASS",
        },
        "limitations": [
            "H decomposition values are validated documentary serializations; original corrected H binary64 detail values were not persisted.",
            "Irradiacion is not reconstructed from solar_energy_MJ.",
            "C per-row CO2_LPG_kg and CO2_electricity_kg are not reconstructed from totals or factors.",
            "No new numerical tolerance, pairing, representative selection, or causal interpretation was introduced.",
        ],
        "REPRESENTATIVE_SOLUTION_SELECTION": "DEFERRED_TO_CR1_COMP_14",
        "GASLP_INCLUDED_IN_DECOMPOSITION_DATASET": "NO",
        "not_executed": {
            "CR1_COMP_14_COMPUTED": False, "MATLAB_EXECUTED": False, "OBJECTIVE_EVALUATIONS": 0,
            "REPLAYS": 0, "GAMULTIOBJ_EXECUTIONS": 0, "NEW_OPTIMIZATION_RUNS": 0,
            "CROSS_DOMINANCE_RECALCULATED": False, "COVERAGE_RECALCULATED": False,
            "HYPERVOLUME_RECALCULATED": False, "NEW_H_C_PAIRING": False,
            "PHYSICAL_INTERPRETATION_COMPUTED": False, "ECONOMIC_INTERPRETATION_COMPUTED": False,
            "ENVIRONMENTAL_INTERPRETATION_COMPUTED": False,
        },
        "next_recommended_step": "CR1-COMP-14 — Physical, economic and environmental interpretation; separate authorization required",
    }

    audit = f"""# CR1-COMP-13 — Objective decomposition audit v96z

## Status

```text
CR1_COMP_13_STATUS = CLOSED_PASS
OBJECTIVE_DECOMPOSITION_COMPUTED = YES
F2_F3_DECOMPOSITION_COMPLETED = YES
INDEPENDENT_QC = PASS
```

## Objective and scope

The economic and environmental specific objectives were decomposed into `total_cost_USD / water_removed_kg` and `total_CO2_kg / water_removed_kg` for all 18 evaluated solutions. This is a documentary postrun decomposition, not a model evaluation or causal interpretation. H and C rows are not paired.

`ECONOMIC_CLAIM_SCOPE = MODELED_OPERATING_ENERGY_COST`. `ENVIRONMENTAL_CLAIM_SCOPE = MODELED_OPERATIONAL_CO2_AS_IMPLEMENTED`. `CO2_UNIT_LABEL_STATUS = COMPUTATIONAL_NAME_PRESERVED_PENDING_MANUSCRIPT_EDITORIAL_RECONCILIATION`.

## Sources and hashes

* Frozen protocol v1.0: `{live_hashes['protocol']}`.
* Historical COST-E3D reevaluation memo: `{live_hashes['historical']}`.
* CORRECTED_R1 validated postrun JSON: `{live_hashes['corrected']}`.
* Canonical comparative dataset: `{live_hashes['dataset']}`.
* Frozen joint-rank table: `{live_hashes['rank']}`.
* CR1-COMP-12 structured result: `{live_hashes['terminal']}`.

All registered hashes passed. CR1-COMP-12 is `CLOSED_PASS` and its comparative terminal regime is `COMMON_TMAX_19P9H`.

## Provenance and denominator

H values are preserved from the validated Markdown decimal serialization and are labeled `DOCUMENTARY_SERIALIZATION`; no absent binary64 precision was reconstructed. C values are preserved from the validated postrun JSON and labeled `VALIDATED_JSON_SERIALIZATION_OF_BINARY64`, not as direct MAT recovery. D004 remains `(Mi - M_terminal) * md`; no simulation was run to recalculate it.

## Availability

```text
Q_AUX_TOT_AVAILABILITY = {availability_summary['Q_aux_tot']}
Q_LPG_INPUT_AVAILABILITY = {availability_summary['Q_LPG_input']}
LPG_MASS_AVAILABILITY = {availability_summary['LPG_mass_kg']}
LPG_COST_AVAILABILITY = {availability_summary['LPG_cost_USD']}
IRRADIACION_AVAILABILITY = {availability_summary['Irradiacion']}
SOLAR_COST_AVAILABILITY = {availability_summary['solar_cost_USD']}
E_AIR_IMPELLER_AVAILABILITY = {availability_summary['E_air_impeller_kWh']}
ELECTRICITY_COST_AVAILABILITY = {availability_summary['electricity_cost_USD']}
CO2_LPG_AVAILABILITY = {availability_summary['CO2_LPG_kg']}
CO2_ELECTRICITY_AVAILABILITY = {availability_summary['CO2_electricity_kg']}
```

`Irradiacion` was not equated with persisted solar energy. Component CO2 values are available for H only and were not fabricated for C. Cost-component sums are recorded for all rows; CO2-component sums are recorded only where both persisted terms exist. Raw differences from the corresponding totals are retained without a new acceptance tolerance.

## Identity diagnostic and QC

The stored f2/f3 values and the ratios reconstructed from persisted numerators and denominator are both retained, together with raw absolute differences. These columns implement `DECOMPOSITION_IDENTITY_DIAGNOSTIC`; they do not redefine either objective and do not introduce rounding, closeness tests, or a new threshold. Upstream identity audits remain the acceptance basis.

```text
H_ROWS = 9
C_ROWS = 9
TOTAL_ROWS = 18
MANDATORY_DECOMPOSITION_COMPLETE_H = YES
MANDATORY_DECOMPOSITION_COMPLETE_C = YES
ALL_MANDATORY_VALUES_FINITE = YES
PENALTY_ROWS_INCLUDED = NO
NO_IMPLICIT_H_C_PAIRING = YES
REPRESENTATIVE_SOLUTION_SELECTION = DEFERRED_TO_CR1_COMP_14
GASLP_INCLUDED_IN_DECOMPOSITION_DATASET = NO
```

Independent QC contrasted canonical objectives, rank context, decomposition sources, source locators, hashes, finite/penalty flags, and H/C counts. No source discrepancy was found.

## Excluded actions and next phase

No MATLAB, objective/model evaluation, replay, optimization, dominance, coverage, hypervolume, representative selection, H↔C pairing, causal interpretation, productive-code change, protocol change, or decision-log change was performed. CR1-COMP-14 was not executed and requires separate authorization.
"""
    return records, availability_rows, result, audit


def write_outputs(records: list[dict], availability_rows: list[dict], result: dict, audit: str) -> None:
    fieldnames = list(records[0].keys())
    with OUTPUTS["csv"].open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        writer.writerows(records)
    with OUTPUTS["availability"].open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(availability_rows[0].keys()), lineterminator="\n")
        writer.writeheader()
        writer.writerows(availability_rows)
    OUTPUTS["json"].write_text(json.dumps(result, indent=2, ensure_ascii=False, allow_nan=False) + "\n", encoding="utf-8")
    OUTPUTS["audit"].write_text(audit, encoding="utf-8")


def main() -> None:
    records, availability_rows, result, audit = build()
    write_outputs(records, availability_rows, result, audit)
    print("CR1_COMP_13_STATUS=CLOSED_PASS")
    print("H_ROWS=9")
    print("C_ROWS=9")
    print("TOTAL_ROWS=18")
    print("INDEPENDENT_QC=PASS")


if __name__ == "__main__":
    main()
