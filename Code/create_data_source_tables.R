# =============================================================================
# create_data_source_tables.R  (thesis_completion_20260704 — Essay 1 §3 data spine)
# =============================================================================
# Builds the two manuscript data tables that introduce the panel in Essay 1 §3:
#
#   E1-T0a  Analysis/descriptive/data_sources_table.{csv,tex}
#           One row per data source: provider, unit of observation, geography,
#           coverage years, observation and unit counts, role in Essay 1.
#
#   E1-T0b  Analysis/descriptive/variable_definitions_table.{csv,tex}
#           One row per variable the essay actually uses: construction,
#           units, source, coverage, and where it appears.
#
# DESIGN RULE: definitions, provider names, and roles are hand-authored metadata
# (they cannot be derived from the data). Every COUNT — year ranges, non-missing
# observations, number of counties/states — is computed from the delivered files
# at build time, so the tables cannot drift from the panel the way a typed table
# would. Nothing here is hand-editable: re-run the script instead.
#
# Real-dollar bases differ by panel (CLAUDE.md cross-cutting rule): the county
# master hardcodes 2023 USD; the state master deflates to the latest year present
# in Data/us_cpi_annual.csv. The state base is therefore READ from that file
# rather than assumed, and printed in the units column.
#
# ENV: R 4.5.2.  Rscript Code/create_data_source_tables.R
# =============================================================================

suppressPackageStartupMessages({ library(dplyr) })

OUT_DIR <- "Analysis/descriptive"

pad_fips <- function(x) formatC(as.integer(x), width = 5, flag = "0")

# --- coverage helpers -------------------------------------------------------
# cover(): non-missing observation count, distinct unit count, and the year
# range over non-missing rows only. `id` is the panel unit column; `yr` the year
# column (NA-safe, and absent for time-invariant sources).
cover <- function(df, col, id, yr = "Year") {
  if (!col %in% names(df)) {
    return(list(n_obs = NA_integer_, n_units = NA_integer_, y0 = NA, y1 = NA))
  }
  ok <- !is.na(df[[col]])
  d <- df[ok, , drop = FALSE]
  list(
    n_obs   = nrow(d),
    n_units = length(unique(d[[id]])),
    y0      = if (yr %in% names(d) && nrow(d)) min(d[[yr]], na.rm = TRUE) else NA,
    y1      = if (yr %in% names(d) && nrow(d)) max(d[[yr]], na.rm = TRUE) else NA
  )
}

fmt_years <- function(y0, y1) {
  if (is.na(y0) || is.na(y1)) return("--")
  if (y0 == y1) as.character(y0) else paste0(y0, "--", y1)
}

fmt_n <- function(x) if (is.na(x)) "--" else formatC(x, format = "d", big.mark = ",")

# --- house number formats (shared by every manuscript table) ----------------
# One rule, applied everywhere: estimates and standard errors to 3 significant
# figures, p-values to 3 decimals, counts as integers with thousands separators.
# sig3() keeps trailing zeros so a column of numbers stays decimal-aligned.
sig3 <- function(x, prefix = "", suffix = "") {
  if (is.na(x)) return("--")
  ax <- abs(x)
  d <- if (ax == 0) 2 else max(0, 2 - floor(log10(ax)))   # 3 significant figures
  d <- min(d, 6)
  paste0(prefix, formatC(x, format = "f", digits = d, big.mark = ","), suffix)
}

# Dollar amounts, with the sign OUTSIDE the currency symbol. sig3(prefix = "$")
# on a negative number yields "$-1,311", which reads as a typo.
usd <- function(x) {
  if (is.na(x)) return("--")
  paste0(if (x < 0) "-$" else "$", sig3(abs(x)))
}

# p-values: 3 decimals, with a floor rather than a spurious "0.000".
sig_p <- function(p) {
  if (is.na(p)) return("--")
  # A plain "<" here, because tex_escape() below turns it into a text-mode
  # less-than. Emitting math delimiters instead got the dollars escaped, so
  # every table printed a literal "$<$0.001" rather than "< 0.001".
  if (p < 0.001) return("<0.001")
  formatC(p, format = "f", digits = 3)
}

# LaTeX escaping for the text columns (definitions carry %, $, _, &).
tex_escape <- function(x) {
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  x <- gsub("([&%$#_{}])", "\\\\\\1", x)
  x <- gsub("~", "\\\\textasciitilde{}", x)
  x <- gsub("\\^", "\\\\textasciicircum{}", x)
  # < and > are comparison glyphs only in math mode; left bare in text mode
  # they set as inverted punctuation and are fragile across font encodings.
  x <- gsub("<", "\\\\textless{}", x)
  x <- gsub(">", "\\\\textgreater{}", x)
  x
}

# Minimal booktabs writer. Uses tabularx so LaTeX solves the column widths
# against \textwidth instead of us hand-computing them (the hand-computed
# version overflowed the scaffold's 1.1in-margin portrait text block).
#
#   align     column spec; must contain at least one X column
#   group_col optional column whose value starts a spanning panel header row;
#             the column itself is dropped (NBER panel convention)
#   landscape wrap in pdflscape for tables too wide for portrait
# resolve_X(): longtable has no X column type, so an align spec written for
# tabularx must have its X column(s) resolved to explicit widths. Budget is the
# 16.5cm text block the template sets, less the fixed p{} columns and the
# inter-column padding (2 x tabcolsep per column, tabcolsep = 4pt = 0.141cm).
resolve_X <- function(align, textwidth_cm = 16.5) {
  fixed <- as.numeric(regmatches(align, gregexpr("(?<=p\\{)[0-9.]+(?=cm\\})",
                                                 align, perl = TRUE))[[1]])
  n_x <- lengths(regmatches(align, gregexpr("\\bX\\b", align)))
  if (n_x == 0L) return(align)
  ncol <- length(fixed) + n_x + lengths(regmatches(align, gregexpr("(?<![{a-zA-Z])[lrc](?![}a-zA-Z])",
                                                                   align, perl = TRUE)))
  avail <- textwidth_cm - sum(fixed) - 0.30 * ncol
  w <- max(1.5, avail / n_x)
  gsub("\\bX\\b", sprintf("p{%.2fcm}", w), align)
}

# `longtable = TRUE` emits a longtable instead of a table float. Use it for any
# table taller than a page: a tabularx inside a `table` float CANNOT break, so
# LaTeX prints it past the bottom margin and the overflow is lost with nothing
# but a "Float too large for page" warning. E1-T0b was overflowing by 1012pt --
# two whole panels and the table note never reached the PDF.
write_tex_table <- function(df, path, align, caption, label, note = NULL,
                            fontsize = "\\footnotesize", group_col = NULL,
                            landscape = FALSE, longtable = FALSE) {
  groups <- NULL
  if (!is.null(group_col) && group_col %in% names(df)) {
    groups <- as.character(df[[group_col]])
    df <- df[, setdiff(names(df), group_col), drop = FALSE]
  }
  ncol_tab <- ncol(df)
  cells <- lapply(df, function(c) tex_escape(as.character(c)))
  body <- do.call(paste, c(cells, sep = " & "))
  body <- paste0(body, " \\\\")

  # Interleave panel headers ahead of the first row of each group.
  if (!is.null(groups)) {
    out <- character(0)
    prev <- NULL
    for (i in seq_along(body)) {
      if (is.null(prev) || groups[i] != prev) {
        if (!is.null(prev)) out <- c(out, "\\addlinespace")
        out <- c(out, paste0("\\multicolumn{", ncol_tab, "}{l}{\\textit{",
                             tex_escape(groups[i]), "}} \\\\"))
        prev <- groups[i]
      }
      out <- c(out, body[i])
    }
    body <- out
  }

  if (longtable) {
    hdr <- paste0(paste(tex_escape(names(df)), collapse = " & "), " \\\\")
    nc  <- ncol_tab
    lines <- c(
      "\\begingroup", fontsize, "\\setlength{\\tabcolsep}{4pt}", "\\sloppy",
      paste0("\\begin{longtable}{", resolve_X(align), "}"),
      paste0("\\caption{", tex_escape(caption), "}"),
      paste0("\\label{", label, "}\\\\"),
      "\\toprule", hdr, "\\midrule", "\\endfirsthead",
      paste0("\\multicolumn{", nc, "}{l}{\\textit{Table \\thetable{} (continued)}} \\\\"),
      "\\toprule", hdr, "\\midrule", "\\endhead",
      paste0("\\midrule \\multicolumn{", nc,
             "}{r}{\\textit{continued on the next page}} \\\\"), "\\endfoot",
      "\\bottomrule", "\\endlastfoot",
      body,
      "\\end{longtable}")
    if (!is.null(note)) {
      lines <- c(lines,
        "\\vspace{-0.6em}\\begin{minipage}{\\textwidth}\\footnotesize",
        tex_escape(note), "\\end{minipage}")
    }
    writeLines(c(lines, "\\endgroup"), path)
    return(invisible(NULL))
  }

  lines <- c(
    if (landscape) "\\begin{landscape}" else NULL,
    "\\begin{table}[htbp]", "\\centering", fontsize,
    "\\setlength{\\tabcolsep}{4pt}",
    # Long source and variable names ("transportation", "Geographic") do not fit
    # the narrow fixed columns at default tolerance; \sloppy trades inter-word
    # spacing for the overfull boxes.
    "\\sloppy",
    paste0("\\caption{", tex_escape(caption), "}"),
    paste0("\\label{", label, "}"),
    # pdflscape rotates the page but leaves \textwidth at its portrait value, so
    # a rotated table must be sized against \textheight to use the wide edge.
    paste0("\\begin{tabularx}{", if (landscape) "\\textheight" else "\\textwidth",
           "}{", align, "}"), "\\toprule",
    paste0(paste(tex_escape(names(df)), collapse = " & "), " \\\\"),
    "\\midrule",
    body,
    "\\bottomrule", "\\end{tabularx}"
  )
  if (!is.null(note)) {
    lines <- c(lines,
      paste0("\\begin{minipage}{", if (landscape) "\\textheight" else "\\textwidth",
             "}\\vspace{0.5em}\\footnotesize"),
      tex_escape(note), "\\end{minipage}")
  }
  lines <- c(lines, "\\end{table}", if (landscape) "\\end{landscape}" else NULL)
  writeLines(lines, path)
}

# Shorthand for a left-aligned, ragged-right fixed-width column.
P <- function(w) paste0(">{\\raggedright\\arraybackslash}p{", w, "cm}")
RX <- ">{\\raggedright\\arraybackslash}X"

if (sys.nframe() == 0L) {
  dir.create(file.path(OUT_DIR, "build_logs"), showWarnings = FALSE, recursive = TRUE)
  lc <- file(file.path(OUT_DIR, "build_logs", "create_data_source_tables.log"), open = "wt")
  sink(lc, split = TRUE); sink(lc, type = "message")
  on.exit({ sink(type = "message"); sink(); close(lc) }, add = TRUE)
  cat("=== Essay 1 data tables (E1-T0a / E1-T0b) ::", format(Sys.time()), "===\n\n")

  # ---- load the delivered panels ------------------------------------------
  cty <- read.csv("Data/county_level_master.csv")
  cty$fips_code <- pad_fips(cty$fips_code)
  st <- read.csv("Data/state_level_analysis_master.csv")

  rds <- function(f) { p <- file.path("Data", f)
    if (!file.exists(p)) stop("missing intermediate: ", p)
    d <- readRDS(p); if ("fips_code" %in% names(d)) d$fips_code <- pad_fips(d$fips_code); d }

  med  <- rds("intermediate_medicare_spending.rds")
  ind  <- rds("intermediate_industry_composition.rds")
  enrg <- rds("intermediate_energy_burden.rds")
  agdp <- rds("intermediate_ag_dependence.rds")
  hum  <- rds("intermediate_humidity_county.rds")
  mig  <- rds("intermediate_migration.rds")

  # State real-dollar base: read, never assume (CLAUDE.md base-divergence trap).
  # Path mirrors create_state_master.R:94 — the state deflator lives under
  # State_Policy_Data/, and its LATEST year is the state master's dollar base.
  cpi_path <- "Data/State_Policy_Data/us_cpi_annual.csv"
  state_base <- if (file.exists(cpi_path)) {
    cpi <- read.csv(cpi_path)
    ycol <- grep("^[Yy]ear$", names(cpi), value = TRUE)[1]
    if (is.na(ycol)) NA_integer_ else max(cpi[[ycol]], na.rm = TRUE)
  } else NA_integer_
  cat("state master real-dollar base year (from us_cpi_annual.csv): ",
      ifelse(is.na(state_base), "UNRESOLVED", state_base), "\n")
  cat("county master real-dollar base year (hardcoded in create_county_master.R): 2023\n\n")
  state_usd <- if (is.na(state_base)) "real USD (base unresolved)" else
    paste0(state_base, " USD")

  # =========================================================================
  # E1-T0a — data sources and coverage
  # =========================================================================
  # `key` is the column whose non-missingness defines the source's coverage.
  src_spec <- list(
    list(domain = "Climate",       source = "NOAA NCEI (nClimDiv)",
         data = "cty", key = "cdd_val", id = "fips_code", unit = "County-year",
         geo = "US counties",
         role = "Heat, cold, and drought shock construction"),
    list(domain = "Air quality",   source = "EPA AQS annual AQI",
         data = "cty", key = "Max_AQI", id = "fips_code", unit = "County-year",
         geo = "Monitored counties",
         role = "Air-quality shock in the Medicare models"),
    list(domain = "Humidity",      source = "PRISM (Oregon State / NACSE)",
         data = "hum", key = "tdmean_F", id = "fips_code", unit = "County-year",
         geo = "CONUS counties",
         role = "Humidity robustness check only"),
    list(domain = "Income",        source = "BEA CAINC1 / CAINC5N",
         data = "cty", key = "PCPI_Real", id = "fips_code", unit = "County-year",
         geo = "US counties",
         role = "Per-capita income outcome; farm/nonfarm split in Appendix A"),
    list(domain = "Employment",    source = "Census ACS 5-year (B23025)",
         data = "cty", key = "Civilian_Employed", id = "fips_code", unit = "County-year",
         geo = "US counties",
         role = "Employment outcome and labor-exposure moderator"),
    list(domain = "Medical debt",  source = "Urban Institute (credit-bureau, Aug snapshots)",
         data = "cty", key = "Medical_Debt_Share", id = "fips_code", unit = "County-year",
         geo = "US counties",
         role = "Debt-ledger outcome; treated as measurement-fragile"),
    list(domain = "ACA premiums",  source = "HIX Compare individual market",
         data = "cty", key = "Benchmark_Silver_Real", id = "fips_code", unit = "County-year (rating-area price)",
         geo = "Marketplace rating areas",
         role = "Pass-through outcome; estimated at the rating-area level"),
    list(domain = "Medicare",      source = "CMS Geographic Variation PUF",
         data = "med", key = "Mdcr_Std_Payment_PC", id = "fips_code", unit = "County-year",
         geo = "US counties, 65+/disabled",
         role = "Main result: standardized spending and ED visits"),
    list(domain = "Industry mix",  source = "Census ACS C24030",
         data = "ind", key = "ClimateExposed_NonFarm_Share", id = "fips_code", unit = "County-year",
         geo = "US counties",
         role = "Climate-exposed non-farm share moderator"),
    list(domain = "Energy burden", source = "DOE LEAD 2022",
         data = "enrg", key = "Energy_Burden_Pct", id = "fips_code", unit = "County (time-invariant)",
         geo = "US counties",
         role = "Energy-burden moderator"),
    list(domain = "Ag dependence", source = "USDA ERS Typology + BEA CAINC5N",
         data = "agdp", key = "Farm_Earnings_Share", id = "fips_code", unit = "County (time-invariant)",
         geo = "US counties",
         role = "Agricultural-channel tests in Appendix A"),
    list(domain = "Migration",     source = "IRS SOI county-to-county flows",
         data = "mig", key = "net_migration_rate", id = "fips_code", unit = "County-year",
         geo = "US counties",
         role = "Selection bound on the drought scar (Appendix A)"),
    list(domain = "Health spending", source = "CMS National Health Expenditure Accounts",
         data = "st", key = "Total_Per_Capita_Health_Exp_Real", id = "State", unit = "State-year",
         geo = "US states",
         role = "Systemic-spending null (contrast motivating household ledgers)"),
    list(domain = "Macro controls", source = "BLS / BEA via FRED",
         data = "st", key = "Unemployment_Rate", id = "State", unit = "State-year",
         geo = "US states",
         role = "State-panel controls and debt-series context")
  )

  envs <- list(cty = cty, st = st, med = med, ind = ind, enrg = enrg,
               agdp = agdp, hum = hum, mig = mig)

  src <- do.call(rbind, lapply(src_spec, function(s) {
    d <- envs[[s$data]]
    cv <- cover(d, s$key, s$id)
    data.frame(
      Domain = s$domain, Source = s$source,
      `Unit and geography` = paste0(s$unit, "; ", s$geo),
      Years = fmt_years(cv$y0, cv$y1),
      `Obs.` = fmt_n(cv$n_obs), Units = fmt_n(cv$n_units),
      `Role in Essay 1` = s$role,
      check.names = FALSE, stringsAsFactors = FALSE)
  }))

  write.csv(src, file.path(OUT_DIR, "data_sources_table.csv"), row.names = FALSE)
  # The CSV keeps Years/Obs./Units as separate machine-readable fields; the
  # printed table merges them into one Coverage column so the text columns get
  # enough width to read at portrait size.
  src_tex <- data.frame(
    Domain = src$Domain, Source = src$Source,
    `Unit and geography` = src$`Unit and geography`,
    Coverage = ifelse(src$Years == "--",
                      paste0(src$Units, " counties"),
                      paste0(src$Years, "; ", src$`Obs.`, " obs.; ",
                             src$Units, " units")),
    `Role in Essay 1` = src$`Role in Essay 1`,
    check.names = FALSE, stringsAsFactors = FALSE)
  write_tex_table(
    src_tex, file.path(OUT_DIR, "data_sources_table.tex"),
    align = paste0(P(1.8), " ", RX, " ", P(2.9), " ", P(2.9), " ", P(3.1)),
    caption = "Data sources, coverage, and role in Essay 1", longtable = TRUE,
    label = "tab:e1t0a",
    note = paste0(
      "Coverage is computed from the delivered files at build time: `Years' is the ",
      "range over non-missing observations, `Obs.' the count of non-missing ",
      "observations, and `Units' the number of distinct counties or states with at ",
      "least one non-missing value. Counts therefore reflect data availability, not ",
      "the estimation sample, which is 2011--2023 for county outcomes, 2014--2023 for ",
      "Medicare, and the marketplace era for premiums. County dollar series are in ",
      "2023 USD; state dollar series are in ", state_usd, "."))
  cat("wrote data_sources_table.{csv,tex} —", nrow(src), "sources\n")

  # =========================================================================
  # E1-T0b — variable definitions
  # =========================================================================
  var_spec <- list(
    # ---- shocks ----
    list(grp = "Climate shocks", var = "High_CDD", data = "cty", id = "fips_code",
         label = "Heat shock",
         defn = "1 if annual cooling degree days are at or above the national 80th percentile of the 1990--2000 baseline distribution",
         units = "Binary", src = "NOAA NCEI",
         use = "Main Medicare models; labor-exposure interactions"),
    list(grp = "Climate shocks", var = "High_HDD", data = "cty", id = "fips_code",
         label = "Cold shock",
         defn = "1 if annual heating degree days are at or above the national 80th percentile of the 1990--2000 baseline distribution",
         units = "Binary", src = "NOAA NCEI",
         use = "Medicare models; debt ledger"),
    list(grp = "Climate shocks", var = "Is_Extreme_Drought", data = "cty", id = "fips_code",
         label = "Extreme drought",
         defn = "1 if the annual mean Palmer Drought Severity Index is at or below -4",
         units = "Binary", src = "NOAA NCEI",
         use = "Debt ledger; premium pass-through; Appendix A event"),
    list(grp = "Climate shocks", var = "Max_AQI", data = "cty", id = "fips_code",
         label = "Air-quality shock",
         defn = "Annual maximum AQI; the shock indicator is Max AQI above 100 (EPA `unhealthy' threshold)",
         units = "AQI index", src = "EPA AQS",
         use = "Medicare ED-visit models"),
    list(grp = "Climate shocks", var = "Z_Temp", data = "cty", id = "fips_code",
         label = "Temperature z-score",
         defn = "Annual mean temperature standardized to each county's own 1990--2000 mean and standard deviation",
         units = "SD", src = "NOAA NCEI",
         use = "Continuous-dose robustness"),
    # ---- outcomes ----
    list(grp = "Outcomes", var = "Mdcr_Std_Payment_PC", data = "med", id = "fips_code",
         label = "Medicare standardized spending",
         defn = "Standardized Medicare payment per beneficiary, price-adjusted by CMS to remove geographic payment-rate variation",
         units = "USD per beneficiary", src = "CMS Geographic Variation",
         use = "Main result"),
    list(grp = "Outcomes", var = "ER_Visits_per1000", data = "med", id = "fips_code",
         label = "Medicare ED visits",
         defn = "Emergency department visits per 1,000 Medicare beneficiaries",
         units = "Visits per 1,000", src = "CMS Geographic Variation",
         use = "Main result"),
    list(grp = "Outcomes", var = "PCPI_Real", data = "cty", id = "fips_code",
         label = "Per-capita personal income",
         defn = "BEA per-capita personal income, CPI-deflated",
         units = "2023 USD", src = "BEA CAINC1",
         use = "Household economic capacity; Appendix A"),
    list(grp = "Outcomes", var = "Civilian_Employed", data = "cty", id = "fips_code",
         label = "Civilian employment",
         defn = "Count of employed civilians; estimated in logs so effects are proportional rather than county-size driven",
         units = "Persons (log)", src = "ACS B23025",
         use = "Employment margin; labor-exposure interactions"),
    list(grp = "Outcomes", var = "Medical_Debt_Share", data = "cty", id = "fips_code",
         label = "Medical debt share",
         defn = "Share of credit records with medical debt in collections",
         units = "Share", src = "Urban Institute",
         use = "Debt ledger (measurement-fragile)"),
    list(grp = "Outcomes", var = "Benchmark_Silver_Real", data = "cty", id = "fips_code",
         label = "Benchmark silver premium",
         defn = "Second-lowest-cost silver marketplace premium, CPI-deflated; aggregated to rating-area by population-weighted mean for estimation",
         units = "2023 USD per month", src = "HIX Compare",
         use = "Pass-through null and equivalence bounds"),
    list(grp = "Outcomes", var = "Lowest_Bronze_Real", data = "cty", id = "fips_code",
         label = "Lowest bronze premium",
         defn = "Lowest-cost bronze marketplace premium, CPI-deflated",
         units = "2023 USD per month", src = "HIX Compare",
         use = "Pass-through robustness"),
    list(grp = "Outcomes", var = "Total_Per_Capita_Health_Exp_Real", data = "st", id = "State",
         label = "Health spending per capita",
         defn = "State personal health-care expenditure per capita, CPI-deflated",
         units = state_usd, src = "CMS NHE",
         use = "Systemic-spending null"),
    # ---- moderators ----
    list(grp = "Moderators", var = "ClimateExposed_NonFarm_Share_baseline", data = "ind", id = "fips_code",
         tinv = TRUE,
         label = "Climate-exposed non-farm share",
         defn = "Baseline share of employment in construction, manufacturing, transportation and warehousing, and utilities; held fixed at its baseline value and entered as a z-score",
         units = "Share (z-scored)", src = "ACS C24030",
         use = "Labor-exposure mechanism"),
    list(grp = "Moderators", var = "Energy_Burden_Pct", data = "enrg", id = "fips_code",
         label = "Household energy burden",
         defn = "Household-weighted energy expenditure as a percentage of income; time-invariant, entered as a z-score",
         units = "Percent of income (z-scored)", src = "DOE LEAD 2022",
         use = "Energy-burden mechanism"),
    list(grp = "Moderators", var = "Farm_Earnings_Share", data = "agdp", id = "fips_code",
         label = "Farm earnings share",
         defn = "Farm earnings as a share of total county earnings over the baseline period; time-invariant, entered as a z-score",
         units = "Share (z-scored)", src = "BEA CAINC5N / USDA ERS",
         use = "Agricultural-channel tests (Appendix A)"),
    # ---- auxiliary ----
    list(grp = "Auxiliary", var = "Population", data = "cty", id = "fips_code",
         label = "County population",
         defn = "Census population; used for population weights in rating-area aggregation and per-capita denominators",
         units = "Persons", src = "Census",
         use = "Weighting and aggregation"),
    list(grp = "Auxiliary", var = "net_migration_rate", data = "mig", id = "fips_code",
         label = "Net migration rate",
         defn = "Net IRS filer migration as a share of non-migrant filers",
         units = "Rate", src = "IRS SOI",
         use = "Selection bound (Appendix A)"),
    list(grp = "Auxiliary", var = "tdmean_F", data = "hum", id = "fips_code",
         label = "Dew-point temperature",
         defn = "Annual mean dew-point temperature from 4km PRISM grids aggregated to counties",
         units = "Degrees F", src = "PRISM",
         use = "Humidity robustness"),
    list(grp = "Auxiliary", var = "Uninsured_Rate", data = "cty", id = "fips_code",
         label = "Uninsured rate",
         defn = "Share of the under-65 population without health insurance",
         units = "Share", src = "Census SAHIE",
         use = "Debt measurement critique")
  )

  vars <- do.call(rbind, lapply(var_spec, function(v) {
    d <- envs[[v$data]]
    cv <- cover(d, v$var, v$id)
    # Time-invariant moderators are stored on a county-year frame but carry no
    # within-county variation; reporting their panel year range would overstate
    # what they measure, so report the county count alone.
    tinv <- isTRUE(v$tinv)
    data.frame(
      Group = v$grp, Variable = v$label, Definition = v$defn,
      Units = v$units, Source = v$src,
      Years = if (tinv) "--" else fmt_years(cv$y0, cv$y1),
      `Obs.` = if (tinv) fmt_n(cv$n_units) else fmt_n(cv$n_obs),
      Counties = fmt_n(cv$n_units),
      `Used in` = v$use, Column = v$var,
      check.names = FALSE, stringsAsFactors = FALSE)
  }))

  missing_cols <- vars$Column[vars$`Obs.` == "--"]
  if (length(missing_cols)) {
    warning("columns not found in their panel: ", paste(missing_cols, collapse = ", "))
    cat("WARNING — columns not found:", paste(missing_cols, collapse = ", "), "\n")
  }

  write.csv(vars, file.path(OUT_DIR, "variable_definitions_table.csv"), row.names = FALSE)
  # As above: rich CSV, readable LaTeX. Units are appended to the definition and
  # the three coverage fields collapse into one column.
  vars_tex <- data.frame(
    Group = vars$Group, Variable = vars$Variable,
    Definition = paste0(vars$Definition, " (", vars$Units, ")"),
    Source = vars$Source,
    Coverage = ifelse(vars$Years == "--",
                      paste0(vars$Counties, " counties"),
                      paste0(vars$Years, "; ", vars$`Obs.`, " obs.")),
    `Used in` = vars$`Used in`,
    check.names = FALSE, stringsAsFactors = FALSE)
  write_tex_table(
    vars_tex, file.path(OUT_DIR, "variable_definitions_table.tex"),
    align = paste0(P(2.7), " ", RX, " ", P(2.1), " ", P(2.7), " ", P(2.5)),
    group_col = "Group",
    caption = "Variable definitions, sources, and coverage", longtable = TRUE,
    label = "tab:e1t0b",
    note = paste0(
      "Coverage columns are computed from the delivered panels: `Years' spans ",
      "non-missing observations, `Obs.' counts them, and `Counties' is the number of ",
      "distinct counties (states, for the state panel) with at least one non-missing ",
      "value. Time-invariant moderators report a single county count and no year range. ",
      "County dollar series are in 2023 USD; state dollar series are in ", state_usd, ". ",
      "Shock indicators use a fixed national 80th-percentile threshold from the ",
      "1990--2000 baseline, so a county's shock status is comparable over time. ",
      "The machine-readable CSV carries an additional `Column' field giving the exact ",
      "variable name in the delivered panel."))
  cat("wrote variable_definitions_table.{csv,tex} —", nrow(vars), "variables\n")

  # =========================================================================
  # E1-T1 (print version) — descriptive statistics, manuscript layout
  # =========================================================================
  # The generated descriptive table from run_descriptive_stats.R carries ten
  # columns (three separate quantile groups, winsorized and population-weighted
  # means, min/max). At manuscript width it can only be shown scaled down far
  # enough to be hard to read. This is the same content reduced to what a reader
  # of the essay needs -- level, spread, and coverage -- so it prints full size.
  # The upstream summary labels rows with the analyst-facing names carried in
  # the panel (High CDD, PDSI, Z-score). A first-time reader of the essay has
  # met none of those, so the print layer relabels them in words. Keyed on
  # Raw_Variable, which is stable, rather than on the display string.
  DS_LAB <- c(
    Z_Temp = "Temperature, standard deviations from the county's 1990--2000 mean",
    Z_Precip = "Precipitation, standard deviations from the county's 1990--2000 mean",
    High_CDD = "Extreme heat (cooling degree days above the national 80th percentile)",
    High_HDD = "Extreme cold (heating degree days above the national 80th percentile)",
    pdsi_val = "Palmer Drought Severity Index, annual mean",
    Is_Extreme_Drought = "Extreme drought (Palmer index at or below -4)",
    Medical_Debt_Share = "Share of adults with medical debt in collections",
    Medical_Debt_Median_2023 = "Median medical debt in collections (2023 USD)",
    Benchmark_Silver_Real = "Benchmark silver premium, monthly (2023 USD)",
    Lowest_Bronze_Real = "Lowest bronze premium, monthly (2023 USD)",
    Hosp_BadDebt_Total_Real = "Hospital bad debt, annual total (2023 USD)",
    Hosp_Charity_Total_Real = "Hospital charity care, annual total (2023 USD)",
    Uninsured_Rate = "Uninsured share of the under-65 population",
    PCPI_Real = "Per-capita personal income (2023 USD)",
    Med_HH_Income_Real = "Median household income (2023 USD)",
    Civilian_Employed = "Civilian employment (persons)",
    Household_Income_2023 = "Household income, credit-bureau file (2023 USD)",
    Population = "County population")
  # The upstream domain is "Climate and Air Quality", but no air-quality series
  # is summarised here -- monitors cover 1,194 counties, so air quality is
  # described in the data-sources and variable-definition tables instead.
  DS_GROUP <- c("Climate and Air Quality" = "Climate exposure",
                "Health and Financial Outcomes" = "Health and financial outcomes",
                "Socioeconomic Outcomes" = "Household and local economy")

  ds_path <- file.path(OUT_DIR, "descriptive_stats_summary.csv")
  if (file.exists(ds_path)) {
    ds <- read.csv(ds_path, stringsAsFactors = FALSE)
    unlabelled <- setdiff(ds$Raw_Variable, names(DS_LAB))
    if (length(unlabelled)) stop("no plain-language label for: ",
                                 paste(unlabelled, collapse = ", "))
    ds_tex <- data.frame(
      Group = unname(DS_GROUP[ds$Domain]),
      Variable = unname(DS_LAB[ds$Raw_Variable]),
      N = vapply(ds$N, fmt_n, character(1)),   # fmt_n is scalar-only
      `Mean (SD)` = paste0(vapply(ds$Mean, sig3, character(1)),
                           " (", vapply(ds$SD, sig3, character(1)), ")"),
      Median = vapply(ds$Median, sig3, character(1)),
      `P10--P90` = paste0(vapply(ds$P10, sig3, character(1)), "--",
                          vapply(ds$P90, sig3, character(1))),
      `Missing` = paste0(vapply(ds$Missing_Pct, sig3, character(1)), "%"),
      check.names = FALSE, stringsAsFactors = FALSE)

    write.csv(ds_tex, file.path(OUT_DIR, "descriptive_stats_print.csv"), row.names = FALSE)
    write_tex_table(
      ds_tex, file.path(OUT_DIR, "descriptive_stats_print.tex"),
      align = paste0(RX, " r ", P(2.6), " r ", P(2.7), " r"),
      group_col = "Group", fontsize = "\\footnotesize",
      caption = "Descriptive statistics, county panel 2011--2023", longtable = TRUE,
      label = "tab:e1t1",
      note = paste0(
        "One row per variable, pooled over county-years in the estimation panel. ",
        "N counts county-years with a value and `Missing' the share of panel rows ",
        "without one; `P10--P90' brackets the middle eighty percent of counties. ",
        "The two shock indicators take the value 1 in a shock year and 0 otherwise, ",
        "so their means are the share of county-years flagged. Means and standard ",
        "deviations are given to three significant figures and dollar series are in ",
        "2023 dollars. County size is heavily right-skewed -- the mean county has ",
        "about four times the employment of the median -- so these unweighted means ",
        "describe the typical county rather than the typical resident."))
    cat("wrote descriptive_stats_print.{csv,tex} —", nrow(ds_tex), "variables\n")
  } else {
    cat("SKIP descriptive print table — ", ds_path, " not found\n")
  }

  cat("\n=== done ===\n")
}
