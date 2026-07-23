#' pkgreviewtest: Water point observations for review workflow testing
#'
#' Water point observations from four Swiss regions, including water source
#' type, functional status, installation date, and number of users.
#'
#' @format A data frame with 30 rows and 10 variables
#' \describe{
#'   \item{id}{Water point identifier}
#'   \item{region}{Region where the water point is located}
#'   \item{waterSource}{Type of water source}
#'   \item{status}{Functional status of the water point}
#'   \item{installation_date}{Date the water point was installed}
#'   \item{users_count}{Number of people using the water point}
#'   \item{owner_phone}{Phone number of the water point owner}
#'   \item{women_users}{Number of women among the water point users}
#'   \item{latitude}{Latitude of the water point in decimal degrees}
#'   \item{longitude}{Longitude of the water point in decimal degrees}
#' }
#'
#' @source Synthetic data generated deterministically by
#'   `fixtures/make_pkgreviewtest.R` in openwashdata/pkgreview
#'   (<https://github.com/openwashdata/pkgreview>); no external data
#'   collector. Accessed 2026-07-23.
#'
#' @examples
#' data(pkgreviewtest)
#' head(pkgreviewtest)
"pkgreviewtest"
