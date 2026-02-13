
if (!require("rmarkdown")) install.packages("rmarkdown", repos = "http://cran.us.r-project.org")
if (!require("pagedown")) install.packages("pagedown", repos = "http://cran.us.r-project.org")

library(rmarkdown)
library(pagedown)

md_path <- "Text/abstract_draft.md"
html_path <- "Text/abstract_draft.html"
pdf_path <- "Text/abstract_draft.pdf"

# Convert MD to HTML first using a simple template or just basic render
# Since we don't have pandoc directly, we'll try to use pagedown's chrome_print 
# on a temporary HTML or use R's capability to wrap it.

# Create a self-contained HTML
cat("---
title: 'Paper Abstract'
output: html_document
---

", file = "temp_abstract.Rmd")
cat(readLines(md_path), sep="
", append=TRUE, file="temp_abstract.Rmd")

tryCatch({
    # Attempt to render. This might still fail without pandoc.
    render("temp_abstract.Rmd", output_file = "abstract_draft.html")
    # If successful, try to print to PDF
    chrome_print("Text/abstract_draft.html", output = pdf_path)
    cat("Success! PDF created at:", pdf_path, "
")
}, error = function(e) {
    cat("PDF Export failed:", conditionMessage(e), "
")
    cat("However, you can open 'Text/abstract_draft.html' in your browser and 'Print to PDF'.
")
})
