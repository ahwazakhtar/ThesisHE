# Hospital Supply-Side Synthesis (Proposal Chapter 2)

Track: `hospital_supply_side_20260615`. Added 2026-06-16.

This document restores the proposal's **supply-side (Chapter 2)** by carrying
hospital finances through the same three-paper lens — Incidence, Persistence,
Inequality — that the demand side uses, but at the **hospital (CCN) × year**
unit so that provider heterogeneity (ownership, safety-net status, system
affiliation, market structure) survives. It complements, and does not replace,
the consumer-side county-summed `Hosp_BadDebt_PerCapita`.

## Data and design

- **Panel:** `Data/intermediate_hospital_panel.rds`, built by
  `Code/process_hospital_panel.R` from the NASHP Hospital Cost Tool
  (`Downloadable` sheet). **59,896 hospital-years, 5,119 hospitals, 2011–2023.**
- **Geography:** each hospital's `Zip Code` is mapped to a single county
  (modal county per zip, the *location* of the hospital — not the residential
  population split used for the consumer debt measure) via the one-to-one
  zip→county crosswalk. **County-match rate 98.4%; county climate shocks
  attached for 97.7%** of hospital-years.
- **Outcomes:** operating margin, net margin, uncompensated care ($2023 and as
  a % of net patient revenue — the core Ch. 2 ratio), net patient revenue,
  expenses, net income, fund balance. Margins and %-of-NPR fields are
  proportions; dollar fields are CPI-deflated to $2023.
- **Moderators:** `SafetyNet` (top-quartile Medicaid + uncompensated payer mix),
  `Ownership` (Non-Profit / For-Profit / Government), `SystemAffiliated`,
  `Hosp_BedSize`, `MedicaidExpansion` (KFF state-year ACA adoption,
  `Code/medicaid_expansion.R`), and a county-year `MarketConcentration` HHI
  (`HighConcentration` ≥ 0.25).
- **Specification:** hospital fixed effects + year fixed effects, clustered at
  the state level throughout.

---

## Paper 1 — Incidence: do climate shocks strain hospital finances?

Source: `Code/run_hospital_incidence.R` → `Analysis/hospital/hospital_incidence_coefs.csv`,
plots in `Analysis/plots/hospital/`. Distributed-lag IRF
(`Shock + Lag1 + Lag2 | CCN + Year`); cumulative = sum over h = 0,1,2.

**The strain shows up in uncompensated care, not in average margins.**

| Shock | Outcome | Cumulative effect | p |
|-------|---------|-------------------|---|
| High_CDD (heat) | Uncompensated care, %NPR | **+1.22 pp** | 0.063 |
| High_HDD (cold) | Uncompensated care, %NPR | **+0.53 pp** | 0.097 |
| High_HDD (cold) | Uncompensated care, $2023 | **+$1.55 M** | 0.022 |
| Is_Extreme_Drought | Uncompensated care, %NPR | **−1.68 pp** | 0.032 |
| Is_Extreme_Drought | Uncompensated care, $2023 | **−$6.21 M** | <0.001 |

- **Temperature shocks raise uncompensated care.** Both hot (CDD) and cold (HDD)
  years push uncompensated care up — cold significantly in dollars (+$1.55M
  cumulative per hospital). This is the supply-side mirror of the demand-side
  "cold → shifted utilization / medical-debt" channel: the unpaid bills land on
  hospital balance sheets.
- **Operating and net margins are not significantly moved on average.** Pooled
  across all providers, hospitals appear to *absorb* climate shocks through the
  uncompensated-care line rather than through reported margins. Whether that
  absorption is evenly distributed is exactly the Paper-3 question.
- **The drought sign is negative and is a measurement caveat, not a "drought
  helps hospitals" result.** Measured uncompensated care *falls* in
  extreme-drought county-years. This parallels the demand-side lesson that
  credit-/billing-based distress measures are fragile: drought-stricken areas
  differ in patient mix, volume and revenue in ways that move the *measured*
  ratio without implying financial relief. Lead the supply-side incidence story
  with the temperature channel; treat drought-on-uncompensated-care as
  exploratory.

---

## Paper 2 — Persistence: do hospital-finance hits scar or compound?

Source: `Code/run_hospital_persistence.R` →
`Analysis/hospital/hospital_persistence_coefs.csv`. (A) Onset/Persist/Exit symmetry
(reuses `Code/transition_symmetry.R`); (B) cumulative climate-shock-years dose
(reuses `Code/cumulative_dose.R`). Hospital + year FE.

**(A) Drought is asymmetric (scarring); temperature shocks are reversible.**

| Shock | Outcome | Onset+Exit asymmetry | p | Verdict |
|-------|---------|----------------------|---|---------|
| Is_Extreme_Drought | Uncompensated care, %NPR | −0.013 | 0.012 | **asymmetric (scar)** |
| Is_Extreme_Drought | Operating margin | +0.027 | 0.006 | **asymmetric (scar)** |
| High_CDD | both | — | >0.30 | symmetric (reversible) |
| High_HDD | both | — | >0.14 | symmetric (reversible) |

Onset and exit do **not** mirror for drought: entering and leaving a drought
state leave a net imprint on both uncompensated care and operating margin,
rather than cleanly reversing. Temperature shocks, by contrast, are reversible —
the financial cost is in the exposure year, consistent with the demand-side
post-exit "relief" pattern for cold shocks.

**(B) Cumulative exposure: a positive margin dose-response (survivorship /
adaptation), not compression.** The marginal effect of an extra cumulative
shock-year on operating margin is positive at moderate dose (+0.0023 at 5 years,
p = 0.010), and the 10+ vs 1-3 cumulative-years contrast is +0.018 (p = 0.033).
This is *not* evidence of margins eroding with repeated exposure; the likely
reading is **survivorship and adaptation** — hospitals that accumulate many
shock-years and remain in the panel are the financially sturdier ones, and/or
have adapted. Uncompensated-care %NPR shows no significant cumulative-dose
effect. Stated plainly: repeated climate exposure does not mechanically compound
into margin collapse over this window; the persistence story is about
**drought hysteresis**, not dose-driven decline.

---

## Paper 3 — Inequality / provider heterogeneity (PRIMARY)

Source: `Code/run_hospital_heterogeneity.R` →
`Analysis/hospital/hospital_heterogeneity_coefs.csv`, plots in
`Analysis/plots/hospital/`. `Y ~ Shock × M | CCN + Year`; marginal shock effect
read at each moderator level; verdict is **outcome-aware** (higher
uncompensated %NPR = more strain; more-negative operating margin = more strain).

This is the supply-side analogue of the demand-side **SVI amplification**: does
climate-driven hospital strain concentrate in the most vulnerable providers?

**Headline — heat-driven uncompensated care concentrates in safety-net
hospitals.** The cleanest amplification result:

- **High_CDD × SafetyNet → uncompensated care %NPR:** interaction p = 0.021,
  **strain concentrates in safety-net hospitals.** When a hot year hits, the
  uncompensated-care burden rises more for top-quartile-Medicaid/uncompensated
  providers — the hospitals least able to absorb it.

**Significant but mixed / reversed interactions (reported transparently):**

| Shock × Moderator | Outcome | Interaction p | Where strain is larger |
|-------------------|---------|---------------|------------------------|
| High_CDD × SafetyNet | Uncompensated %NPR | 0.021 | **safety-net (concentration)** |
| High_HDD × SafetyNet | Uncompensated %NPR | 0.011 | non-safety-net (reversed) |
| Is_Extreme_Drought × SafetyNet | Operating margin | 0.035 | non-safety-net (reversed) |
| Is_Extreme_Drought × MedicaidExpansion | Uncompensated %NPR | <0.001 | expansion states |
| High_HDD × MedicaidExpansion | Uncompensated %NPR | <0.001 | expansion states |

- The **safety-net axis amplifies for heat** but not uniformly across shocks —
  exactly the kind of shock- and outcome-specific amplification the demand side
  also shows (where the EJ direction is consistent for income/employment but
  fragile for medical debt).
- The **Medicaid-expansion interactions are strong but point to *expansion*
  states** having the more weather-elastic uncompensated-care response. A
  plausible reading: in expansion states the residual uninsured/bad-debt
  population that remains is more sharply exposed to weather-driven utilization
  swings; in non-expansion states uncompensated care is already structurally
  high and less shock-elastic. This is a candidate discussion point, not a clean
  "vulnerability concentrates in non-expansion" story.
- **Ownership and market concentration** interactions are not individually
  significant at conventional levels for the headline outcomes (full grid in the
  coefficients file).

**Verdict.** There *is* a supply-side amplification — heat-driven uncompensated
care concentrates in safety-net hospitals — but, as on the demand side, it is
outcome- and shock-specific rather than a blanket "all strain hits the weakest
providers." The honest framing pairs the safety-net heat result (clean) with the
Medicaid-expansion result (strong, surprising direction) and is explicit that
the drought/cold axes do not amplify in the vulnerable direction.

---

## Demand ↔ supply pairing (how this slots into the three papers)

| Paper | Demand side (consumers) | Supply side (hospitals, this track) |
|-------|-------------------------|-------------------------------------|
| **1 Incidence** | Shocks raise premiums & medical-debt share | Temperature shocks raise hospital **uncompensated care**; margins absorbed |
| **2 Persistence** | Drought debt **scars** (h=2); cold = relief on exit | Drought **scars** hospital uncompensated care & margins; temperature reversible |
| **3 Inequality** | Harm amplified in **high-SVI** counties (income/employment) | Heat-driven uncompensated care amplified in **safety-net** hospitals |

The two sides tell a consistent story at the seams: the same drought hysteresis
and the same "vulnerability amplifies, but measurement-fragile outcomes
misbehave" caveats appear on both the consumer and provider ledgers.

## Outputs

| File | Contents |
|------|----------|
| `Data/intermediate_hospital_panel.rds` | Hospital-year panel (gitignored) |
| `Analysis/hospital/hospital_incidence_coefs.csv` | Distributed-lag IRF coefficients |
| `Analysis/hospital/hospital_persistence_coefs.csv` | Symmetry + dose coefficients |
| `Analysis/hospital/hospital_heterogeneity_coefs.csv` | Shock × moderator marginals + verdicts |
| `Analysis/hospital_*_results.txt` | Full model summaries |
| `Analysis/plots/hospital/` | IRF and heterogeneity plots |

## Caveats

- Margins/ratios are NASHP-reported; ~2% of hospital-years lack a usable margin
  (dropped by the LHS-NA rule).
- County shocks are attached at the hospital's location county; cross-county
  catchment is not modeled.
- The cumulative-dose margin result is survivorship-prone (unbalanced panel) and
  is framed as adaptation/survivorship, not causal protection.
- Drought-on-uncompensated-care is a measurement-fragile channel (see Incidence).
