#' WATLAS species colours
#'
#' Returns a vector or table of predefined colours for WATLAS species.
#'
#' @param option A character string specifying the output format. Options are 
#'   `"vector"` (default), which returns a named colour vector, or `"table"`, 
#'   which returns a data.table with species names and colours.
#'
#' @return A named character vector (for use in ggplot2) or a data.table 
#'   with species names and corresponding colours.
#' @export
#'
#' @examples
#' library(tools4watlas)
#' atl_spec_cols("vector")
#' atl_spec_cols("table")
atl_spec_cols <- function(option = "vector") {
  # Ensure valid input
  match.arg(option, choices = c("vector", "table"))

  # Vector with colors
  species_colours <- c(
    "curlew" = "mediumpurple",
    "bar-tailed godwit" = "#E69F00",
    "oystercatcher" = "grey20",
    "redshank" = "#ffdd3c",
    "red knot" = "firebrick",
    "sanderling" = "#0072B2",
    "dunlin" = "#66A61E",
    "turnstone" = "#A6761D",
    "grey plover" = "grey70",
    "curlew sandpiper" = "#FC94AF",
    "spoonbill" = "ivory",
    "kentish plover" = "#56B4E9"
  )

  # Return selected format
  if (option == "vector") {
    return(species_colours)
  } else {
    return(data.table::data.table(
      species = names(species_colours),
      colour = species_colours
    ))
  }
}

#' WATLAS species labels
#'
#' Returns a named vector of species labels in either a multiline or single-line
#' format.
#'
#' @param option A character string specifying the format of the species names. 
#'   Options are `"multiline"` (default), where names include line breaks
#'   (`\n`),  or `"singleline"`, where names are returned as a single line.
#'
#' @return A named character vector where names correspond to species 
#' identifiers and values are formatted species names.
#' @export
#'
#' @examples
#' library(tools4watlas)
#' atl_spec_labs("multiline")
#' atl_spec_labs("multiline")
atl_spec_labs <- function(option = "multiline") {
  # Ensure valid input
  match.arg(option, choices = c("multiline", "singleline"))

  # Return selected format
  if (option == "multiline") {
    return(c(
      "curlew" = "Eurasian\ncurlew",
      "bar-tailed godwit" = "Bar-tailed\ngodwit",
      "oystercatcher" = "Eurasian\noystercatcher",
      "redshank" = "Common\nredshank",
      "red knot" = "Red knot",
      "sanderling" = "Sanderling",
      "dunlin" = "Dunlin",
      "turnstone" = "Turnstone",
      "grey plover" = "Grey\nplover",
      "curlew sandpiper" = "Curlew\nsandpiper",
      "spoonbill" = "Eurasian\nspoonbill",
      "kentish plover" = "Kentish\nplover"
    ))
  } else {
    return(c(
      "curlew" = "Eurasian curlew",
      "bar-tailed godwit" = "Bar-tailed godwit",
      "oystercatcher" = "Eurasian oystercatcher",
      "redshank" = "Common redshank",
      "red knot" = "Red knot",
      "sanderling" = "Sanderling",
      "dunlin" = "Dunlin",
      "turnstone" = "Turnstone",
      "grey plover" = "Grey plover",
      "curlew sandpiper" = "Curlew sandpiper",
      "spoonbill" = "Eurasian spoonbill",
      "kentish plover" = "Kentish plover"
    ))
  }
}

#' Format time in easy readable interval
#'
#' This function converts a given time (in seconds) into a easy readable format
#' with days, hours, minutes, or seconds.
#'
#' @author Johannes Krietsch
#' @param time Time in seconds (numeric or vector of numeric values).
#'
#' @returns A character vector with the formatted time intervals.
#' @export
#'
#' @examples
#' library(tools4watlas)
#' atl_format_time(3600)
#' atl_format_time(c(120, 3600, 86400))
atl_format_time <- function(time) {
  vapply(time, function(t) {
    dplyr::case_when(
      t >= 86400 ~ paste(round(t / 86400, 1), "days"), # more than 1 day
      t >= 3600 ~ paste(round(t / 3600, 1), "hours"),  # more than 1 hour
      t >= 60 ~ paste(round(t / 60, 1), "min"),        # more than 1 minute
      TRUE ~ paste(round(t, 1), "sec")                 # less than 1 minute
    )
  }, character(1))
}

#' Make a colour transparent
#'
#' A functionm that will make the provided colour transparent.
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
