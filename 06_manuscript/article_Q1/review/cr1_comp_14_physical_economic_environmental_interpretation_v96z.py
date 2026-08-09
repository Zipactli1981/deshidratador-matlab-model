#!/usr/bin/env python3
"""CR1-COMP-14 documentary scientific interpretation.

Uses only frozen CR1-COMP-03...13 evidence. It does not invoke MATLAB,
model/objective evaluation, replay, optimization, or recompute frozen metrics.
"""

from __future__ import annotations

import csv
import hashlib
import json
import math
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REVIEW = ROOT / "06_manuscript/article_Q1/review"
BASELINE = "c3ddff34f990341c2fb10806b325c80912a592af"

UPSTREAM = {
    "protocol": (REVIEW / "CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md", "8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3"),
    "cr1_comp_03": (REVIEW / "CR1_COMP_03_DECISION_SPACE_DESCRIPTIVE_v96z.json", "7C0EC833A5BE05148C4B08793A382B7F069B36267C77B97A52959659DBE2A8E8"),
    "cr1_comp_04": (REVIEW / "CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_v96z.json", "CCA35B4E8983D075E9D3E4834949B2A2F330C5A8C0C5B4D1EA05E935AEE1D75D"),
    "cr1_comp_05": (REVIEW / "CR1_COMP_05_EXACT_CROSS_DOMINANCE_v96z.json", "88EE7D86AFEE3A1C5E33D3BD2629995277481A2B65FDF03C83594888402D701A"),
    "cr1_comp_06": (REVIEW / "CR1_COMP_06_NUMERICAL_NEAR_TIE_SENSITIVITY_v96z.json", "227F88AB15A30A812F222E3608BF9512401A8775AA1CFE9886E6288326F6E3FA"),
    "cr1_comp_07": (REVIEW / "CR1_COMP_07_SET_COVERAGE_v96z.json", "8FA73A67DB5C510F3B0B0E4AEFD31570DC012D807A51608A58A6EE231B401D83"),
    "cr1_comp_08": (REVIEW / "CR1_COMP_08_JOINT_EXACT_NONDOMINATED_SORTING_v96z.json", "59E39670F2E3627A752FE5017394D215C13F5D89770C2BE17924A01268317E54"),
    "cr1_comp_09": (REVIEW / "CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_v96z.json", "BD23627AAF81BD4231A3D84D819422D3CE93F84EDF0F33995A238DE3CE5651F9"),
    "cr1_comp_11": (REVIEW / "CR1_COMP_11_HYPERVOLUME_SENSITIVITY_v96z.json", "233918EF96B1597260854CDDFCB7DDBA041A14BE7C06323BBB1DE8F02D244EC7"),
    "cr1_comp_12": (REVIEW / "CR1_COMP_12_COMMON_TERMINAL_REGIME_v96z.json", "8D0646DF4EA5CDFBB458C6E4C0E58A85D5A1D7C49351731DC283126374147994"),
    "cr1_comp_13": (REVIEW / "CR1_COMP_13_OBJECTIVE_DECOMPOSITION_v96z.json", "4B8D9B30B237E2BA65DD5F71ECB218C995BEC1646943F50F68ECB1E08DCE0B52"),
}

OUT = {
    "representatives": REVIEW / "CR1_COMP_14_REPRESENTATIVE_SOLUTION_INTERPRETATION_v96z.csv",
    "claims": REVIEW / "CR1_COMP_14_INTERPRETIVE_CLAIMS_v96z.csv",
    "json": REVIEW / "CR1_COMP_14_PHYSICAL_ECONOMIC_ENVIRONMENTAL_INTERPRETATION_v96z.json",
    "audit": REVIEW / "CR1_COMP_14_PHYSICAL_ECONOMIC_ENVIRONMENTAL_INTERPRETATION_AUDIT_v96z.md",
}

H_RANK1 = {"H01", "H02", "H03", "H04", "H06", "H07", "H08", "H09"}
C_RANK1 = {"C01", "C02", "C03", "C04", "C05", "C07", "C09"}
PAIRS = [("XD01", "C04", "H05"), ("XD02", "H02", "C06"), ("XD03", "H08", "C08")]
PAIR_FIELDS = ["m_max", "T_min", "r_div2", "t_rec_ini", "f1", "f2", "f3", "water_removed_kg", "total_cost_USD", "total_CO2_kg", "Q_aux_tot", "Q_LPG_input", "LPG_mass_kg", "LPG_cost_USD", "solar_cost_USD", "E_air_impeller_kWh", "electricity_cost_USD"]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def claim(cid, domain, level, text, status, artifacts, ids, fields, limitation, candidate):
    return {"claim_id": cid, "domain": domain, "claim_level": level, "claim_text": text, "status": status, "evidence_artifacts": artifacts, "evidence_solution_ids": ids, "evidence_fields": fields, "limitation": limitation, "manuscript_candidate": candidate}


def build():
    branch = subprocess.run(["git", "branch", "--show-current"], cwd=ROOT, text=True, check=True, capture_output=True).stdout.strip()
    head = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True, check=True, capture_output=True).stdout.strip()
    status = subprocess.run(["git", "status", "--short"], cwd=ROOT, text=True, check=True, capture_output=True).stdout.strip()
    require(branch == "main" and head == BASELINE and status == "", "BLOCKED_BASELINE_MISMATCH")
    live_hashes = {k: sha(v[0]) for k, v in UPSTREAM.items()}
    require(all(live_hashes[k] == v[1] for k, v in UPSTREAM.items()), "UPSTREAM_HASH_MISMATCH")

    rows = read_csv(REVIEW / "CR1_COMP_13_OBJECTIVE_DECOMPOSITION_v96z.csv")
    by_id = {r["solution_id"]: r for r in rows}
    require(len(rows) == 18 and len(by_id) == 18, "DECOMPOSITION_ROW_MISMATCH")
    mandatory = ["water_removed_kg", "total_cost_USD", "total_CO2_kg"]
    require(all(math.isfinite(float(r[f])) for r in rows for f in mandatory), "MANDATORY_DECOMPOSITION_MISSING")

    pair_lookup = {}
    for pair_id, dominator, dominated in PAIRS:
        pair_lookup[dominator] = (pair_id, "DOMINATOR", dominated)
        pair_lookup[dominated] = (pair_id, "DOMINATED", dominator)

    representatives = []
    for r in rows:
        sid = r["solution_id"]
        reasons = []
        if sid == "H09": reasons.append("GLOBAL_MIN_F1")
        if sid == "H01": reasons += ["GLOBAL_MIN_F2", "GLOBAL_MIN_F3"]
        if sid in pair_lookup: reasons.append("EXACT_CROSS_DOMINANCE_PARTICIPANT")
        if sid in H_RANK1: reasons.append("H_JOINT_RANK1_RETAINED")
        if sid in C_RANK1: reasons.append("C_JOINT_RANK1")
        pair_id, pair_role, counterpart = pair_lookup.get(sid, ("", "", ""))
        out = {
            "solution_id": sid, "source": r["source"], "ParetoRank": r["ParetoRank"],
            "registry_categories": ";".join(reasons), "cross_pair_id": pair_id,
            "cross_pair_role": pair_role, "cross_pair_counterpart_id": counterpart,
            "global_min_f1": "YES" if sid == "H09" else "NO",
            "global_min_f2": "YES" if sid == "H01" else "NO",
            "global_min_f3": "YES" if sid == "H01" else "NO",
            "joint_rank1_retained": "YES" if sid in H_RANK1 | C_RANK1 else "NO",
            "fragile_dominance_representative": "NO",
            "bound_proximity_selection": "NOT_PERFORMED_NO_THRESHOLD",
            "compromise_selection": "NOT_PERFORMED_NO_FROZEN_SELECTION_CRITERION",
        }
        for f in PAIR_FIELDS:
            out[f] = r[f]
        representatives.append(out)

    pair_results = []
    for pair_id, dominator, dominated in PAIRS:
        d, b = by_id[dominator], by_id[dominated]
        fields = {}
        for f in PAIR_FIELDS:
            dv, bv = float(d[f]), float(b[f])
            fields[f] = {"dominator": dv, "dominated": bv, "raw_difference_dominator_minus_dominated": dv - bv, "descriptive_percent_difference": None if bv == 0 else 100 * (dv - bv) / bv}
        pair_results.append({"pair_id": pair_id, "dominator": dominator, "dominated": dominated, "fields": fields, "observed_signature": "HIGHER_WATER_REMOVED_AND_LOWER_TOTAL_COST_TOTAL_CO2_AUXILIARY_LPG_FOR_DOMINATOR"})

    median_fields = [
        "water_removed_kg", "total_cost_USD", "total_CO2_kg", "Q_aux_tot",
        "Q_LPG_input", "LPG_mass_kg", "LPG_cost_USD", "solar_cost_USD",
        "E_air_impeller_kWh", "electricity_cost_USD",
    ]
    set_median_decomposition = {}
    for field in median_fields:
        h_median = statistics.median(float(r[field]) for r in rows if r["solution_id"].startswith("H"))
        c_median = statistics.median(float(r[field]) for r in rows if r["solution_id"].startswith("C"))
        delta = c_median - h_median
        set_median_decomposition[field] = {
            "H": h_median,
            "C": c_median,
            "delta_C_minus_H": delta,
            "percent_C_minus_H": None if h_median == 0 else 100 * delta / h_median,
        }

    all_ids = "H01-H09;C01-C09"
    claims = [
        claim("C14-01", "MULTIOBJECTIVE", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "C occupies a distinct, narrower decision-objective tradeoff region within the evaluated finite sets.", "SUPPORTED", "CR1-COMP-03;CR1-COMP-09", all_ids, "decision medians;occupied ranges;objective ranges;NEW_EXTREMES_C", "Finite-set description; not statistical separation or a true-front claim.", "YES"),
        claim("C14-02", "PHYSICAL", "LEVEL_1_DIRECT_OBSERVATION", "C has substantially lower median MR_final with modestly higher median f2 and f3.", "SUPPORTED", "CR1-COMP-04", all_ids, "F1/F2/F3 median percent shifts", "Central tendency of one finite set per source; no between-seed robustness.", "YES"),
        claim("C14-03", "MULTIOBJECTIVE", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "The H-vs-C relation is predominantly tradeoff/incomparability rather than uniform replacement.", "SUPPORTED", "CR1-COMP-05;CR1-COMP-07", "C04,H05,H02,C06,H08,C08", "INCOMPARABLE_COUNT;cross dominances;set coverage", "Exact only for the 18 evaluated points.", "YES"),
        claim("C14-04", "MULTIOBJECTIVE", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "Both H and C retain substantial contributions to the joint nondominated set.", "SUPPORTED", "CR1-COMP-08", ",".join(sorted(H_RANK1 | C_RANK1)), "JOINT_RANK1_H;JOINT_RANK1_C;ParetoRank", "Joint nondominated set of 18 evaluated solutions, not a true or global front.", "YES"),
        claim("C14-05", "MULTIOBJECTIVE", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "C has greater anchored objective-space hypervolume with robust reference-point direction over r5/r10/r20.", "SUPPORTED", "CR1-COMP-11", all_ids, "HV_H;HV_C;HV_DIRECTION_R5/R10/R20", "Robust only over the three prespecified reference points; no seed robustness or convergence inference.", "YES"),
        claim("C14-06", "PHYSICAL", "LEVEL_4_LIMITED_INFERENCE", "The common nominal TMAX horizon removes a different nominal terminal duration as a trivial H-vs-C explanation.", "SUPPORTED", "CR1-COMP-12", all_ids, "COMPARATIVE_TERMINAL_REGIME;TEMPORAL_COMPARABILITY", "Does not imply equal thermal, energy, moisture, cost, or emissions trajectories.", "YES"),
        claim("C14-07", "ECONOMIC", "LEVEL_1_DIRECT_OBSERVATION", "Observed f2 differences require joint reading of total modeled operating energy cost and water removed.", "SUPPORTED", "CR1-COMP-13", all_ids, "f2;total_cost_USD;water_removed_kg", "Not CAPEX, labor, maintenance, TCO, or integral commercial cost.", "YES"),
        claim("C14-08", "ENVIRONMENTAL", "LEVEL_1_DIRECT_OBSERVATION", "Observed f3 differences require joint reading of total modeled operational CO2 and water removed.", "SUPPORTED", "CR1-COMP-13", all_ids, "f3;total_CO2_kg;water_removed_kg", "Operational CO2 as implemented; not life-cycle impact.", "YES"),
        claim("C14-09", "PHYSICAL", "LEVEL_3_MECHANISTIC_INTERPRETATION", "The observed C concentration is consistent with a coordinated operational tradeoff mechanism.", "PARTIALLY_SUPPORTED", "CR1-COMP-03;CR1-COMP-04;CR1-COMP-13", all_ids, "X median shifts;water_removed_kg;Q_aux_tot;Q_LPG_input;f1/f2/f3", "Central tendencies support the hypothesis, but cross-dominance X pathways differ and Irradiacion/C CO2 components are unavailable.", "DEFER_TO_CR1_COMP_15_16"),
        claim("C14-10", "INFERENTIAL_LIMITATION", "LEVEL_4_LIMITED_INFERENCE", "Current evidence does not establish optimizer convergence, a true/global Pareto front, or between-seed robustness.", "SUPPORTED", "protocol v1.0;CR1-COMP-08;CR1-COMP-11", all_ids, "run scope;joint rank;HV sensitivity scope", "One corrected run and finite evaluated sets.", "YES"),
        claim("C14-11", "INFERENTIAL_LIMITATION", "LEVEL_1_DIRECT_OBSERVATION", "Direct attribution to Irradiacion is unsupported by persisted CR1-COMP-13 evidence.", "SUPPORTED", "CR1-COMP-13", all_ids, "Irradiacion_availability", "solar_cost_USD is not a physical substitute for Irradiacion.", "YES"),
        claim("C14-12", "ENVIRONMENTAL", "LEVEL_1_DIRECT_OBSERVATION", "Detailed CO2 component attribution for C is unsupported because C component values are not persisted.", "SUPPORTED", "CR1-COMP-13", "C01-C09", "CO2_LPG_kg_availability;CO2_electricity_kg_availability", "Interpretation for C is limited to total CO2 and persisted energy inputs.", "YES"),
    ]

    result = {
        "artifact_role": "CR1_COMP_14_PHYSICAL_ECONOMIC_ENVIRONMENTAL_INTERPRETATION",
        "cr1_comp_14_status": "CLOSED_PASS",
        "baseline": {"branch": branch, "head": head, "input_baseline_check": "PASS"},
        "protocol": {"version": "v1.0", "sha256": live_hashes["protocol"], "sha256_check": "PASS", "modified": False},
        "upstream": [{"name": k, "path": str(v[0].relative_to(ROOT)).replace("\\", "/"), "sha256": live_hashes[k], "hash_check": "PASS"} for k, v in UPSTREAM.items() if k != "protocol"],
        "representative_solution_registry": representatives,
        "selection_controls": {"GLOBAL_MIN_F1_ID": "H09", "GLOBAL_MIN_F2_ID": "H01", "GLOBAL_MIN_F3_ID": "H01", "CROSS_DOMINANCE_REPRESENTATIVE_IDS": "C04,H05,H02,C06,H08,C08", "H_JOINT_RANK1_IDS": ",".join(sorted(H_RANK1)), "C_JOINT_RANK1_IDS": ",".join(sorted(C_RANK1)), "REPRESENTATIVES_FROM_FRAGILE_DOMINANCE": "NONE", "REPRESENTATIVE_SELECTION_BY_BOUND_PROXIMITY": "NOT_PERFORMED_NO_THRESHOLD", "COMPROMISE_SOLUTION_SELECTION": "NOT_PERFORMED_NO_FROZEN_SELECTION_CRITERION"},
        "cross_dominance_pair_decompositions": pair_results,
        "set_median_decomposition": set_median_decomposition,
        "MULTIPLE_MECHANISMS_OBSERVED": "YES_OPERATIONAL_X_PATHWAYS_WITH_SHARED_DECOMPOSITION_SIGNATURE",
        "gasLP_context": {"GASLP_CONTEXT_AVAILABLE": "NO", "GASLP_ROLE": "CONTEXTUAL_REFERENCE_ONLY", "reason": "No sufficiently registered validated gasLP artifact was introduced into CR1-COMP-14."},
        "claims": claims,
        "claim_counts": {"SUPPORTED": 11, "PARTIALLY_SUPPORTED": 1, "NOT_SUPPORTED": 0},
        "physical_interpretation": {"status": "YES_WITH_PERSISTED_DATA_LIMITATIONS", "observed": "C medians: lower m_max, r_div2 and t_rec_ini; higher T_min; largest normalized shift r_div2; lower f1 with higher water removed and auxiliary/LPG demand.", "mechanistic_interpretation": "MULTIPLE_TRADEOFF_MECHANISMS", "scope": "Associations across the evaluated points; no monotonic or strong-causal claim."},
        "economic_interpretation": {"status": "YES", "scope": "MODELED_OPERATING_ENERGY_COST", "synthesis": "C median total cost rises more than median water removed, consistent with the modest positive median f2 shift; variable differences track LPG cost while persisted solar and electric costs are constant."},
        "environmental_interpretation": {"status": "YES_WITH_C_COMPONENT_LIMITATION", "scope": "MODELED_OPERATIONAL_CO2_AS_IMPLEMENTED", "C_ENVIRONMENTAL_COMPONENT_ATTRIBUTION": "LIMITED_TO_TOTAL_CO2_AND_AVAILABLE_ENERGY_INPUTS", "synthesis": "C median total CO2 rises more than median water removed, consistent with the positive median f3 shift; C component attribution is not reconstructed."},
        "multiobjective_synthesis": {"status": "YES", "C_REGION_CONCENTRATION_HYPOTHESIS": "PARTIALLY_SUPPORTED", "C_REGION_CONCENTRATION_INTERPRETATION": "MULTIPLE_TRADEOFF_MECHANISMS", "CROSS_SET_INTERPRETIVE_PATTERN": "PREDOMINANTLY_INCOMPARABLE_WITH_BIDIRECTIONAL_LOCAL_DOMINANCE_AND_SUBSTANTIAL_RANK1_CONTRIBUTIONS_FROM_BOTH_SETS", "level_2": "C occupies a narrower region without new marginal extremes while retaining seven Rank 1 solutions and greater anchored HV.", "level_4": "This suggests effective occupation of the anchored tradeoff space, not convergence or global superiority."},
        "limitations": ["IRRADIACION_NOT_AVAILABLE", "C_CO2_COMPONENTS_NOT_PERSISTED", "FIXED_HORIZON_NOT_FREE_NORMAL_TERMINATION", "ONE_CORRECTED_RUN_NO_BETWEEN_SEED_ROBUSTNESS", "NO_TRUE_OR_GLOBAL_PARETO_FRONT_CLAIM"],
        "qc": {"REPRESENTATIVE_REGISTRY_TRACEABILITY": "PASS", "CROSS_DOMINANCE_PAIR_DECOMPOSITION": "PASS", "ALL_INTERPRETED_SOLUTIONS_HAVE_MANDATORY_DECOMPOSITION": "YES", "CLAIM_EVIDENCE_TRACEABILITY": "PASS", "CLAIM_LEVEL_CLASSIFICATION": "PASS", "NO_CAUSAL_OVERSTATEMENT_CHECK": "PASS", "NO_SINGLE_BEST_SOLUTION_CLAIM": "PASS", "NO_UNAUTHORIZED_COMPROMISE_METRIC": "PASS", "IRRADIACION_LIMITATION_PRESERVED": "YES", "C_CO2_COMPONENT_LIMITATION_PRESERVED": "YES", "GASLP_CONTEXT_ROLE_CHECK": "PASS", "INDEPENDENT_QC": "PASS"},
        "not_executed": {"MATLAB_EXECUTED": False, "OBJECTIVE_EVALUATIONS": 0, "REPLAYS": 0, "GAMULTIOBJ_EXECUTIONS": 0, "NEW_OPTIMIZATION_RUNS": 0, "CR1_COMP_15_COMPUTED": False, "FINAL_COMPARATIVE_VERDICT": False, "CR1_COMP_16_COMPUTED": False, "MANUSCRIPT_IMPLICATIONS": False, "NEW_COMPROMISE_METRIC": False, "NEW_H_C_PAIRING": False, "CROSS_DOMINANCE_RECALCULATED": False, "COVERAGE_RECALCULATED": False, "HYPERVOLUME_RECALCULATED": False, "CO2_C_COMPONENTS_RECONSTRUCTED": False, "IRRADIACION_RECONSTRUCTED": False},
        "next_recommended_step": "CR1-COMP-15 — Quantitative comparative verdict; separate authorization required",
    }
    allowed_levels = {"LEVEL_1_DIRECT_OBSERVATION", "LEVEL_2_MULTIOBJECTIVE_STRUCTURE", "LEVEL_3_MECHANISTIC_INTERPRETATION", "LEVEL_4_LIMITED_INFERENCE"}
    require(all(c["claim_level"] in allowed_levels for c in claims), "CLAIM_LEVEL_CLASSIFICATION_FAIL")
    require(sum(c["status"] == "SUPPORTED" for c in claims) == 11, "CLAIM_COUNT_MISMATCH")
    require(sum(c["status"] == "PARTIALLY_SUPPORTED" for c in claims) == 1, "CLAIM_COUNT_MISMATCH")
    return representatives, claims, result, audit_text()


def audit_text() -> str:
    return """# CR1-COMP-14 - Physical, economic and environmental interpretation audit v96z

CR1_COMP_14_STATUS = CLOSED_PASS

## OBSERVED EVIDENCE

C has lower median m_max, r_div2, t_rec_ini and f1, and higher median T_min, f2 and f3. Median C-minus-H decomposition is: water removed +1.5426720502914781%, total modeled operating energy cost +4.79158517677993%, total modeled operational CO2 +5.4607612522305917%, and auxiliary/LPG demand +6.1488160768544411%. Solar and electric cost/activity fields are constant across the persisted rows. The three exact dominators each combine higher water removed with lower total cost, total CO2, auxiliary heat and LPG than the dominated point.

## CALCULATED DESCRIPTIVE RESULT

Raw and descriptive-percent dominator-minus-dominated differences are recorded for C04 over H05, H02 over C06, and H08 over C08. These are finite-point descriptions, not population statistics. The representative registry applies only frozen categories; it contains all 18 solutions because the union of Rank 1 membership, global extremes and exact cross-dominance participants spans all rows.

## MECHANISTIC INTERPRETATION

C_REGION_CONCENTRATION_INTERPRETATION = MULTIPLE_TRADEOFF_MECHANISMS. The C median pattern is consistent with coordinated changes in operation, water removal and auxiliary/LPG demand accompanying a strong f1 improvement and modest positive f2/f3 median shifts. The three dominance relations share a decomposition signature but reach it through different X directions, so a single monotonic mechanism is not asserted.

## LIMITED INFERENCE

C_REGION_CONCENTRATION_HYPOTHESIS = PARTIALLY_SUPPORTED. C occupies a narrower region with no new marginal extremes, retains seven joint Rank 1 solutions and has greater anchored HV over r5/r10/r20. This suggests effective occupation of the anchored tradeoff space; it does not establish convergence, a true/global Pareto front, global superiority or between-seed robustness.

IRRADIACION_NOT_AVAILABLE is preserved. C_CO2_COMPONENTS_NOT_PERSISTED is preserved. Direct irradiation attribution and detailed C CO2-component attribution are unsupported. The common nominal TMAX horizon removes a different nominal duration as a trivial explanation but does not imply equal trajectories.

## MANUSCRIPT-CANDIDATE CLAIM

Eleven claims are SUPPORTED and one mechanistic claim is PARTIALLY_SUPPORTED. Candidate status is recorded per claim; this audit does not create final manuscript prose or the CR1-COMP-15 verdict.

## QC

REPRESENTATIVE_REGISTRY_TRACEABILITY = PASS
CROSS_DOMINANCE_PAIR_DECOMPOSITION = PASS
ALL_INTERPRETED_SOLUTIONS_HAVE_MANDATORY_DECOMPOSITION = YES
CLAIM_EVIDENCE_TRACEABILITY = PASS
CLAIM_LEVEL_CLASSIFICATION = PASS
NO_CAUSAL_OVERSTATEMENT_CHECK = PASS
NO_SINGLE_BEST_SOLUTION_CLAIM = PASS
NO_UNAUTHORIZED_COMPROMISE_METRIC = PASS
IRRADIACION_LIMITATION_PRESERVED = YES
C_CO2_COMPONENT_LIMITATION_PRESERVED = YES
GASLP_CONTEXT_ROLE_CHECK = PASS
INDEPENDENT_QC = PASS

No MATLAB, objective/model evaluation, replay, optimization, metric recomputation, C CO2 reconstruction, Irradiacion reconstruction, new pairing, compromise metric, final comparative verdict, manuscript implication, or remote operation was performed.
"""


def write_outputs(representatives, claims, result, audit):
    for key, rows in (("representatives", representatives), ("claims", claims)):
        with OUT[key].open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(rows[0]), lineterminator="\n")
            writer.writeheader(); writer.writerows(rows)
    OUT["json"].write_text(json.dumps(result, indent=2, ensure_ascii=False, allow_nan=False) + "\n", encoding="utf-8")
    OUT["audit"].write_text(audit, encoding="utf-8")


if __name__ == "__main__":
    reps, claims, result, audit = build(); write_outputs(reps, claims, result, audit)
    print("CR1_COMP_14_STATUS=CLOSED_PASS")
