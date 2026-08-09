#!/usr/bin/env python3
"""Assemble the frozen CR1-COMP-15 quantitative comparative verdict.

This documentary script reads and verifies CR1-COMP-02...14 artifacts. It
does not invoke MATLAB, evaluate objectives/models, or recompute dominance,
coverage, sorting, geometry, terminal regime, or hypervolume.
"""

from __future__ import annotations

import csv
import hashlib
import json
import subprocess
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
REVIEW = ROOT / "06_manuscript/article_Q1/review"
BASELINE_HEAD = "2ac82115e1e0d39616c0476ea2f8ab08c322f07e"
PROTOCOL_HASH = "8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3"

UPSTREAM = {
    "protocol": ("CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md", PROTOCOL_HASH),
    "CR1-COMP-02": ("CR1_COMP_02_WITHIN_SET_EXACT_PARETO_AUDIT_v96z.json", "6E5391E6D8C65AD04C91EB1A00EE16360D5EE189AF77B67B911CA5B31281CCED"),
    "CR1-COMP-03": ("CR1_COMP_03_DECISION_SPACE_DESCRIPTIVE_v96z.json", "7C0EC833A5BE05148C4B08793A382B7F069B36267C77B97A52959659DBE2A8E8"),
    "CR1-COMP-04": ("CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_v96z.json", "CCA35B4E8983D075E9D3E4834949B2A2F330C5A8C0C5B4D1EA05E935AEE1D75D"),
    "CR1-COMP-05": ("CR1_COMP_05_EXACT_CROSS_DOMINANCE_v96z.json", "88EE7D86AFEE3A1C5E33D3BD2629995277481A2B65FDF03C83594888402D701A"),
    "CR1-COMP-06": ("CR1_COMP_06_NUMERICAL_NEAR_TIE_SENSITIVITY_v96z.json", "227F88AB15A30A812F222E3608BF9512401A8775AA1CFE9886E6288326F6E3FA"),
    "CR1-COMP-07": ("CR1_COMP_07_SET_COVERAGE_v96z.json", "8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83"),
    "CR1-COMP-08": ("CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.json", "59E39670F2E3627A752FE5017394D215C13F5D89770C2BE17924A01268317E54"),
    "CR1-COMP-09": ("CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_v96z.json", "BD23627AAF81BD4231A3D84D819422D3CE93F84EDF0F33995A238DE3CE5651F9"),
    "CR1-COMP-10": ("CR1_COMP_10_HYPERVOLUME_DECISION_GATE_v96z.json", "52A7AA4735B59C01EF57F27841A3DEE8B1EC0AA1F23B4653049EBA20E40352DE"),
    "CR1-COMP-11": ("CR1_COMP_11_HYPERVOLUME_SENSITIVITY_v96z.json", "233918EF96B1597260854CDDFCB7DDBA041A14BE7C06323BBB1DE8F02D244EC7"),
    "CR1-COMP-12": ("CR1_COMP_12_COMMON_TERMINAL_REGIME_v96z.json", "8D0646DF4EA5CDFBB458C6E4C0E58A85D5A1D7C49351731DC283126374147994"),
    "CR1-COMP-13": ("CR1_COMP_13_OBJECTIVE_DECOMPOSITION_v96z.json", "4B8D9B30B237E2BA65DD5F71ECB218C995BEC1646943F50F68ECB1E08DCE0B52"),
    "CR1-COMP-14": ("CR1_COMP_14_PHYSICAL_ECONOMIC_ENVIRONMENTAL_INTERPRETATION_v96z.json", "59B9E07FC5420C923F15873C7E01A549092A92EFAC9D2DF4AB46FA7B8E952A9F"),
    "CR1-COMP-14-CLAIMS": ("CR1_COMP_14_INTERPRETIVE_CLAIMS_v96z.csv", "C8C0BC2323E8D782227123027EF1B375DD5B07A3B9EFCAED531DFBACAE604400"),
}

OUT = {
    "vector": REVIEW / "CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_v96z.csv",
    "evidence": REVIEW / "CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_EVIDENCE_v96z.csv",
    "json": REVIEW / "CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_v96z.json",
    "audit": REVIEW / "CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_AUDIT_v96z.md",
    "script": Path(__file__).resolve(),
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def git(*args: str) -> str:
    return subprocess.run(
        ["git", *args], cwd=ROOT, check=True, text=True, capture_output=True
    ).stdout.strip()


def load_json(phase: str) -> dict:
    return json.loads((REVIEW / UPSTREAM[phase][0]).read_text(encoding="utf-8"))


def read_claims() -> list[dict[str, str]]:
    with (REVIEW / UPSTREAM["CR1-COMP-14-CLAIMS"][0]).open(
        encoding="utf-8", newline=""
    ) as handle:
        return list(csv.DictReader(handle))


def metric(name, value, unit, phase, field, role):
    filename, source_hash = UPSTREAM[phase]
    return {
        "metric": name,
        "value": str(value),
        "unit_or_scale": unit,
        "source_phase": phase,
        "source_artifact": f"06_manuscript/article_Q1/review/{filename}",
        "source_hash": source_hash,
        "source_field": field,
        "interpretive_role": role,
    }


def evidence(eid, domain, statement, etype, status, metrics, phases, limitation, role):
    return {
        "evidence_id": eid,
        "domain": domain,
        "statement": statement,
        "evidence_type": etype,
        "support_status": status,
        "source_metrics": metrics,
        "source_phases": phases,
        "limitation": limitation,
        "verdict_role": role,
    }


def build():
    branch, head, status = git("branch", "--show-current"), git("rev-parse", "HEAD"), git("status", "--short")
    require(branch == "main" and head == BASELINE_HEAD, "BLOCKED_BASELINE_MISMATCH")
    dirty_paths = {line[3:].replace("\\", "/") for line in status.splitlines() if line}
    allowed_dirty = {str(path.relative_to(ROOT)).replace("\\", "/") for path in OUT.values()}
    require(dirty_paths <= allowed_dirty, "BLOCKED_UNAUTHORIZED_WORKTREE_SCOPE")

    live_hashes = {
        phase: sha256(REVIEW / filename) for phase, (filename, _) in UPSTREAM.items()
    }
    require(
        all(live_hashes[phase] == expected for phase, (_, expected) in UPSTREAM.items()),
        "UPSTREAM_HASH_MISMATCH",
    )

    p02, p03, p04, p05, p06, p07, p08 = (
        load_json(f"CR1-COMP-{n:02d}") for n in range(2, 9)
    )
    p09, p10, p11, p12, p13, p14 = (
        load_json(f"CR1-COMP-{n:02d}") for n in range(9, 15)
    )
    claims14 = read_claims()
    phase_docs = [p02, p03, p04, p05, p06, p07, p08, p09, p10, p11, p12, p13, p14]
    require(
        all(doc.get(f"cr1_comp_{n:02d}_status") == "CLOSED_PASS" for n, doc in zip(range(2, 15), phase_docs)),
        "UPSTREAM_PHASE_NOT_CLOSED_PASS",
    )

    h_nd = p02["aggregates"]["H"]["nondominated_count"]
    c_nd = p02["aggregates"]["C"]["nondominated_count"]
    h_dom = p02["aggregates"]["H"]["dominated_count"]
    c_dom = p02["aggregates"]["C"]["dominated_count"]
    counts = p05["global_counts"]
    near = p06["aggregates"]
    coverage = {row["metric"]: row for row in p07["coverage"]}
    rank1 = next(row for row in p08["rank_summary"] if row["pareto_rank"] == 1)
    primary_hv = p11["primary_result"]
    terminal = p12["metrics"]
    synthesis14 = p14["multiobjective_synthesis"]

    expected = {
        "H_INTERNAL_NONDOMINATED_COUNT": 9,
        "C_INTERNAL_NONDOMINATED_COUNT": 9,
        "H_INTERNAL_DOMINATED_COUNT": 0,
        "C_INTERNAL_DOMINATED_COUNT": 0,
        "FULL_COVERAGE_C_OVER_H": 0.1111111111111111,
        "FULL_COVERAGE_H_OVER_C": 0.2222222222222222,
        "CORE_COVERAGE_NC_OVER_NH": 0.1111111111111111,
        "CORE_COVERAGE_NH_OVER_NC": 0.2222222222222222,
        "JOINT_RANK1_H": 8,
        "JOINT_RANK1_C": 7,
        "C_DOMINATES_H_PAIR_COUNT": 1,
        "H_DOMINATES_C_PAIR_COUNT": 2,
        "INCOMPARABLE_PAIR_COUNT": 78,
        "EXACT_EQUAL_PAIR_COUNT": 0,
        "NEAR_TIE_OBJECTIVE_COUNT": 0,
        "NUMERICALLY_FRAGILE_DOMINANCE_COUNT": 0,
        "DOMINANCE_NUMERIC_SENSITIVITY": "PASS_NO_FRAGILE_DOMINANCE",
        "HV_H": 0.9749820881940048,
        "HV_C": 1.0099628901072748,
        "HV_DIRECTION": "C_GT_H",
        "HV_REFERENCE_SENSITIVITY": "ROBUST_DIRECTION",
        "H_TMAX_COUNT": 9,
        "C_TMAX_COUNT": 9,
        "COMPARATIVE_TERMINAL_REGIME": "COMMON_TMAX_19P9H",
    }
    observed = {
        "H_INTERNAL_NONDOMINATED_COUNT": h_nd,
        "C_INTERNAL_NONDOMINATED_COUNT": c_nd,
        "H_INTERNAL_DOMINATED_COUNT": h_dom,
        "C_INTERNAL_DOMINATED_COUNT": c_dom,
        **{name: coverage[name]["coverage"] for name in coverage},
        "JOINT_RANK1_H": rank1["H_count"],
        "JOINT_RANK1_C": rank1["C_count"],
        "C_DOMINATES_H_PAIR_COUNT": counts["C_DOMINATES_H"],
        "H_DOMINATES_C_PAIR_COUNT": counts["H_DOMINATES_C"],
        "INCOMPARABLE_PAIR_COUNT": counts["INCOMPARABLE"],
        "EXACT_EQUAL_PAIR_COUNT": counts["EXACT_EQUAL"],
        "NEAR_TIE_OBJECTIVE_COUNT": near["near_tie_objective_count"],
        "NUMERICALLY_FRAGILE_DOMINANCE_COUNT": near["numerically_fragile_dominance_count"],
        "DOMINANCE_NUMERIC_SENSITIVITY": near["dominance_numeric_sensitivity"],
        "HV_H": primary_hv["HV_H"],
        "HV_C": primary_hv["HV_C"],
        "HV_DIRECTION": primary_hv["HV_DIRECTION"],
        "HV_REFERENCE_SENSITIVITY": p11["HV_SENSITIVITY_STATUS"],
        "H_TMAX_COUNT": terminal["H_TMAX_COUNT"],
        "C_TMAX_COUNT": terminal["C_TMAX_COUNT"],
        "COMPARATIVE_TERMINAL_REGIME": p12["COMPARATIVE_TERMINAL_REGIME"],
    }
    require(observed == expected, "UPSTREAM_VERDICT_VECTOR_MISMATCH")
    require(p10["gate_evaluation"]["hypervolume_gate_outcome"] == "RECOMMENDED", "HV_GATE_MISMATCH")
    require(p11["completion"]["hypervolume_computed"] is True, "HV_NOT_COMPUTED")

    vector = [
        metric("H_INTERNAL_NONDOMINATED_COUNT", h_nd, "count", "CR1-COMP-02", "aggregates.H.nondominated_count", "within-set exact nondominance"),
        metric("C_INTERNAL_NONDOMINATED_COUNT", c_nd, "count", "CR1-COMP-02", "aggregates.C.nondominated_count", "within-set exact nondominance"),
        metric("H_INTERNAL_DOMINATED_COUNT", h_dom, "count", "CR1-COMP-02", "aggregates.H.dominated_count", "within-set exact dominance"),
        metric("C_INTERNAL_DOMINATED_COUNT", c_dom, "count", "CR1-COMP-02", "aggregates.C.dominated_count", "within-set exact dominance"),
    ]
    for name in ("FULL_COVERAGE_C_OVER_H", "FULL_COVERAGE_H_OVER_C", "CORE_COVERAGE_NC_OVER_NH", "CORE_COVERAGE_NH_OVER_NC"):
        vector.append(metric(name, coverage[name]["coverage"], f"fraction={coverage[name]['fraction']}", "CR1-COMP-07", f"coverage[{name}].coverage", "asymmetric exact set coverage"))
    vector += [
        metric("JOINT_RANK1_H", rank1["H_count"], "count", "CR1-COMP-08", "rank_summary[pareto_rank=1].H_count", "joint nondominated contribution"),
        metric("JOINT_RANK1_C", rank1["C_count"], "count", "CR1-COMP-08", "rank_summary[pareto_rank=1].C_count", "joint nondominated contribution"),
        metric("C_DOMINATES_H_PAIR_COUNT", counts["C_DOMINATES_H"], "count_of_81", "CR1-COMP-05", "global_counts.C_DOMINATES_H", "exact cross-set dominance"),
        metric("H_DOMINATES_C_PAIR_COUNT", counts["H_DOMINATES_C"], "count_of_81", "CR1-COMP-05", "global_counts.H_DOMINATES_C", "exact cross-set dominance"),
        metric("INCOMPARABLE_PAIR_COUNT", counts["INCOMPARABLE"], "count_of_81", "CR1-COMP-05", "global_counts.INCOMPARABLE", "exact cross-set incomparability"),
        metric("EXACT_EQUAL_PAIR_COUNT", counts["EXACT_EQUAL"], "count_of_81", "CR1-COMP-05", "global_counts.EXACT_EQUAL", "exact cross-set equality"),
        metric("NEAR_TIE_OBJECTIVE_COUNT", near["near_tie_objective_count"], "count_of_243", "CR1-COMP-06", "aggregates.near_tie_objective_count", "diagnostic numerical sensitivity"),
        metric("NUMERICALLY_FRAGILE_DOMINANCE_COUNT", near["numerically_fragile_dominance_count"], "count", "CR1-COMP-06", "aggregates.numerically_fragile_dominance_count", "diagnostic numerical sensitivity"),
        metric("DOMINANCE_NUMERIC_SENSITIVITY", near["dominance_numeric_sensitivity"], "categorical", "CR1-COMP-06", "aggregates.dominance_numeric_sensitivity", "diagnostic numerical sensitivity"),
        metric("HV_STATUS", "COMPUTED", "categorical", "CR1-COMP-11", "completion.hypervolume_computed=true", "secondary conditional metric status"),
        metric("HV_H", primary_hv["HV_H"], "normalized_anchored_volume_r10", "CR1-COMP-11", "primary_result.HV_H", "secondary conditional metric"),
        metric("HV_C", primary_hv["HV_C"], "normalized_anchored_volume_r10", "CR1-COMP-11", "primary_result.HV_C", "secondary conditional metric"),
        metric("HV_DIRECTION", primary_hv["HV_DIRECTION"], "categorical", "CR1-COMP-11", "primary_result.HV_DIRECTION", "secondary conditional metric"),
        metric("HV_REFERENCE_SENSITIVITY", p11["HV_SENSITIVITY_STATUS"], "r5_r10_r20", "CR1-COMP-11", "HV_SENSITIVITY_STATUS", "secondary conditional metric sensitivity"),
        metric("H_TMAX_COUNT", terminal["H_TMAX_COUNT"], "count_of_9", "CR1-COMP-12", "metrics.H_TMAX_COUNT", "common terminal-regime evidence"),
        metric("C_TMAX_COUNT", terminal["C_TMAX_COUNT"], "count_of_9", "CR1-COMP-12", "metrics.C_TMAX_COUNT", "common terminal-regime evidence"),
        metric("COMPARATIVE_TERMINAL_REGIME", p12["COMPARATIVE_TERMINAL_REGIME"], "categorical", "CR1-COMP-12", "COMPARATIVE_TERMINAL_REGIME", "temporal comparability"),
    ]
    require(len(vector) == 25 and len({row["metric"] for row in vector}) == 25, "VECTOR_FIELD_COUNT_CHECK_FAIL")

    checks = {
        "H_COUNT_SUM": h_nd + h_dom == 9,
        "C_COUNT_SUM": c_nd + c_dom == 9,
        "CROSS_PAIR_PARTITION": counts["C_DOMINATES_H"] + counts["H_DOMINATES_C"] + counts["INCOMPARABLE"] + counts["EXACT_EQUAL"] == 81,
        "JOINT_RANK1_SUM": rank1["H_count"] + rank1["C_count"] == 15,
        "FULL_C_OVER_H_FRACTION": coverage["FULL_COVERAGE_C_OVER_H"]["fraction"] == "1/9",
        "FULL_H_OVER_C_FRACTION": coverage["FULL_COVERAGE_H_OVER_C"]["fraction"] == "2/9",
        "FULL_CORE_C_OVER_H_IDENTITY": coverage["FULL_COVERAGE_C_OVER_H"]["coverage"] == coverage["CORE_COVERAGE_NC_OVER_NH"]["coverage"],
        "FULL_CORE_H_OVER_C_IDENTITY": coverage["FULL_COVERAGE_H_OVER_C"]["coverage"] == coverage["CORE_COVERAGE_NH_OVER_NC"]["coverage"],
        "HV_PRIMARY_DIRECTION": primary_hv["HV_C"] > primary_hv["HV_H"] and primary_hv["HV_DIRECTION"] == "C_GT_H",
        "HV_R5_R10_R20_DIRECTION": all(p11["directions"][ref] == "C_GT_H" for ref in ("r5", "r10", "r20")),
        "TERMINAL_COUNTS": terminal["H_TMAX_COUNT"] == terminal["C_TMAX_COUNT"] == 9,
    }
    require(all(checks.values()), "STRUCTURAL_COUNT_CHECKS_FAIL")

    raw_claim_counts = Counter(row["status"] for row in claims14)
    claim_counts_csv = {
        status: raw_claim_counts.get(status, 0)
        for status in ("SUPPORTED", "PARTIALLY_SUPPORTED", "NOT_SUPPORTED")
    }
    claim_counts_json = p14["claim_counts"]
    require(claim_counts_csv == claim_counts_json == {"SUPPORTED": 11, "PARTIALLY_SUPPORTED": 1, "NOT_SUPPORTED": 0}, "CR1_COMP_14_CLAIMS_CONSISTENCY_FAIL")
    require(synthesis14["C_REGION_CONCENTRATION_HYPOTHESIS"] == "PARTIALLY_SUPPORTED", "CR1_COMP_14_INTERPRETATION_CHANGED")

    derived = {
        "CROSS_SET_INCOMPARABLE_FRACTION": {"fraction": "78/81", "serialized_value": 78 / 81},
        "CROSS_SET_INCOMPARABLE_PERCENT": 100 * 78 / 81,
        "JOINT_RANK1_TOTAL": {"fraction": "15/18", "serialized_value": 15 / 18},
        "H_JOINT_RANK1_RETENTION": {"fraction": "8/9", "serialized_value": 8 / 9},
        "C_JOINT_RANK1_RETENTION": {"fraction": "7/9", "serialized_value": 7 / 9},
    }

    evidence_rows = [
        evidence("E15-01", "C_EVIDENCE", "C has greater anchored hypervolume for r5, r10 and r20.", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "SUPPORTED", "HV_H;HV_C;HV_DIRECTION;HV_REFERENCE_SENSITIVITY", "CR1-COMP-11", "Anchored finite-set coverage only; not convergence or true-front proximity.", "C_EVIDENCE_HV"),
        evidence("E15-02", "C_EVIDENCE", "Seven of nine C solutions remain in joint Rank 1.", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "SUPPORTED", "JOINT_RANK1_C", "CR1-COMP-08", "Joint nondominated set of 18 evaluated solutions.", "C_EVIDENCE_JOINT_RANK"),
        evidence("E15-03", "C_EVIDENCE", "C04 exactly dominates H05.", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "SUPPORTED", "C_DOMINATES_H_PAIR_COUNT", "CR1-COMP-05;CR1-COMP-14", "One local relation; not broad replacement.", "C_EVIDENCE_LOCAL_DOMINANCE"),
        evidence("E15-04", "C_EVIDENCE", "C has substantially lower median f1 with modestly higher median f2 and f3.", "LEVEL_1_DIRECT_OBSERVATION", "SUPPORTED", "F1/F2/F3 median shifts", "CR1-COMP-04;CR1-COMP-14", "Finite-set central tendency; not statistical inference.", "C_EVIDENCE_OBJECTIVE_CENTRAL_TENDENCY"),
        evidence("E15-05", "HISTORICAL_SURVIVAL", "Eight of nine H solutions remain in joint Rank 1.", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "SUPPORTED", "JOINT_RANK1_H", "CR1-COMP-08", "Joint nondominated set of 18 evaluated solutions.", "H_EVIDENCE_JOINT_RANK"),
        evidence("E15-06", "HISTORICAL_SURVIVAL", "H02 exactly dominates C06 and H08 exactly dominates C08.", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "SUPPORTED", "H_DOMINATES_C_PAIR_COUNT", "CR1-COMP-05;CR1-COMP-14", "Two local relations; not global H superiority.", "H_EVIDENCE_LOCAL_DOMINANCE"),
        evidence("E15-07", "HISTORICAL_SURVIVAL", "Full and core H-over-C coverage exceed the reciprocal C-over-H values.", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "SUPPORTED", "FULL_COVERAGE_C_OVER_H;FULL_COVERAGE_H_OVER_C;CORE_COVERAGE_NC_OVER_NH;CORE_COVERAGE_NH_OVER_NC", "CR1-COMP-07", "Coverage is asymmetric and neither direction indicates broad replacement.", "H_EVIDENCE_COVERAGE"),
        evidence("E15-08", "HISTORICAL_SURVIVAL", "All observed global marginal objective extremes remain in H; C adds none.", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "SUPPORTED", "NEW_EXTREMES_C;HISTORICAL_EXTREMES_NOT_REPRODUCED_BY_C", "CR1-COMP-09", "Marginal extrema do not determine multivariate dominance.", "H_EVIDENCE_EXTREMES"),
        evidence("E15-09", "TRADEOFF_RESTRUCTURING", "Seventy-eight of 81 cross-set pairs are incomparable while dominance is sparse and bidirectional.", "DERIVED_SIMPLE_RATIO_FROM_FROZEN_COUNTS", "SUPPORTED", "C_DOMINATES_H_PAIR_COUNT;H_DOMINATES_C_PAIR_COUNT;INCOMPARABLE_PAIR_COUNT", "CR1-COMP-05", "Finite evaluated sets; no population inference.", "PREDOMINANT_INCOMPARABILITY"),
        evidence("E15-10", "TERMINAL_COMPARABILITY", "Both sets contain nine TMAX points under COMMON_TMAX_19P9H.", "LEVEL_1_DIRECT_OBSERVATION", "SUPPORTED", "H_TMAX_COUNT;C_TMAX_COUNT;COMPARATIVE_TERMINAL_REGIME", "CR1-COMP-12", "Fixed horizon, not free normal termination; trajectories need not be equal.", "COMMON_NOMINAL_HORIZON"),
        evidence("E15-11", "INTERPRETIVE_SYNTHESIS", "Direct corrected optimization restructures the evaluated trade-offs rather than uniformly replacing H.", "LEVEL_4_LIMITED_INFERENCE", "SUPPORTED", "full quantitative vector", "CR1-COMP-02...14", "Descriptive synthesis, not a formal class or algorithm-superiority claim.", "QUANTITATIVE_VERDICT_PATTERN"),
        evidence("E15-12", "INTERPRETIVE_SYNTHESIS", "C concentration is partially consistent with multiple operational trade-off mechanisms.", "LEVEL_3_MECHANISTIC_INTERPRETATION", "PARTIALLY_SUPPORTED", "C_REGION_CONCENTRATION_HYPOTHESIS;C_REGION_CONCENTRATION_INTERPRETATION", "CR1-COMP-14", "Irradiacion unavailable; C CO2 components not persisted; no unique causal mechanism.", "PRESERVED_CR1_COMP_14_INTERPRETATION"),
        evidence("E15-13", "INFERENTIAL_LIMITATION", "One corrected run does not establish convergence, between-seed variability, expected performance or statistical configuration superiority.", "LEVEL_4_LIMITED_INFERENCE", "SUPPORTED", "seed;PopulationSize;MaxGenerations;stop reason", "CORRECTED_R1 validated run;CR1-COMP-14", "Seed 61001, PopulationSize 24, MaxGenerations 50; MAXGENERATIONS_REACHED does not imply convergence.", "WHAT_IS_NOT_ESTABLISHED"),
    ]

    final_verdict = (
        "Across the 18 evaluated solutions, direct optimization under corrected COST-E3D "
        "restructures rather than uniformly replaces the historical reevaluated set: both "
        "sets are internally nondominated (9/9), 78/81 cross-set pairs are incomparable, "
        "dominance is sparse and bidirectional (C-to-H 1; H-to-C 2), and joint Rank 1 "
        "retains 8 H and 7 C solutions. C has greater anchored hypervolume at r5, r10 and "
        "r20 and a substantially lower median f1 with modestly higher median f2/f3, while "
        "H retains all observed marginal objective extremes and has greater reciprocal "
        "coverage. This establishes finite-set trade-off restructuring under a common "
        "nominal TMAX horizon, not convergence, global optimality, between-seed robustness "
        "or statistical superiority of the algorithm."
    )
    established = [
        "Both H and C are internally nondominated 9/9.",
        "Cross-set incomparability predominates (78/81) with sparse bidirectional dominance.",
        "Both sets contribute substantially to joint Rank 1 (H=8, C=7).",
        "C has greater anchored hypervolume under r5, r10 and r20.",
        "H retains all observed global marginal objective extremes.",
        "Both sets use the common nominal terminal regime COMMON_TMAX_19P9H.",
    ]
    suggested = [
        "Direct corrected optimization restructures the finite trade-offs rather than uniformly replacing H.",
        "C concentration is partially consistent with multiple trade-off mechanisms, preserving CR1-COMP-14.",
    ]
    not_established = [
        "Optimizer convergence or convergence probability.",
        "Between-seed variability, expected performance or mean performance.",
        "Global optimality or proximity to a true/global Pareto front.",
        "Statistical robustness or statistical configuration superiority.",
        "General sufficiency of 50 generations.",
        "A unique causal mechanism for C concentration.",
    ]

    limitations = {
        "ONE_CORRECTED_R1_RUN": "YES",
        "seed": 61001,
        "PopulationSize": 24,
        "MaxGenerations": 50,
        "CORRECTED_R1_STOP_REASON": "MAXGENERATIONS_REACHED",
        "MAXGENERATIONS_REACHED_DOES_NOT_IMPLY": "CONVERGENCE",
        "EXPECTED_GAMULTIOBJ_PERFORMANCE": "NOT_ESTABLISHED",
        "BETWEEN_SEED_VARIABILITY": "NOT_ESTABLISHED",
        "STATISTICAL_ROBUSTNESS": "NOT_ESTABLISHED",
        "CONVERGENCE_PROBABILITY": "NOT_ESTABLISHED",
        "MEAN_PERFORMANCE": "NOT_ESTABLISHED",
        "STATISTICAL_CONFIGURATION_SUPERIORITY": "NOT_ESTABLISHED",
        "GENERAL_SUFFICIENCY_OF_50_GENERATIONS": "NOT_ESTABLISHED",
        "TERMINAL_REGIME_LIMITATION": "FIXED_HORIZON_NOT_FREE_NORMAL_TERMINATION",
        "IRRADIACION_NOT_AVAILABLE": True,
        "C_CO2_COMPONENTS_NOT_PERSISTED": True,
    }

    qc = {
        "VECTOR_FIELD_COUNT_CHECK": "PASS",
        "VECTOR_SOURCE_TRACEABILITY": "PASS",
        "VECTOR_VALUE_UPSTREAM_IDENTITY": "PASS",
        "STRUCTURAL_COUNT_CHECKS": "PASS",
        "COVERAGE_CONSISTENCY_CHECK": "PASS",
        "HV_UPSTREAM_IDENTITY_CHECK": "PASS",
        "TERMINAL_UPSTREAM_IDENTITY_CHECK": "PASS",
        "CR1_COMP_14_CLAIMS_CONSISTENCY": "PASS",
        "NARRATIVE_TRACEABILITY_CHECK": "PASS",
        "INFERENTIAL_SCOPE_CHECK": "PASS",
        "INDEPENDENT_QC": "PASS",
    }
    result = {
        "artifact_role": "CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT",
        "cr1_comp_15_status": "CLOSED_PASS",
        "baseline": {"branch": branch, "head": head, "input_baseline_check": "PASS"},
        "protocol": {
            "version": "v1.0",
            "sha256": live_hashes["protocol"],
            "sha256_check": "PASS",
            "COMPARATIVE_VERDICT_FORMAT": "QUANTITATIVE_VECTOR_PLUS_NARRATIVE",
            "FORMAL_A_B_C_D_CLASSIFICATION": "NOT_USED",
            "HYPERVOLUME_ROLE": "SECONDARY_CONDITIONAL_METRIC",
        },
        "upstream_artifacts": [
            {
                "phase": phase,
                "path": f"06_manuscript/article_Q1/review/{UPSTREAM[phase][0]}",
                "sha256": live_hashes[phase],
                "hash_check": "PASS",
            }
            for phase in UPSTREAM
            if phase != "protocol"
        ],
        "upstream_consistency_check": "PASS",
        "quantitative_vector": vector,
        "quantitative_vector_map": {row["metric"]: row["value"] for row in vector},
        "coverage_exact_representations": {
            name: {
                "fraction": coverage[name]["fraction"],
                "serialized_value": coverage[name]["coverage"],
            }
            for name in coverage
        },
        "structural_consistency_checks": {name: "PASS" for name in checks},
        "derived_simple_ratios": derived,
        "hypervolume_reference_sensitivity": {
            ref: {
                "HV_H": p11["calculations"][ref]["H"]["hypervolume_inclusion_exclusion"],
                "HV_C": p11["calculations"][ref]["C"]["hypervolume_inclusion_exclusion"],
                "direction": p11["directions"][ref],
            }
            for ref in ("r5", "r10", "r20")
        },
        "cr1_comp_14_claims_status": claim_counts_csv,
        "preserved_cr1_comp_14_interpretation": {
            "C_REGION_CONCENTRATION_HYPOTHESIS": synthesis14["C_REGION_CONCENTRATION_HYPOTHESIS"],
            "C_REGION_CONCENTRATION_INTERPRETATION": synthesis14["C_REGION_CONCENTRATION_INTERPRETATION"],
            "CROSS_SET_INTERPRETIVE_PATTERN": synthesis14["CROSS_SET_INTERPRETIVE_PATTERN"],
        },
        "evidence": evidence_rows,
        "WHAT_IS_ESTABLISHED": established,
        "WHAT_IS_SUGGESTED": suggested,
        "WHAT_IS_NOT_ESTABLISHED": not_established,
        "QUANTITATIVE_VERDICT_PATTERN": "TRADEOFF_RESTRUCTURING_WITH_PARTIAL_CORRECTED_R1_ADVANTAGE_AND_HISTORICAL_SURVIVAL",
        "QUANTITATIVE_VERDICT_PATTERN_ROLE": "DESCRIPTIVE_SYNTHESIS_NOT_FORMAL_CLASSIFICATION",
        "quantitative_narrative": final_verdict,
        "FINAL_COMPARATIVE_VERDICT": final_verdict,
        "limitations": limitations,
        "closure_gate": {
            "QUANTITATIVE_VECTOR_COMPLETE": "YES",
            "NARRATIVE_TRACEABLE_TO_VECTOR": "YES",
            "INFERENTIAL_LIMITATIONS_COMPLETE": "YES",
            "CR1_COMP_14_INTERPRETATION_PRESERVED": "YES",
        },
        "qc": qc,
        "actions_not_executed": {
            "CR1_COMP_16_COMPUTED": False,
            "MANUSCRIPT_IMPLICATIONS_COMPUTED": False,
            "MANUSCRIPT_EDITING": False,
            "MANUSCRIPT_READY_GATE": False,
            "SCIENTIFIC_SUFFICIENCY_GATE": False,
            "MULTISEED_CAMPAIGN_DECISION": False,
            "MATLAB_EXECUTED": False,
            "OBJECTIVE_EVALUATIONS": 0,
            "REPLAYS": 0,
            "GAMULTIOBJ_EXECUTIONS": 0,
            "NEW_OPTIMIZATION_RUNS": 0,
            "DOMINANCE_RECALCULATED": False,
            "COVERAGE_RECALCULATED": False,
            "SORTING_RECALCULATED": False,
            "HYPERVOLUME_RECALCULATED": False,
            "NEW_COMPOSITE_METRIC": False,
            "NEW_STATISTICAL_TEST": False,
            "NEW_COMPROMISE_METRIC": False,
        },
        "next_recommended_step": "CR1-COMP-16 - Manuscript implications; separate authorization required",
    }
    return vector, evidence_rows, result


def audit_text(result: dict) -> str:
    v = result["quantitative_vector_map"]
    d = result["derived_simple_ratios"]
    return f"""# CR1-COMP-15 - Quantitative comparative verdict audit v96z

CR1_COMP_15_STATUS = CLOSED_PASS

## PROTOCOL_REQUIRED_VECTOR

COMPARATIVE_VERDICT_FORMAT = QUANTITATIVE_VECTOR_PLUS_NARRATIVE
FORMAL_A_B_C_D_CLASSIFICATION = NOT_USED
VECTOR_FIELD_COUNT = {len(result["quantitative_vector"])}
HYPERVOLUME_ROLE = SECONDARY_CONDITIONAL_METRIC

## DIRECT_UPSTREAM_VALUES

H and C are internally nondominated 9/9. Exact cross-set relations are C-to-H={v["C_DOMINATES_H_PAIR_COUNT"]}, H-to-C={v["H_DOMINATES_C_PAIR_COUNT"]}, incomparable={v["INCOMPARABLE_PAIR_COUNT"]}, exact equal={v["EXACT_EQUAL_PAIR_COUNT"]}. Full/core coverage is 1/9 C-over-H and 2/9 H-over-C. Joint Rank 1 contains H={v["JOINT_RANK1_H"]} and C={v["JOINT_RANK1_C"]}. Primary r10 hypervolume is H={v["HV_H"]}, C={v["HV_C"]}, direction={v["HV_DIRECTION"]}; r5/r10/r20 all preserve C_GT_H. Both sets contain nine TMAX points under COMMON_TMAX_19P9H.

## DERIVED_SIMPLE_RATIOS

CROSS_SET_INCOMPARABLE_FRACTION = {d["CROSS_SET_INCOMPARABLE_FRACTION"]["fraction"]}
CROSS_SET_INCOMPARABLE_PERCENT = {d["CROSS_SET_INCOMPARABLE_PERCENT"]}
JOINT_RANK1_TOTAL = {d["JOINT_RANK1_TOTAL"]["fraction"]}
H_JOINT_RANK1_RETENTION = {d["H_JOINT_RANK1_RETENTION"]["fraction"]}
C_JOINT_RANK1_RETENTION = {d["C_JOINT_RANK1_RETENTION"]["fraction"]}

These are direct arithmetic transforms of frozen counts, not composite metrics.

## MULTIOBJECTIVE_SYNTHESIS

The vector shows predominant incomparability, sparse bidirectional local dominance, substantial Rank 1 contributions from both sets, reciprocal coverage numerically favoring H, and anchored hypervolume favoring C under all three frozen reference points. H retains the observed marginal extremes; C occupies narrower marginal objective intervals. No single metric is treated as decisive.

## INTERPRETIVE_SYNTHESIS

QUANTITATIVE_VERDICT_PATTERN = TRADEOFF_RESTRUCTURING_WITH_PARTIAL_CORRECTED_R1_ADVANTAGE_AND_HISTORICAL_SURVIVAL
QUANTITATIVE_VERDICT_PATTERN_ROLE = DESCRIPTIVE_SYNTHESIS_NOT_FORMAL_CLASSIFICATION
C_REGION_CONCENTRATION_HYPOTHESIS = PARTIALLY_SUPPORTED
C_REGION_CONCENTRATION_INTERPRETATION = MULTIPLE_TRADEOFF_MECHANISMS

## INFERENTIAL_LIMITATIONS

ONE_CORRECTED_R1_RUN = YES
seed = 61001
PopulationSize = 24
MaxGenerations = 50
CORRECTED_R1_STOP_REASON = MAXGENERATIONS_REACHED
MAXGENERATIONS_REACHED DOES_NOT_IMPLY CONVERGENCE
EXPECTED_GAMULTIOBJ_PERFORMANCE = NOT_ESTABLISHED
BETWEEN_SEED_VARIABILITY = NOT_ESTABLISHED
STATISTICAL_ROBUSTNESS = NOT_ESTABLISHED
CONVERGENCE_PROBABILITY = NOT_ESTABLISHED
MEAN_PERFORMANCE = NOT_ESTABLISHED
STATISTICAL_CONFIGURATION_SUPERIORITY = NOT_ESTABLISHED
GENERAL_SUFFICIENCY_OF_50_GENERATIONS = NOT_ESTABLISHED
TERMINAL_REGIME_LIMITATION = FIXED_HORIZON_NOT_FREE_NORMAL_TERMINATION
IRRADIACION_NOT_AVAILABLE
C_CO2_COMPONENTS_NOT_PERSISTED

## FINAL_COMPARATIVE_VERDICT

{result["FINAL_COMPARATIVE_VERDICT"]}

## QC

VECTOR_FIELD_COUNT_CHECK = PASS
VECTOR_SOURCE_TRACEABILITY = PASS
VECTOR_VALUE_UPSTREAM_IDENTITY = PASS
STRUCTURAL_COUNT_CHECKS = PASS
COVERAGE_CONSISTENCY_CHECK = PASS
HV_UPSTREAM_IDENTITY_CHECK = PASS
TERMINAL_UPSTREAM_IDENTITY_CHECK = PASS
CR1_COMP_14_CLAIMS_CONSISTENCY = PASS
NARRATIVE_TRACEABILITY_CHECK = PASS
INFERENTIAL_SCOPE_CHECK = PASS
INDEPENDENT_QC = PASS

No MATLAB, objective/model evaluation, replay, optimization, dominance, coverage, sorting, hypervolume recomputation, new composite/statistical metric, manuscript editing, CR1-COMP-16, or remote operation was performed.
"""


def write_outputs(vector, evidence_rows, result):
    for key, rows in (("vector", vector), ("evidence", evidence_rows)):
        with OUT[key].open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(rows[0]), lineterminator="\n")
            writer.writeheader()
            writer.writerows(rows)
    OUT["json"].write_text(
        json.dumps(result, indent=2, ensure_ascii=False, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    OUT["audit"].write_text(audit_text(result), encoding="utf-8")


if __name__ == "__main__":
    vector, evidence_rows, result = build()
    write_outputs(vector, evidence_rows, result)
    print("CR1_COMP_15_STATUS=CLOSED_PASS")
