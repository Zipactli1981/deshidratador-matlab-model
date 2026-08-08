# AGENTS.md — Deshidratador MATLAB / Q1

## Startup protocol

Before starting any substantive task:

1. Read:
   - `00_project_context/01_CURRENT_STATE.md`
   - `00_project_context/05_PHASE_HANDOFF_CURRENT.md`

2. If needed, read:
   - `00_project_context/02_METHOD_GUARDRAILS.md`
   - `00_project_context/03_DECISION_LOG.md`
   - `00_project_context/04_ARTIFACT_INDEX.md`

3. Treat these files as the current canonical project state unless direct Git evidence proves they are stale.

4. If repository state conflicts with `01_CURRENT_STATE.md`, STOP and report the discrepancy before modifying or executing anything.

## Execution safety

MATLAB execution, objective/model evaluations, `gamultiobj`, R1/R2/R3/minrep/400gen and sensitivity runs require explicit task-level authorization.

Do not infer execution permission from prior tasks. Do not automatically rerun after timeout, crash or incomplete evidence.

## Git safety

Local commits require task-level authorization.

Push, PR creation/editing, merge, branch deletion, release/publication and other remote mutations require explicit approval.

## Productive code

Do not modify productive objective/model/cost/wrapper files merely to simplify an audit or analysis. Prefer separate analysis scripts and documentary artifacts.

## Scientific state

Historical R1 vectors reevaluated with COST-E3D are historical samples, not a corrected Pareto front.

CORRECTED_R1 is internally validated but comparative scientific review is pending.

Do not promote comparative conclusions to the manuscript until the current phase explicitly authorizes it.

## Context discipline

Do not reconstruct completed phases unless required to resolve a concrete discrepancy.

At phase boundaries, stop instead of automatically continuing into the next scientific phase.

Keep generated handoffs compact and update canonical project-context files only when authorized.
