# ---------------------------------------------------------------------------
# medicaid_expansion.R  (Hospital Supply-Side Integration — Phase 1)
#
# ACA Medicaid expansion adoption, hardcoded from KFF "Status of State Medicaid
# Expansion Decisions" implementation dates.
#   Source: KFF, https://www.kff.org/medicaid/issue-brief/status-of-state-medicaid-expansion-decisions/
#
# `expansion_year` is the calendar year in which expansion was in effect for the
# bulk of that year (Jan-effective states use that year; states whose expansion
# took effect in the second half of a year are credited to the following year —
# e.g. NH 2014-08, NC 2023-12). MedicaidExpansion = as.integer(Year >= expansion_year);
# states absent from the table never expanded within the panel window -> 0.
#
# Keys are 2-letter USPS abbreviations to match the NASHP `State` field and the
# county master's `State` column.
# ---------------------------------------------------------------------------

medicaid_expansion_year <- c(
  # Effective 2014-01-01 (ACA "day one" expanders) + DC
  AZ = 2014, AR = 2014, CA = 2014, CO = 2014, CT = 2014, DE = 2014, DC = 2014,
  HI = 2014, IL = 2014, IA = 2014, KY = 2014, MD = 2014, MA = 2014, MN = 2014,
  NV = 2014, NJ = 2014, NM = 2014, NY = 2014, ND = 2014, OH = 2014, OR = 2014,
  RI = 2014, VT = 2014, WA = 2014, WV = 2014,
  MI = 2014,  # 2014-04-01
  NH = 2015,  # 2014-08-15 -> first full year 2015
  PA = 2015,  # 2015-01-01
  IN = 2015,  # 2015-02-01
  AK = 2016,  # 2015-09-01 -> first full year 2016
  MT = 2016,  # 2016-01-01
  LA = 2016,  # 2016-07-01
  VA = 2019,  # 2019-01-01
  ME = 2019,  # 2019-01-01 (court-ordered)
  UT = 2020,  # 2020-01-01
  ID = 2020,  # 2020-01-01
  NE = 2021,  # 2020-10-01 -> first full year 2021
  OK = 2021,  # 2021-07-01
  MO = 2021,  # 2021-10-01
  SD = 2023,  # 2023-07-01
  NC = 2024   # 2023-12-01 -> outside panel coverage in practice
)

# Returns an integer 0/1 vector: was `state` (USPS abbrev) expanded in `year`?
medicaid_expanded <- function(state, year) {
  st <- toupper(trimws(as.character(state)))
  yr <- suppressWarnings(as.integer(year))
  thr <- medicaid_expansion_year[st]
  out <- as.integer(!is.na(thr) & yr >= thr)
  out[is.na(yr)] <- NA_integer_
  unname(out)
}
