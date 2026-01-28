# Generate ffmpeg filename pattern

This function generates a filename pattern for FFmpeg based on the
number of digits in the numeric part of the input file path (without the
`.png` extension).

## Usage

``` r
atl_ffmpeg_pattern(x)
```

## Arguments

- x:

  A character vector of file paths, where each path should include a
  filename with a `.png` extension.

## Value

A character string representing the FFmpeg-compatible filename pattern
(e.g., "%03d.png" for filenames like "001.png").

## Examples

``` r
atl_ffmpeg_pattern("path/to/file/001.png")
#> [1] "%03d.png"
# Returns: "%03d.png"
```
