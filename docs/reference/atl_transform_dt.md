# Transform coordinates in a data.table and appends new EPSG-Suffixed columns

Transforms coordinate columns in a `data.table` from one CRS to another
using **sf**, and appends the transformed coordinates as new columns.
The new columns are automatically named using the original column names
suffixed with the EPSG code of the target CRS (e.g., `x_4326`,
`y_4326`). Original coordinates are preserved.

## Usage

``` r
atl_transform_dt(
  data,
  x = "x",
  y = "y",
  from = sf::st_crs(32631),
  to = sf::st_crs(4326)
)
```

## Arguments

- data:

  A `data.table` containing coordinate columns.

- x:

  A character string specifying the column with x-coordinates. Defaults
  to `"x"`.

- y:

  A character string specifying the column with y-coordinates. Defaults
  to `"y"`.

- from:

  An
  [`sf::st_crs`](https://r-spatial.github.io/sf/reference/st_crs.html)
  object representing the source coordinate reference system. Defaults
  to EPSG:32631.

- to:

  An
  [`sf::st_crs`](https://r-spatial.github.io/sf/reference/st_crs.html)
  object representing the target coordinate reference system. Defaults
  to EPSG:4326.

## Value

A `data.table` identical to the input but with two new columns
containing the transformed coordinates.

## Examples

``` r
# packages
library(tools4watlas)

# example with bbox from data and movement data
data <- data_example

# add transformed coordinates in projection of the base map (EPSG:4326)
data <- atl_transform_dt(data)
```
