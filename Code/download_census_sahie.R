# =============================================================================
# download_census_sahie.R  (mechanisms_revision_20260704 — Task 0.4 / C1)
# =============================================================================
# Pulls Census SAHIE (Small Area Health Insurance Estimates) county-year
# WORKING-AGE (18-64) uninsured rates — the second-reviewer's requested bridge
# (C1): the existing morbidity channel uses CMS Medicare (65+, insured), which
# "doesn't reach" the working-age un/underinsured population where medical debt
# lives. SAHIE is model-based (BRFSS + ACS), free/keyless, single-year, and
# covers EVERY county for the full 2011-2023 panel (unlike PLACES, 2018+).
#
# Used as a MODERATOR: shock x county 18-64 uninsured share — does the climate
# shock's cost effect load where the working-age uninsured population is largest?
#
# SOURCE: https://api.census.gov/data/timeseries/healthins/sahie
#   AGECAT=1 (18-64), RACECAT=0/SEXCAT=0 (all); IPRCAT=0 (all incomes) as the
#   headline + IPRCAT=3 (<=138% FPL) as a low-income/underinsured proxy.
#   Variable PCTUI_PT = percent uninsured (point estimate). in=state:* wildcard
#   returns all counties per year. Needs CENSUS_API_KEY (~/.Renviron).
#
# OUTPUT: Data/intermediate_sahie.rds — fips_code, Year, Uninsured_18_64,
#   Uninsured_18_64_le138FPL (both in percent).
#
# ENV: main R 4.2.2.  Rscript Code/download_census_sahie.R
# =============================================================================

suppressPackageStartupMessages({ library(dplyr); library(jsonlite) })
readRenviron("~/.Renviron")
KEY <- Sys.getenv("CENSUS_API_KEY")
stopifnot(nchar(KEY) > 0)

YEARS  <- 2011:2023
OUT    <- "Data/intermediate_sahie.rds"
LOGDIR <- "Analysis/mechanism/build_logs"
dir.create(LOGDIR, showWarnings = FALSE, recursive = TRUE)
logcon <- file(file.path(LOGDIR, "download_census_sahie.log"), open = "wt")
sink(logcon, split = TRUE); on.exit({ sink(); close(logcon) }, add = TRUE)
cat("=== Census SAHIE 18-64 uninsured ::", format(Sys.time()), "===\n\n")

# one (year, income-category) pull -> data.frame(fips_code, <valname>)
pull <- function(yr, iprcat, valname) {
  url <- sprintf(paste0("https://api.census.gov/data/timeseries/healthins/sahie",
                        "?get=PCTUI_PT&for=county:*&in=state:*&time=%d",
                        "&AGECAT=1&IPRCAT=%d&RACECAT=0&SEXCAT=0&key=%s"),
                 yr, iprcat, KEY)
  m <- tryCatch(fromJSON(url), error = function(e) NULL)
  if (is.null(m) || nrow(m) < 2) return(NULL)
  hdr <- m[1, ]; d <- as.data.frame(m[-1, , drop = FALSE], stringsAsFactors = FALSE)
  names(d) <- hdr
  d$fips_code <- paste0(formatC(as.integer(d[["state"]]), width = 2, flag = "0"),
                        formatC(as.integer(d[["county"]]), width = 3, flag = "0"))
  out <- data.frame(fips_code = d$fips_code,
                    val = suppressWarnings(as.numeric(d[["PCTUI_PT"]])),
                    stringsAsFactors = FALSE)
  names(out)[2] <- valname
  out
}

years_ok <- c()
frames <- lapply(YEARS, function(yr) {
  a <- pull(yr, 0, "Uninsured_18_64")           # all incomes
  b <- pull(yr, 3, "Uninsured_18_64_le138FPL")  # <=138% FPL
  if (is.null(a)) { cat("  SKIP", yr, "(no data — likely not yet released)\n"); return(NULL) }
  years_ok <<- c(years_ok, yr)
  df <- a; if (!is.null(b)) df <- left_join(a, b, by = "fips_code")
  df$Year <- yr
  cat(sprintf("  -> %d : %d counties\n", yr, nrow(df)))
  df
})
sahie <- bind_rows(Filter(Negate(is.null), frames)) %>%
  filter(grepl("^[0-9]{5}$", fips_code)) %>%
  arrange(fips_code, Year)

saveRDS(sahie, OUT)
cat(sprintf("\nWrote %s : %d county-years, %d counties, years %s\n", OUT, nrow(sahie),
            n_distinct(sahie$fips_code), paste(range(years_ok), collapse = "-")))
cat(sprintf("Mean 18-64 uninsured: %.1f%% ; mean <=138%%FPL uninsured: %.1f%%\n",
            mean(sahie$Uninsured_18_64, na.rm = TRUE),
            mean(sahie$Uninsured_18_64_le138FPL, na.rm = TRUE)))
cat("\n=== done", format(Sys.time()), "===\n")
