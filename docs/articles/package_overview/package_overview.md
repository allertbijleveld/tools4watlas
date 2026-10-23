# Package overview

This article should give an overview of the existing articles
(tutorials) described on the package website, compare what has changed
in the basic workflow from `atlastools`, describe the sources of
external data used and how to setup the working environment for internal
WATLAS users.

## Articles overview

The articles of the package are grouped by purpose. The **basic
workflow** covers the steps most users need to go from raw WATLAS data
to clean tracks, and the **extended workflow** covers more specialised
analyses. The **visualization tutorials** show how to plot and animate
movement data. The **package development** articles explain how to
contribute to `tools4watlas` and how to adapt it, for example by
creating your own basemaps.

Parts of the articles marked with an asterisk (\*) require bathymetry
data. These data are too large to include in `tools4watlas`, so those
parts do not run without access to them. For tidal data, the package
only includes an example dataset. See access to data sections below for
how to get the complete data.

\

**Basic workflow (Vignettes)**:

- [**Load and check
  data**](https://allertbijleveld.github.io/tools4watlas/articles/load_and_check_data.html)

- [**Filter
  data**](https://allertbijleveld.github.io/tools4watlas/articles/filter_data.html) -
  based on spatial boundaries, temporal specifications, error estimates
  and speed.

- [**Smooth and thin
  data**](https://allertbijleveld.github.io/tools4watlas/articles/smooth_and_thin_data.html)

**Extended workflow**:

- [**Add tidal and bathymetry
  data**](https://allertbijleveld.github.io/tools4watlas/articles/extended_workflow/add_tidal_and_bathymetry_data.html) -
  (\*add bathymetry data)

- [**Add residence
  patches**](https://allertbijleveld.github.io/tools4watlas/articles/extended_workflow/add_residence_patches.html)

- [**Interpolate
  data**](https://allertbijleveld.github.io/tools4watlas/articles/extended_workflow/interpolate_data.html)

- [**Add sun and moon
  data**](https://allertbijleveld.github.io/tools4watlas/articles/extended_workflow/add_sun_and_moon_data.html)

**Visualization tutorials**:

- [**Create a
  basemap**](https://allertbijleveld.github.io/tools4watlas/articles/visualization_tutorials/create_basemap.html) -
  (\*Bathymetry basemap option)

- [**Plot
  data**](https://allertbijleveld.github.io/tools4watlas/articles/visualization_tutorials/plot_data.html) -
  an important step between all stages to check the data.

- [**Plot data in
  loop**](https://allertbijleveld.github.io/tools4watlas/articles/visualization_tutorials/plot_data_in_loop.html) -
  quick way to make plots by tag ID.

- [**Plot data
  faster**](https://allertbijleveld.github.io/tools4watlas/articles/visualization_tutorials/plot_data_faster.html)

- [**Plot data
  interactively**](https://allertbijleveld.github.io/tools4watlas/articles/visualization_tutorials/plot_data_interactively.html)

- [**Animate
  data**](https://allertbijleveld.github.io/tools4watlas/articles/visualization_tutorials/animate_data.html) -
  (\*Animation with dynamic water data)

**Package development**:

- [**Contributing to
  tools4watlas**](https://allertbijleveld.github.io/tools4watlas/articles/package_development/contributing_to_tools4watlas.html) -
  describes how to work on `tools4watlas`.

- [**Extract basemap
  data**](https://allertbijleveld.github.io/tools4watlas/articles/package_development/extract_basemap_data.html) -
  describes how the basemap data were extracted and can guide the user
  in creating customized base maps.

- [**tools4watlas
  logo**](https://allertbijleveld.github.io/tools4watlas/articles/package_development/package_logo.html) -
  describes how the `tools4watlas` logo is made.

## Differences from `atlastools`

`tools4watlas` builds on
[`atlastools`](https://github.com/pratikunterwegs/atlastools) ([Gupte et
al. 2021. A Guide to Pre-processing High-throughput Animal Tracking
Data](https://doi.org/10.1111/1365-2656.13610)) and incorporates basic
data processing functions from it.

The main change is the data structure of the workflow: all functions now
work on a single
[`data.table`](https://rdatatable.gitlab.io/data.table/) and group by
tag ID internally, while `atlastools` works on lists of data, with one
element per individual. This list approach means that all functions have
to be run with [`lapply()`](https://rdrr.io/r/base/lapply.html), which
makes the code harder to read and working with the data more complicated
in general. For example, to plot the data with `ggplot2` in between, the
data need to be combined or individuals added in loops to the plot.
Switching back and forth between lists and a full table also copies the
data in memory, which removes the benefit of `data.table`, which can
modify data in place. This matters, because one season of WATLAS data
can already be as big as 10 GB.

### Comparison of basic workflow of `tools4watlas` and `atlastools`

The comparison covers three steps of the basic workflow: calculating
speed, smoothing, and thinning the data.

First we load packages and raw example data.

``` r

# packages
library(tools4watlas)
library(data.table)

# path to csv with raw data
data_path <- system.file(
  "extdata", "watlas_data_raw.csv",
  package = "tools4watlas"
)

# load data
data <- fread(data_path, yaml = TRUE)
```

### `tools4watlas`

The full `data.table` is used by the function group by tag ID.

``` r

# calculate speed
data <- atl_get_speed(data, type = c("in", "out"))

# smooth the data
data <- atl_median_smooth(data, moving_window = 5)

# thin data
data_thinned <- atl_thin_data(
  data,  interval = 60, id_columns = c("tag", "species"), method = "aggregate"
)
```

### `atlastools`

Example workflow with `atlastools`. The `data.table` must first be split
by tag ID, and every function is then run on each element with
[`lapply()`](https://rdrr.io/r/base/lapply.html). The split creates a
full copy of the data, so the data are held in memory twice.

``` r

# split data by tag ID
data_split <- split(data, by = "tag")

# calculate speed
lapply(data_split, function(dt) {
  dt[, `:=`(
    speed_in  = atlastools::atl_get_speed(dt, time = "time", type = "in"),
    speed_out = atlastools::atl_get_speed(dt, time = "time", type = "out")
  )]
})

# smooth data
lapply(
  X = data_split,
  FUN = atlastools::atl_median_smooth,
  x = "x",
  y = "y",
  time = "time",
  moving_window = 5
)

# thin data
data_thinned <- lapply(
  X = data_split,
  FUN = atlastools::atl_thin_data,
  interval = 60,
  time = "time",
  id_columns = c("tag", "species"),
  method = "aggregate"
)
```

### Benchmark both basic workflows

I simply wrapped both workflows as shown above and used `mark` from the
`bench` package to compare them. The code is not shown again, but can be
seen on
[GitHub](https://github.com/allertbijleveld/tools4watlas/blob/master/vignettes/package_overview/package_overview.Rmd)

``` r

# benchmark
result <- bench::mark(
  tools4watlas = workflow_tools4watlas(data),
  atlastools   = workflow_atlastools(data),
  iterations = 5,
  check = FALSE,
  filter_gc = FALSE
)

# print results
result[, c("expression", "min", "median", "mem_alloc", "n_gc")] |>
  knitr::kable(digits = 2)
```

| expression   |    min |  median | mem_alloc | n_gc |
|:-------------|-------:|--------:|----------:|-----:|
| tools4watlas | 47.4ms |  58.9ms |      60MB |   13 |
| atlastools   |  472ms | 481.1ms |    58.9MB |   34 |

The workflow of `tools4watlas` is around **10x faster** using this small
example. When we run the same comparison for a larger data set of 300
individuals and ~3 GB (not shown), the speed is even **25x times**
faster.

### Comparison of residence patch analysis of `tools4watlas` and `atlastools`

The residence patch function was modified in `tools4watlas`. It now
returns the original table with a `patch` column instead of a summary
with nested data, and patch summaries are created separately with
[`atl_res_patch_summary()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_res_patch_summary.md).
Proto-patches are built with a speed threshold (`max_speed`) in addition
to distance and time thresholds, which replaces the buffer radius, and
they are merged when either their median positions or their end and
start positions are close. The function also fills gaps within patches,
splits patches at flights, removes single outliers, and can filter
patches by minimum duration (`min_duration`) as well as by number of
fixes.

Residence patches are too complex to calculate for all tags at once, so
this step still has to be done per tag ID. In `tools4watlas`, we use
`foreach`, which makes it easy to switch to parallel processing with
`doFuture` (see [Add residence
patches](https://allertbijleveld.github.io/tools4watlas/articles/extended_workflow/add_residence_patches.html)).

### `tools4watlas`

``` r

# packages
library(foreach)

# tag IDs to loop through
id <- unique(data$tag)

# loop through all tags to calculate residence patches
data <- foreach(i = id, .combine = "rbind") %do% {
  atl_res_patch(
    data[tag == i],
    max_speed = 3, lim_spat_indep = 75, lim_time_indep = 180,
    min_fixes = 2, min_duration = 60
  )
}

# patch summaries are created separately
data_summary <- atl_res_patch_summary(data)
```

### `atlastools`

``` r

# atlastools::atl_res_patch() requires an "id" column
lapply(data_split, function(dt) dt[, id := tag])

# calculate residence patches per tag ID
patches <- lapply(
  X = data_split,
  FUN = atlastools::atl_res_patch,
  buffer_radius = 10,
  lim_spat_indep = 100,
  lim_time_indep = 30,
  min_fixes = 3,
  summary_variables = c("speed_in"),
  summary_functions = c("mean", "sd")
)
```

As a result the get a summary table with all patch data nested in one
column.

``` r

# one row per patch, localisations nested in `patchdata`
patches <- rbindlist(patches)

# to get the localisations with patch ID again, the data must be unnested
data_patches <- patches[,
  unlist(patchdata, recursive = FALSE),
  by = .(id, patch)
]

# add the patch ID to the original table
data[data_patches, on = .(tag, time), patch := i.patch]
```

### Benchmark both residence patch workflows

I simply wrapped both residence patch workflows as shown above and used
`mark` from the `bench` package to compare them. The code is not shown
again, but can be seen on
[GitHub](https://github.com/allertbijleveld/tools4watlas/blob/master/vignettes/package_overview/package_overview.Rmd)

``` r

# benchmark
result <- bench::mark(
  tools4watlas = workflow_tools4watlas(data),
  atlastools   = workflow_atlastools(data),
  iterations = 5,
  check = FALSE,
  filter_gc = FALSE
)

# print results
result[, c("expression", "min", "median", "mem_alloc", "n_gc")] |>
  knitr::kable(digits = 2)
```

| expression   |   min | median | mem_alloc | n_gc |
|:-------------|------:|-------:|----------:|-----:|
| tools4watlas | 1.46s |  1.57s |     323MB |   23 |
| atlastools   | 8.94s |  9.13s |     893MB |   37 |

The workflow of `tools4watlas` is around **5x faster** using this small
example. When we run the same comparison for a larger data set of 10
random tags (not shown), it remains 5 times faster, but also allocates
**70% less memory**. When we use `%dofuture%`, it runs **17x faster**.

## Data access for external users

- **Tidal data:** Are downloaded from
  [Rijkswaterstaat](https://waterinfo.rws.nl/) for each tidal station
  and pre-processed to assign tide ID, high tide and low tide. Please
  contact [Allert Bijleveld](mailto:allert.bijleveld@nioz.nl) for
  access.
- **Bathymetry data:** The data can be downloaded from the
  [Waddenregister](https://datahuiswadden.openearth.nl/geonetwork/srv/eng/catalog.search#/metadata/JkrvJXasRSGAWU1mJLHUzg),
  to link them directly, they need to be opened with
  [`terra`](https://rspatial.github.io/terra/index.html) and the
  projection needs to be changed to UTM31 (EPSG:32631). To get processed
  ready to use data contact [Allert
  Bijleveld](mailto:allert.bijleveld@nioz.nl)

## Data access and setup for internal WATLAS data users

**Section only relevant for users with access to the local NIOZ
network.**

To work safely with database credentials and internal file paths, store
them as environment variables in R. This way, scripts can be shared on
GitHub without publishing credentials or personal paths. To add the
variables, open your `.Renviron` file with
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html),
add one line per variable, save the file, and restart R. The all scripts
should then run without further changes if all paths are correct.

The following variables are used:

- **Host, username and password** are required to access the remote SQL
  database. Contact [Allert Bijleveld](mailto:allert.bijleveld@nioz.nl)
  for access.
- **watlas_teams**: path to the “WATLAS” SharePoint folder
  `Documents/data/`. It contains files that are updated often, such as
  `tags_watlas_all.xlsx` and the tide data. We recommend adding a
  shortcut to this folder in your OneDrive, so that changes are
  synchronised automatically, and pointing the variable to this copy.
- **rasters**: path to the “Birds, fish ’n chips” SharePoint folder
  `Documents/data/GIS/rasters/`.
- **shapefiles**: path to the “Birds, fish ’n chips” SharePoint folder
  `Documents/data/GIS/shapefiles/`. These GIS folders contain many large
  files that rarely change. We recommend copying only the data you need
  to a local folder and pointing the variables to that folder, instead
  of creating a OneDrive shortcut.
- **sqlite_db**: path to the folder with the `SQLite` localization
  databases.

To build the package website (see [Contributing to
tools4watlas](https://allertbijleveld.github.io/tools4watlas/articles/package_development/contributing_to_tools4watlas.html))
with all articles, all variables must be set.

### Here a code template to fill the `.Renviron`:

``` r

# open .Renviron to edit
usethis::edit_r_environ()

# add variables
host = "host"
username = "username"
password = "password"
watlas_teams = "file_path"
rasters = "file_path"
shapefiles = "file_path"
sqlite_db = "file_path"

# access variables (example)
Sys.getenv("variable_name")
```

### Here templates to access the data (to replace in articles that use example data):

**Metadata `tags_watlas_all.xlsx`:**

``` r

# file path to WATLAS teams data folder
fp <- Sys.getenv("watlas_teams")

# load meta data
all_tags <- readxl::read_excel(
  paste0(fp, "tags/tags_watlas_all.xlsx"),
  sheet = "tags_watlas_all"
) |>
  data.table()
```

**Tidal data:**

``` r

# file path to WATLAS teams data folder
fp <- Sys.getenv("watlas_teams")

# sub path to tide data
tidal_pattern_fp <- paste0(
  fp, "waterdata/allYears-tidalPattern-west_terschelling-UTC.csv"
)
measured_water_height_fp <- paste0(
  fp, "waterdata/allYears-gemeten_waterhoogte-west_terschelling-clean-UTC.csv"
)

# load tide data
tidal_pattern <- fread(tidal_pattern_fp)
measured_water_height <- fread(measured_water_height_fp)
```

**Bathymetry data:**

``` r

# file path to Birds, fish 'n chips GIS/rasters folder
fp <- Sys.getenv("rasters")

# load bathymetry data
bat <- rast(paste0(fp, "bathymetry/2024/bodemhoogte_20mtr_UTM31_int.tif"))
```
