# Unified pipeline runner for state and county workflows.

source("Code/pipeline_utils.R")

align_repo_root <- function() {
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_arg) == 0) {
    return(invisible(NULL))
  }
  script_path <- sub("^--file=", "", file_arg[[1]])
  script_dir <- dirname(normalizePath(script_path, winslash = "/", mustWork = FALSE))
  repo_root <- normalizePath(file.path(script_dir, ".."), winslash = "/", mustWork = FALSE)
  if (dir.exists(repo_root)) {
    setwd(repo_root)
  }
  invisible(NULL)
}

build_step_registry <- function() {
  list(
    list(
      id = "state_download_climate",
      pipeline = "state",
      phase = "download",
      script = "Code/download_climate_data.R",
      function_name = "run_download_climate_data",
      description = "Download NOAA climate files for state and county pipelines",
      required_outputs = c("Data/Climate_Data/State level/climdiv-tmpcst-v1.0.0-20260107")
    ),
    list(
      id = "state_download_policy",
      pipeline = "state",
      phase = "download",
      script = "Code/download_state_policy_data.R",
      description = "Download macroeconomic and CPI policy datasets",
      required_outputs = c(
        "Data/State_Policy_Data/state_macroeconomics.csv",
        "Data/State_Policy_Data/us_cpi_annual.csv"
      )
    ),
    list(
      id = "state_download_meps_scrape",
      pipeline = "state",
      phase = "download",
      script = "Code/scrape_meps_html_base.R",
      description = "Scrape MEPS state-level contribution and deductible tables",
      required_outputs = c("Data/MEPS_Data_IC/meps_ic_state_consolidated.csv")
    ),
    list(
      id = "state_process_meps_local_excel",
      pipeline = "state",
      phase = "process",
      script = "Code/extract_local_meps.R",
      description = "Append local 2021-2024 MEPS Excel values when files are available",
      required_inputs = c("Data/MEPS_Data_IC/meps_ic_state_consolidated.csv", "Data/MEPS_Data_IC/Excel"),
      required_outputs = c("Data/MEPS_Data_IC/meps_ic_state_consolidated.csv"),
      enabled_if = function() {
        dir.exists("Data/MEPS_Data_IC/Excel") &&
          length(list.files("Data/MEPS_Data_IC/Excel", pattern = "202[1-4]\\.xlsx$", full.names = TRUE)) > 0
      }
    ),
    list(
      id = "state_process_climate",
      pipeline = "state",
      phase = "process",
      script = "Code/process_state_climate.R",
      description = "Aggregate NOAA state climate files into annual state panel",
      required_inputs = c("Data/Climate_Data/State level/climdiv-tmpcst-v1.0.0-20260107"),
      required_outputs = c("Data/Climate_Data/state_climate_consolidated.csv")
    ),
    list(
      id = "state_process_aqi",
      pipeline = "state",
      phase = "process",
      script = "Code/process_aqi_data.R",
      function_name = "run_process_aqi_data",
      description = "Aggregate county AQI files to state-year means",
      required_inputs = c("Data/AQIdata/states_and_counties.csv"),
      required_outputs = c("Data/state_aqi_consolidated.csv")
    ),
    list(
      id = "state_process_medical_debt",
      pipeline = "state",
      phase = "process",
      script = "Code/process_medical_debt.R",
      description = "Process state-level medical debt file",
      required_inputs = c("Data/MedicalDebt/changing_med_debt_landscape_state.xlsx"),
      required_outputs = c("Data/MedicalDebt/medical_debt_state_consolidated.csv")
    ),
    list(
      id = "state_process_cms",
      pipeline = "state",
      phase = "process",
      script = "Code/process_cms_health_exp.R",
      description = "Consolidate CMS state expenditure tables",
      required_inputs = c(
        "Data/State Residence health expenditures/residence state estimates/US_PER_CAPITA20.CSV",
        "Data/State Residence health expenditures/residence state estimates/PHI_PER_ENROLLEE20.CSV",
        "Data/State Residence health expenditures/residence state estimates/MEDICAID_PER_ENROLLEE20.CSV",
        "Data/State Residence health expenditures/residence state estimates/MEDICARE_PER_ENROLLEE20.CSV"
      ),
      required_outputs = c("Data/State Residence health expenditures/cms_nhe_state_consolidated.csv")
    ),
    list(
      id = "state_merge_master",
      pipeline = "state",
      phase = "merge",
      script = "Code/create_state_master.R",
      description = "Build state master dataset",
      required_inputs = c(
        "Data/Climate_Data/state_climate_consolidated.csv",
        "Data/MEPS_Data_IC/meps_ic_state_consolidated.csv",
        "Data/State Residence health expenditures/cms_nhe_state_consolidated.csv",
        "Data/State_Policy_Data/state_macroeconomics.csv",
        "Data/MedicalDebt/medical_debt_state_consolidated.csv"
      ),
      required_outputs = c("Data/state_level_analysis_master.csv")
    ),
    list(
      id = "state_feature_engineering",
      pipeline = "state",
      phase = "merge",
      script = "Code/analysis_pre_processing.R",
      description = "Generate climate shock features and lags for state analysis",
      required_inputs = c("Data/state_level_analysis_master.csv"),
      required_outputs = c("Data/analysis_ready_dataset.csv")
    ),
    list(
      id = "state_analysis",
      pipeline = "state",
      phase = "analysis",
      script = "Code/run_analysis.R",
      description = "Estimate state-level FE models",
      required_inputs = c("Data/analysis_ready_dataset.csv"),
      required_outputs = c("Analysis/regression_results_summary.csv")
    ),
    list(
      id = "county_process_population",
      pipeline = "county",
      phase = "process",
      script = "Code/process_county_population.R",
      description = "Process SEER population data to county-year totals",
      required_inputs = c("Data/County Population/us.1969_2023.20ages.adjusted.txt"),
      required_outputs = c("Data/intermediate_pop.rds")
    ),
    list(
      id = "county_process_climate",
      pipeline = "county",
      phase = "process",
      script = "Code/process_county_climate.R",
      function_name = "run_process_county_climate",
      description = "Process county climate data and engineer shocks/lags",
      required_inputs = c("Data/Climate_Data/County level/climdiv-tmpccy-v1.0.0-20260107"),
      required_outputs = c("Data/intermediate_climate.rds")
    ),
    list(
      id = "county_process_aqi",
      pipeline = "county",
      phase = "process",
      script = "Code/process_county_aqi.R",
      description = "Map and process county AQI data",
      required_inputs = c("Data/AQIdata/states_and_counties.csv"),
      required_outputs = c("Data/intermediate_aqi.rds")
    ),
    list(
      id = "county_process_zip_county_map",
      pipeline = "county",
      phase = "process",
      script = "Code/process_zip_county_map.R",
      description = "Map hospital and medical debt data to county level",
      required_inputs = c(
        "Data/MedicalDebt/changing_med_debt_landscape_county.xlsx",
        "Data/Hosp_Data/NASHP 2011-2023 HCT Data 2025 Feb.xlsx",
        "Data/Zip County Crosswalk/zip2county_master_xwalk_2010_2023_tot_ratio_one2one.csv"
      ),
      required_outputs = c("Data/medical_debt_county.csv")
    ),
    list(
      id = "county_process_rating_area_map",
      pipeline = "county",
      phase = "process",
      script = "Code/process_rating_area_map.R",
      description = "Map HIX premiums from rating areas to counties",
      required_inputs = c("Data/HIX_Data/plan details", "Data/HIX_Data/crosswalk"),
      required_outputs = c("Data/premiums_county.csv")
    ),
    list(
      id = "county_merge_master",
      pipeline = "county",
      phase = "merge",
      script = "Code/create_county_master.R",
      description = "Build county master dataset",
      required_inputs = c(
        "Data/medical_debt_county.csv",
        "Data/premiums_county.csv",
        "Data/State_Policy_Data/us_cpi_annual.csv",
        "Data/intermediate_pop.rds",
        "Data/intermediate_climate.rds",
        "Data/intermediate_aqi.rds"
      ),
      required_outputs = c("Data/county_level_master.csv")
    ),
    list(
      id = "county_analysis",
      pipeline = "county",
      phase = "analysis",
      script = "Code/run_county_analysis.R",
      description = "Estimate county-level FE models and robustness checks",
      required_inputs = c("Data/county_level_master.csv"),
      required_outputs = c("Analysis/county_analysis_results.txt", "Analysis/county_regression_coefs.csv")
    )
  )
}

run_pipeline <- function() {
  align_repo_root()
  opts <- parse_cli_args()

  if (isTRUE(opts$help)) {
    print_pipeline_help()
    return(invisible(NULL))
  }

  steps <- build_step_registry()
  validate_step_definitions(steps)

  selected_phases <- resolve_selected_phases(opts)
  selected_steps <- filter_steps(steps, pipeline = opts$pipeline, phases = selected_phases)

  pipeline_log("Pipeline:", opts$pipeline)
  pipeline_log("Phases:", paste(selected_phases, collapse = ", "))
  pipeline_log("Strict mode:", opts$strict)
  pipeline_log("Dry run:", opts$dry_run)

  if (length(selected_steps) == 0) {
    pipeline_log("No steps matched the requested selection.")
    return(invisible(NULL))
  }

  print_step_list(selected_steps)
  if (isTRUE(opts$list_steps)) {
    return(invisible(NULL))
  }

  results <- run_step_sequence(selected_steps, strict = opts$strict, dry_run = opts$dry_run)
  summary <- summarize_step_results(results)
  pipeline_log("Execution summary:", paste(names(summary), unlist(summary), sep = "=", collapse = ", "))

  invisible(results)
}

if (sys.nframe() == 0) {
  run_pipeline()
}
