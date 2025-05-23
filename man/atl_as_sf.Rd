% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fun_as_sf.R
\name{atl_as_sf}
\alias{atl_as_sf}
\title{Convert a data.frame or data.table to an simple feature (sf) object}
\usage{
atl_as_sf(
  data,
  tag = "tag",
  x = "x",
  y = "y",
  projection = sf::st_crs(32631),
  additional_cols = NULL,
  option = "points"
)
}
\arguments{
\item{data}{A \code{data.table} or an object convertible to a \code{data.table}.
The input data containing the coordinates and optional attributes.}

\item{tag}{A character string representing the  name of the column containing
the tag ID.}

\item{x}{A character string representing the name of the column containing
x-coordinates. Defaults to "x".}

\item{y}{A character string representing the name of the column containing
y-coordinates. Defaults to "y".}

\item{projection}{An object of class \code{crs} representing the coordinate
reference system (CRS) to assign to the resulting sf object. Defaults to
EPSG:32631 (WGS 84 / UTM zone 31N).}

\item{additional_cols}{A character vector specifying additional column names
to include in the resulting sf object. Defaults to \code{NULL} (no additional
columns included).}

\item{option}{A character string with "points" (default) for returning sf
points, "lines" to return sf lines and "table" to return a table with a sf
coordinates column.}
}
\value{
An \code{sf} object containing the specified coordinates as geometry and
any included attributes.
}
\description{
This function converts a data.frame or data.table to a simple feature (sf)
object, allowing flexible specification of the x and y coordinate columns.
Additional attributes can also be retained in the resulting sf object. There
are three options = c("points", "lines", "table").
}
\examples{
library(data.table)

# Example data
data <- data.table(
  tag = c("A", "A", "B", "B"),
  x = c(10, 20, 30, 40),
  y = c(50, 60, 70, 80),
  value = c(100, 200, 300, 400)
)

# Convert to sf points with custom CRS and retain the "value" column
sf_points <- atl_as_sf(data,
  x = "x", y = "y", tag = "tag",
  projection = sf::st_crs(4326),
  additional_cols = "value"
)
plot(sf_points)

# Convert to sf lines
sf_lines <- atl_as_sf(data, x = "x", y = "y", tag = "tag", option = "lines")
plot(sf_lines)

# Convert to a data.table with coordinates column
sf_table <- atl_as_sf(data, x = "x", y = "y", tag = "tag", option = "table")
print(sf_table)
}
\author{
Johannes Krietsch
}
