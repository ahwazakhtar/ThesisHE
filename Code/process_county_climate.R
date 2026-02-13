# R script to process NOAA County Climate Data efficiently
library(dplyr)
library(tidyr)
library(readr)

# Constants & Mappings
noaa_state_codes <- c(
  "01" = "Alabama", "02" = "Arizona", "03" = "Arkansas", "04" = "California",
  "05" = "Colorado", "06" = "Connecticut", "07" = "Delaware", "08" = "Florida",
  "09" = "Georgia", "10" = "Idaho", "11" = "Illinois", "12" = "Indiana",
  "13" = "Iowa", "14" = "Kansas", "15" = "Kentucky", "16" = "Louisiana",
  "17" = "Maine", "18" = "Maryland", "19" = "Massachusetts", "20" = "Michigan",
  "21" = "Minnesota", "22" = "Mississippi", "23" = "Missouri", "24" = "Montana",
  "25" = "Nebraska", "26" = "Nevada", "27" = "New Hampshire", "28" = "New Jersey",
  "29" = "New Mexico", "30" = "New York", "31" = "North Carolina", "32" = "North Dakota",
  "33" = "Ohio", "34" = "Oklahoma", "35" = "Oregon", "36" = "Pennsylvania",
  "37" = "Rhode Island", "38" = "South Carolina", "39" = "South Dakota", "40" = "Tennessee",
  "41" = "Texas", "42" = "Utah", "43" = "Vermont", "44" = "Virginia",
  "45" = "Washington", "46" = "West Virginia", "47" = "Wisconsin", "48" = "Wyoming",
  "50" = "Alaska", "51" = "Hawaii"
)

state_fips_map <- c(
  "Alabama" = "01", "Alaska" = "02", "Arizona" = "04", "Arkansas" = "05", "California" = "06",
  "Colorado" = "08", "Connecticut" = "09", "Delaware" = "10", "District of Columbia" = "11",
  "Florida" = "12", "Georgia" = "13", "Hawaii" = "15", "Idaho" = "16", "Illinois" = "17",
  "Indiana" = "18", "Iowa" = "19", "Kansas" = "20", "Kentucky" = "21", "Louisiana" = "22",
  "Maine" = "23", "Maryland" = "24", "Massachusetts" = "25", "Michigan" = "26", "Minnesota" = "27",
  "Mississippi" = "28", "Missouri" = "29", "Montana" = "30", "Nebraska" = "31", "Nevada" = "32",
  "New Hampshire" = "33", "New Jersey" = "34", "New Mexico" = "35", "New York" = "36",
  "North Carolina" = "37", "North Dakota" = "38", "Ohio" = "39", "Oklahoma" = "40", "Oregon" = "41",
  "Pennsylvania" = "42", "Rhode Island" = "44", "South Carolina" = "45", "South Dakota" = "46",
  "Tennessee" = "47", "Texas" = "48", "Utah" = "49", "Vermont" = "50", "Virginia" = "51",
  "Washington" = "53", "West Virginia" = "54", "Wisconsin" = "55", "Wyoming" = "56"
)

files <- list(
  cdd = "Data/Climate_Data/County level/climdiv-cddccy-v1.0.0-20260107",
  hdd = "Data/Climate_Data/County level/climdiv-hddccy-v1.0.0-20260107",
  precip = "Data/Climate_Data/County level/climdiv-pcpncy-v1.0.0-20260107",
  temp = "Data/Climate_Data/County level/climdiv-tmpccy-v1.0.0-20260107"
)

output_rds <- "Data/intermediate_climate.rds"

cat("Processing County Climate Data...
")

processed_list <- list()

for (var in names(files)) {
  fpath <- files[[var]]
  cat(paste0("  Reading ", var, " (", basename(fpath), ")...
"))
  
  # NOAA Widths: State(2), Cnty(3), Elem(2), Year(4), Jan-Dec(12*7)
  # Total: 11 + 84 = 95
  df_raw <- read_fwf(fpath, 
                     fwf_widths(c(2, 3, 2, 4, rep(7, 12)), 
                                col_names = c("NOAA_State", "NOAA_Cnty", "Elem", "Year", month.abb)),
                     col_types = "ccciidddddddddddd",
                     show_col_types = FALSE)
  
  df_raw <- df_raw %>% filter(Year >= 1996)
  
  # State Mapping
  df_raw$StateName <- noaa_state_codes[df_raw$NOAA_State]
  df_raw$StateFIPS <- state_fips_map[df_raw$StateName]
  df_raw <- df_raw %>% filter(!is.na(StateFIPS))
  df_raw$fips_code <- paste0(df_raw$StateFIPS, sprintf("%03d", as.integer(df_raw$NOAA_Cnty)))
  
  # Pivot & Aggregate
  long_df <- df_raw %>%
    select(fips_code, Year, all_of(month.abb)) %>%
    pivot_longer(cols = all_of(month.abb), names_to = "Month", values_to = "Value")
  
  long_df$Value[long_df$Value <= -99] <- NA
  
  agg <- long_df %>%
    group_by(fips_code, Year) %>%
    summarize(
      !!paste0(var, "_val") := if(var == "temp") mean(Value, na.rm=TRUE) else sum(Value, na.rm=TRUE), 
      .groups = "drop"
    )
  
  processed_list[[var]] <- agg
}

cat("  Merging and Feature Engineering...
")

full_climate <- Reduce(function(x, y) full_join(x, y, by = c("fips_code", "Year")), processed_list)

full_climate_feat <- full_climate %>%
  group_by(fips_code) %>%
  arrange(Year) %>%
  mutate(
    # Z-Scores
    Z_Temp = (temp_val - mean(temp_val, na.rm = TRUE)) / sd(temp_val, na.rm = TRUE),
    Z_Precip = (precip_val - mean(precip_val, na.rm = TRUE)) / sd(precip_val, na.rm = TRUE),
    
    # CDD/HDD Quintiles
    High_CDD = ifelse(ntile(cdd_val, 5) == 5, 1, 0),
    High_HDD = ifelse(ntile(hdd_val, 5) == 5, 1, 0),
    
    # Distributed Lags (0-2)
    Z_Temp_Lag1 = lag(Z_Temp, 1), Z_Temp_Lag2 = lag(Z_Temp, 2),
    Z_Precip_Lag1 = lag(Z_Precip, 1), Z_Precip_Lag2 = lag(Z_Precip, 2),
    High_CDD_Lag1 = lag(High_CDD, 1), High_CDD_Lag2 = lag(High_CDD, 2),
    High_HDD_Lag1 = lag(High_HDD, 1), High_HDD_Lag2 = lag(High_HDD, 2)
  ) %>%
  ungroup()

saveRDS(full_climate_feat, output_rds)
cat(paste0("Success! Climate data saved to: ", output_rds, "
"))
