# Tests for run_hospital_heterogeneity.R  (Hospital Supply-Side Integration — Phase 4)
# Run: Rscript Code/tests/test_hospital_heterogeneity.R

suppressPackageStartupMessages({
  library(testthat)
  library(fixest)
  library(dplyr)
})
source("Code/run_hospital_heterogeneity.R")  # guarded: helpers only

# ---------------------------------------------------------------------------
# compute_hhi
# ---------------------------------------------------------------------------
test_that("compute_hhi: monopoly=1, two equal firms=0.5, system aggregates", {
  d <- data.frame(
    fips_code = c("A", "B", "B", "C", "C"),
    Year      = 2011L,
    CCN       = c("1", "2", "3", "4", "5"),
    SystemAffiliated = c(0, 0, 0, 1, 1),
    SystemID  = c("", "", "", "S9", "S9"),   # C's two hospitals share a system
    Hosp_NetPatientRevenue = c(100, 100, 100, 100, 100),
    stringsAsFactors = FALSE
  )
  h <- compute_hhi(d)
  expect_equal(h$MarketConcentration[h$fips_code == "A"], 1)      # single hospital
  expect_equal(h$n_firms[h$fips_code == "A"], 1L)
  expect_equal(h$MarketConcentration[h$fips_code == "B"], 0.5)    # two independent firms
  expect_equal(h$n_firms[h$fips_code == "B"], 2L)
  expect_equal(h$MarketConcentration[h$fips_code == "C"], 1)      # one system = one firm
  expect_equal(h$n_firms[h$fips_code == "C"], 1L)
})

test_that("compute_hhi: unequal shares give the right index", {
  d <- data.frame(
    fips_code = "A", Year = 2011L, CCN = c("1", "2"),
    SystemAffiliated = c(0, 0), SystemID = c("", ""),
    Hosp_NetPatientRevenue = c(300, 100), stringsAsFactors = FALSE)
  h <- compute_hhi(d)
  expect_equal(h$MarketConcentration, 0.75^2 + 0.25^2)  # 0.625
})

# ---------------------------------------------------------------------------
# marginal_binary
# ---------------------------------------------------------------------------
test_that("marginal_binary recovers level-0 and level-1 marginal shock effects", {
  set.seed(11)
  n <- 4000
  d <- data.frame(Shock = rbinom(n, 1, 0.4), M = rbinom(n, 1, 0.5))
  d$Y <- 1.0 * d$Shock + 0.5 * d$Shock * d$M + rnorm(n, 0, 0.3)
  m <- feols(Y ~ Shock * M, data = d)
  mb <- marginal_binary(m, "Shock", "Shock:M", "M")
  e0 <- mb$estimate[mb$level == "0"]
  e1 <- mb$estimate[mb$level == "1"]
  expect_equal(e0, 1.0, tolerance = 0.05)
  expect_equal(e1, 1.5, tolerance = 0.05)
  # interaction attribute ~ 0.5
  expect_equal(attr(mb, "interaction")$estimate, 0.5, tolerance = 0.05)
})

# ---------------------------------------------------------------------------
# strain_verdict (outcome-aware)
# ---------------------------------------------------------------------------
test_that("strain_verdict is outcome-aware", {
  # uncompensated care: higher = worse -> vulnerable worse if higher
  expect_match(strain_verdict("Hosp_UncompCare_PctNPR", 0.2, 0.1), "concentrates")
  expect_match(strain_verdict("Hosp_UncompCare_PctNPR", 0.1, 0.2), "no concentration")
  # operating margin: lower = worse -> vulnerable worse if more negative
  expect_match(strain_verdict("Hosp_OperatingMargin", -0.2, -0.1), "concentrates")
  expect_match(strain_verdict("Hosp_OperatingMargin", -0.1, -0.2), "no concentration")
  expect_true(is.na(strain_verdict("Hosp_OperatingMargin", NA, -0.1)))
})

# ---------------------------------------------------------------------------
test_that("heterogeneity artifact is well-formed when present", {
  f <- "Analysis/hospital/hospital_heterogeneity_coefs.csv"
  if (!file.exists(f)) skip("run run_hospital_heterogeneity.R first")
  co <- read.csv(f, stringsAsFactors = FALSE)
  expect_true(all(c("moderator", "level", "estimate", "shock", "outcome", "verdict") %in% names(co)))
  expect_true(all(c("SafetyNet", "Ownership", "MedicaidExpansion", "HighConcentration") %in%
                    unique(co$moderator)))
})

cat("\nAll hospital heterogeneity tests completed.\n")
