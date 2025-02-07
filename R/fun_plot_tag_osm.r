#' Plot track for one individual on a OpenStreetMap satellite map
#'
#' A function that plots the localization data of one individual.
#'
#' @author Allert Bijleveld
#' @param data A dataframe with the tracking data. Can include multiple tags,
#'  but one tag is selected for plotting.
#' @param tag The four-digit tag number as character to plot. Defaults to
#' plotting the first tag in \code{data}.
#' @param mapID An map-object generated with the function
#'  \code{OpenStreetMap::openmap()}.
#' @param color_by Either \code{"time"}, \code{"SD"}, or \code{"NBS"}, which
#' are respectively used to colour the localization with the relative
#' time (hours), variance in the localizations as the maximum of VARX
#'  and VARY, or the Number of Base Stations (NBS) used to calculate the
#'  localization. Defaults to "time".
#' @param fullname If specified the plot will be saved in this path with this
#' name (include extension). Defaults to NULL and plotting in a graphics window.
#' @param ppi The pixels per inch, which is used to calculate the dimensions of
#' the plotting region from \code{mapID}. Deafults to 96.
#' @param towers A dataframe with coordinates of receiver stations
#'  (named \code{X} and \code{Y}).
#' @param legend Passed to the \code{legend} function and sets the location of
#' the legend in the plot.
#' @param scalebar Length of scalebar in km.
#' @param cex_legend The size of the text in the legend.
#' @return Returns nothing but a plot.
#' @examples
#' library(tools4watlas)
#' library(OpenStreetMap)
#' library(sf)
#'
#' # Load example data
#' data <- data_example[tag == data_example[1, tag]]
#'
#' # make data spatial and transform projection to WGS 84 (used in osm)
#' d_sf <- atl_as_sf(data, additional_cols = names(data))
#' d_sf <- st_transform(d_sf, crs = st_crs(4326))
#'
#' # get bounding box
#' bbox <- atl_bbox(d_sf, buffer = 500)
#'
#' # extract openstreetmap
#' # other 'type' options are "osm", "maptoolkit-topo", "bing", "stamen-toner",
#' # "stamen-watercolor", "esri", "esri-topo", "nps", "apple-iphoto",
#' "skobbler";
#' map <- openmap(c(bbox["ymax"], bbox["xmin"]),
#'   c(bbox["ymin"], bbox["xmax"]),
#'   type = "osm", mergeTiles = TRUE
#' )
#'
#' # Plot the tracking data on the satellite image
#' atl_plot_tag_osm(
#'   data = d_sf, tag = NULL, mapID = map,
#'   color_by = "time", fullname = NULL, scalebar = 3
#' )
#' @export
atl_plot_tag_osm <- function(data,
                             tag = NULL,
                             mapID,
                             color_by = "time",
                             fullname = NULL,
                             ppi = 96,
                             towers = NULL,
                             legend = "topleft",
                             scalebar = 5,
                             cex_legend = 1) {
  # Validate input data
  assertthat::assert_that(nrow(data) > 0, msg = "No data to plot.")
  assertthat::assert_that(
    inherits(data, "sf"),
    msg = "The provided data is not an 'sf' object. Please ensure it is a
    valid simple features object."
  )

  # Process tag
  if (is.null(tag)) {
    tag_id <- data$tag[1]
  } else {
    tag_id <- as.character(tag) # Ensure tag is a character
  }

  data <- data[data$tag == tag_id, ]
  assertthat::assert_that(nrow(data) > 0, msg = "Tag not found.")

  # Transform points to Mercator
  data <- sf::st_transform(data, crs = sf::st_crs(3857))

  # Process the color scale and title
  if (color_by == "nbs") {
    color_by_values <- data$NBS
    color_by_title <- paste("NBS", "\n", "Tag ", tag, sep = "")
  } else if (color_by == "sd") {
    color_by_values <- log10(apply(cbind(
      data$VARX, data$VARY
    ), 1, function(x) max(x)))
    color_by_title <- paste("log10(max(VARX,VARY))", "\n", "Tag ", tag,
      sep = ""
    )
  } else if (color_by == "time") {
    color_by_values <- as.numeric(
      difftime(data$datetime, min(data$datetime), units = "hours")
    )
    color_by_title <- paste("Time since start (h)", "\n", "Tag ", tag, sep = "")
  }

  # Get plot window size
  px_width <- mapID$tiles[[1]]$yres[1]
  px_height <- mapID$tiles[[1]]$xres[1]

  # Handle output: graphics device or file
  if (!is.null(fullname)) {
    dir.create(file.path(dirname(fullname)), showWarnings = FALSE)
    png(filename = fullname, width = px_width, height = px_height, units = "px")
  }

  # Set plotting parameters
  par(bg = "black", xpd = TRUE)

  # Plot background map
  OpenStreetMap::plot.OpenStreetMap(mapID)

  # Add title
  mtext(
    paste("From ", min(data$datetime), " UTC\nTo ", max(data$datetime),
      " UTC",
      sep = ""
    ),
    line = 1.7, cex = 1, col = "white"
  )

  # Add towers if provided
  if (!is.null(towers)) {
    points(towers$X, towers$Y, pch = 23, cex = 2, col = 2, bg = 1)
  }

  # Generate color scale
  rbPal <- colorRampPalette(c(
    "white", "lightyellow", "yellow", "orange",
    "darkorange", "red", "darkred"
  ))
  n <- 100 # Number of color classes
  cuts <- cut(color_by_values, breaks = n)
  colramp <- rbPal(n)
  COLID <- colramp[as.numeric(cuts)]

  # Plot spatial data
  data_lines <- data %>%
    dplyr::summarise(do_union = FALSE) %>%
    sf::st_cast("LINESTRING")
  plot(sf::st_geometry(data_lines), add = TRUE, lwd = 0.5, col = "black")
  plot(sf::st_geometry(data), add = TRUE, pch = 3, cex = 0.5, col = COLID)

  # Add scale bar
  fr <- 0.02 # Custom position of scalebar (fraction of plot width)
  ydiff <- diff(par("usr")[3:4])
  xdiff <- diff(par("usr")[1:2])
  xy_scale <- c(par("usr")[1] + xdiff * fr, par("usr")[3] + ydiff * fr)
  raster::scalebar(
    scalebar * 1000, xy_scale,
    type = "line", divs = 4, lwd = 3,
    col = "white", label = paste0(scalebar, " km")
  )

  # Add legend
  legend_cuts <- pretty(color_by_values, n = 5)
  legend_cuts_col <- colramp[seq(1, n, length = length(legend_cuts))]
  legend(
    legend,
    legend = legend_cuts, col = legend_cuts_col, pch = 15, bty = "n",
    text.col = "white", title = color_by_title, inset = c(0.01, 0.02),
    y.intersp = 0.8, cex = cex_legend
  )

  # Close graphics device if saved to file
  if (!is.null(fullname)) {
    dev.off()
  }
}
