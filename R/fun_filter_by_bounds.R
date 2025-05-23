#' Filter positions by an area
#'
#' Filters out positions lying inside or outside an area.
#' The area can be defined in two ways, either by its X and Y coordinate
#' ranges, or by an \code{sf-*POLYGON} object.
#' \code{MULTIPOLYGON} objects are supported by the internal function
#' \code{atl_within_polygon}.
#'
#' @author Pratik R. Gupte
#' @param data A dataframe or extension which contains X and Y coordinates.
#' @param x The X coordinate column.
#' @param y The Y coordinate column.
#' @param x_range The range of X coordinates.
#' @param y_range The range of Y coordinates.
#' @param sf_polygon \code{sfc_*POLYGON} object which must have a defined CRS.
#' The polygon CRS is assumed to be appropriate for the positions as well, and
#' is assigned to the coordinates when determining the intersection.
#' @param remove_inside Whether to remove points from within the range.
#' Setting \code{negate = TRUE} removes positions within the bounding
#' box specified by the X and Y ranges.
#'
#'
#' @return A data frame of tracking locations with attractor points removed.
#' @examples
#' \dontrun{
#' filtered_data <- atl_filter_bounds(
#'   data = data,
#'   x = "X", y = "Y",
#'   x_range = c(x_min, x_max),
#'   y_range = c(y_min, y_max),
#'   sf_polygon = your_polygon,
#'   remove_inside = FALSE
#' )
#' }
#' @export
#'
atl_filter_bounds <- function(data,
                              x = "x",
                              y = "y",
                              x_range = NA,
                              y_range = NA,
                              sf_polygon = NULL,
                              remove_inside = TRUE) {
  # check input type
  assertthat::assert_that(
    "data.frame" %in% class(data),
    msg = "filter_bbox: input not a dataframe object!"
  )
  assertthat::assert_that(
    is.logical(remove_inside),
    msg = "filter_bbox: remove inside needs TRUE/FALSE"
  )

  # include asserts checking for required columns
  names_req <- c(x, y)
  atl_check_data(data, names_req)

  # check for x_range or y_range or polygon
  # why NA? because between returns true for paired NA
  assertthat::assert_that(any(
    !is.null(sf_polygon),
    !is.na(x_range), !is.na(y_range)
  ))

  # make input list of bound limits
  bounds <- list(x_range = x_range, y_range = y_range)
  # remove NA ie unsupplied limits
  bounds[sapply(bounds, function(b) {
    any(is.na(b))
  })] <- NULL

  # check input length of attractors
  invisible(lapply(bounds, function(f) {
    assertthat::assert_that(
      length(f) == 2,
      msg = "filter_bbox: incorrect bound lengths"
    )
  }))

  was_df <- FALSE
  # convert to data.table
  if (!is.data.table(data)) {
    data.table::setDT(data)
    was_df <- TRUE
  }

  # filter for spatial extent either inside or outside
  if (remove_inside) {
    # KEEPS DATA OUTSIDE THE BOUNDING BOX AND POLYGON
    # filter by bounding box
    keep <- !(data.table::between(
      data[[x]], x_range[1], x_range[2],
      NAbounds = TRUE
    ) &
      data.table::between(data[[y]], y_range[1], y_range[2],
        NAbounds = TRUE
      ))
    # filter by bbox first
    # this is where the first copy is made
    # because the number of rows is reduced
    data_ <- data[keep, ]

    # filter by polygon
    if (!is.null(sf_polygon)) {
      keep <- atl_within_polygon(
        data = data_,
        x = x, y = y,
        polygon = sf_polygon
      )
      data_ <- data_[!keep, ]
    }
  } else {
    # KEEPS DATA INSIDE THE BOUNDING BOX AND POLYGON
    keep <- data.table::between(data[[x]], x_range[1], x_range[2],
      NAbounds = TRUE
    ) &
      data.table::between(data[[y]], y_range[1], y_range[2],
        NAbounds = TRUE
      )

    # filter by bbox
    data_ <- data[keep, ]

    # filter to KEEP those inside polygon
    if (!is.null(sf_polygon)) {
      keep <- atl_within_polygon(
        data = data_,
        x = x, y = y,
        polygon = sf_polygon
      )
      data_ <- data_[keep, ]
    }
  }

  # reconvert original data to data.frame
  if (was_df) {
    data.table::setDF(data)
    assertthat::assert_that(!is.data.table(data))
  }

  assertthat::assert_that(
    "data.frame" %in% class(data_),
    msg = "filter_bbox: cleaned data is not a dataframe object!"
  )

  # print warning if all rows are removed
  if (nrow(data_) == 0) {
    warning("filter_bbox: cleaned data has no rows remaining!")
  }

  return(data_)
}
