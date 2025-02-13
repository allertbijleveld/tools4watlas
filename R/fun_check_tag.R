# 
# 
# # Packages
# library(tools4watlas)
# library(ggplot2)
# library(viridis)
# library(scales)
# library(ggtext)
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
# tag_ring <- ds[1]$rings
# tag_crc <- ds[1]$crc
# tag_name <- ds[1]$bird_name
# year <- min(ds$datetime, na.rm = TRUE) |> year()
# first_data <- min(ds$datetime, na.rm = TRUE) |> format("%d %b %H:%M")
# last_data <- max(ds$datetime, na.rm = TRUE) |> format("%d %b %H:%M")
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
# ds[, gap_in := shift(gap, type = "lead")]
# max_gap <- max(ds$gap, na.rm = TRUE)
# max_gap_format <- if (max_gap > 86400) {  # More than 1 day
#   paste(round(max_gap / 86400, 2), "days")
# } else if (max_gap > 3600) {  # More than 1 hour
#   paste(round(max_gap / 3600, 2), "hours")
# } else {  # Less than 1 hour
#   paste(round(max_gap / 60, 2), "min")
# }
# 
# # sd
# ds[, sd := log10(pmax(varx, vary))]
# 
# 
# 
# 
# # create basemap
# bm <- atl_create_bm(ds, asp = "16:9", buffer = 800)
# 
# # add title
# p <- bm +
#   ggtitle(
#     label = paste(
#       "<b>Tag:</b>", tag_id,
#       "<span style='white-space:pre;'>    </span>",
#       "<b>Species:</b>", tag_species,
#       "<span style='white-space:pre;'>    </span>",
#       # Add ring if not NULL
#       if (!is.null(tag_ring)) paste(
#         "<b>Ring:</b>", tag_ring, 
#         "<span style='white-space:pre;'>    </span>") else "",
#       # Add crc if not NULL
#       if (!is.null(tag_crc)) paste(
#         "<b>Crc:</b>", tag_crc,
#         "<span style='white-space:pre;'>    </span>") else "",
#       # Add name if not NULL
#       if (!is.null(tag_name)) paste("<b>Name:</b>", tag_name) else ""
#     ),
#     subtitle = paste(
#       "<b>Days data:</b>", days_data,
#       "<span style='white-space:pre;'>    </span>",
#       "<b>Year:</b>", year,
#       "<span style='white-space:pre;'>    </span>",
#       "<b>First:</b>", first_data,
#       "<span style='white-space:pre;'>    </span>",
#       "<b>Last:</b> ", last_data,
#       "<span style='white-space:pre;'>    </span>",
#       "<b>N localizations:</b> ", n,
#       "<span style='white-space:pre;'>    </span>",
#       "<b>Longest gap:</b> ", max_gap_format
#     )
#   )
# 
# # add tracks by datetime
# # p <- p +
# #   geom_path(
# #     data = ds, aes(x, y, colour = datetime),
# #     alpha = 0.1, show.legend = TRUE
# #   ) +
# #   geom_point(
# #     data = ds, aes(x, y, colour = datetime),
# #     size = 0.5, show.legend = TRUE
# #   ) +
# #   scale_colour_viridis_c(
# #     option = "D", direction = -1, 
# #     trans = "time", labels = date_format("%d %b"),
# #     name = "Datetime"
# #   )
# 
# # add tracks by nbs
# # p <- p +
# #   geom_path(
# #     data = ds, aes(x, y, colour = nbs),
# #     alpha = 0.1, show.legend = TRUE
# #   ) +
# #   geom_point(
# #     data = ds, aes(x, y, colour = nbs),
# #     size = 0.5, show.legend = TRUE
# #   ) +
# #   scale_colour_viridis(
# #     option = "D", direction = -1, 
# #     name = "NBS"
# #   )
# 
# # add tracks by sd
# # p <- p +
# #   geom_path(
# #     data = ds, aes(x, y, colour = sd),
# #     alpha = 0.1, show.legend = TRUE
# #   ) +
# #   geom_point(
# #     data = ds, aes(x, y, colour = sd),
# #     size = 0.5, show.legend = TRUE
# #   ) +
# #   scale_colour_viridis(
# #     option = "D", direction = -1, 
# #     name = "SD"
# #   )
# 
# # add tracks by gap
# p <- p +
#   geom_path(
#     data = ds, aes(x, y, colour = gap_in),
#     alpha = 0.1, show.legend = TRUE
#   ) +
#   geom_point(
#     data = ds, aes(x, y, colour = gap_in),
#     size = 0.5, show.legend = TRUE
#   ) +
#   scale_colour_viridis(
#     option = "D", direction = -1,
#     name = "Gap"
#   )
# 
# 
# # add theme
# p <- p +
#   theme(
#     legend.key.height = unit(2, "cm"),
#     legend.position = "right",
#     plot.background = element_rect(fill = "white"),
#     plot.margin = unit(c(0.5, 0, 0, 0), "lines"),
#     plot.subtitle = element_markdown(hjust = 0.5),
#     plot.title = element_markdown(hjust = 0.5)
#   )
# 
# p
# 
# ggsave("./test_check_plot.png",
#        plot = last_plot(), width = 3840, height = 2160, units = c("px"), dpi = 300
# )
# 
# 
