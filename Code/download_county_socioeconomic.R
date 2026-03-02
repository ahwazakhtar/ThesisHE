# Download county-level socioeconomic data for integration into the county panel.
#
# Sources:
#   1. BEA CAINC1  -- Per Capita Personal Income by county (annual, 2001-2023)
#   2. Census ACS 5-year -- Median Household Income (B19013_001E) and
#                           Civilian Employed count (B23025_004E), 2009+
#
# Note: BEA CAEMP25N county employment is not accessible via the BEA Regional
# API. ACS B23025_004E (civilian employed 16+) is used as the employment proxy.
#
# API keys required:
#   BEA_API_KEY  : Register free at https://apps.bea.gov/API/signup/
#   CENSUS_API_KEY: Register free at https://api.census.gov/data/key_signup.html
#
# Set keys in ~/.Renviron:
#   BEA_API_KEY=your_key_here
#   CENSUS_API_KEY=your_key_here

library(jsonlite)
library(httr)
library(dplyr)

readRenviron("~/.Renviron")
dir.create("Data/County_Socioeconomic", showWarnings = FALSE)

bea_key    <- Sys.getenv("BEA_API_KEY")
census_key <- Sys.getenv("CENSUS_API_KEY")

if (nchar(bea_key) == 0) {
  stop("BEA_API_KEY not set. Register at https://apps.bea.gov/API/signup/ ",
       "and add BEA_API_KEY=your_key to ~/.Renviron, then restart R.")
}
if (nchar(census_key) == 0) {
  stop("CENSUS_API_KEY not set. Register at https://api.census.gov/data/key_signup.html ",
       "and add CENSUS_API_KEY=your_key to ~/.Renviron, then restart R.")
}

# ---------------------------------------------------------------------------
# 1. BEA CAINC1 -- Per Capita Personal Income (all counties, all years)
# ---------------------------------------------------------------------------
cat("Fetching BEA CAINC1 (per capita personal income, all years)...\n")
bea_url <- paste0(
  "https://apps.bea.gov/api/data/?",
  "UserID=", bea_key,
  "&method=GetData&datasetname=Regional&TableName=CAINC1&LineCode=3",
  "&GeoFips=COUNTY&Year=ALL&ResultFormat=json"
)
resp_bea <- GET(bea_url)
if (http_error(resp_bea)) stop("BEA API failed: HTTP ", status_code(resp_bea))

parsed_bea <- fromJSON(content(resp_bea, as = "text", encoding = "UTF-8"), simplifyDataFrame = TRUE)
df_pcpi    <- parsed_bea$BEAAPI$Results$Data

if (is.null(df_pcpi) || nrow(df_pcpi) == 0) stop("No data returned from BEA CAINC1.")

df_pcpi <- df_pcpi %>%
  select(GeoFips, GeoName, TimePeriod, DataValue, NoteRef) %>%
  rename(fips_code = GeoFips, geo_name = GeoName, Year = TimePeriod, value = DataValue)

write.csv(df_pcpi, "Data/County_Socioeconomic/bea_cainc1_pcpi_raw.csv", row.names = FALSE)
cat("  Saved: bea_cainc1_pcpi_raw.csv (", nrow(df_pcpi), "rows)\n")

# ---------------------------------------------------------------------------
# 2. Census ACS 5-year -- Median HH Income + Civilian Employed (2009-2023)
#
# Variable names require the 'E' suffix (estimate) in the ACS API:
#   B19013_001E = Median household income (inflation-adjusted dollars)
#   B23025_004E = Civilian employed population 16+
# ---------------------------------------------------------------------------
acs_years <- 2009:2023

fetch_acs_year <- function(year, api_key) {
  url <- paste0(
    "https://api.census.gov/data/", year, "/acs/acs5",
    "?get=NAME,B19013_001E,B23025_004E",
    "&for=county:*&in=state:*",
    "&key=", api_key
  )
  resp <- GET(url)
  if (http_error(resp)) {
    warning("ACS request failed for year ", year, ": HTTP ", status_code(resp))
    return(NULL)
  }
  raw <- fromJSON(content(resp, as = "text", encoding = "UTF-8"), simplifyDataFrame = TRUE)
  df  <- as.data.frame(raw[-1, , drop = FALSE], stringsAsFactors = FALSE)
  names(df) <- raw[1, ]
  df$Year <- year
  df
}

cat("\nFetching ACS 5-year (Median HH Income + Employed) 2009-2023...\n")
acs_list <- lapply(acs_years, function(yr) {
  cat("  Year:", yr, "\n")
  fetch_acs_year(yr, census_key)
})

df_acs <- bind_rows(Filter(Negate(is.null), acs_list)) %>%
  mutate(
    fips_code         = paste0(state, county),
    med_hh_income_acs = suppressWarnings(as.numeric(B19013_001E)),
    civilian_employed = suppressWarnings(as.numeric(B23025_004E))
  ) %>%
  select(fips_code, Year, med_hh_income_acs, civilian_employed, NAME)

write.csv(df_acs, "Data/County_Socioeconomic/acs_socioeconomic_raw.csv", row.names = FALSE)
cat("  Saved: acs_socioeconomic_raw.csv (", nrow(df_acs), "rows)\n")

cat("\nDone. Raw socioeconomic data in Data/County_Socioeconomic/\n")
