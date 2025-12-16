library(testthat)
library(tools4watlas)

testthat::test_that(
  "atl_transform_dt adds transformed coordinate columns", {
    
    library(data.table)
    
    dt <- data.table(
      x = 650272.5,
      y = 5902705
    )
    
    res <- atl_transform_dt(dt)
    
    testthat::expect_true("x_4326" %in% names(res))
    testthat::expect_true("y_4326" %in% names(res))
    testthat::expect_true("x" %in% names(res))
    testthat::expect_true("y" %in% names(res))
  }
)


testthat::test_that(
  "atl_transform_dt returns numeric transformed coordinates", {
    
    library(data.table)
    
    dt <- data.table(
      x = 650272.5,
      y = 5902705
    )
    
    res <- atl_transform_dt(dt)
    
    testthat::expect_type(res$x_4326, "double")
    testthat::expect_type(res$y_4326, "double")
  }
)


testthat::test_that(
  "atl_transform_dt sets CRS attribute correctly", {
    
    library(data.table)
    library(sf)
    
    dt <- data.table(
      x = 650272.5,
      y = 5902705
    )
    
    res <- atl_transform_dt(dt)
    
    crs_attr <- attr(res, "crs")
    
    testthat::expect_s3_class(crs_attr, "crs")
    testthat::expect_equal(crs_attr$epsg, 4326)
  }
)


testthat::test_that(
  "atl_transform_dt works with custom coordinate names", {
    
    library(data.table)
    
    dt <- data.table(
      east = 650272.5,
      north = 5902705
    )
    
    res <- atl_transform_dt(
      data = dt,
      x = "east",
      y = "north"
    )
    
    testthat::expect_true("east_4326" %in% names(res))
    testthat::expect_true("north_4326" %in% names(res))
  }
)


testthat::test_that(
  "atl_transform_dt returns unchanged empty data", {
    
    library(data.table)
    
    dt <- data.table(
      x = numeric(),
      y = numeric()
    )
    
    res <- atl_transform_dt(dt)
    
    testthat::expect_equal(res, dt)
    testthat::expect_null(attr(res, "crs"))
  }
)
