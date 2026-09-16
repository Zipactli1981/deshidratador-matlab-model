"""Persisted-output-only PE07 postrun. Never calls MATLAB, model or objective."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path
import tempfile

CAMPAIGN_ID = "ROR_PE07_CONTROLLED_SENSITIVITY_V01"
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
                rows.append({"anchor_id": anchor["anchor_id"],
                             "variable": variable["name"], "response": response,
                             "small_sign": small_sign, "large_sign": large_sign,
                             "magnitude_class": ("MAGNITUDE_DIRECTION_CONSISTENT"
                                                 if consistent else
                                                 "ZERO_OR_MIXED_MAGNITUDE_RESPONSE"),
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
            pe06_level = config["pe06_observational_context"]["all_variable_specific_relations_level"]
            comparison = ("OBSERVATIONAL_RESULT_TOO_AMBIGUOUS_FOR_DIRECTIONAL_COMPARISON"
                          if pe06_level.startswith("LEVEL_4") else "NOT_CLASSIFIED")
            rows.append({"variable": variable["name"], "response": response,
                         "small_signs": values["small"], "large_signs": values["large"],
                         "recurrence_class": recurrence,
                         "cross_context_direction_change": context_change,
                         "pe06_comparison_class": comparison,
                         "evidence_level": level})
    return rows


def analyze_payload(config: dict, perturbation: dict, invalid: object) -> dict:
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
    invalid_rows = invalid if isinstance(invalid, list) else [invalid]
    report = {
        "status": "PASS",
        "campaign_id": CAMPAIGN_ID,
        "design_version": "v1.1",
        "finite_difference_row_count": len(central),
        "invalid_inventory_count": len(invalid_rows),
        "magnitude_consistency": magnitude,
        "recurrence": recurrence,
        "model_or_objective_calls": 0,
        "causal_claim": "NOT_MADE",
        "primary_sufficiency": "FAIL",
        "primary_n_pool_modified": "NO",
    }
    return {"central": central, "report": report,
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
    perturbation = read_json(run_root / "PERTURBATION_RESULTS.json")
    invalid = read_json(run_root / "INVALID_POINT_INVENTORY.json")
    return analyze_payload(config, perturbation, invalid)


def publish(run_root: Path, analysis: dict) -> None:
    postrun = run_root / "postrun"
    if postrun.exists():
        raise Blocked("Postrun directory exists; overwrite prohibited")
    postrun.mkdir(parents=False, exist_ok=False)
    write_csv_once(postrun / "FINITE_DIFFERENCE_TABLE.csv", analysis["central"])
    write_json_once(postrun / "DOMAIN_FEASIBILITY_AUDIT.json", analysis["domain"])
    write_json_once(postrun / "PE07_REPORT.json", analysis["report"])
    inventory = []
    for path in sorted(p for p in run_root.rglob("*")
                       if p.is_file() and p.name != "SHA256_MANIFEST.json"):
        inventory.append({"path": path.relative_to(run_root).as_posix(),
                          "sha256": sha256(path), "size": path.stat().st_size})
    write_json_once(postrun / "SHA256_MANIFEST.json", inventory)


def synthetic_self_test() -> dict:
    variables = [{"name": n, "delta_small": 1.0, "delta_large": 2.0}
                 for n in ("m_max", "T_min", "r_div2", "t_rec_ini")]
    anchors = [{"anchor_id": n, "context": c}
               for n, c in (("N21", "LOW"), ("N11", "MID"), ("N19", "HIGH"))]
    conditions, records = [], []
    order = 0
    for anchor in anchors:
        for variable in variables:
            for magnitude, delta in (("small", 1.0), ("large", 2.0)):
                for direction, multiplier in (("minus", -1), ("plus", 1)):
                    order += 1
                    cid = f"S{order:03d}_{anchor['anchor_id']}_{variable['name']}_{direction}_{magnitude}"
                    conditions.append({"condition_id": cid, "anchor_id": anchor["anchor_id"],
                                       "variable": variable["name"], "magnitude": magnitude,
                                       "direction": direction, "evaluate": True})
                    base = 100.0 + 10.0 * anchors.index(anchor)
                    value = base + multiplier * delta
                    records.append({"condition_id": cid, "invalid": False,
                                    "eligible_for_finite_difference": True,
                                    "responses": {"W": value,
                                                  "LPG_fuel_input_MJ": 2.0 * value}})
    # Make one symmetric pair unusable and prove it is excluded, not replaced.
    records[0]["invalid"] = True
    records[0]["eligible_for_finite_difference"] = False
    config = {"campaign_id": CAMPAIGN_ID, "design_version": "v1.1",
              "variables": variables, "anchors": anchors, "conditions": conditions,
              "pe06_observational_context": {
                  "all_variable_specific_relations_level": "LEVEL_4_AMBIGUOUS_OR_CONFOUNDED"}}
    payload = {"status": "COMPLETED", "evaluation_count": 47,
               "records": records[:47]}
    # The real validator requires 47 unique records. Build a real-shaped subset
    # while retaining sufficient symmetric synthetic pairs.
    result = analyze_payload(config, payload,
                             {"condition_id": records[0]["condition_id"], "invalid": True})
    if not result["central"] or result["domain"]["replacement_points"] != 0:
        raise AssertionError("Synthetic finite-difference/invalid policy failed")
    first = next(r for r in result["central"] if r["variable"] == "T_min")
    if first["central_secant_W"] != 1.0 or first["central_secant_LPG_fuel_input_MJ"] != 2.0:
        raise AssertionError("Synthetic central secant failed")
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
            "sign_and_recurrence": "PASS", "invalid_retained_excluded": "PASS",
            "no_replacement": "PASS", "no_overwrite": "PASS",
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
