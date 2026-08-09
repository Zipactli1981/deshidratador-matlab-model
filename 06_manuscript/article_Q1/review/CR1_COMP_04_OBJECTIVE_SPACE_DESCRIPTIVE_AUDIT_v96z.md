# CR1-COMP-04 — Objective-space Descriptive Analysis Audit

## Purpose and status

CR1-COMP-04 characterizes only the finite objective-space solution sets H and C. The result is `CLOSED_PASS` and is classified as `DESCRIPTIVE_SUMMARIES_OF_FINITE_SOLUTION_SETS`.

## Baseline and canonical input

- Baseline HEAD: `354a9d40dc9803761e26910d306d14574dfa4f98` (`INPUT_BASELINE_CHECK = PASS`).
- Input: `06_manuscript/article_Q1/review/CR1_COMP_01_CANONICAL_DATASET_v96z.json`.
- SHA-256: `4DE32D3292001FC87E7435995E3D9ACC31D51800BA05E2A88BA3B379A95D0164` (`INPUT_HASH_CHECK = PASS`).
- Rows: H = 9; C = 9; objectives = 3; all objective values finite; penalty rows = 0.
- H uses source `HIST_R1_REEVAL`; C uses source `CORRECTED_R1`.

The D1 limitation remains in force for H.f2/f3: their corrected binary64 originals were not persisted, so the canonical dataset retains the approved validated 17-digit decimal documentary recovery. H is a historical reevaluated set, not a corrected Pareto front.

## Frozen D013 conventions

- `STD_CONVENTION = POPULATION_DDOF_0`: `sqrt(sum((x_i - mean(x))^2)/n)`.
- `IQR_CONVENTION = HYNDMAN_FAN_TYPE_7`: `h=1+(n-1)p`, linear interpolation; `IQR=Q3-Q1`.
- Median shift: `median_C - median_H`.
- Percent median shift: `100 * (median_C - median_H) / median_H`; negative means C has a lower median and positive means C has a higher median.
- All three objectives are minimized. No objective normalization was applied.

## Results

| Objective | Median H | Median C | Delta C-H | Delta % |
|---|---:|---:|---:|---:|
| MR_final | 0.043640293266345158 | 0.028886799370315748 | -0.01475349389602941 | -33.807045718015644 |
| cost_specific_USD_per_kgwater | 0.21059554013040163 | 0.21733365919792744 | 0.0067381190675258051 | 3.1995544935821214 |
| CO2_specific_kgCO2_per_kgwater | 0.49516643659138637 | 0.51427275149523777 | 0.019106314903851396 | 3.8585642103238946 |

These signs describe numerical median shifts only; they are not a multiobjective improvement claim.

## Observed extrema

| Source | Objective | Minimum solution ID(s) | Minimum |
|---|---|---|---:|
| HIST_R1_REEVAL | MR_final | H09 | 0.014734459102957981 |
| HIST_R1_REEVAL | cost_specific_USD_per_kgwater | H01 | 0.18030701050054604 |
| HIST_R1_REEVAL | CO2_specific_kgCO2_per_kgwater | H01 | 0.40430974196007208 |
| CORRECTED_R1 | MR_final | C01 | 0.015163555853391462 |
| CORRECTED_R1 | cost_specific_USD_per_kgwater | C02 | 0.18471976529485853 |
| CORRECTED_R1 | CO2_specific_kgCO2_per_kgwater | C03 | 0.42177467537964236 |

The extrema are descriptive and do not select a best or representative solution.

## Descriptive observations

- For `MR_final`, C has a lower observed median than H and lower descriptive population standard deviation.
- For `cost_specific_USD_per_kgwater`, C has a higher observed median than H and lower descriptive population standard deviation.
- For `CO2_specific_kgCO2_per_kgwater`, C has a higher observed median than H and lower descriptive population standard deviation.

These statements concern only the two finite nine-point sets. No statistical significance, robustness, convergence, stochastic performance, causality, total batch cost, total energy, or total batch CO2 conclusion is supported here.

## Independent QC

An independent sorted-list implementation reproduced min, max, median, range, median delta, and percent median delta exactly in the numeric representation used. The identities `range=max-min` and `IQR=Q3-Q1` passed, as did percent/delta sign agreement for positive H medians.

`INDEPENDENT_QC = PASS`

## Actions not executed

No MATLAB, objective/model evaluation, replay, gamultiobj, optimization, statistical test, cross-dominance, near-tie analysis, numeric-fragility analysis, coverage, joint sorting, hypervolume, figure, representative-solution selection, physical interpretation, or later CR1-COMP phase was executed. `CR1_COMP_05_COMPUTED = NO`.

## Output hashes

- `cr1_comp_04_objective_space_descriptive_v96z.py`: `3B0BBA29CE6A3E74D42F08933BF3C6EA60BA94D69C4E182D7649EDA831C22214`
- `CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_v96z.csv`: `7137EFA8D7A391E4B9615E1CA92717B57D15ADF3792E1AE3C59A85AB908741B5`
- `CR1_COMP_04_OBJECTIVE_SPACE_COMPARISON_v96z.csv`: `E0CCDEA0FF89B99701B0F15DD8B66193EC5654ED2FE1D11DEC68C99A32B7E21B`
- `CR1_COMP_04_OBJECTIVE_SPACE_DESCRIPTIVE_v96z.json`: `CCA35B4E8983D075E9D3E4834949B2A2F330C5A8C0C5B4D1EA05E935AEE1D75D`

The audit's own SHA-256 is registered externally in `00_project_context/04_ARTIFACT_INDEX.md` to avoid a self-referential hash.
