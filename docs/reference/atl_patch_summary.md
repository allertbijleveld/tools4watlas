# Get residence patch data

The function `atl_patch_summary` can be used to extract patch-specific
summary data such as the median coordinates, the patch duration, the
distance travelled within the patch, the displacement within the patch,
and the patch area.

## Usage

``` r
atl_patch_summary(patch_data, which_data = "summary", buffer_radius = 10)
```

## Arguments

- patch_data:

  A data.frame with a nested list column of the raw data underlying each
  patch. Since data.frames don't support nested columns, will actually
  be a data.table or similar extension.

- which_data:

  Which data to return. May be the raw data underlying the patch
  (`which_data = "points"`), or a spatial features (`sf-MULTIPOLYGON`)
  object with patch covariates (`which_data = "spatial"`), or a
  data.table of the patch covariates without the geometry column
  (`which_data = "summary"`).

- buffer_radius:

  Spatial buffer radius (in metres) around points when requesting sf
  based polygons.

## Value

An object of type `sf` or `data.table` depending on which data is
requested.

## Author

Pratik R. Gupte

## Examples

``` r
if (FALSE) { # \dontrun{
patch_summary <- atl_patch_summary(
  patch_data = patches,
  which_data = "summary",
  buffer_radius = 10
)
} # }
```
