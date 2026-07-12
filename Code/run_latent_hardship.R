# =============================================================================
# run_latent_hardship.R   (audit_response_20260712 — Task 3.2; objective O6)
# =============================================================================
# PURPOSE (the audit's "high-alpha" latent-hardship question)
#   Does the measured climate-shock -> medical-debt response SHRINK where hardship
#   is least observable to financial institutions? If the debt response attenuates
#   toward zero exactly where insurance coverage, hospital access, and credit
#   visibility are weakest, then credit-bureau medical debt UNDERSTATES harm in
#   those places — converting the debt-measurement caveat into a positive
#   ("latent hardship") finding rather than a limitation. This extends the existing
#   SAHIE working-age-uninsured interaction (mechanisms_revision_20260704, C1) from
#   a caveat to a contribution.
#
# THIS IS A PRE-REGISTERED ANALYSIS.  The design is frozen in
#   conductor/tracks/audit_response_20260712/spec.md
#   -> "Phase-3 pre-specification (task 3.1 — dated 2026-07-12 ...)".
#   This script implements EXACTLY that frozen design. Deviations forced by data
#   availability are recorded below as IMPLEMENTATION BINDINGS and flagged in the
#   return message; nothing else is added (see the pre-spec's parking-lot rule —
#   further moderators/lags/hazards belong in Phase 4, not here).
#
# FROZEN DESIGN (restated; the spec file governs if they differ)
#   Outcomes   : PRIMARY   Medical_Debt_Share
#                SECONDARY Medical_Debt_Median_2023
#   Shock cells: ONLY two — cold (High_HDD) at lag 1 ; extreme drought at lag 2.
#                (the established debt-relevant cells; run_premium_mediation.R's
#                 head_terms are exactly High_HDD_Lag1 and Is_Extreme_Drought_Lag2)
#   Moderators : z-scored at BASELINE (pre-treatment, time-invariant) to avoid bad
#                controls.  PRIMARY (3): SAHIE uninsured rate (baseline-window
#                mean); rurality (RUCC); hospital access.  SECONDARY (2): baseline
#                median household income; SVI.
#   Spec       : the project's established county debt spec (run_county_analysis.R:
#                fixest::feols, county + year FE, STATE-clustered SEs) + a
#                shock x moderator interaction.  POPULATION-WEIGHTED is primary
#                (the established debt spec weights debt by Population); UNWEIGHTED
#                is reported as robustness only.
#   Multiplicity: primary family = 2 shocks x 3 primary moderators x 1 primary
#                outcome = 6 cells; SHARPENED q-values (BKY 2006, the
#                run_mechanism_multipletesting.R machinery) computed over the full
#                20-cell grid (2 shocks x 5 moderators x 2 outcomes).
#   Expected signs (recorded a priori — a surprise is a debugging trigger first):
#                where uninsurance / rurality is HIGHER and hospital access LOWER,
#                the measured debt response ATTENUATES toward zero, i.e. the
#                interaction is OPPOSITE in sign to the shock main effect. The
#                existing SAHIE interaction already shows this for uninsurance.
#   Decision rule (binding for permitted language): "positive contribution"
#                framing ONLY if >=2 of the 3 primary moderators show attenuation
#                at q<0.10 with consistent signs for at least one shock cell;
#                otherwise the honest null (debt stays a caveat). Claim tier is
#                capped at MECHANISM-SUPPORTING regardless.
#
# -----------------------------------------------------------------------------
# IMPLEMENTATION BINDINGS (deviations forced by data availability — flagged)
# -----------------------------------------------------------------------------
#   [B1] RURALITY (RUCC).  The pre-spec names the USDA Rural-Urban Continuum Code.
#        RUCC does NOT exist anywhere in this repo (no download/process script, no
#        column, no intermediate — verified 2026-07-12 by two searches incl. an
#        explicit-glob re-run per the environment-knowledge search gotcha). Closest
#        faithful binding: RURALITY = z-score of NEGATIVE log baseline-window mean
#        county Population. RUCC is fundamentally an ordinal metro/non-metro-by-
#        population-size scale (codes 1-3 metro, 4-9 non-metro, ordered by county
#        population and metro adjacency); baseline county population is its single
#        strongest determinant. Oriented so HIGHER = MORE RURAL (matches RUCC's
#        direction), so higher_is_worse = TRUE like uninsurance.
#   [B2] HOSPITAL ACCESS.  The pre-spec lets the implementer bind "county hospital
#        presence/density or safety-net share from the NASHP panel" (baseline,
#        time-invariant) and document the choice. Binding: HOSPITAL ACCESS =
#        z-score of log1p(count of DISTINCT hospitals (unique CCN) physically
#        located in the county in the NASHP HCT panel over the baseline window).
#        Rationale: a raw COUNT of hospital infrastructure is the cleanest
#        "presence/density" measure and — unlike hospitals-per-capita — does NOT
#        invert for tiny rural counties (1 hospital / few residents would read as
#        very high per-capita "density", corrupting the access interpretation).
#        log1p tames the right skew. Oriented so HIGHER = MORE ACCESS, so
#        higher_is_worse = FALSE (the debt response should STRENGTHEN where access
#        is greater; attenuate where it is scarce).
#        CAVEAT: ~23% of counties never report a hospital in the NASHP HCT (a known
#        data-pipeline fact). Those counties are treated as 0 hospitals (lowest
#        access) — this conflates "no hospital" with "hospital does not report cost
#        data", a documented limitation of this binding.
#   [B3] SVI.  Bound to SVI_static (the repo's established time-invariant baseline
#        SVI in intermediate_svi.rds, used by the exposure/horse-race scripts),
#        which is exactly the "baseline, time-invariant" object the pre-spec asks
#        for. Higher = more socially vulnerable = weaker credit visibility (poor/
#        uninsured areas accrue less MEASURED debt), so higher_is_worse = TRUE.
#   [B4] BASELINE WINDOW = 2011-2013 (first three years of the 2011-2023 outcome
#        panel). The moderator series (SAHIE, ACS median income, hospital panel)
#        all begin in 2011; climate treatment is RECURRENT (no clean pre-period),
#        so the earliest three panel years are the most pre-treatment anchor
#        available. Time-invariant moderators (SVI_static) are used as-is.
#   [B5] DEDUP STOPGAP + "pre-dedup" LABEL.  This runs before thesis_completion 2.2
#        lands, so the pre-spec directs applying run_premium_mediation.R's dedup
#        stopgap and labelling outputs "pre-dedup". The ~428 duplicate county-years
#        (RA splits) are collapsed to one row/county-year by first() (verified:
#        Medical_Debt_Share, the shock lags, and Population are CONSTANT within
#        fips x Year, so first() is lossless for every variable used here). Refresh
#        after 2.2 enforces uniqueness upstream.
#
# INPUTS
#   Data/county_level_master.csv          (outcomes, shocks + precomputed lags, Pop)
#   Data/intermediate_sahie.rds           (18-64 uninsured rate, 2011-2023)
#   Data/intermediate_svi.rds             (SVI_static)
#   Data/intermediate_hospital_panel.rds  (NASHP HCT hospital-year -> county)
# OUTPUTS
#   Analysis/latent_hardship/latent_hardship_gradients.csv   (full 20-cell grid x
#                                                             weighting, + q-values)
#   Analysis/latent_hardship/latent_hardship_summary.md
#   Analysis/latent_hardship/build_logs/run_latent_hardship.log
#
# DATA PROVENANCE:  county master (Urban Institute medical debt; NOAA climate
#   shocks), Census SAHIE, CDC/ATSDR SVI, NASHP Hospital Cost Tool — see
#   conductor/knowledge/data-pipeline.md.  Medical debt is MEASUREMENT-FRAGILE
#   (that fragility is precisely the object under study here).
# ENVIRONMENT:  main R 4.2.2.
#   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/run_latent_hardship.R
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(readr); library(fixest)
})

# ---------------------------------------------------------------------------
# PURE HELPERS  (sourced + unit-tested by Code/tests/test_latent_hardship.R;
#                the guarded main block below does not run when sourced)
# ---------------------------------------------------------------------------

# Zero-pad a FIPS to width 5 via formatC on the INTEGER value. NOT sprintf("%05s")
# — that pads with SPACES and silently drops ~316 single-digit-state counties
# (CLAUDE.md silent-corruption trap).
pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

# z-score with NA handling. Returns a vector of the same length; NA in -> NA out.
zscore <- function(x) {
  m <- mean(x, na.rm = TRUE); s <- sd(x, na.rm = TRUE)
  if (!is.finite(s) || s == 0) return(rep(NA_real_, length(x)))
  (x - m) / s
}

# baseline_window_mean(): per-id mean of `value` over the baseline `years`.
# Returns a data.frame(id, <value_name>) — one time-invariant row per id. An id
# with no non-NA value in the window yields NA (not NaN).
baseline_window_mean <- function(df, value, years, id = "fips_code",
                                 year = "Year", value_name = value) {
  d <- df[df[[year]] %in% years, c(id, value), drop = FALSE]
  ag <- tapply(d[[value]], d[[id]], function(v) {
    m <- mean(v, na.rm = TRUE); if (is.nan(m)) NA_real_ else m
  })
  out <- data.frame(id = names(ag), val = as.numeric(ag), stringsAsFactors = FALSE)
  names(out) <- c(id, value_name)
  out
}

# dedup_county_year(): collapse the ~428 RA-split duplicate county-years to one
# row per fips x Year by first() of every column. first() is lossless here because
# every variable used downstream (medical-debt outcomes, county-level climate-shock
# lags, Population, State, income) is CONSTANT within a fips x Year group (verified
# 2026-07-12). Stopgap for thesis_completion 2.2; outputs are labelled "pre-dedup".
dedup_county_year <- function(df, id = "fips_code", year = "Year") {
  df %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(c(id, year)))) %>%
    dplyr::summarise(dplyr::across(dplyr::everything(), dplyr::first),
                     .groups = "drop")
}

# BKY (2006) two-stage adaptive step-up "sharpened" q-values — the exact machinery
# from run_mechanism_multipletesting.R (Anderson's sharpened q; hand-rolled because
# mutoss needs Bioconductor). Estimates the number of true nulls at stage 1, scales
# BH q-values by m0/m at stage 2.
bky_qvalues <- function(p, alpha = 0.05) {
  keep <- which(!is.na(p)); q <- rep(NA_real_, length(p))
  pp <- p[keep]; m <- length(pp)
  if (m == 0) return(q)
  o <- order(pp); po <- pp[o]
  ap <- alpha / (1 + alpha); crit <- (seq_len(m) / m) * ap
  r1 <- suppressWarnings(max(which(po <= crit))); r1 <- if (is.finite(r1)) r1 else 0
  m0 <- m - r1
  qq <- rev(cummin(rev(po * m / (seq_len(m) * pmax(m0, 1) / m))))
  qout <- numeric(m); qout[o] <- pmin(qq, 1)
  q[keep] <- qout; q
}

# The frozen shock cells: base shock name, its full contemporaneous+lag family
# (the established debt spec always enters all three together), and the single
# debt-relevant TARGET lag term reported/tested per the pre-spec.
shock_cells <- function() {
  list(
    cold_L1 = list(shock = "cold", base = "High_HDD",
                   family = c("High_HDD", "High_HDD_Lag1", "High_HDD_Lag2"),
                   target = "High_HDD_Lag1"),
    drought_L2 = list(shock = "drought", base = "Is_Extreme_Drought",
                      family = c("Is_Extreme_Drought", "Is_Extreme_Drought_Lag1",
                                 "Is_Extreme_Drought_Lag2"),
                      target = "Is_Extreme_Drought_Lag2")
  )
}

# The five moderators + orientation. higher_is_worse = TRUE means HIGHER moderator
# = weaker institutional visibility/access (uninsurance, rurality, SVI); for those
# the attenuation hypothesis predicts the interaction OPPOSITE in sign to the main
# effect. higher_is_worse = FALSE (hospital access, income) predicts the SAME sign
# (the response strengthens where access/income is greater, attenuates where scarce).
moderator_meta <- function() {
  data.frame(
    moderator       = c("Uninsured_z", "Rurality_z", "HospAccess_z",
                        "BaseIncome_z", "SVI_z"),
    label           = c("SAHIE uninsured 18-64 (baseline mean)",
                        "Rurality (neg-log baseline pop; RUCC proxy [B1])",
                        "Hospital access (log1p baseline hosp count [B2])",
                        "Baseline median HH income (real)",
                        "SVI (static baseline [B3])"),
    family          = c("primary", "primary", "primary", "secondary", "secondary"),
    higher_is_worse = c(TRUE, TRUE, FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
}

# attenuates(): does the interaction attenuate the shock main effect toward zero,
# in the direction the moderator's orientation predicts?  For higher_is_worse
# moderators, attenuation = interaction sign OPPOSITE the main effect; otherwise
# attenuation = interaction sign SAME as the main effect. NA if either coef is NA
# or the main effect is ~0 (no effect to attenuate).
attenuates <- function(main, inter, higher_is_worse) {
  if (is.na(main) || is.na(inter) || main == 0) return(NA)
  same_sign <- sign(main) == sign(inter)
  if (higher_is_worse) !same_sign else same_sign
}

# fit_gradient_cell(): fit the established debt spec with the full shock family and
# its moderator interactions, cluster on State, county+Year FE, optionally
# population-weighted; return the TARGET-lag main effect and its moderator
# interaction. The time-invariant moderator itself is absorbed by county FE (so it
# is not entered as a standalone term — matches the SAHIE-bridge pattern).
fit_gradient_cell <- function(dat, outcome, cell, modname, weighted) {
  inter <- paste0(cell$family, ":", modname)
  rhs   <- paste(c(cell$family, inter), collapse = " + ")
  f     <- stats::as.formula(paste(outcome, "~", rhs, "| fips_code + Year"))
  m <- tryCatch(
    if (weighted) fixest::feols(f, data = dat, weights = ~Population, cluster = ~State)
    else          fixest::feols(f, data = dat, cluster = ~State),
    error = function(e) { cat("    fit error:", conditionMessage(e), "\n"); NULL })
  if (is.null(m)) return(NULL)
  ct <- fixest::coeftable(m)
  get <- function(term, col) if (term %in% rownames(ct)) ct[term, col] else NA_real_
  tt <- cell$target; it <- paste0(tt, ":", modname)
  data.frame(
    main_effect    = get(tt, "Estimate"), main_se = get(tt, "Std. Error"),
    main_p         = get(tt, 4),
    interaction    = get(it, "Estimate"), se_interaction = get(it, "Std. Error"),
    p_interaction  = get(it, 4),
    N = m$nobs, stringsAsFactors = FALSE)
}

# ---------------------------------------------------------------------------
# MAIN  (guarded so sourcing for tests does not run the analysis)
# ---------------------------------------------------------------------------
if (sys.nframe() == 0L) {

  OUT <- "Analysis/latent_hardship"
  dir.create(file.path(OUT, "build_logs"), showWarnings = FALSE, recursive = TRUE)
  logcon <- file(file.path(OUT, "build_logs", "run_latent_hardship.log"), open = "wt")
  sink(logcon, split = TRUE); sink(logcon, type = "message")
  on.exit({ sink(type = "message"); sink(); close(logcon) }, add = TRUE)
  cat("=== O6 latent hardship (PRE-REGISTERED; pre-dedup) ::",
      format(Sys.time()), "===\n\n")

  BASELINE_YEARS <- 2011:2013
  ANALYSIS_YEARS <- 2011:2023

  # --- load county master, FIPS-pad, CO-2023 debt exclusion, window --------
  raw <- read_csv("Data/county_level_master.csv", show_col_types = FALSE,
                  progress = FALSE)
  raw$fips_code <- pad_fips(raw$fips_code)
  co23 <- !is.na(raw$State) & toupper(trimws(raw$State)) == "CO" &
          !is.na(raw$Year)  & as.integer(raw$Year) == 2023L
  raw$Medical_Debt_Share[co23]       <- NA_real_       # CO HB23-1126 (CLAUDE.md)
  raw$Medical_Debt_Median_2023[co23] <- NA_real_
  cat(sprintf("CO-2023 debt-reporting exclusion applied to %d rows.\n", sum(co23)))
  raw <- raw %>% filter(Year >= min(ANALYSIS_YEARS), Year <= max(ANALYSIS_YEARS))

  keep_cols <- c("fips_code", "Year", "State", "Population",
                 "Medical_Debt_Share", "Medical_Debt_Median_2023",
                 "Med_HH_Income_Real",
                 unlist(lapply(shock_cells(), `[[`, "family")))
  keep_cols <- unique(intersect(keep_cols, names(raw)))
  panel <- raw[, keep_cols, drop = FALSE]

  # --- dedup stopgap [B5]: one row per fips x Year -------------------------
  ndup <- panel %>% count(fips_code, Year) %>% filter(n > 1) %>% nrow()
  panel <- dedup_county_year(panel)
  stopifnot(!any(duplicated(panel[, c("fips_code", "Year")])))
  cat(sprintf("Deduped %d duplicate county-year groups -> %d unique fips x Year rows.\n",
              ndup, nrow(panel)))
  panel$State <- as.factor(panel$State)

  # --- build BASELINE, TIME-INVARIANT moderators --------------------------
  # (1) SAHIE uninsured 18-64, baseline-window mean
  sahie <- readRDS("Data/intermediate_sahie.rds")
  sahie$fips_code <- pad_fips(sahie$fips_code)
  m_unins <- baseline_window_mean(sahie, "Uninsured_18_64", BASELINE_YEARS,
                                  value_name = "Uninsured_base")
  # (2) Rurality = -log baseline-window mean Population [B1]
  m_pop <- baseline_window_mean(panel, "Population", BASELINE_YEARS,
                                value_name = "Pop_base")
  m_pop$Rurality_raw <- -log(m_pop$Pop_base)
  # (3) Hospital access = log1p distinct-CCN count in baseline window [B2]
  hp <- readRDS("Data/intermediate_hospital_panel.rds")
  hp$fips_code <- pad_fips(hp$fips_code)
  hp_cnt <- hp %>%
    filter(Year %in% BASELINE_YEARS, !is.na(fips_code)) %>%
    distinct(fips_code, CCN) %>% count(fips_code, name = "hosp_n")
  # (4) Baseline median HH income (real), baseline-window mean
  m_inc <- baseline_window_mean(panel, "Med_HH_Income_Real", BASELINE_YEARS,
                                value_name = "Income_base")
  # (5) SVI_static [B3]
  svi <- readRDS("Data/intermediate_svi.rds")
  svi$fips_code <- pad_fips(svi$fips_code)
  m_svi <- svi %>% distinct(fips_code, SVI_static)

  # assemble one county-level moderator table, then z-score across counties
  mod_tbl <- data.frame(fips_code = unique(panel$fips_code),
                        stringsAsFactors = FALSE) %>%
    left_join(m_unins, by = "fips_code") %>%
    left_join(m_pop[, c("fips_code", "Rurality_raw")], by = "fips_code") %>%
    left_join(hp_cnt, by = "fips_code") %>%
    left_join(m_inc, by = "fips_code") %>%
    left_join(m_svi, by = "fips_code")
  mod_tbl$hosp_n[is.na(mod_tbl$hosp_n)] <- 0L   # absent-from-panel -> 0 [B2 caveat]

  mod_tbl$Uninsured_z  <- zscore(mod_tbl$Uninsured_base)
  mod_tbl$Rurality_z   <- zscore(mod_tbl$Rurality_raw)
  mod_tbl$HospAccess_z <- zscore(log1p(mod_tbl$hosp_n))
  mod_tbl$BaseIncome_z <- zscore(mod_tbl$Income_base)
  mod_tbl$SVI_z        <- zscore(mod_tbl$SVI_static)

  meta <- moderator_meta()
  for (mz in meta$moderator) {
    v <- mod_tbl[[mz]]
    cat(sprintf("  moderator %-13s: non-NA counties = %4d | mean = %+.3f | sd = %.3f\n",
                mz, sum(!is.na(v)), mean(v, na.rm = TRUE), sd(v, na.rm = TRUE)))
  }
  panel <- left_join(panel,
                     mod_tbl[, c("fips_code", meta$moderator)], by = "fips_code")

  # --- fit the grid: 2 shocks x 5 moderators x 2 outcomes x {wtd, unwtd} ---
  cells   <- shock_cells()
  outcomes <- c(Medical_Debt_Share = "primary",
                Medical_Debt_Median_2023 = "secondary")
  rows <- list()
  for (wtd in c(TRUE, FALSE)) {
    for (oc in names(outcomes)) {
      for (cn in names(cells)) {
        cell <- cells[[cn]]
        for (mz in meta$moderator) {
          # complete-case sample for THIS cell (no-NA leakage): outcome + shock
          # family + interactions' moderator + FE ids (+ Population if weighted)
          need <- c(oc, cell$family, mz, "fips_code", "Year", "State")
          if (wtd) need <- c(need, "Population")
          dat <- panel[stats::complete.cases(panel[, need, drop = FALSE]), ,
                       drop = FALSE]
          fit <- fit_gradient_cell(dat, oc, cell, mz, weighted = wtd)
          if (is.null(fit)) next
          hw <- meta$higher_is_worse[meta$moderator == mz]
          rows[[length(rows) + 1]] <- data.frame(
            weighting     = if (wtd) "population" else "unweighted",
            outcome       = oc,
            outcome_family = unname(outcomes[oc]),
            shock         = cell$shock,
            shock_cell    = cn,
            target_term   = cell$target,
            moderator     = mz,
            moderator_family = meta$family[meta$moderator == mz],
            higher_is_worse  = hw,
            fit,
            attenuates    = attenuates(fit$main_effect, fit$interaction, hw),
            stringsAsFactors = FALSE)
        }
      }
    }
  }
  grid <- bind_rows(rows)

  # --- sharpened q over the full 20-cell grid, WITHIN each weighting -------
  # (the pre-spec's "full 20-cell grid (2x5x2)" is one weighting's interaction set;
  #  the decision rule reads the population-weighted primary grid)
  grid$q_bky <- NA_real_
  for (w in unique(grid$weighting)) {
    idx <- which(grid$weighting == w)
    grid$q_bky[idx] <- bky_qvalues(grid$p_interaction[idx])
  }
  grid$sig_q10 <- !is.na(grid$q_bky) & grid$q_bky < 0.10
  grid$attenuates_sig_q10 <- !is.na(grid$attenuates) & grid$attenuates & grid$sig_q10

  # round for storage but keep full precision available upstream
  num_cols <- c("main_effect", "main_se", "main_p", "interaction",
                "se_interaction", "p_interaction", "q_bky")
  grid_out <- grid
  grid_out[num_cols] <- lapply(grid_out[num_cols], function(x) signif(x, 5))
  write_csv(grid_out, file.path(OUT, "latent_hardship_gradients.csv"))
  cat(sprintf("\nWrote %d-row gradient grid (2 shocks x 5 mods x 2 outcomes x 2 weightings).\n",
              nrow(grid_out)))

  # --- PRIMARY family (pop-wtd, Medical_Debt_Share, 3 primary moderators) --
  prim <- grid %>% filter(weighting == "population",
                          outcome == "Medical_Debt_Share",
                          moderator_family == "primary")
  cat("\n--- PRIMARY 6-cell family (pop-weighted; Medical_Debt_Share) ---\n")
  print(prim %>% mutate(across(c(main_effect, interaction, se_interaction,
                                 p_interaction, q_bky), ~signif(.x, 3))) %>%
          select(shock, moderator, main_effect, interaction, se_interaction,
                 p_interaction, q_bky, attenuates, sig_q10),
        row.names = FALSE)

  # --- DECISION RULE: >=2/3 primary moderators attenuate at q<0.10 with -----
  #     consistent signs, for at least one shock cell ------------------------
  per_shock <- prim %>% group_by(shock) %>%
    summarise(n_attenuating_q10 = sum(attenuates_sig_q10, na.rm = TRUE),
              mods_hit = paste(moderator[which(attenuates_sig_q10)], collapse = ", "),
              .groups = "drop")
  cat("\n--- decision-rule tally (primary family, per shock) ---\n")
  print(as.data.frame(per_shock), row.names = FALSE)
  positive_contribution <- any(per_shock$n_attenuating_q10 >= 2)
  verdict <- if (positive_contribution)
    "POSITIVE CONTRIBUTION (latent-hardship): >=2/3 primary moderators attenuate at q<0.10 for >=1 shock."
  else
    "HONEST NULL: the >=2/3-at-q<0.10 bar is NOT cleared; medical debt stays a caveat."
  cat("\nVERDICT:", verdict, "\n")

  # --- expected-sign check (a priori) --------------------------------------
  exp_ok <- prim %>%
    summarise(cells = n(),
              attenuating = sum(attenuates %in% TRUE),
              contradicting = sum(attenuates %in% FALSE))
  cat(sprintf("Expected-sign check (primary family): %d/%d cells attenuate as predicted; %d contradict.\n",
              exp_ok$attenuating, exp_ok$cells, exp_ok$contradicting))

  # --- SANITY: reproduce the established SAHIE-bridge sign (unweighted, cold)
  sahie_cold <- grid %>% filter(weighting == "unweighted",
                                outcome == "Medical_Debt_Share",
                                moderator == "Uninsured_z", shock == "cold")

  # -----------------------------------------------------------------------
  # Summary markdown
  # -----------------------------------------------------------------------
  fmt <- function(d) d %>% mutate(across(where(is.numeric), ~signif(.x, 3)))
  prim_tbl <- prim %>%
    select(shock, moderator, main_effect, interaction, se_interaction,
           p_interaction, q_bky, attenuates, sig_q10)
  sec_tbl <- grid %>% filter(weighting == "population",
                             moderator_family == "secondary" |
                               outcome == "Medical_Debt_Median_2023") %>%
    select(outcome, shock, moderator, main_effect, interaction, se_interaction,
           p_interaction, q_bky, attenuates, sig_q10)

  md <- c(
    "# Observed vs Latent Hardship — Gradient Summary (O6)",
    "",
    sprintf("_Generated %s. PRE-REGISTERED design (spec.md Phase-3 pre-specification, dated 2026-07-12)._",
            format(Sys.Date())),
    "_Outputs labelled **pre-dedup**: run before thesis_completion 2.2; the run_premium_mediation.R",
    "dedup stopgap collapsed ~428 RA-split county-years to one row/county-year (lossless — the debt",
    "outcomes, shock lags, and Population are constant within fips x Year). Refresh after 2.2._",
    "",
    "**Question.** Does the measured climate-shock -> medical-debt response *shrink* where hardship is",
    "least observable to financial institutions (uninsurance, rurality, hospital scarcity, low income,",
    "high SVI)? If so, credit-bureau debt understates harm where access/visibility is weakest.",
    "",
    "**Spec.** Established county debt spec (`fixest::feols`, county + Year FE, STATE-clustered SEs) +",
    "shock x moderator interaction; the full contemporaneous+L1+L2 shock family is entered and the",
    "debt-relevant TARGET lag is reported (cold -> L1; drought -> L2). POPULATION-WEIGHTED is primary;",
    "unweighted is robustness. Moderators are z-scored at BASELINE (2011-2013 window), time-invariant.",
    "Multiplicity: BKY (2006) sharpened q-values over the full 20-cell grid (2 shocks x 5 moderators x",
    "2 outcomes) within each weighting.",
    "",
    "## Implementation bindings (frozen elements bound to available data)",
    "- **Rurality (RUCC)** — RUCC absent from the repo; bound to z(-log baseline population) [B1].",
    "- **Hospital access** — z(log1p distinct-CCN count in county, 2011-2013); absent-from-NASHP -> 0 [B2].",
    "- **SVI** — `SVI_static` (repo's time-invariant baseline SVI) [B3].",
    "- **Baseline window** — 2011-2013 [B4]. **Dedup** — first() stopgap, pre-dedup label [B5].",
    "",
    "## Decision rule",
    sprintf("**%s**", verdict),
    "",
    "Rule (binding for permitted language): 'positive contribution' framing only if >=2 of 3 primary",
    "moderators (uninsurance, rurality, hospital access) show attenuation at q<0.10 with consistent",
    "signs for at least one shock cell; else the honest null. Claim tier capped at **mechanism-supporting**.",
    "",
    "Per-shock tally (primary family, population-weighted, Medical_Debt_Share):",
    knitr::kable(as.data.frame(per_shock), format = "pipe"),
    "",
    sprintf("Expected-sign check: %d of %d primary cells attenuate in the a-priori-predicted direction; %d contradict.",
            exp_ok$attenuating, exp_ok$cells, exp_ok$contradicting),
    "",
    "## PRIMARY family — population-weighted, `Medical_Debt_Share` (6 cells)",
    "`attenuates` = interaction shrinks the shock main effect toward zero in the moderator's predicted",
    "direction (opposite-signed for uninsurance/rurality; same-signed for hospital access). q = BKY",
    "sharpened q over the 20-cell weighted grid.",
    knitr::kable(fmt(prim_tbl), format = "pipe"),
    "",
    "## SECONDARY grid — population-weighted (secondary moderators and/or `Medical_Debt_Median_2023`)",
    knitr::kable(fmt(sec_tbl), format = "pipe"),
    "",
    "## Notes & reading",
    "- Medical debt is **measurement-fragile** by construction (credit file + insurance + billed",
    "  encounter required); this analysis tests whether that fragility is *systematic* along access/",
    "  visibility gradients. A clean attenuation pattern would convert the caveat into a finding; a",
    "  null leaves debt as a caveat and the real-economy (income/employment) results as the lead.",
    "- The full 40-row grid (both weightings) with q-values is in `latent_hardship_gradients.csv`.",
    "- Unweighted results are robustness only; the decision rule reads the population-weighted primary.",
    "",
    "## Parking lot (pre-spec: further ideas go here, NOT into this analysis)",
    "- Additional moderators (energy burden, ag dependence, %<138% FPL uninsured), more lags/hazards,",
    "  nonlinearity in the gradient, an actual RUCC/land-area rurality measure, and a per-capita vs",
    "  count hospital-access sensitivity are Phase-4 items, gated on Tier-1 essay drafts existing.")
  writeLines(md, file.path(OUT, "latent_hardship_summary.md"))

  cat("\nWrote gradients.csv + summary.md.\n=== done", format(Sys.time()), "===\n")
}
