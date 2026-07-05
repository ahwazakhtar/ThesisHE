# =============================================================================
# download_rma_cause_of_loss.R  (mechanisms_revision_20260704 — Task 0.4 / C2)
# =============================================================================
# Pulls USDA RMA "Summary of Business — Cause of Loss" county-year crop-insurance
# INDEMNITIES to enable the provider-finance test (C2): does the drought shock
# spike federal crop indemnities in the same counties where hospital
# uncompensated care does NOT move? (Federal buffers — crop insurance + disaster
# aid — sever the farm-income -> uninsurance -> uncompensated-care chain.)
#
# SOURCE (keyless, public): annual pipe-delimited ZIPs
#   https://pubfs-rma.fpac.usda.gov/pub/Web_Data_Files/Summary_of_Business/cause_of_loss/colsom_<YYYY>.zip
# Each ZIP holds colsom_<YYYY>.txt — 30 columns, HEADERLESS. Column map verified
# 2026-07-05 against the RMA loss-ratio identity (col30 == col29/col22):
#   col1  Commodity_Year      col2  State_FIPS (2)     col4  County_FIPS (3)
#   col12 CauseOfLoss_Code    col13 CauseOfLoss_Desc   col21 Liability
#   col22 Total_Premium       col29 Indemnity_Amount   col30 Loss_Ratio
# "Drought" is identified by description match (robust to code drift).
#
# OUTPUT: Data/intermediate_rma_indemnity.rds — one row per county-year with
#   Drought_Indemnity, Total_Indemnity (all causes), Drought_Indemnity_Share,
#   Drought_Liability. County FIPS = State_FIPS(2) + County_FIPS(3), zero-padded.
#
# ENV: main R 4.2.2.  Rscript Code/download_rma_cause_of_loss.R
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(readr) })

YEARS   <- 2011:2023
BASEURL <- "https://pubfs-rma.fpac.usda.gov/pub/Web_Data_Files/Summary_of_Business/cause_of_loss"
OUT     <- "Data/intermediate_rma_indemnity.rds"
LOGDIR  <- "Analysis/mechanism/build_logs"
dir.create(LOGDIR, showWarnings = FALSE, recursive = TRUE)
logcon  <- file(file.path(LOGDIR, "download_rma_cause_of_loss.log"), open = "wt")
sink(logcon, split = TRUE)
on.exit({ sink(); close(logcon) }, add = TRUE)
cat("=== RMA cause-of-loss indemnities ::", format(Sys.time()), "===\n\n")

# readr compact col-types: keep 1,2,4,12,13,21,22,29; skip the rest (30 cols).
CT <- "ic_c_______cc_______dd______d_"
stopifnot(nchar(CT) == 30L)
COLNM <- c("Commodity_Year", "State_FIPS", "County_FIPS", "CoL_Code", "CoL_Desc",
           "Liability", "Total_Premium", "Indemnity")

one_year <- function(yr) {
  url <- sprintf("%s/colsom_%d.zip", BASEURL, yr)
  tf  <- tempfile(fileext = ".zip"); td <- tempdir()
  ok  <- tryCatch({ download.file(url, tf, mode = "wb", quiet = TRUE); TRUE },
                  error = function(e) { cat("  DOWNLOAD FAIL", yr, ":", conditionMessage(e), "\n"); FALSE })
  if (!ok) return(NULL)
  fn  <- utils::unzip(tf, list = TRUE)$Name[1]
  utils::unzip(tf, files = fn, exdir = td, overwrite = TRUE)
  raw <- read_delim(file.path(td, fn), delim = "|", col_names = COLNM,
                    col_types = CT, progress = FALSE, trim_ws = TRUE)
  unlink(c(tf, file.path(td, fn)))
  raw %>%
    mutate(fips_code = paste0(formatC(State_FIPS, width = 2, flag = "0"),
                              formatC(County_FIPS, width = 3, flag = "0")),
           is_drought = grepl("drought", CoL_Desc, ignore.case = TRUE)) %>%
    group_by(fips_code) %>%
    summarise(Year = yr,
              Total_Indemnity   = sum(Indemnity, na.rm = TRUE),
              Drought_Indemnity = sum(Indemnity[is_drought], na.rm = TRUE),
              Drought_Liability = sum(Liability[is_drought], na.rm = TRUE),
              .groups = "drop")
}

all_years <- lapply(YEARS, function(y) { cat("  ->", y, "\n"); one_year(y) })
rma <- bind_rows(Filter(Negate(is.null), all_years)) %>%
  mutate(Drought_Indemnity_Share = ifelse(Total_Indemnity > 0,
                                           Drought_Indemnity / Total_Indemnity, NA_real_)) %>%
  filter(grepl("^[0-9]{5}$", fips_code)) %>%          # drop non-county rows (state summaries etc.)
  arrange(fips_code, Year)

saveRDS(rma, OUT)
cat(sprintf("\nWrote %s : %d county-years, %d counties, %d-%d\n", OUT, nrow(rma),
            n_distinct(rma$fips_code), min(rma$Year), max(rma$Year)))
cat(sprintf("Counties with any drought indemnity: %d ; median drought share (nonzero-indem cty-yrs): %.3f\n",
            sum(rma$Drought_Indemnity > 0),
            median(rma$Drought_Indemnity_Share[rma$Total_Indemnity > 0], na.rm = TRUE)))
cat("\n=== done", format(Sys.time()), "===\n")
