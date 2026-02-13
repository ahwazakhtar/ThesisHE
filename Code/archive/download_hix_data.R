# R script to download HIX data from hix-compare.org
# NOTE: This script is not currently functional. The data is not available for direct download.
# To access the data, you must contact HIXsupport@ideonapi.com as per https://hix-compare.org/.

# # Base URL for the HIX data
# base_url <- "https://hix-compare.org/data-sets/"
# 
# # List of years to download data for
# years <- 2014:2026
# 
# # Create a directory to store the downloaded data
# dir.create("Data/HIX_Data", showWarnings = FALSE)
# 
# # Loop through the years and download each file
# for (year in years) {
#   # Construct the file name
#   file_name <- paste0(year, "_individual_market_data.zip")
# 
#   # Construct the full URL
#   url <- paste0(base_url, file_name)
# 
#   # Construct the destination path
#   dest_path <- file.path("Data/HIX_Data", file_name)
# 
#   # Download the file
#   download.file(url, destfile = dest_path, mode = "wb")
# 
#   # Print a message to the console
#   cat("Downloaded:", file_name, "\n")
# }
