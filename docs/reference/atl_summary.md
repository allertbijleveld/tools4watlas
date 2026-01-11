# Summary of localization data

This function generates a summary of localization data by calculating
the total number of positions, first and last data, days of data and
time gaps between localizations, as well as data coverage. It returns a
summary for each unique ID specified in `id_columns`.

## Usage

``` r
atl_summary(data, id_columns = c("tag"))
```

## Arguments

- data:

  A data.table containing localization data with columns for ID, x, y
  coordinates, time, and datetime.

- id_columns:

  A character vector specifying the column(s) to group by. Defaults to
  "tag".

## Value

A data.table with summary statistics for each ID group, including the
total number of positions, first and last data, days of data and time
gaps between localizations, as well as data coverage.

## Author

Johannes Krietsch

## Examples

``` r
# packages
library(tools4watlas)

# path to csv with filtered data
data_path <- system.file(
  "extdata", "watlas_data_filtered.csv",
  package = "tools4watlas"
)

# load data
data <- fread(data_path, yaml = TRUE)

# summarize data
summary <- atl_summary(data, id_columns = c("tag"))
summary
#>       tag n_positions          first_data           last_data days_data min_gap
#>    <char>       <int>              <POSc>              <POSc>     <num>   <num>
#> 1:   3027       15833 2023-09-23 03:13:22 2023-09-23 22:24:26       0.8       3
#> 2:   3038       15935 2023-09-23 00:00:01 2023-09-23 23:59:57       1.0       3
#> 3:   3063       12294 2023-09-23 03:27:49 2023-09-23 22:24:55       0.8       3
#> 4:   3100        8411 2023-09-23 04:21:46 2023-09-23 21:41:16       0.7       3
#> 5:   3158       12401 2023-09-23 00:00:01 2023-09-23 23:59:57       1.0       3
#> 6:   3188       10050 2023-09-23 00:00:45 2023-09-23 23:41:50       1.0       3
#> 7:   3212        3846 2023-09-23 00:00:00 2023-09-23 23:59:56       1.0       8
#> 8:   3288        8130 2023-09-23 00:00:03 2023-09-23 23:59:54       1.0       6
#>    max_gap max_gap_factor fix_rate
#>      <num>         <char>    <num>
#> 1:    2523         42 min     0.69
#> 2:    2850       47.5 min     0.55
#> 3:    2541       42.4 min     0.54
#> 4:   16145      4.5 hours     0.40
#> 5:    3252       54.2 min     0.43
#> 6:    9021      2.5 hours     0.35
#> 7:    7664      2.1 hours     0.36
#> 8:    2622       43.7 min     0.56
```
