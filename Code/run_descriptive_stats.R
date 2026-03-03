# Publication-Grade Descriptive Statistics for County-Level Panel
#
# Produces:
#   Analysis/descriptive_stats_summary.csv
#   Analysis/descriptive_stats_table_main.csv
#   Analysis/descriptive_stats_table_main.tex
#   Analysis/descriptive_period_comparison.csv
#   Analysis/descriptive_period_comparison.tex
#   Analysis/descriptive_missingness_by_year.csv
#   Analysis/descriptive_missingness_summary.csv
#   Analysis/descriptive_correlation_matrix.csv
#   Analysis/descriptive_tables.tex
#   Analysis/descriptive_stats_report.md
#   Analysis/plots/fig1_climate_shock_prevalence.png
#   Analysis/plots/fig2_outcome_index_trends.png
#   Analysis/plots/fig3_distribution_shift.png
#   Analysis/plots/ts_climate_shocks.png
#   Analysis/plots/ts_outcomes.png
#   Analysis/plots/ts_income.png
#
# Sanity checks:
#   stopifnot input exists, required columns exist, and panel is non-empty.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
})

weighted_mean_safe <- function(x, w) {
  x <- as.numeric(x)
  w <- as.numeric(w)
  valid <- !is.na(x) & !is.na(w) & w > 0
  if (sum(valid) == 0) {
    return(NA_real_)
  }
  weighted.mean(x[valid], w[valid])
}

weighted_sd_safe <- function(x, w) {
  x <- as.numeric(x)
  w <- as.numeric(w)
  valid <- !is.na(x) & !is.na(w) & w > 0
  if (sum(valid) <= 1) {
    return(NA_real_)
  }
  x_val <- x[valid]
  w_val <- w[valid]
  mu <- weighted.mean(x_val, w_val)
  sqrt(sum(w_val * (x_val - mu)^2) / sum(w_val))
}

safe_quantile <- function(x, p) {
  x <- x[!is.na(x)]
  if (length(x) == 0) {
    return(NA_real_)
  }
  as.numeric(quantile(x, probs = p, na.rm = TRUE, names = FALSE, type = 7))
}

winsorized_mean <- function(x, p = 0.01) {
  x <- x[!is.na(x)]
  if (length(x) == 0) {
    return(NA_real_)
  }
  lo <- safe_quantile(x, p)
  hi <- safe_quantile(x, 1 - p)
  mean(pmin(pmax(x, lo), hi), na.rm = TRUE)
}

format_num <- function(x, digits = 2) {
  ifelse(
    is.na(x),
    NA_character_,
    format(round(x, digits), big.mark = ",", scientific = FALSE, trim = TRUE)
  )
}

format_pct <- function(x, digits = 1) {
  ifelse(is.na(x), NA_character_, paste0(format_num(x, digits), "%"))
}

format_dollar <- function(x, digits = 0) {
  ifelse(is.na(x), NA_character_, paste0("$", format_num(x, digits)))
}

escape_latex <- function(x) {
  x <- ifelse(is.na(x), "", as.character(x))
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  x <- gsub("([#$%&_{}])", "\\\\\\1", x, perl = TRUE)
  x <- gsub("~", "\\\\textasciitilde{}", x, fixed = TRUE)
  x <- gsub("\\^", "\\\\textasciicircum{}", x, perl = TRUE)
  x
}

write_latex_table <- function(df, path, caption, label) {
  stopifnot(is.data.frame(df))
  df_chr <- as.data.frame(lapply(df, function(col) {
    if (is.numeric(col)) {
      format(col, scientific = FALSE, trim = TRUE)
    } else {
      as.character(col)
    }
  }), stringsAsFactors = FALSE, check.names = FALSE)

  ncol_df <- ncol(df_chr)
  align <- paste0("p{3.2cm} p{4.6cm}", paste(rep("r", max(0, ncol_df - 2)), collapse = " "))
  align <- trimws(align)
  header <- paste(escape_latex(names(df_chr)), collapse = " & ")

  body <- apply(df_chr, 1, function(row) {
    paste(escape_latex(row), collapse = " & ")
  })

  lines <- c(
    paste0("% Auto-generated: ", basename(path)),
    "\\begin{table}[!htbp]",
    "\\centering",
    "\\small",
    paste0("\\caption{", escape_latex(caption), "}"),
    paste0("\\label{", label, "}"),
    paste0("\\begin{tabular}{", align, "}"),
    "\\toprule",
    paste0(header, " \\\\"),
    "\\midrule",
    paste0(body, " \\\\"),
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{table}",
    ""
  )

  writeLines(lines, con = path)
}

summarize_variable <- function(df, var_name, var_label, domain_name, weight_var = "Population") {
  x <- df[[var_name]]
  w <- if (weight_var %in% names(df)) df[[weight_var]] else rep(NA_real_, length(x))

  valid <- !is.na(x)
  n_total <- length(x)
  n_non_missing <- sum(valid)

  if (n_non_missing == 0) {
    return(data.frame(
      Domain = domain_name,
      Variable = var_label,
      Raw_Variable = var_name,
      N = 0,
      Missing_Pct = 100,
      Mean = NA_real_,
      SD = NA_real_,
      Winsor_Mean_P1_P99 = NA_real_,
      Min = NA_real_,
      P10 = NA_real_,
      P25 = NA_real_,
      Median = NA_real_,
      P75 = NA_real_,
      P90 = NA_real_,
      Max = NA_real_,
      W_Mean = NA_real_,
      W_SD = NA_real_,
      stringsAsFactors = FALSE
    ))
  }

  x_valid <- x[valid]

  data.frame(
    Domain = domain_name,
    Variable = var_label,
    Raw_Variable = var_name,
    N = n_non_missing,
    Missing_Pct = (n_total - n_non_missing) / n_total * 100,
    Mean = mean(x_valid, na.rm = TRUE),
    SD = sd(x_valid, na.rm = TRUE),
    Winsor_Mean_P1_P99 = winsorized_mean(x_valid, p = 0.01),
    Min = min(x_valid, na.rm = TRUE),
    P10 = safe_quantile(x_valid, 0.10),
    P25 = safe_quantile(x_valid, 0.25),
    Median = median(x_valid, na.rm = TRUE),
    P75 = safe_quantile(x_valid, 0.75),
    P90 = safe_quantile(x_valid, 0.90),
    Max = max(x_valid, na.rm = TRUE),
    W_Mean = weighted_mean_safe(x, w),
    W_SD = weighted_sd_safe(x, w),
    stringsAsFactors = FALSE
  )
}

period_summary <- function(df, var_name, label, domain_name) {
  early <- df %>% filter(Period == "2011-2016")
  late <- df %>% filter(Period == "2017-2023")

  early_u <- mean(early[[var_name]], na.rm = TRUE)
  late_u <- mean(late[[var_name]], na.rm = TRUE)
  early_w <- weighted_mean_safe(early[[var_name]], early$Population)
  late_w <- weighted_mean_safe(late[[var_name]], late$Population)

  data.frame(
    Domain = domain_name,
    Variable = label,
    Raw_Variable = var_name,
    Early_Mean = early_u,
    Late_Mean = late_u,
    Diff_Late_minus_Early = late_u - early_u,
    Pct_Change = ifelse(is.na(early_u) || early_u == 0, NA_real_, (late_u / early_u - 1) * 100),
    Early_W_Mean = early_w,
    Late_W_Mean = late_w,
    W_Diff_Late_minus_Early = late_w - early_w,
    W_Pct_Change = ifelse(is.na(early_w) || early_w == 0, NA_real_, (late_w / early_w - 1) * 100),
    stringsAsFactors = FALSE
  )
}

journal_theme <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      legend.position = "bottom",
      legend.title = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      legend.background = element_rect(fill = "white", color = NA),
      legend.key = element_rect(fill = "white", color = NA),
      strip.background = element_rect(fill = "white", color = "grey85", linewidth = 0.2),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_line(color = "grey90", linewidth = 0.25),
      panel.grid.major.y = element_line(color = "grey90", linewidth = 0.25),
      axis.title.x = element_blank(),
      strip.text = element_text(face = "bold"),
      plot.title = element_text(face = "bold"),
      plot.subtitle = element_text(color = "grey30")
    )
}

run_descriptive_stats <- function(
  input_path = "Data/county_level_master.csv",
  output_dir = "Analysis",
  plot_dir = "Analysis/plots",
  debt_reporting_policy = data.frame(
    State = "CO",
    Start_Year = 2023L,
    End_Year = 2023L,
    stringsAsFactors = FALSE
  )
) {
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

  cat("Loading county master...\n")
  stopifnot(file.exists(input_path))
  df <- read.csv(input_path, stringsAsFactors = FALSE)
  stopifnot(nrow(df) > 0)

  required_cols <- c("fips_code", "Year")
  missing_required <- setdiff(required_cols, names(df))
  if (length(missing_required) > 0) {
    stop("Missing required columns: ", paste(missing_required, collapse = ", "))
  }

  if (!"Population" %in% names(df)) {
    warning("Population column missing. Weighted statistics will be NA.")
    df$Population <- NA_real_
  }

  study_df <- df %>% filter(Year >= 2011, Year <= 2023)
  stopifnot(nrow(study_df) > 0)

  # Optional exclusion for medical debt variables using state-year policy windows.
  # Per AGENTS.md: CO 2023 only; NY and MN do not require panel-period exclusion.
  debt_vars <- c("Medical_Debt_Share", "Medical_Debt_Median_2023")
  debt_vars_present <- intersect(debt_vars, names(study_df))
  applied_debt_exclusion <- FALSE
  debt_exclusion_policy_used <- character(0)
  debt_excluded_county_years <- 0

  if (length(debt_vars_present) > 0 &&
      "State" %in% names(study_df) &&
      is.data.frame(debt_reporting_policy) &&
      nrow(debt_reporting_policy) > 0) {
    required_policy_cols <- c("State", "Start_Year", "End_Year")
    missing_policy_cols <- setdiff(required_policy_cols, names(debt_reporting_policy))
    if (length(missing_policy_cols) > 0) {
      stop(
        "debt_reporting_policy is missing required columns: ",
        paste(missing_policy_cols, collapse = ", ")
      )
    }

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
      state_upper <- toupper(trimws(as.character(study_df$State)))
      year_int <- as.integer(study_df$Year)
      exclusion_mask <- rep(FALSE, nrow(study_df))

      for (i in seq_len(nrow(policy_tbl))) {
        exclusion_mask <- exclusion_mask |
          (state_upper == policy_tbl$State[i] &
             year_int >= policy_tbl$Start_Year[i] &
             year_int <= policy_tbl$End_Year[i])
      }

      debt_exclusion_policy_used <- paste0(
        policy_tbl$State, " ",
        policy_tbl$Start_Year,
        ifelse(
          policy_tbl$Start_Year == policy_tbl$End_Year,
          "",
          paste0("-", policy_tbl$End_Year)
        )
      )

      had_debt_measure <- rowSums(!is.na(study_df[, debt_vars_present, drop = FALSE])) > 0
      debt_excluded_county_years <- sum(exclusion_mask & had_debt_measure, na.rm = TRUE)

      if (debt_excluded_county_years > 0) {
        for (v in debt_vars_present) {
          study_df[[v]] <- ifelse(exclusion_mask, NA_real_, as.numeric(study_df[[v]]))
        }
        applied_debt_exclusion <- TRUE
        cat(
          "  Applied medical-debt exclusion policy:",
          paste(debt_exclusion_policy_used, collapse = "; "),
          "| Excluded county-years:", debt_excluded_county_years, "\n"
        )
      }
    }
  }

  cat(
    "  Rows:", nrow(df),
    "| Study rows:", nrow(study_df),
    "| Counties:", dplyr::n_distinct(df$fips_code),
    "| Years:", min(df$Year, na.rm = TRUE), "-", max(df$Year, na.rm = TRUE),
    "\n\n"
  )

  # -------------------------------------------------------------------------
  # Variable definitions for publication tables
  # -------------------------------------------------------------------------
  var_definitions <- data.frame(
    var = c(
      "Z_Temp", "Z_Precip", "High_CDD", "High_HDD", "pdsi_val", "Is_Extreme_Drought", "AQI_Shock",
      "Medical_Debt_Share", "Medical_Debt_Median_2023", "Benchmark_Silver_Real", "Lowest_Bronze_Real",
      "Hosp_BadDebt_Total_Real", "Hosp_Charity_Total_Real", "Uninsured_Rate",
      "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed", "Household_Income_2023", "Population"
    ),
    label = c(
      "Temperature Z-score (1990-2000 baseline)",
      "Precipitation Z-score (1990-2000 baseline)",
      "Extreme Heat (High CDD indicator)",
      "Extreme Cold (High HDD indicator)",
      "PDSI annual mean",
      "Extreme Drought (PDSI <= -4)",
      "AQI Shock (z-score based)",
      "Medical Debt Share (%)",
      "Median Medical Debt (2023 USD)",
      "Benchmark Silver Premium (2023 USD)",
      "Lowest Bronze Premium (2023 USD)",
      "Hospital Bad Debt (2023 USD)",
      "Hospital Charity Care (2023 USD)",
      "Uninsured Rate",
      "Per Capita Personal Income (2023 USD)",
      "Median Household Income (2023 USD)",
      "Civilian Employed (count)",
      "Household Income from Debt Data (2023 USD)",
      "County Population"
    ),
    domain = c(
      rep("Climate and Air Quality", 7),
      rep("Health and Financial Outcomes", 7),
      rep("Socioeconomic Outcomes", 5)
    ),
    stringsAsFactors = FALSE
  )

  available_defs <- var_definitions %>% filter(var %in% names(study_df))
  missing_defs <- setdiff(var_definitions$var, available_defs$var)
  if (length(missing_defs) > 0) {
    cat("Warning: missing expected columns:", paste(missing_defs, collapse = ", "), "\n")
  }

  # -------------------------------------------------------------------------
  # Table 1: Main descriptive statistics
  # -------------------------------------------------------------------------
  cat("Computing publication-grade descriptive table...\n")
  stats_df <- bind_rows(lapply(seq_len(nrow(available_defs)), function(i) {
    summarize_variable(
      df = study_df,
      var_name = available_defs$var[i],
      var_label = available_defs$label[i],
      domain_name = available_defs$domain[i],
      weight_var = "Population"
    )
  }))

  numeric_cols <- c(
    "Missing_Pct", "Mean", "SD", "Winsor_Mean_P1_P99", "Min", "P10", "P25",
    "Median", "P75", "P90", "Max", "W_Mean", "W_SD"
  )
  stats_df[numeric_cols] <- lapply(stats_df[numeric_cols], function(x) round(x, 4))

  write.csv(stats_df, file.path(output_dir, "descriptive_stats_summary.csv"), row.names = FALSE)

  table_main <- stats_df %>%
    transmute(
      Domain,
      Variable,
      N,
      `Mean (SD)` = ifelse(
        is.na(Mean),
        NA_character_,
        paste0(format_num(Mean, 3), " (", format_num(SD, 3), ")")
      ),
      `P25 | Median | P75` = ifelse(
        is.na(Median),
        NA_character_,
        paste0(format_num(P25, 3), " | ", format_num(Median, 3), " | ", format_num(P75, 3))
      ),
      `P10 | P90` = ifelse(
        is.na(P10),
        NA_character_,
        paste0(format_num(P10, 3), " | ", format_num(P90, 3))
      ),
      `Min | Max` = ifelse(
        is.na(Min),
        NA_character_,
        paste0(format_num(Min, 3), " | ", format_num(Max, 3))
      ),
      `Winsor Mean (P1-P99)` = format_num(Winsor_Mean_P1_P99, 3),
      `Pop-Wtd Mean` = format_num(W_Mean, 3),
      `Missing %` = format_pct(Missing_Pct, 1)
    )

  write.csv(table_main, file.path(output_dir, "descriptive_stats_table_main.csv"), row.names = FALSE)
  write_latex_table(
    table_main,
    path = file.path(output_dir, "descriptive_stats_table_main.tex"),
    caption = "Descriptive Statistics: County-Level Panel (2011--2023)",
    label = "tab:desc_main"
  )

  # -------------------------------------------------------------------------
  # Missingness diagnostics
  # -------------------------------------------------------------------------
  cat("Computing missingness diagnostics...\n")
  missingness_by_year <- study_df %>%
    group_by(Year) %>%
    summarize(
      across(
        all_of(available_defs$var),
        ~ mean(is.na(.x)) * 100,
        .names = "{.col}_MissingPct"
      ),
      .groups = "drop"
    )
  write.csv(missingness_by_year, file.path(output_dir, "descriptive_missingness_by_year.csv"), row.names = FALSE)

  missingness_summary <- stats_df %>%
    select(Domain, Variable, Raw_Variable, N, Missing_Pct) %>%
    arrange(desc(Missing_Pct))
  write.csv(missingness_summary, file.path(output_dir, "descriptive_missingness_summary.csv"), row.names = FALSE)

  # -------------------------------------------------------------------------
  # Early/Late comparison table
  # -------------------------------------------------------------------------
  cat("Computing period-comparison table...\n")
  period_df <- study_df %>%
    mutate(Period = ifelse(Year <= 2016, "2011-2016", "2017-2023"))

  period_vars <- c(
    "High_CDD", "High_HDD", "Is_Extreme_Drought",
    "Medical_Debt_Share", "Medical_Debt_Median_2023",
    "Benchmark_Silver_Real", "Lowest_Bronze_Real", "Uninsured_Rate",
    "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed"
  )
  period_defs <- available_defs %>% filter(var %in% period_vars)

  period_comp <- bind_rows(lapply(seq_len(nrow(period_defs)), function(i) {
    period_summary(
      df = period_df,
      var_name = period_defs$var[i],
      label = period_defs$label[i],
      domain_name = period_defs$domain[i]
    )
  }))
  period_comp <- period_comp %>%
    mutate(across(where(is.numeric), ~ round(.x, 4)))
  write.csv(period_comp, file.path(output_dir, "descriptive_period_comparison.csv"), row.names = FALSE)

  period_table <- period_comp %>%
    transmute(
      Domain,
      Variable,
      `2011-2016 Mean` = format_num(Early_Mean, 3),
      `2017-2023 Mean` = format_num(Late_Mean, 3),
      `Difference` = format_num(Diff_Late_minus_Early, 3),
      `% Change` = format_pct(Pct_Change, 1),
      `Pop-Wtd Diff` = format_num(W_Diff_Late_minus_Early, 3),
      `Pop-Wtd % Change` = format_pct(W_Pct_Change, 1)
    )
  write_latex_table(
    period_table,
    path = file.path(output_dir, "descriptive_period_comparison.tex"),
    caption = "Early vs Late Period Comparison (2011--2016 vs 2017--2023)",
    label = "tab:desc_period"
  )

  writeLines(
    c(
      "% Compile in Analysis/: pdflatex descriptive_tables.tex",
      "\\documentclass[11pt]{article}",
      "\\usepackage[margin=1in]{geometry}",
      "\\usepackage{booktabs}",
      "\\usepackage{array}",
      "\\usepackage[T1]{fontenc}",
      "\\begin{document}",
      "\\section*{Descriptive Statistics Tables}",
      "\\input{descriptive_stats_table_main.tex}",
      "\\clearpage",
      "\\input{descriptive_period_comparison.tex}",
      "\\end{document}",
      ""
    ),
    con = file.path(output_dir, "descriptive_tables.tex")
  )

  # -------------------------------------------------------------------------
  # Correlation matrix for key descriptive variables
  # -------------------------------------------------------------------------
  cat("Computing correlation matrix...\n")
  corr_vars <- c(
    "Z_Temp", "Z_Precip", "High_CDD", "High_HDD", "Is_Extreme_Drought", "AQI_Shock",
    "Medical_Debt_Share", "Benchmark_Silver_Real", "Uninsured_Rate",
    "PCPI_Real", "Med_HH_Income_Real"
  )
  corr_vars <- intersect(corr_vars, names(study_df))
  corr_data <- study_df %>% select(all_of(corr_vars))
  corr_mat <- suppressWarnings(cor(corr_data, use = "pairwise.complete.obs"))
  corr_mat <- round(corr_mat, 4)
  write.csv(corr_mat, file.path(output_dir, "descriptive_correlation_matrix.csv"), row.names = TRUE)

  # -------------------------------------------------------------------------
  # Figure 1: Climate shock prevalence (county share and population-weighted share)
  # -------------------------------------------------------------------------
  cat("Generating Figure 1: climate shock prevalence...\n")
  shock_defs <- data.frame(
    var = c("High_CDD", "High_HDD", "Is_Extreme_Drought"),
    label = c("Extreme Heat (High CDD)", "Extreme Cold (High HDD)", "Extreme Drought (PDSI <= -4)"),
    stringsAsFactors = FALSE
  ) %>% filter(var %in% names(study_df))

  shock_series <- bind_rows(lapply(seq_len(nrow(shock_defs)), function(i) {
    v <- shock_defs$var[i]
    lbl <- shock_defs$label[i]
    study_df %>%
      group_by(Year) %>%
      summarize(
        n_obs = sum(!is.na(.data[[v]])),
        county_share = mean(.data[[v]], na.rm = TRUE),
        pop_share = weighted_mean_safe(.data[[v]], Population),
        .groups = "drop"
      ) %>%
      mutate(
        Shock = lbl,
        county_share_pct = county_share * 100,
        pop_share_pct = pop_share * 100,
        se = sqrt(pmax(county_share * (1 - county_share) / pmax(n_obs, 1), 0)),
        ci_low_pct = pmax((county_share - 1.96 * se) * 100, 0),
        ci_high_pct = pmin((county_share + 1.96 * se) * 100, 100)
      )
  }))

  p1 <- ggplot(shock_series, aes(x = Year)) +
    geom_ribbon(
      aes(ymin = ci_low_pct, ymax = ci_high_pct),
      fill = "grey82",
      alpha = 0.45
    ) +
    geom_line(
      aes(y = county_share_pct, color = "County share"),
      linewidth = 0.9
    ) +
    geom_point(
      aes(y = county_share_pct, color = "County share"),
      size = 1.4
    ) +
    geom_line(
      aes(y = pop_share_pct, color = "Population-weighted share"),
      linewidth = 0.9,
      linetype = "22"
    ) +
    geom_point(
      aes(y = pop_share_pct, color = "Population-weighted share"),
      size = 1.4,
      shape = 17
    ) +
    scale_color_manual(values = c(
      "County share" = "#1b4f72",
      "Population-weighted share" = "#af601a"
    )) +
    scale_x_continuous(breaks = seq(2011, 2023, 2)) +
    scale_y_continuous(labels = function(x) paste0(round(x, 1), "%")) +
    facet_wrap(~Shock, ncol = 1) +
    labs(
      title = "Figure 1. Climate Shock Prevalence Across U.S. Counties",
      subtitle = "Ribbon shows 95% CI around county-share prevalence",
      y = "Share of counties/population"
    ) +
    journal_theme(base_size = 11)

  ggsave(file.path(plot_dir, "fig1_climate_shock_prevalence.png"), p1, width = 8, height = 9, dpi = 320, bg = "white")
  ggsave(file.path(plot_dir, "ts_climate_shocks.png"), p1, width = 8, height = 9, dpi = 200, bg = "white")

  # -------------------------------------------------------------------------
  # Figure 2: Outcome indices (2011 = 100), population weighted
  # -------------------------------------------------------------------------
  cat("Generating Figure 2: indexed outcome trends...\n")
  trend_defs <- data.frame(
    var = c(
      "Benchmark_Silver_Real",
      "Medical_Debt_Median_2023",
      "Medical_Debt_Share",
      "Uninsured_Rate",
      "PCPI_Real",
      "Med_HH_Income_Real"
    ),
    label = c(
      "Benchmark Silver Premium",
      "Median Medical Debt",
      "Medical Debt Share",
      "Uninsured Rate",
      "Per Capita Personal Income",
      "Median Household Income"
    ),
    stringsAsFactors = FALSE
  ) %>% filter(var %in% names(study_df))

  trend_series <- bind_rows(lapply(seq_len(nrow(trend_defs)), function(i) {
    v <- trend_defs$var[i]
    lbl <- trend_defs$label[i]

    annual <- study_df %>%
      group_by(Year) %>%
      summarize(
        value = weighted_mean_safe(.data[[v]], Population),
        n_obs = sum(!is.na(.data[[v]])),
        .groups = "drop"
      ) %>%
      arrange(Year)

    base_val <- annual$value[annual$Year == 2011]
    if (length(base_val) == 0 || is.na(base_val)) {
      base_val <- annual$value[which(!is.na(annual$value))[1]]
    }
    annual %>%
      mutate(
        Metric = lbl,
        Index_2011_100 = (value / base_val) * 100
      )
  }))

  p2 <- ggplot(trend_series, aes(x = Year, y = Index_2011_100)) +
    geom_hline(yintercept = 100, color = "grey60", linewidth = 0.4, linetype = "22") +
    geom_line(color = "#1f618d", linewidth = 0.9) +
    geom_point(color = "#1f618d", size = 1.5) +
    scale_x_continuous(breaks = seq(2011, 2023, 2)) +
    facet_wrap(~Metric, scales = "free_y", ncol = 2) +
    labs(
      title = "Figure 2. Population-Weighted Trends, Indexed to 2011 = 100",
      subtitle = "Each panel reports annual county aggregates weighted by county population",
      y = "Index (2011 = 100)"
    ) +
    journal_theme(base_size = 11)

  trend_series_plot <- trend_series %>% filter(!is.na(Index_2011_100))
  p2 <- p2 %+% trend_series_plot

  ggsave(file.path(plot_dir, "fig2_outcome_index_trends.png"), p2, width = 10, height = 7, dpi = 320, bg = "white")
  ggsave(file.path(plot_dir, "ts_outcomes.png"), p2, width = 10, height = 7, dpi = 200, bg = "white")

  # Legacy income trend file for existing references
  income_df <- trend_series %>%
    filter(Metric %in% c("Per Capita Personal Income", "Median Household Income")) %>%
    filter(!is.na(Index_2011_100))
  p_income <- ggplot(income_df, aes(x = Year, y = Index_2011_100, color = Metric, group = Metric)) +
    geom_hline(yintercept = 100, color = "grey60", linewidth = 0.4, linetype = "22") +
    geom_line(linewidth = 1) +
    geom_point(size = 1.8) +
    scale_color_manual(values = c(
      "Per Capita Personal Income" = "#1f618d",
      "Median Household Income" = "#148f77"
    )) +
    scale_x_continuous(breaks = seq(2011, 2023, 2)) +
    labs(
      title = "Income Trends (Population-Weighted, 2011 = 100)",
      subtitle = "County panel, 2011-2023",
      y = "Index (2011 = 100)"
    ) +
    journal_theme(base_size = 11)
  ggsave(file.path(plot_dir, "ts_income.png"), p_income, width = 8.5, height = 5, dpi = 200, bg = "white")

  # -------------------------------------------------------------------------
  # Figure 3: Distribution shifts (early vs late period)
  # -------------------------------------------------------------------------
  cat("Generating Figure 3: distribution shifts...\n")
  dist_defs <- data.frame(
    var = c(
      "Medical_Debt_Median_2023",
      "Benchmark_Silver_Real",
      "Hosp_BadDebt_Total_Real",
      "Hosp_Charity_Total_Real"
    ),
    label = c(
      "Median Medical Debt (2023 USD)",
      "Benchmark Silver Premium (2023 USD)",
      "Hospital Bad Debt (log1p, 2023 USD)",
      "Hospital Charity Care (log1p, 2023 USD)"
    ),
    transform = c("identity", "identity", "log1p", "log1p"),
    stringsAsFactors = FALSE
  ) %>% filter(var %in% names(period_df))

  dist_data <- bind_rows(lapply(seq_len(nrow(dist_defs)), function(i) {
    v <- dist_defs$var[i]
    lbl <- dist_defs$label[i]
    tfm <- dist_defs$transform[i]
    tmp <- period_df %>%
      filter(!is.na(.data[[v]])) %>%
      mutate(
        Variable = lbl,
        Value = {
          raw <- as.numeric(.data[[v]])
          if (tfm == "log1p") {
            out <- rep(NA_real_, length(raw))
            keep <- !is.na(raw) & raw > -1
            out[keep] <- log1p(raw[keep])
            out
          } else {
            raw
          }
        }
      ) %>%
      select(Period, Variable, Value)
    tmp
  }))

  dist_data <- dist_data %>% filter(is.finite(Value))

  p3 <- ggplot(dist_data, aes(x = Value, fill = Period, color = Period)) +
    geom_density(alpha = 0.22, linewidth = 0.7, adjust = 1.05) +
    scale_fill_manual(values = c("2011-2016" = "#1f618d", "2017-2023" = "#ca6f1e")) +
    scale_color_manual(values = c("2011-2016" = "#1f618d", "2017-2023" = "#ca6f1e")) +
    facet_wrap(~Variable, scales = "free", ncol = 2) +
    labs(
      title = "Figure 3. Distributional Shifts: Early vs Late Study Period",
      subtitle = "Density plots compare county-year distributions across periods",
      y = "Density",
      x = "Value (raw units; log1p used for hospital amounts)"
    ) +
    journal_theme(base_size = 11)

  ggsave(file.path(plot_dir, "fig3_distribution_shift.png"), p3, width = 10, height = 7, dpi = 320, bg = "white")

  # -------------------------------------------------------------------------
  # Report generation
  # -------------------------------------------------------------------------
  cat("Writing manuscript-style descriptive report...\n")
  panel_counties <- dplyr::n_distinct(study_df$fips_code)
  panel_obs <- nrow(study_df)
  year_min <- min(study_df$Year, na.rm = TRUE)
  year_max <- max(study_df$Year, na.rm = TRUE)

  shock_overall <- shock_series %>%
    group_by(Shock) %>%
    summarize(
      county_avg = mean(county_share_pct, na.rm = TRUE),
      pop_avg = mean(pop_share_pct, na.rm = TRUE),
      .groups = "drop"
    )

  get_period_row <- function(raw_var) {
    row <- period_comp %>% filter(Raw_Variable == raw_var)
    if (nrow(row) == 0) {
      return(NULL)
    }
    row[1, ]
  }

  premium_row <- get_period_row("Benchmark_Silver_Real")
  debt_share_row <- get_period_row("Medical_Debt_Share")
  uninsured_row <- get_period_row("Uninsured_Rate")
  pcpi_row <- get_period_row("PCPI_Real")

  top_missing <- missingness_summary %>%
    slice_head(n = 5) %>%
    mutate(line = paste0("- ", Variable, ": ", format_pct(Missing_Pct, 1))) %>%
    pull(line)

  shock_lines <- shock_overall %>%
    mutate(
      line = paste0(
        "- ", Shock, ": county-share average ", format_pct(county_avg, 1),
        ", population-weighted average ", format_pct(pop_avg, 1), "."
      )
    ) %>%
    pull(line)

  report_lines <- c(
    "# Descriptive Statistics Report: County-Level Panel",
    "",
    paste0("**Generated:** ", Sys.Date()),
    paste0("**Panel:** ", format(panel_counties, big.mark = ","), " U.S. counties, ",
           year_min, "-", year_max, " (", format(panel_obs, big.mark = ","), " county-year observations)"),
    "**Script:** `Code/run_descriptive_stats.R`",
    "**Input data:** `Data/county_level_master.csv`",
    "",
    "---",
    "",
    "## 1. Sample Construction and Coverage",
    "",
    paste0(
      "- Balanced county identifiers: ",
      format(panel_counties, big.mark = ","),
      " counties observed between ",
      year_min, " and ", year_max, "."
    ),
    "- Analysis uses unbalanced outcome coverage where source data are not universal (AQI monitors, HIX, and hospital filings).",
    "- Core climate series (temperature, precipitation, drought) are near-complete with low missingness.",
    if (applied_debt_exclusion) paste0(
      "- For debt outcomes, applied reporting-rule exclusion window(s): ",
      paste(debt_exclusion_policy_used, collapse = "; "),
      " (", format(debt_excluded_county_years, big.mark = ","), " county-year observations removed from debt variables)."
    ) else NULL,
    "",
    "Main output tables:",
    "- `Analysis/descriptive_stats_summary.csv`: numeric table with tails, winsorized moments, and weighted moments.",
    "- `Analysis/descriptive_stats_table_main.csv`: manuscript-ready condensed table.",
    "- `Analysis/descriptive_stats_table_main.tex`: LaTeX table for manuscript integration.",
    "- `Analysis/descriptive_period_comparison.csv`: early vs late period changes.",
    "- `Analysis/descriptive_period_comparison.tex`: LaTeX period-comparison table.",
    "- `Analysis/descriptive_tables.tex`: compile-ready LaTeX document with both descriptive tables.",
    "- `Analysis/descriptive_missingness_by_year.csv`: annual missingness diagnostics.",
    "- `Analysis/descriptive_correlation_matrix.csv`: pairwise correlation matrix for core variables.",
    "",
    "---",
    "",
    "## 2. Climate Shock Prevalence",
    "",
    "Average prevalence over 2011-2023:",
    shock_lines,
    "",
    "Interpretation:",
    "- Extreme heat is materially more common than extreme drought at the county-year level.",
    "- Population-weighted prevalence differs from county-share prevalence, indicating non-random exposure by county size.",
    "",
    "---",
    "",
    "## 3. Health and Economic Outcomes: Early vs Late Period",
    "",
    if (!is.null(premium_row)) paste0(
      "- Benchmark Silver premium: ",
      format_dollar(premium_row$Early_Mean, 0), " (2011-2016 mean) to ",
      format_dollar(premium_row$Late_Mean, 0), " (2017-2023 mean), change ",
      format_pct(premium_row$Pct_Change, 1), " unweighted."
    ) else NULL,
    if (!is.null(debt_share_row)) paste0(
      "- Medical debt share: ",
      format_num(debt_share_row$Early_Mean, 3), " to ",
      format_num(debt_share_row$Late_Mean, 3), ", change ",
      format_pct(debt_share_row$Pct_Change, 1), "."
    ) else NULL,
    if (!is.null(uninsured_row)) paste0(
      "- Uninsured rate: ",
      format_num(uninsured_row$Early_Mean, 3), " to ",
      format_num(uninsured_row$Late_Mean, 3), ", change ",
      format_pct(uninsured_row$Pct_Change, 1), "."
    ) else NULL,
    if (!is.null(pcpi_row)) paste0(
      "- Per capita personal income (real): ",
      format_dollar(pcpi_row$Early_Mean, 0), " to ",
      format_dollar(pcpi_row$Late_Mean, 0), ", change ",
      format_pct(pcpi_row$Pct_Change, 1), "."
    ) else NULL,
    "",
    "Interpretation:",
    "- Real income growth is strong in the late period, while insurance and debt outcomes move on different trajectories.",
    "- These descriptive differences motivate panel fixed-effects models with lag structures and differential exposure measures.",
    "",
    "---",
    "",
    "## 4. Missing-Data Diagnostics",
    "",
    "Highest-missing variables in the study sample:",
    top_missing,
    "",
    "Implications for econometric work:",
    "- AQI, premium, and hospital variables require unbalanced-panel inference and sensitivity checks.",
    "- Population-weighted and unweighted specifications should both be reported where feasible.",
    "",
    "---",
    "",
    "## 5. Figures for Manuscript Use",
    "",
    "- `Analysis/plots/fig1_climate_shock_prevalence.png`",
    "- `Analysis/plots/fig2_outcome_index_trends.png`",
    "- `Analysis/plots/fig3_distribution_shift.png`",
    "",
    "Legacy compatibility outputs retained:",
    "- `Analysis/plots/ts_climate_shocks.png`",
    "- `Analysis/plots/ts_outcomes.png`",
    "- `Analysis/plots/ts_income.png`"
  )

  report_lines <- report_lines[!is.na(report_lines)]
  writeLines(report_lines, con = file.path(output_dir, "descriptive_stats_report.md"))

  cat("Done. Outputs written to Analysis/ and Analysis/plots/.\n")

  invisible(list(
    stats = stats_df,
    period = period_comp,
    missingness_by_year = missingness_by_year,
    correlations = corr_mat
  ))
}

if (!isTRUE(getOption("descriptive_stats.test_mode", FALSE))) {
  run_descriptive_stats()
}
