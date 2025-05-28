#' Construct residence patches from position data
#'
#' A cleaned movement track of one individual at a time can be classified into
#'  residence patches using the
#' function \code{atl_res_patch}.
#' The function expects a specific organisation of the data: there should be
#' at least the following columns, \code{x}, \code{y}, and \code{time},
#' corresponding to the coordinates, and the time as \code{POSIXct}.
#' \code{atl_res_patch} requires only three parameters: (1) the maximum
#' speed threshold between localizations (called \code{max_speed}), (2) the
#' distance threshold between clusters of positions (called
#' \code{lim_spat_indep}), and (3) the time interval between clusters
#' (called \code{lim_time_indep}).Clusters formed of fewer than a minimum
#' number of positions can be excluded.The exclusion of clusters with few
#' positions can help in removing bias due to short stops, but if such short
#'  stops are also of interest, they can be included by reducing the
#'  \code{min_fixes} argument.
#'
#' @author Pratik R. Gupte, Christine E. Beardsworth & Allert I. Bijleveld &
#' Johannes Krietsch
#' @param data A dataframe of any class that is or extends data.frame of one
#' individual only. The dataframe must contain at least two spatial coordinates,
#' \code{x} and \code{y}, and a temporal coordinate, \code{time}.
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
#'
#' @return A data.table that has the added column
#' \code{patch} indicating the patch.
#' @import data.table
#' @export
atl_res_patch <- function(data,
                          max_speed = 3,
                          lim_spat_indep = 75,
                          lim_time_indep = 180,
                          min_fixes = 3,
                          min_duration = 120,
                          summary_variables = c(),
                          summary_functions = c()) {
  # Initialize necessary variables to avoid NSE (Non-Standard Evaluation) issues
  row_id <- newpatch <- nfixes <- patch <- speed <- tag <- duration <- NULL
  patchdata <- spat_diff <- time_diff_end_start <- i.patch <- NULL # nolint
  time <- time_diff <- time_end <- time_start <- spat_diff_end_start <- NULL

  # Validate input
  assertthat::assert_that(is.data.frame(data),
    msg = glue::glue("Input is not a data.frame or data.table, it has class
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

  # Create unique row ID
  data[, row_id := seq_len(nrow(data))]

  # Copy of original data
  data_original <- copy(data)

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
    data[, `:=`(nfixes, .N), by = c("tag", "patch")]
    data <- data[nfixes >= min_fixes]
    data[, `:=`(nfixes, NULL)] # remove nfixes-column
    # Subset by id and patch
    data <- data[, list(list(.SD)), by = list(tag, patch)]
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
      dt2
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
    ### new patch without speed filter & with spatial distance on end-strt
    patch_summary[, `:=`(newpatch, cumsum(
      (spat_diff > lim_spat_indep | time_diff_end_start > lim_time_indep) &
        (spat_diff_end_start > lim_spat_indep)
    ))]

    # Merge new patches with initial proto-patches
    patch_summary <- patch_summary[, list(patch, newpatch)]
    data <- data[, unlist(patchdata, recursive = FALSE), by = list(tag, patch)]
    data <- data.table::merge.data.table(data, patch_summary, by = "patch")
    data[, `:=`(patch = newpatch, newpatch = NULL)]

    # Add patch ID to original data
    data_original[data, on = "row_id", `:=`(patch = i.patch)]

    # Fill positions that where excluded from proto-patches
    # Apply forward and backward fill
    fwd <- zoo::na.locf(data_original$patch, na.rm = FALSE)
    bwd <- zoo::na.locf(data_original$patch, fromLast = TRUE, na.rm = FALSE)

    # Fill only where both directions agree
    data_original[, patch := ifelse(is.na(patch) & fwd == bwd, fwd, patch)]

    # Remove row_id
    data_original[, row_id := NULL]

    return(data_original)
  }, error = function(e) {
    message(glue::glue("there was an error in {unique(data$tag)}:\n
                       {as.character(e)}"))
  })
}
