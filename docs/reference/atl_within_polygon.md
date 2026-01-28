# Detect position intersections with a polygon

Detects which positions intersect a `sfc_*POLYGON`. Tested only for
single polygon objects.

## Usage

``` r
atl_within_polygon(data, x = "x", y = "y", polygon)
```

## Arguments

- data:

  A dataframe or similar containg at least X and Y coordinates.

- x:

  The name of the X coordinate, assumed by default to be "x".

- y:

  The Y coordinate as above, default "y".

- polygon:

  An `sfc_*POLYGON` object which must have a defined CRS. The polygon
  CRS is assumed to be appropriate for the positions as well, and is
  assigned to the coordinates when determining the intersection.

## Value

Row numbers of positions which are inside the polygon.
