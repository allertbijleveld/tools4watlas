# Make a colour transparent

A functionm that will make the provided colour transparent.

## Usage

``` r
atl_t_col(color, percent = 50, name = NULL)
```

## Arguments

- color:

  The color to make transparant.

- percent:

  The percentage of transparancy to apply .

- name:

  The name argument as passed on to rgb.

## Value

The transparant color will be returned.

## Author

Allert Bijleveld & Johannes Krietsch

## Examples

``` r
# Example with 50% transparency
color_with_alpha <- atl_t_col("blue", percent = 50)
print(color_with_alpha)
#> [1] "#0000FF7F"

plot(1, 1,
  col = color_with_alpha, pch = 16, cex = 20,
  xlab = "X", ylab = "Y", main = "Point with Transparent Color"
)


# Example with 30% transparency
color_with_alpha <- atl_t_col("red", percent = 90)
print(color_with_alpha)
#> [1] "#FF000019"

plot(1, 1,
  col = color_with_alpha, pch = 16, cex = 20,
  xlab = "X", ylab = "Y", main = "Point with Transparent Color"
)
```
