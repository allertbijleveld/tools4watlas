#' Check the residency patches from one tag during one tide
#'
#' Generates a `ggplot2` showing bird residency patches per tideID, including
#' movement paths, patch durations, and an inset overview map.
#'
#' @author Johannes Krietsch
#' @param tag Bird tag ID to subset.
#' @param tide Tide ID to subset.
#' @param data A `data.table` containing tracking data. Must include the
#'   columns: `"tag"`, `"x"`, `"y"`, `"time"`,`"datetime"`, and `species`.
#' @param patch_data A `data.table` containing residency patch details as
#' created by `atl_res_patch()`.
#' @param tide_data Data on the timing (in UTC) of low and high tides.
#' @param offset The offset in minutes between the location of the tidal gauge
#' and the tracking area. This value will be added to the timing of the
#' water data.
#' @param buffer Map buffer size (default: 250).
#' @param buffer_overview Overview map buffer size (default: 10000).
#' @param point_size Size of plotted points (default: 1).
#' @param point_alpha Transparency of points (default: 0.5).
#' @param path_linewidth Line width of movement paths (default: 0.5).
#' @param path_alpha Transparency of movement paths (default: 0.2).
#' @param patch_label_size Font size for patch labels (default: 4).
#' @param patch_label_padding Padding for patch labels (default: 1).
#' @param element_text_size Font size for axis and legend text (default: 11).
#' @param water_fill Water fill (default "#D7E7FF")
#' @param water_colour Water coulour (default "grey80")
#' @param land_fill Land fill (default "#faf5ef")
#' @param land_colour Land colour (default "grey80")
#' @param mudflat_colour Mudflat colour (default "#faf5ef")
#' @param mudflat_fill Mudflat fill (default "#faf5ef")
#' @param mudflat_alpha Mudflat alpha (default 0.6)
#' @param filename Character (or NULL). If provided, the plot is saved as a
#'   `.png` file to this path and with this name; otherwise, the function
#'   returns the plot.
#' @param png_width Width of saved PNG (default: 3840).
#' @param png_height Height of saved PNG (default: 2160).
#'
#' @return A ggplot object or a saved PNG file.
#' @import patchwork
#' @importFrom ggtext element_markdown
#' @importFrom ragg agg_png
#' @export
atl_check_res_patch <- function(tag,
                                tide,
                                data,
                                patch_data,
                                tide_data,
                                offset = 0,
                                buffer = 250,
                                buffer_overview = 10000,
                                point_size = 1,
                                point_alpha = 0.5,
                                path_linewidth = 0.5,
                                path_alpha = 0.2,
                                patch_label_size = 4,
                                patch_label_padding = 1,
                                element_text_size = 11,
                                water_fill = "#D7E7FF",
                                water_colour = "grey80",
                                land_fill = "#faf5ef",
                                land_colour = "grey80",
                                mudflat_colour = "#faf5ef",
                                mudflat_fill = "#faf5ef",
                                mudflat_alpha = 0.6,
                                filename = NULL,
                                png_width = 3840,
                                png_height = 2160) {
  # global variables
  patch <- duration <- . <- time_median <- polygons <- time <- NULL
  x <- y <- datetime <- x_median <- y_median <- tideID <- NULL # nolint

  # assign tag and tideID new to avoid confusion
  tag_id <- tag
  tideID_id <- tide #nolint

  # check data structure
  atl_check_data(data, names_expected = c("tag", "x", "y", "time", "datetime"))
  atl_check_data(patch_data, names_expected = c(
    "tag", "patch", "x_median", "y_median", "duration"
  ))
  atl_check_data(tide_data, names_expected = c(
    "tideID", "low_time", "high_start_level", "low_level", "high_end_level"
  ))

  # convert to DT if not
  if (data.table::is.data.table(data) != TRUE) {
    data.table::setDT(data)
  }
  if (data.table::is.data.table(patch_data) != TRUE) {
    data.table::setDT(patch_data)
  }
  if (data.table::is.data.table(tide_data) != TRUE) {
    data.table::setDT(tide_data)
  }

  # subset first tag and tide if more than one tag
  ds <- data[tag == tag_id & tideID == tideID_id]

  # subset all patches linked to this tag and tide
  dp <- patch_data[tag == tag_id & patch %in% ds$patch]

  # subset tide pattern data
  dtp <- tide_data[tideID == tideID_id]

  # patch as factor
  ds[, patch := as.factor(patch)]
  dp[, patch := as.factor(patch)]

  # duration in mins
  ds[, duration := duration / 60]
  dp[, duration := duration / 60]

  # transform into sf object
  dp_sf <- dp[, .(
    duration,
    geometry = sf::st_sfc(unlist(polygons, recursive = FALSE))
  ), by = .(tag, patch)] |> sf::st_as_sf(crs = 32631)

  # set time without patch to 0
  ds[is.na(duration), duration := 0]

  # median time as POSIXct
  dp[, time_median := as.POSIXct(
    time_median,
    origin = "1970-01-01", tz = "UTC"
  )]

  # collect relevant data for plot
  tag_species <- ds[1]$species
  year <- min(ds$datetime, na.rm = TRUE) |> year()
  first_data <- min(ds$datetime, na.rm = TRUE) |> format("%d %b %H:%M")
  last_data <- max(ds$datetime, na.rm = TRUE) |> format("%d %b %H:%M")
  n <- nrow(ds)

  # create basemap and bounding box
  bm <- atl_create_bm(
    ds,
    water_fill = water_fill,
    water_colour = water_colour,
    land_fill = land_fill,
    land_colour = land_colour,
    mudflat_colour = mudflat_colour,
    mudflat_fill = mudflat_fill,
    mudflat_alpha = mudflat_alpha,
    asp = "4:3",
    buffer = buffer
  )
  bbox <- atl_bbox(ds, buffer = buffer, asp = "4:3")

  # plot on map
  p1 <- bm +
    # add patch polygons
    geom_sf(data = dp_sf, aes(fill = duration), alpha = 0.6) +
    viridis::scale_fill_viridis(
      option = "A", direction = -1, begin = 0.1,
      name = "Duration in\npatch (min)"
    ) +
    # add track and points
    geom_path(
      data = ds, aes(x, y),
      linewidth = path_linewidth, alpha = path_alpha
    ) +
    geom_point(
      data = ds[is.na(patch)], aes(x, y), size = point_size, color = "grey20",
      alpha = point_alpha, show.legend = FALSE
    ) +
    geom_point(
      data = ds[!is.na(patch)], aes(x, y, color = patch),
      size = point_size, show.legend = FALSE
    ) +
    # add labels for patches
    ggrepel::geom_text_repel(
      data = dp, aes(x_median, y_median, label = patch, colour = patch),
      size = patch_label_size, box.padding = patch_label_padding,
      fontface = "bold", show.legend = FALSE
    ) +
    # set extend again (overwritten by geom_sf)
    coord_sf(
      xlim = c(bbox["xmin"], bbox["xmax"]),
      ylim = c(bbox["ymin"], bbox["ymax"]), expand = FALSE
    ) +
    # adjust legend position
    theme(
      legend.position = "inside",
      legend.position.inside = c(.08, .18),
      legend.background = element_rect(fill = "transparent"),
      legend.title = element_text(face = "bold"),
      legend.text = element_text(size = element_text_size)
    )

  # add overview map
  bbox_sf <- bbox |> sf::st_as_sfc() |> sf::st_set_crs(32631)
  bbox2 <- atl_bbox(ds, buffer = buffer_overview, asp = "1:1")

  bm2 <- atl_create_bm(ds, buffer = buffer_overview, asp = "1:1") +
    # add small area
    geom_sf(data = bbox_sf, color = "firebrick3", fill = NA, lwd = 1) +
    # set extend again (overwritten by geom_sf)
    coord_sf(
      xlim = c(bbox2["xmin"], bbox2["xmax"]),
      ylim = c(bbox2["ymin"], bbox2["ymax"]), expand = FALSE
    )

  # add to map
  p1 <- p1 +
    patchwork::inset_element(bm2, left = 0.8, bottom = 0.8, right = 1, top = 1)

  # add plot by time and duration
  p2 <- ggplot() +
    # add low tide line
    geom_hline(
      yintercept = as.numeric(dtp$low_time)  + offset * 60,
      color = "dodgerblue3", linetype = "dashed"
    ) +
    # add high tide lines
    geom_hline(
      yintercept = as.numeric(dtp$high_start_time) + offset * 60,
      color = "dodgerblue3"
    ) +
    geom_hline(
      yintercept = as.numeric(dtp$high_end_time) + offset * 60,
      color = "dodgerblue3"
    ) +
    # add line and points
    geom_path(
      data = ds, aes(duration, time), color = "grey",
      show.legend = FALSE
    ) +
    geom_point(
      data = ds, aes(duration, time, color = as.character(patch)),
      size = point_size, alpha = 0.5, show.legend = FALSE
    ) +
    # add labels for patches
    geom_text(
      data = dp,
      aes(duration + 5, as.numeric(time_median), label = patch, colour = patch),
      size = 4, fontface = "bold", show.legend = FALSE
    ) +
    # flip y axis
    scale_y_reverse(
      breaks = seq(
        from = floor(min(as.numeric(dtp$high_start_time)) / 3600) * 3600,
        to = ceiling(max(as.numeric(dtp$high_end_time)) / 3600) * 3600,
        by = 3600 * 1
      ),
      labels = function(x) {
        format(as.POSIXct(x, origin = "1970-01-01"), "%H", tz = "UTC")
      }
    ) +
    labs(
      x = "Duration in patch (min)",
      y = "Hour (UTC)"
    ) +
    theme_bw() +
    theme(
      axis.text.x = element_text(size = element_text_size),
      axis.text.y = element_text(size = element_text_size)
    )

  # combine plots
  p <- p1 + p2 + patchwork::plot_layout(widths = c(3, 1.15)) +
    patchwork::plot_annotation(
      title = paste(
        "<b>Tag:</b>", tag_id,
        "<span style='white-space:pre;'>    </span>",
        "<b>Species:</b>", tag_species,
        "<span style='white-space:pre;'>    </span>",
        "<b>TideID:</b>", tideID_id
      ),
      subtitle = paste(
        "<b>Year:</b>", year,
        "<span style='white-space:pre;'>    </span>",
        "<b>First:</b>", first_data,
        "<span style='white-space:pre;'>    </span>",
        "<b>Last:</b>", last_data,
        "<span style='white-space:pre;'>    </span>",
        "<b>N localizations:</b>", n,
        "<span style='white-space:pre;'>    </span>",
        "<b>Waterlevel (HLH):</b>", dtp$high_start_level, " / ",
        dtp$low_level, " / ", dtp$high_end_level
      ),
      theme = theme(
        plot.subtitle = element_markdown(hjust = 0.5),
        plot.title = element_markdown(hjust = 0.5)
      )
    )

  # return or save
  if (is.null(filename)) {
    # return if no filename provided
    return(p)
  } else {
    # save the plot if filename provided
    agg_png(
      filename = paste0(filename, ".png"),
      width = png_width, height = png_height, units = "px", res = 300
    )
    print(p)
    dev.off()
  }
}
