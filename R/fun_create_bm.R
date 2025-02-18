#' Create a basemap with customised bounding box
#'
#' This function creates a basemap using spatial data layers, allowing for
#' custom bounding boxes, aspect ratios, and scale bar adjustments.
#'
#' @author Johannes Krietsch
#' @param data A `data.table` or an object convertible to `data.table`
#' containing spatial points. Defaults to a single point around Griend if
#' `NULL`.
#' @param x A character string specifying the column with x-coordinates.
#'   Defaults to `"x"`.
#' @param y A character string specifying the column with y-coordinates.
#'   Defaults to `"y"`.
#' @param buffer A numeric value specifying the buffer distance for the bounding
#'   box. Default is `1000`.
#' @param asp A character string specifying the aspect ratio in `"width:height"`
#'   format. Default is `"16:9"`.
#' @param option Either "osm" for OpenStreetMap polygons or "bathymetry" for
#' bathymetry data. Note that for the later it is necessary to provide the
#' bathymetry data in UTM31.
#' @param land_data An `sf` object for land polygons. Defaults to `land`.
#' @param mudflats_data An `sf` object for mudflat polygons. Defaults to
#'   `mudflats`.
#' @param lakes_data An `sf` object for lake polygons. Defaults to `lakes`.
#' @param raster_data An `SpatRaster` (tif opened with `terra::rast()` of
#' bathymetry data.
#' @param scalebar TRUE or FALSE for adding a scalebar to the plot.
#' @param sc_location A character string specifying the location of the scale
#'   bar. Default is `"br"` (bottom right).
#' @param sc_cex Numeric value for the scale bar text size. Default is `0.7`.
#' @param sc_height A unit object specifying the height of the scale bar.
#' Default is `unit(0.25, "cm")`.
#' @param sc_pad_x A unit object specifying horizontal padding for the scale
#' bar. Default is `unit(0.25, "cm")`.
#' @param sc_pad_y A unit object specifying vertical padding for the scale bar.
#'   Default is `unit(0.5, "cm")`.
#' @param projection The coordinate reference system (CRS) for the spatial data.
#'   Defaults to EPSG:32631 (WGS 84 / UTM zone 31N). Output is always UTM 31N
#'
#' @return A `ggplot2` object representing the base map with the specified
#'   settings.
#' @import ggplot2
#' @import ggspatial
#' @export
#'
#' @examples
#' # Example with default settings (map around Griend)
#' bm <- atl_create_bm(buffer = 5000)
#' print(bm)
atl_create_bm <- function(data = NULL,
                          x = "x",
                          y = "y",
                          buffer = 100,
                          asp = "16:9",
                          option = "osm",
                          land_data = tools4watlas::land,
                          mudflats_data = tools4watlas::mudflats,
                          lakes_data = tools4watlas::lakes,
                          raster_data,
                          scalebar = TRUE,
                          sc_location = "br",
                          sc_cex = 0.7,
                          sc_height = 0.25,
                          sc_pad_x = 0.25,
                          sc_pad_y = 0.5,
                          projection = sf::st_crs(32631)) {
  if (is.null(data) || nrow(data) == 0) {
    # If no data make map around Griend
    data <- data.table::data.table(tag = 1, x = 650272.5, y = 5902705)
  }

  # Convert to data.table if not already
  if (!data.table::is.data.table(data)) {
    data.table::setDT(data)
  }

  # check if required columns are present
  names_req <- c(x, y)
  atl_check_data(data, names_req)

  # Create bounding box
  if (projection == sf::st_crs(32631)) {
    bbox <- atl_bbox(data, x = x, y = y, asp = asp, buffer = buffer)
  } else {
    # Create sf and change projection if data were not UTM31
    d_sf <- atl_as_sf(data, tag = NULL, x = x, y = y, projection = projection)
    d_sf <- sf::st_transform(d_sf, crs = sf::st_crs(32631))
    bbox <- atl_bbox(d_sf, x = x, y = y, asp = asp, buffer = buffer)
  }

  if (option == "batymetry") {
    # bounding box as vector
    bbox_vec <-  sf::st_as_sfc(bbox) |> terra::vect()
    # crop bathymetry data
    raster_data_c <- terra::crop(raster_data, bbox_vec, mask = TRUE)
    # discrete steps in color scale to highlight mudflats
    x <- c(
      -50,
      seq(-6, -30, -4),
      seq(-2, -6, -1),
      seq(0, -2, -0.05),
      seq(0, 2, 0.05),
      seq(2, 6, 1),
      45
    ) |> unique()
    x <- sort(x)
    # classify in categories
    raster_data_class <- terra::classify(
      raster_data_c, x, include.lowest = TRUE, brackets = TRUE
    )
    # custom made scale
    cc <- scales::pal_div_gradient(
      "#567e9f", "#e4ccb6", "#fdf2f3", "Lab"
    )(seq(0, 1, length.out = length(x)))
    # variable name
    var_name <- names(raster_data)[1]
  }
  # Create base map
  bm <- ggplot()
  # Define layers conditionally
  if (option == "osm") {
    layers <- list(
      geom_sf(
        data = mudflats_data, fill = "#faf5ef", alpha = 0.6,
        colour = "#faf5ef"
      ),
      geom_sf(data = land_data, fill = "#faf5ef", colour = "grey80"),
      geom_sf(data = lakes_data, fill = "#D7E7FF", colour = "grey80")
    )
  } else {
    layers <- list(
      tidyterra::geom_spatraster(
        data = raster_data_class, aes(fill = !!sym(var_name)),
        show.legend = FALSE
      ),
      geom_sf(data = land_data, fill = "transparent", colour = "grey60"),
      scale_fill_manual(values = cc, na.value = "#fdf2f3")
    )
  }
  # add layers
  bm <- bm + layers

  # add scalbar if TRUE
  if (scalebar == TRUE) {
    bm <- bm +
      ggspatial::annotation_scale(
        aes(location = "br"),
        text_cex = sc_cex,
        height = unit(sc_height, "cm"),
        pad_x = unit(sc_pad_x, "cm"),
        pad_y = unit(sc_pad_y, "cm")
      )
  }

  # add plot modifications
  bm <- bm +
    # Crop to bounding box
    coord_sf(
      xlim = c(bbox["xmin"], bbox["xmax"]),
      ylim = c(bbox["ymin"], bbox["ymax"]), expand = FALSE
    ) +
    # Clean up layout
    theme(
      panel.grid.major = element_line(colour = "transparent"),
      panel.grid.minor = element_line(colour = "transparent"),
      panel.background = element_rect(fill = "#D7E7FF"),
      plot.background = element_rect(fill = "transparent", colour = NA),
      panel.border = element_rect(fill = NA, colour = "grey20"),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.x = element_blank(),
      axis.ticks.y = element_blank(),
      axis.title = element_blank(),
      plot.margin = unit(c(0, 0, -0.2, -0.2), "lines"),
    )

  return(bm)
}
