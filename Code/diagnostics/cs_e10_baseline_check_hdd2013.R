# Essay-2 follow-up (2026-08-17): baseline check for the long-horizon CS cells.
#
# The e=10 compounding cells (HDD cohort g=2013, t=2023) are canonical CS 2x2s
# with a single pre-year (2012) by construction — the same structure that made
# the Essay-1 2012-drought income contrast fragile. This diagnostic replicates
# both cells and re-estimates them with the pooled pre-period {2011, 2012}
# (all the panel allows), plus full year-by-year treated-control gaps.
#
# Findings (recorded in master_evidence_table.md Row 17):
#   - Civilian_Employed: SURVIVES — -4,894 (pre=2012) vs -4,990 (pooled),
#     p~0.005 both; gap builds monotonically (-145 -> -2,644 -> -4,513 -> -4,895).
#   - Medical_Debt_Share (+4.9pp): NOT baseline-fragile but SINGLE-YEAR-DRIVEN —
#     gap ~0 through 2022 (2018 p=.89, 2022 p=.27); entire gap appears in 2023,
#     the bureau reporting-regime-change year. Demoted from compounding evidence.
#
# Output: Analysis/did/cs_e10_baseline_check_hdd2013.csv

suppressPackageStartupMessages({ library(dplyr); library(readr); library(fixest) })

county_df <- read_csv("Data/county_level_master.csv",
                      show_col_types = FALSE, progress = FALSE)
excl <- toupper(trimws(as.character(county_df$State))) == "CO" & county_df$Year == 2023
county_df$Medical_Debt_Share[excl] <- NA_real_

panel <- county_df %>%
  distinct(fips_code, Year, State, High_HDD, Civilian_Employed, Medical_Debt_Share) %>%
  filter(Year >= 2011, Year <= 2023)

cohorts <- panel %>%
  filter(!is.na(High_HDD)) %>%
  group_by(fips_code) %>%
  summarise(first_event = suppressWarnings(min(Year[High_HDD == 1], na.rm = TRUE)),
            .groups = "drop") %>%
  mutate(first_event = if_else(is.finite(first_event), first_event, NA_real_),
         cohort = if_else(is.na(first_event), 0L, as.integer(first_event)))

treated <- cohorts$fips_code[cohorts$cohort == 2013L]
control <- cohorts$fips_code[cohorts$cohort == 0L]
cat(sprintf("HDD g=2013 treated: %d, never-exposed: %d\n", length(treated), length(control)))

rows <- list()
cell <- function(outcome, pre_years, t = 2023L) {
  d <- panel %>%
    filter(fips_code %in% c(treated, control), Year %in% c(pre_years, t),
           !is.na(.data[[outcome]])) %>%
    mutate(Treated = as.integer(fips_code %in% treated),
           Treated_x_Post = Treated * as.integer(Year == t))
  m <- feols(as.formula(paste(outcome, "~ Treated_x_Post | fips_code + Year")),
             data = d, cluster = "State")
  ct <- coeftable(m)
  cat(sprintf("  %-20s pre={%s}  ATT = %10.2f  SE = %9.2f  p = %.4f  N = %d\n",
              outcome, paste(pre_years, collapse = ","), ct[1,1], ct[1,2], ct[1,4], nobs(m)))
  data.frame(Check = "ATT_g2013_t2023", Outcome = outcome,
             Pre_Period = paste(pre_years, collapse = "+"), Year = t,
             Estimate = ct[1,1], Std_Error = ct[1,2], p_value = ct[1,4], N = nobs(m))
}

cat("\nATT(g=2013, t=2023) — e=10 cells:\n")
for (oc in c("Civilian_Employed", "Medical_Debt_Share")) {
  rows[[length(rows)+1]] <- cell(oc, 2012L)
  rows[[length(rows)+1]] <- cell(oc, c(2011L, 2012L))
}

# Year-by-year treated-control gaps, ref = 2012 (the CS anchor year)
for (oc in c("Civilian_Employed", "Medical_Debt_Share")) {
  d <- panel %>%
    filter(fips_code %in% c(treated, control), !is.na(.data[[oc]])) %>%
    mutate(Treated = as.integer(fips_code %in% treated))
  m <- feols(as.formula(paste(oc, "~ i(Year, Treated, ref = 2012) | fips_code + Year")),
             data = d, cluster = "State")
  ct <- as.data.frame(coeftable(m))
  rows[[length(rows)+1]] <- data.frame(
    Check = "yearly_gap_ref2012", Outcome = oc, Pre_Period = "ref=2012",
    Year = as.integer(gsub("Year::(\\d+):Treated", "\\1", rownames(ct))),
    Estimate = ct[,1], Std_Error = ct[,2], p_value = ct[,4], N = nobs(m))
}

res <- bind_rows(rows)
write.csv(res, "Analysis/did/cs_e10_baseline_check_hdd2013.csv", row.names = FALSE)
cat("\nWrote Analysis/did/cs_e10_baseline_check_hdd2013.csv\n")
