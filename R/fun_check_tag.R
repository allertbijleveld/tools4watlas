# 
# 
# # Packages
# library(tools4watlas)
# library(ggplot2)
# library(viridis)
# library(scales)
# 
# # Path to csv with filtered data
# data_path <- system.file(
#   "extdata", "watlas_data_filtered.csv",
#   package = "tools4watlas"
# )
# 
# # Load data
# data <- fread(data_path, yaml = TRUE)
# 
# 
# 
# # Subset bar-tailed godwit
# data <- data[species == "bar-tailed godwit"]
# 
# 
# # warning if more than one tag
# if (data$tag |> unique() |> length() > 1) {
#   warning("Data includes multiple tag ID's, only the first is plotted")
# }
# 
# # subset first if more than one tag
# ds <- data[tag == data[1]$tag]
# 
# # collect relevant data for plot
# tag_id <- ds[1]$tag
# tag_species <- ds[1]$species
# tag_name <- ds[1]$bird_name
# first_data <- min(ds$datetime, na.rm = TRUE) |> as.Date()
# last_data <- max(ds$datetime, na.rm = TRUE) |> as.Date()
# days_data <- round(
#   as.numeric(difftime(
#     max(ds$datetime, na.rm = TRUE),
#     min(ds$datetime, na.rm = TRUE),
#     units = "days"
#   )), 2
# )
# n <- nrow(ds)
# 
# # longest gap
# ds[, gap := c(NA, diff(datetime))]
# max_gap <- max(ds$gap, na.rm = TRUE)
# max_gap_format <- if (max_gap > 86400) {  # More than 1 day
#   paste(round(max_gap / 86400, 2), "days")
# } else if (max_gap > 3600) {  # More than 1 hour
#   paste(round(max_gap / 3600, 2), "hours")
# } else {  # Less than 1 hour
#   paste(round(max_gap / 60, 2), "min")
# }
# 
# 
# 
# # create basemap
# bm <- atl_create_bm(data, buffer = 800)
# 
# # Plot points and tracks
# bm +
#   ggtitle(label = paste("Tag:", tag_id, tag_species, tag_name),
#           subtitle = paste0("Days of data: ", days_data, " (", first_data, " to ", last_data, ")   N localizations: ", n, "   Longest gap: ", max_gap_format)) +
#   geom_path(
#     data = data, aes(x, y, colour = tag),
#     alpha = 0.1, show.legend = FALSE
#   ) +
#   geom_point(
#     data = data, aes(x, y, colour = tag),
#     size = 0.5, show.legend = FALSE
#   )
# 
# 
# bm +
#   ggtitle(label = paste("Tag:", tag_id, tag_species, tag_name),
#           subtitle = paste0("Days of data: ", days_data, " (", first_data, " to ", last_data, ")   N localizations: ", n, "   Longest gap: ", max_gap_format)) +
#   geom_path(
#     data = ds, aes(x, y, colour = gap),
#     alpha = 0.1, show.legend = FALSE
#   ) +
#   geom_point(
#     data = ds, aes(x, y, colour = gap),
#     size = 0.5, show.legend = FALSE
#   )
# 
# 
# 
# 
