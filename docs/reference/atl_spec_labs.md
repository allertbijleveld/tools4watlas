# WATLAS species labels

Returns a named vector of species labels in either a multiline or
single-line format, which can also be the short common name.

## Usage

``` r
atl_spec_labs(option = "multiline")
```

## Arguments

- option:

  A character string specifying the format of the species names. Options
  are `"multiline"` (default), where names include line breaks (`\n`),
  or `"singleline"`, where names are returned as a single line.
  Additionally, `"short_multiline"` and `"short_singleline"` options can
  be returned.

## Value

A named character vector where names correspond to species identifiers
and values are formatted species names.

## Examples

``` r
library(tools4watlas)
atl_spec_labs("multiline")
#>                    curlew         bar-tailed godwit             oystercatcher 
#>        "Eurasian\ncurlew"      "Bar-tailed\ngodwit" "Eurasian\noystercatcher" 
#>                  redshank                  red knot                sanderling 
#>        "Common\nredshank"                "Red knot"              "Sanderling" 
#>                    dunlin                 turnstone               grey plover 
#>                  "Dunlin"        "Ruddy\nturnstone"            "Grey\nplover" 
#>          curlew sandpiper                 spoonbill            kentish plover 
#>       "Curlew\nsandpiper"     "Eurasian\nspoonbill"         "Kentish\nplover" 
atl_spec_labs("singleline")
#>                   curlew        bar-tailed godwit            oystercatcher 
#>        "Eurasian curlew"      "Bar-tailed godwit" "Eurasian oystercatcher" 
#>                 redshank                 red knot               sanderling 
#>        "Common redshank"               "Red knot"             "Sanderling" 
#>                   dunlin                turnstone              grey plover 
#>                 "Dunlin"        "Ruddy turnstone"            "Grey plover" 
#>         curlew sandpiper                spoonbill           kentish plover 
#>       "Curlew sandpiper"     "Eurasian spoonbill"         "Kentish plover" 
atl_spec_labs("short_multiline")
#>               curlew    bar-tailed godwit        oystercatcher 
#>             "Curlew" "Bar-tailed\ngodwit"      "Oystercatcher" 
#>             redshank             red knot           sanderling 
#>           "Redshank"           "Red knot"         "Sanderling" 
#>               dunlin            turnstone          grey plover 
#>             "Dunlin"          "Turnstone"       "Grey\nplover" 
#>     curlew sandpiper            spoonbill       kentish plover 
#>  "Curlew\nsandpiper"          "Spoonbill"       "Grey\nplover" 
atl_spec_labs("short_singleline")
#>              curlew   bar-tailed godwit       oystercatcher            redshank 
#>            "Curlew" "Bar-tailed godwit"     "Oystercatcher"          "Redshank" 
#>            red knot          sanderling              dunlin           turnstone 
#>          "Red knot"        "Sanderling"            "Dunlin"         "Turnstone" 
#>         grey plover    curlew sandpiper           spoonbill      kentish plover 
#>       "Grey plover"  "Curlew sandpiper"         "Spoonbill"       "Grey plover" 
```
