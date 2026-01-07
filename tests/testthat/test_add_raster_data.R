library(testthat)
library(data.table)
library(terra)
library(sf)

# Create sample data
data <- data.table(x = c(1, 2, 3), y = c(4, 5, 6))
raster_matrix <- matrix(1:9, nrow = 3, ncol = 3)
example_raster <- rast(raster_matrix)
terra::crs(example_raster) <- "EPSG:32631"

# Test valid raster extraction
test_that("atl_add_raster_data extracts raster values correctly", {
  skip_on_os("mac")
  result <- atl_add_raster_data(data, raster_data = example_raster)
  expect_s3_class(result, "data.table")
  expect_true("lyr.1" %in% names(result))
})

# Test missing coordinate columns
test_that("atl_add_raster_data handles missing coordinates", {
  skip_on_os("mac")
  data_invalid <- data.table(a = c(1, 2, 3), b = c(4, 5, 6))
  expect_error(
    atl_add_raster_data(data_invalid, raster_data = example_raster),
    "Specified x or y columns do not exist in the data."
  )
})

# Test invalid raster input
test_that("atl_add_raster_data checks raster input type", {
  skip_on_os("mac")
  expect_error(
    atl_add_raster_data(data, raster_data = "not_a_raster"),
    "Specified raster_data are not terra SpatRaster, but should be."
  )
})
