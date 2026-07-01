# Aggregate DOE LEAD 2022 county AMI files into a per-county energy-burden moderator.
# Track: mechanism_channels_20260625 (Phase 1).
#
# PURPOSE -------------------------------------------------------------------
# LEAD ships household-stratum rows (income bracket x tenure x building x fuel), NOT a
# precomputed energy-burden %. We reproduce LEAD's household-weighted county averages by
# summing the weighted products over each county's rows. Two burdens are produced:
#   * Energy_Burden_Pct        -- all households (overall structural energy burden)
#   * Energy_Burden_Pct_LowInc -- households at/below 80% Area Median Income (the
#                                 distributional cut that maps to high-SVI amplification;
#                                 Doremus et al. 2022; Barreca et al. 2016 AC affordability)
#
# INPUT: Data/County_Energy/raw/{ST}_AMI_Counties_2022.csv  (download_county_energy.R)
#
# LEAD AGGREGATION FORMULAS (from the official 2022 data dictionary) ---------
#   Household-weighted average energy burden (%) for a county =
#       ( Σ ELEP*UNITS + Σ GASP*UNITS + Σ FULP*UNITS ) / ( Σ HINCP*UNITS ) * 100
#   Average annual energy cost ($) = (Σ ELEP*UNITS + GASP*UNITS + FULP*UNITS) / Σ(ELEP UNITS)
#   Average annual income ($)      =  Σ HINCP*UNITS / Σ(HINCP UNITS)
#   Household count                =  Σ UNITS
#   The "... UNITS" (space, not asterisk) columns are the correct denominators: they sum
#   UNITS only over rows with a non-null value for that variable.
#
# CAVEAT: single 2022 cross-section -> TIME-INVARIANT moderator (no Year column). Attach
# as a fixed county attribute; do not interpret as an annual series.
#
# GOTCHAS: column names contain spaces and asterisks -> read with check.names=FALSE and
# index by the exact literal name. Values carry leading spaces (" 32.8") -> as.numeric ok.
# FIP is a 5-digit county FIPS string.

log_con <- file("Analysis/mechanism/build_logs/process_county_energy.log", open = "wt")
sink(log_con, split = TRUE); sink(log_con, type = "message")
on.exit({ sink(type = "message"); sink(); close(log_con) }, add = TRUE)
cat("=== process_county_energy.R run ===\n")

library(dplyr)

rawdir <- "Data/County_Energy/raw"
files  <- list.files(rawdir, pattern = "_AMI_Counties_2022\\.csv$", full.names = TRUE)
if (length(files) == 0) stop("No LEAD county files found in ", rawdir,
                             " -- run download_county_energy.R first.")
cat("Reading", length(files), "state county files...\n")

num <- function(x) suppressWarnings(as.numeric(x))

read_one <- function(f) {
  d <- read.csv(f, check.names = FALSE, colClasses = "character")
  data.frame(
    fips_code = formatC(as.integer(d[["FIP"]]), width = 5, flag = "0"),
    ami       = d[["AMI150"]],
    units     = num(d[["UNITS"]]),
    hincp_u   = num(d[["HINCP*UNITS"]]),
    elep_u    = num(d[["ELEP*UNITS"]]),
    gasp_u    = num(d[["GASP*UNITS"]]),
    fulp_u    = num(d[["FULP*UNITS"]]),
    hincp_den = num(d[["HINCP UNITS"]]),
    elep_den  = num(d[["ELEP UNITS"]]),
    stringsAsFactors = FALSE
  )
}

all_rows <- bind_rows(lapply(files, read_one))
all_rows$energy_u <- rowSums(all_rows[, c("elep_u","gasp_u","fulp_u")], na.rm = TRUE)

# Low-income = at/below 80% AMI. Detect which bracket strings qualify (lower bound < 80).
brackets <- sort(unique(all_rows$ami))
cat("AMI brackets present:", paste(brackets, collapse = " | "), "\n")
low_lower_bound <- function(b) suppressWarnings(as.numeric(sub("-.*|%.*", "", b)))
low_brackets <- brackets[!is.na(low_lower_bound(brackets)) & low_lower_bound(brackets) < 80]
cat("Low-income (<=80% AMI) brackets:", paste(low_brackets, collapse = " | "), "\n")

agg <- function(df) {
  ec <- sum(df$energy_u,  na.rm = TRUE)   # weighted energy cost
  inc <- sum(df$hincp_u,  na.rm = TRUE)   # weighted income
  data.frame(
    burden = ifelse(inc > 0, 100 * ec / inc, NA_real_),
    avg_cost = ifelse(sum(df$elep_den, na.rm = TRUE) > 0,
                      ec / sum(df$elep_den, na.rm = TRUE), NA_real_),
    avg_income = ifelse(sum(df$hincp_den, na.rm = TRUE) > 0,
                        inc / sum(df$hincp_den, na.rm = TRUE), NA_real_),
    households = sum(df$units, na.rm = TRUE)
  )
}

overall <- all_rows %>% group_by(fips_code) %>% group_modify(~ agg(.x)) %>% ungroup() %>%
  rename(Energy_Burden_Pct = burden, Avg_Energy_Cost = avg_cost,
         Avg_Income = avg_income, LEAD_Households = households)

lowinc <- all_rows %>% filter(ami %in% low_brackets) %>%
  group_by(fips_code) %>% group_modify(~ agg(.x)) %>% ungroup() %>%
  transmute(fips_code, Energy_Burden_Pct_LowInc = burden)

energy <- overall %>% left_join(lowinc, by = "fips_code") %>%
  mutate(Energy_Burden_Tercile = as.integer(cut(
    Energy_Burden_Pct,
    breaks = quantile(Energy_Burden_Pct, c(0, 1/3, 2/3, 1), na.rm = TRUE),
    include.lowest = TRUE, labels = FALSE)))

# ---- coverage / sanity report --------------------------------------------
cat("\nEnergy-burden moderator:", nrow(energy), "counties\n")
cat("Overall energy burden (%) summary:\n");   print(summary(energy$Energy_Burden_Pct))
cat("Low-income energy burden (%) summary:\n"); print(summary(energy$Energy_Burden_Pct_LowInc))
cat("Burden tercile counts:\n"); print(table(energy$Energy_Burden_Tercile, useNA = "ifany"))

saveRDS(energy, "Data/intermediate_energy_burden.rds")
cat("\nSaved: Data/intermediate_energy_burden.rds\n")
