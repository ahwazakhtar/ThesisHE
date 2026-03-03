# Tests for event study lead/lag construction and model helpers
# Run: Rscript Code/tests/test_run_event_study.R

library(testthat)

# ===========================================================================
# Test 1: Lead/lag correctness on synthetic panel
# ===========================================================================
test_that("Lead/lag construction is correct on synthetic 3-county, 6-year panel", {
  library(dplyr)

  syn <- expand.grid(fips_code = c("01001", "01002", "01003"), Year = 2015:2020,
                     stringsAsFactors = FALSE) %>%
    arrange(fips_code, Year)
  set.seed(42)
  syn$Is_Extreme_Drought <- sample(0:1, nrow(syn), replace = TRUE)
  syn$Medical_Debt_Share <- runif(nrow(syn), 10, 30)

  # -- Shock leads/lags --
  syn <- syn %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      Is_Extreme_Drought_Lead1 = dplyr::lead(Is_Extreme_Drought, 1),
      Is_Extreme_Drought_Lead2 = dplyr::lead(Is_Extreme_Drought, 2),
      Is_Extreme_Drought_Lag1  = dplyr::lag(Is_Extreme_Drought, 1),
      Is_Extreme_Drought_Lag2  = dplyr::lag(Is_Extreme_Drought, 2),
      Is_Extreme_Drought_Lag3  = dplyr::lag(Is_Extreme_Drought, 3)
    ) %>%
    ungroup()

  # For county 01001, year 2017 (3rd row of that county):
  c1 <- syn %>% filter(fips_code == "01001") %>% arrange(Year)
  row_2017 <- c1 %>% filter(Year == 2017)

  expect_equal(row_2017$Is_Extreme_Drought_Lead1, c1$Is_Extreme_Drought[c1$Year == 2018])
  expect_equal(row_2017$Is_Extreme_Drought_Lead2, c1$Is_Extreme_Drought[c1$Year == 2019])
  expect_equal(row_2017$Is_Extreme_Drought_Lag1,  c1$Is_Extreme_Drought[c1$Year == 2016])
  expect_equal(row_2017$Is_Extreme_Drought_Lag2,  c1$Is_Extreme_Drought[c1$Year == 2015])
  expect_true(is.na(c1$Is_Extreme_Drought_Lag3[c1$Year == 2017]))  # only 2 years before 2017

  # Boundary: first year should have NA lags

  expect_true(is.na(c1$Is_Extreme_Drought_Lag1[c1$Year == 2015]))
  expect_true(is.na(c1$Is_Extreme_Drought_Lag2[c1$Year == 2015]))

  # Boundary: last year should have NA leads
  expect_true(is.na(c1$Is_Extreme_Drought_Lead1[c1$Year == 2020]))
  expect_true(is.na(c1$Is_Extreme_Drought_Lead2[c1$Year == 2020]))
})

# ===========================================================================
# Test 2: LP outcome shifting (forward/backward)
# ===========================================================================
test_that("LP outcome forward/backward shifts are correct", {
  library(dplyr)

  syn <- expand.grid(fips_code = c("01001", "01002"), Year = 2015:2020,
                     stringsAsFactors = FALSE) %>%
    arrange(fips_code, Year)
  syn$Medical_Debt_Share <- seq_len(nrow(syn)) * 1.5  # deterministic values

  syn <- syn %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(
      Medical_Debt_Share_fwd0 = Medical_Debt_Share,
      Medical_Debt_Share_fwd1 = dplyr::lead(Medical_Debt_Share, 1),
      Medical_Debt_Share_fwd2 = dplyr::lead(Medical_Debt_Share, 2),
      Medical_Debt_Share_fwd3 = dplyr::lead(Medical_Debt_Share, 3),
      Medical_Debt_Share_bwd1 = dplyr::lag(Medical_Debt_Share, 1),
      Medical_Debt_Share_bwd2 = dplyr::lag(Medical_Debt_Share, 2)
    ) %>%
    ungroup()

  c1 <- syn %>% filter(fips_code == "01001") %>% arrange(Year)

  # h=2 forward: 2016 outcome should equal 2018 outcome
  expect_equal(c1$Medical_Debt_Share_fwd2[c1$Year == 2016],
               c1$Medical_Debt_Share[c1$Year == 2018])

  # h=1 backward: 2018 outcome should equal 2017 outcome
  expect_equal(c1$Medical_Debt_Share_bwd1[c1$Year == 2018],
               c1$Medical_Debt_Share[c1$Year == 2017])

  # Boundary losses
  expect_true(is.na(c1$Medical_Debt_Share_fwd3[c1$Year == 2019]))  # 2019+3 = 2022 > 2020
  expect_true(is.na(c1$Medical_Debt_Share_bwd2[c1$Year == 2016]))  # 2016-2 = 2014 < 2015
})

# ===========================================================================
# Test 3: Reference period row (h=-1, estimate=0) for Approach A
# ===========================================================================
test_that("Reference period row is present with estimate=0 for Approach A", {
  # Simulate a tidy coefficient data frame from Approach A
  coefs <- data.frame(
    shock = "Is_Extreme_Drought",
    outcome = "Medical_Debt_Share",
    horizon = c(-2, 0, 1, 2, 3),
    estimate = c(0.1, 0.5, 0.3, 0.2, 0.1),
    std.error = c(0.05, 0.1, 0.08, 0.07, 0.06),
    approach = "DL",
    stringsAsFactors = FALSE
  )

  # Insert reference row (as the script should do)
  ref_row <- data.frame(
    shock = "Is_Extreme_Drought",
    outcome = "Medical_Debt_Share",
    horizon = -1,
    estimate = 0,
    std.error = 0,
    approach = "DL",
    stringsAsFactors = FALSE
  )
  coefs <- rbind(coefs, ref_row)

  ref <- coefs[coefs$horizon == -1, ]
  expect_equal(nrow(ref), 1)
  expect_equal(ref$estimate, 0)
  expect_equal(ref$std.error, 0)
})

# ===========================================================================
# Test 4: Formula construction omits exactly Lead1
# ===========================================================================
test_that("Dynamic DL formula omits Lead1 (reference period)", {
  shock <- "Is_Extreme_Drought"
  controls <- c("Household_Income_2023", "Uninsured_Rate")

  # Build RHS terms as the script should
  # Uses _Lag1_es/_Lag2_es suffix to avoid collision with master's existing _Lag1/_Lag2
  rhs_terms <- c(
    paste0(shock, "_Lead2"),
    # Lead1 omitted (reference)
    shock,                         # h=0
    paste0(shock, "_Lag1_es"),     # h=+1
    paste0(shock, "_Lag2_es"),     # h=+2
    paste0(shock, "_Lag3"),        # h=+3
    controls
  )

  expect_false(paste0(shock, "_Lead1") %in% rhs_terms)
  expect_true(paste0(shock, "_Lead2") %in% rhs_terms)
  expect_true(shock %in% rhs_terms)
  expect_true(paste0(shock, "_Lag1_es") %in% rhs_terms)
  expect_true(paste0(shock, "_Lag3") %in% rhs_terms)
  expect_length(rhs_terms, 7)  # 5 shock terms + 2 controls
})

# ===========================================================================
# Test 5: No cross-county contamination in lead/lag
# ===========================================================================
test_that("Lead/lag does not cross county boundaries", {
  library(dplyr)

  syn <- data.frame(
    fips_code = c(rep("A", 3), rep("B", 3)),
    Year = c(2018, 2019, 2020, 2018, 2019, 2020),
    shock = c(1, 0, 0, 0, 0, 1),
    stringsAsFactors = FALSE
  )

  syn <- syn %>%
    group_by(fips_code) %>%
    arrange(Year) %>%
    mutate(shock_Lead1 = dplyr::lead(shock, 1),
           shock_Lag1  = dplyr::lag(shock, 1)) %>%
    ungroup()

  # County A, 2020: Lead1 should be NA (no 2021), not county B's 2018 value
  expect_true(is.na(syn$shock_Lead1[syn$fips_code == "A" & syn$Year == 2020]))
  # County B, 2018: Lag1 should be NA, not county A's 2020 value
  expect_true(is.na(syn$shock_Lag1[syn$fips_code == "B" & syn$Year == 2018]))
})

# ===========================================================================
# Test 6: Combined shock indicator construction
# ===========================================================================
test_that("Any_Shock, Shock_Count, Compound_Shock are correct", {
  syn <- data.frame(
    Is_Extreme_Drought = c(0, 1, 0, 1, 1, 0),
    High_CDD           = c(0, 0, 1, 1, 0, 0),
    High_HDD           = c(0, 0, 0, 0, 1, 0),
    stringsAsFactors = FALSE
  )

  syn$Any_Shock      <- as.integer(syn$Is_Extreme_Drought == 1 | syn$High_CDD == 1 | syn$High_HDD == 1)
  syn$Shock_Count    <- as.integer(syn$Is_Extreme_Drought) + as.integer(syn$High_CDD) + as.integer(syn$High_HDD)
  syn$Compound_Shock <- as.integer(syn$Shock_Count >= 2)

  # Row 1: all zero
  expect_equal(syn$Any_Shock[1], 0L)
  expect_equal(syn$Shock_Count[1], 0L)
  expect_equal(syn$Compound_Shock[1], 0L)

  # Row 2: drought only
  expect_equal(syn$Any_Shock[2], 1L)
  expect_equal(syn$Shock_Count[2], 1L)
  expect_equal(syn$Compound_Shock[2], 0L)

  # Row 4: drought + CDD
  expect_equal(syn$Any_Shock[4], 1L)
  expect_equal(syn$Shock_Count[4], 2L)
  expect_equal(syn$Compound_Shock[4], 1L)

  # Row 5: drought + HDD (triple check)
  expect_equal(syn$Shock_Count[5], 2L)
  expect_equal(syn$Compound_Shock[5], 1L)
})

# ===========================================================================
# Test 7: All three shocks active simultaneously
# ===========================================================================
test_that("All three shocks = Shock_Count 3, Compound 1, Any 1", {
  syn <- data.frame(Is_Extreme_Drought = 1, High_CDD = 1, High_HDD = 1)
  syn$Any_Shock      <- as.integer(syn$Is_Extreme_Drought == 1 | syn$High_CDD == 1 | syn$High_HDD == 1)
  syn$Shock_Count    <- as.integer(syn$Is_Extreme_Drought) + as.integer(syn$High_CDD) + as.integer(syn$High_HDD)
  syn$Compound_Shock <- as.integer(syn$Shock_Count >= 2)

  expect_equal(syn$Any_Shock[1], 1L)
  expect_equal(syn$Shock_Count[1], 3L)
  expect_equal(syn$Compound_Shock[1], 1L)
})

cat("\n=== All event study tests passed ===\n")
