# R script to aggregate county AQI data to state level.
# Primary series: strict population-weighted (no Pop_Wt=1 fallback).
# Robustness series: equal-weight county mean.
# Depends on: process_county_aqi.R, process_county_population.R

library(dplyr)

if (!exists("%||%")) {
  `%||%` <- function(x, y) {
    if (is.null(x)) return(y)
    if (length(x) == 1 && is.atomic(x) && is.na(x)) return(y)
    x
  }
}

pick_col <- function(df, candidates, required = TRUE) {
  hit <- intersect(candidates, names(df))
  if (length(hit) > 0) return(hit[[1]])
  if (required) stop("Missing required column. Expected one of: ", paste(candidates, collapse = ", "))
  NULL
}

run_process_aqi_data <- function(config = list()) {
  county_aqi_rds     <- config$county_aqi_rds     %||% "Data/intermediate_aqi.rds"
  pop_rds            <- config$pop_rds            %||% "Data/intermediate_pop.rds"
  output_path        <- config$output_path        %||% "Data/state_aqi_consolidated.csv"
  diagnostics_path   <- config$diagnostics_path   %||% "Analysis/state_aqi_weight_diagnostics.csv"

  cat("Aggregating County AQI to State Level (Strict Population Weights + EW Robustness)...\n")

  if (!file.exists(county_aqi_rds)) stop("Run process_county_aqi.R first: ", county_aqi_rds)
  if (!file.exists(pop_rds))        stop("Run process_county_population.R first: ", pop_rds)

  df_aqi <- readRDS(county_aqi_rds)
  df_pop <- readRDS(pop_rds) %>% select(fips_code, Year, Population)

  # Column compatibility: supports both legacy and current county AQI intermediates.
  col_state_abbr <- pick_col(df_aqi, c("State", "StateAbbr"), required = FALSE)
  col_state_name <- pick_col(df_aqi, c("StateName"), required = FALSE)
  col_median     <- pick_col(df_aqi, c("Median_AQI", "Median.AQI"))
  col_max        <- pick_col(df_aqi, c("Max_AQI", "Max.AQI"), required = FALSE)
  col_days_aqi   <- pick_col(df_aqi, c("Days_AQI", "Days.with.AQI"), required = FALSE)
  col_days_co    <- pick_col(df_aqi, c("Days_CO", "Days.CO"), required = FALSE)
  col_days_no2   <- pick_col(df_aqi, c("Days_NO2", "Days.NO2"), required = FALSE)
  col_days_ozone <- pick_col(df_aqi, c("Days_Ozone", "Days.Ozone"), required = FALSE)
  col_days_pm25  <- pick_col(df_aqi, c("Days_PM25", "Days.PM2.5"), required = FALSE)
  col_days_pm10  <- pick_col(df_aqi, c("Days_PM10", "Days.PM10"), required = FALSE)
  col_days_unhl  <- pick_col(df_aqi, c("Days_Unhealthy", "Unhealthy.Days"), required = FALSE)

  abbr_to_name <- c(setNames(state.name, state.abb), "DC" = "District of Columbia")
  name_to_abbr <- c(setNames(state.abb, state.name), "District of Columbia" = "DC")
  us_state_abbr <- c(state.abb, "DC")

  state_abbr_raw <- if (!is.null(col_state_abbr)) toupper(trimws(as.character(df_aqi[[col_state_abbr]]))) else NA_character_
  state_name_raw <- if (!is.null(col_state_name)) trimws(as.character(df_aqi[[col_state_name]])) else NA_character_
  state_abbr <- ifelse(!is.na(state_abbr_raw) & state_abbr_raw != "", state_abbr_raw, name_to_abbr[state_name_raw])
  state_name <- ifelse(!is.na(state_name_raw) & state_name_raw != "", state_name_raw, unname(abbr_to_name[state_abbr]))

  # Keep only 50 states + DC for the state analysis pipeline.
  df_norm <- data.frame(
    fips_code = as.character(df_aqi$fips_code),
    Year = as.integer(df_aqi$Year),
    State_Abbr = as.character(state_abbr),
    State = as.character(state_name),
    Median_AQI = as.numeric(df_aqi[[col_median]]),
    Max_AQI = if (!is.null(col_max)) as.numeric(df_aqi[[col_max]]) else NA_real_,
    Days_AQI = if (!is.null(col_days_aqi)) as.numeric(df_aqi[[col_days_aqi]]) else NA_real_,
    Days_CO = if (!is.null(col_days_co)) as.numeric(df_aqi[[col_days_co]]) else NA_real_,
    Days_NO2 = if (!is.null(col_days_no2)) as.numeric(df_aqi[[col_days_no2]]) else NA_real_,
    Days_Ozone = if (!is.null(col_days_ozone)) as.numeric(df_aqi[[col_days_ozone]]) else NA_real_,
    Days_PM25 = if (!is.null(col_days_pm25)) as.numeric(df_aqi[[col_days_pm25]]) else NA_real_,
    Days_PM10 = if (!is.null(col_days_pm10)) as.numeric(df_aqi[[col_days_pm10]]) else NA_real_,
    Days_Unhealthy = if (!is.null(col_days_unhl)) as.numeric(df_aqi[[col_days_unhl]]) else NA_real_,
    stringsAsFactors = FALSE
  ) %>%
    filter(!is.na(State_Abbr), State_Abbr %in% us_state_abbr, !is.na(State), State != "")

  # Strict weighting: missing population is dropped from weighted aggregation.
  df <- df_norm %>%
    left_join(df_pop, by = c("fips_code", "Year")) %>%
    mutate(Population = as.numeric(Population))

  state_aqi <- df %>%
    group_by(State, Year) %>%
    summarize(
      N_Counties_AQI = sum(!is.na(Median_AQI)),
      N_Counties_With_Pop = sum(!is.na(Median_AQI) & !is.na(Population)),
      N_Dropped_Missing_Pop = N_Counties_AQI - N_Counties_With_Pop,
      Drop_Share = ifelse(N_Counties_AQI > 0, N_Dropped_Missing_Pop / N_Counties_AQI, NA_real_),
      # Primary: strict population-weighted mean.
      AQI_Median_Wtd = {
        ok <- !is.na(Median_AQI) & !is.na(Population)
        if (sum(ok) == 0) NA_real_ else weighted.mean(Median_AQI[ok], w = Population[ok], na.rm = TRUE)
      },
      # Robustness: equal-weight county mean.
      AQI_Median_EW = {
        ok <- !is.na(Median_AQI)
        if (sum(ok) == 0) NA_real_ else mean(Median_AQI[ok], na.rm = TRUE)
      },
      AQI_Max_State = {
        ok <- !is.na(Max_AQI)
        if (sum(ok) == 0) NA_real_ else max(Max_AQI[ok], na.rm = TRUE)
      },
      Days_AQI_Total = {
        ok <- !is.na(Days_AQI)
        if (sum(ok) == 0) NA_real_ else sum(Days_AQI[ok], na.rm = TRUE)
      },
      Days_CO_Total = {
        ok <- !is.na(Days_CO)
        if (sum(ok) == 0) NA_real_ else sum(Days_CO[ok], na.rm = TRUE)
      },
      Days_NO2_Total = {
        ok <- !is.na(Days_NO2)
        if (sum(ok) == 0) NA_real_ else sum(Days_NO2[ok], na.rm = TRUE)
      },
      Days_Ozone_Total = {
        ok <- !is.na(Days_Ozone)
        if (sum(ok) == 0) NA_real_ else sum(Days_Ozone[ok], na.rm = TRUE)
      },
      Days_PM25_Total = {
        ok <- !is.na(Days_PM25)
        if (sum(ok) == 0) NA_real_ else sum(Days_PM25[ok], na.rm = TRUE)
      },
      Days_PM10_Total = {
        ok <- !is.na(Days_PM10)
        if (sum(ok) == 0) NA_real_ else sum(Days_PM10[ok], na.rm = TRUE)
      },
      Days_Unhealthy_Total = {
        ok <- !is.na(Days_Unhealthy)
        if (sum(ok) == 0) NA_real_ else sum(Days_Unhealthy[ok], na.rm = TRUE)
      },
      .groups = "drop"
    ) %>%
    mutate(
      AQI_Median_Wtd_minus_EW = AQI_Median_Wtd - AQI_Median_EW,
      Pct_CO_State = if_else(!is.na(Days_AQI_Total) & Days_AQI_Total > 0, Days_CO_Total / Days_AQI_Total * 100, NA_real_),
      Pct_NO2_State = if_else(!is.na(Days_AQI_Total) & Days_AQI_Total > 0, Days_NO2_Total / Days_AQI_Total * 100, NA_real_),
      Pct_Ozone_State = if_else(!is.na(Days_AQI_Total) & Days_AQI_Total > 0, Days_Ozone_Total / Days_AQI_Total * 100, NA_real_),
      Pct_PM25_State = if_else(!is.na(Days_AQI_Total) & Days_AQI_Total > 0, Days_PM25_Total / Days_AQI_Total * 100, NA_real_),
      Pct_PM10_State = if_else(!is.na(Days_AQI_Total) & Days_AQI_Total > 0, Days_PM10_Total / Days_AQI_Total * 100, NA_real_),
      Pct_Unhealthy_State = if_else(!is.na(Days_AQI_Total) & Days_AQI_Total > 0, Days_Unhealthy_Total / Days_AQI_Total * 100, NA_real_)
    ) %>%
    arrange(State, Year)

  # Avoid propagating all-NA optional columns into downstream regressions.
  # If an AQI component is unavailable in the county intermediate, drop it
  # rather than keeping a degenerate all-NA column.
  optional_cols <- c(
    "AQI_Max_State",
    "Days_AQI_Total", "Days_CO_Total", "Days_NO2_Total", "Days_Ozone_Total",
    "Days_PM25_Total", "Days_PM10_Total", "Days_Unhealthy_Total",
    "Pct_CO_State", "Pct_NO2_State", "Pct_Ozone_State",
    "Pct_PM25_State", "Pct_PM10_State", "Pct_Unhealthy_State"
  )
  optional_cols <- intersect(optional_cols, names(state_aqi))
  drop_all_na <- optional_cols[sapply(state_aqi[optional_cols], function(x) all(is.na(x)))]
  if (length(drop_all_na) > 0) {
    state_aqi <- state_aqi %>% select(-all_of(drop_all_na))
    cat("Dropped all-NA optional AQI columns:", paste(drop_all_na, collapse = ", "), "\n")
  }

  diagnostics <- state_aqi %>%
    select(any_of(c(
      "State", "Year", "N_Counties_AQI", "N_Counties_With_Pop", "N_Dropped_Missing_Pop",
      "Drop_Share", "AQI_Median_Wtd", "AQI_Median_EW", "AQI_Median_Wtd_minus_EW"
    ))) %>%
    mutate(Has_Primary_AQI = !is.na(AQI_Median_Wtd))

  dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)
  dir.create(dirname(diagnostics_path), showWarnings = FALSE, recursive = TRUE)
  write.csv(state_aqi, output_path, row.names = FALSE)
  write.csv(diagnostics, diagnostics_path, row.names = FALSE)

  n_state_year <- nrow(diagnostics)
  n_drop_groups <- sum(diagnostics$N_Dropped_Missing_Pop > 0, na.rm = TRUE)
  n_no_primary <- sum(!diagnostics$Has_Primary_AQI, na.rm = TRUE)
  dropped_rows <- sum(diagnostics$N_Dropped_Missing_Pop, na.rm = TRUE)

  cat("Success! State AQI consolidated to:", output_path, "\n")
  cat("Diagnostics saved to:", diagnostics_path, "\n")
  cat("State-years:", n_state_year,
      "| With dropped counties (missing pop):", n_drop_groups,
      "| No primary AQI value:", n_no_primary,
      "| Total dropped county-year rows:", dropped_rows, "\n")

  list(outputs = c(output_path, diagnostics_path), rows = nrow(state_aqi))
}

if (sys.nframe() == 0) {
  run_process_aqi_data()
}
