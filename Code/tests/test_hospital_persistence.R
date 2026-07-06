# Tests for run_hospital_persistence.R  (Hospital Supply-Side Integration — Phase 3)
# Run: Rscript Code/tests/test_hospital_persistence.R

suppressPackageStartupMessages({
  library(testthat)
})
source("Code/run_hospital_persistence.R")  # guarded: defines make_transitions only

test_that("make_transitions encodes 0->1 onset, 1->1 persist, 1->0 exit", {
  d <- data.frame(
    CCN   = "H1",
    Year  = 2011:2016,
    #          t-1: NA  0  1  1  0  1   (last year's shock)
    S       = c(0, 1, 1, 0, 1, 0),
    S_Lag1  = c(NA, 0, 1, 1, 0, 1)
  )
  d <- make_transitions(d, "S")
  expect_equal(d$S_Onset,   c(NA, 1L, 0L, 0L, 1L, 0L))  # 0->1 transitions (NA where lag NA)
  expect_equal(d$S_Persist, c(NA, 0L, 1L, 0L, 0L, 0L))  # 1->1
  expect_equal(d$S_Exit,    c(NA, 0L, 0L, 1L, 0L, 1L))  # 1->0
})

test_that("the three transition states are mutually exclusive", {
  set.seed(3)
  d <- data.frame(CCN = "H1", Year = 2011:2030,
                  S = rbinom(20, 1, 0.5))
  d$S_Lag1 <- c(NA, head(d$S, -1))
  d <- make_transitions(d, "S")
  both <- d$S_Onset + d$S_Persist + d$S_Exit
  ok <- !is.na(both)
  expect_true(all(both[ok] <= 1))            # never two states at once
  # When in shock (S==1) exactly one of onset/persist is 1 (given non-NA lag)
  in_shock <- ok & d$S == 1
  expect_true(all((d$S_Onset + d$S_Persist)[in_shock] == 1))
})

test_that("persistence artifact is well-formed and flags a verdict when present", {
  f <- "Analysis/hospital/hospital_persistence_coefs.csv"
  if (!file.exists(f)) skip("run run_hospital_persistence.R first")
  co <- read.csv(f, stringsAsFactors = FALSE)
  expect_true(all(c("analysis", "shock", "outcome", "asymmetry", "p.value") %in% names(co)))
  expect_true(any(co$analysis == "symmetry"))
  expect_true(any(co$analysis %in% c("dose_marginal", "dose_high_vs_low")))
})

cat("\nAll hospital persistence tests completed.\n")
