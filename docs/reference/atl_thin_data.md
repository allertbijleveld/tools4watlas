# Thin tracking data by resampling or aggregation

Uniformly reduce data volumes with either aggregation or resampling
(specified by the `method` argument) over an interval specified in
seconds using the `interval` argument. Both options make two important
assumptions: (1) that timestamps are named 'time' and 'datetime', and
(2) all columns except the identity columns can be averaged in `R`.
While the 'subsample' option returns a thinned dataset with all columns
from the input data, the 'aggregate' option drops the column `covxy`,
since this cannot be propagated to the averaged position. Both options
handle the column 'time' differently: while 'subsample' returns the
actual timestamp (in UNIX time) of each sample, 'aggregate' returns the
mean timestamp (also in UNIX time). The 'aggregate' option only
recognises errors named `varx` and `vary`. If all of these columns are
not present together the function assumes there is no measure of error,
and drops those columns. If there is actually no measure of error, the
function simply returns the averaged position and covariates in each
time interval. Grouping variables' names (such as animal identity) may
be passed as a character vector to the `id_columns` argument. If `patch`
is among the columns, it will be converted to numeric for aggregation
and rounded back to the nearest integer, then converted back to
character to match the original type. This ensures that the most common
patch ID is retained after aggregation (e.g. 2 positions with patch ID 5
and 20 with patch ID 6 will aggregate to patch ID 6).

## Usage

``` r
atl_thin_data(
  data,
  interval = 60,
  id_columns = NULL,
  method = c("subsample", "aggregate")
)
```

## Arguments

- data:

  Tracking data to aggregate. Must have columns `x` and `y`, and a
  numeric column named `time`, as well as `datetime`.

- interval:

  The interval in seconds over which to aggregate.

- id_columns:

  Column names for grouping columns.

- method:

  Should the data be thinned by subsampling or aggregation. If
  resampling (`method = "subsample"`), the first position of each group
  is taken. If aggregation (`method = "aggregate"`), the group
  positions' mean is taken.

## Value

A data.table with aggregated or subsampled data.

## Author

Pratik Gupte & Allert Bijleveld & Johannes Krietsch

## Examples

``` r
library(data.table)

data <- data.table(
  tag = as.character(rep(1:2, each = 10)),
  time = rep(seq(1696218721, 1696218721 + 92, by = 10), 2),
  x = rnorm(20, 10, 1),
  y = rnorm(20, 15, 1)
)

data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]
#>        tag       time         x        y            datetime
#>     <char>      <num>     <num>    <num>              <POSc>
#>  1:      1 1696218721 10.606748 14.64564 2023-10-02 03:52:01
#>  2:      1 1696218731  9.890064 15.94635 2023-10-02 03:52:11
#>  3:      1 1696218741 10.172182 16.31683 2023-10-02 03:52:21
#>  4:      1 1696218751  9.909673 14.70336 2023-10-02 03:52:31
#>  5:      1 1696218761 11.924343 14.61279 2023-10-02 03:52:41
#>  6:      1 1696218771 11.298393 14.21457 2023-10-02 03:52:51
#>  7:      1 1696218781 10.748791 13.94326 2023-10-02 03:53:01
#>  8:      1 1696218791 10.556224 14.20446 2023-10-02 03:53:11
#>  9:      1 1696218801  9.451743 13.24372 2023-10-02 03:53:21
#> 10:      1 1696218811 11.110535 14.30946 2023-10-02 03:53:31
#> 11:      2 1696218721  7.387666 14.44146 2023-10-02 03:52:01
#> 12:      2 1696218731  9.844306 14.46334 2023-10-02 03:52:11
#> 13:      2 1696218741 10.433890 15.22713 2023-10-02 03:52:21
#> 14:      2 1696218751  9.618049 15.97845 2023-10-02 03:52:31
#> 15:      2 1696218761 10.424188 14.79112 2023-10-02 03:52:41
#> 16:      2 1696218771 11.063102 13.60059 2023-10-02 03:52:51
#> 17:      2 1696218781 11.048713 15.25854 2023-10-02 03:53:01
#> 18:      2 1696218791  9.961897 14.55820 2023-10-02 03:53:11
#> 19:      2 1696218801 10.486149 15.56860 2023-10-02 03:53:21
#> 20:      2 1696218811 11.672883 17.12685 2023-10-02 03:53:31
#>        tag       time         x        y            datetime
#>     <char>      <num>     <num>    <num>              <POSc>

# Thin the data by aggregation with a 60-second interval
thinned_aggregated <- atl_thin_data(
  data = data,
  interval = 60,
  id_columns = "tag",
  method = "aggregate"
)

# Thin the data by subsampling with a 60-second interval
thinned_subsampled <- atl_thin_data(
  data = data,
  interval = 60,
  id_columns = "tag",
  method = "subsample"
)

# View results
print(thinned_aggregated)
#>       tag       time        x        y            datetime n_aggregated
#>    <char>      <num>    <num>    <num>              <POSc>        <int>
#> 1:      1 1696218720 10.63357 15.07325 2023-10-02 03:52:00            6
#> 2:      1 1696218780 10.46682 13.92523 2023-10-02 03:53:00            4
#> 3:      2 1696218720  9.79520 14.75035 2023-10-02 03:52:00            6
#> 4:      2 1696218780 10.79241 15.62805 2023-10-02 03:53:00            4
print(thinned_subsampled)
#>       tag       time         x        y            datetime n_subsampled
#>    <char>      <num>     <num>    <num>              <POSc>        <int>
#> 1:      1 1696218721 10.606748 14.64564 2023-10-02 03:52:01            6
#> 2:      1 1696218781 10.748791 13.94326 2023-10-02 03:53:01            4
#> 3:      2 1696218721  7.387666 14.44146 2023-10-02 03:52:01            6
#> 4:      2 1696218781 11.048713 15.25854 2023-10-02 03:53:01            4
```
