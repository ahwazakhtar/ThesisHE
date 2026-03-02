# R script to download NOAA climate data used by state and county pipelines.

if (!exists("%||%")) {
  `%||%` <- function(x, y) {
    if (is.null(x)) return(y)
    if (length(x) == 1 && is.atomic(x) && is.na(x)) return(y)
    x
  }
}

run_download_climate_data <- function(config = list()) {
  base_url <- config$base_url %||% "https://www.ncei.noaa.gov/pub/data/cirs/climdiv/"
  file_names <- config$file_names %||% c(
    "climdiv-tmpccy-v1.0.0-20260107",
    "climdiv-tmincy-v1.0.0-20260107",
    "climdiv-hddccy-v1.0.0-20260107",
    "climdiv-cddccy-v1.0.0-20260107",
    "climdiv-tmaxcy-v1.0.0-20260107",
    "climdiv-pcpncy-v1.0.0-20260107",
    "climdiv-tmpcst-v1.0.0-20260107",
    "climdiv-tminst-v1.0.0-20260107",
    "climdiv-hddcst-v1.0.0-20260107",
    "climdiv-cddcst-v1.0.0-20260107",
    "climdiv-tmaxst-v1.0.0-20260107",
    "climdiv-pcpnst-v1.0.0-20260107",
    "climdiv-pdsist-v1.0.0-20260107",
    "climdiv-phdist-v1.0.0-20260107",
    "climdiv-pmdist-v1.0.0-20260107",
    "climdiv-zndxst-v1.0.0-20260107",
    "climdiv-norm-tmaxst-v1.0.0-20260107"
  )

  climate_root <- config$climate_root %||% "Data/Climate_Data"
  state_dir <- config$state_dir %||% file.path(climate_root, "State level")
  county_dir <- config$county_dir %||% file.path(climate_root, "County level")
  overwrite <- isTRUE(config$overwrite)

  dir.create(state_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(county_dir, showWarnings = FALSE, recursive = TRUE)

  downloaded <- character(0)
  skipped <- character(0)
  failed <- character(0)

  for (file_name in file_names) {
    is_county <- grepl("cy-v", file_name) || grepl("ccy", file_name)
    target_dir <- if (is_county) county_dir else state_dir
    dest_path <- file.path(target_dir, file_name)

    if (file.exists(dest_path) && !overwrite) {
      skipped <- c(skipped, dest_path)
      cat("Skipping existing:", basename(dest_path), "\n")
      next
    }

    url <- paste0(base_url, file_name)
    ok <- tryCatch({
      download.file(url, destfile = dest_path, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) {
      warning("Failed download for ", file_name, ": ", conditionMessage(e), call. = FALSE)
      FALSE
    })

    if (ok) {
      downloaded <- c(downloaded, dest_path)
      cat("Downloaded:", basename(dest_path), "\n")
    } else {
      failed <- c(failed, file_name)
    }
  }

  list(
    outputs = downloaded,
    downloaded = length(downloaded),
    skipped = length(skipped),
    failed = failed
  )
}

if (sys.nframe() == 0) {
  run_download_climate_data()
}
