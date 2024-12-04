#' Thin tracking data by resampling or aggregation.
#'
#' Uniformly reduce data volumes with either aggregation or resampling
#' (specified by the \code{method} argument) over an interval specified in
#' seconds using the \code{interval} argument.
#' Both options make two important assumptions:
#' (1) that timestamps are named `TIME', and
#' (2) all columns except the identity columns can be averaged in \code{R}.
#' While the `subsample' option returns a thinned dataset with all columns from
#' the input data, the `aggregate' option drops the column \code{covxy}, since
#' this cannot be propagated to the averaged position.
#' Both options handle the column `TIME' differently: while `subsample' returns
#' the actual timestamp (in UNIX TIME) of each sample, `aggregate' returns the
#' mean timestamp (also in UNIX TIME).
#' In both cases, an extra column, \code{time_agg}, is added which has a uniform
#'  difference between each element corresponding to the user-defined thinning
#' interval.
#' The `aggregate' option only recognises errors named \code{varx} and
#' \code{vary}.
#' If all of these columns are not present together the function assumes there
#' is no measure of error, and drops those columns.
#' If there is actually no measure of error, the function simply returns the
#' averaged position and covariates in each time interval.
#' Grouping variables' names (such as animal identity) may be passed as a
#' character vector to the \code{id_columns} argument.
#'
#' @author Pratik Gupte & Allert Bijleveld
#' @param data Tracking data to aggregate. Must have columns \code{X} and 
#' \code{Y}, and a numeric column named \code{TIME}.
#' @param interval The interval in seconds over which to aggregate.
#' @param id_columns Column names for grouping columns.
#' @param method Should the data be thinned by subsampling or aggregation.
#' If resampling (\code{method = "subsample"}), the first position of each group
#' is taken. If aggregation (\code{method = "aggregate"}), the group positions'
#' mean is taken.
#'
#' @return A dataframe aggregated taking the mean over the interval.
#'
#' @examples
#' \dontrun{
#' thinned_data <- atl_thin_data(data,
#'   interval = 60,
#'   id_columns = c("animal_id"),
#'   method = "aggregate"
#' )
#' }
#'
#' @export
#'
atl_thin_data <- function(data,
                          interval = 60,
						              id_columns = NULL,
                          method = c(
                            "subsample",
                            "aggregate"
                          )) {
  # global variables
  TIME <- varx <- vary <- covxy <- NULL
  X <- Y <- time <- time_agg <- NULL

  # check input type
  assertthat::assert_that("data.frame" %in% class(data),
    msg = "thin_data: input not a dataframe object!"
  )

  # check that type is a character and within scope
  assertthat::assert_that(method %in% c(
    "subsample",
    "aggregate"
  ),
  msg = "thin_data: type must be 'subsample' or \\
                          'aggregate'"
  )

  # if input is not a data.table set it so
  if (!data.table::is.data.table(data)) {
    setDT(data)
  }

  # include asserts checking for required columns
  atl_check_data(data,
    names_expected = c("x", "y", "time", id_columns)
  )

  # check aggregation interval is greater than min time difference
  assertthat::assert_that(interval > min(diff(data$time)),
    msg = "thin_data: thinning interval less than tracking interval!"
  )

  # round interval and reassign, this modifies by reference!
  data[, time_agg := floor(as.numeric(time) / interval) * interval]

  # handle method option
  if (method == "aggregate") {
    if (all(c("varx", "vary") %in% colnames(data))) {
      # aggregate over tracking interval
      # the variance of an average is the sum of variances / sample size square
      data <- data[, c(lapply(.SD, mean, na.rm = TRUE),
        varx_agg = sum(varx, na.rm = TRUE) / (length(varx)^2),
        vary_agg = sum(vary, na.rm = TRUE) / (length(vary)^2)

        # variance of an average is sum of variances sum(SD ^ 2)
        # divided by sample size squared length(SD) ^ 2
        # the standard deviation is the square root of the variance
      ),
      by = c("time_agg", id_columns)
      ]
    } else {
      # aggregate over tracking interval
      data <- data[, c(lapply(.SD, mean, na.rm = TRUE),
        count = length(X)
      ),
      by = c("time_agg", id_columns)
      ]
    }

    # remove error columns
    data <- data[, setdiff(
      colnames(data),
      c("varx", "vary", "covxy")
    ),
    with = FALSE
    ]

    # reset names to propagated error
    data.table::setnames(data,
      old = c("varx_agg", "vary_agg"),
      new = c("varx", "vary"),
      skip_absent = TRUE
    )
  } else if (method == "subsample") {
    # subsample the first observation per rounded interval
    data <- data[, c(lapply(.SD, data.table::first),
      count = length(X)
    ),
    by = c("time_agg", id_columns)
    ]
  }

  # assert copy time is of interval
  lag <- diff(data$time_agg)
  assertthat::assert_that(min(lag) >= interval,
    msg = "thin_data: diff time < interval asked!"
  )

  # check for class and whether there are rows
  assertthat::assert_that("data.frame" %in% class(data),
    msg = "thin_data: thinned data is not a dataframe object!"
  )

  return(as.data.frame(data))
}
