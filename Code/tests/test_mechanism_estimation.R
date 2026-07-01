# Tests for the Phase-2 mechanism ESTIMATION machinery.
# Track: mechanism_channels_20260625.  Run: Rscript Code/tests/test_mechanism_estimation.R
#
# The Phase-2 scripts (run_mechanism_agriculture.R / _medicare.R / _secondary.R) run
# top-to-bottom rather than exporting helpers, so we test in two layers:
#   (1) METHOD tests on a SYNTHETIC panel with a planted interaction/subsample structure,
#       replicating the exact estimator the scripts use (feols, County+Year FE, the
#       shock x z(moderator) interaction, and the bottom-tercile subsample). These confirm
#       the design recovers known signs.
#   (2) INTEGRATION tests on the produced coefficient CSVs (schema, expected specs/moderators,
#       Medicare 2014-2023 window), skipped if a build has not been run.

suppressPackageStartupMessages({ library(testthat); library(fixest) })

zscore <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)

# ---------------------------------------------------------------------------
# (1) Synthetic-panel method tests
# ---------------------------------------------------------------------------
make_panel <- function(n_county = 90, n_year = 8, beta = 200, theta = -400, seed = 1) {
  set.seed(seed)
  cty <- sprintf("%05d", seq_len(n_county))
  # time-invariant moderator, evenly spread so terciles are balanced
  modv <- setNames(seq(0, 1, length.out = n_county)[order(runif(n_county))], cty)
  grid <- expand.grid(fips_code = cty, Year = seq_len(n_year), stringsAsFactors = FALSE)
  grid$Mod   <- modv[grid$fips_code]
  grid$Mod_z <- zscore(grid$Mod)
  grid$cfe   <- as.numeric(factor(grid$fips_code))          # county fixed effect
  grid$yfe   <- grid$Year * 1.5                             # year fixed effect
  grid$Shock <- rbinom(nrow(grid), 1, 0.3)
  # planted DGP: Y = cfe + yfe + beta*Shock + theta*Shock*Mod_z + noise
  grid$Y <- grid$cfe * 10 + grid$yfe + beta * grid$Shock +
            theta * grid$Shock * grid$Mod_z + rnorm(nrow(grid), 0, 15)
  grid
}

test_that("interaction spec recovers the planted sign and magnitude", {
  d <- make_panel(beta = 200, theta = -400)
  m <- feols(Y ~ Shock + Shock:Mod_z | fips_code + Year, data = d, cluster = "fips_code")
  cf <- coef(m)
  expect_true(cf[["Shock"]] > 100)             # main effect recovered near +200
  expect_true(cf[["Shock:Mod_z"]] < -200)      # interaction recovered near -400 (negative)
  # significance of the interaction
  p_int <- as.data.frame(coeftable(m))["Shock:Mod_z", 4]
  expect_lt(p_int, 0.05)
})

test_that("tercile split is balanced and bottom tercile inverts the interaction contribution", {
  d <- make_panel(beta = 200, theta = -400)
  # tercile on the time-invariant moderator (one value per county)
  cty <- unique(d[, c("fips_code", "Mod")])
  cty$terc <- as.integer(cut(cty$Mod,
                             quantile(cty$Mod, c(0, 1/3, 2/3, 1)), include.lowest = TRUE, labels = FALSE))
  tab <- table(cty$terc)
  expect_length(tab, 3)
  expect_lt(max(tab) - min(tab), 3)            # balanced within rounding
  # bottom tercile = low moderator => Mod_z negative => theta*Mod_z positive =>
  # the shock effect estimated there should exceed the main beta
  d2 <- merge(d, cty[, c("fips_code", "terc")], by = "fips_code")
  m_bot <- feols(Y ~ Shock | fips_code + Year, data = d2[d2$terc == 1, ], cluster = "fips_code")
  expect_gt(coef(m_bot)[["Shock"]], 200)       # inflated above beta because -400*neg > 0
})

# ---------------------------------------------------------------------------
# (2) Integration tests on produced CSVs
# ---------------------------------------------------------------------------
skip_if_absent <- function(p) if (!file.exists(p)) skip(paste("not built:", p))

test_that("ag_channel_coefs has expected specs and both moderators", {
  skip_if_absent("Analysis/mechanism/ag_channel_coefs.csv")
  d <- read.csv("Analysis/mechanism/ag_channel_coefs.csv", stringsAsFactors = FALSE)
  expect_true(all(c("outcome","shock","moderator","spec","term","estimate","se","p") %in% names(d)))
  expect_setequal(unique(d$spec), c("overall","interaction","subsample_bottom"))
  expect_true(all(c("Ag","Labor") %in% d$moderator))
  expect_true(all(d$n_counties > 100))
})

test_that("medicare_channel_coefs covers the 2014-2023 outcomes and both specs", {
  skip_if_absent("Analysis/mechanism/medicare_channel_coefs.csv")
  d <- read.csv("Analysis/mechanism/medicare_channel_coefs.csv", stringsAsFactors = FALSE)
  expect_setequal(unique(d$spec), c("overall","subsample_low_ag"))
  expect_true("Mdcr_Std_Payment_PC" %in% d$outcome)
  expect_true("AQI" %in% d$shock)
  # the Medicare panel is 2014-2023 => fewer obs than the full 2011-2023 count for the same shocks
  expect_true(all(d$n < 40000))
})

test_that("medicare intermediate is strictly within 2014-2023", {
  skip_if_absent("Data/intermediate_medicare_spending.rds")
  m <- readRDS("Data/intermediate_medicare_spending.rds")
  expect_gte(min(m$Year), 2014); expect_lte(max(m$Year), 2023)
})

cat("mechanism estimation tests defined.\n")
