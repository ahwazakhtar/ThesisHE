library(testthat)
library(dplyr)
library(here)

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
