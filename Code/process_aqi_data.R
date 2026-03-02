# R script to aggregate county AQI data to state level (population-weighted).
# Depends on: process_county_aqi.R, process_county_population.R

library(dplyr)

if (!exists("%||%")) {
  `%||%` <- function(x, y) {
    if (is.null(x)) return(y)
    if (length(x) == 1 && is.atomic(x) && is.na(x)) return(y)
    x
  }
}

run_process_aqi_data <- function(config = list()) {
  county_aqi_rds <- config$county_aqi_rds %||% "Data/intermediate_aqi.rds"
  pop_rds        <- config$pop_rds        %||% "Data/intermediate_pop.rds"
  output_path    <- config$output_path    %||% "Data/state_aqi_consolidated.csv"

  cat("Aggregating County AQI to State Level (Population-Weighted)...\n")

  if (!file.exists(county_aqi_rds)) stop("Run process_county_aqi.R first: ", county_aqi_rds)
  if (!file.exists(pop_rds))        stop("Run process_county_population.R first: ", pop_rds)

  df_aqi <- readRDS(county_aqi_rds)
  df_pop <- readRDS(pop_rds) %>% select(fips_code, Year, Population)

  # Join population; fall back to weight = 1 for counties with no pop data
  df <- df_aqi %>%
    left_join(df_pop, by = c("fips_code", "Year")) %>%
    mutate(Pop_Wt = coalesce(as.numeric(Population), 1))

  state_aqi <- df %>%
    group_by(State = StateName, Year) %>%
    summarize(
      # Population-weighted mean of county median AQI
      AQI_Median_Wtd       = weighted.mean(Median_AQI, w = Pop_Wt, na.rm = TRUE),
      # Worst county reading in the state
      AQI_Max_State        = max(Max_AQI, na.rm = TRUE),
      # Pollutant day totals (summed across counties)
      Days_AQI_Total       = sum(Days_AQI,       na.rm = TRUE),
      Days_CO_Total        = sum(Days_CO,         na.rm = TRUE),
      Days_NO2_Total       = sum(Days_NO2,        na.rm = TRUE),
      Days_Ozone_Total     = sum(Days_Ozone,      na.rm = TRUE),
      Days_PM25_Total      = sum(Days_PM25,       na.rm = TRUE),
      Days_PM10_Total      = sum(Days_PM10,       na.rm = TRUE),
      Days_Unhealthy_Total = sum(Days_Unhealthy,  na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      Pct_CO_State        = if_else(Days_AQI_Total > 0, Days_CO_Total        / Days_AQI_Total * 100, 0),
      Pct_NO2_State       = if_else(Days_AQI_Total > 0, Days_NO2_Total       / Days_AQI_Total * 100, 0),
      Pct_Ozone_State     = if_else(Days_AQI_Total > 0, Days_Ozone_Total     / Days_AQI_Total * 100, 0),
      Pct_PM25_State      = if_else(Days_AQI_Total > 0, Days_PM25_Total      / Days_AQI_Total * 100, 0),
      Pct_PM10_State      = if_else(Days_AQI_Total > 0, Days_PM10_Total      / Days_AQI_Total * 100, 0),
      Pct_Unhealthy_State = if_else(Days_AQI_Total > 0, Days_Unhealthy_Total / Days_AQI_Total * 100, 0)
    )

  write.csv(state_aqi, output_path, row.names = FALSE)
  cat("Success! State AQI consolidated to:", output_path, "\n")

  list(outputs = c(output_path), rows = nrow(state_aqi))
}

if (sys.nframe() == 0) {
  run_process_aqi_data()
}
