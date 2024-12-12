#' Apply a median smooth to coordinates.
#'
#' Applies a median smooth defined by a rolling window to the X and Y
#' coordinates of the data.
#'
#' @author Pratik Gupte & Allert Bijleveld
#' @param data A dataframe object returned by \code{atl_get_data}, which should
#' contain the original columns (particularly X,Y and TIME).
#' @param moving_window The size of the moving window for the median smooth.
#' Must be an odd number.
#' @param x The X coordinate.
#' @param y The Y coordinate.
#' @param time The timestamp, ideally as an integer.
#' @return A datatable class object (extends data.frame), including X,Y as
#' smoothed coordinates and the x_raw and y_raw, which are the raw coordinates.
#'
#' @examples
#' \dontrun{
#' atl_median_smooth(
#'   data = track_data,
#'   x = "x", y = "y",
#'   time = "time",
#'   moving_window = 5
#' )
#' }
#'
#' @export
#'
atl_median_smooth <- function(data,
                              x = "x",
                              y = "y",
                              time = "time",
                              moving_window = 5) {
  # global variables
  x_raw <- y_raw <- NULL

  # check parameter types and assumptions
  assertthat::assert_that("data.frame" %in% class(data),
    msg = "cleanData: not a dataframe object!"
  )

  # check the data
  names_req <- c(x, y, time)
  atl_check_data(data, names_req)

  # check args positive
  assertthat::assert_that(min(c(moving_window)) > 1,
    msg = "cleanData: moving window not > 1"
  )
  assertthat::assert_that(moving_window %% 2 != 0,
    msg = "moving window must be an odd number"
  )

  # convert both to DT if not
  if (data.table::is.data.table(data) != TRUE) {
    data.table::setDT(data)
  }

  # set in ascending order of time
  data.table::setorderv(data, time)

  # add original coordinates
  data[, x_raw := x]
  data[, y_raw := y]

  # mutate in place
  data[, c(x, y) := lapply(
    .SD,
    function(z) {
      rev(stats::runmed(
        rev(stats::runmed(z, moving_window)),
        moving_window
      ))
    }
  ),
  .SDcols = c(x, y)
  ]

  assertthat::assert_that("data.frame" %in% class(data),
    msg = "median_smooth: cleanded data is not a dataframe object!"
  )

  if (nrow(data) > 0) {
    return(as.data.frame(data))
  } else {
    warning("median_smooth: no data remaining")
    return(NULL)
  }
}
