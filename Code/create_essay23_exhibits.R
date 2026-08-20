# =============================================================================
# create_essay23_exhibits.R  (thesis_completion_20260704 — Essays 2 and 3)
# =============================================================================
# Typesets the nine exhibits that Essays 2 and 3 cite but that existed only as
# analysis CSVs, so the combined submission stops showing placeholder boxes:
#
#   E2-T1  Analysis/delta/transition_table.{csv,tex}          episode counts by hazard
#   E2-T3  Analysis/delta/symmetry_table.{csv,tex}            onset/exit symmetry tests
#   E3-T1  Analysis/mechanism/moderator_correlations.{csv,tex}
#   E3-T2  Analysis/exposure_index/svi_marginal_effects.{csv,tex}
#   E3-T3  Analysis/mechanism/horserace_table.{csv,tex}
#   E3-T4  Analysis/hospital/safetynet_table.{csv,tex}
#   E3-T5  Analysis/latent_hardship/visibility_gradients.{csv,tex}
#   E3-T6  Analysis/policy/concentration_table.{csv,tex}
#   (E3-F6 already exists as Analysis/policy/fig_concentration_lorenz.png and
#    only needed wiring into the renderer.)
#
# Every number is READ from the committed analysis output. Where a source grid
# is larger than a manuscript table should be, the rows the essays actually
# discuss are selected and the note says the full grid lives in the analysis
# outputs -- nothing is recomputed or retyped.
#
# ENV: R 4.5.2.  Rscript Code/create_essay23_exhibits.R
# =============================================================================

suppressPackageStartupMessages({ library(dplyr) })
source("Code/create_data_source_tables.R", local = TRUE)  # write_tex_table, sig3, sig_p, P, RX

rd <- function(p) { if (!file.exists(p)) stop("missing input: ", p); read.csv(p, check.names = FALSE) }

# Pretty hazard labels used across both essays.
HAZ <- c(Drought = "Extreme drought", Heat = "Extreme heat", Cold = "Extreme cold",
         CDD = "Extreme heat", HDD = "Extreme cold", AQI = "Poor air quality",
         drought = "Extreme drought", heat = "Extreme heat", cold = "Extreme cold")
OUT_LAB <- c(Medical_Debt_Share = "Medical debt share",
             PCPI_Real = "Per-capita income",
             Civilian_Employed = "Civilian employment",
             Med_HH_Income_Real = "Median household income",
             Benchmark_Silver_Real = "Benchmark premium",
             Hosp_UncompCare_PctNPR = "Uncompensated care (% of net patient revenue)",
             Hosp_OperatingMargin = "Operating margin",
             Hosp_BadDebt_PerCapita = "Hospital bad debt per capita")
lab <- function(x, map) ifelse(is.na(map[as.character(x)]), as.character(x), map[as.character(x)])

# The exposure-index output keys its shocks by the panel column name rather than
# by hazard, and it carries lag and cumulative-dose variants the other families
# do not. Those raw names (Heat_CDD, Drought_Lag2, ...) are pipeline internals
# and must never reach a printed table, so they get their own label map and an
# explicit print order.
EI_SHOCK <- c(Heat_CDD = "Extreme heat",
              Cold_HDD = "Extreme cold",
              Cold_CumYears = "Cumulative cold-years",
              Drought = "Extreme drought",
              Drought_Lag2 = "Extreme drought (2-year lag)")
EI_ORDER <- names(EI_SHOCK)

# Likewise for the latent-hardship moderators, which arrive z-scored and
# abbreviated.
LH_MOD <- c(Uninsured_z = "Uninsured share",
            Rurality_z = "Rurality",
            HospAccess_z = "Hospital access",
            SVI_z = "Social vulnerability",
            BaseIncome_z = "Baseline income")
# shock_cell encodes the lag the debt response is measured at.
LH_LAG <- c(cold_L1 = "1-year lag", drought_L2 = "2-year lag",
            heat_L1 = "1-year lag", heat_L0 = "same year")

if (sys.nframe() == 0L) {
  dir.create("Analysis/policy/build_logs", showWarnings = FALSE, recursive = TRUE)
  lc <- file("Analysis/policy/build_logs/create_essay23_exhibits.log", open = "wt")
  sink(lc, split = TRUE); sink(lc, type = "message")
  on.exit({ sink(type = "message"); sink(); close(lc) }, add = TRUE)
  cat("=== Essay 2/3 exhibits ::", format(Sys.time()), "===\n\n")

  # =========================================================================
  # E2-T1 — transition episode counts and support
  # =========================================================================
  ep <- rd("Analysis/delta/transition_episode_counts.csv")
  e2t1 <- data.frame(
    Hazard = lab(ep$hazard, HAZ),
    Onset = vapply(ep$onset, fmt_n, character(1)),
    Persist = vapply(ep$persist, fmt_n, character(1)),
    Exit = vapply(ep$exit, fmt_n, character(1)),
    Calm = vapply(ep$calm, fmt_n, character(1)),
    `County-years` = vapply(ep$county_years, fmt_n, character(1)),
    `Counties` = vapply(ep$counties_ever, fmt_n, character(1)),
    check.names = FALSE, stringsAsFactors = FALSE)
  write.csv(e2t1, "Analysis/delta/transition_table.csv", row.names = FALSE)
  write_tex_table(e2t1, "Analysis/delta/transition_table.tex",
    align = paste0(RX, " r r r r r r"),
    caption = "Transition episodes by hazard, county panel 2011--2023",
    label = "tab:e2t1",
    note = paste0(
      "A county-year is classified by its position in an exposure episode: onset ",
      "(first year of a spell), persistence (a continuing spell), exit (the first ",
      "year after a spell ends), or calm. The counts show how much support each ",
      "transition has, which is what limits the horizons the dynamic estimates can ",
      "reach: drought spells are rare and short, while heat spells persist."))
  cat("wrote E2-T1 transition_table —", nrow(e2t1), "hazards\n")

  # =========================================================================
  # E2-T3 — onset/exit symmetry tests
  # =========================================================================
  sym <- rd("Analysis/delta/delta_symmetry_test.csv")
  # The essay discusses the h=2 cells for the headline outcomes; the full grid
  # (168 rows across horizons, outcomes and weightings) stays in the output.
  s2 <- sym %>%
    filter(horizon == 2,
           outcome %in% c("Medical_Debt_Share", "PCPI_Real", "Civilian_Employed")) %>%
    arrange(match(shock, c("Drought", "Cold", "Heat")), outcome, weighting)
  e2t3 <- data.frame(
    Hazard = lab(s2$shock, HAZ),
    Outcome = lab(s2$outcome, OUT_LAB),
    Weighting = s2$weighting,
    `Onset` = vapply(s2$beta_onset, sig3, character(1)),
    `Exit` = vapply(s2$beta_exit, sig3, character(1)),
    `Asymmetry` = vapply(s2$asymmetry, sig3, character(1)),
    `p` = vapply(s2$p.value, sig_p, character(1)),
    `Rejected` = ifelse(s2$reject_symmetry, "yes", "no"),
    check.names = FALSE, stringsAsFactors = FALSE)
  write.csv(e2t3, "Analysis/delta/symmetry_table.csv", row.names = FALSE)
  write_tex_table(e2t3, "Analysis/delta/symmetry_table.tex",
    align = paste0(P(2.4), " ", RX, " ", P(2.1), " r r r r r"),
    fontsize = "\\scriptsize",
    caption = "Onset--exit symmetry tests at a two-year horizon",
    label = "tab:e2t3",
    note = paste0(
      "Symmetry requires that the effect of entering a shock state and the effect ",
      "of leaving it offset one another, so that their sum is zero. The asymmetry ",
      "column reports that sum; a value reliably different from zero means the ",
      "outcome does not return to its pre-shock path when the shock ends. ",
      "Estimates at other horizons and for the remaining outcomes are reported in ",
      "the analysis output."))
  cat("wrote E2-T3 symmetry_table —", nrow(e2t3), "cells\n")

  # =========================================================================
  # E3-T1 — moderator correlation matrix
  # =========================================================================
  mc <- rd("Analysis/mechanism/horserace_modcorr.csv")
  nm <- c(EnergyBurden_z = "Energy burden", Ag_z = "Farm earnings share",
          Labor_z = "Climate-exposed non-farm share", SVI_z = "Social vulnerability",
          baseline_CDD_z = "Baseline climate (cooling degree days)")
  rown <- mc[[1]]
  vals <- mc[, -1, drop = FALSE]
  e3t1 <- data.frame(Moderator = paste0("(", seq_along(rown), ") ", lab(rown, nm)),
                     stringsAsFactors = FALSE)
  for (k in seq_along(names(vals))) {
    j <- names(vals)[k]
    e3t1[[paste0("(", k, ")")]] <- vapply(vals[[j]], function(z) sig3(z), character(1))
  }
  write.csv(e3t1, "Analysis/mechanism/moderator_correlations.csv", row.names = FALSE)
  write_tex_table(e3t1, "Analysis/mechanism/moderator_correlations.tex",
    align = paste0(RX, " r r r r r"), fontsize = "\\small",
    caption = "Correlations among the county moderators",
    label = "tab:e3t1",
    note = paste0(
      "Pairwise correlations across counties. The moderators are related but not ",
      "interchangeable: energy burden and social vulnerability correlate only ",
      "weakly, which is why the two are treated as separate distributional ",
      "dimensions rather than one."))
  cat("wrote E3-T1 moderator_correlations —", nrow(e3t1), "moderators\n")

  # =========================================================================
  # E3-T2 — marginal effects across the vulnerability distribution
  # =========================================================================
  ei <- rd("Analysis/exposure_index/exposure_interaction_coefs.csv")
  e3 <- ei %>%
    filter(outcome %in% c("PCPI_Real", "Civilian_Employed", "Med_HH_Income_Real",
                          "Benchmark_Silver_Real", "Medical_Debt_Share")) %>%
    arrange(match(shock, EI_ORDER), outcome)
  stopifnot(all(e3$shock %in% EI_ORDER))   # no raw column name may reach print
  e3t2 <- data.frame(
    Group = lab(e3$shock, EI_SHOCK),
    Outcome = lab(e3$outcome, OUT_LAB),
    `Less vulnerable (25th pct.)` = vapply(e3$me_lowSVI, sig3, character(1)),
    `p` = vapply(e3$me_lowSVI_p, sig_p, character(1)),
    `More vulnerable (75th pct.)` = vapply(e3$me_highSVI, sig3, character(1)),
    `p ` = vapply(e3$me_highSVI_p, sig_p, character(1)),
    `Difference, p` = vapply(e3$p_interaction, sig_p, character(1)),
    check.names = FALSE, stringsAsFactors = FALSE)
  write.csv(e3t2, "Analysis/exposure_index/svi_marginal_effects.csv", row.names = FALSE)
  write_tex_table(e3t2, "Analysis/exposure_index/svi_marginal_effects.tex",
    align = paste0(RX, " r r r r r"), group_col = "Group", fontsize = "\\scriptsize",
    caption = "Marginal effect of each hazard at low and high social vulnerability",
    label = "tab:e3t2",
    note = paste0(
      "Each cell is the effect of the hazard on the outcome, evaluated at the 25th ",
      "percentile of the county social-vulnerability distribution (less vulnerable) ",
      "and at the 75th (more vulnerable); the final column gives the p-value on the ",
      "shock-by-vulnerability interaction, which tests whether the two differ. ",
      "Units follow the outcome: dollars per year for per-capita and median ",
      "household income, dollars per month for the benchmark premium, persons for ",
      "employment, and share of adults for medical debt. County and year fixed ",
      "effects throughout, with standard errors clustered by state. Medical debt ",
      "runs opposite to the other ledgers; it is read as a statement about what the ",
      "credit-bureau record captures, not about where hardship falls."))
  cat("wrote E3-T2 svi_marginal_effects —", nrow(e3t2), "cells\n")

  # =========================================================================
  # E3-T3 — moderator horse race
  # =========================================================================
  hr <- rd("Analysis/mechanism/horserace_coefs.csv")
  TERM <- c("High_CDD:EnergyBurden_z" = "Heat x energy burden",
            "High_CDD:Labor_z" = "Heat x exposed non-farm share",
            "High_CDD:Ag_z" = "Heat x farm earnings share",
            "High_CDD:SVI_z" = "Heat x social vulnerability",
            "High_CDD:baseline_CDD_z" = "Heat x baseline climate")
  SPEC <- c(full_joint = "All moderators jointly",
            minimal_EB_vs_SVI_climate = "Energy burden vs vulnerability and climate",
            eb_alone = "Energy burden alone")
  h3 <- hr %>% filter(outcome == "log_emp", term %in% names(TERM)) %>%
    arrange(match(spec, names(SPEC)), match(term, names(TERM)))
  e3t3 <- data.frame(
    Group = unname(SPEC[h3$spec]),
    Interaction = unname(TERM[h3$term]),
    Estimate = vapply(h3$estimate, sig3, character(1)),
    `Std. error` = vapply(h3$se, sig3, character(1)),
    `p` = vapply(h3$p, sig_p, character(1)),
    N = vapply(h3$n, fmt_n, character(1)),
    check.names = FALSE, stringsAsFactors = FALSE)
  write.csv(e3t3, "Analysis/mechanism/horserace_table.csv", row.names = FALSE)
  write_tex_table(e3t3, "Analysis/mechanism/horserace_table.tex",
    align = paste0(RX, " r r r r"), group_col = "Group", fontsize = "\\small",
    caption = "Which county characteristic carries the heat--employment gradient?",
    label = "tab:e3t3",
    note = paste0(
      "Outcome is log employment; each moderator is a z-score, so a coefficient is ",
      "the change in the heat response per standard deviation of that moderator ",
      "within a shock year. Running the moderators against one another asks which ",
      "survives when the others are allowed to compete for the same variation."))
  cat("wrote E3-T3 horserace_table —", nrow(e3t3), "rows\n")

  # =========================================================================
  # E3-T4 — safety-net hospital heterogeneity
  # =========================================================================
  hh <- rd("Analysis/hospital/hospital_heterogeneity_coefs.csv")
  h4 <- hh %>% filter(moderator == "SafetyNet") %>%
    arrange(outcome, shock, level)
  e3t4 <- data.frame(
    Outcome = lab(h4$outcome, OUT_LAB),
    Hazard = lab(gsub("^Is_Extreme_|^High_", "", h4$shock), HAZ),
    `Status` = ifelse(h4$level == "1", "Safety net", "Other hospitals"),
    Estimate = vapply(h4$estimate, sig3, character(1)),
    `p` = vapply(h4$p.value, sig_p, character(1)),
    `Int. p` = vapply(h4$interaction_p, sig_p, character(1)),
    check.names = FALSE, stringsAsFactors = FALSE)
  write.csv(e3t4, "Analysis/hospital/safetynet_table.csv", row.names = FALSE)
  write_tex_table(e3t4, "Analysis/hospital/safetynet_table.tex",
    align = paste0(RX, " ", P(2.4), " ", P(2.5), " r r r"), fontsize = "\\scriptsize",
    caption = "Hospital responses by safety-net status",
    label = "tab:e3t4",
    note = paste0(
      "Hospital-year panel with hospital and year fixed effects and state-clustered ",
      "standard errors. Safety-net status is a top-quartile flag on Medicaid and ",
      "uncompensated payer mix. Exposure is measured at the location of the ",
      "hospital rather than the residence of its patients, which understates ",
      "exposure for hospitals drawing from a wide catchment."))
  cat("wrote E3-T4 safetynet_table —", nrow(e3t4), "rows\n")

  # =========================================================================
  # E3-T5 — debt visibility gradients
  # =========================================================================
  lh <- rd("Analysis/latent_hardship/latent_hardship_gradients.csv")
  # Each (hazard, moderator) pair is estimated under BOTH weightings. Earlier
  # builds dropped the weighting column, so the table printed six pairs of
  # visually identical rows carrying different numbers. Keep the column.
  l5 <- lh %>% filter(outcome_family == "primary", moderator_family == "primary") %>%
    arrange(shock, moderator, weighting)
  e3t5 <- data.frame(
    Group = paste0(lab(l5$shock, HAZ), ", ", lab(l5$shock_cell, LH_LAG)),
    Moderator = lab(l5$moderator, LH_MOD),
    Weighting = ifelse(l5$weighting == "population", "Population", "Unweighted"),
    `Debt response` = vapply(l5$main_effect, sig3, character(1)),
    `p` = vapply(l5$main_p, sig_p, character(1)),
    `Per SD of moderator` = vapply(l5$interaction, sig3, character(1)),
    `p ` = vapply(l5$p_interaction, sig_p, character(1)),
    `q` = vapply(l5$q_bky, sig_p, character(1)),
    check.names = FALSE, stringsAsFactors = FALSE)
  stopifnot(!any(duplicated(e3t5[, c("Group", "Moderator", "Weighting")])))
  write.csv(e3t5, "Analysis/latent_hardship/visibility_gradients.csv", row.names = FALSE)
  write_tex_table(e3t5, "Analysis/latent_hardship/visibility_gradients.tex",
    align = paste0(RX, " ", P(2.1), " r r r r r"), group_col = "Group",
    fontsize = "\\scriptsize",
    caption = "Does measured medical debt respond less where hardship is least visible?",
    label = "tab:e3t5",
    note = paste0(
      "The outcome is the share of adults with medical debt in collections on a ",
      "credit record. `Debt response' is the effect of the hazard at the average ",
      "county; `Per SD of moderator' is how much that response changes for each ",
      "standard deviation increase in the moderator. A negative value there means ",
      "the measured response is SMALLER where the moderator is higher -- the ",
      "pattern predicted if a bill reaches a credit bureau only after passing an ",
      "insurance, a billing and a credit-file filter. Each pair of rows reports the ",
      "same specification population-weighted and unweighted. The q column is a ",
      "false-discovery rate adjusted for testing the whole grid at once; only the ",
      "drought-by-uninsurance cell clears it. Attenuation in the predicted ",
      "direction is necessary but not sufficient evidence for that reading."))
  cat("wrote E3-T5 visibility_gradients —", nrow(e3t5), "rows\n")

  # =========================================================================
  # E3-T6 — burden concentration
  # =========================================================================
  cs <- rd("Analysis/policy/concentration_topshares.csv")
  BAND <- c(cold_cumulative_employment = "Cumulative cold exposure, employment",
            cold_medicare_annual = "Cold, annual Medicare cost",
            heat_medicare_annual = "Heat, annual Medicare cost",
            heat_exposure_personyears_descriptive = "Heat exposure, person-years",
            drought_debt_scar = "Drought debt scar",
            event_2012_income = "2012 drought event, income")
  c6 <- cs %>% arrange(desc(top10_pop_burden_share))
  e3t6 <- data.frame(
    `Burden measure` = lab(c6$band, BAND),
    `Top 10%` = vapply(100 * c6$top10_pop_burden_share, function(z) sig3(z, suffix = "%"), character(1)),
    `Top 20%` = vapply(100 * c6$top20_pop_burden_share, function(z) sig3(z, suffix = "%"), character(1)),
    `Top 50%` = vapply(100 * c6$top50_pop_burden_share, function(z) sig3(z, suffix = "%"), character(1)),
    Counties = vapply(c6$n_counties, fmt_n, character(1)),
    `Uniform` = ifelse(c6$uniform_per_capita, "yes", "no"),
    check.names = FALSE, stringsAsFactors = FALSE)
  write.csv(e3t6, "Analysis/policy/concentration_table.csv", row.names = FALSE)
  write_tex_table(e3t6, "Analysis/policy/concentration_table.tex",
    align = paste0(RX, " r r r r r"), fontsize = "\\small",
    caption = "Share of measured burden borne by the most vulnerable population",
    label = "tab:e3t6",
    note = paste0(
      "Counties are ordered from most to least socially vulnerable, and each ",
      "column reports the share of the total measured burden borne by that ",
      "fraction of the national population. A burden spread evenly across people ",
      "would read 10 percent, 20 percent and 50 percent across the three columns; ",
      "figures above those benchmarks mean the burden concentrates on the more ",
      "vulnerable. Rows flagged as uniform per capita are built with a constant ",
      "per-person burden and therefore sit on the benchmark by construction -- ",
      "they are a reference line, not a finding."))
  cat("wrote E3-T6 concentration_table —", nrow(e3t6), "bands\n")

  cat("\n=== done ===\n")
}
