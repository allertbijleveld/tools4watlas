#' Detect position intersections with a polygon
#'
#' @description Detects which positions intersect a polygon sf object.
#'
#' @author Johannes Krietsch
#' @param data A `data.table` or similar containing at least x and
#' y coordinates.
#' @param x The name of the x coordinate, default "x".
#' @param y The name of the y coordinate, default "y".
#' @param polygon An `sf` polygon object with a EPSG:32631 (UTM zone 31N) as
#' CRS.
#' @param col_name The name of the output column added to `data`. Defaults
#' to the name of the polygon object passed in.
#'
#' @return The original `data` with an added logical column indicating
#' whether each position intersects the polygon.
#'
#' @examples
#' # packages
#' library(tools4watlas)
#' library(sf)
#' 
#' # load example data
#' data <- data_example
#' 
#' # create basemap
#' bm <- atl_create_bm(data, buffer = 800)
#' 
#' # create a bounding box to filter data
#' griend_east <- st_sfc(st_point(c(5.275, 53.2523)), crs = st_crs(4326)) |>
#'   st_transform(crs = st_crs(32631))
#' 
#' # define bbox to crop data
#' bbox_crop <- atl_bbox(griend_east, asp = "16:9", buffer = 2000)
#' bbox_sf <- st_as_sfc(bbox_crop) # just for plotting as sf object
#' 
#' # geom_sf overwrites the coordinate system, so we need to set the limits again
#' bbox <- atl_bbox(data, buffer = 800)
#' 
#' 
#' data <- atl_within_polygon(data, polygon = bbox_sf)
#' @export
atl_within_polygon <- function(data,
                               x = "x",
                               y = "y",
                               polygon,
                               col_name = deparse(substitute(polygon))) {
  # check inputs
  assertthat::assert_that(
    "data.frame" %in% class(data),
    msg = "atl_within_polygon: input not a dataframe object!"
  )
  assertthat::assert_that(
    any(c("sf", "sfc") %in% class(polygon)),
    msg = "atl_within_polygon: polygon is not class sf or sfc"
  )
  assertthat::assert_that(
    any(stringr::str_detect(sf::st_geometry_type(polygon), "(POLYGON)")),
    msg = "atl_within_polygon: polygon geometry is not *POLYGON"
  )
  assertthat::assert_that(
    !is.na(sf::st_crs(polygon)),
    msg = "atl_within_polygon: polygon has no CRS"
  )
  assertthat::assert_that(
    sf::st_crs(polygon) == sf::st_crs(32631),
    msg = "atl_within_polygon: polygon CRS is not EPSG:32631 (UTM zone 31N)"
  )

  # pre-filter by bounding box for speed
  bbox <- sf::st_bbox(polygon)
  in_bbox <- data.table::between(data[[x]], bbox["xmin"], bbox["xmax"]) &
    data.table::between(data[[y]], bbox["ymin"], bbox["ymax"])
  rows <- which(in_bbox)

  # convert bbox-filtered subset to sf and check intersection
  data_sf <- sf::st_as_sf(
    data[rows, .SD, .SDcols = c(x, y)],
    coords = c(x, y),
    crs = sf::st_crs(polygon)
  )
  in_polygon <- apply(
    sf::st_intersects(data_sf, polygon, sparse = FALSE), 1, any
  )

  # add result column to original data
  # (FALSE by default, TRUE where intersecting)
  data[, (col_name) := FALSE]
  data[rows[in_polygon], (col_name) := TRUE]

  data
}
