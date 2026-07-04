# =============================================================================
# run_premium_mediation.R  (thesis_completion_20260704 — T1.1)
# =============================================================================
# WHY THIS EXISTS
#   The October-2025 proposal promised Chapter 1's novel contribution as a
#   premium -> medical-debt MEDIATION test and named the pass-through rho of
#   claims-relevant shocks into benchmark premiums as a key input. This closes
#   that promise and gives Essay 1 its insurer-side story.
#
# TWO EQUATIONS
#   (i)  PASS-THROUGH: do claims-relevant shocks raise ACA benchmark premiums?
#   (ii) MEDIATION: does the shock -> medical-debt effect run THROUGH premiums?
#
# ---- THE UNIT-OF-ANALYSIS PROBLEM (why eq (i) is a TWO-LEVEL decomposition) ----
#   ACA rates are set at the geographic RATING-AREA level and filed/reviewed per
#   STATE, and ~86% of benchmark-premium variance is state x year. A county+Year-FE
#   regression of a premium on a county shock therefore identifies mostly the
#   BETWEEN-state pattern leaking through an insufficient FE, and its coefficients
#   are confounded with state-year premium dynamics (the CSR-defunding "silver
#   loading" spike, insurer entry/exit, 1332 waivers). Adding State x Year FE, in
#   turn, OVER-absorbs: under 45 CFR 156.80 any *legal* statewide morbidity
#   pass-through lives in the statewide index rate — exactly the state x year cell
#   those FE delete. So NEITHER county spec identifies the object of interest; the
#   county specs are reported only as a TRANSPARENCY TRAIL (misspecified).
#   The question is estimated at the two levels the institutions actually use:
#     PRIMARY   — rating-area x year, RA + State^Year FE: the WITHIN-state local
#                 margin (the geographic rating factor, which regulation directs to
#                 provider UNIT COSTS, not morbidity). A null here is informative.
#     SECONDARY — state x year, State + Year FE: the BETWEEN-state statewide-risk-
#                 pool margin, which the index rate MAY legally price. Interpreted
#                 with sign/magnitude coherence, not taken at face value.
#   Shocks aggregate to a pop-weighted SHARE in [0,1] at each level, so a level
#   coefficient is dollars-per-fully-exposed-unit. Rate-filing timing => LAGGED
#   shocks only (plan-year-t rates filed ~mid t-1 on ~t-2 experience; t-2 primary).
#
# INFERENCE: STATE clustering is primary (shocks are ~state-level events; rate
#   review is a state process, so errors correlate within state-year). Rating-area
#   clustering understates SEs here (more clusters, within-state error correlation)
#   and is reported only as a variant — NEVER used to select significance.
#
# CAVEATS: eq (ii) is a difference-method decomposition, not causal mediation.
#   Split counties (multi-rating-area) are deduped to one row/county-year here as a
#   stopgap — the durable fix is T1.2 (enforced upstream in create_county_master.R).
#   Medical debt is measurement-fragile; read with the real-economy results.
#
# ENVIRONMENT: main R 4.2.2.  Rscript Code/run_premium_mediation.R
# OUTPUTS
#   Analysis/mediation/premium_passthrough.csv   (all four specs, tidy)
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

# add_shock_lags(): per-`group` L1..Lmax_lag lags of each named column, by Year.
# `group` defaults to fips_code (county panel) but is set to rating_area_id / State
# for the aggregated level panels. Works on any numeric column (shocks, shares, or
# the premium mediator).
add_shock_lags <- function(df, cols, max_lag = 2L, group = "fips_code") {
  df <- df[order(df[[group]], df$Year), , drop = FALSE]
  df <- dplyr::group_by(df, dplyr::across(dplyr::all_of(group)))
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
  wmean <- function(x, w) { i <- !is.na(x) & !is.na(w)
    if (!any(i)) NA_real_ else stats::weighted.mean(x[i], w[i]) }
  fmean <- function(x) { m <- mean(x, na.rm = TRUE); if (is.nan(m)) NA_real_ else m }

  raw <- read_csv("Data/county_level_master.csv", show_col_types = FALSE, progress = FALSE)
  raw$fips_code <- pad_fips(raw$fips_code)
  excl <- toupper(trimws(raw$State)) == "CO" & as.integer(raw$Year) == 2023L
  raw$Medical_Debt_Share[excl] <- NA_real_
  raw <- raw %>% filter(Year >= 2011L, Year <= 2025L)   # premiums 2014-2025; 2011 for debt lags

  shocks   <- c("Is_Extreme_Drought", "High_CDD", "High_HDD")
  premium  <- "Benchmark_Silver_Real"
  premium2 <- "Lowest_Bronze_Real"
  haz_lab  <- c(sh_dr = "Drought", sh_cdd = "Heat", sh_hdd = "Cold",
                Is_Extreme_Drought = "Drought", High_CDD = "Heat", High_HDD = "Cold")

  # --- county-deduped frame (resolves the 54 multi-rating-area split counties;
  #     stopgap for T1.2). Premiums averaged across a split county's areas; shocks
  #     are county-level climate so identical across a county's rows. ------------
  ndup <- raw %>% count(fips_code, Year) %>% filter(n > 1) %>% nrow()
  county <- raw %>% group_by(fips_code, Year) %>%
    summarise(State = first(State), rating_area_id = first(rating_area_id),
              Population = first(Population),
              Benchmark_Silver_Real = fmean(Benchmark_Silver_Real),
              Lowest_Bronze_Real    = fmean(Lowest_Bronze_Real),
              Medical_Debt_Share = first(Medical_Debt_Share),
              Is_Extreme_Drought = first(Is_Extreme_Drought),
              High_CDD = first(High_CDD), High_HDD = first(High_HDD),
              PCPI_Real = first(PCPI_Real), .groups = "drop")
  cat(sprintf("Deduped %d duplicate county-year groups -> %d county-year rows.\n",
              ndup, nrow(county)))

  # --- aggregate to level panels: pop-weighted premium + shock SHARES ----------
  build_level <- function(dat, group) {
    dat %>% filter(!is.na(Benchmark_Silver_Real) | !is.na(Lowest_Bronze_Real)) %>%
      group_by(across(all_of(c(group, "Year")))) %>%
      summarise(State = first(State),
                Benchmark_Silver_Real = wmean(Benchmark_Silver_Real, Population),
                Lowest_Bronze_Real    = wmean(Lowest_Bronze_Real, Population),
                sh_dr  = wmean(Is_Extreme_Drought, Population),
                sh_cdd = wmean(High_CDD, Population),
                sh_hdd = wmean(High_HDD, Population),
                pop = sum(Population, na.rm = TRUE), .groups = "drop")
  }
  ra_panel <- build_level(raw, "rating_area_id")    # from raw (split-county RA rows)
  st_panel <- build_level(county, "State")          # from deduped county rows
  lvl_cols <- c("sh_dr", "sh_cdd", "sh_hdd")
  ra_panel <- add_shock_lags(ra_panel, lvl_cols, 2L, group = "rating_area_id")
  st_panel <- add_shock_lags(st_panel, lvl_cols, 2L, group = "State")
  lvl_lags <- as.vector(t(outer(lvl_cols, c("_L1", "_L2"), paste0)))   # 6 terms

  cell <- function(ct, term, col) if (term %in% rownames(ct)) ct[term, col] else NA_real_
  tidy_terms <- function(m, terms, spec, prem) do.call(rbind, lapply(terms, function(t) {
    hz <- haz_lab[sub("_L[12]$", "", t)]; lg <- sub("^.*_(L[12])$", "\\1", t)
    data.frame(spec = spec, premium = prem, hazard = unname(hz), lag = lg,
               estimate = cell(coeftable(m), t, "Estimate"),
               se = cell(coeftable(m), t, "Std. Error"),
               p_state = cell(coeftable(m), t, 4), N = nobs(m),
               stringsAsFactors = FALSE) }))

  # --- (i-PRIMARY) rating-area x year: within-state local margin ---------------
  cat("\n--- (i-PRIMARY) rating-area x year (RA + State^Year FE, pop-wtd, state-clustered) ---\n")
  fit_level <- function(panel, prem, fe, spec)
    tidy_terms(feols(stats::as.formula(paste(prem, "~", paste(lvl_lags, collapse = "+"),
              "|", fe)), data = panel, weights = ~pop, cluster = ~State), lvl_lags, spec, prem)
  ra_res <- rbind(
    fit_level(ra_panel, premium,  "rating_area_id + State^Year", "RAxYr: RA+State^Year"),
    fit_level(ra_panel, premium2, "rating_area_id + State^Year", "RAxYr: RA+State^Year"))
  print(ra_res %>% filter(lag == "L2") %>%
          mutate(across(c(estimate, se, p_state), ~signif(.x, 3))), row.names = FALSE)

  # --- (i-SECONDARY) state x year: between-state statewide-pool margin ----------
  cat("\n--- (i-SECONDARY) state x year (State + Year FE, pop-wtd, state-clustered) ---\n")
  st_res <- rbind(
    fit_level(st_panel, premium,  "State + Year", "StatexYr: State+Year"),
    fit_level(st_panel, premium2, "State + Year", "StatexYr: State+Year"))
  print(st_res %>% filter(lag == "L2") %>%
          mutate(across(c(estimate, se, p_state), ~signif(.x, 3))), row.names = FALSE)
  cat("  NOTE: interpret via sign/magnitude coherence, not p-values — see summary.\n")

  # --- (i-TRANSPARENCY) county specs (MISSPECIFIED for a state-set outcome) -----
  cat("\n--- (i-TRANSPARENCY) county specs — lagged binary shocks (misspecified) ---\n")
  cty <- add_shock_lags(county, shocks, 2L, group = "fips_code")
  cty_lags <- as.vector(t(outer(shocks, c("_L1", "_L2"), paste0)))
  tidy_cty <- function(m, spec, prem) do.call(rbind, lapply(cty_lags, function(t) {
    hz <- haz_lab[sub("_L[12]$", "", t)]; lg <- sub("^.*_(L[12])$", "\\1", t)
    data.frame(spec = spec, premium = prem, hazard = unname(hz), lag = lg,
               estimate = cell(coeftable(m), t, "Estimate"), se = cell(coeftable(m), t, "Std. Error"),
               p_state = cell(coeftable(m), t, 4), N = nobs(m), stringsAsFactors = FALSE) }))
  fit_cty <- function(fe, spec) tidy_cty(feols(stats::as.formula(paste(premium, "~",
                paste(cty_lags, collapse = "+"), "|", fe)), data = cty, cluster = ~State), spec, premium)
  cty_res <- rbind(fit_cty("fips_code + Year", "County: fips+Year (misspec)"),
                   fit_cty("fips_code + State^Year", "County: fips+State^Year (misspec)"))
  print(cty_res %>% filter(lag == "L2", hazard %in% c("Heat", "Cold")) %>%
          mutate(across(c(estimate, se, p_state), ~signif(.x, 3))), row.names = FALSE)

  pt <- rbind(ra_res, st_res, cty_res)
  pt$ci_lo <- pt$estimate - 1.96 * pt$se
  pt$ci_hi <- pt$estimate + 1.96 * pt$se
  write_csv(pt, file.path(OUT, "premium_passthrough.csv"))

  # -----------------------------------------------------------------------
  # (ii) MEDIATION: does shock -> debt run through premiums? (county, deduped)
  # -----------------------------------------------------------------------
  cat("\n--- (ii) Mediation: shock -> debt, with/without premium controls ---\n")
  medf <- add_shock_lags(county, c(shocks, premium), 2L, group = "fips_code")
  shock_terms <- as.vector(t(outer(shocks, c("", "_L1", "_L2"), paste0)))  # 9 terms
  mediator_terms <- c(premium, paste0(premium, "_L1"), paste0(premium, "_L2"))
  dec <- mediation_decompose(medf, "Medical_Debt_Share", shock_terms,
                             mediator_terms, cluster = ~State)
  write_csv(dec, file.path(OUT, "debt_mediation.csv"))
  head_terms <- c("High_HDD_L1", "Is_Extreme_Drought_L2")
  print(dec %>% mutate(across(c(est_base, est_with, fraction_surviving), ~signif(.x, 3))) %>%
          select(term, est_base, est_with, fraction_surviving, p_base), row.names = FALSE)

  # -----------------------------------------------------------------------
  # Summary md
  # -----------------------------------------------------------------------
  fnum <- function(d) d %>% mutate(across(where(is.numeric), ~signif(.x, 3)))
  ra_l2 <- pt %>% filter(grepl("^RAxYr", spec), lag == "L2")     # pt carries ci_lo/ci_hi
  st_l2 <- pt %>% filter(grepl("^StatexYr", spec), lag == "L2")
  md <- c(
    "# Premium Pass-through and Debt Mediation — Summary",
    "",
    sprintf("_Generated %s. Premiums are MONTHLY real dollars (mean benchmark ~$375),", format(Sys.Date())),
    "2014-2025. Pass-through uses LAGGED shocks (rate-filing timing; t-2 primary) as pop-",
    "weighted SHARES, so a level coefficient is $ per fully-exposed unit. STATE clustering",
    "is primary; rating-area clustering understates SEs here and is not used to select_",
    "_significance. Split counties deduped to one row/county-year (stopgap for T1.2)._",
    "",
    "## (i) PASS-THROUGH — estimated at the levels ACA rates are actually set",
    "",
    "### PRIMARY — within-state local margin (rating-area x year, RA + State^Year FE)",
    "_The only margin a local shock could legally enter (the geographic rating factor)._",
    knitr::kable(fnum(ra_l2 %>% select(premium, hazard, estimate, se, p_state, ci_lo, ci_hi)),
                 format = "pipe"),
    "",
    "### SECONDARY — between-state statewide-pool margin (state x year, State + Year FE)",
    "_The index rate MAY legally price statewide experience. Read via sign/magnitude",
    "coherence: a claims channel predicts cold-POSITIVE (cold raises Medicare spending in",
    "this project) and moves of ~1-2% of premium; observed signs/sizes are inconsistent._",
    knitr::kable(fnum(st_l2 %>% select(premium, hazard, estimate, se, p_state, ci_lo, ci_hi)),
                 format = "pipe"),
    "",
    "### TRANSPARENCY — county specs are MISSPECIFIED for a state-set outcome",
    "_~86% of premium variance is state x year; county+Year FE lets state-year premium",
    "dynamics load onto county shocks, county+State^Year FE deletes the statewide margin.",
    "Shown only to trace where the earlier spurious county coefficients came from._",
    knitr::kable(fnum(cty_res %>% filter(lag == "L2", hazard %in% c("Heat", "Cold")) %>%
                        select(spec, hazard, estimate, se, p_state)), format = "pipe"),
    "",
    "**Verdict — no COHERENT pass-through.** The tell is sign-instability across the level of",
    "analysis: the cold t-2 coefficient runs -$15.5 (county+Year) -> +$12.6 (RA x year) -> -$16.7",
    "(state x year), and heat runs +$19.5 -> -$10.5 -> +$93. Each apparent 'effect' is an artifact",
    "of which variance (within- vs between-state) the FE leave standing, not a stable price",
    "response. Within states the estimates are small (a few % of the $375 mean) and not coherently",
    "signed; the one nominally significant term (cold, positive at the RA level) reverses between",
    "states and is unmatched by heat. Between states, premium levels co-move with lagged",
    "temperature anomalies (heat +$54-93/mo = 14-25% of the mean), but that is far too large for a",
    "claims channel and cold's sign is backwards vs this project's own Medicare result (cold RAISES",
    "spending), so it reads as a temperature-anomaly correlate of premium LEVELS, not pricing.",
    "Drought is null at every level (the hazard with the most county-level identifying variation).",
    "Net: no coherent evidence the ACA individual market reprices local climate-health-cost shocks",
    "— consistent with the single statewide risk pool, unit-cost-only geographic rating factors,",
    "and Part 153 risk adjustment removing the incentive to price local morbidity.",
    "",
    "## (ii) Mediation: fraction of the shock->debt effect surviving premium adjustment",
    knitr::kable(fnum(dec %>% filter(term %in% head_terms) %>%
                   select(term, est_base, est_with, mediated, fraction_surviving, p_base, p_with)),
                 format = "pipe"),
    "",
    "**Reading.** 93-99% of each headline debt effect survives premium controls. Given the",
    "null/incoherent first stage, this is the expected corollary: there is no premium channel",
    "for the shock->debt effect to run through. Difference-method decomposition, not causal;",
    "premiums are rating-area-level (mediated share is a lower bound); marketplace-era (2014+)",
    "sample so base debt coefs exceed full-panel headlines (the surviving fraction is",
    "sample-invariant). NB: the same State^Year FE that (correctly) absorbs the premium-",
    "generating process also absorbs county debt/income treatment (cold waves are state-level",
    "events) — so State^Year FE is the right benchmark for the administratively-state-set",
    "premium, NOT for household outcomes. See the cross_level_symmetry track.")
  writeLines(md, file.path(OUT, "premium_mediation_summary.md"))

  cat("\nWrote passthrough, debt_mediation, summary.\n=== done", format(Sys.time()), "===\n")
}
