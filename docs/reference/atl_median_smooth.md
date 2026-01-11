# Apply a median smooth to coordinates

Applies a median smooth defined by a rolling window to the x and y
coordinates of the data, by tag ID

## Usage

``` r
atl_median_smooth(
  data,
  tag = "tag",
  x = "x",
  y = "y",
  time = "time",
  moving_window = 5
)
```

## Arguments

- data:

  A data.frame or data.table object returned by `atl_get_data`, which
  should contain the original columns (particularly tag, x, y, and
  time).

- tag:

  The tag ID.

- x:

  The X coordinate.

- y:

  The Y coordinate.

- time:

  The timestamp, ideally as an integer.

- moving_window:

  The size of the moving window for the median smooth. Must be an odd
  number.

## Value

A data.table class object (extends data.frame), including X,Y as
smoothed coordinates and the x_raw and y_raw, which are the raw
coordinates.

## Author

Pratik Gupte & Allert Bijleveld & Johannes Krietsch

## Examples

``` r
library(tools4watlas)
library(data.table)
library(ggplot2)

# Example dataset
# tag 1
data1 <- data.table(
  tag = rep(1, 10),
  x = c(1, 2, 5, 6, 8, 10, 12, 14, 17, 21),
  y = c(1, 7, 8, 12, 13, 20, 16, 18, 20, 21),
  time = 1:10
)

# tag 2
data2 <- data.table(
  tag = rep(2, 10),
  x = c(2, 3, 6, 7, 9, 11, 13, 15, 18, 26),
  y = c(2, 6, 7, 11, 12, 19, 15, 17, 19, 20),
  time = 1:10
)

# Combine both datasets
data <- rbind(data1, data2)
setorder(data, tag, time)

# Run the function
smoothed_data <- atl_median_smooth(data, moving_window = 5)

ggplot() +
  geom_path(
    data = smoothed_data, aes(x_raw, y_raw),
    color = "firebrick3", linewidth = 0.5
  ) +
  geom_path(
    data = smoothed_data, aes(x, y),
    color = "black", linewidth = 0.5
  ) +
  geom_point(
    data = smoothed_data, aes(x_raw, y_raw),
    color = "firebrick3", size = 1.2
  ) +
  geom_point(
    data = smoothed_data, aes(x, y),
    color = "black", size = 1
  ) +
  theme_bw() +
  facet_wrap(~tag)
```
