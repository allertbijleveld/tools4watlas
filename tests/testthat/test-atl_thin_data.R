
test_that("atl_thin_data handles subsampling correctly", {
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
  expect_true(data.table::is.data.table(thinned))
  expect_true(
    all(c("animal_id", "x", "y", "time", "datetime") %in% names(thinned))
  )

  # Check thinning interval
  time_diffs <- thinned[, diff(time), by = animal_id]$V1
  expect_true(all(time_diffs >= 60, na.rm = TRUE))
})

test_that("atl_thin_data handles aggregation correctly", {
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

  expect_true(data.table::is.data.table(thinned))
  expect_true(
    all(c("animal_id", "x", "y", "time", "datetime") %in% names(thinned))
  )

  expect_equal(nrow(thinned), 4)
  expect_true(
    all(thinned[, diff(time), by = animal_id]$V1 >= 60, na.rm = TRUE)
  )
})

test_that("atl_thin_data throws error for invalid method", {
  data <- data.table::data.table(
    animal_id = rep(1:2, each = 10),
    time = rep(seq(1696218720, 1696218720 + 90, by = 10), 2),
    x = stats::rnorm(20, 10, 1),
    y = stats::rnorm(20, 15, 1)
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]

  expect_error(
    atl_thin_data(data,
      interval = 60, id_columns = "animal_id",
      method = "invalid"
    ),
    "method must be 'subsample' or 'aggregate'"
  )
})

test_that("atl_thin_data throws error for invalid data input", {
  expect_error(
    atl_thin_data(list(),
      interval = 60, id_columns = "animal_id",
      method = "subsample"
    ),
    "input is not a data.frame object"
  )
})

test_that("atl_thin_data handles missing id_columns gracefully", {
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

  expect_true(data.table::is.data.table(thinned))
  expect_true(all(c("x", "y", "time", "datetime") %in% names(thinned)))
})

test_that(
  "atl_thin_data throws error for interval smaller than tracking interval",
  {
    data <- data.table::data.table(
      animal_id = rep(1:2, each = 10),
      time = rep(seq(1696218720, 1696218720 + 90, by = 10), 2),
      x = stats::rnorm(20, 10, 1),
      y = stats::rnorm(20, 15, 1)
    )
    data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]

    expect_error(
      atl_thin_data(data,
        interval = 5, id_columns = "animal_id",
        method = "aggregate"
      ),
      "thinning interval is less than the tracking interval"
    )
  }
)

test_that(
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

    expect_true(data.table::is.data.table(thinned))
    expect_true(all(!c("varx", "vary") %in% names(thinned)))
  }
)

test_that("atl_thin_data aggregates correctly with varx and vary columns", {
  # Create data that includes varx and vary
  data <- data.table::data.table(
    animal_id = rep(1:2, each = 10),
    time = rep(seq(1696218720, 1696218720 + 90, by = 10), 2),
    x = stats::rnorm(20, 10, 1),
    y = stats::rnorm(20, 15, 1),
    varx = runif(20, 0.1, 0.5),
    vary = runif(20, 0.1, 0.5)
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]
  data <- as.data.frame(data)
  
  # Run aggregation
  thinned <- atl_thin_data(
    data = data,
    interval = 60,
    id_columns = "animal_id",
    method = "aggregate"
  )
  
  # Basic checks
  expect_true(data.table::is.data.table(thinned))
  expect_true(all(c("varx", "vary") %in% names(thinned)))
  expect_true(all(thinned$n_aggregated > 0))
  
  # Check that varx and vary were aggregated correctly
  expect_true(all(thinned$varx <= max(data$varx)))
  expect_true(all(thinned$vary <= max(data$vary)))
  
  # Ensure time differences are consistent
  lag <- thinned[, diff(time), by = animal_id]$V1
  expect_true(all(lag >= 60, na.rm = TRUE))
})

test_that("atl_thin_data keeps the first value of non-numeric columns", {
  base_time <- 1696218720
  data <- data.table::data.table(
    time = seq(base_time, base_time + 110, by = 10),
    x = as.numeric(1:12),
    y = as.numeric(1:12),
    species = c(rep("red knot", 6), rep("redshank", 6))
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]
  
  thinned <- atl_thin_data(
    data,
    interval = 60, id_columns = NULL, method = "aggregate"
  )
  
  expect_equal(nrow(thinned), 2)
  expect_equal(thinned$species, c("red knot", "redshank"))
  # numeric columns are averaged per window
  expect_equal(thinned$x, c(3.5, 9.5))
  expect_equal(thinned$y, c(3.5, 9.5))
  expect_equal(thinned$n_aggregated, c(6, 6))
})

test_that("atl_thin_data keeps patch only if first and last point agree", {
  base_time <- 1696218720
  data <- data.table::data.table(
    animal_id = 1,
    time = seq(base_time, base_time + 110, by = 10),
    x = as.numeric(1:12),
    y = as.numeric(1:12),
    # window 1: all "a"; window 2: starts with "b", ends with "c"
    patch = c(rep("a", 6), "b", rep("b", 4), "c")
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]
  
  thinned <- atl_thin_data(
    data,
    interval = 60, id_columns = "animal_id", method = "aggregate"
  )
  
  expect_equal(nrow(thinned), 2)
  expect_equal(thinned$patch, c("a", NA_character_))
})

test_that("atl_thin_data errors when aggregated windows are not in time order", {
  base_time <- 1696218720
  # time in descending order passes the first interval check
  # (negative lags) but gives negative differences after aggregation
  data <- data.table::data.table(
    animal_id = 1,
    time = rev(seq(base_time, base_time + 90, by = 10)),
    x = stats::rnorm(10, 10, 1),
    y = stats::rnorm(10, 15, 1)
  )
  data[, datetime := as.POSIXct(time, origin = "1970-01-01", tz = "UTC")]
  
  expect_error(
    atl_thin_data(
      data,
      interval = 60, id_columns = "animal_id", method = "aggregate"
    ),
    "time differences are less than the specified interval"
  )
})

