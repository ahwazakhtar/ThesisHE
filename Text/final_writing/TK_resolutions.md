# TK Resolutions — best-guess fills with sources

**Date:** 2026-08-13. Each `[TK]` in the harnesses/content pack was resolved from the repo
(code, certified outputs) or a web-verified citation. **Confidence** flags: ✅ verified
(traced to a repo file or fetched source), 🟡 high-confidence memory (standard literature,
verify at BibTeX assembly), 🔶 author review requested. Resolutions are applied in the
harness suggested text; unedited paragraphs pick them up automatically (your localStorage
edits are untouched — re-apply manually where you had already rewritten a paragraph).

## A. Repo facts

| # | Item | Resolution | Source | Conf. |
|---|---|---|---|---|
| A1 | Dollar base year | **2023 dollars** (county master hardcodes "Adjusting Inflation (Base 2023)"; descriptive labels "(2023 USD)") | `Code/create_county_master.R:173-175`; `Analysis/descriptive/descriptive_stats_summary.csv` | ✅ (see caution below) |
| A2 | Shock definitions | z-shocks: temperature z beyond **±1.5** vs the **1990–2000 baseline**; **High_CDD/High_HDD**: degree-day totals above the **80th percentile of the 1990–2000 baseline distribution** (fixed national threshold, per the state script comment "matching the county-level pipeline design"); **extreme drought: PDSI ≤ −4**; wet bin Z_Precip > +1.5 | `Code/create_state_master.R:55-83` (state mirror of the design); descriptive-table variable labels ("1990-2000 baseline", "PDSI <= -4") | ✅ |
| A3 | Shock incidence (Essay 2 §4 support ¶) | Extreme drought **2.3%** of county-years (episodic); extreme heat **24.3%**; extreme cold **17.4%**; transition regressions N ≈ 27,000–34,000 | `descriptive_stats_summary.csv` (High_CDD/High_HDD/Is_Extreme_Drought means); `Analysis/delta/delta_transition_summary.csv` (N column) | ✅ |
| A4 | Mean medical-debt share anchor | Mean **0.188** (≈19% of adults with medical debt in collections) → cold +1.35 pp ≈ **7% relative**; drought scar +0.019 ≈ **10% of the level** | `descriptive_stats_summary.csv` (Medical_Debt_Share mean 0.1884) | ✅ |
| A5 | Premium units (Essay 3 drought×SVI) | `Benchmark_Silver_Real` is a **monthly** premium in 2023 dollars, county-master mean **$374/mo** (the $366/mo elsewhere is the RA-panel mean — different panel, both fine if labeled). Post-dedup marginal effects: low-SVI **−$55.1 (p=0.030)**, high-SVI **+$14.1 (p=0.319)** — the high end is imprecise; the claim is the interaction gradient (p=0.0012) | `descriptive_stats_summary.csv` (mean 373.80); `Analysis/exposure_index/exposure_interaction_coefs.csv` (Drought_Lag2 row) | ✅ |
| A6 | 2012 event-time profile description (E1 §5 ¶4) | Income gap opens at onset: e=0 **−$1,561** (p=0.008), e=1 **−$1,609** (p<0.001), attenuating e=2 **−$698** (p=0.034), e=3 −$306 (ns); employment gap **builds**: −114 → −139 → −554 → −1,097. (2×2 ATT −$1,311 averages all 11 post-years.) The frontier event-time file (`dr_csdid_eventtime.csv`, E1-F3) is the **pooled** profile (e=0 −$324 null) and belongs to §7, not §5. | `Analysis/did/did_pretrends_event_study.csv` (Drought_2012 PCPI_Real/Civilian_Employed rows); `dr_csdid_eventtime.csv` | ✅ |
| A7 | Treated-cohort population anchors (E1 §5 ¶5) | 2012 treated cohort (replicated exactly: 139 counties): median 2012 population **12,817**; total **5.29M** residents → −$1,311/head ≈ **$16.8M/yr** median county, ≈ **$6.9B/yr** cohort-wide (illustrative; formal aggregation in the policy chapter) | Scratchpad replication of `run_did_analysis.R` cohort build (2011–2023 window, first-onset-2012 vs never-exposed; treated_n=139 ✓) on the certified master | ✅ |

## B. Anchor corrections (🔶 author review)

The earlier suggested text anchored to task-1.5 candidates (**PCPI $46,269; employment
50,113**). The registry exhibit **E1-T1** (post-dedup, re-run 2026-07-13) gives **PCPI_Real
mean $53,145** and **Civilian_Employed mean 48,068** (unweighted county-year means,
2011–2023, N≈40.9k). I switched all anchors to the E1-T1 values since that is the
manuscript's own Table 1:

- −$1,311 → **≈2.5%** of mean PCPI (was ≈2.8%)
- −2,053 jobs → **≈4%** of mean employment (unchanged rounding)
- −5,522 binned contrast → **≈11%** of mean employment (unchanged rounding)
- heat×energy-burden −1,380 → **≈2.9%**; SVI heat swing (+878→−184) → **≈2%**
- cold×SVI income −$56 → −$472 → **≈0.1% vs 0.9%** of mean PCPI (was 1.0%)

🔶 The task-1.5 note says the author confirms intended denominators; if you prefer the
1.5 candidates (or weighted means), say so and I'll swap them back everywhere. Medicare
anchors are unchanged (**$10,359/beneficiary; 629 ED visits/1,000** — beneficiary-weighted
2014–2023 full-sample baselines from task 1.5, matching the Medicare window).

**Base-year caution (A1):** the **state** master targets the latest CPI year in
`us_cpi_annual.csv` ("Target Year: Latest Available"), and that file now runs to **2025**
(last modified 2026-02-08). The county master is hardcoded Base 2023. No essay headline
cites a state-panel dollar level (the ESI figure is recommended dropped), but if one is
added, verify its base year first.

## C. Citations — web-verified ✅

| Cite | Full reference | Source |
|---|---|---|
| Audi et al. 2025 (the missing "Audi et al. 2024–25" ref) | Audi, G., Hamadi, H., Capen, M., Tawk, R., & Williams, W. (2025). Natural disasters in the United States: Hurricane risk, hospital closures, and healthcare finance. *Journal of Hospital Administration*, 14(2), 16–23. doi:10.63564/jha.v14n2p16 | [jhaweb.org](https://jhaweb.org/journal/jha/archives/doi/10.63564/jha.v14n2p16/) — 2021 CMS cost reports × 2023 FEMA National Risk Index, 1,030 southeastern hospitals, cost-to-charge ratios |
| Doremus et al. 2022 (the missing energy-burden ref) | Doremus, J. M., Jacqz, I., & Johnston, S. (2022). Sweating the energy bill: Extreme weather, poor households, and the energy spending gap. *Journal of Environmental Economics and Management*, 112, 102609. | [ideas.repec.org](https://ideas.repec.org/a/eee/jeeman/v112y2022ics0095069622000018.html) / [sciencedirect.com](https://www.sciencedirect.com/science/article/abs/pii/S0095069622000018) |
| Hoerling et al. 2014 | Hoerling, M., et al. (2014). Causes and predictability of the 2012 Great Plains drought. *Bulletin of the American Meteorological Society*, 95(2), 269–282. doi:10.1175/BAMS-D-13-00055.1 | [journals.ametsoc.org](https://journals.ametsoc.org/view/journals/bams/95/2/bams-d-13-00055.1.xml) — bonus fact used in §2/§4: the drought "developed suddenly in May" and "arrived without early warning" — direct support for the sharp/unanticipated design claim |

## D. Citations — standard literature, from model knowledge 🟡 (verify at BibTeX assembly)

| Cite (as used) | Reference | Used in |
|---|---|---|
| Deschênes & Greenstone 2007 | *AER* 97(1): The economic impacts of climate change: evidence from agricultural output and random fluctuations in weather | E1 intro, §5 |
| Deryugina et al. 2019 | Deryugina, Heutel, Miller, Molitor, Reif, *AER* 109(12): The mortality and medical costs of air pollution | E1 §8 (the in-panel replication target) |
| Dell, Jones & Olken 2014 | *JEL* 52(3): What do we learn from the weather? | E1/E2 intros |
| Hsiang 2016 | *Annual Review of Resource Economics* 8: Climate econometrics | E1 intro |
| Hsiang & Jina 2014 | NBER WP 20352: The causal effect of environmental catastrophe on long-run economic growth | E2 intro |
| Deryugina, Kawano & Levitt 2018 | *AEJ: Applied* 10(2): The economic impact of Hurricane Katrina on its victims | E2 intro (persistence of local shocks) |
| Deryugina 2017 | *AEJ: Policy* 9(3): The fiscal cost of hurricanes | E1 §5 magnitude comparison |
| Barreca et al. 2016 | Barreca, Clay, Deschenes, Greenstone, Shapiro, *JPE* 124(1): Adapting to climate change | E1 contributions ¶ |
| Callaway & Sant'Anna 2021 | *Journal of Econometrics* 225(2): Difference-in-differences with multiple time periods | E1 §7, E2 §7 |
| Sant'Anna & Zhao 2020 | *Journal of Econometrics* 219(1): Doubly robust difference-in-differences estimators | E1 §5 (DRDID) — add when citing the estimator formally |
| Abadie, Athey, Imbens & Wooldridge 2023 | *QJE* 138(1): When should you adjust standard errors for clustering? | E1 §3 (already named in text) |
| Dobkin et al. 2018 | Dobkin, Finkelstein, Kluender, Notowidigdo, *AER* 108(2): The economic consequences of hospital admissions | E1 intro (medical-debt lit) |
| Kluender et al. 2021 | Kluender, Mahoney, Wong, Yin, *JAMA* 326(3): Medical debt in the US, 2009–2020 | E1 intro (bureau-debt measurement) |
| Banzhaf, Ma & Timmins 2019 | *JEP* 33(1): Environmental justice: the economics of race, place, and pollution | E3 intro |
| de Chaisemartin & D'Haultfœuille 2024 | Difference-in-differences estimators of intertemporal treatment effects, *REStat* (volume/pages **verify** — venue less certain than the others) | E1 §8 (`did_multiplegt_dyn`) |

## E. Remaining TKs

1. **[BUILD] exhibits — 4 of 5 BUILT 2026-08-13** by `Code/create_manuscript_exhibits.R`
   (tests: `Code/tests/test_manuscript_exhibits.R`, all pass; registry rows updated):
   E1-F1 map ✅, E2-F1 concept diagram ✅, E2-F4 dose-contrast panel ✅, E3-T6/F6
   concentration table+figure ✅. **Still pending: E1-F5** institutional-ledger figure
   (needs cross-ledger standardization design choices; debt coefficients live in narrative
   docs, not machine-readable CSVs — build during Essay-1 §9 drafting).
2. **[DECIDE] — RESOLVED by the author 2026-08-13**: ESI **dropped** from Essay 1 entirely;
   drought→debt leads with the **county +0.54 pp**; anchors confirmed as the **E1-T1 values**.
   Still open: MAD employment construction (advisor to confirm; table reports both either way).
3. Transition **episode counts** — ✅ DONE: `Analysis/delta/transition_episode_counts.csv`
   (drought 511 onsets / 705 exits / 175 persisting, 603 counties; heat 903/1,033/8,125;
   cold 1,032/1,181/5,485).

## F. Exhibit-build findings (2026-08-13) — read before drafting the affected paragraphs

1. **Heat "saturation" exhibit re-specified.** The county chronic-heat debt-gap dynamic
   series (`persistent_exposure_dynamic.csv`, High_CDD × Medical_Debt_Share) is **negative
   and significantly widening** (WLS slope −0.0033/yr, p<0.001) — the region-confounded CDD
   pattern `did_results.md` §3 demotes to suggestive. It must NOT be used as saturation
   evidence. E2-F4 instead shows the **HDD-vs-CDD cumulative-dose contrast** (certified
   `cumulative_dose_marginal.csv`): cold binned −5,522 (p=3.9e-6) vs heat **+4,460 (p=0.06)**
   — no negative dose gradient for heat. Row 18's "fixed level difference" language rests on
   the state synthesis and remains permitted; the county dynamic series is a known tension
   to keep out of the saturation paragraph.
2. **Correction to an earlier session claim:** the "heat binned contrast −928 (p=0.16)"
   quoted mid-build was the **PCPI_Real** row, not employment; the employment figure is
   +4,460 (p=0.06). The committed figure computes its caption from the data.
3. **Concentration bands:** `drought_debt_scar` and `event_2012_income` allocate uniform
   per-capita coefficients → Lorenz curves diagonal **by construction** (flagged in
   `concentration_topshares.csv`, omitted from the figure). Informative bands: cold
   employment top-10% = **19%** (top-20% = 36%), heat person-years 15%, cold/heat Medicare
   14%/11%.
4. **Environment:** `usmap` + `sf` (with `wk`, `classInt`, `s2`, `units`, `usmapdata`)
   installed to the R 4.5.2 user library 2026-08-13 for the county map.
