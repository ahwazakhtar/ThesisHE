# Annotated exemplars — NBER economist writing style

Model sentences lifted from Aguilar-Gomez, Graff Zivin & Neidell (2025), NBER WP 33491, "Hot and Crowded." Each is paired with the *move* it executes. Imitate the move, not the content.

---

## Abstract (the whole thing, annotated)

> **[stakes]** Extreme heat raises emergency demand and may increase mortality through hospital congestion when shocks hit many people at once. **[data + design in one clause]** Using administrative records from Mexico's largest public health system, we separate direct heat effects from congestion spillovers. **[headline result, quantified]** Days with maximum temperature above 34°C increase ED visits by 6.9 percent and hospitalizations by 4.2 percent, with sicker ED patients discharged home more often. **[second result / mechanism]** In-hospital deaths rise for already-admitted patients, suggesting important spillover effects, and deaths disproportionately increase outside hospitals. **[takeaway framed as a contribution]** These results identify health-system capacity as an important margin of adaptation to extreme heat.

Seven sentences, zero citations, every claim quantified or mechanistic.

---

## Intro-funnel steps

**Broad phenomenon + citations:**
> Extreme heat imperils health, increasing both morbidity and mortality (Deschenes, 2014; Basu, 2009), and results in more emergency room visits and hospitalizations (e.g., Gould et al., 2024; White, 2017).

**The gap / "first to":**
> In this paper, we provide the first exploration of the health impacts from extreme heat that unpacks the direct from the indirect effects that arise due to hospital congestion.

**Why it matters now:**
> Understanding these impacts matters because, unlike idiosyncratic shocks to healthcare demand, we know that climate change will make those shocks associated with extreme heat far more common.

**Setting justification:**
> This setting is particularly relevant because evidence on the relationship between extreme heat and health in developing countries remains limited (Sapari et al., 2024).

**Results-walkthrough opener:**
> Our analyses reveal a series of interesting, interconnected results. To begin, we find that higher temperatures increase ED and hospital admissions.

**Contribution framing:**
> Our paper builds upon the extensive literature focused on the health impacts of climate change (see reviews by Basu, 2009; Ye et al., 2012) to reveal a new channel through which those impacts may arise. … We extend this work by broadening our purview to spillovers between EDs and the entire hospital system.

---

## The number-anchoring template (use every time)

> When the daily maximum temperature reaches the highest bin of >34°C, we estimate an additional 3 ED visits compared to the number under 22–24°C. From a mean of approximately 40 daily visits, this translates to a 6.9% increase.

Pattern: **effect (in natural units) → reference/baseline → "From a mean of X, this translates to Y%."**

> we estimate a .35 percentage point decrease in the probability of being admitted to the hospital. This amounts to a ∼3% decrease from the baseline hospitalization rate of 12%.

---

## The disarm-the-alternative move (signature)

> While our findings thus far are consistent with congestion, this pattern of results could also arise due to changes in the composition of patients on extreme heat days. If, for example, less-sick patients show up to the ED on hot days, it is perfectly reasonable for EDs to admit fewer patients. Fortunately, we can examine this directly by utilizing a standard severity of illness measure (Hoe, 2022). In fact, we find that the severity of illness of patients in the ED increases with temperature.

Structure: **consistent-with-X → but-could-be-Y → "Fortunately, we can examine this directly" → "In fact, we find" X.** End the paragraph with the verdict: "Congestion is the most plausible explanation for our main results."

---

## Signposting connectives (steal these verbatim)

- "To begin, we find…"
- "Turning to hospital visits in Panel (b)…"
- "The gap between ED and hospital admissions motivates a deeper investigation of…"
- "The final piece of the puzzle is estimating the impacts of this congestion."
- "Taken together, these results suggest that…"
- "By contrast, while those admitted … are among the sickest, they are no more infirm than…"
- "What happens to these extra patients? We investigate this question using…" (deliberate rhetorical pivot)

---

## Hedging ladder (pick the rung that matches your evidence)

| Confidence | Phrasing |
|---|---|
| The estimate itself | "increases," "raises," "leads to," "we estimate" |
| Interpretation | "suggesting," "indicating," "this implies," "consistent with," "appears to operate through," "points to" |
| Mechanism verdict | "the most plausible explanation," "the pattern points to X as a key mechanism" |
| Honest limit | "While we cannot rule out other explanations, our results are consistent with…" |

---

## What the original does NOT do (verified against the source text)

The register is *plainer* than a first imitation tends to make it. Grep evidence from the full paper:

- **Antithetical epigrams ("X, not Y"): 0 occurrences.** The paper never writes "a contributor, not the generator" or "a bound, not a decomposition." It states the finding and stops.
- **"rather than": exactly 3 occurrences**, all for a *substantive mechanism* contrast the data resolve — never for framing:
  > the rise in deaths reflects higher utilization **rather than** greater severity among new admits
  > additional deaths are largely due to spillovers … **rather than** direct heat exposure
  > the increase in total deaths reflects higher utilization **rather than** a detectable increase in mortality risk
- **Figurative flourishes: ~4 in the whole paper**, all single metaphors, all in the intro's first line or the conclusion — "imperils," "silver lining," "quiver," and one body signpost "the final piece of the puzzle." None appear in a results paragraph.

**So when revising, delete these tics (they read as trying-too-hard, not as house style):**

| Don't write | Write instead |
|---|---|
| "Agriculture is a contributor, not the generator." | "The agricultural channel is real but narrow / event-specific." |
| "Migration and selection are a bound, not a decomposition." | "I report migration as a bound on the scarring interpretation." |
| "The sharpest refutation is a channel with no farm-income intermediary." | "The Medicare data measure cost directly, with no farm-income intermediary." |
| "the most cleanly identified result in the project" | (cut the ranking; just report the result and its p-values) |
| "The competing story holds that everything runs through farm income." | "One explanation is that the effect runs through farm income. To examine this, I …" |

The disarm-the-alternative move (non-negotiable 4) still applies — but state the alternative neutrally and let the test do the talking, exactly as the source does ("If, for example, less-sick patients show up… Fortunately, we can examine this directly"). No adjectives on the rival story.

## Methodology register

> we estimate a Poisson pseudo-maximum likelihood model (PPML). The PPML point estimates are consistent as long as the conditional mean is correctly specified, irrespective of the distribution of the outcome or errors (Gourieroux et al., 1984). PPML models also readily accommodate fixed effects without an incidental parameters problem (Correia et al., 2019).

**Identification assumption, stated plainly:**
> The identification assumption is that after accounting for baseline factors such as annual trends and seasonality, the remaining fluctuations in daily temperature within a given facility are exogenous.

**Clustering, justified:**
> We cluster standard errors at the municipality level to allow for these features [assignment of temperature at that level and serial correlation within municipalities].

---

## Conclusion moves

**Restate + headline number:**
> An extra day at which the maximum temperature exceeds 34°C leads to a 4.9% increase in mortality among patients already admitted to the hospital, and a 6% increase in deaths at home. Our results are robust to various assumptions, including varying lag structures, using wet-bulb temperature … and excluding patients with heat-related diagnoses.

**Back-of-the-envelope for stakes:**
> To place these numbers in a broader context, we offer a simple back-of-the-envelope calculation… Under a high-emission pathway, we project that the Mexican territory in 2050 will experience an annual average increase of 33 days with temperatures exceeding 34°C… By 2050, ED visits are projected to rise by 6%.

**Policy + one idiom + future research:**
> This pernicious threat from extreme heat comes with a silver lining. Increasing capacity in the healthcare system is a novel arrow that can be added to the rather limited quiver of climate adaptation tools. … Quantifying the marginal value of these inputs across contexts is therefore an important focus for future research.
