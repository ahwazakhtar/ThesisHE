# Process IRS SOI county migration files into per-county-year net-migration metrics.
# Track: mechanism_channels_20260625 (Phase 1).
#
# PURPOSE -------------------------------------------------------------------
# Provide county net-migration flows to bound the population-SELECTION alternative
# to the income/employment "scarring" effect: if shocked counties simply lose people,
# a same-population income loss is partly a composition change. These flows let the
# mechanism write-up quantify that margin rather than merely caveat it.
#
# INPUT: Data/County_Migration/county{inflow,outflow}<TOK>.csv (download_county_migration.R)
#
# METRIC CONSTRUCTION -------------------------------------------------------
# For each county-year we read three quantities:
#   gross_in   = INFLOW file "Total Migration-US" summary row (y1_statefips==97 &
#                y1_countyfips==000): individuals (n2) and AGI ($000s) moving IN.
#   gross_out  = OUTFLOW file "Total Migration-US" summary row (y2_statefips==97 &
#                y2_countyfips==000): individuals and AGI moving OUT.
#   nonmigrant = INFLOW row where origin county == destination county: individuals
#                who stayed put (the resident base that did not move).
# Derived:
#   net_migration        = gross_in_n2 - gross_out_n2
#   base                 = nonmigrant_n2 + gross_out_n2   (~ start-of-period residents)
#   net_migration_rate   = net_migration / base
#   in_migration_rate    = gross_in_n2  / base
#   out_migration_rate   = gross_out_n2 / base
#   net_agi_flow         = gross_in_agi - gross_out_agi   ($000s of AGI, in-minus-out)
#
# YEAR CONVENTION: token "1112" (tax years 2011->2012) is assigned Year = 2012 (the
# destination/"year 2" of the move), so the panel spans Year 2012..2021.
#
# GOTCHAS -------------------------------------------------------------------
#  * Read FIPS columns as CHARACTER: state arrives 2-char ("01"), county 3-char ("001");
#    concatenating preserves the 5-digit code. Reading as integer would drop leading zeros.
#  * State-aggregate rows carry county FIPS "000" (e.g. y2_countyfips=="000"); excluded
#    from the real-county set (but ARE the rows we read for the special 97-000 summaries,
#    which live under a real fixed county -- so we match on the VARYING end's 97/000).
#  * Suppressed cells = -1 -> coerced to NA (summary rows are large and unsuppressed).

library(dplyr)

tokens <- c("1112","1213","1314","1415","1516","1617","1718","1819","1920","2021")

read_mig <- function(path) {
  df <- read.csv(path, colClasses = "character")
  # numeric flow fields; -1 suppression -> NA
  for (v in c("n1","n2","agi")) {
    df[[v]] <- suppressWarnings(as.numeric(df[[v]]))
    df[[v]][df[[v]] == -1] <- NA
  }
  df
}

process_token <- function(tok) {
  yr <- 2000L + as.integer(substr(tok, 3, 4))
  inf <- read_mig(file.path("Data/County_Migration", paste0("countyinflow",  tok, ".csv")))
  out <- read_mig(file.path("Data/County_Migration", paste0("countyoutflow", tok, ".csv")))

  # --- INFLOW: destination county is the fixed (y2) end ---
  inf <- inf %>% mutate(dest_fips = paste0(y2_statefips, y2_countyfips))
  # gross in = Total Migration-US summary (varying origin coded 97-000), fixed to a real county
  gross_in <- inf %>%
    filter(y1_statefips == "97", y1_countyfips == "000", y2_countyfips != "000") %>%
    transmute(fips_code = dest_fips, gross_in_n2 = n2, gross_in_agi = agi)
  # non-migrants = origin county == destination county
  nonmig <- inf %>%
    filter(y1_statefips == y2_statefips, y1_countyfips == y2_countyfips,
           y2_countyfips != "000") %>%
    transmute(fips_code = dest_fips, nonmigrant_n2 = n2)

  # --- OUTFLOW: origin county is the fixed (y1) end ---
  out <- out %>% mutate(orig_fips = paste0(y1_statefips, y1_countyfips))
  gross_out <- out %>%
    filter(y2_statefips == "97", y2_countyfips == "000", y1_countyfips != "000") %>%
    transmute(fips_code = orig_fips, gross_out_n2 = n2, gross_out_agi = agi)

  gross_in %>%
    full_join(gross_out, by = "fips_code") %>%
    full_join(nonmig,    by = "fips_code") %>%
    mutate(
      Year               = yr,
      net_migration      = gross_in_n2 - gross_out_n2,
      base               = nonmigrant_n2 + gross_out_n2,
      net_migration_rate = ifelse(base > 0, (gross_in_n2 - gross_out_n2) / base, NA_real_),
      in_migration_rate  = ifelse(base > 0, gross_in_n2  / base, NA_real_),
      out_migration_rate = ifelse(base > 0, gross_out_n2 / base, NA_real_),
      net_agi_flow       = gross_in_agi - gross_out_agi
    )
}

mig <- bind_rows(lapply(tokens, process_token)) %>%
  # keep only well-formed 5-digit county codes (defensive against stray summary rows)
  filter(grepl("^[0-9]{5}$", fips_code), substr(fips_code, 3, 5) != "000") %>%
  select(fips_code, Year, gross_in_n2, gross_out_n2, nonmigrant_n2, net_migration,
         net_migration_rate, in_migration_rate, out_migration_rate,
         gross_in_agi, gross_out_agi, net_agi_flow)

# ---- coverage / sanity report --------------------------------------------
cat("Migration panel:", nrow(mig), "county-years,",
    length(unique(mig$fips_code)), "counties,",
    paste(range(mig$Year), collapse = "-"), "\n")
cat("net_migration_rate summary:\n"); print(summary(mig$net_migration_rate))
cat("Counties per year:\n"); print(table(mig$Year))

saveRDS(mig, "Data/intermediate_migration.rds")
cat("\nSaved: Data/intermediate_migration.rds\n")
