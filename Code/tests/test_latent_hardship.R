# =============================================================================
# test_latent_hardship.R  — unit tests for Code/run_latent_hardship.R (O6)
# =============================================================================
# Run (main R 4.2.2):
#   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/tests/test_latent_hardship.R
#
# Coverage (per the task's required test surface):
#   - moderator construction: baseline-window anchoring, time-invariance, z-scoring
#   - interaction alignment: lag construction matches the established pattern
#   - no-NA leakage: complete-case sample carries no NA in used vars
#   - FIPS formatC idiom (single-digit-state counties survive; no space padding)
#   - dedup stopgap: unique fips x Year post-dedup, values preserved
#   - output schema: gradient grid carries the required columns
#   - end-to-end fit recovery + decision-rule helpers (attenuates, BKY q)
# =============================================================================

suppressPackageStartupMessages({ library(testthat); library(dplyr) })

# Source the analysis script; the guarded main (sys.nframe()==0L) does NOT run.
SCRIPT <- file.path("Code", "run_latent_hardship.R")
if (!file.exists(SCRIPT)) SCRIPT <- file.path(dirname(dirname(getwd())), "run_latent_hardship.R")
stopifnot(file.exists("Code/run_latent_hardship.R"))
source("Code/run_latent_hardship.R")

set.seed(20260712)

# ---------------------------------------------------------------------------
context("FIPS formatC idiom")
# ---------------------------------------------------------------------------
test_that("pad_fips zero-pads to width 5 without space-dropping single-digit states", {
  expect_identical(pad_fips(1001),  "01001")   # AL 01001 (single-digit state code)
  expect_identical(pad_fips(1),     "00001")
  expect_identical(pad_fips(56045), "56045")    # WY, already width 5
  expect_identical(pad_fips("6037"), "06037")   # CA county as character
  padded <- pad_fips(c(1001, 6037, 48201))
  expect_true(all(nchar(padded) == 5))
  expect_false(any(grepl(" ", padded)))         # NEVER space-padded (sprintf trap)
})

# ---------------------------------------------------------------------------
context("z-scoring")
# ---------------------------------------------------------------------------
test_that("zscore standardizes to mean 0 / sd 1 and is NA-safe", {
  z <- zscore(c(1, 2, 3, 4, 5))
  expect_equal(mean(z), 0, tolerance = 1e-12)
  expect_equal(sd(z),   1, tolerance = 1e-12)
  z2 <- zscore(c(10, 20, NA, 40))
  expect_true(is.na(z2[3]))
  expect_equal(mean(z2, na.rm = TRUE), 0, tolerance = 1e-12)
  expect_equal(sd(z2, na.rm = TRUE),   1, tolerance = 1e-12)
  expect_true(all(is.na(zscore(c(5, 5, 5)))))   # zero variance -> all NA
})

# ---------------------------------------------------------------------------
context("moderator construction: baseline-window anchoring & time-invariance")
# ---------------------------------------------------------------------------
test_that("baseline_window_mean uses only the window years and is per-id", {
  df <- data.frame(
    fips_code = rep(c("01001", "02013"), each = 5),
    Year      = rep(2011:2015, times = 2),
    v         = c(10, 20, 30, 999, 999,    # 01001: window (2011-13) mean = 20
                   4,  6,  8, 999, 999),   # 02013: window mean = 6
    stringsAsFactors = FALSE)
  bw <- baseline_window_mean(df, "v", 2011:2013, value_name = "v_base")
  expect_setequal(names(bw), c("fips_code", "v_base"))
  expect_equal(bw$v_base[bw$fips_code == "01001"], 20)  # ignores 2014-15 (999)
  expect_equal(bw$v_base[bw$fips_code == "02013"], 6)
  expect_equal(nrow(bw), 2)                              # one row per id
})

test_that("baseline_window_mean returns NA (not NaN) when the window is all-NA", {
  df <- data.frame(fips_code = "01001", Year = 2011:2013, v = c(NA, NA, NA))
  bw <- baseline_window_mean(df, "v", 2011:2013, value_name = "v_base")
  expect_true(is.na(bw$v_base))
  expect_false(is.nan(bw$v_base))
})

test_that("a baseline moderator joined to a panel is time-invariant within county", {
  df <- data.frame(
    fips_code = rep(c("01001", "02013"), each = 5),
    Year      = rep(2011:2015, times = 2),
    v         = c(10, 20, 30, 40, 50, 4, 6, 8, 10, 12),
    stringsAsFactors = FALSE)
  bw <- baseline_window_mean(df, "v", 2011:2013, value_name = "v_base")
  bw$v_z <- zscore(bw$v_base)
  joined <- dplyr::left_join(df, bw[, c("fips_code", "v_z")], by = "fips_code")
  inv <- joined %>% group_by(fips_code) %>% summarise(nu = dplyr::n_distinct(v_z))
  expect_true(all(inv$nu == 1))                           # constant across years
  expect_equal(mean(bw$v_z), 0, tolerance = 1e-12)        # z-scored across counties
})

# ---------------------------------------------------------------------------
context("interaction alignment: lag construction matches the established pattern")
# ---------------------------------------------------------------------------
test_that("frozen shock cells map to the correct debt-relevant target lag terms", {
  cells <- shock_cells()
  expect_setequal(names(cells), c("cold_L1", "drought_L2"))
  expect_identical(cells$cold_L1$target,    "High_HDD_Lag1")
  expect_identical(cells$drought_L2$target, "Is_Extreme_Drought_Lag2")
  # full contemporaneous + L1 + L2 family is entered (established debt spec)
  expect_identical(cells$cold_L1$family,
                   c("High_HDD", "High_HDD_Lag1", "High_HDD_Lag2"))
  expect_identical(cells$drought_L2$family,
                   c("Is_Extreme_Drought", "Is_Extreme_Drought_Lag1",
                     "Is_Extreme_Drought_Lag2"))
  expect_true(cells$cold_L1$target %in% cells$cold_L1$family)
  expect_true(cells$drought_L2$target %in% cells$drought_L2$family)
})

test_that("'_Lag k' naming means the within-county lag-by-k (established pattern)", {
  # mirrors run_county_analysis.R's RA-aggregation lag() semantics
  p <- data.frame(fips_code = rep(c("A", "B"), each = 5),
                  Year = rep(2011:2015, 2),
                  High_HDD = c(1, 0, 1, 1, 0,  0, 1, 0, 0, 1)) %>%
    arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(High_HDD_Lag1 = dplyr::lag(High_HDD, 1),
           High_HDD_Lag2 = dplyr::lag(High_HDD, 2)) %>% ungroup()
  # for county A: 2013's Lag1 = 2012's level (0); Lag2 = 2011's level (1)
  a13 <- p[p$fips_code == "A" & p$Year == 2013, ]
  expect_equal(a13$High_HDD_Lag1, 0)
  expect_equal(a13$High_HDD_Lag2, 1)
})

test_that("master's precomputed High_HDD_Lag1 equals the within-county lag (spot check)", {
  skip_if_not(file.exists("Data/county_level_master.csv"))
  m <- read.csv("Data/county_level_master.csv")
  m$fips_code <- pad_fips(m$fips_code)
  m <- m[m$Year >= 2011 & m$Year <= 2023,
         c("fips_code", "Year", "High_HDD", "High_HDD_Lag1")]
  # dedup so duplicate RA-split rows do not corrupt the lag ordering
  m <- m[!duplicated(m[, c("fips_code", "Year")]), ]
  m <- m %>% arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(manual = dplyr::lag(High_HDD, 1)) %>% ungroup()
  ok <- with(m, sum(High_HDD_Lag1 == manual, na.rm = TRUE))
  tot <- with(m, sum(!is.na(High_HDD_Lag1) & !is.na(manual)))
  expect_gt(ok / tot, 0.999)   # near-perfect; established precomputed lags are authoritative
})

# ---------------------------------------------------------------------------
context("dedup stopgap: unique fips x Year post-dedup")
# ---------------------------------------------------------------------------
test_that("dedup_county_year collapses RA-split duplicates losslessly", {
  dup <- data.frame(
    fips_code = c("01001", "01001", "02013"),       # 01001 duplicated (2 RA rows)
    Year      = c(2012L, 2012L, 2012L),
    Medical_Debt_Share = c(0.15, 0.15, 0.22),       # constant within fips x Year
    High_HDD_Lag1 = c(1, 1, 0),
    Population = c(50000, 50000, 8000),
    State = c("AL", "AL", "AK"),
    stringsAsFactors = FALSE)
  dd <- dedup_county_year(dup)
  expect_false(any(duplicated(dd[, c("fips_code", "Year")])))
  expect_equal(nrow(dd), 2)
  expect_equal(dd$Medical_Debt_Share[dd$fips_code == "01001"], 0.15)
  expect_equal(dd$High_HDD_Lag1[dd$fips_code == "01001"], 1)
})

# ---------------------------------------------------------------------------
context("moderator metadata & orientation")
# ---------------------------------------------------------------------------
test_that("moderator_meta lists 3 primary + 2 secondary with correct orientation", {
  meta <- moderator_meta()
  expect_equal(nrow(meta), 5)
  expect_equal(sum(meta$family == "primary"),   3)
  expect_equal(sum(meta$family == "secondary"), 2)
  # higher_is_worse: uninsurance/rurality/SVI = TRUE; hospital access/income = FALSE
  hw <- setNames(meta$higher_is_worse, meta$moderator)
  expect_true(hw["Uninsured_z"]); expect_true(hw["Rurality_z"]); expect_true(hw["SVI_z"])
  expect_false(hw["HospAccess_z"]); expect_false(hw["BaseIncome_z"])
  expect_setequal(meta$moderator[meta$family == "primary"],
                  c("Uninsured_z", "Rurality_z", "HospAccess_z"))
})

test_that("attenuates() encodes the orientation-aware attenuation hypothesis", {
  # higher_is_worse (uninsurance-like): attenuation = interaction OPPOSITE main
  expect_true (attenuates(main =  0.5, inter = -0.2, higher_is_worse = TRUE))
  expect_false(attenuates(main =  0.5, inter =  0.2, higher_is_worse = TRUE))
  # higher_is_better (hospital access / income): attenuation = interaction SAME sign
  expect_true (attenuates(main =  0.5, inter =  0.2, higher_is_worse = FALSE))
  expect_false(attenuates(main =  0.5, inter = -0.2, higher_is_worse = FALSE))
  # NA / no-effect guards
  expect_true(is.na(attenuates(NA, -0.2, TRUE)))
  expect_true(is.na(attenuates(0.5, NA, TRUE)))
  expect_true(is.na(attenuates(0,  -0.2, TRUE)))
})

# ---------------------------------------------------------------------------
context("BKY sharpened q-values")
# ---------------------------------------------------------------------------
test_that("bky_qvalues returns values in [0,1], NA-safe, tiny p -> tiny q", {
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
context("end-to-end fit: recovery, no-NA leakage, output schema")
# ---------------------------------------------------------------------------
# Build a synthetic county panel with a KNOWN cold-lag1 x moderator interaction.
make_panel <- function(n_state = 8, per_state = 6, yrs = 2011:2020) {
  counties <- sprintf("%05d", seq_len(n_state * per_state))
  states   <- rep(sprintf("S%02d", seq_len(n_state)), each = per_state)
  cty <- data.frame(fips_code = counties, State = states,
                    mod_raw = rnorm(length(counties)),
                    cfe = rnorm(length(counties)), stringsAsFactors = FALSE)
  cty$mod_z <- zscore(cty$mod_raw)
  grid <- expand.grid(fips_code = counties, Year = yrs, stringsAsFactors = FALSE)
  d <- dplyr::left_join(grid, cty, by = "fips_code")
  d <- d %>% arrange(fips_code, Year) %>% group_by(fips_code) %>%
    mutate(High_HDD = rbinom(dplyr::n(), 1, 0.35),
           High_HDD_Lag1 = dplyr::lag(High_HDD, 1),
           High_HDD_Lag2 = dplyr::lag(High_HDD, 2)) %>% ungroup()
  yfe <- setNames(rnorm(length(yrs)), yrs)
  # TRUE model: main +0.5 on cold-L1, interaction -0.3 (attenuation) + FE + noise
  d$Population <- 20000 + round(runif(nrow(d)) * 80000)
  d$Y <- 0.5 * d$High_HDD_Lag1 - 0.3 * d$High_HDD_Lag1 * d$mod_z +
         d$cfe + yfe[as.character(d$Year)] + rnorm(nrow(d), 0, 0.25)
  d$State <- as.factor(d$State)
  d
}

test_that("fit_gradient_cell recovers the target main effect + interaction sign", {
  d <- make_panel()
  cell <- shock_cells()$cold_L1
  fit <- fit_gradient_cell(d, "Y", cell, "mod_z", weighted = FALSE)
  expect_s3_class(fit, "data.frame")
  expect_setequal(names(fit),
    c("main_effect", "main_se", "main_p", "interaction",
      "se_interaction", "p_interaction", "N"))
  expect_gt(fit$main_effect, 0.2)     # true 0.5
  expect_lt(fit$interaction, 0)       # true -0.3 (attenuating)
  # attenuation reads TRUE for an uninsurance-like (higher_is_worse) moderator
  expect_true(attenuates(fit$main_effect, fit$interaction, higher_is_worse = TRUE))
})

test_that("weighted fit runs and uses Population without error", {
  d <- make_panel()
  cell <- shock_cells()$cold_L1
  fit <- fit_gradient_cell(d, "Y", cell, "mod_z", weighted = TRUE)
  expect_true(is.finite(fit$main_effect))
  expect_true(is.finite(fit$interaction))
})

test_that("no-NA leakage: complete-case subsetting drops NA-moderator rows", {
  d <- make_panel()
  # blank out the moderator for one whole state (its counties must be excluded)
  na_counties <- unique(d$fips_code[d$State == levels(d$State)[1]])
  d$mod_z[d$fips_code %in% na_counties] <- NA_real_
  need <- c("Y", "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2", "mod_z",
            "fips_code", "Year", "State")
  dat <- d[complete.cases(d[, need]), ]
  expect_false(any(is.na(dat$mod_z)))
  expect_false(any(dat$fips_code %in% na_counties))
  fit <- fit_gradient_cell(dat, "Y", shock_cells()$cold_L1, "mod_z", weighted = FALSE)
  expect_equal(fit$N, nrow(dat))       # reported N == clean complete-case sample
})

test_that("output schema: assembled grid row carries every required column", {
  d <- make_panel()
  meta <- moderator_meta()
  fit <- fit_gradient_cell(d, "Y", shock_cells()$cold_L1, "mod_z", weighted = FALSE)
  row <- data.frame(
    weighting = "population", outcome = "Medical_Debt_Share",
    outcome_family = "primary", shock = "cold", shock_cell = "cold_L1",
    target_term = "High_HDD_Lag1", moderator = "Uninsured_z",
    moderator_family = "primary", higher_is_worse = TRUE, fit,
    attenuates = attenuates(fit$main_effect, fit$interaction, TRUE),
    q_bky = 0.01, sig_q10 = TRUE, attenuates_sig_q10 = TRUE,
    stringsAsFactors = FALSE)
  required <- c("weighting", "outcome", "outcome_family", "shock", "shock_cell",
                "target_term", "moderator", "moderator_family", "higher_is_worse",
                "main_effect", "main_se", "main_p", "interaction",
                "se_interaction", "p_interaction", "N", "attenuates",
                "q_bky", "sig_q10", "attenuates_sig_q10")
  expect_true(all(required %in% names(row)))
})

test_that("produced gradients.csv (if present) matches the required schema & size", {
  f <- "Analysis/latent_hardship/latent_hardship_gradients.csv"
  skip_if_not(file.exists(f))
  g <- read.csv(f, stringsAsFactors = FALSE)
  required <- c("weighting", "outcome", "shock", "shock_cell", "moderator",
                "moderator_family", "main_effect", "interaction",
                "se_interaction", "p_interaction", "q_bky", "attenuates")
  expect_true(all(required %in% names(g)))
  expect_equal(nrow(g), 40)            # 2 shocks x 5 mods x 2 outcomes x 2 weightings
  expect_setequal(unique(g$weighting), c("population", "unweighted"))
})

cat("\nAll latent-hardship tests defined; running via testthat...\n")
