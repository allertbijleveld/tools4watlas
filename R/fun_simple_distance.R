#' Calculate distances between successive localizations.
#'
#' Gets the euclidean distance between consecutive localization in a coordinate
#' reference system in metres, i.e., UTM systems.
#'
#' @author Pratik R. Gupte & Allert Bijleveld
#' @param X A column name in a data.frame object that contains the numeric X coordinate.
#' @param Y A column name in a data.frame object that contains the numeric Y coordinate.
#' @param data A dataframe object of or extending the class data.frame,
#' which must contain two coordinate columns for the X and Y coordinates.
#' @param lag The lag (in number of localizations) over which to calculate distance
#' @return Returns a vector of distances between consecutive points.
#' @export
#'
atl_simple_dist <- function(data, X = "X", Y = "Y", lag=1) {
  # check for basic assumptions
  atl_check_data(data, names_expected = c(X, Y))
  if (nrow(data) > lag) {
		x1 <- data[[X]][seq_len(nrow(data) - lag)]
		x2 <- data[[X]][(lag+1):nrow(data)]
		y1 <- data[[Y]][seq_len(nrow(data) - lag)]
		y2 <- data[[Y]][(lag+1):nrow(data)]
		dist <- c(rep(NA, lag), sqrt((x1 - x2)^2 + (y1 - y2)^2))
  } else {
		dist <- rep(NA_real_, lag)
  }
	return(dist)
}
