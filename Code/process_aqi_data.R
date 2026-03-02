# R script to process EPA AQI Data and aggregate to state level.

library(dplyr)

if (!exists("%||%")) {
  `%||%` <- function(x, y) {
    if (is.null(x)) return(y)
    if (length(x) == 1 && is.atomic(x) && is.na(x)) return(y)
    x
  }
}

run_process_aqi_data <- function(config = list()) {
  aqi_dir <- config$aqi_dir %||% "Data/AQIdata"
  lookup_path <- config$lookup_path %||% "Data/AQIdata/states_and_counties.csv"
  output_path <- config$output_path %||% "Data/state_aqi_consolidated.csv"

  cat("Processing AQI Data (State Aggregation)...\n")

  if (!dir.exists(aqi_dir)) stop("AQI directory not found: ", aqi_dir)
  if (!file.exists(lookup_path)) stop("FIPS lookup file not found at: ", lookup_path)

  df_lookup <- read.csv(lookup_path, colClasses = "character") %>%
    mutate(
      County_Join = tolower(trimws(County.Name)),
      StateName = State.Name
    ) %>%
    distinct(StateName, County_Join)

  aqi_files <- list.files(aqi_dir, pattern = "\\.zip$", full.names = TRUE)
  if (length(aqi_files) == 0) stop("No AQI zip files found in: ", aqi_dir)

  all_aqi_list <- list()
  idx <- 1L
  for (f in aqi_files) {
    year <- as.integer(gsub("[^0-9]", "", basename(f)))
    csv_name <- paste0("annual_aqi_by_county_", year, ".csv")
    cat("  Processing Year:", year, "\n")

    con <- unz(f, csv_name)
    df_aqi <- tryCatch(
      read.csv(con, stringsAsFactors = FALSE),
      error = function(e) NULL
    )
    if (is.null(df_aqi)) next

    if (!all(c("State", "County", "Year", "Median.AQI") %in% names(df_aqi))) {
      warning("Skipping file with unexpected schema: ", basename(f), call. = FALSE)
      next
    }

    df_aqi_clean <- df_aqi %>%
      mutate(
        County_Join = tolower(trimws(County)),
        StateName = State
      ) %>%
      inner_join(df_lookup, by = c("StateName", "County_Join")) %>%
      select(State = StateName, Year, Median.AQI)

    all_aqi_list[[idx]] <- df_aqi_clean
    idx <- idx + 1L
  }

  if (length(all_aqi_list) == 0) stop("No AQI records were parsed from zip files.")

  df_all_aqi <- bind_rows(all_aqi_list)
  state_aqi <- df_all_aqi %>%
    group_by(State, Year) %>%
    summarize(aqi_mean = mean(Median.AQI, na.rm = TRUE), .groups = "drop")

  write.csv(state_aqi, output_path, row.names = FALSE)
  cat("Success! State AQI consolidated to:", output_path, "\n")

  list(outputs = c(output_path), rows = nrow(state_aqi))
}

if (sys.nframe() == 0) {
  run_process_aqi_data()
}
