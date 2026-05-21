# Never-Exposed Inventory for DiD Feasibility (Phase 0)
#
# Counts shock-event occurrences per county over 2011-2023 to identify
# never-exposed counties for each shock indicator. Output supports the
# DiD feasibility memo (Analysis/did_feasibility_memo.md) and the
# downstream Phase 3a/3b natural-experiment and Callaway-Sant'Anna designs.
#
# Inputs:
#   Data/county_level_master.csv
#
# Outputs:
#   Analysis/never_exposed_inventory.csv      (long: one row per county x shock)
#   Analysis/never_exposed_summary.csv        (per-shock totals: ever/never)
#   Analysis/never_exposed_by_state.csv       (per-shock x state counts)
#   Analysis/never_exposed_event_year.csv     (per-shock x year: new-onset counts)
#
# Shock indicators:
#   Is_Extreme_Drought  (PDSI <= -4; from process_county_climate.R)
#   High_CDD            (top quintile CDD; from process_county_climate.R)
#   High_HDD            (top quintile HDD; from process_county_climate.R)
#   High_AQI_Max        (Max_AQI > 100; constructed here, matches run_event_study.R)

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
})

master_path <- "Data/county_level_master.csv"
stopifnot(file.exists(master_path))

df <- read_csv(master_path, show_col_types = FALSE, progress = FALSE)

required_cols <- c("fips_code", "Year", "State",
                   "Is_Extreme_Drought", "High_CDD", "High_HDD", "Max_AQI")
missing_cols <- setdiff(required_cols, names(df))
if (length(missing_cols) > 0) {
  stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
}

df <- df %>%
  mutate(High_AQI_Max = as.integer(Max_AQI > 100)) %>%
  distinct(fips_code, Year, State, Is_Extreme_Drought, High_CDD, High_HDD, High_AQI_Max) %>%
  filter(Year >= 2011, Year <= 2023)

shock_indicators <- c("Is_Extreme_Drought", "High_CDD", "High_HDD", "High_AQI_Max")

county_year_n <- df %>% distinct(fips_code, Year) %>% nrow()
cat(sprintf("Panel: %d unique county-years; %d unique counties; %d unique years.\n",
            county_year_n,
            length(unique(df$fips_code)),
            length(unique(df$Year))))

# 1. Per-county event counts, one row per (county x shock) ------------------
inventory_long <- df %>%
  pivot_longer(cols = all_of(shock_indicators),
               names_to = "shock", values_to = "is_event") %>%
  group_by(fips_code, State, shock) %>%
  summarise(n_years_obs = sum(!is.na(is_event)),
            n_events    = sum(is_event == 1, na.rm = TRUE),
            first_event_year = suppressWarnings(min(Year[is_event == 1], na.rm = TRUE)),
            last_event_year  = suppressWarnings(max(Year[is_event == 1], na.rm = TRUE)),
            .groups = "drop") %>%
  mutate(first_event_year = ifelse(is.infinite(first_event_year), NA_integer_, first_event_year),
         last_event_year  = ifelse(is.infinite(last_event_year),  NA_integer_, last_event_year),
         ever_exposed     = as.integer(n_events > 0),
         never_exposed    = as.integer(n_events == 0 & n_years_obs > 0))

dir.create("Analysis", showWarnings = FALSE)
write_csv(inventory_long, "Analysis/never_exposed_inventory.csv")

# 2. Per-shock totals --------------------------------------------------------
summary_per_shock <- inventory_long %>%
  group_by(shock) %>%
  summarise(n_counties_total   = n(),
            n_ever_exposed     = sum(ever_exposed),
            n_never_exposed    = sum(never_exposed),
            share_never        = n_never_exposed / n_counties_total,
            mean_events_ever   = mean(n_events[ever_exposed == 1], na.rm = TRUE),
            median_events_ever = median(n_events[ever_exposed == 1], na.rm = TRUE),
            max_events         = max(n_events, na.rm = TRUE),
            .groups = "drop")

write_csv(summary_per_shock, "Analysis/never_exposed_summary.csv")

cat("\n=== Per-shock summary ===\n")
print(as.data.frame(summary_per_shock))

# 3. Per-shock x state -------------------------------------------------------
by_state <- inventory_long %>%
  group_by(shock, State) %>%
  summarise(n_counties      = n(),
            n_ever_exposed  = sum(ever_exposed),
            n_never_exposed = sum(never_exposed),
            share_never     = n_never_exposed / n_counties,
            .groups = "drop") %>%
  arrange(shock, State)

write_csv(by_state, "Analysis/never_exposed_by_state.csv")

# 4. Event-year onset density ----------------------------------------------
# A "new onset" is a county-year where the shock transitions 0 -> 1
# (or appears for the first time after a non-shock prior year). Used to
# locate sharp candidate events for natural-experiment DiD.
onset_table <- df %>%
  arrange(fips_code, Year) %>%
  group_by(fips_code) %>%
  mutate(across(all_of(shock_indicators),
                ~ ifelse(is.na(.x) | is.na(lag(.x)), NA_integer_,
                         as.integer(.x == 1 & lag(.x) == 0)),
                .names = "onset_{.col}")) %>%
  ungroup()

onsets_by_year <- onset_table %>%
  pivot_longer(cols = starts_with("onset_"),
               names_to = "shock", values_to = "is_onset") %>%
  mutate(shock = sub("^onset_", "", shock)) %>%
  group_by(shock, Year) %>%
  summarise(n_counties_with_onset = sum(is_onset == 1, na.rm = TRUE),
            n_counties_obs        = sum(!is.na(is_onset)),
            onset_rate            = n_counties_with_onset / pmax(n_counties_obs, 1),
            .groups = "drop") %>%
  arrange(shock, Year)

write_csv(onsets_by_year, "Analysis/never_exposed_event_year.csv")

# 5. Top candidate event years per shock (for memo) -------------------------
top_event_years <- onsets_by_year %>%
  group_by(shock) %>%
  slice_max(order_by = n_counties_with_onset, n = 5) %>%
  arrange(shock, desc(n_counties_with_onset))

cat("\n=== Top 5 onset years per shock (candidates for natural-experiment DiD) ===\n")
print(as.data.frame(top_event_years))

cat("\nOutputs written to Analysis/never_exposed_*.csv\n")
