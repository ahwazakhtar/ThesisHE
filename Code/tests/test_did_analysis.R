# Tests for Committee Phase 3 DiD analysis (Code/run_did_analysis.R)
# Run: Rscript Code/tests/test_did_analysis.R

suppressPackageStartupMessages({
  library(testthat)
  library(dplyr)
  library(fixest)
})

# ---------------------------------------------------------------------------
# Synthetic 2x2 DiD fixture with known treatment effect
# ---------------------------------------------------------------------------
make_2x2_panel <- function(n_treated = 30, n_control = 100, event_year = 2012,
                           year_range = 2010:2015, tau = 0.5, seed = 41) {
  set.seed(seed)
  fips <- c(sprintf("T%04d", seq_len(n_treated)),
            sprintf("C%04d", seq_len(n_control)))
  d <- expand.grid(fips_code = fips, Year = year_range, stringsAsFactors = FALSE)
  d$Treated <- as.integer(grepl("^T", d$fips_code))
  d$Post <- as.integer(d$Year >= event_year)
  d$Treated_x_Post <- d$Treated * d$Post

  # Unit FE + time FE + treatment effect + noise
  unit_fe <- setNames(rnorm(length(fips), 0, 1), fips)
  year_fe <- setNames(seq_along(year_range) * 0.2, as.character(year_range))
  d$Y <- unit_fe[d$fips_code] + year_fe[as.character(d$Year)] +
         tau * d$Treated_x_Post + rnorm(nrow(d), 0, 0.3)
  # 10 clusters cutting across both arms; a single constant State (G=1) makes
  # the cluster small-sample correction divide by (G-1)=0, producing a
  # non-finite VCOV that fixest's internal collinearity check chokes on.
  d$State <- sprintf("S%02d", as.integer(sub("^[A-Z]", "", d$fips_code)) %% 10L)
  d
}

# ---------------------------------------------------------------------------
test_that("2x2 DiD recovers the true treatment effect on a clean synthetic panel", {
  ## tol = 0.2 (~ noise_sd / sqrt(n_eff)); n_treated=30 with 0.3 residual sd.
  d <- make_2x2_panel(tau = 0.5)
  m <- feols(Y ~ Treated_x_Post | fips_code + Year, data = d, cluster = "State")
  est <- as.numeric(coef(m)["Treated_x_Post"])
  expect_equal(est, 0.5, tolerance = 0.2)
})

# ---------------------------------------------------------------------------
test_that("Treated and control populations partition cleanly (no overlap)", {
  d <- make_2x2_panel(n_treated = 30, n_control = 100)
  treated_fips <- unique(d$fips_code[d$Treated == 1])
  control_fips <- unique(d$fips_code[d$Treated == 0])
  expect_length(intersect(treated_fips, control_fips), 0)
  expect_length(treated_fips, 30)
  expect_length(control_fips, 100)
})

# ---------------------------------------------------------------------------
test_that("Cohort construction picks first event year and tags never-exposed as 0", {
  set.seed(7)
  d <- expand.grid(fips_code = paste0("c", 1:5),
                   Year = 2011:2015, stringsAsFactors = FALSE) %>%
    mutate(shock = case_when(
      fips_code == "c1" & Year == 2012 ~ 1L,
      fips_code == "c2" & Year %in% c(2013, 2014) ~ 1L,
      fips_code == "c3" & Year == 2015 ~ 1L,
      TRUE ~ 0L
    ))

  cohorts <- d %>%
    filter(!is.na(shock)) %>%
    group_by(fips_code) %>%
    summarise(first_event = suppressWarnings(min(Year[shock == 1], na.rm = TRUE)),
              n_events    = sum(shock == 1, na.rm = TRUE),
              .groups = "drop") %>%
    mutate(first_event = if_else(is.finite(first_event), first_event, NA_real_),
           first_event = as.integer(first_event),
           cohort = if_else(is.na(first_event), 0L, first_event))

  expect_equal(cohorts$cohort[cohorts$fips_code == "c1"], 2012L)
  expect_equal(cohorts$cohort[cohorts$fips_code == "c2"], 2013L)
  expect_equal(cohorts$cohort[cohorts$fips_code == "c3"], 2015L)
  expect_equal(cohorts$cohort[cohorts$fips_code == "c4"], 0L)
  expect_equal(cohorts$cohort[cohorts$fips_code == "c5"], 0L)
})

# ---------------------------------------------------------------------------
test_that("CS-DiD ATT(g,t) on synthetic data matches the canonical 2x2", {
  # Build a small panel with a single cohort g=2012 and never-treated control.
  d <- make_2x2_panel(n_treated = 30, n_control = 50, event_year = 2012,
                      year_range = 2011:2014, tau = 1.2, seed = 19)
  # Manual CS-DiD for (g=2012, t=2013): use g-1=2011 and t=2013 only.
  d_sub <- d %>% filter(Year %in% c(2011, 2013))
  m <- feols(Y ~ Treated_x_Post | fips_code + Year, data = d_sub, cluster = "State")
  att_13 <- as.numeric(coef(m)["Treated_x_Post"])
  # Should approximate the true tau (one event-time post, no anticipation).
  expect_equal(att_13, 1.2, tolerance = 0.2)
})

# ---------------------------------------------------------------------------
test_that("Phase 3 outputs exist and have expected schema", {
  paths <- c(
    "Analysis/did/did_2x2_drought_2012.csv",
    "Analysis/did/did_cs_att_gt.csv",
    "Analysis/did/did_cs_event_time.csv"
  )
  skip_if_not(all(file.exists(paths)),
              "DiD output CSVs missing; run run_did_analysis.R first")
  r <- read.csv("Analysis/did/did_2x2_drought_2012.csv", stringsAsFactors = FALSE)
  expect_true(all(c("Event", "Event_Year", "Outcome", "Estimate",
                    "Std_Error", "p_value", "N_Treated", "N_Control") %in% names(r)))
  cs <- read.csv("Analysis/did/did_cs_att_gt.csv", stringsAsFactors = FALSE)
  expect_true(all(c("Shock", "Cohort_g", "Time_t", "Event_Time",
                    "ATT", "Std_Error", "p_value") %in% names(cs)))
  expect_true(all(cs$Time_t >= cs$Cohort_g))
})

cat("All DiD tests completed.\n")
