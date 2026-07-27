# pkgreview-check.R
#
# Deterministic checks for the mechanical subset of the pkgreview
# review standard (pkgcheck pattern, openwashdata/pkgreview#13).
#
# Usage:
#   Rscript pkgreview-check.R [package-dir] [--analytics=plausible|none]
#     package-dir  default: current directory
#     --analytics  default plausible; pass none when the org profile
#                  (references/orgs/) defines no analytics header
#
# Output: a Markdown report on stdout, grouped by review area, one line
# per check with PASS / FAIL / FLAG / NOT RUN and the observed counts.
# Exit status: 1 if any required-tier check FAILs, 0 otherwise.
#
# Scope: only checks that are mechanically decidable. Judgment items
# (description quality, provenance prose, plausibility of values,
# tidy-data structure) are NOT here and stay with the reviewer. The PII
# item is reported as FLAG only: the standard forbids any agent or
# script from certifying it (premortem constraint P6).
#
# Base R only. The per-package cross-field pairs live in
# CROSS_FIELD_PAIRS below; extend the list for packages with known
# part/whole or date-order relations.

args <- commandArgs(trailingOnly = TRUE)
flags <- grep("^--", args, value = TRUE)
pos <- setdiff(args, flags)
analytics <- sub("^--analytics=", "", grep("^--analytics=", flags, value = TRUE))
analytics <- if (length(analytics)) analytics[[1]] else "plausible"
if (!analytics %in% c("plausible", "none"))
  stop("Unknown --analytics value: ", analytics, " (expected plausible or none)")
pkg <- if (length(pos) >= 1) pos[[1]] else "."
if (!dir.exists(pkg)) stop("Package directory not found: ", pkg)

CROSS_FIELD_PAIRS <- list(
  c(part = "women_users", whole = "users_count")
)

PLACEHOLDERS <- c("", "TODO", "TBD", "todo", "tbd", "...", "description")
SENTINELS <- c(-99, -999, -9999)

results <- data.frame(
  area = character(), tier = character(), status = character(),
  check = character(), detail = character(), stringsAsFactors = FALSE
)
add <- function(area, tier, status, check, detail = "") {
  results[nrow(results) + 1L, ] <<- list(area, tier, status, check, detail)
}

path <- function(...) file.path(pkg, ...)
has <- function(...) file.exists(path(...))
read_lines_if <- function(...) if (has(...)) readLines(path(...), warn = FALSE) else character()

# ---------------------------------------------------------------------------
# Load package data
# ---------------------------------------------------------------------------

desc <- if (has("DESCRIPTION")) read.dcf(path("DESCRIPTION")) else NULL
dfield <- function(f) if (!is.null(desc) && f %in% colnames(desc)) unname(desc[1, f]) else NA_character_

rda_files <- if (dir.exists(path("data"))) list.files(path("data"), "\\.rda$") else character()
datasets <- list()
for (f in rda_files) {
  e <- new.env()
  ok <- tryCatch({ load(path("data", f), envir = e); TRUE }, error = function(err) FALSE)
  if (ok) for (nm in ls(e)) datasets[[nm]] <- get(nm, envir = e)
}

# ---------------------------------------------------------------------------
# Area 1: metadata
# ---------------------------------------------------------------------------

lic <- dfield("License")
add("metadata", "required",
    if (!is.na(lic) && grepl("CC BY 4.0", lic, fixed = TRUE)) "PASS" else "FAIL",
    "License: CC BY 4.0", paste("License field:", ifelse(is.na(lic), "missing", lic)))

cff <- read_lines_if("CITATION.cff")
if (length(cff) == 0) {
  add("metadata", "required", "FAIL", "CITATION.cff present and valid", "file missing")
} else {
  add("metadata", "required", "PASS", "CITATION.cff present", "")
  v_desc <- dfield("Version")
  v_cff <- sub("^version:\\s*['\"]?([^'\"]*)['\"]?\\s*$", "\\1", grep("^version:", cff, value = TRUE)[1])
  add("metadata", "required",
      if (!is.na(v_desc) && length(v_cff) == 1 && identical(v_desc, v_cff)) "PASS" else "FAIL",
      "CITATION.cff version matches DESCRIPTION",
      sprintf("DESCRIPTION %s vs CITATION.cff %s", v_desc, v_cff))
  placeholder_auth <- any(grepl("Firstname|Lastname", cff)) ||
    any(grepl("Firstname|Lastname", read_lines_if("inst", "CITATION")))
  add("metadata", "required",
      if (placeholder_auth) "FAIL" else "PASS",
      "Citation files carry real authors, not template placeholders",
      if (placeholder_auth) "\"Firstname Lastname\" found in citation files" else "")
  add("metadata", "advisory",
      if (any(grepl("^keywords:", cff))) "PASS" else "FAIL",
      "CITATION.cff carries keywords for discovery", "")
}

title <- dfield("Title")
add("metadata", "advisory",
    if (!is.na(title) && nchar(title) <= 65) "PASS" else "FAIL",
    "Title is under 65 characters",
    sprintf("%d characters", ifelse(is.na(title), 0L, nchar(title))))

# ---------------------------------------------------------------------------
# Area 2: data
# ---------------------------------------------------------------------------

add("data", "required",
    if (dir.exists(path("data-raw")) && length(list.files(path("data-raw"))) > 0) "PASS" else "FAIL",
    "Raw data files preserved in data-raw/", "")
add("data", "required",
    if (has("data-raw", "data_processing.R")) "PASS" else "FAIL",
    "data_processing.R in data-raw/", "")
add("data", "required",
    if (length(rda_files) > 0 && length(datasets) > 0) "PASS" else "FAIL",
    "Primary data present in data/ as .rda and loads",
    sprintf("%d file(s), %d dataset(s)", length(rda_files), length(datasets)))

ext <- if (dir.exists(path("inst", "extdata"))) list.files(path("inst", "extdata")) else character()
add("data", "required",
    if (any(grepl("\\.csv$", ext)) && any(grepl("\\.xlsx$", ext))) "PASS" else "FAIL",
    "CSV and XLSX exports in inst/extdata/", paste(ext, collapse = ", "))

# Dictionary: coverage and description quality
dict_path <- path("data-raw", "dictionary.csv")
if (!file.exists(dict_path)) {
  add("data", "required", "FAIL", "data-raw/dictionary.csv present", "file missing")
} else {
  dict <- read.csv(dict_path, stringsAsFactors = FALSE)
  all_vars <- unique(unlist(lapply(datasets, names)))
  missing_vars <- setdiff(all_vars, dict$variable_name)
  add("data", "required",
      if (length(missing_vars) == 0) "PASS" else "FAIL",
      "Dictionary covers every variable in every dataset",
      if (length(missing_vars)) paste("missing:", paste(missing_vars, collapse = ", ")) else "")
  desc_col <- if ("description" %in% names(dict)) dict$description else rep("", nrow(dict))
  bad <- is.na(desc_col) | trimws(desc_col) %in% PLACEHOLDERS
  add("data", "required",
      if (!any(bad)) "PASS" else "FAIL",
      "Dictionary descriptions present (no empty or placeholder)",
      if (any(bad)) paste("defective:", paste(dict$variable_name[bad], collapse = ", ")) else "")
}

# PII signal scan: FLAG only, never PASS (premortem P6: no agent or
# script certifies the PII item)
pii_name_re <- "(^|_)(phone|mobile|email|e_mail|first_name|last_name|surname|national_id|passport|beneficiary)"
pii_cols <- character()
for (nm in names(datasets)) {
  df <- datasets[[nm]]
  hits <- names(df)[grepl(pii_name_re, names(df), ignore.case = TRUE)]
  for (col in setdiff(names(df), names(df)[grepl("date", names(df), ignore.case = TRUE)])) {
    x <- df[[col]]
    if (is.character(x)) {
      nz <- x[!is.na(x) & nzchar(x)]
      if (length(nz) > 0) {
        phone_like <- grepl("^\\+?[0-9][0-9 ()/-]{7,}$", nz) &
          nchar(gsub("[^0-9]", "", nz)) >= 9
        if (mean(phone_like) > 0.5) hits <- c(hits, col)
        if (mean(grepl("@.+\\.", nz)) > 0.5) hits <- c(hits, col)
      }
    }
  }
  pii_cols <- c(pii_cols, unique(hits))
}
add("data", "required",
    if (length(pii_cols)) "FLAG" else "FLAG",
    "PII signal scan (never auto-certified; human sign-off required)",
    if (length(pii_cols)) paste("suspicious columns:", paste(unique(pii_cols), collapse = ", "))
    else "no suspicious column names or value patterns detected; the item still requires the intake screen and human judgment")

# Per-dataset mechanical checks
for (nm in names(datasets)) {
  df <- datasets[[nm]]
  lab <- function(s) sprintf("%s [%s]", s, nm)

  # NA sentinels and pseudo-NA strings
  sent <- 0L; sent_cols <- character()
  for (col in names(df)) {
    x <- df[[col]]
    n <- if (is.numeric(x)) sum(x %in% SENTINELS, na.rm = TRUE)
         else if (is.character(x)) sum(trimws(x) %in% c("N/A", "NULL", "-99"), na.rm = TRUE)
         else 0L
    if (n > 0) { sent <- sent + n; sent_cols <- c(sent_cols, sprintf("%s (%d)", col, n)) }
  }
  add("data", "advisory", if (sent == 0) "PASS" else "FAIL",
      lab("Missing values coded as NA, no sentinels"),
      if (sent) paste("sentinel values in:", paste(sent_cols, collapse = ", ")) else "")

  # UTF-8 encoding
  enc_cols <- character()
  for (col in names(df)) {
    x <- df[[col]]
    if (is.character(x) && (any(Encoding(x) == "latin1") || !all(validUTF8(x[!is.na(x)]))))
      enc_cols <- c(enc_cols, col)
  }
  add("data", "advisory", if (length(enc_cols) == 0) "PASS" else "FAIL",
      lab("All text data encoded in UTF-8"),
      if (length(enc_cols)) paste("non-UTF-8:", paste(enc_cols, collapse = ", ")) else "")

  # Date columns stored as Date class
  date_cols <- names(df)[grepl("date", names(df), ignore.case = TRUE)]
  bad_dates <- date_cols[!vapply(df[date_cols], function(x) inherits(x, "Date"), logical(1))]
  if (length(date_cols))
    add("data", "advisory", if (length(bad_dates) == 0) "PASS" else "FAIL",
        lab("Date variables stored as Date class"),
        if (length(bad_dates)) paste("not Date class:", paste(bad_dates, collapse = ", ")) else "")

  # Categorical case collisions
  cat_bad <- character()
  for (col in names(df)) {
    x <- df[[col]]
    if (is.character(x) && length(unique(tolower(x))) < length(unique(x)))
      cat_bad <- c(cat_bad, sprintf("%s (%d variants, %d after case-folding)",
                                    col, length(unique(x)), length(unique(tolower(x)))))
  }
  add("data", "advisory", if (length(cat_bad) == 0) "PASS" else "FAIL",
      lab("Categorical values consistent (no case-only variants)"),
      paste(cat_bad, collapse = "; "))

  # Unique identifiers
  id_cols <- names(df)[grepl("^id$|_id$", names(df), ignore.case = TRUE)]
  for (col in id_cols) {
    d <- sum(duplicated(df[[col]]))
    add("data", "advisory", if (d == 0) "PASS" else "FAIL",
        lab(sprintf("Unique identifier `%s` is unique", col)),
        if (d) sprintf("%d duplicated value(s): %s", d,
                       paste(unique(df[[col]][duplicated(df[[col]])]), collapse = ", ")) else "")
  }

  # Exact duplicate rows, full and non-ID
  full_dup <- sum(duplicated(df))
  non_id <- setdiff(names(df), id_cols)
  nonid_dup <- if (length(non_id)) sum(duplicated(df[non_id])) else 0L
  add("data", "advisory", if (full_dup + nonid_dup == 0) "PASS" else "FAIL",
      lab("Exact duplicate rows (full and non-ID columns)"),
      sprintf("full: %d, non-ID: %d", full_dup, nonid_dup))

  # snake_case column names
  bad_names <- names(df)[grepl("[A-Z]", names(df))]
  add("data", "advisory", if (length(bad_names) == 0) "PASS" else "FAIL",
      lab("Column names are snake_case"),
      if (length(bad_names)) paste("not snake_case:", paste(bad_names, collapse = ", ")) else "")

  # Hard ranges: counts and percentages
  cnt_cols <- names(df)[grepl("count|_n$|^n_|users", names(df), ignore.case = TRUE) &
                          vapply(df, is.numeric, logical(1))]
  neg <- vapply(df[cnt_cols], function(x) sum(x < 0, na.rm = TRUE), integer(1))
  pct_cols <- names(df)[grepl("percent|pct|share", names(df), ignore.case = TRUE) &
                          vapply(df, is.numeric, logical(1))]
  oob_pct <- vapply(df[pct_cols], function(x) sum(x < 0 | x > 100, na.rm = TRUE), integer(1))
  if (length(cnt_cols) || length(pct_cols))
    add("data", "advisory", if (sum(neg) + sum(oob_pct) == 0) "PASS" else "FAIL",
        lab("Hard ranges: counts >= 0, percentages in [0, 100]"),
        sprintf("negative counts: %s; out-of-range percentages: %s",
                if (sum(neg)) paste(sprintf("%s (%d)", names(neg)[neg > 0], neg[neg > 0]), collapse = ", ") else "none",
                if (sum(oob_pct)) paste(sprintf("%s (%d)", names(oob_pct)[oob_pct > 0], oob_pct[oob_pct > 0]), collapse = ", ") else "none"))

  # Coordinates
  lat_col <- names(df)[grepl("^lat(itude)?$", names(df), ignore.case = TRUE)]
  lon_col <- names(df)[grepl("^lon(g|gitude)?$", names(df), ignore.case = TRUE)]
  if (length(lat_col) == 1 && length(lon_col) == 1) {
    la <- df[[lat_col]]; lo <- df[[lon_col]]
    oob <- sum(abs(la) > 90, na.rm = TRUE) + sum(abs(lo) > 180, na.rm = TRUE)
    zz <- sum(la == 0 & lo == 0, na.rm = TRUE)
    add("data", "advisory", if (oob + zz == 0) "PASS" else "FAIL",
        lab("Coordinates in bounds, no (0, 0) points"),
        sprintf("out-of-bounds: %d, (0, 0) points: %d", oob, zz))
  }

  # Cross-field pairs (explicit configuration at the top of this script)
  ran_pair <- FALSE
  for (p in CROSS_FIELD_PAIRS) {
    if (all(c(p[["part"]], p[["whole"]]) %in% names(df))) {
      ran_pair <- TRUE
      viol <- sum(df[[p[["part"]]]] > df[[p[["whole"]]]] & df[[p[["whole"]]]] >= 0, na.rm = TRUE)
      add("data", "advisory", if (viol == 0) "PASS" else "FAIL",
          lab(sprintf("Cross-field: %s <= %s", p[["part"]], p[["whole"]])),
          sprintf("%d violating row(s)", viol))
    }
  }
  if (!ran_pair)
    add("data", "advisory", "NOT RUN",
        lab("Cross-field consistency"),
        "no configured field pairs apply; add pairs to CROSS_FIELD_PAIRS for this package")
}

# Processing script content checks
proc <- read_lines_if("data-raw", "data_processing.R")
if (length(proc)) {
  code_comment_re <- "^\\s*#.*(<-|\\|>|%>%|stopifnot\\(|write_csv\\(|read_csv\\(|mutate\\(|rename\\(|filter\\()"
  dead <- grep(code_comment_re, proc)
  add("data", "advisory", if (length(dead) == 0) "PASS" else "FAIL",
      "No commented-out code in data_processing.R",
      if (length(dead)) sprintf("%d line(s): %s", length(dead), paste(dead, collapse = ", ")) else "")

  uses_read_csv <- any(grepl("read_csv\\(", proc[!grepl("^\\s*#", proc)]))
  has_col_types <- any(grepl("\\bcol_types\\s*=", proc[!grepl("^\\s*#", proc)]))
  uses_base_write <- any(grepl("write\\.csv\\(", proc[!grepl("^\\s*#", proc)]))
  conv_fail <- (uses_read_csv && !has_col_types) || uses_base_write
  add("data", "advisory", if (!conv_fail) "PASS" else "FAIL",
      "Script conventions: read_csv with col_types; readr/writexl exports",
      paste(c(if (uses_read_csv && !has_col_types) "read_csv() without col_types",
              if (uses_base_write) "base write.csv() used for export"), collapse = "; "))
}

# ---------------------------------------------------------------------------
# Area 3: docs
# ---------------------------------------------------------------------------

add("docs", "required",
    if (has("README.Rmd") && has("README.md")) "PASS" else "FAIL",
    "README.Rmd and rendered README.md present", "")

rd_files <- if (dir.exists(path("man"))) list.files(path("man"), "\\.Rd$") else character()
has_source <- any(vapply(rd_files, function(f) any(grepl("\\\\source\\{", readLines(path("man", f), warn = FALSE))), logical(1)))
add("docs", "advisory", if (has_source) "PASS" else "FAIL",
    "Roxygen @source present for the datasets", "")

readme <- read_lines_if("README.md")
add("docs", "advisory",
    if (any(grepl("^## Download", readme))) "PASS" else "FAIL",
    "README Download section with direct export links", "")

vig <- if (dir.exists(path("vignettes"))) list.files(path("vignettes"), "\\.(Rmd|qmd)$") else character()
add("docs", "advisory", if (length(vig) == 0) "PASS" else "FAIL",
    "No vignettes directly in vignettes/ (they belong in vignettes/articles/)",
    paste(vig, collapse = ", "))

pd <- read_lines_if("_pkgdown.yml")
if (length(pd)) {
  if (analytics == "plausible") {
    add("docs", "advisory",
        if (any(grepl("plausible\\.io", pd))) "PASS" else "FAIL",
        "_pkgdown.yml carries the Plausible analytics header", "")
  } else {
    add("docs", "advisory", "NOT RUN",
        "_pkgdown.yml analytics header",
        "org profile defines no analytics header (--analytics=none)")
  }
  url_line <- grep("^url:", pd, value = TRUE)
  add("docs", "advisory",
      if (length(url_line) && grepl("github\\.io", url_line[1])) "PASS" else "FAIL",
      "_pkgdown.yml url is the Pages URL, not the repo URL",
      if (length(url_line)) url_line[1] else "no url: line")
} else {
  add("docs", "advisory", "FAIL", "_pkgdown.yml present", "file missing")
}

# ---------------------------------------------------------------------------
# Area 4: tests
# ---------------------------------------------------------------------------

add("tests", "required",
    if (has(".github", "workflows", "R-CMD-check.yaml")) "PASS" else "FAIL",
    "GitHub Actions R-CMD-check workflow present", "")
add("tests", "advisory",
    if (any(grepl("R-CMD-check", read_lines_if("README.Rmd")))) "PASS" else "FAIL",
    "R-CMD-check badge in README.Rmd", "")

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

cat("# pkgreview mechanical check report\n\n")
cat(sprintf("Package: `%s`  \n", normalizePath(pkg)))
cat(sprintf("Standard: mechanical subset of the pkgreview checklists  \n"))
n_fail_req <- sum(results$status == "FAIL" & results$tier == "required")
cat(sprintf("Result: %d PASS, %d FAIL (%d required-tier), %d FLAG, %d NOT RUN\n\n",
            sum(results$status == "PASS"), sum(results$status == "FAIL"),
            n_fail_req, sum(results$status == "FLAG"), sum(results$status == "NOT RUN")))

for (a in c("metadata", "data", "docs", "tests")) {
  cat(sprintf("## %s\n\n", a))
  sub <- results[results$area == a, ]
  for (i in seq_len(nrow(sub))) {
    r <- sub[i, ]
    cat(sprintf("- [%s] (%s) %s%s\n", r$status, r$tier, r$check,
                if (nzchar(r$detail)) paste0(": ", r$detail) else ""))
  }
  cat("\n")
}

cat("Not machine-checked (reviewer judgment, run in the session per the\n")
cat("evidence rule): description and provenance prose quality, tidy-data\n")
cat("structure, plausibility of values, devtools::check(), README rebuild,\n")
cat("website build, ORCID and maintainer identification, dictionary\n")
cat("description accuracy (a present description can still be wrong), PII\n")
cat("certification (the FLAG above is a signal, never a verdict).\n")

quit(status = if (n_fail_req > 0) 1L else 0L)
