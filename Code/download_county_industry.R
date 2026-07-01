# Download county industry-of-employment composition (ACS C24030) for the
# mechanism track (mechanism_channels_20260625, Phase 1).
#
# PURPOSE -------------------------------------------------------------------
# The labor-productivity / labor-supply channel (Graff Zivin & Neidell 2014;
# Somanathan et al. 2021; the Deryugina & Hsiang 2014 weekday-only US income dip)
# operates across ALL climate-exposed industries -- construction, mining,
# manufacturing, transportation & utilities -- not agriculture alone. To show a
# climate effect is NOT purely agricultural we need each county's share of
# employment in climate-exposed NON-FARM industries, separate from its farm share.
# ACS table C24030 ("Sex by Industry for the Civilian Employed Population 16+")
# provides exactly this.
#
# SOURCE --------------------------------------------------------------------
#   Census ACS 5-year, table C24030 (existing CENSUS_API_KEY).
#   County 5-year estimates available 2011+ (we pull 2011-2023).
#
# C24030 STRUCTURE (verified live 2026-07-01) -------------------------------
#   Estimates are split Male (lines 003-027) and Female (lines 029-053); we sum the
#   two sexes per industry. Line numbers used (E-suffixed estimate variables):
#     _001  Total civilian employed 16+
#     Agriculture, forestry, fishing & hunting:        male _004,  female _030
#     Mining, quarrying, oil & gas extraction:         male _005,  female _031
#     Construction:                                    male _006,  female _032
#     Manufacturing:                                   male _007,  female _033
#     Transportation & warehousing:                    male _011,  female _037
#     Utilities:                                       male _012,  female _038
#   NOTE C24030 nests ag+mining under a combined header (_003/_029); we deliberately
#   take the DISAGGREGATED children (_004/_005) so agriculture is cleanly separable
#   from mining. Likewise transport (_011) and utilities (_012) are the children of
#   the combined "Transportation, warehousing & utilities" header (_010/_036).
#
# GOTCHA: ACS variable names REQUIRE the trailing "E" (estimate). Plain codes 400.
#
# OUTPUT: Data/County_Industry/acs_c24030_raw.csv  (long-ish; processed downstream)

library(jsonlite)
library(httr)
library(dplyr)

readRenviron("~/.Renviron")
dir.create("Data/County_Industry", showWarnings = FALSE, recursive = TRUE)

census_key <- Sys.getenv("CENSUS_API_KEY")
if (nchar(census_key) == 0) {
  stop("CENSUS_API_KEY not set. Register at https://api.census.gov/data/key_signup.html ",
       "and add CENSUS_API_KEY=your_key to ~/.Renviron, then restart R.")
}

# Variables to request (total + 6 industries x 2 sexes). E-suffix mandatory.
c24030_vars <- c(
  "C24030_001E",                       # total
  "C24030_004E", "C24030_030E",        # agriculture/forestry/fishing/hunting
  "C24030_005E", "C24030_031E",        # mining
  "C24030_006E", "C24030_032E",        # construction
  "C24030_007E", "C24030_033E",        # manufacturing
  "C24030_011E", "C24030_037E",        # transportation & warehousing
  "C24030_012E", "C24030_038E"         # utilities
)
acs_years <- 2011:2023

fetch_c24030_year <- function(year, api_key) {
  url <- paste0(
    "https://api.census.gov/data/", year, "/acs/acs5",
    "?get=NAME,", paste(c24030_vars, collapse = ","),
    "&for=county:*&in=state:*",
    "&key=", api_key
  )
  resp <- GET(url)
  if (http_error(resp)) {
    warning("C24030 request failed for year ", year, ": HTTP ", status_code(resp))
    return(NULL)
  }
  raw <- fromJSON(content(resp, as = "text", encoding = "UTF-8"), simplifyDataFrame = TRUE)
  df  <- as.data.frame(raw[-1, , drop = FALSE], stringsAsFactors = FALSE)
  names(df) <- raw[1, ]
  df$Year <- year
  df
}

cat("Fetching ACS 5-year C24030 (industry of employment) 2011-2023...\n")
acs_list <- lapply(acs_years, function(yr) { cat("  Year:", yr, "\n"); fetch_c24030_year(yr, census_key) })

df_ind <- bind_rows(Filter(Negate(is.null), acs_list)) %>%
  mutate(fips_code = paste0(state, county))

write.csv(df_ind, "Data/County_Industry/acs_c24030_raw.csv", row.names = FALSE)
cat("  Saved: acs_c24030_raw.csv (", nrow(df_ind), "rows,",
    length(unique(df_ind$fips_code)), "counties )\n")
cat("\nDone. Raw industry data in Data/County_Industry/\n")
