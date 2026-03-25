# Filter data by position covariates

The atlastools function `atl_filter_covariates` allows convenient
filtering of a dataset by any number of logical filters. This function
can be used to easily filter timestamps in a range, as well as combine
simple spatial and temporal filters. It accepts a character vector of
`R` expressions that each return a logical vector (i.e. `TRUE` or
`FALSE`). Each filtering condition is interpreted in the context of the
dataset supplied, and used to filter for rows that satisfy each of the
filter conditions. Users must make sure that the filtering variables
exist in their dataset in order to avoid errors.

## Usage

``` r
atl_filter_covariates(data, filters = c(), quietly = FALSE)
```

## Arguments

- data:

  A `data.table` or similar containing the variables to be filtered.

- filters:

  A character vector of filter expressions. An example might be
  `"speed < 20"`. The filtering variables must be in the `data.table`.
  The function will not explicitly check whether the filtering variables
  are present; this makes it flexible, allowing expressions such as
  `"between(speed, 2, 20)"`, but also something to use at your own risk.
  A missing filter variables *will* result in an empty data frame.

- quietly:

  If `TRUE` returns percentage and number of positions filtered, if
  `FALSE` functions runs quietly

## Value

A dataframe filtered using the filters specified.

## Author

Pratik R. Gupte and Johannes Krietsch

## Examples

``` r
# packages
library(tools4watlas)

# load example data
data <- data_example

# filter data at night
# extract hour of the day
data[, hour := as.integer(format(datetime, "%H"))]
#> Index: <tag>
#>              species posID    tag       time            datetime        x
#>               <char> <int> <char>      <num>              <POSc>    <num>
#>     1:        dunlin   275   3212 1695430800 2023-09-23 01:00:00 650151.6
#>     2: oystercatcher   660   3158 1695430801 2023-09-23 01:00:01 649975.0
#>     3:    sanderling   493   3288 1695430804 2023-09-23 01:00:03 650188.7
#>     4:      red knot  1044   3038 1695430804 2023-09-23 01:00:03 650120.1
#>     5:      red knot  1045   3038 1695430807 2023-09-23 01:00:06 650120.1
#>    ---                                                                   
#> 84411:        dunlin  3855   3212 1695513589 2023-09-23 23:59:48 650183.4
#> 84412: oystercatcher 12531   3158 1695513591 2023-09-23 23:59:51 650004.4
#> 84413:      red knot 15957   3038 1695513591 2023-09-23 23:59:51 650159.1
#> 84414: oystercatcher 12532   3158 1695513594 2023-09-23 23:59:54 650004.4
#> 84415:      red knot 15958   3038 1695513594 2023-09-23 23:59:54 650159.1
#>              y   nbs      varx     vary      covxy  speed_in speed_out    x_raw
#>          <num> <int>     <num>    <num>      <num>     <num>     <num>    <num>
#>     1: 5902407     3  38.26355 12.38899   1.356684 0.0000000 0.3238910 650149.8
#>     2: 5902425     3 131.97209 34.78138 -58.865135 0.0000000 1.9851646 649986.8
#>     3: 5902413     3  66.80401 44.25712  37.512772 0.0000000 0.3227225 650188.3
#>     4: 5902400     3 115.79927 12.08877 -18.469843 0.2251024 0.0000000 650124.6
#>     5: 5902400     3  96.15878 12.61339 -15.279923 0.0000000 0.8369818 650107.8
#>    ---                                                                         
#> 84411: 5902397     3 104.30193 19.05418   3.946224 0.0000000 0.0000000 650179.0
#> 84412: 5902405     3 218.35306 49.32916 -39.187370 1.7745534 0.0000000 650004.4
#> 84413: 5902391     3 147.30193 15.44028 -17.418375 0.0000000 0.0000000 650142.0
#> 84414: 5902405     3 135.37704 29.45627 -28.880238 0.0000000 0.0000000 650017.9
#> 84415: 5902391     3  95.73801 13.23645  -6.875969 0.0000000 0.0000000 650143.1
#>          y_raw  tideID tidaltime time2lowtide waterlevel bathymetry  hour
#>          <num>   <int>     <num>        <num>      <num>      <num> <int>
#>     1: 5902404 2023513  133.4210    -246.5790       49.9  100.82805     1
#>     2: 5902423 2023513  133.4710    -246.5290       49.9  113.91438     1
#>     3: 5902415 2023513  139.8205    -240.1795       45.0  135.18997     1
#>     4: 5902400 2023513  139.8705    -240.1295       45.0   95.74708     1
#>     5: 5902400 2023513  139.9205    -240.0795       45.0   95.74708     1
#>    ---                                                                   
#> 84411: 5902395 2023514  639.4034     269.4034       61.7   99.64340    23
#> 84412: 5902405 2023514  639.5034     269.5034       62.0   90.67731    23
#> 84413: 5902393 2023514  639.6034     269.6034       62.0  100.82805    23
#> 84414: 5902411 2023514  639.7033     269.7033       62.0   90.67731    23
#> 84415: 5902391 2023514  639.8033     269.8033       62.0  100.82805    23

night_data <- atl_filter_covariates(
  data = data,
  filters = c("!inrange(hour, 6, 18)")
)
#> Note: 66.3% of the dataset was filtered out, corresponding to 55969 positions.

# filter on the variance of the estimated x- and y-coordinates
var_max <- 5000 # in meters squared

data_filtered <- atl_filter_covariates(
  data = data,
  filters = c(
    sprintf("varx < %s", var_max),
    sprintf("vary < %s", var_max)
  )
)
#> Note: 0% of the dataset was filtered out, corresponding to 0 positions.

# filter by speed
speed_max <- 35 # m/s (126 km/h)

data <- atl_filter_covariates(
  data = data,
  filters = c(
    sprintf("speed_in < %s | is.na(speed_in)", speed_max),
    sprintf("speed_out < %s | is.na(speed_out)", speed_max)
  )
)
#> Note: 0% of the dataset was filtered out, corresponding to 0 positions.
```
