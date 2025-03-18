#' Get the turning angle between points
#'
#' Gets the relative heading between two track segments (three localizations)
#' using the law of cosines.
#' The turning angle is returned in degrees.
#' Adds the column `angle` to a data.table with tracking data.
#' Note that with smoothed data NaN values may occur (when subsequent
#' localizations are at the same place).
#'
#' @author Pratik R. Gupte & Allert Bijleveld & Johannes Krietsch
#' @param data A dataframe or similar which must have the columns
#' specified by \code{x}, \code{y}, and \code{time}.
#' @param tag The tag ID.
#' @param x The x coordinate.
#' @param y The y coordinate.
#' @param time The timestamp in seconds since the UNIX epoch.
#' @return A a data.table with added turning angles in degrees.
#' Negative degrees indicate 'left' turns. There are two fewer
#' angles than the number of rows in the dataframe.
#'
#' @examples
#' \dontrun{
#' data <- atl_turning_angle(
#'   data,
#'   tag = "tag", x = "x", y = "y", time = "time"
#' )
#' }
#' @export
atl_turning_angle <- function(data,
                              tag = "tag",
                              x = "x",
                              y = "y",
                              time = "time") {
  # global variables
  x1 <- x2 <- x3 <- y1 <- y2 <- y3 <- NULL
  dist_x1_x2 <- dist_x2_x3 <- dist_x3_x1 <- angle <- NULL

  # check for column names
  atl_check_data(
    data, names_expected = c(x, y, time)
  )

  # dynamic column names
  x_col <- as.character(substitute(x))
  y_col <- as.character(substitute(y))

  # set order in time
  if (!data.table::is.data.table(data)) {
    data.table::setDT(data)
  }
  data.table::setorderv(data, c(tag, time))

  # handle good data case
  data[, x1 := get(x_col), by = tag]
  data[, x2 := shift(get(x_col), n = 1, type = "lead"), by = tag]
  data[, x3 := shift(get(x_col), n = 2, type = "lead"), by = tag]

  data[, y1 := get(y_col), by = tag]
  data[, y2 := shift(get(y_col), n = 1, type = "lead"), by = tag]
  data[, y3 := shift(get(y_col), n = 2, type = "lead"), by = tag]

  # get three sides of a triangle of (x1,y1), (x2,y2), (x3,y3)
  data[, dist_x1_x2 := sqrt(((x2 - x1)^2) + ((y2 - y1)^2)), by = tag]
  data[, dist_x2_x3 := sqrt(((x3 - x2)^2) + ((y3 - y2)^2)), by = tag]
  data[, dist_x3_x1 := sqrt(((x3 - x1)^2) + ((y3 - y1)^2)), by = tag]

  # use the law of cosines
  data[, angle :=
         acos(((dist_x1_x2^2) + (dist_x2_x3^2) - (dist_x3_x1^2)) /
                (2 * dist_x1_x2 * dist_x2_x3)), by = tag]

  # convert to degrees
  data[, angle := angle * 180 / pi]

  # subtract from 180 to get the external angle
  data[, angle := 180 - (angle)]

  # shift column so first angle is with second position
  data[, angle := shift(angle, n = 1, type = "lag"), by = tag]

  # remove unnecessary columns
  data[, c(
    "x1", "x2", "x3", "y1", "y2", "y3", "dist_x1_x2", "dist_x2_x3", "dist_x3_x1"
  ) := NULL]

  # return data
  return(data)
}
