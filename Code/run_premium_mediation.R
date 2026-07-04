# =============================================================================
# run_premium_mediation.R  (thesis_completion_20260704 — T1.1)
# =============================================================================
# WHY THIS EXISTS
#   The October-2025 proposal promised Chapter 1's novel contribution as a
#   premium -> medical-debt MEDIATION test and named the pass-through rho of
#   claims-relevant shocks into benchmark premiums as a key input. That analysis
#   was never estimated. Everything it needs is already in the county master, so
#   this closes the proposal promise and gives Essay 1 its insurer-side story.
#
# TWO EQUATIONS
#   (i)  PASS-THROUGH (rho): do lagged claims-relevant shocks raise the benchmark
#        premium? feols(Benchmark_Silver_Real ~ shock + L1 + L2 | fips + Year),
#        state-clustered, with a rating-area-clustered variant. (Premiums are set
#        at the rating-area level, so counties in a rating area share a premium by
#        construction; state clustering nests rating areas, the RA-clustered
#        variant is the robustness — mirrors run_county_analysis.R.) rho is the
#        pass-through of a shock into next-years' premiums.
#   (ii) MEDIATION: does the shock -> medical-debt-share effect run THROUGH
#        premiums? Fit debt ~ shocks(+lags) with and without premium controls on
#        the IDENTICAL sample and report the fraction of each shock effect that
#        SURVIVES premium adjustment (same difference-method decomposition as
#        run_demographic_mediators.R). 1 - fraction is the premium-mediated share.
#
# CAVEATS (stated, not hidden)
#   - This is a descriptive difference-method decomposition, not a causally
#     identified mediation: the premium mediator is itself an outcome of the
#     shock, so the split assumes no mediator-outcome confounding conditional on
#     the FE. Same limitation the demographic-mediator decomposition carries.
#   - Premiums are rating-area-level; the mediated share is therefore a lower
#     bound on any true county-level premium channel.
#   - Medical debt is the measurement-fragile outcome (needs insurance + billed
#     care + a credit file); read alongside the real-economy results, not alone.
#
# ENVIRONMENT: main R 4.2.2.  Rscript Code/run_premium_mediation.R
# OUTPUTS
#   Analysis/mediation/premium_passthrough.csv   (eq i, both cluster variants)
#   Analysis/mediation/debt_mediation.csv        (eq ii, fraction surviving)
#   Analysis/mediation/premium_mediation_summary.md
#   Analysis/mediation/build_logs/run_premium_mediation.log
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(fixest)
})

# ---------------------------------------------------------------------------
# HELPERS (pure; sourced and unit-tested by Code/tests/test_premium_mediation.R)
# ---------------------------------------------------------------------------

# add_shock_lags(): per-county L1..Lmax_lag lags of each named column, by Year.
# Works on any numeric column (shocks OR the premium mediator). CLAUDE.md FIPS
# note is handled by the caller; here we only need within-county ordering.
add_shock_lags <- function(df, cols, max_lag = 2L) {
  df <- dplyr::arrange(df, fips_code, Year) %>% dplyr::group_by(fips_code)
  for (s in cols) for (k in seq_len(max_lag)) {
    df <- dplyr::mutate(df, !!paste0(s, "_L", k) := dplyr::lag(.data[[s]], k))
  }
  as.data.frame(dplyr::ungroup(df))
}

# mediation_decompose(): fit base (Y ~ shocks | FE) and with-mediator
# (Y ~ shocks + mediators | FE) on the IDENTICAL complete-case sample, and return
# per shock term the base coef, the with-mediator coef, the mediated part
# (base - with), and the surviving fraction (with / base).
mediation_decompose <- function(df, outcome, shock_terms, mediator_terms,
                                cluster = ~State) {
  needed <- c(outcome, shock_terms, mediator_terms, "fips_code", "Year")
  sub <- df[stats::complete.cases(df[, needed, drop = FALSE]), , drop = FALSE]
  f_base <- stats::as.formula(paste(outcome, "~",
              paste(shock_terms, collapse = " + "), "| fips_code + Year"))
  f_with <- stats::as.formula(paste(outcome, "~",
              paste(c(shock_terms, mediator_terms), collapse = " + "),
              "| fips_code + Year"))
  m_base <- feols(f_base, data = sub, cluster = cluster)
  m_with <- feols(f_with, data = sub, cluster = cluster)
  cb <- coeftable(m_base); cw <- coeftable(m_with)
  cell <- function(ct, term, col) if (term %in% rownames(ct)) ct[term, col] else NA_real_
  do.call(rbind, lapply(shock_terms, function(t) {
    eb <- cell(cb, t, "Estimate"); ew <- cell(cw, t, "Estimate")
    data.frame(term = t, est_base = eb, est_with = ew,
               mediated = eb - ew,
               fraction_surviving = if (!is.na(eb) && eb != 0) ew / eb else NA_real_,
               p_base = cell(cb, t, 4), p_with = cell(cw, t, 4),
               N = nobs(m_base), stringsAsFactors = FALSE)
  }))
}

# ---------------------------------------------------------------------------
# MAIN (guarded so sourcing for tests does not run the analysis)
# ---------------------------------------------------------------------------
if (sys.nframe() == 0L) {

  OUT <- "Analysis/mediation"
  dir.create(file.path(OUT, "build_logs"), showWarnings = FALSE, recursive = TRUE)
  logcon <- file(file.path(OUT, "build_logs", "run_premium_mediation.log"), open = "wt")
  sink(logcon, split = TRUE); sink(logcon, type = "message")
  on.exit({ sink(type = "message"); sink(); close(logcon) }, add = TRUE)
  cat("=== premium pass-through + debt mediation ::", format(Sys.time()), "===\n\n")

  pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

  df <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)
  df$fips_code <- pad_fips(df$fips_code)
  # CO-2023 medical-debt reporting-rule exclusion (CLAUDE.md / run_county_analysis.R).
  excl <- toupper(trimws(df$State)) == "CO" & as.integer(df$Year) == 2023L
  df$Medical_Debt_Share[excl] <- NA_real_
  df <- df %>% filter(Year >= 2011L, Year <= 2023L)

  shocks   <- c("Is_Extreme_Drought", "High_CDD", "High_HDD")
  premium  <- "Benchmark_Silver_Real"
  premium2 <- "Lowest_Bronze_Real"

  # Build 2 lags for the shocks AND the premium mediator.
  df <- add_shock_lags(df, c(shocks, premium, premium2), max_lag = 2L)
  shock_terms <- as.vector(t(outer(shocks, c("", "_L1", "_L2"), paste0)))  # 9 terms

  # -----------------------------------------------------------------------
  # (i) PASS-THROUGH rho: shocks -> benchmark premium
  # -----------------------------------------------------------------------
  cat("--- (i) Pass-through: shocks -> premium ---\n")
  passthrough <- function(prem) {
    f <- stats::as.formula(paste(prem, "~", paste(shock_terms, collapse = " + "),
                                 "| fips_code + Year"))
    sub <- df[stats::complete.cases(df[, c(prem, shock_terms)]), ]
    m  <- feols(f, data = sub, cluster = ~State)
    cs <- coeftable(m)                                       # state-clustered
    cr <- coeftable(summary(m, cluster = ~rating_area_id))   # RA-clustered
    do.call(rbind, lapply(shock_terms, function(t) data.frame(
      premium = prem, shock_term = t,
      estimate = cs[t, "Estimate"],
      se_state = cs[t, "Std. Error"], p_state = cs[t, 4],
      se_ra    = cr[t, "Std. Error"], p_ra    = cr[t, 4],
      N = nobs(m), stringsAsFactors = FALSE)))
  }
  pt <- rbind(passthrough(premium), passthrough(premium2))
  write_csv(pt, file.path(OUT, "premium_passthrough.csv"))
  cat("Significant pass-through terms (state-clustered p<0.05):\n")
  print(pt %>% filter(p_state < 0.05) %>%
          mutate(across(c(estimate, se_state, p_state), ~signif(.x, 3))) %>%
          select(premium, shock_term, estimate, se_state, p_state), row.names = FALSE)

  # -----------------------------------------------------------------------
  # (ii) MEDIATION: does shock -> debt run through premiums?
  # -----------------------------------------------------------------------
  cat("\n--- (ii) Mediation: shock -> debt, with/without premium controls ---\n")
  mediator_terms <- c(premium, paste0(premium, "_L1"), paste0(premium, "_L2"))
  dec <- mediation_decompose(df, "Medical_Debt_Share", shock_terms,
                             mediator_terms, cluster = ~State)
  write_csv(dec, file.path(OUT, "debt_mediation.csv"))
  cat("Decomposition (all shock terms):\n")
  print(dec %>% mutate(across(c(est_base, est_with, mediated, fraction_surviving),
                              ~signif(.x, 3))) %>%
          select(term, est_base, est_with, fraction_surviving, p_base), row.names = FALSE)

  # Headline debt terms: cold at lag1, drought at lag2.
  head_terms <- c("High_HDD_L1", "Is_Extreme_Drought_L2")
  hh <- dec[dec$term %in% head_terms, ]

  # -----------------------------------------------------------------------
  # Summary md
  # -----------------------------------------------------------------------
  sig_pt <- pt %>% filter(p_state < 0.05)
  md <- c(
    "# Premium Pass-through and Debt Mediation — Summary",
    "",
    sprintf("_Generated %s. County panel, county + year FE, state-clustered_",
            format(Sys.Date())),
    sprintf("_(rating-area-clustered variant alongside). N(premium eq) up to %d._", max(pt$N)),
    "_Premiums are MONTHLY real dollars (mean benchmark silver ~$375). The premium",
    "series begins 2014 (ACA marketplaces), so both equations run on 2014-2023; the",
    "eq-(ii) base debt coefficients are therefore larger than the full-panel headlines_",
    "_(the surviving fraction, invariant to sample, carries the mediation conclusion)._",
    "",
    "## (i) Pass-through rho: claims-relevant shocks -> benchmark premium",
    if (nrow(sig_pt) == 0) "_No shock term significant at 0.05 (state-clustered)._" else
      knitr::kable(sig_pt %>% select(premium, shock_term, estimate, se_state,
                                     p_state, p_ra) %>%
                     mutate(across(where(is.numeric), ~signif(.x, 3))),
                   format = "pipe"),
    "",
    "## (ii) Mediation: fraction of the shock->debt effect surviving premium adjustment",
    knitr::kable(dec %>% filter(term %in% head_terms) %>%
                   select(term, est_base, est_with, mediated, fraction_surviving,
                          p_base, p_with) %>%
                   mutate(across(where(is.numeric), ~signif(.x, 3))),
                 format = "pipe"),
    "",
    "**Reading.** `fraction_surviving` = coef(with premium) / coef(base). A value",
    "below 1 means premiums absorb part of the shock->debt effect (premium-mediated);",
    "≈1 means the debt effect does not run through premiums. `mediated` = base - with.",
    "This is a difference-method decomposition, not a causally identified mediation",
    "(the premium mediator is itself shock-affected); premiums are rating-area-level,",
    "so the mediated share is a lower bound on a true county premium channel.")
  writeLines(md, file.path(OUT, "premium_mediation_summary.md"))

  cat("\nWrote:\n ", file.path(OUT, "premium_passthrough.csv"),
      "\n ", file.path(OUT, "debt_mediation.csv"),
      "\n ", file.path(OUT, "premium_mediation_summary.md"), "\n")
  cat("\n=== done", format(Sys.time()), "===\n")
}
