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
#   fp, "waterdata/allYears-tidalPattern-west_terschelling-UTC.csv"
# )
# measured_water_height_fp <- paste0(
#   fp, "waterdata/allYears-gemeten_waterhoogte-west_terschelling-clean-UTC.csv"
# )
# 
# # load tide data
# tidal_pattern <- fread(tidal_pattern_fp)
# measured_water_height <- fread(measured_water_height_fp)
# 
# # subset relevant columns
# data <- data[, .(species, posID, tag, time, datetime, x, y, tideID)]
# 
# # unique tag ID
# id <- unique(data$tag)
# 
# # loop through all tags to calculate residency patches
# data <- foreach(i = id, .combine = "rbind") %do% {
#   atl_res_patch(
#     data[tag == i],
#     max_speed = 3, lim_spat_indep = 75, lim_time_indep = 180,
#     min_fixes = 3, min_duration = 120
#   )
# }
# 
# 
# 
# 
# atl_check_res_patch(
#   data[tag == "3038"], tide_data = tidal_pattern,
#   tide = "2023513", offset = 30,
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
# 
# # subset first if more than one tag
# ds <- data[tag == data[1]$tag]
# 
# # assign tag and tideID new to avoid confusion
# tag_id <- ds[1]$tag
# tideID_id <- tide #nolint
# 
# # create patch summary
# dp <- atl_res_patch_summary(ds)
# 
# # subset all data linked to this tide
# ds <- ds[tideID == tideID_id]
# dp <- dp[patch %in% unique(ds$patch)]
# 
# # check if data for this period and tide
# if (nrow(ds) == 0) {
#   stop(paste0(
#     "No data for this tag and tide."
#   ))
# }
# 
# # subset tide pattern data
# dtp <- tide_data[tideID == tideID_id]
# 
# # patch as factor
# ds[, patch := as.factor(patch)]
# dp[, patch := as.factor(patch)]
# 
# # join duration to ds
# ds[dp, on = .(tag, patch), `:=`(duration = i.duration)]
# 
# # duration in mins
# ds[, duration := duration / 60]
# dp[, duration := duration / 60]
# 
# # transform into sf object
# dp_sf <- atl_as_sf(ds, option = "res_patches", buffer = buffer_res_patches)
# 
# # add duration
# dp_sf <- dp_sf %>%
#   dplyr::left_join(dp[, .(tag, patch, duration)], by = c("tag", "patch"))
# 
# # set time without patch to 0
# ds[is.na(duration), duration := 0]
# 
# # median time as POSIXct
# dp[, time_median := as.POSIXct(
#   time_median,
#   origin = "1970-01-01", tz = "UTC"
# )]
# 
# # collect relevant data for plot
# tag_species <- ds[1]$species
# year <- min(ds$datetime, na.rm = TRUE) |> year()
# first_data <- min(ds$datetime, na.rm = TRUE) |> format("%d %b %H:%M")
# last_data <- max(ds$datetime, na.rm = TRUE) |> format("%d %b %H:%M")
# n <- nrow(ds)
# 
# # create basemap and bounding box
# bm <- atl_create_bm(
#   ds,
#   water_fill = water_fill,
#   water_colour = water_colour,
#   land_fill = land_fill,
#   land_colour = land_colour,
#   mudflat_colour = mudflat_colour,
#   mudflat_fill = mudflat_fill,
#   mudflat_alpha = mudflat_alpha,
#   asp = "4:3",
#   buffer = buffer_bm
# )
# bbox <- atl_bbox(ds, buffer = buffer_bm, asp = "4:3")
# 
# # plot on map
# p1 <- bm +
#   # add patch polygons
#   geom_sf(data = dp_sf, aes(fill = duration), alpha = 0.6) +
#   viridis::scale_fill_viridis(
#     option = "A", direction = -1, begin = 0.1,
#     name = "Duration in\npatch (min)"
#   ) +
#   # add track and points
#   geom_path(
#     data = ds, aes(x, y),
#     linewidth = path_linewidth, alpha = path_alpha
#   ) +
#   geom_point(
#     data = ds[is.na(patch)], aes(x, y), size = point_size, color = "grey20",
#     alpha = point_alpha, show.legend = FALSE
#   ) +
#   geom_point(
#     data = ds[!is.na(patch)], aes(x, y, color = patch),
#     size = point_size, show.legend = FALSE
#   ) +
#   # add labels for patches
#   ggrepel::geom_text_repel(
#     data = dp, aes(x_median, y_median, label = patch, colour = patch),
#     size = patch_label_size, box.padding = patch_label_padding,
#     fontface = "bold", show.legend = FALSE
#   ) +
#   # set extend again (overwritten by geom_sf)
#   coord_sf(
#     xlim = c(bbox["xmin"], bbox["xmax"]),
#     ylim = c(bbox["ymin"], bbox["ymax"]), expand = FALSE
#   ) +
#   # adjust legend position
#   theme(
#     legend.position = "inside",
#     legend.position.inside = c(.08, .18),
#     legend.background = element_rect(fill = "transparent"),
#     legend.title = element_text(face = "bold"),
#     legend.text = element_text(size = element_text_size)
#   )
# 
# # add overview map
# bbox_sf <- bbox |> sf::st_as_sfc() |> sf::st_set_crs(32631)
# bbox2 <- atl_bbox(ds, buffer = buffer_overview, asp = "1:1")
# 
# bm2 <- atl_create_bm(ds, buffer = buffer_overview, asp = "1:1") +
#   # add small area
#   geom_sf(data = bbox_sf, color = "firebrick3", fill = NA, lwd = 1) +
#   # set extend again (overwritten by geom_sf)
#   coord_sf(
#     xlim = c(bbox2["xmin"], bbox2["xmax"]),
#     ylim = c(bbox2["ymin"], bbox2["ymax"]), expand = FALSE
#   )
# 
# 
# # add to map
# p1 <- p1 +
#   patchwork::inset_element(bm2, left = 0.8, bottom = 0.8, right = 1, top = 1)
# 
# 
# 
# 
# 
# 
# 
# 
# # subset tide data
# dtf <- tide_data_highres[
#   dateTime > dtp$high_start_time & dateTime < dtp$high_end_time
# ]
# 
# 
# 
# 
# p2 <- ggplot() +
#   geom_point(data = ds,
#              mapping = aes(x = waterlevel*2,
#                            y = time)) +
#   geom_hline(
#     yintercept = as.numeric(dtp$low_time)  + offset * 60,
#     color = "dodgerblue3", linetype = "dashed"
#   ) +
#   # add high tide lines
#   geom_hline(
#     yintercept = as.numeric(dtp$high_start_time) + offset * 60,
#     color = "dodgerblue3"
#   ) +
#   geom_hline(
#     yintercept = as.numeric(dtp$high_end_time) + offset * 60,
#     color = "dodgerblue3"
#   ) +
#   # add line and points
#   geom_path(
#     data = ds, aes(duration, time), color = "grey",
#     show.legend = FALSE
#   ) +
#   geom_point(
#     data = ds, aes(duration, time, color = as.character(patch)),
#     size = point_size, alpha = 0.5, show.legend = FALSE
#   ) +
#   # add labels for patches
#   geom_text(
#     data = dp,
#     aes(duration + 5, as.numeric(time_median), label = patch, colour = patch),
#     size = 4, fontface = "bold", show.legend = FALSE
#   ) +
#   # flip y axis
#   scale_y_reverse(
#     breaks = seq(
#       from = floor(min(as.numeric(dtp$high_start_time)) / 3600) * 3600,
#       to = ceiling(max(as.numeric(dtp$high_end_time)) / 3600) * 3600,
#       by = 3600 * 1
#     ),
#     labels = function(x) {
#       format(as.POSIXct(x, origin = "1970-01-01"), "%H", tz = "UTC")
#     }
#   ) +
#   labs(
#     x = "Duration in patch (min)",
#     y = "Hour (UTC)"
#   ) +
#   theme_bw() +
#   theme(
#     axis.text.x = element_text(size = element_text_size),
#     axis.text.y = element_text(size = element_text_size)
#   ) +
#   scale_x_continuous(
#     name = "Duration in patch (min)",
#     sec.axis = sec_axis(~ (.)/2, name = "Waterlevel",
#                         breaks = pretty(c(min(ds$waterlevel), 
#                                           max(ds$waterlevel)), n = 10))
#   )
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
