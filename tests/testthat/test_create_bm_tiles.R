# library(tools4watlas)
# library(ggplot2)
# 
# testthat::test_that(
#   "atl_create_bm_tiles works with defaults", {
#     
#     bm <- atl_create_bm_tiles(buffer = 500)
#     
#     testthat::expect_s3_class(bm, "ggplot")
#   }
# )
# 
# 
# testthat::test_that(
#   "atl_create_bm_tiles works with input data", {
#     
#     dt <- data.table::data.table(
#       x = 650272.5,
#       y = 5902705
#     )
#     
#     bm <- atl_create_bm_tiles(data = dt, buffer = 100)
#     
#     testthat::expect_s3_class(bm, "ggplot")
#   }
# )
# 
# 
# testthat::test_that(
#   "atl_create_bm_tiles handles NULL data", {
#     
#     bm <- atl_create_bm_tiles(data = NULL, buffer = 100)
#     
#     testthat::expect_s3_class(bm, "ggplot")
#   }
# )
# 
# 
# testthat::test_that(
#   "atl_create_bm_tiles converts bbox input", {
#     
#     bbox <- sf::st_bbox(
#       c(
#         xmin = 650000,
#         ymin = 5902500,
#         xmax = 650500,
#         ymax = 5903000
#       ),
#       crs = sf::st_crs(32631)
#     )
#     
#     bm <- atl_create_bm_tiles(data = bbox)
#     
#     testthat::expect_s3_class(bm, "ggplot")
#   }
# )
# 
# 
# testthat::test_that(
#   "atl_create_bm_tiles works with data.frame input", {
#     
#     df <- data.frame(
#       x = 650272.5,
#       y = 5902705
#     )
#     
#     bm <- atl_create_bm_tiles(data = df, buffer = 100)
#     
#     testthat::expect_s3_class(bm, "ggplot")
#   }
# )
# 
# 
# testthat::test_that(
#   "atl_create_bm_tiles works without scalebar", {
#     
#     dt <- data.table::data.table(
#       x = 650272.5,
#       y = 5902705
#     )
#     
#     bm <- atl_create_bm_tiles(
#       data = dt,
#       scalebar = FALSE
#     )
#     
#     testthat::expect_s3_class(bm, "ggplot")
#   }
# )
# 
# 
# testthat::test_that(
#   "atl_create_bm_tiles errors on invalid data", {
#     
#     testthat::expect_error(
#       atl_create_bm_tiles(data = "invalid")
#     )
#   }
# )
