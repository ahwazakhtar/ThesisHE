# R script to create the Master County-Level Analysis Dataset (Optimized)
library(dplyr)
library(tidyr)
library(readr)

# =============================================================================
# ## One-row-per-county-year enforcement (2026-07-13) — DEFENSE DOCUMENTATION
# =============================================================================
# (thesis_completion_20260704 task 2.2 / spec T1.2; closes the
#  county_analysis_refinement_20260216 deferred one-row-per-county-year item.)
#
# CAUSE. ACA benchmark/bronze premiums are set at the geographic RATING-AREA
#   level. Most counties belong to exactly one rating area, but where a state
#   defines rating areas by 3-digit ZIP or by MSA a single county can straddle
#   MORE THAN ONE rating area. The premium source (Data/premiums_county.csv, built
#   by process_rating_area_map.R from the HIX county<->rating-area crosswalk) then
#   carries one row per county x year x rating_area, and the premium LEFT JOIN
#   below (master <- ... left_join(df_premiums, by = c("fips_code","Year"))) fans
#   those out into DUPLICATE county-year rows. Diagnosed on the pre-dedup master
#   (see Analysis/county_dedup_integrity.md):
#     * 484 duplicate county-year GROUPS, 568 EXTRA rows (all years);
#       428 groups / 497 extra rows within the 2011-2023 outcome window.
#     * group sizes: 413 x2, 58 x3, 13 x4 rating areas.
#     * concentrated in NE (199 groups), AK (140), MA (92), ID (40), CA (13);
#       entirely within 2014-2026 (the premium window — no pre-2014 duplicates).
#   These are ~1.2% of 2011-2023 county-years. Downstream consumers that read the
#   raw master and treat rows as independent observations (run_county_analysis.R,
#   the DiD/RE panel loads) DOUBLE-COUNT split counties: inflated N, understated
#   clustered SEs, and distorted population weighting. That is the bug this fixes.
#
# WHAT VARIES vs WHAT IS CONSTANT WITHIN A DUPLICATE GROUP (verified, Step 0).
#   ONLY the five premium / rating-area-derived columns differ across a split
#   county's rows: rating_area_id (all 484 groups, by construction),
#   Benchmark_Silver (418), Lowest_Bronze (417), Benchmark_Silver_Real (399),
#   Lowest_Bronze_Real (398). EVERY other column — the medical-debt outcomes, all
#   climate shocks + lags, AQI, Population, PCPI/income/employment, hospital
#   accounts — is CONSTANT within fips_code x Year (0 groups varying). County
#   climate/economic variables are county-level objects; they cannot differ by
#   rating area. This is what makes a first()-collapse of the non-premium columns
#   PROVABLY LOSSLESS (asserted at run time; the build aborts otherwise).
#
# THE RULE (committee-defensible).
#   * Non-premium columns  -> first() AFTER a stopifnot() that every one is
#       constant within fips_code x Year. Lossless (they are identical across the
#       group's rows), so first() is order-independent and information-preserving.
#   * Premium columns (Benchmark_Silver, Lowest_Bronze, Benchmark_Silver_Real,
#       Lowest_Bronze_Real) -> UNWEIGHTED MEAN across the county's rating areas
#       (NA-aware; all-NA -> NA, never NaN). Interpretation: the premium faced by a
#       representative resident of a county that spans several rating areas, giving
#       every rating area the county touches equal say. Deterministic, symmetric,
#       and uses all rating-area information. Within-county rating-area premium
#       dispersion is modest (benchmark range mean $45.79/mo, median $33.37/mo =
#       ~9% of the ~$483/mo split-county mean; 57/456 groups have ZERO dispersion),
#       and the headline coefficients are shown rule-invariant vs a min-rating-area
#       selection alternative (Analysis/county_dedup_integrity.md).
#   * rating_area_id -> the deterministic MINIMUM (alphabetically-first) id the
#       county touches, kept only as a representative label so the rating-area
#       clustering / aggregation robustness variants in run_county_analysis.R still
#       run; the premium a split county now carries is the cross-area MEAN, not that
#       one area's premium.
#
# REJECTED ALTERNATIVES (and why).
#   (i)   enrollment-weighted mean ("premium faced by the average enrollee") —
#         BEST in principle, but INFEASIBLE: the HIX crosswalk and plan files carry
#         no county x rating-area enrollment (or any county-level enrollment) weight.
#   (ii)  county-population-share-weighted mean — INFEASIBLE: we have whole-county
#         Population but no SUB-county split of a county's population across the
#         rating areas it straddles, so no defensible share weight exists.
#   (iii) unweighted mean across rating areas — CHOSEN (see above).
#   (iv)  first()-by-sort-order on the premium — REJECTED as the production rule:
#         it is the non-deterministic downstream STOPGAP being retired here
#         (run_premium_mediation.R / run_latent_hardship.R); it discards information
#         and depends on row order. (It IS used, harmlessly, for the constant
#         non-premium columns, where every row is identical.)
#
# ENFORCEMENT. After all joins + inflation adjustment (so the assertion covers
#   EVERY downstream analysis column, not just the columns present at the premium
#   merge) this script: (1) stopifnot() non-premium constancy within fips x Year;
#   (2) collapses per the rule; (3) stopifnot() one row per (fips_code, Year); and
#   (4) checks the output row count equals pre-dedup rows minus the extra duplicate
#   rows (definitional) and lands in a sane absolute band. The before/after
#   coefficient comparison and rule-robustness table are in
#   Analysis/county_dedup_integrity.md.
# =============================================================================

# Paths
path_med_debt   <- "Data/medical_debt_county.csv"
path_premiums   <- "Data/premiums_county.csv"
path_cpi        <- "Data/State_Policy_Data/us_cpi_annual.csv"
path_pop_rds    <- "Data/intermediate_pop.rds"
path_climate_rds <- "Data/intermediate_climate.rds"
path_aqi_rds    <- "Data/intermediate_aqi.rds"
path_socio_rds  <- "Data/intermediate_socioeconomic.rds"
output_path     <- "Data/county_level_master.csv"

cat("Consolidating County-Level Master Dataset...\n")

# 1. Load Pre-processed Data -----------------------------------------------
if (!file.exists(path_pop_rds)) stop("Run Code/process_county_population.R first.")
if (!file.exists(path_climate_rds)) stop("Run Code/process_county_climate.R first.")
if (!file.exists(path_aqi_rds)) stop("Run Code/process_county_aqi.R first.")
if (!file.exists(path_socio_rds)) stop("Run Code/download_county_socioeconomic.R then Code/process_county_socioeconomic.R first.")

df_pop     <- readRDS(path_pop_rds)
df_climate <- readRDS(path_climate_rds)
df_aqi     <- readRDS(path_aqi_rds)
df_socio   <- readRDS(path_socio_rds)

# 2. Load Other Datasets --------------------------------------------------
cat("Loading Outcomes & Policy Data...\n")
df_med_debt <- read.csv(path_med_debt, colClasses = c("fips_code"="character"))
df_premiums <- read.csv(path_premiums, colClasses = c("fips_code"="character"))
df_cpi <- read.csv(path_cpi, stringsAsFactors = FALSE)

# 3. Merge ----------------------------------------------------------------
cat("Merging...\n")

# Build an outcome-neutral key skeleton to avoid anchoring all analyses
# to medical debt coverage. This preserves county-years that only appear in
# premiums/climate/AQI/socioeconomic sources.
keys_med <- df_med_debt %>% select(fips_code, Year)
keys_prem <- df_premiums %>% select(fips_code, Year)
keys_climate <- df_climate %>% select(fips_code, Year)
keys_pop <- df_pop %>% select(fips_code, Year)
keys_aqi <- df_aqi %>% select(fips_code, Year)
keys_socio <- df_socio %>% select(fips_code, Year)

master_keys <- bind_rows(keys_med, keys_prem, keys_climate, keys_pop, keys_aqi, keys_socio) %>%
  distinct()

# County state lookup (fips_code -> State) from available source state labels.
state_lookup <- bind_rows(
  df_med_debt %>% select(fips_code, State),
  df_premiums %>% select(fips_code, State)
) %>%
  filter(!is.na(State), State != "") %>%
  group_by(fips_code) %>%
  summarize(State = dplyr::first(State), .groups = "drop")

drop_state <- function(df) {
  if ("State" %in% names(df)) {
    df %>% select(-State)
  } else {
    df
  }
}

# Master Join (outcome-neutral skeleton + source tables)
master <- master_keys %>%
  left_join(state_lookup, by = "fips_code") %>%
  left_join(drop_state(df_med_debt), by = c("fips_code", "Year")) %>%
  left_join(drop_state(df_premiums), by = c("fips_code", "Year")) %>%
  left_join(df_climate, by = c("fips_code", "Year")) %>%
  left_join(df_pop, by = c("fips_code", "Year"))

# 4. AQI Join (FIPS-based) ------------------------------------------------
# Join using fips_code and Year
master <- master %>%
  left_join(df_aqi %>% select(fips_code, Year, Median_AQI, Max_AQI,
                              any_of(c("AQI_Shock", "AQI_Shock_Lag1", "AQI_Shock_Lag2",
                                       "Delta_Median_AQI", "Delta_Max_AQI",
                                       "Delta_Median_AQI_Pos", "Delta_Median_AQI_Neg",
                                       "Delta_Max_AQI_Pos", "Delta_Max_AQI_Neg"))),
            by = c("fips_code", "Year"))

# 4b. Socioeconomic Outcomes Join -----------------------------------------
# PCPI_Real: BEA per capita personal income (2023 dollars, 2001+)
# Total_Employment: BEA total jobs count (2001+)
# Med_HH_Income_Real: ACS 5-yr median household income (2023 dollars, 2009+)
master <- master %>%
  left_join(df_socio, by = c("fips_code", "Year"))

# 5. Inflation Adjustment (Base 2023) -------------------------------------
cat("Adjusting Inflation (Base 2023)...\n")
cpi_2023 <- df_cpi$CPI_Value[df_cpi$Year == 2023]

master <- master %>%
  left_join(df_cpi, by = "Year") %>%
  mutate(
    CPI_Factor = cpi_2023 / CPI_Value,
    Benchmark_Silver_Real = Benchmark_Silver * CPI_Factor,
    Lowest_Bronze_Real = Lowest_Bronze * CPI_Factor,
    Hosp_BadDebt_Total_Real = if("Hosp_BadDebt_Total" %in% names(.)) Hosp_BadDebt_Total * CPI_Factor else NA,
    Hosp_Charity_Total_Real = if("Hosp_Charity_Total" %in% names(.)) Hosp_Charity_Total * CPI_Factor else NA
  ) %>%
  select(-CPI_Value, -CPI_Factor)

# 6. One-row-per-county-year enforcement ----------------------------------
# See the DEFENSE-DOCUMENTATION header block at the top of this script for the
# cause, the rule, the rejected alternatives, and the constancy proof. Done here
# (after every join + inflation adjustment) so the constancy assertion covers all
# downstream analysis columns. The ONLY source of county-year duplication upstream
# is the rating-area premium fan-out; the medical-debt, climate, AQI, population,
# socioeconomic, and CPI joins are all unique on their keys.

# Columns collapsed by unweighted mean across the county's rating areas.
premium_avg_cols <- intersect(
  c("Benchmark_Silver", "Lowest_Bronze", "Benchmark_Silver_Real", "Lowest_Bronze_Real"),
  names(master))
# rating_area_id is kept as the deterministic minimum representative id.
ra_id_col   <- intersect("rating_area_id", names(master))
key_cols    <- c("fips_code", "Year")
# Every remaining column must be constant within fips_code x Year (asserted below),
# then collapsed by first() — provably lossless.
const_cols  <- setdiff(names(master), c(key_cols, premium_avg_cols, ra_id_col))

orig_names  <- names(master)
n_pre       <- nrow(master)

dup_keys     <- master %>% count(fips_code, Year) %>% filter(n > 1)
n_dup_groups <- nrow(dup_keys)
n_extra_rows <- sum(dup_keys$n) - n_dup_groups

dedup_log <- c(
  "--- create_county_master.R one-row-per-county-year enforcement ---",
  paste0("Run: ", format(Sys.time())),
  paste0("Pre-dedup rows: ", n_pre),
  paste0("Duplicate county-year groups: ", n_dup_groups,
         " | extra rows: ", n_extra_rows)
)

# (1) Constancy assertion on the non-premium columns (dup groups only — singleton
#     groups are trivially constant). Aborts the build if the collapse would lose
#     information, i.e. if any non-premium analysis column varies within a group.
if (n_dup_groups > 0) {
  viol <- master %>%
    semi_join(dup_keys, by = key_cols) %>%
    group_by(fips_code, Year) %>%
    summarise(across(all_of(const_cols), ~ dplyr::n_distinct(.x)), .groups = "drop")
  max_distinct <- vapply(viol[const_cols], max, numeric(1))
  offending    <- names(max_distinct)[max_distinct > 1]
  if (length(offending) > 0) {
    stop("County-master dedup ABORTED: non-premium column(s) vary within ",
         "fips_code x Year: ", paste(offending, collapse = ", "),
         ". The premium-mean / first() collapse is lossless ONLY if every ",
         "non-premium column is constant within the group. Investigate before ",
         "overriding — a varying non-premium column means the duplicate rows are ",
         "NOT pure rating-area splits.")
  }
  dedup_log <- c(dedup_log,
    paste0("Constancy assertion PASSED: all ", length(const_cols),
           " non-premium columns constant within every duplicate group."))
}

# (2) Collapse. Arrange by rating_area_id so first(rating_area_id) is the
#     deterministic minimum (NA sorts last); mean() over rating areas for premiums.
collapse_premium_mean <- function(x) {
  m <- mean(x, na.rm = TRUE)
  if (is.nan(m)) NA_real_ else m
}
master <- master %>%
  { if (length(ra_id_col) == 1) arrange(., fips_code, Year, .data[[ra_id_col]])
    else arrange(., fips_code, Year) } %>%
  group_by(fips_code, Year) %>%
  summarise(
    across(all_of(const_cols), dplyr::first),
    across(all_of(ra_id_col),  dplyr::first),          # min representative id
    across(all_of(premium_avg_cols), collapse_premium_mean),
    .groups = "drop") %>%
  select(all_of(orig_names))                            # restore original col order

# (3) Uniqueness assertion — the core guarantee of this task.
stopifnot(!anyDuplicated(paste(master$fips_code, master$Year)))

# (4) Row-count band. Definitional exact check (collapsing k-row groups to 1 drops
#     exactly sum(n)-n_groups rows) plus a coarse absolute band as a defense guard.
n_out         <- nrow(master)
expected_rows <- n_pre - n_extra_rows
stopifnot(n_out == expected_rows)
stopifnot(n_out >= 110000L, n_out <= n_pre)             # sane absolute band
dedup_log <- c(dedup_log,
  paste0("Collapsed premium columns by unweighted rating-area MEAN: ",
         paste(premium_avg_cols, collapse = ", ")),
  paste0("Post-dedup rows: ", n_out, " (expected ", expected_rows,
         " = ", n_pre, " - ", n_extra_rows, ") -> EXACT match."),
  paste0("Unique on (fips_code, Year): TRUE | distinct counties: ",
         dplyr::n_distinct(master$fips_code)))

# Emit the enforcement log (build-time manifest for the dedup step).
log_dir <- "Analysis/county/build_logs"
dir.create(log_dir, showWarnings = FALSE, recursive = TRUE)
writeLines(dedup_log, file.path(log_dir, "create_county_master_dedup.log"))
cat(paste0(dedup_log, collapse = "\n"), "\n")

# 7. Final Output ---------------------------------------------------------
write.csv(master, output_path, row.names = FALSE)
cat(paste0("Success! Master Dataset saved to: ", output_path, "\n"))
cat(paste0("Rows: ", nrow(master), "\n"))
