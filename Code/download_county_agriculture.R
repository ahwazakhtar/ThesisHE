# Download county-level agricultural-dependence data for the mechanism track
# (mechanism_channels_20260625). Builds the STRUCTURAL agricultural-dependence
# moderator used to bound the reviewer's agricultural income channel.
#
# Sources (all verified reachable 2026-07-01):
#   1. USDA ERS County Typology Codes, 2015 edition (keyless CSV).
#      Carries the mutually-exclusive economic-dependence typology; a county is
#      "Farming-dependent" when farm earnings >= 25% of county earnings OR farm
#      employment >= 16% of employment, over 2010-2012.
#   2. BEA CAINC5N (Regional API, existing BEA_API_KEY):
#        LineCode 81 = Farm earnings (111-112)
#        LineCode 35 = Earnings by place of work (total)
#      -> Farm_Earnings_Share = 81 / 35, baseline-averaged 2001-2010 downstream.
#
# ACS ag-EMPLOYMENT share (a cross-check) is built from ACS C24030 in the sibling
# industry module (download_county_industry.R / process_county_industry.R), not here.
#
# Output raws -> Data/County_Agriculture/. Processed by process_county_agriculture.R.

library(jsonlite)
library(httr)
library(dplyr)

readRenviron("~/.Renviron")
dir.create("Data/County_Agriculture", showWarnings = FALSE, recursive = TRUE)

bea_key <- Sys.getenv("BEA_API_KEY")
if (nchar(bea_key) == 0) {
  stop("BEA_API_KEY not set. Register at https://apps.bea.gov/API/signup/ and add ",
       "BEA_API_KEY=your_key to ~/.Renviron, then restart R.")
}

# ---------------------------------------------------------------------------
# 1. USDA ERS County Typology Codes, 2015 edition (keyless static CSV)
# ---------------------------------------------------------------------------
cat("Downloading USDA ERS County Typology Codes (2015 edition)...\n")
usda_url  <- "https://www.ers.usda.gov/media/6176/ers-county-typology-codes-2015-edition.csv"
usda_dest <- "Data/County_Agriculture/ers_county_typology_2015.csv"
# ERS serves a cache-busting ?v= token but the bare path is stable; follow redirects.
resp_usda <- GET(usda_url, write_disk(usda_dest, overwrite = TRUE),
                 config(followlocation = TRUE))
if (http_error(resp_usda)) stop("USDA ERS download failed: HTTP ", status_code(resp_usda))
cat("  Saved:", usda_dest, "(", file.info(usda_dest)$size, "bytes )\n")

# ---------------------------------------------------------------------------
# 2. BEA CAINC5N -- Farm earnings (81) and Earnings by place of work (35)
# ---------------------------------------------------------------------------
fetch_bea_cainc5n <- function(line_code, label, api_key) {
  cat("Fetching BEA CAINC5N LineCode", line_code, "(", label, ", all counties/years)...\n")
  url <- paste0(
    "https://apps.bea.gov/api/data/?UserID=", api_key,
    "&method=GetData&datasetname=Regional&TableName=CAINC5N",
    "&LineCode=", line_code, "&GeoFips=COUNTY&Year=ALL&ResultFormat=json"
  )
  resp <- GET(url)
  if (http_error(resp)) stop("BEA API failed (LineCode ", line_code, "): HTTP ", status_code(resp))
  parsed <- fromJSON(content(resp, as = "text", encoding = "UTF-8"), simplifyDataFrame = TRUE)
  df <- parsed$BEAAPI$Results$Data
  if (is.null(df) || nrow(df) == 0) stop("No data returned from BEA CAINC5N LineCode ", line_code)
  df %>%
    select(GeoFips, GeoName, TimePeriod, DataValue) %>%
    rename(fips_code = GeoFips, geo_name = GeoName, Year = TimePeriod, value = DataValue) %>%
    mutate(line_code = line_code, series = label)
}

df_farm  <- fetch_bea_cainc5n(81, "farm_earnings",   bea_key)
df_total <- fetch_bea_cainc5n(35, "total_earnings",  bea_key)

df_bea <- bind_rows(df_farm, df_total)
write.csv(df_bea, "Data/County_Agriculture/bea_cainc5n_earnings_raw.csv", row.names = FALSE)
cat("  Saved: bea_cainc5n_earnings_raw.csv (", nrow(df_bea), "rows,",
    length(unique(df_bea$fips_code)), "geos )\n")

cat("\nDone. Raw agricultural data in Data/County_Agriculture/\n")
