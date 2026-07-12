# Tests for Code/hospital_winsorize.R  (audit_response_20260712 task 2.4)
# Run: Rscript Code/tests/test_hospital_winsorize.R
suppressPackageStartupMessages({ library(testthat) })
source("Code/hospital_winsorize.R")

test_that("winsorize_vec clips to the [p, 1-p] quantiles", {
  x <- c(1:100, -1e6, 1e6)                 # two extreme outliers
  w <- winsorize_vec(x, p = 0.01)
  q <- quantile(x, c(0.01, 0.99), na.rm = TRUE, names = FALSE, type = 7)
  expect_equal(min(w), q[1])
  expect_equal(max(w), q[2])
  expect_true(all(w >= q[1] & w <= q[2]))
  # interior values are untouched
  expect_equal(w[x > q[1] & x < q[2]], x[x > q[1] & x < q[2]])
})

test_that("winsorize_vec preserves NA and passes non-numeric through", {
  x <- c(1, NA, 5, 100, NA)
  w <- winsorize_vec(x, p = 0.25)
  expect_equal(which(is.na(w)), which(is.na(x)))
  expect_identical(winsorize_vec(letters), letters)     # non-numeric untouched
})

test_that("winsorize_vec leaves degenerate (constant) windows unchanged", {
  x <- rep(7, 20)
  expect_equal(winsorize_vec(x, 0.01), x)               # lo == hi, returned as-is
})

test_that("winsorize_within_year trims each year to its OWN tails", {
  # Year 2011 centered near 0; year 2012 centered near 1000. A value of 900 is an
  # outlier within 2011 but ordinary within 2012 -> within-year must treat them
  # differently (a pooled winsorization would not).
  set.seed(1)
  df <- data.frame(
    Year = rep(c(2011, 2012), each = 200),
    Y    = c(rnorm(200, 0, 1), rnorm(200, 1000, 1))
  )
  df$Y[1]   <- 900     # extreme HIGH within 2011
  df$Y[201] <- 100     # extreme LOW within 2012
  w <- winsorize_within_year(df, "Y", p = 0.01, year_col = "Year")
  hi_2011 <- quantile(df$Y[df$Year == 2011], 0.99, names = FALSE, type = 7)
  lo_2012 <- quantile(df$Y[df$Year == 2012], 0.01, names = FALSE, type = 7)
  expect_equal(w$Y[1], hi_2011)          # 2011 outlier pulled to 2011's p99
  expect_equal(w$Y[201], lo_2012)        # 2012 outlier pulled to 2012's p01
  # every year stays within its own [p1, p99]
  for (y in unique(df$Year)) {
    yy <- w$Y[w$Year == y]
    b  <- quantile(df$Y[df$Year == y], c(0.01, 0.99), names = FALSE, type = 7)
    expect_true(all(yy >= b[1] - 1e-9 & yy <= b[2] + 1e-9))
  }
})

test_that("winsorize_within_year skips absent columns and keeps others intact", {
  df <- data.frame(Year = rep(2011:2012, each = 5), A = 1:10)
  w  <- winsorize_within_year(df, c("A", "DOES_NOT_EXIST"), p = 0.1)
  expect_true("A" %in% names(w))
  expect_equal(nrow(w), nrow(df))        # no rows dropped, no error on missing col
})

test_that("winsorize_within_year winsorizes several columns independently", {
  df <- data.frame(Year = rep(2011, 100), A = c(1:99, 1e6), B = c(-1e6, 2:100))
  w  <- winsorize_within_year(df, c("A", "B"), p = 0.01)
  expect_equal(max(w$A), quantile(df$A, 0.99, names = FALSE, type = 7))
  expect_equal(min(w$B), quantile(df$B, 0.01, names = FALSE, type = 7))
})

test_that("HOSP_WINSORIZE gate and suffix track the env var", {
  old <- Sys.getenv("HOSP_WINSORIZE", unset = NA)
  Sys.setenv(HOSP_WINSORIZE = "1")
  expect_true(hosp_winsor_active())
  expect_equal(hosp_winsor_suffix(), "_winsorized")
  Sys.unsetenv("HOSP_WINSORIZE")
  expect_false(hosp_winsor_active())
  expect_equal(hosp_winsor_suffix(), "")
  if (!is.na(old)) Sys.setenv(HOSP_WINSORIZE = old)
})

cat("\nAll hospital winsorization tests completed.\n")
