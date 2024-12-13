#' Calculate distances between successive localizations
#'
#' Gets the euclidean distance between consecutive localization in a coordinate
#' reference system in metres, i.e., UTM systems.
#'
#' @author Pratik R. Gupte & Allert Bijleveld
#' @param x A column name in a data.frame object that contains the numeric X
#' coordinate.
#' @param y A column name in a data.frame object that contains the numeric Y
#' coordinate.
#' @param data A dataframe object of or extending the class data.frame,
#' which must contain two coordinate columns for the X and Y coordinates.
#' @param lag The lag (in number of localizations) over which to calculate
#' distance
#' @return Returns a vector of distances between consecutive points.
#' @export
#'
atl_simple_dist <- function(data, x = "x", y = "y", lag = 1) {
  # check for basic assumptions
  atl_check_data(data, names_expected = c(x, y))
  if (nrow(data) > lag) {
    x1 <- data[[x]][seq_len(nrow(data) - lag)]
    x2 <- data[[x]][(lag + 1):nrow(data)]
    y1 <- data[[y]][seq_len(nrow(data) - lag)]
    y2 <- data[[y]][(lag + 1):nrow(data)]
    dist <- c(rep(NA, lag), sqrt((x1 - x2)^2 + (y1 - y2)^2))
  } else {
    dist <- rep(NA_real_, lag)
  }
  return(dist)
}
