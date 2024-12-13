#' The Netherlands
#'
#' SpatialPolygonsDataFrame describing the Netherlands' surface areas. Used for
#' background layer in the function atl_plot_tag.
#'
#' @format
#' \describe{
#'   \item{SOORT}{land, water, sea (zee)}
#' }
#' @source <https://www.rijkswaterstaat.nl>
"land"

#' Intertidal Dutch Wadden Sea
#'
#' SpatialPolygonsDataFrame describing the Wadden Sea's intertidal area. Used
#' for background layer in the function atl_plot_tag()
#'
#' @source <https://www.rijkswaterstaat.nl>
"mudflats"

#' OSM data land around Griend
#'
#' @format sf object used for background layer in the function atl_create_bm()
#'
#' @source <https://www.openstreetmap.org>
"land_sf"

#' OSM data mudflats around Griend
#'
#' @format sf object used for background layer in the function atl_create_bm()
#'
#' @source <https://www.openstreetmap.org>
"mudflats_sf"

#' OSM data lakes around Griend
#'
#' @format sf object used for background layer in the function atl_create_bm()
#'
#' @source <https://www.openstreetmap.org>
"lakes_sf"

#' OSM data rivers around Griend
#'
#' @format sf object used for background layer in the function atl_create_bm()
#'
#' @source <https://www.openstreetmap.org>
"rivers_sf"

#' Data from two red knots and one redshank
#'
#' @format data.table of watlas data with tide data added
#'
#' @source watlas data example
"data_example"
