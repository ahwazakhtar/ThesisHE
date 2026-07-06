---
name: nber-economist-writing-style
description: Write or revise academic economics prose in the style of a modern NBER working paper (applied micro / climate-health econometrics). Use this when the user asks to draft, rewrite, or polish thesis sections, abstracts, introductions, results narratives, or conclusions "in NBER style" or "like an economist." Modeled on Aguilar-Gomez, Graff Zivin & Neidell (2025), NBER WP 33491, "Hot and Crowded."
allowed-tools: Read, Write, Edit, Glob, Grep
---

Write applied-economics prose in the voice of a modern NBER working paper. This style guide was reverse-engineered from `Text/reference/w33491.pdf` (Aguilar-Gomez, Graff Zivin & Neidell 2025) — a climate-health econometrics paper that is a close cousin of this thesis. Annotated sentence-level exemplars live in `reference/exemplars.md`; read that file when you need concrete models to imitate.

## When to apply

Drafting or revising: the abstract, introduction, empirical-methodology section, results narrative, or conclusion of a paper or thesis chapter. The goal is prose that a referee at *AEJ: Applied* or *JAERE* would recognize as house style — confident but hedged, quantitative, mechanism-driven.

---

## The core voice (non-negotiables)

1. **First-person plural, active, present tense.** "We find," "we estimate," "we provide the first exploration of…" Results are stated in the present: "higher temperatures increase ED visits," not "increased." Reserve past tense for what you *did* procedurally ("we linked health data to weather data").

2. **Every number is anchored to a baseline.** Never report a raw coefficient without translating it into an interpretable magnitude. The template is: *effect size → baseline → percent*. E.g. "an additional 3 ED visits compared to the number under 22–24°C. From a mean of approximately 40 daily visits, this translates to a 6.9% increase." A coefficient with no `From a mean of…` clause is a defect.

3. **Causal claims are hedged, mechanism claims doubly so.** Use a graded vocabulary: *increase / raise* (for the estimated effect) → *suggests / indicates / points to / is consistent with / appears to operate through* (for interpretation) → *the most plausible explanation is* (for mechanism). Never write "proves" or "causes X" bare. "Congestion is the most plausible explanation for our main results" is the ceiling of confidence.

4. **Anticipate and disarm the alternative explanation.** The signature move of this literature: state your finding, then immediately raise the competing story, then show data that rules it out. "While our findings thus far are consistent with congestion, this pattern could also arise due to changes in the composition of patients… Fortunately, we can examine this directly by utilizing a standard severity measure. In fact, we find that severity increases with temperature." Structure: *consistent-with-X → but-could-be-Y → fortunately-we-can-test → in-fact-the-data-say-X*.

5. **Prose is signposted like a proof.** Open paragraphs with transition phrases that tell the reader where they are in the argument: "To begin," "Turning to hospital visits," "The gap between ED and hospital admissions motivates a deeper investigation," "The final piece of the puzzle is," "Taken together, these results suggest," "In contrast," "By contrast."

6. **State what happened plainly; skip the epigram.** The original never uses the punchy antithetical construction — no "X is a bound, not a decomposition," no "a contributor, not the generator," no "the sharpest refutation is…". It simply reports the result and lets the number carry the weight. Verified against the source: *zero* "X, not Y" epigrams in 30 pages. The only contrastive form it permits is **"rather than,"** used **3 times total**, and always for a *substantive mechanism* contrast the data actually adjudicate ("the rise in deaths reflects higher utilization **rather than** greater severity"; "congestion **rather than** direct heat exposure") — never for a rhetorical antithesis about the paper's own framing or contribution. If you catch yourself writing "A, not B" to sound decisive, delete it and state A. Avoid unnecessary comparisons generally: don't rank your own result ("the most cleanly identified result in the project"), don't dramatize the alternative ("the naive story"), don't editorialize the stakes. Report; don't sell.

---

## Document architecture

| Section | Convention |
|---|---|
| **Abstract** | 5–7 sentences, no citations. Order: (1) the phenomenon/stakes, (2) data + identification in one clause, (3) headline quantitative result with %, (4) the mechanism/second result, (5) the interpretive takeaway ("These results identify … as an important margin of adaptation"). |
| **Introduction** | Unnumbered. A funnel — see below. |
| **Numbered body** | `1 Background and data`, `2 Empirical methodology`, `3 Results` (with `3.1`, `3.2`…), `4 Conclusion`. Section titles are plain topic labels here, *not* declarative claims (that's a slides convention, not a paper convention). |
| **Conclusion** | Restate what you did + headline numbers, offer a **back-of-the-envelope** projection to give the magnitudes stakes, then policy implications and one forward-looking "important focus for future research" sentence. |
| **Footnotes** | Heavily used for: data caveats, "results available upon request," robustness asides, institutional detail, and defusing objections that would derail the main text. Push anything that interrupts the argument's momentum into a footnote. |

### The introduction funnel (imitate this arc precisely)

1. **Broad phenomenon, with citations.** "Extreme heat imperils health, increasing both morbidity and mortality (Deschenes, 2014; Basu, 2009)…"
2. **The gap / unexplored channel.** "In this paper, we provide the first exploration of … that unpacks the direct from the indirect effects."
3. **Why it matters now.** Tie to policy/climate stakes: "Understanding these impacts matters because … climate change will make those shocks far more common."
4. **Setting and why it's the right lab.** "Our empirical work focuses on Mexico … This setting is particularly relevant because…"
5. **Data + design, compactly.** "Our primary analysis covers nearly 57% of the population over an 8-year period… we estimate distributed lag models … with facility fixed effects."
6. **Results walkthrough.** Signal it: "Our analyses reveal a series of interesting, interconnected results. To begin, we find…" Then march through each finding *with its number*, in the order the paper will present them.
7. **Contribution to the literature.** "Our paper builds upon the extensive literature on … (see reviews by …) to reveal a new channel." Name the 2–3 closest papers and say exactly how you extend them: "We extend this work by broadening our purview to…"

---

## Sentence-level craft

- **Declarative topic sentences.** Each paragraph's first sentence makes a claim the rest of the paragraph supports.
- **Parenthetical citations**, author-year: `(White, 2017)`, `(Barreca et al., 2016)`. Use `(e.g., White, 2017)` when illustrative, `(see reviews by X, Y)` for literatures.
- **Numbers:** spell out as "6.9 percent" / "5.2 percent" in running prose; use `%`, `°C`, and symbols like `∼` freely inside parentheticals, figures, and tighter passages. Be consistent within a passage.
- **Tasteful economist idiom, rare and confined to the frame.** The *entire* source paper contains about four figurative flourishes, all single metaphors, and they cluster in the introduction's opening line and the conclusion — "imperils health," "this pernicious threat … comes with a silver lining," "a novel arrow … in the rather limited quiver of climate adaptation tools," plus one "the final piece of the puzzle" as a body signpost. The results narrative itself carries *none*. So: at most one or two metaphors in a whole document, placed in the intro or conclusion, never in a results paragraph, and never an antithesis ("X, not Y") dressed up as an idiom.
- **Precise institutional/data detail** builds credibility: "1,865,622 ED-days," "916 EDs and 857 hospitals," "up to 6 secondary diagnoses." Don't round away the texture.
- **"Taken together"** is the standard connective for synthesizing multiple results into one conclusion.
- Avoid: the antithetical epigram ("A, not B" — see non-negotiable 6); self-ranking ("the most cleanly identified result," "the sharpest refutation"); dramatizing the counter-story ("the naive story," "the competing story holds…"); adverbial hype ("dramatically," "strikingly"); and unhedged mechanism claims. Rhetorical questions are allowed *only* as a deliberate section pivot ("What happens to these extra patients?").

---

## Methodology-section register

Write the empirical strategy as a defense, not a recipe. State the estimator, then *why it's the right one* with a citation: "we estimate a Poisson pseudo-maximum likelihood model (PPML). The PPML point estimates are consistent as long as the conditional mean is correctly specified … (Gourieroux et al., 1984)." Present the equation, define every symbol in a sentence immediately after, then state the **identification assumption** explicitly and in plain language: "The identification assumption is that after accounting for annual trends and seasonality, the remaining fluctuations in daily temperature within a given facility are exogenous." Close with the clustering choice and its justification.

---

## Workflow when invoked

1. If revising existing text, Read it first and diagnose which non-negotiables it violates (usually: unanchored numbers, unhedged causality, no signposting, buried topic sentence).
2. Consult `reference/exemplars.md` for a same-purpose model sentence (abstract line, intro-funnel step, results-anchor, mechanism-disarm, conclusion BOTE).
3. Rewrite. Preserve the author's actual findings and numbers exactly — style is the target, not the substance. Never invent data, citations, or magnitudes; if a number or reference is needed and absent, flag it with `[TK: …]` rather than fabricate.
4. Match citation format to whatever the surrounding document already uses (BibTeX keys, `\citep`, etc.) — check the `.tex` source before imposing author-year.
