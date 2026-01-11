# Add tracks to plot from list

A function that is used for plotting multiple individuals on a map from
a list of spatial data.

## Usage

``` r
atl_plot_add_track(
  data,
  Pch = 19,
  Cex = 0.25,
  Lwd = 1,
  col,
  Type = "o",
  endpoint = FALSE
)
```

## Arguments

- data:

  The spatial data frame.

- Pch:

  The type of point to plot a localization

- Cex:

  The size of the point to plot a localization

- Lwd:

  The width of the line to connect localizations

- col:

  The colour of plotted localizations

- Type:

  The type of graph to make. For instance, "b" is both points and lines
  and "o" is simlar but places points on top of line (no gaps)

- endpoint:

  Whether to plot the last localization of an individual in magenta

## Author

Allert Bijleveld
