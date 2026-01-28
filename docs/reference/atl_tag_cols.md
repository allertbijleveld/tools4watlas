# Assign colours to tag ID's

Generates distinct and visually distinct colours for a set of input tags
using the default hue-based palette from ggplot2 (via
[`scales::hue_pal()`](https://scales.r-lib.org/reference/pal_hue.html)).
This is useful for assigning consistent colours to categorical labels in
plots, for example in an animation, where not all individuals always
have data in each frame.

## Usage

``` r
atl_tag_cols(tags, option = "vector")
```

## Arguments

- tags:

  A character or numeric vector of tags. Duplicate values are ignored.

- option:

  A string indicating the output format. Either `"vector"` for a named
  character vector of hex colors, or `"table"` for a `data.table` with
  columns `tag` and `colour`. Default is `"vector"`.

## Value

A named character vector of hex color codes if `option = "vector"`, or a
`data.table` with two columns (`tag`, `colour`) if `option = "table"`.

## Examples

``` r
# Default output (named vector)
atl_tag_cols(c("1234", "2121", "9999"))
#>      1234      2121      9999 
#> "#F8766D" "#00BA38" "#619CFF" 

# Output as a data.table
atl_tag_cols(c("1234", "2121", "9999"), option = "table")
#>       tag  colour
#>    <char>  <char>
#> 1:   1234 #F8766D
#> 2:   2121 #00BA38
#> 3:   9999 #619CFF
```
