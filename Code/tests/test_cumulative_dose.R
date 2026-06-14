# Tests for cumulative_dose.R (Persistence Extensions — Phase 3)
# Run: Rscript Code/tests/test_cumulative_dose.R

suppressPackageStartupMessages({
  library(testthat)
  library(fixest)
})
source("Code/cumulative_dose.R")

# Small synthetic panel with KNOWN shock sequences.
make_panel <- function() {
  data.frame(
    fips_code = rep(c("01001", "01002"), each = 5),
    Year      = rep(2011:2015, times = 2),
    # county 1: shock in 2011, 2013, 2014  -> cum 1,1,2,3,3
    # county 2: shock in 2012, 2015        -> cum 0,1,1,1,2
    shock     = c(1, 0, 1, 1, 0,
                  0, 1, 0, 0, 1),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
test_that("cumulative count is the running sum of shock-years per county", {
  d <- add_cumulative_shock_years(make_panel(), "shock", "cum")
  expect_equal(d$cum[d$fips_code == "01001"], c(1, 1, 2, 3, 3))
  expect_equal(d$cum[d$fips_code == "01002"], c(0, 1, 1, 1, 2))
})

# ---------------------------------------------------------------------------
test_that("cumulative count is monotonic non-decreasing within each county", {
  d <- add_cumulative_shock_years(make_panel(), "shock", "cum")
  for (f in unique(d$fips_code)) {
    cc <- d$cum[d$fips_code == f]
    expect_true(all(diff(cc) >= 0), info = paste("county", f, "must be non-decreasing"))
  }
})

# ---------------------------------------------------------------------------
test_that("does not reset and does not bleed across counties", {
  d <- add_cumulative_shock_years(make_panel(), "shock", "cum")
  # County 2 starts at 0 in 2011 (not carried over from county 1's tail of 3).
  expect_equal(d$cum[d$fips_code == "01002" & d$Year == 2011], 0)
  # Final value equals each county's total shock-years.
  expect_equal(max(d$cum[d$fips_code == "01001"]), 3)
  expect_equal(max(d$cum[d$fips_code == "01002"]), 2)
})

# ---------------------------------------------------------------------------
test_that("NA shock-years contribute 0 and the total carries forward", {
  p <- make_panel()
  p$shock[p$fips_code == "01001" & p$Year == 2013] <- NA   # was a 1
  d <- add_cumulative_shock_years(p, "shock", "cum")
  # 2011=1, 2012=1, 2013(NA)->no increment=1, 2014=2, 2015=2
  expect_equal(d$cum[d$fips_code == "01001"], c(1, 1, 1, 2, 2))
})

# ---------------------------------------------------------------------------
test_that("input row order does not change the per-county result", {
  p <- make_panel()
  shuffled <- p[sample(nrow(p)), ]
  d <- add_cumulative_shock_years(shuffled, "shock", "cum")
  d1 <- d[d$fips_code == "01001", ]
  d1 <- d1[order(d1$Year), ]
  expect_equal(d1$cum, c(1, 1, 2, 3, 3))
})

# ---------------------------------------------------------------------------
test_that("lincom recovers a known linear combination of coefficients", {
  set.seed(42)
  n <- 400
  d <- data.frame(
    g = rep(1:40, each = 10), t = rep(1:10, times = 40),
    a = rnorm(400), b = rnorm(400)
  )
  d$y <- 2 * d$a - 3 * d$b + rnorm(400, 0, 0.5)
  m <- feols(y ~ a + b, data = d)
  # a - b should be about 2 - (-3) = 5
  r <- lincom(m, c(a = 1, b = -1))
  expect_equal(r$estimate, 5, tolerance = 0.2)
  expect_lt(r$p.value, 1e-6)
  # difference equals manual coef arithmetic
  expect_equal(r$estimate, unname(coef(m)["a"] - coef(m)["b"]), tolerance = 1e-10)
})

# ---------------------------------------------------------------------------
test_that("lincom returns NULL on missing terms or NULL model", {
  d <- data.frame(y = rnorm(50), a = rnorm(50))
  m <- feols(y ~ a, data = d)
  expect_null(lincom(m, c(a = 1, nonexistent = -1)))
  expect_null(lincom(NULL, c(a = 1)))
})

cat("\nAll cumulative dose tests completed.\n")
