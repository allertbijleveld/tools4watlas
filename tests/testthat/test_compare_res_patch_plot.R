# library(testthat)
# library(tools4watlas)

test_that("atl_compare_res_patch_plot returns a ggplot object", {
  
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
  
  # change summary
  change_summary <- atl_compare_res_patch_summary(data_v1, data_v2)
  
  i <- 1
  
  # returns a ggplot object
  p <- atl_compare_res_patch_plot(
    data_v1 = data_v1,
    data_v2 = data_v2,
    tag = change_summary$tag[i],
    change = change_summary$change[i],
    patch_v1 = change_summary$patch_v1[i],
    patch_v2 = change_summary$patch_v2[i]
  )
  
  expect_s3_class(p, "gg")
  
})

test_that("atl_compare_res_patch_plot works for all change types", {
  
  # load example data
  data <- data_example
  
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
  
  change_summary <- atl_compare_res_patch_summary(data_v1, data_v2)
  
  # all rows should produce a ggplot without error
  for (i in seq_len(nrow(change_summary))) {
    p <- atl_compare_res_patch_plot(
      data_v1 = data_v1,
      data_v2 = data_v2,
      tag = change_summary$tag[i],
      change = change_summary$change[i],
      patch_v1 = change_summary$patch_v1[i],
      patch_v2 = change_summary$patch_v2[i]
    )
    expect_s3_class(p, "gg")
  }
  
})

test_that("atl_compare_res_patch_plot errors on missing columns", {
  
  data <- data_example
  
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
  
  change_summary <- atl_compare_res_patch_summary(data_v1, data_v2)
  
  bad_data <- copy(data_v1)
  bad_data[, patch := NULL]
  
  expect_error(
    atl_compare_res_patch_plot(
      data_v1 = bad_data,
      data_v2 = data_v2,
      tag = change_summary$tag[1],
      change = change_summary$change[1],
      patch_v1 = change_summary$patch_v1[1],
      patch_v2 = change_summary$patch_v2[1]
    )
  )
  
})

test_that("atl_compare_res_patch_plot saves a PNG when filename is provided", {
  
  data <- data_example
  
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
  
  change_summary <- atl_compare_res_patch_summary(data_v1, data_v2)
  
  tmp <- tempfile()
  
  atl_compare_res_patch_plot(
    data_v1 = data_v1,
    data_v2 = data_v2,
    tag = change_summary$tag[1],
    change = change_summary$change[1],
    patch_v1 = change_summary$patch_v1[1],
    patch_v2 = change_summary$patch_v2[1],
    filename = tmp
  )
  
  expect_true(file.exists(paste0(tmp, ".png")))
  
  # clean up
  file.remove(paste0(tmp, ".png"))
  
})

test_that("atl_compare_res_patch_plot works for lost change type", {
  
  data <- data_example
  
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
  
  # swap v1 and v2 to get a "lost" change type
  change_summary <- atl_compare_res_patch_summary(data_v2, data_v1)
  
  lost_rows <- change_summary[change == "lost"]
  
  if (nrow(lost_rows) > 0) {
    p <- atl_compare_res_patch_plot(
      data_v1 = data_v2,
      data_v2 = data_v1,
      tag = lost_rows$tag[1],
      change = lost_rows$change[1],
      patch_v1 = lost_rows$patch_v1[1],
      patch_v2 = lost_rows$patch_v2[1]
    )
    expect_s3_class(p, "gg")
  }
  
})

test_that("atl_compare_res_patch_plot errors when no data in time window", {
  
  data <- data_example
  
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
  
  change_summary <- atl_compare_res_patch_summary(data_v1, data_v2)
  
  # empty data triggers the nrow == 0 stop
  empty_data <- data_v1[0]
  
  expect_error(
    atl_compare_res_patch_plot(
      data_v1 = empty_data,
      data_v2 = data_v2,
      tag = change_summary$tag[1],
      change = change_summary$change[1],
      patch_v1 = change_summary$patch_v1[1],
      patch_v2 = change_summary$patch_v2[1]
    )
  )
  
})
