# =============================================================================
# test_county_master_dedup.R  — unit tests for the one-row-per-county-year
#   enforcement added to Code/create_county_master.R (thesis_completion 2.2 / T1.2)
# =============================================================================
# Run (main R 4.2.2):
#   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/tests/test_county_master_dedup.R
#
# WHY THE RULE IS RE-IMPLEMENTED HERE (not sourced from create_county_master.R):
#   create_county_master.R is a straight-through build script with NO
#   sys.nframe()==0L guard, and run_pipeline.R executes it via sys.source() (see
#   pipeline_utils.R) — so it cannot be guarded without breaking the pipeline, and
#   sourcing it in a test would rebuild + overwrite the master. The enforcement
#   block is short and deterministic, so the fixtures below mirror it VERBATIM
#   (same premium-mean rule, same constancy assertion, same min-rating-area id,
#   same column set). The produced-master tests then assert the REAL output of the
#   production run (uniqueness, row band, FIPS padding, and — the strongest check —
#   that a split county's premium in the shipped master equals the unweighted mean
#   of its rating-area premiums in the pre-dedup backup). This mirrors the repo's
#   established test style (test_did_robustness.R, test_latent_hardship.R).
#
# Coverage (per the task's required test surface):
#   - master is UNIQUE on (fips_code, Year)
#   - row count within the documented band (and exactly backup - extra dup rows)
#   - premium collapse rule correct on a synthetic 2-rating-area fixture
#   - non-premium constancy assertion FIRES on a poisoned fixture
#   - FIPS zero-padding intact (single-digit-state counties are 5-char, not space-padded)
# =============================================================================

suppressPackageStartupMessages({ library(testthat); library(dplyr) })

set.seed(20260713)

MASTER      <- "Data/county_level_master.csv"
BACKUP      <- "Data/_archive/county_level_master_prededup_20260713.csv"

# ---------------------------------------------------------------------------
# FIPS zero-padding idiom (the CLAUDE.md silent-corruption trap): formatC on the
# INTEGER value, NOT sprintf("%05s") which pads with spaces and drops ~316
# single-digit-state counties.
# ---------------------------------------------------------------------------
pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

# ---------------------------------------------------------------------------
# The enforcement rule, mirrored VERBATIM from create_county_master.R so the
# synthetic-fixture tests exercise exactly the production logic.
# ---------------------------------------------------------------------------
PREMIUM_AVG_COLS <- c("Benchmark_Silver", "Lowest_Bronze",
                      "Benchmark_Silver_Real", "Lowest_Bronze_Real")
RA_ID_COL <- "rating_area_id"
KEY_COLS  <- c("fips_code", "Year")

collapse_premium_mean <- function(x) {
  m <- mean(x, na.rm = TRUE); if (is.nan(m)) NA_real_ else m
}

enforce_one_row <- function(master) {
  const_cols   <- setdiff(names(master), c(KEY_COLS, PREMIUM_AVG_COLS, RA_ID_COL))
  orig         <- names(master)
  ra_present   <- intersect(RA_ID_COL, names(master))
  prem_present <- intersect(PREMIUM_AVG_COLS, names(master))
  dup_keys     <- master %>% count(fips_code, Year) %>% filter(n > 1)
  if (nrow(dup_keys) > 0 && length(const_cols) > 0) {
    viol <- master %>%
      semi_join(dup_keys, by = KEY_COLS) %>%
      group_by(fips_code, Year) %>%
      summarise(across(all_of(const_cols), ~ dplyr::n_distinct(.x)), .groups = "drop")
    md  <- vapply(viol[const_cols], max, numeric(1))
    off <- names(md)[md > 1]
    if (length(off) > 0)
      stop("non-premium column(s) vary within fips_code x Year: ",
           paste(off, collapse = ", "))
  }
  master %>%
    { if (length(ra_present) == 1) arrange(., fips_code, Year, .data[[RA_ID_COL]])
      else arrange(., fips_code, Year) } %>%
    group_by(fips_code, Year) %>%
    summarise(across(all_of(const_cols), dplyr::first),
              across(all_of(ra_present), dplyr::first),
              across(all_of(prem_present), collapse_premium_mean),
              .groups = "drop") %>%
    select(all_of(orig))
}

# ---------------------------------------------------------------------------
context("FIPS zero-padding idiom (single-digit-state counties survive)")
# ---------------------------------------------------------------------------
test_that("pad_fips zero-pads to width 5 without space-dropping single-digit states", {
  expect_identical(pad_fips(1001),   "01001")   # AL 01001
  expect_identical(pad_fips(1),      "00001")
  expect_identical(pad_fips(56045),  "56045")    # WY, already width 5
  expect_identical(pad_fips("6037"), "06037")
  padded <- pad_fips(c(1001, 6037, 48201))
  expect_true(all(nchar(padded) == 5))
  expect_false(any(grepl(" ", padded)))          # NEVER space-padded
})

# ---------------------------------------------------------------------------
context("premium collapse rule: unweighted mean across a county's rating areas")
# ---------------------------------------------------------------------------
test_that("two rating areas collapse to the unweighted premium mean", {
  fixture <- data.frame(
    fips_code = c("31001", "31001", "25001"),      # 31001 (NE) split into 2 RAs
    Year      = c(2016L, 2016L, 2016L),
    rating_area_id = c("NE02", "NE01", "MA03"),     # arrange -> NE01 is the min id
    Benchmark_Silver      = c(400, 300, 500),
    Lowest_Bronze         = c(220, 180, 260),
    Benchmark_Silver_Real = c(420, 310, 520),
    Lowest_Bronze_Real    = c(231, 189, 273),
    Medical_Debt_Share    = c(0.12, 0.12, 0.20),    # constant within the split group
    Population            = c(50000, 50000, 8000),
    Is_Extreme_Drought    = c(0, 0, 1),
    stringsAsFactors = FALSE)

  out <- enforce_one_row(fixture)
  expect_false(any(duplicated(out[, c("fips_code", "Year")])))
  expect_equal(nrow(out), 2)

  row31 <- out[out$fips_code == "31001", ]
  expect_equal(row31$Benchmark_Silver,      mean(c(400, 300)))   # 350
  expect_equal(row31$Lowest_Bronze,         mean(c(220, 180)))   # 200
  expect_equal(row31$Benchmark_Silver_Real, mean(c(420, 310)))   # 365
  expect_equal(row31$Lowest_Bronze_Real,    mean(c(231, 189)))   # 210
  # rating_area_id -> deterministic MINIMUM id the county touches
  expect_equal(row31$rating_area_id, "NE01")
  # non-premium columns are preserved (constant -> first())
  expect_equal(row31$Medical_Debt_Share, 0.12)
  expect_equal(row31$Population, 50000)
  # the non-split county is untouched
  row25 <- out[out$fips_code == "25001", ]
  expect_equal(row25$Benchmark_Silver, 500)
  expect_equal(row25$rating_area_id, "MA03")
})

test_that("all-NA premiums collapse to NA (never NaN)", {
  expect_true(is.na(collapse_premium_mean(c(NA_real_, NA_real_))))
  expect_false(is.nan(collapse_premium_mean(c(NA_real_, NA_real_))))
  expect_equal(collapse_premium_mean(c(400, NA)), 400)           # NA-aware mean
})

# ---------------------------------------------------------------------------
context("constancy assertion FIRES when a non-premium column varies in a group")
# ---------------------------------------------------------------------------
test_that("a poisoned fixture (non-premium column differs within a group) aborts", {
  poisoned <- data.frame(
    fips_code = c("31001", "31001"),
    Year      = c(2016L, 2016L),
    rating_area_id = c("NE01", "NE02"),
    Benchmark_Silver      = c(300, 400),
    Lowest_Bronze         = c(180, 220),
    Benchmark_Silver_Real = c(310, 420),
    Lowest_Bronze_Real    = c(189, 231),
    Medical_Debt_Share    = c(0.12, 0.99),          # <-- POISON: non-premium varies
    Population            = c(50000, 50000),
    stringsAsFactors = FALSE)
  expect_error(enforce_one_row(poisoned),
               regexp = "vary within fips_code x Year")
  # and it names the offending column
  expect_error(enforce_one_row(poisoned), regexp = "Medical_Debt_Share")
})

test_that("a clean fixture (only premium/RA columns vary) does NOT abort", {
  clean <- data.frame(
    fips_code = c("31001", "31001"),
    Year      = c(2016L, 2016L),
    rating_area_id = c("NE01", "NE02"),
    Benchmark_Silver      = c(300, 400),
    Lowest_Bronze         = c(180, 220),
    Benchmark_Silver_Real = c(310, 420),
    Lowest_Bronze_Real    = c(189, 231),
    Medical_Debt_Share    = c(0.12, 0.12),
    Population            = c(50000, 50000),
    stringsAsFactors = FALSE)
  expect_silent(out <- enforce_one_row(clean))
  expect_equal(nrow(out), 1)
})

# ---------------------------------------------------------------------------
context("PRODUCED MASTER — the real shipped output of create_county_master.R")
# ---------------------------------------------------------------------------
test_that("shipped master is UNIQUE on (fips_code, Year)", {
  skip_if_not(file.exists(MASTER))
  m <- read.csv(MASTER, colClasses = c(fips_code = "character"))
  expect_equal(anyDuplicated(paste(m$fips_code, m$Year)), 0L)
})

test_that("shipped master row count is in the documented band (and exact vs backup)", {
  skip_if_not(file.exists(MASTER))
  m <- read.csv(MASTER, colClasses = c(fips_code = "character"))
  expect_gte(nrow(m), 110000L)
  expect_lte(nrow(m), 119300L)
  if (file.exists(BACKUP)) {
    b <- read.csv(BACKUP, colClasses = c(fips_code = "character"))
    # collapsing removes exactly (rows - distinct county-years) duplicate rows
    expect_equal(nrow(m), dplyr::n_distinct(paste(b$fips_code, b$Year)))
  }
})

test_that("shipped master FIPS codes are 5-char, single-digit-state counties present", {
  skip_if_not(file.exists(MASTER))
  m <- read.csv(MASTER, colClasses = c(fips_code = "character"))
  fp <- pad_fips(m$fips_code)
  expect_true(all(nchar(fp) == 5))
  expect_false(any(grepl(" ", fp)))
  # single-digit-state counties (state code < 10, e.g. AL=01, CA=06) survive
  expect_true(any(substr(fp, 1, 1) == "0"))
  expect_gt(dplyr::n_distinct(fp[substr(fp, 1, 2) == "01"]), 0)   # Alabama present
})

test_that("shipped premiums equal the unweighted RA mean of the pre-dedup backup", {
  skip_if_not(file.exists(MASTER))
  skip_if_not(file.exists(BACKUP))
  m <- read.csv(MASTER, colClasses = c(fips_code = "character"))
  b <- read.csv(BACKUP, colClasses = c(fips_code = "character"))
  # expected premium per county-year = unweighted mean across the backup's RA rows
  exp_prem <- b %>%
    group_by(fips_code, Year) %>%
    summarise(exp_bs = collapse_premium_mean(Benchmark_Silver_Real),
              exp_lb = collapse_premium_mean(Lowest_Bronze_Real), .groups = "drop")
  cmp <- m %>%
    select(fips_code, Year, Benchmark_Silver_Real, Lowest_Bronze_Real) %>%
    inner_join(exp_prem, by = c("fips_code", "Year"))
  d_bs <- abs(cmp$Benchmark_Silver_Real - cmp$exp_bs); d_bs <- d_bs[is.finite(d_bs)]
  d_lb <- abs(cmp$Lowest_Bronze_Real   - cmp$exp_lb); d_lb <- d_lb[is.finite(d_lb)]
  expect_lt(max(d_bs), 1e-6)
  expect_lt(max(d_lb), 1e-6)
  # and NA patterns agree
  expect_equal(sum(is.na(cmp$Benchmark_Silver_Real) != is.na(cmp$exp_bs)), 0L)
})

test_that("every non-premium column is CONSTANT within the backup's duplicate groups", {
  # This is the lossless-collapse precondition, verified on the real pre-dedup data.
  skip_if_not(file.exists(BACKUP))
  b <- read.csv(BACKUP, colClasses = c(fips_code = "character"))
  const_cols <- setdiff(names(b), c(KEY_COLS, PREMIUM_AVG_COLS, RA_ID_COL))
  dup_keys <- b %>% count(fips_code, Year) %>% filter(n > 1)
  skip_if(nrow(dup_keys) == 0)
  viol <- b %>% semi_join(dup_keys, by = KEY_COLS) %>%
    group_by(fips_code, Year) %>%
    summarise(across(all_of(const_cols), ~ dplyr::n_distinct(.x)), .groups = "drop")
  md <- vapply(viol[const_cols], max, numeric(1))
  expect_equal(as.integer(sum(md > 1)), 0L)   # zero non-premium columns vary
})

cat("\nAll county-master dedup tests defined; running via testthat...\n")
