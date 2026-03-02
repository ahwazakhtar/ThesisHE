library(testthat)

detect_repo_root <- function() {
  candidates <- c(".", "..", "../..")
  for (candidate in candidates) {
    if (dir.exists(file.path(candidate, "Code")) && dir.exists(file.path(candidate, "Data"))) {
      return(candidate)
    }
  }
  "."
}

repo_root <- detect_repo_root()
repo_file <- function(...) file.path(repo_root, ...)

script_path <- repo_file("Code", "process_rating_area_map.R")
if (!file.exists(script_path)) {
  stop("Could not locate Code/process_rating_area_map.R from current working directory")
}

old_skip <- Sys.getenv("PROCESS_RATING_AREA_MAP_SKIP_MAIN", unset = NA)
Sys.setenv(PROCESS_RATING_AREA_MAP_SKIP_MAIN = "1")
source(script_path)
if (is.na(old_skip)) {
  Sys.unsetenv("PROCESS_RATING_AREA_MAP_SKIP_MAIN")
} else {
  Sys.setenv(PROCESS_RATING_AREA_MAP_SKIP_MAIN = old_skip)
}

test_that("normalize_rating_area_id handles mixed area formats", {
  normalized <- normalize_rating_area_id(
    st = c("CA", "TX", "NY", "WA"),
    area = c("Rating Area 1", "TX7", "ny03", " WA2 ")
  )

  expect_equal(normalized, c("CA01", "TX07", "NY03", "WA02"))
})

test_that("process_year maps 2025 source data with bronze-level coverage", {
  zip_path <- repo_file("Data", "HIX_Data", "plan details", "2025.zip")
  skip_if_not(file.exists(zip_path), "Missing 2025 HIX plan zip")

  crosswalk_files <- list.files(
    repo_file("Data", "HIX_Data", "crosswalk"),
    pattern = "individual_county_rating_area_crosswalk_2025_.*\\.csv$",
    full.names = TRUE
  )
  skip_if(length(crosswalk_files) == 0, "Missing 2025 rating area crosswalk")

  proc_env <- environment(process_year)
  old_crosswalk_dir <- get("crosswalk_dir", envir = proc_env)
  assign("crosswalk_dir", repo_file("Data", "HIX_Data", "crosswalk"), envir = proc_env)
  on.exit(assign("crosswalk_dir", old_crosswalk_dir, envir = proc_env), add = TRUE)

  result <- process_year(zip_path)

  expect_s3_class(result, "data.frame")
  expect_true(all(c(
    "fips_code", "Year", "Benchmark_Silver",
    "Lowest_Bronze", "State", "rating_area_id"
  ) %in% names(result)))
  expect_equal(unique(result$Year), 2025)

  crosswalk <- read.csv(crosswalk_files[1], stringsAsFactors = FALSE)
  if ("FIPS.Code" %in% names(crosswalk)) {
    crosswalk$fips_code <- crosswalk$FIPS.Code
  }
  if ("Rating.Area.ID" %in% names(crosswalk)) {
    crosswalk$rating_area_id <- crosswalk$Rating.Area.ID
  }
  expect_true(all(c("fips_code", "rating_area_id") %in% names(crosswalk)))

  crosswalk$fips_code <- sprintf("%05d", as.numeric(crosswalk$fips_code))
  crosswalk$rating_area_id <- as.character(crosswalk$rating_area_id)
  expected_rows <- nrow(unique(crosswalk[, c("fips_code", "rating_area_id")]))

  expect_equal(nrow(result), expected_rows)

  file_list <- unzip(zip_path, list = TRUE)
  target_file <- file_list$Name[grepl("plans\\.csv|Rate\\.csv", file_list$Name, ignore.case = TRUE)][1]
  plan_df <- read.csv(unz(zip_path, target_file), stringsAsFactors = FALSE)
  expect_true("METAL" %in% names(plan_df))

  has_expanded_bronze <- any(grepl(
    "^expanded[ _]bronze$",
    tolower(trimws(as.character(plan_df$METAL)))
  ))
  expect_true(has_expanded_bronze)

  # Bronze missingness should not exceed silver missingness after normalization.
  expect_equal(
    sum(is.na(result$Lowest_Bronze)),
    sum(is.na(result$Benchmark_Silver))
  )
})
