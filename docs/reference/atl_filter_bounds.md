# Filter positions by an area

Filters out positions lying inside or outside an area. The area can be
defined in two ways, either by its X and Y coordinate ranges, or by an
`sf-*POLYGON` object. `MULTIPOLYGON` objects are supported by the
internal function `atl_within_polygon`.

## Usage

``` r
atl_filter_bounds(
  data,
  x = "x",
  y = "y",
  x_range = NA,
  y_range = NA,
  sf_polygon = NULL,
  remove_inside = TRUE
)
```

## Arguments

- data:

  A dataframe or extension which contains X and Y coordinates.

- x:

  The X coordinate column.

- y:

  The Y coordinate column.

- x_range:

  The range of X coordinates.

- y_range:

  The range of Y coordinates.

- sf_polygon:

  `sfc_*POLYGON` object which must have a defined CRS. The polygon CRS
  is assumed to be appropriate for the positions as well, and is
  assigned to the coordinates when determining the intersection.

- remove_inside:

  Whether to remove points from within the range. Setting
  `negate = TRUE` removes positions within the bounding box specified by
  the X and Y ranges.

## Value

A data frame of tracking locations with attractor points removed.

## Author

Pratik R. Gupte

## Examples

``` r
if (FALSE) { # \dontrun{
filtered_data <- atl_filter_bounds(
  data = data,
  x = "X", y = "Y",
  x_range = c(x_min, x_max),
  y_range = c(y_min, y_max),
  sf_polygon = your_polygon,
  remove_inside = FALSE
)
} # }
```
