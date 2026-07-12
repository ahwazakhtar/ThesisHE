# County Master One-Row-Per-County-Year — Integrity & Before/After Report

**Task:** `thesis_completion_20260704` 2.2 (spec T1.2); cross-referenced as the blocker
for `audit_response_20260712` task 1.4 and audit §9. Closes the
`county_analysis_refinement_20260216` deferred one-row-per-county-year item.
**Date:** 2026-07-13. **Environment:** R 4.2.2, `fixest::feols`.
**The fix:** `Code/create_county_master.R` (see its DEFENSE-DOCUMENTATION header block).
**Pre-dedup backup (byte copy, md5-verified):**
`Data/_archive/county_level_master_prededup_20260713.csv`.

> **One-line verdict.** The county master is now certified unique on
> `(fips_code, Year)` (119,300 → **118,732** rows). **Every headline/evidence-table
> claim is preserved**: the 2012 DiD income & employment ATTs are *identical*, the
> county medical-debt cells (cold L1, drought L2) move < 0.08 SE, and the ACA
> premium pass-through verdict is unchanged. **One material, expected, and now
> corrected movement** appears in *non-headline* population-weighted distributed-lag
> climate coefficients on income/employment — the pre-dedup master double-counted
> split counties, and in population-weighted specs each duplicate carried the
> county's full population weight. That is the bug this task fixes, exactly as audit
> §9 warned ("can alter county weighting, standard errors, treatment counts").

---

## 1. Diagnosis

### 1.1 The cause (pinpointed)

ACA benchmark/bronze premiums are set at the geographic **rating-area** level. Most
counties belong to exactly one rating area, but where a state defines rating areas by
3-digit ZIP or by MSA, a single county can straddle **multiple** rating areas. The
premium source `Data/premiums_county.csv` (built by `process_rating_area_map.R` from the
HIX county↔rating-area crosswalk, columns `fips_code, Year, Benchmark_Silver,
Lowest_Bronze, State, rating_area_id`) then carries **one row per county × year ×
rating_area**, and the premium `left_join(df_premiums, by = c("fips_code","Year"))` in
`create_county_master.R` fans those into duplicate county-year rows.

### 1.2 Duplicate counts (pre-dedup master, 119,300 rows)

| Scope | Duplicate groups | Extra rows | % of rows |
|---|---|---|---|
| All years (1990–2026) | **484** | **568** | 0.48% |
| Outcome window 2011–2023 | 428 | 497 | ~1.2% of county-years |
| Premium window 2011–2025 | 465 | 544 | — |

Group sizes: **413 × 2, 58 × 3, 13 × 4** rating areas. All duplicates fall in **2014–2026**
(the premium window; no pre-2014 duplicates). Concentration by state (extra rows):

| State | Duplicate groups | Extra rows |
|---|---|---|
| NE (Nebraska) | 199 | 218 |
| AK (Alaska) | 140 | 140 |
| MA (Massachusetts) | 92 | 157 |
| ID (Idaho) | 40 | 40 |
| CA (California) | 13 | 13 |

### 1.3 What varies vs what is constant within a duplicate group (the constancy proof)

Across all 484 duplicate groups, **only the five premium / rating-area-derived columns
differ**; **every one of the other 77 columns is constant** (0 groups varying):

| Column | # duplicate groups in which it varies |
|---|---|
| `rating_area_id` | 484 (all — by construction) |
| `Benchmark_Silver` | 418 |
| `Lowest_Bronze` | 417 |
| `Benchmark_Silver_Real` | 399 |
| `Lowest_Bronze_Real` | 398 |
| **all 77 other columns** (medical-debt outcomes, every climate shock + lag, AQI, `Population`, `PCPI_Real`, `Med_HH_Income_Real`, `Civilian_Employed`, hospital accounts, …) | **0** |

County climate and economic variables are county-level objects — they cannot differ by
rating area. This is what makes a `first()`-collapse of the non-premium columns **provably
lossless**. `create_county_master.R` re-derives this at build time with a `stopifnot()`
(the build **aborts** if any non-premium column ever varies within a group), and the test
`Code/tests/test_county_master_dedup.R` re-verifies it on the real pre-dedup backup:
`max(n_distinct) = 1` for every non-premium column. **HARD-REQUIREMENT check: passed** — no
non-premium analysis column varies within any duplicate group.

### 1.4 Within-county rating-area premium dispersion

The premium columns *do* vary across a split county's rating areas, so the collapse rule
for them matters. The dispersion is modest but not trivial:

- `Benchmark_Silver_Real` within-group **range**: mean **$45.79/mo**, median **$33.37/mo**,
  p90 **$113/mo**, max **$248/mo**.
- As a share of the split-county mean level (~$482.87/mo): **~9.1%** on average; within-group
  **CV** median **0.036**, mean 0.061.
- **57 of 456** finite-premium groups have **zero** dispersion (identical premium across
  rating areas); 28 groups have all-NA premiums (2024–2026, where the CPI deflator is not yet
  populated).

---

## 2. The collapse rule (committee-defense core)

**Chosen rule.**
- **Non-premium columns** → `first()` **after** the constancy `stopifnot()`. Lossless
  (identical across the group's rows), order-independent.
- **Premium columns** (`Benchmark_Silver`, `Lowest_Bronze`, `Benchmark_Silver_Real`,
  `Lowest_Bronze_Real`) → **unweighted mean across the county's rating areas** (NA-aware;
  all-NA → NA, never NaN). Interpretation: *the premium faced by a representative resident of
  a county that spans several rating areas*, giving every rating area the county touches equal
  say — deterministic, symmetric, uses all rating-area information.
- **`rating_area_id`** → the deterministic **minimum** (alphabetically-first) id the county
  touches, kept only as a representative label so the rating-area clustering / aggregation
  robustness variants in `run_county_analysis.R` still run. The premium a split county now
  carries is the cross-area **mean**, not that one area's premium.

**Rejected alternatives (in the task's stated order of preference).**

| Rank | Rule | Feasible? | Reason |
|---|---|---|---|
| (i) | enrollment-weighted mean ("premium of the average enrollee") | **No** | The HIX crosswalk and plan files carry **no** county × rating-area enrollment (nor any county-level enrollment) weight. Best in principle, unavailable in data. |
| (ii) | county-population-share-weighted mean | **No** | We have whole-county `Population` but **no sub-county split** of a county's population across the rating areas it straddles, so no defensible share weight exists. |
| (iii) | **unweighted mean across rating areas** | **Yes → CHOSEN** | Symmetric, deterministic, uses all information; dispersion is modest (§1.4) and the result is rule-invariant (§2.1). |
| (iv) | `first()`-by-sort-order on the premium | Rejected as production rule | This is the non-deterministic downstream **stopgap being retired** (`run_premium_mediation.R` / `run_latent_hardship.R`). Order-dependent, discards information. (It *is* used, harmlessly, for the constant non-premium columns, where every row is identical.) |

### 2.1 Alternative-rule robustness (mean vs. min-rating-area selection)

To show the headline is not an artifact of the mean rule, the same before/after harness was
run on a second deduped master that selects each split county's premium from its **minimum**
rating-area row (the requested min-RA-id alternative) instead of averaging.

- **Non-premium outcomes (income, employment, debt): the two rules are byte-identical
  — max |Δ|/SE = 0.000.** Mechanically true: the mean- and min-collapse produce identical
  non-premium columns (both `first()` on constant columns); only the premium columns differ,
  and income/employment/debt regressions do not use them.
- **Premium as the outcome** (`Benchmark_Silver_Real` on the LHS, `run_county_analysis.R`
  county spec): max |mean − min|/SE = **0.092** — rule-invariant.
- **RA-level pass-through, Drought L2 benchmark:** mean rule **3.167** (SE 2.573) vs min-RA
  **3.812** (SE 2.643); both up from the 2.479 pre-dedup value, and **both keep the STRONG
  bound** (equivalence δ* = 7.40 and 8.16 respectively, each below the $9.33–$14.75
  full-pass-through band). Verdict is rule-invariant.

---

## 3. Before/after coefficient comparison

**"Materially unchanged" is defined EXPLICITLY as |Δ| < 0.1 × SE(before).** Harness: the
exact `run_county_analysis.R` Spec1_Base / Spec2_Base models (county+Year FE, state-clustered,
unweighted **and** population-weighted) plus the 2012 DiD 2×2 (139 first-onset vs 2,534
never-exposed, `fixest::feols`, mirroring `Code/tests/test_did_robustness.R`), run on the
pre-dedup backup ("before") and the rebuilt master ("after"). **No rebuild drift:** the
rebuilt master equals a post-hoc mean-collapse of the backup to 1e-6 (same keys, same NA
pattern), so every Δ below is attributable **purely to de-duplication**, not to any rebuild or
data change.

### 3.1 Headline / evidence-table cells — all preserved

| Model | Coefficient | Before | After | Δ | Δ / SE(before) | Verdict |
|---|---|---:|---:|---:|---:|---|
| **2012 DiD 2×2** | PCPI_Real ATT (TxP) | −1310.67 | −1310.67 | 0 | 0.000 | **identical** |
| **2012 DiD 2×2** | Civilian_Employed ATT | −2042.67 | −2042.67 | 0 | 0.000 | **identical** |
| 2012 DiD 2×2 | Med_HH_Income_Real ATT | −990.72 | −990.72 | 0 | 0.000 | identical |
| 2012 DiD 2×2 | Medical_Debt_Share ATT | −0.006192 | −0.006192 | 0 | 0.000 | identical |
| Debt, Spec2 pop-wtd | cold L1 (High_HDD_Lag1) | 1.9270e-3 | 1.7748e-3 | −1.52e-4 | −0.079 | unchanged |
| Debt, Spec2 unwtd | cold L1 (High_HDD_Lag1) | 1.2830e-3 | 1.3135e-3 | +3.05e-5 | +0.022 | unchanged |
| Debt, Spec1 pop-wtd | drought L2 (PDSI_Lag2) | −5.802e-4 | −6.032e-4 | −2.30e-5 | −0.066 | unchanged |
| Debt, Spec2 pop-wtd | drought L2 (PDSI_Lag2) | −6.657e-5 | −5.263e-5 | +1.39e-5 | +0.042 | unchanged |
| Debt, Spec1/2 unwtd | drought L2 (PDSI_Lag2) | 6.36e-5 / −1.03e-4 | 5.18e-5 / −1.07e-4 | tiny | −0.024 / −0.011 | unchanged |
| **RA×yr pass-through** | Drought L2, benchmark | 2.479 | **3.167** | +0.688 | **+0.295** | **MOVED — verdict STRONG holds** |
| RA×yr pass-through | Heat L2, benchmark | −10.48 | −10.40 | +0.072 | +0.008 | unchanged |
| RA×yr pass-through | Cold L2, benchmark | 12.57 | 13.08 | +0.510 | +0.089 | unchanged |
| County premium (transparency trail) | Heat L2 | 19.45 | 19.45 | 0 | 0.000 | **invariant** |
| County premium (transparency trail) | Cold L2 | −15.45 | −15.45 | 0 | 0.000 | **invariant** |

**RA-level Drought L2 moved +0.30 SE but the H4 verdict is unchanged.** The equivalence
bound δ* = |β| + 1.645·SE goes 6.32 → **7.40**, still **below** the $9.33–$14.75
full-morbidity-pass-through band → the **STRONG** drought bound holds (now "rules out
pass-through larger than ~50–79% of the benchmark" vs the pre-dedup ~43–68% — a marginally
weaker but qualitatively identical bound). Heat/Cold cells and the "no coherent pass-through /
sign-instability-across-levels" headline are unchanged. **Why it moved at all:**
`run_premium_mediation.R` builds its RA panel from the master's per-rating-area rows
(`build_level(raw, "rating_area_id")` — explicitly "from raw (split-county RA rows)"), so the
upstream collapse necessarily alters it: split counties (NE/ID drought-relevant) no longer
appear once per rating area, and their population is no longer double-counted across the areas
they straddle. See §5 for the consequence and the recommended follow-up.

### 3.2 The surprise: non-headline population-weighted climate coefficients moved — investigated

Across all **180** county coefficient cells, **116 are materially unchanged and 64 exceed the
0.1-SE bar** (max **|Δ|/SE = 1.28**). This is far larger than the task's a-priori expectation
(≲ 0.05 SE) and was treated as a debugging trigger first. **It is not a bug — it is the
correction working, and it is confined to non-headline cells.**

- **The exceedances are dominated by population-weighted specs: 49 of 64 moved cells are
  population-weighted** (of 90 pop-weighted cells, 49 moved; of 90 unweighted cells, only 15
  moved). Largest mover: `Civilian_Employed`, Spec1 pop-weighted **PDSI_Lag1: 2084.9 → 1342.8
  (SE 580.7, Δ/SE −1.28)**.
- **Mechanism.** The pre-dedup master listed a split county 2–4 times per year with identical
  climate/economic values but different premiums. In an **unweighted** regression a duplicated
  row is merely counted k times (mild leverage change → 75/90 unweighted cells unchanged). In
  a **population-weighted** regression each duplicate carries the county's **full `Population`
  weight**, so a k-times-split county receives **k × its weight** — and the split counties
  include large-population metros (**MA/Boston, CA**) that then dominate the pop-weighted
  climate coefficients. De-duplication removes this artificial replication of weight. This is
  precisely the "county weighting … standard errors … treatment counts" distortion audit §9
  flagged. Complete-case N falls by the expected amount (≈ −376 for income/employment, −349
  for debt, −362 for the premium outcome = the split county-years in each sample).
- **No headline claim rests on a moved cell.** The moved cells are the distributed-lag
  *climate* coefficients on income/employment (Spec1/Spec2), which the master evidence table
  treats as exploratory/robustness, **not** as headline estimands. The income/employment
  headline is the 2012 **DiD** (identical), the cumulative-dose result (separate script), and
  the shock×moderator interactions (separate scripts). Even within the debt outcome, the
  pop-weighted *Z-shock* and `pdsi_val` cells move (large-county double-count) while the two
  **headline** debt cells — cold L1 and drought L2 — stay < 0.08 SE.
- **Direction of correctness.** The **post-dedup** population-weighted coefficients are the
  correct ones; the pre-dedup values were inflated by counting split-county population 2–4×.
  Any prior narrative that leaned on a pop-weighted distributed-lag climate coefficient from
  `run_county_analysis.R` should be re-checked against the refreshed
  `Analysis/county/county_regression_results.md` (regenerated 2026-07-13).

---

## 4. Downstream dedup stopgaps — now no-ops (code left untouched)

| Stopgap | Status after the upstream fix |
|---|---|
| `run_latent_hardship.R::dedup_county_year()` (first() collapse, [B5]) | **No-op / exactly invariant.** Its `keep_cols` are all non-premium (fips, Year, State, Population, the two debt outcomes, `Med_HH_Income_Real`, cold & drought shock families) — every one constant within `fips×Year`. Collapsing an already-unique panel by `first()` returns it unchanged, so the pre-registered primary cell **drought × uninsurance = −0.00547 (q = 0.012)** and the whole 40-row gradient grid are **numerically identical** post-dedup. The "pre-dedup" label may be dropped on the next refresh; no re-run required for correctness. |
| `run_premium_mediation.R` county/state dedup (`county <- raw %>% group_by %>% summarise(fmean, first)`) | **No-op for the county & state frames.** Non-premium columns are already unique; the premium `fmean` of a single (already-averaged) value returns that value. Hence the **county transparency-trail premium spec** and the **mediation (ii) decomposition** (92–99% surviving) and the **state×year secondary** spec are all invariant (confirmed: county Heat/Cold L2 Δ = 0 exactly). |
| `run_premium_mediation.R` **RA panel** (`build_level(raw, "rating_area_id")`) | **NOT a stopgap and NOT invariant** — see §3.1/§5. This is core RA construction that reads the master's per-rating-area rows, which the upstream dedup changes. The **verdict is unchanged** (STRONG drought bound holds), but the RA-level point estimates shift slightly (Drought L2 2.48 → 3.17). Because I may not modify that script, its committed `Analysis/mediation/*` outputs remain "pre-dedup" for the RA-level spec. |

**Recommended follow-up (out of scope here; needs the owner of `run_premium_mediation.R`):**
re-point its RA panel at `Data/premiums_county.csv` (which retains the full county×rating-area
structure) instead of the now-deduped master, so the RA-level pass-through is computed from
source and is no longer coupled to the county-master collapse. Until then, re-running
`run_premium_mediation.R` / `run_passthrough_bounds.R` will reproduce the small RA-level shift
documented above (verdict-invariant).

---

## 5. Remaining consumers to re-run opportunistically

39 scripts read `Data/county_level_master.csv`. With the fix upstream, each now reads the
deduped master automatically on its next run — **no code change needed**.

- **Already re-run in this task:** `run_county_analysis.R` (exit 0; all outputs regenerated
  2026-07-13).
- **Invariant (dedup internally) — no re-run needed for correctness:** the DiD/robustness
  layer (`00_did_robustness_common.R` via `distinct()`, `07_falsification_suite.R`,
  `07_recurring_treatment_check.R`, `run_did_analysis.R`, `run_re_robustness.R`),
  `run_latent_hardship.R`, and the county/state/mediation parts of `run_premium_mediation.R`.
- **Read the raw master and should be re-run before final tables freeze (they will pick up the
  dedup, and their population-weighted specs may shift as in §3.2):** `run_event_study.R`,
  `run_delta_analysis.R`, `run_cumulative_dose.R`, `run_descriptive_stats.R`,
  `run_threshold_sensitivity.R`, `run_county_humidity_sensitivity.R`, `run_pathway_descriptives.R`,
  `run_exposure_index.R`, `run_exposure_index_state.R`, `run_exposure_secondary.R`,
  `run_persistent_exposure.R`, `run_never_exposed_inventory.R`, `run_passthrough_bounds.R`,
  and the mechanism family (`run_mechanism_medicare.R`, `run_mechanism_horserace.R`,
  `run_mechanism_conley.R`, `run_mechanism_sahie_bridge.R`, `run_mechanism_multipletesting.R`,
  `run_mechanism_rma_buffer.R`, `run_mechanism_secondary.R`, `run_mechanism_agriculture.R`,
  `run_mechanism_employment_rescaled.R`, `run_demographic_mediators.R`,
  `run_demographic_mediators_state.R`). Priority for those citing **population-weighted**
  county coefficients (§3.2). A full `run_pipeline.R` pass is the clean way to refresh all of
  them before `audit_response_20260712` task 1.4 freezes the evidence table.

---

## 6. Reproduction & provenance

- **Fix:** `Code/create_county_master.R` — DEFENSE-DOCUMENTATION header block +
  "6. One-row-per-county-year enforcement" section (constancy `stopifnot` → premium-mean
  collapse → uniqueness `stopifnot` → row-count band). Build-time manifest:
  `Analysis/county/build_logs/create_county_master_dedup.log`.
- **Backup:** `Data/_archive/county_level_master_prededup_20260713.csv` (byte copy of the
  pre-dedup master; md5-identical to the pre-run file).
- **Rebuilt master:** `Data/county_level_master.csv` — **118,732 rows × 82 cols, 3,232
  counties**, unique on `(fips_code, Year)`; = 119,300 − 568 (exact).
- **Tests:** `Code/tests/test_county_master_dedup.R` (testthat, R 4.2.2, all pass) — uniqueness,
  row band, premium-mean rule on a synthetic two-rating-area fixture, constancy assertion fires
  on a poisoned fixture, FIPS zero-padding, and the real shipped premiums = unweighted RA mean
  of the backup.
- **Rebuild command:** `& "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/create_county_master.R`.
