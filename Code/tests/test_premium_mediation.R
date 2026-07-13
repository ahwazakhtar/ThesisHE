# Tests for run_premium_mediation.R (thesis_completion_20260704, T1.1).
# The script exposes two pure helpers (guarded main via sys.nframe()==0), so this
# sources it and exercises them on synthetic data. Run on main R 4.2.2:
#   Rscript Code/tests/test_premium_mediation.R
#
# Covers the two acceptance properties the plan names:
#   - decomposition identity: est_base == est_with + mediated ; fraction = with/base
#   - lag alignment: a shock at year t lands in _L1 at t+1 and _L2 at t+2, per county.

suppressPackageStartupMessages({
  library(testthat)
  library(fixest)
})
source("Code/run_premium_mediation.R")

# ---------------------------------------------------------------------------
test_that("add_shock_lags aligns L1/L2 by county with no cross-county bleed", {
  d <- data.frame(
    fips_code = rep(c("01001", "06075"), each = 5),
    Year      = rep(2011:2015, times = 2),
    shk       = c(1, 0, 0, 0, 0,      # county A: shock in 2011 only
                  0, 0, 1, 0, 0),     # county B: shock in 2013 only
    stringsAsFactors = FALSE)
  out <- add_shock_lags(d, "shk", max_lag = 2)
  a <- out[out$fips_code == "01001", ]
  b <- out[out$fips_code == "06075", ]
  # County A: 2011 shock -> L1 at 2012, L2 at 2013.
  expect_equal(a$shk_L1, c(NA, 1, 0, 0, 0))
  expect_equal(a$shk_L2, c(NA, NA, 1, 0, 0))
  # County B: 2013 shock -> L1 at 2014, L2 at 2015; and A's tail does NOT bleed in.
  expect_equal(b$shk_L1, c(NA, 0, 0, 1, 0))
  expect_equal(b$shk_L2, c(NA, NA, 0, 0, 1))
})

# ---------------------------------------------------------------------------
test_that("add_shock_lags honors a non-default group (RA/state level panels)", {
  # The aggregated pass-through panels lag within rating_area_id / State, not fips.
  d <- data.frame(
    rating_area_id = rep(c("CA01", "NY02"), each = 4),
    Year = rep(2014:2017, times = 2),
    fips_code = "X",                         # present but must be IGNORED as grouper
    sh = c(0.1, 0.2, 0.3, 0.4,  0.5, 0.6, 0.7, 0.8),
    stringsAsFactors = FALSE)
  out <- add_shock_lags(d, "sh", max_lag = 1L, group = "rating_area_id")
  ca <- out[out$rating_area_id == "CA01", ]
  ny <- out[out$rating_area_id == "NY02", ]
  expect_equal(ca$sh_L1, c(NA, 0.1, 0.2, 0.3))
  expect_equal(ny$sh_L1, c(NA, 0.5, 0.6, 0.7))   # no bleed from CA's 0.4 into NY
})

# ---------------------------------------------------------------------------
test_that("mediation_decompose satisfies the additive identity and fraction", {
  set.seed(101)
  n_c <- 60; yrs <- 2008:2019
  g <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs,
                   stringsAsFactors = FALSE)
  g$State <- substr(g$fips_code, 1, 2)
  g$shk <- rbinom(nrow(g), 1, 0.25)
  fe_c <- rnorm(n_c); names(fe_c) <- sprintf("%05d", 1:n_c)
  # DGP: shock raises the mediator, which raises the outcome; shock also has a
  # direct effect. So controlling for M should shrink (but not zero) the shock coef.
  g$M <- 3 * g$shk + fe_c[g$fips_code] + rnorm(nrow(g), 0, 1)
  g$Y <- 2 * g$shk + 1.5 * g$M + fe_c[g$fips_code] * 0.5 + rnorm(nrow(g), 0, 1)

  dec <- mediation_decompose(g, outcome = "Y", shock_terms = "shk",
                             mediator_terms = "M", cluster = ~State)
  r <- dec[dec$term == "shk", ]
  # Additive identity is definitional but must be computed consistently.
  expect_equal(r$est_base, r$est_with + r$mediated, tolerance = 1e-9)
  expect_equal(r$fraction_surviving, r$est_with / r$est_base, tolerance = 1e-9)
  # Economically: controlling for the mediator shrinks the effect toward the
  # direct component (2), and some is mediated (>0), so 0 < fraction < 1.
  expect_gt(r$mediated, 0)
  expect_true(r$fraction_surviving > 0 && r$fraction_surviving < 1)
})

# ---------------------------------------------------------------------------
test_that("an unrelated mediator leaves the effect essentially intact (fraction ~ 1)", {
  set.seed(202)
  n_c <- 60; yrs <- 2008:2019
  g <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs,
                   stringsAsFactors = FALSE)
  g$State <- substr(g$fips_code, 1, 2)
  g$shk <- rbinom(nrow(g), 1, 0.25)
  g$M   <- rnorm(nrow(g))                       # pure noise, unrelated to shock
  g$Y   <- 2 * g$shk + rnorm(nrow(g), 0, 1)
  dec <- mediation_decompose(g, outcome = "Y", shock_terms = "shk",
                             mediator_terms = "M", cluster = ~State)
  r <- dec[dec$term == "shk", ]
  expect_equal(r$fraction_surviving, 1, tolerance = 0.05)  # nothing mediated
})

# ---------------------------------------------------------------------------
test_that("mediation_decompose fits base and with-mediator on the SAME sample", {
  # Rows missing the mediator must be dropped from BOTH fits, else the
  # decomposition compares different samples and the identity is meaningless.
  set.seed(303)
  n_c <- 40; yrs <- 2010:2019
  g <- expand.grid(fips_code = sprintf("%05d", 1:n_c), Year = yrs,
                   stringsAsFactors = FALSE)
  g$State <- substr(g$fips_code, 1, 2)
  g$shk <- rbinom(nrow(g), 1, 0.3)
  g$M   <- 2 * g$shk + rnorm(nrow(g))
  g$Y   <- g$shk + g$M + rnorm(nrow(g))
  g$M[sample(nrow(g), 50)] <- NA                # punch holes in the mediator
  dec <- mediation_decompose(g, outcome = "Y", shock_terms = "shk",
                             mediator_terms = "M", cluster = ~State)
  r <- dec[dec$term == "shk", ]
  expect_equal(r$N, sum(!is.na(g$M) & !is.na(g$Y) & !is.na(g$shk)))
  expect_false(is.na(r$est_base))
})

# ---------------------------------------------------------------------------
# RA-panel-from-source helpers (audit A3, code_quality_remediation T2.1):
# deflate_premiums(), allocate_county_pop(), build_ra_panel(). These replace the
# old "aggregate the deduped master by rating_area_id" construction, which after
# the county-master dedup mis-collapsed split counties (county-mean premium +
# whole population on one representative RA). Fixture: county B (01003) is SPLIT
# across two rating areas (AL02, AL03) with DIFFERENT source premiums; AL02 also
# contains county C (01005). Premium is constant within a rating area.
# ---------------------------------------------------------------------------

make_src <- function() data.frame(
  fips_code          = c("01001", "01003", "01003", "01005"),
  Year               = 2014L,
  rating_area_id     = c("AL01",  "AL02",  "AL03",  "AL02"),
  Benchmark_Silver   = c(200,     300,     360,     300),   # constant within an RA
  Lowest_Bronze      = c(160,     240,     300,     240),
  State              = "AL",
  Is_Extreme_Drought = c(1,       0,       0,       0),
  High_CDD           = c(0,       1,       1,       0),
  High_HDD           = c(0,       0,       0,       1),
  Population         = c(100,     300,     300,     200),
  stringsAsFactors   = FALSE)
make_cpi <- function() data.frame(Year = c(2014L, 2023L), CPI_Value = c(100, 150))

test_that("deflate_premiums applies the base-2023 CPI factor (parity w/ create_county_master.R)", {
  src <- make_src(); cpi <- make_cpi()
  d <- deflate_premiums(src, cpi, base_year = 2023L)   # factor = 150/100 = 1.5
  expect_equal(d$Benchmark_Silver_Real, src$Benchmark_Silver * 1.5)
  expect_equal(d$Lowest_Bronze_Real,    src$Lowest_Bronze    * 1.5)
  # a year absent from the CPI table -> NA real premium (dropped downstream)
  src2 <- src; src2$Year <- 2099L
  expect_true(all(is.na(deflate_premiums(src2, cpi)$Benchmark_Silver_Real)))
})

test_that("allocate_county_pop equal-split never double-counts a split county's population", {
  src <- make_src()
  a <- allocate_county_pop(src, "equal")
  expect_equal(a$n_ra[a$fips_code == "01003"], c(2, 2))   # B touches 2 rating areas
  # a county's population summed across its rating areas == county Population
  agg <- aggregate(pop_alloc ~ fips_code, data = a, sum)
  pop_by_fips <- tapply(src$Population, src$fips_code, `[`, 1)
  for (f in agg$fips_code)
    expect_equal(agg$pop_alloc[agg$fips_code == f], unname(pop_by_fips[f]))
  # SENSITIVITY (full) rule = the old implicit behavior: full population in EVERY RA
  expect_equal(allocate_county_pop(src, "full")$pop_alloc, src$Population)
})

test_that("build_ra_panel: one row per RA x Year; premium from SOURCE, not the master mean", {
  src <- make_src(); cpi <- make_cpi()
  ra <- build_ra_panel(allocate_county_pop(deflate_premiums(src, cpi), "equal"))
  # RA panel row count == distinct (rating_area_id, Year) in the (filtered) source
  expect_equal(nrow(ra), length(unique(paste(src$rating_area_id, src$Year))))
  expect_equal(sort(ra$rating_area_id), c("AL01", "AL02", "AL03"))
  # SPLIT county 01003: each RA carries its OWN source premium (deflated), NOT the
  # master's cross-area mean (mean(300,360)=330 -> 495 real), which is the bug fixed.
  master_mean_real <- mean(c(300, 360)) * 1.5
  expect_equal(ra$Benchmark_Silver_Real[ra$rating_area_id == "AL02"], 300 * 1.5)
  expect_equal(ra$Benchmark_Silver_Real[ra$rating_area_id == "AL03"], 360 * 1.5)
  expect_false(isTRUE(all.equal(ra$Benchmark_Silver_Real[ra$rating_area_id == "AL03"],
                                master_mean_real)))
  # shock SHARES are pop-weighted county fractions within the RA (equal-split wts):
  # AL02 = {01003 alloc 150 (CDD=1), 01005 alloc 200 (HDD=1)} -> sh_cdd = 150/350
  expect_equal(ra$sh_cdd[ra$rating_area_id == "AL02"], 150 / 350)
  expect_equal(ra$sh_hdd[ra$rating_area_id == "AL02"], 200 / 350)
  expect_equal(ra$pop[ra$rating_area_id == "AL02"], 350)   # 150 + 200 (allocated)
})

test_that("build_ra_panel drops RA-years whose premiums are entirely NA (documented exclusion)", {
  src <- make_src(); cpi <- make_cpi()
  extra <- src[1, ]; extra$fips_code <- "01007"; extra$rating_area_id <- "AL09"
  extra$Benchmark_Silver <- NA_real_; extra$Lowest_Bronze <- NA_real_
  ra <- build_ra_panel(allocate_county_pop(deflate_premiums(rbind(src, extra), cpi), "equal"))
  expect_false("AL09" %in% ra$rating_area_id)
})

cat("\nAll premium-mediation tests completed.\n")
