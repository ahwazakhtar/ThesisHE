# Process ACS C24030 into county industry-composition moderators.
# Track: mechanism_channels_20260625 (Phase 1).
#
# PURPOSE -------------------------------------------------------------------
# Produce the moderator that separates the LABOR-productivity channel from the
# agricultural channel: a county's share of employment in climate-exposed NON-FARM
# industries (mining, construction, manufacturing, transportation & warehousing,
# utilities), alongside its agricultural-employment share. A climate effect that
# survives in low-farm counties but scales with this exposed-non-farm share is
# evidence the mechanism is broad labor exposure, not agriculture (Graff Zivin &
# Neidell 2014; Somanathan et al. 2021; Deryugina & Hsiang 2014 weekday income dip).
#
# INPUT: Data/County_Industry/acs_c24030_raw.csv  (from download_county_industry.R)
#
# OUTPUT: Data/intermediate_industry_composition.rds
#   Long-by-year columns (annual, for optional time-varying use):
#     fips_code, Year, Ag_Emp_Share, ClimateExposed_NonFarm_Share,
#     Mining_Share, Construction_Share, Manufacturing_Share,
#     TransportWarehouse_Share, Utilities_Share, Total_Employed
#   Plus time-invariant STRUCTURAL baseline columns (suffixed _baseline), averaged
#   over 2011-2013 ACS 5-year vintages -- the earliest available and the closest to
#   pre-/early-study composition. Industry composition is highly persistent, so the
#   baseline is a defensible structural moderator; the annual series is retained for
#   robustness. (Caveat: ACS 5-year windows partially precede 2011, so 2011-2013 is
#   near-but-not-strictly pre-treatment -- documented, mirrors the ag-dependence choice.)
#
# CLIMATE-EXPOSED SET RATIONALE ---------------------------------------------
# Following the labor/heat literature, "climate-exposed" = industries with heavy
# outdoor or thermally-stressed work: mining/extraction, construction, manufacturing,
# transportation & warehousing, and utilities. Agriculture is EXCLUDED from this set
# by construction so the moderator is orthogonal to the farm channel (agriculture is
# carried separately as Ag_Emp_Share and via intermediate_ag_dependence.rds).
#
# GOTCHA: FIPS from ACS is state(2)+county(3) already 5-char; keep as character.

library(dplyr)

BASELINE_YEARS <- 2011:2013

raw <- read.csv("Data/County_Industry/acs_c24030_raw.csv", colClasses = "character")

num <- function(x) suppressWarnings(as.numeric(x))

ind <- raw %>%
  transmute(
    fips_code = formatC(as.integer(fips_code), width = 5, flag = "0"),
    Year      = as.integer(Year),
    total     = num(C24030_001E),
    # sum male + female per industry
    ag        = num(C24030_004E) + num(C24030_030E),
    mining    = num(C24030_005E) + num(C24030_031E),
    constr    = num(C24030_006E) + num(C24030_032E),
    manuf     = num(C24030_007E) + num(C24030_033E),
    transp    = num(C24030_011E) + num(C24030_037E),
    util      = num(C24030_012E) + num(C24030_038E)
  ) %>%
  mutate(
    exposed_nonfarm = mining + constr + manuf + transp + util,
    Ag_Emp_Share                 = ifelse(total > 0, ag / total, NA_real_),
    ClimateExposed_NonFarm_Share = ifelse(total > 0, exposed_nonfarm / total, NA_real_),
    Mining_Share                 = ifelse(total > 0, mining / total, NA_real_),
    Construction_Share           = ifelse(total > 0, constr / total, NA_real_),
    Manufacturing_Share          = ifelse(total > 0, manuf  / total, NA_real_),
    TransportWarehouse_Share     = ifelse(total > 0, transp / total, NA_real_),
    Utilities_Share              = ifelse(total > 0, util   / total, NA_real_),
    Total_Employed               = total
  ) %>%
  select(fips_code, Year, Ag_Emp_Share, ClimateExposed_NonFarm_Share,
         Mining_Share, Construction_Share, Manufacturing_Share,
         TransportWarehouse_Share, Utilities_Share, Total_Employed)

# Structural baseline (time-invariant): mean of the annual shares over 2011-2013.
baseline <- ind %>%
  filter(Year %in% BASELINE_YEARS) %>%
  group_by(fips_code) %>%
  summarise(
    Ag_Emp_Share_baseline                 = mean(Ag_Emp_Share, na.rm = TRUE),
    ClimateExposed_NonFarm_Share_baseline = mean(ClimateExposed_NonFarm_Share, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  # tercile of the exposed-non-farm baseline share (for a subsample reading paralleling
  # the ag-dependence tercile)
  mutate(ClimateExposed_Tercile = as.integer(cut(
    ClimateExposed_NonFarm_Share_baseline,
    breaks = quantile(ClimateExposed_NonFarm_Share_baseline, c(0, 1/3, 2/3, 1), na.rm = TRUE),
    include.lowest = TRUE, labels = FALSE
  )))

out <- ind %>% left_join(baseline, by = "fips_code")

# ---- coverage / sanity report --------------------------------------------
cat("Industry composition: ", nrow(out), "county-years,",
    length(unique(out$fips_code)), "counties,",
    paste(range(out$Year), collapse = "-"), "\n")
cat("Baseline (2011-2013) exposed-non-farm share summary:\n")
print(summary(baseline$ClimateExposed_NonFarm_Share_baseline))
cat("Baseline ag-emp share summary:\n")
print(summary(baseline$Ag_Emp_Share_baseline))
cat("Exposed-non-farm tercile counts:\n")
print(table(baseline$ClimateExposed_Tercile, useNA = "ifany"))
# Shares must lie in [0,1]
rng_ok <- with(out, all(ClimateExposed_NonFarm_Share >= 0 &
                        ClimateExposed_NonFarm_Share <= 1, na.rm = TRUE))
cat("All exposed-non-farm shares in [0,1]:", rng_ok, "\n")

saveRDS(out, "Data/intermediate_industry_composition.rds")
cat("\nSaved: Data/intermediate_industry_composition.rds\n")
