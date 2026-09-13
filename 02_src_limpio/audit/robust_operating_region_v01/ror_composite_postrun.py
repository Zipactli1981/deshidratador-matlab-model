"""Fail-closed composite source adapter for the frozen ROR postrun.

Dry validation checks identity, hashes, configuration and MAT structure only.
Scientific analysis remains separately opt-in and reuses ror_postrun.audit_seed
and ror_core.analyze without changing their mathematics.
"""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile

import numpy as np
import scipy
from scipy.io import loadmat, savemat

import ror_postrun as postrun
import ror_recovery as recovery
from ror_core import Blocked, SEEDS, analyze


EXPECTED = {
    61001: (recovery.ORIGINAL_CAMPAIGN_ID, "ORIGINAL_VALID_PRIMARY"),
    61002: (recovery.ORIGINAL_CAMPAIGN_ID, "ORIGINAL_VALID_PRIMARY"),
    61003: (recovery.RECOVERY_CAMPAIGN_ID, "RECOVERY_PRIMARY"),
    61004: (recovery.RECOVERY_CAMPAIGN_ID, "RECOVERY_PRIMARY"),
    61005: (recovery.RECOVERY_CAMPAIGN_ID, "RECOVERY_PRIMARY"),
}
PRIMARY_MAT_FIELDS = {
    "X", "F", "population", "scores", "metadata_json", "exitflag", "output",
    "rng_initial", "rng_final",
}
DETAIL_MAT_FIELDS = {"callX", "callF", "callObjectiveF", "details_json"}
COMPOSITE_POSTRUN_ID = "ROR_PRIMARY_20260907_COMPOSITE_POSTRUN"
FINAL_MANIFEST = "COMPOSITE_POSTRUN_MANIFEST.json"
BASE_ARTIFACTS = (
    "audit/POSTRUN_INTEGRITY.json",
    "audit/DOMINANCE_AUDIT.json",
    "audit/PRIMARY_SUFFICIENCY.json",
    "tables/ALL_RUNS.csv",
    "tables/N_R.csv",
    "tables/N_POOL.csv",
    "tables/INTER_RUN_METRICS.csv",
    "numeric/N_POOL.mat",
    "SHA256_MANIFEST.csv",
)


def _blocked(message):
    raise Blocked("COMPOSITE_SOURCE_MAP: " + message)


def _metadata(path):
    raw = loadmat(path, simplify_cells=True, variable_names=["metadata_json"])
    if "metadata_json" not in raw:
        _blocked("missing metadata_json")
    try:
        return json.loads(str(raw["metadata_json"]))
    except (TypeError, ValueError, json.JSONDecodeError) as exc:
        raise Blocked("COMPOSITE_SOURCE_MAP: malformed metadata_json") from exc


def _validate_seed_files(folder, seed, cfg):
    folder = Path(folder).resolve()
    inventory_path = folder / "SEED_SHA256.json"
    inventory = postrun.read_json(inventory_path)
    by_path = {entry.get("path"): entry for entry in inventory.values()
               if isinstance(entry, dict)}
    if set(by_path) != set(recovery.PRIMARY_FILES):
        _blocked(f"seed {seed} inventory is incomplete or has extras")
    for name in recovery.PRIMARY_FILES:
        path = folder / name
        entry = by_path[name]
        if (not path.is_file() or path.stat().st_size != entry.get("size") or
                postrun.sha(path) != str(entry.get("sha256", "")).upper()):
            _blocked(f"seed {seed} hash/size mismatch: {name}")

    conf = postrun.read_json(folder / "FROZEN_CONFIG.json")
    if (conf.get("seed") != seed or conf.get("config") != cfg or
            not postrun.options_equivalent(conf.get("observed_options"), cfg["options"]) or
            conf.get("effective_functions_expected") != cfg["effective_functions"]):
        _blocked(f"seed {seed} configuration mismatch")

    primary_names = set(loadmat(folder / "PRIMARY_OUTPUT.mat",
                                variable_names=sorted(PRIMARY_MAT_FIELDS)))
    detail_names = set(loadmat(folder / "EVALUATION_DETAILS.mat",
                               variable_names=sorted(DETAIL_MAT_FIELDS)))
    if not PRIMARY_MAT_FIELDS.issubset(primary_names):
        _blocked(f"seed {seed} PRIMARY_OUTPUT schema mismatch")
    if not DETAIL_MAT_FIELDS.issubset(detail_names):
        _blocked(f"seed {seed} EVALUATION_DETAILS schema mismatch")

    meta = _metadata(folder / "PRIMARY_OUTPUT.mat")
    required = postrun.REQUIRED_EXECUTION_METADATA | {
        "status", "errors", "config_sha256", "source_lock_sha256",
        "observed_options", "rng_seed", "rng_type",
    }
    if not required.issubset(meta):
        _blocked(f"seed {seed} incomplete execution provenance")
    if (meta["seed"] != seed or meta["status"] != "COMPLETED" or meta["errors"] != [] or
            meta["config_sha256"] != postrun.CONFIG_HASH or
            meta["protocol_sha256"] != postrun.PROTOCOL_HASH or
            meta["source_lock_sha256"] != postrun.LOCK_HASH or
            meta["rng_seed"] != seed or meta["rng_type"] != "twister" or
            meta["expected_git_head"].lower() != meta["observed_git_head"].lower() or
            not postrun.options_equivalent(meta["observed_options"], cfg["options"]) or
            not postrun.options_equivalent(meta["solver_options"], cfg["options"]) or
            meta["productive_dependency_hashes"] != postrun.read_json(postrun.HERE / "source_lock.json")):
        _blocked(f"seed {seed} execution provenance mismatch")
    if Path(meta["exact_output_directory"]).resolve() != folder:
        _blocked(f"seed {seed} output-directory provenance mismatch")
    expected_paths = {
        "PRIMARY_OUTPUT_mat": folder / "PRIMARY_OUTPUT.mat",
        "EVALUATION_DETAILS_mat": folder / "EVALUATION_DETAILS.mat",
        "FROZEN_CONFIG_json": folder / "FROZEN_CONFIG.json",
        "FINAL_CANDIDATES_csv": folder / "FINAL_CANDIDATES.csv",
        "SOLVER_DIARY_txt": folder / "SOLVER_DIARY.txt",
        "SEED_SHA256_json": folder / "SEED_SHA256.json",
    }
    if set(meta["exact_primary_output_paths"]) != set(expected_paths):
        _blocked(f"seed {seed} primary-path inventory mismatch")
    for key, expected_path in expected_paths.items():
        if Path(meta["exact_primary_output_paths"][key]).resolve() != expected_path:
            _blocked(f"seed {seed} primary-path mismatch: {key}")
    return dict(seed=seed, source_path=str(folder), seed_sha256=postrun.sha(inventory_path))


def validate_composite_source_map(manifest_path):
    """Resolve exactly five immutable sources; never computes scientific metrics."""
    manifest_path = Path(manifest_path).resolve()
    manifest = postrun.read_json(manifest_path)
    cfg = postrun.frozen_config()
    if (manifest.get("status") != "COMPLETED_RECOVERY_PENDING_COMPOSITE_AUDIT" or
            manifest.get("RECOVERY_CAMPAIGN_ID") != recovery.RECOVERY_CAMPAIGN_ID or
            manifest.get("ORIGINAL_CAMPAIGN_ID") != recovery.ORIGINAL_CAMPAIGN_ID or
            manifest.get("PROTOCOL_SHA256") != postrun.PROTOCOL_HASH or
            manifest.get("CONFIG_SHA256") != postrun.CONFIG_HASH or
            manifest.get("SOURCE_LOCK_SHA256") != postrun.LOCK_HASH or
            manifest.get("FINAL_PRIMARY_SEED_SET") != list(SEEDS) or
            manifest.get("FINAL_PRIMARY_SEED_COUNT") != len(SEEDS) or
            manifest.get("VALID_ORIGINAL_SEEDS") != list(recovery.ORIGINAL_SEEDS) or
            manifest.get("RECOVERY_SEEDS") != list(recovery.RECOVERY_SEEDS)):
        _blocked("recovery manifest identity/configuration mismatch")
    if (not postrun.options_equivalent(manifest.get("solver_options"), cfg["options"]) or
            manifest.get("productive_dependency_hashes") != postrun.read_json(postrun.HERE / "source_lock.json")):
        _blocked("recovery manifest solver/source provenance mismatch")
    recovery_root = manifest_path.parent
    if Path(manifest.get("exact_output_directory", "")).resolve() != recovery_root:
        _blocked("recovery root provenance mismatch")

    sources = manifest.get("FINAL_PRIMARY_SOURCES")
    if not isinstance(sources, list) or len(sources) != len(SEEDS):
        _blocked("primary source count is not five")
    seeds = [item.get("seed") for item in sources if isinstance(item, dict)]
    if len(seeds) != len(sources) or sorted(seeds) != list(SEEDS) or len(set(seeds)) != len(SEEDS):
        _blocked("missing, duplicate or extra primary seed")

    interrupted = Path(manifest.get("INTERRUPTED_ATTEMPT_PATH", "")).resolve()
    if (manifest.get("INTERRUPTED_SEED") != 61003 or
            manifest.get("INTERRUPTED_ATTEMPT_CLASS") != "INTERRUPTED_ATTEMPT_EVIDENCE"):
        _blocked("interrupted-attempt identity mismatch")
    interrupted_hashes = manifest.get("INTERRUPTED_ATTEMPT_HASHES", {})
    for key, name in (("FROZEN_CONFIG_json", "FROZEN_CONFIG.json"),
                      ("SOLVER_DIARY_txt", "SOLVER_DIARY.txt")):
        path = interrupted / name
        if not path.is_file() or postrun.sha(path) != interrupted_hashes.get(key):
            _blocked("interrupted-attempt evidence mismatch")

    original_integrity = {item.get("seed"): item for item in
                          manifest.get("ORIGINAL_SEED_INTEGRITY", [])}
    if set(original_integrity) != set(recovery.ORIGINAL_SEEDS):
        _blocked("original seed integrity manifest mismatch")

    resolved = []
    original_root = None
    for item in sorted(sources, key=lambda value: value["seed"]):
        seed = item["seed"]
        expected_campaign, expected_role = EXPECTED[seed]
        folder = Path(item.get("source_path", "")).resolve()
        if (item.get("source_campaign_id") != expected_campaign or
                item.get("role") != expected_role or folder.name != f"seed_{seed}" or
                folder.parent.name != expected_campaign or folder == interrupted):
            _blocked(f"seed {seed} source identity mismatch")
        if not folder.is_dir():
            _blocked(f"seed {seed} source path does not exist")
        if seed in recovery.ORIGINAL_SEEDS:
            original_root = folder.parent if original_root is None else original_root
            if folder.parent != original_root:
                _blocked("original sources do not share the declared campaign root")
        elif folder.parent != recovery_root:
            _blocked("recovery source lies outside the recovery campaign root")
        validated = _validate_seed_files(folder, seed, cfg)
        if seed in recovery.ORIGINAL_SEEDS:
            recorded = original_integrity[seed]
            expected_files = {name.replace(".", "_"): digest
                              for name, digest in validated_files(folder).items()}
            if (recorded.get("seed_sha256") != validated["seed_sha256"] or
                    recorded.get("files") != expected_files):
                _blocked(f"seed {seed} original integrity cross-check mismatch")
        resolved.append(dict(seed=seed, source_campaign_id=expected_campaign,
                             role=expected_role, source_path=validated["source_path"]))

    campaign = postrun.read_json(original_root / "CAMPAIGN_MANIFEST.json")
    if (campaign.get("campaign_id") != recovery.ORIGINAL_CAMPAIGN_ID or
            campaign.get("protocol_sha256") != postrun.PROTOCOL_HASH or
            campaign.get("config_sha256") != postrun.CONFIG_HASH or
            campaign.get("source_lock_sha256") != postrun.LOCK_HASH):
        _blocked("original campaign manifest mismatch")
    return resolved


def validated_files(folder):
    return {name: postrun.sha(Path(folder) / name) for name in recovery.PRIMARY_FILES}


def composite_audits(manifest_path):
    cfg = postrun.frozen_config()
    return [_audit_composite_seed(item, cfg)
            for item in validate_composite_source_map(manifest_path)]


def _audit_composite_seed(source, cfg):
    families = {
        "ORIGINAL_VALID_PRIMARY": "legacy",
        "RECOVERY_PRIMARY": "recovery",
    }
    try:
        family = families[source["role"]]
    except (KeyError, TypeError) as exc:
        raise Blocked("COMPOSITE_SOURCE_MAP: unknown source role for log provenance") from exc
    return postrun.audit_seed(Path(source["source_path"]), cfg,
                              expected_log_family=family)


def analyze_composite(manifest_path, acknowledge=False):
    if acknowledge is not True:
        raise Blocked("Composite scientific postrun requires explicit acknowledgement")
    return analyze(composite_audits(manifest_path))


def composite_output_root(manifest_path):
    """Deterministic sibling root, separate from both source campaigns."""
    return Path(manifest_path).resolve().parent.parent / COMPOSITE_POSTRUN_ID


def _validate_publication_inputs(result, audits, sources):
    """Validate shape/completeness only; never recompute scientific results."""
    if result.get("PRIMARY_SUFFICIENCY") not in ("PASS", "FAIL"):
        _blocked("publication requires resolved PRIMARY_SUFFICIENCY")
    required = {"conditions", "metrics", "normalization", "max_igd", "median_igd",
                "hv_ratio", "extreme_runs", "pool", "nr", "union",
                "N_POOL_objective_count", "coverage", "recommendations"}
    if not required.issubset(result):
        _blocked("publication result is incomplete")
    if ([a.get("seed") for a in audits] != list(SEEDS) or
            [s.get("seed") for s in sources] != list(SEEDS)):
        _blocked("publication provenance is not the exact ordered five-seed set")
    if set(result["nr"]) != set(SEEDS):
        _blocked("N_R does not contain the exact five seeds")
    pairs = [(row.get("source"), row.get("target")) for row in result["coverage"]]
    expected_pairs = [(source, target) for source in SEEDS for target in SEEDS
                      if source != target]
    if pairs != expected_pairs:
        _blocked("coverage matrix is incomplete or out of canonical order")
    if [row.get("seed") for row in result["metrics"]] != list(SEEDS):
        _blocked("inter-run metrics are incomplete or out of canonical order")
    policies = result["recommendations"]
    expected_policies = {"MOISTURE_PRIORITY", "COST_PRIORITY",
                         "EMISSIONS_PRIORITY", "BALANCED_COMPROMISE"}
    if result["PRIMARY_SUFFICIENCY"] == "PASS":
        if set(policies) != expected_policies:
            _blocked("PASS publication requires exactly four policy selections")
    elif policies:
        _blocked("FAIL publication must not contain policy selections")


def _git_head():
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=postrun.HERE, text=True).strip()
    except (OSError, subprocess.CalledProcessError) as exc:
        raise Blocked("COMPOSITE_SOURCE_MAP: Git HEAD unavailable") from exc


def _publication_sources(sources, audits):
    audit_by_seed = {item["seed"]: item for item in audits}
    records = []
    for source in sources:
        seed = source["seed"]
        folder = Path(source["source_path"])
        metadata = audit_by_seed[seed]["metadata"]
        records.append(dict(
            seed=seed,
            source_campaign_id=source["source_campaign_id"],
            role=source["role"],
            source_path=str(folder.resolve()),
            seed_sha256=postrun.sha(folder / "SEED_SHA256.json"),
            input_hashes=validated_files(folder),
            input_git_head=metadata["observed_git_head"],
            validation_status="PASS",
        ))
    return records


def _policy_rows(result):
    descriptions = {
        "MOISTURE_PRIORITY": "MIN_F1_WITH_F_X_SEED_ROW_TIE_BREAK",
        "COST_PRIORITY": "MIN_F2_WITH_F_X_SEED_ROW_TIE_BREAK",
        "EMISSIONS_PRIORITY": "MIN_F3_WITH_F_X_SEED_ROW_TIE_BREAK",
        "BALANCED_COMPROMISE": "MIN_EQUAL_WEIGHT_NORMALIZED_EUCLIDEAN_DISTANCE_WITH_F_X_SEED_ROW_TIE_BREAK",
    }
    rows = []
    for name in ("MOISTURE_PRIORITY", "COST_PRIORITY", "EMISSIONS_PRIORITY",
                 "BALANCED_COMPROMISE"):
        row = result["recommendations"][name]
        rows.append(dict(policy=name, source_seed=row["seed"], source_row=row["row"],
                         x=row["x"], f=row["f"], origins=row["origins"],
                         selection_provenance=dict(
                             implementation="ror_core.recommendations",
                             rule=descriptions[name],
                             primary_sufficiency="PASS")))
    return rows


def publish_composite(manifest_path, result, audits, sources, output_root=None):
    """Persist an already calculated result via isolated build + atomic promotion."""
    manifest_path = Path(manifest_path).resolve()
    prescribed_root = composite_output_root(manifest_path)
    output_root = prescribed_root if output_root is None else Path(output_root).resolve()
    expected_parent = manifest_path.parent.parent.resolve()
    if output_root != prescribed_root or output_root.parent != expected_parent:
        _blocked("composite output root differs from the deterministic dedicated root")
    if output_root.exists():
        _blocked("composite postrun output root exists: no overwrite or resume")
    _validate_publication_inputs(result, audits, sources)
    source_records = _publication_sources(sources, audits)
    interrupted_path = Path(postrun.read_json(manifest_path)["INTERRUPTED_ATTEMPT_PATH"]).resolve()
    if any(Path(item["source_path"]) == interrupted_path for item in source_records):
        _blocked("interrupted original 61003 cannot be a primary source")

    staging = Path(tempfile.mkdtemp(prefix=f".{COMPOSITE_POSTRUN_ID}_", dir=expected_parent))
    try:
        for name in ("audit", "tables", "numeric"):
            (staging / name).mkdir()
        postrun.write_json(staging / "audit/POSTRUN_INTEGRITY.json",
            [{k: v for k, v in audit.items() if k not in ("rows", "all_rows")}
             for audit in audits])
        postrun.write_json(staging / "audit/DOMINANCE_AUDIT.json", dict(
            definition="EXACT_LE_ALL_LT_ANY", U=result["union"],
            normalization=result["normalization"], coverage=result["coverage"],
            U_count=len(result["union"]), N_POOL_count=len(result["pool"]),
            N_POOL_objective_count=result["N_POOL_objective_count"]))
        campaign_status = ("COMPLETED_SUFFICIENT" if result["PRIMARY_SUFFICIENCY"] == "PASS"
                           else "COMPLETED_BUT_INSUFFICIENT")
        selection_status = {
            f"{name}_SELECTED": ("YES" if result["PRIMARY_SUFFICIENCY"] == "PASS" else "NO")
            for name in ("MOISTURE_PRIORITY", "COST_PRIORITY", "EMISSIONS_PRIORITY",
                         "BALANCED_COMPROMISE")
        }
        failed = [name for name, passed in result["conditions"].items() if not passed]
        postrun.write_json(staging / "audit/PRIMARY_SUFFICIENCY.json",
            {**{k: v for k, v in result.items()
                if k not in ("pool", "nr", "union", "recommendations")},
             "CAMPAIGN_STATUS": campaign_status, "failed_conditions": failed,
             "policy_selections_persisted": result["PRIMARY_SUFFICIENCY"] == "PASS",
             **selection_status})
        fields = ["seed", "row", "source", "x", "f", "penalized", "origins"]
        postrun.write_csv(staging / "tables/ALL_RUNS.csv",
            [row for audit in audits for row in audit["all_rows"]],
            ["seed", "row", "source", "x", "f", "inclusion", "reason"])
        postrun.write_csv(staging / "tables/N_R.csv",
            [row for seed in SEEDS for row in result["nr"][seed]], fields)
        postrun.write_csv(staging / "tables/N_POOL.csv", result["pool"], fields)
        postrun.write_csv(staging / "tables/INTER_RUN_METRICS.csv",
                          result["metrics"], list(result["metrics"][0]))
        pool = result["pool"]
        savemat(staging / "numeric/N_POOL.mat", dict(
            X=np.array([row["x"] for row in pool]),
            F=np.array([row["f"] for row in pool]),
            lo=result["normalization"]["lo"], hi=result["normalization"]["hi"],
            provenance_json=postrun.encode(pool)), do_compression=True)
        relative = list(BASE_ARTIFACTS)
        if result["PRIMARY_SUFFICIENCY"] == "PASS":
            policies = _policy_rows(result)
            postrun.write_csv(staging / "tables/OPERATING_RECOMMENDATIONS.csv", policies,
                              list(policies[0]))
            relative.insert(-1, "tables/OPERATING_RECOMMENDATIONS.csv")

        inventory = []
        for rel in relative:
            if rel == "SHA256_MANIFEST.csv":
                continue
            path = staging / rel
            if not path.is_file() or path.stat().st_size == 0:
                _blocked("required publication artifact missing or empty: " + rel)
            inventory.append(dict(path=rel, size=path.stat().st_size,
                                  sha256=postrun.sha(path), role="DERIVED_POSTRUN_ARTIFACT"))
        postrun.write_csv(staging / "SHA256_MANIFEST.csv", inventory,
                          ["path", "size", "sha256", "role"])
        manifest_inventory = inventory + [dict(
            path="SHA256_MANIFEST.csv", size=(staging / "SHA256_MANIFEST.csv").stat().st_size,
            sha256=postrun.sha(staging / "SHA256_MANIFEST.csv"),
            role="DERIVED_ARTIFACT_HASH_INVENTORY")]
        recovery_manifest = postrun.read_json(manifest_path)
        manifest = dict(
            status="COMPLETE_TRANSACTIONAL", CAMPAIGN_STATUS=campaign_status,
            PRIMARY_SUFFICIENCY=result["PRIMARY_SUFFICIENCY"],
            **selection_status,
            composite_postrun_id=COMPOSITE_POSTRUN_ID,
            exact_output_directory=str(output_root),
            source_map=source_records,
            **{f"PRIMARY_SEED_{item['seed']}_SOURCE": item for item in source_records},
            INTERRUPTED_ORIGINAL_61003="EXCLUDED",
            interrupted_attempt=dict(path=str(interrupted_path), seed=61003,
                classification=recovery_manifest["INTERRUPTED_ATTEMPT_CLASS"],
                hashes=recovery_manifest["INTERRUPTED_ATTEMPT_HASHES"]),
            recovery_manifest_path=str(manifest_path),
            recovery_manifest_sha256=postrun.sha(manifest_path),
            protocol_sha256=postrun.PROTOCOL_HASH,
            config_sha256=postrun.CONFIG_HASH, source_lock_sha256=postrun.LOCK_HASH,
            git_head=_git_head(),
            code_provenance=dict(
                composite_adapter_path=str(Path(__file__).resolve()),
                composite_adapter_sha256=postrun.sha(Path(__file__)),
                ror_postrun_sha256=postrun.sha(postrun.HERE / "ror_postrun.py"),
                ror_core_sha256=postrun.sha(postrun.HERE / "ror_core.py")),
            python_environment=dict(python=platform.python_version(),
                                    numpy=np.__version__, scipy=scipy.__version__,
                                    executable=sys.executable),
            timestamp_utc=datetime.now(timezone.utc).isoformat(),
            validation_status="PASS",
            artifacts=manifest_inventory,
            outputs_role="DERIVED_POSTRUN_ARTIFACTS_NOT_PRIMARY_OUTPUTS")
        postrun.write_json(staging / FINAL_MANIFEST, manifest)
        if not (staging / FINAL_MANIFEST).is_file():
            _blocked("final manifest was not completed")
        os.replace(staging, output_root)
    except BaseException:
        shutil.rmtree(staging, ignore_errors=True)
        raise
    return dict(status=result["PRIMARY_SUFFICIENCY"], campaign_status=campaign_status,
                output_root=str(output_root), manifest_sha256=postrun.sha(output_root / FINAL_MANIFEST),
                publish_status="COMPLETE_TRANSACTIONAL")


def run_and_publish_composite(manifest_path, acknowledge=False, output_root=None):
    if acknowledge is not True:
        raise Blocked("Composite scientific postrun publication requires explicit acknowledgement")
    sources = validate_composite_source_map(manifest_path)
    cfg = postrun.frozen_config()
    audits = [_audit_composite_seed(item, cfg) for item in sources]
    result = analyze(audits)
    return publish_composite(manifest_path, result, audits, sources, output_root)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--dry-validate", action="store_true")
    parser.add_argument("--run-analysis", action="store_true")
    parser.add_argument("--publish", action="store_true")
    parser.add_argument("--output-root", type=Path)
    parser.add_argument("--acknowledge-scientific-postrun", action="store_true")
    args = parser.parse_args()
    if (args.dry_validate and not args.run_analysis and not args.publish and
            not args.acknowledge_scientific_postrun and args.output_root is None):
        records = validate_composite_source_map(args.manifest)
        print(json.dumps(dict(status="PASS", sources=records,
                              scientific_metrics_computed=False), separators=(",", ":")))
    elif (args.run_analysis and args.acknowledge_scientific_postrun and
          not args.dry_validate and not args.publish and args.output_root is None):
        result = analyze_composite(args.manifest, True)
        print(json.dumps(dict(status=result["PRIMARY_SUFFICIENCY"],
                              scientific_metrics_computed=True), separators=(",", ":")))
    elif (args.publish and args.acknowledge_scientific_postrun and
          not args.dry_validate and not args.run_analysis):
        published = run_and_publish_composite(args.manifest, True, args.output_root)
        print(json.dumps(published, separators=(",", ":")))
    else:
        parser.error("Choose dry validation, analysis, or explicitly acknowledged publication")
