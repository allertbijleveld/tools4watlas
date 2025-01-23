testthat::test_that("tools4watlas::atl_create_bm works with defaults", {
  bm <- tools4watlas::atl_create_bm(buffer = 5000)
  testthat::expect_s3_class(bm, "ggplot") # Check if output is a ggplot object
})

testthat::test_that("tools4watlas::atl_create_bm works with input data", {
  # Create sample data
  sample_data <- data.table::data.table(
    x = c(5.25, 5.26),
    y = c(53.25, 53.26)
  )

  bm <- tools4watlas::atl_create_bm(data = sample_data, buffer = 1000)
  testthat::expect_s3_class(bm, "ggplot") # Output should be a ggplot object
})


testthat::test_that("tools4watlas::atl_create_bm handles NULL data correctly", {
  bm <- tools4watlas::atl_create_bm(data = NULL)
  testthat::expect_s3_class(bm, "ggplot") # Default produces a ggplot object
})

testthat::test_that("tools4watlas::atl_create_bm fails with invalid input", {
  # Invalid data type
  testthat::expect_error(tools4watlas::atl_create_bm(data = "invalid"))
})
