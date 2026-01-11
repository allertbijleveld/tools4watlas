# Summary of patch data

Computes summary statistics of movement data grouped by patches for each
individual tag. Calculates spatial and temporal summaries within each
patch, distances traveled inside patches, distances and time intervals
between patches, displacement within patches, and patch duration.
Additional user-specified summary variables and functions can also be
applied dynamically.

## Usage

``` r
atl_res_patch_summary(data, summary_variables = c(), summary_functions = c())
```

## Arguments

- data:

  A data.frame or data.table containing movement data. Must include
  columns: `tag` (ID), `x`, `y` (coords), `time` (timestamp), and
  `patch` (patch ID).

- summary_variables:

  Character vector of variable names in `data` for additional summaries.
  Variables should be numeric or compatible with the summary functions.

- summary_functions:

  Character vector of function names to apply to each variable in
  `summary_variables`. Functions must work on numeric vectors (e.g.,
  "mean" or "median").

## Value

A data.table with one row per `tag` and `patch` containing:

- `nfixes`: Number of fixes in the patch.

- `x_mean`, `x_median`, `x_start`, `x_end`: Summary stats of x.

- `y_mean`, `y_median`, `y_start`, `y_end`: Summary stats of y.

- `time_mean`, `time_median`, `time_start`, `time_end`: Summary stats of
  time.

- Additional summaries from `summary_variables` and `summary_functions`.

- `dist_in_patch`: Total distance (in m) travelled within the patch.

- `dist_bw_patch`: Distance (in m) between end of previous and start of
  current patch.

- `time_bw_patch`: Time (in sec) elapsed between end of previous and
  start of current patch.

- `disp_in_patch`: Straight-line (in m) displacement between start and
  end of patch.

- `duration`: Duration spent (in sec) within the patch.

## Details

Converts input data to data.table if needed and filters out rows with
missing patch assignments. All summaries are calculated by `tag` and
`patch`.Distance calculations use Euclidean distance in x-y coordinate
space.

## Author

Johannes Krietsch
