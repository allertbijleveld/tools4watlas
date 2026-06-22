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
#>  1:      1 1696218721 10.821221 16.10003 2023-10-02 03:52:01
#>  2:      1 1696218731 10.593901 15.76318 2023-10-02 03:52:11
#>  3:      1 1696218741 10.918977 14.83548 2023-10-02 03:52:21
#>  4:      1 1696218751 10.782136 14.74664 2023-10-02 03:52:31
#>  5:      1 1696218761 10.074565 15.69696 2023-10-02 03:52:41
#>  6:      1 1696218771  8.010648 15.55666 2023-10-02 03:52:51
#>  7:      1 1696218781 10.619826 14.31124 2023-10-02 03:53:01
#>  8:      1 1696218791  9.943871 14.29250 2023-10-02 03:53:11
#>  9:      1 1696218801  9.844204 15.36458 2023-10-02 03:53:21
#> 10:      1 1696218811  8.529248 15.76853 2023-10-02 03:53:31
#> 11:      2 1696218721  9.521850 14.88765 2023-10-02 03:52:01
#> 12:      2 1696218731 10.417942 15.88111 2023-10-02 03:52:11
#> 13:      2 1696218741 11.358680 15.39811 2023-10-02 03:52:21
#> 14:      2 1696218751  9.897212 14.38797 2023-10-02 03:52:31
#> 15:      2 1696218761 10.387672 15.34112 2023-10-02 03:52:41
#> 16:      2 1696218771  9.946195 13.87064 2023-10-02 03:52:51
#> 17:      2 1696218781  8.622940 16.43302 2023-10-02 03:53:01
#> 18:      2 1696218791  9.585005 16.98040 2023-10-02 03:53:11
#> 19:      2 1696218801  9.605710 14.63278 2023-10-02 03:53:21
#> 20:      2 1696218811  9.940687 13.95587 2023-10-02 03:53:31
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
#> 1:      1 1696218720 10.200242 15.44982 2023-10-02 03:52:00            6
#> 2:      1 1696218780  9.734287 14.93422 2023-10-02 03:53:00            4
#> 3:      2 1696218720 10.254925 14.96110 2023-10-02 03:52:00            6
#> 4:      2 1696218780  9.438586 15.50052 2023-10-02 03:53:00            4
print(thinned_subsampled)
#>       tag       time        x        y            datetime n_subsampled
#>    <char>      <num>    <num>    <num>              <POSc>        <int>
#> 1:      1 1696218721 10.82122 16.10003 2023-10-02 03:52:01            6
#> 2:      1 1696218781 10.61983 14.31124 2023-10-02 03:53:01            4
#> 3:      2 1696218721  9.52185 14.88765 2023-10-02 03:52:01            6
#> 4:      2 1696218781  8.62294 16.43302 2023-10-02 03:53:01            4
```
