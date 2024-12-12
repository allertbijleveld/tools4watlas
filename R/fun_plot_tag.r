#' Plot track for one individual on a simple background.
#'
#' A function that plots the localization data of one individual.
#'
#' @author Allert Bijleveld & Johannes Krietsch
#' @param data A dataframe with the tracking data. Can include multiple tags,
#' but one tag is selected for plotting.
#' @param tag The four-digit tag number as character to plot. Defaults to
#' plotting the first tag in \code{data}.
#' @param fullname If specified the plot will be saved in this path with this
#' name (include extension). Defaults to NULL and plotting in a graphics window.
#' @param color_by Either \code{"time"}, \code{"sd"}, or \code{"nbs"},
#' which are respectively used to colour the localization with the relative
#' time (hours), variance in the localizations as the maximum of VARX and
#' VARY, or the Number of Base Stations (NBS) used to calculate the
#' localization. Defaults to "time".
#' @param towers A dataframe with coordinates of receiver stations
#' (named \code{X} and \code{Y}).
#' @param h height of the plot (when saving)
#' @param w width of the plot (when saving)
#' @param buffer Buffer around bounding box in meters
#' @param legend Passed to the \code{legend} function and sets the location
#' of the legend in the plot.
#' @param scalebar Length of scalebar in km.
#' @param cex_legend The size of the text in the legend.
#' @param land_data An `sf` object for land polygons. Defaults to `land_sf`.
#' @param mudflats_data An `sf` object for mudflat polygons. Defaults to
#'   `mudflats_sf`.
#' @param lakes_data An `sf` object for lake polygons. Defaults to `lakes_sf`.
#' @param rivers_data An `sf` object for river polygons. Defaults to
#' `rivers_sf`.
#' @return Returns nothing but a plot.
#' @importFrom grDevices colorRampPalette dev.new dev.off png rgb
#' @importFrom graphics axis box legend lines mtext par points
#' @examples
#' library(tools4watlas)
#'
#' # Load example data
#' data <- data_example
#'
#' # Transform to sf
#' d_sf <- atl_as_sf(data, additional_cols = names(data))
#'
#' # Plot the tracking data with a simple background
#' atl_plot_tag(
#'   data = d_sf, tag = NULL, fullname = NULL, buffer = 1,
#'   color_by = "time"
#' )
#'
#' atl_plot_tag(
#'   data = d_sf, tag = NULL, fullname = NULL, buffer = 1,
#'   color_by = "sd"
#' )
#'
#' atl_plot_tag(
#'   data = data, tag = NULL, fullname = NULL, buffer = 1,
#'   color_by = "time"
#' )
#' @export
atl_plot_tag <- function(data,
                         tag = NULL,
                         fullname = NULL,
                         color_by = "time",
                         towers = NULL,
                         h = 7,
                         w = 7 * (16 / 9),
                         buffer = 1,
                         legend = "topleft",
                         scalebar = 5,
                         cex_legend = 1,
                         land_data = tools4watlas::land_sf,
                         mudflats_data = tools4watlas::mudflats_sf,
                         lakes_data = tools4watlas::lakes_sf,
                         rivers_data = tools4watlas::rivers_sf) {
  # Ensure data has rows
  assertthat::assert_that(nrow(data) > 0, msg = "No data to plot")

  # Ensure tag is valid
  if (is.null(tag)) {
    tag_id <- data$tag[1]
  } else {
    tag_id <- as.character(tag)
  }

  data <- data[data$tag == tag_id, ]
  assertthat::assert_that(nrow(data) > 0, msg = "Tag not found")

  print("Ensure that data has the UTM 31N coordinate reference system.")

  # Define color scale and title based on color_by
  if (color_by == "nbs") {
    color_by_values <- data$nbs
    color_by_title <- paste("nbs", "\n", "tag ", tag, sep = "")
  } else if (color_by == "sd") {
    color_by_values <- log10(apply(cbind(data$varx, data$vary), 1, max))
    color_by_title <- paste("log10(max(VARX,VARY))", "\n", "tag ", tag,
      sep = ""
    )
  } else if (color_by == "time") {
    color_by_values <- as.numeric(difftime(data$datetime,
      min(data$datetime),
      units = "hours"
    ))
    color_by_title <- paste("Time since start (h)", "\n", "tag ", tag, sep = "")
  }

  # Generate color ramp
  rbPal <- colorRampPalette(c("white", "yellow", "orange", "red", "darkred"))
  n <- 100
  cuts <- cut(color_by_values, breaks = n)
  colramp <- rbPal(n)
  COLID <- colramp[as.numeric(cuts)]

  # Open graphics device
  if (is.null(fullname)) {
    dev.new(height = h, width = w)
  } else {
    dir.create(file.path(dirname(fullname)), showWarnings = FALSE)
    png(filename = fullname, height = h, width = w, units = "in", res = 96)
  }

  # Set plot bounds
  xrange <- range(data$x) + c(-buffer * 1000, buffer * 1000)
  yrange <- range(data$y) + c(-buffer * 1000, buffer * 1000)

  prettyX <- pretty(xrange, n = 3)
  prettyXkm <- prettyX / 1000
  prettyY <- pretty(yrange, n = 3)
  prettyYkm <- prettyY / 1000

  # Define colors
  COL_LAND <- "grey49"
  COL_WATER <- "lightblue2"
  COL_MUD <- "grey90"

  # Plot elements
  plot(sf::st_geometry(land_data),
    xlab = "x (km)", ylab = "y (km)", asp = 1,
    xaxt = "n", yaxt = "n", ylim = yrange, xlim = xrange, xaxs = "i",
    cex.lab = 1.5
  )
  axis(1, at = prettyX, labels = prettyXkm)
  axis(2, at = prettyY, labels = prettyYkm)
  graphics::rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4],
    col = COL_WATER, border = NA
  )
  plot(sf::st_geometry(mudflats_data),
    add = TRUE, col = COL_MUD,
    border = COL_MUD
  )
  plot(sf::st_geometry(land_data), add = TRUE, col = COL_LAND, border = 1)
  plot(sf::st_geometry(rivers_data), add = TRUE, col = COL_WATER, border = NA)
  plot(sf::st_geometry(lakes_data),
    add = TRUE, col = COL_WATER,
    border = COL_WATER
  )

  # Title
  mtext(
    paste("Tag ", tag, "\nFrom ", min(data$datetime), " UTC\nTo ",
      max(data$datetime), " UTC",
      sep = ""
    ),
    line = 0.5, cex = 1, col = "black"
  )

  # Add towers
  if (!is.null(towers)) {
    points(towers$X, towers$Y, pch = 23, cex = 2, col = 2, bg = 1)
  }

  # Plot tracking data
  lines(data$x, data$y, lwd = 0.5, col = "black")
  points(data$x, data$y, pch = 3, cex = 0.5, col = COLID)

  # Add scalebar
  fr <- 0.02
  xy_scale <- c(
    par("usr")[1] + diff(par("usr")[1:2]) * fr,
    par("usr")[3] + diff(par("usr")[3:4]) * fr
  )
  raster::scalebar(scalebar * 1000, xy_scale,
    type = "line", divs = 4,
    lwd = 3, col = "black", label = paste0(scalebar, " km")
  )

  # Add legend
  legend_cuts <- pretty(color_by_values, n = 5)
  legend_colors <- colramp[seq(1, n, length = length(legend_cuts))]
  legend(legend,
    legend = legend_cuts, col = legend_colors, pch = 15,
    bty = "n", text.col = "black", title = color_by_title,
    inset = c(0.01, 0.02), y.intersp = 0.8, cex = cex_legend
  )

  # Add box
  box(col = 1)

  # Close graphics device
  if (!is.null(fullname)) {
    dev.off()
  }
}
