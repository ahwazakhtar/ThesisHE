# Process the CMS Medicare Geographic Variation county PUF into a spending/utilization
# panel. Track: mechanism_channels_20260625 (Phase 1).
#
# PURPOSE -------------------------------------------------------------------
# Provide the DIRECTLY-MEASURED health-cost outcomes for the morbidity/utilization
# channel: county per-capita Medicare spending (actual + standardized) and utilization
# (ED visits, inpatient stays/days, readmissions). Lets us test whether climate shocks
# raise realized medical costs -- a channel with no farm-income intermediary that should
# survive in low-agriculture counties (Deryugina et al. 2019; IJPH 2025).
#
# INPUT: Data/County_Health_Spending/medicare_geo_variation_2014_2024.csv
#        (download_county_medicare.R). A wide 58MB file (~155 cols, National/State/County
#        rows stacked, multiple age levels).
#
# WHY colClasses="NULL" ------------------------------------------------------
# Reading all 155 columns as character SEGFAULTS base read.csv on this file. We instead
# read the header, then re-read selecting ONLY the ~14 columns we need (unwanted columns
# get colClasses "NULL" = skipped at parse time). Light, dependency-free, crash-free.
#
# FILTERS -------------------------------------------------------------------
#   BENE_GEO_LVL == "County"   (drop National/State rows)
#   BENE_AGE_LVL == "All"      (drop under-65 / 65+ age subgroups)
#   YEAR in 2014:2023          (PUF starts 2014; align to the county panel's upper end)
# Suppressed small cells are "*" -> NA.
#
# OUTPUT: Data/intermediate_medicare_spending.rds  (fips_code x Year)
#   Mdcr_Payment_PC          TOT_MDCR_PYMT_PC        actual $/beneficiary
#   Mdcr_Std_Payment_PC      TOT_MDCR_STDZD_PYMT_PC  standardized $/beneficiary (price-adjusted)
#   Readmission_Rate         ACUTE_HOSP_READMSN_PCT  proportion
#   ER_Visits_per1000        ER_VISITS_PER_1000_BENES
#   IP_Stays_per1000         IP_CVRD_STAYS_PER_1000_BENES
#   IP_Days_per1000          IP_CVRD_DAYS_PER_1000_BENES
#   Benes_Total              BENES_TOTAL_CNT         beneficiary count (weight)
#   MA_Rate, Dual_Pct        Medicare-Advantage participation, dual-eligible share (controls)
#
# NOTE the standardized payment (Mdcr_Std_Payment_PC) is the preferred spending outcome:
# it removes geographic price differences, isolating utilization/intensity.
#
# GEOGRAPHY: BENE_GEO_CD is a 5-digit zero-padded county FIPS string -- read as character.

log_con <- file("Analysis/mechanism/build_logs/process_county_medicare.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== process_county_medicare.R run ===\n")

library(dplyr)

csv_path <- "Data/County_Health_Spending/medicare_geo_variation_2014_2024.csv"

want <- c("YEAR","BENE_GEO_LVL","BENE_GEO_CD","BENE_AGE_LVL",
          "BENES_TOTAL_CNT","MA_PRTCPTN_RATE","BENE_DUAL_PCT",
          "TOT_MDCR_PYMT_PC","TOT_MDCR_STDZD_PYMT_PC","ACUTE_HOSP_READMSN_PCT",
          "ER_VISITS_PER_1000_BENES","IP_CVRD_STAYS_PER_1000_BENES","IP_CVRD_DAYS_PER_1000_BENES")

header <- names(read.csv(csv_path, nrows = 0, check.names = FALSE))
missing <- setdiff(want, header)
if (length(missing)) stop("Medicare PUF missing expected columns: ", paste(missing, collapse = ", "))

# select-only read: unwanted -> "NULL" (skipped), wanted -> "character"
cc <- setNames(rep("NULL", length(header)), header)
cc[want] <- "character"

cat("Reading", length(want), "of", length(header), "columns...\n")
raw <- read.csv(csv_path, colClasses = cc, check.names = FALSE)
cat("  raw rows:", nrow(raw), "\n")

num <- function(x) { x[x == "*" | x == ""] <- NA; suppressWarnings(as.numeric(x)) }

med <- raw %>%
  filter(BENE_GEO_LVL == "County", BENE_AGE_LVL == "All") %>%
  mutate(
    fips_code = formatC(as.integer(BENE_GEO_CD), width = 5, flag = "0"),
    Year      = as.integer(YEAR)
  ) %>%
  filter(Year %in% 2014:2023) %>%
  transmute(
    fips_code, Year,
    Mdcr_Payment_PC     = num(TOT_MDCR_PYMT_PC),
    Mdcr_Std_Payment_PC = num(TOT_MDCR_STDZD_PYMT_PC),
    Readmission_Rate    = num(ACUTE_HOSP_READMSN_PCT),
    ER_Visits_per1000   = num(ER_VISITS_PER_1000_BENES),
    IP_Stays_per1000    = num(IP_CVRD_STAYS_PER_1000_BENES),
    IP_Days_per1000     = num(IP_CVRD_DAYS_PER_1000_BENES),
    Benes_Total         = num(BENES_TOTAL_CNT),
    MA_Rate             = num(MA_PRTCPTN_RATE),
    Dual_Pct            = num(BENE_DUAL_PCT)
  )

# ---- coverage / sanity report --------------------------------------------
cat("County Medicare panel:", nrow(med), "county-years,",
    length(unique(med$fips_code)), "counties,",
    paste(range(med$Year), collapse = "-"), "\n")
cat("Std payment PC summary ($):\n"); print(summary(med$Mdcr_Std_Payment_PC))
cat("ER visits/1000 summary:\n");    print(summary(med$ER_Visits_per1000))
cat("Counties per year:\n");         print(table(med$Year))

saveRDS(med, "Data/intermediate_medicare_spending.rds")
cat("\nSaved: Data/intermediate_medicare_spending.rds\n")
