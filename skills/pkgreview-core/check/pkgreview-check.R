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
#
# Scope (openwashdata/pkgreview#66, decided 2026-09-05): the metadata,
# docs, and tests sections below are FROZEN. They receive no new lines
# and are slated for replacement by one call to
# washr::check_publication_readiness() once openwashdata/washr#82 ships;
# the scorecard mapping for those lines moves with them. pkgreview keeps
# what washr will never own: the data-quality checks (sentinels,
# encoding, dates, categories, duplicates, ranges, coordinates,
# cross-field pairs, dictionary schema), the PII signal scan, and the
# git-history scan.

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
}

# Keywords: DESCRIPTION X-schema.org-keywords is the canonical home
# (washr >= 1.1.0 carries them into CITATION.cff); CITATION.cff agreement
# is reported as a drift detail, never as a second finding.
kw_field <- dfield("X-schema.org-keywords")
kw <- if (!is.na(kw_field)) trimws(strsplit(kw_field, ",")[[1]]) else character()
kw <- kw[nzchar(kw)]
cff_kw <- character()
kw_start <- grep("^keywords:", cff)
if (length(kw_start)) {
  i <- kw_start[1] + 1L
  while (i <= length(cff) && grepl("^\\s*-\\s", cff[i])) {
    cff_kw <- c(cff_kw, trimws(sub("^\\s*-\\s*", "", cff[i])))
    i <- i + 1L
  }
}
cff_kw <- gsub("^['\"]|['\"]$", "", cff_kw)
kw_agree <- if (length(cff) == 0) {
  "CITATION.cff missing"
} else if (length(cff_kw) == 0) {
  "CITATION.cff carries no keywords yet (washr::update_citation() writes them)"
} else if (setequal(tolower(kw), tolower(cff_kw))) {
  "CITATION.cff agrees"
} else {
  sprintf("CITATION.cff differs (drift, rerun washr::update_citation()): %s", paste(cff_kw, collapse = ", "))
}
add("metadata", "advisory",
    if (length(kw)) "PASS" else "FAIL",
    "DESCRIPTION carries X-schema.org-keywords",
    if (length(kw)) sprintf("%d keyword(s): %s; %s", length(kw), paste(kw, collapse = ", "), kw_agree)
    else paste("field missing or empty;", kw_agree))

# Coverage fields (#64): read by washr::update_metadata() and the org catalog
sp_cov <- dfield("X-schema.org-spatialCoverage")
tm_cov <- dfield("X-schema.org-temporalCoverage")
cov_missing <- c(if (is.na(sp_cov) || !nzchar(trimws(sp_cov))) "X-schema.org-spatialCoverage",
                 if (is.na(tm_cov) || !nzchar(trimws(tm_cov))) "X-schema.org-temporalCoverage")
add("metadata", "advisory",
    if (length(cov_missing) == 0) "PASS" else "FAIL",
    "DESCRIPTION carries X-schema.org spatial and temporal coverage",
    if (length(cov_missing)) paste("missing:", paste(cov_missing, collapse = ", "))
    else sprintf("spatial: %s; temporal: %s", sp_cov, tm_cov))

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

  # Dictionary schema (advisory): the five washr columns in order, UTF-8
  # without a BOM, one class name per variable_type value. These are the
  # pathologies the org catalog parser found across pre-standard packages.
  DICT_COLS <- c("directory", "file_name", "variable_name", "variable_type", "description")
  head_bytes <- readBin(dict_path, "raw", n = 3L)
  has_bom <- length(head_bytes) == 3L && identical(as.integer(head_bytes), c(0xEFL, 0xBBL, 0xBFL))
  dict_lines <- readLines(dict_path, warn = FALSE)
  bad_utf8 <- !all(validUTF8(dict_lines))
  header <- if (length(dict_lines)) sub("^\ufeff", "", dict_lines[1]) else ""
  cols <- tryCatch(scan(text = header, what = "", sep = ",", quiet = TRUE, strip.white = FALSE),
                   error = function(e) character())
  types <- if ("variable_type" %in% names(dict)) as.character(dict$variable_type) else character()
  type_bad <- !is.na(types) & nzchar(types) & !grepl("^[A-Za-z][A-Za-z0-9_.]*$", types)
  schema_problems <- c(
    if (has_bom) "UTF-8 byte order mark at the start of the file",
    if (bad_utf8) "non-UTF-8 bytes in the file",
    if (!identical(cols, DICT_COLS))
      sprintf("columns are [%s], expected [%s]", paste(cols, collapse = ", "), paste(DICT_COLS, collapse = ", ")),
    if (any(type_bad))
      sprintf("variable_type is not a single class name for: %s",
              paste(unique(dict$variable_name[type_bad]), collapse = ", ")))
  add("data", "advisory",
      if (length(schema_problems) == 0) "PASS" else "FAIL",
      "Dictionary schema: five washr columns, UTF-8 without BOM, single-class variable_type",
      paste(schema_problems, collapse = "; "))
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

# Git-history PII signal scan (issue #52): identifying data removed from
# the working tree stays recoverable from any clone. This is the text-file
# part of the intake screen's history check; the .rda column scan and the
# commit-message read stay with the reviewer (review-package Step 2). FLAG
# only, never PASS (premortem P6). NOT RUN when pkg is not a git repo.
git_ok <- tryCatch(
  system2("git", c("-C", shQuote(pkg), "rev-parse", "--is-inside-work-tree"),
          stdout = TRUE, stderr = FALSE),
  warning = function(w) character(), error = function(e) character())
git_prefix <- tryCatch(
  system2("git", c("-C", shQuote(pkg), "rev-parse", "--show-prefix"),
          stdout = TRUE, stderr = FALSE),
  warning = function(w) character(), error = function(e) character())
is_repo <- length(git_ok) && identical(trimws(git_ok[1]), "true")
# A package nested inside a larger repo (non-empty prefix) has no history
# of its own: the visible commits belong to the enclosing repo, not to the
# package, so a history scan there would report the wrong repo's data. A
# package under review is its own repo root (empty prefix). This is also
# what keeps the fixture scan deterministic: fixtures/pkgreviewtest is a
# subdir of the tooling repo, so its D18 defect is exercised by the
# throwaway repo from make_history_fixture.sh, not from here.
in_subdir <- is_repo && length(git_prefix) && nzchar(trimws(git_prefix[1]))
if (!is_repo) {
  add("data", "required", "NOT RUN",
      "Git-history PII signal scan (text data files)",
      "package directory is not a git repository; run the history scan manually if the package is versioned elsewhere")
} else if (in_subdir) {
  add("data", "required", "NOT RUN",
      "Git-history PII signal scan (text data files)",
      "package is a subdirectory of a larger git repository; the visible history is the enclosing repo's, not the package's. Run the scan against the package's own repository")
} else {
  # pkg is the repo root here (empty prefix; the subdir case returned NOT
  # RUN above). `git log --name-only` prints repo-root-relative paths and
  # `git show rev:PATH` takes a root-relative path, so both are anchored at
  # the repo root and the data directories can be named directly.
  # Every path that ever existed under the data directories, including
  # files deleted before the current commit.
  hist_paths <- tryCatch(
    system2("git", c("-C", shQuote(pkg), "log", "--all", "--pretty=format:",
                     "--name-only", "--diff-filter=AMD", "--",
                     "data-raw/", "inst/extdata/"),
            stdout = TRUE, stderr = FALSE),
    warning = function(w) character(), error = function(e) character())
  hist_paths <- unique(hist_paths[nzchar(hist_paths)])
  text_paths <- grep("\\.(csv|tsv|txt|json|geojson)$", hist_paths,
                     ignore.case = TRUE, value = TRUE)
  # Identifier column names or coordinate/value patterns in any historical
  # revision of each text data file. Paths are root-relative, so the per
  # file revision list and each blob read use them directly.
  hist_hits <- character()
  for (p in text_paths) {
    header_hit <- tryCatch({
      # `p` is repo-root-relative and pkg is the repo root, so the
      # pathspec and the blob reference both resolve directly.
      revs <- system2("git", c("-C", shQuote(pkg), "log", "--all",
                               "--pretty=format:%H", "--", p),
                      stdout = TRUE, stderr = FALSE)
      hit <- FALSE
      for (rev in revs[nzchar(revs)]) {
        blob <- system2("git", c("-C", shQuote(pkg), "show",
                                 paste0(rev, ":", p)),
                        stdout = TRUE, stderr = FALSE)
        if (length(blob) &&
            (grepl(pii_name_re, blob[1], ignore.case = TRUE) ||
             any(grepl("(^|,)(lat|latitude|lon|long|longitude|gps)($|,)",
                       blob[1], ignore.case = TRUE))))
          { hit <- TRUE; break }
      }
      hit
    }, warning = function(w) FALSE, error = function(e) FALSE)
    if (isTRUE(header_hit)) hist_hits <- c(hist_hits, p)
  }
  add("data", "required", "FLAG",
      "Git-history PII signal scan (text data files)",
      if (length(hist_hits))
        paste("identifier-like columns in historical revisions of:",
              paste(unique(hist_hits), collapse = ", "),
              "- inspect these revisions and treat as disclosed if confirmed")
      else paste("no identifier-like column names or value patterns found in the",
                 length(text_paths),
                 "text data file path(s) across history; the .rda history and commit messages still need the reviewer's judgment"))
}

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
dl_lines <- grep("inst/extdata/[^)\\s\"']+\\.(csv|xlsx)", readme, ignore.case = TRUE, perl = TRUE)
add("docs", "advisory",
    if (length(dl_lines)) "PASS" else "FAIL",
    "README links the CSV/XLSX exports in inst/extdata/ for non-R users",
    if (length(dl_lines)) sprintf("%d line(s) link into inst/extdata/", length(dl_lines))
    else "no link to a .csv or .xlsx file under inst/extdata/ (the washr README template's download table provides them)")

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

# Site deployment: with the pkgdown workflow in place, docs/ is ignored
# and never committed. The workflow's own presence is the required
# Website item, checked by the reviewer, so this line is NOT RUN without
# it rather than a second finding for the same gap.
pkgdown_wf <- has(".github", "workflows", "pkgdown.yaml") || has(".github", "workflows", "pkgdown.yml")
if (!pkgdown_wf) {
  add("docs", "advisory", "NOT RUN",
      "docs/ untracked while the pkgdown workflow deploys the site",
      "no .github/workflows/pkgdown.yaml; the required Website item covers the missing workflow")
} else if (!is_repo) {
  add("docs", "advisory", "NOT RUN",
      "docs/ untracked while the pkgdown workflow deploys the site",
      "package directory is not a git repository")
} else {
  tracked_docs <- tryCatch(
    system2("git", c("-C", shQuote(pkg), "ls-files", "docs"), stdout = TRUE, stderr = FALSE),
    warning = function(w) character(), error = function(e) character())
  tracked_docs <- tracked_docs[nzchar(tracked_docs)]
  add("docs", "advisory",
      if (length(tracked_docs) == 0) "PASS" else "FAIL",
      "docs/ untracked while the pkgdown workflow deploys the site",
      if (length(tracked_docs)) sprintf("%d tracked file(s) under docs/; untrack them (git rm -r --cached docs) and ignore the directory", length(tracked_docs))
      else "")
}

# ---------------------------------------------------------------------------
# Area 4: tests
# ---------------------------------------------------------------------------

add("tests", "required",
    if (has(".github", "workflows", "R-CMD-check.yaml")) "PASS" else "FAIL",
    "GitHub Actions R-CMD-check workflow present", "")

# Trigger branches: every `branches:` list under `on:` must include dev
# (inline `[main, master, dev]` or a nested `- dev` list). NOT RUN when the
# workflow file is missing: that gap is the presence line's finding.
branch_blocks <- function(lines) {
  out <- character(); i <- 1L
  while (i <= length(lines)) {
    m <- regmatches(lines[i], regexec("^(\\s*)branches:\\s*(.*)$", lines[i]))[[1]]
    if (length(m) == 3L) {
      indent <- nchar(m[2]); val <- gsub("^\\[|\\]$", "", trimws(m[3]))
      if (nzchar(val)) { out <- c(out, val); i <- i + 1L; next }
      j <- i + 1L; items <- character()
      while (j <= length(lines) && grepl("^\\s*-\\s", lines[j]) &&
             nchar(sub("^(\\s*).*$", "\\1", lines[j])) > indent) {
        items <- c(items, trimws(sub("^\\s*-\\s*", "", lines[j]))); j <- j + 1L
      }
      out <- c(out, paste(items, collapse = ", ")); i <- j; next
    }
    i <- i + 1L
  }
  out
}
wf_lines <- read_lines_if(".github", "workflows", "R-CMD-check.yaml")
if (length(wf_lines) == 0) {
  add("tests", "required", "NOT RUN",
      "R-CMD-check workflow triggers include dev (push and pull_request)",
      "workflow file missing; see the presence line above")
} else {
  blocks <- branch_blocks(wf_lines)
  dev_ok <- length(blocks) >= 1L && all(grepl("\\bdev\\b", blocks, perl = TRUE))
  add("tests", "required", if (dev_ok) "PASS" else "FAIL",
      "R-CMD-check workflow triggers include dev (push and pull_request)",
      if (length(blocks)) sprintf("branches: %s", paste(sprintf("[%s]", blocks), collapse = " "))
      else "no branches: list found under on:")
}
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
cat("website build, the pkgdown workflow's Pages setting, ORCID and\n")
cat("maintainer identification, dictionary\n")
cat("description accuracy (a present description can still be wrong), PII\n")
cat("certification (the FLAG above is a signal, never a verdict), and the\n")
cat("history parts the script does not cover: historical .rda column names\n")
cat("(compressed, not text-searchable) and commit-message wording that\n")
cat("names identifying data being added or removed.\n")

quit(status = if (n_fail_req > 0) 1L else 0L)
