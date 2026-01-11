# Get the distance between patches

Gets the linear distance between the first point of patch `i` and the
last point of the previous patch patch `i - 1`. Distance is returned in
metres. This function is used internally by other functions, and rarely
on its own.

## Usage

``` r
atl_patch_dist(
  data,
  x1 = "x_end",
  x2 = "x_start",
  y1 = "y_end",
  y2 = "y_start"
)
```

## Arguments

- data:

  A dataframe of or extending the class data.frame, such as a
  data.table. This must contain two pairs of coordinates, the start and
  end X and Y coordinates of a feature.

- x1:

  The first X coordinate or longitude; for inter-patch distances, this
  is the last coordinate (x_end) of a patch \\i\\.

- x2:

  The second X coordinate; for inter-patch distances, this is the first
  coordinate (x_start) of a subsequent patch \\i + 1\\.

- y1:

  The first Y coordinate or latitude; for inter-patch distances, this is
  the last coordinate (y_end) of a patch \\i\\.

- y2:

  The second Y coordinate; for inter-patch distances, this is the first
  coordinate (y_start) of a subsequent patch \\i + 1\\.

## Value

A numeric vector of the length of the number of patches, or rows in the
input dataframe. For single patches, returns `NA`. The vector has as its
elements `NA`, followed by n-1 distances, where n is the number of rows.

## Author

Pratik R. Gupte

## Examples

``` r
# basic usage of atl_patch_dist
if (FALSE) { # \dontrun{
atl_patch_dist(
  data = data,
  x1 = "x_end", x2 = "x_start",
  y1 = "y_end", y2 = "y_start"
)
} # }
```
