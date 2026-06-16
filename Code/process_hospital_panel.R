# ===========================================================================
# process_hospital_panel.R  (Hospital Supply-Side Integration — Phase 1)
#
# Builds a HOSPITAL (CCN) x YEAR financial panel from the NASHP Hospital Cost
# Tool (HCT). County aggregation (the county master) destroys the provider
# heterogeneity — ownership, safety-net status, system affiliation, bed size,
# payer mix — that the supply-side analysis turns on, so this panel keeps the
# hospital as the unit and ATTACHES each hospital's county climate shocks via a
# Zip Code -> county crosswalk (hospital LOCATION, modal county per zip; not the
# residential-population split used for the consumer-side county debt measure).
#
# Output: Data/intermediate_hospital_panel.rds
#
# Units (verified against the source file):
#   - Margins / payer-mix / "% of NPR" fields are PROPORTIONS (0.135 = 13.5%).
#   - Dollar fields are raw dollars; inflation-adjusted to $2023 via CPI.
#   - Ownership is one of {For-Profit, Governmental, Non-Profit}.
#   - `Independent` is 0/1 (1 = independent, i.e. NOT system-affiliated).
#
# Reusable helpers (classify_ownership, derive_uncomp, derive_safetynet,
# pad_fips) are defined first and unit-tested in Code/tests/test_hospital_panel.R;
# the heavy build only runs when the file is executed via Rscript (sys.nframe 0).
# ===========================================================================

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
})

# --- Paths -----------------------------------------------------------------
PATH_NASHP     <- "Data/Hosp_Data/NASHP 2011-2023 HCT Data 2025 Feb.xlsx"
PATH_CROSSWALK <- "Data/Zip County Crosswalk/zip2county_master_xwalk_2010_2023_tot_ratio_one2one.csv"
PATH_CPI       <- "Data/State_Policy_Data/us_cpi_annual.csv"
PATH_MASTER    <- "Data/county_level_master.csv"
PATH_MEDICAID  <- "Code/medicaid_expansion.R"
OUTPUT_RDS     <- "Data/intermediate_hospital_panel.rds"

# ---------------------------------------------------------------------------
# Helpers (pure, unit-tested)
# ---------------------------------------------------------------------------

# Zero-pad a numeric/character FIPS or ZIP to a fixed width. Uses formatC on the
# integer value (NOT sprintf("%05s"), which pads with spaces and silently drops
# single-digit-state codes — see CLAUDE.md Session 5 lessons).
pad_fips <- function(x, width = 5) {
  xi <- suppressWarnings(as.integer(round(as.numeric(x))))
  out <- formatC(xi, width = width, flag = "0", format = "d")
  out[is.na(xi)] <- NA_character_
  out
}

# Collapse the NASHP ownership string into a clean 3-level factor with
# Non-Profit (the modal category) as the reference level.
classify_ownership <- function(x) {
  s <- tolower(trimws(as.character(x)))
  out <- ifelse(grepl("for.?profit", s), "For-Profit",
         ifelse(grepl("non.?profit|not.?for.?profit", s), "Non-Profit",
         ifelse(grepl("govern|public|state|county|district|municipal|federal", s), "Government",
                NA_character_)))
  factor(out, levels = c("Non-Profit", "For-Profit", "Government"))
}

# Sum two dollar (or proportion) components into total uncompensated care.
# Treats a single NA component as 0 BUT returns NA only when BOTH are missing,
# so the identity total == baddebt + charity holds wherever both are observed.
derive_uncomp <- function(baddebt, charity) {
  bd <- as.numeric(baddebt); ch <- as.numeric(charity)
  tot <- rowSums(cbind(bd, ch), na.rm = TRUE)
  tot[is.na(bd) & is.na(ch)] <- NA_real_
  tot
}

# Safety-net flag: top-quartile of (Medicaid payer mix + charity/uninsured/bad-debt
# payer mix), thresholded over the pooled hospital-years. The score is NA whenever
# EITHER payer-mix component is missing (we then can't place the hospital).
derive_safetynet <- function(medicaid_mix, uncomp_mix, q = 0.75) {
  score <- as.numeric(medicaid_mix) + as.numeric(uncomp_mix)  # NA if either NA
  thr <- stats::quantile(score, probs = q, na.rm = TRUE)
  out <- as.integer(score >= thr)
  out[is.na(score)] <- NA_integer_
  list(flag = out, score = score, threshold = unname(thr))
}

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

build_hospital_panel <- function(path_nashp = PATH_NASHP,
                                 path_crosswalk = PATH_CROSSWALK,
                                 path_cpi = PATH_CPI,
                                 path_master = PATH_MASTER,
                                 verbose = TRUE) {
  say <- function(...) if (verbose) cat(...)

  # 1. Read NASHP HCT -------------------------------------------------------
  say("Reading NASHP HCT...\n")
  raw <- suppressWarnings(readxl::read_excel(path_nashp, sheet = "Downloadable"))
  num <- function(col) suppressWarnings(as.numeric(raw[[col]]))

  hp <- tibble::tibble(
    CCN              = trimws(as.character(raw[["CCN#"]])),
    Year             = suppressWarnings(as.integer(raw[["Year"]])),
    Zip_Code         = pad_fips(raw[["Zip Code"]]),
    State            = toupper(trimws(as.character(raw[["State"]]))),
    Hospital_Name    = as.character(raw[["Hospital Name"]]),
    # --- Outcomes (financial flows / stocks) ---
    Hosp_NetPatientRevenue = num("Net Patient Revenue"),
    Hosp_OperatingMargin   = num("Operating Profit Margin"),
    Hosp_NetMargin         = num("Net Profit Margin"),
    Hosp_Expenses          = num("Hospital Expenses (Inclusive of All Services)"),
    Hosp_NetIncome         = num("Net Income (Loss)"),
    Hosp_FundBalance       = num("Fund Balance"),
    .baddebt               = num("Uninsured and Bad Debt Cost"),
    .charity               = num("Net Charity Care Cost"),
    .baddebt_pct           = num("Uninsured and Bad Debt Cost as % of Net Patient Revenue"),
    .charity_pct           = num("Net Charity Care Cost as % of Net Patient Revenue"),
    # --- Moderator raw inputs ---
    Ownership              = classify_ownership(raw[["Hospital Ownership Type"]]),
    .independent           = suppressWarnings(as.integer(raw[["Independent"]])),
    SystemID               = trimws(as.character(raw[["Health System ID"]])),
    Hosp_BedSize           = num("Bed Size"),
    MedicaidPayerMix       = num("Medicaid Payer Mix"),
    MedicarePayerMix       = num("Medicare Payer Mix"),
    CommercialPayerMix     = num("Commercial Payer Mix"),
    .uncomp_mix            = num("Charity Care and Uninsured and Bad Debt Payer Mix")
  )

  # Drop rows with no usable key
  hp <- hp[!is.na(hp$CCN) & hp$CCN != "" & !is.na(hp$Year), , drop = FALSE]

  # Collapse rare CCN x Year duplicates (e.g. "Multiple MCRs") to one row by
  # summing dollar flows and averaging ratios, so the panel key is unique.
  dup_key <- paste(hp$CCN, hp$Year)
  n_dups  <- sum(duplicated(dup_key))
  if (n_dups > 0) {
    say(sprintf("Collapsing %d duplicate (CCN, Year) rows...\n", n_dups))
    hp <- hp %>%
      group_by(CCN, Year) %>%
      summarise(
        Zip_Code = dplyr::first(Zip_Code), State = dplyr::first(State),
        Hospital_Name = dplyr::first(Hospital_Name),
        Hosp_NetPatientRevenue = sum(Hosp_NetPatientRevenue, na.rm = TRUE),
        Hosp_Expenses          = sum(Hosp_Expenses, na.rm = TRUE),
        Hosp_NetIncome         = sum(Hosp_NetIncome, na.rm = TRUE),
        Hosp_FundBalance       = sum(Hosp_FundBalance, na.rm = TRUE),
        .baddebt = sum(.baddebt, na.rm = TRUE), .charity = sum(.charity, na.rm = TRUE),
        Hosp_OperatingMargin = mean(Hosp_OperatingMargin, na.rm = TRUE),
        Hosp_NetMargin       = mean(Hosp_NetMargin, na.rm = TRUE),
        .baddebt_pct = mean(.baddebt_pct, na.rm = TRUE), .charity_pct = mean(.charity_pct, na.rm = TRUE),
        Ownership = dplyr::first(Ownership), .independent = dplyr::first(.independent),
        SystemID = dplyr::first(SystemID), Hosp_BedSize = dplyr::first(Hosp_BedSize),
        MedicaidPayerMix = mean(MedicaidPayerMix, na.rm = TRUE),
        MedicarePayerMix = mean(MedicarePayerMix, na.rm = TRUE),
        CommercialPayerMix = mean(CommercialPayerMix, na.rm = TRUE),
        .uncomp_mix = mean(.uncomp_mix, na.rm = TRUE),
        .groups = "drop"
      )
    # NaN from all-NA mean() -> NA
    for (v in names(hp)) if (is.numeric(hp[[v]])) hp[[v]][is.nan(hp[[v]])] <- NA
  }

  # 2. Derived outcomes & moderators ---------------------------------------
  hp$Hosp_UncompCare        <- derive_uncomp(hp$.baddebt, hp$.charity)
  hp$Hosp_UncompCare_PctNPR <- derive_uncomp(hp$.baddebt_pct, hp$.charity_pct)
  sn <- derive_safetynet(hp$MedicaidPayerMix, hp$.uncomp_mix)
  hp$SafetyNet       <- sn$flag
  hp$SafetyNet_Score <- sn$score
  hp$SystemAffiliated <- as.integer(hp$.independent == 0)  # 1 = belongs to a system

  # 3. Inflation-adjust dollar fields to $2023 ------------------------------
  say("Inflation-adjusting to $2023...\n")
  cpi <- read.csv(path_cpi, stringsAsFactors = FALSE)
  cpi_2023 <- cpi$CPI_Value[cpi$Year == 2023]
  hp <- hp %>%
    left_join(cpi[, c("Year", "CPI_Value")], by = "Year") %>%
    mutate(CPI_Factor = cpi_2023 / CPI_Value)
  # source field -> canonical real column name
  dollar_map <- c(
    Hosp_NetPatientRevenue = "Hosp_NetPatientRevenue_Real",
    Hosp_Expenses          = "Hosp_Expenses_Real",
    Hosp_NetIncome         = "Hosp_NetIncome_Real",
    Hosp_FundBalance       = "Hosp_FundBalance_Real",
    Hosp_UncompCare        = "Hosp_UncompCare_Real",
    .baddebt               = "Hosp_BadDebt_Real",
    .charity               = "Hosp_Charity_Real"
  )
  for (v in names(dollar_map)) {
    hp[[dollar_map[[v]]]] <- hp[[v]] * hp$CPI_Factor
  }

  # 4. Map Zip -> county (hospital location, modal county per zip) -----------
  say("Mapping Zip -> county via one-to-one crosswalk...\n")
  cw <- read.csv(path_crosswalk, stringsAsFactors = FALSE) %>%
    transmute(Zip_Code = pad_fips(zip), fips_code = pad_fips(county),
              Year = as.integer(year))
  # Year-specific match, then fall back to each zip's modal county across years
  cw_modal <- cw %>%
    count(Zip_Code, fips_code, name = "n") %>%
    group_by(Zip_Code) %>% slice_max(n, n = 1, with_ties = FALSE) %>%
    ungroup() %>% select(Zip_Code, fips_modal = fips_code)

  hp <- hp %>%
    left_join(cw, by = c("Zip_Code", "Year")) %>%
    left_join(cw_modal, by = "Zip_Code") %>%
    mutate(fips_code = dplyr::coalesce(fips_code, fips_modal)) %>%
    select(-fips_modal)

  match_rate <- mean(!is.na(hp$fips_code))
  say(sprintf("County-match rate: %.1f%% (%d of %d hospital-years)\n",
              100 * match_rate, sum(!is.na(hp$fips_code)), nrow(hp)))

  # 5. Attach county climate shocks (county-level, joined on fips x Year) ----
  say("Attaching county climate shocks from county master...\n")
  master <- read.csv(path_master, stringsAsFactors = FALSE)
  master$fips_code <- pad_fips(master$fips_code)
  shock_cols <- c("Is_Extreme_Drought", "Is_Extreme_Drought_Lag1", "Is_Extreme_Drought_Lag2",
                  "High_CDD", "High_CDD_Lag1", "High_CDD_Lag2",
                  "High_HDD", "High_HDD_Lag1", "High_HDD_Lag2",
                  "Max_AQI", "Population")
  shock_cols <- intersect(shock_cols, names(master))
  county_shocks <- master %>%
    select(fips_code, Year, dplyr::all_of(shock_cols)) %>%
    distinct(fips_code, Year, .keep_all = TRUE) %>%
    arrange(fips_code, Year) %>%
    group_by(fips_code) %>%
    mutate(
      High_AQI_Max      = as.integer(Max_AQI > 100),
      High_AQI_Max_Lag1 = dplyr::lag(as.integer(Max_AQI > 100), 1),
      High_AQI_Max_Lag2 = dplyr::lag(as.integer(Max_AQI > 100), 2)
    ) %>%
    ungroup()

  hp <- hp %>% left_join(county_shocks, by = c("fips_code", "Year"))

  # 6. Medicaid expansion (state-year) --------------------------------------
  source(PATH_MEDICAID, local = TRUE)
  hp$MedicaidExpansion <- medicaid_expanded(hp$State, hp$Year)

  # 7. Tidy: drop internal scratch columns ----------------------------------
  hp <- hp %>% select(-dplyr::starts_with("."), -CPI_Value, -CPI_Factor)

  say(sprintf("Panel built: %d hospital-years, %d hospitals, %d-%d.\n",
              nrow(hp), length(unique(hp$CCN)),
              min(hp$Year, na.rm = TRUE), max(hp$Year, na.rm = TRUE)))
  hp
}

# ---------------------------------------------------------------------------
# Run (only when executed via Rscript, not when sourced by tests)
# ---------------------------------------------------------------------------
if (sys.nframe() == 0L) {
  panel <- build_hospital_panel()
  saveRDS(panel, OUTPUT_RDS)
  cat("Saved:", OUTPUT_RDS, "\n")
  # Coverage report
  cat("\n--- Coverage ---\n")
  cat("Hospital-years:", nrow(panel), "\n")
  cat("Unique CCN:", length(unique(panel$CCN)), "\n")
  cat("County-match rate:", round(100 * mean(!is.na(panel$fips_code)), 1), "%\n")
  cat("Shock-attached rate:", round(100 * mean(!is.na(panel$Is_Extreme_Drought)), 1), "%\n")
  cat("SafetyNet hospitals (any yr):",
      length(unique(panel$CCN[panel$SafetyNet == 1 & !is.na(panel$SafetyNet)])), "\n")
  print(table(Ownership = panel$Ownership, useNA = "ifany"))
}
