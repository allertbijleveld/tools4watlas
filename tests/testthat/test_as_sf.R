testthat::test_that("atl_as_sf handles valid data and columns", {
  # Create test data
  data <- data.table::data.table(
    tag = c("1111", "1111", "2222", "2222"),
    x = c(1, 2, 3, 4),
    y = c(5, 6, 7, 8),
    value = c(9, 10, 11, 12),
    category = c("A", "B", "C", "D")
  )

  # Convert to sf with x and y columns
  d_sf <- tools4watlas::atl_as_sf(data, "tag", "x", "y",
    additional_cols = c("value", "category")
  )

  # Check if the result is an sf object
  testthat::expect_s3_class(d_sf, "sf")

  # Check that the output has the expected number of columns
  testthat::expect_equal(ncol(d_sf), 4) # geometry, value, category

  # Check that geometry is correctly set
  testthat::expect_true("geometry" %in% names(d_sf))

  # Check if the values in 'value' and 'category' are retained
  testthat::expect_equal(d_sf$value, c(9, 10, 11, 12))
  testthat::expect_equal(d_sf$category, c("A", "B", "C", "D"))
})

testthat::test_that("atl_as_sf handles option lines", {
  # Create test data
  data <- data.table::data.table(
    tag = c("1111", "1111", "2222", "2222"),
    x = c(1, 2, 3, 4),
    y = c(5, 6, 7, 8),
    value = c(9, 10, 11, 12),
    category = c("A", "B", "C", "D")
  )

  # Convert to sf with x and y columns
  d_sf <- tools4watlas::atl_as_sf(data, "tag", "x", "y",
    additional_cols = c("value", "category"),
    option = "lines"
  )

  # Check if the result is an sf object
  testthat::expect_s3_class(d_sf, "sf")

  # Check that the output has the expected number of columns
  testthat::expect_equal(ncol(d_sf), 4) # tag, geometry, value, category

  # Check that geometry is correctly set
  testthat::expect_true("geometry" %in% names(d_sf))
})

testthat::test_that("atl_as_sf handles option data.table", {
  # Create test data
  data <- data.table::data.table(
    tag = c("1111", "1111", "2222", "2222"),
    x = c(1, 2, 3, 4),
    y = c(5, 6, 7, 8),
    value = c(9, 10, 11, 12),
    category = c("A", "B", "C", "D")
  )

  # Convert to sf with x and y columns
  d_sf <- tools4watlas::atl_as_sf(data, "tag", "x", "y",
    additional_cols = c("value", "category"),
    option = "table"
  )

  # Check if the result is an sf object
  testthat::expect_true(is.data.table(d_sf))

  # Check that the output has the expected number of columns
  testthat::expect_equal(ncol(d_sf), 4) # geometry, value, category

  # Check that geometry is correctly set
  testthat::expect_true("geometry" %in% names(d_sf))

  # Check if the values in 'value' and 'category' are retained
  testthat::expect_equal(d_sf$value, c(9, 10, 11, 12))
  testthat::expect_equal(d_sf$category, c("A", "B", "C", "D"))
})

testthat::test_that("atl_as_sf handles missing columns for x and y", {
  # Create test data with no 'x' or 'y'
  data <- data.table::data.table(
    tag = c("1111", "1111", "2222", "2222"),
    lon = c(1, 2, 3, 4),
    lat = c(5, 6, 7, 8)
  )

  # Expect error when the 'x' and 'y' columns are not present in the data
  testthat::expect_error(
    tools4watlas::atl_as_sf(data, "x", "y"),
    "Specified x or y columns do not exist in the data."
  )
})

testthat::test_that("atl_as_sf handles missing additional columns", {
  # Create test data
  data <- data.table::data.table(
    tag = c("1111", "1111", "2222", "2222"),
    x = c(1, 2, 3, 4),
    y = c(5, 6, 7, 8),
    value = c(9, 10, 11, 12)
  )

  # Try to convert to sf with additional columns that don't exist
  testthat::expect_error(
    tools4watlas::atl_as_sf(data, "tag", "x", "y",
      additional_cols = c("nonexistent_col")
    ),
    "The following additional columns are missing in the data: nonexistent_col"
  )
})

testthat::test_that("atl_as_sf excludes rows with NA values in x or y", {
  # Create test data with NAs in x and y
  data <- data.table::data.table(
    tag = c("1111", "1111", "2222", "2222"),
    x = c(1, 2, NA, 4),
    y = c(5, 6, 7, NA),
    value = c(9, 10, 11, 12)
  )

  # Convert to sf and check that rows with NA in x or y are excluded
  d_sf <- tools4watlas::atl_as_sf(data, "tag", "x", "y",
    additional_cols = "value"
  )

  # Check that the resulting sf object has no NA values
  testthat::expect_equal(nrow(d_sf), 2) # Only two rows should remain

  # Check that the excluded rows (with NA values) are not present in the output
  testthat::expect_false(any(is.na(d_sf$x) | is.na(d_sf$y)))
})

testthat::test_that("atl_as_sf works with custom projections", {
  # Create test data
  data <- data.table::data.table(
    tag = c("1111", "1111", "2222", "2222"),
    x = c(1, 2, 3, 4),
    y = c(5, 6, 7, 8),
    value = c(9, 10, 11, 12)
  )

  # Convert to sf with custom projection (WGS 84)
  custom_crs <- sf::st_crs(4326)
  d_sf <- tools4watlas::atl_as_sf(data, "tag", "x", "y",
    projection = custom_crs,
    additional_cols = "value"
  )

  # Check that the projection is correctly set
  testthat::expect_equal(sf::st_crs(d_sf)$epsg, 4326)
})

testthat::test_that("atl_as_sf handles missing additional columns gracefully", {
  # Create test data
  data <- data.frame(
    tag = c("1111", "1111", "2222", "2222"),
    x = c(1, 2, 3, 4),
    y = c(5, 6, 7, 8),
    value = c(9, 10, 11, 12),
    category = c("A", "B", "C", "D")
  )

  # Convert to sf without additional columns
  d_sf <- tools4watlas::atl_as_sf(data, "tag", "x", "y")

  # Check if only x, y, and geometry are present (no additional columns)
  testthat::expect_equal(names(d_sf), c("tag", "geometry"))
})


test_that("atl_as_sf triggers warning for MULTIPOLYGON in res_patches", {
  # Create example data with multiple points per patch that will generate MULTIPOLYGON
  test_data <- data.table(
    tag = rep("A", 4),
    x = c(0, 0.1, 5, 5.1),
    y = c(0, 0.1, 5, 5.1),
    patch = c(1, 1, 1, 1)
  )
  
  # Expect warning when converting to res_patches with small buffer
  expect_warning(
    sf_result <- atl_as_sf(
      data = test_data,
      x = "x",
      y = "y",
      tag = "tag",
      option = "res_patches",
      buffer = 0.05
    ),
    "Some of the residency patch are split in MULTIPOLYGON geometries"
  )
  
  # Check that the output is an sf object
  expect_s3_class(sf_result, "sf")
  # Check that geometry is MULTIPOLYGON
  expect_true(any(sf::st_geometry_type(sf_result) == "MULTIPOLYGON"))
})


test_that("atl_as_sf stops if tag column does not exist", {
  df <- data.table(x = 1:3, y = 4:6)
  
  # tag column "tag" is missing
  expect_error(
    atl_as_sf(df, tag = "tag", x = "x", y = "y"),
    "Specified tag column do not exist in the data."
  )
})

test_that("atl_as_sf stops if 'patch' column missing for res_patches", {
  df <- data.table(tag = 1:3, x = 1:3, y = 4:6)
  
  # missing 'patch' column
  expect_error(
    atl_as_sf(df, tag = "tag", x = "x", y = "y", option = "res_patches", buffer = 1),
    "Option 'res_patches' requires a 'patch' column in the data."
  )
})

test_that("atl_as_sf stops if buffer missing for res_patches", {
  df <- data.table(tag = 1:3, x = 1:3, y = 4:6, patch = 1:3)
  
  # buffer not supplied
  expect_error(
    atl_as_sf(df, tag = "tag", x = "x", y = "y", option = "res_patches"),
    "Option 'res_patches' requires a specified 'buffer' value."
  )
})

