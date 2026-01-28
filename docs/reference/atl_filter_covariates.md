# Filter data by position covariates

The atlastools function `atl_filter_covariates` allows convenient
filtering of a dataset by any number of logical filters. This function
can be used to easily filter timestamps in a range, as well as combine
simple spatial and temporal filters. It accepts a character vector of
`R` expressions that each return a logical vector (i.e., `TRUE` or
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

  A dataframe or similar containing the variables to be filtered.

- filters:

  A character vector of filter expressions. An example might be
  `"speed < 20"`. The filtering variables must be in the dataframe. The
  function will not explicitly check whether the filtering variables are
  present; this makes it flexible, allowing expressions such as
  `"between(speed, 2, 20)"`, but also something to use at your own risk.
  A missing filter variables *will* result in an empty data frame.

- quietly:

  If TRUE returns percentage and number of positions filtered, if FALSE
  functions runs quietly

## Value

A dataframe filtered using the filters specified.

## Author

Pratik R. Gupte

## Examples

``` r
if (FALSE) { # \dontrun{
night_data <- atl_filter_covariates(
  data = dataset,
  filters = c("!inrange(hour, 6, 18)")
)

data_in_area <- atl_filter_covariates(
  data = dataset,
  filters = c(
    "between(time, t_min, t_max)",
    "between(x, x_min, x_max)"
  )
)
filtered_data <- atl_filter_covariates(
  data = data,
  filters = c(
    "NBS > 3",
    "SD < 100",
    "between(day, 5, 8)"
  )
)
} # }
```
