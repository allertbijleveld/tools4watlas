library(testthat)

test_that("tools4watlas::atl_create_bm works with default parameters", {
  skip_on_cran() # Skip on CRAN to avoid external dependency issues

  bm <- tools4watlas::atl_create_bm(buffer = 5000)
  expect_s3_class(bm, "ggplot") # Check if output is a ggplot object
})

test_that("tools4watlas::atl_create_bm works with input data", {
  skip_on_cran()

  # Create sample data
  sample_data <- data.table::data.table(
    x = c(5.25, 5.26),
    y = c(53.25, 53.26)
  )

  bm <- tools4watlas::atl_create_bm(data = sample_data, buffer = 1000)
  expect_s3_class(bm, "ggplot") # Output should be a ggplot object
})


test_that("tools4watlas::atl_create_bm handles NULL data correctly", {
  skip_on_cran()

  bm <- tools4watlas::atl_create_bm(data = NULL)
  expect_s3_class(bm, "ggplot") # Default produces a ggplot object
})

test_that("tools4watlas::atl_create_bm fails with invalid input", {
  skip_on_cran()

  # Invalid data type
  expect_error(tools4watlas::atl_create_bm(data = "invalid"))

  # Missing required columns
  invalid_data <- data.table::data.table(a = 1:5, b = 1:5)
  expect_error(tools4watlas::atl_create_bm(data = invalid_data))
})
