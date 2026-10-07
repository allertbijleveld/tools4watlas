
test_that("data_example is a data.table with the expected columns", {
  d <- tools4watlas::data_example
  expect_s3_class(d, "data.table")
  expect_gt(nrow(d), 0)
  
  expected_cols <- c(
    "species", "posID", "tag", "time", "datetime", "x", "y", "nbs",
    "varx", "vary", "covxy", "speed_in", "speed_out", "x_raw", "y_raw",
    "tideID", "tidaltime", "time2lowtide", "waterlevel", "bathymetry"
  )
  expect_true(all(expected_cols %in% names(d)))
})

test_that("data_example columns have the expected types", {
  d <- tools4watlas::data_example
  expect_type(d$tag, "character")
  expect_type(d$species, "character")
  expect_s3_class(d$datetime, "POSIXct")
  expect_type(d$time, "double")
  expect_type(d$x, "double")
  expect_type(d$y, "double")
})

test_that("data_example has sensible tag ids, times and coordinates", {
  d <- tools4watlas::data_example
  
  # tag ids are present and 4 digits
  expect_false(anyNA(d$tag))
  expect_true(all(nchar(d$tag) == 4))
  
  # time (seconds) and datetime agree
  expect_equal(as.numeric(d$datetime), d$time)
  
  # coordinates are in EPSG:32631 range for the Dutch Wadden Sea
  expect_true(all(d$x > 500000 & d$x < 800000, na.rm = TRUE))
  expect_true(all(d$y > 5800000 & d$y < 6000000, na.rm = TRUE))
})

test_that("data_example has no stale data.table index", {
  # a stale index made data[tag == "x"] return no rows while the tag exists
  d <- data.table::copy(tools4watlas::data_example)
  tags <- unique(d$tag)
  
  for (tg in tags) {
    expect_equal(d[tag == tg, .N], sum(d$tag == tg))
  }
})