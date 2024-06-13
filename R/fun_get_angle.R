#' Get the turning angle between points.
#'
#' Gets the relative heading between two track segments (three localizations) using the law of cosines.
#' The turning angle is returned in degrees.
#' Users should apply this function to _one individual at a time_, ideally by
#' splittng a dataframe with multiple individuals into a list of dataframes.
#'
#' @author Pratik R. Gupte & Allert Bijleveld
#' @param data A dataframe or similar ordered by time, which must have the columns
#' specified by \code{X}, \code{Y}, and \code{TIME}.
#' @param X The X coordinate.
#' @param Y The Y coordinate.
#' @param time The timestamp in seconds since the UNIX epoch.
#' @return A vector of turning angles in degrees.
#' Negative degrees indicate 'left' turns. There are two fewer
#' angles than the number of rows in the dataframe.
#'
#' @examples
#' \dontrun{
#' data$angle <- atl_turning_angle(data,
#'   X = "X", Y = "Y", time = "TIME"
#' )
#' }
#' @export
atl_turning_angle <- function(data,
                              X = "X",
                              Y = "Y",
                              time = "TIME") {

  # check for column names
  atl_check_data(data,
    names_expected = c(X, Y, time)
  )

  ## check whether the data is orderd on time 
	assertthat::assert_that(min(diff(data[,time])) >= 0, msg = "data is not ordered by TIME")

  # handle good data case
  if (nrow(data) > 1) {
    x1 <- data[[X]][seq_len(nrow(data) - 2)]
    x2 <- data[[X]][2:(nrow(data) - 1)]
    x3 <- data[[X]][3:nrow(data)]

    y1 <- data[[Y]][seq_len(nrow(data) - 2)]
    y2 <- data[[Y]][2:(nrow(data) - 1)]
    y3 <- data[[Y]][3:nrow(data)]

    # get three sides of a triangle of (x1,y1), (x2,y2), (x3,y3)
    dist_x1_x2 <- sqrt(((x2 - x1)^2) + ((y2 - y1)^2))
    dist_x2_x3 <- sqrt(((x3 - x2)^2) + ((y3 - y2)^2))
    dist_x3_x1 <- sqrt(((x3 - x1)^2) + ((y3 - y1)^2))

    # use the law of cosines
    angle <- acos(((dist_x1_x2^2) +
      (dist_x2_x3^2) -
      (dist_x3_x1^2)) /
      (2 * dist_x1_x2 * dist_x2_x3))

    # convert to degrees
    angle <- angle * 180 / pi

    # subtract from 180 to get the external angle
    angle <- 180 - (angle)

    # add NA to maintain length
    angle <- c(NA_real_, angle, NA_real_)
  } else if (nrow(data) == 1) {
    angle <- NA_real_
  }
  return(angle)
}
