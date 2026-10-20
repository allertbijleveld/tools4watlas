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

## Accessing internal files

**Section only relevant for NIOZ users.** External users, please
[e-mail](mailto:allert.bijleveld@nioz.nl) Allert Bijleveld for
access\*\*

If you want to access the database, fill host, username and password

If you have local copies of relevant data folders also fill them in

``` r

# open .Renviron to edit
file.edit("~/.Renviron")

# add variables
host = "host"
username = "username"
password = "password"

# access variables (example)
Sys.getenv("variable_name")
```

``` r

# file path to WATLAS teams data folder
fp <- atl_file_path("watlas_teams")

# sub path to tide data
tidal_pattern_fp <- paste0(
  fp, "waterdata/allYears-tidalPattern-west_terschelling-UTC.csv"
)
measured_water_height_fp <- paste0(
  fp, "waterdata/allYears-gemeten_waterhoogte-west_terschelling-clean-UTC.csv"
)
```
