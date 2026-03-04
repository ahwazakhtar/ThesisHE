# R script to run County-Level Fixed Effects Analysis
# Models:
# 1. Spec A (Adaptation): Z-Scores (Temp/Precip)
# 2. Spec B (Burden): Absolute Extremes (CDD/HDD Quintiles)
# Both specs include County-Level Drought (PDSI/PHDI/PMDI)
# All models run both WITH and WITHOUT AQI shocks.

library(dplyr)
library(fixest) # Primary package for FE with clustering

# 1. Setup ----------------------------------------------------------------
input_path <- "Data/county_level_master.csv"
output_file <- "Analysis/county_analysis_results.txt"
output_csv <- "Analysis/county_regression_coefs.csv"
sample_diag_csv <- "Analysis/county_sample_diagnostics.csv"
vif_output_path <- "Analysis/county_vif_diagnostics.txt"

cat("Loading Data...\n")
df <- read.csv(input_path)

# 2. Pre-Analysis Prep ----------------------------------------------------
# Create Per Capita Hospital Debt if Population exists
if ("Population" %in% names(df) && !all(is.na(df$Population))) {
  df$Hosp_BadDebt_PerCapita <- df$Hosp_BadDebt_Total_Real / df$Population
} else {
  df$Hosp_BadDebt_PerCapita <- NA # Placeholder
}

# Debt reporting-rule policy exclusion (AGENTS.md):
# CO HB23-1126 affects the 2023 August snapshot in Urban county debt panel.
# NY (effective Dec 2023) and MN (effective Oct 2024) do not require exclusion
# in this panel window.
debt_reporting_policy <- data.frame(
  State = "CO",
  Start_Year = 2023L,
  End_Year = 2023L,
  stringsAsFactors = FALSE
)
debt_outcomes <- intersect(c("Medical_Debt_Share", "Medical_Debt_Median_2023"), names(df))
debt_excluded_by_outcome <- setNames(integer(length(debt_outcomes)), debt_outcomes)
debt_policy_label <- "None"

if (length(debt_outcomes) > 0 && "State" %in% names(df) && "Year" %in% names(df) &&
    is.data.frame(debt_reporting_policy) && nrow(debt_reporting_policy) > 0) {
  policy_tbl <- debt_reporting_policy %>%
    transmute(
      State = toupper(trimws(as.character(State))),
      Start_Year = as.integer(Start_Year),
      End_Year = as.integer(End_Year)
    ) %>%
    filter(
      !is.na(State), State != "",
      !is.na(Start_Year), !is.na(End_Year),
      End_Year >= Start_Year
    ) %>%
    distinct()

  if (nrow(policy_tbl) > 0) {
    state_upper <- toupper(trimws(as.character(df$State)))
    year_int <- as.integer(df$Year)
    exclusion_mask <- rep(FALSE, nrow(df))

    for (i in seq_len(nrow(policy_tbl))) {
      exclusion_mask <- exclusion_mask |
        (state_upper == policy_tbl$State[i] &
           year_int >= policy_tbl$Start_Year[i] &
           year_int <= policy_tbl$End_Year[i])
    }

    debt_policy_label <- paste0(
      policy_tbl$State, " ",
      policy_tbl$Start_Year,
      ifelse(
        policy_tbl$Start_Year == policy_tbl$End_Year,
        "",
        paste0("-", policy_tbl$End_Year)
      ),
      collapse = "; "
    )

    for (v in debt_outcomes) {
      debt_excluded_by_outcome[v] <- sum(exclusion_mask & !is.na(df[[v]]), na.rm = TRUE)
      df[[v]] <- ifelse(exclusion_mask, NA_real_, as.numeric(df[[v]]))
    }

    cat(
      "Applied debt reporting exclusion policy:", debt_policy_label,
      "| Excluded debt-outcome observations:",
      format(sum(debt_excluded_by_outcome), big.mark = ","), "\n"
    )
  }
}

# Ensure State Factor for Clustering
df$State <- as.factor(df$State)

# 3. Model Specifications -------------------------------------------------

# Common Controls
# Note: Unemployment_Rate is excluded — no county-level unemployment series has
# been sourced yet (BLS LAUS integration is planned in Phase 1). Adding it here
# while absent from the master would cause intersect() to silently drop it from
# all regressions with no warning.
controls <- c("Household_Income_2023", "Uninsured_Rate")
available_controls <- intersect(controls, names(df))

# Drought block strategy:
# Primary identification uses one drought index (PDSI) to avoid severe
# multicollinearity across PDSI/PHDI/PMDI and their lags. Alternative drought
# indices are retained as robustness candidates for optional specs.
drought_vars_primary <- c("pdsi_val", "PDSI_Lag1", "PDSI_Lag2")
drought_vars_robust_full <- c(
  drought_vars_primary,
  "phdi_val", "PHDI_Lag1", "PHDI_Lag2",
  "pmdi_val", "PMDI_Lag1", "PMDI_Lag2"
)

# Spec 1: Relative Shocks (Climate only, primary drought block)
vars_spec1_base <- c(
  drought_vars_primary,
  "Z_Temp", "Z_Temp_Lag1", "Z_Temp_Lag2",
  "Z_Precip", "Z_Precip_Lag1", "Z_Precip_Lag2"
)

# Spec 1b: Relative Shocks (Climate + AQI)
vars_spec1_aqi <- c(vars_spec1_base, "AQI_Shock", "AQI_Shock_Lag1", "AQI_Shock_Lag2")

# Spec 2: Absolute Burden (High CDD/HDD, primary drought block)
vars_spec2_base <- c(
  drought_vars_primary,
  "High_CDD", "High_CDD_Lag1", "High_CDD_Lag2",
  "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2"
)

# Spec 2b: Absolute Burden (+ AQI)
vars_spec2_aqi <- c(vars_spec2_base, "AQI_Shock", "AQI_Shock_Lag1", "AQI_Shock_Lag2")

# 4. Helper Functions -----------------------------------------------------

# VIF via auxiliary OLS regressions (no external package required).
# Returns a named numeric vector of VIFs, or NULL on failure.
# Used on the demeaned/within predictor matrix from a fitted feols model.
calculate_vif <- function(model) {
  tryCatch({
    if (is.null(model) || any(is.na(coef(model)))) return(NULL)
    X <- model.matrix(model)
    if (is.null(X) || ncol(X) < 2) return(NULL)
    vifs <- setNames(numeric(ncol(X)), colnames(X))
    for (i in seq_len(ncol(X))) {
      r2 <- summary(lm(X[, i] ~ X[, -i]))$r.squared
      vifs[i] <- if (r2 < 1) 1 / (1 - r2) else Inf
    }
    vifs
  }, error = function(e) NULL)
}

# Helper to run feols safely
safe_feols <- function(f, data, cluster, weights = NULL) {
  tryCatch({
    if (!is.null(weights)) {
      if(is.character(weights)) {
        feols(f, data = data, cluster = cluster, weights = data[[weights]])
      } else {
        feols(f, data = data, cluster = cluster, weights = weights)
      }
    } else {
      feols(f, data = data, cluster = cluster)
    }
  }, error = function(e) {
    cat("    Error in model fit:", conditionMessage(e), "\n")
    return(NULL)
  })
}

# 5. Run Analysis Function ------------------------------------------------

run_models <- function(outcome_var, weight_var = NULL) {
  if (!outcome_var %in% names(df)) return(NULL)
  
  cat(paste0("  Running Models for: ", outcome_var, 
             if(!is.null(weight_var)) " (Weighted)" else " (Unweighted)", "...\n"))
  
  # Filter NA for outcome
  df_mod <- df %>% filter(!is.na(!!sym(outcome_var)))

  is_debt_outcome <- outcome_var %in% debt_outcomes
  debt_filter_label <- if (is_debt_outcome) debt_policy_label else "None"
  debt_excluded_obs <- if (is_debt_outcome && outcome_var %in% names(debt_excluded_by_outcome)) {
    as.integer(debt_excluded_by_outcome[[outcome_var]])
  } else {
    0L
  }
  
  # Prepare formulas
  f1_base <- as.formula(paste(outcome_var, "~", paste(c(vars_spec1_base, available_controls), collapse = "+"), "| fips_code + Year"))
  f1_aqi  <- as.formula(paste(outcome_var, "~", paste(c(vars_spec1_aqi, available_controls), collapse = "+"), "| fips_code + Year"))
  f2_base <- as.formula(paste(outcome_var, "~", paste(c(vars_spec2_base, available_controls), collapse = "+"), "| fips_code + Year"))
  f2_aqi  <- as.formula(paste(outcome_var, "~", paste(c(vars_spec2_aqi, available_controls), collapse = "+"), "| fips_code + Year"))

  # Outcome/spec-specific sample diagnostics (complete-case on outcome + RHS + FE IDs)
  build_sample_diag <- function(spec_name, rhs_vars, require_ra_id = FALSE) {
    vars_needed <- unique(c(outcome_var, rhs_vars, available_controls, "fips_code", "Year", "State"))
    if (!is.null(weight_var)) vars_needed <- unique(c(vars_needed, weight_var))
    if (require_ra_id) vars_needed <- unique(c(vars_needed, "rating_area_id"))
    vars_needed <- vars_needed[vars_needed %in% names(df_mod)]

    keep <- rep(TRUE, nrow(df_mod))
    for (v in vars_needed) {
      keep <- keep & !is.na(df_mod[[v]])
    }
    d <- df_mod[keep, ]

    data.frame(
      Outcome = outcome_var,
      Weighting = ifelse(is.null(weight_var), "Unweighted", "Population"),
      Spec = spec_name,
      Debt_Reporting_Filter = debt_filter_label,
      Debt_Excluded_Obs = debt_excluded_obs,
      N = nrow(d),
      Counties = dplyr::n_distinct(d$fips_code),
      States = dplyr::n_distinct(d$State),
      Year_Min = ifelse(nrow(d) > 0, min(d$Year, na.rm = TRUE), NA),
      Year_Max = ifelse(nrow(d) > 0, max(d$Year, na.rm = TRUE), NA),
      stringsAsFactors = FALSE
    )
  }

  sample_diag <- dplyr::bind_rows(
    build_sample_diag("Spec1_Base", vars_spec1_base),
    build_sample_diag("Spec1_AQI", vars_spec1_aqi),
    build_sample_diag("Spec2_Base", vars_spec2_base),
    build_sample_diag("Spec2_AQI", vars_spec2_aqi)
  )
  
  m1_base <- safe_feols(f1_base, df_mod, "State", weight_var)
  m1_aqi  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f1_aqi, df_mod, "State", weight_var) else NULL
  m2_base <- safe_feols(f2_base, df_mod, "State", weight_var)
  m2_aqi  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f2_aqi, df_mod, "State", weight_var) else NULL

  # For premium outcomes: add rating-area-clustered variants to account for
  # within-rating-area residual correlation (counties in the same rating area
  # share the same premium by construction). State clustering nests rating areas
  # but is imprecise; these variants use the tighter cluster.
  is_premium_outcome <- outcome_var %in% c("Benchmark_Silver_Real", "Lowest_Bronze_Real")
  if (is_premium_outcome && "rating_area_id" %in% names(df_mod)) {
    m1_base_ra <- safe_feols(f1_base, df_mod, "rating_area_id", weight_var)
    m1_aqi_ra  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f1_aqi, df_mod, "rating_area_id", weight_var) else NULL
    m2_base_ra <- safe_feols(f2_base, df_mod, "rating_area_id", weight_var)
    m2_aqi_ra  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f2_aqi, df_mod, "rating_area_id", weight_var) else NULL

    sample_diag <- dplyr::bind_rows(
      sample_diag,
      build_sample_diag("Spec1_Base_RA_Cluster", vars_spec1_base, require_ra_id = TRUE),
      build_sample_diag("Spec1_AQI_RA_Cluster", vars_spec1_aqi, require_ra_id = TRUE),
      build_sample_diag("Spec2_Base_RA_Cluster", vars_spec2_base, require_ra_id = TRUE),
      build_sample_diag("Spec2_AQI_RA_Cluster", vars_spec2_aqi, require_ra_id = TRUE)
    )
  } else {
    m1_base_ra <- m1_aqi_ra <- m2_base_ra <- m2_aqi_ra <- NULL
  }

  # VIF diagnostics on the primary unweighted Spec1 model only.
  # Computed via auxiliary OLS on the within-transformed predictor matrix.
  # High VIF (>10) on drought vars would indicate residual multicollinearity
  # even after pruning to PDSI-only. Logged to county_vif_diagnostics.txt.
  vif_result <- if (!is.null(m1_base)) calculate_vif(m1_base) else NULL

  return(list(
    Spec1_Base = m1_base, Spec1_AQI = m1_aqi,
    Spec2_Base = m2_base, Spec2_AQI = m2_aqi,
    Spec1_Base_RA_Cluster = m1_base_ra, Spec1_AQI_RA_Cluster = m1_aqi_ra,
    Spec2_Base_RA_Cluster = m2_base_ra, Spec2_AQI_RA_Cluster = m2_aqi_ra,
    Sample_Diagnostics = sample_diag,
    VIF_Spec1_Base = vif_result
  ))
}

# 6. Execution Loop -------------------------------------------------------
outcomes <- c("Medical_Debt_Share", "Medical_Debt_Median_2023", "Benchmark_Silver_Real", "Hosp_BadDebt_PerCapita",
              "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed")
results_list <- list()
sample_diag_list <- list()

vif_log_lines <- c(
  "--- County-Level Multicollinearity Diagnostics (VIF) ---",
  "Model: Spec1_Base (primary drought: PDSI only), unweighted, cluster=State",
  "VIF > 10 = severe; VIF 5-10 = moderate concern",
  ""
)

sink(output_file)
cat("=================================================\n")
cat("COUNTY LEVEL ENVIRONMENTAL IMPACT ANALYSIS RESULTS\n")
cat("=================================================\n")

for (y in outcomes) {
  # Unweighted
  res <- run_models(y)
  if (!is.null(res)) {
    cat(paste0("\nOUTCOME: ", y, " (Unweighted)\n"))
    cat("--- Spec 1 (Climate Shocks) ---\n")
    if(!is.null(res$Spec1_Base)) print(summary(res$Spec1_Base, n = 100))
    cat("\n--- Spec 1b (Climate + AQI Shocks) ---\n")
    if(!is.null(res$Spec1_AQI)) print(summary(res$Spec1_AQI, n = 100))
    cat("\n--- Spec 2 (Absolute Burden) ---\n")
    if(!is.null(res$Spec2_Base)) print(summary(res$Spec2_Base, n = 100))
    cat("\n--- Spec 2b (Absolute Burden + AQI Shocks) ---\n")
    if(!is.null(res$Spec2_AQI)) print(summary(res$Spec2_AQI, n = 100))
    if(!is.null(res$Spec1_Base_RA_Cluster)) {
      cat("\n--- Spec 1 (Rating-Area Clustered SEs) ---\n")
      print(summary(res$Spec1_Base_RA_Cluster, n = 100))
    }
    if(!is.null(res$Spec1_AQI_RA_Cluster)) {
      cat("\n--- Spec 1b (Rating-Area Clustered SEs + AQI) ---\n")
      print(summary(res$Spec1_AQI_RA_Cluster, n = 100))
    }
    if(!is.null(res$Spec2_Base_RA_Cluster)) {
      cat("\n--- Spec 2 (Rating-Area Clustered SEs) ---\n")
      print(summary(res$Spec2_Base_RA_Cluster, n = 100))
    }
    if(!is.null(res$Spec2_AQI_RA_Cluster)) {
      cat("\n--- Spec 2b (Rating-Area Clustered SEs + AQI) ---\n")
      print(summary(res$Spec2_AQI_RA_Cluster, n = 100))
    }
    if (!is.null(res$Sample_Diagnostics)) {
      sample_diag_list[[length(sample_diag_list) + 1]] <- res$Sample_Diagnostics
    }
    if (!is.null(res$VIF_Spec1_Base)) {
      vif_log_lines <- c(vif_log_lines,
        paste0("Outcome: ", y, " (Unweighted)"),
        capture.output(print(round(res$VIF_Spec1_Base, 2))),
        ""
      )
    }
    results_list[[paste0(y, "_Unweighted")]] <- res
  }
  
  # Weighted (Only if Population exists)
  if ("Population" %in% names(df) && !all(is.na(df$Population))) {
    res_w <- run_models(y, "Population")
    if (!is.null(res_w)) {
      cat(paste0("\nOUTCOME: ", y, " (Pop-Weighted)\n"))
      cat("--- Spec 1 (Climate Shocks) ---\n")
      if(!is.null(res_w$Spec1_Base)) print(summary(res_w$Spec1_Base, n = 100))
      cat("\n--- Spec 1b (Climate + AQI Shocks) ---\n")
      if(!is.null(res_w$Spec1_AQI)) print(summary(res_w$Spec1_AQI, n = 100))
      cat("\n--- Spec 2 (Absolute Burden) ---\n")
      if(!is.null(res_w$Spec2_Base)) print(summary(res_w$Spec2_Base, n = 100))
      cat("\n--- Spec 2b (Absolute Burden + AQI Shocks) ---\n")
      if(!is.null(res_w$Spec2_AQI)) print(summary(res_w$Spec2_AQI, n = 100))
      if(!is.null(res_w$Spec1_Base_RA_Cluster)) {
        cat("\n--- Spec 1 (Rating-Area Clustered SEs) ---\n")
        print(summary(res_w$Spec1_Base_RA_Cluster, n = 100))
      }
      if(!is.null(res_w$Spec1_AQI_RA_Cluster)) {
        cat("\n--- Spec 1b (Rating-Area Clustered SEs + AQI) ---\n")
        print(summary(res_w$Spec1_AQI_RA_Cluster, n = 100))
      }
      if(!is.null(res_w$Spec2_Base_RA_Cluster)) {
        cat("\n--- Spec 2 (Rating-Area Clustered SEs) ---\n")
        print(summary(res_w$Spec2_Base_RA_Cluster, n = 100))
      }
      if(!is.null(res_w$Spec2_AQI_RA_Cluster)) {
        cat("\n--- Spec 2b (Rating-Area Clustered SEs + AQI) ---\n")
        print(summary(res_w$Spec2_AQI_RA_Cluster, n = 100))
      }
      if (!is.null(res_w$Sample_Diagnostics)) {
        sample_diag_list[[length(sample_diag_list) + 1]] <- res_w$Sample_Diagnostics
      }
      results_list[[paste0(y, "_Weighted")]] <- res_w
    }
  }
}

# -------------------------------------------------------------------------
# 7. Robustness: Rating Area Aggregation
# -------------------------------------------------------------------------
cat("\n=================================================\n")
cat("ROBUSTNESS CHECK: RATING AREA LEVEL AGGREGATION\n")
cat("=================================================\n")

if ("rating_area_id" %in% names(df) && "Population" %in% names(df) && !all(is.na(df$Population))) {
  
  cat("Aggregating to Rating Area Level (Population Weighted)...\n")
  
  # Aggregate numeric cols by Rating Area + Year
  cols_to_agg <- c(outcomes, available_controls,
                   "Z_Temp", "Z_Precip", "High_CDD", "High_HDD",
                   "pdsi_val", "phdi_val", "pmdi_val")
  if("AQI_Shock" %in% names(df)) cols_to_agg <- c(cols_to_agg, "AQI_Shock")

  df_ra <- df %>%
    filter(!is.na(rating_area_id), !is.na(Population)) %>%
    group_by(rating_area_id, Year, State) %>%
    summarize(
      # Force double arithmetic to avoid integer overflow in weighted means
      # when x and Population are stored as integers.
      across(all_of(cols_to_agg),
             ~ weighted.mean(as.numeric(.), w = as.numeric(Population), na.rm = TRUE)),

      # Sum Population
      Population = sum(as.numeric(Population), na.rm = TRUE),

      .groups = "drop"
    ) %>%
    # Re-calculate Lags
    group_by(rating_area_id) %>%
    arrange(Year) %>%
    mutate(
      Z_Temp_Lag1 = lag(Z_Temp, 1), Z_Temp_Lag2 = lag(Z_Temp, 2),
      Z_Precip_Lag1 = lag(Z_Precip, 1), Z_Precip_Lag2 = lag(Z_Precip, 2),
      High_CDD_Lag1 = lag(High_CDD, 1), High_CDD_Lag2 = lag(High_CDD, 2),
      High_HDD_Lag1 = lag(High_HDD, 1), High_HDD_Lag2 = lag(High_HDD, 2),
      PDSI_Lag1 = lag(pdsi_val, 1), PDSI_Lag2 = lag(pdsi_val, 2),
      PHDI_Lag1 = lag(phdi_val, 1), PHDI_Lag2 = lag(phdi_val, 2),
      PMDI_Lag1 = lag(pmdi_val, 1), PMDI_Lag2 = lag(pmdi_val, 2)
    )
  
  if("AQI_Shock" %in% names(df_ra)) {
    df_ra <- df_ra %>%
      group_by(rating_area_id) %>%
      mutate(AQI_Shock_Lag1 = lag(AQI_Shock, 1), AQI_Shock_Lag2 = lag(AQI_Shock, 2)) %>%
      ungroup()
  } else {
    df_ra <- df_ra %>% ungroup()
  }

  # Run Models on RA Data
  run_models_ra <- function(outcome_var) {
    if (!outcome_var %in% names(df_ra)) return(NULL)
    
    cat(paste0("  Running RA Models for: ", outcome_var, "...\n"))
    df_mod <- df_ra %>% filter(!is.na(!!sym(outcome_var)))
    
    if (nrow(df_mod) == 0) {
      cat("    Skipping: No observations after NA filtering.\n")
      return(NULL)
    }

    f1_base <- as.formula(paste(outcome_var, "~", paste(c(vars_spec1_base, available_controls), collapse = "+"), "| rating_area_id + Year"))
    f1_aqi  <- as.formula(paste(outcome_var, "~", paste(c(vars_spec1_aqi, available_controls), collapse = "+"), "| rating_area_id + Year"))
    f2_base <- as.formula(paste(outcome_var, "~", paste(c(vars_spec2_base, available_controls), collapse = "+"), "| rating_area_id + Year"))
    f2_aqi  <- as.formula(paste(outcome_var, "~", paste(c(vars_spec2_aqi, available_controls), collapse = "+"), "| rating_area_id + Year"))
    
    m1_base <- safe_feols(f1_base, df_mod, "State", "Population")
    m1_aqi  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f1_aqi, df_mod, "State", "Population") else NULL
    m2_base <- safe_feols(f2_base, df_mod, "State", "Population")
    m2_aqi  <- if("AQI_Shock" %in% names(df_mod)) safe_feols(f2_aqi, df_mod, "State", "Population") else NULL
    
    return(list(Spec1_Base = m1_base, Spec1_AQI = m1_aqi, Spec2_Base = m2_base, Spec2_AQI = m2_aqi))
  }

  for (y in outcomes) {
    res_ra <- run_models_ra(y)
    if (!is.null(res_ra)) {
      cat(paste0("\nOUTCOME: ", y, " (Rating Area Level)\n"))
      if(!is.null(res_ra$Spec1_Base)) print(summary(res_ra$Spec1_Base, n = 100))
      if(!is.null(res_ra$Spec1_AQI)) print(summary(res_ra$Spec1_AQI, n = 100))
      if(!is.null(res_ra$Spec2_Base)) print(summary(res_ra$Spec2_Base, n = 100))
      if(!is.null(res_ra$Spec2_AQI)) print(summary(res_ra$Spec2_AQI, n = 100))
      results_list[[paste0(y, "_RA_Robustness")]] <- res_ra
    }
  }

} else {
  cat("Skipping Robustness: Missing 'rating_area_id' or 'Population' column.\n")
}

sink()

# Write VIF diagnostics log
if (length(vif_log_lines) > 4) {
  writeLines(vif_log_lines, vif_output_path)
  cat(paste0("VIF diagnostics saved to: ", vif_output_path, "\n"))
}

# Export sample diagnostics
if (length(sample_diag_list) > 0) {
  sample_diag_df <- dplyr::bind_rows(sample_diag_list)
  write.csv(sample_diag_df, sample_diag_csv, row.names = FALSE)
  cat(paste0("Sample diagnostics saved to: ", sample_diag_csv, "\n"))
}

# 8. Export Coefficients Table --------------------------------------------
# Using etable to export to CSV
if (length(results_list) > 0) {
  # Collect all valid models
  all_models <- list()
  for (res in results_list) {
    if (!is.null(res$Spec1_Base)) all_models[[length(all_models)+1]] <- res$Spec1_Base
    if (!is.null(res$Spec1_AQI))  all_models[[length(all_models)+1]] <- res$Spec1_AQI
    if (!is.null(res$Spec2_Base)) all_models[[length(all_models)+1]] <- res$Spec2_Base
    if (!is.null(res$Spec2_AQI))  all_models[[length(all_models)+1]] <- res$Spec2_AQI
  }
  
  # Collect RA-clustered variants
  for (res in results_list) {
    if (!is.null(res$Spec1_Base_RA_Cluster)) all_models[[length(all_models)+1]] <- res$Spec1_Base_RA_Cluster
    if (!is.null(res$Spec1_AQI_RA_Cluster))  all_models[[length(all_models)+1]] <- res$Spec1_AQI_RA_Cluster
    if (!is.null(res$Spec2_Base_RA_Cluster)) all_models[[length(all_models)+1]] <- res$Spec2_Base_RA_Cluster
    if (!is.null(res$Spec2_AQI_RA_Cluster))  all_models[[length(all_models)+1]] <- res$Spec2_AQI_RA_Cluster
  }

  if (length(all_models) > 0) {
    etable(all_models, file = output_csv, replace = TRUE)
    cat(paste0("\nResults exported to: ", output_file, " and ", output_csv, "\n"))
  } else {
    cat("\nNo valid models were estimated.\n")
  }
} else {
  cat("No models converged or variables missing.\n")
}
