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
#>  1:      1 1696218721  8.599956 15.46815 2023-10-02 03:52:01
#>  2:      1 1696218731 10.255317 15.36295 2023-10-02 03:52:11
#>  3:      1 1696218741  7.562736 13.69546 2023-10-02 03:52:21
#>  4:      1 1696218751  9.994429 15.73778 2023-10-02 03:52:31
#>  5:      1 1696218761 10.621553 16.88850 2023-10-02 03:52:41
#>  6:      1 1696218771 11.148412 14.90255 2023-10-02 03:52:51
#>  7:      1 1696218781  8.178182 14.06415 2023-10-02 03:53:01
#>  8:      1 1696218791  9.752675 14.98405 2023-10-02 03:53:11
#>  9:      1 1696218801  9.755800 14.17321 2023-10-02 03:53:21
#> 10:      1 1696218811  9.717295 13.48760 2023-10-02 03:53:31
#> 11:      2 1696218721  9.446301 15.93536 2023-10-02 03:52:01
#> 12:      2 1696218731 10.628982 15.17649 2023-10-02 03:52:11
#> 13:      2 1696218741 12.065025 15.24369 2023-10-02 03:52:21
#> 14:      2 1696218751  8.369011 16.62355 2023-10-02 03:52:31
#> 15:      2 1696218761 10.512427 15.11204 2023-10-02 03:52:41
#> 16:      2 1696218771  8.136989 14.86600 2023-10-02 03:52:51
#> 17:      2 1696218781  9.477987 13.08991 2023-10-02 03:53:01
#> 18:      2 1696218791  9.947398 14.72076 2023-10-02 03:53:11
#> 19:      2 1696218801 10.542996 14.68655 2023-10-02 03:53:21
#> 20:      2 1696218811  9.085925 16.06731 2023-10-02 03:53:31
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
#> 1:      1 1696218720 9.697067 15.34257 2023-10-02 03:52:00            6
#> 2:      1 1696218780 9.350988 14.17725 2023-10-02 03:53:00            4
#> 3:      2 1696218720 9.859789 15.49285 2023-10-02 03:52:00            6
#> 4:      2 1696218780 9.763577 14.64113 2023-10-02 03:53:00            4
print(thinned_subsampled)
#>       tag       time        x        y            datetime n_subsampled
#>    <char>      <num>    <num>    <num>              <POSc>        <int>
#> 1:      1 1696218721 8.599956 15.46815 2023-10-02 03:52:01            6
#> 2:      1 1696218781 8.178182 14.06415 2023-10-02 03:53:01            4
#> 3:      2 1696218721 9.446301 15.93536 2023-10-02 03:52:01            6
#> 4:      2 1696218781 9.477987 13.08991 2023-10-02 03:53:01            4
```
