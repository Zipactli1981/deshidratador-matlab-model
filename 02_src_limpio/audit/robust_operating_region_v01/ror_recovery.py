"""Read-only recovery provenance validation and synthetic manifest construction."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ORIGINAL_CAMPAIGN_ID = "ROR_PRIMARY_20260907_REAUTHORIZED"
RECOVERY_CAMPAIGN_ID = "ROR_PRIMARY_20260907_RECOVERY_FROM_61003_A1"
PROTOCOL_HASH = "7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599"
CONFIG_HASH = "5131DA361C7C8688D755C724F2830C057980F7F2444DDC3B8983CCEEF4DCFE47"
ORIGINAL_SEEDS = (61001, 61002)
RECOVERY_SEEDS = (61003, 61004, 61005)
FINAL_SEEDS = tuple(range(61001, 61006))
PRIMARY_FILES = (
    "PRIMARY_OUTPUT.mat", "EVALUATION_DETAILS.mat", "FROZEN_CONFIG.json",
    "FINAL_CANDIDATES.csv", "SOLVER_DIARY.txt",
)


class RecoveryBlocked(RuntimeError):
    pass


def sha(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise RecoveryBlocked(f"Unreadable JSON: {path}") from exc


def validate_plan(cfg, recovery_seeds=RECOVERY_SEEDS, warm_start=None):
    seeds = tuple(recovery_seeds)
    if len(set(seeds)) != len(seeds):
        raise RecoveryBlocked("duplicate recovery seed")
    if any(seed not in FINAL_SEEDS for seed in seeds):
        raise RecoveryBlocked("unknown recovery seed")
    if set(seeds) & set(ORIGINAL_SEEDS):
        raise RecoveryBlocked("completed original seed reexecution")
    if seeds != RECOVERY_SEEDS:
        raise RecoveryBlocked("recovery subset mismatch")
    if tuple(cfg.get("seeds", ())) != FINAL_SEEDS or cfg.get("primary_run_count") != 5:
        raise RecoveryBlocked("frozen seed identity mismatch")
    if cfg.get("nvars") != 4:
        raise RecoveryBlocked("nvars mismatch")
    options = cfg.get("options", {})
    if (options.get("PopulationSize"), options.get("MaxGenerations"),
            options.get("UseParallel")) != (24, 200, False):
        raise RecoveryBlocked("scientific options mismatch")
    if options.get("InitialPopulationMatrix") != [] or options.get("InitialScoresMatrix") != []:
        raise RecoveryBlocked("initial population/scores prohibited")
    if cfg.get("HB200_INITIALIZATION") or cfg.get("C_INITIALIZATION") or warm_start is not None:
        raise RecoveryBlocked("warm start prohibited")
    if tuple(sorted(ORIGINAL_SEEDS + seeds)) != FINAL_SEEDS:
        raise RecoveryBlocked("final primary identity mismatch")
    return True


def verify_original_seed(seed_dir: Path, seed: int, cfg: dict):
    if seed not in ORIGINAL_SEEDS:
        raise RecoveryBlocked("only completed original seeds are valid sources")
    seed_dir = Path(seed_dir)
    inventory_path = seed_dir / "SEED_SHA256.json"
    inventory = read_json(inventory_path)
    by_path = {entry.get("path"): entry for entry in inventory.values()
               if isinstance(entry, dict)}
    if set(by_path) != set(PRIMARY_FILES):
        raise RecoveryBlocked("original inventory is incomplete or unexpected")
    hashes = {}
    for name in PRIMARY_FILES:
        path = seed_dir / name
        if not path.is_file():
            raise RecoveryBlocked(f"missing original output: {name}")
        entry = by_path[name]
        if path.stat().st_size != int(entry.get("size", -1)):
            raise RecoveryBlocked(f"original size mismatch: {name}")
        observed = sha(path)
        if observed != str(entry.get("sha256", "")).upper():
            raise RecoveryBlocked(f"original hash mismatch: {name}")
        hashes[name] = observed
    seed_cfg = read_json(seed_dir / "FROZEN_CONFIG.json")
    if seed_cfg.get("seed") != seed or seed_cfg.get("config") != cfg:
        raise RecoveryBlocked("original source/config mismatch")
    return {"seed": seed, "seed_sha256": sha(inventory_path), "files": hashes}


def build_manifest(original_root: Path, recovery_root: Path, cfg: dict,
                   protocol_hash: str, git_head: str, warm_start=None):
    validate_plan(cfg, RECOVERY_SEEDS, warm_start)
    if protocol_hash.upper() != PROTOCOL_HASH:
        raise RecoveryBlocked("protocol hash mismatch")
    if sha(Path(__file__).with_name("frozen_config.json")) != CONFIG_HASH:
        raise RecoveryBlocked("repository frozen config hash mismatch")
    original_root, recovery_root = Path(original_root), Path(recovery_root)
    if recovery_root.exists():
        raise RecoveryBlocked("recovery campaign root already exists")
    original = [verify_original_seed(original_root / f"seed_{seed}", seed, cfg)
                for seed in ORIGINAL_SEEDS]
    partial = original_root / "seed_61003"
    partial_files = {}
    for name in ("FROZEN_CONFIG.json", "SOLVER_DIARY.txt"):
        path = partial / name
        if not path.is_file():
            raise RecoveryBlocked(f"missing interrupted evidence: {name}")
        partial_files[name] = sha(path)
    sources = []
    for seed in FINAL_SEEDS:
        original_source = seed in ORIGINAL_SEEDS
        campaign = ORIGINAL_CAMPAIGN_ID if original_source else RECOVERY_CAMPAIGN_ID
        base = original_root if original_source else recovery_root
        sources.append(dict(seed=seed, source_campaign_id=campaign,
                            source_path=str(base / f"seed_{seed}"),
                            role="ORIGINAL_VALID_PRIMARY" if original_source else "RECOVERY_PRIMARY"))
    return dict(
        RECOVERY_CAMPAIGN_ID=RECOVERY_CAMPAIGN_ID,
        ORIGINAL_CAMPAIGN_ID=ORIGINAL_CAMPAIGN_ID,
        PROTOCOL_SHA256=PROTOCOL_HASH, GIT_HEAD=git_head,
        INTERRUPTION_CAUSE="EXTERNAL_WINDOWS_UPDATE_REBOOT",
        INTERRUPTED_SEED=61003, INTERRUPTED_ATTEMPT_PATH=str(partial),
        INTERRUPTED_ATTEMPT_CLASS="INTERRUPTED_ATTEMPT_EVIDENCE",
        INTERRUPTED_ATTEMPT_HASHES=partial_files,
        VALID_ORIGINAL_SEEDS=list(ORIGINAL_SEEDS), RECOVERY_SEEDS=list(RECOVERY_SEEDS),
        FINAL_PRIMARY_SEED_SET=list(FINAL_SEEDS), FINAL_PRIMARY_SEED_COUNT=5,
        ORIGINAL_SEED_INTEGRITY=original, FINAL_PRIMARY_SOURCES=sources,
    )
