# =============================================================================
# test_wet_shock_bin.R  — unit tests for Code/run_wet_shock_bin.R (T1.6)
# =============================================================================
# Run (main R 4.2.2, from repo root):
#   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/tests/test_wet_shock_bin.R
#
# Coverage (per the task's required test surface):
#   - bin construction: threshold EXACTLY > +1.5; NA passthrough ([B3])
#   - lag alignment: thresholding the master lag columns == lag(High_Precip)
#   - master uniqueness assertion (pass on unique; stop on duplicate)
#   - identical-sample assertion between primary & sensitivity variants per outcome
#   - BKY sharpened-q arithmetic on a synthetic p-vector (hand-computed reference)
#   - output schema: 12 primary rows + required columns + labeled sensitivity rows
#   - FIPS formatC idiom (single-digit-state counties survive; no space padding)
#   - end-to-end fit recovery (distributed-lag coefficient)
# =============================================================================

suppressPackageStartupMessages({ library(testthat); library(dplyr) })

stopifnot(file.exists("Code/run_wet_shock_bin.R"))
# Sourcing run_wet_shock_bin.R also sources Code/pipeline_utils.R (pad_fips,
# open_build_log). The guarded main (sys.nframe()==0L) does NOT run on source.
source("Code/run_wet_shock_bin.R")

set.seed(20260713)

# ---------------------------------------------------------------------------
context("FIPS formatC idiom (blessed pad_fips from pipeline_utils.R)")
# ---------------------------------------------------------------------------
test_that("pad_fips zero-pads to width 5 without space-dropping single-digit states", {
  expect_identical(pad_fips(1001),  "01001")   # AL 01001 (single-digit state code)
  expect_identical(pad_fips(56045), "56045")   # WY, already width 5
  expect_identical(pad_fips("6037"), "06037")  # CA county as character
  padded <- pad_fips(c(1001, 6037, 48201))
  expect_true(all(nchar(padded) == 5))
  expect_false(any(grepl(" ", padded)))        # NEVER space-padded (sprintf trap)
})

# ---------------------------------------------------------------------------
context("bin construction: threshold EXACTLY > +1.5, NA passthrough")
# ---------------------------------------------------------------------------
test_that("high_precip_bin fires strictly above +1.5 and passes NA through", {
  z <- c(1.5, 1.500001, 1.6, 1.49, 0, -2, 3.0, NA)
  b <- high_precip_bin(z)
  expect_equal(b[1], 0L)   # z == 1.5 -> NOT wet (strictly greater)
  expect_equal(b[2], 1L)   # just above threshold -> wet
  expect_equal(b[3], 1L)
  expect_equal(b[4], 0L)
  expect_equal(b[5], 0L)
  expect_equal(b[6], 0L)
  expect_equal(b[7], 1L)
  expect_true(is.na(b[8]))                       # NA passthrough ([B3])
  expect_true(is.integer(b))
})

test_that("the frozen threshold constant and term set are exactly as specified", {
  expect_identical(WET_THRESHOLD, 1.5)
  expect_identical(WET_TERMS, c("High_Precip", "High_Precip_Lag1", "High_Precip_Lag2"))
  expect_identical(WET_LAGS, c(0L, 1L, 2L))
  expect_setequal(WET_OUTCOMES, c("Medical_Debt_Share", "PCPI_Real",
                                  "Civilian_Employed", "Med_HH_Income_Real"))
})

# ---------------------------------------------------------------------------
context("lag alignment: thresholding master lag columns == lag(High_Precip)")
# ---------------------------------------------------------------------------
test_that("build_wet_bins on master lag columns matches within-county lag of the bin", {
  # synthetic 2-county panel with TRUE within-county lags of Z_Precip
  p <- data.frame(fips_code = rep(c("01001", "02013"), each = 6),
                  Year = rep(2011:2016, 2),
                  Z_Precip = c(2.0, 0.3, 1.7, -0.5, 1.51, 0.9,
                               0.2, 1.9, 1.5, 2.4, -1.0, 1.6),
                  stringsAsFactors = FALSE) %>%
    arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(Z_Precip_Lag1 = dplyr::lag(Z_Precip, 1),
           Z_Precip_Lag2 = dplyr::lag(Z_Precip, 2)) %>% ungroup()
  b <- build_wet_bins(p)
  # independent within-county lag of the contemporaneous bin
  ref <- b %>% arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(ref_L1 = dplyr::lag(High_Precip, 1),
           ref_L2 = dplyr::lag(High_Precip, 2)) %>% ungroup()
  ok1 <- with(ref, High_Precip_Lag1 == ref_L1)
  ok2 <- with(ref, High_Precip_Lag2 == ref_L2)
  # on every interior row where the within-county lag is defined, they agree
  expect_true(all(ok1[!is.na(ref$ref_L1)]))
  expect_true(all(ok2[!is.na(ref$ref_L2)]))
  # z == 1.5 exactly (county 02013 Year 2013) is NOT a wet extreme
  expect_equal(b$High_Precip[b$fips_code == "02013" & b$Year == 2013], 0L)
})

test_that("master's precomputed Z_Precip_Lag1 equals the within-county lag (spot check)", {
  skip_if_not(file.exists("Data/county_level_master.csv"))
  m <- read.csv("Data/county_level_master.csv")
  m$fips_code <- pad_fips(m$fips_code)
  m <- m[m$Year >= 2011 & m$Year <= 2023, c("fips_code", "Year", "Z_Precip", "Z_Precip_Lag1")]
  m <- m[!duplicated(m[, c("fips_code", "Year")]), ]
  m <- m %>% arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(manual = dplyr::lag(Z_Precip, 1)) %>% ungroup()
  # bin(master lag) vs bin(manual lag) — the object the analysis actually uses
  agree <- sum(high_precip_bin(m$Z_Precip_Lag1) == high_precip_bin(m$manual), na.rm = TRUE)
  tot   <- sum(!is.na(m$Z_Precip_Lag1) & !is.na(m$manual))
  expect_gt(agree / tot, 0.999)   # near-perfect; precomputed lags are authoritative
})

# ---------------------------------------------------------------------------
context("master uniqueness assertion")
# ---------------------------------------------------------------------------
test_that("assert_unique_panel passes on a unique panel and stops on a duplicate", {
  uniq <- data.frame(fips_code = c("01001", "01001", "02013"),
                     Year = c(2011L, 2012L, 2011L))
  expect_true(assert_unique_panel(uniq))
  dup <- data.frame(fips_code = c("01001", "01001", "02013"),
                    Year = c(2012L, 2012L, 2011L))   # 01001-2012 duplicated
  expect_error(assert_unique_panel(dup), "NOT unique")
})

# ---------------------------------------------------------------------------
context("BKY sharpened q-values — arithmetic on a synthetic p-vector")
# ---------------------------------------------------------------------------
test_that("bky_qvalues reproduces the hand-computed two-stage adaptive q", {
  # m=4, alpha=0.05: stage-1 crit_i = (i/4)*(0.05/1.05); po = .001,.2,.5,.9
  #   po<=crit only at i=1 -> r1=1 -> m0=3. stage-2 q_i = po_i*4/(i*(3/4)),
  #   then rev-cummin-rev + cap at 1:  ~ c(0.0053333, 0.53333, 0.88889, 1.0)
  q <- bky_qvalues(c(0.001, 0.2, 0.5, 0.9))
  expect_equal(q, c(0.0053333, 0.53333, 0.88889, 1.0), tolerance = 1e-4)
  # all-equal spacing -> equal q (0.16) for c(.01,.02,.03,.04): r1=4, m0=0->1
  expect_equal(bky_qvalues(c(0.01, 0.02, 0.03, 0.04)),
               rep(0.16, 4), tolerance = 1e-6)
})

test_that("bky_qvalues is bounded [0,1], NA-safe, order-preserving", {
  p <- c(0.0001, 0.002, 0.01, 0.2, 0.8)
  q <- bky_qvalues(p)
  expect_length(q, length(p))
  expect_true(all(q >= 0 & q <= 1))
  expect_lt(q[1], 0.05)                 # a very small p survives
  expect_gt(q[5], q[1])                 # ordering preserved
  qn <- bky_qvalues(c(0.001, NA, 0.5))  # NA in -> NA out; others computed
  expect_true(is.na(qn[2]))
  expect_true(all(!is.na(qn[c(1, 3)])))
})

# ---------------------------------------------------------------------------
context("identical-sample assertion between primary & sensitivity variants")
# ---------------------------------------------------------------------------
# Build a small panel where some rows lack the contemporaneous controls; the
# same-sample rule must give the no-control and contemporaneous variants EQUAL N.
make_wet_panel <- function(n_state = 8, per_state = 6, yrs = 2011:2020,
                           control_gap = TRUE) {
  counties <- sprintf("%05d", seq_len(n_state * per_state))
  states   <- rep(sprintf("S%02d", seq_len(n_state)), each = per_state)
  cty <- data.frame(fips_code = counties, State = states,
                    cfe = rnorm(length(counties)), stringsAsFactors = FALSE)
  grid <- expand.grid(fips_code = counties, Year = yrs, stringsAsFactors = FALSE)
  d <- dplyr::left_join(grid, cty, by = "fips_code")
  d <- d %>% arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(Z_Precip = rnorm(dplyr::n(), 0.2, 1),
           Z_Precip_Lag1 = dplyr::lag(Z_Precip, 1),
           Z_Precip_Lag2 = dplyr::lag(Z_Precip, 2)) %>% ungroup()
  d <- build_wet_bins(d)
  yfe <- setNames(rnorm(length(yrs)), yrs)
  # TRUE distributed-lag model: +300 on High_Precip_Lag1, county+year FE + noise
  d$Population <- 20000 + round(runif(nrow(d)) * 80000)
  hp1 <- ifelse(is.na(d$High_Precip_Lag1), 0, d$High_Precip_Lag1)
  d$Med_HH_Income_Real <- 50000 + 300 * hp1 + 1000 * d$cfe +
    yfe[as.character(d$Year)] + rnorm(nrow(d), 0, 200)
  d$Household_Income_2023 <- d$Med_HH_Income_Real * 1.1 + rnorm(nrow(d), 0, 100)
  d$Uninsured_Rate <- runif(nrow(d), 5, 20)
  if (control_gap) {
    # blank the controls for one whole state -> those rows must drop from the
    # identical sample (both variants), keeping N equal across variants.
    gap_state <- levels(as.factor(d$State))[1]
    d$Household_Income_2023[d$State == gap_state] <- NA_real_
    d$Uninsured_Rate[d$State == gap_state]        <- NA_real_
  }
  d$State <- as.factor(d$State)
  d
}

test_that("no-control and contemporaneous variants share N on the identical sample", {
  d <- make_wet_panel(control_gap = TRUE)
  oc <- "Med_HH_Income_Real"
  fe_ids <- c("fips_code", "Year", "State")
  id_keep <- complete_case_rows(d, c(oc, WET_TERMS, CONTROLS_CONTEMP, fe_ids))
  dident <- d[id_keep, , drop = FALSE]
  r_nc <- fit_wet_model(dident, oc, character(0),      weighted = FALSE)
  r_cc <- fit_wet_model(dident, oc, CONTROLS_CONTEMP,  weighted = FALSE)
  expect_equal(unique(r_nc$N), unique(r_cc$N))          # identical-sample N
  # the control-gapped state's rows are excluded from the identical sample
  expect_false(any(is.na(dident$Household_Income_2023)))
  # full (no-control) sample is strictly larger than the identical sample
  full_keep <- complete_case_rows(d, c(oc, WET_TERMS, fe_ids))
  expect_gt(sum(full_keep), sum(id_keep))
})

# ---------------------------------------------------------------------------
context("end-to-end fit recovery + output schema")
# ---------------------------------------------------------------------------
test_that("fit_wet_model returns 3 lag rows with the required columns and recovers the DL effect", {
  d <- make_wet_panel(control_gap = FALSE)
  fe_ids <- c("fips_code", "Year", "State")
  keep <- complete_case_rows(d, c("Med_HH_Income_Real", WET_TERMS, fe_ids))
  fit <- fit_wet_model(d[keep, ], "Med_HH_Income_Real", character(0), weighted = FALSE)
  expect_s3_class(fit, "data.frame")
  expect_equal(nrow(fit), 3)
  expect_setequal(fit$term, WET_TERMS)
  expect_setequal(names(fit),
    c("outcome", "term", "lag", "estimate", "se", "t_stat", "p_value",
      "N", "n_counties", "n_states"))
  # lag-1 coefficient recovers the true +300 effect (sign & rough magnitude)
  b1 <- fit$estimate[fit$term == "High_Precip_Lag1"]
  expect_gt(b1, 150)
  # weighted fit also runs without error
  fitw <- fit_wet_model(d[keep, ], "Med_HH_Income_Real", character(0), weighted = TRUE)
  expect_true(all(is.finite(fitw$estimate)))
})

test_that("produced wet_shock_coefs.csv (if present) matches the required schema & size", {
  f <- "Analysis/wet_shock/wet_shock_coefs.csv"
  skip_if_not(file.exists(f))
  g <- read.csv(f, stringsAsFactors = FALSE)
  required <- c("spec_role", "weighting", "controls", "sample", "outcome",
                "term", "lag", "estimate", "se", "t_stat", "p_value",
                "q_bky", "N", "n_counties", "n_states")
  expect_true(all(required %in% names(g)))
  # exactly 12 primary cells (4 outcomes x 3 lags)
  prim <- g[g$spec_role == "primary", ]
  expect_equal(nrow(prim), 12)
  expect_setequal(unique(prim$outcome), WET_OUTCOMES)
  expect_setequal(unique(prim$term), WET_TERMS)
  expect_true(all(prim$weighting == "unweighted" & prim$controls == "none"))
  # sensitivity rows are present and clearly labeled
  expect_true(any(grepl("sensitivity", g$spec_role)))
  expect_true(any(g$spec_role == "sensitivity_contemp_identical" &
                  g$controls == "contemporaneous"))
  # pop-weighted robustness present and labeled (not among the 12 primary)
  expect_true(any(g$spec_role == "robustness_popwt" & g$weighting == "population"))
})

cat("\nAll wet-shock-bin tests defined; running via testthat...\n")
