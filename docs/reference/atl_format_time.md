# Format time in easy readable interval

This function converts a given time (in seconds) into a easy readable
format with days, hours, minutes, or seconds.

## Usage

``` r
atl_format_time(time)
```

## Arguments

- time:

  Time in seconds (numeric or vector of numeric values).

## Value

A character vector with the formatted time intervals.

## Author

Johannes Krietsch

## Examples

``` r
library(tools4watlas)
atl_format_time(3600)
#> [1] "1 hours"
atl_format_time(c(120, 3600, 86400))
#> [1] "2 min"   "1 hours" "1 days" 
```
