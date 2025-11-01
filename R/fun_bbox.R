#' Create a bounding box with specified aspect ratio and buffer
#'
#' This function generates a bounding box for a given geometry with a
#' specified aspect ratio. Additionally, it allows applying a buffer to
#' expand or contract the bounding box.
#'
#' @author Johannes Krietsch
#' @param data An `sf` or `sfc` object for which the bounding box is
#' calculated or a data.table with x- and y- coordinates.
#' @param x A character string representing the name of the column containing
#'  x-coordinates. Defaults to "x".
#' @param y A character string representing the name of the column containing
#'  y-coordinates. Defaults to "y".
#' @param asp A character string specifying the desired aspect ratio in the
#' format `"width:height"`. Default is `"16:9"`, if `NULL` returns simple
#' bounding box without modifying aspect ratio.
#' @param buffer A numeric value (in meters) specifying the buffer distance to
#' be applied to the bounding box. Positive values expand the bounding box,
#' while negative values shrink it. Default is `0`.
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
atl_bbox <- function(data,
                     x = "x",
                     y = "y",
                     asp = "16:9",
                     buffer = 0) {
  # Check input
  if (!is.null(asp)) {
    assertthat::assert_that(
      stringr::str_detect(asp, ":"),
      length(as.numeric(unlist(strsplit(asp, ":")))) == 2,
      msg = "Aspect ratio must be in the format 'width:height'."
    )
  }

  if (inherits(data, c("sf", "sfc"))) {
    if (nrow(sf::st_coordinates(data)) == 1) {
      assertthat::assert_that(
        buffer > 0,
        msg = "Buffer must be >0 if geometry is a single point"
      )
    }
  } else {
    if (nrow(data) == 1) {
      assertthat::assert_that(
        buffer > 0,
        msg = "Buffer must be >0 if geometry is a single point"
      )
    }
  }

  # Extract the original bounding box
  if (inherits(data, c("sf", "sfc"))) {
    bbox <- sf::st_bbox(data)
  } else {
    # check if required columns are present
    names_req <- c(x, y)
    atl_check_data(data, names_req)
    bbox <- sf::st_bbox(c(
      xmin = min(data[[x]], na.rm = TRUE),
      ymin = min(data[[y]], na.rm = TRUE),
      xmax = max(data[[x]], na.rm = TRUE),
      ymax = max(data[[y]], na.rm = TRUE)
    ))
  }

  # Apply the buffer to the bbox
  if (buffer != 0) {
    bbox <- sf::st_as_sfc(bbox) |> sf::st_buffer(dist = buffer) |> sf::st_bbox()
  }

  # If asp is NULL, return the bbox without modifying aspect ratio
  if (is.null(asp)) {
    return(bbox)
  }

  # Parse the aspect ratio
  ratio <- as.numeric(unlist(strsplit(asp, ":")))

  # Extract range
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
