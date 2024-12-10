#' Thin tracking data by resampling or aggregation.
#'
#' Uniformly reduce data volumes with either aggregation or resampling
#' (specified by the \code{method} argument) over an interval specified in
#' seconds using the \code{interval} argument.
#' Both options make two important assumptions:
#' (1) that timestamps are named 'time' and 'datetime', and
#' (2) all columns except the identity columns can be averaged in \code{R}.
#' While the 'subsample' option returns a thinned dataset with all columns from
#' the input data, the 'aggregate' option drops the column \code{covxy}, since
#' this cannot be propagated to the averaged position.
#' Both options handle the column 'time' differently: while 'subsample' returns
#' the actual timestamp (in UNIX time) of each sample, 'aggregate' returns the
#' mean timestamp (also in UNIX time).
#' In both cases, an extra column, \code{time_agg}, is added which has a uniform
#'  difference between each element corresponding to the user-defined thinning
#' interval.
#' The 'aggregate' option only recognises errors named \code{varx} and
#' \code{vary}.
#' If all of these columns are not present together the function assumes there
#' is no measure of error, and drops those columns.
#' If there is actually no measure of error, the function simply returns the
#' averaged position and covariates in each time interval.
#' Grouping variables' names (such as animal identity) may be passed as a
#' character vector to the \code{id_columns} argument.
#'
#' @author Pratik Gupte & Allert Bijleveld & Johannes Krietsch
#' @param data Tracking data to aggregate. Must have columns \code{x} and 
#' \code{y}, and a numeric column named \code{time}, as well as \code{datetime}.
#' @param interval The interval in seconds over which to aggregate.
#' @param id_columns Column names for grouping columns.
#' @param method Should the data be thinned by subsampling or aggregation.
#' If resampling (\code{method = "subsample"}), the first position of each group
#' is taken. If aggregation (\code{method = "aggregate"}), the group positions'
#' mean is taken.
#'
#' @return A data.table with aggregated or subsampled data.
#'
#' @examples
#' library(data.table)
#' 
# Create sample tracking data
#' data <- data.table(
#'   tag = as.character(rep(1:2, each = 10)),
#'   time = rep(seq(1696218721, 1696218721 + 92, by = 10), 2),
#'   x = rnorm(20, 10, 1),
#'   y = rnorm(20, 15, 1)
#' )
#' 
#' data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]
#' 
#' # Thin the data by aggregation with a 60-second interval
#' thinned_aggregated <- atl_thin_data(
#'   data = data,
#'   interval = 60,
#'   id_columns = "tag",
#'   method = "aggregate"
#' )
#' 
#' # Thin the data by subsampling with a 60-second interval
#' thinned_subsampled <- atl_thin_data(
#'   data = data,
#'   interval = 60,
#'   id_columns = "tag",
#'   method = "subsample"
#' )
#' 
#' # View results
#' print(thinned_aggregated)
#' print(thinned_subsampled)
#' @export
atl_thin_data <- function(data,
                          interval = 60,
                          id_columns = NULL,
                          method = c("subsample", "aggregate")) {
  # Global variables to suppress notes in data.table
  varx <- vary <- covxy <- x <- y <- NULL
  time <- time_agg <- time_diff <- datetime <- NULL
  
  # Input validation
  assertthat::assert_that(
    "data.frame" %in% class(data),
    msg = "thin_data: input is not a data.frame object!"
  )
  assertthat::assert_that(
    method %in% c("subsample", "aggregate"),
    msg = "thin_data: method must be 'subsample' or 'aggregate'!"
  )
  
  # Convert to data.table if not already
  if (!data.table::is.data.table(data)) {
    data <- data.table::setDT(data)
  }
  
  # Check for required columns
  atl_check_data(data, names_expected = c("x", "y", "time", id_columns))
  
  # Check that the interval is greater than the minimum time difference
  if (is.null(id_columns)) {
    lag <- diff(data$time)
  } else {
    data[, time_diff := c(NA, diff(time)), by = c(id_columns)]
    lag <- data[!is.na(time_diff)]$time_diff
    data[, time_diff := NULL]
  }
  
  assertthat::assert_that(
    interval > min(lag),
    msg = "thin_data: thinning interval is less than the tracking interval!"
  )
  
  # Preserve original column order
  col_order <- copy(colnames(data))
  
  # Round time to the nearest interval
  data[, time_agg := floor(as.numeric(time) / interval) * interval]
  
  # Handle method: aggregate or subsample
  if (method == "aggregate") {
    if (all(c("varx", "vary") %in% colnames(data))) {
      # Aggregate with variance propagation
      # variance of an average is sum of variances sum(SD ^ 2)
      # divided by sample size squared length(SD) ^ 2
      # the standard deviation is the square root of the variance
      data_s <- data[, c(lapply(.SD, mean, na.rm = TRUE),
                         varx_agg = sum(varx, na.rm = TRUE) / (length(varx)^2),
                         vary_agg = sum(vary, na.rm = TRUE) / (length(vary)^2),
                         n_aggregated = length(x)),
                     by = c("time_agg", id_columns)]
    } else {
      # Simple aggregation
      data_s <- data[, c(lapply(.SD, mean, na.rm = TRUE),
                         n_aggregated = length(x)),
                     by = c("time_agg", id_columns)]
    }
    
    # Recalculate datetime and clean up columns
    data_s[, datetime := as.POSIXct(time_agg, 
                                    origin = "1970-01-01", tz = "UTC")]
    data_s <- data_s[, setdiff(colnames(data_s), c("varx", "vary", 
                                                   "covxy", "time")),
                   with = FALSE]
    
    # Rename columns
    data.table::setnames(data_s,
                         old = c("varx_agg", "vary_agg", "time_agg"),
                         new = c("varx", "vary", "time"),
                         skip_absent = TRUE
    )
  } else if (method == "subsample") {
    # Subsample the first observation per rounded interval
    data_s <- data[, c(lapply(.SD, data.table::first),
                     n_subsampled = length(x)),
                 by = c("time_agg", id_columns)]
    data_s[, time_agg := NULL]
  }
  
  # Restore original column order
  setcolorder(data_s, intersect(col_order, names(data_s)))
  
  # Validate time differences match the interval
  if (is.null(id_columns)) {
    lag <- diff(data_s$time)
  } else {
    data_s[, time_diff := c(NA, diff(time)), by = c(id_columns)]
    lag <- data_s[!is.na(time_diff)]$time_diff
    data_s[, time_diff := NULL]
  }

  assertthat::assert_that(
    min(lag) >= interval,
    msg = "thin_data: time differences are less than the specified interval!"
  )
  
  # Final validation
  assertthat::assert_that(
    "data.frame" %in% class(data_s),
    msg = "thin_data: thinned data is not a data.frame object!"
  )
  
  # clean original data
  data[, time_agg := NULL]
  
  return(data_s)
}
