"""Synthetic composite-source tests; never reads real campaign data."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import numpy as np
from scipy.io import loadmat

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
        fixture(recovered, seed, cfg, log_family="recovery")
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

    def publication_fixture(self, td, fail=False):
        path, manifest, original, recovered = make_composite(td, self.cfg)
        sources = composite.validate_composite_source_map(path)
        audits = composite.composite_audits(path)
        if fail:
            audits[0]["rows"] = audits[0]["rows"][:1]
        result = analyze(audits)
        output = Path(td) / composite.COMPOSITE_POSTRUN_ID
        primary = {str(path): io.sha(path) for root in (original, recovered)
                   for path in root.rglob("*") if path.is_file()}
        return path, manifest, original, recovered, sources, audits, result, output, primary

    def assert_inventory(self, output):
        with (output / "SHA256_MANIFEST.csv").open(newline="", encoding="utf-8") as handle:
            rows = list(__import__("csv").DictReader(handle))
        self.assertTrue(rows)
        for row in rows:
            artifact = output / row["path"]
            self.assertTrue(artifact.is_file())
            self.assertGreater(artifact.stat().st_size, 0)
            self.assertEqual(io.sha(artifact), row["sha256"])

    def test_publication_pass_artifacts_manifest_values_and_input_preservation(self):
        with tempfile.TemporaryDirectory(prefix="ror_composite_publish_pass_") as td:
            (path, _, original, _, sources, audits, result, output,
             before) = self.publication_fixture(td)
            published = composite.publish_composite(path, result, audits, sources, output)
            self.assertEqual(published["campaign_status"], "COMPLETED_SUFFICIENT")
            required = [output / rel for rel in composite.BASE_ARTIFACTS]
            required += [output / "tables/OPERATING_RECOMMENDATIONS.csv",
                         output / composite.FINAL_MANIFEST]
            self.assertTrue(all(path.is_file() and path.stat().st_size > 0 for path in required))
            manifest = io.read_json(output / composite.FINAL_MANIFEST)
            self.assertEqual([item["seed"] for item in manifest["source_map"]], list(SEEDS))
            self.assertEqual([item["source_campaign_id"] for item in manifest["source_map"]],
                [recovery.ORIGINAL_CAMPAIGN_ID, recovery.ORIGINAL_CAMPAIGN_ID,
                 recovery.RECOVERY_CAMPAIGN_ID, recovery.RECOVERY_CAMPAIGN_ID,
                 recovery.RECOVERY_CAMPAIGN_ID])
            self.assertEqual(manifest["INTERRUPTED_ORIGINAL_61003"], "EXCLUDED")
            self.assertNotIn(str((original / "seed_61003").resolve()),
                             [item["source_path"] for item in manifest["source_map"]])
            for seed, source in zip(SEEDS, sources):
                self.assertEqual(manifest[f"PRIMARY_SEED_{seed}_SOURCE"]["source_path"],
                                 source["source_path"])
            sufficiency = io.read_json(output / "audit/PRIMARY_SUFFICIENCY.json")
            for key in ("PRIMARY_SUFFICIENCY", "conditions", "metrics", "max_igd",
                        "median_igd", "hv_ratio", "extreme_runs", "coverage"):
                self.assertEqual(sufficiency[key], result[key])
            dominance = io.read_json(output / "audit/DOMINANCE_AUDIT.json")
            self.assertEqual(dominance["U"], result["union"])
            self.assertEqual(dominance["coverage"], result["coverage"])
            self.assertEqual(dominance["N_POOL_count"], len(result["pool"]))
            self.assertEqual(len(dominance["coverage"]), 20)
            mat = loadmat(output / "numeric/N_POOL.mat", simplify_cells=True)
            np.testing.assert_array_equal(np.atleast_2d(mat["X"]),
                                          np.array([row["x"] for row in result["pool"]]))
            np.testing.assert_array_equal(np.atleast_2d(mat["F"]),
                                          np.array([row["f"] for row in result["pool"]]))
            with (output / "tables/N_R.csv").open(newline="", encoding="utf-8") as handle:
                nr_rows = list(__import__("csv").DictReader(handle))
            expected_nr = [row for seed in SEEDS for row in result["nr"][seed]]
            self.assertEqual([(int(row["seed"]), int(row["row"]), json.loads(row["x"]),
                               json.loads(row["f"]), json.loads(row["origins"]))
                              for row in nr_rows],
                             [(row["seed"], row["row"], row["x"], row["f"], row["origins"])
                              for row in expected_nr])
            with (output / "tables/OPERATING_RECOMMENDATIONS.csv").open(
                    newline="", encoding="utf-8") as handle:
                policies = list(__import__("csv").DictReader(handle))
            self.assertEqual([row["policy"] for row in policies],
                ["MOISTURE_PRIORITY", "COST_PRIORITY", "EMISSIONS_PRIORITY",
                 "BALANCED_COMPROMISE"])
            self.assertTrue(all(row["source_seed"] and row["x"] and row["f"] and
                                row["selection_provenance"] for row in policies))
            self.assert_inventory(output)
            for item in manifest["artifacts"]:
                artifact = output / item["path"]
                self.assertEqual(artifact.stat().st_size, item["size"])
                self.assertEqual(io.sha(artifact), item["sha256"])
            after = {name: io.sha(name) for name in before}
            self.assertEqual(after, before)

    def test_publication_fail_persists_metrics_without_recommendations(self):
        with tempfile.TemporaryDirectory(prefix="ror_composite_publish_fail_") as td:
            path, _, _, _, sources, audits, result, output, _ = self.publication_fixture(td, True)
            self.assertEqual(result["PRIMARY_SUFFICIENCY"], "FAIL")
            composite.publish_composite(path, result, audits, sources, output)
            sufficiency = io.read_json(output / "audit/PRIMARY_SUFFICIENCY.json")
            self.assertEqual(sufficiency["CAMPAIGN_STATUS"], "COMPLETED_BUT_INSUFFICIENT")
            self.assertTrue(sufficiency["failed_conditions"])
            self.assertFalse(sufficiency["policy_selections_persisted"])
            for name in ("MOISTURE_PRIORITY", "COST_PRIORITY", "EMISSIONS_PRIORITY",
                         "BALANCED_COMPROMISE"):
                self.assertEqual(sufficiency[f"{name}_SELECTED"], "NO")
            self.assertFalse((output / "tables/OPERATING_RECOMMENDATIONS.csv").exists())
            self.assertEqual(io.read_json(output / composite.FINAL_MANIFEST)["CAMPAIGN_STATUS"],
                             "COMPLETED_BUT_INSUFFICIENT")
            self.assert_inventory(output)

    def test_publication_collision_is_fail_closed_without_overwrite(self):
        with tempfile.TemporaryDirectory(prefix="ror_composite_collision_") as td:
            path, _, _, _, sources, audits, result, output, _ = self.publication_fixture(td)
            output.mkdir()
            marker = output / "keep.txt"
            marker.write_text("unchanged", encoding="utf-8")
            with self.assertRaises(Blocked):
                composite.publish_composite(path, result, audits, sources, output)
            self.assertEqual(marker.read_text(encoding="utf-8"), "unchanged")
            self.assertFalse((output / composite.FINAL_MANIFEST).exists())

    def test_exception_before_completion_leaves_no_publication(self):
        with tempfile.TemporaryDirectory(prefix="ror_composite_partial_") as td:
            path, _, _, _, sources, audits, result, output, _ = self.publication_fixture(td)
            original = io.write_json
            def fail_final(target, value):
                if Path(target).name == composite.FINAL_MANIFEST:
                    raise RuntimeError("synthetic pre-completion failure")
                return original(target, value)
            with mock.patch.object(composite.postrun, "write_json", side_effect=fail_final):
                with self.assertRaises(RuntimeError):
                    composite.publish_composite(path, result, audits, sources, output)
            self.assertFalse(output.exists())
            self.assertFalse(any(Path(td).glob(f".{composite.COMPOSITE_POSTRUN_ID}_*")))

    def test_end_to_end_publication_entrypoint_and_acknowledgement_gate(self):
        with tempfile.TemporaryDirectory(prefix="ror_composite_entrypoint_") as td:
            path, _, _, _ = make_composite(td, self.cfg)
            output = composite.composite_output_root(path)
            with self.assertRaises(Blocked):
                composite.run_and_publish_composite(path, acknowledge=False)
            self.assertFalse(output.exists())
            published = composite.run_and_publish_composite(path, acknowledge=True)
            self.assertEqual(published["publish_status"], "COMPLETE_TRANSACTIONAL")
            self.assertTrue((output / composite.FINAL_MANIFEST).is_file())


if __name__ == "__main__":
    unittest.main(verbosity=2)
