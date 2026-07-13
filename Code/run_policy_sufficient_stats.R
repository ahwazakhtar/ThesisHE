# =============================================================================
# run_policy_sufficient_stats.R
# Track: thesis_completion_20260704, task 2.3 (T1.3, as amended 2026-07-12).
# ENV: main R 4.2.2 (C:/Program Files/R/R-4.2.2/bin/Rscript.exe).
# Run: Rscript Code/run_policy_sufficient_stats.R
# =============================================================================
#
# PURPOSE. The bounded "sufficient-statistics" policy synthesis (the honest,
# tractable descendant of the retired structural Chapter 3). It converts the
# project's *hardened* coefficients into policy-scale quantities WITHOUT any new
# identification. Every aggregate is per-unit-coefficient x exposed-count with a
# delta-method error band from the coefficient's own SE/CI. NO welfare model, NO
# new regression.
#
# BINDING DISCIPLINE (spec T1.3 Amendment 2026-07-12; audit
# `Plans/project_audit_research_questions_20260712.md` "High alpha: quantify
# burden concentration"; writing plan `dissertation_writing_and_framing_plan_
# 20260712.md` sec 9). Read these before touching this file:
#   (1) Component (a), "the unpriced margin", is RE-BASED on the measured Medicare
#       morbidity cost (Row 10) bounded by the certified premium equivalence
#       result (Row 8) -- NOT on aggregating premium coefficients into mispricing
#       dollars. The premium mediation (T1.1) found NO coherent pass-through and
#       sign-unstable premium coefficients, so multiplying premium betas by
#       enrollment is exactly the negative-alpha move the audit forbids. This
#       script therefore NEVER multiplies a premium coefficient by enrollment.
#   (2) Component (b) reports SCENARIO BANDS, each standalone, each with an honest
#       estimand label. A single national causal welfare TOTAL is never formed
#       (the strongest coefficient, the 2012 income ATT, is event-specific).
#       Bands are never summed into one number and never averaged across
#       incompatible estimands (dollars / jobs / people / Medicare $ stay
#       separate).
#   (3) Every input coefficient is read from its certified source file AND checked
#       against a hard-coded certified anchor (verify_anchors()). A mismatch STOPS
#       the run -- the master evidence table (`Plans/master_evidence_table.md`,
#       status FROZEN-READY) may have moved and the number must be re-traced.
#
# INPUT COEFFICIENTS (source file -> evidence-table row):
#   * 2012 drought income ATT (Row 1, H1):
#       Analysis/did/robustness/wild_bootstrap_2x2.csv  (ITT -$1,311, WCB CI)
#       Analysis/did/robustness/dr_2x2_drought_2012.csv (DRDID -$1,451 alt)
#   * typical multi-cohort drought income (Row 1): dr_csdid_eventtime.csv (e=0
#       -$324), dr_csdid_drought.csv (long-run +$350) -- the bounded null.
#   * cold cumulative-dose employment (Row 17, H3):
#       Analysis/cumulative_dose/cumulative_dose_marginal.csv (10+ vs 1-3 = -5,522)
#   * drought debt scar (Row 16): Analysis/delta/delta_symmetry_test.csv
#       (onset+exit asymmetry, h=2, unweighted = +0.01874)
#   * Medicare morbidity $ (Row 10, H2): Analysis/mechanism/medicare_channel_coefs.csv
#       (heat High_CDD +$112 / L1 +$177; cold High_HDD_Lag2 +$85, per beneficiary-yr)
#   * ACA premium equivalence bound (Row 8, H4): Analysis/mediation/passthrough_bounds.csv
#       (drought delta*=$7.40 PMPM vs full-morbidity benchmark $9.33-$14.75 PMPM)
#
# EXPOSED-COUNT SOURCES (all computed live from the certified county master):
#   * 139 first-onset 2012 drought cohort (did_robustness cohort construction).
#   * counties reaching 10+ cumulative High_HDD years (cumulative_dose machinery).
#   * ever-extreme-drought counties (debt-scar population base).
#   * Medicare beneficiaries in High_CDD / High_HDD county-years (CMS PUF, 2014-23).
#   * RMA drought/total crop-insurance indemnities to the treated counties.
#
# DATA GAP (documented, not hidden): the medical-debt SHARE denominator is the
# credit-VISIBLE population (Urban Institute credit-bureau snapshots), which is
# not in the master. The primary debt-scar band uses total resident Population as
# a transparent UPPER BOUND; a labeled sensitivity row applies a documented
# national credit-visible fraction (CREDIT_VISIBLE_FRAC). See notes on that band.
#
# OUTPUTS (all under Analysis/policy/):
#   sufficient_stats.csv        - one tidy long table: bands + Medicare lag
#                                 variants + DRDID alt + unpriced-floor rows +
#                                 RMA-framing rows + concentration rows.
#   concentration_curve.csv     - per-band county-sorted-by-vulnerability curve
#                                 (cum population share vs cum burden share) for a
#                                 figure, plus a descriptive heat-exposure curve.
#   sufficient_stats_summary.md - structured numeric summary for the writer (task
#                                 2.4/2.5 consumes this; the prose write-up is a
#                                 separate later task).
#   build_logs/run_policy_sufficient_stats.log - provenance + full console echo.
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
})

source("Code/pipeline_utils.R")    # pad_fips(), open_build_log()  (blessed helpers)
source("Code/cumulative_dose.R")   # add_cumulative_shock_years()

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
Z95 <- qnorm(0.975)                # 1.959964: two-sided 95% delta-method band
ANALYSIS_WINDOW <- c(2011L, 2023L) # outcome analysis window (county master)
MEDICARE_WINDOW <- c(2014L, 2023L) # CMS Geographic Variation PUF span

# Credit-visible fraction of total resident population (debt-scar sensitivity).
# Transparent national approximation: US adults ~= 77% of population (Census) and
# ~= 89% of adults have a scoreable credit file (CFPB "credit invisibles" ~= 11%),
# so credit-visible ~= 0.77 * 0.89 ~= 0.685. Applied uniformly -- a labeled
# sensitivity, NOT the primary base (see the debt-scar band).
CREDIT_VISIBLE_FRAC <- 0.685

MASTER_PATH <- "Data/county_level_master.csv"
OUT_DIR     <- "Analysis/policy"

# -----------------------------------------------------------------------------
# Certified anchors (hard-coded from Plans/master_evidence_table.md + the
# certified source outputs). verify_anchors() reads the live source files and
# STOPS if any has drifted beyond tolerance.
# Each entry: file, a locator function returning the found value, expected, tol.
# -----------------------------------------------------------------------------
ANCHOR_TOL <- 1e-3                 # relative tolerance for the anchor check

read_csv_base <- function(path) {
  if (!file.exists(path)) stop("Missing required input: ", path)
  utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

# Locators (pure; used by both main() and the test suite) -----------------------
locate_medicare <- function(med = read_csv_base("Analysis/mechanism/medicare_channel_coefs.csv"),
                            shock, term, outcome = "Mdcr_Std_Payment_PC") {
  # Mdcr_Std_Payment_PC = price-standardized per-beneficiary spending (the $ cost
  # the premium comparison is anchored on). shock/spec/term alone match multiple
  # outcomes (ED visits, IP stays, ...), so the outcome filter is required.
  r <- med[med$outcome == outcome & med$shock == shock & med$spec == "overall" & med$term == term, ]
  if (nrow(r) != 1) stop("medicare anchor not uniquely found: ", outcome, "/", shock, "/", term)
  list(estimate = as.numeric(r$estimate), se = as.numeric(r$se), p = as.numeric(r$p))
}
locate_passthrough <- function(pb = read_csv_base("Analysis/mediation/passthrough_bounds.csv")) {
  r <- pb[pb$outcome_role == "primary" & pb$hazard == "Drought" & pb$lag == "L2", ]
  if (nrow(r) != 1) stop("passthrough drought-L2 primary anchor not uniquely found")
  list(delta_star = as.numeric(r$delta_star), bench_lo = as.numeric(r$bench_lo),
       bench_hi = as.numeric(r$bench_hi), beta = as.numeric(r$beta),
       se = as.numeric(r$se), mean_premium = as.numeric(r$mean_premium),
       verdict = r$verdict)
}
locate_colddose <- function(cd = read_csv_base("Analysis/cumulative_dose/cumulative_dose_marginal.csv")) {
  r <- cd[cd$shock == "HDD" & cd$outcome == "Civilian_Employed" &
          cd$weighting == "Unweighted" & cd$quantity == "binned_10plus_minus_1to3", ]
  if (nrow(r) != 1) stop("cold cumulative-dose anchor not uniquely found")
  list(estimate = as.numeric(r$estimate), se = as.numeric(r$std.error), p = as.numeric(r$p.value))
}
locate_debtscar <- function(ds = read_csv_base("Analysis/delta/delta_symmetry_test.csv")) {
  r <- ds[ds$shock == "Drought" & ds$outcome == "Medical_Debt_Share" &
          ds$horizon == 2 & ds$weighting == "Unweighted", ]
  if (nrow(r) != 1) stop("drought debt-scar anchor not uniquely found")
  list(estimate = as.numeric(r$asymmetry), se = as.numeric(r$std.error), p = as.numeric(r$p.value))
}
locate_did2012 <- function(wb = read_csv_base("Analysis/did/robustness/wild_bootstrap_2x2.csv")) {
  r <- wb[wb$Event == "Drought_2012" & wb$Outcome == "PCPI_Real", ]
  if (nrow(r) != 1) stop("2012 ITT anchor not uniquely found")
  list(att = as.numeric(r$ATT), se = as.numeric(r$SE_analytic),
       wcb_lo = as.numeric(r$wcb_ci_lo), wcb_hi = as.numeric(r$wcb_ci_hi),
       p_wcb = as.numeric(r$p_wcb_webb))
}
locate_drdid <- function(dr = read_csv_base("Analysis/did/robustness/dr_2x2_drought_2012.csv")) {
  r <- dr[dr$Estimator == "DRDID_2x2" & dr$Outcome == "PCPI_Real", ]
  if (nrow(r) != 1) stop("DRDID 2012 anchor not uniquely found")
  list(att = as.numeric(r$ATT), se = as.numeric(r$SE),
       ci_lo = as.numeric(r$ci_lo), ci_hi = as.numeric(r$ci_hi))
}
locate_pooled_e0 <- function(et = read_csv_base("Analysis/did/robustness/dr_csdid_eventtime.csv")) {
  r <- et[et$Outcome == "PCPI_Real" & et$Event_Time == 0, ]
  if (nrow(r) != 1) stop("pooled e=0 anchor not uniquely found")
  list(att = as.numeric(r$ATT), se = as.numeric(r$SE))
}
locate_pooled_lr <- function(cs = read_csv_base("Analysis/did/robustness/dr_csdid_drought.csv")) {
  r <- cs[cs$Estimator == "CS_dr_simple" & cs$Outcome == "PCPI_Real", ]
  if (nrow(r) != 1) stop("pooled long-run anchor not uniquely found")
  list(att = as.numeric(r$ATT), se = as.numeric(r$SE))
}

# The frozen expected values (Plans/master_evidence_table.md). If a source file
# moves, verify_anchors() reports the mismatch and main() stops.
CERTIFIED_ANCHORS <- list(
  medicare_heat_t0 = list(getter = function() locate_medicare(shock = "CDD", term = "High_CDD")$estimate,       expected = 111.620936, row = "Row 10"),
  medicare_heat_l1 = list(getter = function() locate_medicare(shock = "CDD", term = "High_CDD_Lag1")$estimate,  expected = 175.576630, row = "Row 10"),
  medicare_cold_l2 = list(getter = function() locate_medicare(shock = "HDD", term = "High_HDD_Lag2")$estimate,  expected = 86.787960,  row = "Row 10"),
  passthrough_deltastar = list(getter = function() locate_passthrough()$delta_star, expected = 7.404866,  row = "Row 8"),
  passthrough_bench_lo  = list(getter = function() locate_passthrough()$bench_lo,   expected = 9.333333,  row = "Row 8"),
  passthrough_bench_hi  = list(getter = function() locate_passthrough()$bench_hi,   expected = 14.75,     row = "Row 8"),
  cold_dose_binned      = list(getter = function() locate_colddose()$estimate,      expected = -5522.02202, row = "Row 17"),
  debt_scar             = list(getter = function() locate_debtscar()$estimate,      expected = 0.0187376850, row = "Row 16"),
  did2012_itt           = list(getter = function() locate_did2012()$att,            expected = -1310.665380, row = "Row 1"),
  did2012_drdid         = list(getter = function() locate_drdid()$att,              expected = -1451.268144, row = "Row 1"),
  pooled_e0             = list(getter = function() locate_pooled_e0()$att,          expected = -324.397359,  row = "Row 1"),
  pooled_longrun        = list(getter = function() locate_pooled_lr()$att,          expected = 349.768763,   row = "Row 1")
)

verify_anchors <- function(tol = ANCHOR_TOL) {
  rows <- lapply(names(CERTIFIED_ANCHORS), function(nm) {
    a <- CERTIFIED_ANCHORS[[nm]]
    found <- tryCatch(a$getter(), error = function(e) NA_real_)
    denom <- max(abs(a$expected), 1e-8)
    ok <- is.finite(found) && (abs(found - a$expected) / denom <= tol)
    data.frame(anchor = nm, evidence_row = a$row, expected = a$expected,
               found = found, rel_diff = abs(found - a$expected) / denom,
               ok = ok, stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}

# -----------------------------------------------------------------------------
# Pure numeric helpers (unit-tested directly)
# -----------------------------------------------------------------------------

# Aggregation identity: an aggregate is ALWAYS per-unit coefficient x count.
aggregate_band <- function(per_unit, count) per_unit * count

# Delta-method band for aggregate = count * beta, count treated as fixed:
#   Var(count*beta) = count^2 * Var(beta) => SE_agg = |count| * SE_beta,
#   CI_agg = count * (beta +/- z * SE_beta).
# Returns per-unit and aggregate endpoints so the aggregate is exactly
# count * per-unit at every endpoint (keeps the aggregation identity intact).
delta_band <- function(point, se, count, z = Z95) {
  pu_lo <- point - z * se
  pu_hi <- point + z * se
  list(per_unit_lo = pu_lo, per_unit_hi = pu_hi,
       agg_point = aggregate_band(point, count),
       agg_lo    = aggregate_band(pu_lo, count),
       agg_hi    = aggregate_band(pu_hi, count),
       agg_se    = abs(count) * se)
}

# Concentration curve: sort counties by a vulnerability rank (most vulnerable
# first) and accumulate population and burden shares. `weight` (>= 0) is the
# county's contribution to the band's total burden; `pop` its population.
# Returns the Lorenz-style curve (cum_pop_share vs cum_burden_share).
concentration_curve <- function(fips, vuln, weight, pop) {
  keep <- is.finite(vuln) & is.finite(weight) & is.finite(pop) & weight >= 0 & pop >= 0
  fips <- fips[keep]; vuln <- vuln[keep]; weight <- weight[keep]; pop <- pop[keep]
  if (length(vuln) == 0 || sum(weight) <= 0 || sum(pop) <= 0)
    return(NULL)
  ord <- order(-vuln)                       # most vulnerable first
  fips <- fips[ord]; vuln <- vuln[ord]; weight <- weight[ord]; pop <- pop[ord]
  n <- length(vuln)
  data.frame(
    rank             = seq_len(n),
    fips             = fips,
    vuln             = vuln,
    cum_county_share = seq_len(n) / n,
    cum_pop_share    = cumsum(pop) / sum(pop),
    cum_burden_share = cumsum(weight) / sum(weight),
    stringsAsFactors = FALSE)
}

# Share of burden / population held by the top `frac` of counties (by
# vulnerability), from a concentration curve.
top_share <- function(curve, frac) {
  if (is.null(curve) || nrow(curve) == 0) return(c(county = NA, pop = NA, burden = NA))
  k <- max(1L, ceiling(frac * nrow(curve)))
  c(county = curve$cum_county_share[k], pop = curve$cum_pop_share[k],
    burden = curve$cum_burden_share[k])
}

# -----------------------------------------------------------------------------
# Data assembly (county master, cohorts, exposure counts)
# -----------------------------------------------------------------------------
load_inputs <- function() {
  df <- read_csv_base(MASTER_PATH)
  df$fips_code <- pad_fips(df$fips_code)
  df <- df[df$Year >= ANALYSIS_WINDOW[1] & df$Year <= ANALYSIS_WINDOW[2], ]

  # time-invariant county population base = mean over the analysis window.
  pop <- df %>% group_by(fips_code) %>%
    summarise(pop_mean = mean(Population, na.rm = TRUE), .groups = "drop")

  # SVI + energy-burden vulnerability inputs (join, time-invariant).
  svi <- readRDS("Data/intermediate_svi.rds")
  svi$fips_code <- pad_fips(svi$fips_code)
  svi <- svi %>% distinct(fips_code, SVI_static)
  eb <- readRDS("Data/intermediate_energy_burden.rds")
  eb$fips_code <- pad_fips(eb$fips_code)
  eb <- eb %>% distinct(fips_code, Energy_Burden_Pct)

  # Medicare beneficiary counts (2014-2023).
  med <- readRDS("Data/intermediate_medicare_spending.rds")
  med$fips_code <- pad_fips(med$fips_code)
  med <- med %>% select(fips_code, Year, Benes_Total)

  # RMA crop-insurance indemnities.
  rma <- readRDS("Data/intermediate_rma_indemnity.rds")
  rma$fips_code <- pad_fips(rma$fips_code)

  list(df = df, pop = pop, svi = svi, eb = eb, med = med, rma = rma)
}

# 2012 first-onset drought cohort (mirrors did_robustness build_cohorts()).
build_cohorts_local <- function(df) {
  df %>% filter(!is.na(Is_Extreme_Drought)) %>%
    group_by(fips_code) %>%
    summarise(first_event = suppressWarnings(min(Year[Is_Extreme_Drought == 1], na.rm = TRUE)),
              .groups = "drop") %>%
    mutate(first_event = ifelse(is.finite(first_event), first_event, NA_integer_),
           cohort = ifelse(is.na(first_event), 0L, as.integer(first_event)))
}

# Composite vulnerability proxy = mean of standardized SVI and standardized
# energy burden (equal weight). Higher = more vulnerable. Documented in-summary.
build_vuln <- function(pop, svi, eb) {
  v <- pop %>% left_join(svi, by = "fips_code") %>% left_join(eb, by = "fips_code")
  z <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
  v$svi_z <- z(v$SVI_static)
  v$eb_z  <- z(v$Energy_Burden_Pct)
  v$vuln_proxy <- rowMeans(cbind(v$svi_z, v$eb_z), na.rm = TRUE)
  v
}

# =============================================================================
# main()
# =============================================================================
main <- function() {
  dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)
  close_log <- open_build_log("policy", "run_policy_sufficient_stats")
  on.exit(close_log(), add = TRUE)

  cat("\n############ SUFFICIENT-STATISTICS POLICY SYNTHESIS ############\n")
  cat("Amendment 2026-07-12: (a) re-based on Medicare morbidity (NOT premium\n",
      "coefficient aggregation); (b) scenario bands, never one national total.\n\n", sep = "")

  # ---- 0. Anchor verification (STOP on drift) -------------------------------
  cat("== 0. Certified-anchor verification (source files vs frozen values) ==\n")
  anch <- verify_anchors()
  print(anch, row.names = FALSE, digits = 8)
  if (!all(anch$ok)) {
    stop("ANCHOR MISMATCH -- a certified coefficient has moved; re-trace against ",
         "Plans/master_evidence_table.md before citing:\n",
         paste(sprintf("  %s: expected %.6g, found %.6g", anch$anchor[!anch$ok],
                       anch$expected[!anch$ok], anch$found[!anch$ok]), collapse = "\n"))
  }
  cat("All", nrow(anch), "anchors match the frozen evidence table.\n\n")

  # ---- 1. Load coefficients from certified sources --------------------------
  med_heat_t0 <- locate_medicare(shock = "CDD", term = "High_CDD")
  med_heat_l1 <- locate_medicare(shock = "CDD", term = "High_CDD_Lag1")
  med_cold_l2 <- locate_medicare(shock = "HDD", term = "High_HDD_Lag2")
  pt          <- locate_passthrough()
  cold_dose   <- locate_colddose()
  debt_scar   <- locate_debtscar()
  did_itt     <- locate_did2012()
  did_drdid   <- locate_drdid()
  pooled_e0   <- locate_pooled_e0()
  pooled_lr   <- locate_pooled_lr()

  # ---- 2. Exposed counts (live from the certified master) -------------------
  cat("== 2. Exposed-count construction ==\n")
  inp <- load_inputs()
  df <- inp$df; pop <- inp$pop

  coh <- build_cohorts_local(df)
  treated2012 <- coh$fips_code[coh$cohort == 2012L]
  n_treated2012 <- length(treated2012)
  pop_2012 <- pop %>% filter(fips_code %in% treated2012)
  count_2012_pop <- sum(pop_2012$pop_mean, na.rm = TRUE)
  cat(sprintf("2012 first-onset cohort: %d counties, total mean-pop %s\n",
              n_treated2012, format(round(count_2012_pop), big.mark = ",")))

  # ever-extreme-drought counties (debt-scar base)
  ever_dr <- df %>% group_by(fips_code) %>%
    summarise(any_dr = any(Is_Extreme_Drought == 1, na.rm = TRUE), .groups = "drop") %>%
    filter(any_dr) %>% pull(fips_code)
  count_everdr_pop <- sum(pop$pop_mean[pop$fips_code %in% ever_dr], na.rm = TRUE)
  cat(sprintf("Ever-extreme-drought: %d counties, total mean-pop %s\n",
              length(ever_dr), format(round(count_everdr_pop), big.mark = ",")))

  # typical drought-year exposed population = avg annual pop in extreme drought
  dr_year <- df %>% filter(Is_Extreme_Drought == 1) %>% group_by(Year) %>%
    summarise(p = sum(Population, na.rm = TRUE), .groups = "drop")
  count_typical_dr_pop <- mean(dr_year$p)
  cat(sprintf("Typical drought-year exposed pop (avg annual): %s\n",
              format(round(count_typical_dr_pop), big.mark = ",")))

  # cold cumulative-dose: counties reaching 10+ cumulative High_HDD years
  df_hdd <- add_cumulative_shock_years(df, "High_HDD", "Cum_HDD_Years")
  maxdose <- df_hdd %>% group_by(fips_code) %>%
    summarise(mx = max(Cum_HDD_Years, na.rm = TRUE), .groups = "drop")
  cold10_fips <- maxdose$fips_code[maxdose$mx >= 10]
  count_cold10 <- length(cold10_fips)
  cat(sprintf("Cold cumulative-dose 10+ bin: %d counties (vs %d in the 1-3 bin)\n",
              count_cold10, sum(maxdose$mx >= 1 & maxdose$mx <= 3)))

  # Medicare exposed beneficiaries (avg annual) in heat/cold shock county-years
  dm <- df %>% filter(Year >= MEDICARE_WINDOW[1], Year <= MEDICARE_WINDOW[2]) %>%
    left_join(inp$med, by = c("fips_code", "Year"))
  benes_annual <- function(mask) {
    dm[mask, ] %>% group_by(Year) %>%
      summarise(b = sum(Benes_Total, na.rm = TRUE), .groups = "drop") %>%
      summarise(m = mean(b)) %>% pull(m)
  }
  count_benes_heat <- benes_annual(dm$High_CDD == 1 & !is.na(dm$High_CDD))
  count_benes_cold <- benes_annual(dm$High_HDD == 1 & !is.na(dm$High_HDD))
  cat(sprintf("Medicare exposed benes (avg annual): heat/High_CDD %s ; cold/High_HDD %s\n\n",
              format(round(count_benes_heat), big.mark = ","),
              format(round(count_benes_cold), big.mark = ",")))

  # per-county Medicare exposure weights (for concentration) = annualized
  # exposed beneficiary-years over the county's own shock years.
  bene_wt <- function(mask) {
    dm[mask, ] %>% group_by(fips_code) %>%
      summarise(w = sum(Benes_Total, na.rm = TRUE) /
                    (MEDICARE_WINDOW[2] - MEDICARE_WINDOW[1] + 1), .groups = "drop")
  }
  bene_wt_heat <- bene_wt(dm$High_CDD == 1 & !is.na(dm$High_CDD))
  bene_wt_cold <- bene_wt(dm$High_HDD == 1 & !is.na(dm$High_HDD))

  # ---- 3. Assemble the scenario bands ---------------------------------------
  cat("== 3. Scenario bands (each standalone; never summed) ==\n")
  bands <- list()
  add_row <- function(...) bands[[length(bands) + 1]] <<- data.frame(..., stringsAsFactors = FALSE)

  # --- Band A1: 2012-style event income loss (WCB CI, certified) ---
  a1 <- list(agg_point = aggregate_band(did_itt$att, count_2012_pop),
             agg_lo = aggregate_band(did_itt$wcb_lo, count_2012_pop),
             agg_hi = aggregate_band(did_itt$wcb_hi, count_2012_pop))
  add_row(result_type = "band", band = "event_2012_income", hazard = "Drought",
          unit = "USD (per-capita income, event level)",
          per_unit_coef = did_itt$att, per_unit_se = did_itt$se,
          per_unit_ci_lo = did_itt$wcb_lo, per_unit_ci_hi = did_itt$wcb_hi,
          ci_method = "wild-cluster bootstrap-t (Webb), certified",
          count = count_2012_pop, count_desc = sprintf("total mean-pop of %d first-onset 2012 counties", n_treated2012),
          aggregate_point = a1$agg_point, aggregate_ci_lo = a1$agg_lo, aggregate_ci_hi = a1$agg_hi,
          estimand_label = "event-specific ITT (first drought onset, 2012 cohort); NOT annualizable; NOT a general drought-response function",
          evidence_row = "Row 1 (H1)", source_file = "wild_bootstrap_2x2.csv",
          notes = "Headline income result. CI is the certified WCB interval, not delta-method.")

  # --- Band A1-alt: DRDID doubly-robust alternative ---
  a1b <- delta_band(did_drdid$att, did_drdid$se, count_2012_pop)  # delta from DRDID SE
  add_row(result_type = "band_alt", band = "event_2012_income_DRDID", hazard = "Drought",
          unit = "USD (per-capita income, event level)",
          per_unit_coef = did_drdid$att, per_unit_se = did_drdid$se,
          per_unit_ci_lo = did_drdid$ci_lo, per_unit_ci_hi = did_drdid$ci_hi,
          ci_method = "DRDID analytic CI (certified)",
          count = count_2012_pop, count_desc = sprintf("total mean-pop of %d first-onset 2012 counties", n_treated2012),
          aggregate_point = aggregate_band(did_drdid$att, count_2012_pop),
          aggregate_ci_lo = aggregate_band(did_drdid$ci_lo, count_2012_pop),
          aggregate_ci_hi = aggregate_band(did_drdid$ci_hi, count_2012_pop),
          estimand_label = "event-specific ITT (doubly-robust); the effect STRENGTHENS under DRDID",
          evidence_row = "Row 1 (H1)", source_file = "dr_2x2_drought_2012.csv",
          notes = "Doubly-robust alternative to the headline; report as a robustness point, not a second band.")

  # --- Band A2: typical recurring drought income (bounded null) ---
  a2 <- delta_band(pooled_e0$att, pooled_e0$se, count_typical_dr_pop)
  add_row(result_type = "band", band = "typical_recurring_income", hazard = "Drought",
          unit = "USD (per-capita income, annual)",
          per_unit_coef = pooled_e0$att, per_unit_se = pooled_e0$se,
          per_unit_ci_lo = a2$per_unit_lo, per_unit_ci_hi = a2$per_unit_hi,
          ci_method = "delta-method 95% (frontier CS-dr e=0 SE)",
          count = count_typical_dr_pop, count_desc = "avg annual population in extreme drought (typical cohort)",
          aggregate_point = a2$agg_point, aggregate_ci_lo = a2$agg_lo, aggregate_ci_hi = a2$agg_hi,
          estimand_label = "typical-year multi-cohort ITT (frontier did::att_gt, e=0); BOUNDED NULL -- CI spans zero; the distinctive claim is that a typical drought year's income effect is bounded near zero while a 2012-scale event is not",
          evidence_row = "Row 1 (H1)", source_file = "dr_csdid_eventtime.csv",
          notes = sprintf("Long-run pooled average is +$%.0f (SE %.0f), also null (dr_csdid_drought.csv). Do NOT present as a causal loss.",
                          pooled_lr$att, pooled_lr$se))

  # --- Band B: cold cumulative-exposure standing employment gap ---
  b <- delta_band(cold_dose$estimate, cold_dose$se, count_cold10)
  add_row(result_type = "band", band = "cold_cumulative_employment", hazard = "Cold (HDD)",
          unit = "jobs (standing employment gap)",
          per_unit_coef = cold_dose$estimate, per_unit_se = cold_dose$se,
          per_unit_ci_lo = b$per_unit_lo, per_unit_ci_hi = b$per_unit_hi,
          ci_method = "delta-method 95% (binned-contrast SE)",
          count = count_cold10, count_desc = sprintf("%d counties reaching 10+ cumulative cold-years", count_cold10),
          aggregate_point = b$agg_point, aggregate_ci_lo = b$agg_lo, aggregate_ci_hi = b$agg_hi,
          estimand_label = "within-county exposure-history contrast (audit B6): standing employment gap of 10+-cumulative-cold-year counties vs the 1-3 baseline; NOT the marginal causal effect of exogenously assigned shock-years; estimator-dependent (binned contrast, not the flat smooth quadratic)",
          evidence_row = "Row 17 (H3)", source_file = "cumulative_dose_marginal.csv",
          notes = "Unweighted 10+ vs 1-3 binned contrast; cite the binned contrast / CS DiD, never the flat quadratic.")

  # --- Band C: drought debt-scar (primary = resident-pop upper bound) ---
  cprim <- delta_band(debt_scar$estimate, debt_scar$se, count_everdr_pop)
  add_row(result_type = "band", band = "drought_debt_scar", hazard = "Drought",
          unit = "people (additional, with medical debt in collections)",
          per_unit_coef = debt_scar$estimate, per_unit_se = debt_scar$se,
          per_unit_ci_lo = cprim$per_unit_lo, per_unit_ci_hi = cprim$per_unit_hi,
          ci_method = "delta-method 95% (onset+exit asymmetry SE)",
          count = count_everdr_pop, count_desc = sprintf("total resident mean-pop of %d ever-extreme-drought counties (UPPER BOUND for credit-visible base)", length(ever_dr)),
          aggregate_point = cprim$agg_point, aggregate_ci_lo = cprim$agg_lo, aggregate_ci_hi = cprim$agg_hi,
          estimand_label = "onset/exit asymmetry, h=2 (debt accrued in drought does not unwind on exit); per scar episode; MEASUREMENT-FRAGILE (Row 24); LOWER BOUND on people (out-migration composition + credit-visibility selection)",
          evidence_row = "Row 16", source_file = "delta_symmetry_test.csv",
          notes = "DATA GAP: credit-visible population unavailable; total resident population substituted as an upper bound. See credit-visible sensitivity row.")

  # --- Band C-sensitivity: credit-visible-adjusted ---
  count_everdr_cv <- count_everdr_pop * CREDIT_VISIBLE_FRAC
  csens <- delta_band(debt_scar$estimate, debt_scar$se, count_everdr_cv)
  add_row(result_type = "band_sensitivity", band = "drought_debt_scar_creditvisible", hazard = "Drought",
          unit = "people (additional, with medical debt in collections)",
          per_unit_coef = debt_scar$estimate, per_unit_se = debt_scar$se,
          per_unit_ci_lo = csens$per_unit_lo, per_unit_ci_hi = csens$per_unit_hi,
          ci_method = "delta-method 95% (onset+exit asymmetry SE)",
          count = count_everdr_cv, count_desc = sprintf("credit-visible base = resident pop x %.3f (documented national approximation)", CREDIT_VISIBLE_FRAC),
          aggregate_point = csens$agg_point, aggregate_ci_lo = csens$agg_lo, aggregate_ci_hi = csens$agg_hi,
          estimand_label = "as drought_debt_scar, credit-visible-adjusted denominator; measurement-fragile lower bound",
          evidence_row = "Row 16", source_file = "delta_symmetry_test.csv",
          notes = sprintf("CREDIT_VISIBLE_FRAC=%.3f (Census adult share ~0.77 x CFPB scoreable-adult share ~0.89).", CREDIT_VISIBLE_FRAC))

  # --- Band D: direct Medicare morbidity cost (annual), per hazard/lag ---
  add_medicare_band <- function(coef_obj, count_benes, label_band, lag_desc) {
    d <- delta_band(coef_obj$estimate, coef_obj$se, count_benes)
    add_row(result_type = "band", band = label_band, hazard = sub("_.*", "", label_band),
            unit = "USD/year (Medicare standardized spending)",
            per_unit_coef = coef_obj$estimate, per_unit_se = coef_obj$se,
            per_unit_ci_lo = d$per_unit_lo, per_unit_ci_hi = d$per_unit_hi,
            ci_method = "delta-method 95% (distributed-lag FE SE)",
            count = count_benes, count_desc = sprintf("avg annual Medicare beneficiaries in shock county-years (%s)", lag_desc),
            aggregate_point = d$agg_point, aggregate_ci_lo = d$agg_lo, aggregate_ci_hi = d$agg_hi,
            estimand_label = "administrative Medicare morbidity burden (65+/disabled, 2014-2023); direct utilization/spending response reproducing Deryugina et al.; PARALLEL direct evidence, NOT mediation of the 2012 income loss (different populations)",
            evidence_row = "Row 10 (H2)", source_file = "medicare_channel_coefs.csv",
            notes = "Restrict to the Medicare population; do not present as a demonstrated chain into working-age household debt.")
  }
  add_medicare_band(med_heat_t0, count_benes_heat, "heat_medicare_annual_t0", "High_CDD, contemporaneous")
  add_medicare_band(med_heat_l1, count_benes_heat, "heat_medicare_annual_L1", "High_CDD, 1-year lag")
  add_medicare_band(med_cold_l2, count_benes_cold, "cold_medicare_annual_L2", "High_HDD, 2-year lag")

  # ---- 4. Unpriced-margin floor (drought-only strong claim) -----------------
  cat("== 4. The unpriced margin (drought-only) ==\n")
  # delta* = TOST upper bound on the drought premium pass-through (PMPM).
  # Full-morbidity benchmark = Medicare heat morbidity cost expressed PMPM
  # ($112-$177/beneficiary-year / 12 = $9.33-$14.75 PMPM). The premium bound
  # rules out drought pass-through above delta*/benchmark of the morbidity scale;
  # its complement is the share that CANNOT be flowing through local premiums.
  excl_lo <- pt$delta_star / pt$bench_lo   # excluded pass-through vs low benchmark
  excl_hi <- pt$delta_star / pt$bench_hi   # excluded pass-through vs high benchmark
  floor_share_lo <- 1 - excl_lo            # unpriced floor (share), low benchmark
  floor_share_hi <- 1 - excl_hi            # unpriced floor (share), high benchmark
  floor_pmpm_lo <- pt$bench_lo - pt$delta_star  # unpriced floor ($ PMPM)
  floor_pmpm_hi <- pt$bench_hi - pt$delta_star
  cat(sprintf("delta* = $%.2f PMPM; benchmark $%.2f-$%.2f PMPM.\n", pt$delta_star, pt$bench_lo, pt$bench_hi))
  cat(sprintf("Excluded pass-through band: > %.1f%%-%.1f%% of a morbidity-scale cost.\n", 100*excl_hi, 100*excl_lo))
  cat(sprintf("=> UNPRICED FLOOR: >= %.1f%%-%.1f%% of a morbidity-scale cost cannot flow through local drought premiums.\n",
              100*floor_share_lo, 100*floor_share_hi))
  cat(sprintf("   In dollars: >= $%.2f-$%.2f PMPM (>= $%.0f-$%.0f per member-year) provably unpriced.\n\n",
              floor_pmpm_lo, floor_pmpm_hi, 12*floor_pmpm_lo, 12*floor_pmpm_hi))

  add_row(result_type = "unpriced_floor", band = "unpriced_margin_drought", hazard = "Drought",
          unit = "share of a morbidity-scale cost",
          per_unit_coef = pt$delta_star, per_unit_se = pt$se,
          per_unit_ci_lo = pt$bench_lo, per_unit_ci_hi = pt$bench_hi,
          ci_method = "TOST equivalence bound vs full-morbidity benchmark",
          count = NA_real_, count_desc = "n/a (a bounding share, NOT enrollment-scaled -- premium coefficients are NOT multiplied by enrollment)",
          aggregate_point = NA_real_, aggregate_ci_lo = floor_share_lo, aggregate_ci_hi = floor_share_hi,
          estimand_label = "DROUGHT ONLY: at least this share of a morbidity-scale cost is provably NOT priced into local premiums (delta*=$7.40 PMPM rules out pass-through > 50-79% of the $9.33-$14.75 PMPM Medicare-heat morbidity benchmark). Heat/cold get only softer bounded language (delta* exceeds the benchmark).",
          evidence_row = "Row 8 (H4) x Row 10 (H2)", source_file = "passthrough_bounds.csv",
          notes = sprintf("floor share [%.3f, %.3f]; floor $ PMPM [%.2f, %.2f]; excluded pass-through band [%.3f, %.3f].",
                          floor_share_lo, floor_share_hi, floor_pmpm_lo, floor_pmpm_hi, excl_hi, excl_lo))

  # ---- 5. RMA framing statistic ---------------------------------------------
  cat("== 5. RMA framing (federal crop transfers vs the health-finance side) ==\n")
  rma_treat <- inp$rma %>% filter(fips_code %in% treated2012, Year >= 2012, Year <= 2023)
  rma_2012  <- inp$rma %>% filter(fips_code %in% treated2012, Year == 2012)
  rma_drought_total <- sum(pmax(rma_treat$Drought_Indemnity, 0), na.rm = TRUE)  # floor tiny negatives at 0
  rma_all_total     <- sum(rma_treat$Total_Indemnity, na.rm = TRUE)
  rma_drought_2012  <- sum(pmax(rma_2012$Drought_Indemnity, 0), na.rm = TRUE)
  income_loss <- abs(a1$agg_point)   # |2012-event income loss|
  ratio_vs_drought <- income_loss / rma_drought_total
  ratio_vs_total   <- income_loss / rma_all_total
  ratio_vs_dr2012  <- income_loss / rma_drought_2012
  cat(sprintf("2012-event income loss (|band A1|): $%s\n", format(round(income_loss), big.mark=",")))
  cat(sprintf("RMA drought indemnity to the 139 counties, 2012-2023: $%s\n", format(round(rma_drought_total), big.mark=",")))
  cat(sprintf("RMA total indemnity to the 139 counties, 2012-2023: $%s\n", format(round(rma_all_total), big.mark=",")))
  cat(sprintf("Ratio (income loss / RMA drought): %.2fx ; / RMA total: %.2fx ; / RMA drought 2012 only: %.2fx\n\n",
              ratio_vs_drought, ratio_vs_total, ratio_vs_dr2012))

  add_row(result_type = "rma_framing", band = "rma_income_vs_drought_indemnity", hazard = "Drought",
          unit = "ratio (dimensionless)",
          per_unit_coef = NA_real_, per_unit_se = NA_real_, per_unit_ci_lo = NA_real_, per_unit_ci_hi = NA_real_,
          ci_method = "point ratio (no CI; unit mismatch flagged)",
          count = rma_drought_total, count_desc = "RMA drought indemnity to the 139 treated counties, 2012-2023 (USD)",
          aggregate_point = ratio_vs_drought, aggregate_ci_lo = NA_real_, aggregate_ci_hi = NA_real_,
          estimand_label = "FRAMING statistic: the 2012-event local income loss is this many times the federal crop-drought indemnity paid to the same counties over 2012-2023. UNIT CAVEAT: income loss is an event-level ITT (per-capita x population); RMA is a multi-year dollar flow.",
          evidence_row = "Row 1 vs RMA", source_file = "intermediate_rma_indemnity.rds",
          notes = sprintf("income loss $%.0f; RMA drought total $%.0f; RMA all-peril total $%.0f (ratio %.2fx); RMA drought 2012 $%.0f (ratio %.2fx).",
                          income_loss, rma_drought_total, rma_all_total, ratio_vs_total, rma_drought_2012, ratio_vs_dr2012))

  # ---- 6. Targeting / concentration -----------------------------------------
  cat("== 6. Targeting / concentration (SVI + energy-burden weighted) ==\n")
  vuln <- build_vuln(pop, inp$svi, inp$eb)
  vmap <- setNames(vuln$vuln_proxy, vuln$fips_code)
  pmap <- setNames(pop$pop_mean, pop$fips_code)

  # per-band county-level burden weights (>= 0 for concentration)
  # A1 & C: burden proportional to population (uniform per-capita coefficient).
  # B: uniform per county. D: proportional to exposed beneficiaries.
  curves <- list()
  conc_rows <- list()
  add_conc <- function(band, curve) {
    if (is.null(curve)) return(invisible())
    curve$band <- band
    curves[[length(curves) + 1]] <<- curve
    td <- top_share(curve, 0.10); tq <- top_share(curve, 0.20)
    conc_rows[[length(conc_rows) + 1]] <<- data.frame(
      result_type = "concentration", band = band, hazard = NA_character_,
      unit = "share", per_unit_coef = NA_real_, per_unit_se = NA_real_,
      per_unit_ci_lo = td[["pop"]], per_unit_ci_hi = tq[["pop"]],   # top-decile / top-quintile POP share
      ci_method = "vulnerability-ranked cumulative shares (per_unit_ci=pop, aggregate_ci=burden)",
      count = nrow(curve), count_desc = "counties in the band's burden-bearing set",
      aggregate_point = NA_real_,
      aggregate_ci_lo = td[["burden"]], aggregate_ci_hi = tq[["burden"]],  # top-decile / top-quintile BURDEN share
      estimand_label = "descriptive concentration (NOT causal welfare weights): share of the band's burden borne by the most-vulnerable counties, ranked by mean-standardized SVI + energy burden",
      evidence_row = "Row 20/21 context", source_file = "vuln = intermediate_svi.rds + intermediate_energy_burden.rds",
      notes = sprintf("top-decile burden %.3f vs pop %.3f ; top-quintile burden %.3f vs pop %.3f",
                      td[["burden"]], td[["pop"]], tq[["burden"]], tq[["pop"]]),
      stringsAsFactors = FALSE)
  }

  # A1: 2012 event (burden ~ pop)
  add_conc("event_2012_income",
           concentration_curve(treated2012, vmap[treated2012], pmap[treated2012], pmap[treated2012]))
  # C: debt scar (burden ~ pop over ever-drought counties)
  add_conc("drought_debt_scar",
           concentration_curve(ever_dr, vmap[ever_dr], pmap[ever_dr], pmap[ever_dr]))
  # B: cold cumulative (burden uniform per county)
  add_conc("cold_cumulative_employment",
           concentration_curve(cold10_fips, vmap[cold10_fips],
                               rep(1, length(cold10_fips)), pmap[cold10_fips]))
  # D-heat: Medicare heat (burden ~ exposed beneficiaries)
  wh <- bene_wt_heat
  add_conc("heat_medicare_annual",
           concentration_curve(wh$fips_code, vmap[wh$fips_code], wh$w, pmap[wh$fips_code]))
  # D-cold: Medicare cold
  wc <- bene_wt_cold
  add_conc("cold_medicare_annual",
           concentration_curve(wc$fips_code, vmap[wc$fips_code], wc$w, pmap[wc$fips_code]))

  # Descriptive national heat-EXPOSURE concentration (person-years of extreme
  # heat), a pure exposure statistic labeled descriptive. weight = pop x mean
  # High_CDD incidence over the window.
  heat_inc <- df %>% group_by(fips_code) %>%
    summarise(inc = mean(High_CDD, na.rm = TRUE), .groups = "drop")
  heat_inc$py <- pmap[heat_inc$fips_code] * heat_inc$inc
  add_conc("heat_exposure_personyears_descriptive",
           concentration_curve(heat_inc$fips_code, vmap[heat_inc$fips_code],
                               heat_inc$py, pmap[heat_inc$fips_code]))

  conc_df <- do.call(rbind, conc_rows)
  print(conc_df[, c("band", "count", "notes")], row.names = FALSE)
  cat("\n")

  # ---- 7. Write outputs -----------------------------------------------------
  results <- dplyr::bind_rows(bands)
  results <- dplyr::bind_rows(results, conc_df)
  utils::write.csv(results, file.path(OUT_DIR, "sufficient_stats.csv"), row.names = FALSE)

  curve_df <- do.call(rbind, curves)
  curve_df <- curve_df[, c("band", "rank", "fips", "vuln",
                           "cum_county_share", "cum_pop_share", "cum_burden_share")]
  utils::write.csv(curve_df, file.path(OUT_DIR, "concentration_curve.csv"), row.names = FALSE)

  write_summary(OUT_DIR, results, anch, list(
    n_treated2012 = n_treated2012, count_2012_pop = count_2012_pop,
    count_everdr_pop = count_everdr_pop, n_everdr = length(ever_dr),
    count_typical_dr_pop = count_typical_dr_pop, count_cold10 = count_cold10,
    count_benes_heat = count_benes_heat, count_benes_cold = count_benes_cold,
    excl_lo = excl_lo, excl_hi = excl_hi,
    floor_share_lo = floor_share_lo, floor_share_hi = floor_share_hi,
    floor_pmpm_lo = floor_pmpm_lo, floor_pmpm_hi = floor_pmpm_hi,
    pt = pt, income_loss = income_loss, rma_drought_total = rma_drought_total,
    rma_all_total = rma_all_total, rma_drought_2012 = rma_drought_2012,
    ratio_vs_drought = ratio_vs_drought, ratio_vs_total = ratio_vs_total,
    ratio_vs_dr2012 = ratio_vs_dr2012, conc = conc_df,
    pooled_lr = pooled_lr, did_drdid = did_drdid))

  cat("Wrote:\n  ", file.path(OUT_DIR, "sufficient_stats.csv"), " (", nrow(results), " rows)\n",
      "  ", file.path(OUT_DIR, "concentration_curve.csv"), " (", nrow(curve_df), " rows)\n",
      "  ", file.path(OUT_DIR, "sufficient_stats_summary.md"), "\n", sep = "")
  cat("\n############ DONE ############\n")
  invisible(results)
}

# -----------------------------------------------------------------------------
# Structured numeric summary (consumed by the essay/policy write-up task 2.4/2.5;
# this is NOT the prose write-up, which is a separate later task).
# -----------------------------------------------------------------------------
write_summary <- function(out_dir, results, anch, x) {
  usd <- function(v) paste0(ifelse(v < 0, "-$", "$"), format(round(abs(v)), big.mark = ","))
  num <- function(v) format(round(v), big.mark = ",")
  bandrow <- function(b) results[results$band == b, ][1, ]

  a1 <- bandrow("event_2012_income")
  a1b <- bandrow("event_2012_income_DRDID")
  a2 <- bandrow("typical_recurring_income")
  bB <- bandrow("cold_cumulative_employment")
  cC <- bandrow("drought_debt_scar")
  cCv <- bandrow("drought_debt_scar_creditvisible")
  dH0 <- bandrow("heat_medicare_annual_t0")
  dH1 <- bandrow("heat_medicare_annual_L1")
  dC2 <- bandrow("cold_medicare_annual_L2")

  L <- c()
  a <- function(...) L <<- c(L, sprintf(...))
  a("# Sufficient-Statistics Policy Synthesis - Numeric Summary")
  a("")
  a("Generated by `Code/run_policy_sufficient_stats.R` (thesis_completion_20260704 task 2.3, T1.3 as amended 2026-07-12). **This is a structured numeric summary for the write-up task, not the prose policy section.**")
  a("")
  a("All aggregates are per-unit coefficient x exposed count with a delta-method band from the coefficient SE/CI. **Bands are standalone and are never summed into one national total, nor averaged across estimands.** Every input coefficient is verified against the frozen `Plans/master_evidence_table.md` (anchor check: %d/%d matched).", sum(anch$ok), nrow(anch))
  a("")
  a("## (a) The unpriced margin (drought-only strong claim)")
  a("")
  a("**(a)(i) Direct Medicare morbidity cost in exposed counties (annual, per hazard):**")
  a("")
  a("| Hazard / lag | $/beneficiary-year (95%% CI) | Avg annual exposed beneficiaries | Annual cost (95%% CI) |")
  a("|---|---|---|---|")
  a("| Heat, contemporaneous | %s [%s, %s] | %s | %s [%s, %s] |",
    usd(dH0$per_unit_coef), usd(dH0$per_unit_ci_lo), usd(dH0$per_unit_ci_hi), num(dH0$count),
    usd(dH0$aggregate_point), usd(dH0$aggregate_ci_lo), usd(dH0$aggregate_ci_hi))
  a("| Heat, 1-year lag | %s [%s, %s] | %s | %s [%s, %s] |",
    usd(dH1$per_unit_coef), usd(dH1$per_unit_ci_lo), usd(dH1$per_unit_ci_hi), num(dH1$count),
    usd(dH1$aggregate_point), usd(dH1$aggregate_ci_lo), usd(dH1$aggregate_ci_hi))
  a("| Cold, 2-year lag | %s [%s, %s] | %s | %s [%s, %s] |",
    usd(dC2$per_unit_coef), usd(dC2$per_unit_ci_lo), usd(dC2$per_unit_ci_hi), num(dC2$count),
    usd(dC2$aggregate_point), usd(dC2$aggregate_ci_lo), usd(dC2$aggregate_ci_hi))
  a("")
  a("Estimand: administrative Medicare morbidity burden (65+/disabled, 2014-2023); direct utilization response (Deryugina et al.), **parallel evidence, NOT mediation** of the 2012 income loss (different populations).")
  a("")
  a("**(a)(ii) The drought-specific unpriced floor (arithmetic shown):**")
  a("")
  a("- Certified premium equivalence bound (Row 8, drought L2 primary): delta* = **$%.2f per member-month (PMPM)**, verdict %s.", x$pt$delta_star, x$pt$verdict)
  a("- Full-morbidity benchmark (Row 10 heat cost expressed PMPM): **$%.2f-$%.2f PMPM** (= $112-$177/beneficiary-year / 12).", x$pt$bench_lo, x$pt$bench_hi)
  a("- delta* rules out drought pass-through **> %.1f%%-%.1f%%** of the morbidity benchmark (= delta*/benchmark = %.3f-%.3f).", 100*x$excl_hi, 100*x$excl_lo, x$excl_hi, x$excl_lo)
  a("- Its complement is the floor that **cannot** be priced: **>= %.1f%%-%.1f%%** of a morbidity-scale cost (= 1 - delta*/benchmark).", 100*x$floor_share_lo, 100*x$floor_share_hi)
  a("- In dollars: **>= $%.2f-$%.2f PMPM** (>= $%.0f-$%.0f per member-year) is provably unpriced in local drought premiums.", x$floor_pmpm_lo, x$floor_pmpm_hi, 12*x$floor_pmpm_lo, 12*x$floor_pmpm_hi)
  a("")
  a("Discipline: **drought only.** Heat/cold premium bounds are softer (delta* exceeds the benchmark; equivalence with full pass-through is not rejected), so the strong unpriced claim is not licensed for them. Premium coefficients are **never** multiplied by enrollment.")
  a("")
  a("## (b) Scenario bands (each standalone)")
  a("")
  a("| Band | Point | 95%% band | Per-unit coef | Count | Estimand label (short) |")
  a("|---|---|---|---|---|---|")
  a("| 2012-style event income | %s | [%s, %s] | %s/capita | %s people (%d cos) | event-specific ITT; not annualizable |",
    usd(a1$aggregate_point), usd(a1$aggregate_ci_lo), usd(a1$aggregate_ci_hi), usd(a1$per_unit_coef), num(a1$count), x$n_treated2012)
  a("| &nbsp; (DRDID alt) | %s | [%s, %s] | %s/capita | (same) | doubly-robust; strengthens |",
    usd(a1b$aggregate_point), usd(a1b$aggregate_ci_lo), usd(a1b$aggregate_ci_hi), usd(a1b$per_unit_coef))
  a("| Typical-recurring income | %s | [%s, %s] | %s/capita | %s people | **bounded null** (CI spans 0) |",
    usd(a2$aggregate_point), usd(a2$aggregate_ci_lo), usd(a2$aggregate_ci_hi), usd(a2$per_unit_coef), num(a2$count))
  a("| Cold cumulative employment | %s jobs | [%s, %s] | %s jobs/county | %s counties | exposure-history contrast (B6) |",
    num(bB$aggregate_point), num(bB$aggregate_ci_lo), num(bB$aggregate_ci_hi), num(bB$per_unit_coef), num(bB$count))
  a("| Drought debt scar | %s ppl | [%s, %s] | %.5f share/episode | %s (resident, UB) | measurement-fragile; lower bound |",
    num(cC$aggregate_point), num(cC$aggregate_ci_lo), num(cC$aggregate_ci_hi), cC$per_unit_coef, num(cC$count))
  a("| &nbsp; (credit-visible adj.) | %s ppl | [%s, %s] | (same) | %s (x%.3f) | sensitivity |",
    num(cCv$aggregate_point), num(cCv$aggregate_ci_lo), num(cCv$aggregate_ci_hi), num(cCv$count), CREDIT_VISIBLE_FRAC)
  a("| Direct Medicare (heat t0) | %s/yr | [%s, %s] | %s/bene-yr | %s benes | Medicare morbidity (parallel) |",
    usd(dH0$aggregate_point), usd(dH0$aggregate_ci_lo), usd(dH0$aggregate_ci_hi), usd(dH0$per_unit_coef), num(dH0$count))
  a("")
  a("Long-run pooled drought income average is +%s (SE %s) - also null; the typical-recurring band is deliberately reported as a bounded null, not a loss.", usd(x$pooled_lr$att), usd(x$pooled_lr$se))
  a("")
  a("## (c) Targeting / concentration")
  a("")
  a("County vulnerability rank = mean of standardized SVI (CDC) and standardized energy burden (DOE LEAD), time-invariant. For each band the burden-bearing counties are ranked most-vulnerable-first; shares are cumulative. **Descriptive concentration, not causal welfare weights.** For income and debt bands the per-capita coefficient is uniform, so within-band burden tracks population (the distributional *bite* is the separate SVI-amplification result, Row 20/21, deliberately NOT folded into these aggregates).")
  a("")
  a("| Band | Top-decile burden / pop share | Top-quintile burden / pop share |")
  a("|---|---|---|")
  for (i in seq_len(nrow(x$conc))) {
    cr <- x$conc[i, ]
    # aggregate_ci = burden share; per_unit_ci = pop share (top-decile / top-quintile)
    a("| %s | %.3f / %.3f | %.3f / %.3f |", cr$band,
      cr$aggregate_ci_lo, cr$per_unit_ci_lo, cr$aggregate_ci_hi, cr$per_unit_ci_hi)
  }
  a("")
  a("(Per-band pop shares and full curve for a figure are in `concentration_curve.csv` and the `notes` column of `sufficient_stats.csv`.)")
  a("")
  a("## (d) RMA framing statistic")
  a("")
  a("- 2012-event local income loss (|band A1|): **%s**.", usd(x$income_loss))
  a("- RMA **drought** crop-insurance indemnity to the same 139 counties, 2012-2023: **%s**.", usd(x$rma_drought_total))
  a("- RMA **all-peril** indemnity to those counties, 2012-2023: **%s**.", usd(x$rma_all_total))
  a("- **Ratio: the health-finance income loss is %.1fx the federal drought-crop transfer (and %.2fx all-peril transfers) to the same counties over 2012-2023; %.1fx the 2012 drought-year crop payout alone (%s).**",
    x$ratio_vs_drought, x$ratio_vs_total, x$ratio_vs_dr2012, usd(x$rma_drought_2012))
  a("- UNIT CAVEAT: the income loss is an event-level ITT (per-capita x population, one event); RMA is a multi-year dollar flow. Report as a framing contrast, not a like-for-like net.")
  a("")
  a("## Estimand-label ledger (binding)")
  a("")
  a("- 2012 income & DRDID: **event-specific ITT of first drought onset**; do NOT annualize or generalize.")
  a("- Typical-recurring: **bounded null** (frontier CS-dr, e=0); a typical drought year's income effect is bounded near zero.")
  a("- Cold cumulative: **within-county exposure-history contrast (B6)**, estimator-dependent; NOT a marginal causal effect of assigned shock-years.")
  a("- Debt scar: **onset/exit asymmetry**; measurement-fragile (Row 24); a lower bound on people (out-migration + credit-visibility selection).")
  a("- Medicare: **administrative burden for the 65+/disabled population**, parallel direct evidence, not mediation.")
  a("- Unpriced floor: **drought-only**; a bounding share, never enrollment-scaled.")
  a("- Concentration & RMA: **descriptive / framing**, not causal welfare weights.")
  a("")

  writeLines(L, file.path(out_dir, "sufficient_stats_summary.md"))
}

# Run only when invoked as a script (sourcing for tests just defines functions).
if (sys.nframe() == 0L) main()
