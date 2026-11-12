
test_that("atl_compare_res_patch_summary works correctly", {
  
  # load example data
  data <- data_example
  
  # run atl_res_patch with two different parameter sets
  data_v1 <- atl_res_patch(
    data[tag == "3038"],
    max_speed = 3, lim_spat_indep = 75, lim_time_indep = 180,
    min_fixes = 3, min_duration = 120
  )
  data_v2 <- atl_res_patch(
    data[tag == "3038"],
    max_speed = 5, lim_spat_indep = 75, lim_time_indep = 180,
    min_fixes = 3, min_duration = 120
  )
  
  # run function
  result <- atl_compare_res_patch_summary(data_v1, data_v2, quietly = TRUE)
  
  # returns a data.table
  expect_s3_class(result, "data.table")
  
  # has expected columns
  expect_named(result, c("tag", "tideID", "change", "patch_v1", "patch_v2"),
               ignore.order = TRUE
  )
  
  # change column only contains valid categories
  expect_true(all(result$change %in% c("lost", "gained", "split", "merge")))
  
  # patch_v1 is NA for gained patches
  expect_true(all(is.na(result[change == "gained"]$patch_v1)))
  
  # patch_v2 is NA for lost patches
  expect_true(all(is.na(result[change == "lost"]$patch_v2)))
  
  # known output from example data: 1 gained, 2 merges
  expect_equal(nrow(result[change == "gained"]), 1)
  expect_equal(nrow(result[change == "lost"]), 0)
  expect_equal(nrow(result[change == "split"]), 0)
  expect_equal(nrow(result[change == "merge"]), 2)
  
  # merge rows have comma-separated patch_v1
  merge_rows <- result[change == "merge"]
  expect_true(all(grepl(",", merge_rows$patch_v1)))
  
  # no NAs in tag or change columns
  expect_false(anyNA(result$tag))
  expect_false(anyNA(result$change))
  
})

test_that("atl_compare_res_patch_summary errors on missing columns", {
  
  data <- data_example
  
  data_v1 <- atl_res_patch(
    data[tag == "3038"],
    max_speed = 3, lim_spat_indep = 75, lim_time_indep = 180,
    min_fixes = 3, min_duration = 120
  )
  
  # remove required column from already patched data
  bad_data <- copy(data_v1)
  bad_data[, patch := NULL]
  
  expect_error(
    atl_compare_res_patch_summary(bad_data, data_v1, quietly = TRUE)
  )
  
})

# helper: synthetic patch data with one example of each change type
make_patch_data <- function() {
  n <- 18
  base <- data.table(
    posID = 1:n,
    tag = "1",
    tideID = 1L,
    datetime = as.POSIXct("2024-01-01", tz = "UTC") + (seq_len(n) - 1) * 60,
    x = seq_len(n) * 10,
    y = seq_len(n) * 10
  )
  v1 <- copy(base)[, patch := c(1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, NA, NA, NA)]
  v2 <- copy(base)[, patch := c(1, 1, 1, 2, 2, 2, NA, NA, NA, 3, 3, 3, 3, 3, 3, 4, 4, 4)]
  list(v1 = v1, v2 = v2)
}

test_that("atl_compare_res_patch_summary detects splits, lost, merges and gains", {
  
  d <- make_patch_data()
  result <- atl_compare_res_patch_summary(d$v1, d$v2, quietly = TRUE)
  
  # one row per change type, ordered by change within tag and tideID
  expect_equal(result$change, c("gained", "lost", "merge", "split"))
  
  # patch columns for each change type
  expect_equal(result[change == "split"]$patch_v1, "1")
  expect_equal(result[change == "split"]$patch_v2, "1, 2")
  expect_equal(result[change == "lost"]$patch_v1, "2")
  expect_true(is.na(result[change == "lost"]$patch_v2))
  expect_equal(result[change == "merge"]$patch_v1, "3, 4")
  expect_equal(result[change == "merge"]$patch_v2, "3")
  expect_true(is.na(result[change == "gained"]$patch_v1))
  expect_equal(result[change == "gained"]$patch_v2, "4")
  
})

test_that("atl_compare_res_patch_summary prints a summary when not quiet", {
  
  d <- make_patch_data()
  
  expect_output(
    atl_compare_res_patch_summary(d$v1, d$v2, quietly = FALSE),
    "Patch changes summary"
  )
  expect_output(
    atl_compare_res_patch_summary(d$v1, d$v2, quietly = FALSE),
    "Lost.*: 1"
  )
  expect_output(
    atl_compare_res_patch_summary(d$v1, d$v2, quietly = FALSE),
    "Merges.*: 1"
  )
  
})

test_that("atl_compare_res_patch_summary errors on non-data.frame input", {
  
  d <- make_patch_data()
  
  expect_error(
    atl_compare_res_patch_summary(list(1), d$v2, quietly = TRUE),
    "not a data.frame"
  )
  expect_error(
    atl_compare_res_patch_summary(d$v1, "not a table", quietly = TRUE),
    "not a data.frame"
  )
  
})

test_that("atl_compare_res_patch_summary errors on missing columns in either input", {
  
  d <- make_patch_data()
  bad <- copy(d$v1)[, patch := NULL]
  
  # missing in data_v1
  expect_error(atl_compare_res_patch_summary(bad, d$v2, quietly = TRUE))
  
  # missing in data_v2 (the line your current test never reaches)
  expect_error(atl_compare_res_patch_summary(d$v1, bad, quietly = TRUE))
  
})