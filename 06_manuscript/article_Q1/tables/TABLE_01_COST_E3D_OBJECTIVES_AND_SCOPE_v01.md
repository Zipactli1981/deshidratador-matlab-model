# Table 1. Corrected COST-E3D objectives and interpretation boundaries

| Objective | Computational definition | Manuscript name | Unit | Direction | Constitutive boundary |
|---|---|---|---|---|---|
| `f1` | `MR_final` | Final moisture ratio | dimensionless | Minimize | Terminal modeled moisture ratio. |
| `f2` | `total_cost_USD / water_removed_kg` | Modeled specific operating-energy cost | USD/kg water removed | Minimize | Includes modeled operating-energy components; excludes capital, maintenance, labor, fixed charges, total ownership cost, and comprehensive commercial process cost. |
| `f3` | `CO2_specific_kgCO2_per_kgwater` | Modeled specific operational greenhouse-gas emissions | kg CO2e/kg water removed | Minimize | Direct LPG-combustion CO2 plus indirect grid-electricity CO2e; excludes life-cycle, infrastructure, manufacturing, transport, maintenance, and total environmental impact. |

The common functional denominator is the water actually removed:

$$
\mathrm{water\_removed\_kg}=(M_i-M_{\mathrm{terminal}})m_d.
$$

Source basis: frozen COST-E3D formulation and D017 CO2/CO2e reconciliation.
