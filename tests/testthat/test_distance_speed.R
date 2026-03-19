testthat::test_that("simple distance and speed works", {
  # make test positions
  test_df <- data.table::data.table(
    tag = 1111,
    a = 1,
    y = 1:100,
    time = 1:100
  )
  # run function with custom col names
  test_output <- tools4watlas::atl_simple_dist(test_df, x = "a", y = "y")

  # get speeds as well
  test_speed <- tools4watlas::atl_get_speed(
    test_df,
    tag = "tag",                                        
    x = "a",
    y = "y",
    time = "time"
  )

  # do tests
  # should return as many elements as nrows in df
  testthat::expect_equal(length(test_output), nrow(test_df),
    info = "distances returned are not same length
                                 as data provided"
  )
  testthat::expect_equal(nrow(test_speed), nrow(test_df),
    info = "speeds returned are not same length
                                 as data provided"
  )
  # test that the first element is NA
  testthat::expect_equal(test_output[1], NA_real_,
    info = "first distance is not NA"
  )
  testthat::expect_equal(test_speed[1]$speed_in, NA_real_,
    info = "first speed is not NA"
  )
  # test that the vector class is numeric or double
  testthat::expect_type(test_output, "double")
  testthat::expect_type(test_speed$speed_in, "double")

  # test that the distances except first are 1 in this case
  testthat::expect_equal(test_output, c(NA, rep(1.0, 99)),
    info = "the distance calculation is wrong"
  )
})

testthat::test_that("simple distance is correct", {
  test_data <- data.table::fread(
    "../testdata/whole_season_tx_435.csv")[1:1000, ]
  test_data[, TIME := as.numeric(TIME)]

  # distance using custom fun
  test_distances <- tools4watlas::atl_simple_dist(test_data,
    x = "X", y = "Y"
  )

  # test speed out
  test_speed_in <- tools4watlas::atl_get_speed(
    test_data,
    tag = "TAG", x = "X", y = "Y",
    time = "TIME",
    type = "in"
  )
  
  # test speed out
  test_speed_out <- tools4watlas::atl_get_speed(
    test_data,
    tag = "TAG", x = "X", y = "Y",
    time = "TIME",
    type = "out"
  )

  # distance using sf
  data_sf <- sf::st_as_sf(test_data,
    coords = c("X", "Y")
  )
  sf::st_crs(data_sf) <- 32631

  sf_distance <- sf::st_distance(data_sf$geometry[seq_len(nrow(data_sf) - 1)],
    data_sf$geometry[-1],
    by_element = T
  )

  sf_distance <- as.numeric(c(NA, sf_distance))

  # check that the distances are correct
  testthat::expect_equal(test_distances, sf_distance)

  # check the speeds are correct
  testthat::expect_equal(
    sf_distance / c(NA, diff(test_data[["TIME"]])),
    test_speed_in$speed_in
  )

  # check that out speed is correct
  testthat::expect_equal(
    data.table::shift(sf_distance / c(NA, diff(test_data[["TIME"]])),
      type = "lead"
    ),
    test_speed_out$speed_out
  )
})

testthat::test_that("atl_simple_dist() returns NA when nrow(data) <= lag", {
  skip_if_not_installed("tools4watlas")
  
  # nrow == lag: exactly at the boundary
  data_eq <- data.table::data.table(x = 1, y = 1)
  result_eq <- tools4watlas::atl_simple_dist(data_eq, lag = 1)
  expect_equal(result_eq, NA_real_)
  
  # nrow < lag: below the boundary
  data_lt <- data.table::data.table(x = c(1, 2), y = c(1, 2))
  result_lt <- tools4watlas::atl_simple_dist(data_lt, lag = 3)
  expect_equal(result_lt, rep(NA_real_, 3))
  expect_length(result_lt, 3)
})
