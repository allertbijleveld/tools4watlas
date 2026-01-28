# Create full tag ID or tag ID with specific length

Create full tag ID or tag ID with specific length

## Usage

``` r
atl_full_tag_id(tag, short = FALSE, n = 4)
```

## Arguments

- tag:

  Tag number or vector with multiple numbers (either numeric or
  character). Maximally provide 6 digits, but less work.

- short:

  TRUE or FALSE for short or long tag ID

- n:

  if short = TRUE, how many digits should the short tag ID have?

## Value

Full or short tag ID as character

## Author

Johannes Krietsch

## Examples

``` r
tag <- c(3040, 3085, 3086)
atl_full_tag_id(tag)
#> [1] "31001003040" "31001003085" "31001003086"
atl_full_tag_id(tag, short = TRUE)
#> [1] "3040" "3085" "3086"
```
