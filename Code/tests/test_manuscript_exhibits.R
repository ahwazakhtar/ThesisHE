# test_manuscript_exhibits.R — checks for create_manuscript_exhibits.R outputs
# Run: Rscript Code/tests/test_manuscript_exhibits.R
suppressMessages(library(testthat))

test_that("all exhibit outputs exist", {
  expect_true(file.exists("Analysis/delta/transition_episode_counts.csv"))
  expect_true(file.exists("Analysis/policy/concentration_topshares.csv"))
  expect_true(file.exists("Analysis/policy/fig_concentration_lorenz.png"))
  expect_true(file.exists("Analysis/persistent_exposure/fig_heat_saturation.png"))
  expect_true(file.exists("Analysis/plots/essay_diagrams/fig_adjustment_regimes.png"))
  expect_true(file.exists("Analysis/did/fig_treated_map.png"))
})

test_that("transition counts reconcile", {
  tr <- read.csv("Analysis/delta/transition_episode_counts.csv")
  expect_true(all(c("Drought", "Heat", "Cold") %in% tr$hazard))
  # every classified pair is one of the four transition types
  expect_equal(tr$onset + tr$exit + tr$persist + tr$calm, tr$county_years)
  expect_true(all(tr$onset > 0 & tr$exit > 0))
  # drought is episodic: persisting years are rarer than onsets
  expect_lt(tr$persist[tr$hazard == "Drought"], tr$onset[tr$hazard == "Drought"])
})

test_that("concentration top shares are valid and monotone", {
  ts <- read.csv("Analysis/policy/concentration_topshares.csv")
  expect_true(all(ts$top10_pop_burden_share >= 0 & ts$top50_pop_burden_share <= 1 + 1e-9))
  expect_true(all(ts$top10_pop_burden_share <= ts$top20_pop_burden_share + 1e-9))
  expect_true(all(ts$top20_pop_burden_share <= ts$top50_pop_burden_share + 1e-9))
  # the two uniform-per-capita bands are flagged, and only those sit exactly on the diagonal
  uni <- ts[ts$uniform_per_capita, ]
  expect_setequal(uni$band, c("drought_debt_scar", "event_2012_income"))
  expect_equal(uni$top10_pop_burden_share, rep(0.10, nrow(uni)), tolerance = 1e-9)
  expect_true(all(ts$top10_pop_burden_share[!ts$uniform_per_capita] > 0.10))
})

test_that("treated map cohort matches the DiD design", {
  # replicate the run_did_analysis.R first-onset logic on the certified master
  m <- read.csv("Data/county_level_master.csv")
  m <- m[m$Year >= 2011 & m$Year <= 2023 & !is.na(m$Is_Extreme_Drought), ]
  fe <- aggregate(Year ~ fips_code, data = m[m$Is_Extreme_Drought == 1, ], FUN = min)
  expect_equal(sum(fe$Year == 2012), 139)
})

cat("test_manuscript_exhibits: ALL PASS\n")
