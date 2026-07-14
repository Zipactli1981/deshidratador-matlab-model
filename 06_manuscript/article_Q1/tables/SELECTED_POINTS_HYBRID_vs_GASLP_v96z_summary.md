# Selected points — Hybrid vs gas-LPG comparison

Micropaso: `9.6z-sim-lite-a`

Identifier: `SELECTED-POINTS-HYBRID-vs-GASLP-COMPARISON-001`

Wrapper: `opt_tunel_mod2_v19_eta_sensitivity`

Eta mode: `eta_article_2SAH_curve`

No GA was executed. No optimization was executed. Only fixed selected points were evaluated.

| Case | Q_aux hybrid (kWh) | Q_aux gas-LPG (kWh) | Reduction (kWh) | Reduction (|---|---:|---:|---:|---:|---:|---:|---|
| `H2_historical` | 747.00 | 1292.56 | 545.56 | 42.21 | 0.04448 | 0.04448 | Historical deeper-drying reference |
| `R1_solution_7` | 656.23 | 1194.11 | 537.89 | 45.04 | 0.07057 | 0.07199 | Energy-saving feasible candidate |
| `R1_solution_3` | 723.36 | 1270.58 | 547.22 | 43.07 | 0.05493 | 0.05486 | Balanced feasible candidate |
| `R1_solution_9` | 1218.41 | 1773.87 | 555.46 | 31.31 | 0.01388 | 0.01388 | Aggressive drying boundary case |

## Interpretation note

This table compares the selected operating points under hybrid operation and gas-LPG-only operation. The comparison is pointwise and does not imply a new optimization run. The result should be used as a baseline energy comparison for the selected candidates.
