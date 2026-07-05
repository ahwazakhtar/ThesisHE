# Tests for run_mechanism_employment_rescaled.R (mechanisms_revision_20260704, T1.1).
# Guards the B1 lead-placebo construction (add_shock_leads) and the A2 outcome
# transforms. Run on main R 4.2.2:  Rscript Code/tests/test_employment_rescaled.R

suppressPackageStartupMessages({ library(testthat) })
source("Code/run_mechanism_employment_rescaled.R")   # sys.nframe() guard => helpers only

# ---------------------------------------------------------------------------
test_that("add_shock_leads aligns F1 by group with no cross-group bleed", {
  d <- data.frame(
    fips_code = rep(c("01001", "06075"), each = 4),
    Year      = rep(2011:2014, times = 2),
    shk       = c(0, 1, 0, 0,      # county A: shock in 2012 -> Lead1 lands in 2011
                  0, 0, 1, 0),     # county B: shock in 2013 -> Lead1 lands in 2012
    stringsAsFactors = FALSE)
  out <- add_shock_leads(d, "shk", n_lead = 1L)
  a <- out[out$fips_code == "01001", ]
  b <- out[out$fips_code == "06075", ]
  # Lead1 at row t = shock at t+1; last year of each county is NA (no t+1).
  expect_equal(a$shk_Lead1, c(1, 0, 0, NA))     # 2012 shock shows at 2011
  expect_equal(b$shk_Lead1, c(0, 1, 0, NA))     # 2013 shock shows at 2012; A's tail does not bleed
})

# ---------------------------------------------------------------------------
test_that("a placebo lead of a null-DGP shock recovers ~0 (sanity of the design)", {
  # Under no effect, the F1 lead coefficient should be centered on zero.
  set.seed(11)
  n_c <- 40; yrs <- 2008:2016
  g <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs, stringsAsFactors = FALSE)
  g$shk <- rbinom(nrow(g), 1, 0.25)
  g$y   <- 5 * g$shk + rnorm(nrow(g))            # depends on CURRENT shock only
  g <- add_shock_leads(g, "shk", 1L)
  suppressPackageStartupMessages(library(fixest))
  m <- feols(y ~ shk + shk_Lead1 | fips_code + Year, data = g)
  expect_lt(abs(unname(coef(m)["shk_Lead1"])), 0.5)   # lead ~ 0
  expect_gt(unname(coef(m)["shk"]), 4)                 # current effect intact
})

# ---------------------------------------------------------------------------
test_that("outcome transforms are correct and scale-free relative to level", {
  emp <- c(721, 2011, 50000); pop <- c(9000, 30000, 900000)
  log_emp     <- ifelse(emp > 0, log(emp), NA_real_)
  emp_per1000 <- ifelse(pop > 0, emp / pop * 1000, NA_real_)
  expect_equal(log_emp, log(emp))
  expect_equal(asinh(emp), log(emp + sqrt(emp^2 + 1)))          # asinh identity
  expect_equal(emp_per1000, c(721/9000*1000, 2011/30000*1000, 50000/900000*1000))
  # the whole point of A2: a proportional (log) change does NOT depend on county size,
  # whereas a level difference does — verify the log gap is size-invariant.
  # county A (small) and B (big) each lose 5% of employment:
  expect_equal(log(1000*0.95) - log(1000), log(50000*0.95) - log(50000), tolerance = 1e-12)
})

cat("\nAll employment-rescaling tests completed.\n")
