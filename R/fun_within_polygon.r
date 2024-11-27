#' Detect position intersections with a polygon.
#'
#' @description Detects which positions intersect a \code{sfc_*POLYGON}. Tested
#' only for single polygon objects.
#'
#' @param data A dataframe or similar containg at least X and Y coordinates.
#' @param x The name of the X coordinate, assumed by default to be "x".
#' @param y The Y coordinate as above, default "y".
#' @param polygon An \code{sfc_*POLYGON} object which must have a defined CRS.
#' The polygon CRS is assumed to be appropriate for the positions as well, and
#' is assigned to the coordinates when determining the intersection.
#'
#' @return Row numbers of positions which are inside the polygon.
#'
atl_within_polygon <- function(data,
                               x = "x",
                               y = "y",
                               polygon) {
  ptid <- NULL
  # check input type
  assertthat::assert_that("data.frame" %in% class(data),
                          msg = "filter_bbox: input not a dataframe object!"
  )
  
  assertthat::assert_that("sf" %in% class(polygon),
                          msg = "filter_polygon: given spatial is not class sf"
  )
  # check polygon type
  assertthat::assert_that(any(stringr::str_detect(
    sf::st_geometry_type(polygon),
    pattern = "(POLYGON)"
  )),
  msg = "filter_polygon: given sf is not *POLYGON"
  )
  
  # check for crs
  assertthat::assert_that(!is.na(sf::st_crs(polygon)))
  
  # get bounding box of polygon
  bbox <- sf::st_bbox(polygon)
  
  # get bbox filter string
  filter_string <- c(
    sprintf(
      "data.table::between(%s, %f, %f)",
      x, bbox["xmin"], bbox["xmax"]
    ),
    sprintf(
      "data.table::between(%s, %f, %f)",
      y, bbox["ymin"], bbox["ymax"]
    )
  )
  
  # filter data on bbox first
  data[, ptid := seq_len(nrow(data))]
  data <- tools4watlas::atl_filter_covariates(
    data = data,
    filters = c(filter_string)
  )
  # get remaining rows
  rows <- data$ptid
  
  # set ptid to NULL
  data[, ptid := NULL]
  
  # get coordinates
  coord_cols <- c(x, y)
  data <- data[, coord_cols, with = FALSE]
  # make sf
  data <- sf::st_as_sf(data,
                       coords = c(x, y),
                       crs = sf::st_crs(polygon)
  )
  
  # get intersection
  poly_intersections <- apply(sf::st_intersects(data, polygon), 1, any)
  
  # add asserts
  assertthat::assert_that(is.logical(poly_intersections),
                          msg = "filter_polygon: logical not returned"
  )
  
  # return rows
  return(rows[poly_intersections])
}

# ends here
