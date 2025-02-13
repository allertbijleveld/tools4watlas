

# Packages
library(tools4watlas)
library(ggplot2)
library(viridis)
library(scales)
library(ggtext)

# Path to csv with filtered data
data_path <- system.file(
  "extdata", "watlas_data_filtered.csv",
  package = "tools4watlas"
)

# Load data
data <- fread(data_path, yaml = TRUE)

# Subset bar-tailed godwit
data <- data[species == "bar-tailed godwit"]




atl_check_tag(data, option = "datetime")
atl_check_tag(data, option = "nbs")
atl_check_tag(data, option = "sd")
atl_check_tag(data, option = "gap")








atl_check_tag <- function(data = NULL,
                          buffer = 1000,
                          asp = "16:9",
                          option = "datetime",
                          point_size = 0.5,
                          point_alpha = 1,
                          path_linewidth = 0.5,
                          path_alpha = 0.1,
                          viridis_option = "A",
                          viridis_direction = -1) {
  # warning if more than one tag
  if (data$tag |> unique() |> length() > 1) {
    warning("Data includes multiple tag ID's, only the first is plotted")
  }

  # subset first if more than one tag
  ds <- data[tag == data[1]$tag]

  # collect relevant data for plot
  tag_id <- ds[1]$tag
  tag_species <- ds[1]$species
  tag_ring <- ds[1]$rings
  tag_crc <- ds[1]$crc
  tag_name <- ds[1]$bird_name
  year <- min(ds$datetime, na.rm = TRUE) |> year()
  first_data <- min(ds$datetime, na.rm = TRUE) |> format("%d %b %H:%M")
  last_data <- max(ds$datetime, na.rm = TRUE) |> format("%d %b %H:%M")
  days_data <- round(
    as.numeric(difftime(
      max(ds$datetime, na.rm = TRUE),
      min(ds$datetime, na.rm = TRUE),
      units = "days"
    )), 2
  )
  n <- nrow(ds)

  # longest gap
  ds[, gap := c(NA, diff(datetime))]
  ds[, gap_in := shift(gap, type = "lead")]
  min_gap <- min(ds$gap, na.rm = TRUE)
  ds[is.na(gap_in), gap_in := min_gap]
  max_gap <- max(ds$gap, na.rm = TRUE)
  max_gap_format <- if (max_gap > 86400) { # more than 1 day
    paste(round(max_gap / 86400, 2), "days")
  } else if (max_gap > 3600) { # more than 1 hour
    paste(round(max_gap / 3600, 2), "hours")
  } else { # less than 1 hour
    paste(round(max_gap / 60, 2), "min")
  }

  # sd
  ds[, sd := log10(pmax(varx, vary))]

  # create basemap
  bm <- atl_create_bm(ds, asp = asp, buffer = buffer)

  # add title
  p <- bm +
    ggtitle(
      label = paste(
        "<b>Tag:</b>", tag_id,
        "<span style='white-space:pre;'>    </span>",
        # add species if not NULL
        if (!is.null(tag_species)) {
          paste(
            "<b>Species:</b>", tag_species,
            "<span style='white-space:pre;'>    </span>"
          )
        } else {
          ""
        },
        # add ring if not NULL
        if (!is.null(tag_ring)) {
          paste(
            "<b>Ring:</b>", tag_ring,
            "<span style='white-space:pre;'>    </span>"
          )
        } else {
          ""
        },
        # add crc if not NULL
        if (!is.null(tag_crc)) {
          paste(
            "<b>Crc:</b>", tag_crc,
            "<span style='white-space:pre;'>    </span>"
          )
        } else {
          ""
        },
        # add name if not NULL
        if (!is.null(tag_name)) paste("<b>Name:</b>", tag_name) else ""
      ),
      subtitle = paste(
        "<b>Days data:</b>", days_data,
        "<span style='white-space:pre;'>    </span>",
        "<b>Year:</b>", year,
        "<span style='white-space:pre;'>    </span>",
        "<b>First:</b>", first_data,
        "<span style='white-space:pre;'>    </span>",
        "<b>Last:</b> ", last_data,
        "<span style='white-space:pre;'>    </span>",
        "<b>N localizations:</b> ", n,
        "<span style='white-space:pre;'>    </span>",
        "<b>Longest gap:</b> ", max_gap_format
      )
    )

  # add points and tracks with different options
  p <- switch(option,
    datetime = {
      # add tracks by datetime
      p +
        geom_path(
          data = ds, aes(x, y, colour = datetime),
          size = path_linewidth, alpha = path_alpha, show.legend = TRUE
        ) +
        geom_point(
          data = ds, aes(x, y, colour = datetime),
          size = point_size, alpha = point_alpha, show.legend = TRUE
        ) +
        scale_colour_viridis_c(
          option = viridis_option, direction = viridis_direction,
          trans = "time", labels = date_format("%d %b"),
          name = "Datetime"
        )
    },
    nbs = {
      # add tracks by nbs
      p +
        geom_path(
          data = ds, aes(x, y, colour = nbs),
          size = path_linewidth, alpha = path_alpha, show.legend = TRUE
        ) +
        geom_point(
          data = ds, aes(x, y, colour = nbs),
          size = point_size, alpha = point_alpha, show.legend = TRUE
        ) +
        scale_colour_viridis(
          option = viridis_option, direction = viridis_direction,
          name = "NBS"
        )
    },
    sd = {
      # add tracks by sd
      p +
        geom_path(
          data = ds, aes(x, y, colour = sd),
          size = path_linewidth, alpha = path_alpha, show.legend = TRUE
        ) +
        geom_point(
          data = ds, aes(x, y, colour = sd),
          size = point_size, alpha = point_alpha, show.legend = TRUE
        ) +
        scale_colour_viridis(
          option = viridis_option, direction = viridis_direction,
          name = "SD"
        )
    },
    gap = {
      # add tracks by gap
      p <- p +
        geom_path(
          data = ds, aes(x, y, colour = gap_in),
          size = path_linewidth, alpha = path_alpha, show.legend = TRUE
        ) +
        geom_point(
          data = ds[gap > 3600],
          aes(x, y, colour = gap_in, size = gap_in),
          alpha = point_alpha, show.legend = FALSE
        ) +
        geom_point(
          data = ds[gap < 3600],
          aes(x, y, colour = gap_in, size = gap_in),
          alpha = point_alpha, show.legend = FALSE
        ) +
        scale_size_continuous(
          range = c(0.5, 30), guide = "none",
          limits = c(NA, 86400)
        ) +
        scale_colour_viridis(
          option = viridis_option, direction = viridis_direction,
          name = "Gap", trans = "log",
          breaks = c(10, 60, 600, 3600, 86400),
          labels = c("10 sec", "1 min", "10 min", "1 hr", "1 day"),
          limits = c(NA, 86400)
        )
    },
    stop("Invalid option")
  )

  # add theme
  p <- p +
    theme(
      legend.key.height = unit(2, "cm"),
      legend.position = "right",
      plot.background = element_rect(fill = "white"),
      plot.margin = unit(c(0.5, 0, 0, 0), "lines"),
      plot.subtitle = element_markdown(hjust = 0.5),
      plot.title = element_markdown(hjust = 0.5)
    )

  return(p)
}
# ggsave("./test_check_plot.png",
#        plot = last_plot(), width = 3840, height = 2160, units = c("px"), dpi = 300
# )


