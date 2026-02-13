# R script to download climate data from NOAA

# Base URL for the climate data
base_url <- "https://www.ncei.noaa.gov/pub/data/cirs/climdiv/"

# List of climate data files to download
file_names <- c(
  "climdiv-tmpccy-v1.0.0-20260107",
  "climdiv-tmincy-v1.0.0-20260107",
  "climdiv-hddccy-v1.0.0-20260107",
  "climdiv-cddccy-v1.0.0-20260107",
  "climdiv-tmaxcy-v1.0.0-20260107",
  "climdiv-pcpncy-v1.0.0-20260107",
  "climdiv-tmpcst-v1.0.0-20260107",
  "climdiv-tminst-v1.0.0-20260107",
  "climdiv-hddcst-v1.0.0-20260107",
  "climdiv-cddcst-v1.0.0-20260107",
  "climdiv-tmaxst-v1.0.0-20260107",
  "climdiv-pcpnst-v1.0.0-20260107",
  "climdiv-pdsist-v1.0.0-20260107",
  "climdiv-phdist-v1.0.0-20260107",
  "climdiv-pmdist-v1.0.0-20260107",
  "climdiv-zndxst-v1.0.0-20260107",
  "climdiv-norm-tmaxst-v1.0.0-20260107"
)

# Create a directory to store the downloaded data
dir.create("Data/Climate_Data", showWarnings = FALSE)

# Loop through the file names and download each file
for (file_name in file_names) {
  # Construct the full URL
  url <- paste0(base_url, file_name)

  # Construct the destination path
  dest_path <- file.path("Data/Climate_Data", file_name)

  # Download the file
  download.file(url, destfile = dest_path, mode = "wb")

  # Print a message to the console
  cat("Downloaded:", file_name, "\n")
}
