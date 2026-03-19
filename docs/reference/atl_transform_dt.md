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

# check data
data[, .(tag, datetime, x, y, x_4326, y_4326)]
#>           tag            datetime        x       y   x_4326   y_4326
#>        <char>              <POSc>    <num>   <num>    <num>    <num>
#>     1:   3027 2023-09-23 03:13:25 650705.6 5902556 5.258917 53.25084
#>     2:   3027 2023-09-23 03:13:28 650705.6 5902556 5.258917 53.25084
#>     3:   3027 2023-09-23 03:19:49 650721.0 5902559 5.259149 53.25087
#>     4:   3027 2023-09-23 03:19:52 650721.1 5902559 5.259150 53.25087
#>     5:   3027 2023-09-23 03:19:55 650723.1 5902564 5.259183 53.25091
#>    ---                                                              
#> 84411:   3288 2023-09-23 23:59:24 650178.5 5902404 5.250951 53.24963
#> 84412:   3288 2023-09-23 23:59:30 650178.5 5902404 5.250951 53.24963
#> 84413:   3288 2023-09-23 23:59:36 650178.5 5902404 5.250951 53.24963
#> 84414:   3288 2023-09-23 23:59:42 650178.2 5902403 5.250946 53.24962
#> 84415:   3288 2023-09-23 23:59:48 650177.5 5902403 5.250936 53.24962
```
