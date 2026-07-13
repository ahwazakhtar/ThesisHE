# Errata — Submitted Conference Abstract

**Subject:** `Text/submissions/conference_abstract.md` and `conference_abstract.tex`
("Climate Shocks and the Financial Health of American Households: Incidence, Persistence,
and Inequality," A. Akhtar).
**Date:** 2026-07-12. **Origin:** `audit_response_20260712` task 1.2 (objective O2).
**Status:** ADVISORY. The submitted files are **not edited** — a submitted document is never
silently rewritten. This note lists each claim the master evidence table
(`Plans/master_evidence_table.md`) has since **retired or amended**, with the row reference
and a suggested corrected sentence, for the author to decide whether and how to notify the
conference.

The claim architecture changed after submission in four material ways: (1) the "2012 Midwest
drought" label is a geographic misnomer; (2) the ~2,000-job employment loss is fragile and no
longer co-headlines with income; (3) insurance premiums do **not** show a coherent local
pass-through, so "raise … premiums" overstates the finding; and (4) part of the drought scar
is out-migration composition, so "not mediated by migration" is not accurate for drought.
None of the corrections reverse the abstract's thesis — they tighten it.

---

## Amendments (submitted sentence → issue → suggested correction)

### 1. "2012 Midwest drought" — RETIRED label (Row 3)
- **Submitted (¶2, long version):** "The 2012 Midwest drought, used as a sharp natural
  experiment, lowered per-capita income by $1,311 and employment by roughly 2,000 jobs …"
- **Issue:** The extreme-PDSI first-onset treated cohort is Georgia, the Mountain West, and
  the Plains — not the Midwest. (The short version already avoids the word "Midwest.")
- **Suggested:** "The 2012 drought (treating first-onset counties in Georgia, the Mountain
  West, and the Plains as a sharp natural experiment) lowered per-capita income by about
  $1,311 relative to never-exposed counties …"

### 2. Employment co-headlined with income — now FRAGILE, event-specific (Rows 1–2)
- **Submitted (¶2):** "… lowered per-capita income by $1,311 and employment by roughly 2,000
  jobs in treated relative to never-exposed counties, identifying the income channel …"
- **Issue:** Income is robust (WCB/RI, DRDID −$1,451, flat two-decade pre-trend). The ~2,000-job
  employment estimate is fragile — it attenuates ~58% under DRDID and reverses sign in the
  pooled estimator — and should not carry equal billing. The income result is the 2012
  event's effect (ITT of first onset), not a general drought-response function: the pooled
  multi-cohort average is null under the doubly-robust frontier estimator at onset (−$324,
  SE 276) and over the long run. *(Corrected 2026-07-13: an earlier draft of this erratum
  cited a −$1,050 onset effect from a manual aggregation with invalid SEs — coding audit A4.)*
- **Suggested:** "… lowered per-capita income by about $1,311 relative to never-exposed
  counties, with a smaller and more fragile, event-specific employment decline alongside it,
  identifying the income channel through which drought later surfaces in household finances."

### 3. "raise … insurance premiums" — no coherent ACA pass-through (Row 8; and Row 24 for debt)
- **Submitted (¶1, long):** "… cold and drought raise medical debt and insurance premiums one
  to two years out, operating through a household income channel …"
  **Short version:** "… cold and drought raise medical debt and premiums at a one- to two-year
  lag, through a household income channel."
- **Issue:** The completed premium mediation shows **no coherent local pass-through**:
  benchmark-premium coefficients flip sign across county, rating-area, and state levels;
  within-state responses are bounded below ~7–8% of the mean premium; and 92–99% of each
  shock's debt response survives premium adjustment. The bound is hazard-split (strong for
  drought, softer for heat/cold). Separately, credit-bureau medical debt is
  measurement-fragile, not a clean welfare outcome (Row 24).
- **Suggested (long):** "… cold and drought raise a measurement-fragile medical-debt margin one
  to two years out, operating through a household income channel rather than systemic health
  spending, while ACA premiums show no coherent local pass-through of the shock."
- **Suggested (short):** "… cold and drought register in a lagged, measurement-fragile
  medical-debt margin through a household income channel, while ACA premiums show no coherent
  local pass-through."

### 4. "not mediated by migration" — drought scar is partly out-migration (Rows 16, 19)
- **Submitted (¶3, long):** "These findings survive adjustment for humidity, are not mediated
  by migration or population aging, and hold under stricter extreme-temperature thresholds."
- **Issue:** True for the cold-compounding result, but part of the **drought debt scar** is
  composition — drought raises net out-migration the following year (suggestive, p≈0.05), so
  the scar is a lower bound on same-population loss.
- **Suggested:** "The cold-compounding result survives adjustment for humidity and population
  aging and holds under stricter thresholds; part of the drought scar, by contrast, reflects
  out-migration selection, so it is a lower bound on same-population loss."

### 5. Cold-compounding magnitude — name the estimator (Row 17)
- **Submitted (¶3):** "cold employment losses compound (the tenth cumulative cold-year costs
  roughly 5,700 more jobs than the first, echoed by a staggered difference-in-differences)"
- **Issue:** The ~5,700 figure is the **unweighted 10+ vs 1–3 binned contrast**; the smooth
  quadratic dose term is flat, and the population-weighted binned contrast is much larger. The
  claim is estimator-dependent and should name the estimator.
- **Suggested:** "cold employment losses compound (in an unweighted binned contrast the tenth
  cumulative cold-year costs roughly 5,500 more jobs than the first, echoed by a
  Callaway–Sant'Anna employment gap widening to about 5,000 jobs a decade after onset)."
  *(Magnitude updated 2026-07-13 to the certified post-dedup value, −5,522.)*

### 6. Cold-income amplification — flag the marginal interaction (Row 20)
- **Submitted (¶4):** "… extreme heat costs jobs, cold's income loss is several times larger,
  and drought raises premiums …"
- **Issue:** Directionally correct, but the cold-income × SVI interaction is only marginal
  (p=0.056); the heat-employment and drought-premium interactions are the firmer amplification
  results.
- **Suggested:** "… extreme heat turns a small employment gain into a loss, cold's income loss
  is several times larger (a marginal interaction), and drought pushes benchmark premiums up …"

---

## No change needed (verified consistent with the evidence table)

- The overall three-part thesis (incidence / persistence / inequality) and the closing
  argument are intact.
- "credit-bureau medical debt proves a measurement-fragile outcome" (¶4) is consistent with
  Row 24.
- "drought debt scars and does not unwind on exit" and "heat saturates into a standing level
  difference" (¶3) are consistent with Rows 16 and 18.
- The panel description, methods list, and the person-years exposure framing are unaffected.

---

## Author decision required

Whether to notify the conference at all depends on the venue and stage. If the abstract is
already in a printed program, the cleanest path is a corrected version in the slides/paper
rather than a program erratum. Amendments 1 (Midwest), 3 (premiums), and 4 (migration) are the
substantive ones a discussant could otherwise flag; 2, 5, and 6 are precision fixes.
