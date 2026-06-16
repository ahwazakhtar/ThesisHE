# Tests for run_hospital_incidence.R  (Hospital Supply-Side Integration — Phase 2)
# Run: Rscript Code/tests/test_hospital_incidence.R

suppressPackageStartupMessages({
  library(testthat)
  library(fixest)
})
source("Code/run_hospital_incidence.R")  # guarded: defines fit_incidence_dl only

# Synthetic hospital panel with a KNOWN distributed-lag data-generating process:
#   Y = 2*Shock + 1*Shock_Lag1 + hospital FE + year FE + small noise
make_panel <- function(n_hosp = 120, years = 2011:2020, seed = 7) {
  set.seed(seed)
  grid <- expand.grid(CCN = sprintf("H%03d", seq_len(n_hosp)), Year = years,
                      stringsAsFactors = FALSE)
  grid <- grid[order(grid$CCN, grid$Year), ]
  grid$State <- rep(state.abb[1 + (seq_len(n_hosp) - 1) %% 20], times = length(years))
  grid$Shock <- rbinom(nrow(grid), 1, 0.3)
  grid <- grid %>% group_by(CCN) %>% arrange(Year) %>%
    mutate(Shock_Lag1 = dplyr::lag(Shock, 1),
           Shock_Lag2 = dplyr::lag(Shock, 2)) %>% ungroup()
  hfe <- setNames(rnorm(n_hosp, 0, 0.5), unique(grid$CCN))
  yfe <- setNames(rnorm(length(years), 0, 0.3), as.character(years))
  grid$Y <- 2 * grid$Shock +
    1 * ifelse(is.na(grid$Shock_Lag1), 0, grid$Shock_Lag1) +
    hfe[grid$CCN] + yfe[as.character(grid$Year)] + rnorm(nrow(grid), 0, 0.2)
  as.data.frame(grid)
}

test_that("fit_incidence_dl recovers the per-horizon coefficients", {
  d <- make_panel()
  r <- fit_incidence_dl(d, "Y", "Shock")
  h0 <- r$estimate[r$term == "Shock"]
  h1 <- r$estimate[r$term == "Shock_Lag1"]
  expect_equal(h0, 2, tolerance = 0.1)
  expect_equal(h1, 1, tolerance = 0.1)
})

test_that("the cumulative row equals the sum of the horizon coefficients", {
  d <- make_panel()
  r <- fit_incidence_dl(d, "Y", "Shock")
  horiz_sum <- sum(r$estimate[r$horizon < 90])
  cum <- r$estimate[r$term == "Cumulative"]
  expect_equal(cum, horiz_sum, tolerance = 1e-8)
  expect_equal(cum, 3, tolerance = 0.15)  # 2 + 1 + ~0
})

test_that("output has one row per horizon plus a cumulative summary", {
  d <- make_panel()
  r <- fit_incidence_dl(d, "Y", "Shock")
  expect_true(all(c("Shock", "Shock_Lag1", "Shock_Lag2", "Cumulative") %in% r$term))
  expect_true(all(c("estimate", "std.error", "p.value", "N", "n_hosp") %in% names(r)))
  expect_equal(unique(r$n_hosp), 120)
})

# Integration: the real coefficients file is well-formed if it has been produced.
test_that("incidence coefficient artifact is well-formed when present", {
  f <- "Analysis/hospital_incidence_coefs.csv"
  if (!file.exists(f)) skip("run run_hospital_incidence.R first")
  co <- read.csv(f, stringsAsFactors = FALSE)
  expect_true(all(c("shock", "outcome", "term", "estimate", "p.value") %in% names(co)))
  expect_true(any(co$term == "Cumulative"))
  om <- co[co$outcome == "Hosp_OperatingMargin" & co$horizon == 0, "estimate"]
  expect_true(all(abs(om) < 1, na.rm = TRUE))  # margin effects are small proportions
})

cat("\nAll hospital incidence tests completed.\n")
