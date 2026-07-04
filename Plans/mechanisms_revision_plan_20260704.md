# Mechanisms Section — Second-Reviewer Response Plan

**Date:** July 2026. **Feedback:** `Text/second_reviewer_feedback_mechanisms.md` (points A1–A3, B1–B2, C1–C4).
**Inputs:** a Fable strategic review + three Sonnet reference/data lookups (DiD-robustness methods;
multiple-testing corrections; morbidity/indemnity data feasibility). This plan integrates all four.

---

## Strategic frame (read first)

1. **The reviewer's deepest attacks hit HEAT; the section's spine is COLD/AQI.** A3 (energy burden)
   and B2 (frozen-baseline trend) bite almost exclusively on heat coefficients. But the load-bearing
   separability results — cold→employment (bottom-ag tercile), cold→debt, AQI→ED, safety-net
   heat×uncompensated-care — mostly survive the worst-case outcomes of the new robustness runs.
   **Cold and drought are anti-fragile to B2** (secular warming makes cold shocks *rarer* → bias
   toward attenuation, not spurious findings). This tells us which channel to be willing to
   sacrifice: **energy burden**, a heat interaction exposed to A3 *and* B2 at once.
2. **This reads as a friendly committee-side reviewer handing over pre-emptive armor** ("our best
   result"), not an adversary. Respond in that register: adopt the fixes, concede the two weak
   points cleanly, and lean on the robustness battery already built.

---

## Point-by-point triage

### A1 — "Runs primarily through" is an unestimated decomposition
- **Verdict:** Correct, and exposure is worse than it looks — the track's own `spec.md` acceptance
  criteria promised "the effect-share-not-explained-by-agriculture stated numerically," and the
  write-up substituted a *stronger verbal* claim ("runs primarily through" / "generated primarily
  by"). The design is a **necessity test**, which licenses only "operates substantially outside
  agriculture."
- **Action:** (1) **Soften the language** in §6.6, the §6 opener, and the NBER-response bottom line —
  this alone discharges the point (reviewer offered it as either/or). (2) **Build the accounting
  table** *after* the A2 rescaling, only for significantly-nonzero overall effects
  (cold→employment, heat→Medicare, drought→premiums): columns = overall effect, bottom-ag-tercile
  effect, share reproduced outside agriculture, with a footnote that it is an **upper bound under
  channel-homogeneity, not a decomposition**. Skip the `effect_bottom/effect_overall` ratio where
  overall ≈ 0 (unstable — already flagged).
- **The $177/9.5-ED → 1.1pp back-of-envelope is a TRAP** — Medicare 65+ standardized dollars can't be
  chained to working-age credit-bureau collections without three order-of-magnitude-uncertain free
  parameters (65+→working-age utilization ratio; out-of-pocket per encounter by insurance status;
  bill→collections hazard). A specific chained number hands a referee three new targets and re-asserts
  the decomposition A1 just retracted. **Substitute a hedged order-of-magnitude compatibility
  paragraph** (a 1.1pp rise needs only a modest count of new collections/county; median medical
  collection ≈ a few hundred dollars vs a self-pay ED visit in the low thousands; so a *fraction* of
  the sentinel-population utilization response suffices) — clearly labeled a plausibility check, or
  decline entirely.
- **Priority:** Soften = MUST. Table = STRENGTHENS. BOE = hedged-or-decline.

### A2 — Tercile scale problem (levels vs logs) — THE most dangerous item
- **Verdict:** Correct and highest-risk. `Civilian_Employed` is a level count; bottom-ag-tercile
  counties are urban and mechanically larger, so −2,011 vs −721 overall is uninterpretable — in
  proportional terms it could even reverse. Same contamination in the −689 (CDD×Labor) and −1,380
  (CDD×EnergyBurden) interactions. Income/debt outcomes are already scale-free; **only employment
  needs surgery.**
- **Action:** Re-run every employment spec with **log(Civilian_Employed)** (asinh as sensitivity;
  ACS counts strictly positive) and **per-1,000-workers** for the accounting table. Rewrite §6.3 +
  the energy-burden paragraph in log points.
- **Priority:** MUST-FIX and **FIRST** — every downstream quantitative fix (A1 table, A3, C4) is
  computed on this rescaled grid.
- **Fallback (pre-commit now):** "strengthens" may die in logs. The separability logic only needs the
  effect to **survive** (nonzero, significant) in low-ag counties — "strengthens" was rhetorical
  surplus. If even survival weakens, lean on the interaction reading (loads on non-farm exposed
  share, not on Ag_z), which is scale-clean once logged.

### A3 — Horse-race the interactions
- **Verdict:** Correct; the r=0.11-with-SVI defense is a non-sequitur (SVI isn't the confounder —
  baseline climate and poverty are). High-energy-burden counties are hot, poor, Southern, so
  CDD×EnergyBurden may be damage-function **curvature** (hot places hit harder by a marginal hot
  year). Most exposed claim in the section; compounds with B2.
- **Action:** One horse-race on the rescaled grid — shock × {Ag_z, Labor_z, EnergyBurden_z, SVI_z,
  **poverty_z, baseline-own-climate_z**} jointly, all standardized, + a moderator-correlation matrix
  in the appendix. Minimal must-do: shock×EnergyBurden controlling for shock×baseline-CDD and
  shock×poverty. Read **sign/significance survival, not magnitudes** (6 correlated interactions under
  state clustering will be noisy — say so).
- **Priority:** Minimal energy-burden version = MUST. Full joint = STRENGTHENS.
- **Fallback:** If energy burden dies, **concede it** — demote from "independent channel" to "a marker
  of the affordability margin we cannot separate from damage-function curvature." Architecture
  survives on morbidity + labor exposure.

### B1 — Recurring-treatment TWFE / negative weights / robust estimator
- **Verdict:** Right in principle, but the project is well-armed (DiD-frontier track already ran
  DRDID, HonestDiD, wild bootstrap, RI on the 2012 2×2). **Key nuance from the methods lookup: most
  of the modern DiD toolkit is built for *staggered absorbing* adoption and does NOT cleanly apply to
  recurring on/off shocks.** The right tools are the de Chaisemartin–D'Haultfœuille family.
- **Action (split by cost):**
  - (a) **Leads as placebos** — add F1 of each shock to the mechanism specs; piggybacks on the A2
    rerun at ~zero cost; should pass (weather is quasi-random | FE). A non-null heat lead is *B2*
    information, not a B1 failure.
  - (b) **Event-study figure** — `Analysis/did/robustness/dr_csdid_eventtime.csv` already exists;
    ~half a day. Be explicit the 2012 cohort has no testable pre-period (panel starts at its e=−1) —
    show the 2012 dynamic post-path + the pooled CS event-study with its already-disclosed
    employment pre-trends. Use `fixest::i(event_time, treat_cohort, ref=-1) | county + year` /
    LP-DiD (`alexCardazzi/lpdid`) for the single-cohort plot (clean, no negative-weight problem).
  - (c) **Robust estimator** — run `TwoWayFEWeights::twowayfeweights` (negative-weight share — the
    literal ask; the one family built for reversible treatment) on the main specs, then
    `DIDmultiplegtDYN::did_multiplegt_dyn` on **two headline pairs only** (cold→log-employment,
    heat→Medicare). NOT the full grid. R 4.5.3 environment already stands. **State explicitly** that
    Goodman-Bacon (`bacondecomp`) and Borusyak–Jaravel–Spiess (`didimputation`) are staggered-only
    and do not extend — the referee may ask by name.
- **Priority:** (a)+(b) = MUST. Weight diagnostic + dCDH on two pairs = STRENGTHENS. Full-grid
  re-estimation = DEFER explicitly.
- **Fallback:** Cite the existing frontier battery + weight shares; promise LP-DiD/dCDH full-grid as
  next iteration. Honest and strong — few dissertations have this much already run.

### B2 — Frozen baseline + secular warming
- **Verdict:** Right, deepest identification threat — **but heat-only.** Cold/drought are anti-fragile
  (warming → rarer cold → attenuation bias). Say this explicitly: it converts a general concession
  into a targeted one, and the best separability results are largely immune.
- **Action:** (1) **Division×year FE** on the headline heat results (piggyback the A2 rerun as an
  extra column) — run early; if heat→Medicare survives, the morbidity channel is near-unassailable
  (Deryugina-style results usually do). (2) **State×year FE** as a harsher column where feasible
  (employment, Medicare; note premiums die mechanically since rating areas are within-state — don't
  hide it). (3) **Conley SEs** alongside state clustering: `fixest::vcov_conley(est, lat="lon"...,
  cutoff=200)` (county centroids in `Data/Geo/`), primary = 200 km triangular + a 2–3-cutoff
  robustness row; verify it handles serial+spatial or add `conleyreg` `time=`. (4) **Decline the
  rolling climatology** — it re-opens the shock definition (scoped out; technical-note §1.2 defends
  the frozen baseline); FE robustness substitutes.
- **Priority:** Division×year FE on heat = MUST. State×year + Conley = STRENGTHENS. Rolling
  climatology = DECLINE with rationale.
- **Fallback:** If heat attenuates under division×year FE, lead the morbidity paragraph with **AQI and
  cold** (reproduce Deryugina in-panel regardless) and describe heat as trend-entangled. Channel
  verdict survives.

### C1 — Medicare doesn't reach the debt outcome
- **Verdict:** Right as a logical gap; the lag inversion (cold→debt t+1 vs cold→Medicare t+2) costs
  credibility if unaddressed.
- **Action:** (1) **Reframe Medicare as a SENTINEL population** — where the morbidity shock is
  *measurable* in clean administrative data, never "Medicare spending causes debt." One paragraph.
  (2) **Lag-structure-by-channel calendar** (the fallback the reviewer offers, and it's genuinely
  defensible): a winter-t cold shock generates bills hitting the following **August credit-bureau
  snapshot** (t+1) within the 90–180-day collections pipeline, while annual Medicare totals smooth
  within-year timing and Lag2 reflects delayed sequelae. Reuse the calendar-forensics move from the
  ACA rate-filing timing work (commit f35bf5f). (3) **Working-age bridge — use Census SAHIE**
  (the data lookup's top pick): free/keyless, county×year **18–64 uninsured rate** (+ income bands
  for an underinsured proxy), **full 2011–2023** — run shocks × uninsured-share as the working-age
  moderator; CDC PLACES (2018–2023 only) as a secondary cross-check. HCUP (purchase+DUA), HCCI
  (insured-only), BRFSS/SMART (MMSA not county) are **out of window — decline as future work.**
- **Priority:** Sentinel reframe + lag calendar = MUST (text). SAHIE moderator = STRENGTHENS.
- **Fallback:** Sentinel + lag calendar is the complete honest position with zero new data.

### C2 — Provider-finance: a null plus five stories
- **Verdict:** Fair hit (stacks ~5 unfalsified stories on one null). But the reviewer handed over the
  best cheap test in the report.
- **Action:** (1) **Pull USDA RMA Cause-of-Loss indemnities** (the data lookup's strongest find:
  free pipe-delimited ZIPs `colsom_2011.zip…colsom_2025.zip` at
  `pubfs-rma.fpac.usda.gov/pub/Web_Data_Files/Summary_of_Business/cause_of_loss/`; State/County FIPS
  + Cause-of-Loss "Drought" + Indemnity Amount; 2011–2023). Show the mechanical first stage
  (drought→indemnity spike), then interact **drought × baseline-indemnity-intensity** on
  uncompensated care: the federal-buffer story predicts the uncompensated-care rise concentrates in
  *low*-insurance-participation ag counties. Converts the weakest passage into its most creative
  affirmative test. (2) **Trim the five stories to the two evidenced** — federal buffers (now tested)
  + revenue-positive utilization (already evidenced by the safety-net heat interaction); label the
  rest speculation in one clause.
- **Priority:** Story-trim = MUST (text). RMA test = STRENGTHENS, **highest leverage-per-effort.**
  FSA disaster payments = heavy lift (no bulk file), DEFER.
- **Fallback:** Trimmed stories + safety-net interaction, RMA flagged in-progress.

### C3 — IRS non-filer undercount
- **Verdict:** Correct, cheap, and the direction matters: non-filers (low-income) are the most
  displacement-prone, so measured out-migration is a **lower bound** → the selection share of the
  drought scar could be *larger* than −0.0021 implies. This **cuts against** the scarring
  interpretation — say so.
- **Action:** One or two sentences + a coverage cite; simultaneously downgrade the p=0.047 migration
  result to "suggestive" (ties to C4).
- **Priority:** MUST (10 minutes).

### C4 — Multiple hypothesis testing
- **Verdict:** Legitimate (~15 significant coefficients from a grid of hundreds). Load-bearing results
  (heat→ED p=0.0002, AQI→ED p=0.0003, CDD×EnergyBurden p<0.001, safety-net p<1e-4) will survive
  family-wise correction within ~18-test channel families; casualties are predictable — bottom-tercile
  cold-employment (p=0.048), migration (p=0.047), cold→debt×Labor (p=0.03) will not.
- **Action:** (1) **Define families per channel, pre-specified in text** (morbidity, labor, energy,
  provider) — never post hoc around the stars. (2) **Romano–Wolf** via `wildrwolf::rwolf` (r-universe
  `s3alfisc`, archived from CRAN → R 4.5.3 sandbox; one `rwolf()` call per channel; use fixest
  multi-LHS or a generic regressor alias to share a `param` name; apply the FWL/`demean` trick if
  slow with heavy FE) on the **post-A2 rescaled** grid, + one **Anderson (2008) index per channel**
  (hand-roll: `w = solve(cov(Y,use="pairwise")) %*% 1; index = (Y %*% w)/sum(w)` on sign-aligned,
  baseline-standardized outcomes — no R package needed; cite Anderson 2008 JASA + swindex Stata J
  2020). Add **sharpened q-values** (`mutoss::multiple.down`, BKY 2006). (3) **Soften every p≈0.05
  claim now** — de-risks A2 and C3 too. Optional cross-check: `wildwyoung::wyoung` (Westfall–Young).
- **Priority:** Text softening = MUST. RW + Anderson table = STRENGTHENS (bordering MUST since the
  referee wrote it down). Must run *after* A2 or q-values won't match the reported estimates.
- **Fallback:** Anderson indices only + candid text on which results sit near 0.05.

---

## Sequencing (~2–3 weeks)

**Organizing trick:** ONE re-estimation campaign in week 1 discharges A2 + B1(leads) + B2(division×year
FE) at once. Everything quantitative downstream (A1 table, A3, C4) consumes that grid.

- **Week 1 — the rescaling gate + free text fixes.**
  1. A2 rerun campaign — log employment outcomes, F1 lead terms, division×year-FE column — one grid
     (2–3 days, critical path, start immediately).
  2. Same-day text batch (no dependencies): A1 soften, C3 sentence, C2 story-trim, C1 sentinel
     reframe + lag calendar, C4 downgrades of p≈0.05 claims.
  3. B1 event-study figure from the existing `dr_csdid_eventtime.csv`.
- **Week 2 — new evidence, three parallel lanes.**
  4. A3 horse-race on the rescaled grid; decide energy burden's fate.
  5. C4 Romano–Wolf + Anderson indices on the rescaled grid (R 4.5.3).
  6. C2 RMA Cause-of-Loss pull + buffer test (independent). B1 weight diagnostic (`twowayfeweights`)
     + `did_multiplegt_dyn` on the two headline pairs also slots here.
- **Week 3 — assembly.**
  7. A1 accounting table (needs A2 + C4). State×year FE + Conley columns. Census SAHIE working-age
     bridge. Rewrite §6 end-to-end with the new numbers; update the reviewer response.

**Explicitly deferred/declined:** full-grid robust estimator; rolling climatology (declined w/
rationale); HCUP/HCCI/FSA (access-infeasible in window); literal Medicare→debt calibration.

## Three highest-leverage actions
1. **The A2 campaign with B1-leads + B2-division×year-FE piggybacked** — one run addresses the "best
   result" concern *and* both identification points. If cold→log-employment survives in the bottom
   tercile and heat→Medicare survives division×year FE, the section's spine is near referee-proof.
2. **Romano–Wolf per channel + Anderson indices** — one appendix table neutralizes an entire category
   of suspicion and makes the section read as self-policing rather than star-hunting.
3. **The RMA indemnity test** — cheapest conversion of a liability (null + stories) into a novel
   affirmative result, and it strengthens the agriculture narrative (drought is real but insured).

## Where to concede rather than fight
1. **Energy burden (A3)** — double-exposed (curvature + heat-trend), current defense misses the real
   confounders, not load-bearing. Run the horse-race; if it attenuates, demote in one paragraph.
2. **"Runs primarily through" (A1)** — concede immediately; the design is a bound.
3. **Migration p=0.047 + C3** — fold in the undercount caveat, call it suggestive before RW forces it.

---

## Reference appendix (from the Sonnet lookups)

**DiD robustness (B1) / SEs (B2):**
- LP-DiD — Dube, Girardi, Jordà & Taylor, NBER 31184 (2023) / JAE 40(7) 2025; R `alexCardazzi/lpdid`
  (GitHub). Partial mismatch with recurring treatment → use for the **2012 2×2** event-study only.
- Negative-weight diagnostic — `TwoWayFEWeights::twowayfeweights` (CRAN); dCDH, AER 110(9) 2020.
  Built for **reversible** treatment — the correct tool here.
- Dynamic recurring estimator — `DIDmultiplegtDYN::did_multiplegt_dyn` (CRAN); dCDH NBER 29873.
  Closest off-the-shelf fit; estimand ≠ linear DL coefficient → companion, not drop-in. Two pairs only.
- Staggered-only (state they don't extend): `bacondecomp::bacon` (Goodman-Bacon, JoE 2021);
  `didimputation::did_imputation` (Borusyak–Jaravel–Spiess, ReStud 2024).
- Event study / leads — `fixest::i(event_time, cohort, ref=-1)`; add F1 shock terms for placebos.
  `sunab` needs a cohort → mismatch for recurring shocks.
- Conley SEs — `fixest::vcov_conley(est, lat, lon, cutoff)` or inline `vcov=conley(200)`; Conley,
  JoE 1999; or `conleyreg::conleyreg(..., time=)`. 200 km triangular primary + cutoff robustness.

**Multiple testing (C4):**
- Romano–Wolf — `wildrwolf::rwolf(models, param, B=9999)` (r-universe `s3alfisc`, archived from CRAN
  2024-05-29 → R 4.5.3); Romano & Wolf, Econometrica 2005; Clarke, Romano & Wolf, Stata J 2020.
  One call per channel; share a `param` name via multi-LHS or a regressor alias; FWL trick if slow.
- Anderson index — hand-rolled 5-line R (pairwise cov → `solve` → weighted avg on sign-aligned,
  baseline-standardized outcomes); Anderson, JASA 2008; methods cite `swindex`, Stata J 2020.
- Sharpened q-values — `mutoss::multiple.down` (Benjamini–Krieger–Yekutieli 2006) or `p.adjust(...,
  "BY")`. Westfall–Young cross-check: `wildwyoung::wyoung` (experimental).

**Data (C1/C2):**
- **Census SAHIE** — county×year 18–64 uninsured rate + income bands, 2008–2023, free/keyless
  (census.gov/programs-surveys/sahie or API). **Primary C1 bridge.**
- **CDC PLACES** — county uninsured-adults 18–64, **2018–2023 only** (data.cdc.gov). Secondary C1.
- **USDA RMA Cause-of-Loss** — county×crop×year×cause, free ZIPs (`colsom_YYYY.zip` at
  pubfs-rma.fpac.usda.gov/.../cause_of_loss/), 1989–2026; Drought cause code + Indemnity Amount.
  **Primary C2 test.**
- **Out of window (decline):** HCUP SID/SEDD (purchase + DUA), HCCI (insured-only + application),
  BRFSS/SMART (MMSA not county), USDA FSA payments (no public bulk county-year file).
