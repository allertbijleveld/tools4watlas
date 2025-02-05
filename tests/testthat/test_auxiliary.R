library(testthat)
library(data.table)

# Tests for atl_spec_cols

# Test that function returns a named vector when option is "vector"
test_that("atl_spec_cols returns named vector", {
  result <- atl_spec_cols("vector")
  expect_type(result, "character")
  expect_named(result)
  expect_true(all(nzchar(names(result))))
})

# Test that function returns a data.table when option is "table"
test_that("atl_spec_cols returns data.table", {
  result <- atl_spec_cols("table")
  expect_s3_class(result, "data.table")
  expect_true(all(c("species", "colour") %in% colnames(result)))
  expect_equal(nrow(result), length(atl_spec_cols("vector")))
})

# Test that function defaults to "vector" output
test_that("atl_spec_cols defaults to vector", {
  result <- atl_spec_cols()
  expect_type(result, "character")
})

# Test invalid input handling
test_that("atl_spec_cols handles invalid input", {
  expect_error(atl_spec_cols("invalid"), 
               "'arg' should be one of \"vector\", \"table\"")
})

# Tests for atl_spec_labs

# Test that function returns a named vector
test_that("atl_spec_labs returns named vector", {
  result <- atl_spec_labs("multiline")
  expect_type(result, "character")
  expect_named(result)
  expect_true(all(nzchar(names(result))))
})

# Test multiline output format
test_that("atl_spec_labs multiline format contains newlines", {
  result <- atl_spec_labs("multiline")
  expect_true(any(grepl("\\n", result)))
})

# Test singleline output format
test_that("atl_spec_labs singleline format does not contain newlines", {
  result <- atl_spec_labs("singleline")
  expect_false(any(grepl("\\n", result)))
})

# Test function defaults to "multiline" output
test_that("atl_spec_labs defaults to multiline", {
  result <- atl_spec_labs()
  expect_true(any(grepl("\\n", result)))
})

# Test invalid input handling
test_that("atl_spec_labs handles invalid input", {
  expect_error(atl_spec_labs("invalid"), 
               "'arg' should be one of \"multiline\", \"singleline\"")
})


# Tests for atl_t_col

# Test valid color conversion
test_that("atl_t_col returns correct transparent color", {
  result <- atl_t_col("blue", percent = 50)
  expect_type(result, "character")
  expect_match(result, "#", fixed = TRUE)
})

# Test transparency limits
test_that("atl_t_col handles transparency limits", {
  result_0 <- atl_t_col("red", percent = 0)
  result_100 <- atl_t_col("red", percent = 100)
  expect_match(result_0, "FF", fixed = TRUE)  # Fully opaque
  expect_match(result_100, "00", fixed = TRUE) # Fully transparent
})

# Test invalid color input
test_that("atl_t_col handles invalid color input", {
  expect_error(atl_t_col(123),
               "The 'color' parameter should be a single character string.")
  expect_error(atl_t_col(c("red", "blue")),
               "The 'color' parameter should be a single character string.")
})

# Test invalid percent input
test_that("atl_t_col handles invalid percent input", {
  expect_error(atl_t_col("blue", percent = -10),
               "The 'percent' parameter should be a numeric value between 0" )
  expect_error(atl_t_col("blue", percent = 110),
               "The 'percent' parameter should be a numeric value between 0" )
  expect_error(atl_t_col("blue", percent = "fifty"),
               "The 'percent' parameter should be a numeric value between 0" )
})
