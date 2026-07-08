# Exploratory analysis of the pkgreviewtest dataset used during
# package development. Kept for reproducibility.

library(dplyr)

load("data/pkgreviewtest.rda")

# Observations per region
pkgreviewtest |>
  count(region)

# Observations per water source type
pkgreviewtest |>
  count(waterSource)

# Summary of user counts
summary(pkgreviewtest$users_count)
