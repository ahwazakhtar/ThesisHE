# =============================================================================
# DiD Frontier-Robustness — Common Helpers
# =============================================================================
# Shared data construction for the DiD frontier-methods robustness layer
# (committee_feedback_april_2026, Phase 6). Sourced by 01-04.
#
# IMPORTANT — R VERSION: This robustness layer runs on **R 4.5.3**, NOT the
# project's main R 4.2.2. The packages it needs (DRDID, did, HonestDiD,
# fwildclusterboot) are unavailable on CRAN for R 4.2.2. The main pipeline is
# unchanged and still runs on 4.2.2.
#   Rscript path: "C:/Program Files/R/R-4.5.3/bin/Rscript.exe"
#
# Estimand note: the DiD "treated" cohort is defined by *first* extreme-drought
# onset (2012). Treatment is recurring, so post-2012 the cohort is actually in
# extreme drought only ~13% of county-years. The ATT is therefore an
# intent-to-treat / "effect of first drought onset" estimand, not the effect of
# being currently droughted. See spec.md.
#
# "Midwest" label: the 2012 extreme-PDSI cohort is concentrated in GA (45),
# CO (21), NE (17), NM (10) — i.e. Georgia + Mountain West + Plains, not the
# Midwest proper. The historical "2012 Midwest drought" name is retained for
# continuity with did_results.md but flagged here.
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
})

DID_ROB_SEED   <- 20260625L
MASTER_PATH    <- "Data/county_level_master.csv"
OUT_DIR        <- "Analysis/did/robustness"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# Outcomes carried through the robustness layer. Income & employment are the
# persistent real-economy outcomes that survive 11-year post-period averaging;
# the debt/premium outcomes are reported but expected to be noisier here.
DID_ROB_OUTCOMES <- c("PCPI_Real", "Civilian_Employed", "Med_HH_Income_Real",
                      "Medical_Debt_Share")

# 2-letter state abbreviation -> Census division (county master `State` is a
# 2-letter abbreviation per CLAUDE.md).
CENSUS_DIVISION <- c(
  CT="NewEngland", ME="NewEngland", MA="NewEngland", NH="NewEngland",
  RI="NewEngland", VT="NewEngland",
  NJ="MidAtlantic", NY="MidAtlantic", PA="MidAtlantic",
  IL="ENCentral", IN="ENCentral", MI="ENCentral", OH="ENCentral", WI="ENCentral",
  IA="WNCentral", KS="WNCentral", MN="WNCentral", MO="WNCentral",
  NE="WNCentral", ND="WNCentral", SD="WNCentral",
  DE="SAtlantic", FL="SAtlantic", GA="SAtlantic", MD="SAtlantic",
  NC="SAtlantic", SC="SAtlantic", VA="SAtlantic", DC="SAtlantic", WV="SAtlantic",
  AL="ESCentral", KY="ESCentral", MS="ESCentral", TN="ESCentral",
  AR="WSCentral", LA="WSCentral", OK="WSCentral", TX="WSCentral",
  AZ="Mountain", CO="Mountain", ID="Mountain", MT="Mountain", NV="Mountain",
  NM="Mountain", UT="Mountain", WY="Mountain",
  AK="Pacific", CA="Pacific", HI="Pacific", OR="Pacific", WA="Pacific"
)

# -----------------------------------------------------------------------------
# load_did_panel(): dedup county master, CO-2023 debt exclusion, restrict window
# -----------------------------------------------------------------------------
load_did_panel <- function(path = MASTER_PATH) {
  county_df <- read_csv(path, show_col_types = FALSE, progress = FALSE)

  # CO 2023 medical-debt reporting-rule exclusion (CLAUDE.md / run_did_analysis.R).
  if (all(c("State", "Year") %in% names(county_df))) {
    excl <- toupper(trimws(as.character(county_df$State))) == "CO" &
            as.integer(county_df$Year) == 2023L
    for (v in intersect(c("Medical_Debt_Share", "Medical_Debt_Median_2023"),
                        names(county_df))) {
      county_df[[v]][excl] <- NA_real_
    }
  }

  keep <- c("fips_code", "Year", "State", "Is_Extreme_Drought",
            "PCPI_Real", "Med_HH_Income_Real", "Civilian_Employed",
            "Medical_Debt_Share", "Population")
  keep <- intersect(keep, names(county_df))

  county_df %>%
    distinct(across(all_of(keep))) %>%
    filter(Year >= 2011L, Year <= 2023L) %>%
    mutate(Division = unname(CENSUS_DIVISION[as.character(State)]))
}

# -----------------------------------------------------------------------------
# build_cohorts(): first-event year per county for a shock; 0 = never-exposed.
# Mirrors Code/run_did_analysis.R::build_first_event exactly.
# -----------------------------------------------------------------------------
build_cohorts <- function(panel, shock_var = "Is_Extreme_Drought") {
  panel %>%
    filter(!is.na(.data[[shock_var]])) %>%
    group_by(fips_code) %>%
    summarise(
      first_event = suppressWarnings(min(Year[.data[[shock_var]] == 1], na.rm = TRUE)),
      n_events    = sum(.data[[shock_var]] == 1, na.rm = TRUE),
      .groups = "drop") %>%
    mutate(
      first_event = if_else(is.finite(first_event), first_event, NA_real_),
      first_event = as.integer(first_event),
      cohort      = if_else(is.na(first_event), 0L, first_event))
}

# -----------------------------------------------------------------------------
# baseline_covariates(): time-invariant, PRE-treatment (2011) covariates for
# conditional-parallel-trends DR estimation. Deliberately EXCLUDES contemporaneous
# mediators (income, unemployment, premiums) — those are bad controls.
# Available & non-missing at 2011: log population, baseline median HH income.
# (Census `Division` is already carried per-row by load_did_panel(), so it is
# NOT re-emitted here — re-joining it would collide to Division.x/.y.)
# (Uninsured_Rate / Disability_Rate are all-NA in 2011.)
# -----------------------------------------------------------------------------
baseline_covariates <- function(panel) {
  panel %>%
    filter(Year == 2011L) %>%
    transmute(
      fips_code,
      log_pop_2011   = log(Population),
      medinc_2011    = Med_HH_Income_Real)
}

# -----------------------------------------------------------------------------
# did_2x2_frame(): assemble the treated(first-onset = event_year) + never-exposed
# analysis frame for one shock/event, joined to baseline covariates.
# -----------------------------------------------------------------------------
did_2x2_frame <- function(panel, cohorts, event_year = 2012L,
                          base = NULL) {
  treated <- cohorts %>% filter(cohort == event_year) %>% pull(fips_code)
  control <- cohorts %>% filter(cohort == 0L) %>% pull(fips_code)
  d <- panel %>%
    filter(fips_code %in% c(treated, control)) %>%
    mutate(Treated = as.integer(fips_code %in% treated),
           Post    = as.integer(Year >= event_year),
           TxP     = Treated * Post)
  if (!is.null(base)) d <- left_join(d, base, by = "fips_code")
  attr(d, "n_treated") <- length(treated)
  attr(d, "n_control") <- length(control)
  d
}

if (sys.nframe() == 0L) {
  cat("This file provides helpers; source it. Quick self-check:\n")
  p  <- load_did_panel()
  co <- build_cohorts(p)
  cat(sprintf("  panel rows: %d | drought cohorts: %s\n",
              nrow(p), paste(names(table(co$cohort)), collapse = ",")))
}
