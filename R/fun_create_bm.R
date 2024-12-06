#' Create a base map with customised bounding box 
#'
#' This function creates a base map using spatial data layers, allowing for 
#' custom bounding boxes, aspect ratios, and scale bar adjustments.
#'
#' @author Johannes Krietsch
#' @param data A `data.table` or an object convertible to `data.table` containing
#'   spatial points. Defaults to a single point around Griend if `NULL`.
#' @param x A character string specifying the column with x-coordinates.
#'   Defaults to `"x"`.
#' @param y A character string specifying the column with y-coordinates.
#'   Defaults to `"y"`.
#' @param buffer A numeric value specifying the buffer distance for the bounding 
#'   box. Default is `1000`.
#' @param asp A character string specifying the aspect ratio in `"width:height"`
#'   format. Default is `"16:9"`.
#' @param land_data An `sf` object for land polygons. Defaults to `land_sf`.
#' @param lakes_data An `sf` object for lake polygons. Defaults to `lakes_sf`.
#' @param mudflats_data An `sf` object for mudflat polygons. Defaults to 
#'   `mudflats_sf`.
#' @param rivers_data An `sf` object for river polygons. Defaults to `rivers_sf`.
#' @param sc_dist Scale bar distance. Optional; calculated automatically if 
#'   omitted.
#' @param sc_location A character string specifying the location of the scale 
#'   bar. Default is `"br"` (bottom right).
#' @param sc_cex Numeric value for the scale bar text size. Default is `0.7`.
#' @param sc_height A unit object specifying the height of the scale bar. Default
#'   is `unit(0.25, "cm")`.
#' @param sc_pad_x A unit object specifying horizontal padding for the scale bar. 
#'   Default is `unit(0.25, "cm")`.
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
#' bm = atl_create_bm(buffer = 5000)
#' print(bm)
atl_create_bm <- function(data = NULL,
                          x = "x", 
                          y = "y", 
                          buffer = 100, 
                          asp = "16:9",
                          land_data = tools4watlas::land_sf,
                          lakes_data = tools4watlas::lakes_sf,
                          mudflats_data = tools4watlas::mudflats_sf,
                          rivers_data = tools4watlas::rivers_sf,
                          sc_dist,
                          sc_location = "br", 
                          sc_cex = 0.7, 
                          sc_height = unit(0.25, "cm"),
                          sc_pad_x = unit(0.25, "cm"), 
                          sc_pad_y = unit(0.5, "cm"),
                          projection = sf::st_crs(32631)) {
  
  if (is.null(data) || nrow(data) == 0) {
    # If no data make map around Griend
    data <- data.table::data.table(x = 5.2525, y = 53.2523) 
    projection <- sf::st_crs(4326)
  }
  
  # Convert to data.table if not already
  if (!data.table::is.data.table(data)) {
    data.table::setDT(data)
  }
  
  # Exclude rows where x or y are NA and convert to sf object
  d_sf <- atl_as_sf(data, x, y, projection = projection)
  
  # Change projection if data were not UTM31
  d_sf <- sf::st_transform(d_sf, crs = sf::st_crs(32631)) 
  
  # Create bounding box
  bbox <- atl_bbox(d_sf, asp = asp, buffer = buffer)
  
  # Create base map
  bm <- ggplot() +
    geom_sf(data = mudflats_data, fill = '#faf5ef', alpha = 0.6, 
            colour = '#faf5ef') +
    geom_sf(data = land_data, fill = '#faf5ef', colour = 'grey80') +
    geom_sf(data = lakes_data, fill = "#D7E7FF", 
            colour = 'grey80') +
    geom_sf(data = rivers_data, fill = "#D7E7FF", colour = 'grey80') +
    # Scale bar
    ggspatial::annotation_scale(aes(location = 'br'), 
                                text_cex = 0.7, 
                                height = unit(0.25, "cm"),
                                pad_x = unit(0.25, "cm"), 
                                pad_y = unit(0.5, "cm")) +
    # Crop to bounding box
    coord_sf(xlim = c(bbox["xmin"], bbox["xmax"]), 
             ylim = c(bbox["ymin"], bbox["ymax"]), expand = FALSE) +
    # Clean up layout
    theme(
      panel.grid.major = element_line(colour = "transparent"),
      panel.grid.minor = element_line(colour = "transparent"),
      panel.background = element_rect(fill = '#D7E7FF'),
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
