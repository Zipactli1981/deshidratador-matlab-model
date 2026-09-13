"""Independent persisted-data diagnostic; never calls MATLAB, model, objective, or N_POOL."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import tempfile

from ror_core import dominates, hypervolume

HERE = Path(__file__).resolve().parent
CAMPAIGN_ID = "ROR_BUDGET_DIAGNOSTIC_61001_G400_V01"
PRIMARY_SHA256 = "E227B1E0FA6C944C9A0F55DEC77C050239E5165C724F84BA075410B5E548A37E"
LO = (0.0035234386070778913, 0.18288767994676008, 0.4004048587704998)
HI = (0.2855208662368561, 0.6013407286569235, 1.54182299594184)
HV_REFERENCE = (1.10, 1.10, 1.10)
PRIMARY_STATE = {
    "PRIMARY_SUFFICIENCY": "FAIL",
    "FAILED_CONDITION": "HV_RATIO",
    "PRIMARY_N_POOL_MODIFIED": "NO",
    "PRIMARY_HV_RATIO_RECALCULATED": "NO",
    "PRIMARY_POLICIES_SELECTED": "NO",
    "MULTISEED_CONCLUSION_SUPPORTED": "NO",
}


class Blocked(ValueError):
    pass


def sha(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest().upper()


def _matrix(value, columns):
    import numpy as np
    result = np.asarray(value, dtype=float)
    if result.size == 0:
        return np.empty((0, columns), dtype=float)
    if result.ndim == 1:
        result = result.reshape(1, -1)
    if result.ndim != 2 or result.shape[1] != columns or not np.isfinite(result).all():
        raise Blocked("Malformed/nonfinite matrix")
    return result


def nd_rows(scores):
    scores = _matrix(scores, 3)
    rows = [{"f": tuple(row)} for row in scores]
    return [tuple(row["f"]) for i, row in enumerate(rows)
            if not any(i != j and dominates(other["f"], row["f"])
                       for j, other in enumerate(rows))]


def exact_objective_set(a, b):
    return set(map(tuple, a)) == set(map(tuple, b))


def near_tie_set(a, b, tolerance=1e-12):
    if len(a) != len(b):
        return False
    remaining = list(map(tuple, b))
    for row in map(tuple, a):
        match = next((i for i, other in enumerate(remaining)
                      if all(abs(x-y) <= tolerance*max(1.0, abs(x), abs(y))
                             for x, y in zip(row, other))), None)
        if match is None:
            return False
        remaining.pop(match)
    return not remaining


def coverage(source, target):
    if not target:
        raise Blocked("Coverage target is empty")
    return sum(any(dominates({"f": a}["f"], {"f": b}["f"]) for a in source)
               for b in target) / len(target)


def normalize(points):
    return [tuple((row[k]-LO[k])/(HI[k]-LO[k]) for k in range(3)) for row in points]


def fixed_hv(points):
    # ror_core.REFERENCE is exactly the frozen (1.10, 1.10, 1.10).
    value, outside = hypervolume(normalize(points))
    return value, outside


def compare_g200_primary(g200_population, g200_scores, primary_population, primary_scores):
    import numpy as np
    gp, gs = _matrix(g200_population, 4), _matrix(g200_scores, 3)
    pp, ps = _matrix(primary_population, 4), _matrix(primary_scores, 3)
    gnd, pnd = nd_rows(gs), nd_rows(ps)
    pop_equal = gp.shape == pp.shape and np.array_equal(gp, pp, equal_nan=False)
    score_equal = gs.shape == ps.shape and np.array_equal(gs, ps, equal_nan=False)
    nd_equal = exact_objective_set(gnd, pnd)
    return {
        "POPULATION_EQUALITY": pop_equal,
        "SCORE_EQUALITY": score_equal,
        "ND_OBJECTIVE_SET_EQUALITY": nd_equal,
        "NEAR_TIE_1E12_DIAGNOSTIC": near_tie_set(gnd, pnd),
        "TRAJECTORY_CLASS": ("EXACT_PRIMARY_61001_G200_REPRODUCTION" if
                             pop_equal and score_equal and nd_equal else
                             "ALTERNATIVE_400GEN_BUDGET_TRAJECTORY"),
    }


def compare_g200_final(g200_scores, final_scores):
    g, f = nd_rows(g200_scores), nd_rows(final_scores)
    if not g or not f:
        raise Blocked("Empty nondominated set")
    hv_g, outside_g = fixed_hv(g)
    hv_f, outside_f = fixed_hv(f)
    dominated_g = sum(any(dominates(a, b) for a in f) for b in g)
    dominated_f = sum(any(dominates(a, b) for a in g) for b in f)
    result = {
        "N_G200_SIZE": len(g), "N_FINAL_SIZE": len(f),
        "ND_OBJECTIVE_SET_EQUALITY": exact_objective_set(g, f),
        "COVERAGE_G200_TO_FINAL": coverage(g, f),
        "COVERAGE_FINAL_TO_G200": coverage(f, g),
        "G200_POINTS_DOMINATED_BY_FINAL": dominated_g,
        "FINAL_POINTS_DOMINATED_BY_G200": dominated_f,
        "BEST_F1_G200": min(x[0] for x in g), "BEST_F1_FINAL": min(x[0] for x in f),
        "BEST_F2_G200": min(x[1] for x in g), "BEST_F2_FINAL": min(x[1] for x in f),
        "BEST_F3_G200": min(x[2] for x in g), "BEST_F3_FINAL": min(x[2] for x in f),
        "HV_G200": hv_g, "HV_FINAL": hv_f,
        "HV_ABSOLUTE_CHANGE": hv_f-hv_g,
        "HV_RELATIVE_CHANGE": "NOT_COMPARABLE" if hv_g == 0 else (hv_f-hv_g)/hv_g,
        "HV_G200_OUTSIDE_REFERENCE": outside_g,
        "HV_FINAL_OUTSIDE_REFERENCE": outside_f,
        "normalization": {"source": "PRIMARY_LITERAL_FIXED", "lo": LO, "hi": HI},
        "hv_reference": HV_REFERENCE,
    }
    return result


def classify(exitflag, generations, internal_termination_valid, metrics):
    if exitflag == 1 and generations < 400 and internal_termination_valid is True:
        return "A", "INTERNAL_TERMINATION_BEFORE_400"
    if generations != 400:
        raise Blocked("Termination is neither valid category A nor G400")
    if metrics["ND_OBJECTIVE_SET_EQUALITY"]:
        unchanged = (metrics["G200_POINTS_DOMINATED_BY_FINAL"] == 0 and
                     metrics["FINAL_POINTS_DOMINATED_BY_G200"] == 0 and
                     metrics["HV_ABSOLUTE_CHANGE"] == 0 and
                     all(metrics[f"BEST_F{k}_G200"] == metrics[f"BEST_F{k}_FINAL"]
                         for k in (1, 2, 3)))
        if unchanged:
            return "C", "NO_DETECTABLE_POST_200_CHANGE"
    improvements = (metrics["G200_POINTS_DOMINATED_BY_FINAL"] > 0 or
                    metrics["COVERAGE_FINAL_TO_G200"] > metrics["COVERAGE_G200_TO_FINAL"] or
                    metrics["HV_ABSOLUTE_CHANGE"] > 0)
    contradictions = (metrics["FINAL_POINTS_DOMINATED_BY_G200"] > 0 or
                      metrics["COVERAGE_G200_TO_FINAL"] > metrics["COVERAGE_FINAL_TO_G200"] or
                      metrics["HV_ABSOLUTE_CHANGE"] < 0)
    if improvements and not contradictions:
        return "B", "POST_200_EVOLUTION_OBSERVED"
    return "D", "MIXED_OR_AMBIGUOUS_POST_200_CHANGE"


def snapshot_generation(snapshot):
    value = snapshot.get("Generation", "NOT_AVAILABLE")
    return int(value) if isinstance(value, (int, float)) else None


def analyze_files(run_root: Path, primary_path: Path):
    from scipy.io import loadmat
    run_root, primary_path = Path(run_root).resolve(), Path(primary_path).resolve()
    if run_root.name != CAMPAIGN_ID:
        raise Blocked("Wrong campaign root")
    if sha(primary_path) != PRIMARY_SHA256:
        raise Blocked("Primary reference hash mismatch")
    final_path = run_root / "EXTENDED_FINAL.mat"
    if not final_path.exists():
        raise Blocked("Final output missing")
    fraw = loadmat(final_path, simplify_cells=True)
    meta = fraw.get("metadata", {})
    generations = int(meta.get("output", {}).get("generations", -1))
    exitflag = int(fraw["exitflag"])
    internal_valid = bool(meta.get("internal_termination_valid", False))
    g200_path = run_root / "snapshots" / "G200.mat"
    if not g200_path.exists():
        category = classify(exitflag, generations, internal_valid, {})
        if category[0] != "A" or generations >= 200:
            raise Blocked("G200 = NOT_REACHED without valid pre-G200 category A termination")
        return {"status": "PASS", "campaign_id": CAMPAIGN_ID,
                "G200_STATUS": "NOT_REACHED", "G200_VS_PRIMARY": "NOT_COMPARABLE",
                "G200_VS_FINAL": "NOT_COMPARABLE",
                "INTERPRETATION_CATEGORY": category[0], "INTERPRETATION": category[1],
                **PRIMARY_STATE}
    graw = loadmat(g200_path, simplify_cells=True)["snapshot"]
    praw = loadmat(primary_path, simplify_cells=True)
    if snapshot_generation(graw) != 200 or graw.get("complete") != 1:
        raise Blocked("Invalid G200 snapshot")
    reproduction = compare_g200_primary(graw["Population"], graw["Score"],
                                        praw["population"], praw["scores"])
    within = compare_g200_final(graw["Score"], fraw["scores"])
    category = classify(exitflag, generations, internal_valid, within)
    return {"status": "PASS", "campaign_id": CAMPAIGN_ID,
            "G200_VS_PRIMARY": reproduction, "G200_VS_FINAL": within,
            "INTERPRETATION_CATEGORY": category[0], "INTERPRETATION": category[1],
            **PRIMARY_STATE}


def write_once(path: Path, value):
    if path.exists():
        raise Blocked("Postrun output exists; overwrite prohibited")
    path.parent.mkdir(parents=False, exist_ok=False)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent,
                                     delete=False, suffix=".tmp") as stream:
        json.dump(value, stream, indent=2, sort_keys=True)
        stream.write("\n")
        temp = Path(stream.name)
    temp.replace(path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-root", required=True, type=Path)
    parser.add_argument("--primary", required=True, type=Path)
    args = parser.parse_args()
    report = analyze_files(args.run_root, args.primary)
    write_once(args.run_root / "postrun" / "EXTENDED_DIAGNOSTIC_REPORT.json", report)


if __name__ == "__main__":
    main()
