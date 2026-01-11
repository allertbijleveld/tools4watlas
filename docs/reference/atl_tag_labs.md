# Create unique labels for tags by combining specified columns

Generates a named character vector of unique labels for each `tag` in
the data. The labels are created by concatenating the values of
specified columns for the first occurrence of each tag, using a
user-defined separator.

## Usage

``` r
atl_tag_labs(data, columns, sep = " ")
```

## Arguments

- data:

  A `data.table` or `data.frame` containing at least a `tag` column.

- columns:

  A character vector specifying the names of columns to combine into the
  label. These columns must exist in `data`.

- sep:

  A character string used to separate concatenated column values in the
  label. Defaults to an space `" "`.

## Value

A named character vector where the names are unique `tag` values from
the data, and the values are concatenated labels created from the
specified columns.

## Details

The function selects the first row for each unique `tag` to create the
label. If the `tag` column or any of the specified columns are missing,
the function will stop with an informative error message.

## Examples

``` r
library(data.table)
data <- data.table(
  tag = c("1234", "2222", "1234"),
  rings = c(123234442, 334234234, 123234442),
  name = c("Allert", "Peter", "Karl")
)
atl_tag_labs(data, c("rings", "name"), sep = " ")
#>               1234               2222 
#> "123234442 Allert"  "334234234 Peter" 
```
