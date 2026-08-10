# Table 2. Principal quantitative comparison of H and C

| Metric | H | C | Comparative result |
|---|---:|---:|---|
| Internally nondominated | 9/9 | 9/9 | Both sets internally nondominated |
| Cross-set dominance pairs | H dominates C: 2 | C dominates H: 1 | Sparse and bidirectional |
| Incomparable cross-set pairs | — | — | 78/81 (96.296%) |
| Exact equal objective vectors | — | — | 0/81 |
| Directional coverage | H over C: 2/9 (22.222%) | C over H: 1/9 (11.111%) | Greater reciprocal H-over-C coverage; neither direction indicates broad replacement |
| Joint Rank 1 contribution | 8 | 7 | 15/18 solutions in joint Rank 1 |
| Median `f1` | 0.0436403 | 0.0288868 | C−H = −33.807% |
| Median `f2` (USD/kg water removed) | 0.210596 | 0.217334 | C−H = +3.200% |
| Median `f3` (kg CO2e/kg water removed) | 0.495166 | 0.514273 | C−H = +3.859% |
| Observed marginal extrema | Retains all low and high extrema | Adds none | C intervals nested within H intervals |
| Anchored HV, `r5` | 0.8214144073536221 | 0.8596538595095115 | C > H |
| Anchored HV, `r10` (primary) | 0.9749820881940048 | 1.0099628901072748 | C > H |
| Anchored HV, `r20` | 1.3323674498747686 | 1.3592107397484303 | C > H |
| Terminal regime | 9/9 TMAX | 9/9 TMAX | Common nominal fixed horizon, 19.9 h |

H comprises historical R1 solutions reevaluated under corrected COST-E3D. C comprises solutions generated directly under corrected COST-E3D. All comparisons concern these finite evaluated sets. Anchored hypervolume is a secondary normalized coverage metric under the three prespecified reference points; it does not establish convergence or global optimality.
