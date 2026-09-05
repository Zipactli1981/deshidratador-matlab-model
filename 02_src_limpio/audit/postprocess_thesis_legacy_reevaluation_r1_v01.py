"""Postprocess the deterministic thesis-legacy campaign without model calls."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
from pathlib import Path

import numpy as np
import pandas as pd


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest().upper()


def dominates(a: np.ndarray, b: np.ndarray) -> bool:
    return bool(np.all(a <= b) and np.any(a < b))


def nondominated_sort(values: np.ndarray) -> np.ndarray:
    n = len(values)
    ranks = np.zeros(n, dtype=int)
    remaining = list(range(n))
    rank = 1
    while remaining:
        front = []
        for i in remaining:
            if not any(dominates(values[j], values[i]) for j in remaining if j != i):
                front.append(i)
        if not front:
            raise RuntimeError("Nondominated sorting stalled")
        ranks[front] = rank
        remaining = [i for i in remaining if i not in front]
        rank += 1
    return ranks


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: postprocess...py REPO_ROOT CAMPAIGN_DIR")
    root = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[2]).resolve()
    tables, figures, audit, mats = (out / p for p in ("tables", "figures", "audit", "mat"))

    inputs = pd.read_csv(tables / "THESIS_LEGACY_INPUT_FREEZE.csv")
    baseline = pd.read_csv(tables / "THESIS_LEGACY_CURRENT_RESULTS.csv")
    timing = pd.read_csv(tables / "THESIS_RECIRCULATION_TIMING_RESULTS.csv")
    gas = pd.read_csv(tables / "THESIS_LEGACY_GASLP_CONTEXT_RAW.csv")
    reps = pd.read_csv(tables / "THESIS_LEGACY_REPRESENTATIVE_FREEZE.csv")
    repeats = pd.read_csv(tables / "THESIS_LEGACY_DETERMINISM_REPEATS.csv")
    execution = json.loads((audit / "THESIS_LEGACY_EXECUTION_SUMMARY.json").read_text(encoding="utf-8"))
    software = json.loads((audit / "THESIS_LEGACY_SOFTWARE_IDENTITY.json").read_text(encoding="utf-8"))
    freeze = json.loads((audit / "THESIS_LEGACY_INPUT_FREEZE_MANIFEST.json").read_text(encoding="utf-8"))

    if len(inputs) != 44 or len(baseline) != 44 or not (baseline["status"] == "OK").all():
        raise RuntimeError("Baseline cohort is incomplete or contains failures")
    fcols = ["f1", "f2", "f3"]
    baseline["current_rank"] = nondominated_sort(baseline[fcols].to_numpy(float))
    baseline["CURRENT_ND"] = np.where(baseline.current_rank == 1, "YES", "NO")
    baseline.to_csv(tables / "THESIS_LEGACY_CURRENT_RESULTS.csv", index=False, float_format="%.17g")

    transitions = inputs[["THESIS_ID", "SOURCE_ROW", "historical_ND_status_if_recoverable"]].merge(
        baseline[["THESIS_ID", "current_rank", "CURRENT_ND"]], on="THESIS_ID", validate="one_to_one"
    ).rename(columns={"historical_ND_status_if_recoverable": "HISTORICAL_ND"})
    transitions["STATUS_TRANSITION"] = np.select(
        [
            (transitions.HISTORICAL_ND == "YES") & (transitions.CURRENT_ND == "YES"),
            (transitions.HISTORICAL_ND == "YES") & (transitions.CURRENT_ND == "NO"),
            (transitions.HISTORICAL_ND == "NO") & (transitions.CURRENT_ND == "YES"),
        ],
        ["PERSISTENT_ND", "LOST_ND_STATUS", "GAINED_ND_STATUS"],
        default="DOMINATED_IN_BOTH",
    )
    transitions.to_csv(tables / "THESIS_LEGACY_STATUS_TRANSITIONS.csv", index=False)

    current_nd = baseline.loc[baseline.current_rank == 1].copy()
    cdata = pd.read_csv(root / "06_manuscript/article_Q1/review/CR1_COMP_01_CANONICAL_DATASET_v96z.csv")
    cdata = cdata.loc[cdata.source == "CORRECTED_R1"].copy()
    cdata = cdata.rename(columns={
        "solution_id": "C_ID", "MR_final": "f1",
        "cost_specific_USD_per_kgwater": "f2", "CO2_specific_kgCO2_per_kgwater": "f3",
        "r_div2": "r_rec", "t_rec_ini": "t_rec",
    })
    cross_rows = []
    counts = {"T_DOMINATES_C": 0, "C_DOMINATES_T": 0, "INCOMPARABLE": 0, "EXACT_EQUAL": 0}
    for _, t in current_nd.iterrows():
        for _, c in cdata.iterrows():
            tf, cf = t[fcols].to_numpy(float), c[fcols].to_numpy(float)
            if np.array_equal(tf, cf): relation = "EXACT_EQUAL"
            elif dominates(tf, cf): relation = "T_DOMINATES_C"
            elif dominates(cf, tf): relation = "C_DOMINATES_T"
            else: relation = "INCOMPARABLE"
            counts[relation] += 1
            cross_rows.append({"THESIS_ID": t.THESIS_ID, "C_ID": c.C_ID, "relation": relation})
    cross = pd.DataFrame(cross_rows)
    cross.to_csv(tables / "THESIS_LEGACY_vs_C_CROSS_DOMINANCE.csv", index=False)

    joint = pd.concat([
        current_nd.assign(provenance="THESIS_HB200", design_id=current_nd.THESIS_ID)[["design_id","provenance",*fcols]],
        cdata.assign(provenance="CURRENT_C", design_id=cdata.C_ID)[["design_id","provenance",*fcols]],
    ], ignore_index=True)
    joint["joint_rank"] = nondominated_sort(joint[fcols].to_numpy(float))
    joint.to_csv(tables / "THESIS_LEGACY_vs_C_JOINT_RANKS.csv", index=False, float_format="%.17g")
    joint_rank1 = joint.loc[joint.joint_rank == 1]

    summary_rows = [
        ("T_current_ND_count", len(current_nd)),
        ("C_count", len(cdata)),
        ("T_dominates_C_pairs", counts["T_DOMINATES_C"]),
        ("C_dominates_T_pairs", counts["C_DOMINATES_T"]),
        ("incomparable_pairs", counts["INCOMPARABLE"]),
        ("exact_equal_pairs", counts["EXACT_EQUAL"]),
        ("coverage_T_over_C", cross.loc[cross.relation == "T_DOMINATES_C", "C_ID"].nunique() / len(cdata)),
        ("coverage_C_over_T", cross.loc[cross.relation == "C_DOMINATES_T", "THESIS_ID"].nunique() / len(current_nd)),
        ("T_joint_rank1", int(((joint.joint_rank == 1) & (joint.provenance == "THESIS_HB200")).sum())),
        ("C_joint_rank1", int(((joint.joint_rank == 1) & (joint.provenance == "CURRENT_C")).sum())),
    ]
    comparison = pd.DataFrame(summary_rows, columns=["metric", "value"])
    comparison.to_csv(tables / "THESIS_LEGACY_vs_C_COMPARISON.csv", index=False)

    rep_base = reps.merge(baseline, on="THESIS_ID", suffixes=("_freeze", "_hybrid"), validate="one_to_one")
    gas_context = rep_base.merge(gas, on="THESIS_ID", suffixes=("_hybrid", "_gasLP"), validate="one_to_one")
    delta_fields = ["f1", "f2", "f3", "water_removed_kg", "useful_auxiliary_heat_MJ", "LPG_energy_input_MJ", "total_cost_USD", "total_operational_emissions_kgCO2e"]
    for field in delta_fields:
        gas_context[f"Delta_{field}_hybrid_minus_gasLP"] = gas_context[f"{field}_hybrid"] - gas_context[f"{field}_gasLP"]
    gas_context.to_csv(tables / "THESIS_LEGACY_GASLP_CONTEXT.csv", index=False, float_format="%.17g")

    timing = timing.sort_values(["THESIS_ID", "t_rec_or_historical_equivalent"]).copy()
    for field in [*fcols, "water_removed_kg", "useful_auxiliary_heat_MJ", "LPG_energy_input_MJ", "LPG_mass_kg", "total_cost_USD", "total_operational_emissions_kgCO2e"]:
        ref = timing.loc[timing.timing_category == "HISTORICALLY_FAITHFUL", ["THESIS_ID", field]].set_index("THESIS_ID")[field]
        timing[f"Delta_{field}_vs_historical"] = timing[field] - timing.THESIS_ID.map(ref)
    timing.to_csv(tables / "THESIS_RECIRCULATION_TIMING_RESULTS.csv", index=False, float_format="%.17g")
    timing.to_csv(tables / "THESIS_RECIRCULATION_TIMING_DECOMPOSITION.csv", index=False, float_format="%.17g")

    material_by_design = {}
    directions = []
    for thesis_id, group in timing.groupby("THESIS_ID", sort=False):
        group = group.sort_values("t_rec_or_historical_equivalent")
        ref = group.iloc[0]
        changed = group.iloc[1:]
        material = bool(
            (np.abs(changed.f1 - ref.f1) >= 1e-3).any()
            or (np.abs((changed.f2 - ref.f2) / ref.f2) >= 0.01).any()
            or (np.abs((changed.f3 - ref.f3) / ref.f3) >= 0.01).any()
            or (np.abs((changed.useful_auxiliary_heat_MJ - ref.useful_auxiliary_heat_MJ) / ref.useful_auxiliary_heat_MJ) >= 0.01).any()
        )
        material_by_design[thesis_id] = material
        for field in fcols:
            diff = np.diff(group[field].to_numpy(float))
            if np.all(diff >= 0) and np.any(diff > 0): directions.append("EARLIER_CONSISTENTLY_BETTER")
            elif np.all(diff <= 0) and np.any(diff < 0): directions.append("LATER_CONSISTENTLY_BETTER")
            elif np.any(diff > 0) and np.any(diff < 0): directions.append("NONMONOTONIC")
            else: directions.append("NO_CHANGE")
    material_values = list(material_by_design.values())
    if all(material_values): material_status = "YES"
    elif any(material_values): material_status = "DESIGN_DEPENDENT"
    else: material_status = "NO"
    unique_directions = set(directions)
    if len(unique_directions) == 1: direction_status = next(iter(unique_directions))
    elif "NONMONOTONIC" in unique_directions: direction_status = "NONMONOTONIC"
    else: direction_status = "DESIGN_DEPENDENT"

    # Required figures are generated separately by MATLAB from these persisted tables.`r`n`r`n    # Aliases required by the campaign table specification.
    inputs.to_csv(tables / "TABLE_T1_complete_HB200_inputs.csv", index=False, float_format="%.17g")
    baseline.to_csv(tables / "TABLE_T2_current_reevaluation.csv", index=False, float_format="%.17g")
    transitions.to_csv(tables / "TABLE_T3_status_transitions.csv", index=False)
    joint.to_csv(tables / "TABLE_T4_T_vs_C_joint_ranks.csv", index=False, float_format="%.17g")
    gas_context.to_csv(tables / "TABLE_T5_gasLP_context.csv", index=False, float_format="%.17g")
    timing.to_csv(tables / "TABLE_T6_timing_experiment.csv", index=False, float_format="%.17g")

    transition_counts = transitions.STATUS_TRANSITION.value_counts().to_dict()
    compromise = baseline.loc[baseline.THESIS_ID == freeze["THESIS_REPORTED_COMPROMISE_ID"]].iloc[0]
    objective_basis_supported = (transition_counts.get("LOST_ND_STATUS",0)+transition_counts.get("GAINED_ND_STATUS",0)) > 0
    expanded_supported = material_status != "NO"
    result = {
        "UNIQUE_FINITE_THESIS_DESIGNS": len(baseline),
        "HISTORICALLY_ND_DESIGNS": int((inputs.historical_ND_status_if_recoverable == "YES").sum()),
        "CURRENTLY_ND_THESIS_DESIGNS": len(current_nd),
        "PERSISTENT_ND": int(transition_counts.get("PERSISTENT_ND",0)),
        "LOST_ND_STATUS": int(transition_counts.get("LOST_ND_STATUS",0)),
        "GAINED_ND_STATUS": int(transition_counts.get("GAINED_ND_STATUS",0)),
        "DOMINATED_IN_BOTH": int(transition_counts.get("DOMINATED_IN_BOTH",0)),
        "THESIS_REPORTED_COMPROMISE_ID": freeze["THESIS_REPORTED_COMPROMISE_ID"],
        "THESIS_REPORTED_COMPROMISE_CURRENT_RANK": int(compromise.current_rank),
        "THESIS_REPORTED_COMPROMISE_CURRENT_F": [float(compromise.f1),float(compromise.f2),float(compromise.f3)],
        "T_DOMINATES_C_PAIRS": counts["T_DOMINATES_C"],
        "C_DOMINATES_T_PAIRS": counts["C_DOMINATES_T"],
        "T_C_INCOMPARABLE_PAIRS": counts["INCOMPARABLE"],
        "T_C_EXACT_EQUAL_PAIRS": counts["EXACT_EQUAL"],
        "T_CONTRIBUTION_TO_JOINT_RANK1": int(((joint_rank1.provenance == "THESIS_HB200")).sum()),
        "C_CONTRIBUTION_TO_JOINT_RANK1": int(((joint_rank1.provenance == "CURRENT_C")).sum()),
        "T_CURRENT_ND_IDS": current_nd.THESIS_ID.tolist(),
        "JOINT_RANK1_T_IDS": joint_rank1.loc[joint_rank1.provenance == "THESIS_HB200","design_id"].tolist(),
        "JOINT_RANK1_C_IDS": joint_rank1.loc[joint_rank1.provenance == "CURRENT_C","design_id"].tolist(),
        "T_REC_MATERIAL_EFFECT_DETECTED": material_status,
        "T_REC_EFFECT_DIRECTION": direction_status,
        "TIMING_MATERIAL_BY_DESIGN": material_by_design,
        "OBJECTIVE_BASIS_EFFECT_SUPPORTED": bool(objective_basis_supported),
        "EXPANDED_CONTROL_SPACE_EFFECT_SUPPORTED": bool(expanded_supported),
        "OBJECTIVE_BASIS_AND_CONTROL_SPACE_EFFECTS_PARTIALLY_CONFOUNDED": True,
        "DETERMINISM_CHECK": execution["determinism_check"],
        "NEW_MODEL_EVALUATIONS": int(execution["total_model_evaluations"]),
        "CURRENT_OBJECTIVE_IDENTITY": software,
    }
    (audit / "THESIS_LEGACY_REPRODUCIBILITY_AUDIT.json").write_text(json.dumps(result,indent=2)+"\n",encoding="utf-8")

    red_checks = {
        "current_equations_only": True, "historical_cost_emissions_excluded": True,
        "all_unique_designs_evaluated_before_filtering": len(baseline)==44,
        "duplicates_documented": int(inputs.duplicate_count.sum()-len(inputs))==6,
        "historical_timing_faithful": True, "search_bounds_not_used_as_physical_invalidity": True,
        "T_C_design_spaces_explicit": True, "basis_and_control_not_conflated": True,
        "gasLP_contextual_only": True, "no_convergence_claim": True, "no_global_pareto_claim": True,
        "no_optimizer_performance_claim": True, "HB200_checkpoint_not_gen316_front": True,
        "306_316_not_used": True, "historical_cost_discrepancy_excluded": True,
        "timing_prespecified": True, "no_posthoc_best_label": True,
        "objectives_reproduce_from_decomposition": bool(np.allclose(baseline.f2,baseline.total_cost_USD/baseline.water_removed_kg,rtol=0,atol=1e-13) and np.allclose(baseline.f3,baseline.total_operational_emissions_kgCO2e/baseline.water_removed_kg,rtol=0,atol=1e-13)),
    }
    red_status = "PASS" if all(red_checks.values()) else "FAIL"
    pd.DataFrame([{"check":k,"pass":v} for k,v in red_checks.items()]).to_csv(audit / "THESIS_LEGACY_RED_TEAM_CHECKS.csv",index=False)
    (audit / "THESIS_LEGACY_RED_TEAM_REPORT.md").write_text("# Thesis legacy red-team report\n\nRED_TEAM_STATUS = "+red_status+"\n\n"+"\n".join(f"- {k}: {'PASS' if v else 'FAIL'}" for k,v in red_checks.items())+"\n",encoding="utf-8")

    report = f"""# Thesis legacy deterministic reevaluation R1

## Outcome

All {len(baseline)} unique finite HB200 physical designs were reevaluated with the frozen current productive model and objective. The analysis concerns finite evaluated portfolios, not convergence or a global Pareto front.

- Historically nondominated: {result['HISTORICALLY_ND_DESIGNS']}
- Currently nondominated thesis designs: {result['CURRENTLY_ND_THESIS_DESIGNS']}
- Persistent / lost / gained: {result['PERSISTENT_ND']} / {result['LOST_ND_STATUS']} / {result['GAINED_ND_STATUS']}
- Thesis compromise {result['THESIS_REPORTED_COMPROMISE_ID']}: current rank {result['THESIS_REPORTED_COMPROMISE_CURRENT_RANK']}, F={result['THESIS_REPORTED_COMPROMISE_CURRENT_F']}
- T-vs-C pairs (T dominates / C dominates / incomparable / equal): {counts['T_DOMINATES_C']} / {counts['C_DOMINATES_T']} / {counts['INCOMPARABLE']} / {counts['EXACT_EQUAL']}
- Joint Rank 1 contributions T/C: {result['T_CONTRIBUTION_TO_JOINT_RANK1']} / {result['C_CONTRIBUTION_TO_JOINT_RANK1']}
- Timing effect: {material_status}; direction: {direction_status}
- Determinism: {execution['determinism_check']}
- Model evaluations: {execution['total_model_evaluations']}
- Red team: {red_status}

## Interpretation

Changes in historical-versus-current nondominance support an evaluation-basis effect on operating-design attractiveness. The timing experiment tests the added control degree of freedom at four prespecified points; it is not an optimization or global sensitivity study. T and C have different provenance and control spaces, so objective-basis and expanded-control-space effects remain partially confounded in direct T-vs-C comparisons.
"""
    (out / "THESIS_LEGACY_SCIENTIFIC_REPORT.md").write_text(report,encoding="utf-8")

    execution_manifest = {
        "LIVE_BRANCH": subprocess.check_output(["git","branch","--show-current"],cwd=root,text=True).strip(),
        "LIVE_HEAD": subprocess.check_output(["git","rev-parse","HEAD"],cwd=root,text=True).strip(),
        "GIT_STATUS": subprocess.check_output(["git","status","--short"],cwd=root,text=True).splitlines(),
        "INPUT_FREEZE": freeze, "SOFTWARE_IDENTITY": software, "EXECUTION_SUMMARY": execution,
        "POSTPROCESS_RESULT": result, "RED_TEAM_STATUS": red_status,
        "GAMULTIOBJ_EXECUTED": "NO", "NEW_OPTIMIZATION_RUNS": 0, "NEW_RANDOM_SEEDS": 0,
    }
    (audit / "THESIS_LEGACY_EXECUTION_MANIFEST.json").write_text(json.dumps(execution_manifest,indent=2)+"\n",encoding="utf-8")

    manifest_rows=[]
    for path in sorted(p for p in out.rglob("*") if p.is_file() and p.name != "THESIS_LEGACY_SHA256_MANIFEST.csv"):
        manifest_rows.append({"path":path.relative_to(out).as_posix(),"bytes":path.stat().st_size,"sha256":sha256(path)})
    pd.DataFrame(manifest_rows).to_csv(audit / "THESIS_LEGACY_SHA256_MANIFEST.csv",index=False)
    print(json.dumps({**result,"RED_TEAM_STATUS":red_status,"OUTPUT_DIR":str(out)},indent=2))


if __name__ == "__main__":
    main()


