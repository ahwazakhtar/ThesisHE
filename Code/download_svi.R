# ---------------------------------------------------------------------------
# download_svi.R  (Climate–Health Exposure Index — Phase 1)
#
# Acquires CDC/ATSDR Social Vulnerability Index (SVI) county CSVs — the
# structural-vulnerability layer for the exposure index.
#
# ACCESS: open / keyless. County files live at
#   https://svi.cdc.gov/Documents/Data/<YYYY>/csv/states_counties/<file>.csv
# ATSDR changed the file-naming casing across vintages (e.g. SVI_2020_US_county.csv
# vs SVI2018_US_COUNTY.csv), so we try a few candidate names per year and keep the
# first that returns HTTP 200. Missing values in SVI are coded as -999.
#
# Vintages 2014/2016/2018/2020/2022 cover the 2011-2023 analysis panel.
#
# OUTPUT: Data/SVI_Data/SVI_<YYYY>_US_county.csv  (one normalized file per vintage)
# ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(httr) })

if (!exists("%||%")) {
  `%||%` <- function(x, y) if (is.null(x) || (length(x) == 1 && is.na(x))) y else x
}

svi_url_candidates <- function(year) {
  base <- paste0("https://svi.cdc.gov/Documents/Data/", year, "/csv/states_counties/")
  paste0(base, c(
    paste0("SVI_", year, "_US_county.csv"),
    paste0("SVI", year, "_US_county.csv"),
    paste0("SVI", year, "_US_COUNTY.csv")
  ))
}

run_download_svi <- function(config = list()) {
  years     <- config$years %||% c(2014, 2016, 2018, 2020, 2022)
  out_dir   <- config$out_dir %||% "Data/SVI_Data"
  overwrite <- isTRUE(config$overwrite)
  timeout   <- config$timeout %||% 180

  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  old <- getOption("timeout"); options(timeout = timeout); on.exit(options(timeout = old), add = TRUE)

  downloaded <- character(0); skipped <- character(0); failed <- integer(0)

  for (yr in years) {
    dest <- file.path(out_dir, sprintf("SVI_%d_US_county.csv", yr))
    if (file.exists(dest) && !overwrite) {
      skipped <- c(skipped, dest); cat("Skipping existing:", yr, "\n"); next
    }
    ok <- FALSE
    for (u in svi_url_candidates(yr)) {
      got <- tryCatch({
        r <- GET(u, write_disk(dest, overwrite = TRUE), timeout(timeout))
        if (status_code(r) == 200 && file.exists(dest) && file.info(dest)$size > 50000) {
          cat("Downloaded:", yr, "<-", basename(u), "\n"); TRUE
        } else { if (file.exists(dest)) file.remove(dest); FALSE }
      }, error = function(e) { if (file.exists(dest)) file.remove(dest); FALSE })
      if (got) { ok <- TRUE; break }
    }
    if (ok) downloaded <- c(downloaded, dest) else { failed <- c(failed, yr); warning("All SVI URLs failed for ", yr) }
  }

  cat(sprintf("\nSVI: %d downloaded, %d skipped, %d failed.\n",
              length(downloaded), length(skipped), length(failed)))
  if (length(failed) > 0) cat("Failed years:", paste(failed, collapse = ", "), "\n")
  invisible(list(out_dir = out_dir, years = years,
                 downloaded = downloaded, skipped = skipped, failed = failed))
}

if (sys.nframe() == 0) run_download_svi()
