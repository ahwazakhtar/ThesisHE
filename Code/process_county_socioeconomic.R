# Process county-level socioeconomic data into a panel-format intermediate RDS.
#
# Inputs (produced by download_county_socioeconomic.R):
#   Data/County_Socioeconomic/bea_cainc1_pcpi_raw.csv   -- BEA per capita income
#   Data/County_Socioeconomic/acs_socioeconomic_raw.csv -- ACS median HH income
#                                                           + civilian employed count
#
# Output:
#   Data/intermediate_socioeconomic.rds
#     Columns: fips_code, Year, PCPI_Real, Med_HH_Income_Real, Civilian_Employed
#
# Notes:
#   - BEA FIPS codes include US totals (00000) and state totals (*000).
#     We keep only genuine 5-digit county FIPS.
#   - ACS values of -666666666 indicate suppressed estimates -> NA.
#   - Dollar variables are inflation-adjusted to 2023 dollars via CPI.
#   - ACS employment proxy (B23025_004E) covers 2009+; PCPI covers 2001+.
#     Left join on BEA universe so pre-2009 rows have NA for ACS columns.

library(dplyr)
library(readr)

if (!exists("%||%")) {
  `%||%` <- function(x, y) if (is.null(x) || (length(x) == 1 && is.na(x))) y else x
}

# ---------------------------------------------------------------------------
# Helper: validate county FIPS (5 digits, not a state/US aggregate)
# ---------------------------------------------------------------------------
is_valid_county_fips <- function(fips) {
  grepl("^[0-9]{5}$", fips) & !grepl("000$", fips) & substr(fips, 1, 2) != "00"
}

run_process_county_socioeconomic <- function(config = list()) {
  path_pcpi   <- config$path_pcpi   %||% "Data/County_Socioeconomic/bea_cainc1_pcpi_raw.csv"
  path_acs    <- config$path_acs    %||% "Data/County_Socioeconomic/acs_socioeconomic_raw.csv"
  path_cpi    <- config$path_cpi    %||% "Data/State_Policy_Data/us_cpi_annual.csv"
  output_path <- config$output_path %||% "Data/intermediate_socioeconomic.rds"

  for (p in c(path_pcpi, path_acs, path_cpi)) {
    if (!file.exists(p)) stop("Required file not found: ", p,
                              "\nRun Code/download_county_socioeconomic.R first.")
  }

  cat("Processing county socioeconomic data...\n")

  # CPI for inflation adjustment (base year 2023)
  df_cpi   <- read_csv(path_cpi, show_col_types = FALSE)
  cpi_2023 <- df_cpi$CPI_Value[df_cpi$Year == 2023]
  if (length(cpi_2023) == 0) stop("CPI value for 2023 not found in ", path_cpi)

  # ---------------------------------------------------------------------------
  # 1. BEA CAINC1 -- Per Capita Personal Income
  # ---------------------------------------------------------------------------
  cat("  Loading BEA CAINC1 (per capita income)...\n")
  df_pcpi <- read_csv(path_pcpi, col_types = cols(fips_code = col_character(),
                                                   Year      = col_integer(),
                                                   value     = col_character()))
  df_pcpi <- df_pcpi %>%
    mutate(
      fips_code = trimws(sprintf("%05s", fips_code)),
      value_num = suppressWarnings(as.numeric(gsub(",", "", value)))
    ) %>%
    filter(is_valid_county_fips(fips_code), !is.na(Year), !is.na(value_num)) %>%
    # Inner join: drops rows outside CPI coverage (pre-1990, post-2023)
    inner_join(df_cpi, by = "Year") %>%
    mutate(PCPI_Real = value_num * (cpi_2023 / CPI_Value)) %>%
    select(fips_code, Year, PCPI_Real)

  cat("    Rows after cleaning:", nrow(df_pcpi), "\n")

  # ---------------------------------------------------------------------------
  # 2. ACS 5-year -- Median HH Income + Civilian Employed
  # ---------------------------------------------------------------------------
  cat("  Loading ACS (median HH income + civilian employed)...\n")
  df_acs <- read_csv(path_acs, col_types = cols(fips_code         = col_character(),
                                                  Year              = col_integer(),
                                                  med_hh_income_acs = col_double(),
                                                  civilian_employed  = col_double()))
  df_acs <- df_acs %>%
    mutate(
      fips_code = trimws(sprintf("%05s", fips_code)),
      # ACS suppressed values are coded as -666666666
      med_hh_income_acs = if_else(!is.na(med_hh_income_acs) & med_hh_income_acs < 0,
                                  NA_real_, med_hh_income_acs),
      civilian_employed  = if_else(!is.na(civilian_employed) & civilian_employed < 0,
                                   NA_real_, civilian_employed)
    ) %>%
    filter(is_valid_county_fips(fips_code), !is.na(Year)) %>%
    inner_join(df_cpi, by = "Year") %>%
    mutate(Med_HH_Income_Real = med_hh_income_acs * (cpi_2023 / CPI_Value),
           Civilian_Employed  = civilian_employed) %>%
    select(fips_code, Year, Med_HH_Income_Real, Civilian_Employed)

  cat("    Rows after cleaning:", nrow(df_acs), "\n")

  # ---------------------------------------------------------------------------
  # 3. Merge (BEA as spine; ACS left-joined, NA for pre-2009)
  # ---------------------------------------------------------------------------
  cat("  Merging...\n")
  df_merged <- df_pcpi %>%
    left_join(df_acs, by = c("fips_code", "Year")) %>%
    arrange(fips_code, Year)

  cat("  Final panel:", nrow(df_merged), "rows,",
      n_distinct(df_merged$fips_code), "counties,",
      min(df_merged$Year), "-", max(df_merged$Year), "\n")

  # ---------------------------------------------------------------------------
  # 4. Data integrity checks
  # ---------------------------------------------------------------------------
  pcpi_na_pct <- mean(is.na(df_merged$PCPI_Real)) * 100
  acs_na_pct  <- mean(is.na(df_merged$Med_HH_Income_Real)) * 100
  emp_na_pct  <- mean(is.na(df_merged$Civilian_Employed)) * 100

  cat(sprintf("  NA rates: PCPI_Real=%.1f%%, Med_HH_Income_Real=%.1f%%, Civilian_Employed=%.1f%%\n",
              pcpi_na_pct, acs_na_pct, emp_na_pct))

  if (pcpi_na_pct > 20) warning("High NA rate in PCPI_Real — check BEA download.")

  saveRDS(df_merged, output_path)
  cat("Success! Saved to:", output_path, "\n")

  invisible(list(
    outputs  = output_path,
    rows     = nrow(df_merged),
    counties = n_distinct(df_merged$fips_code)
  ))
}

if (!isTRUE(getOption("socioeconomic.test_mode"))) {
  run_process_county_socioeconomic()
}
