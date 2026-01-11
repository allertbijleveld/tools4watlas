# WATLAS species colours

Returns a vector or table of predefined colours for WATLAS species.

## Usage

``` r
atl_spec_cols(option = "vector")
```

## Arguments

- option:

  A character string specifying the output format. Options are
  `"vector"` (default), which returns a named colour vector, or
  `"table"`, which returns a data.table with species names and colours.

## Value

A named character vector (for use in ggplot2) or a data.table with
species names and corresponding colours.

## Examples

``` r
library(tools4watlas)
atl_spec_cols("vector")
#>            curlew bar-tailed godwit     oystercatcher          redshank 
#>    "mediumpurple"         "#E69F00"          "grey20"         "#ffdd3c" 
#>          red knot        sanderling            dunlin         turnstone 
#>       "firebrick"         "#0072B2"         "#66A61E"         "#A6761D" 
#>       grey plover  curlew sandpiper         spoonbill    kentish plover 
#>          "grey70"         "#FC94AF"           "ivory"         "#56B4E9" 
atl_spec_cols("table")
#>               species       colour
#>                <char>       <char>
#>  1:            curlew mediumpurple
#>  2: bar-tailed godwit      #E69F00
#>  3:     oystercatcher       grey20
#>  4:          redshank      #ffdd3c
#>  5:          red knot    firebrick
#>  6:        sanderling      #0072B2
#>  7:            dunlin      #66A61E
#>  8:         turnstone      #A6761D
#>  9:       grey plover       grey70
#> 10:  curlew sandpiper      #FC94AF
#> 11:         spoonbill        ivory
#> 12:    kentish plover      #56B4E9
```
