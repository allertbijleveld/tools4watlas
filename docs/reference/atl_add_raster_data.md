# Add raster data to tracking data

This function extracts raster data (for example bathymetry data) at
specified coordinates and adds it as a column to the input data.table.

## Usage

``` r
atl_add_raster_data(
  data = NULL,
  x = "x",
  y = "y",
  projection = sf::st_crs(32631),
  raster_data,
  var_name = NULL,
  new_name = NULL,
  change_unit = 1
)
```

## Arguments

- data:

  A `data.table` containing the data to which raster values will be
  added. If not a `data.table`, it will be coerced to one.

- x:

  Character string specifying the column name for x-coordinates.
  Defaults to `"x"`.

- y:

  Character string specifying the column name for y-coordinates.
  Defaults to `"y"`.

- projection:

  A coordinate reference system (CRS) for the spatial data in the input.
  Defaults to EPSG:32631.

- raster_data:

  A `SpatRaster` object from which values will be extracted.

- var_name:

  Character string specifying the raster variable to extract. Defaults
  to the first layer if `NULL`.

- new_name:

  Character string specifying the name of the new column in the output.
  If `NULL`, uses `var_name`.

- change_unit:

  Numeric value by which to multiply extracted raster values \#' before
  adding them to the data. Defaults to `1`.

## Value

A `data.table` with the extracted raster data added as a new column.
