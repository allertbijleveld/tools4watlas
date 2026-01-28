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
be passed as a character vector to the `id_columns` argument.

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
#>  1:      1 1696218721  8.033383 14.93809 2023-10-02 03:52:01
#>  2:      1 1696218731 10.701356 14.69404 2023-10-02 03:52:11
#>  3:      1 1696218741  9.527209 14.61953 2023-10-02 03:52:21
#>  4:      1 1696218751  8.932176 14.30529 2023-10-02 03:52:31
#>  5:      1 1696218761  9.782025 14.79208 2023-10-02 03:52:41
#>  6:      1 1696218771  8.973996 13.73460 2023-10-02 03:52:51
#>  7:      1 1696218781  9.271109 17.16896 2023-10-02 03:53:01
#>  8:      1 1696218791  9.374961 16.20796 2023-10-02 03:53:11
#>  9:      1 1696218801  8.313307 13.87689 2023-10-02 03:53:21
#> 10:      1 1696218811 10.837787 14.59712 2023-10-02 03:53:31
#> 11:      2 1696218721 10.153373 14.53334 2023-10-02 03:52:01
#> 12:      2 1696218731  8.861863 15.77997 2023-10-02 03:52:11
#> 13:      2 1696218741 11.253815 14.91663 2023-10-02 03:52:21
#> 14:      2 1696218751 10.426464 15.25332 2023-10-02 03:52:31
#> 15:      2 1696218761  9.704929 14.97145 2023-10-02 03:52:41
#> 16:      2 1696218771 10.895126 14.95713 2023-10-02 03:52:51
#> 17:      2 1696218781 10.878133 16.36860 2023-10-02 03:53:01
#> 18:      2 1696218791 10.821581 14.77423 2023-10-02 03:53:11
#> 19:      2 1696218801 10.688640 16.51647 2023-10-02 03:53:21
#> 20:      2 1696218811 10.553918 13.45125 2023-10-02 03:53:31
#>        tag       time         x        y            datetime

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
#>       tag       time         x        y            datetime n_aggregated
#>    <char>      <num>     <num>    <num>              <POSc>        <int>
#> 1:      1 1696218720  9.325024 14.51394 2023-10-02 03:52:00            6
#> 2:      1 1696218780  9.449291 15.46273 2023-10-02 03:53:00            4
#> 3:      2 1696218720 10.215928 15.06864 2023-10-02 03:52:00            6
#> 4:      2 1696218780 10.735568 15.27764 2023-10-02 03:53:00            4
print(thinned_subsampled)
#>       tag       time         x        y            datetime n_subsampled
#>    <char>      <num>     <num>    <num>              <POSc>        <int>
#> 1:      1 1696218721  8.033383 14.93809 2023-10-02 03:52:01            6
#> 2:      1 1696218781  9.271109 17.16896 2023-10-02 03:53:01            4
#> 3:      2 1696218721 10.153373 14.53334 2023-10-02 03:52:01            6
#> 4:      2 1696218781 10.878133 16.36860 2023-10-02 03:53:01            4
```
