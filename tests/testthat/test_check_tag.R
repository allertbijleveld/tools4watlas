# library(testthat)
# library(tools4watlas)
library(ggplot2)

# Sample dataset for testing
test_data <- data.table(
  tag = rep("test_tag", 10),
  species = rep("red knot", 10),
  rings = rep(1234, 10),
  crc = rep("ABC", 10),
  x = runif(10, 0, 100),
  y = runif(10, 0, 100),
  time = seq(1, 10),
  datetime = as.POSIXct("2024-01-01 00:00:00") + seq(1, 10),
  nbs = sample(1:5, 10, replace = TRUE),
  varx = runif(10, 0, 1),
  vary = runif(10, 0, 1),
  speed_in = runif(10, 0, 5), 
  outlier = c(rep(FALSE, 4), TRUE, rep(FALSE, 5))
)

test_that("atl_check_tag handles missing required columns", {
  expect_error(atl_check_tag(test_data[, .(x, y, time, datetime)]))
})

test_that("atl_check_tag handles invalid options", {
  expect_error(atl_check_tag(test_data, option = "invalid"), "Invalid option")
})


test_that("atl_check_tag returns a ggplot object", {
  p <- atl_check_tag(test_data, option = "datetime")
  expect_s3_class(p, "ggplot")
})

test_that("atl_check_tag check highlighting points", {
  p <- atl_check_tag(test_data,
    option = "datetime",
    highlight_first = TRUE, highlight_last = TRUE, highlight_outliers = TRUE
  )
  expect_s3_class(p, "ggplot")
})

test_that("atl_check_tag handles different options correctly", {
  expect_s3_class(atl_check_tag(test_data, option = "datetime"), "ggplot")
  expect_s3_class(atl_check_tag(test_data, option = "nbs"), "ggplot")
  expect_s3_class(atl_check_tag(test_data, option = "var"), "ggplot")
  expect_s3_class(atl_check_tag(test_data, option = "speed_in"), "ggplot")
  expect_s3_class(atl_check_tag(test_data, option = "gap"), "ggplot")
})

test_that("atl_check_tag correctly filters first_n and last_n", {
  p1 <- atl_check_tag(test_data, option = "datetime", first_n = 5)
  p2 <- atl_check_tag(test_data, option = "datetime", last_n = 5)
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

