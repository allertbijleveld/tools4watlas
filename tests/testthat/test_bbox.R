
# Test that the function works with a simple polygon geometry
testthat::test_that("atl_bbox handles simple geometry", {
  geom <- sf::st_as_sfc("POLYGON((0 0, 1 0, 1 2, 0 2, 0 0))")
  bbox <- tools4watlas::atl_bbox(geom, asp = "16:9")
  # Ensure the bbox has 4 elements (xmin, ymin, xmax, ymax)
  testthat::expect_equal(length(bbox), 4)  
  # Check names
  testthat::expect_true(all(names(bbox) %in% c("xmin", "ymin", "xmax", "ymax")))  
})

# Test buffer functionality (expanding the bounding box)
testthat::test_that("atl_bbox applies buffer correctly short format", {
  geom <- sf::st_as_sfc("POLYGON((0 0, 1 0, 1 2, 0 2, 0 0))")
  bbox_no_buffer <- tools4watlas::atl_bbox(geom, asp = "16:9", buffer = 0)
  bbox_with_buffer <- tools4watlas::atl_bbox(geom, asp = "16:9", buffer = 0.5)
  
  # Ensure the bounding box with buffer is larger than the one without buffer
  testthat::expect_true(bbox_with_buffer["xmax"] > bbox_no_buffer["xmax"])
  testthat::expect_true(bbox_with_buffer["ymax"] > bbox_no_buffer["ymax"])
  testthat::expect_true(bbox_with_buffer["xmin"] < bbox_no_buffer["xmin"])
  testthat::expect_true(bbox_with_buffer["ymin"] < bbox_no_buffer["ymin"])
})


# Test buffer functionality (expanding the bounding box)
testthat::test_that("atl_bbox applies buffer correctly long format", {
  geom <- sf::st_as_sfc("POLYGON((0 0, 5 0, 1 2, 0 2, 0 0))")
  bbox_no_buffer <- tools4watlas::atl_bbox(geom, asp = "1:1", buffer = 0)
  bbox_with_buffer <- tools4watlas::atl_bbox(geom, asp = "1:1", buffer = 0.5)
  
  # Ensure the bounding box with buffer is larger than the one without buffer
  testthat::expect_true(bbox_with_buffer["xmax"] > bbox_no_buffer["xmax"])
  testthat::expect_true(bbox_with_buffer["ymax"] > bbox_no_buffer["ymax"])
  testthat::expect_true(bbox_with_buffer["xmin"] < bbox_no_buffer["xmin"])
  testthat::expect_true(bbox_with_buffer["ymin"] < bbox_no_buffer["ymin"])
})

# Test error handling for invalid aspect ratio format
testthat::test_that("atl_bbox throws an error for invalid aspect ratio format", {
  geom <- sf::st_as_sfc("POLYGON((0 0, 1 0, 1 2, 0 2, 0 0))")
  
  testthat::expect_error(tools4watlas::atl_bbox(geom, asp = "16-9"), 
                          "Aspect ratio must be in the format 'width:height'.")
  testthat::expect_error(tools4watlas::atl_bbox(geom, asp = "16:9:1"), 
                          "Aspect ratio must be in the format 'width:height'.")
})
