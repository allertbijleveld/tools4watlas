#' Calculate instantaenous speed.
#'
#' Returns speed in metres per time interval. The time interval is dependent
#' on the units of the column specified in \code{TIME}.
#' Users should apply this function to _one individual at a time_, ideally by
#' splittng a dataframe with multiple individuals into a list of dataframes.
#'
#' @author Pratik R. Gupte & Allert Bijleveld
#' @param data A dataframe or similar ordered by time, which must have the columns
#' specified by \code{X}, \code{Y}, and \code{TIME}.
#' @param Y The X coordinate.
#' @param Y The Y coordinate.
#' @param time The timestamp in seconds since the UNIX epoch.
#' @param type The type of speed (incoming or outgoing) to return.
#' Incoming speeds are specified by \code{type = "in"}, and outgoing speeds
#' by \code{type = "out"}.
#'
#' @return A vector of numerics representing speed.
#' The first position is assigned a speed of NA.
#'
#' @examples
#' \dontrun{
#' data$speed_in <- atl_get_speed(data,
#'   X = "X", Y = "Y",
#'   time = "TIME", type = c("in")
#' )
#' }
#' @export
atl_get_speed <- function(data,
                          X = "X",
                          Y = "Y",
                          time = "TIME",
                          type = c("in")) {
  atl_check_data(data, names_expected = c(X, Y, time))

	## check whether the data is orderd on time 
	assertthat::assert_that(min(diff(data[,time])) >= 0, msg = "data is not ordered by time")

	# get distance
	distance <- atl_simple_dist(data, X, Y)

	# get time
	time <- c(NA, diff(data[[time]]))

	  if (type == "in") {
		speed <- distance / time
	  } else if (type == "out") {
		speed <- data.table::shift(distance, type = "lead") /
		  data.table::shift(time, type = "lead")
	  }
	return(speed)
}
