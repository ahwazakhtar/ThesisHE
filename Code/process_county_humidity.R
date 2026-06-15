# ---------------------------------------------------------------------------
# process_county_humidity.R  (Cross-Level Symmetry — humidity at county level)
#
# County mirror of process_state_humidity.R: aggregates the PRISM annual tdmean
# 4km CONUS grids to a COUNTY-year panel by area-weighted zonal mean over the
# Census 2018 cartographic county boundaries (terra). Same units handling
# (PRISM Celsius -> tdmean_F). CONUS-only, so AK/HI/PR counties are NA.
#
# OUTPUT: Data/intermediate_humidity_county.rds (fips_code, Year, tdmean_C, tdmean_F)
# ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(terra))

if (!exists("%||%")) `%||%` <- function(x, y) if (is.null(x) || (length(x)==1 && is.na(x))) y else x

run_process_county_humidity <- function(config = list()) {
  prism_dir <- config$prism_dir %||% "Data/Climate_Data/State level/PRISM_tdmean"
  geo_shp   <- config$geo_shp %||% "Data/Geo/cb_2018_us_county_20m/cb_2018_us_county_20m.shp"
  out_path  <- config$out_path %||% "Data/intermediate_humidity_county.rds"
  years     <- config$years %||% 2009:2023   # county panel 2011-2023 + lag headroom

  counties <- terra::vect(geo_shp)

  panel_list <- list()
  for (yr in years) {
    bil <- list.files(file.path(prism_dir, as.character(yr)), pattern = "\\.bil$",
                      full.names = TRUE, ignore.case = TRUE)[1]
    if (is.na(bil)) { warning("No grid for ", yr); next }
    r  <- terra::rast(bil)
    cv <- terra::project(counties, terra::crs(r))
    ex <- terra::extract(r, cv, fun = mean, na.rm = TRUE, weights = TRUE, ID = TRUE)
    df <- data.frame(fips_code = cv$GEOID, tdmean_C = ex[[2]], Year = yr,
                     stringsAsFactors = FALSE)
    panel_list[[as.character(yr)]] <- df
    cat(sprintf("Aggregated %d: %d counties with value\n", yr, sum(!is.na(df$tdmean_C))))
  }

  panel <- do.call(rbind, panel_list)
  panel$tdmean_F <- panel$tdmean_C * 9/5 + 32
  panel <- panel[order(panel$fips_code, panel$Year),
                 c("fips_code", "Year", "tdmean_C", "tdmean_F")]
  rownames(panel) <- NULL
  saveRDS(panel, out_path)
  cat(sprintf("\nSaved %d county-year humidity rows (%d-%d, %d counties) to %s\n",
              nrow(panel), min(panel$Year), max(panel$Year),
              length(unique(panel$fips_code)), out_path))
  invisible(panel)
}

if (sys.nframe() == 0) run_process_county_humidity()
