# # packages
# library(tools4watlas)
# library(ggplot2)
# library(viridis)
# library(foreach)
# library(doFuture)
# 
# # load example data
# data <- data_example
# 
# # file path to WATLAS teams data folder
# fp <- atl_file_path("watlas_teams")
# 
# # sub path to tide data
# tidal_pattern_fp <- paste0(
#   fp "waterdata/allYears-tidalPattern-west_terschelling-UTC.csv"
# )
# measured_water_height_fp <- paste0(
#   fp "waterdata/allYears-gemeten_waterhoogte-west_terschelling-clean-UTC.csv"
# )
# 
# # load tide data
# tidal_pattern <- fread(tidal_pattern_fp)
# measured_water_height <- fread(measured_water_height_fp)
# 
# # subset relevant columns
# data <- data[ .(species posID tag time datetime x y tideID)]
# 
# # unique tag ID
# id <- unique(data$tag)
# 
# # loop through all tags to calculate residency patches
# data <- foreach(i = id .combine = "rbind") %do% {
#   atl_res_patch(
#     data[tag == i]
#     max_speed = 3 lim_spat_indep = 75 lim_time_indep = 180
#     min_fixes = 3 min_duration = 120
#   )
# }
# 
# 
# 
# 
# atl_check_res_patch(
#   data[tag == "3038"] tide_data = tidal_pattern
#   tide = "2023513" offset = 30
#   buffer_res_patches = 75
# )
# 
# 
# 
# tide_data = tidal_pattern
# tide_data_highres = measured_water_height
# tide = "2023513"
# offset = 30
# buffer_res_patches = 75
# buffer_bm = 250
# buffer_overview = 10000
# point_size = 1
# point_alpha = 0.5
# path_linewidth = 0.5
# path_alpha = 0.2
# patch_label_size = 4
# patch_label_padding = 1
# element_text_size = 11
# water_fill = "#D7E7FF"
# water_colour = "grey80"
# land_fill = "#faf5ef"
# land_colour = "grey80"
# mudflat_colour = "#faf5ef"
# mudflat_fill = "#faf5ef"
# mudflat_alpha = 0.6
# filename = NULL
# png_width = 3840
# png_height = 2160
# 
# 
