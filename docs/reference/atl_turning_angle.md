# Get the turning angle between points

Gets the relative heading between two track segments (three
localizations) using the law of cosines. The turning angle is returned
in degrees. Adds the column `angle` to a data.table with tracking data.
Note that with smoothed data NaN values may occur (when subsequent
localizations are at the same place).

## Usage

``` r
atl_turning_angle(data, tag = "tag", x = "x", y = "y", time = "time")
```

## Arguments

- data:

  A dataframe or similar which must have the columns specified by `x`,
  `y`, and `time`.

- tag:

  The tag ID.

- x:

  The x coordinate.

- y:

  The y coordinate.

- time:

  The timestamp in seconds since the UNIX epoch.

## Value

A a data.table with added turning angles in degrees. Negative degrees
indicate 'left' turns. There are two fewer angles than the number of
rows in the dataframe.

## Author

Pratik R. Gupte & Allert Bijleveld & Johannes Krietsch

## Examples

``` r
if (FALSE) { # \dontrun{
data <- atl_turning_angle(
  data,
  tag = "tag", x = "x", y = "y", time = "time"
)
} # }
```
