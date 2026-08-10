# ARTIFACT INDEX — Deshidratador MATLAB / Q1

## Baselines documentados

CORRECTED_R1 validated postrun baseline HEAD:

```text
8a794c389edd10f9750e10a27eca0ec58c14da2d
```

D019 handoff expected repository state:

```text
branch = main
HEAD = 22ea73a7bf3dbfa4f594097d4612b58b5c384682
commit = docs: freeze D019 scientific narrative architecture
worktree = CLEAN
LIVE_GIT_STATUS = NOT_VERIFIED_IN_THIS_MICROSTEP
```

El SHA D019 anterior es estado esperado documentado, no una lectura del HEAD vivo.

## CORRECTED_R1

### Runner
`02_src_limpio/production/run_corrected_r1_cost_e3d_v96z.m`

Git blob:
`075742ff72bc5b7a51e8c54b6122feea7a2fb345`

SHA-256:
`AB481811872CA984F398D83A519C4C7A4584A2F1E401AE7F2F7CA9411EAE5B20`

### Auditoría estática
- `06_manuscript/article_Q1/review/CORRECTED_R1_STATIC_AUDIT_v96z.md`
- `06_manuscript/article_Q1/review/CORRECTED_R1_STATIC_DIFF_v96z.patch`

### Solver/defaults
- `06_manuscript/article_Q1/review/FULL_SOLVER_DEFAULTS_AUDIT_CORRECTED_R1_v96z.md`
- `06_manuscript/article_Q1/review/CURRENT_ENVIRONMENT_COMPATIBILITY_INSPECTION_v96z.md`
- `06_manuscript/article_Q1/review/CURRENT_ENVIRONMENT_COMPATIBILITY_MATLAB_EVIDENCE_v96z.txt`

### Manifest
`06_manuscript/article_Q1/review/EXECUTION_PROVENANCE_MANIFEST_CORRECTED_R1_v96z_POSTRUN_FINAL.md`

### Postrun
- `06_manuscript/article_Q1/review/CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.md`
- `06_manuscript/article_Q1/review/CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z.xlsx`
- `06_manuscript/article_Q1/review/CORRECTED_R1_POSTRUN_INTERNAL_AUDIT_v96z_SHA256.txt`

Workbook SHA-256:
`A9D3ACDC65761AC0EC343A1BFDAF5C784ECD39467A1A79E2D91CEDA7E347C8C3`

SHA registry:
`721FD6BA3E7E9417CFC136A2A6984C7FBDB74DF30309CA280BD1B40AB576B7A0`

### Output no versionado
`05_runs/triobjective_formal_ga_v96m/CORRECTED_R1_COST_E3D_v96z_20260808_005736`

## Histórico R1

Artefacto:
`SEEDAWARE_FORMAL_R1_ONLY_v96z_rngfix_20260727_185454/R1/SEEDAWARE_FORMAL_R1_ONLY_seed_61001_output.mat`

SHA-256:
`A04D1ADCD769CE9D8ED858FA321D7AF6A22E42D1F8A954094084B4B5A2A2ECD0`

## Protocolo comparativo CORRECTED_R1

Artefacto canónico:

```text
06_manuscript/article_Q1/review/CORRECTED_R1_COMPARATIVE_PROTOCOL_v96z.md
```

Versión / estado:

```text
v1.0
FROZEN_APPROVED_FOR_POSTRUN_COMPARATIVE_IMPLEMENTATION
```

SHA-256:

```text
8A8C91DE2B9498A725B544D50E9BA32CD1A159D46E06814F6B9885C01EE062C3
```

Estado de implementación registrado por el handoff D019:

```text
CR1-COMP-01...16 = CLOSED_PASS
COMPARATIVE_PROTOCOL_IMPLEMENTATION = COMPLETED
COMPARATIVE_SCIENTIFIC_REVIEW = CLOSED_PASS
```

## Manuscrito canónico

```text
06_manuscript/article_Q1/draft_sections/MASTER_manuscript_v01.md
```

```text
CANONICAL_MANUSCRIPT_SOURCE_STATUS = UNAMBIGUOUS
MANUSCRIPT_SCIENTIFIC_REVIEW = PASS
SOURCE_CHECK_ITEMS = 0
MANUSCRIPT_FREEZE_CANDIDATE = YES
MANUSCRIPT_FILES_MODIFIED = YES_AUTHORIZED_BLOCKS_A_TO_C
```

## Editorial freeze pre-commit package — Block C

Primary manifest:

```text
path = 06_manuscript/article_Q1/review/MANUSCRIPT_FREEZE_MANIFEST_BLOCK_C_v01.md
role = PRECOMMIT_MANUSCRIPT_FREEZE_MANIFEST
SHA256 = EA55F643BF1A951BA3DC69FB55D6B25F916792F4CA31666CDB6F5567040498D2
status = PASS_LOCAL_NOT_GIT_COMMITTED
```

Figure regeneration audit:

```text
path = 06_manuscript/article_Q1/review/FIGURE_LABEL_REGENERATION_AUDIT_BLOCK_C_v01.json
role = LABEL_ONLY_PIXEL_IDENTITY_AUDIT
REPOSITORY_CANONICAL_SHA256 = C36D0D1319E3A01D2CF6BDCCDE3E05313165EE6A1F539BA5F3A0B788C9385708
BLOCK_C_WORKTREE_PROVENANCE_SHA256 = C9E132EC694FC5E8EEE123094E4F5335AD570C22F268E222F82E42F13608B7AD
LINE_ENDING_NORMALIZATION = CRLF_WORKTREE_TO_LF_GIT_CANONICAL
SCIENTIFIC_CONTENT_CHANGED = NO
status = PASS_GIT_CANONICAL_LF
```

Publish-facing figure SHA-256 values:

```text
CR1_COMP_09_F1_F2_F3_3D_v96z.png = B36636B039D473520F9D06EC3D5E3C7DBB5B09ECC709164881A3E110AFA681CC
CR1_COMP_09_F1_F2_v96z.png = 49B1395B6B19088DC0F0C009245D4DBDBA87DEA21CBC46937CF2AABBF1499599
CR1_COMP_09_F1_F3_v96z.png = 91C7C0D3C02774284FDB0F844A455862EC78FAF6A3CF5067B272F2AB861A9BF6
CR1_COMP_09_F2_F3_v96z.png = 0036B6C884AD4F82D4AF9AE924B6E47E9F6866315CEF3FB1238062BF55AAE2E9
FIGURE_REGENERATION_STATUS = PASS_LABEL_ONLY
```

The complete path/role/upstream/hash/status/classification registry for the manuscript, tables, captions, figures, D020 evidence, and regeneration tooling is contained in the primary manifest. These figures are editorial derivatives, not new scientific computations.

## D016–D020

Estados registrados:

```text
D016 = FROZEN_PASS
D017 = FROZEN_PASS
D018 = FROZEN_PASS
D019 = FROZEN_PASS
D020 = FROZEN_PASS
```

La evidencia suministrada para esta sincronización no incluye las rutas y hashes individuales de los artefactos congelados que materializaron D016–D019 ni el registro exacto CR1-COMP-16. Por trazabilidad, no se inventan nombres, rutas o SHA-256. Deben incorporarse en una futura actualización del índice sólo a partir del repositorio o de artefactos canónicos verificables.

## Literature positioning / novelty freeze

Artefacto primario local:

```text
06_manuscript/article_Q1/review/LITERATURE_POSITIONING_GATE_v01.md
role = DOCUMENTAL_GATE_FREEZE
SHA256 = 3114FDC9A6188C450D499B424D147DB4B6BC3077E424CD8D0BAEA23DA7C3F83F
status = FROZEN_LOCAL_NOT_GIT_COMMITTED
```

Matriz de evidencia derivada:

```text
06_manuscript/article_Q1/review/LITERATURE_POSITIONING_EVIDENCE_MATRIX_v01.csv
role = DERIVED_LITERATURE_EVIDENCE_MATRIX
upstream = LITERATURE_POSITIONING_GATE_v01.md + externally verified literature metadata
SHA256 = E68DB197170910D17A02046830BEC0A1469181DD22AFF3B5829D51774268E5A2
status = FROZEN_LOCAL_NOT_GIT_COMMITTED
```

Estado:

```text
LITERATURE_POSITIONING_GATE = FROZEN_PASS_WITH_NOVELTY_NARROWING
CANDIDATE_KNOWLEDGE_GAP_1 = PARTIALLY_VERIFIED_GAP
CANDIDATE_KNOWLEDGE_GAP_2 = PARTIALLY_VERIFIED_GAP
OVERALL_PAPER_A_POSITIONING = INCREMENTAL_NOVELTY_WITH_STRONG_NARROW_SUBCONTRIBUTION
UNIVERSAL_PRIORITY_ESTABLISHED = NO
CLOSED_PHASE = LITERATURE_POSITIONING_AND_NOVELTY_VERIFICATION
NEXT_PHASE = CONTROLLED_MANUSCRIPT_REWRITING
NEXT_PHASE_AUTHORIZED = NO
```

The repository paths above were resolved from the established manuscript-review
artifact convention during the authorized D020 repository synchronization.

## Productive fingerprints preservados

```text
historical runner = 243554b3df9644a74c54d45472068557204d650c
formal design = 2006fe8da06740c9bcf0bc1b1c7bdd7b85df0268
corrected triobjective = d7fdcb88f94ef8a766af438ad7bb40f28bcda2bc
base objective = 2e3e29cc1d417eedd278ba579bc10b4c2eda4ba0
wrapper v18 = b825a513c95f50ac105d16346650cfe48f7d0096
cost params = 4b1fbfb8554ba59a79ed7908f62b83b38e8947c8
cost breakdown = e1c9a29df585c4f2016b07d5d1f28b71eb917f52
```
