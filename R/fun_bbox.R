#' Create a bounding box with specified aspect ratio and buffer
#'
#' This function generates a bounding box for a given geometry with a
#' specified aspect ratio. Additionally, it allows applying a buffer to
#' expand or contract the bounding box.
#'
#' @author Johannes Krietsch
#' @param geometry An `sf` or `sfc` object for which the bounding box is
#' calculated.
#' @param asp A character string specifying the desired aspect ratio in the
#' format `"width:height"`. Default is `"16:9"`.
#' @param buffer A numeric value specifying the buffer distance to be applied
#' to the bounding box. Positive values expand the bounding box, while
#' negative values shrink it. Default is `0`.
#'
#' @return A bounding box (`bbox`), represented as a named vector with
#' `xmin`, `ymin`, `xmax`, and `ymax` values.
#'
#' @export
#'
#' @examples
#' library(sf)
#'
#' # Create a simple geometry
#' geom <- st_as_sfc("POLYGON((0 0, 1 0, 1 2, 0 2, 0 0))")
#'
#' # Create a bounding box with a 16:9 aspect ratio
#' atl_bbox(geom, asp = "16:9")
#'
#' # Create a bounding box with a 1:1 aspect ratio and a buffer of 0.5 units
#' atl_bbox(geom, asp = "1:1", buffer = 0.5)
atl_bbox <- function(geometry, asp = "16:9", buffer = 0) {
  # Check input
  assertthat::assert_that(
    stringr::str_detect(asp, ":"),
    length(as.numeric(unlist(strsplit(asp, ":")))) == 2,
    msg = "Aspect ratio must be in the format 'width:height'."
  )

  if (mapview::npts(geometry, by_feature = FALSE) == 1 &&
        sf::st_geometry_type(geometry)[1] == "POINT") {
    assertthat::assert_that(
      buffer > 0,
      msg = "Buffer must be >0 if geometry is a single point"
    )
  }

  # Parse the aspect ratio
  ratio <- as.numeric(unlist(strsplit(asp, ":")))

  # Apply the buffer to the geometry
  if (buffer != 0) {
    # For all geometries, apply the buffer
    geometry <- sf::st_buffer(geometry, dist = buffer)
  }

  # Extract the original bounding box for the geometry (with the buffer applied)
  bbox <- sf::st_bbox(geometry)
  x_range <- bbox["xmax"] - bbox["xmin"]
  y_range <- bbox["ymax"] - bbox["ymin"]

  # Compute the desired width and height based on the aspect ratio
  desired_aspect <- ratio[1] / ratio[2]
  current_aspect <- x_range / y_range

  if (current_aspect > desired_aspect) {
    # Wider than desired aspect ratio, adjust y-range
    new_y_range <- x_range / desired_aspect
    delta_y <- (new_y_range - y_range) / 2
    bbox["ymin"] <- bbox["ymin"] - delta_y
    bbox["ymax"] <- bbox["ymax"] + delta_y
  } else {
    # Taller than desired aspect ratio, adjust x-range
    new_x_range <- y_range * desired_aspect
    delta_x <- (new_x_range - x_range) / 2
    bbox["xmin"] <- bbox["xmin"] - delta_x
    bbox["xmax"] <- bbox["xmax"] + delta_x
  }

  # Return the adjusted bounding box
  return(bbox)
}
