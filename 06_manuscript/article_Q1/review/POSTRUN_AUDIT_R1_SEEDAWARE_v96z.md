# POSTRUN AUDIT R1 SEEDAWARE v96z

## Scope

Static postrun audit of the existing formal R1 seed-aware evidence produced on
2026-07-27. This audit did not execute MATLAB, `gamultiobj`, R1, R2, or R3. It
does not authorize any additional formal run and does not declare the candidate
chain official.

The audit is anchored to the two exact MAT paths and SHA-256 hashes supplied for
R1. Existing global `SEEDAWARE_FORMAL_R1_ONLY_*` CSV/Markdown files were not
used as current-run evidence because they retain an older local path and an
older runtime.

## Audit outcome

`POSTRUN_AUDIT_R1_SEEDAWARE_v96z_PASS_WITH_WARNINGS`

Decision:

`R1_EVIDENCE_CONSISTENT_POSTPROCESS_ONLY_DO_NOT_RUN_R2_R3`

The reported wrapper diagnosis `SEEDAWARE_FORMAL_R1_ONLY_PASS` is consistent
with the inspected R1 MAT evidence. This postrun result does not establish
solver convergence, validate provisional CO2 factors, or authorize R2/R3.

## Verified artifacts

| Artifact | Path | SHA-256 | Verification |
|---|---|---|---|
| Formal runner MAT | `05_runs/triobjective_formal_ga_v96m/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_20260727_185506/mat/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix.mat` | `E550F09ED17030F1318ADEC6A4F5F5FA97194E147BAC31132B8123AC6A488170` | Matches supplied hash |
| Formal raw MAT | `05_runs/triobjective_formal_ga_v96m/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_20260727_185506/mat/TRIOBJECTIVE_FORMAL_GA_v96m_seedaware_v96z_rngfix_raw.mat` | `92BEEC3F2FF6D26CDEEB7A4AB9ABC053F8178FE47B38B8C17AD3CA9F7AD59397` | Hash calculated during static audit |
| Wrapper R1 MAT | `06_manuscript/article_Q1/runs/SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat` | `A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0` | Matches supplied hash |
| R1 traceability MAT | `06_manuscript/article_Q1/traceability/SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.mat` | `EFF59291872B12A7387AF6FA061083A545C16E763B252B6174E0BCA23EAB3C9E` | Hash calculated during static audit |

The MAT files remain ignored external evidence. They are not added, moved, or
versioned by this audit.

## R1 consistency summary

| Metric | Verified value |
|---|---:|
| seed | 61001 |
| RNG control | `EXTERNAL_SEED_APPLIED` |
| `rngSeed_v96z` | 61001 |
| PopulationSize | 24 |
| MaxGenerations | 50 |
| formal mode | `hybrid` |
| reference mode | `gasLP` |
| `X` size | 9 x 4 |
| `F` size | 9 x 3 |
| solutions | 9 |
| finite solution rows | 9 |
| penalized solution rows | 0 |
| final population size | 24 x 4 |
| final scores size | 24 x 3 |
| minimum MR | 0.014734459102958 |
| minimum cost | 0.246303839698567 |
| minimum CO2 | 0.893115176231879 |
| function evaluations | 1200 |
| generations | 50 |
| exitflag | 0 |
| formal runner runtime | 3.85731256280556 h |
| wrapper elapsed time | 3.88203267297222 h |

The formal and wrapper MAT files contain identical `X` and `F` arrays. Every
entry of `X`, `F`, `population`, and `scores` inspected in the numeric evidence
is finite.

The raw MAT contains the serialized `opts` object with class
`optim.options.GamultiobjOptions`. The formal MAT also stores `popSize=24` and
`maxGen=50`; the formal report records the same configuration. Exact option
properties should be rechecked by the provided lightweight MATLAB audit before
any future interpretation, without invoking the solver.

## Solver stop interpretation

Observed message:

```text
gamultiobj stopped because it exceeded options.MaxGenerations.
```

The combination of `exitflag=0`, `generations=50`, and this message is
internally consistent with stopping at the configured maximum generation count.
It is not evidence that the Pareto front converged. No convergence claim should
be derived solely from the R1 PASS diagnosis.

## R2/R3 scope check

The current run directory
`SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454` contains only the `R1`
directory and its seed-61001 MAT. No `R2`, `R3`, seed 61002, or seed 61003
evidence was found inside this current R1 run.

Historical R2/R3 folders from an earlier
`MINREP_SEED_CONTROLLED_RUN_v96z_20260628_024351` exist elsewhere under
`06_manuscript/article_Q1/runs`. They predate and do not belong to the current
seed-aware R1. Therefore this audit does not make the broader claim that the
repository contains no historical R2/R3 artifacts.

No R2/R3 execution is authorized or recommended by this audit.

## CO2 status

CO2 remains explicitly provisional:

- `objective_productive_corrected_v96j_triobjective_CO2_fix1.m` contains
  `PROVISIONAL_FOR_CODE_VALIDATION`;
- the formal MAT flag `emission_factors_provisional` is true;
- the formal checks state that manuscript-final CO2 claims are blocked.

The minimum CO2 value is reported only to verify consistency with the existing
R1 evidence. It must not be used for a final manuscript claim.

## Traceability-table warning

The current traceability MAT contains `Tplan`, `Tsummary`, and `Tchecks` and
points to the D-drive R1 run from 2026-07-27.

However, the global files:

- `SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix.md`;
- `SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_Tplan.csv`;
- `SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_Tsummary.csv`;
- `SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_Tchecks.csv`;

retain an old `C:\Users\PC\MATLAB Drive\...` path and an older 25.4-hour runtime.
They must not be treated as the authoritative summary for the current R1. This
PR does not overwrite or repair them because its scope is limited to a new,
hash-anchored postrun audit.

## Files produced by this audit PR

- `02_src_limpio/audit/postrun_audit_r1_seedaware_v96z.m`
- `06_manuscript/article_Q1/review/POSTRUN_AUDIT_R1_SEEDAWARE_v96z.md`
- `06_manuscript/article_Q1/tables/POSTRUN_AUDIT_R1_SEEDAWARE_v96z_checks.csv`
- `06_manuscript/article_Q1/tables/POSTRUN_AUDIT_R1_SEEDAWARE_v96z_summary.csv`
- `06_manuscript/article_Q1/tables/POSTRUN_AUDIT_R1_SEEDAWARE_v96z_artifacts.csv`

The MATLAB function defaults to read-only operation. Writing regenerated audit
tables and Markdown requires the caller to pass `writeOutputs=true`. It never
calls the model or solver.

## Active limitations

- R1 PASS is a postrun consistency finding, not a final scientific claim.
- Solver convergence is not established.
- CO2 factors remain provisional.
- Existing global R1 summaries contain stale path/runtime evidence.
- The candidate operational chain remains non-official.
- R2/R3 remain outside the authorized scope.
