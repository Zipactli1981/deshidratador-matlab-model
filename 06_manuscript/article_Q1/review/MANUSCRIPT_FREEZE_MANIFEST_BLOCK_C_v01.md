# Manuscript freeze manifest — Block C pre-commit candidate

`EDITORIAL_FREEZE_PRECOMMIT_BLOCK_C = PASS`

`MANUSCRIPT_FREEZE_CANDIDATE = YES`

`NEXT_GATE = VERSION_CONTROL_FREEZE`

This manifest identifies the complete publish-facing manuscript package before any Git staging or commit. The regenerated figures are editorial derivatives of frozen CR1-COMP-09 raster evidence; they are not new scientific computations.

| Repository-relative path | Artifact role | Upstream source | SHA-256 | Validation status | Classification |
|---|---|---|---|---|---|
| `06_manuscript/article_Q1/draft_sections/MASTER_manuscript_v01.md` | Canonical publish-facing manuscript | D016–D020 frozen evidence; Blocks A–C editorial review | `695056D85F9858C42873AE40707C8EF97669D6417D80CA2C6BF8F473CED241EF` | `PASS_FREEZE_CANDIDATE` | PRIMARY |
| `06_manuscript/article_Q1/tables/TABLE_01_COST_E3D_OBJECTIVES_AND_SCOPE_v01.md` | Main Table 1, objective definitions and boundaries | COST-E3D; D017 | `AB99A3716A4272C8B82FE7B38A2CD3449C3E4509C5E37A2B773896ED7307D210` | `PASS_ALIGNED` | DERIVED |
| `06_manuscript/article_Q1/tables/TABLE_02_H_VS_C_COMPARATIVE_SUMMARY_v01.md` | Main Table 2, H-vs-C results | CR1-COMP-01…16 frozen results | `487B72D1056CB2C1094EDDDA74B8934C06A4A876E0DF32C9FD74043F23CE7C4F` | `PASS_NUMERICALLY_VERIFIED` | DERIVED |
| `06_manuscript/article_Q1/tables/SUPP_TABLE_H_VS_C_DESCRIPTIVE_SUMMARY_v01.md` | Supplementary Table S1 | CR1-COMP descriptive summaries | `01826C1C843DFDC8B1C0F48E456C355F9B683CED3DABEDEFAE6DAD48B9974A29` | `PASS_NUMERICALLY_VERIFIED` | DERIVED |
| `06_manuscript/article_Q1/review/FIGURE_CAPTIONS_H_VS_C_v01.md` | Active manuscript and supplementary figure captions | D016–D020; regenerated figures | `434EE881957B3E1F54DD7E7A7A36A666AFD507E98319E15BF88B46007234CE20` | `PASS_PUBLISH_FACING` | DOCUMENTARY |
| `06_manuscript/article_Q1/review/CR1_COMP_09_F1_F2_F3_3D_v96z.png` | Main Figure 1 | Frozen CR1-COMP-09 PNG; label-margin replacement only | `B36636B039D473520F9D06EC3D5E3C7DBB5B09ECC709164881A3E110AFA681CC` | `PASS_LABEL_ONLY_PIXEL_IDENTITY` | DERIVED |
| `06_manuscript/article_Q1/review/CR1_COMP_09_F1_F2_v96z.png` | Supplementary Figure S1 | Frozen CR1-COMP-09 PNG; label-margin replacement only | `49B1395B6B19088DC0F0C009245D4DBDBA87DEA21CBC46937CF2AABBF1499599` | `PASS_LABEL_ONLY_PIXEL_IDENTITY` | DERIVED |
| `06_manuscript/article_Q1/review/CR1_COMP_09_F1_F3_v96z.png` | Supplementary Figure S2 | Frozen CR1-COMP-09 PNG; label-margin replacement only | `91C7C0D3C02774284FDB0F844A455862EC78FAF6A3CF5067B272F2AB861A9BF6` | `PASS_LABEL_ONLY_PIXEL_IDENTITY` | DERIVED |
| `06_manuscript/article_Q1/review/CR1_COMP_09_F2_F3_v96z.png` | Supplementary Figure S3 | Frozen CR1-COMP-09 PNG; label-margin replacement only | `0036B6C884AD4F82D4AF9AE924B6E47E9F6866315CEF3FB1238062BF55AAE2E9` | `PASS_LABEL_ONLY_PIXEL_IDENTITY` | DERIVED |
| `06_manuscript/article_Q1/review/LITERATURE_POSITIONING_GATE_v01.md` | D020 literature-positioning gate | Verified literature corpus | `3114FDC9A6188C450D499B424D147DB4B6BC3077E424CD8D0BAEA23DA7C3F83F` | `FROZEN_PASS_WITH_NOVELTY_NARROWING` | DOCUMENTARY |
| `06_manuscript/article_Q1/review/LITERATURE_POSITIONING_EVIDENCE_MATRIX_v01.csv` | D020 literature evidence matrix | D020 gate and verified metadata | `E68DB197170910D17A02046830BEC0A1469181DD22AFF3B5829D51774268E5A2` | `PASS_VERIFIED` | DERIVED |
| `06_manuscript/article_Q1/review/FIGURE_LABEL_REGENERATION_AUDIT_BLOCK_C_v01.json` | Pixel-identity and figure-regeneration audit | Frozen and regenerated CR1-COMP-09 PNG pairs | `C36D0D1319E3A01D2CF6BDCCDE3E05313165EE6A1F539BA5F3A0B788C9385708` | `PASS_GIT_CANONICAL_LF` | DOCUMENTARY |
| `06_manuscript/article_Q1/review/regenerate_cr1_comp_09_labels_only_block_c.py` | Reproducible editorial relabeling utility | Frozen CR1-COMP-09 PNGs | `B37ABE596EF2512A3BD9C777AAA4E6715F9033CEDB5680AA505FE177029EDE0A` | `PASS_NO_OBJECTIVE_DATA_READ` | DOCUMENTARY |

For `FIGURE_LABEL_REGENERATION_AUDIT_BLOCK_C_v01.json`:

```text
REPOSITORY_CANONICAL_SHA256 = C36D0D1319E3A01D2CF6BDCCDE3E05313165EE6A1F539BA5F3A0B788C9385708
BLOCK_C_WORKTREE_PROVENANCE_SHA256 = C9E132EC694FC5E8EEE123094E4F5335AD570C22F268E222F82E42F13608B7AD
LINE_ENDING_NORMALIZATION = CRLF_WORKTREE_TO_LF_GIT_CANONICAL
SCIENTIFIC_CONTENT_CHANGED = NO
```

The manifest does not include its own SHA-256 because self-registration would be recursive. Its final hash is registered in `00_project_context/04_ARTIFACT_INDEX.md`.
