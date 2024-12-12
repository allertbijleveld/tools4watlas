#' Construct residence patches from position data
#'
#' A cleaned movement track of one individual at a time can be classified into
#'  residence patches using the
#' function \code{atl_res_patch_speed}.
#' The function expects a specific organisation of the data: there should be
#' at least the following columns, \code{X}, \code{Y}, and \code{time},
#' corresponding to the coordinates, and the time as \code{POSIXct}.
#' \code{atl_res_patch_speed} requires only three parameters: (1) the maximum
#' speed threshold between localizations (called \code{max_speed}), (2) the
#' distance threshold between clusters of positions (called
#' \code{lim_spat_indep}), and (3) the time interval between clusters
#' (called \code{lim_time_indep}).Clusters formed of fewer than a minimum
#' number of positions can be excluded.The exclusion of clusters with few
#' positions can help in removing bias due to short stops, but if such short
#'  stops are also of interest, they can be included by reducing the
#'  \code{min_fixes} argument. Position covariates such as speed may also be
#'  summarised patch-wise by passing covariate names and  summary functions as
#'  character vectors to the \code{summary_variables} and
#'  \code{summary_functions} arguments, respectively.
#'
#' @author Pratik R. Gupte, Christine E. Beardsworth & Allert I. Bijleveld
#' @param data A dataframe of any class that is or extends data.frame of one
#' individual only. The dataframe must contain at least two spatial coordinates,
#' \code{X} and \code{Y}, and a temporal coordinate, \code{time}.
#' @param max_speed A numeric value specifying the maximum speed (m/s) between
#' two coordinates that would be considered non-transitory
#' @param lim_spat_indep A numeric value of distance in metres of the spatial
#' distance between two patches for them to the considered independent.
#' @param lim_time_indep A numeric value of time in minutes of the time
#' difference between two patches for them to be considered independent.
#' @param min_fixes The minimum number of fixes for a group of
#' spatially-proximate number of ponts to be considered a preliminary residence
#' patch.
#' @param min_duration The minimum duration (in seconds) for classifying
#' residence patches.
#' @param summary_variables Optional variables for which patch-wise summary
#' values are required. To be passed as a character vector.
#' @param summary_functions The functions with which to summarise the summary
#' variables; must return only a single value, such as median, mean etc. To be
#' passed as a character vector.
#'
#' @return A data.frame extension object. This dataframe has the added column
#' \code{patch}, \code{patchdata}, and \code{polygons}, indicating the patch
#' identity, the localization data used to construct the patch, and the polygons
#' of residence patches based on the \code{lim_spat_indep}. In addition, there
#' are columns with patch summaries: nfixes, dist_in_patch, dist_bw_patch and
#' statistics based on the \code{summary_variables} and \code{summary_functions}
#' provided.
#' summary variables.
#' @import data.table
#' @examples
#' require(data.table)
#' require(ggplot2)
#'
#' # Load data
#' d <- atl_get_data_csv() |> data.table()
#' setnames(d, c("X", "Y"), c("x", "y"))
#'
#' # Calculate residency patches
#' rp <- atl_res_patch_speed(
#'   d,
#'   max_speed = 3, lim_spat_indep = 75, lim_time_indep = 180, min_fixes = 3,
#'   min_duration = 120,
#'   summary_functions = c("mean", "median", "sd", "min", "max", "first", "last")
#' )
#'
#' # Extract data from all residency patches
#' dr <- rp[, rbindlist(lapply(patchdata, function(x) cbind(x))), by = patch]
#'
#' # Merge with data
#' d <- merge(d, dr[, .(TAG, posID, patch)], by = c("TAG", "posID"), all.x = TRUE)
#'
#' # Plot data
#' ggplot(d) +
#'   geom_path(aes(x, y), alpha = 0.1) +
#'   geom_point(aes(x, y, color = as.character(patch)), show.legend = FALSE) +
#'   theme_bw()
#' @export
atl_res_patch_speed <- function(data,
                                max_speed = 3,
                                lim_spat_indep = 75,
                                lim_time_indep = 180,
                                min_fixes = 3,
                                min_duration = 120,
                                summary_variables = c(),
                                summary_functions = c()) {
  # Initialize necessary variables to avoid NSE (Non-Standard Evaluation) issues
  disp_in_patch <- dist_bw_patch <- dist_in_patch <- duration <- NULL
  newpatch <- nfixes <- patch <- speed <- tag <- . <- NULL
  patchdata <- polygons <- spat_diff <- time_diff_end_start <- NULL
  time <- time_diff <- time_end <- time_start <- spat_diff_end_start <- NULL
  x_end <- x_start <- y_end <- y_start <- time_bw_patch <- NULL

  # Validate input
  assertthat::assert_that(is.data.frame(data),
    msg = glue::glue("Input is not a data.frame, it has class
                     {stringr::str_flatten(class(data), collapse = ' ')}")
  )
  assertthat::assert_that(
    all(c(max_speed, lim_spat_indep, lim_time_indep, min_fixes) > 0),
    msg = "All input parameters must be positive"
  )
  lim_time_indep <- lim_time_indep * 60 # Convert to seconds

  # Check data structure
  required_columns <- c("x", "y", "time")
  atl_check_data(data, names_expected = required_columns)

  # Convert data to data.table if not already
  if (!is.data.table(data)) {
    data.table::setDT(data)
  }
  data.table::setorderv(data, "time")

  # Ensure data is ordered by time
  assertthat::assert_that(min(diff(data$time)) >= 0,
    msg = "Data for segmentation is not ordered by time"
  )

  tryCatch(expr = {
    # Calculate spatial and time differences
    data[, `:=`(
      spat_diff = atl_simple_dist(data = data, x = "x", y = "y"),
      time_diff = c(Inf, as.numeric(diff(time)))
    )]
    data[1, c("spat_diff")] <- Inf
    data[, `:=`(speed = spat_diff / time_diff)]
    data[1, c("speed")] <- Inf

    # Create proto-patches based on thresholds
    data[, `:=`(patch, cumsum(speed > max_speed | spat_diff >
      lim_spat_indep | time_diff > lim_time_indep))]

    # Filter based on minimum fixes
    data[, `:=`(nfixes, .N), by = c("tag", "patch")] # .N provides the number of rows in a group
    data <- data[nfixes >= min_fixes]
    data[, `:=`(nfixes, NULL)] # remove nfixes-column
    data <- data[, list(list(.SD)), by = list(tag, patch)] # Subset Data by id and patch
    setnames(data, old = "V1", new = "patchdata")
    data[, `:=`(nfixes, as.integer(lapply(patchdata, nrow)))]

    # Summarize patch data
    data[, `:=`(patch_summary, lapply(patchdata, function(dt) {
      dt2 <- dt[, unlist(lapply(.SD, function(d) {
        list(
          median = as.double(stats::median(d)),
          start = as.double(data.table::first(d)),
          end = as.double(data.table::last(d))
        )
      }), recursive = FALSE), .SDcols = c("x", "y", "time")]
      setnames(dt2, stringr::str_replace(colnames(dt2), "\\.", "_"))
      return(dt2)
    }))]

    patch_summary <- data[, unlist(patch_summary, recursive = FALSE),
      by = list(tag, patch)
    ]
    data[, `:=`(patch_summary, NULL)]

    # Calculate duration in patch and filter for minimal duration
    patch_summary[, `:=`(duration, as.numeric(time_end) -
      as.numeric(time_start))]
    patch_summary <- patch_summary[duration > min_duration]

    # Recalculate variables for merging residence patches e.g. distances,
    # time, speed
    # time and distance between patches (between end and start)
    patch_summary[, `:=`(
      time_diff_end_start,
      c(Inf, as.numeric(time_start[2:length(time_start)] -
        time_end[seq_len(length(time_end) - 1)]))
    )]
    patch_summary[, `:=`(
      spat_diff_end_start,
      c(atl_patch_dist(
        data = patch_summary,
        x1 = "x_end", x2 = "x_start",
        y1 = "y_end", y2 = "y_start"
      ))
    )]
    patch_summary[1, "spat_diff_end_start"] <- Inf
    patch_summary[, `:=`(
      speed_between_patches_end_start =
        patch_summary$spat_diff_end_start / patch_summary$time_diff_end_start
    )]
    patch_summary[1, "speed_between_patches_end_start"] <- Inf

    ## calculate distance between patches based on MEDIAN locations
    patch_summary[, `:=`(spat_diff, c(atl_patch_dist(
      data = patch_summary,
      x1 = "x_median", x2 = "x_median",
      y1 = "y_median", y2 = "y_median"
    )))]
    patch_summary[1, "spat_diff"] <- Inf
    patch_summary[, `:=`(
      speed_between_patches_medianxy =
        patch_summary$spat_diff /
          patch_summary$time_diff_end_start
    )]
    patch_summary[1, "speed_between_patches_medianxy"] <- Inf

    ## create  residence patches on new criteria
    ### newpatch without speed filter & with spatial distance on end-strt
    patch_summary[, `:=`(newpatch, cumsum(
      (spat_diff > lim_spat_indep | time_diff_end_start > lim_time_indep) &
        (spat_diff_end_start > lim_spat_indep)
    ))]

    # Merge new patches with initial proto-patches
    patch_summary <- patch_summary[, list(patch, newpatch)]
    data <- data[, unlist(patchdata, recursive = FALSE), by = list(tag, patch)]
    data <- data.table::merge.data.table(data, patch_summary, by = "patch")
    data[, `:=`(patch = newpatch, newpatch = NULL)]
    data <- data[, list(list(.SD)), by = .(tag, patch)]
    setnames(data, old = "V1", new = "patchdata")
    data[, `:=`(nfixes, as.integer(lapply(patchdata, nrow)))]

    # Summarize and create output
    data[, `:=`(patch_summary, lapply(patchdata, function(dt) {
      dt2 <- dt[, unlist(lapply(.SD, function(d) {
        list(
          mean = as.double(mean(d)),
          median = as.double(stats::median(d)),
          start = as.double(data.table::first(d)),
          end = as.double(data.table::last(d))
        )
      }), recursive = FALSE), .SDcols = c("x", "y", "time")]
      setnames(dt2, stringr::str_replace(colnames(dt2), "\\.", "_"))
      if (length(summary_variables) > 0) {
        dt3 <- data.table::dcast(dt, 1 ~ 1,
          fun.aggregate = eval(lapply(summary_functions, as.symbol)),
          value.var = summary_variables
        )
        dt3[, `:=`(., NULL)]
        return(cbind(dt2, dt3))
      } else {
        return(dt2)
      }
    }))]

    ## Create patch values
    data[, `:=`(dist_in_patch, as.double(lapply(patchdata, function(df) {
      sum(atl_simple_dist(data = df), na.rm = TRUE)
    })))]
    temp_data <- data[, unlist(patch_summary, recursive = FALSE),
      by = list(tag, patch)
    ]
    data[, `:=`(patch_summary, NULL)]
    data[, `:=`(dist_bw_patch, atl_patch_dist(
      data = temp_data,
      x1 = "x_end", x2 = "x_start",
      y1 = "y_end", y2 = "y_start"
    ))]

    temp_data[, `:=`(
      time_bw_patch,
      c(NA, as.numeric(time_start[2:length(time_start)] -
        time_end[seq_len(length(time_end) - 1)]))
    )]
    temp_data[, `:=`(disp_in_patch, sqrt((x_end - x_start)^2 +
      (y_end - y_start)^2))]
    temp_data[, `:=`(duration, (time_end - time_start))]
    data <- data.table::merge.data.table(data, temp_data,
      by = c("tag", "patch")
    )
    assertthat::assert_that(
      !is.null(data),
      msg = "make_patch: patch has no data"
    )

    # add polygons with buffer around localizations per residency patch
    data[, `:=`(polygons, lapply(patchdata, function(df) {
      p1 <- sf::st_as_sf(df, coords = c("x", "y"))
      p2 <- sf::st_buffer(p1, dist = lim_spat_indep)
      p2 <- sf::st_union(p2)
      return(p2) ## output polygons
    }))]

    return(data)
  }, error = function(e) {
    message(glue::glue("there was an error in {unique(data$tag)}:\n
                       {as.character(e)}"))
  })
}
