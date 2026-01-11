# Calculate instantaneous speed

Returns additional columns for incoming and outcoming speed to the
data.table. Speed in metres per time interval. The time interval is
dependent on the units of the column specified in `TIME`.

## Usage

``` r
atl_get_speed(
  data,
  tag = "tag",
  x = "x",
  y = "y",
  time = "time",
  type = c("in", "out")
)
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

- type:

  The type of speed (incoming or outgoing) to return. Incoming speeds
  are specified by `type = "in"`, and outgoing speeds by `type = "out"`
  or both c("in", "out").

## Value

Data.table changed in place with additional speed columns

## Author

Pratik R. Gupte & Allert Bijleveld & Johannes Krietsch

## Examples

``` r
library(tools4watlas)
library(data.table)

# Create example data with two tags
set.seed(123)
data <- data.table(
  tag = rep(c("1000", "2000"), each = 5),
  x = c(1, 3, 6, 10, 15, 2, 4, 7, 11, 16),
  y = c(2, 5, 9, 14, 20, 3, 6, 10, 15, 21)
)

# Add a Unix timestamp column (randomized within a date range)
start_time <- as.numeric(as.POSIXct("2024-01-01 00:00:00", tz = "UTC"))
data[, time := start_time + sample(0:10000, .N, replace = TRUE)]
#>        tag     x     y       time
#>     <char> <num> <num>      <num>
#>  1:   1000     1     2 1704069662
#>  2:   1000     3     5 1704069710
#>  3:   1000     6     9 1704075917
#>  4:   1000    10    14 1704070185
#>  5:   1000    15    20 1704069041
#>  6:   2000     2     3 1704076533
#>  7:   2000     4     6 1704070570
#>  8:   2000     7    10 1704071960
#>  9:   2000    11    15 1704073945
#> 10:   2000    16    21 1704077018


data <- atl_get_speed(data,
  tag = "tag",
  x = "x",
  y = "y",
  time = "time",
  type = c("in", "out")
)
```
