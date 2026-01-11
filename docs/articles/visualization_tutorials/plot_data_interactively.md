# Plot data interactively

This article shows different ways on how to plot WATLAS data
interactively using `mapview`. This is useful when manually checking
specific data. Check for more details the [mapview
website](https://r-spatial.github.io/mapview/index.html). Note that one
can change the base map by clicking in the layer symbol, to for example
a satellite image. Each chunk of code only requires this chunk with
loading the data to be run before and is otherwise independent.

#### Load packages

``` r
# packages
library(tools4watlas)
library(mapview)
```

## Interactive plot for one individual

Subset the individual of choice and transform it into a `sf` with the
additional columns of your choice (can be seen when clicking on the
point). Colour the track by selecting the desired parameter as `zcol`.

``` r
# load example data from one tide
data <- data_example[tideID == "2023513"]

# subset data
data_subset <- data[tag == "3063"]

# make data spatial
d_sf <- atl_as_sf(
  data_subset,
  additional_cols = c("species", "datetime", "speed_in", "nbs", "waterlevel")
)

# add track
d_sf_lines <- atl_as_sf(
  data_subset,
  additional_cols = c("species", "datetime", "speed_in", "nbs", "waterlevel"),
  option = "lines"
)

# plot interactive map
mapview(d_sf_lines, zcol = "speed_in", legend = FALSE) +
  mapview(d_sf, zcol = "speed_in")
```

## Interactive plot for multiple individuals

If one wants to plot a lot of data, it is recommended to thin the data
first.

``` r
# load example data
data <- data_example

# thin the data by subsampling with a 60-second interval
data <- atl_thin_data(
  data = data,
  interval = 60,
  id_columns = c("tag", "species"),
  method = "subsample"
)

# make data spatial
d_sf <- atl_as_sf(data, additional_cols = c("datetime", "species"))

# add track
d_sf_lines <- atl_as_sf(
  data,
  additional_cols = c("species"),
  option = "lines"
)

# plot interactive map
mapview(d_sf_lines, zcol = "tag", legend = FALSE) +
  mapview(d_sf, zcol = "tag")
```

## Interactive plot for multiple species

``` r
# load example data from one tide
data <- data_example[tideID == "2023513"]

# thin the data by subsampling with a 60-second interval
data <- atl_thin_data(
  data = data,
  interval = 60,
  id_columns = c("tag", "species"),
  method = "subsample"
)

# make data spatial
d_sf <- atl_as_sf(data, additional_cols = c("datetime", "species"))

# add track
d_sf_lines <- atl_as_sf(
  data,
  additional_cols = c("species"),
  option = "lines"
)

# plot interactive map
mapview(d_sf_lines, zcol = "species", legend = FALSE) +
  mapview(d_sf, zcol = "species")
```
