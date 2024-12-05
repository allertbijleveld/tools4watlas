
# Test that the function works with a simple polygon geometry
test_that("atl_bbox handles simple geometry", {
  geom <- sf::st_as_sfc("POLYGON((0 0, 1 0, 1 2, 0 2, 0 0))")
  bbox <- atl_bbox(geom, asp = "16:9")
  
  expect_equal(length(bbox), 4)  # Ensure the bbox has 4 elements (xmin, ymin, xmax, ymax)
  expect_true(all(names(bbox) %in% c("xmin", "ymin", "xmax", "ymax")))  # Check names
})

# Test buffer functionality (expanding the bounding box)
test_that("atl_bbox applies buffer correctly", {
  geom <- sf::st_as_sfc("POLYGON((0 0, 1 0, 1 2, 0 2, 0 0))")
  bbox_no_buffer <- atl_bbox(geom, asp = "16:9", buffer = 0)
  bbox_with_buffer <- atl_bbox(geom, asp = "16:9", buffer = 0.5)
  
  # Ensure the bounding box with buffer is larger than the one without buffer
  expect_true(bbox_with_buffer["xmax"] > bbox_no_buffer["xmax"])
  expect_true(bbox_with_buffer["ymax"] > bbox_no_buffer["ymax"])
  expect_true(bbox_with_buffer["xmin"] < bbox_no_buffer["xmin"])
  expect_true(bbox_with_buffer["ymin"] < bbox_no_buffer["ymin"])
})

# Test error handling for invalid aspect ratio format
test_that("atl_bbox throws an error for invalid aspect ratio format", {
  geom <- sf::st_as_sfc("POLYGON((0 0, 1 0, 1 2, 0 2, 0 0))")
  
  expect_error(atl_bbox(geom, asp = "16-9"), "Aspect ratio must be in the format 'width:height'.")
  expect_error(atl_bbox(geom, asp = "16:9:1"), "Aspect ratio must be in the format 'width:height'.")
})
