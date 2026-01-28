# Calculate distances between successive localizations

Gets the euclidean distance between consecutive localization in a
coordinate reference system in metres, i.e., UTM systems.

## Usage

``` r
atl_simple_dist(data, x = "x", y = "y", lag = 1)
```

## Arguments

- data:

  A dataframe object of or extending the class data.frame, which must
  contain two coordinate columns for the X and Y coordinates.

- x:

  A column name in a data.frame object that contains the numeric X
  coordinate.

- y:

  A column name in a data.frame object that contains the numeric Y
  coordinate.

- lag:

  The lag (in number of localizations) over which to calculate distance

## Value

Returns a vector of distances between consecutive points.

## Author

Pratik R. Gupte & Allert Bijleveld
