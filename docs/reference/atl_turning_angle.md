# Get the turning angle between points

Gets the relative heading between two track segments (three
localizations) using the law of cosines. The turning angle is returned
in degrees. Adds the column `angle` to a `data.table` with tracking
data. Note that with smoothed data NaN values may occur (when subsequent
localizations are at the same place).

## Usage

``` r
atl_turning_angle(data, tag = "tag", x = "x", y = "y", time = "time")
```

## Arguments

- data:

  A dataframe or similar which must have the columns specified by `x`,
  `y`, and `time`.

- tag:

  The tag ID.

- x:

  The x coordinate.

- y:

  The y coordinate.

- time:

  The timestamp in seconds since the UNIX epoch.

## Value

A a data.table with added turning angles in degrees. Negative degrees
indicate 'left' turns. There are two fewer angles than the number of
rows in the `data.table`.

## Author

Pratik R. Gupte, Allert Bijleveld & Johannes Krietsch

## Examples

``` r
# packages
library(tools4watlas)

# load example data
data <- data_example

# calculate turning angle
data <- atl_turning_angle(
  data,
  tag = "tag", x = "x", y = "y", time = "time"
)
#> Warning: NaNs produced
#> Warning: NaNs produced
#> Warning: NaNs produced
#> Warning: NaNs produced
#> Warning: NaNs produced
#> Warning: NaNs produced
#> Warning: NaNs produced
#> Warning: NaNs produced

# check data
data[, .(tag, datetime, x, y, angle)]
#>           tag            datetime        x       y    angle
#>        <char>              <POSc>    <num>   <num>    <num>
#>     1:   3027 2023-09-23 03:13:25 650705.6 5902556       NA
#>     2:   3027 2023-09-23 03:13:28 650705.6 5902556      NaN
#>     3:   3027 2023-09-23 03:19:49 650721.0 5902559 12.16458
#>     4:   3027 2023-09-23 03:19:52 650721.1 5902559 66.56262
#>     5:   3027 2023-09-23 03:19:55 650723.1 5902564      NaN
#>    ---                                                     
#> 84411:   3288 2023-09-23 23:59:24 650178.5 5902404      NaN
#> 84412:   3288 2023-09-23 23:59:30 650178.5 5902404      NaN
#> 84413:   3288 2023-09-23 23:59:36 650178.5 5902404      NaN
#> 84414:   3288 2023-09-23 23:59:42 650178.2 5902403 73.68575
#> 84415:   3288 2023-09-23 23:59:48 650177.5 5902403       NA
```
