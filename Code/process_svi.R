# ---------------------------------------------------------------------------
# process_svi.R  (Climate–Health Exposure Index — Phase 1)
#
# Builds a county-year SVI panel (2011-2023) from the ATSDR vintage CSVs.
# Keeps the overall vulnerability percentile RPL_THEMES and the four theme
# percentiles (RPL_THEME1 socioeconomic, 2 household composition/disability,
# 3 minority status/language, 4 housing type/transportation). -999 -> NA.
#
# VINTAGE -> YEAR MAPPING: SVI is published every ~2 years (2014/16/18/20/22). Each
# panel year is assigned the largest vintage <= that year, floored at 2014 (so
# 2011-2013 use the 2014 vintage). SVI is slow-moving, so this nearest-vintage
# carry is a standard approach.
#
# Two vulnerability columns are produced:
#   SVI_static : TIME-INVARIANT per county (2018 vintage; mean-across-vintages
#                fallback where 2018 is NA). PRIMARY for the Shock x SVI
#                interaction — the main effect is absorbed by county FE, the
#                interaction is identified, and a fixed V_i cannot respond to shocks.
#   SVI_yr      : TIME-VARYING nearest-vintage value (robustness).
#
# OUTPUT: Data/intermediate_svi.rds
#   (fips_code, Year, SVI_yr, SVI_T1_yr..SVI_T4_yr, SVI_static)
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(dplyr); library(tidyr) })

if (!exists("%||%")) {
  `%||%` <- function(x, y) if (is.null(x) || (length(x) == 1 && is.na(x))) y else x
}

is_valid_county_fips <- function(fips) {
  grepl("^[0-9]{5}$", fips) & !grepl("000$", fips) & substr(fips, 1, 2) != "00"
}

# Largest vintage <= year, floored at the earliest available vintage.
nearest_svi_vintage <- function(year, vintages = c(2014, 2016, 2018, 2020, 2022)) {
  vapply(as.integer(year), function(y) {
    le <- vintages[vintages <= y]
    if (length(le) > 0) max(le) else min(vintages)
  }, numeric(1))
}

# Load all vintage CSVs into one long table (fips_code, vintage + percentiles).
load_svi_long <- function(svi_dir = "Data/SVI_Data",
                          vintages = c(2014, 2016, 2018, 2020, 2022)) {
  keep <- c("RPL_THEMES", "RPL_THEME1", "RPL_THEME2", "RPL_THEME3", "RPL_THEME4")
  out <- list()
  for (yr in vintages) {
    f <- file.path(svi_dir, sprintf("SVI_%d_US_county.csv", yr))
    if (!file.exists(f)) { warning("Missing SVI vintage file: ", f); next }
    d <- utils::read.csv(f, stringsAsFactors = FALSE)
    # Zero-pad to 5 digits. NOTE: %05s pads with SPACES (would drop CA/AL/etc.
    # whose FIPS read as 4-digit integers) — use integer zero-padding.
    d$fips_code <- formatC(as.integer(trimws(as.character(d$FIPS))), width = 5, flag = "0")
    sub <- d[, c("fips_code", keep)]
    for (k in keep) {
      v <- suppressWarnings(as.numeric(sub[[k]]))
      v[!is.na(v) & v == -999] <- NA_real_     # ATSDR missing code
      sub[[k]] <- v
    }
    sub$vintage <- yr
    out[[as.character(yr)]] <- sub
  }
  dplyr::bind_rows(out) %>% filter(is_valid_county_fips(fips_code))
}

run_process_svi <- function(config = list()) {
  svi_dir     <- config$svi_dir %||% "Data/SVI_Data"
  output_path <- config$output_path %||% "Data/intermediate_svi.rds"
  panel_years <- config$panel_years %||% 2011:2023
  vintages    <- config$vintages %||% c(2014, 2016, 2018, 2020, 2022)

  svi_long <- load_svi_long(svi_dir, vintages)

  # Time-invariant vulnerability: 2018 value, fallback to per-county cross-vintage mean.
  static <- svi_long %>%
    group_by(fips_code) %>%
    summarise(svi_mean = mean(RPL_THEMES, na.rm = TRUE),
              svi_2018 = RPL_THEMES[vintage == 2018][1], .groups = "drop") %>%
    mutate(SVI_static = ifelse(!is.na(svi_2018), svi_2018, svi_mean)) %>%
    select(fips_code, SVI_static)

  # Time-varying: assign each panel year its nearest vintage, then join.
  grid <- expand.grid(fips_code = unique(svi_long$fips_code), Year = panel_years,
                      stringsAsFactors = FALSE)
  grid$vintage <- nearest_svi_vintage(grid$Year, vintages)

  tv <- svi_long %>%
    rename(SVI_yr = RPL_THEMES, SVI_T1_yr = RPL_THEME1, SVI_T2_yr = RPL_THEME2,
           SVI_T3_yr = RPL_THEME3, SVI_T4_yr = RPL_THEME4)

  panel <- grid %>%
    left_join(tv, by = c("fips_code", "vintage")) %>%
    left_join(static, by = "fips_code") %>%
    select(fips_code, Year, SVI_yr, SVI_T1_yr, SVI_T2_yr, SVI_T3_yr, SVI_T4_yr, SVI_static) %>%
    arrange(fips_code, Year)

  saveRDS(panel, output_path)
  cat(sprintf("Saved %d county-year SVI rows (%d-%d, %d counties) to %s\n",
              nrow(panel), min(panel$Year), max(panel$Year),
              dplyr::n_distinct(panel$fips_code), output_path))
  cat(sprintf("  NA rates: SVI_yr=%.1f%%, SVI_static=%.1f%%\n",
              100 * mean(is.na(panel$SVI_yr)), 100 * mean(is.na(panel$SVI_static))))
  invisible(panel)
}

if (sys.nframe() == 0 && !isTRUE(getOption("svi.test_mode"))) run_process_svi()
