
url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=CPIAUCNS"
dest <- "Data/State_Policy_Data/us_cpi_annual_test.csv"
tryCatch({
  download.file(url, destfile = dest, method="libcurl", mode="wb")
  print("Success")
}, error = function(e) {
  print(e)
})
