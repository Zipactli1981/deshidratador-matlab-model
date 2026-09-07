"""Pure, deterministic protocol mathematics. No MATLAB, subprocess or model imports."""
import math
import statistics

SEEDS = (61001, 61002, 61003, 61004, 61005)
LB = (.07, 45., 0., 0.)
UB = (.20, 70., .99, 19.)
REFERENCE = (1.1, 1.1, 1.1)


class Blocked(ValueError):
    pass


def finite_vector(v, n):
    return (len(v) == n and all(isinstance(t, (float, int)) and
            not isinstance(t, bool) and math.isfinite(t) for t in v))


def dominates(a, b):
    if not finite_vector(a, 3) or not finite_vector(b, 3):
        raise Blocked("Dominance requires three finite real objectives")
    return all(x <= y for x, y in zip(a, b)) and any(x < y for x, y in zip(a, b))


def nondominated(rows):
    return [r for r in rows if not any(dominates(s["f"], r["f"]) for s in rows)]


def ranks(rows):
    remaining = list(range(len(rows)))
    answer = [0] * len(rows)
    rank = 1
    while remaining:
        front = [i for i in remaining if not any(
            dominates(rows[j]["f"], rows[i]["f"]) for j in remaining)]
        for i in front:
            answer[i] = rank
        remaining = [i for i in remaining if i not in front]
        rank += 1
    return answer


def near_tie(a, b):
    return all(abs(x-y) <= 1e-12*max(1., abs(x), abs(y)) for x, y in zip(a, b))


def coverage(a, b):
    if not b:
        return None
    return sum(any(dominates(x["f"], y["f"]) for x in a) for y in b)/len(b)


def unique_designs(rows):
    result = {}
    for r in sorted(rows, key=lambda r: (r["seed"], r["row"])):
        x, f = tuple(r["x"]), tuple(r["f"])
        if not finite_vector(x, 4) or not finite_vector(f, 3):
            raise Blocked("Nonfinite pool candidate")
        if not all(l <= t <= u for l, t, u in zip(LB, x, UB)):
            raise Blocked("Out of bounds pool candidate")
        if r.get("penalized", True):
            raise Blocked("Penalized or unclassified pool candidate")
        if x in result and tuple(result[x]["f"]) != f:
            raise Blocked("Same design with different full precision scores")
        if x not in result:
            result[x] = dict(r, origins=[])
        for origin in r.get("origins", [[r["seed"], r["row"]]]):
            if origin not in result[x]["origins"]:
                result[x]["origins"].append(origin)
    return list(result.values())


def normalization(pool):
    if not pool:
        raise Blocked("Empty N_POOL")
    lo = tuple(min(r["f"][k] for r in pool) for k in range(3))
    hi = tuple(max(r["f"][k] for r in pool) for k in range(3))
    if any(h == l for h, l in zip(hi, lo)):
        raise Blocked("ZERO_RANGE: HV/IGD+/balanced NOT_DETERMINABLE")
    return lo, hi


def normalize(rows, lo, hi):
    return sorted(set(tuple((r["f"][k]-lo[k])/(hi[k]-lo[k]) for k in range(3))
                      for r in rows))


def igd_plus(reference, approximation):
    if not reference or not approximation:
        raise Blocked("Empty IGD+ set")
    return sum(min(math.sqrt(sum(max(q[k]-p[k], 0.)**2 for k in range(3)))
                   for q in approximation) for p in reference)/len(reference)


def hypervolume(points):
    """Deterministic x/y slab union of 3D boxes; no sampling or clipping."""
    if any(not finite_vector(p, 3) for p in points):
        raise Blocked("Invalid HV vector")
    r = REFERENCE
    inside = sorted(set(tuple(p) for p in points if all(p[k] <= r[k] for k in range(3))))
    outside = sum(not all(p[k] <= r[k] for k in range(3)) for p in points)
    xs = sorted(set([p[0] for p in inside]+[r[0]]))
    volume = 0.
    for left, right in zip(xs, xs[1:]):
        active = [p for p in inside if p[0] <= left]
        ys = sorted(set([p[1] for p in active]+[r[1]]))
        area = 0.
        for bottom, top in zip(ys, ys[1:]):
            zs = [p[2] for p in active if p[1] <= bottom]
            if zs:
                area += (top-bottom)*(r[2]-min(zs))
        volume += (right-left)*area
    return volume, outside


def recommendations(pool, sufficiency):
    if sufficiency != "PASS":
        raise Blocked("Recommendations require PRIMARY_SUFFICIENCY=PASS")
    lo, hi = normalization(pool)
    def tie(r):
        return tuple(r["f"])+tuple(r["x"])+(r["seed"], r["row"])
    policies = {}
    for k, name in enumerate(("MOISTURE_PRIORITY", "COST_PRIORITY", "EMISSIONS_PRIORITY")):
        policies[name] = min(pool, key=lambda r: (r["f"][k], tie(r)))
    def distance(r):
        return math.sqrt(sum(((r["f"][k]-lo[k])/(hi[k]-lo[k]))**2 for k in range(3)))
    policies["BALANCED_COMPROMISE"] = min(pool, key=lambda r: (distance(r), tie(r)))
    return policies


def analyze(runs):
    """runs: five audited records {seed, valid, rows}. Invalid data never rescues PASS."""
    if sorted(r["seed"] for r in runs) != list(SEEDS):
        raise Blocked("Five exact unique seeds required")
    if not all(r["valid"] is True for r in runs):
        return {"PRIMARY_SUFFICIENCY": "FAIL", "reason": "VALID_RUNS_NOT_5"}
    ar = {r["seed"]: unique_designs(r["rows"]) for r in runs}
    union = unique_designs([r for rows in ar.values() for r in rows])
    pool = nondominated(union)
    nr = {s: nondominated(ar[s]) for s in SEEDS}
    if not pool or any(not nr[s] for s in SEEDS):
        return {"PRIMARY_SUFFICIENCY": "FAIL", "reason": "EMPTY_SET"}
    lo, hi = normalization(pool)
    p = normalize(pool, lo, hi)
    metrics = []
    for s in SEEDS:
        q = normalize(nr[s], lo, hi)
        hv, outside = hypervolume(q)
        shared = [r for r in pool if any(o[0] == s for o in r["origins"])]
        exclusive = sum(len(set(o[0] for o in r["origins"])) == 1 for r in shared)
        metrics.append(dict(seed=s, A_count=len(ar[s]), N_count=len(nr[s]),
            objective_count=len(q), contribution=len(shared), exclusive=exclusive,
            contribution_fraction=len(shared)/len(pool),
            igd_plus=igd_plus(p, q), hv=hv, outside_reference=outside,
            extremes=[min(v[k] for v in q) for k in range(3)]))
    max_igd = max(m["igd_plus"] for m in metrics)
    median_igd = statistics.median(m["igd_plus"] for m in metrics)
    max_hv = max(m["hv"] for m in metrics)
    ratio = min(m["hv"] for m in metrics)/max_hv if max_hv > 0 else None
    reach = [sum(m["extremes"][k] <= .10 for m in metrics) for k in range(3)]
    conditions = dict(valid_runs=True, finite_nonpenalized=True,
        igd=max_igd <= .10 and median_igd <= .05,
        hv=ratio is not None and ratio >= .90, extremes=all(n >= 4 for n in reach))
    status = "PASS" if all(conditions.values()) else "FAIL"
    return dict(PRIMARY_SUFFICIENCY=status, conditions=conditions, metrics=metrics,
        normalization=dict(lo=lo, hi=hi), max_igd=max_igd, median_igd=median_igd,
        hv_ratio=ratio, extreme_runs=reach, pool=pool, nr=nr, union=union,
        N_POOL_objective_count=len(p),
        coverage=[dict(source=s, target=t, value=coverage(nr[s], nr[t]))
                  for s in SEEDS for t in SEEDS if s != t],
        recommendations=recommendations(pool, status) if status == "PASS" else {})


def compare_benchmark(pool, benchmark):
    """Input must already be current-basis full-precision, independently audited."""
    if not pool or not benchmark:
        raise Blocked("Empty benchmark")
    core = nondominated(benchmark)
    return dict(pool_to_full=coverage(pool, benchmark), full_to_pool=coverage(benchmark, pool),
        pool_to_core=coverage(pool, core), core_to_pool=coverage(core, pool),
        benchmark_core_count=len(core),
        pairs=[dict(pool_row=i, benchmark_row=j,
                    relation="POOL_DOMINATES" if dominates(a["f"], b["f"]) else
                    "BENCHMARK_DOMINATES" if dominates(b["f"], a["f"]) else
                    "EQUAL" if tuple(a["f"]) == tuple(b["f"]) else "INCOMPARABLE")
               for i, a in enumerate(pool) for j, b in enumerate(benchmark)])
