#' Transform coordinates in a data.table and appends new EPSG-Suffixed columns
#'
#' @description
#' Transforms coordinate columns in a `data.table` from one CRS to another using
#' **sf**, and appends the transformed coordinates as new columns.
#' The new columns are automatically named using the original column names
#' suffixed with the EPSG code of the target CRS (e.g., `x_4326`, `y_4326`).
#' Original coordinates are preserved.
#'
#' @param data A `data.table` containing coordinate columns.
#' @param x A character string specifying the column with x-coordinates.
#'   Defaults to `"x"`.
#' @param y A character string specifying the column with y-coordinates.
#'   Defaults to `"y"`.
#' @param from An `sf::st_crs` object representing the source coordinate
#' reference system.
#'             Defaults to EPSG:32631.
#' @param to An `sf::st_crs` object representing the target coordinate
#' reference system.
#'           Defaults to EPSG:4326.
#'
#' @return
#' A `data.table` identical to the input but with two new columns containing the
#' transformed coordinates.
#' @import     data.table
#' @importFrom sf st_as_sf st_transform st_coordinates
#'
#' @examples
#' require(tools4watlas)
#'
#'  data <- data_example
#' data <- atl_transform_dt(data)
#' data[, .(species, tag, datetime, x, y, x_4326, y_4326)]
#' #'
#' DT = data.table(name = c('NARL', 'Utqiagvik'),
#'                 lat  = c(71.320854, 71.290246),
#'                 lon  = c(-156.648210, -156.788622))
#'
#' st_transform_DT(DT)
atl_transform_dt <- function(data,
                             x = "x",
                             y = "y",
                             from = sf::st_crs(32631),
                             to = sf::st_crs(4326)) {
  if (nrow(data) > 0) {
    # temporarily rename to x,y (so function works with any col names)
    data.table::setnames(data, c(y, x), c("y", "x"))

    # convert to sf + transform
    pp <- sf::st_as_sf(data, coords = c("x", "y"), crs = from)
    pp <- sf::st_transform(pp, crs = to)

    # extract coordinates
    coords <- sf::st_coordinates(pp)

    # extract EPSG code for automatic naming
    epsg_to <- to$epsg
    if (is.null(epsg_to)) stop("Target CRS has no EPSG code.")

    # construct new column names
    x_trans <- paste0(x, "_", epsg_to)
    y_trans <- paste0(y, "_", epsg_to)

    # add new transformed coordinate columns
    data[, (x_trans) := coords[, 1]]
    data[, (y_trans) := coords[, 2]]

    # restore original names
    setnames(data, c("y", "x"), c(y, x))

    # store CRS attribute
    setattr(data, "crs", to)
  }

  return(data)
}
