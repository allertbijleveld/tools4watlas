# Check the residency patches from one tag during one tide

Generates a `ggplot2` showing bird residency patches per tideID,
including movement paths, patch durations, and an inset overview map.

## Usage

``` r
atl_check_res_patch(
  data,
  tide_data,
  tide_data_highres,
  tide,
  offset = 0,
  buffer_res_patches,
  buffer_bm = 250,
  buffer_overview = 10000,
  point_size = 1,
  point_alpha = 0.5,
  path_linewidth = 0.5,
  path_alpha = 0.2,
  patch_label_size = 4,
  patch_label_padding = 1,
  element_text_size = 11,
  water_fill = "#D7E7FF",
  water_colour = "grey80",
  land_fill = "#faf5ef",
  land_colour = "grey80",
  mudflat_colour = "#faf5ef",
  mudflat_fill = "#faf5ef",
  mudflat_alpha = 0.6,
  filename = NULL,
  png_width = 3840,
  png_height = 2160
)
```

## Arguments

- data:

  A `data.table` containing tracking data of one tag. Must include the
  columns: `tag`, `x`, `y`, `time`,`datetime`, and `species` and
  `patch`, as created by
  [`atl_res_patch()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_res_patch.md).

- tide_data:

  Data on the timing (in UTC) of low and high tides.

- tide_data_highres:

  Data on the timing (in UTC) of the waterlevel in small intervals (e.g.
  every 10 min) as provided from Rijkwaterstaat.

- tide:

  Tide ID to subset.

- offset:

  The offset in minutes between the location of the tidal gauge and the
  tracking area. This value will be added to the timing of the water
  data.

- buffer_res_patches:

  A numeric value (in meters) specifying the buffer around the polygon
  of each residency patch, which should be half of `lim_spat_indep` of
  the residency patch calculation. If not the function can create
  MULTIPOLGONS for single residency patches. That will give a warning
  message, but works if desired.

- buffer_bm:

  Map buffer size (default: 250).

- buffer_overview:

  Overview map buffer size (default: 10000).

- point_size:

  Size of plotted points (default: 1).

- point_alpha:

  Transparency of points (default: 0.5).

- path_linewidth:

  Line width of movement paths (default: 0.5).

- path_alpha:

  Transparency of movement paths (default: 0.2).

- patch_label_size:

  Font size for patch labels (default: 4).

- patch_label_padding:

  Padding for patch labels (default: 1).

- element_text_size:

  Font size for axis and legend text (default: 11).

- water_fill:

  Water fill (default "#D7E7FF")

- water_colour:

  Water coulour (default "grey80")

- land_fill:

  Land fill (default "#faf5ef")

- land_colour:

  Land colour (default "grey80")

- mudflat_colour:

  Mudflat colour (default "#faf5ef")

- mudflat_fill:

  Mudflat fill (default "#faf5ef")

- mudflat_alpha:

  Mudflat alpha (default 0.6)

- filename:

  Character (or NULL). If provided, the plot is saved as a `.png` file
  to this path and with this name; otherwise, the function returns the
  plot.

- png_width:

  Width of saved PNG (default: 3840).

- png_height:

  Height of saved PNG (default: 2160).

## Value

A ggplot object or a saved PNG file.

## Author

Johannes Krietsch
