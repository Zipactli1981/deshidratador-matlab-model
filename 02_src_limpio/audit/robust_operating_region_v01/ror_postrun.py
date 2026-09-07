"""Static preflight and explicitly gated postrun IO; never imports/starts MATLAB."""
import argparse
import csv
from datetime import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

from ror_core import (Blocked, SEEDS, LB, UB, analyze, compare_benchmark,
                      finite_vector, nondominated, ranks, near_tie)

HERE = Path(__file__).resolve().parent
CONFIG_HASH = "5131DA361C7C8688D755C724F2830C057980F7F2444DDC3B8983CCEEF4DCFE47"
LOCK_HASH = "5F528E34A97BB279478BDD0FF5CF1D3A78EF7864D392CCC545162DAF0E2765EB"
PROTOCOL_HASH = "7259B0855CF2F835851EE46FF8B8845FCAA0A1E07852419C76731F7F82A82599"
REQUIRED_EXECUTION_METADATA = {
    "start_timestamp", "end_timestamp", "elapsed_time_seconds",
    "exact_output_directory", "exact_primary_output_paths", "seed",
    "solver_options", "solver_output", "exitflag", "generations", "funccount",
    "message", "protocol_sha256", "expected_git_head", "observed_git_head",
    "productive_dependency_hashes",
}


def sha(path):
    with Path(path).open("rb") as f:
        return hashlib.file_digest(f, "sha256").hexdigest().upper()


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8-sig"))


def frozen_config():
    if sha(HERE/"frozen_config.json") != CONFIG_HASH:
        raise Blocked("Frozen configuration hash mismatch")
    if sha(HERE/"source_lock.json") != LOCK_HASH:
        raise Blocked("Source lock hash mismatch")
    return read_json(HERE/"frozen_config.json")


def static_check(root):
    """Read-only; no MAT reads and no execution other than Git inspection."""
    root = Path(root).resolve()
    cfg = frozen_config()
    if sha(root/cfg["protocol_path"]) != PROTOCOL_HASH:
        raise Blocked("Protocol hash mismatch")
    if "NEXT_GATE = ROBUST_OPERATING_REGION_IMPLEMENTATION" not in (
            root/cfg["protocol_path"]).read_text(encoding="utf-8"):
        raise Blocked("Wrong protocol gate")
    lock = read_json(HERE/"source_lock.json")
    for item in lock:
        path = root/item["path"]
        if sha(path) != item["sha256"]:
            raise Blocked("Source byte mismatch: "+item["path"])
        blob = subprocess.check_output(
            ["git", "hash-object", "--path="+item["path"], str(path)], cwd=root,
            text=True).strip()
        baseline = subprocess.check_output(
            ["git", "rev-parse", cfg["baseline"]+":"+item["path"]], cwd=root,
            text=True).strip()
        if blob != item["blob"] or baseline != item["blob"]:
            raise Blocked("Source baseline mismatch: "+item["path"])
    return dict(status="PASS_STATIC_ONLY", sources=len(lock), protocol_sha256=PROTOCOL_HASH,
                matlab_executed=False, dynamic_path_resolution="DEFERRED_TO_AUTHORIZED_EXECUTION")


def matrix(value, cols):
    import numpy as np
    a = np.asarray(value)
    if a.size == 0:
        return np.empty((0, cols), dtype=float)
    if not np.isrealobj(a) or a.dtype.kind != "f":
        raise Blocked("MAT matrix must be real numeric")
    if a.ndim == 1:
        a = a.reshape(1, -1)
    if a.ndim != 2 or a.shape[1] != cols or a.dtype.itemsize != 8:
        raise Blocked("MAT dimensions/precision mismatch")
    return a.astype(float, copy=False)


def absolute_timestamp(value):
    if not isinstance(value, str) or not value:
        raise Blocked("Missing absolute timestamp")
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise Blocked("Malformed absolute timestamp") from error
    if parsed.tzinfo is None:
        raise Blocked("Timestamp has no UTC offset")
    return parsed


def audit_seed(folder, cfg):
    """Only persisted doubles/details; no replay. Raises rather than fixing evidence."""
    import numpy as np
    from scipy.io import loadmat
    folder = Path(folder)
    seed = int(folder.name.removeprefix("seed_"))
    if seed not in SEEDS:
        raise Blocked("Unexpected seed")
    required = {"PRIMARY_OUTPUT.mat", "EVALUATION_DETAILS.mat", "FROZEN_CONFIG.json",
                "FINAL_CANDIDATES.csv", "SOLVER_DIARY.txt"}
    inv = read_json(folder/"SEED_SHA256.json")
    if {v["path"] for v in inv.values()} != required or len(inv) != len(required):
        raise Blocked("Incomplete/extra seed inventory")
    for entry in inv.values():
        p = folder/entry["path"]
        if p.stat().st_size != entry["size"] or sha(p) != entry["sha256"]:
            raise Blocked("Seed file hash/size mismatch")
    conf = read_json(folder/"FROZEN_CONFIG.json")
    if conf["seed"] != seed or conf["config"] != cfg or conf["observed_options"] != cfg["options"]:
        raise Blocked("Seed config/options mismatch")
    if conf["effective_functions_expected"] != cfg["effective_functions"]:
        raise Blocked("Effective function identity mismatch")
    raw = loadmat(folder/"PRIMARY_OUTPUT.mat", simplify_cells=True)
    detail = loadmat(folder/"EVALUATION_DETAILS.mat", simplify_cells=True)
    meta = json.loads(str(raw["metadata_json"]))
    if not REQUIRED_EXECUTION_METADATA.issubset(meta):
        raise Blocked("Incomplete execution provenance: " +
                      ",".join(sorted(REQUIRED_EXECUTION_METADATA-set(meta))))
    if (meta["seed"] != seed or meta["status"] != "COMPLETED" or meta["errors"] != [] or
        meta["config_sha256"] != CONFIG_HASH or meta["protocol_sha256"] != PROTOCOL_HASH or
        meta["source_lock_sha256"] != LOCK_HASH or meta["observed_options"] != cfg["options"]):
        raise Blocked("Execution provenance mismatch")
    if meta["solver_options"] != cfg["options"]:
        raise Blocked("Solver option provenance mismatch")
    if meta["productive_dependency_hashes"] != read_json(HERE/"source_lock.json"):
        raise Blocked("Productive dependency provenance mismatch")
    start, end = absolute_timestamp(meta["start_timestamp"]), absolute_timestamp(meta["end_timestamp"])
    if end < start or meta["elapsed_time_seconds"] < 0:
        raise Blocked("Invalid execution timing provenance")
    if not (isinstance(meta["expected_git_head"], str) and
            len(meta["expected_git_head"]) == 40 and
            meta["expected_git_head"].lower() == meta["observed_git_head"].lower()):
        raise Blocked("Expected/observed Git HEAD mismatch")
    expected_paths = {
        "PRIMARY_OUTPUT_mat": folder/"PRIMARY_OUTPUT.mat",
        "EVALUATION_DETAILS_mat": folder/"EVALUATION_DETAILS.mat",
        "FROZEN_CONFIG_json": folder/"FROZEN_CONFIG.json",
        "FINAL_CANDIDATES_csv": folder/"FINAL_CANDIDATES.csv",
        "SOLVER_DIARY_txt": folder/"SOLVER_DIARY.txt",
        "SEED_SHA256_json": folder/"SEED_SHA256.json",
    }
    if Path(meta["exact_output_directory"]).resolve() != folder.resolve():
        raise Blocked("Exact output directory provenance mismatch")
    if set(meta["exact_primary_output_paths"]) != set(expected_paths):
        raise Blocked("Exact primary output path inventory mismatch")
    for key, expected in expected_paths.items():
        if Path(meta["exact_primary_output_paths"][key]).resolve() != expected.resolve():
            raise Blocked("Exact primary output path mismatch: "+key)
    if not isinstance(meta["solver_output"], dict) or meta["solver_output"].get("message") != meta["message"]:
        raise Blocked("Solver output/message provenance mismatch")
    if any(meta[k] != cfg["environment"][k] for k in ("matlab", "globaloptim", "platform")):
        raise Blocked("Environment mismatch")
    if meta["rng_seed"] != seed or meta["rng_type"] != "twister":
        raise Blocked("RNG provenance mismatch")
    for key in ("rng_initial", "rng_final"):
        if not raw.get(key) or "State" not in raw[key]:
            raise Blocked("Missing full RNG state")
    if int(raw["rng_initial"]["Seed"]) != seed:
        raise Blocked("RNG seed MAT mismatch")
    if (meta["exitflag"] not in (0, 1) or not 0 <= meta["generations"] <= 200 or
        (meta["exitflag"] == 0 and meta["generations"] != 200) or
        meta["runtime_seconds"] < 0 or not meta["message"] or
        meta["runtime_seconds"] != meta["elapsed_time_seconds"]):
        raise Blocked("Abnormal stop/count")
    if (raw["exitflag"] != meta["exitflag"] or
        raw["output"]["generations"] != meta["generations"] or
        raw["output"]["funccount"] != meta["funccount"]):
        raise Blocked("Output/metadata inconsistency")
    log = (folder/"SOLVER_DIARY.txt").read_text(encoding="utf-8", errors="replace")
    if f"ROR_SEED_COMPLETE {seed}" not in log or "ROR_SEED_FAILED" in log:
        raise Blocked("Incomplete/error log")
    cx, cf = matrix(detail["callX"], 4), matrix(detail["callF"], 3)
    df = matrix(detail["callObjectiveF"], 3)
    dj = np.asarray(detail["details_json"], dtype=object).reshape(-1)
    if not (len(cx) == len(cf) == len(df) == len(dj) == meta["funccount"]):
        raise Blocked("Actual calls/detail/funccount mismatch")
    calls = {}
    for x, f, objective_f, text in zip(cx, cf, df, dj):
        key = tuple(x.tolist())
        d = json.loads(str(text))
        if key in calls and not np.array_equal(calls[key][0], f, equal_nan=True):
            raise Blocked("Same evaluated x with distinct F")
        calls[key] = (f, d, objective_f)
    rows, exported, all_rows = [], [], []
    excluded = {"nonfinite": 0, "bounds": 0, "penalized": 0}
    for label, xname, fname in (("returned", "X", "F"), ("population", "population", "scores")):
        xs, fs = matrix(raw[xname], 4), matrix(raw[fname], 3)
        if len(xs) != len(fs):
            raise Blocked("X/F row mismatch")
        for i, (x, f) in enumerate(zip(xs, fs), 1):
            row_id = i if label == "returned" else len(matrix(raw["X"],4))+i
            exported.append([label, i, *x.tolist(), *f.tolist()])
            record=dict(seed=seed,row=row_id,source=label,
                        x=[float(t) if np.isfinite(t) else str(t) for t in x],
                        f=[float(t) if np.isfinite(t) else str(t) for t in f],
                        inclusion="EXCLUDED",reason="")
            all_rows.append(record)
            if not np.isfinite(x).all() or not np.isfinite(f).all():
                excluded["nonfinite"] += 1
                record["reason"]="NONFINITE"
                continue
            if not all(l <= t <= u for l, t, u in zip(LB, x, UB)):
                excluded["bounds"] += 1
                record["reason"]="BOUNDS"
                continue
            if tuple(x) not in calls or not np.array_equal(calls[tuple(x)][0], f):
                raise Blocked("Final candidate missing exact captured objective call")
            _, d, objective_f = calls[tuple(x)]
            penalty = (d.get("status") != "OK" or d.get("execution_status") != "OK" or
                       f[0] >= 999.999 or f[1] >= 999999.999 or
                       np.array_equal(f, [1000., 1e6, 1e6]))
            if penalty:
                excluded["penalized"] += 1
                record["reason"]="PENALIZED"
                continue
            if not np.array_equal(f, objective_f):
                raise Blocked("Objective detail/F inconsistency")
            rows.append(dict(seed=seed, row=row_id, source=label, x=x.tolist(),
                             f=f.tolist(), detail=d, penalized=False))
            record["inclusion"]="INCLUDED_BEFORE_EXACT_DEDUP"
    with (folder/"FINAL_CANDIDATES.csv").open(newline="", encoding="utf-8-sig") as f:
        csv_rows = list(csv.reader(f))
    if not csv_rows or csv_rows[0] != ["source","row","x1","x2","x3","x4","f1","f2","f3"]:
        raise Blocked("Unexpected candidate CSV schema")
    if len(csv_rows)-1 != len(exported):
        raise Blocked("CSV candidate count mismatch")
    for stored, expected in zip(csv_rows[1:], exported):
        if stored[0] != expected[0] or int(stored[1]) != expected[1]:
            raise Blocked("CSV provenance mismatch")
        # %.17g roundtrips finite doubles; NaN positions compared separately.
        if not np.array_equal(np.array(stored[2:], dtype=float), expected[2:], equal_nan=True):
            raise Blocked("CSV/MAT mismatch (no rounded CSV used for ranks)")
    return dict(seed=seed, valid=True, rows=rows, all_rows=all_rows, excluded=excluded,
                final_count=len(exported), metadata=meta)


def encode(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, allow_nan=False)


def write_json(path, value):
    with Path(path).open("x", encoding="utf-8", newline="\n") as f:
        f.write(encode(value)+"\n")


def write_csv(path, rows, fields):
    with Path(path).open("x", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: encode(row.get(k)) if isinstance(row.get(k), (list, dict))
                             else row.get(k) for k in fields})


def benchmark_from_manifest(path):
    """Explicit MAT path/field/hash mapping; never discovers latest or reads as initialization."""
    from scipy.io import loadmat
    m = read_json(path)
    if m["name"] not in ("HB200_CURRENT", "C") or m["basis"] != "CURRENT_COST_E3D":
        raise Blocked("Benchmark identity/basis missing")
    if m["objective_blob"] != "d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc":
        raise Blocked("Benchmark objective mismatch")
    source = (Path(path).parent/m["mat_path"]).resolve()
    if source.suffix.lower() != ".mat" or sha(source) != m["sha256"]:
        raise Blocked("Benchmark primary MAT hash mismatch")
    raw = loadmat(source, simplify_cells=True)
    def field(key):
        obj = raw
        for part in key.split("."):
            obj = obj[part]
        return obj
    xs, fs = matrix(field(m["x_field"]),4), matrix(field(m["f_field"]),3)
    expected = 44 if m["name"] == "HB200_CURRENT" else 9
    if len(xs) != expected or len(fs) != expected:
        raise Blocked("Benchmark count mismatch")
    rows = [dict(x=x.tolist(), f=f.tolist(), id=i+1) for i,(x,f) in enumerate(zip(xs,fs))]
    if any(not finite_vector(r["x"],4) or not finite_vector(r["f"],3) for r in rows):
        raise Blocked("Nonfinite benchmark")
    return m["name"], rows


def postrun(run, acknowledge=False, benchmarks=()):
    if acknowledge is not True:
        raise Blocked("Postrun is opt-in; no real-data processing by default")
    from scipy.io import savemat
    import numpy as np
    run = Path(run).resolve()
    cfg = frozen_config()
    manifest = read_json(run/"CAMPAIGN_MANIFEST.json")
    if (manifest["status"] != "COMPLETED_PENDING_POSTRUN" or manifest["seeds"] != list(SEEDS) or
        manifest["protocol_sha256"] != PROTOCOL_HASH or manifest["config_sha256"] != CONFIG_HASH or
        manifest["source_lock_sha256"] != LOCK_HASH):
        raise Blocked("Campaign incomplete or configuration mismatch")
    if sorted(p.name for p in run.glob("seed_*")) != [f"seed_{s}" for s in SEEDS]:
        raise Blocked("Extra/missing seed directory")
    identity = read_json(run/"audit/SOFTWARE_IDENTITY.json")
    if identity["sources"] != read_json(HERE/"source_lock.json"):
        raise Blocked("Recorded software provenance differs")
    # PHASE 1 — PREFLIGHT READ-ONLY. No derived path is touched here.
    audits = [audit_seed(run/f"seed_{s}", cfg) for s in SEEDS]
    if len(benchmarks) != 2:
        raise Blocked("Exactly the frozen HB200_CURRENT and C benchmark manifests are required")
    benchmark_data = []
    seen = set()
    for path in benchmarks:
        name, data = benchmark_from_manifest(path)
        if name in seen:
            raise Blocked("Duplicate benchmark")
        seen.add(name)
        benchmark_data.append((name, data))
    if seen != {"HB200_CURRENT", "C"}:
        raise Blocked("Both HB200_CURRENT and C benchmarks are required")
    result = analyze(audits)
    if not result.get("pool"):
        raise Blocked("Pool unavailable: "+str(result))
    relative_outputs = [
        "audit/POSTRUN_INTEGRITY.json", "audit/DOMINANCE_AUDIT.json",
        "audit/PRIMARY_SUFFICIENCY.json", "tables/ALL_RUNS.csv",
        "tables/N_R.csv", "tables/N_POOL.csv", "tables/INTER_RUN_METRICS.csv",
        "tables/BENCHMARK_COMPARISON.csv", "numeric/N_POOL.mat",
        "SHA256_MANIFEST.csv",
    ]
    if result["PRIMARY_SUFFICIENCY"] == "PASS":
        relative_outputs.append("tables/OPERATING_RECOMMENDATIONS.csv")
    final_outputs = [run/p for p in relative_outputs]
    if any(p.exists() for p in final_outputs):
        raise Blocked("Postrun output exists: no overwrite or automatic resume")
    for name in ("audit","tables","numeric","figures"):
        if not (run/name).is_dir():
            raise Blocked("Missing reserved output directory: "+name)

    # PHASE 2 — DERIVATION. Everything is built in an isolated sibling directory.
    staging = Path(tempfile.mkdtemp(prefix=f".{run.name}_postrun_", dir=run.parent))
    moved = []
    try:
        for name in ("audit","tables","numeric"):
            (staging/name).mkdir()
        write_json(staging/"audit/POSTRUN_INTEGRITY.json",
                   [{k:v for k,v in a.items() if k not in ("rows","all_rows")} for a in audits])
        union = result["union"]
        write_json(staging/"audit/DOMINANCE_AUDIT.json",
            dict(definition="EXACT_LE_ALL_LT_ANY", ranks=ranks(union),
                 near_ties=[(i,j) for i,a in enumerate(union) for j,b in enumerate(union)
                            if i<j and near_tie(a["f"],b["f"])],
                 normalization=result["normalization"], coverage=result["coverage"],
                 U_count=len(union), N_POOL_count=len(result["pool"]),
                 N_POOL_objective_count=result["N_POOL_objective_count"]))
        write_json(staging/"audit/PRIMARY_SUFFICIENCY.json",
                   {k:v for k,v in result.items()
                    if k not in ("pool","nr","union","recommendations")})
        fields=["seed","row","source","x","f","penalized","origins"]
        write_csv(staging/"tables/ALL_RUNS.csv",
                  [r for a in audits for r in a["all_rows"]],
                  ["seed","row","source","x","f","inclusion","reason"])
        write_csv(staging/"tables/N_R.csv",
                  [r for a in result["nr"].values() for r in a], fields)
        write_csv(staging/"tables/N_POOL.csv", result["pool"], fields)
        write_csv(staging/"tables/INTER_RUN_METRICS.csv",
                  result["metrics"], list(result["metrics"][0]))
        pool = result["pool"]
        savemat(staging/"numeric/N_POOL.mat",
                dict(X=np.array([r["x"] for r in pool]),
                     F=np.array([r["f"] for r in pool]),
                     lo=result["normalization"]["lo"],
                     hi=result["normalization"]["hi"],
                     provenance_json=encode(pool)), do_compression=True)
        pool_hash = sha(staging/"numeric/N_POOL.mat")
        comparisons = [
            dict(name=name, pool_sha256=pool_hash,
                 comparison=compare_benchmark(pool, data))
            for name, data in benchmark_data
        ]
        write_csv(staging/"tables/BENCHMARK_COMPARISON.csv", comparisons,
                  ["name","pool_sha256","comparison"])
        if result["PRIMARY_SUFFICIENCY"] == "PASS":
            policies=[]
            for name,row in result["recommendations"].items():
                d=row.get("detail",{})
                def get(group,key):
                    return d.get(group,{}).get(key,"NOT_RECOVERED")
                policies.append(dict(policy=name,x=row["x"],f=row["f"],origins=row["origins"],
                    t_rec=row["x"][3],dry_time_h=get("outputs","dry_time"),
                    LPG_mass_kg=get("cost","LPG_mass_kg"),
                    LPG_fuel_input_MJ=get("cost","LPG_fuel_input_MJ"),
                    Q_aux_useful_MJ=get("outputs","Q_aux_tot"),
                    electric_energy_kWh=get("cost","electric_energy_kWh"),
                    terminal_regime="NOT_RECOVERED",terminal_basis="NOT_DIRECTLY_PROPAGATED",
                    detail=d))
            write_csv(staging/"tables/OPERATING_RECOMMENDATIONS.csv",
                      policies, list(policies[0]))
        inventory=[]
        derived = {p.relative_to(staging).as_posix(): p
                   for p in staging.rglob("*") if p.is_file()}
        for p in sorted(run.rglob("*")):
            if p.is_file():
                rel=p.relative_to(run).as_posix()
                inventory.append(dict(path=rel,size=p.stat().st_size,sha256=sha(p)))
        for rel,p in sorted(derived.items()):
            inventory.append(dict(path=rel,size=p.stat().st_size,sha256=sha(p)))
        write_csv(staging/"SHA256_MANIFEST.csv",inventory,["path","size","sha256"])

        # PHASE 3 — PUBLISH. Roll back every newly moved file if publication fails.
        for rel in relative_outputs:
            src, dst = staging/rel, run/rel
            if not src.is_file() or dst.exists():
                raise Blocked("Publish precondition failed: "+rel)
            os.replace(src, dst)
            moved.append((src, dst))
    except BaseException:
        for src, dst in reversed(moved):
            if dst.exists():
                src.parent.mkdir(parents=True, exist_ok=True)
                os.replace(dst, src)
        raise
    finally:
        shutil.rmtree(staging, ignore_errors=True)
    return dict(status=result["PRIMARY_SUFFICIENCY"],
                pool_sha256=sha(run/"numeric/N_POOL.mat"),
                inventory_sha256=sha(run/"SHA256_MANIFEST.csv"),
                publish_status="COMPLETE_TRANSACTIONAL")


if __name__ == "__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--static",type=Path)
    ap.add_argument("--run",type=Path)
    ap.add_argument("--acknowledge-postrun",action="store_true")
    ap.add_argument("--benchmark",action="append",default=[])
    args=ap.parse_args()
    if args.static and not args.run:
        print(encode(static_check(args.static)))
    elif args.run and args.acknowledge_postrun and not args.static:
        print(encode(postrun(args.run,True,args.benchmark)))
    else:
        ap.error("Choose read-only --static ROOT or explicitly authorized --run with --acknowledge-postrun")
