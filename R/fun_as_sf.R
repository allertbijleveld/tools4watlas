#' Convert a data.frame or data.table to an simple feature (sf) object
#'
#' This function converts a data.frame or data.table to a simple feature (sf)
#' object, allowing flexible specification of the x and y coordinate columns.
#' Additional attributes can also be retained in the resulting sf object. There
#' are three options = c("points", "lines", "table").
#'
#' @author Johannes Krietsch
#' @param data A `data.table` or an object convertible to a `data.table`.
#'  The input data containing the coordinates and optional attributes.
#' @param tag A character string representing the  name of the column containing
#'  the tag ID.
#' @param x A character string representing the name of the column containing
#'  x-coordinates. Defaults to "x".
#' @param y A character string representing the name of the column containing
#'  y-coordinates. Defaults to "y".
#' @param projection An object of class `crs` representing the coordinate
#'  reference system (CRS) to assign to the resulting sf object. Defaults to
#'  EPSG:32631 (WGS 84 / UTM zone 31N).
#' @param additional_cols A character vector specifying additional column names
#'  to include in the resulting sf object. Defaults to `NULL` (no additional
#'  columns included).
#' @param option A character string with "points" (default) for returning sf
#'  points, "lines" to return sf lines and "table" to return a table with a sf
#' coordinates column.
#' @return An `sf` object containing the specified coordinates as geometry and
#'  any included attributes.
#' @import data.table
#' @examples
#' library(data.table)
#'
#' # Example data
#' data <- data.table(
#'   tag = c("A", "A", "B", "B"),
#'   x = c(10, 20, 30, 40),
#'   y = c(50, 60, 70, 80),
#'   value = c(100, 200, 300, 400)
#' )
#'
#' # Convert to sf points with custom CRS and retain the "value" column
#' sf_points <- atl_as_sf(data,
#'   x = "x", y = "y", tag = "tag",
#'   projection = sf::st_crs(4326),
#'   additional_cols = "value"
#' )
#' plot(sf_points)
#'
#' # Convert to sf lines
#' sf_lines <- atl_as_sf(data, x = "x", y = "y", tag = "tag", option = "lines")
#' plot(sf_lines)
#'
#' # Convert to a data.table with coordinates column
#' sf_table <- atl_as_sf(data, x = "x", y = "y", tag = "tag", option = "table")
#' print(sf_table)
#' @export
atl_as_sf <- function(data,
                      tag = "tag",
                      x = "x",
                      y = "y",
                      projection = sf::st_crs(32631),
                      additional_cols = NULL,
                      option = "points") {
  # Global variables to suppress notes in data.table
  tag_dummy <- NULL

  # Convert to data.table if not already
  if (!is.data.table(data)) {
    data <- data.table::setDT(data)
  }

  # Add so function also works without tag ID
  if (is.null(tag)) {
    tag <- "tag_dummy"
    data[, tag_dummy := "dummy"]
  }

  # Ensure x and y are character strings
  x_col <- as.character(x)
  y_col <- as.character(y)
  tag_col <- as.character(tag)
  tag_col_group <- rlang::ensym(tag)

  # Check if columns exist in the data
  if (!(x_col %in% names(data)) || !(y_col %in% names(data))) {
    stop("Specified x or y columns do not exist in the data.")
  }
  if (!(tag_col %in% names(data)) || is.null(tag)) {
    stop("Specified tag column do not exist in the data.")
  }

  # Include additional columns if specified
  if (!is.null(additional_cols)) {
    # Ensure all specified additional columns exist in the data
    missing_cols <- setdiff(additional_cols, names(data))
    if (length(missing_cols) > 0) {
      stop(paste(
        "The following additional columns are missing in the data:",
        paste(missing_cols, collapse = ", ")
      ))
    }
    # Select x, y, and additional columns
    cols_to_keep <- unique(c(tag_col, x_col, y_col, additional_cols))
  } else {
    # Default to only x and y columns
    cols_to_keep <- c(tag_col, x_col, y_col)
  }

  # Exclude rows where x or y are NA
  data_subset <- data[!is.na(get(x_col)) & !is.na(get(y_col)),
    cols_to_keep,
    with = FALSE
  ]

  # Convert to sf object
  d_sf <- sf::st_as_sf(
    data_subset,
    coords = c(x_col, y_col),
    crs = projection
  )

  # Switch for different return options
  return_data <- switch(option,
    points = {
      # Return sf with points
      d_sf
    },
    lines = {
      # Return sf with lines
      d_sf %>%
        dplyr::group_by(!!tag_col_group) %>%
        dplyr::summarise(
          do_union = FALSE,
          dplyr::across(dplyr::all_of(additional_cols), first)
        ) %>%
        sf::st_cast("LINESTRING")
    },
    table = {
      # Return data.table with coordinates as column
      data.table::data.table(d_sf)
    },
    stop("Invalid option")
  )

  return(return_data)
}
