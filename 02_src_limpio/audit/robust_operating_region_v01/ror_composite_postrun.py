"""Fail-closed composite source adapter for the frozen ROR postrun.

Dry validation checks identity, hashes, configuration and MAT structure only.
Scientific analysis remains separately opt-in and reuses ror_postrun.audit_seed
and ror_core.analyze without changing their mathematics.
"""
import argparse
import json
from pathlib import Path

from scipy.io import loadmat

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
    return [postrun.audit_seed(Path(item["source_path"]), cfg)
            for item in validate_composite_source_map(manifest_path)]


def analyze_composite(manifest_path, acknowledge=False):
    if acknowledge is not True:
        raise Blocked("Composite scientific postrun requires explicit acknowledgement")
    return analyze(composite_audits(manifest_path))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--dry-validate", action="store_true")
    parser.add_argument("--run-analysis", action="store_true")
    parser.add_argument("--acknowledge-scientific-postrun", action="store_true")
    args = parser.parse_args()
    if args.dry_validate and not args.run_analysis and not args.acknowledge_scientific_postrun:
        records = validate_composite_source_map(args.manifest)
        print(json.dumps(dict(status="PASS", sources=records,
                              scientific_metrics_computed=False), separators=(",", ":")))
    elif args.run_analysis and args.acknowledge_scientific_postrun and not args.dry_validate:
        result = analyze_composite(args.manifest, True)
        print(json.dumps(dict(status=result["PRIMARY_SUFFICIENCY"],
                              scientific_metrics_computed=True), separators=(",", ":")))
    else:
        parser.error("Choose dry validation or explicitly acknowledged scientific analysis")
