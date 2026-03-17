# Detect position intersections with a polygon

Detects which positions intersect a polygon sf object.

## Usage

``` r
atl_within_polygon(
  data,
  x = "x",
  y = "y",
  polygon,
  col_name = deparse(substitute(polygon))
)
```

## Arguments

- data:

  A `data.table` or similar containing at least x and y coordinates.

- x:

  The name of the x coordinate, default "x".

- y:

  The name of the y coordinate, default "y".

- polygon:

  An `sf` polygon object with a EPSG:32631 (UTM zone 31N) as CRS.

- col_name:

  The name of the output column added to `data`. Defaults to the name of
  the polygon object passed in.

## Value

The original `data` with an added logical column indicating whether each
position intersects the polygon.

## Author

Johannes Krietsch

## Examples

``` r
# packages
library(tools4watlas)
library(sf)
library(ggplot2)

# load example data
data <- data_example

# create basemap
bm <- atl_create_bm(data, buffer = 800)

# create a bounding box to filter data
griend_east <- st_sfc(st_point(c(5.275, 53.2523)), crs = st_crs(4326)) |>
  st_transform(crs = st_crs(32631))

# define bbox to crop data
bbox_crop <- atl_bbox(griend_east, asp = "16:9", buffer = 2000)
bbox_sf <- st_as_sfc(bbox_crop) # just for plotting as sf object

# geom_sf overwrites coordinate system, so we need to set the limits again
bbox <- atl_bbox(data, buffer = 800)


data <- atl_within_polygon(data, polygon = bbox_sf)
```
