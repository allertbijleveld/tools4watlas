# Check data has required columns

An internal function that checks that the data.table has the required
columns.

## Usage

``` r
atl_check_data(data, names_expected = c("x", "y", "time"))
```

## Arguments

- data:

  The tracking data to check for required columns. Must be in the form
  of a data.frame or similar, which can be handled by the function
  colnames.

- names_expected:

  The names expected as a character vector. By default, checks for the
  column names `x, y, time`.

## Value

None. Breaks if the data does not have required columns.

## Author

Pratik R. Gupte

## Examples

``` r
# basic (and only) use
if (FALSE) { # \dontrun{
atl_check_data(
  data = data,
  names_expected = c("x", "y", "time")
)
} # }
```
