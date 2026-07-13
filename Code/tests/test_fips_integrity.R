# =============================================================================
# test_fips_integrity.R  — unit tests for pad_fips() + an integrity scan that
#   the built county-level intermediates carry 5-char, zero-padded county FIPS.
#   (code_quality_remediation_20260713, Phase 4.3 / audit finding B4.)
# =============================================================================
# Run (main R 4.2.2), from the repository root:
#   & "C:/Program Files/R/R-4.2.2/bin/Rscript.exe" Code/tests/test_fips_integrity.R
#
# WHY THIS TEST EXISTS
#   The project has already suffered a serious silent-corruption failure from the
#   FIPS zero-padding trap. `sprintf("%05s", fips)` pads with SPACES (the C "0"
#   flag is ignored for %s), so a single-digit-state code becomes " 1001" not
#   "01001", silently dropping/mis-keying the ~316 counties whose state FIPS is a
#   single digit (AL=01, CA=06, CT=09, ...). B4 centralizes the blessed helper
#   `pad_fips()` in Code/pipeline_utils.R (formatC on the INTEGER value) and adds
#   this repository test scanning built intermediates for correct 5-char FIPS.
#
#   The trap and the correct idiom are documented in CLAUDE.md ("Silent-corruption
#   traps") and conductor/knowledge/data-pipeline.md. This test is the executable
#   guard for both.
#
# SCOPE NOTE (B4): pad_fips() is the standard for NEW/touched code. This track did
#   NOT mass-refactor the ~137 existing scripts to call it; they keep their in-line
#   `formatC(...)` idioms. The integrity scan below therefore validates the *built
#   outputs* (which must be correct regardless of which idiom produced them),
#   not that every script imports the helper.
#
# Coverage:
#   (a) pad_fips unit tests, incl. an explicit contrast against the sprintf %05s
#       space-padding trap, NA passthrough, and the >5-digit hard error.
#   (b) Integrity scan of Data/county_level_master.csv (the manuscript master) and
#       1-2 other built county-FIPS intermediates: every FIPS is exactly 5 chars,
#       all digits, zero-padded, no spaces; single-digit-state counties present.
# =============================================================================

suppressPackageStartupMessages(library(testthat))

# pad_fips() lives in the shared utils; source it from the repo root.
if (!file.exists("Code/pipeline_utils.R")) {
  stop("Run this test from the repository root (Code/pipeline_utils.R not found).")
}
source("Code/pipeline_utils.R")

# ---------------------------------------------------------------------------
# (a) pad_fips() unit tests
# ---------------------------------------------------------------------------
context("pad_fips(): correct zero-padding, never the sprintf space-padding trap")

test_that("single-digit-state FIPS are zero-padded, not space-padded", {
  # 1001 (Autauga County, AL) must become "01001".
  expect_identical(pad_fips(1001),   "01001")
  expect_identical(pad_fips(1),      "00001")
  expect_identical(pad_fips(6037),   "06037")   # Los Angeles County, CA
  expect_identical(pad_fips("1001"), "01001")   # character leading-zero-free input
  expect_identical(pad_fips("06037"), "06037")  # already-padded character input
  expect_identical(pad_fips(56045),  "56045")   # WY, already width 5

  padded <- pad_fips(c(1001, 6037, 9001, 48201))
  expect_true(all(nchar(padded) == 5))
  expect_false(any(grepl(" ", padded)))         # NEVER space-padded
})

test_that("pad_fips does NOT reproduce the sprintf('%05s', .) space-padding trap", {
  # The documented trap: %05s ignores the "0" flag and pads with SPACES.
  trap <- sprintf("%05s", "1001")
  expect_true(grepl(" ", trap))                 # trap really is space-padded ...
  expect_identical(substr(trap, 1, 1), " ")     # ... leading char is a space
  # ... whereas pad_fips zero-pads the same value with no space.
  fixed <- pad_fips("1001")
  expect_identical(fixed, "01001")
  expect_false(grepl(" ", fixed))
  expect_false(identical(fixed, trap))
})

test_that("NA passes through as NA_character_ (never the literal '   NA')", {
  expect_identical(pad_fips(NA), NA_character_)
  expect_identical(pad_fips(c(1001, NA, 6037)),
                   c("01001", NA_character_, "06037"))
})

test_that("empty input returns an empty character vector", {
  expect_identical(pad_fips(integer(0)), character(0))
  expect_identical(pad_fips(character(0)), character(0))
})

test_that("FIPS wider than 5 digits is a hard error (upstream key/scale bug)", {
  expect_error(pad_fips(123456), regexp = "wider than 5 digits")
  expect_error(pad_fips(c(1001, 999999)), regexp = "wider than 5 digits")
})

test_that("non-numeric FIPS is a hard error", {
  expect_error(pad_fips("not_a_fips"), regexp = "non-numeric")
})

# ---------------------------------------------------------------------------
# (b) Integrity scan of built intermediates
# ---------------------------------------------------------------------------
context("built intermediates carry 5-char zero-padded county FIPS (no spaces)")

# Read just the FIPS column, cheaply and as character (leading zeros preserved).
# Prefer data.table::fread if available; otherwise base read.csv with a
# colClasses mask that drops every other column.
FIPS_CANDIDATES <- c("fips_code", "fips", "FIPS", "county_fips", "GEOID", "geoid")

read_fips_col <- function(path) {
  hdr <- names(read.csv(path, nrows = 1L, check.names = FALSE))
  col <- intersect(FIPS_CANDIDATES, hdr)
  if (length(col) == 0L) {
    stop("no FIPS column found in ", path,
         " (header: ", paste(hdr, collapse = ","), ")")
  }
  col <- col[1L]
  if (requireNamespace("data.table", quietly = TRUE)) {
    dt <- data.table::fread(path, select = col, colClasses = "character")
    return(as.character(dt[[col]]))
  }
  cc <- rep("NULL", length(hdr))
  cc[hdr == col] <- "character"
  read.csv(path, colClasses = cc, check.names = FALSE)[[col]]
}

# Built county-FIPS-carrying outputs to scan (all < 200MB; skipped if absent).
#   - county_level_master.csv : the manuscript county master (primary check).
#   - premiums_county.csv      : county x rating-area premium source panel.
#   - medical_debt_county.csv  : Urban Institute county medical-debt intermediate.
SCAN_TARGETS <- c(
  "Data/county_level_master.csv",
  "Data/premiums_county.csv",
  "Data/medical_debt_county.csv"
)

assert_fips_integrity <- function(path) {
  fips <- read_fips_col(path)
  fips_present <- fips[!is.na(fips)]
  expect_gt(length(fips_present), 0L)
  # exactly 5 characters
  expect_true(all(nchar(fips_present) == 5L),
              info = paste0(path, ": found non-5-char FIPS, e.g. ",
                            paste(utils::head(unique(fips_present[nchar(fips_present) != 5L]), 5),
                                  collapse = ", ")))
  # all digits -> implies zero-padded and NO spaces / signs / letters
  expect_true(all(grepl("^[0-9]{5}$", fips_present)),
              info = paste0(path, ": found non-numeric / space-padded FIPS, e.g. ",
                            paste0("'", utils::head(unique(fips_present[!grepl("^[0-9]{5}$", fips_present)]), 5), "'",
                                   collapse = ", ")))
  # belt-and-suspenders: explicitly no embedded spaces
  expect_false(any(grepl(" ", fips_present)), info = paste0(path, ": embedded space in FIPS"))
  # single-digit-state counties (state code < 10) survive -> real zero-padding,
  # not an artifact of the file only containing 2-digit-state counties.
  expect_true(any(substr(fips_present, 1, 1) == "0"),
              info = paste0(path, ": no leading-zero (single-digit-state) FIPS present"))
  # pad_fips is idempotent on an already-correct built column.
  expect_identical(pad_fips(fips_present), fips_present)
}

for (target in SCAN_TARGETS) {
  local({
    tgt <- target
    test_that(paste("FIPS integrity:", basename(tgt)), {
      skip_if_not(file.exists(tgt), paste(tgt, "not present; skipping"))
      assert_fips_integrity(tgt)
    })
  })
}

cat("\nAll FIPS-integrity tests defined; running via testthat...\n")
