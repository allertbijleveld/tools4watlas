# Construct residence patches from position data

A cleaned movement track of one individual at a time can be classified
into residence patches using the function `atl_res_patch`. The function
expects a specific organisation of the data: there should be at least
the following columns, `x`, `y`, and `time`, corresponding to the
coordinates, and the time as `POSIXct`. `atl_res_patch` requires only
three parameters: (1) the maximum speed threshold between localizations
(called `max_speed`), (2) the distance threshold between clusters of
positions (called `lim_spat_indep`), and (3) the time interval between
clusters (called `lim_time_indep`).Clusters formed of fewer than a
minimum number of positions can be excluded.The exclusion of clusters
with few positions can help in removing bias due to short stops, but if
such short stops are also of interest, they can be included by reducing
the `min_fixes` argument.

## Usage

``` r
atl_res_patch(
  data,
  max_speed = 3,
  lim_spat_indep = 75,
  lim_time_indep = 180,
  min_fixes = 3,
  min_duration = 120
)
```

## Arguments

- data:

  A dataframe of any class that is or extends data.frame of one
  individual only. The dataframe must contain at least two spatial
  coordinates, `x` and `y`, and a temporal coordinate, `time`.

- max_speed:

  A numeric value specifying the maximum speed (m/s) between two
  coordinates that would be considered non-transitory

- lim_spat_indep:

  A numeric value of distance in metres of the spatial distance between
  two patches for them to the considered independent.

- lim_time_indep:

  A numeric value of time in minutes of the time difference between two
  patches for them to be considered independent.

- min_fixes:

  The minimum number of fixes for a group of spatially-proximate number
  of points to be considered a preliminary residence patch.

- min_duration:

  The minimum duration (in seconds) for classifying residence patches.

## Value

A data.table that has the added column `patch` indicating the patch ID.

## Author

Pratik R. Gupte, Christine E. Beardsworth & Allert I. Bijleveld &
Johannes Krietsch
