# Add residence patches to a plot

Adds residence pattch data in UTM 31N as points or polygons to a plot.

## Usage

``` r
atl_plot_rpatches(
  data,
  Pch = 21,
  Cex = 0.25,
  Lwd = 1,
  Col = 1,
  Bg = NULL,
  Lines = TRUE
)
```

## Arguments

- data:

  Either sfc_Polygon or a dataframe with the tracking data

- Pch:

  Corresponding graphical argument passed on to the base plot function

- Cex:

  Corresponding graphical argument passed on to the base plot function

- Lwd:

  Corresponding graphical argument passed on to the base plot function

- Col:

  Corresponding graphical argument passed on to the base plot function

- Bg:

  Corresponding graphical argument passed on to the base plot function

- Lines:

  Corresponding graphical argument passed on to the base plot function

## Value

Nothing but an addition to the current plotting device.

## Author

Allert Bijleveld
