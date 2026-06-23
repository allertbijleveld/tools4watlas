# Add residence patches

In this vignette, we provide a general workflow to group WATLAS position
data into so-called ‘residence patches’. Note that the parameter
settings should be adapted for different species’ behaviour and data
quality.

## Background and parameter explanation

The
[`atl_res_patch()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_res_patch.md)
function is designed to segment and aggregate WATLAS movement data into
residence patches. The main parameter is speed (`max_speed`). With
perfect data that would be the only parameter necessary to adjust,
because the speed flying, walking or standing do not overlap. Because
WATLAS data have localization error (comparable to GPS, see [Beardsworth
et
al. 2022](https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.13913))
and gaps when birds are out of range of receivers, we need to have
additional variables for classifying these data into robust residence
patches.

The logic of the function is to first identify proto-patches
(preliminary residence patches). When subsequent positions have a speed
smaller than `max_speed`, a distance smaller than `lim_spat_indep` and a
time gap smaller than `lim_time_indep`, they are assigned to the same
proto patch. Proto-patches with fewer than `min_fixes` positions and
shorter `min_duration` are filtered out.

For each proto-patch, the median position is calculated as well as the
time between two subsequent proto-patches (time between last location
and first location of the next proto-patch). Proto patches are merged
into residence patches, if the distance between the median positions of
two subsequent proto-patches is smaller than `lim_spat_indep` and the
time between the proto-patch is less then `lim_time_indep`.

Lastly, a unique patch ID is assigned to each residence patch ordered by
time from 1 to n.

Note that without cleaning the data or having short intervals (e.g. 3
sec), position error can lead to speed outliers, which affects the
creation of proto-patches. When calculating residence patches, it is
therefore recommended to first filter (`var_max < 5000`) and smooth
(`moving_window = 5`) the data. Depending on the species’ behaviour or
quality of the data, the `max_speed` can also be set to a higher value,
or the data can be thinned first. Keep in mind that smoothing and
thinning will influence the speeds between positions, and thus the
creation of residence patches.

**Parameter overview:**

Deciding on the optimal parameters for the residence patch
classification is not a trivial task. The key is to find a good balance
between true and false positives. See section below on how we decided on
the standard parameter settings.

- **`max_speed`:** A numeric value specifying the maximum speed (m/s)
  between two subsequent positions that would be considered
  non-transitory. **3 m/s** seems to be the best compromise. Higher
  values often result in the merging of patches with clear flights in
  between and with lower values clear foraging behaviour is sometimes
  not picked up.
- **`lim_spat_indep`:** A numeric value specifying the maximum
  distance (m) between subsequent residence patches for them to be
  considered independent. In combination with `lim_time_indep`, this
  parameter avoids making a new proto-patch from gaps in the data when
  the bird was actually still at the same location. **75 m** seems to be
  the best compromise.
- **`lim_time_indep`:** A numeric value specifying the time difference
  (min) between two subsequent residence patches for them to be
  considered independent. In combination with `lim_spat_indep`, this
  parameter can prevent the creation new proto-patches when there are
  large gaps in the data. For example, at the roost site a bird might
  not move for a long time at a location with poor coverage by
  receivers. If the bird then moves away and sends data from the same
  position, we can assume that all missed positions were also at this
  place. **180 min** (3 hours) works fine for foraging, but it could be
  increased with position data that has large gaps. For example, when
  the analysis is focused on roosting behaviour, this could even be
  increased to e.g. 12 hours, to deal with large gaps in the data that
  can occur with roosting birds not moving and being at the same place
  with bad signal strength.
- **`min_fixes`:** The minimum number of positions for proto-patches. To
  make sure that residence patches have at least a few positions. **2
  positions** works best in picking up proto-patches. If the patch is
  below `min_duration` it will anyway be filtered out.
- **`min_duration`:** The minimum duration (s) for classifying residence
  patches. With a high-sampling interval (e.g. 3 s), short residence
  patches can be created, which are not biological relevant. A value of
  **60 sec** (1 minute) helps to pick-up proto-patches. Biological
  relevance depends on the focus of the analysis and residence patches
  with a shorter duration can still be filtered out afterwards.

## Load packages and required data

``` r

# packages
library(tools4watlas)
library(ggplot2)
library(viridis)
library(patchwork)
library(foreach)
library(doFuture)

# load example data
data <- data_example

# file path to WATLAS teams data folder
fp <- atl_file_path("watlas_teams")

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

## Calculate residence patches by tag

To reduce the memory size for parallel computing, we will first subset
the relevant columns from the data. This can be skipped for small data
tables. We will then run
[`atl_res_patch()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_res_patch.md)
for each tag ID in parallel. The column `patch` is added to the data
table, which provides the assigned patch ID’s for the positions.

``` r

# subset relevant columns
data <- data[, .(species, posID, tag, time, datetime, x, y, tideID)]

# extract the unique tag IDs
id <- unique(data$tag)

# register cores and backend for parallel processing
registerDoFuture()
plan(multisession)

# loop through all tags to calculate residence patches
data <- foreach(i = id, .combine = "rbind") %dofuture% {
  atl_res_patch(
    data[tag == i],
    max_speed = 3, lim_spat_indep = 75, lim_time_indep = 180,
    min_fixes = 2, min_duration = 60
  )
}

# close parallel processing
plan(sequential)

# show head of the summary table
head(data) |> knitr::kable(digits = 2)
```

| species | posID | tag | time | datetime | x | y | tideID | patch |
|:---|---:|:---|---:|:---|---:|---:|---:|:---|
| redshank | 2 | 3027 | 1695438805 | 2023-09-23 03:13:25 | 650705.6 | 5902556 | 2023513 | 1 |
| redshank | 3 | 3027 | 1695438808 | 2023-09-23 03:13:28 | 650705.6 | 5902556 | 2023513 | 1 |
| redshank | 4 | 3027 | 1695439189 | 2023-09-23 03:19:49 | 650721.0 | 5902559 | 2023513 | 1 |
| redshank | 5 | 3027 | 1695439192 | 2023-09-23 03:19:52 | 650721.1 | 5902559 | 2023513 | 1 |
| redshank | 6 | 3027 | 1695439195 | 2023-09-23 03:19:55 | 650723.1 | 5902564 | 2023513 | 1 |
| redshank | 7 | 3027 | 1695439198 | 2023-09-23 03:19:58 | 650723.1 | 5902564 | 2023513 | 1 |

## Evaluate residence patch classification and parameters

The function
[`atl_check_res_patch()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_check_res_patch.md)
can be used to evaluate the residence patch classification by tag and
tide ID. the function plots the track with residence patches on a map
and shows the duration (time in a patch in min) as coloured polygon on
the map and as plot against the time in a separate plot. Time starts on
the top and goes from high tide to high tide (solid blue lines), as well
as indicating low tide (dashed blue line). The title of the plot gives
basic information about the data and the water level for the
corresponding tide.

### Inspect one tag and tide

We can select one tag and tide to plot. Additionally, we need to specify
the offset for the tidal data we use (e.g. 30 min for West-Terschelling)
and a buffer (in m) around the residence patch data to create the
polygon. For data inspection it makes sense to set the buffer to half of
`lim_spat_indep` (maximum distance between subsequent residence patches
at which they will be considered independent), ensuring that the
polygons around residence patches correspond to the spatial distance
threshold used to merge residence patches. However, for analysis using
the residence patch polygons in a biological context, it is better to
set the buffer to appropiate scale. For example 15 m, will capture some
error in positions and potential movements in between fixes.

``` r

atl_check_res_patch(
  data[tag == "3038"],
  tide_data = tidal_pattern, tide_data_highres = measured_water_height,
  tide = "2023513", offset = 30,
  buffer_res_patches = 75 / 2
)
```

![Overview plot res patches one
tide](add_residence_patches_files/figure-html/unnamed-chunk-3-1.png)

Zoom in on specifc range of residence patches to inspect them in more
detail.

``` r

# set parameters for subsetting data
tag_id <- "3038"
tide_id <- "2023513"
from_patch <- 6
to_patch <- 11

atl_check_res_patch(
  data[
    tag == tag_id &
      datetime >= data[
        tag == tag_id & tideID == tide_id & patch == from_patch, min(datetime)
      ] &
      datetime <= data[
        tag == tag_id & tideID == tide_id & patch == to_patch, max(datetime)
      ]
  ],
  tide_data = tidal_pattern, tide_data_highres = measured_water_height,
  tide = tide_id, offset = 30,
  buffer_res_patches = 15,
  buffer_bm = 50,
  patch_label_padding = 2
)
```

![Overview plot res patches one
tide](add_residence_patches_files/figure-html/unnamed-chunk-4-1.png)

### Inspect many tags and tides

To get a general overview, we can also loop through and plot all data by
tag and tide, or for example a random sample of 100 tags and tides. The
plots are saved in any directory (e.g. `./outputs/res_patch_check/`),
which has to be created before running the code.

``` r

# create table with data combinations to plot
idc <- unique(data[, c("species", "tag", "tideID")])

# sample 100 combinations to plot
set.seed(123)
idc <- idc[sample(.N, 100)]

# register cores and backend for parallel processing
registerDoFuture()
plan(multisession)

# loop to make plots for all
foreach(i = seq_len(nrow(idc))) %dofuture% {

  # plot and save for each combination
  atl_check_res_patch(
    data[tag == idc$tag[i]],
    tide_data = tidal_pattern,
    tide_data_highres = measured_water_height,
    tide = idc$tideID[i], offset = 30,
    buffer_res_patches = 75 / 2,
    filename = paste0(
      "./outputs/res_patch_check/",
      idc$species[i], "_tag_", idc$tag[i], "_tide_", idc$tideID[i]
    )
  )

}

# close parallel processing
plan(sequential)
```

Based on these plots and perhaps additional checks, the parameters can
be adjusted to improve the classification of residence patches.

## Summary of residence patch data

Once satisfied with the residence patch classification, we can summarize
the residence patches by tag and patch ID and merge the desired columns
back to our full data table.

``` r

# summary of residence patches
data_summary <- atl_res_patch_summary(data)

# standardise duration to minutes
data_summary[, duration := duration / 60]

# merge desired summary columns with original data table
data[data_summary, on = c("tag", "patch"), `:=`(
  duration = i.duration,
  disp_in_patch = i.disp_in_patch
)]

# show head of the summary table
head(data_summary) |> knitr::kable(digits = 2)
```

| species | tag | patch | nfixes | x_mean | x_median | x_start | x_end | y_mean | y_median | y_start | y_end | time_mean | time_median | time_start | time_end | dist_start_end | dist_in_patch | dist_bw_patch | time_bw_patch | disp_in_patch | duration |
|:---|:---|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|:---|:---|:---|---:|---:|---:|---:|---:|---:|
| redshank | 3027 | 1 | 65 | 650705.6 | 650703.9 | 650705.6 | 650709.5 | 5902564 | 5902562 | 5902556 | 5902560 | 2023-09-23 03:40:31 | 2023-09-23 03:25:31 | 2023-09-23 03:13:25 | 2023-09-23 04:20:33 | 5.79 | 212.19 | NA | NA | 5.79 | 67.15 |
| redshank | 3027 | 2 | 60 | 650776.6 | 650776.6 | 650778.7 | 650771.9 | 5902216 | 5902217 | 5902216 | 5902206 | 2023-09-23 04:25:34 | 2023-09-23 04:25:32 | 2023-09-23 04:24:00 | 2023-09-23 04:27:09 | 12.29 | 51.41 | 351.03 | 206.99 | 12.29 | 3.15 |
| redshank | 3027 | 3 | 2456 | 650760.9 | 650762.0 | 650778.4 | 650699.8 | 5901722 | 5901737 | 5902014 | 5901490 | 2023-09-23 05:38:18 | 2023-09-23 05:35:44 | 2023-09-23 04:27:36 | 2023-09-23 06:51:24 | 530.22 | 1968.58 | 192.16 | 27.00 | 530.22 | 143.79 |
| redshank | 3027 | 4 | 25 | 648514.3 | 648514.8 | 648516.0 | 648514.2 | 5901441 | 5901440 | 5901453 | 5901441 | 2023-09-23 06:55:19 | 2023-09-23 06:55:21 | 2023-09-23 06:54:36 | 2023-09-23 06:55:57 | 11.98 | 37.77 | 2184.17 | 191.99 | 11.98 | 1.35 |
| redshank | 3027 | 5 | 64 | 648364.2 | 648362.5 | 648360.7 | 648365.8 | 5901596 | 5901590 | 5901578 | 5901620 | 2023-09-23 06:58:00 | 2023-09-23 06:58:01 | 2023-09-23 06:56:18 | 2023-09-23 06:59:42 | 42.01 | 79.03 | 206.04 | 21.00 | 42.01 | 3.40 |
| redshank | 3027 | 6 | 41 | 648059.6 | 648058.4 | 648059.7 | 648058.4 | 5902193 | 5902192 | 5902184 | 5902204 | 2023-09-23 07:01:48 | 2023-09-23 07:01:51 | 2023-09-23 07:00:39 | 2023-09-23 07:02:57 | 19.69 | 48.94 | 641.75 | 57.00 | 19.69 | 2.30 |

| Column | Description |
|----|----|
| **tag** | 4 digit tag ID (character), i.e. last 4 digits of the full tag number |
| **patch** | Patch ID |
| **nfixes** | Number of fixes in the patch |
| **x_mean** | Mean X-coordinate in meters (UTM 31 N) |
| **x_median** | Median X-coordinate in meters (UTM 31 N) |
| **x_start** | X-coordinate at the start of the residence patch (UTM 31 N) |
| **x_end** | X-coordinate at the end of the residence patch (UTM 31 N) |
| **y_mean** | Mean Y-coordinate in meters (UTM 31 N) |
| **y_median** | Median Y-coordinate in meters (UTM 31 N) |
| **y_start** | Y-coordinate at the start of the residence patch (UTM 31 N) |
| **y_end** | Y-coordinate at the end of the residence patch (UTM 31 N) |
| **time_mean** | Mean datetime of the positions in the residence patch |
| **time_median** | Median datetime of the positions in the residence patch |
| **time_start** | Start datetime of the patch |
| **time_end** | End datetime of the patch |
| **dist_start_end** | Distance (in meters) between first and last position |
| **dist_in_patch** | Distance (in meters) travelled within the patch (cumulative distance) |
| **dist_bw_patch** | Distance (in meters) between end of previous and start of current patch |
| **time_bw_patch** | Time (in seconds) between end of previous and start of current patch |
| **disp_in_patch** | Straight-line displacement (in meters) between start and end of the patch |
| **duration** | Time duration (in seconds) between first and last position in patch |

## Plot the residence patches

It might also be useful to plot the residence patches using `ggplot2`.

### Plot by tag

In this example, we will plot the residence patches for one red knot
(tag 3038). In the frist example, the residence patches are coloured by
patch ID. To show the full track, the transient (unassigned) positions
are plotted in grey.

``` r

# subset red knot
data_subset <- data[tag == 3038]
data_summary_subset <- data_summary[tag == 3038]

# create basemap
bm <- atl_create_bm(data_subset, buffer = 500)

# track with residence patches coloured
bm +
  geom_path(data = data_subset, aes(x, y), alpha = 0.1) +
  geom_point(
    data = data_subset, aes(x, y), color = "grey",
    show.legend = FALSE
  ) +
  geom_point(
    data = data_subset[!is.na(patch)], aes(x, y, color = as.character(patch)),
    size = 1.5, show.legend = FALSE
  )
```

![residence patches within track colored by
ID](add_residence_patches_files/figure-html/unnamed-chunk-7-1.png)

In the second example, the residence patches are plotted at their median
positions with the size and colour scaled to their duration (in
minutes).

``` r

# plot residence patches itself by duration
bm +
  geom_point(
    data = data_summary_subset,
    aes(x_median, y_median, color = duration, size = duration),
    show.legend = TRUE, alpha = 0.5
  ) +
  scale_color_viridis()
```

![residence patches by duration in
patch](add_residence_patches_files/figure-html/unnamed-chunk-8-1.png)

In the third example, we will calculate polygons around the residence
patches and plot them

``` r

# make patch character for plotting
data_subset[, patch := as.character(patch)]

# create polygons around residence patches
d_sf <- atl_as_sf(
  data_subset,
  additional_cols = "patch",
  option = "res_patches", buffer = 75 / 2
)

# geom_sf overwrites the coordinate system, so we need to set the limits again
bbox <- atl_bbox(data_subset, buffer = 500)

# plot polygons around residence patches
bm +
  # add patch polygons
  geom_sf(data = d_sf, aes(fill = patch), alpha = 0.2) +
  # add track and points
  geom_path(
    data = data_subset, aes(x, y),
    linewidth = 0.5, alpha = 0.5
  ) +
  geom_point(
    data = data_subset[is.na(patch)], aes(x, y),
    size = 0.5, alpha = 0.5, color = "grey20",
    show.legend = FALSE
  ) +
  geom_point(
    data = data_subset[!is.na(patch)], aes(x, y, color = patch),
    size = 0.5, show.legend = FALSE
  ) +
  # set extend again (overwritten by geom_sf)
  coord_sf(
    xlim = c(bbox["xmin"], bbox["xmax"]),
    ylim = c(bbox["ymin"], bbox["ymax"]), expand = FALSE
  )
```

![residence patches by duration in
patch](add_residence_patches_files/figure-html/unnamed-chunk-9-1.png)

### Plot by species

Similarly, we can plot the residence patches by species. For this, we
need to merge the species information back to the summary table for
residence patches. The residence patches are coloured by species and
scaled by duration (in minutes).

``` r

# create basemap
bm <- atl_create_bm(data, buffer = 500)

# add species
du <- unique(data, by = "tag")
data_summary <- data_summary[du, on = "tag", `:=`(species = i.species)]

# plot residence patches itself by duration and species
bm +
  geom_point(
    data = data_summary,
    aes(x_median, y_median, color = species, size = duration),
    show.legend = TRUE, alpha = 0.5
  ) +
  scale_color_manual(
    values = atl_spec_cols(),
    labels = atl_spec_labs("multiline"),
    name = ""
  )
```

![residence patches colored by
species](add_residence_patches_files/figure-html/unnamed-chunk-10-1.png)

## Choosing the best parameters

To select appropriate parameters for residence patch detection, we first
explored the data through extensive visual inspection, which informed
several parameter choices prior to systematic testing. A minimum of 2
fixes and a minimum proto-patch duration of 60 s were found to perform
best: with high fix intervals (e.g., 3 s), individual outlier positions
can prevent proto-patches from reaching the minimum duration threshold,
making a low minimum fix count essential for retaining short but valid
foraging bouts.

We then systematically tested a range of values for two key parameters:
maximum speed threshold (2, 3, 4, and 5 m/s, temporal independence: 75
m) and spatial independence distance (50, 75, and 100 m, maximum speed
threshold: 3 m/s), with all other parameters held constant (temporal
independence: 180 min, minimum fixes: 2, minimum duration: 60 s). For
each parameter combination, residence patches were computed for a subset
of 100 randomly selected tag–tide combinations per species (minimum 500
positions per combination) across eight shorebird species tracked in the
Wadden Sea in 2023. Then we did a pair-wise comparison of parameter
settings using
[`atl_compare_res_patch_summary()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_compare_res_patch_summary.md),
which highlighted all new, lost, merged and split residence patches.
From this overall summary, we picked again subset of 100 random changes
and plotted them using
[`atl_compare_res_patch_plot()`](https://allertbijleveld.github.io/tools4watlas/reference/atl_compare_res_patch_plot.md),
showing the result of each parameter setting. These resulting plots
where then scored by three observers to judge how well they fit the
underlying data.

**Example workflow to choose parameters:**

As the whole code for the procedure takes some time to compute and would
require all data as part of the repository, we simply show an example
here.

``` r

# load example data
data <- data_example

# run atl_res_patch with two different parameter sets
data_v1 <- atl_res_patch(
  data[tag == "3100"],
  max_speed = 3, lim_spat_indep = 75, lim_time_indep = 180,
  min_fixes = 2, min_duration = 60
)
data_v2 <- atl_res_patch(
  data[tag == "3100"],
  max_speed = 4, lim_spat_indep = 75, lim_time_indep = 180,
  min_fixes = 2, min_duration = 60
)

# change summary
change_summary <- atl_compare_res_patch_summary(data_v1, data_v2)
```

    ## === Patch changes summary ===
    ## Lost    (v1 patches gone in v2) : 0 
    ## Gained  (new patches in v2)     : 0 
    ## 
    ## Splits  (one v1 -> multiple v2): 0 
    ## Merges  (multiple v1 -> one v2): 1

``` r

# plot specific change
i <- 1

atl_compare_res_patch_plot(
  data_v1 = data_v1,
  data_v2 = data_v2,
  tag = change_summary$tag[i],
  change = change_summary$change[i],
  patch_v1 = change_summary$patch_v1[i],
  patch_v2 = change_summary$patch_v2[i]
)
```

![residence patches compared
parameters](add_residence_patches_files/figure-html/unnamed-chunk-11-1.png)

In this example, comparing 3 m/s and 4 m/s, the patches are wrongly
merged when using 4 m/s, so the 3 m/s (left) were rated as much better.

**Results of final rating:**

``` r

# path to csv with aggregated data
data_path <- system.file(
  "extdata", "rated_res_patch_parameters.csv",
  package = "tools4watlas"
)

# load data
data_rating <- fread(data_path, yaml = TRUE)

# sort factor
rating_levels <- c(
  "v1 much better", "v1 slightly better", "similar",
  "v2 slightly better", "v2 much better"
)
data_rating[, rating := factor(rating, levels = rating_levels)]

# plot results
make_plot <- function(data, x_lab) {
  ggplot(data, aes(x = score, y = pct, fill = rating)) +
    geom_bar(stat = "identity") +
    geom_text(
      aes(label = paste0(pct, "%")),
      position = position_stack(vjust = 0.5),
      size = 3
    ) +
    scale_fill_manual(
      values = c(
        "v1 much better"     = "#2166ac",
        "v1 slightly better" = "#92c5de",
        "similar"            = "grey50",
        "v2 slightly better" = "#f4a582",
        "v2 much better"     = "#d6604d"
      ), drop = FALSE
    ) +
    scale_y_continuous(
      expand = expansion(mult = c(0, 0.05)),
      labels = scales::label_percent(scale = 1)
    ) +
    labs(x = x_lab, y = "Percentage", fill = "Rating") +
    theme_bw(base_size = 14)
}

p1 <- make_plot(
  data_rating[param == "speed"], "Speed threshold (m/s)"
)
p2 <- make_plot(
  data_rating[param == "distance"], "Distance threshold (m)"
) + labs(y = "")

# combine plots
p1 + p2 +
  plot_layout(guides = "collect", widths = c(3, 2)) &
  theme(
    legend.position = "top",
    panel.grid      = element_blank(),
    plot.margin     = margin(0, 5.5, 5.5, 5.5)
  )
```

![residence patches
rating](add_residence_patches_files/figure-html/unnamed-chunk-12-1.png)

**Conclusion:**

Based on this we decided 3 m/s was the best setting for the maximum
speed and 75 m as distance threshold.
