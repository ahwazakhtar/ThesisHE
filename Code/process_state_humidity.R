# ---------------------------------------------------------------------------
# process_state_humidity.R
#
# Committee Feedback April 2026, Environmental #1: humidity integration.
# Aggregates the PRISM annual `tdmean` (mean dew point) 4km CONUS grids
# downloaded by `download_prism_humidity.R` to a STATE-YEAR panel via
# area-weighted zonal means, and writes `Data/intermediate_humidity.rds`.
#
# METHOD ---------------------------------------------------------------------
#   For each year, the 4km CONUS grid is read with terra and reduced to one
#   value per state by an AREA-WEIGHTED mean (terra::extract(..., weights=TRUE)),
#   the standard aggregation for a continuous climate field. (Population
#   weighting, used for AQI exposure, is not appropriate for a climate covariate
#   and would require a population raster; noted as possible future robustness.)
#
# UNITS ----------------------------------------------------------------------
#   PRISM distributes `tdmean` in degrees CELSIUS. We retain the native value as
#   `tdmean_C` and add `tdmean_F` (= C*9/5 + 32) for consistency with the rest of
#   the project, which expresses temperature in Fahrenheit (NOAA climdiv).
#
# COVERAGE -------------------------------------------------------------------
#   The PRISM web service `us` region is CONUS only. Alaska and Hawaii are NOT
#   served, so `tdmean` is NA for those states (and for Puerto Rico, which is not
#   in the analysis panel). All 48 contiguous states + DC are covered.
#
# STATE BOUNDARIES -----------------------------------------------------------
#   Uses the Census 2018 cartographic boundary file (cb_2018_us_state_20m),
#   downloaded once into Data/Geo/ if absent. The `NAME` field carries full
#   state names that match the `State` column of the analysis master.
#
# OUTPUT: Data/intermediate_humidity.rds  (State, Year, tdmean_C, tdmean_F)
# ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(terra))

if (!exists("%||%")) {
  `%||%` <- function(x, y) {
    if (is.null(x)) return(y)
    if (length(x) == 1 && is.atomic(x) && is.na(x)) return(y)
    x
  }
}

# Download (once) and load the Census cartographic state boundaries as a SpatVector.
load_state_boundaries <- function(geo_dir = "Data/Geo/cb_2018_us_state_20m",
                                   url = paste0("https://www2.census.gov/geo/tiger/",
                                                "GENZ2018/shp/cb_2018_us_state_20m.zip"),
                                   timeout = 300) {
  dir.create(geo_dir, showWarnings = FALSE, recursive = TRUE)
  shp <- file.path(geo_dir, "cb_2018_us_state_20m.shp")
  if (!file.exists(shp)) {
    z <- file.path(geo_dir, "cb_2018_us_state_20m.zip")
    old <- getOption("timeout"); options(timeout = timeout)
    on.exit(options(timeout = old), add = TRUE)
    download.file(url, destfile = z, mode = "wb", quiet = TRUE)
    utils::unzip(z, exdir = geo_dir)
  }
  terra::vect(shp)
}

# Area-weighted state means of one annual tdmean grid. Accepts either a path to
# a raster or an in-memory SpatRaster (note: rast() on a SpatRaster copies only
# geometry and drops values, so a SpatRaster is used as-is). Returns a
# data.frame with State, tdmean_C (NA for states outside CONUS coverage).
extract_state_tdmean <- function(bil_path, states_vect) {
  r <- if (inherits(bil_path, "SpatRaster")) bil_path else terra::rast(bil_path)
  sv <- terra::project(states_vect, terra::crs(r))
  ex <- terra::extract(r, sv, fun = mean, na.rm = TRUE, weights = TRUE, ID = TRUE)
  data.frame(State = sv$NAME, tdmean_C = ex[[2]], stringsAsFactors = FALSE)
}

run_process_state_humidity <- function(config = list()) {
  prism_dir  <- config$prism_dir %||% "Data/Climate_Data/State level/PRISM_tdmean"
  out_path   <- config$out_path %||% "Data/intermediate_humidity.rds"
  geo_dir    <- config$geo_dir %||% "Data/Geo/cb_2018_us_state_20m"
  # Non-panel territories to drop (not present in the analysis master).
  drop_states <- config$drop_states %||% c("Puerto Rico")

  # Discover years that have an unzipped grid.
  year_dirs <- list.dirs(prism_dir, recursive = FALSE)
  years <- suppressWarnings(as.integer(basename(year_dirs)))
  keep <- !is.na(years)
  year_dirs <- year_dirs[keep]; years <- years[keep]
  ord <- order(years); year_dirs <- year_dirs[ord]; years <- years[ord]
  if (length(years) == 0) {
    stop("No PRISM tdmean year directories found under ", prism_dir,
         "; run download_prism_humidity.R first.")
  }

  states_vect <- load_state_boundaries(geo_dir = geo_dir)

  panel_list <- vector("list", length(years))
  for (i in seq_along(years)) {
    yr  <- years[i]
    bil <- list.files(year_dirs[i], pattern = "\\.bil$",
                      full.names = TRUE, ignore.case = TRUE)[1]
    if (is.na(bil)) {
      warning("No .bil grid in ", year_dirs[i], "; skipping ", yr, call. = FALSE)
      next
    }
    df <- extract_state_tdmean(bil, states_vect)
    df$Year <- yr
    panel_list[[i]] <- df
    cat(sprintf("Aggregated %d: %d states with value\n",
                yr, sum(!is.na(df$tdmean_C))))
  }

  panel <- do.call(rbind, panel_list)
  panel <- panel[!panel$State %in% drop_states, , drop = FALSE]
  panel$tdmean_F <- panel$tdmean_C * 9/5 + 32
  panel <- panel[order(panel$State, panel$Year),
                 c("State", "Year", "tdmean_C", "tdmean_F")]
  rownames(panel) <- NULL

  saveRDS(panel, out_path)
  cat(sprintf("\nSaved %d state-year humidity rows (%d-%d) to %s\n",
              nrow(panel), min(panel$Year), max(panel$Year), out_path))
  cat(sprintf("States with NA tdmean (no CONUS coverage): %s\n",
              paste(sort(unique(panel$State[is.na(panel$tdmean_C)])), collapse = ", ")))

  invisible(panel)
}

if (sys.nframe() == 0) {
  run_process_state_humidity()
}
