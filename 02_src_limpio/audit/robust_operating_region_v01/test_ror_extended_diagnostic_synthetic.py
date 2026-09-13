import json
from pathlib import Path
import tempfile
import unittest

import numpy as np

import ror_extended_diagnostic_postrun as diagnostic


HERE = Path(__file__).resolve().parent


class ExtendedDiagnosticSyntheticTests(unittest.TestCase):
    def test_exact_reproduction_fixture(self):
        population = np.array([[.1, 50., .2, 3.], [.12, 55., .3, 4.]])
        scores = np.array([[.1, .4, .8], [.2, .3, .7]])
        result = diagnostic.compare_g200_primary(population, scores, population.copy(), scores.copy())
        self.assertTrue(result["POPULATION_EQUALITY"])
        self.assertTrue(result["SCORE_EQUALITY"])
        self.assertTrue(result["ND_OBJECTIVE_SET_EQUALITY"])
        self.assertEqual(result["TRAJECTORY_CLASS"], "EXACT_PRIMARY_61001_G200_REPRODUCTION")

    def test_alternative_trajectory_fixture(self):
        population = np.array([[.1, 50., .2, 3.], [.12, 55., .3, 4.]])
        scores = np.array([[.1, .4, .8], [.2, .3, .7]])
        changed = population.copy(); changed[0, 0] = np.nextafter(changed[0, 0], 1.0)
        result = diagnostic.compare_g200_primary(changed, scores, population, scores)
        self.assertFalse(result["POPULATION_EQUALITY"])
        self.assertEqual(result["TRAJECTORY_CLASS"], "ALTERNATIVE_400GEN_BUDGET_TRAJECTORY")

    def test_nd_set_equality_is_order_independent_and_exact(self):
        a = [(1., 2., 3.), (2., 1., 3.)]
        self.assertTrue(diagnostic.exact_objective_set(a, list(reversed(a))))
        b = [a[0], (np.nextafter(2., 3.), 1., 3.)]
        self.assertFalse(diagnostic.exact_objective_set(a, b))
        self.assertTrue(diagnostic.near_tie_set(a, b))

    def test_g200_final_metrics_and_frozen_hv(self):
        g = np.array([[.20, .50, 1.00], [.15, .55, .90]])
        f = np.array([[.18, .48, .95], [.14, .53, .85]])
        result = diagnostic.compare_g200_final(g, f)
        self.assertEqual(result["normalization"]["lo"], diagnostic.LO)
        self.assertEqual(result["normalization"]["hi"], diagnostic.HI)
        self.assertEqual(result["hv_reference"], diagnostic.HV_REFERENCE)
        self.assertGreater(result["G200_POINTS_DOMINATED_BY_FINAL"], 0)
        self.assertGreater(result["HV_FINAL"], result["HV_G200"])

    def test_category_a_fixture(self):
        self.assertEqual(diagnostic.classify(1, 275, True, {}),
                         ("A", "INTERNAL_TERMINATION_BEFORE_400"))
        with self.assertRaises(diagnostic.Blocked):
            diagnostic.classify(1, 275, False, {})

    def test_category_b_fixture(self):
        metrics = fixture_metrics(equal=False, g_dominated=2, f_dominated=0,
                                  g_to_f=0., f_to_g=.5, hv_change=.1)
        self.assertEqual(diagnostic.classify(0, 400, False, metrics)[0], "B")

    def test_category_c_fixture(self):
        metrics = fixture_metrics(equal=True, g_dominated=0, f_dominated=0,
                                  g_to_f=0., f_to_g=0., hv_change=0.)
        self.assertEqual(diagnostic.classify(0, 400, False, metrics)[0], "C")

    def test_category_d_fixture(self):
        metrics = fixture_metrics(equal=False, g_dominated=1, f_dominated=1,
                                  g_to_f=.5, f_to_g=.5, hv_change=.1)
        self.assertEqual(diagnostic.classify(0, 400, False, metrics)[0], "D")

    def test_primary_literals_are_frozen(self):
        cfg = json.loads((HERE / "extended_diagnostic_config.json").read_text(encoding="utf-8"))
        self.assertEqual(tuple(cfg["normalization"]["lo"]), diagnostic.LO)
        self.assertEqual(tuple(cfg["normalization"]["hi"]), diagnostic.HI)
        self.assertEqual(tuple(cfg["hv_reference"]), diagnostic.HV_REFERENCE)
        self.assertEqual(cfg["primary_reference_sha256"], diagnostic.PRIMARY_SHA256)

    def test_primary_n_pool_is_never_a_mutable_output(self):
        self.assertEqual(diagnostic.PRIMARY_STATE["PRIMARY_N_POOL_MODIFIED"], "NO")
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            report = {**diagnostic.PRIMARY_STATE, "status": "PASS"}
            output = root / "postrun" / "report.json"
            diagnostic.write_once(output, report)
            self.assertFalse((root / "N_POOL.mat").exists())
            self.assertFalse((root / "N_POOL.csv").exists())
            self.assertEqual(json.loads(output.read_text())["PRIMARY_N_POOL_MODIFIED"], "NO")


def fixture_metrics(equal, g_dominated, f_dominated, g_to_f, f_to_g, hv_change):
    result = {
        "ND_OBJECTIVE_SET_EQUALITY": equal,
        "G200_POINTS_DOMINATED_BY_FINAL": g_dominated,
        "FINAL_POINTS_DOMINATED_BY_G200": f_dominated,
        "COVERAGE_G200_TO_FINAL": g_to_f,
        "COVERAGE_FINAL_TO_G200": f_to_g,
        "HV_ABSOLUTE_CHANGE": hv_change,
    }
    for k in (1, 2, 3):
        result[f"BEST_F{k}_G200"] = 1.
        result[f"BEST_F{k}_FINAL"] = 1.
    return result


if __name__ == "__main__":
    unittest.main()
