# Process county agricultural-dependence raws into a STRUCTURAL moderator.
# Track: mechanism_channels_20260625 (Phase 1 data gate).
#
# PURPOSE -------------------------------------------------------------------
# Build a time-invariant, pre-treatment agricultural-dependence moderator so we
# can bound the reviewer's "agricultural income channel": interact climate shocks
# with ag-dependence (does the effect LOAD on farm counties?) and re-estimate in
# the bottom ag-dependence tercile (the surviving effect there is, by construction,
# NOT agriculture). The moderator MUST be structural/baseline, never contemporaneous
# farm income (that would be a bad control on the causal path).
#
# INPUTS (from download_county_agriculture.R) -------------------------------
#   Data/County_Agriculture/ers_county_typology_2015.csv   (USDA ERS, keyless)
#   Data/County_Agriculture/bea_cainc5n_earnings_raw.csv   (BEA CAINC5N 81 & 35)
#
# OUTPUT --------------------------------------------------------------------
#   Data/intermediate_ag_dependence.rds  (one row per county)
#     fips_code                 5-char zero-padded county FIPS
#     Ag_Dependent              USDA non-overlapping economic type == 1 (Farming).
#                               PRIMARY structural flag. 444 counties (ERS headline).
#     Ag_Dependent_Flag         USDA Farming_2015_Update == 1. BROADER standalone
#                               farm-threshold flag (507 counties); a county can meet
#                               the farm threshold yet be typed to another dominant
#                               sector, so this is a superset of Ag_Dependent.
#     Farm_Earnings_Share       BEA farm earnings / total earnings, AVERAGED over the
#                               2001-2010 pre-study baseline (structural, continuous).
#     Ag_Dependence_Tercile     tercile (1=low ... 3=high) of Farm_Earnings_Share;
#                               drives the subsample (bottom-tercile) reading in Phase 2.
#
# KEY DECISIONS / GOTCHAS ---------------------------------------------------
#  * USDA "Farming-dependent" is ambiguous in the file: the non-overlapping
#    economic-type column (mutually exclusive, ==1 -> "Farming") gives 444 counties
#    and matches ERS's published farming-dependent count; the standalone
#    `Farming_2015_Update` flag gives 507 (counties meeting the >=25% earnings /
#    >=16% employment threshold even if another sector dominates). We keep BOTH and
#    use the non-overlapping type as the primary classification.
#  * BEA farm-earnings share is the CONTINUOUS moderator. Baseline window = 2001-2010,
#    which (a) is strictly pre-study (panel starts 2011) so it cannot be a bad control,
#    and (b) mirrors the project's z-score baseline philosophy of anchoring to a fixed
#    historical period. BEA CAINC5N NAICS series begins 2001, so 2001-2010 is the widest
#    clean pre-period available.
#  * FIPS zero-padding: USDA FIPStxt arrives UNPADDED (e.g. "1001" for AL). Use
#    formatC(as.integer(x), width=5, flag="0") -- NEVER sprintf("%05s", x), which
#    space-pads and silently drops single-digit-state counties (project lesson, Session 5).
#    BEA GeoFips already arrives 5-char padded ("01001").
#  * BEA state/US aggregate rows have county part "000" (e.g. "01000", "00000") and are
#    dropped so only true counties remain.
#  * Farm earnings can be NEGATIVE (a bad farm year -> net loss), so Farm_Earnings_Share
#    can be < 0. We keep the sign in the baseline mean but clip the final structural share
#    to a plausible [-0.5, 1] range for the tercile cut (defensive; extreme negatives are
#    rare and would distort terciles).

library(dplyr)
library(tidyr)

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

# ---------------------------------------------------------------------------
# 1. USDA ERS typology -> structural farm-dependence flags
# ---------------------------------------------------------------------------
usda <- read.csv("Data/County_Agriculture/ers_county_typology_2015.csv",
                 check.names = FALSE, colClasses = "character")

# The non-overlapping economic-type column has an awkward name with spaces.
econ_type_col <- "Economic Types Type_2015_Update non-overlapping"
stopifnot(econ_type_col %in% names(usda), "Farming_2015_Update" %in% names(usda))

usda_flags <- usda %>%
  transmute(
    fips_code         = pad_fips(FIPStxt),
    Ag_Dependent      = as.integer(.data[[econ_type_col]] == "1"),  # 444 counties
    Ag_Dependent_Flag = as.integer(Farming_2015_Update == "1")      # 507 counties
  ) %>%
  filter(!is.na(fips_code))

cat("USDA typology:", nrow(usda_flags), "counties;",
    sum(usda_flags$Ag_Dependent), "farming-dependent (non-overlapping type);",
    sum(usda_flags$Ag_Dependent_Flag), "meeting the standalone farm threshold.\n")

# ---------------------------------------------------------------------------
# 2. BEA CAINC5N -> baseline farm-earnings share (2001-2010)
# ---------------------------------------------------------------------------
bea <- read.csv("Data/County_Agriculture/bea_cainc5n_earnings_raw.csv",
                colClasses = "character") %>%
  mutate(
    fips_code = formatC(as.integer(fips_code), width = 5, flag = "0"),
    Year      = as.integer(Year),
    # BEA DataValue: numeric string; suppression tokens "(NA)"/"(D)"/"(L)" -> NA.
    value     = suppressWarnings(as.numeric(gsub(",", "", value)))
  ) %>%
  filter(substr(fips_code, 3, 5) != "000")   # drop state/US aggregate rows

BASELINE_YEARS <- 2001:2010

farm_share <- bea %>%
  filter(Year %in% BASELINE_YEARS) %>%
  select(fips_code, Year, series, value) %>%
  pivot_wider(names_from = series, values_from = value) %>%
  # county-year share, then average over the baseline window (structural)
  mutate(share_yr = ifelse(is.na(total_earnings) | total_earnings == 0,
                           NA_real_, farm_earnings / total_earnings)) %>%
  group_by(fips_code) %>%
  summarise(
    Farm_Earnings_Share = mean(share_yr, na.rm = TRUE),
    n_baseline_years    = sum(!is.na(share_yr)),
    .groups = "drop"
  ) %>%
  mutate(Farm_Earnings_Share = ifelse(is.nan(Farm_Earnings_Share), NA_real_,
                                      Farm_Earnings_Share))

cat("BEA farm-earnings share: computed for", sum(!is.na(farm_share$Farm_Earnings_Share)),
    "counties over", paste(range(BASELINE_YEARS), collapse = "-"), "\n")

# ---------------------------------------------------------------------------
# 3. Merge, tercile-cut, write
# ---------------------------------------------------------------------------
ag <- usda_flags %>%
  full_join(farm_share, by = "fips_code") %>%
  # Tercile on the continuous baseline share (defensive clip for extreme negatives)
  mutate(
    share_clip = pmin(pmax(Farm_Earnings_Share, -0.5), 1),
    Ag_Dependence_Tercile = ifelse(
      is.na(share_clip), NA_integer_,
      as.integer(cut(share_clip,
                     breaks = quantile(share_clip, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
                     include.lowest = TRUE, labels = FALSE))
    )
  ) %>%
  select(fips_code, Ag_Dependent, Ag_Dependent_Flag,
         Farm_Earnings_Share, Ag_Dependence_Tercile, n_baseline_years)

# Coverage report
n_total <- nrow(ag)
cat("\nMerged ag-dependence table:", n_total, "counties\n")
cat("  Ag_Dependent (USDA type==1):   ", sum(ag$Ag_Dependent == 1, na.rm = TRUE), "\n")
cat("  Farm_Earnings_Share non-missing:", sum(!is.na(ag$Farm_Earnings_Share)), "\n")
cat("  Tercile counts:\n"); print(table(ag$Ag_Dependence_Tercile, useNA = "ifany"))
cat("  Farm_Earnings_Share summary:\n"); print(summary(ag$Farm_Earnings_Share))

saveRDS(ag, "Data/intermediate_ag_dependence.rds")
cat("\nSaved: Data/intermediate_ag_dependence.rds (", nrow(ag), "rows )\n")
