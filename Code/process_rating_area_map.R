# R script to process HIX Premium Data (Rating Area to County)

# 1. Setup ----------------------------------------------------------------
library(dplyr)
library(stringr)

plan_dir <- "Data/HIX_Data/plan details"
crosswalk_dir <- "Data/HIX_Data/crosswalk"
output_path <- "Data/premiums_county.csv"

# Normalize mixed rating area formats to crosswalk-compatible "ST##" IDs.
normalize_rating_area_id <- function(st, area) {
  st <- as.character(st)
  area <- trimws(as.character(area))
  normalized <- area

  # Example: "Rating Area 1" -> "ST01"
  rating_area_text <- str_detect(area, regex("^Rating\\s*Area", ignore_case = TRUE))
  if (any(rating_area_text, na.rm = TRUE)) {
    area_num <- str_extract(area[rating_area_text], "\\d+")
    normalized[rating_area_text] <- paste0(st[rating_area_text], sprintf("%02d", as.integer(area_num)))
  }

  # Example: "CA1" -> "CA01"
  short_code <- str_detect(normalized, "^[A-Za-z]{2}\\d{1,2}$")
  if (any(short_code, na.rm = TRUE)) {
    state_prefix <- toupper(str_sub(normalized[short_code], 1, 2))
    area_num <- str_extract(normalized[short_code], "\\d+")
    normalized[short_code] <- paste0(state_prefix, sprintf("%02d", as.integer(area_num)))
  }

  normalized
}

# 2. Helper Function to Process Single Year -------------------------------
process_year <- function(zip_file) {
  year <- as.integer(str_extract(basename(zip_file), "\\d{4}"))
  cat(paste0("Processing Year: ", year, "...
"))
  
  # A. Read Plans/Rates
  # Note: File name inside zip might vary. We look for 'plans.csv' or similar.
  file_list <- unzip(zip_file, list = TRUE)
  target_file <- file_list$Name[grepl("plans\\.csv|Rate\\.csv", file_list$Name, ignore.case = TRUE)][1]
  
  if (is.na(target_file)) {
    warning(paste("No suitable plan/rate file found in", zip_file))
    return(NULL)
  }
  
  cat(paste0("  Reading ", target_file, "...
"))
  
  # Read CSV from Zip
  con <- unz(zip_file, target_file)
  df_plans <- tryCatch(
    read.csv(con, stringsAsFactors = FALSE),
    error = function(e) { warning(e); return(NULL) }
  )
  
  if (is.null(df_plans)) return(NULL)
  
  # Normalize Columns (Handle varying names across years)
  # Standardize to: ST, AREA, METAL, RATE
  cols <- colnames(df_plans)
  
  # Identify Rate Column (PREMI27 or IndividualRate)
  if ("PREMI27" %in% cols) {
    df_plans <- df_plans %>% rename(RATE = PREMI27)
  } else if ("IndividualRate" %in% cols) {
    df_plans <- df_plans %>% rename(RATE = IndividualRate)
  } else {
    warning("  Rate column not found. Skipping.")
    return(NULL)
  }
  
  # Identify Area Column (AREA or RatingAreaId)
  if ("RatingAreaId" %in% cols) {
    df_plans <- df_plans %>% rename(AREA = RatingAreaId)
  }
  # Ensure ST exists
  if (!"ST" %in% cols && "StateCode" %in% cols) {
    df_plans <- df_plans %>% rename(ST = StateCode)
  }

  required_cols <- c("ST", "AREA", "METAL", "RATE")
  missing_cols <- setdiff(required_cols, colnames(df_plans))
  if (length(missing_cols) > 0) {
    warning(paste("  Missing required columns:", paste(missing_cols, collapse = ", ")))
    return(NULL)
  }
  
  # Filter and Aggregate
  # We need Silver and Bronze-level plans.
  # Some years label bronze-level plans as "Expanded_bronze".
  # Rate needs to be numeric
  df_agg <- df_plans %>%
    mutate(
      RATE = as.numeric(RATE),
      METAL = trimws(as.character(METAL)),
      METAL = str_replace_all(METAL, "_", " "),
      METAL = str_to_title(str_to_lower(METAL)),
      METAL = if_else(METAL == "Expanded Bronze", "Bronze", METAL)
    ) %>%
    filter(!is.na(RATE), RATE > 0, METAL %in% c("Silver", "Bronze")) %>%
    group_by(ST, AREA, METAL) %>%
    summarize(
      # Benchmark Silver = 2nd Lowest Cost Silver Plan
      # Logic: Sort, take 2nd. If only 1, take 1st.
      Price = if (unique(METAL) == "Silver") {
        if(n() >= 2) sort(RATE)[2] else sort(RATE)[1]
      } else {
        min(RATE) # Lowest Bronze
      },
      .groups = "drop"
    ) %>%
    tidyr::pivot_wider(names_from = METAL, values_from = Price) %>%
    rename(Benchmark_Silver = Silver, Lowest_Bronze = Bronze)
  
  # B. Read Crosswalk for Year
  cw_pattern <- paste0("individual_county_rating_area_crosswalk_", year, "_.*\\.csv")
  cw_files <- list.files(crosswalk_dir, pattern = cw_pattern, full.names = TRUE)
  
  if (length(cw_files) == 0) {
    warning(paste("  No crosswalk found for year", year))
    return(NULL)
  }
  
  # Take the first match (usually only one per year)
  cw_file <- cw_files[1]
  cat(paste0("  Using Crosswalk: ", basename(cw_file), "
"))
  
  df_cw <- read.csv(cw_file, stringsAsFactors = FALSE)
  
  # Normalize Crosswalk Columns
  # Expected: fips_code, rating_area_id, State
  cw_cols <- colnames(df_cw)
  
  # Map columns
  if ("fips_code" %in% cw_cols) {
    # Keep as is
  } else if ("FIPS.Code" %in% cw_cols) {
    df_cw <- df_cw %>% rename(fips_code = FIPS.Code)
  }
  
  if ("rating_area_id" %in% cw_cols) {
    # Keep
  } else if ("Rating.Area.ID" %in% cw_cols) {
    df_cw <- df_cw %>% rename(rating_area_id = Rating.Area.ID)
  }
  
  # Normalize AREA to crosswalk format "ST##".
  df_agg <- df_agg %>%
    mutate(rating_area_id = normalize_rating_area_id(ST, AREA))

  # C. Join crosswalk to rates on normalized rating_area_id
  df_cw$fips_code <- sprintf("%05d", as.numeric(df_cw$fips_code))

  df_merged <- df_cw %>%
    select(fips_code, rating_area_id) %>%
    distinct() %>%
    left_join(df_agg, by = "rating_area_id") %>%
    mutate(
      Year = year,
      State = substr(rating_area_id, 1, 2)
    ) %>%
    select(fips_code, Year, Benchmark_Silver, Lowest_Bronze, State, rating_area_id)
  
  return(df_merged)
}

run_process_rating_area_map <- function() {
  # 3. Main Loop ----------------------------------------------------------
  zip_files <- list.files(plan_dir, pattern = "\\.zip$", full.names = TRUE)
  all_premiums <- list()

  for (f in zip_files) {
    res <- process_year(f)
    if (!is.null(res)) {
      all_premiums[[length(all_premiums) + 1]] <- res
    }
  }

  # 4. Consolidate and Export ---------------------------------------------
  if (length(all_premiums) > 0) {
    final_df <- do.call(rbind, all_premiums)
    
    # Filter out rows where we failed to map premiums (optional)
    # final_df <- final_df %>% filter(!is.na(Benchmark_Silver))
    
    write.csv(final_df, output_path, row.names = FALSE)
    cat(paste0("
Success! Premium data saved to: ", output_path, "
"))
    cat(paste0("Total Records: ", nrow(final_df), "
"))
  } else {
    cat("
Error: No data processed.
")
  }
}

if (Sys.getenv("PROCESS_RATING_AREA_MAP_SKIP_MAIN") != "1") {
  run_process_rating_area_map()
}
