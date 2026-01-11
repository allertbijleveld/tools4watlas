# Create a bounding box with specified aspect ratio and buffer

This function generates a bounding box for a given geometry with a
specified aspect ratio. Additionally, it allows applying a buffer to
expand or contract the bounding box.

## Usage

``` r
atl_bbox(data, x = "x", y = "y", asp = "16:9", buffer = 0)
```

## Arguments

- data:

  An `sf` or `sfc` object for which the bounding box is calculated or a
  data.table with x- and y- coordinates.

- x:

  A character string representing the name of the column containing
  x-coordinates. Defaults to "x".

- y:

  A character string representing the name of the column containing
  y-coordinates. Defaults to "y".

- asp:

  A character string specifying the desired aspect ratio in the format
  `"width:height"`. Default is `"16:9"`, if `NULL` returns simple
  bounding box without modifying aspect ratio.

- buffer:

  A numeric value (in meters) specifying the buffer distance to be
  applied to the bounding box. Positive values expand the bounding box,
  while negative values shrink it. Default is `0`.

## Value

A bounding box (`bbox`), represented as a named vector with `xmin`,
`ymin`, `xmax`, and `ymax` values.

## Author

Johannes Krietsch

## Examples

``` r
library(sf)
#> Linking to GEOS 3.13.1, GDAL 3.11.0, PROJ 9.6.0; sf_use_s2() is TRUE

# Create a simple geometry
geom <- st_as_sfc("POLYGON((0 0, 1 0, 1 2, 0 2, 0 0))")

# Create a bounding box with a 16:9 aspect ratio
atl_bbox(geom, asp = "16:9")
#>      xmin      ymin      xmax      ymax 
#> -1.277778  0.000000  2.277778  2.000000 

# Create a bounding box with a 1:1 aspect ratio and a buffer of 0.5 units
atl_bbox(geom, asp = "1:1", buffer = 0.5)
#> xmin ymin xmax ymax 
#> -1.0 -0.5  2.0  2.5 
```
