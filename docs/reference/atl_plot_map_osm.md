# Plot a map downloaded with OpenStreetMap

A function that is used in e.g. plotting multiple individuals.

## Usage

``` r
atl_plot_map_osm(map, ppi = 96)
```

## Arguments

- map:

  The map loaded with
  [`OpenStreetMap::openmap()`](https://rdrr.io/pkg/OpenStreetMap/man/openmap.html).

- ppi:

  The pixels per inch, which is used to calculate the dimensions of the
  plotting region from `mapID`. Deafults to 96.

## Value

Returns an OSM background plot for adding tracks.

## Author

Allert Bijleveld
