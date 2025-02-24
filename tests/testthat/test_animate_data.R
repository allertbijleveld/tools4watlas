# library(tools4watlas)
# library(testthat)

# Test atl_time_steps
# Define temporary output path
temp_path <- tempdir()

test_that("atl_time_steps generates correct time sequence", {
  datetime_vector <- as.POSIXct(c("2024-01-01 00:00:00", "2024-01-01 01:00:00"))
  ts <- atl_time_steps(datetime_vector, "30 min", temp_path, create_path = TRUE)
  
  expect_s3_class(ts, "data.table")
  expect_equal(ncol(ts), 2)
  expect_named(ts, c("datetime", "path"))
  expect_equal(nrow(ts), 3)
  expect_equal(ts$datetime, seq(datetime_vector[1], datetime_vector[2], "30 min"))
})

test_that("atl_time_steps handles directory creation", {
  new_path <- file.path(temp_path, "new_dir")
  expect_false(dir.exists(new_path))
  
  ts <- atl_time_steps(Sys.time(), "1 hour", new_path, create_path = TRUE)
  expect_true(dir.exists(new_path))
})

test_that("atl_time_steps errors if directory does not exist and create_path is FALSE", {
  nonexistent_path <- file.path(temp_path, "does_not_exist")
  expect_error(
    atl_time_steps(Sys.time(), "1 hour", nonexistent_path, create_path = FALSE),
    "Directory does not exist"
  )
})

# Test atl_alpha_along and atl_size_along
test_that("along is double", {
  expect_type(atl_alpha_along(1:100, head = 20, skew = -2), "double")
  expect_type(atl_size_along(1:100, head = 70, to = c(0.1, 5)), "double")
})

test_that("along is in expected range", {
  expect_lt(max(atl_alpha_along(1:100, head = 20, skew = -2)), 1.1)
  expect_gt(min(atl_alpha_along(1:100, head = 20, skew = -2)), 0)
  expect_lt(max(atl_size_along(1:100, head = 70, to = c(0.1, 5))), 5.1)
  expect_gt(min(atl_size_along(1:100, head = 70, to = c(0.1, 5))), 0)
})

# Test atl_ffmpeg_pattern
test_that("atl_ffmpeg_pattern generates correct patterns", {
  expect_equal(atl_ffmpeg_pattern("path/to/file/001.png"), "%03d.png")
  expect_equal(atl_ffmpeg_pattern("/another/path/0001.png"), "%04d.png")
  expect_equal(atl_ffmpeg_pattern("/img/123456.png"), "%06d.png")
})
