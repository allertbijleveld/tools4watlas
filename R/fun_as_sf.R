#' Convert a data.frame or data.table to an simple feature (sf) object
#'
#' This function converts a data.frame or data.table to a simple feature (sf) 
#' object, allowing flexible specification of the x and y coordinate columns. 
#' Additional attributes can also be retained in the resulting sf object.
#'
#' @author Johannes Krietsch
#' @param data A `data.table` or an object convertible to a `data.table`. 
#'  The input data containing the coordinates and optional attributes.
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
#' @return An `sf` object containing the specified coordinates as geometry and
#'  any included attributes.
#' @import data.table
#' @examples
#' library(data.table)
#' 
#' # Example usage when column names are "x" and "y"
#' data <- data.table(x = c(1, 2, NA, 4), 
#'                    y = c(5, 6, 7, 8), 
#'                    value = c(9, 10, 11, 12), 
#'                    category = c("A", "B", "C", "D"))
#' 
#' # Add the "value" and "category" columns to the sf object
#' d_sf <- atl_as_sf(data, additional_cols = c("value", "category"))
#' print(d_sf)
#' 
#' # Example usage when column names are "lon" and "lat"
#' data2 <- data.table(lon = c(10, 20, 30, NA), lat = c(40, 50, 60, 70))
#' d_sf2 <- atl_as_sf(data2, "lon", "lat")
#' print(d_sf2)
#' @export
atl_as_sf <- function(data, 
                      x = "x", 
                      y = "y", 
                      projection = sf::st_crs(32631), 
                      additional_cols = NULL) {

  # Convert to data.table if not already
  if (!is.data.table(data)) {
    data <- data.table::setDT(data)
  }
  
  # Ensure x and y are character strings
  x_col <- as.character(substitute(x))
  y_col <- as.character(substitute(y))
  
  # Check if columns exist in the data
  if (!(x_col %in% names(data)) || !(y_col %in% names(data))) {
    stop("Specified x or y columns do not exist in the data.")
  }
  
  # Include additional columns if specified
  if (!is.null(additional_cols)) {
    # Ensure all specified additional columns exist in the data
    missing_cols <- setdiff(additional_cols, names(data))
    if (length(missing_cols) > 0) {
      stop(paste("The following additional columns are missing in the data:", 
                 paste(missing_cols, collapse = ", ")))
    }
    # Select x, y, and additional columns
    cols_to_keep <- c(x_col, y_col, additional_cols)
  } else {
    # Default to only x and y columns
    cols_to_keep <- c(x_col, y_col)
  }
  
  # Exclude rows where x or y are NA
  data_subset <- data[!is.na(get(x_col)) & !is.na(get(y_col)), 
                      cols_to_keep, with = FALSE]
  
  # Convert to sf object
  d_sf <- sf::st_as_sf(
    data_subset,
    coords = c(x_col, y_col),
    crs = projection
  )
  
  return(d_sf)
}
