# Tests for the DiD frontier-robustness layer (did_frontier_robustness_20260625, Phase 5).
# Runs on the MAIN R 4.2.2 (where testthat lives): the tests deliberately avoid the
# frontier-only packages (no fwildclusterboot::boottest) — they exercise the shared helper
# and the FWL/randomization-inference *identities* the layer relies on, both of which base
# fixest provides. Run:
#   Rscript Code/tests/test_did_robustness.R
#
# Covers the four properties the layer relies on:
#   (1) cohort construction = first-event year per county (mirrors run_did_analysis.R),
#   (2) the FWL-residualized 2x2 point estimate equals the full two-way-FE feols ATT
#       (the identity that makes the fast wild bootstrap in 01_ legitimate),
#   (3) the randomization-inference placebo distribution centers on 0 under a true null,
#   (4) baseline covariates are strictly pre-treatment (2011).

suppressPackageStartupMessages({
  library(testthat)
  library(fixest)
})
source("Code/did_robustness/00_did_robustness_common.R")

# ---------------------------------------------------------------------------
# Synthetic panel with KNOWN drought onset per county and the columns the
# helpers consume. 6 counties x 2011:2015. Onsets:
#   A (01001): 2012 | B (01003): 2013 | C (04001): 2012 (2 spells)
#   D (06001): never | E (08001): never | F (13001): never
# ---------------------------------------------------------------------------
make_panel <- function() {
  yrs <- 2011:2015
  mk <- function(fips, st, drought) data.frame(
    fips_code = fips, Year = yrs, State = st, Is_Extreme_Drought = drought,
    Population = 10000 + 100 * (yrs - 2011),
    PCPI_Real = 40000, Med_HH_Income_Real = 50000,
    Civilian_Employed = 5000, Medical_Debt_Share = 0.12,
    stringsAsFactors = FALSE)
  rbind(
    mk("01001", "AL", c(0, 1, 0, 0, 0)),   # first onset 2012
    mk("01003", "AL", c(0, 0, 1, 1, 0)),   # first onset 2013
    mk("04001", "AZ", c(0, 1, 0, 1, 0)),   # first onset 2012, two spells
    mk("06001", "CA", c(0, 0, 0, 0, 0)),   # never
    mk("08001", "CO", c(0, 0, 0, 0, 0)),   # never
    mk("13001", "GA", c(0, 0, 0, 0, 0)))   # never
}

# ---------------------------------------------------------------------------
test_that("build_cohorts assigns first drought-onset year; 0 = never-exposed", {
  co <- build_cohorts(make_panel(), "Is_Extreme_Drought")
  expect_equal(co$cohort[co$fips_code == "01001"], 2012L)
  expect_equal(co$cohort[co$fips_code == "01003"], 2013L)
  expect_equal(co$cohort[co$fips_code == "04001"], 2012L)   # first, not last
  expect_equal(co$cohort[co$fips_code == "06001"], 0L)      # never-exposed
  # n_events counts spells, not just onset
  expect_equal(co$n_events[co$fips_code == "04001"], 2L)
  expect_equal(co$n_events[co$fips_code == "06001"], 0L)
})

# ---------------------------------------------------------------------------
test_that("did_2x2_frame builds Treated/Post/TxP and correct counts", {
  p  <- make_panel()
  co <- build_cohorts(p, "Is_Extreme_Drought")
  fr <- did_2x2_frame(p, co, event_year = 2012L)
  # Treated = the two 2012-onset counties; control = the three never-exposed.
  expect_equal(attr(fr, "n_treated"), 2L)
  expect_equal(attr(fr, "n_control"), 3L)
  # The 2013-onset county is neither treated nor a control (excluded → clean control group).
  expect_false("01003" %in% fr$fips_code)
  # TxP is exactly Treated * Post.
  expect_equal(fr$TxP, fr$Treated * fr$Post)
  # Post switches on in the event year.
  expect_equal(unique(fr$Post[fr$Year >= 2012]), 1L)
  expect_equal(unique(fr$Post[fr$Year <  2012]), 0L)
})

# ---------------------------------------------------------------------------
test_that("FWL-residualized 2x2 point estimate equals the full two-way-FE ATT", {
  # This identity is what licenses bootstrapping the 1-regressor residual model
  # in 01_wild_cluster_bootstrap.R instead of the FE-heavy full model.
  set.seed(DID_ROB_SEED)
  n_c <- 30; yrs <- 2008:2016
  grid <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs,
                      stringsAsFactors = FALSE)
  treated <- sprintf("%05d", 1:12)
  grid$Treated <- as.integer(grid$fips_code %in% treated)
  grid$Post    <- as.integer(grid$Year >= 2012)
  grid$TxP     <- grid$Treated * grid$Post
  fe_c <- rnorm(n_c);  names(fe_c) <- sprintf("%05d", 1:n_c)
  fe_y <- rnorm(length(yrs)); names(fe_y) <- as.character(yrs)
  grid$y <- 500 * grid$TxP + fe_c[grid$fips_code] * 1000 +
            fe_y[as.character(grid$Year)] * 800 + rnorm(nrow(grid), 0, 50)

  m_full <- feols(y ~ TxP | fips_code + Year, data = grid)
  dm <- demean(cbind(yv = grid$y, TxP = grid$TxP),
               f = grid[, c("fips_code", "Year")])
  grid$.yv <- dm[, "yv"]; grid$.TxP <- dm[, "TxP"]      # mirrors 01_wild_cluster_bootstrap.R
  m_fwl <- feols(.yv ~ .TxP, data = grid)
  expect_equal(unname(coef(m_full)["TxP"]),
               unname(coef(m_fwl)[".TxP"]), tolerance = 1e-8)
})

# ---------------------------------------------------------------------------
test_that("randomization-inference placebo coefficients center on 0 under a true null", {
  # No treatment effect in the DGP → placebo ATTs (random treated labels) must be
  # mean-zero. Tests the RI engine used in 01_ (signed, before the abs()).
  set.seed(DID_ROB_SEED)
  n_c <- 40; yrs <- 2008:2016
  grid <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs,
                      stringsAsFactors = FALSE)
  fe_c <- rnorm(n_c); names(fe_c) <- sprintf("%05d", 1:n_c)
  grid$y <- fe_c[grid$fips_code] * 1000 + (grid$Year - 2012) * 30 +
            rnorm(nrow(grid), 0, 40)               # NO TxP term
  grid$Post <- as.integer(grid$Year >= 2012)
  yv <- demean(cbind(y = grid$y), f = grid[, c("fips_code", "Year")])[, "y"]

  fips_all <- unique(grid$fips_code); n_tr <- 15L
  placebo <- replicate(400, {
    pl <- sample(fips_all, n_tr)
    plTxP <- as.integer(grid$fips_code %in% pl) * grid$Post
    plr <- demean(cbind(p = plTxP), f = grid[, c("fips_code", "Year")])[, "p"]
    coef(.lm.fit(cbind(1, plr), yv))[2]
  })
  expect_equal(mean(placebo), 0, tolerance = 15)   # centered on 0 (units of y)
  expect_gt(sd(placebo), 0)                         # non-degenerate
})

# ---------------------------------------------------------------------------
test_that("baseline_covariates use strictly pre-treatment (2011) values only", {
  p <- make_panel()
  base1 <- baseline_covariates(p)
  # Perturb every POST-2011 row; baseline output must be unchanged.
  p2 <- p
  p2$Population[p2$Year > 2011]         <- 99
  p2$Med_HH_Income_Real[p2$Year > 2011] <- -1
  base2 <- baseline_covariates(p2)
  expect_equal(base1, base2)
  # And the covariate equals the county's 2011 value.
  expect_equal(base1$log_pop_2011[base1$fips_code == "01001"],
               log(p$Population[p$fips_code == "01001" & p$Year == 2011]))
  expect_equal(nrow(base1), length(unique(p$fips_code)))
})

cat("\nAll DiD robustness tests completed.\n")
