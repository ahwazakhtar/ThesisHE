# ---------------------------------------------------------------------------
# process_county_demographics.R  (Persistence Extensions — Phase 4)
#
# Derives county-year demographic mediators from the raw ACS pull produced by
# download_county_socioeconomic.R (acs_demographics_raw.csv):
#
#   Pct_Owner_Occupied : B25003_002E / B25003_001E
#   Pct_Age_65plus     : sum(B01001 male 020-025 + female 044-049) / B01001_001E
#   In_Migration_Rate  : (B07001_049E + B07001_065E + B07001_081E) / B07001_001E
#                        i.e. (moved-from-diff-county-same-state + diff-state +
#                        abroad) over population 1yr+.
#
# NAMING NOTE / DEVIATION FROM PLAN: the plan calls for `Net_Migration_Rate`, but
# ACS geographic-mobility tables observe only IN-migrants (out-migration is not in
# the table), so a true net rate is not recoverable from ACS. We therefore expose
# an honestly-named `In_Migration_Rate`. It still serves the mediation question
# (does shock exposure shift who lives in a county?) since in-migration is the ACS-
# observable component of population turnover. Documented here per workflow.md.
#
# ACS 5-year estimates are 5-year moving averages, so year-to-year variation is
# smoothed; treat these as slow-moving compositional controls, not annual shocks.
#
# Output: Data/intermediate_demographics.rds
#   (fips_code, Year, In_Migration_Rate, Pct_Age_65plus, Pct_Owner_Occupied)
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(dplyr); library(readr) })

if (!exists("%||%")) {
  `%||%` <- function(x, y) if (is.null(x) || (length(x) == 1 && is.na(x))) y else x
}

is_valid_county_fips <- function(fips) {
  grepl("^[0-9]{5}$", fips) & !grepl("000$", fips) & substr(fips, 1, 2) != "00"
}

# The 12 B01001 cells that make up the 65-and-over population.
AGE_65PLUS_CELLS <- c(
  paste0("B01001_0", 20:25, "E"),   # male  65-66, 67-69, 70-74, 75-79, 80-84, 85+
  paste0("B01001_0", 44:49, "E")    # female 65-66, 67-69, 70-74, 75-79, 80-84, 85+
)

# Pure transform: raw wide ACS data.frame -> demographic features. Testable.
compute_demographic_features <- function(raw) {
  num <- function(x) suppressWarnings(as.numeric(x))
  safe_div <- function(a, b) ifelse(!is.na(b) & b > 0, a / b, NA_real_)

  age_mat <- sapply(AGE_65PLUS_CELLS, function(v) num(raw[[v]]))
  if (is.null(dim(age_mat))) age_mat <- matrix(age_mat, nrow = nrow(raw))  # single-row guard
  age65 <- rowSums(age_mat, na.rm = FALSE)
  inmig <- num(raw[["B07001_049E"]]) + num(raw[["B07001_065E"]]) + num(raw[["B07001_081E"]])

  data.frame(
    fips_code         = raw$fips_code,
    Year              = as.integer(raw$Year),
    In_Migration_Rate = safe_div(inmig, num(raw[["B07001_001E"]])),
    Pct_Age_65plus    = safe_div(age65, num(raw[["B01001_001E"]])),
    Pct_Owner_Occupied = safe_div(num(raw[["B25003_002E"]]), num(raw[["B25003_001E"]])),
    stringsAsFactors  = FALSE
  )
}

run_process_county_demographics <- function(config = list()) {
  path_raw    <- config$path_raw %||% "Data/County_Socioeconomic/acs_demographics_raw.csv"
  output_path <- config$output_path %||% "Data/intermediate_demographics.rds"
  if (!file.exists(path_raw)) {
    stop("Required file not found: ", path_raw,
         "\nRun Code/download_county_socioeconomic.R first.")
  }

  raw <- read_csv(path_raw, show_col_types = FALSE, progress = FALSE)
  raw$fips_code <- trimws(sprintf("%05s", raw$fips_code))

  feats <- compute_demographic_features(raw) %>%
    filter(is_valid_county_fips(fips_code), !is.na(Year)) %>%
    arrange(fips_code, Year)

  saveRDS(feats, output_path)
  cat(sprintf("Saved %d county-year demographic rows (%d-%d, %d counties) to %s\n",
              nrow(feats), min(feats$Year), max(feats$Year),
              dplyr::n_distinct(feats$fips_code), output_path))
  cat(sprintf("  NA rates: In_Migration_Rate=%.1f%%, Pct_Age_65plus=%.1f%%, Pct_Owner_Occupied=%.1f%%\n",
              100 * mean(is.na(feats$In_Migration_Rate)),
              100 * mean(is.na(feats$Pct_Age_65plus)),
              100 * mean(is.na(feats$Pct_Owner_Occupied))))
  invisible(feats)
}

if (sys.nframe() == 0 && !isTRUE(getOption("demographics.test_mode"))) {
  run_process_county_demographics()
}
