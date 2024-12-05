testthat::test_that("atl_full_tag_id creates correct full tag ID from numeric 
                    input", {
  tag <- 123
  result <- tools4watlas::atl_full_tag_id(tag)
  
  # Full tag should add 31001000000 to the tag
  testthat::expect_equal(result, "31001000123")
})

testthat::test_that("atl_full_tag_id creates correct short tag ID from numeric 
                    input", {
  tag <- 123
  result <- tools4watlas::atl_full_tag_id(tag, short = TRUE, n = 4)
  
  # Short tag ID should return the last 4 digits of the full tag
  testthat::expect_equal(result, "0123")
})

testthat::test_that("atl_full_tag_id creates correct full tag ID from character
                    input", {
  tag <- "456"
  result <- tools4watlas::atl_full_tag_id(tag)
  
  # Full tag should add 31001000000 to the tag
  testthat::expect_equal(result, "31001000456")
})

testthat::test_that("atl_full_tag_id creates correct short tag ID from
                    character input", {
  tag <- "456"
  result <- tools4watlas::atl_full_tag_id(tag, short = TRUE, n = 3)
  
  # Short tag ID should return the last 3 digits of the full tag
  testthat::expect_equal(result, "456")
})

testthat::test_that("atl_full_tag_id handles tag exceeding 6 digits", {
  tag <- 1234567
  
  # Expect error when the tag exceeds 6 digits
  testthat::expect_error(tools4watlas::atl_full_tag_id(tag),
                         "tag should be < 7 digits, but is 7 digits")
})

testthat::test_that("atl_full_tag_id handles invalid tag format (non-numeric, 
                    non-character)", {
  tag <- list(123)
  
  # Expect error when tag is neither numeric nor character
  testthat::expect_error(tools4watlas::atl_full_tag_id(tag),
                         "tag provided must be numeric or character")
})


testthat::test_that("atl_full_tag_id handles correct behavior with tag that has 
                    leading zeros", {
  tag <- "007"
  
  # Full tag should add 31001000000 to the tag
  result <- tools4watlas::atl_full_tag_id(tag)
  testthat::expect_equal(result, "31001000007")
  
  # Short tag should return the last 3 digits
  result <- tools4watlas::atl_full_tag_id(tag, short = TRUE, n = 3)
  testthat::expect_equal(result, "007")
})


testthat::test_that("atl_full_tag_id works with character tags that include 
                    leading zeros", {
  tag <- "007"
  
  result <- tools4watlas::atl_full_tag_id(tag, short = TRUE, n = 3)
  testthat::expect_equal(result, "007")
})
