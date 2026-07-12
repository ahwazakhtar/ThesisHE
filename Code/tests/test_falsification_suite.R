# Tests for the falsification suite (audit_response_20260712, tasks 2.2 + 2.3;
# Code/did_robustness/07_falsification_suite.R).
#
# Runs on the MAIN R 4.2.2 (where testthat lives), deliberately fixest-only and
# fwildclusterboot-free — mirroring Code/tests/test_did_robustness.R. This is
# legitimate because 07_'s estimation functions use ONLY dplyr + fixest (both
# present on 4.2.2); sourcing the script defines its functions without running
# main() (guarded by `if (sys.nframe() == 0L)`), so no I/O or estimation fires.
#   Rscript Code/tests/test_falsification_suite.R
#
# Covers the four required properties:
#   (i)   LOO with NO state dropped reproduces the full-sample 2x2 ATT exactly,
#   (ii)  the placebo assigns pseudo-treated ONLY from never-exposed counties
#         (never a treated-cohort county),
#   (iii) every pseudo-onset year lies in the pre-specified {2013..2019} support,
#   (iv)  the LOO and placebo output schemas are as documented.

suppressPackageStartupMessages({
  library(testthat)
  library(fixest)
})
# Sourcing 07_ also sources 00_did_robustness_common.R (its helpers). main() is
# guarded, so this only brings the functions into scope.
source("Code/did_robustness/07_falsification_suite.R")

# ---------------------------------------------------------------------------
# Synthetic panel: treated (2012-onset) counties in 2 states + never-exposed
# counties in 2 states, 2009:2020, with a real TxP effect + county/year FE +
# noise so the 2x2 is identified. The span runs through 2020 so the production
# placebo support {2013..2019} always has a post-period (g <= 2019 => >=1 year
# >= g), exactly as in the 2011:2023 production panel. FIPS built with the
# mandated formatC idiom.
#   Treated : AL 01001-01003, GA 13001-13003   (drought=1 in 2012)
#   Never   : CO 08001-08012, NE 31001-31012   (drought=0 throughout)
# ---------------------------------------------------------------------------
make_panel <- function(seed = 20260712L) {
  set.seed(seed)
  yrs <- 2009:2020
  fips_al <- formatC(1001:1003,  width = 5, flag = "0")   # "01001".."01003"
  fips_ga <- formatC(13001:13003, width = 5, flag = "0")  # "13001".."13003"
  fips_co <- formatC(8001:8012,  width = 5, flag = "0")   # "08001".."08012"
  fips_ne <- formatC(31001:31012, width = 5, flag = "0")  # "31001".."31012"
  spec <- rbind(
    data.frame(fips = fips_al, st = "AL", treated = TRUE),
    data.frame(fips = fips_ga, st = "GA", treated = TRUE),
    data.frame(fips = fips_co, st = "CO", treated = FALSE),
    data.frame(fips = fips_ne, st = "NE", treated = FALSE),
    stringsAsFactors = FALSE)
  fe_c <- setNames(rnorm(nrow(spec), 0, 1000), spec$fips)
  fe_y <- setNames(rnorm(length(yrs), 0, 400), as.character(yrs))
  rows <- lapply(seq_len(nrow(spec)), function(i) {
    fips <- spec$fips[i]; st <- spec$st[i]; tr <- spec$treated[i]
    drought <- if (tr) as.integer(yrs == 2012L) else rep(0L, length(yrs))
    post <- as.integer(yrs >= 2012L)
    txp  <- as.integer(tr) * post
    y <- 40000 - 900 * txp + fe_c[[fips]] + fe_y[as.character(yrs)] +
         rnorm(length(yrs), 0, 150)
    data.frame(
      fips_code = fips, Year = yrs, State = st,
      Is_Extreme_Drought = drought,
      PCPI_Real = y,
      Med_HH_Income_Real = 50000 + fe_c[[fips]],
      Civilian_Employed  = 5000 - 40 * txp + rnorm(length(yrs), 0, 30),
      Medical_Debt_Share = 0.12,
      Population = 10000 + 100 * (yrs - min(yrs)),
      stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}

# ---------------------------------------------------------------------------
test_that("(i) LOO with no state dropped reproduces the full-sample 2x2 ATT", {
  p  <- make_panel()
  co <- build_cohorts(p, "Is_Extreme_Drought")
  fr <- did_2x2_frame(p, co, event_year = 2012L)
  expect_equal(attr(fr, "n_treated"), 6L)
  expect_equal(attr(fr, "n_control"), 24L)

  # Independent full two-way-FE, state-clustered 2x2 (the benchmark estimator).
  d <- fr[!is.na(fr$PCPI_Real), ]; d$State <- factor(d$State)
  m_full <- feols(PCPI_Real ~ TxP | fips_code + Year, data = d, cluster = ~State)
  att_full <- unname(coef(m_full)["TxP"])

  # loo_att with no state dropped must equal it to machine precision.
  r_none1 <- loo_att(fr, NA_character_, "PCPI_Real")
  r_none2 <- loo_att(fr, "(none)",      "PCPI_Real")
  expect_equal(r_none1$att, att_full, tolerance = 1e-8)
  expect_equal(r_none2$att, att_full, tolerance = 1e-8)
  expect_equal(unname(se(m_full)["TxP"]), r_none1$se, tolerance = 1e-8)

  # And dropping a real state actually changes the sample (sanity).
  r_drop <- loo_att(fr, "AL", "PCPI_Real")
  expect_lt(r_drop$n, r_none1$n)
})

# ---------------------------------------------------------------------------
test_that("(i-bis) run_loo row 0 equals loo_att no-drop; envelope is sane", {
  p  <- make_panel()
  co <- build_cohorts(p, "Is_Extreme_Drought")
  fr <- did_2x2_frame(p, co, event_year = 2012L)
  ts <- identify_treated_states(co, p, 2012L)
  expect_setequal(ts, c("AL", "GA"))

  loo_df <- run_loo(fr, ts, c("PCPI_Real", "Civilian_Employed"))
  base   <- loo_df[loo_df$state_dropped == "(none)", ]
  direct <- loo_att(fr, NA_character_, "PCPI_Real")
  expect_equal(base$pcpi_att, direct$att, tolerance = 1e-8)
  # Row 0 keeps all treated units/states; a dropped row keeps fewer.
  expect_equal(base$n_treated_remaining, 6L)
  expect_equal(base$n_treated_states_remaining, 2L)
  expect_equal(loo_df$n_treated_states_remaining[loo_df$state_dropped == "AL"], 1L)
})

# ---------------------------------------------------------------------------
test_that("(ii) placebo pseudo-treated are drawn ONLY from never-exposed counties", {
  p  <- make_panel()
  co <- build_cohorts(p, "Is_Extreme_Drought")
  never   <- never_exposed_fips(co)               # 24 CO+NE counties
  treated <- co$fips_code[co$cohort == 2012L]     # 6 AL+GA counties

  pb <- run_placebo(p, co, y = "PCPI_Real", n_treated = 5L, B = 40L,
                    onset_years = 2013:2015, seed = 20260712L)
  # Pool is exactly the analyzable never-exposed set (no treated counties).
  expect_true(all(pb$pool %in% never))
  expect_equal(length(intersect(pb$pool, treated)), 0L)
  # Every county ever used as pseudo-treated is never-exposed; none is treated.
  expect_true(all(pb$used_fips %in% never))
  expect_equal(length(intersect(pb$used_fips, treated)), 0L)
})

# ---------------------------------------------------------------------------
test_that("(iii) every pseudo-onset year lies in the frozen {support}", {
  p  <- make_panel()
  co <- build_cohorts(p, "Is_Extreme_Drought")
  pb <- run_placebo(p, co, y = "PCPI_Real", n_treated = 5L, B = 60L,
                    onset_years = 2013:2015, seed = 20260712L)
  expect_true(all(pb$dist$pseudo_onset_year %in% 2013:2015))
  # And the production support is respected when passed explicitly.
  pb2 <- run_placebo(p, co, y = "PCPI_Real", n_treated = 5L, B = 30L,
                     onset_years = 2013:2019, seed = 1L)
  expect_true(all(pb2$dist$pseudo_onset_year %in% 2013:2019))
})

# ---------------------------------------------------------------------------
test_that("(iii-bis) placebo draws are reproducible under a fixed seed", {
  p  <- make_panel()
  co <- build_cohorts(p, "Is_Extreme_Drought")
  a <- run_placebo(p, co, "PCPI_Real", n_treated = 5L, B = 25L,
                   onset_years = 2013:2015, seed = 20260712L)$dist
  b <- run_placebo(p, co, "PCPI_Real", n_treated = 5L, B = 25L,
                   onset_years = 2013:2015, seed = 20260712L)$dist
  expect_equal(a, b)
})

# ---------------------------------------------------------------------------
test_that("(iv) output schemas are exactly as documented", {
  p  <- make_panel()
  co <- build_cohorts(p, "Is_Extreme_Drought")
  fr <- did_2x2_frame(p, co, event_year = 2012L)
  ts <- identify_treated_states(co, p, 2012L)

  loo_df <- run_loo(fr, ts, c("PCPI_Real", "Civilian_Employed"))
  expect_identical(names(loo_df), c(
    "state_dropped", "n_treated_remaining", "n_treated_states_remaining",
    "pcpi_att", "pcpi_se", "pcpi_p", "pcpi_n",
    "emp_att", "emp_se", "emp_p", "emp_n"))
  # 1 baseline row + one row per treated state.
  expect_equal(nrow(loo_df), length(ts) + 1L)
  expect_equal(loo_df$state_dropped[1], "(none)")
  expect_true(is.numeric(loo_df$pcpi_att) && all(is.finite(loo_df$pcpi_att)))

  pb <- run_placebo(p, co, "PCPI_Real", n_treated = 5L, B = 20L,
                    onset_years = 2013:2015, seed = 20260712L)
  expect_identical(names(pb$dist), c("draw", "pseudo_onset_year", "placebo_att"))
  expect_equal(nrow(pb$dist), 20L)
  expect_equal(pb$dist$draw, 1:20)
  expect_true(all(is.finite(pb$dist$placebo_att)))
})

cat("\nAll falsification-suite tests completed.\n")
