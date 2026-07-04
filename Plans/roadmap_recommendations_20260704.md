# Roadmap & Recommendations — What More to Do on a Time-Bound Thesis
**Date:** July 4, 2026
**Companion to:** `Plans/project_assessment_20260704.md` (read that first for the evidence behind each claim here).

**Framing principle:** the econometrics is essentially finished; the binding constraint is now (a) inference protection on the headline natural experiment, (b) prose, and (c) stakes (welfare quantification). Every recommendation below is scored against that. Assumptions where the author hasn't yet answered: ~6–12 months to defense, Essay 1 (Incidence) as the job market paper, committee sign-off on the Incidence/Persistence/Inequality structure still pending.

---

## Tier 0 — Do regardless of timeline (≈2–3 weeks total)

### 0.1 Run DiD frontier Phase 1: wild cluster bootstrap + randomization inference
**Why first:** 67% of the 2012 treated cohort sits in 4 states. Every committee member and referee who knows Cameron–Gelbach–Miller will ask whether the −$1,311 income effect survives few-treated-cluster correction. This is the only open item that can *retroactively weaken an existing headline*.
**Effort:** hours. `Code/did_robustness/01_wild_cluster_bootstrap.R` exists; the FWL-demeaning fix for the FE-heavy model is documented; runs on R 4.5.3.
**Then close the track:** run `04_synthesize_did_robustness.R` → `Analysis/did/robustness/did_robustness_summary.md`; fold the bootstrap p-values into the technical note; write the Phase 5 `testthat` suite. The DRDID and HonestDiD results currently exist only as CSVs — unsynthesized robustness is robustness a committee can't see.

### 0.2 Extend the 2012 DiD pre-period with BEA income (new, cheap, high value)
**The problem it solves:** the panel starts in 2011, so the 2012 cohort has *no testable pre-period* — which is why HonestDiD could only run on the pooled event study and "cannot vindicate the 2012 headline." This is the single biggest identification hole in the dissertation's strongest result.
**The fix already sits in the data:** BEA CAINC1 per-capita income is downloaded back to 1990 (`process_county_socioeconomic.R`). Construct 1990–2011 PCPI pre-trends for the 139 treated vs 2,534 never-exposed counties and show (or test) parallel pre-trends over two decades. If they're parallel, the income headline gets the pre-trend defense it currently lacks; if they're not, better to know now than at the defense. Employment can't be extended (ACS starts 2011) — fine, income is the robust result anyway.
**Effort:** ~1–2 days. One script, one figure, one paragraph in the technical note.

### 0.3 Get the committee decision on Chapter 3
Before writing anything long, confirm in writing that the Incidence/Persistence/Inequality structure replaces the proposed structural model. If the committee still expects a policy component, Tier 1.3 below is the scaled-down version to offer — do not let a full microsimulation back onto the critical path.

### 0.4 Housekeeping (half a day)
Fix the two incomplete references (Audi et al.; Doremus et al.) and the two `[TK]` denominators in the reviewer-response file; delete stray `*.tmp.*` artifacts; work through the 8 open Conductor verification gates (they are checklists, not analysis — batch them).

---

## Tier 1 — The core push (≈2–3 months): write, and add stakes

### 1.1 Write Essay 1 in full, first
The repo has abstracts, a technical note, a mechanisms section, and decks — but no complete manuscript. Essay 1 is the job market paper candidate: it has the natural experiment, the frontier robustness, the Medicare mechanism, and the reviewer-tested mechanisms narrative. Assemble it from parts that already exist (the writing skill and NBER exemplar are in place). Target a full draft in 4–6 weeks, then Essays 2 and 3, which share its data/methods sections and will go much faster.
**Writing discipline already established, keep it:** lead with income (robust), caveat employment (fragile), frame medical debt as measurement (extensive-margin + fragility), lead mechanisms with morbidity and labor exposure.

### 1.2 Estimate the premium pass-through / mediation the proposal promised
The one proposal-era analysis that is both undelivered and cheap: do premiums mediate the shock→debt relationship, and what is the pass-through ρ of lagged claims-relevant shocks into benchmark premiums? Everything needed (premiums, debt, shocks, lags, rating-area structure) is in the county master. A two-equation exercise: shock → premium (ρ), then debt with/without premium controls (fraction-surviving decomposition, same machinery as `run_demographic_mediators.R`). Closes a proposal promise, gives Essay 1 its insurer-side story, and feeds 1.3.
**Effort:** ~1 week including write-up.

### 1.3 A sufficient-statistics policy section instead of the structural model
The honest, tractable descendant of Chapter 3 — one section (or a short chapter coda), not a model:
- **Price the "unpriced margin":** the abstracts claim insurers leave the environmental lag structure unpriced; multiply the estimated premium lag responses by exposed enrollment to state the aggregate mispricing in dollars.
- **Aggregate the scars:** cold-compounding job losses × counties in each dose bin; drought debt scar × exposed population → a national annual burden figure with honest error bands.
- **One targeting statement:** given SVI and energy-burden amplification, a back-of-envelope on how geographically concentrated the burden is (top-decile counties' share of total harm) — the reduced-form answer to the proposal's subsidy-targeting question.
**Effort:** ~2 weeks. This is the highest-leverage stakes-raiser per unit of time, and the strongest response if the committee still wants "policy relevance" from the old Ch. 3.

### 1.4 Close the one data-integrity hole
Enforce one-row-per-county-year in the county master (the ~3% multi-rating-area duplicates, currently deduped ad hoc downstream). Do it once upstream, re-run the affected regressions, confirm nothing moves, and log it. A defense-question magnet eliminated for ~2–3 days of work.

---

## Tier 2 — If time allows (~1 month each; only after Tier 1 drafts exist)

### 2.1 County mortality from CDC WONDER
The standard health-econ complement the dissertation currently lacks: direct physical-health outcomes. Keyless, public, county-year, slots into the existing pipeline as one more outcome family (all-cause and cardiovascular/respiratory mortality vs the four shocks). Reproduces the Barreca/Deryugina benchmark in-panel and pre-empts the "where is health in this health-economics thesis?" question. High defensive value for a health-econ committee; medium offensive value (the literature is mature).

### 2.2 A recurring-treatment frontier estimator
The DiD spec names de Chaisemartin–D'Haultfœuille (`did_multiplegt_dyn`) and Borusyak–Jaravel–Spiess as candidates that address the on/off treatment estimand directly rather than via the first-onset recast. One of them, run on the income outcome only, would future-proof the JMP for referees. Runs on the R 4.5.3 toolchain.

### 2.3 Hospital closures as the supply-side extreme outcome
The mechanism verdict noted the rural-closure prediction literature omits climate entirely — a real gap. A shock → closure-hazard model (closure events are derivable from CCN exit in the NASHP panel) would give Essay 3's supply side a sharper endpoint than margins. Guard the reverse-causality direction (closures → local economy) as already noted.

## Explicitly recommend against (given the time bound)

- **The full structural microsimulation.** Multiple months of work, high modeling risk, and the committee pressure it answered has (apparently) moved on. Offer 1.3 instead.
- **Reviving wildfire smoke / FEMA disasters as headline hazards.** AQI identification in this panel is thin (3% never-exposed); satellite smoke would be a new data platform late in the game. Acknowledge the demotion in one paragraph and move on.
- **New exposure platforms** (satellite NDVI/LST, mobility-based exposure) — already decided out of scope in the CHEI spec; keep them there.

---

## Suggested sequencing (assuming ~9 months to defense)

| Months | Focus |
|---|---|
| **Jul** | Tier 0 in full: wild bootstrap + RI, BEA pre-trends, DiD synthesis + tests, committee email on Ch. 3, housekeeping, verification gates |
| **Aug–Sep** | Essay 1 full draft (1.1) + mediation analysis (1.2) folded in as it lands |
| **Oct** | Sufficient-statistics policy section (1.3); data-integrity fix (1.4); circulate Essay 1 to committee |
| **Nov–Dec** | Essays 2 and 3 drafts; Tier 2 items only if committee feedback demands them (mortality being the most likely ask) |
| **Jan–Mar 2027** | Revisions, defense packaging, JMP polish |

**The one-sentence version:** protect the 2012 income result (bootstrap inference + a 20-year pre-trend it currently lacks), then stop doing econometrics and write — adding stakes through a mediation estimate and a sufficient-statistics policy section rather than any new machinery.
