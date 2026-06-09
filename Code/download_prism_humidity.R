# ---------------------------------------------------------------------------
# download_prism_humidity.R
#
# Committee Feedback April 2026, Environmental #1: humidity integration.
# Acquires PRISM `tdmean` (mean dew point) annual grids for the conterminous
# United States (CONUS) from the PRISM web service, to be aggregated to the
# state level in `process_state_humidity.R`.
#
# ACCESS PATTERN -------------------------------------------------------------
#   * The PRISM web service is OPEN: no API key, login, or token is required.
#   * It serves ONE GRID PER REQUEST as a zipped raster package. We request the
#     annual 4km CONUS grid in BIL format:
#
#       https://services.nacse.org/prism/data/get/us/4km/tdmean/<YYYY>?format=bil
#
#     <region> = us  -> CONUS (the 48 contiguous states). Alaska, Hawaii, and
#                       Puerto Rico are NOT served by this web service yet, so
#                       `tdmean` is unavailable for AK and HI (left NA downstream).
#     <res>    = 4km (the resolution we aggregate to states; 800m also exists).
#     <date>   = YYYY -> a single annual grid (PRISM annual data: 1895-present).
#
#   Reference: https://prism.oregonstate.edu/documents/PRISM_downloads_web_service.pdf
#
# DOWNLOAD LIMITS ------------------------------------------------------------
#   PRISM blocks a file that is downloaded twice within a 24-hour window, and
#   repeated abuse can lead to IP blocking. This script therefore SKIPS any
#   year whose grid package already exists on disk, and sleeps between requests.
#   Re-run with `overwrite = TRUE` only when you intend to refresh a grid.
#
# MANUAL FALLBACK ------------------------------------------------------------
#   If the web service is unreachable, the same annual grids can be downloaded
#   by hand from https://prism.oregonstate.edu/recent/ (choose tdmean, Annual,
#   4km, BIL). Place each `PRISM_tdmean_*_<YYYY>_bil.zip` in the directory
#   `Data/Climate_Data/State level/PRISM_tdmean/` and re-run; existing files are
#   skipped and unzipped in place.
#
# OUTPUT ---------------------------------------------------------------------
#   Data/Climate_Data/State level/PRISM_tdmean/<YYYY>/   (unzipped grid package)
#   containing PRISM_tdmean_*_<YYYY>_bil.bil (+ .hdr/.prj/.xml ancillary files).
# ---------------------------------------------------------------------------

if (!exists("%||%")) {
  `%||%` <- function(x, y) {
    if (is.null(x)) return(y)
    if (length(x) == 1 && is.atomic(x) && is.na(x)) return(y)
    x
  }
}

run_download_prism_humidity <- function(config = list()) {
  base_url   <- config$base_url %||% "https://services.nacse.org/prism/data/get/us/4km/tdmean"
  element    <- config$element %||% "tdmean"
  # Analysis window (2011+) plus two years of lag headroom. Humidity is a raw
  # control (dew point, deg F), not z-scored, so no 1990-2000 baseline is needed.
  years      <- config$years %||% 2009:2025
  out_dir    <- config$out_dir %||% "Data/Climate_Data/State level/PRISM_tdmean"
  overwrite  <- isTRUE(config$overwrite)
  sleep_secs <- config$sleep_secs %||% 2     # be courteous to the PRISM server
  timeout    <- config$timeout %||% 300

  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  old_timeout <- getOption("timeout")
  options(timeout = timeout)
  on.exit(options(timeout = old_timeout), add = TRUE)

  downloaded <- character(0)
  skipped    <- character(0)
  failed     <- integer(0)

  for (yr in years) {
    year_dir <- file.path(out_dir, as.character(yr))
    # A successfully unzipped year always yields a .bil raster. PRISM names the
    # unzipped 4km grid `prism_tdmean_us_25m_<YYYY>.bil` ("25m" is PRISM's token
    # for the 4km resolution), so match on the .bil extension, not "_bil.bil".
    existing_bil <- list.files(year_dir, pattern = "\\.bil$",
                               full.names = TRUE, ignore.case = TRUE)

    if (length(existing_bil) > 0 && !overwrite) {
      skipped <- c(skipped, year_dir)
      cat("Skipping existing:", yr, "\n")
      next
    }

    dir.create(year_dir, showWarnings = FALSE, recursive = TRUE)
    zip_path <- file.path(year_dir, sprintf("prism_%s_us_4km_%d_bil.zip", element, yr))
    url <- sprintf("%s/%d?format=bil", base_url, yr)

    ok <- tryCatch({
      download.file(url, destfile = zip_path, mode = "wb", quiet = TRUE)
      # PRISM returns an HTML error page (small) when a grid is unavailable or
      # rate-limited; a real grid package is hundreds of KB. Guard on size.
      if (file.exists(zip_path) && file.info(zip_path)$size < 10000) {
        stop("response too small (", file.info(zip_path)$size,
             " bytes) - likely rate-limited or grid unavailable")
      }
      utils::unzip(zip_path, exdir = year_dir)
      TRUE
    }, error = function(e) {
      warning("Failed download for ", yr, ": ", conditionMessage(e), call. = FALSE)
      FALSE
    })

    if (ok) {
      downloaded <- c(downloaded, year_dir)
      cat("Downloaded + unzipped:", yr, "\n")
    } else {
      failed <- c(failed, yr)
    }

    if (sleep_secs > 0 && yr != years[length(years)]) Sys.sleep(sleep_secs)
  }

  cat(sprintf("\nPRISM tdmean: %d downloaded, %d skipped, %d failed.\n",
              length(downloaded), length(skipped), length(failed)))
  if (length(failed) > 0) cat("Failed years:", paste(failed, collapse = ", "), "\n")

  invisible(list(
    out_dir    = out_dir,
    years      = years,
    downloaded = downloaded,
    skipped    = skipped,
    failed     = failed
  ))
}

if (sys.nframe() == 0) {
  run_download_prism_humidity()
}
