library(testthat)
library(dplyr)
library(here)

# ---------------------------------------------------------------------------
# Helper: replicate the baseline Z-score logic from process_county_climate.R
# ---------------------------------------------------------------------------
compute_baseline_zscores <- function(df, val_col, baseline_start = 1990, baseline_end = 2000) {
  baseline_stats <- df %>%
    filter(Year >= baseline_start, Year <= baseline_end) %>%
    group_by(fips_code) %>%
    summarize(
      base_mean = mean(.data[[val_col]], na.rm = TRUE),
      base_sd   = sd(.data[[val_col]], na.rm = TRUE),
      .groups   = "drop"
    )

  df %>%
    left_join(baseline_stats, by = "fips_code") %>%
    mutate(z_score = (.data[[val_col]] - base_mean) / base_sd) %>%
    select(-base_mean, -base_sd)
}

# This test focuses ONLY on the missing value logic, avoiding file I/O.
test_that("Variable-specific missing value logic is correct", {
  
  # --- Setup: Create a dataframe with test cases for each variable type ---
  test_data <- data.frame(
    var = c("precip", "precip", "temp", "temp", "cdd", "cdd", "hdd", "hdd", "pdsi", "pdsi"),
    Value = c(-9.99, 5.00, -99.90, -99.80, -9999.00, 100.00, -10000.00, 200.00, -99.99, -5.00)
  )
  
  # --- Execution: Apply the logic from the script ---
  # We manually replicate the core logic here to test it in isolation.
  processed_data <- test_data %>%
    rowwise() %>%
    mutate(Value_proc = case_when(
      var == "precip" & Value <= -9.99   ~ NA_real_,
      var == "temp"   & Value <= -99.90   ~ NA_real_,
      var %in% c("cdd", "hdd") & Value <= -9999 ~ NA_real_,
      var == "pdsi"   & Value <= -99.99   ~ NA_real_,
      TRUE ~ Value
    )) %>%
    ungroup()
  
  # --- Verification ---
  
  # Expected processed values
  expected_values <- c(NA, 5.00, NA, -99.80, NA, 100.00, NA, 200.00, NA, -5.00)
  
  # Check that the processed values match the expected values
  expect_equal(processed_data$Value_proc, expected_values)

})

# ---------------------------------------------------------------------------
# Tests for baseline Z-score calculation (1990–2000 baseline)
# ---------------------------------------------------------------------------

test_that("Baseline Z-scores use only 1990-2000 window for mean/SD", {
  # County with known baseline values 1990–2000: mean = 15, sd = 2
  baseline_vals <- c(13, 14, 15, 15, 16, 17, 14, 15, 16, 14, 16)  # 11 values, mean~15, sd~1.18
  baseline_mean <- mean(baseline_vals)
  baseline_sd   <- sd(baseline_vals)

  test_df <- data.frame(
    fips_code = rep("01001", 15),
    Year      = 1990:2004,
    temp_val  = c(baseline_vals, 20, 10, 25, 5)  # post-baseline values diverge
  )

  result <- compute_baseline_zscores(test_df, "temp_val")

  # Baseline years: Z-scores computed with baseline mean/sd
  expected_z_1990 <- (13 - baseline_mean) / baseline_sd
  expect_equal(result$z_score[result$Year == 1990], expected_z_1990, tolerance = 1e-10)

  # Post-baseline years: same baseline mean/sd applied, not the full-sample mean/sd
  expected_z_2001 <- (20 - baseline_mean) / baseline_sd
  expect_equal(result$z_score[result$Year == 2001], expected_z_2001, tolerance = 1e-10)
})

test_that("Baseline Z-scores differ from full-sample Z-scores when post-baseline values diverge", {
  # If post-baseline temps are systematically higher, the full-sample mean would be inflated
  # and would make post-baseline Z-scores smaller than the baseline-anchored ones.
  test_df <- data.frame(
    fips_code = rep("01001", 20),
    Year      = 1990:2009,
    temp_val  = c(rep(15, 11), rep(25, 9))  # baseline 1990-2000: mean=15; post: 25
  )

  baseline_mean <- 15
  baseline_sd   <- 0  # all identical — expect NaN; use slightly varied data
  test_df$temp_val[1:11] <- seq(13, 17, length.out = 11)  # baseline sd > 0
  baseline_mean <- mean(test_df$temp_val[1:11])
  baseline_sd   <- sd(test_df$temp_val[1:11])

  result       <- compute_baseline_zscores(test_df, "temp_val")
  full_mean    <- mean(test_df$temp_val)
  full_sd      <- sd(test_df$temp_val)

  # Post-2000 year using baseline anchoring
  z_baseline <- (25 - baseline_mean) / baseline_sd
  z_fullsamp <- (25 - full_mean) / full_sd

  expect_equal(result$z_score[result$Year == 2001], z_baseline, tolerance = 1e-10)
  expect_false(isTRUE(all.equal(z_baseline, z_fullsamp)))
})

test_that("Baseline Z-scores are computed independently per county", {
  test_df <- data.frame(
    fips_code = c(rep("01001", 11), rep("01003", 11)),
    Year      = rep(1990:2000, 2),
    temp_val  = c(seq(10, 14, length.out = 11),   # county A baseline mean ~12
                  seq(20, 24, length.out = 11))    # county B baseline mean ~22
  )

  result <- compute_baseline_zscores(test_df, "temp_val")

  # The Z-score of the first observation in each county should reflect
  # that county's own baseline mean, so Z-scores won't be equal
  z_A_yr1990 <- result$z_score[result$fips_code == "01001" & result$Year == 1990]
  z_B_yr1990 <- result$z_score[result$fips_code == "01003" & result$Year == 1990]

  # Both are the lowest value in their respective series, so both should be negative
  expect_true(z_A_yr1990 < 0)
  expect_true(z_B_yr1990 < 0)

  # But their actual values should be equal since both series are symmetric
  expect_equal(z_A_yr1990, z_B_yr1990, tolerance = 1e-10)
})
