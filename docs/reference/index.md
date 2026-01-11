# Package index

## Load and check data

Functions to load data from SQLlite or remote SQL database

- [`atl_get_data()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_get_data.md)
  : Get data from a SQLite-database
- [`atl_summary()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_summary.md)
  : Summary of localization data
- [`atl_format_time()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_format_time.md)
  : Format time in easy readable interval
- [`atl_check_data()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_check_data.md)
  : Check data has required columns
- [`atl_full_tag_id()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_full_tag_id.md)
  : Create full tag ID or tag ID with specific length
- [`atl_file_path()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_file_path.md)
  : Get the file path for WATLAS or GIS data based on the user's name.

## Filter data

Fuctions to filter data

- [`atl_filter_covariates()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_filter_covariates.md)
  : Filter data by position covariates
- [`atl_filter_bounds()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_filter_bounds.md)
  : Filter positions by an area
- [`atl_within_polygon()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_within_polygon.md)
  : Detect position intersections with a polygon

## Track characteristics

Functions to calculate speed and turning angle

- [`atl_simple_dist()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_simple_dist.md)
  : Calculate distances between successive localizations
- [`atl_get_speed()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_get_speed.md)
  : Calculate instantaneous speed
- [`atl_turning_angle()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_turning_angle.md)
  : Get the turning angle between points

## Smooth or thin track

Functions to calculate speed and turning angle

- [`atl_median_smooth()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_median_smooth.md)
  : Apply a median smooth to coordinates
- [`atl_thin_data()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_thin_data.md)
  : Thin tracking data by resampling or aggregation

## Residency patch functions

Functions to calculate residency patches

- [`atl_res_patch()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_res_patch.md)
  : Construct residence patches from position data
- [`atl_patch_dist()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_patch_dist.md)
  : Get the distance between patches
- [`atl_res_patch_summary()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_res_patch_summary.md)
  : Summary of patch data
- [`atl_check_res_patch()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_check_res_patch.md)
  : Check the residency patches from one tag during one tide

## Spatial functions

Transform data to sf object and get a bounding box

- [`atl_as_sf()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_as_sf.md)
  : Convert a data.frame or data.table to an simple feature (sf) object
- [`atl_transform_dt()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_transform_dt.md)
  : Transform coordinates in a data.table and appends new EPSG-Suffixed
  columns
- [`atl_bbox()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_bbox.md)
  : Create a bounding box with specified aspect ratio and buffer

## Plotting functions

Functions to plot the data

- [`atl_create_bm()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_create_bm.md)
  : Create a basemap with customised bounding box using package stored
  data
- [`atl_create_bm_tiles()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_create_bm_tiles.md)
  : Create a basemap with customised bounding box using map tiles
- [`atl_check_tag()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_check_tag.md)
  : Check the data from one tag on a map
- [`atl_check_res_patch()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_check_res_patch.md)
  : Check the residency patches from one tag during one tide
- [`atl_t_col()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_t_col.md)
  : Make a colour transparent
- [`atl_spec_cols()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_spec_cols.md)
  : WATLAS species colours
- [`atl_spec_labs()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_spec_labs.md)
  : WATLAS species labels
- [`atl_tag_cols()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_tag_cols.md)
  : Assign colours to tag ID's
- [`atl_tag_labs()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_tag_labs.md)
  : Create unique labels for tags by combining specified columns

## Animation functions

Functions to animate the data

- [`atl_time_steps()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_time_steps.md)
  : Generate time steps and file names for an animation of movements
- [`atl_progress_bar()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_progress_bar.md)
  : Display a live progress bar for PNG file generation in a directory
- [`atl_alpha_along()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_alpha_along.md)
  : Creates different alpha values along a vector
- [`atl_size_along()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_size_along.md)
  : Creates different size values along a vector
- [`atl_ffmpeg_pattern()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_ffmpeg_pattern.md)
  : Generate ffmpeg filename pattern

## Add enviromental data

Functions to add tidal data and other SpatRaster data

- [`atl_add_tidal_data()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_add_tidal_data.md)
  : Add tidal data to tracking data
- [`atl_add_raster_data()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_add_raster_data.md)
  : Add raster data to tracking data

## Data

Example and map data provided with the package

- [`data_example`](https://allertbijleveld.github.io/tools4watlas/reference/data_example.md)
  : Data from two red knots and one redshank
- [`land`](https://allertbijleveld.github.io/tools4watlas/reference/land.md)
  : Land polygon around the Dutch Wadden Sea
- [`mudflats`](https://allertbijleveld.github.io/tools4watlas/reference/mudflats.md)
  : Mudflats polygons within the Dutch Wadden Sea
- [`lakes`](https://allertbijleveld.github.io/tools4watlas/reference/lakes.md)
  : Lake on Griend
