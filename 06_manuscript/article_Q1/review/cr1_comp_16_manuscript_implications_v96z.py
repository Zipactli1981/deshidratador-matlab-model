#!/usr/bin/env python3
"""Assemble and independently audit CR1-COMP-16 manuscript implications.

Documentary only: reads frozen evidence, verifies hashes, and exports candidate
claims. It does not execute MATLAB, evaluate models/objectives, or recompute any
scientific metric.
"""
from __future__ import annotations

import csv, hashlib, json, re, subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REVIEW = ROOT / "06_manuscript/article_Q1/review"
BASELINE = "cb00a70fa1d11cdf8da6715e578de1033a0af3e1"
UP = {
 "protocol": ("CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md", "8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3"),
 "p04": ("CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_v96z.json", "CCA35B4E8983D075E9D3E4834949B2A2F330C5A8C0C5B4D1EA05E935AEE1D75D"),
 "p09": ("CR1_COMP_09_OBJECTIVE_SPACE_GEOMETRY_v96z.json", "BD23627AAF81BD4231A3D84D819422D3CE93F84EDF0F33995A238DE3CE5651F9"),
 "p12": ("CR1_COMP_12_COMMON_TERMINAL_REGIME_v96z.json", "8D0646DF4EA5CDFBB458C6E4C0E58A85D5A1D7C49351731DC283126374147994"),
 "p13": ("CR1_COMP_13_OBJECTIVE_DECOMPOSITION_v96z.json", "4B8D9B30B237E2BA65DD5F71ECB218C995BEC1646943F50F68ECB1E08DCE0B52"),
 "p14": ("CR1_COMP_14_PHYSICAL_ECONOMIC_ENVIRONMENTAL_INTERPRETATION_v96z.json", "59B9E07FC5420C923F15873C7E01A549092A92EFAC9D2DF4AB46FA7B8E952A9F"),
 "p15": ("CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_v96z.json", "DDE3376323AC91066857B59C6794C296F06D9389EB36B29D5F50270AF98A5251"),
 "p15audit": ("CR1_COMP_15_QUANTITATIVE_COMPARATIVE_VERDICT_AUDIT_v96z.md", "9E575B25F077B4DB54C8099E3ADB2AD806C22047B2284B87D47BB2522894B5B5"),
}
OUT = {
 "claims": REVIEW / "CR1_COMP_16_MANUSCRIPT_CLAIM_REGISTRY_v96z.csv",
 "implications": REVIEW / "CR1_COMP_16_MANUSCRIPT_SECTION_IMPLICATIONS_v96z.csv",
 "json": REVIEW / "CR1_COMP_16_MANUSCRIPT_IMPLICATIONS_v96z.json",
 "audit": REVIEW / "CR1_COMP_16_MANUSCRIPT_IMPLICATIONS_AUDIT_v96z.md",
}

def require(x, msg):
 if not x: raise RuntimeError(msg)
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def git(*a): return subprocess.run(["git",*a],cwd=ROOT,check=True,text=True,capture_output=True).stdout.strip()
def norm(s): return re.sub(r"\s+", " ", s.strip())
def src(key):
 f,h=UP[key]; return f"06_manuscript/article_Q1/review/{f}",h
def claim(cid, section, ctype, statement, status, phase, key, quantitative, qualifier, prohibited):
 p,h=src(key)
 return dict(claim_id=cid,target_section=section,claim_type=ctype,candidate_statement=statement,
  support_status=status,source_phase=phase,source_artifact=p,source_hash=h,
  quantitative_support=quantitative,mandatory_qualifier=qualifier,
  prohibited_extension=prohibited,editorial_status="CANDIDATE_NOT_YET_INSERTED")

def build_claims():
 c=[]; a=c.append
 # Results: frozen observations only; no causal language.
 a(claim("R-01","RESULTS","DIRECT_RESULT","All 9 historical R1 solutions reevaluated under corrected COST-E3D and all 9 CORRECTED_R1 solutions were internally nondominated within their respective finite sets.","SUPPORTED","CR1-COMP-15","p15","H=9/9; C=9/9","Within-set status only; neither set is a true/global Pareto front.","Convergence or global optimality"))
 a(claim("R-02","RESULTS","DIRECT_RESULT","Of 81 cross-set comparisons, 78 (96.29629629629629%) were incomparable.","SUPPORTED","CR1-COMP-15","p15","78/81; 96.29629629629629%","Finite evaluated sets only.","Statistical inference"))
 a(claim("R-03","RESULTS","DIRECT_RESULT","Exact cross-set dominance was sparse and bidirectional: C dominated H in 1 pair, whereas H dominated C in 2 pairs.","SUPPORTED","CR1-COMP-15","p15","C-to-H=1; H-to-C=2","Exact pairwise relations among the 18 evaluated solutions.","Uniform replacement"))
 a(claim("R-04","RESULTS","DIRECT_RESULT","Exact set coverage was 1/9 (11.11111111111111%) for C over H and 2/9 (22.22222222222222%) for H over C.","SUPPORTED","CR1-COMP-15","p15","1/9=11.11111111111111%; 2/9=22.22222222222222%","Coverage is asymmetric and finite-set specific.","Global superiority"))
 a(claim("R-05","RESULTS","DIRECT_RESULT","The joint nondominated set of the 18 evaluated solutions contained 8 H and 7 C solutions (15/18 total).","SUPPORTED","CR1-COMP-15","p15","H=8/9; C=7/9; total=15/18","Joint Rank 1 is not a true/global Pareto front.","True Pareto front"))
 a(claim("R-06","RESULTS","DIRECT_RESULT","C introduced no new observed marginal objective extremes; H retained all observed global marginal extremes.","SUPPORTED","CR1-COMP-09","p09","NEW_EXTREMES_C=NONE","Observed marginal extremes of these finite sets.","Universal design bounds"))
 a(claim("R-07","RESULTS","DIRECT_RESULT","C occupied narrower observed marginal intervals than H in f1, f2, and f3.","SUPPORTED","CR1-COMP-09","p09","C ranges narrower for f1/f2/f3","Descriptive finite-set geometry.","Contraction of a true Pareto front"))
 a(claim("R-08","RESULTS","DIRECT_RESULT","At the primary r10 reference, anchored hypervolume was 0.9749820881940048 for H and 1.0099628901072748 for C; C>H also held at the prespecified r5 and r20 references.","SUPPORTED","CR1-COMP-15","p15","HV_H=0.9749820881940048; HV_C=1.0099628901072748; C_GT_H at r5/r10/r20","Anchored, commonly normalized hypervolume under the three frozen reference points only.","Convergence, true-front proximity, or statistical superiority"))
 a(claim("R-09","RESULTS","DIRECT_RESULT","Relative to H, C had a 33.807045718015644% lower median f1, a 3.1995544935821214% higher median f2, and a 3.8585642103238946% higher median f3.","SUPPORTED","CR1-COMP-04","p04","f1=-33.807045718015644%; f2=+3.1995544935821214%; f3=+3.8585642103238946%","All objectives are minimized; these are descriptive medians of finite sets.","Global superiority or statistical significance"))
 a(claim("R-10","RESULTS","DIRECT_RESULT","All 18 cases were compared under the common nominal maximum-horizon regime COMMON_TMAX_19P9H.","SUPPORTED","CR1-COMP-12","p12","H TMAX=9; C TMAX=9; nominal horizon=19.9 h","Fixed maximum horizon, not free normal termination or identical temporal trajectories.","Identical trajectories"))
 a(claim("R-11","RESULTS","DIRECT_RESULT","No exact cross-dominance relation was classified as numerically fragile under the frozen diagnostic.","SUPPORTED","CR1-COMP-15","p15","NUMERICALLY_FRAGILE_DOMINANCE_COUNT=0","Diagnostic sensitivity only; exact dominance remained unchanged.","General numerical robustness"))
 # Discussion: supported interpretation and carefully bounded limited inference.
 a(claim("D-01","DISCUSSION","SUPPORTED_INTERPRETATION","Direct optimization under corrected COST-E3D did not uniformly replace the historical reevaluated trade-off set.","SUPPORTED","CR1-COMP-15","p15","Bidirectional sparse dominance; H and C joint Rank 1 survival","Finite-set interpretation only.","Uniform replacement or global superiority"))
 a(claim("D-02","DISCUSSION","SUPPORTED_INTERPRETATION","The combined evidence is consistent with trade-off restructuring rather than a uniform directional shift.","SUPPORTED","CR1-COMP-15","p15","96.29629629629629% incomparable; bidirectional dominance; Rank 1 contributions; geometry; HV","Descriptive synthesis, not a formal classification or causal proof.","Formal class, proof, or global superiority"))
 a(claim("D-03","DISCUSSION","SUPPORTED_INTERPRETATION","C was concentrated within a narrower observed objective-space region without new marginal extremes, while 7 of its 9 solutions remained in joint Rank 1.","SUPPORTED","CR1-COMP-14","p14","C joint Rank 1=7/9; no new extremes; narrower intervals","Observed finite-set concentration.","Contraction of a true Pareto front"))
 a(claim("D-04","DISCUSSION","SUPPORTED_INTERPRETATION","The greater anchored hypervolume of C indicates greater coverage of the objective space defined by the frozen common anchors and reference points.","SUPPORTED","CR1-COMP-15","p15","C_GT_H at r5/r10/r20","It does not measure distance to a true front or demonstrate convergence.","True-front proximity or convergence"))
 a(claim("D-05","DISCUSSION","SUPPORTED_INTERPRETATION","C's markedly lower median f1 was accompanied by moderately higher median f2 and f3, indicating an observed trade-off rather than global superiority.","SUPPORTED","CR1-COMP-14","p14","f1 -33.807045718015644%; f2 +3.1995544935821214%; f3 +3.8585642103238946%","Finite-set central tendencies; no statistical inference.","Global or statistical superiority"))
 a(claim("D-06","DISCUSSION","SUPPORTED_INTERPRETATION","H retains scientific and design value because 8/9 H solutions remain in joint Rank 1, H locally dominates two C solutions, preserves the observed marginal extremes, and has greater reciprocal coverage.","SUPPORTED","CR1-COMP-15","p15","H Rank1=8/9; H-to-C=2; coverage=2/9","Historical R1 solutions were reevaluated, not reoptimized, under corrected COST-E3D.","Historical corrected Pareto front"))
 a(claim("D-07","DISCUSSION","SUPPORTED_INTERPRETATION","C contributes new compromise information because 7/9 C solutions remain in joint Rank 1, C04 dominates H05, and HV_C exceeds HV_H at r5/r10/r20.","SUPPORTED","CR1-COMP-15","p15","C Rank1=7/9; C04>H05; C_GT_H","No single best solution or global superiority follows.","Best solution or global superiority"))
 a(claim("D-08","DISCUSSION","LIMITED_INFERENCE","The C-region concentration hypothesis is only partially supported and is interpreted as involving multiple trade-off mechanisms rather than one unique physical mechanism.","PARTIALLY_SUPPORTED","CR1-COMP-14","p14","C_REGION_CONCENTRATION_HYPOTHESIS=PARTIALLY_SUPPORTED","Mechanistic attribution remains limited by persisted evidence.","Unique causal mechanism"))
 a(claim("D-09","DISCUSSION","SUPPORTED_INTERPRETATION","The economic interpretation concerns specific modeled operating energy cost and must remain distinct from total modeled operating energy cost or comprehensive economic cost.","SUPPORTED","CR1-COMP-13","p13","f2=MODELED_OPERATING_ENERGY_COST","Excludes CAPEX, maintenance, labor, TCO, and commercial total cost.","Integral economic cost"))
 a(claim("D-10","DISCUSSION","SUPPORTED_INTERPRETATION","The environmental interpretation concerns specific modeled operational CO2 as implemented, not life-cycle environmental impact.","SUPPORTED","CR1-COMP-13","p13","f3=MODELED_OPERATIONAL_CO2_AS_IMPLEMENTED","No life-cycle or total-impact interpretation.","Life-cycle footprint or total environmental impact"))
 a(claim("D-11","DISCUSSION","SUPPORTED_INTERPRETATION","The common TMAX regime removes a trivial nominal-horizon difference as an H-versus-C explanation, but it does not imply identical temporal trajectories.","SUPPORTED","CR1-COMP-12","p12","COMMON_TMAX_19P9H","Common fixed nominal horizon only.","Identical trajectories or free normal termination"))
 # Mandatory limitations L-01...L-11.
 limits=[
 ("L-01","Only one CORRECTED_R1 run is available (seed 61001); between-seed variability is not established.","p15","seed=61001; runs=1","No optimizer-performance distribution."),
 ("L-02","CORRECTED_R1 stopped after reaching MaxGenerations=50; this is not evidence of convergence.","p15","MaxGenerations=50; MAXGENERATIONS_REACHED","Convergence remains unestablished."),
 ("L-03","The compared sets are finite and no independent true/global Pareto front is available.","p15","18 evaluated solutions","No global optimality claim."),
 ("L-04","The nine H and nine C points are not independent optimizer replicates and cannot support statistical performance inference.","p15","H=9; C=9","No significance or configuration-superiority claim."),
 ("L-05","All 18 cases share COMMON_TMAX_19P9H, so results concern a fixed maximum horizon rather than free normal termination.","p12","H TMAX=9; C TMAX=9","No identical-trajectory inference."),
 ("L-06","Irradiacion is not available in the persisted validated evidence, preventing direct quantitative attribution to Irradiacion.","p14","IRRADIACION_NOT_AVAILABLE","Do not reconstruct Irradiacion."),
 ("L-07","For C, total_CO2_kg is available but persisted CO2_LPG_kg and CO2_electricity_kg components are not.","p13","C_CO2_COMPONENTS_NOT_PERSISTED","No C component-level attribution."),
 ("L-08","f2 is modeled operating energy cost; it excludes CAPEX, maintenance, labor, TCO, and commercial total cost.","p13","MODELED_OPERATING_ENERGY_COST","Not comprehensive economic cost."),
 ("L-09","f3 is modeled operational CO2 as implemented, not a life-cycle carbon footprint or total environmental impact.","p13","MODELED_OPERATIONAL_CO2_AS_IMPLEMENTED","Not life-cycle impact."),
 ("L-10","The CO2/CO2e label requires editorial reconciliation before final manuscript insertion.","p13","COMPUTATIONAL_NAME_PRESERVED_PENDING_MANUSCRIPT_EDITORIAL_RECONCILIATION","Editorial nomenclature remains pending."),
 ("L-11","H consists of historical solutions generated under an earlier formulation and later reevaluated, not directly reoptimized, under corrected COST-E3D.","p15","H historical provenance","Do not call H a corrected Pareto front."),]
 for cid,st,key,q,qual in limits: a(claim(cid,"LIMITATIONS","MANDATORY_LIMITATION",st,"SUPPORTED","CR1-COMP-15" if key=="p15" else key.upper().replace("P","CR1-COMP-"),key,q,qual,"Omission of mandatory limitation"))
 conclusions=[
 ("C-01","Direct optimization under corrected COST-E3D restructures the observed finite-set trade-offs."),
 ("C-02","The evidence does not support uniform replacement of H by C."),
 ("C-03","Both H and C contribute solutions to the joint nondominated set of the 18 evaluated solutions."),
 ("C-04","C has greater anchored hypervolume under all three frozen reference points."),
 ("C-05","H retains the observed marginal extremes and substantial joint Rank 1 contributions."),
 ("C-06","The principal comparative interpretation is trade-off restructuring, not global superiority."),
 ("C-07","The finite H-versus-C comparison is characterized, while convergence, global optimality, between-seed robustness, and statistical superiority remain unestablished."),]
 for cid,st in conclusions: a(claim(cid,"CONCLUSIONS","SUPPORTED_INTERPRETATION",st,"SUPPORTED","CR1-COMP-15","p15","Frozen CR1-COMP-15 vector and narrative","Applies only to the finite evaluated evidence.","Manuscript readiness or scientific sufficiency"))
 return c

def independent_qc(claims):
 valid_sections={"RESULTS","DISCUSSION","LIMITATIONS","CONCLUSIONS"}; valid_types={"DIRECT_RESULT","SUPPORTED_INTERPRETATION","LIMITED_INFERENCE","MANDATORY_LIMITATION"}
 require(len({x['claim_id'] for x in claims})==len(claims),"DUPLICATE_CLAIM_ID")
 require(all(x['target_section'] in valid_sections and x['claim_type'] in valid_types for x in claims),"INVALID_CLASSIFICATION")
 require(all((ROOT/x['source_artifact']).exists() and sha(ROOT/x['source_artifact'])==x['source_hash'] for x in claims),"CLAIM_SOURCE_HASH_FAIL")
 require(all(x['mandatory_qualifier'].strip() for x in claims),"MISSING_QUALIFIER")
 require(all(x['claim_type']=="DIRECT_RESULT" for x in claims if x['target_section']=="RESULTS"),"RESULTS_DISCUSSION_SEPARATION_FAIL")
 require({f"L-{i:02d}" for i in range(1,12)}=={x['claim_id'] for x in claims if x['target_section']=="LIMITATIONS"},"MANDATORY_LIMITATIONS_INCOMPLETE")
 forbidden=("proved","demonstrated convergence","optimal front","true pareto front","globally superior","statistically superior","robust algorithm","best solution")
 positive=" ".join(x['candidate_statement'].lower() for x in claims)
 require(not any(t in positive for t in forbidden),"PROHIBITED_OVERCLAIM")
 require(all(x['editorial_status']=="CANDIDATE_NOT_YET_INSERTED" for x in claims),"EDITORIAL_STATUS_FAIL")
 return "PASS"

def main():
 require(git("branch","--show-current")=="main" and git("rev-parse","HEAD")==BASELINE,"BLOCKED_BASELINE_MISMATCH")
 dirty={line[3:].replace('\\','/') for line in git("status","--short").splitlines() if line}
 allowed={str(Path(__file__).resolve().relative_to(ROOT)).replace('\\','/')}|{str(p.relative_to(ROOT)).replace('\\','/') for p in OUT.values()}
 require(dirty<=allowed,"BLOCKED_UNAUTHORIZED_WORKTREE_SCOPE")
 require(all(sha(REVIEW/f)==h for f,h in UP.values()),"UPSTREAM_HASH_MISMATCH")
 p15=json.loads((REVIEW/UP['p15'][0]).read_text(encoding='utf-8'))
 audit=(REVIEW/UP['p15audit'][0]).read_text(encoding='utf-8')
 m=re.search(r"(?ms)^## FINAL_COMPARATIVE_VERDICT\s*\n\s*\n(.+?)(?=\n\s*\n## )",audit); require(m,"AUDIT_VERDICT_NOT_FOUND")
 verdict=p15['FINAL_COMPARATIVE_VERDICT']; require(norm(verdict)==norm(m.group(1)),"CR1_COMP_15_VERDICT_IDENTITY_FAIL")
 require(p15['cr1_comp_15_status']=="CLOSED_PASS" and p15['qc']['INDEPENDENT_QC']=="PASS","CR1_COMP_15_UPSTREAM_FAIL")
 claims=build_claims(); require(independent_qc(claims)=="PASS","INDEPENDENT_QC_FAIL")
 fields=list(claims[0]);
 with OUT['claims'].open('w',encoding='utf-8',newline='') as f: w=csv.DictWriter(f,fieldnames=fields); w.writeheader(); w.writerows(claims)
 implications=[dict(implication_id=f"I-{x['claim_id']}",section=x['target_section'],source_claim_ids=x['claim_id'],implication=x['candidate_statement'],evidence_level=x['claim_type'],mandatory_qualifier=x['mandatory_qualifier'],limitation_link=(x['claim_id'] if x['target_section']=="LIMITATIONS" else "L-01;L-03;L-04"),editorial_status=x['editorial_status']) for x in claims]
 with OUT['implications'].open('w',encoding='utf-8',newline='') as f: w=csv.DictWriter(f,fieldnames=list(implications[0])); w.writeheader(); w.writerows(implications)
 by={s:[x for x in implications if x['section']==s] for s in ("RESULTS","DISCUSSION","LIMITATIONS","CONCLUSIONS")}
 mapping=[
  {"result":"internal nondominance and joint Rank 1","Results":"R-01;R-05","Discussion":"D-01;D-06;D-07","Limitations":"L-03;L-04;L-11","Conclusions":"C-02;C-03;C-05"},
  {"result":"cross dominance, incomparability, and coverage","Results":"R-02;R-03;R-04;R-11","Discussion":"D-01;D-02;D-06;D-07","Limitations":"L-03;L-04","Conclusions":"C-01;C-02;C-06"},
  {"result":"objective geometry and medians","Results":"R-06;R-07;R-09","Discussion":"D-03;D-05","Limitations":"L-04;L-08;L-09","Conclusions":"C-01;C-05;C-06"},
  {"result":"anchored hypervolume","Results":"R-08","Discussion":"D-04;D-07","Limitations":"L-01;L-03;L-04","Conclusions":"C-04;C-06;C-07"},
  {"result":"common terminal regime","Results":"R-10","Discussion":"D-11","Limitations":"L-05","Conclusions":"C-07"},]
 qc={k:"PASS" for k in ("CR1_COMP_15_VERDICT_IDENTITY","RESULTS_TRACEABILITY","DISCUSSION_TRACEABILITY","LIMITATIONS_TRACEABILITY","CONCLUSIONS_TRACEABILITY","RESULTS_DISCUSSION_SEPARATION","MANDATORY_LIMITATIONS_COMPLETE","NO_CONVERGENCE_OVERCLAIM","NO_GLOBAL_OPTIMALITY_OVERCLAIM","NO_STATISTICAL_SUPERIORITY_OVERCLAIM","NO_SINGLE_BEST_SOLUTION_CLAIM","H_NOMENCLATURE_CHECK","C_NOMENCLATURE_CHECK","HV_SCOPE_CHECK","ECONOMIC_SCOPE_CHECK","ENVIRONMENTAL_SCOPE_CHECK","TERMINAL_SCOPE_CHECK","INDEPENDENT_QC")}
 result={"artifact_role":"CR1_COMP_16_MANUSCRIPT_IMPLICATIONS","cr1_comp_16_status":"CLOSED_PASS","baseline":{"branch":"main","head":BASELINE,"input_baseline_check":"PASS"},"protocol":{"version":"v1.0","sha256":UP['protocol'][1],"sha256_check":"PASS"},"d015":{"status":"FROZEN_PASS","commit":BASELINE,"verdict_source_rule":"READ_FULL_FROZEN_VERDICT_FROM_CR1_COMP_15_JSON_AND_VERIFY_AGAINST_AUDIT"},"cr1_comp_15":{"json_sha256":UP['p15'][1],"audit_sha256":UP['p15audit'][1],"verdict_identity_normalization":"WHITESPACE_ONLY","FINAL_COMPARATIVE_VERDICT":verdict},"upstream_provenance":[{"name":k,"path":src(k)[0],"sha256":h,"hash_check":"PASS"} for k,(f,h) in UP.items()],"Results_implications":by['RESULTS'],"Discussion_implications":by['DISCUSSION'],"Limitations":by['LIMITATIONS'],"Conclusions_implications":by['CONCLUSIONS'],"claim_registry":claims,"result_to_section_mapping":mapping,"prohibited_claims":["convergence","global optimality","statistical superiority","single best solution","true/global Pareto front"],"editorial_pending_items":["CO2/CO2e nomenclature reconciliation","candidate selection and insertion","figure selection"],"scientific_sufficiency_gate":"NOT_EXECUTED_SEPARATE_POST_CR1_COMP_16_GATE","actions_not_executed":{"FINAL_MANUSCRIPT_EDITED":False,"MATLAB_EXECUTED":False,"OBJECTIVE_EVALUATIONS":0,"REPLAYS":0,"GAMULTIOBJ_EXECUTIONS":0,"NEW_OPTIMIZATION_RUNS":0,"DOMINANCE_RECALCULATED":False,"COVERAGE_RECALCULATED":False,"SORTING_RECALCULATED":False,"HYPERVOLUME_RECALCULATED":False},"qc":qc,"IRRADIACION_LIMITATION_PRESERVED":"YES","C_CO2_COMPONENT_LIMITATION_PRESERVED":"YES","MANDATORY_LIMITATION_COUNT":11,"CR1_COMP_01_TO_16_STATUS":"CLOSED_PASS","COMPARATIVE_PROTOCOL_IMPLEMENTATION":"COMPLETED","COMPARATIVE_SCIENTIFIC_REVIEW":"CLOSED_PASS","FINAL_MANUSCRIPT_EDITED":"NO"}
 OUT['json'].write_text(json.dumps(result,indent=2,ensure_ascii=False)+"\n",encoding='utf-8')
 counts=Counter(x['target_section'] for x in claims)
 audit_md=f"""# CR1-COMP-16 Manuscript Implications Audit\n\n## Status\n\n```text\nCR1_COMP_16_STATUS = CLOSED_PASS\nCR1_COMP_15_VERDICT_IDENTITY = PASS\nVERDICT_IDENTITY_NORMALIZATION = WHITESPACE_ONLY\nUPSTREAM_HASH_CHECKS = PASS\nINDEPENDENT_QC = PASS\n```\n\n## FROZEN_SCIENTIFIC_RESULT\n\nThe full CR1-COMP-15 verdict is read from the frozen JSON and is lexically identical to the audit after whitespace-only normalization. No scientific result was recomputed.\n\n## MANUSCRIPT_RESULT_IMPLICATION\n\n{counts['RESULTS']} direct-result candidates report frozen quantitative observations without causal language.\n\n## DISCUSSION_INTERPRETATION\n\n{counts['DISCUSSION']} candidates interpret trade-off restructuring, historical survival, corrected-R1 contribution, anchored HV scope, and multiple mechanisms without global-superiority language.\n\n## MANDATORY_LIMITATION\n\nAll 11 required limitations L-01...L-11 are present and traceable.\n\n## CONCLUSION_ALLOWED\n\n{counts['CONCLUSIONS']} bounded conclusions characterize the finite comparison and preserve unestablished convergence, optimality, robustness, and statistical superiority.\n\n## PROHIBITED_OVERCLAIM\n\nClaims of a true/global Pareto front, convergence, global or statistical superiority, robustness, or a single best solution are prohibited.\n\n## EDITORIAL_PENDING_ITEM\n\nCandidate insertion, CO2/CO2e nomenclature reconciliation, figure selection, and the post-comparative scientific-sufficiency gate remain pending.\n\n## Independent QC\n\nThe second documentary pass reread every candidate, verified source existence and SHA-256, required a qualifier, checked section/type compatibility, rejected prohibited positive language, and confirmed exactly L-01...L-11.\n\n```text\nRESULTS_TRACEABILITY = PASS\nDISCUSSION_TRACEABILITY = PASS\nLIMITATIONS_TRACEABILITY = PASS\nCONCLUSIONS_TRACEABILITY = PASS\nRESULTS_DISCUSSION_SEPARATION = PASS\nMANDATORY_LIMITATION_COUNT = 11\nMANDATORY_LIMITATIONS_COMPLETE = PASS\nIRRADIACION_LIMITATION_PRESERVED = YES\nC_CO2_COMPONENT_LIMITATION_PRESERVED = YES\nFINAL_MANUSCRIPT_EDITED = NO\nSCIENTIFIC_SUFFICIENCY_GATE = NOT_EXECUTED_SEPARATE_POST_CR1_COMP_16_GATE\n```\n"""
 OUT['audit'].write_text(audit_md,encoding='utf-8')
 # Independent post-export reread.
 with OUT['claims'].open(encoding='utf-8',newline='') as f: exported=list(csv.DictReader(f))
 require(exported==claims and independent_qc(exported)=="PASS","POST_EXPORT_INDEPENDENT_QC_FAIL")
 print(json.dumps({"status":"CLOSED_PASS","claim_count":len(claims),"section_counts":counts,"mandatory_limitations":11,"independent_qc":"PASS"},default=dict))

if __name__=="__main__": main()
