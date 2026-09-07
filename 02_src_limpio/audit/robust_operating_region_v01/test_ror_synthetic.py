"""Synthetic-only tests. Temporary fixtures never load repository historical MATs."""
import ast
import copy
import csv
import itertools
import json
from pathlib import Path
import random
import subprocess
import tempfile
import unittest
from unittest import mock

import numpy as np
try:
    from scipy.io import loadmat, savemat
except ModuleNotFoundError:
    loadmat = None
    savemat = None

import ror_core as core
import ror_postrun as io

F = [[0.,1.,1.],[1.,0.,1.],[1.,1.,0.]]
X = [[.08,50.,.1,1.],[.09,55.,.2,2.],[.1,60.,.3,3.]]


def rows(seed=61001):
    return [dict(seed=seed,row=i+1,x=x[:],f=f[:],penalized=False,detail={})
            for i,(x,f) in enumerate(zip(X,F))]


def fixture(parent, seed, cfg, case="valid", omit_meta=None, observed_options=None):
    if savemat is None:
        raise unittest.SkipTest("SciPy is not available in the existing Python runtime")
    observed_options=copy.deepcopy(cfg["options"] if observed_options is None else observed_options)
    folder=Path(parent)/f"seed_{seed}"
    folder.mkdir()
    x=np.array(X,dtype=float)
    values=np.array(F,dtype=float)
    statuses=[("OK","OK") for _ in X]
    if case == "nan":
        x[0,0]=np.nan
    elif case == "inf":
        values[0,0]=np.inf
        values[1,1]=-np.inf
    elif case == "bounds":
        x[0,0]=.01
    elif case == "penalty":
        values[0]=[1000.,1e6,1e6]
        statuses[0]=("PENALIZED","PENALIZED")
    elif case == "valid_precision":
        x[0,0]=np.nextafter(.08,.2)
        values[0,0]=np.nextafter(0.,1.)
    elif case != "valid":
        raise ValueError(case)
    expected_head="1"*40
    exact_paths=dict(
        PRIMARY_OUTPUT_mat=str((folder/"PRIMARY_OUTPUT.mat").resolve()),
        EVALUATION_DETAILS_mat=str((folder/"EVALUATION_DETAILS.mat").resolve()),
        FROZEN_CONFIG_json=str((folder/"FROZEN_CONFIG.json").resolve()),
        FINAL_CANDIDATES_csv=str((folder/"FINAL_CANDIDATES.csv").resolve()),
        SOLVER_DIARY_txt=str((folder/"SOLVER_DIARY.txt").resolve()),
        SEED_SHA256_json=str((folder/"SEED_SHA256.json").resolve()))
    meta=dict(seed=seed,config_sha256=io.CONFIG_HASH,protocol_sha256=io.PROTOCOL_HASH,
        source_lock_sha256=io.LOCK_HASH,status="COMPLETED",errors=[],generations=200,
        funccount=3,exitflag=0,message="Synthetic MaxGenerations",runtime_seconds=1.,
        start_timestamp="2026-09-05T12:00:00.000+00:00",
        end_timestamp="2026-09-05T12:00:01.000+00:00",elapsed_time_seconds=1.,
        exact_output_directory=str(folder.resolve()),exact_primary_output_paths=exact_paths,
        expected_git_head=expected_head,observed_git_head=expected_head,
        solver_options=observed_options,
        solver_output=dict(message="Synthetic MaxGenerations",generations=200,funccount=3),
        productive_dependency_hashes=io.read_json(io.HERE/"source_lock.json"),
        observed_options=observed_options,rng_type="twister",rng_seed=seed,**cfg["environment"])
    if omit_meta:
        meta.pop(omit_meta)
    rng=dict(Type="twister",Seed=seed,State=np.array([1.,2.,3.]))
    savemat(folder/"PRIMARY_OUTPUT.mat",dict(X=x,F=values,
        population=x,scores=values,metadata_json=json.dumps(meta),
        exitflag=0,output=dict(generations=200,funccount=3),
        rng_initial=rng,rng_final=rng))
    details=[json.dumps(dict(status=status,execution_status=execution,
                            outputs=dict(dry_time=19.9),cost=dict(LPG_mass_kg=1.)))
             for status,execution in statuses]
    savemat(folder/"EVALUATION_DETAILS.mat",dict(callX=x,callF=values,
        callObjectiveF=values,details_json=np.array(details,dtype=object)))
    io.write_json(folder/"FROZEN_CONFIG.json",dict(seed=seed,config=cfg,
        observed_options=observed_options,effective_functions_expected=cfg["effective_functions"]))
    with (folder/"FINAL_CANDIDATES.csv").open("w",newline="") as f:
        w=csv.writer(f); w.writerow(["source","row","x1","x2","x3","x4","f1","f2","f3"])
        for label in ("returned","population"):
            for i,(candidate,v) in enumerate(zip(x,values),1):
                w.writerow([label,i,*candidate,*v])
    (folder/"SOLVER_DIARY.txt").write_text(f"ROR_SEED_START {seed}\nROR_SEED_COMPLETE {seed}\n")
    inventory={}
    for p in folder.iterdir():
        inventory[p.name.replace(".","_")]=dict(path=p.name,size=p.stat().st_size,sha256=io.sha(p))
    io.write_json(folder/"SEED_SHA256.json",inventory)
    return folder


def benchmark(parent, name, corrupt=False):
    if savemat is None:
        raise unittest.SkipTest("SciPy is not available in the existing Python runtime")
    count=44 if name == "HB200_CURRENT" else 9
    x=np.tile(np.array(X,dtype=float),(count//3+1,1))[:count]
    f=np.tile(np.array(F,dtype=float),(count//3+1,1))[:count]
    mat=Path(parent)/f"{name}.mat"
    savemat(mat,dict(X=x,F=f))
    manifest=Path(parent)/f"{name}.json"
    io.write_json(manifest,dict(name=name,basis="CURRENT_COST_E3D",
        objective_blob="d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc",
        mat_path=mat.name,sha256=io.sha(mat),x_field="X",f_field="F"))
    if corrupt:
        with mat.open("ab") as stream:
            stream.write(b"corrupt")
    return manifest


def campaign_fixture(parent, cfg):
    root=Path(parent)
    for name in ("audit","tables","numeric","figures"):
        (root/name).mkdir()
    for seed in core.SEEDS:
        fixture(root,seed,cfg)
    io.write_json(root/"CAMPAIGN_MANIFEST.json",dict(
        status="COMPLETED_PENDING_POSTRUN",seeds=list(core.SEEDS),
        protocol_sha256=io.PROTOCOL_HASH,config_sha256=io.CONFIG_HASH,
        source_lock_sha256=io.LOCK_HASH))
    io.write_json(root/"audit/SOFTWARE_IDENTITY.json",
                  dict(sources=io.read_json(io.HERE/"source_lock.json")))
    return [benchmark(root,"HB200_CURRENT"),benchmark(root,"C")]


def final_derivatives(root):
    names=("POSTRUN_INTEGRITY.json","DOMINANCE_AUDIT.json","PRIMARY_SUFFICIENCY.json",
           "ALL_RUNS.csv","N_R.csv","N_POOL.csv","INTER_RUN_METRICS.csv",
           "OPERATING_RECOMMENDATIONS.csv","BENCHMARK_COMPARISON.csv","N_POOL.mat",
           "SHA256_MANIFEST.csv")
    return [p for p in Path(root).rglob("*") if p.is_file() and p.name in names]


class CoreTests(unittest.TestCase):
    def test_exact_dominance_no_tolerance(self):
        self.assertFalse(core.dominates((1.,1.,1.),(1.,1.,1.)))
        self.assertTrue(core.dominates((1.,1.,1.),(1.+2**-52,1.,1.)))
        self.assertTrue(core.near_tie((1.,1.,1.),(1.+2**-52,1.,1.)))

    def test_incomparable_and_ranks(self):
        r=rows()
        r.append(dict(r[0],f=[2.,2.,2.],x=[.11,60.,.3,3.]))
        self.assertEqual(core.ranks(r),[1,1,1,2])
        self.assertEqual(len(core.nondominated(r)),3)
        self.assertEqual(core.coverage(r[:3],r[3:]),1)
        self.assertEqual(core.coverage(r[:3],r[:3]),0)
        self.assertIsNone(core.coverage(r,[]))

    def test_igd_orientation(self):
        self.assertEqual(core.igd_plus([(0.,0.,0.)],[(1.,0.,0.)]),1)
        self.assertEqual(core.igd_plus([(1.,0.,0.)],[(0.,0.,0.)]),0)

    def test_hv_known_union(self):
        self.assertAlmostEqual(core.hypervolume(F)[0],.031)
        self.assertAlmostEqual(core.hypervolume([(0.,0.,0.)])[0],1.331)
        self.assertEqual(core.hypervolume([(1.2,0.,0.)]),(0.,1))
        self.assertEqual(core.hypervolume([]),(0.,0))

    def test_hv_independent_inclusion_exclusion(self):
        rng=random.Random(823)
        for _ in range(20):
            p=[tuple(rng.random() for _ in range(3)) for _ in range(5)]
            expected=0.
            for n in range(1,len(p)+1):
                for subset in itertools.combinations(p,n):
                    expected+=(-1)**(n+1)*np.prod(
                        [1.1-max(q[k] for q in subset) for k in range(3)])
            self.assertAlmostEqual(core.hypervolume(p)[0],expected,places=12)

    def test_identical_five_runs_pass(self):
        result=core.analyze([dict(seed=s,valid=True,rows=rows(s)) for s in core.SEEDS])
        self.assertEqual(result["PRIMARY_SUFFICIENCY"],"PASS")
        self.assertEqual(len(result["pool"]),3)
        self.assertEqual(result["extreme_runs"],[5,5,5])
        self.assertEqual(result["hv_ratio"],1)
        self.assertTrue(all(m["contribution"]==3 for m in result["metrics"]))
        self.assertEqual(len(result["recommendations"]),4)

    def test_missing_seed_blocked(self):
        with self.assertRaises(core.Blocked):
            core.analyze([dict(seed=s,valid=True,rows=rows(s)) for s in core.SEEDS[:-1]])

    def test_invalid_run_fails(self):
        r=[dict(seed=s,valid=True,rows=rows(s)) for s in core.SEEDS]
        r[0]["valid"]=False
        self.assertEqual(core.analyze(r)["PRIMARY_SUFFICIENCY"],"FAIL")

    def test_weak_run_not_rescued(self):
        r=[dict(seed=s,valid=True,rows=rows(s)) for s in core.SEEDS]
        r[0]["rows"]=r[0]["rows"][:1]
        self.assertEqual(core.analyze(r)["PRIMARY_SUFFICIENCY"],"FAIL")

    def test_zero_range_and_penalty_block(self):
        with self.assertRaises(core.Blocked):
            core.normalization(rows()[:1])
        with self.assertRaises(core.Blocked):
            core.unique_designs([dict(rows()[0],penalized=True)])

    def test_design_conflict_and_origins(self):
        r=rows()
        with self.assertRaises(core.Blocked):
            core.unique_designs(r+[dict(r[0],f=[.1,1.,1.])])
        x=core.unique_designs(r+[dict(r[0],row=9)])
        merged=core.unique_designs(x+rows(61002))
        self.assertEqual(merged[0]["origins"],[[61001,1],[61001,9],[61002,1]])

    def test_recommendation_gate_and_tie(self):
        with self.assertRaises(core.Blocked):
            core.recommendations(rows(),"FAIL")
        r=rows()+[dict(rows()[0],x=[.071,50.,.1,1.],row=4)]
        choice=core.recommendations(r,"PASS")
        self.assertEqual(choice["MOISTURE_PRIORITY"]["row"],4)
        self.assertEqual(choice["BALANCED_COMPROMISE"]["row"],4)

    def test_benchmark_separate(self):
        p=rows()
        saved=copy.deepcopy(p)
        comp=core.compare_benchmark(p,[dict(f=[2.,2.,2.])])
        self.assertEqual(comp["pool_to_full"],1.)
        self.assertEqual(p,saved)


class IOTests(unittest.TestCase):
    def test_mat_requires_double_not_integer_or_single(self):
        for a in (np.array([[1,2,3]],dtype=np.int64),np.array([[1,2,3]],dtype=np.float32)):
            with self.assertRaises(core.Blocked):
                io.matrix(a,3)

    def test_config_exact(self):
        cfg=io.frozen_config()
        self.assertEqual(cfg["seeds"],list(core.SEEDS))
        self.assertEqual(cfg["options"]["PopulationSize"],24)
        self.assertEqual(cfg["options"]["MaxGenerations"],200)
        self.assertIs(cfg["options"]["UseParallel"],False)
        self.assertEqual(cfg["options"]["InitialPopulationMatrix"],[])
        self.assertEqual(cfg["options"]["InitialScoresMatrix"],[])
        self.assertFalse(cfg["HB200_INITIALIZATION"] or cfg["C_INITIALIZATION"])
        self.assertEqual(cfg["analysis"]["reference"],[1.1]*3)

    def test_option_representation_equivalence_and_raw_preservation(self):
        cfg=io.frozen_config()["options"]
        raw=copy.deepcopy(cfg)
        raw["PopulationType"]="doublevector"
        saved=copy.deepcopy(raw)
        self.assertTrue(io.options_equivalent(raw,cfg))
        self.assertEqual(raw,saved)
        canonical=copy.deepcopy(cfg)
        canonical["PopulationType"]="doublevector"
        self.assertTrue(io.options_equivalent(raw,canonical))

    def test_unknown_population_type_fails_closed(self):
        cfg=io.frozen_config()["options"]
        raw=copy.deepcopy(cfg)
        raw["PopulationType"]="customPopulation"
        self.assertFalse(io.options_equivalent(raw,cfg))

    def test_other_option_mismatches_remain_strict(self):
        cfg=io.frozen_config()["options"]
        for key,value in (("PopulationSize",25),("MaxGenerations",201),
                          ("UseParallel",True),("ParetoFraction",.36),
                          ("CrossoverFraction",.81),("Display","ITER")):
            changed=copy.deepcopy(cfg)
            changed[key]=value
            self.assertFalse(io.options_equivalent(changed,cfg),key)

    def test_option_serialization_shapes_are_unchanged(self):
        cfg=io.frozen_config()["options"]
        raw=copy.deepcopy(cfg)
        raw["PopulationType"]="doublevector"
        before=copy.deepcopy(raw)
        compared=io.canonical_options(raw)
        self.assertEqual(raw,before)
        for key in ("DistanceMeasureFcn","SelectionFcn","MaxTime",
                    "InitialPopulationRange","InitialPopulationMatrix",
                    "InitialScoresMatrix"):
            self.assertEqual(compared[key],before[key])

    def test_postrun_raw_population_type_mat_fixture(self):
        cfg=io.frozen_config()
        raw=copy.deepcopy(cfg["options"])
        raw["PopulationType"]="doublevector"
        saved=copy.deepcopy(raw)
        with tempfile.TemporaryDirectory(prefix="ror_options_raw_") as td:
            folder=fixture(td,61001,cfg,observed_options=raw)
            audit=io.audit_seed(folder,cfg)
            self.assertTrue(audit["valid"])
            primary=loadmat(folder/"PRIMARY_OUTPUT.mat",simplify_cells=True)
            metadata=json.loads(str(primary["metadata_json"]))
            self.assertEqual(metadata["observed_options"]["PopulationType"],"doublevector")
            self.assertEqual(raw,saved)
        for key,value in (("PopulationType","customPopulation"),
                          ("PopulationSize",25),("MaxGenerations",201),
                          ("UseParallel",True)):
            changed=copy.deepcopy(raw)
            changed[key]=value
            with self.subTest(key=key), tempfile.TemporaryDirectory(prefix="ror_options_bad_") as td:
                folder=fixture(td,61001,cfg,observed_options=changed)
                with self.assertRaises(core.Blocked):
                    io.audit_seed(folder,cfg)

    def test_static_python_syntax(self):
        for p in io.HERE.glob("*.py"):
            ast.parse(p.read_text(encoding="utf-8"),filename=str(p))

    def test_runner_safety_structure(self):
        text=(io.HERE/"run_ror_campaign.m").read_text(encoding="utf-8")
        self.assertLess(text.index("ROR:ExecutionLocked"),text.index("setup_v05_paths();"))
        self.assertLess(text.index("ROR:ExecutionLocked"),text.index("rng(seed"))
        self.assertNotIn("load(",text)
        self.assertEqual(text.count("]=gamultiobj("),1)
        self.assertNotIn("run_corrected_r1",text)
        self.assertIn("callObjectiveF",text)
        self.assertIn("reservation.mkdir()",text)
        self.assertIn("'expected_head'",text)
        self.assertIn("'start_timestamp'",text)
        self.assertIn("meta.exact_primary_output_paths",text)
        self.assertIn("ror_options_equivalent(cfg.options,observed_options)",text)
        self.assertNotIn("function value=ror_canonical_population_type",text)

    def test_hash_frozen_paths_preserve_exact_bytes(self):
        root=io.HERE.parents[2]
        expected={"frozen_config.json":io.CONFIG_HASH,"source_lock.json":io.LOCK_HASH}
        for name,digest in expected.items():
            path=io.HERE/name
            rel=path.relative_to(root).as_posix()
            attr=subprocess.check_output(
                ["git","check-attr","text","--",rel],cwd=root,text=True).strip()
            self.assertTrue(attr.endswith(": unset"),attr)
            filtered=subprocess.check_output(
                ["git","hash-object","--path="+rel,str(path)],cwd=root,text=True).strip()
            raw=subprocess.check_output(
                ["git","hash-object","--no-filters",str(path)],cwd=root,text=True).strip()
            self.assertEqual(filtered,raw)
            self.assertEqual(io.sha(path),digest)

    def test_default_postrun_locked(self):
        with self.assertRaises(core.Blocked):
            io.postrun("NONEXISTENT",False)

    def test_synthetic_mat_csv_audit_and_hash_corruption(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_synthetic_") as td:
            folder=fixture(td,61001,cfg)
            audit=io.audit_seed(folder,cfg)
            self.assertEqual(len(audit["rows"]),6)
            self.assertEqual(audit["excluded"],dict(nonfinite=0,bounds=0,penalized=0))
            with (folder/"SOLVER_DIARY.txt").open("a") as f:
                f.write("altered")
            with self.assertRaises(core.Blocked):
                io.audit_seed(folder,cfg)

    def test_audit_seed_nonfinite_nan(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_audit_nan_") as td:
            audit=io.audit_seed(fixture(td,61001,cfg,"nan"),cfg)
            self.assertEqual(audit["excluded"]["nonfinite"],2)
            self.assertEqual(len(audit["rows"]),4)

    def test_audit_seed_nonfinite_both_infinities(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_audit_inf_") as td:
            audit=io.audit_seed(fixture(td,61001,cfg,"inf"),cfg)
            self.assertEqual(audit["excluded"]["nonfinite"],4)
            self.assertEqual(len(audit["rows"]),2)

    def test_audit_seed_bounds(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_audit_bounds_") as td:
            audit=io.audit_seed(fixture(td,61001,cfg,"bounds"),cfg)
            self.assertEqual(audit["excluded"]["bounds"],2)
            self.assertEqual(len(audit["rows"]),4)

    def test_audit_seed_penalty(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_audit_penalty_") as td:
            audit=io.audit_seed(fixture(td,61001,cfg,"penalty"),cfg)
            self.assertEqual(audit["excluded"]["penalized"],2)
            self.assertEqual(len(audit["rows"]),4)

    def test_audit_seed_valid_preserves_precision_and_provenance(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_audit_valid_") as td:
            audit=io.audit_seed(fixture(td,61001,cfg,"valid_precision"),cfg)
            self.assertEqual(audit["excluded"],dict(nonfinite=0,bounds=0,penalized=0))
            self.assertEqual(audit["rows"][0]["x"][0],np.nextafter(.08,.2))
            self.assertEqual(audit["rows"][0]["f"][0],np.nextafter(0.,1.))
            self.assertEqual(audit["rows"][0]["seed"],61001)

    def test_audit_seed_each_missing_provenance_field_fails_closed(self):
        cfg=io.frozen_config()
        for field in sorted(io.REQUIRED_EXECUTION_METADATA):
            with self.subTest(field=field):
                with tempfile.TemporaryDirectory(prefix="ror_audit_metadata_") as td:
                    folder=fixture(td,61001,cfg,omit_meta=field)
                    with self.assertRaises(core.Blocked):
                        io.audit_seed(folder,cfg)

    def test_full_synthetic_postrun_and_no_overwrite(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_synthetic_campaign_") as td:
            root=Path(td)
            manifests=campaign_fixture(root,cfg)
            answer=io.postrun(root,True,manifests)
            self.assertEqual(answer["status"],"PASS")
            self.assertEqual(answer["publish_status"],"COMPLETE_TRANSACTIONAL")
            self.assertTrue((root/"numeric/N_POOL.mat").exists())
            self.assertTrue((root/"tables/OPERATING_RECOMMENDATIONS.csv").exists())
            with self.assertRaises(core.Blocked):
                io.postrun(root,True,manifests)

    def test_invalid_benchmark_fails_before_derivation(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_bad_benchmark_") as td:
            root=Path(td)
            manifests=campaign_fixture(root,cfg)
            bad=io.read_json(manifests[0])
            with (root/bad["mat_path"]).open("ab") as stream:
                stream.write(b"corrupt")
            with self.assertRaises(core.Blocked):
                io.postrun(root,True,manifests)
            self.assertEqual(final_derivatives(root),[])
            self.assertEqual(list(root.parent.glob(f".{root.name}_postrun_*")),[])

    def test_derivation_failure_has_no_partial_outputs_and_clean_retry(self):
        cfg=io.frozen_config()
        with tempfile.TemporaryDirectory(prefix="ror_derivation_failure_") as td:
            root=Path(td)
            manifests=campaign_fixture(root,cfg)
            original=io.write_csv
            with mock.patch.object(io,"write_csv",side_effect=RuntimeError("synthetic derivation failure")):
                with self.assertRaisesRegex(RuntimeError,"synthetic derivation failure"):
                    io.postrun(root,True,manifests)
            self.assertEqual(final_derivatives(root),[])
            self.assertEqual(list(root.parent.glob(f".{root.name}_postrun_*")),[])
            self.assertIs(io.write_csv,original)
            answer=io.postrun(root,True,manifests)
            self.assertEqual(answer["publish_status"],"COMPLETE_TRANSACTIONAL")


if __name__ == "__main__":
    unittest.main(verbosity=2)
