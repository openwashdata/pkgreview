#' pkgreviewtest: Water point observations for review workflow testing
#'
#' Water point observations from four Swiss regions, including water source
#' type, functional status, installation date, and number of users.
#'
#' @format A data frame with 30 rows and 6 variables
#' \describe{
#'   \item{id}{Water point identifier}
#'   \item{region}{Region where the water point is located}
#'   \item{waterSource}{Type of water source}
#'   \item{status}{Functional status of the water point}
#'   \item{installation_date}{Date the water point was installed}
#'   \item{users_count}{Number of people using the water point}
#' }
#'
#' @examples
#' data(pkgreviewtest)
#' head(pkgreviewtest)
"pkgreviewtest"
