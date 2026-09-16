"""Persisted-output-only PE07 postrun. Never calls MATLAB, model or objective."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path
import tempfile

CAMPAIGN_ID = "ROR_PE07_CONTROLLED_SENSITIVITY_V01"
CORRECTED_POSTRUN_NAME = "POSTRUN_CORRECTED_V02"
RESPONSES = ("W", "LPG_fuel_input_MJ")


class Blocked(ValueError):
    pass


def sha256(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest().upper()


def read_json(path: Path):
    if not path.is_file():
        raise Blocked(f"Missing required artifact: {path.name}")
    with path.open("r", encoding="utf-8") as stream:
        return json.load(stream)


def write_json_once(path: Path, value) -> None:
    if path.exists():
        raise Blocked(f"Overwrite prohibited: {path}")
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent,
                                     delete=False, suffix=".tmp") as stream:
        json.dump(value, stream, indent=2, sort_keys=True, allow_nan=False)
        stream.write("\n")
        temp = Path(stream.name)
    temp.replace(path)


def write_csv_once(path: Path, rows: list[dict]) -> None:
    if path.exists():
        raise Blocked(f"Overwrite prohibited: {path}")
    fields = list(rows[0]) if rows else ["status"]
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="",
                                     dir=path.parent, delete=False,
                                     suffix=".tmp") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        if rows:
            writer.writerows(rows)
        temp = Path(stream.name)
    temp.replace(path)


def sign(value: float) -> str:
    if value > 0:
        return "POSITIVE_MODEL_RESPONSE"
    if value < 0:
        return "NEGATIVE_MODEL_RESPONSE"
    return "ZERO_MODEL_RESPONSE"


def valid_record(record: dict) -> bool:
    return (not record.get("invalid", True)
            and record.get("eligible_for_finite_difference", False))


def central_rows(config: dict, records: list[dict]) -> list[dict]:
    by_id = {row["condition_id"]: row for row in records}
    conditions = config["conditions"]
    lookup = {(c["anchor_id"], c["variable"], c["magnitude"], c["direction"]): c
              for c in conditions if c["evaluate"]}
    variables = {v["name"]: v for v in config["variables"]}
    rows: list[dict] = []
    for anchor in config["anchors"]:
        for variable in config["variables"]:
            for magnitude in ("small", "large"):
                key = (anchor["anchor_id"], variable["name"], magnitude)
                minus_c = lookup.get((*key, "minus"))
                plus_c = lookup.get((*key, "plus"))
                if minus_c is None or plus_c is None:
                    continue
                minus = by_id.get(minus_c["condition_id"])
                plus = by_id.get(plus_c["condition_id"])
                if minus is None or plus is None or not valid_record(minus) or not valid_record(plus):
                    continue
                delta = variables[variable["name"]][f"delta_{magnitude}"]
                row = {"anchor_id": anchor["anchor_id"], "context": anchor["context"],
                       "variable": variable["name"], "magnitude": magnitude,
                       "delta": delta, "minus_condition_id": minus["condition_id"],
                       "plus_condition_id": plus["condition_id"]}
                for response in RESPONSES:
                    change = (plus["responses"][response]
                              - minus["responses"][response])
                    row[f"central_delta_{response}"] = change
                    row[f"central_secant_{response}"] = change / (2.0 * delta)
                    row[f"sign_{response}"] = sign(change)
                rows.append(row)
    return rows


def magnitude_rows(central: list[dict], config: dict) -> list[dict]:
    index = {(r["anchor_id"], r["variable"], r["magnitude"]): r for r in central}
    rows = []
    for anchor in config["anchors"]:
        for variable in config["variables"]:
            for response in RESPONSES:
                small = index.get((anchor["anchor_id"], variable["name"], "small"))
                large = index.get((anchor["anchor_id"], variable["name"], "large"))
                small_sign = small.get(f"sign_{response}") if small else "NOT_EVALUABLE"
                large_sign = large.get(f"sign_{response}") if large else "NOT_EVALUABLE"
                consistent = (small_sign == large_sign
                              and small_sign not in ("NOT_EVALUABLE", "ZERO_MODEL_RESPONSE"))
                opposite = ({small_sign, large_sign}
                            == {"POSITIVE_MODEL_RESPONSE", "NEGATIVE_MODEL_RESPONSE"})
                if "NOT_EVALUABLE" in (small_sign, large_sign):
                    magnitude_class = "MAGNITUDE_COMPARISON_NOT_EVALUABLE"
                elif consistent:
                    magnitude_class = "MAGNITUDE_DIRECTION_CONSISTENT"
                else:
                    magnitude_class = "ZERO_OR_MIXED_MAGNITUDE_RESPONSE"
                rows.append({"anchor_id": anchor["anchor_id"],
                             "variable": variable["name"], "response": response,
                             "small_sign": small_sign, "large_sign": large_sign,
                             "magnitude_class": magnitude_class,
                             "local_magnitude_nonmonotonicity": opposite})
    return rows


def recurrence_class(signs_by_magnitude: dict[str, list[str]]) -> tuple[str, bool]:
    evaluable = []
    for values in signs_by_magnitude.values():
        evaluable.extend(s for s in values if s != "ZERO_MODEL_RESPONSE")
        if len(values) == 3 and len(set(values)) == 1 and values[0] != "ZERO_MODEL_RESPONSE":
            return "STRONG_LOCAL_MODEL_RECURRENCE", False
    nonzero = set(evaluable)
    if len(nonzero) > 1:
        return "CONTEXT_DEPENDENT_MODEL_RESPONSE", True
    for values in signs_by_magnitude.values():
        nonzero_values = [s for s in values if s != "ZERO_MODEL_RESPONSE"]
        if len(nonzero_values) >= 2 and len(set(nonzero_values)) == 1:
            return "PARTIAL_LOCAL_MODEL_RECURRENCE", False
    return "INSUFFICIENT_DOMAIN_SUPPORT", False


def recurrence_rows(central: list[dict], config: dict) -> list[dict]:
    rows = []
    for variable in config["variables"]:
        for response in RESPONSES:
            values = {m: [r[f"sign_{response}"] for r in central
                          if r["variable"] == variable["name"] and r["magnitude"] == m]
                      for m in ("small", "large")}
            recurrence, context_change = recurrence_class(values)
            level = {"STRONG_LOCAL_MODEL_RECURRENCE": "PE07_LEVEL_A",
                     "PARTIAL_LOCAL_MODEL_RECURRENCE": "PE07_LEVEL_B",
                     "CONTEXT_DEPENDENT_MODEL_RESPONSE": "PE07_LEVEL_C",
                     "INSUFFICIENT_DOMAIN_SUPPORT": "PE07_LEVEL_D"}[recurrence]
            observational = config["pe06_observational_context"]["directions"].get(
                variable["name"], "UNRESOLVED")
            if observational not in ("POSITIVE", "NEGATIVE"):
                comparison = "OBSERVATIONAL_RESULT_TOO_AMBIGUOUS_FOR_DIRECTIONAL_COMPARISON"
            elif recurrence == "CONTEXT_DEPENDENT_MODEL_RESPONSE":
                comparison = "CONTROLLED_RESPONSE_CONTEXT_DEPENDENT"
            else:
                expected_sign = f"{observational}_MODEL_RESPONSE"
                controlled_signs = [s for magnitude in values.values() for s in magnitude]
                comparison = (
                    "OBSERVATIONAL_AND_CONTROLLED_DIRECTION_CONSISTENT"
                    if recurrence in ("STRONG_LOCAL_MODEL_RECURRENCE",
                                      "PARTIAL_LOCAL_MODEL_RECURRENCE")
                    and controlled_signs
                    and all(s == expected_sign for s in controlled_signs)
                    else "OBSERVATIONAL_ASSOCIATION_NOT_REPRODUCED_LOCALLY")
            rows.append({"variable": variable["name"], "response": response,
                         "small_signs": values["small"], "large_signs": values["large"],
                         "recurrence_class": recurrence,
                         "cross_context_direction_change": context_change,
                         "pe06_comparison_class": comparison,
                         "evidence_level": level})
    return rows


def anchor_relative_rows(config: dict, records: list[dict],
                         baseline_records: list[dict]) -> list[dict]:
    baselines = {row["anchor_id"]: row for row in baseline_records}
    conditions = {row["condition_id"]: row for row in config["conditions"]}
    variables = {row["name"]: row for row in config["variables"]}
    rows = []
    for record in records:
        condition = conditions.get(record["condition_id"])
        if condition is None or not condition.get("evaluate", False):
            raise Blocked("Perturbation record does not map to an executable condition")
        baseline = baselines.get(record["anchor_id"])
        if baseline is None:
            raise Blocked("Perturbation record does not map to a baseline anchor")
        variable = variables[condition["variable"]]
        index = variable["index"] - 1
        rows.append({
            "condition_id": record["condition_id"],
            "anchor": record["anchor_id"],
            "control": condition["variable"],
            "magnitude": condition["magnitude"],
            "direction": condition["direction"],
            "Delta_X": record["x"][index] - baseline["x"][index],
            "Delta_W": record["responses"]["W"] - baseline["responses"]["W"],
            "Delta_LPG": (record["responses"]["LPG_fuel_input_MJ"]
                          - baseline["responses"]["LPG_fuel_input_MJ"]),
            "Delta_MR": record["responses"]["MR"] - baseline["responses"]["MR"],
            "Delta_f1": record["responses"]["f1"] - baseline["responses"]["f1"],
            "Delta_f2": record["responses"]["f2"] - baseline["responses"]["f2"],
            "Delta_f3": record["responses"]["f3"] - baseline["responses"]["f3"],
            "validity": "VALID" if valid_record(record) else "INVALID",
            "status": record.get("status", ""),
            "execution_status": record.get("execution_status", ""),
        })
    if len(rows) != 47 or len({row["condition_id"] for row in rows}) != 47:
        raise Blocked("Anchor-relative table count/identity mismatch")
    return rows


def analyze_payload(config: dict, perturbation: dict, invalid: object,
                    baseline: dict) -> dict:
    if config.get("campaign_id") != CAMPAIGN_ID or config.get("design_version") != "v1.1":
        raise Blocked("Wrong PE07 configuration identity")
    if perturbation.get("status") != "COMPLETED" or perturbation.get("evaluation_count") != 47:
        raise Blocked("Perturbation execution is not complete")
    records = perturbation.get("records", [])
    if len(records) != 47 or len({r["condition_id"] for r in records}) != 47:
        raise Blocked("Perturbation result count/identity mismatch")
    central = central_rows(config, records)
    magnitude = magnitude_rows(central, config)
    recurrence = recurrence_rows(central, config)
    baseline_records = baseline.get("records", [])
    if (baseline.get("status") != "BASELINE_REPLAY_PASS"
            or baseline.get("pass_count") != 3
            or len(baseline_records) != 3):
        raise Blocked("Baseline replay audit is not exact 3/3 PASS")
    anchor_relative = anchor_relative_rows(config, records, baseline_records)
    invalid_rows = invalid if isinstance(invalid, list) else [invalid]
    report = {
        "status": "PASS",
        "campaign_id": CAMPAIGN_ID,
        "design_version": "v1.1",
        "finite_difference_row_count": len(central),
        "anchor_relative_row_count": len(anchor_relative),
        "invalid_inventory_count": len(invalid_rows),
        "magnitude_consistency": magnitude,
        "recurrence": recurrence,
        "model_or_objective_calls": 0,
        "causal_claim": "NOT_MADE",
        "primary_sufficiency": "FAIL",
        "primary_n_pool_modified": "NO",
    }
    return {"central": central, "anchor_relative": anchor_relative,
            "report": report,
            "domain": {"status": "PASS", "invalid_points": invalid_rows,
                       "invalid_excluded_from_finite_differences": True,
                       "replacement_points": 0, "clipping": "NOT_USED"}}


def analyze_run(run_root: Path) -> dict:
    run_root = run_root.resolve()
    if run_root.name != CAMPAIGN_ID:
        raise Blocked("Wrong campaign root")
    status = read_json(run_root / "EXECUTION_STATUS.json")
    if status.get("status") != "COMPLETED_PENDING_POSTRUN":
        raise Blocked("Execution is not ready for postrun")
    config = read_json(run_root / "FROZEN_PE07_CONFIG.json")
    baseline = read_json(run_root / "BASELINE_REPLAY_AUDIT.json")
    perturbation = read_json(run_root / "PERTURBATION_RESULTS.json")
    invalid = read_json(run_root / "INVALID_POINT_INVENTORY.json")
    analysis = analyze_payload(config, perturbation, invalid, baseline)
    analysis["report"].update({
        "postrun_version": CORRECTED_POSTRUN_NAME,
        "upstream_execution_root": str(run_root),
        "upstream_execution_hash_identity": sha256(
            run_root / "SHA256_MANIFEST_EXECUTION.json"),
        "postrun_implementation_sha256": sha256(Path(__file__).resolve()),
        "repair_source_lock_sha256": sha256(
            Path(__file__).with_name("pe07_execution_source_lock.json")),
        "supersedes_derived_postrun": "postrun",
        "execution_primary_superseded": "NO",
    })
    return analysis


def publish(run_root: Path, analysis: dict) -> None:
    postrun = run_root / CORRECTED_POSTRUN_NAME
    if postrun.exists():
        raise Blocked("Postrun directory exists; overwrite prohibited")
    postrun.mkdir(parents=False, exist_ok=False)
    write_csv_once(postrun / "FINITE_DIFFERENCE_TABLE.csv", analysis["central"])
    write_csv_once(postrun / "ANCHOR_RELATIVE_RESPONSE_TABLE.csv",
                   analysis["anchor_relative"])
    write_json_once(postrun / "DOMAIN_FEASIBILITY_AUDIT.json", analysis["domain"])
    write_json_once(postrun / "PE07_REPORT.json", analysis["report"])
    inventory = []
    for path in sorted(p for p in run_root.rglob("*")
                       if p.is_file() and p.name != "SHA256_MANIFEST.json"):
        inventory.append({"path": path.relative_to(run_root).as_posix(),
                          "sha256": sha256(path), "size": path.stat().st_size})
    write_json_once(postrun / "SHA256_MANIFEST.json", inventory)


def synthetic_self_test() -> dict:
    variables = [{"name": n, "index": i + 1,
                  "delta_small": 1.0, "delta_large": 2.0}
                 for i, n in enumerate(("m_max", "T_min", "r_div2", "t_rec_ini"))]
    anchors, baseline_records = [], []
    for anchor_index, (anchor_id, context) in enumerate(
            (("N21", "LOW"), ("N11", "MID"), ("N19", "HIGH"))):
        x = [10.0 + anchor_index, 20.0 + anchor_index,
             30.0 + anchor_index, 40.0 + anchor_index]
        responses = {"W": 100.0 + 10.0 * anchor_index,
                     "LPG_fuel_input_MJ": 200.0 + 20.0 * anchor_index,
                     "MR": 0.5 - 0.1 * anchor_index,
                     "f1": 0.5 - 0.1 * anchor_index,
                     "f2": 1.0 + anchor_index,
                     "f3": 2.0 + anchor_index}
        anchors.append({"anchor_id": anchor_id, "context": context, "x": x})
        baseline_records.append({"anchor_id": anchor_id, "x": x,
                                 "responses": responses,
                                 "baseline_exact_match": True})
    conditions, records = [], []
    order = 0
    for anchor in anchors:
        for variable in variables:
            for magnitude, delta in (("small", 1.0), ("large", 2.0)):
                for direction, multiplier in (("minus", -1), ("plus", 1)):
                    order += 1
                    cid = f"S{order:03d}_{anchor['anchor_id']}_{variable['name']}_{direction}_{magnitude}"
                    is_oob = (anchor["anchor_id"] == "N21"
                              and variable["name"] == "m_max"
                              and magnitude == "large" and direction == "minus")
                    proposed = anchor["x"][variable["index"] - 1] + multiplier * delta
                    conditions.append({"condition_id": cid, "anchor_id": anchor["anchor_id"],
                                       "variable": variable["name"], "magnitude": magnitude,
                                       "direction": direction, "evaluate": not is_oob,
                                       "proposed_value": proposed})
                    if is_oob:
                        continue
                    baseline_record = next(row for row in baseline_records
                                           if row["anchor_id"] == anchor["anchor_id"])
                    change = multiplier * delta
                    if (anchor["anchor_id"] == "N11"
                            and variable["name"] == "t_rec_ini"
                            and magnitude == "small"):
                        change = 0.0
                    x = list(anchor["x"])
                    x[variable["index"] - 1] = proposed
                    base = baseline_record["responses"]
                    responses = {"W": base["W"] + change,
                                 "LPG_fuel_input_MJ": base["LPG_fuel_input_MJ"] + 2.0 * change,
                                 "MR": base["MR"] - 0.001 * change,
                                 "f1": base["f1"] - 0.001 * change,
                                 "f2": base["f2"] + 0.01 * change,
                                 "f3": base["f3"] + 0.02 * change}
                    records.append({"condition_id": cid, "anchor_id": anchor["anchor_id"],
                                    "x": x, "invalid": False,
                                    "eligible_for_finite_difference": True,
                                    "status": "OK", "execution_status": "OK",
                                    "responses": responses})
    config = {"campaign_id": CAMPAIGN_ID, "design_version": "v1.1",
              "variables": variables, "anchors": anchors, "conditions": conditions,
              "pe06_observational_context": {
                  "all_variable_specific_relations_level": "LEVEL_4_AMBIGUOUS_OR_CONFOUNDED",
                  "directions": {"m_max": "POSITIVE", "T_min": "POSITIVE",
                                 "r_div2": "NEGATIVE_SELECTION_SENSITIVE",
                                 "t_rec_ini": "NEGATIVE_SELECTION_SENSITIVE"}}}
    payload = {"status": "COMPLETED", "evaluation_count": 47,
               "records": records}
    baseline = {"status": "BASELINE_REPLAY_PASS", "pass_count": 3,
                "records": baseline_records}
    result = analyze_payload(
        config, payload,
        {"condition_id": conditions[2]["condition_id"],
         "classification": "OUT_OF_DOMAIN_PREDEFINED_PERTURBATION",
         "evaluated": False}, baseline)
    if len(result["central"]) != 23 or result["domain"]["replacement_points"] != 0:
        raise AssertionError("Synthetic finite-difference/invalid policy failed")
    first = next(r for r in result["central"] if r["variable"] == "T_min")
    if first["central_secant_W"] != 1.0 or first["central_secant_LPG_fuel_input_MJ"] != 2.0:
        raise AssertionError("Synthetic central secant failed")
    missing = next(r for r in result["report"]["magnitude_consistency"]
                   if r["anchor_id"] == "N21" and r["variable"] == "m_max"
                   and r["response"] == "W")
    if missing["magnitude_class"] != "MAGNITUDE_COMPARISON_NOT_EVALUABLE":
        raise AssertionError("Missing symmetric pair classification failed")
    zero = next(r for r in result["report"]["magnitude_consistency"]
                if r["anchor_id"] == "N11" and r["variable"] == "t_rec_ini"
                and r["response"] == "W")
    if (zero["small_sign"] != "ZERO_MODEL_RESPONSE"
            or zero["magnitude_class"] != "ZERO_OR_MIXED_MAGNITUDE_RESPONSE"):
        raise AssertionError("Zero response was not distinct from missing pair")
    eligible = next(r for r in result["report"]["recurrence"]
                    if r["variable"] == "m_max" and r["response"] == "W")
    if eligible["pe06_comparison_class"] != "OBSERVATIONAL_AND_CONTROLLED_DIRECTION_CONSISTENT":
        raise AssertionError("Eligible PE06/PE07 comparison failed")
    ambiguous = next(r for r in result["report"]["recurrence"]
                     if r["variable"] == "r_div2" and r["response"] == "W")
    if ambiguous["pe06_comparison_class"] != "OBSERVATIONAL_RESULT_TOO_AMBIGUOUS_FOR_DIRECTIONAL_COMPARISON":
        raise AssertionError("Ambiguous PE06 comparison was not preserved")
    if (len(result["anchor_relative"]) != 47
            or len({r["condition_id"] for r in result["anchor_relative"]}) != 47):
        raise AssertionError("Anchor-relative table count/identity failed")
    source_records = {r["condition_id"]: r for r in records}
    source_baselines = {r["anchor_id"]: r for r in baseline_records}
    for row in result["anchor_relative"]:
        source = source_records[row["condition_id"]]
        source_baseline = source_baselines[source["anchor_id"]]
        if row["Delta_W"] != source["responses"]["W"] - source_baseline["responses"]["W"]:
            raise AssertionError("Anchor-relative delta used the wrong baseline")
    with tempfile.TemporaryDirectory(prefix="pe07_postrun_test_") as folder:
        root = Path(folder)
        path = root / "once.json"
        write_json_once(path, {"status": "PASS"})
        try:
            write_json_once(path, {"status": "SHOULD_FAIL"})
        except Blocked:
            pass
        else:
            raise AssertionError("No-overwrite guard failed")
    return {"status": "PASS", "central_secants": "PASS",
            "eligible_pe06_comparison": "PASS", "ambiguous_pe06_preserved": "PASS",
            "missing_pair_classification": "PASS", "zero_distinct_from_missing": "PASS",
            "anchor_relative_47_unique": "PASS", "anchor_baseline_deltas": "PASS",
            "invalid_retained_excluded": "PASS", "no_replacement": "PASS",
            "no_overwrite": "PASS",
            "model_calls": 0, "objective_calls": 0}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-root", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        print(json.dumps(synthetic_self_test(), sort_keys=True))
        return
    if args.run_root is None:
        parser.error("--run-root is required unless --self-test is used")
    analysis = analyze_run(args.run_root)
    publish(args.run_root.resolve(), analysis)


if __name__ == "__main__":
    main()
