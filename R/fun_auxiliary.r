#' Make a colour transparant
#'
#' A functionm that will make the provided colour transparant.
#'
#' @author Allert Bijleveld & Johannes Krietsch
#' @param color The color to make transparant.
#' @param percent The percentage of transparancy to apply .
#' @param name The name argument as passed on to rgb.
#' @return The transparant color will be returned.
#' @importFrom grDevices col2rgb
#' @examples
#' # Example with 50% transparency
#' color_with_alpha <- atl_t_col("blue", percent = 50)
#' print(color_with_alpha)
#'
#' plot(1, 1,
#'   col = color_with_alpha, pch = 16, cex = 20,
#'   xlab = "X", ylab = "Y", main = "Point with Transparent Color"
#' )
#'
#' # Example with 30% transparency
#' color_with_alpha <- atl_t_col("red", percent = 90)
#' print(color_with_alpha)
#'
#' plot(1, 1,
#'   col = color_with_alpha, pch = 16, cex = 20,
#'   xlab = "X", ylab = "Y", main = "Point with Transparent Color"
#' )
#' @export
atl_t_col <- function(color, percent = 50, name = NULL) {
  # Validate color input
  if (!is.character(color) || length(color) != 1) {
    stop("The 'color' parameter should be a single character string.")
  }

  # Convert the color to RGB
  rgb_val <- col2rgb(color)

  # Validate percent input
  if (!is.numeric(percent) || percent < 0 || percent > 100) {
    stop("The 'percent' parameter should be a numeric value between 0 and 100.")
  }

  # Calculate the alpha transparency
  alpha_val <- (100 - percent) * 255 / 100

  # Return the color with adjusted transparency (alpha)
  rgb(rgb_val[1, ], rgb_val[2, ], rgb_val[3, ],
    maxColorValue = 255, alpha = alpha_val,
    names = name
  )
}

#' Add residence patches to a plot
#'
#' Adds residence pattch data in UTM 31N as points or polygons to a plot.
#'
#' @author Allert Bijleveld
#' @param data Either sfc_Polygon or a dataframe with the tracking data
#' @param Pch Corresponding graphical argument passed on to the base plot
#' function
#' @param Cex Corresponding graphical argument passed on to the base plot
#' function
#' @param Lwd Corresponding graphical argument passed on to the base plot
#' function
#' @param Col Corresponding graphical argument passed on to the base plot
#' function
#' @param Bg Corresponding graphical argument passed on to the base plot
#' function
#' @param Lines Corresponding graphical argument passed on to the base plot
#' function
#' @return Nothing but an addition to the current plotting device.
#' @export
atl_plot_rpatches <- function(data,
                              Pch = 21,
                              Cex = 0.25,
                              Lwd = 1,
                              Col = 1,
                              Bg = NULL,
                              Lines = TRUE) {
  if ("sfc_POLYGON" %in% class(data)) {
    plot(data, add = TRUE, col = Bg, border = Col, lwd = 1)
  } else {
    points(data$X, data$Y, col = Col, bg = Bg, pch = Pch, cex = Cex, lwd = Lwd)
    if (Lines) {
      lines(data$X, data$Y, col = Col)
    }
  }
}

#' Plot a map downloaded with OpenStreetMap
#'
#' A function that is used in e.g. plotting multiple individuals.
#'
#' @author Allert Bijleveld
#' @param map The map loaded with \code{OpenStreetMap::openmap()}.
#' @param ppi The pixels per inch, which is used to calculate the dimensions of
#' the plotting region from \code{mapID}. Deafults to 96.
#' @return Returns an OSM background plot for adding tracks.
#' @export
atl_plot_map_osm <- function(map,
                             ppi = 96) {
  ## map=osm map; ppi=pixels per inch resolution for plot
  ## get size of plot
  px_width <- map$tiles[[1]]$yres[1]
  px_height <- map$tiles[[1]]$xres[1]
  ## initiate plotting window
  # win.graph(width=px_width/ppi, height=px_height/ppi)
  dev.new(width = px_width / ppi, height = px_height / ppi)
  par(bg = "black")
  par(xpd = TRUE)
  ## make plot
  plot(map)
}

#' Add tracks to plot from list
#'
#' A function that is used for plotting multiple individuals on a map from a
#' list of spatial data.
#'
#' @author Allert Bijleveld
#' @param data The spatial data frame.
#' @param Pch The type of point to plot a localization
#' @param Cex The size of the point to plot a localization
#' @param Lwd The width of the line to connect localizations
#' @param col The colour of plotted localizations
#' @param Type The type of graph to make. For instance, "b" is both points
#' and lines and "o" is simlar but places points on top of line (no gaps)
#' @param endpoint Whether to plot the last localization of an individual
#' in magenta
#' @export
atl_plot_add_track <- function(data,
                               Pch = 19,
                               Cex = 0.25,
                               Lwd = 1,
                               col,
                               Type = "o",
                               endpoint = FALSE) {
  points(data, col = col, pch = Pch, cex = Cex, lwd = Lwd, type = Type)

  if (endpoint) {
    points(data[nrow(data), ], col = "magenta", pch = Pch, cex = Cex * 2)
  }
}
