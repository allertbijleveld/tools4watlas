# library(testthat)
# library(tools4watlas)
library(ggplot2)

test_that("atl_check_res_patch() works with example data files", {
  skip_if_not_installed("tools4watlas")
  
  # Load example tracking data
  data <- data_example[
    tag == "3038",
    .(species, posID, tag, time, datetime, x, y, tideID)
  ]
  
  # Compute residency patches
  data <- atl_res_patch(
    data,
    max_speed = 3,
    lim_spat_indep = 75,
    lim_time_indep = 180,
    min_fixes = 3,
    min_duration = 120
  )
  
  # Locate example tide data files
  fp <- system.file("extdata", package = "tools4watlas")
  
  tidal_pattern_fp <- paste0(
    fp, "/example-tidalPattern-west_terschelling-UTC.csv"
  )
  measured_water_height_fp <- paste0(
    fp, "/example-gemeten_waterhoogte-west_terschelling-clean-UTC.csv"
  )
  
  # Read tide data
  tide_data <- data.table::fread(tidal_pattern_fp)
  tide_data_highres <- data.table::fread(measured_water_height_fp)
  
  # Pick one tide ID to plot
  tide_id <- unique(data$tideID)[1]
  
  # Run the function
  result <- atl_check_res_patch(
    data = data,
    tide_data = tide_data,
    tide_data_highres = tide_data_highres,
    tide = tide_id,
    buffer_res_patches = 30,
    filename = NULL
  )
  
  # Check output type
  expect_s3_class(result, "ggplot")
  
})

test_that("atl_check_res_patch() errors without buffer_res_patches", {
  skip_if_not_installed("tools4watlas")
  
  data <- data_example[
    tag == "3038",
    .(species, posID, tag, time, datetime, x, y, tideID)
  ]
  
  data <- atl_res_patch(
    data,
    max_speed = 3,
    lim_spat_indep = 75,
    lim_time_indep = 180,
    min_fixes = 3,
    min_duration = 120
  )
  
  fp <- system.file("extdata", package = "tools4watlas")
  
  tidal_pattern_fp <- paste0(
    fp, "/example-tidalPattern-west_terschelling-UTC.csv"
  )
  measured_water_height_fp <- paste0(
    fp, "/example-gemeten_waterhoogte-west_terschelling-clean-UTC.csv"
  )
  
  tide_data <- data.table::fread(tidal_pattern_fp)
  tide_data_highres <- data.table::fread(measured_water_height_fp)
  
  expect_error(
    atl_check_res_patch(
      data = data,
      tide_data = tide_data,
      tide_data_highres = tide_data_highres,
      tide = unique(data$tideID)[1]
    ),
    "buffer_res_patches"
  )
})
