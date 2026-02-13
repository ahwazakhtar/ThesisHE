# Test refined scraping strategy (FIXED)
st <- "Alabama"
html_str <- paste(readLines("test_2001.html", warn=FALSE), collapse=" ")

# 1. Clean HTML tags
clean_text <- gsub("<.*?>", " ", html_str)
# 2. Collapse whitespace
clean_text <- gsub("\\s+", " ", clean_text)

cat("Cleaned Text (Fragment):\n")
cat(substr(clean_text, regexpr(st, clean_text)[1], regexpr(st, clean_text)[1] + 100), "\n")

# 3. Find value
# After state name, look for the next numeric sequence
pattern <- paste0(st, "\\s+([0-9,.]+)")
match <- regmatches(clean_text, regexec(pattern, clean_text))[[1]]

if (length(match) >= 2) {
  cat("Found Value:", match[2], "\n")
} else {
  cat("Not Found\n")
}