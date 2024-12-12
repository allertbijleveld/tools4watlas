testthat::test_that("atl_thin_data handles subsampling correctly", {
  # Create test data
  data <- data.table::data.table(
    animal_id = rep(1:2, each = 10),
    time = rep(seq(1696218720, 1696218720 + 90, by = 10), 2),
    x = stats::rnorm(20, 10, 1),
    y = stats::rnorm(20, 15, 1)
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]

  # Subsampling
  thinned <- atl_thin_data(data,
    interval = 60, id_columns = "animal_id",
    method = "subsample"
  )

  # Check structure
  testthat::expect_true(data.table::is.data.table(thinned))
  testthat::expect_true(
    all(c("animal_id", "x", "y", "time", "datetime") %in% names(thinned))
  )

  # Check thinning interval
  time_diffs <- thinned[, diff(time), by = animal_id]$V1
  testthat::expect_true(all(time_diffs >= 60, na.rm = TRUE))
})

testthat::test_that("atl_thin_data handles aggregation correctly", {
  data <- data.table::data.table(
    animal_id = rep(1:2, each = 10),
    time = rep(seq(1696218720, 1696218720 + 90, by = 10), 2),
    x = stats::rnorm(20, 10, 1),
    y = stats::rnorm(20, 15, 1)
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]

  thinned <- atl_thin_data(data,
    interval = 60, id_columns = "animal_id",
    method = "aggregate"
  )

  testthat::expect_true(data.table::is.data.table(thinned))
  testthat::expect_true(
    all(c("animal_id", "x", "y", "time", "datetime") %in% names(thinned))
  )

  testthat::expect_equal(nrow(thinned), 4)
  testthat::expect_true(
    all(thinned[, diff(time), by = animal_id]$V1 >= 60, na.rm = TRUE)
  )
})

testthat::test_that("atl_thin_data throws error for invalid method", {
  data <- data.table::data.table(
    animal_id = rep(1:2, each = 10),
    time = rep(seq(1696218720, 1696218720 + 90, by = 10), 2),
    x = stats::rnorm(20, 10, 1),
    y = stats::rnorm(20, 15, 1)
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]

  testthat::expect_error(
    atl_thin_data(data,
      interval = 60, id_columns = "animal_id",
      method = "invalid"
    ),
    "method must be 'subsample' or 'aggregate'"
  )
})

testthat::test_that("atl_thin_data throws error for invalid data input", {
  testthat::expect_error(
    atl_thin_data(list(),
      interval = 60, id_columns = "animal_id",
      method = "subsample"
    ),
    "input is not a data.frame object"
  )
})

testthat::test_that("atl_thin_data handles missing id_columns gracefully", {
  data <- data.table::data.table(
    time = seq(1696218720, 1696218720 + 90, by = 10),
    x = stats::rnorm(10, 10, 1),
    y = stats::rnorm(10, 15, 1)
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]

  thinned <- atl_thin_data(data,
    interval = 60, id_columns = NULL,
    method = "subsample"
  )

  testthat::expect_true(data.table::is.data.table(thinned))
  testthat::expect_true(all(c("x", "y", "time", "datetime") %in% names(thinned)))
})

testthat::test_that(
  "atl_thin_data throws error for interval smaller than tracking interval",
  {
    data <- data.table::data.table(
      animal_id = rep(1:2, each = 10),
      time = rep(seq(1696218720, 1696218720 + 90, by = 10), 2),
      x = stats::rnorm(20, 10, 1),
      y = stats::rnorm(20, 15, 1)
    )
    data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]

    testthat::expect_error(
      atl_thin_data(data,
        interval = 5, id_columns = "animal_id",
        method = "aggregate"
      ),
      "thinning interval is less than the tracking interval"
    )
  }
)

testthat::test_that(
  "atl_thin_data handles missing error columns during aggregation",
  {
    data <- data.table::data.table(
      animal_id = rep(1:2, each = 10),
      time = rep(seq(1696218720, 1696218720 + 90, by = 10), 2),
      x = stats::rnorm(20, 10, 1),
      y = stats::rnorm(20, 15, 1)
    )
    data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]

    thinned <- atl_thin_data(data,
      interval = 60, id_columns = "animal_id",
      method = "aggregate"
    )

    testthat::expect_true(data.table::is.data.table(thinned))
    testthat::expect_true(all(!c("varx", "vary") %in% names(thinned)))
  }
)
