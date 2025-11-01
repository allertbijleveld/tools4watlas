library(testthat)
library(tools4watlas)

testthat::test_that("data kept within bounds", {
  # make test_data
  test_data <- data.table::data.table(
    X = as.double(seq_len(1000)),
    Y = as.double(seq_len(1000)),
    TIME = seq_len(1000)
  )

  test_data <- test_data[200:500, `:=`(
    X = rnorm(301, 300, 20),
    Y = rnorm(301, 800, 20)
  )]
  # test polygon
  test_polygon <- sf::st_multipoint(x = matrix(c(250, 250, 500, 500),
    ncol = 2,
    byrow = T
  ))
  test_polygon <- sf::st_buffer(test_polygon, dist = 200)
  test_area <- sf::st_sf(data.frame(
    feature = 1,
    geom = sf::st_sfc(test_polygon)
  ))
  sf::st_crs(test_area) <- 32631 # the WATLAS system CRS

  # run function
  test_output <- tools4watlas::atl_filter_bounds(
    data = test_data,
    x = "X",
    y = "Y",
    x_range = c(100, 600),
    y_range = c(100, 650),
    sf_polygon = test_area,
    remove_inside = FALSE
  )

  # do tests
  # test that the vector class is data.table and data.frame
  testthat::expect_s3_class(object = test_output, class = c(
    "data.table",
    "data.frame"
  ))

  # check that some rows are removed or that none are added
  testthat::expect_gte(nrow(test_data), nrow(test_output))

  # check the correct points are kept
  testthat::expect_true(all(data.table::between(test_output$X, 100, 600)),
    info = "within bounds not working"
  )

  testthat::expect_true(all(data.table::between(test_output$Y, 100, 650)),
    info = "within bounds not working"
  )
})

testthat::test_that("data removed within bounds", {
  # make test_data
  test_data <- data.table::data.table(
    X = as.double(seq_len(1000)),
    Y = as.double(seq_len(1000)),
    TIME = seq_len(1000)
  )

  test_data <- test_data[200:500, `:=`(
    X = rnorm(301, 300, 20),
    Y = rnorm(301, 800, 20)
  )]

  # run function
  test_output <- tools4watlas::atl_filter_bounds(
    data = test_data,
    x = "X",
    y = "Y",
    x_range = c(200, 500),
    y_range = c(700, 900),
    remove_inside = TRUE
  )

  # do tests
  # test that the vector class is data.table and data.frame
  testthat::expect_s3_class(object = test_output, class = c(
    "data.table",
    "data.frame"
  ))

  # check that some rows are removed or that none are added
  testthat::expect_gte(nrow(test_data), nrow(test_output))

  # check the correct points are kept
  testthat::expect_true(
    all(!(data.table::between(test_output$X, 200, 500) &
      data.table::between(test_output$Y, 700, 900))),
    info = "within bounds not working"
  )
})

testthat::test_that("data filtered correctly by polygon only", {
  # create test data
  test_data <- data.frame(
    X = c(1, 2, 3, 4, 5),
    Y = c(1, 2, 3, 4, 5)
  )
  
  # define a square polygon covering points (2,2) to (4,4)
  poly_coords <- list(matrix(c(
    2,2,
    4,2,
    4,4,
    2,4,
    2,2
  ), ncol = 2, byrow = TRUE))
  test_polygon <- sf::st_polygon(poly_coords)
  
  # convert to sf object (required by atl_within_polygon)
  sf_poly <- sf::st_sf(geometry = sf::st_sfc(test_polygon, crs = 32631))
  
  # run function to keep points **inside polygon**
  filtered_inside <- tools4watlas::atl_filter_bounds(
    data = test_data,
    x = "X",
    y = "Y",
    sf_polygon = sf_poly,
    remove_inside = FALSE
  )
  
  # points inside polygon: (2,2), (3,3), (4,4)
  expect_equal(filtered_inside$X, c(2, 3, 4))
  expect_equal(filtered_inside$Y, c(2, 3, 4))
  
})
