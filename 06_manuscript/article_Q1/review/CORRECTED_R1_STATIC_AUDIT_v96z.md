# CORRECTED R1 — static clone audit v96z

## Verdict

`CORRECTED_R1_STATIC_CLONE_AUDIT = PASS`

`MATLAB_EXECUTED = NO`
`GAMULTIOBJ_EXECUTED = NO`
`MODEL_EVALUATED = NO`
`PRODUCTIVE_CODE_MODIFIED = NO`

## Canonical baseline

- Branch: `main`
- HEAD: `e74e70ff7e87c9d9f19955b341ce152b11418f92`
- Historical runner: `02_src_limpio/production/run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m`
- Historical runner blob: `243554b3df9644a74c54d45472068557204d650c`
- Corrected runner clone: `02_src_limpio/production/run_corrected_r1_cost_e3d_v96z.m`
- Corrected runner clone blob: `075742ff72bc5b7a51e8c54b6122feea7a2fb345`
- Historical R1 artifact SHA-256: `A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0`

## Exact configuration freeze

- Seed: `61001` — explicit and mandatory.
- RNG call on valid path: `rng(rngSeed,'twister')` — unchanged.
- PopulationSize: `24`.
- MaxGenerations: `50`.
- Mode: `hybrid`.
- Reference mode: `gasLP`.
- nvars: `4`.
- x_selected: `[0.0740767982118, 62.6832965028, 0.672252618341, 11.6517528081]`.
- lb: `[0.0540767982118, 57.6832965028, 0.422252618341, 8.6517528081]`.
- ub: `[0.0940767982118, 67.6832965028, 0.922252618341, 14]`.
- UseParallel: `false`.
- FunctionTolerance: `1e-5`.
- ConstraintTolerance: `1e-6`.
- PlotFcn: `[]`.
- Objective handle: unchanged.
- `gamultiobj` call signature: unchanged.
- Solver constraints: unchanged (only `lb`, `ub`).

## Allowed diff classes

1. `naming`
2. `preflight/configuration guard`
3. `provenance/status`

No other class is permitted.

## Protected-source fingerprints

Verification is Git-object-aware:

- exact `HEAD:path` blob must equal the frozen expected SHA;
- path-aware `git hash-object --path=...` for the checkout must equal the same SHA;
- `git diff --quiet HEAD -- <path>` must report no logical change.

This avoids false failures caused solely by Windows CRLF checkout bytes without
weakening repository identity checks.

```json
{
  "historical_runner": {
    "path": "02_src_limpio/production/run_guarded_triobjective_formal_ga_v96m_seedaware_v96z_rngfix.m",
    "expected": "243554b3df9644a74c54d45472068557204d650c",
    "head_blob": "243554b3df9644a74c54d45472068557204d650c",
    "worktree_filtered_blob": "243554b3df9644a74c54d45472068557204d650c",
    "git_path_clean": true,
    "pass": true
  },
  "formal_design": {
    "path": "02_src_limpio/production/design_triobjective_formal_run_v96l.m",
    "expected": "2006fe8da06740c9bcf0bc1b1c7bdd7b85df0268",
    "head_blob": "2006fe8da06740c9bcf0bc1b1c7bdd7b85df0268",
    "worktree_filtered_blob": "2006fe8da06740c9bcf0bc1b1c7bdd7b85df0268",
    "git_path_clean": true,
    "pass": true
  },
  "corrected_triobjective": {
    "path": "02_src_limpio/production/objective_productive_corrected_v96j_triobjective_CO2_fix1.m",
    "expected": "d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc",
    "head_blob": "d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc",
    "worktree_filtered_blob": "d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc",
    "git_path_clean": true,
    "pass": true
  },
  "base_objective": {
    "path": "02_src_limpio/production/objective_productive_corrected_v95j_endpoint_TMAX_corrected.m",
    "expected": "2e3e29cc1d417eedd278ba579bc10b4c2eda4ba0",
    "head_blob": "2e3e29cc1d417eedd278ba579bc10b4c2eda4ba0",
    "worktree_filtered_blob": "2e3e29cc1d417eedd278ba579bc10b4c2eda4ba0",
    "git_path_clean": true,
    "pass": true
  },
  "wrapper_v18": {
    "path": "02_src_limpio/wrappers/opt_tunel_mod2_v18_endpoint_TMAX_corrected.m",
    "expected": "b825a513c95f50ac105d16346650cfe48f7d0096",
    "head_blob": "b825a513c95f50ac105d16346650cfe48f7d0096",
    "worktree_filtered_blob": "b825a513c95f50ac105d16346650cfe48f7d0096",
    "git_path_clean": true,
    "pass": true
  },
  "cost_params": {
    "path": "02_src_limpio/cost/build_cost_params_historical.m",
    "expected": "4b1fbfb8554ba59a79ed7908f62b83b38e8947c8",
    "head_blob": "4b1fbfb8554ba59a79ed7908f62b83b38e8947c8",
    "worktree_filtered_blob": "4b1fbfb8554ba59a79ed7908f62b83b38e8947c8",
    "git_path_clean": true,
    "pass": true
  },
  "cost_breakdown": {
    "path": "02_src_limpio/cost/calc_cost_breakdown.m",
    "expected": "e1c9a29df585c4f2016b07d5d1f28b71eb917f52",
    "head_blob": "e1c9a29df585c4f2016b07d5d1f28b71eb917f52",
    "worktree_filtered_blob": "e1c9a29df585c4f2016b07d5d1f28b71eb917f52",
    "git_path_clean": true,
    "pass": true
  }
}
```

## Protected algorithmic blocks

```json
{
  "optimoptions": {
    "original_count": 1,
    "clone_count": 1,
    "pass": true
  },
  "objective_handle": {
    "original_count": 1,
    "clone_count": 1,
    "pass": true
  },
  "gamultiobj_call": {
    "original_count": 1,
    "clone_count": 1,
    "pass": true
  },
  "preflight_modes": {
    "original_count": 1,
    "clone_count": 1,
    "pass": true
  },
  "penalty_row_classification": {
    "original_count": 1,
    "clone_count": 1,
    "pass": true
  }
}
```

## Transformation log

```json
[
  {
    "label": "naming:function",
    "count": 4
  },
  {
    "label": "naming:artifact_prefix",
    "count": 16
  },
  {
    "label": "naming:preflight_usage",
    "count": 1
  },
  {
    "label": "naming:diagnosis:TRIOBJECTIVE_FORMAL_RUN_SCRIPT_READY_NO_EXECUTION",
    "count": 1
  },
  {
    "label": "naming:diagnosis:TRIOBJECTIVE_FORMAL_RUN_EXECUTION_COMPLETED_PASS",
    "count": 1
  },
  {
    "label": "naming:diagnosis:TRIOBJECTIVE_FORMAL_RUN_EXECUTION_REQUIRES_REVIEW",
    "count": 1
  },
  {
    "label": "naming:diagnosis:TRIOBJECTIVE_FORMAL_RUN_SCRIPT_REQUIRES_REVIEW",
    "count": 1
  },
  {
    "label": "naming:next_step_hold",
    "count": 1
  },
  {
    "label": "naming:next_step_post",
    "count": 1
  },
  {
    "label": "naming:txt_status",
    "count": 2
  },
  {
    "label": "preflight:seed_freeze",
    "count": 1
  },
  {
    "label": "preflight:exact_configuration_freeze",
    "count": 1
  },
  {
    "label": "preflight:replace_obsolete_source_marker",
    "count": 1
  },
  {
    "label": "provenance:header",
    "count": 1
  },
  {
    "label": "provenance:M08",
    "count": 1
  },
  {
    "label": "provenance:formal_flags",
    "count": 1
  },
  {
    "label": "provenance:markdown_status",
    "count": 1
  }
]
```

## Automatic reverse-proof log

The reversal is not maintained as a second manual list. It is generated from
the same `old -> new` rules used to construct the clone and applied in exact
reverse order.

```json
[
  {
    "label": "provenance:markdown_status",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "provenance:formal_flags",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "provenance:M08",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "provenance:header",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "preflight:replace_obsolete_source_marker",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "preflight:exact_configuration_freeze",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "preflight:seed_freeze",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "naming:txt_status",
    "applied_count": 2,
    "available_before_reverse": 2,
    "pass": true
  },
  {
    "label": "naming:next_step_post",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "naming:next_step_hold",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "naming:diagnosis:TRIOBJECTIVE_FORMAL_RUN_SCRIPT_REQUIRES_REVIEW",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "naming:diagnosis:TRIOBJECTIVE_FORMAL_RUN_EXECUTION_REQUIRES_REVIEW",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "naming:diagnosis:TRIOBJECTIVE_FORMAL_RUN_EXECUTION_COMPLETED_PASS",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "naming:diagnosis:TRIOBJECTIVE_FORMAL_RUN_SCRIPT_READY_NO_EXECUTION",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "naming:preflight_usage",
    "applied_count": 1,
    "available_before_reverse": 1,
    "pass": true
  },
  {
    "label": "naming:artifact_prefix",
    "applied_count": 16,
    "available_before_reverse": 16,
    "pass": true
  },
  {
    "label": "naming:function",
    "applied_count": 4,
    "available_before_reverse": 4,
    "pass": true
  }
]
```

## Equivalence proof

After reversing only the explicitly allowed naming/provenance changes and
removing only the two marked preflight guard blocks:

`NORMALIZED_CLONE_EQUALS_HISTORICAL_RUNNER = YES`

Therefore the optimizer configuration and algorithmic execution block are
unchanged on the valid frozen path.

## Static-only limitation

This audit does not call MATLAB, does not deserialize historical MATLAB
`optim.options.GamultiobjOptions`, does not evaluate the model/objective and
does not launch `gamultiobj`.

Execution remains blocked pending a separate explicit authorization.
