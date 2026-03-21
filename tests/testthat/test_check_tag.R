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

# Test: days_data < 1 triggers %H:%M datetime format
test_that("atl_check_tag uses H:M format when data spans less than one day", {
  test_data_short <- data.table::copy(test_data)
  # all within same hour
  test_data_short[, datetime := as.POSIXct("2024-01-01 08:00:00") +
                    seq(0, 9) * 60]
  p <- atl_check_tag(test_data_short, option = "datetime")
  expect_s3_class(p, "ggplot")
})

# Test: scale_max supplied caps values for nbs, var, speed_in, gap
test_that("atl_check_tag respects scale_max for all relevant options", {
  expect_s3_class(
    atl_check_tag(test_data, option = "nbs", scale_max = 3),
    "ggplot"
  )
  expect_s3_class(
    atl_check_tag(test_data, option = "var", scale_max = 0.5),
    "ggplot"
  )
  expect_s3_class(
    atl_check_tag(test_data, option = "speed_in", scale_max = 2),
    "ggplot"
  )
  expect_s3_class(
    atl_check_tag(test_data, option = "gap", scale_max = 5),
    "ggplot"
  )
})

# Test: data.frame input is accepted (triggers setDT conversion)
test_that("atl_check_tag accepts data.frame input", {
  p <- atl_check_tag(as.data.frame(test_data), option = "datetime")
  expect_s3_class(p, "ggplot")
})

# Test: highlight_outliers = TRUE errors when outlier column is missing
test_that("atl_check_tag errors when outlier column missing and highlight_outliers = TRUE", {
  data_no_outlier <- data.table::copy(test_data)
  data_no_outlier[, outlier := NULL]
  expect_error(
    atl_check_tag(data_no_outlier, option = "datetime", highlight_outliers = TRUE)
  )
})

# Test: bird_name column present in title (non-NULL tag_name path)
test_that("atl_check_tag includes bird_name in title when column present", {
  test_data_named <- data.table::copy(test_data)
  test_data_named[, bird_name := "Henk"]
  p <- atl_check_tag(test_data_named, option = "datetime")
  expect_s3_class(p, "ggplot")
  expect_true(grepl("Henk", p$labels$title))
})

# Test: filename saves PNG to disk
test_that("atl_check_tag saves PNG when filename is provided", {
  skip_if_not_installed("ragg")
  tmp <- tempfile()
  atl_check_tag(test_data, option = "datetime", filename = tmp)
  expect_true(file.exists(paste0(tmp, ".png")))
  expect_gt(file.size(paste0(tmp, ".png")), 0)
  unlink(paste0(tmp, ".png"))
})

