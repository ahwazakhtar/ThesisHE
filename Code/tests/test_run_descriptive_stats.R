library(testthat)

options(descriptive_stats.test_mode = TRUE)
descriptive_script <- if (file.exists("Code/run_descriptive_stats.R")) {
  "Code/run_descriptive_stats.R"
} else {
  "../run_descriptive_stats.R"
}
source(descriptive_script, local = TRUE)
options(descriptive_stats.test_mode = FALSE)

make_mock_county_panel <- function(path) {
  df <- data.frame(
    fips_code = rep(c("01001", "48001"), each = 4),
    Year = rep(c(2011L, 2012L, 2018L, 2019L), times = 2),
    State = rep(c("AL", "TX"), each = 4),
    Population = c(55000, 55200, 56000, 56300, 200000, 201500, 210000, 212000),
    Z_Temp = c(0.1, 0.2, 1.0, 1.1, 0.3, 0.4, 1.2, 1.3),
    Z_Precip = c(0.0, -0.1, 0.2, 0.1, 0.3, 0.2, 0.4, 0.5),
    High_CDD = c(0, 0, 1, 1, 0, 1, 1, 1),
    High_HDD = c(1, 1, 0, 0, 1, 0, 0, 0),
    pdsi_val = c(-1.5, -0.8, -2.1, -1.7, -1.0, -0.5, -2.6, -2.4),
    Is_Extreme_Drought = c(0, 0, 1, 1, 0, 0, 1, 1),
    AQI_Shock = c(0.1, 0.2, 0.5, 0.6, -0.2, -0.1, 0.3, 0.4),
    Medical_Debt_Share = c(0.22, 0.21, 0.17, 0.16, 0.20, 0.19, 0.15, 0.14),
    Medical_Debt_Median_2023 = c(1000, 980, 920, 900, 1100, 1080, 940, 920),
    Benchmark_Silver_Real = c(280, 285, 370, 380, 290, 295, 390, 400),
    Lowest_Bronze_Real = c(220, 225, 290, 295, 230, 235, 300, 305),
    Hosp_BadDebt_Total_Real = c(2000000, 2100000, 2400000, 2500000, 8000000, 8200000, 8800000, 9000000),
    Hosp_Charity_Total_Real = c(1500000, 1600000, 2000000, 2100000, 5000000, 5100000, 6200000, 6300000),
    Uninsured_Rate = c(0.15, 0.14, 0.10, 0.09, 0.13, 0.12, 0.09, 0.08),
    PCPI_Real = c(45000, 46000, 56000, 57000, 47000, 48000, 59000, 60000),
    Med_HH_Income_Real = c(52000, 53000, 64000, 65000, 54000, 55000, 67000, 68000),
    Civilian_Employed = c(24000, 24500, 26000, 26500, 85000, 86000, 92000, 93000),
    Household_Income_2023 = c(70000, 70500, 76000, 76500, 73000, 73500, 79000, 79500),
    stringsAsFactors = FALSE
  )
  write.csv(df, path, row.names = FALSE)
}

test_that("run_descriptive_stats creates publication outputs", {
  tmp <- tempdir()
  input_path <- file.path(tmp, "county_master_mock.csv")
  output_dir <- file.path(tmp, "analysis")
  plot_dir <- file.path(output_dir, "plots")

  make_mock_county_panel(input_path)
  run_descriptive_stats(input_path = input_path, output_dir = output_dir, plot_dir = plot_dir)

  expect_true(file.exists(file.path(output_dir, "descriptive_stats_summary.csv")))
  expect_true(file.exists(file.path(output_dir, "descriptive_stats_table_main.csv")))
  expect_true(file.exists(file.path(output_dir, "descriptive_stats_table_main.tex")))
  expect_true(file.exists(file.path(output_dir, "descriptive_period_comparison.csv")))
  expect_true(file.exists(file.path(output_dir, "descriptive_period_comparison.tex")))
  expect_true(file.exists(file.path(output_dir, "descriptive_tables.tex")))
  expect_true(file.exists(file.path(output_dir, "descriptive_missingness_by_year.csv")))
  expect_true(file.exists(file.path(output_dir, "descriptive_correlation_matrix.csv")))
  expect_true(file.exists(file.path(output_dir, "descriptive_stats_report.md")))

  tex_main <- readLines(file.path(output_dir, "descriptive_stats_table_main.tex"), warn = FALSE)
  tex_doc <- readLines(file.path(output_dir, "descriptive_tables.tex"), warn = FALSE)
  expect_true(any(grepl("\\\\begin\\{tabular\\}", tex_main)))
  expect_true(any(grepl("\\\\documentclass\\[11pt\\]\\{article\\}", tex_doc)))

  expect_true(file.exists(file.path(plot_dir, "fig1_climate_shock_prevalence.png")))
  expect_true(file.exists(file.path(plot_dir, "fig2_outcome_index_trends.png")))
  expect_true(file.exists(file.path(plot_dir, "fig3_distribution_shift.png")))
})

test_that("period comparison captures rising premium levels in mock data", {
  tmp <- tempdir()
  input_path <- file.path(tmp, "county_master_mock_2.csv")
  output_dir <- file.path(tmp, "analysis_2")
  plot_dir <- file.path(output_dir, "plots")

  make_mock_county_panel(input_path)
  run_descriptive_stats(input_path = input_path, output_dir = output_dir, plot_dir = plot_dir)

  period <- read.csv(file.path(output_dir, "descriptive_period_comparison.csv"), stringsAsFactors = FALSE)
  row <- period[period$Raw_Variable == "Benchmark_Silver_Real", ]

  expect_equal(nrow(row), 1)
  expect_true(row$Diff_Late_minus_Early > 0)
  expect_true(row$W_Diff_Late_minus_Early > 0)
})

test_that("summary table includes weighted moments when population is available", {
  tmp <- tempdir()
  input_path <- file.path(tmp, "county_master_mock_3.csv")
  output_dir <- file.path(tmp, "analysis_3")
  plot_dir <- file.path(output_dir, "plots")

  make_mock_county_panel(input_path)
  run_descriptive_stats(input_path = input_path, output_dir = output_dir, plot_dir = plot_dir)

  stats <- read.csv(file.path(output_dir, "descriptive_stats_summary.csv"), stringsAsFactors = FALSE)
  z_temp_row <- stats[stats$Raw_Variable == "Z_Temp", ]

  expect_equal(nrow(z_temp_row), 1)
  expect_false(is.na(z_temp_row$W_Mean))
  expect_false(is.na(z_temp_row$W_SD))
})

test_that("debt exclusion rule removes flagged state-year windows from debt variables", {
  tmp <- tempdir()
  input_path <- file.path(tmp, "county_master_mock_4.csv")
  output_dir <- file.path(tmp, "analysis_4")
  plot_dir <- file.path(output_dir, "plots")

  make_mock_county_panel(input_path)
  run_descriptive_stats(
    input_path = input_path,
    output_dir = output_dir,
    plot_dir = plot_dir,
    debt_reporting_policy = data.frame(
      State = c("AL", "TX"),
      Start_Year = c(2011L, 2011L),
      End_Year = c(2019L, 2019L),
      stringsAsFactors = FALSE
    )
  )

  stats <- read.csv(file.path(output_dir, "descriptive_stats_summary.csv"), stringsAsFactors = FALSE)
  debt_rows <- stats[stats$Raw_Variable %in% c("Medical_Debt_Share", "Medical_Debt_Median_2023"), ]

  expect_equal(nrow(debt_rows), 2)
  expect_true(all(debt_rows$N == 0))
  expect_true(all(round(debt_rows$Missing_Pct, 4) == 100))
})
