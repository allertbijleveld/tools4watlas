#' Summary of localization data
#'
#' This function generates a summary of localization data by calculating the
#' total number of positions, first and last data, days of data and time gaps
#' between localizations, as well as  data coverage. It returns a summary for
#' each unique ID specified in `id_columns`.
#'
#' @author Johannes Krietsch
#' @param data A data.table containing localization data with columns for
#'        ID, x, y coordinates, time, and datetime.
#' @param id_columns A character vector specifying the column(s) to group by.
#'        Defaults to "tag".
#' @returns A data.table with summary statistics for each ID group, including
#' the total number of positions, first and last data, days of data and time
#' gaps between localizations, as well as  data coverage.
#' @export
#'
#' @examples
#' # packages
#' library(tools4watlas)
#'
#' # path to csv with filtered data
#' data_path <- system.file(
#'   "extdata", "watlas_data_filtered.csv",
#'   package = "tools4watlas"
#' )
#'
#' # load data
#' data <- fread(data_path, yaml = TRUE)
#'
#' # summarize data
#' summary <- atl_summary(data, id_columns = c("tag"))
#' summary
atl_summary <- function(data,
                        id_columns = c("tag")) {
  # Global variables to suppress notes in data.table
  gap_tmp <- . <- datetime <- max_gap <- min_gap <- max_gap_factor <- NULL
  n_positions <- first_data_sec <- last_data_sec <- fix_rate <- time <- NULL

  # check data structure
  required_columns <- c("tag", "x", "y", "time", "datetime")
  atl_check_data(data, names_expected = required_columns)

  # calculate time between localizations
  data[, gap_tmp := c(NA, diff(time)), by = c(id_columns)]

  # summarise by ID
  ds <- data[, .(
    n_positions = .N,
    first_data_sec = min(time, na.rm = TRUE),
    last_data_sec = max(time, na.rm = TRUE),
    first_data = min(datetime, na.rm = TRUE),
    last_data = max(datetime, na.rm = TRUE),
    days_data = round(
      as.numeric(difftime(max(datetime, na.rm = TRUE),
        min(datetime, na.rm = TRUE),
        units = "days"
      )), 1
    ),
    min_gap = round(min(gap_tmp, na.rm = TRUE), 0),
    max_gap = round(max(gap_tmp, na.rm = TRUE), 0)
  ), by = c(id_columns)]

  # format gap easy readable
  ds[, max_gap_factor := atl_format_time(max_gap)]

  # calculate coverage (how complete the track is)
  ds[, fix_rate := round(
    n_positions / ((last_data_sec - first_data_sec) / min_gap), 2
  )]

  # remove unnecessary columns
  data[, gap_tmp := NULL]
  ds[, c("first_data_sec", "last_data_sec") := NULL]

  return(ds)
}
