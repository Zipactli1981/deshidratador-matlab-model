"""Synthetic-only recovery orchestration tests; never executes MATLAB/model/objective."""
import copy
import json
from pathlib import Path
import tempfile
import unittest

import ror_recovery as recovery


HERE = Path(__file__).resolve().parent


def write_json(path, value):
    path.write_text(json.dumps(value, separators=(",", ":")) + "\n", encoding="utf-8")


def original_seed_fixture(root, seed, cfg):
    folder = Path(root) / f"seed_{seed}"
    folder.mkdir(parents=True)
    payloads = {
        "PRIMARY_OUTPUT.mat": b"synthetic primary",
        "EVALUATION_DETAILS.mat": b"synthetic details",
        "FINAL_CANDIDATES.csv": b"source,row,x1,x2,x3,x4,f1,f2,f3\n",
        "SOLVER_DIARY.txt": f"ROR_SEED_COMPLETE {seed}\n".encode(),
    }
    for name, payload in payloads.items():
        (folder / name).write_bytes(payload)
    write_json(folder / "FROZEN_CONFIG.json", {"seed": seed, "config": cfg})
    inventory = {}
    for name in recovery.PRIMARY_FILES:
        path = folder / name
        inventory[name.replace(".", "_")] = {
            "path": name, "sha256": recovery.sha(path), "size": path.stat().st_size}
    write_json(folder / "SEED_SHA256.json", inventory)
    return folder


def complete_fixture(parent, cfg):
    original = Path(parent) / recovery.ORIGINAL_CAMPAIGN_ID
    original.mkdir()
    for seed in recovery.ORIGINAL_SEEDS:
        original_seed_fixture(original, seed, cfg)
    partial = original / "seed_61003"
    partial.mkdir()
    write_json(partial / "FROZEN_CONFIG.json", {"seed": 61003, "config": cfg})
    (partial / "SOLVER_DIARY.txt").write_text("interrupted generation 103\n", encoding="utf-8")
    return original, Path(parent) / recovery.RECOVERY_CAMPAIGN_ID


class RecoveryTests(unittest.TestCase):
    def setUp(self):
        self.cfg = json.loads((HERE / "frozen_config.json").read_text(encoding="utf-8"))

    def test_plan_and_negative_seed_guards(self):
        self.assertTrue(recovery.validate_plan(self.cfg))
        for seeds in ((61001, 61003, 61004), (61002, 61004, 61005),
                      (61003, 61004, 61006), (61003, 61003, 61005)):
            with self.subTest(seeds=seeds), self.assertRaises(recovery.RecoveryBlocked):
                recovery.validate_plan(self.cfg, seeds)

    def test_warm_start_and_initial_population_fail_closed(self):
        with self.assertRaises(recovery.RecoveryBlocked):
            recovery.validate_plan(self.cfg, warm_start="partial/seed_61003")
        changed = copy.deepcopy(self.cfg)
        changed["options"]["InitialPopulationMatrix"] = [[0.1, 50, 0, 0]]
        with self.assertRaises(recovery.RecoveryBlocked):
            recovery.validate_plan(changed)

    def test_synthetic_five_seed_identity_and_partial_exclusion(self):
        with tempfile.TemporaryDirectory(prefix="ror_recovery_") as td:
            original, new = complete_fixture(td, self.cfg)
            manifest = recovery.build_manifest(original, new, self.cfg,
                                               recovery.PROTOCOL_HASH, "2" * 40)
            self.assertEqual(manifest["FINAL_PRIMARY_SEED_SET"], list(recovery.FINAL_SEEDS))
            self.assertEqual(manifest["FINAL_PRIMARY_SEED_COUNT"], 5)
            sources = manifest["FINAL_PRIMARY_SOURCES"]
            self.assertEqual([x["source_campaign_id"] for x in sources[:2]],
                             [recovery.ORIGINAL_CAMPAIGN_ID] * 2)
            self.assertEqual([x["source_campaign_id"] for x in sources[2:]],
                             [recovery.RECOVERY_CAMPAIGN_ID] * 3)
            self.assertNotIn(str(original / "seed_61003"), [x["source_path"] for x in sources])

    def test_existing_root_and_protocol_mismatch_block(self):
        with tempfile.TemporaryDirectory(prefix="ror_recovery_") as td:
            original, new = complete_fixture(td, self.cfg)
            new.mkdir()
            with self.assertRaises(recovery.RecoveryBlocked):
                recovery.build_manifest(original, new, self.cfg, recovery.PROTOCOL_HASH, "2" * 40)
            new.rmdir()
            with self.assertRaises(recovery.RecoveryBlocked):
                recovery.build_manifest(original, new, self.cfg, "0" * 64, "2" * 40)

    def test_missing_corrupt_and_source_config_mismatch_block(self):
        cases = ("missing", "corrupt", "config")
        for case in cases:
            with self.subTest(case=case), tempfile.TemporaryDirectory(prefix="ror_recovery_") as td:
                original, new = complete_fixture(td, self.cfg)
                if case == "missing":
                    (original / "seed_61001" / "PRIMARY_OUTPUT.mat").unlink()
                elif case == "corrupt":
                    with (original / "seed_61002" / "SOLVER_DIARY.txt").open("ab") as stream:
                        stream.write(b"corrupt")
                else:
                    content = json.loads((original / "seed_61001" / "FROZEN_CONFIG.json").read_text())
                    content["config"]["options"]["PopulationSize"] = 25
                    write_json(original / "seed_61001" / "FROZEN_CONFIG.json", content)
                    inventory = json.loads((original / "seed_61001" / "SEED_SHA256.json").read_text())
                    item = inventory["FROZEN_CONFIG_json"]
                    path = original / "seed_61001" / "FROZEN_CONFIG.json"
                    item.update(sha256=recovery.sha(path), size=path.stat().st_size)
                    write_json(original / "seed_61001" / "SEED_SHA256.json", inventory)
                with self.assertRaises(recovery.RecoveryBlocked):
                    recovery.build_manifest(original, new, self.cfg,
                                            recovery.PROTOCOL_HASH, "2" * 40)

    def test_primary_runner_is_unchanged_and_recovery_has_one_solver_call(self):
        primary = (HERE / "run_ror_campaign.m").read_text(encoding="utf-8")
        runner = (HERE / "run_ror_recovery_campaign.m").read_text(encoding="utf-8")
        self.assertEqual(primary.count("]=gamultiobj("), 1)
        self.assertEqual(runner.count("]=gamultiobj("), 1)
        self.assertIn("recoverySeeds=[61003 61004 61005]", runner)
        self.assertNotIn("load(", runner)
        for invariant in ("rng(seed,'twister')", "cfg.nvars", "cfg.lb(:)'", "cfg.ub(:)'",
                          "objective_productive_corrected_v96j_triobjective_CO2_fix1(x,'hybrid')"):
            self.assertIn(invariant, primary)
            self.assertIn(invariant, runner)


if __name__ == "__main__":
    unittest.main(verbosity=2)
