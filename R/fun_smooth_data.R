#' Apply a median smooth to coordinates.
#'
#' Applies a median smooth defined by a rolling window to the X and Y
#' coordinates of the data.
#'
#' @author Pratik Gupte & Allert Bijleveld
#' @param data A dataframe object returned by \code{atl_get_data}, which should contain the original columns (particularly X,Y and TIME).
#' @param moving_window The size of the moving window for the median smooth. Must be an odd number.
#' @param X The X coordinate.
#' @param Y The Y coordinate.
#' @param time The timestamp, ideally as an integer.
#' @return A datatable class object (extends data.frame), including X,Y as smoothed coordinates and the X_raw and Y_raw, which are the raw coordinates. 
#'
#' @examples
#' \dontrun{
#' atl_median_smooth(
#'   data = track_data,
#'   time = "TIME",
#'   moving_window = 5
#' )
#' }
#'
#' @export
#'
atl_median_smooth <- function(data,
                              X = "X",
                              Y = "Y",
                              time = "TIME",
                              moving_window = 3) {

  # check parameter types and assumptions
  assertthat::assert_that("data.frame" %in% class(data),
    msg = "cleanData: not a dataframe object!"
  )

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

## add original coordinates 	
	data$X_raw <- data$X
	data$Y_raw <- data$Y
	
  # mutate in place
  data[, c(X, Y) := lapply(
    .SD,
    function(z) {
      rev(stats::runmed(
        rev(stats::runmed(z, moving_window)),
        moving_window
      ))
    }
  ),
  .SDcols = c(X, Y)
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

# ends here
