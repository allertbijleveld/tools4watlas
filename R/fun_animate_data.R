# Contains all functions related to making animations

#' Generate time steps and file names for an animation of movements
#'
#' This function creates a sequence of time steps based on a given datetime
#' vector and time interval. It also generates corresponding file names in a
#' provided folder path for each time step.
#'
#' @author Johannes Krietsch
#' @param datetime_vector A vector of datetime values (POSIXct or similar).
#' Can be a min and max or simple a full vector from the data
#' @param time_interval A character string specifying the time interval
#' (e.g., "30 sec", "10 min", "1 hour").
#' @param output_path A character string specifying the directory of the folder
#' where the files will be saved.
#' @param create_path A logical value. If TRUE, the function creates the
#' directory if it does not exist.
#'
#' @returns A data.table with two columns:
#' \itemize{
#'   \item \code{datetime}: The generated time steps.
#'   \item \code{path}: Corresponding file paths for each time step.
#' }
#'
#' @export
#'
#' @examples
#' library(tools4watlas)
#'
#' # load example data
#' data <- data_example
#'
#' # create time steps
#' ts <- atl_time_steps(
#'   datetime_vector = data$datetime,
#'   time_interval = "10 min",
#'   output_path = tempdir(),
#'   create_path = FALSE
#' )
#' ts
atl_time_steps <- function(datetime_vector,
                           time_interval = "10 min",
                           output_path,
                           create_path = FALSE) {
  # global variables
  path <- NULL

  # check if directory exists, create if wanted
  if (!dir.exists(output_path)) {
    if (create_path) {
      dir.create(output_path, recursive = TRUE)
      message("Directory created: ", output_path)
    } else {
      stop(
        "Error: Directory does not exist: ", output_path,
        "use create_path = TRUE to create directory"
      )
    }
  }

  # create time series
  ts <- data.table(datetime = seq(
    lubridate::floor_date(
      min(datetime_vector, na.rm = TRUE),
      unit = time_interval
    ),
    lubridate::ceiling_date(
      max(datetime_vector, na.rm = TRUE),
      unit = time_interval
    ),
    by = time_interval
  ))

  # generate file paths with padded numbers
  ts[, path := paste0(
    output_path, "/", stringr::str_pad(
      seq_len(.N), nchar(as.character(.N)), "left",
      pad = "0"
    ), ".png"
  )]

  return(ts)
}

#' Creates different alpha values along a vector
#'
#' Copied from https://github.com/mpio-be/windR
#'
#' @author Mihai Valcu & Johannes Krietsch
#' @param x Vector along which alpha is created
#' @param head Numeric parameter influencing the lenght of the head
#' @param skew Numeric parameter influencing the skew of alpha
#'
#' @return Numeric verctor with different alpha values
#' @export
#'
#' @importFrom scales rescale
#' @examples
#' library(ggplot2)
#' d <- data.frame(
#'   x = 1:100, y = 1:100,
#'   a = atl_alpha_along(1:100, head = 20, skew = -2)
#' )
#' bm <- ggplot(d, aes(x, y))
#' bm + geom_path(linewidth = 10)
#' bm + geom_path(linewidth = 10, alpha = d$a, lineend = "round")
atl_alpha_along <- function(x, head = 20, skew = -2) {
  if (head >= length(x)) head <- as.integer(length(x) * 0.5)
  x <- as.numeric(x)
  he <- exp(rescale(x[(length(x) - head):length(x)], c(skew, 0)))
  ta <- rep(min(he), length.out = length(x) - head - 1)
  c(ta, he)
}

#' Creates different size values along a vector
#'
#' Copied from https://github.com/mpio-be/windR
#'
#' @author Mihai Valcu & Johannes Krietsch
#' @param x Vector along which alpha is created
#' @param head Numeric parameter influencing the lenght of the head
#' @param to Numeric vector including the minimum and maximum size
#'
#' @return Numeric verctor with different size values
#' @export
#'
#' @importFrom scales rescale
#' @examples
#' library(ggplot2)
#' d <- data.frame(
#'   x = 1:100, y = 1:100,
#'   s = atl_size_along(1:100, head = 70, to = c(0.1, 5))
#' )
#' bm <- ggplot(d, aes(x, y))
#' bm + geom_path(linewidth = 1)
#' bm + geom_path(linewidth = d$s, lineend = "round")
atl_size_along <- function(x, head = 20, to = c(0.1, 2.5)) {
  if (head >= length(x)) head <- as.integer(length(x) * 0.5)
  x <- as.numeric(x)
  he <- rescale(x[(length(x) - head):length(x)], to)
  ta <- rep(min(he), length.out = length(x) - head - 1)
  c(ta, he)
}

#' Generate ffmpeg filename pattern
#'
#' This function generates a filename pattern for FFmpeg based on the number of
#' digits in the numeric part of the input file path (without the `.png`
#' extension).
#'
#' @param x A character vector of file paths, where each path should include a
#'        filename with a `.png` extension.
#'
#' @returns A character string representing the FFmpeg-compatible filename
#'          pattern (e.g., "%03d.png" for filenames like "001.png").
#' @export
#'
#' @examples
#' atl_ffmpeg_pattern("path/to/file/001.png")
#' # Returns: "%03d.png"
atl_ffmpeg_pattern <- function(x) {
  # extract number of digits in filename
  x <- nchar(sub("\\.png$", "", basename(x)))

  # create the pattern needed for ffmpeg
  paste0("%0", x, "d.png")

}
