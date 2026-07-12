# Hospital Financial Levels — Winsorization / Filtering Verification

**Track:** `audit_response_20260712`, task 2.4 (absorbed from `policy_microsim` Phase 0; audit §8).
**Date:** 2026-07-12. **Environment:** R 4.2.2 (`fixest`), panel `Data/intermediate_hospital_panel.rds`
(59,896 hospital-years, 2011–2023) present locally; re-runs performed on it directly.

Verdict in one line: **winsorization was ABSENT from all three NASHP CCN-panel analysis
scripts; it is now available as an opt-in robustness pass (`HOSP_WINSORIZE=1`) writing
`*_winsorized` outputs alongside the raw ones. The primary heat × safety-net headline
SURVIVES winsorization; the cumulative-dose margin "survivorship" result does NOT.**

---

## 1. The factual verdict — where winsorization exists and where it was absent

There are **two distinct `Hosp_*` families** and they must not be conflated:

| Family | Built in | Level variables | Winsorized before regression? |
|---|---|---|---|
| **CCN (hospital) × year panel** | `Code/process_hospital_panel.R` | `Hosp_UncompCare_Real`, `Hosp_Charity_Real`, `Hosp_BadDebt_Real`, `Hosp_UncompCare_PctNPR`, `Hosp_OperatingMargin`, `Hosp_NetMargin`, `Hosp_NetPatientRevenue_Real`, … | **NO (was absent — now opt-in, see §4)** |
| **County-summed totals** | `Code/process_zip_county_map.R` → `Code/create_county_master.R` | `Hosp_BadDebt_Total_Real`, `Hosp_Charity_Total_Real`, `Hosp_Revenue_Total`; derived `Hosp_BadDebt_PerCapita` | **Partially** (only in one mechanism script; see below) |

**The earlier review's premise — "no winsorize call in `Code/`" — is technically wrong but
right where it counts.** A grep for `winsor` misses the helper, which is named `winz`.
Winsorization *does* exist in two places, neither of which protects the hospital-panel
headlines:

- **`Code/run_descriptive_stats.R:61-68,177`** — `winsorized_mean()` (P1/P99) is computed
  **for the descriptive summary moment `Winsor_Mean_P1_P99` only** (reporting). It is never
  fed back into any regression.
- **`Code/run_mechanism_rma_buffer.R:35,50,53`** — `winz()` (P1/P99) **is** applied to a
  regression input: `Uncomp_Real = winz(bad_debt + charity)` and `Uncomp_PctRev`. Its header
  (`:19`) even names "one negative charity outlier". But this is the **county-summed**
  uncompensated-care measure in the `mechanism_channels` track — **not** the CCN-panel
  outcomes that produce the Chapter-2 hospital headlines.

**Where winsorization was ABSENT (raw levels/ratios entered the regression unmodified):**

- `Code/process_hospital_panel.R` — builds every CCN-panel level with no clipping. The only
  row filtering is dropping rows with a missing CCN/Year key (`:129`); the duplicate-CCN
  collapse (`:135-160`) **sums** dollar flows, which can only *amplify* an outlier. `feols`
  silently drops NA LHS; nothing bounds finite outliers.
- `Code/run_hospital_incidence.R` — `OUTCOMES` (`:32-33`) includes the dollar level
  `Hosp_UncompCare_Real`; no winsorization before `feols`.
- `Code/run_hospital_persistence.R` — `OUTCOMES` (`:31`) = `{Hosp_UncompCare_PctNPR,
  Hosp_OperatingMargin}`; cumulative-dose and symmetry regressions on raw ratios.
- `Code/run_hospital_heterogeneity.R` — `OUTCOMES` (`:38`) = same two ratios; the PRIMARY
  Shock × moderator regressions ran on raw ratios.
- (`Code/run_mechanism_provider.R:57`, a different track, also consumes raw
  `Hosp_UncompCare_Real`/ratios — **out of scope here**, flagged in §6.)

---

## 2. Where the −$408M value lives, and how far it travels

The "−$408M charity-care reversal" is real and confirmed in the data (R 4.2.2 inspection):

- **Source (CCN panel):** hospital **CCN 050060 (CA), 2012** reports **Net Charity Care Cost
  = −$461.6M** (an accounting reversal/restatement). `derive_uncomp()`
  (`process_hospital_panel.R:66-71,163`) makes `Hosp_UncompCare_Real = bad_debt + charity`,
  so this becomes `Hosp_UncompCare_Real = −$461.2M` for that hospital-year.
- **County master:** after the zip→county residential allocation
  (`process_zip_county_map.R:100-102`) and CPI deflation
  (`create_county_master.R:103-104`), the same event appears as
  **`Hosp_Charity_Total_Real = −$408.7M` at fips 6019 (Fresno County, CA), 2012** — the exact
  figure flagged in descriptive reports.
- **Not a lone freak.** `Hosp_Charity_Total_Real` has **3,146 negative county-years**
  (of 31,834 finite); `Hosp_UncompCare_Real` (CCN) spans **−$461M to +$1.37 billion**
  (p1/p99 = −$4.9M / +$97M). The proportion outcomes are just as pathological:
  `Hosp_OperatingMargin` reaches **−496%**, `Hosp_UncompCare_PctNPR` reaches **+697%**.

**Which regressions the outlier actually reaches (raw, unwinsorized):**

| Consumer | Variable | −$408M / charity reversal reaches it? |
|---|---|---|
| `run_hospital_incidence.R` (`:32`) | `Hosp_UncompCare_Real` (LHS) | **YES** — dollar level, directly |
| `run_mechanism_provider.R` (`:57`, other track) | `Hosp_UncompCare_Real` (LHS) | **YES** — dollar level, directly |
| `run_hospital_persistence.R`, `run_hospital_heterogeneity.R` | `Hosp_UncompCare_PctNPR`, `Hosp_OperatingMargin` | **Indirectly** — the *dollar* reversal is not in these `% of NPR` columns (those come from separate NASHP `…as % of NPR` source fields, `process_hospital_panel.R:115-116,164`), but these ratios carry their **own** severe outliers (−496% / +697%) |
| `run_mechanism_rma_buffer.R` (`:48-53`) | `Hosp_Charity_Total_Real` (county) | **YES but winsorized** (`winz`) — protected |
| ~14 county scripts | `Hosp_BadDebt_PerCapita` = `Hosp_BadDebt_Total_Real / Population` | **NO** — bad-debt only; charity (and the −$408M) never enters. `Hosp_BadDebt_Real` min ≈ −$0.17M, effectively non-negative |

So the −$408M dollar reversal enters an **unwinsorized levels regression only through
`Hosp_UncompCare_Real` in `run_hospital_incidence.R`** (and the out-of-scope
`run_mechanism_provider.R`). The two *named* published headlines
(heat × safety-net; cumulative dose) run on **ratios** — exposed to outliers generally, but
not to this specific dollar figure. The demand-side `Hosp_BadDebt_PerCapita` results are
**not** exposed to the charity reversal at all.

---

## 3. Exposed published results

- **Heat × safety-net uncompensated care** (PRIMARY, `Analysis/hospital/synthesis.md` Paper 3):
  `run_hospital_heterogeneity.R`, outcome `Hosp_UncompCare_PctNPR`. Ran on raw ratios with
  −496%/+697% tails ⇒ **exposed to outlier-driven interaction estimates** (audit §8), though
  not to the −$408M dollar reversal specifically.
- **Cumulative-dose hospital estimates** (Paper 2 "survivorship/adaptation"):
  `run_hospital_persistence.R`, `Hosp_OperatingMargin` dose-response. The synthesis already
  flags this as "survivorship-prone (unbalanced panel)"; unwinsorized ratios compound that.
- **Dollar-level incidence** (Paper 1): `Hosp_UncompCare_Real` (+$1.55M cold; −$6.21M drought)
  — the only headline directly carrying the −$408M-class reversals.

---

## 4. What I changed (contained, additive, no ripples)

Winsorization was genuinely absent from the CCN-panel analyses and the fix is contained, so
per the task rule I implemented an **opt-in within-year 1st/99th-percentile winsorization of
the analysis outcomes**, in the ANALYSIS layer only (never `process_hospital_panel.R`, so no
ripple to other tracks that read the panel). New/changed files:

- **`Code/hospital_winsorize.R`** (new) — pure helpers `winsorize_vec()`,
  `winsorize_within_year(df, cols, p=0.01, year_col="Year")`, and the `HOSP_WINSORIZE`
  env-var gate (`hosp_winsor_active()`, `hosp_winsor_suffix()`). Header documents the rule
  and rationale. **Rule:** each analysis **outcome (LHS only)** is winsorized to its
  **within-year** [P1, P99]; shocks, moderators, dose counts, and HHI inputs are untouched.
  Within-year (not pooled) so the shifting 2011–2023 NASHP sample is not conflated with
  outliers.
- **`Code/run_hospital_incidence.R`, `_persistence.R`, `_heterogeneity.R`** — each now
  `source("Code/hospital_winsorize.R")`, appends `hosp_winsor_suffix()` to its output paths,
  and (when `HOSP_WINSORIZE=1`) calls `winsorize_within_year(df, outcomes, 0.01)` right after
  the panel load / before any lead/dose transform. Plot blocks are guarded so raw PNGs are
  never overwritten. **Default runs (env unset) are byte-for-byte unchanged** — existing
  outputs and the scripts' own unit tests are unaffected.
- **`Code/tests/test_hospital_winsorize.R`** (new) — 7 `testthat` tests: quantile bounds,
  NA/non-numeric pass-through, degenerate (constant) windows, **within-year independence**
  (a value that is an outlier in one year but ordinary in another is clipped only where it is
  extreme), multi-column independence, absent-column skip, and the env-var gate.

Outputs written (14:18) alongside the untouched originals (10:44–10:51):
`hospital_{incidence,persistence,heterogeneity}_coefs_winsorized.csv` (+ `_results_winsorized.txt`).
Build logs: `Analysis/hospital/build_logs/run_hospital_*_winsorized.log`.
Within-year 1/99 clips ≈1,178 of ~58k hospital-years per outcome (~2%, i.e. the two 1% tails).

---

## 5. Before / after headline coefficients (raw → winsorized)

**Incidence (cumulative h=0..2):**

| Shock → outcome | Raw | Winsorized | Verdict |
|---|---|---|---|
| High_HDD → UncompCare $Real | +$1.55M (p=0.022) | +$1.37M (p=0.037) | **survives** |
| Is_Extreme_Drought → UncompCare $Real | −$6.21M (p<0.001) | **−$3.88M** (p<0.001) | survives; **magnitude −38%** (outlier-inflated) |
| High_CDD → UncompCare %NPR | +1.22pp (p=0.063) | +0.73pp (p=0.083) | survives (marginal both) |
| Is_Extreme_Drought → UncompCare %NPR | −1.68pp (p=0.032) | −1.23pp (p=0.015) | survives (stronger) |

**Persistence — symmetry (drought scarring) SURVIVES; cumulative-dose margin does NOT:**

| Estimate | Raw | Winsorized | Verdict |
|---|---|---|---|
| Drought symmetry, OperatingMargin (h=0) | +0.027 (p=0.006, asym) | +0.015 (p=0.006, asym) | **survives** |
| Drought symmetry, UncompCare %NPR (h=0) | −0.013 (p=0.012, asym) | −0.0098 (p=0.028, asym) | **survives** |
| **Dose marginal @5yr, OperatingMargin** | +0.00226 (**p=0.010**) | +0.00161 (**p=0.080**) | **FAILS — loses 5% significance** |
| **Dose 10+ vs 1-3, OperatingMargin** | +0.0179 (**p=0.033**) | +0.0124 (**p=0.131**) | **FAILS — loses significance** |
| Dose marginal @5yr, UncompCare %NPR | +0.0016 (p=0.067) | +0.0015 (p=0.044) | ~unchanged (was already weak) |

The margin "positive dose-response (survivorship/adaptation)" — the exact estimate the
synthesis already flagged as survivorship-prone — **is not robust to winsorization.** This
is the audit §8 survivorship concern materializing; the claim should be softened to
"no significant cumulative-margin decline, and no robust positive dose-response either."

**Heterogeneity — the PRIMARY heat × safety-net headline SURVIVES:**

| Interaction (on UncompCare %NPR) | Raw | Winsorized | Verdict |
|---|---|---|---|
| **High_CDD × SafetyNet** | int=+0.0345 (**p=0.021**) | int=+0.0209 (**p=0.013**) | **SURVIVES — slightly stronger** |
| High_HDD × SafetyNet (reversed) | int=−0.0207 (p=0.011) | int=−0.0134 (p=0.010) | survives (still reversed) |
| Is_Extreme_Drought × MedicaidExpansion | int=+0.0083 (p=0.001) | int=+0.0046 (p=0.044) | survives (weaker) |
| High_HDD × MedicaidExpansion | int=+0.0104 (p<0.001) | int=+0.0092 (p=0.002) | survives |

(Two `HighConcentration × …` verdict labels flip raw↔win, but both are non-significant
p≈0.6–1.0 — meaningless sign noise, not a real reversal.)

**Bottom line on exposure:** the headline the track most worried about
(**heat × safety-net uncompensated care**) is **robust** — winsorizing to remove the −496%/
+697% ratio tails *strengthens* it slightly (p 0.021 → 0.013). The −$408M-bearing drought
dollar effect keeps its sign and significance but sheds ~38% of its magnitude, so the
point estimate should be reported from the winsorized run. The **cumulative-dose margin
survivorship claim is the casualty** and should be demoted.

---

## 6. Test results & residual items

- **`Code/tests/test_hospital_winsorize.R`: 7/7 pass** (R 4.2.2).
- **`Code/tests/test_hospital_incidence.R`: pass** — confirms default (non-winsorized)
  behavior is unchanged by the edits.
- Winsorized re-runs of all three scripts: **exit 0**; `*_winsorized` outputs written;
  originals (10:44–10:51 timestamps) untouched.

**Residual / recommendations (not actioned here — out of task scope):**

1. **`run_mechanism_provider.R:57`** (track `mechanism_channels_20260625`) consumes raw
   `Hosp_UncompCare_Real` + ratios from the same panel and is **not** winsorized. For
   cross-track consistency it should adopt the same `HOSP_WINSORIZE` pass; left to that track
   (task 2.4 forbids editing other tracks' scripts).
2. **Canonical-status decision (evidence table, track 1.1):** the winsorized outputs sit
   alongside the raw ones by design. The author/evidence-table should decide which is
   canonical per result — recommendation: **winsorized as primary for the drought dollar
   incidence effect and for the cumulative-dose claim; raw and winsorized are consistent for
   the heat × safety-net headline** (report either; winsorized is marginally cleaner).
3. **Synthesis update (deferred):** `Analysis/hospital/synthesis.md` Paper 2 should note the
   cumulative-dose margin result does not survive winsorization; Paper 1 should cite the
   winsorized drought magnitude (−$3.9M). Not edited here (documentation-only task 2.5 folds
   verdicts in).
