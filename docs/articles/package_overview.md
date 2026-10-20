# Package overview

Test

## Loading the data

``` r

# packages
library(tools4watlas)
library(lubridate)
library(sf)
library(ggplot2)
library(scales)
library(viridis)

# path to csv with raw data
data_path <- system.file(
  "extdata", "watlas_data_raw.csv",
  package = "tools4watlas"
)

# load data
data <- fread(data_path, yaml = TRUE)
```
