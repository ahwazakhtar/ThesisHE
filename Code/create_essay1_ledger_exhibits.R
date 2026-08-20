# =============================================================================
# create_essay1_ledger_exhibits.R  (thesis_completion_20260704 — Essay 1)
# =============================================================================
# Builds the four Essay-1 exhibits that were cited in the draft but had no
# typeset artifact, so the submission render stops showing placeholder boxes:
#
#   E1-T2  Analysis/did/cohort_balance_table.{csv,tex}
#          2012 first-onset cohort vs never-exposed: pre-treatment (2011) means,
#          difference, and normalized difference for the covariates the design
#          leans on. COMPUTED here — no balance table existed anywhere.
#
#   E1-T6  Analysis/mechanism/medicare_table.{csv,tex}
#          Medicare spending and ED-visit responses by hazard and lag, each
#          anchored to its own baseline (the NBER percent-of-mean convention).
#
#   E1-T7  Analysis/mediation/ledger_comparison.{csv,tex}
#          One row per institutional ledger: the estimated response, the
#          ledger's own baseline, and the response as a share of that baseline.
#
#   E1-F5  Analysis/mediation/fig_institutional_ledgers.png
#          The registry's deferred figure. It was deferred because cross-ledger
#          standardisation had no agreed units; the convention adopted here is
#          "effect as a percent of that ledger's own mean", which is what makes
#          a dollar premium, a debt share, and an ED-visit rate comparable.
#
# PROVENANCE RULE: every number is read from a committed output or estimated
# here from the master panel. Two cells could NOT be sourced either way and are
# handled explicitly rather than transcribed from prose (see VERIFY block):
#   - Row 4's "county mirror +1.2 pp (p<0.001)" for cold->debt at lag 1
#   - Row 5's "county +0.54 pp (p<0.01)" for drought->debt at lag 2
# Both are re-estimated below as the county mirror of the state specification,
# and the RE-ESTIMATED values (with their true p-values) are what the exhibits
# report. The script prints a comparison so the divergence is visible at build.
#
# ENV: R 4.5.2.  Rscript Code/create_essay1_ledger_exhibits.R
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(fixest); library(ggplot2)
})

source("Code/create_data_source_tables.R", local = TRUE)  # write_tex_table, P, RX

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

# Delegates to sig_p() so the "<0.001" floor is written the one way that
# survives tex_escape(); this local copy used to emit math delimiters, which
# were then escaped into literal dollar signs in every table it touched.
fmt_p <- function(p) sig_p(p)
fmt_est <- function(x, d = 2, unit = "") paste0(formatC(x, format = "f", digits = d,
                                                        big.mark = ","), unit)

if (sys.nframe() == 0L) {
  for (dd in c("Analysis/did", "Analysis/mechanism", "Analysis/mediation")) {
    dir.create(file.path(dd, "build_logs"), showWarnings = FALSE, recursive = TRUE)
  }
  lc <- file("Analysis/mediation/build_logs/create_essay1_ledger_exhibits.log", open = "wt")
  sink(lc, split = TRUE); sink(lc, type = "message")
  on.exit({ sink(type = "message"); sink(); close(lc) }, add = TRUE)
  cat("=== Essay 1 ledger exhibits (E1-T2/T6/T7/F5) ::", format(Sys.time()), "===\n\n")

  # ---- panel -------------------------------------------------------------
  cty <- read.csv("Data/county_level_master.csv")
  cty$fips_code <- pad_fips(cty$fips_code)
  panel <- cty %>% filter(Year >= 2011, Year <= 2023) %>%
    distinct(fips_code, Year, .keep_all = TRUE)

  # =========================================================================
  # E1-T2 — 2012 first-onset cohort balance
  # =========================================================================
  # Cohort logic mirrors run_did_analysis.R: treated = first extreme-drought
  # year is 2012; control = zero extreme-drought years over 2011-2023.
  first_ev <- panel %>% filter(!is.na(Is_Extreme_Drought)) %>%
    group_by(fips_code) %>%
    summarise(first_event = suppressWarnings(min(Year[Is_Extreme_Drought == 1])),
              n_events = sum(Is_Extreme_Drought == 1, na.rm = TRUE), .groups = "drop") %>%
    mutate(first_event = ifelse(is.finite(first_event), first_event, NA_integer_),
           cohort = ifelse(is.na(first_event), 0L, as.integer(first_event)))

  treated <- first_ev$fips_code[first_ev$cohort == 2012L]
  control <- first_ev$fips_code[first_ev$cohort == 0L]
  cat(sprintf("cohort: treated=%d, never-exposed=%d\n", length(treated), length(control)))
  if (length(treated) != 139L || length(control) != 2534L) {
    warning("cohort sizes differ from the registered 139/2,534 — check the panel build")
    cat("WARNING: cohort sizes differ from the registered 139 / 2,534\n")
  }

  # Pre-treatment year: 2011 (the 2x2's single pre-period).
  bal_vars <- c(PCPI_Real = "Per-capita income (2023 USD)",
                Civilian_Employed = "Civilian employment",
                Population = "Population",
                Medical_Debt_Share = "Medical debt share",
                Uninsured_Rate = "Uninsured rate",
                Household_Income_2023 = "Median household income (2023 USD)")
  pre <- panel %>% filter(Year == 2011L) %>%
    mutate(grp = ifelse(fips_code %in% treated, "T",
                        ifelse(fips_code %in% control, "C", NA_character_))) %>%
    filter(!is.na(grp))

  bal <- do.call(rbind, lapply(names(bal_vars), function(v) {
    if (!v %in% names(pre)) return(NULL)
    t <- pre[[v]][pre$grp == "T"]; c0 <- pre[[v]][pre$grp == "C"]
    t <- t[!is.na(t)]; c0 <- c0[!is.na(c0)]
    if (!length(t) || !length(c0)) return(NULL)
    # Normalized difference (Imbens-Rubin): diff / sqrt((s_t^2 + s_c^2)/2).
    nd <- (mean(t) - mean(c0)) / sqrt((var(t) + var(c0)) / 2)
    dec <- if (v %in% c("Medical_Debt_Share", "Uninsured_Rate")) 3 else 0
    data.frame(Variable = unname(bal_vars[v]),
               `Treated (139)` = fmt_est(mean(t), dec),
               `Never-exposed (2,534)` = fmt_est(mean(c0), dec),
               Difference = fmt_est(mean(t) - mean(c0), dec),
               `Norm. diff.` = formatC(nd, format = "f", digits = 3),
               check.names = FALSE, stringsAsFactors = FALSE)
  }))

  write.csv(bal, "Analysis/did/cohort_balance_table.csv", row.names = FALSE)
  write_tex_table(bal, "Analysis/did/cohort_balance_table.tex",
    align = paste0(RX, " r r r r"),
    caption = "Pre-treatment (2011) balance: 2012 first-onset counties versus never-exposed counties",
    label = "tab:e1t2",
    note = paste0(
      "Treated counties are the 139 whose first extreme-drought year (PDSI at or below ",
      "-4) in the 2011--2023 panel is 2012; never-exposed counties are the 2,534 with no ",
      "extreme-drought year in the window. Means are taken in 2011, the single pre-period ",
      "of the two-by-two design. The normalized difference is the treated-control gap divided by the ",
      "square root of the average of the two group variances; values above 0.25 in ",
      "absolute terms are conventionally treated as substantial imbalance, and motivate ",
      "the doubly-robust estimator reported alongside the raw contrast."))
  cat("wrote E1-T2 cohort_balance_table.{csv,tex} —", nrow(bal), "covariates\n")

  # =========================================================================
  # E1-T6 — Medicare responses, anchored to baselines
  # =========================================================================
  med_co <- read.csv("Analysis/mechanism/medicare_channel_coefs.csv")
  med_raw <- readRDS("Data/intermediate_medicare_spending.rds")
  # BENEFICIARY-WEIGHTED, not unweighted: this is the convention behind the
  # $10,359 / 629 anchors the essay already uses, and it is the right one for a
  # per-beneficiary quantity (an unweighted county mean would give $9,951 / 646,
  # over-weighting small counties). Verified to reproduce both to the dollar.
  base_spend <- weighted.mean(med_raw$Mdcr_Std_Payment_PC, med_raw$Benes_Total, na.rm = TRUE)
  base_ed    <- weighted.mean(med_raw$ER_Visits_per1000, med_raw$Benes_Total, na.rm = TRUE)
  cat(sprintf("Medicare baselines: spending $%.0f/beneficiary, ED %.0f per 1,000\n",
              base_spend, base_ed))

  lag_lab <- function(term) if (grepl("_Lag1$", term)) "1 year" else
    if (grepl("_Lag2$", term)) "2 years" else "Same year"
  haz_lab <- c(CDD = "Extreme heat", HDD = "Extreme cold",
               AQI = "Poor air quality", Drought = "Extreme drought")

  med_tab <- med_co %>%
    filter(spec == "overall",
           outcome %in% c("Mdcr_Std_Payment_PC", "ER_Visits_per1000")) %>%
    mutate(Hazard = unname(haz_lab[shock]),
           Timing = vapply(term, lag_lab, character(1)),
           base = ifelse(outcome == "Mdcr_Std_Payment_PC", base_spend, base_ed),
           pct = 100 * estimate / base) %>%
    filter(!is.na(Hazard)) %>%
    arrange(match(shock, c("CDD", "HDD", "AQI", "Drought")), outcome, term)

  med_out <- data.frame(
    Group = ifelse(med_tab$outcome == "Mdcr_Std_Payment_PC",
                   "Standardized spending per beneficiary",
                   "Emergency department visits per 1,000"),
    Hazard = med_tab$Hazard, Timing = med_tab$Timing,
    # usd() keeps the minus outside the currency symbol; sig3(prefix = "$") on a
    # negative estimate printed "$-14.1", which reads as a typo.
    Estimate = vapply(seq_len(nrow(med_tab)), function(i)
      if (med_tab$outcome[i] == "Mdcr_Std_Payment_PC") usd(med_tab$estimate[i])
      else sig3(med_tab$estimate[i]),
      character(1)),
    `Std. error` = vapply(med_tab$se, sig3, character(1)),
    `p` = vapply(med_tab$p, sig_p, character(1)),
    `Percent of mean` = vapply(med_tab$pct, function(z) sig3(z, suffix = "%"), character(1)),
    check.names = FALSE, stringsAsFactors = FALSE)

  write.csv(med_out, "Analysis/mechanism/medicare_table.csv", row.names = FALSE)
  write_tex_table(med_out, "Analysis/mechanism/medicare_table.tex",
    align = paste0(RX, " ", P(2.0), " l r r r"),
    group_col = "Group",
    caption = "Medicare spending and utilization responses to climate and air-quality shocks",
    longtable = TRUE,
    label = "tab:e1t6",
    note = paste0(
      "County-year panel of CMS Geographic Variation data, 2014--2023, for the 65-plus ",
      "and disabled Medicare population; county and year fixed effects, standard errors ",
      "clustered by state. ",
      "`Percent of mean' expresses each estimate against its own baseline: ",
      formatC(base_spend, format = "f", digits = 0, big.mark = ","),
      " dollars of standardized spending per beneficiary and ",
      formatC(base_ed, format = "f", digits = 0),
      " emergency department visits per 1,000 beneficiaries."))
  cat("wrote E1-T6 medicare_table.{csv,tex} —", nrow(med_out), "rows\n")

  # =========================================================================
  # VERIFY + estimate the county debt cells (Rows 4 and 5)
  # =========================================================================
  # The county pipeline has no binary cold-z shock and reports drought through
  # continuous pdsi_val, so neither county cell asserted in the evidence table
  # exists in a committed output. Estimate the county mirror of the state spec.
  dsub <- panel %>% arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(cold_z = as.integer(!is.na(Z_Temp) & Z_Temp < -1.5),
           cold_z_lag1 = dplyr::lag(cold_z, 1),
           heat_z = as.integer(!is.na(Z_Temp) & Z_Temp > 1.5),
           heat_z_lag1 = dplyr::lag(heat_z, 1)) %>% ungroup()

  m_cold <- feols(Medical_Debt_Share ~ cold_z + cold_z_lag1 + heat_z + heat_z_lag1 |
                    fips_code + Year, data = dsub, cluster = ~State)
  m_dr <- feols(Medical_Debt_Share ~ Is_Extreme_Drought + Is_Extreme_Drought_Lag1 +
                  Is_Extreme_Drought_Lag2 | fips_code + Year,
                data = dsub, cluster = ~State)
  ct_cold <- coeftable(m_cold); ct_dr <- coeftable(m_dr)
  cty_cold_l1 <- ct_cold["cold_z_lag1", ]
  cty_dr_l2 <- ct_dr["Is_Extreme_Drought_Lag2", ]

  cat("\n--- county debt cells: asserted vs re-estimated -------------------\n")
  cat(sprintf("cold -> debt, lag 1 : asserted +1.20 pp (p<0.001) | re-estimated %+0.2f pp (p=%.3f)\n",
              100 * cty_cold_l1[1], cty_cold_l1[4]))
  cat(sprintf("drought -> debt, lag2: asserted +0.54 pp (p<0.01)  | re-estimated %+0.2f pp (p=%.3f)\n",
              100 * cty_dr_l2[1], cty_dr_l2[4]))
  cat("Exhibits report the RE-ESTIMATED values.\n\n")

  # State cells, read from the committed state summary.
  st <- read.csv("Analysis/state/regression_results_summary.csv")
  st_cold <- st %>% filter(Dependent_Var == "Medical_Debt_Share",
                           Predictor == "is_cold_shock_lag1") %>% slice(1)
  st_dr <- st %>% filter(Dependent_Var == "Medical_Debt_Share",
                         Predictor == "is_extreme_drought_lag2") %>% slice(1)

  # Premium pass-through and its equivalence bound.
  pb <- read.csv("Analysis/mediation/passthrough_bounds.csv") %>%
    filter(outcome_role == "primary", premium == "Benchmark_Silver_Real",
           lag_role == "primary")
  pb_dr <- pb %>% filter(hazard == "Drought") %>% slice(1)
  mean_prem <- pb_dr$mean_premium

  base_debt <- mean(panel$Medical_Debt_Share, na.rm = TRUE)
  cat(sprintf("baselines: debt share %.4f, benchmark premium $%.2f/mo\n",
              base_debt, mean_prem))

  # =========================================================================
  # E1-T7 — institutional-ledger comparison
  # =========================================================================
  heat_sp <- med_co %>% filter(outcome == "Mdcr_Std_Payment_PC", spec == "overall",
                               term == "High_CDD_Lag1") %>% slice(1)
  heat_ed <- med_co %>% filter(outcome == "ER_Visits_per1000", spec == "overall",
                               term == "High_CDD_Lag1") %>% slice(1)

  ledger <- data.frame(
    Ledger = c("Medicare (administrative)", "Medicare (administrative)",
               "Credit bureau (state)", "Credit bureau (county)",
               "Credit bureau (county)", "ACA premiums (rating area)"),
    Response = c("Standardized spending per beneficiary, heat at 1-year lag",
                 "Emergency visits per 1,000, heat at 1-year lag",
                 "Medical debt share, cold at 1-year lag",
                 "Medical debt share, cold at 1-year lag",
                 "Medical debt share, drought at 2-year lag",
                 "Benchmark silver premium, drought at 2-year lag"),
    Estimate = c(sig3(heat_sp$estimate, prefix = "$"),
                 sig3(heat_ed$estimate),
                 sig3(100 * st_cold$Estimate, suffix = " pp"),
                 sig3(100 * cty_cold_l1[1], suffix = " pp"),
                 sig3(100 * cty_dr_l2[1], suffix = " pp"),
                 sig3(pb_dr$beta, prefix = "$", suffix = "/mo")),
    `p` = c(sig_p(heat_sp$p), sig_p(heat_ed$p), sig_p(st_cold$p_value),
            sig_p(cty_cold_l1[4]), sig_p(cty_dr_l2[4]), sig_p(pb_dr$p_state)),
    Baseline = c(sig3(base_spend, prefix = "$"),
                 sig3(base_ed),
                 sig3(100 * base_debt, suffix = "%"),
                 sig3(100 * base_debt, suffix = "%"),
                 sig3(100 * base_debt, suffix = "%"),
                 sig3(mean_prem, prefix = "$", suffix = "/mo")),
    `Percent of baseline` = c(
      sig3(100 * heat_sp$estimate / base_spend, suffix = "%"),
      sig3(100 * heat_ed$estimate / base_ed, suffix = "%"),
      sig3(100 * st_cold$Estimate / base_debt, suffix = "%"),
      sig3(100 * cty_cold_l1[1] / base_debt, suffix = "%"),
      sig3(100 * cty_dr_l2[1] / base_debt, suffix = "%"),
      sig3(100 * pb_dr$beta / mean_prem, suffix = "%")),
    check.names = FALSE, stringsAsFactors = FALSE)

  write.csv(ledger, "Analysis/mediation/ledger_comparison.csv", row.names = FALSE)
  write_tex_table(ledger, "Analysis/mediation/ledger_comparison.tex",
    align = paste0(P(3.0), " ", RX, " r r r r"),
    caption = "Institutional ledgers compared: response, baseline, and response as a share of baseline",
    label = "tab:e1t7",
    note = paste0(
      "Each ledger records a different population under different rules, so responses are ",
      "expressed as a percentage of that ledger's own mean to make them comparable. ",
      "Medicare estimates cover 2014--2023 for the 65-plus ",
      "and disabled population; the ACA cell is estimated ",
      "on the rating-area pass-through panel. The two county debt cells are estimated ",
      "as the county mirror of the state specification, because the county pipeline ",
      "carries no binary cold-z shock and reports drought through a continuous index -- ",
      "no committed county output contains them. Their values differ from figures quoted ",
      "in earlier drafts and supersede them. All specifications use county (or state) and ",
      "year fixed effects with state-clustered standard errors."))
  cat("wrote E1-T7 ledger_comparison.{csv,tex} —", nrow(ledger), "rows\n")

  # =========================================================================
  # E1-F5 — institutional-ledger figure
  # =========================================================================
  # The deferred design question was the unit. Standardising each response as a
  # percent of its own ledger mean is what makes them commensurable, and the
  # 90% interval travels with each point so precision is visible.
  z90 <- qnorm(0.95)
  fig <- data.frame(
    ledger = c("Medicare spending", "Medicare ED visits", "Medical debt share (state)",
               "Medical debt share (county)", "Medical debt share (county)",
               "ACA benchmark premium"),
    detail = c("heat, 1-yr lag", "heat, 1-yr lag", "cold, 1-yr lag",
               "cold, 1-yr lag", "drought, 2-yr lag", "drought, 2-yr lag"),
    est = c(heat_sp$estimate, heat_ed$estimate, st_cold$Estimate,
            cty_cold_l1[1], cty_dr_l2[1], pb_dr$beta),
    se  = c(heat_sp$se, heat_ed$se, st_cold$Std_Error,
            cty_cold_l1[2], cty_dr_l2[2], pb_dr$se),
    base = c(base_spend, base_ed, base_debt, base_debt, base_debt, mean_prem),
    stringsAsFactors = FALSE) %>%
    mutate(pct = 100 * est / base,
           lo = 100 * (est - z90 * se) / base,
           hi = 100 * (est + z90 * se) / base,
           lab = paste0(ledger, "\n(", detail, ")"),
           sig = ifelse(lo > 0 | hi < 0, "Interval excludes zero", "Interval includes zero"))
  fig$lab <- factor(fig$lab, levels = rev(fig$lab))

  p <- ggplot(fig, aes(x = pct, y = lab, colour = sig)) +
    geom_vline(xintercept = 0, linewidth = 0.4, colour = "grey40") +
    geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.18, linewidth = 0.6) +
    geom_point(size = 2.6) +
    scale_colour_manual(values = c("Interval excludes zero" = "#1b5e88",
                                   "Interval includes zero" = "#9a9a9a")) +
    labs(title = "Climate-shock responses across institutional ledgers",
         subtitle = paste0("Each response as a percent of that ledger's own mean; ",
                           "bars are 90% confidence intervals"),
         x = "Response as percent of ledger baseline", y = NULL, colour = NULL,
         # No script path here: the figure is read by people who will never see
         # the repository. Provenance belongs in the exhibit registry.
         caption = paste0("Each ledger observes a different population under different ",
                          "recording rules, so responses are shown relative to that ",
                          "ledger's own mean. County medical-debt cells are the county ",
                          "mirror of the state specification.")) +
    theme_minimal(base_size = 11) +
    theme(legend.position = "bottom",
          panel.grid.major.y = element_blank(),
          plot.title = element_text(face = "bold"),
          plot.caption = element_text(size = 7.5, colour = "grey35", hjust = 0))

  ggsave("Analysis/mediation/fig_institutional_ledgers.png", p,
         width = 8.2, height = 4.6, dpi = 200)
  cat("wrote E1-F5 fig_institutional_ledgers.png\n")

  # =========================================================================
  # E1-T8 — baseline sensitivity of the 2012 two-by-two
  # =========================================================================
  # Appendix A.2 argues that the -$1,311 contrast is a function of the single
  # 2011 pre-year. The grid that establishes it existed only as a CSV, so the
  # appendix asserted the result without showing it. Nothing is recomputed:
  # the numbers are read from the committed decomposition output.
  bs <- read.csv("Analysis/did/did_2x2_baseline_sensitivity_drought2012.csv",
                 check.names = FALSE)
  COMP <- c(PCPI_Real = "Total per-capita income",
            Farm_PC_Real = "Farm earnings component",
            NonFarm_PCPI_Real = "Nonfarm income component")
  bs <- bs[order(match(bs$Outcome, names(COMP)), -bs$Pre_Period_Start), ]
  e1t8 <- data.frame(
    Group = unname(COMP[bs$Outcome]),
    `Pre-period baseline` = ifelse(bs$Pre_Period_Start == 2011, "2011 only",
                                   paste0(bs$Pre_Period_Start, "--2011")),
    `Estimate` = vapply(bs$ATT, usd, character(1)),
    `Std. error` = vapply(bs$Std_Error, sig3, character(1)),
    `p` = vapply(bs$p_value, sig_p, character(1)),
    `County-years` = vapply(bs$N, fmt_n, character(1)),
    check.names = FALSE, stringsAsFactors = FALSE)
  write.csv(e1t8, "Analysis/did/baseline_sensitivity_table.csv", row.names = FALSE)
  write_tex_table(e1t8, "Analysis/did/baseline_sensitivity_table.tex",
    align = paste0(RX, " r r r r"), group_col = "Group", fontsize = "\\footnotesize",
    caption = paste0("Sensitivity of the 2012 drought income contrast to the ",
                     "pre-period baseline"),
    label = "tab:e1t8",
    note = paste0(
      "Each row re-estimates the same two-by-two contrast -- 139 counties with ",
      "their first extreme drought in 2012 against 2,534 never-exposed counties -- ",
      "changing only which years form the pre-period against which post-2012 ",
      "outcomes are measured. Reading down the first panel, the headline contrast ",
      # Bare "$" here: write_tex_table() escapes it. Pre-escaping it as "\\$"
      # made the escaper emit \textbackslash{}\$ and the note printed literal
      # backslash-brace tokens.
      "shrinks from roughly $1,300 to under $300 as soon as the baseline ",
      "extends beyond 2011 alone. The lower panels locate that instability: the ",
      "farm component collapses from -$907 to near zero, because 2011 was the ",
      "peak of the commodity-price cycle, while the nonfarm component holds ",
      "between -$261 and -$414 under every choice. County and year fixed ",
      "effects with state-clustered standard errors throughout."))
  cat("wrote E1-T8 baseline_sensitivity_table.{csv,tex} —", nrow(e1t8), "rows\n")

  cat("\n=== done ===\n")
}
