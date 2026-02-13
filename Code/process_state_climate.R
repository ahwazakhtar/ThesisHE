# R script to process and consolidate state-level climate data
# Aggregation: Annual Sums with Missing Month Flags

# 1. Setup ----------------------------------------------------------------
dir.create("Data/Climate_Data", showWarnings = FALSE)

# NOAA State Code Mapping
state_codes <- c(
  "001" = "Alabama", "002" = "Arizona", "003" = "Arkansas", "004" = "California",
  "005" = "Colorado", "006" = "Connecticut", "007" = "Delaware", "008" = "Florida",
  "009" = "Georgia", "010" = "Idaho", "011" = "Illinois", "012" = "Indiana",
  "013" = "Iowa", "014" = "Kansas", "015" = "Kentucky", "016" = "Louisiana",
  "017" = "Maine", "018" = "Maryland", "019" = "Massachusetts", "020" = "Michigan",
  "021" = "Minnesota", "022" = "Mississippi", "023" = "Missouri", "024" = "Montana",
  "025" = "Nebraska", "026" = "Nevada", "027" = "New Hampshire", "028" = "New Jersey",
  "029" = "New Mexico", "030" = "New York", "031" = "North Carolina", "032" = "North Dakota",
  "033" = "Ohio", "034" = "Oklahoma", "035" = "Oregon", "036" = "Pennsylvania",
  "037" = "Rhode Island", "038" = "South Carolina", "039" = "South Dakota", "040" = "Tennessee",
  "041" = "Texas", "042" = "Utah", "043" = "Vermont", "044" = "Virginia",
  "045" = "Washington", "046" = "West Virginia", "047" = "Wisconsin", "048" = "Wyoming",
  "050" = "Alaska", "101" = "District of Columbia", "110" = "Hawaii"
)

# Files to process
climate_files <- list(
  temp    = "Data/Climate_Data/State level/climdiv-tmpcst-v1.0.0-20260107",
  precip  = "Data/Climate_Data/State level/climdiv-pcpnst-v1.0.0-20260107",
  pdsi    = "Data/Climate_Data/State level/climdiv-pdsist-v1.0.0-20260107",
  cdd     = "Data/Climate_Data/State level/climdiv-cddcst-v1.0.0-20260107",
  hdd     = "Data/Climate_Data/State level/climdiv-hddcst-v1.0.0-20260107"
)

# 2. Function to parse NOAA FWF -------------------------------------------
parse_noaa_file <- function(file_path, var_name) {
  cat("Processing:", var_name, "from", basename(file_path), "
")
  
  # NOAA FWF layout: 
  # State(1-3), Element(4-6), Year(7-10), Jan(11-17), Feb(18-24), ..., Dec(88-94)
  widths <- c(3, 3, 4, rep(7, 12))
  col_names <- c("StateCode", "Element", "Year", month.abb)
  
  df <- read.fwf(file_path, widths = widths, col.names = col_names, comment.char = "")
  
  # Convert State Code to Name
  df$State <- state_codes[sprintf("%03d", df$StateCode)]
  
  # Filter years and remove invalid states
  df <- df[!is.na(df$State) & df$Year >= 1996 & df$Year <= 2025, ]
  
  # Reshape to long to handle missing values and summing
  long_df <- reshape(df, 
                     varying = month.abb, 
                     v.names = "Value", 
                     timevar = "Month", 
                     times = month.abb, 
                     direction = "long")
  
  # Handle NOAA missing values (-9.99, -99.9, -99.99)
  long_df$Value[long_df$Value <= -9.9] <- NA
  
  # Aggregate by State and Year
  # 1. Sum of values
  # 2. Count of missing months
  agg <- aggregate(Value ~ State + Year, data = long_df, 
                   FUN = function(x) sum(x, na.rm = TRUE), 
                   na.action = na.pass)
  
  missing_counts <- aggregate(Value ~ State + Year, data = long_df, 
                              FUN = function(x) sum(is.na(x)), 
                              na.action = na.pass)
  
  names(agg)[3] <- paste0(var_name, "_sum")
  names(missing_counts)[3] <- paste0(var_name, "_missing_months")
  
  merge(agg, missing_counts, by = c("State", "Year"))
}

# 3. Execution ------------------------------------------------------------
processed_list <- list()

for (n in names(climate_files)) {
  processed_list[[n]] <- parse_noaa_file(climate_files[[n]], n)
}

# Combine all variables into one wide data frame
master_climate <- Reduce(function(x, y) merge(x, y, by = c("State", "Year"), all = TRUE), processed_list)

# Write output
output_path <- "Data/Climate_Data/state_climate_consolidated.csv"
write.csv(master_climate, output_path, row.names = FALSE)

cat("
Success! State-level climate data consolidated to:", output_path, "
")
cat("Observations:", nrow(master_climate), "
")
print(head(master_climate))
