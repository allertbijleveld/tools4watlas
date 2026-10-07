test_that("simple speed works", {
  # make test positions
  test_df <- data.table::data.table(
    tag = 1111,
    a = 1,
    y = 1:100,
    time = 1:100
  )
  
  # get speeds with custom col names
  test_speed <- atl_get_speed(
    test_df,
    tag = "tag",
    x = "a",
    y = "y",
    time = "time"
  )
  
  # should return as many rows as nrows in df
  expect_equal(
    nrow(test_speed), nrow(test_df),
    info = "speeds returned are not same length as data provided"
  )
  
  # test that the first element is NA
  expect_equal(test_speed[1]$speed_in, NA_real_, info = "first speed is not NA")
  
  # test that the vector class is numeric or double
  expect_type(test_speed$speed_in, "double")
})

test_that("speed is correct", {
  test_data <- data.table::fread(
    "../testdata/whole_season_tx_435.csv"
  )[1:1000, ]
  test_data[, TIME := as.numeric(TIME)]
  
  # speed in
  test_speed_in <- atl_get_speed(
    test_data,
    tag = "TAG", x = "X", y = "Y",
    time = "TIME",
    type = "in"
  )
  
  # speed out
  test_speed_out <- atl_get_speed(
    test_data,
    tag = "TAG", x = "X", y = "Y",
    time = "TIME",
    type = "out"
  )
  
  # reference distance using sf
  data_sf <- sf::st_as_sf(test_data, coords = c("X", "Y"))
  sf::st_crs(data_sf) <- 32631
  
  sf_distance <- sf::st_distance(
    data_sf$geometry[seq_len(nrow(data_sf) - 1)],
    data_sf$geometry[-1],
    by_element = TRUE
  )
  sf_distance <- as.numeric(c(NA, sf_distance))
  
  # check the speeds are correct
  expect_equal(
    sf_distance / c(NA, diff(test_data[["TIME"]])),
    test_speed_in$speed_in
  )
  
  # check that out speed is correct
  expect_equal(
    data.table::shift(
      sf_distance / c(NA, diff(test_data[["TIME"]])),
      type = "lead"
    ),
    test_speed_out$speed_out
  )
})