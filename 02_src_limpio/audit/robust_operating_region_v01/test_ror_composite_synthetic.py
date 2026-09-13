"""Synthetic composite-source tests; never reads real campaign data."""
import copy
import json
from pathlib import Path
import tempfile
import unittest

import ror_composite_postrun as composite
import ror_postrun as io
import ror_recovery as recovery
from ror_core import Blocked, SEEDS, analyze
from test_ror_synthetic import fixture


def write(path, value):
    Path(path).write_text(json.dumps(value, ensure_ascii=False, sort_keys=True,
                                    separators=(",", ":")) + "\n",
                          encoding="utf-8", newline="\n")


def make_composite(parent, cfg):
    parent = Path(parent)
    parent.mkdir(parents=True, exist_ok=True)
    original = parent / recovery.ORIGINAL_CAMPAIGN_ID
    recovered = parent / recovery.RECOVERY_CAMPAIGN_ID
    original.mkdir(); recovered.mkdir()
    for seed in recovery.ORIGINAL_SEEDS:
        fixture(original, seed, cfg)
    for seed in recovery.RECOVERY_SEEDS:
        fixture(recovered, seed, cfg)
    partial = original / "seed_61003"
    partial.mkdir()
    write(partial / "FROZEN_CONFIG.json", {"seed": 61003, "config": cfg})
    (partial / "SOLVER_DIARY.txt").write_text("interrupted\n", encoding="utf-8")
    write(original / "CAMPAIGN_MANIFEST.json", dict(
        campaign_id=recovery.ORIGINAL_CAMPAIGN_ID,
        protocol_sha256=io.PROTOCOL_HASH, config_sha256=io.CONFIG_HASH,
        source_lock_sha256=io.LOCK_HASH))
    sources = []
    for seed in SEEDS:
        is_original = seed in recovery.ORIGINAL_SEEDS
        root = original if is_original else recovered
        sources.append(dict(seed=seed,
            source_campaign_id=recovery.ORIGINAL_CAMPAIGN_ID if is_original else recovery.RECOVERY_CAMPAIGN_ID,
            source_path=str((root / f"seed_{seed}").resolve()),
            role="ORIGINAL_VALID_PRIMARY" if is_original else "RECOVERY_PRIMARY"))
    original_integrity = []
    for seed in recovery.ORIGINAL_SEEDS:
        folder = original / f"seed_{seed}"
        original_integrity.append(dict(seed=seed,
            seed_sha256=io.sha(folder / "SEED_SHA256.json"),
            files={name.replace(".", "_"): io.sha(folder / name)
                   for name in recovery.PRIMARY_FILES}))
    manifest = dict(status="COMPLETED_RECOVERY_PENDING_COMPOSITE_AUDIT",
        RECOVERY_CAMPAIGN_ID=recovery.RECOVERY_CAMPAIGN_ID,
        ORIGINAL_CAMPAIGN_ID=recovery.ORIGINAL_CAMPAIGN_ID,
        PROTOCOL_SHA256=io.PROTOCOL_HASH, CONFIG_SHA256=io.CONFIG_HASH,
        SOURCE_LOCK_SHA256=io.LOCK_HASH,
        FINAL_PRIMARY_SEED_SET=list(SEEDS), FINAL_PRIMARY_SEED_COUNT=5,
        VALID_ORIGINAL_SEEDS=list(recovery.ORIGINAL_SEEDS),
        RECOVERY_SEEDS=list(recovery.RECOVERY_SEEDS),
        FINAL_PRIMARY_SOURCES=sources, INTERRUPTED_SEED=61003,
        INTERRUPTED_ATTEMPT_PATH=str(partial.resolve()),
        INTERRUPTED_ATTEMPT_CLASS="INTERRUPTED_ATTEMPT_EVIDENCE",
        INTERRUPTED_ATTEMPT_HASHES={
            "FROZEN_CONFIG_json": io.sha(partial / "FROZEN_CONFIG.json"),
            "SOLVER_DIARY_txt": io.sha(partial / "SOLVER_DIARY.txt")},
        ORIGINAL_SEED_INTEGRITY=original_integrity,
        solver_options=cfg["options"],
        productive_dependency_hashes=io.read_json(io.HERE / "source_lock.json"),
        exact_output_directory=str(recovered.resolve()))
    path = recovered / "RECOVERY_MANIFEST.json"
    write(path, manifest)
    return path, manifest, original, recovered


class CompositeTests(unittest.TestCase):
    def setUp(self):
        self.cfg = io.frozen_config()

    def test_happy_path_exact_identity_and_partial_exclusion(self):
        with tempfile.TemporaryDirectory(prefix="ror_composite_") as td:
            path, _, original, _ = make_composite(td, self.cfg)
            sources = composite.validate_composite_source_map(path)
            self.assertEqual([item["seed"] for item in sources], list(SEEDS))
            self.assertEqual(len({item["source_path"] for item in sources}), 5)
            self.assertNotIn(str((original / "seed_61003").resolve()),
                             [item["source_path"] for item in sources])

    def test_identity_fail_closed_cases(self):
        cases = ("partial", "duplicate", "missing", "extra", "wrong_campaign")
        for case in cases:
            with self.subTest(case=case), tempfile.TemporaryDirectory(prefix="ror_composite_") as td:
                path, manifest, original, _ = make_composite(td, self.cfg)
                sources = manifest["FINAL_PRIMARY_SOURCES"]
                if case == "partial":
                    sources[2].update(source_campaign_id=recovery.ORIGINAL_CAMPAIGN_ID,
                                      role="ORIGINAL_VALID_PRIMARY",
                                      source_path=str((original / "seed_61003").resolve()))
                elif case == "duplicate":
                    sources[3]["seed"] = 61003
                elif case == "missing":
                    sources.pop()
                elif case == "extra":
                    sources.append(dict(seed=61006, source_campaign_id="X", role="X",
                                        source_path=str((Path(td) / "seed_61006").resolve())))
                else:
                    sources[4]["source_campaign_id"] = recovery.ORIGINAL_CAMPAIGN_ID
                write(path, manifest)
                with self.assertRaises(Blocked):
                    composite.validate_composite_source_map(path)

    def test_hash_config_protocol_and_manifest_fail_closed(self):
        cases = ("hash", "config", "protocol", "manifest")
        for case in cases:
            with self.subTest(case=case), tempfile.TemporaryDirectory(prefix="ror_composite_") as td:
                path, manifest, _, recovered = make_composite(td, self.cfg)
                if case == "hash":
                    (recovered / "seed_61004" / "SOLVER_DIARY.txt").write_text("changed\n")
                elif case == "config":
                    conf_path = recovered / "seed_61004" / "FROZEN_CONFIG.json"
                    conf = io.read_json(conf_path)
                    conf["config"]["options"]["PopulationSize"] = 25
                    write(conf_path, conf)
                    inv_path = recovered / "seed_61004" / "SEED_SHA256.json"
                    inv = io.read_json(inv_path)
                    inv["FROZEN_CONFIG_json"].update(
                        size=conf_path.stat().st_size, sha256=io.sha(conf_path))
                    write(inv_path, inv)
                elif case == "protocol":
                    manifest["PROTOCOL_SHA256"] = "0" * 64
                    write(path, manifest)
                else:
                    manifest["status"] = "RUNNING"
                    write(path, manifest)
                with self.assertRaises(Blocked):
                    composite.validate_composite_source_map(path)

    def test_single_root_composite_numerical_equivalence(self):
        with tempfile.TemporaryDirectory(prefix="ror_composite_equivalence_") as td:
            base = Path(td)
            path, _, _, _ = make_composite(base / "composite", self.cfg)
            mono = base / "single"
            mono.mkdir()
            for seed in SEEDS:
                fixture(mono, seed, self.cfg)
            legacy = analyze([io.audit_seed(mono / f"seed_{seed}", self.cfg) for seed in SEEDS])
            adapted = composite.analyze_composite(path, acknowledge=True)
            for key in ("nr", "pool", "coverage", "metrics", "max_igd", "median_igd",
                        "hv_ratio", "extreme_runs", "PRIMARY_SUFFICIENCY"):
                self.assertEqual(adapted[key], legacy[key], key)

    def test_scientific_analysis_is_explicitly_locked(self):
        with self.assertRaises(Blocked):
            composite.analyze_composite("unused", acknowledge=False)


if __name__ == "__main__":
    unittest.main(verbosity=2)
