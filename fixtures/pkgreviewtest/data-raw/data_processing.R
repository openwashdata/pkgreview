# Description ------------------------------------------------------------
# R script to process water point observation data into the pkgreviewtest
# package dataset.

# Load libraries ----------------------------------------------------------

library(readr)
library(dplyr)

# Read data ---------------------------------------------------------------

pkgreviewtest <- read_csv(
  "data-raw/waterpoints_raw.csv",
  locale = locale(encoding = "latin1"),
  show_col_types = FALSE
) |>
  as.data.frame()

# Tidy data ---------------------------------------------------------------

# Keep observations from all four regions
pkgreviewtest <- pkgreviewtest |>
  filter(!is.na(id))

# An earlier version of this script recoded the columns below. Kept here
# for reference in case we need to revisit the cleaning decisions.
# pkgreviewtest <- pkgreviewtest |>
#   rename(water_source = waterSource) |>
#   mutate(
#     status = tolower(status),
#     installation_date = as.Date(installation_date),
#     users_count = if_else(users_count == -99, NA_integer_, users_count),
#     region = iconv(region, from = "latin1", to = "UTF-8")
#   )
# stopifnot(!any(duplicated(pkgreviewtest$id)))
# write_csv(pkgreviewtest, "data-raw/waterpoints_clean.csv")

# Export data -------------------------------------------------------------

usethis::use_data(pkgreviewtest, overwrite = TRUE, version = 2)

fs::dir_create(here::here("inst", "extdata"))

write.csv(
  pkgreviewtest,
  here::here("inst", "extdata", "pkgreviewtest.csv"),
  row.names = FALSE,
  fileEncoding = "latin1"
)
writexl::write_xlsx(
  pkgreviewtest,
  here::here("inst", "extdata", "pkgreviewtest.xlsx")
)
