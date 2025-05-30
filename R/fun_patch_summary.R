#' Summary of patch data
#'
#' Computes summary statistics of movement data grouped by patches for each
#' individual tag. Calculates spatial and temporal summaries within each patch,
#' distances traveled inside patches, distances and time intervals between
#' patches, displacement within patches, and patch duration. Additional
#' user-specified summary variables and functions can also be applied
#' dynamically.
#'
#' Converts input data to data.table if needed and filters out rows with missing
#' patch assignments. All summaries are calculated by \code{tag} and
#' \code{patch}.Distance calculations use Euclidean distance in x-y coordinate
#' space.
#'
#' @author Johannes Krietsch
#' @param data A data.frame or data.table containing movement data. Must include
#'   columns: \code{tag} (ID), \code{x}, \code{y} (coords),
#'   \code{time} (timestamp), and \code{patch} (patch ID).
#' @param summary_variables Character vector of variable names in \code{data}
#'   for additional summaries. Variables should be numeric or compatible with
#'   the summary functions.
#' @param summary_functions Character vector of function name (as single string)
#'   to apply to each variable in \code{summary_variables}. Functions must work
#'   on numeric vectors (e.g., "mean" or "median").
#'
#' @return A data.table with one row per \code{tag} and \code{patch} containing:
#' \itemize{
#'   \item \code{nfixes}: Number of fixes in the patch.
#'   \item \code{x_mean}, \code{x_median}, \code{x_start}, \code{x_end}: Summary
#'   stats of x.
#'   \item \code{y_mean}, \code{y_median}, \code{y_start}, \code{y_end}: Summary
#'   stats of y.
#'   \item \code{time_mean}, \code{time_median}, \code{time_start},
#'   \code{time_end}: Summary stats of time.
#'   \item Additional summaries from \code{summary_variables} and
#'   \code{summary_functions}.
#'   \item \code{dist_in_patch}:
#'   Total distance (in m) traveled within thepatch.
#'   \item \code{dist_bw_patch}:
#'   Distance (in m) between end of previous and start of current patch.
#'   \item \code{time_bw_patch}:
#'   Time (in sec) elapsed between end of previous and start of current patch.
#'   \item \code{disp_in_patch}:
#'   Straight-line (in m) displacement between start and end of patch.
#'   \item \code{duration}: Duration spent (in sec) within the patch.
#' }
#' @import data.table
#' @export

atl_patch_summary <- function(data,
                              summary_variables = c(),
                              summary_functions = c()) {

  # Initialize necessary variables to avoid NSE (Non-Standard Evaluation) issues
  i.disp_in_patch <- dist_bw_patch <- dist_in_patch <- duration <- NULL # nolint
  x <- y <- tag <- .  <- patch <- disp_in_patch <- median <- NULL
  time_end <- time_start <- i.dist_in_patch <- time <- NULL # nolint
  x_end <- x_start <- y_end <- y_start <- time_bw_patch <- NULL

  # Validate input
  assertthat::assert_that(is.data.frame(data),
    msg = glue::glue("Input is not a data.frame or data.table, it has class
                     {stringr::str_flatten(class(data), collapse = ' ')}")
  )

  # Check data structure
  required_columns <- c("tag", "x", "y", "time", "patch")
  atl_check_data(data, names_expected = required_columns)

  # Convert data to data.table if not already
  if (!is.data.table(data)) {
    data.table::setDT(data)
  }

  # Exclude NA
  d <- data[!is.na(patch)]

  # Basic summaries
  ds <- d[, .(
    nfixes = .N,
    x_mean = mean(x),
    x_median = median(x),
    x_start = first(x),
    x_end = last(x),
    y_mean = mean(y),
    y_median = median(y),
    y_start = first(y),
    y_end = last(y),
    time_mean = mean(time),
    time_median = median(time),
    time_start = first(time),
    time_end = last(time)
  ), by = .(tag, patch)]

  # Additional summaries dynamically if any
  if (length(summary_variables) > 0) {
    extra_summaries <- d[, lapply(summary_variables, function(var) {
      lapply(summary_functions, function(fn) {
        fun <- match.fun(fn)
        fun(get(var))
      })
    }), by = .(tag, patch)]
    ds <- merge(
      ds, extra_summaries,
      by = c("tag", "patch"), all.x = TRUE
    )
  }

  # Distances inside patch
  dist_in_patch_dt <- d[, .(
    dist_in_patch = sum(sqrt(diff(x)^2 + diff(y)^2), na.rm = TRUE)
  ), by = .(tag, patch)]
  ds[dist_in_patch_dt, on = .(tag, patch), dist_in_patch := i.dist_in_patch]

  # Distances between patches, time between patches
  setorder(ds, tag, time_start)
  ds[, dist_bw_patch :=
      sqrt((x_start - shift(x_end))^2 + (y_start - shift(y_end))^2), by = tag
  ]
  ds[, time_bw_patch := time_start - shift(time_end), by = tag]

  # Displacement and duration
  ds[, disp_in_patch := sqrt((x_end - x_start)^2 + (y_end - y_start)^2)]
  ds[, duration := time_end - time_start]

  return(ds)

}
