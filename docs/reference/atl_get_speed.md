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

Pratik R. Gupte, Allert Bijleveld & Johannes Krietsch

## Examples

``` r
# packages
library(tools4watlas)

# load example data
data <- data_example

# remove speed columns
data[, c("speed_in", "speed_out") := NULL]
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
#>              y   nbs      varx     vary      covxy    x_raw   y_raw  tideID
#>          <num> <int>     <num>    <num>      <num>    <num>   <num>   <int>
#>     1: 5902407     3  38.26355 12.38899   1.356684 650149.8 5902404 2023513
#>     2: 5902425     3 131.97209 34.78138 -58.865135 649986.8 5902423 2023513
#>     3: 5902413     3  66.80401 44.25712  37.512772 650188.3 5902415 2023513
#>     4: 5902400     3 115.79927 12.08877 -18.469843 650124.6 5902400 2023513
#>     5: 5902400     3  96.15878 12.61339 -15.279923 650107.8 5902400 2023513
#>    ---                                                                     
#> 84411: 5902397     3 104.30193 19.05418   3.946224 650179.0 5902395 2023514
#> 84412: 5902405     3 218.35306 49.32916 -39.187370 650004.4 5902405 2023514
#> 84413: 5902391     3 147.30193 15.44028 -17.418375 650142.0 5902393 2023514
#> 84414: 5902405     3 135.37704 29.45627 -28.880238 650017.9 5902411 2023514
#> 84415: 5902391     3  95.73801 13.23645  -6.875969 650143.1 5902391 2023514
#>        tidaltime time2lowtide waterlevel bathymetry
#>            <num>        <num>      <num>      <num>
#>     1:  133.4210    -246.5790       49.9  100.82805
#>     2:  133.4710    -246.5290       49.9  113.91438
#>     3:  139.8205    -240.1795       45.0  135.18997
#>     4:  139.8705    -240.1295       45.0   95.74708
#>     5:  139.9205    -240.0795       45.0   95.74708
#>    ---                                             
#> 84411:  639.4034     269.4034       61.7   99.64340
#> 84412:  639.5034     269.5034       62.0   90.67731
#> 84413:  639.6034     269.6034       62.0  100.82805
#> 84414:  639.7033     269.7033       62.0   90.67731
#> 84415:  639.8033     269.8033       62.0  100.82805

# calculate speed
data <- atl_get_speed(data,
                      tag = "tag",
                      x = "x",
                      y = "y",
                      time = "time",
                      type = c("in", "out")
)

# check data
data[, .(tag, datetime, x, y, speed_in, speed_out)]
#>           tag            datetime        x       y    speed_in  speed_out
#>        <char>              <POSc>    <num>   <num>       <num>      <num>
#>     1:   3027 2023-09-23 03:13:25 650705.6 5902556          NA 0.00000000
#>     2:   3027 2023-09-23 03:13:28 650705.6 5902556 0.000000000 0.04132607
#>     3:   3027 2023-09-23 03:19:49 650721.0 5902559 0.041326067 0.01412799
#>     4:   3027 2023-09-23 03:19:52 650721.1 5902559 0.014127986 1.73816620
#>     5:   3027 2023-09-23 03:19:55 650723.1 5902564 1.738166199 0.00000000
#>    ---                                                                   
#> 84411:   3288 2023-09-23 23:59:24 650178.5 5902404 0.008866944 0.00000000
#> 84412:   3288 2023-09-23 23:59:30 650178.5 5902404 0.000000000 0.00000000
#> 84413:   3288 2023-09-23 23:59:36 650178.5 5902404 0.000000000 0.17174318
#> 84414:   3288 2023-09-23 23:59:42 650178.2 5902403 0.171743185 0.11173205
#> 84415:   3288 2023-09-23 23:59:48 650177.5 5902403 0.111732046         NA
```
