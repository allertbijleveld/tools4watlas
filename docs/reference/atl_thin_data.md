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
#>  1:      1 1696218721  9.746638 14.96076 2023-10-02 03:52:01
#>  2:      1 1696218731 10.696963 15.68974 2023-10-02 03:52:11
#>  3:      1 1696218741 10.556663 15.02800 2023-10-02 03:52:21
#>  4:      1 1696218751  9.311244 14.25673 2023-10-02 03:52:31
#>  5:      1 1696218761  9.292505 15.18879 2023-10-02 03:52:41
#>  6:      1 1696218771 10.364582 13.19504 2023-10-02 03:52:51
#>  7:      1 1696218781 10.768533 16.46555 2023-10-02 03:53:01
#>  8:      1 1696218791  9.887654 15.15325 2023-10-02 03:53:11
#>  9:      1 1696218801 10.881108 17.17261 2023-10-02 03:53:21
#> 10:      1 1696218811 10.398106 15.47551 2023-10-02 03:53:31
#> 11:      2 1696218721  9.387974 14.29005 2023-10-02 03:52:01
#> 12:      2 1696218731 10.341120 15.61073 2023-10-02 03:52:11
#> 13:      2 1696218741  8.870637 14.06590 2023-10-02 03:52:21
#> 14:      2 1696218751 11.433024 13.74637 2023-10-02 03:52:31
#> 15:      2 1696218761 11.980400 15.29145 2023-10-02 03:52:41
#> 16:      2 1696218771  9.632779 14.55671 2023-10-02 03:52:51
#> 17:      2 1696218781  8.955865 15.00111 2023-10-02 03:53:01
#> 18:      2 1696218791 10.569720 15.07434 2023-10-02 03:53:11
#> 19:      2 1696218801  9.864945 14.41048 2023-10-02 03:53:21
#> 20:      2 1696218811 12.401618 14.43133 2023-10-02 03:53:31
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
#>       tag       time         x        y            datetime n_aggregated
#>    <char>      <num>     <num>    <num>              <POSc>        <int>
#> 1:      1 1696218720  9.994766 14.71984 2023-10-02 03:52:00            6
#> 2:      1 1696218780 10.483850 16.06673 2023-10-02 03:53:00            4
#> 3:      2 1696218720 10.274322 14.59353 2023-10-02 03:52:00            6
#> 4:      2 1696218780 10.448037 14.72931 2023-10-02 03:53:00            4
print(thinned_subsampled)
#>       tag       time         x        y            datetime n_subsampled
#>    <char>      <num>     <num>    <num>              <POSc>        <int>
#> 1:      1 1696218721  9.746638 14.96076 2023-10-02 03:52:01            6
#> 2:      1 1696218781 10.768533 16.46555 2023-10-02 03:53:01            4
#> 3:      2 1696218721  9.387974 14.29005 2023-10-02 03:52:01            6
#> 4:      2 1696218781  8.955865 15.00111 2023-10-02 03:53:01            4
```
