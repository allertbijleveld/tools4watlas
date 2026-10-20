#' Thin tracking data by resampling or aggregation
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
#' The 'aggregate' option only recognises errors named \code{varx} and
#' \code{vary}.
#' If all of these columns are not present together the function assumes there
#' is no measure of error, and drops those columns.
#' If there is actually no measure of error, the function simply returns the
#' averaged position and covariates in each time interval.
#' Grouping variables' names (such as animal identity) may be passed as a
#' character vector to the \code{id_columns} argument.
#' If `patch` is among the columns and the data are aggregated, only if the
#' first and last point of the aggregation interval are from the same patch,
#' this position will be assigned to the patch. With thinning the patch ID
#' stays as it is for this position.
#'
#' Derived from `atlastools::atl_thin_data()` in the \pkg{atlastools}
#' package (Gupte et al., 2022), licensed under GPL-3.
#'
#' @author Pratik Gupte & Allert Bijleveld & Johannes Krietsch
#' @references
#' Gupte, P. R., Beardsworth, C. E., Spiegel, O., Lourie, E., Toledo, S.,
#' Nathan, R., & Bijleveld, A. I. (2022). A guide to pre-processing
#' high-throughput animal tracking data. *Journal of Animal Ecology*, 91,
#' 287-307. \doi{10.1111/1365-2656.13610}
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
  varx <- vary <- patch <- n_aggregated <- p_first <- p_last <- NULL
  time <- time_agg <- time_diff <- datetime <- n_subsampled <- NULL

  # Input validation
  assertthat::assert_that(
    inherits(data, "data.frame"),
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
  on.exit(data[, time_agg := NULL], add = TRUE)

  # Identify numeric and non-numeric columns (excluding grouping/key columns)
  by_cols <- c("time_agg", id_columns)
  drop_cols <- c("varx", "vary", "covxy", "time", "datetime", "patch")

  num_cols <- setdiff(
    names(data)[vapply(data, is.numeric, logical(1))],
    c(by_cols, drop_cols)
  )
  non_num_cols <- setdiff(names(data), c(num_cols, by_cols, drop_cols))

  # Handle method: aggregate or subsample
  if (method == "aggregate") {
    # Only assign patch to aggregated window if first and last point are same
    # means of numeric columns
    data_s <- data[, lapply(.SD, mean, na.rm = TRUE),
      by = by_cols, .SDcols = num_cols
    ]

    # counts and variance propagation
    if (all(c("varx", "vary") %in% names(data))) {
      cnt <- data[, list(
        n_aggregated = .N,
        varx = sum(varx, na.rm = TRUE),
        vary = sum(vary, na.rm = TRUE)
      ), by = by_cols]
      cnt[, `:=`(
        varx = varx / n_aggregated^2,
        vary = vary / n_aggregated^2
      )]
    } else {
      cnt <- data[, list(n_aggregated = .N), by = by_cols]
    }
    data_s <- cbind(data_s, cnt[, !by_cols, with = FALSE])

    # first value of non-numeric columns
    if (length(non_num_cols) > 0) {
      firsts <- data[, lapply(.SD, first),
        by = by_cols, .SDcols = non_num_cols
      ]
      data_s <- cbind(data_s, firsts[, !by_cols, with = FALSE])
    }

    #  only keep if first and last point of the window agree
    if ("patch" %in% names(data)) {
      pt <- data[, list(p_first = first(patch), p_last = last(patch)),
        by = by_cols
      ]
      pt[, patch := fifelse(p_first == p_last, p_first, NA_character_)]
      data_s <- cbind(data_s, pt[, "patch", with = FALSE])
    }

    # datetime and time
    data_s[, datetime := as.POSIXct(
      time_agg,
      origin = "1970-01-01", tz = "UTC"
    )]
    data.table::setnames(data_s, "time_agg", "time")
  } else if (method == "subsample") {
    # Subsample the first observation per rounded interval
    data_s <- unique(data, by = by_cols)
    data_s[, n_subsampled := data[, .N, by = by_cols]$N]
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

  # Check if intervalls are correct
  if (method == "aggregate") {
    assertthat::assert_that(
      min(lag) >= interval,
      msg = "thin_data: time differences are less than the specified interval!"
    )
  }

  # Final validation
  assertthat::assert_that(
    inherits(data_s, "data.frame"),
    msg = "thin_data: thinned data is not a data.frame object!"
  )

  data_s
}
