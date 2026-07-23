# make_pkgreviewtest.R
#
# Deterministically regenerates the data files of the deliberately defective
# fixture package fixtures/pkgreviewtest/. Run this script after any change
# to the review checklists that requires adjusting the planted defects.
#
# Regenerates:
#   - fixtures/pkgreviewtest/data-raw/waterpoints_raw.csv
#   - fixtures/pkgreviewtest/data/pkgreviewtest.rda
#   - fixtures/pkgreviewtest/inst/extdata/pkgreviewtest.csv
#   - fixtures/pkgreviewtest/inst/extdata/pkgreviewtest.xlsx (if writexl or
#     openxlsx is installed; skipped gracefully otherwise)
#
# The planted data defects (see fixtures/SCORECARD.md for the full list):
#   D3  region column encoded in latin1, not UTF-8
#   D4  missing users_count coded as -99, not NA
#   D8  installation_date stored as character in mixed formats
#   D9  inconsistent capitalisation in status
#   D10 one duplicated id
#   D11 camelCase column name waterSource
#   D14 direct-identifier column owner_phone (PII for the intake screen)
#
# D13 (defective dictionary descriptions) lives in the static file
# data-raw/dictionary.csv and is not generated here.
#
# Fixture changes are strictly additive: the D1-D12 defect mechanisms must
# stay untouched. New columns are generated AFTER all random draws, with
# deterministic values that consume no RNG, so the RNG stream for D1-D12
# does not shift (premortem constraint, issue #31).
#
# Uses base R only, plus writexl or openxlsx for the optional xlsx export.

# Locate the fixtures/ directory from the script path so the script can be
# run from any working directory.
get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) == 1) {
    return(dirname(normalizePath(sub("^--file=", "", file_arg))))
  }
  # Fallback: assume the working directory is the repo root or fixtures/
  if (dir.exists("fixtures/pkgreviewtest")) {
    return(normalizePath("fixtures"))
  }
  if (dir.exists("pkgreviewtest")) {
    return(normalizePath("."))
  }
  stop("Cannot locate the fixtures/ directory. Run from the repo root.")
}

fixtures_dir <- get_script_dir()
pkg_dir <- file.path(fixtures_dir, "pkgreviewtest")

dir.create(file.path(pkg_dir, "data"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(pkg_dir, "data-raw"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(pkg_dir, "inst", "extdata"), recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------------------
# Generate the dataset (30 rows, deterministic)
# ---------------------------------------------------------------------------

set.seed(4242)

n <- 30

id <- sprintf("WP-%03d", seq_len(n))
id[17] <- id[5] # D10: duplicated id

regions_utf8 <- c("Zürich", "Genève", "Basel", "Bern")
region_utf8 <- sample(regions_utf8, n, replace = TRUE)
# D3: mark the strings as latin1 so the character encoding is not UTF-8
region <- iconv(region_utf8, from = "UTF-8", to = "latin1")

# D11: camelCase column name (waterSource instead of water_source)
waterSource <- sample(
  c("borehole", "protected spring", "hand-dug well", "rainwater"),
  n,
  replace = TRUE
)

# D9: inconsistent categorical values
status <- sample(
  c("functional", "Functional", "FUNCTIONAL", "non-functional", "Non-Functional"),
  n,
  replace = TRUE,
  prob = c(0.35, 0.15, 0.1, 0.25, 0.15)
)

# D8: dates as character strings in mixed formats
dates_iso <- as.Date("2018-01-01") + sample(0:1500, n, replace = TRUE)
installation_date <- format(dates_iso, "%Y-%m-%d")
mixed_idx <- c(3, 8, 14, 21, 27)
installation_date[mixed_idx] <- format(dates_iso[mixed_idx], "%d/%m/%Y")

# D4: missing values coded as -99
users_count <- sample(20:400, n, replace = TRUE)
users_count[c(6, 12, 19, 25)] <- -99L

# D14: direct-identifier column owner_phone. Generated after all random
# draws above, from row-index arithmetic only (no RNG consumed), so the
# D1-D12 columns stay byte-identical to the pre-D14 fixture.
i <- seq_len(n)
owner_phone <- sprintf(
  "+41 79 %03d %02d %02d",
  100 + ((i * 37) %% 900),
  (i * 11) %% 100,
  (i * 23) %% 100
)

pkgreviewtest <- data.frame(
  id = id,
  region = region,
  waterSource = waterSource,
  status = status,
  installation_date = installation_date,
  users_count = as.integer(users_count),
  owner_phone = owner_phone,
  stringsAsFactors = FALSE
)

# ---------------------------------------------------------------------------
# Write outputs
# ---------------------------------------------------------------------------

# Raw CSV in data-raw/, written in latin1 to mimic a legacy export
raw_path <- file.path(pkg_dir, "data-raw", "waterpoints_raw.csv")
write.csv(pkgreviewtest, raw_path, row.names = FALSE, fileEncoding = "latin1")
message("Wrote ", raw_path)

# .rda in data/ (region stays latin1-encoded: D3)
rda_path <- file.path(pkg_dir, "data", "pkgreviewtest.rda")
save(pkgreviewtest, file = rda_path, version = 2, compress = "bzip2")
message("Wrote ", rda_path)

# Exportable CSV in inst/extdata/, also latin1
csv_path <- file.path(pkg_dir, "inst", "extdata", "pkgreviewtest.csv")
write.csv(pkgreviewtest, csv_path, row.names = FALSE, fileEncoding = "latin1")
message("Wrote ", csv_path)

# Exportable XLSX in inst/extdata/, if a writer is available
xlsx_path <- file.path(pkg_dir, "inst", "extdata", "pkgreviewtest.xlsx")
if (requireNamespace("writexl", quietly = TRUE)) {
  writexl::write_xlsx(pkgreviewtest, xlsx_path)
  message("Wrote ", xlsx_path, " (writexl)")
} else if (requireNamespace("openxlsx", quietly = TRUE)) {
  openxlsx::write.xlsx(pkgreviewtest, xlsx_path)
  message("Wrote ", xlsx_path, " (openxlsx)")
} else {
  message(
    "Skipped ", xlsx_path,
    ": neither writexl nor openxlsx is installed."
  )
}

# ---------------------------------------------------------------------------
# Verification summary
# ---------------------------------------------------------------------------

message("\nVerification:")
message("  Rows: ", nrow(pkgreviewtest))
message(
  "  region encodings: ",
  paste(unique(Encoding(pkgreviewtest$region)), collapse = ", ")
)
message("  users_count == -99: ", sum(pkgreviewtest$users_count == -99))
message("  duplicated ids: ", sum(duplicated(pkgreviewtest$id)))
message(
  "  installation_date class: ",
  class(pkgreviewtest$installation_date)
)
message(
  "  status values: ",
  paste(sort(unique(pkgreviewtest$status)), collapse = ", ")
)
message(
  "  owner_phone (D14) present: ",
  "owner_phone" %in% names(pkgreviewtest),
  ", all match +41 pattern: ",
  all(grepl("^\\+41 79 \\d{3} \\d{2} \\d{2}$", pkgreviewtest$owner_phone))
)
