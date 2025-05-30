#' Summary of patch data
#'
#' The function \code{atl_patch_summary} can be used to extract patch-specific
#' summary data such as the median coordinates, the patch duration, the distance
#' travelled within the patch, the displacement within the patch, and the patch
#' area. Position covariates such as speed may also be
#' summarised patch-wise by passing covariate names and  summary functions as
#' character vectors to the \code{summary_variables} and
#' \code{summary_functions} arguments, respectively.


#' @param buffer A numeric value (in meters) specifying the buffer distance for
#' the bounding box. Default is 15 m, but could for example be
#' \code{lim_spat_indep} of the residency patch calculation.
#' @param data A data.table including .....
#' \code{x} and \code{y}, and a temporal coordinate, \code{time}.
#' @param summary_variables Optional variables for which patch-wise summary
#' values are required. To be passed as a character vector.
#' @param summary_functions The functions with which to summarise the summary
#' variables; must return only a single value, such as median, mean etc. To be
#' passed as a character vector.
#' @return A data.table that has the added column
#' \code{patch}, \code{patchdata}, and \code{polygons}, indicating the patch
#' identity, the localization data used to construct the patch, and the polygons
#' of residence patches based on the \code{lim_spat_indep}. In addition, there
#' are columns with patch summaries: nfixes, dist_in_patch, dist_bw_patch and
#' statistics based on the \code{summary_variables} and \code{summary_functions}
#' provided.
#' @import data.table
#' @export

atl_patch_summary_old <- function(data,
                              buffer = 15,
                              summary_variables = c(),
                              summary_functions = c()) {
  # Initialize necessary variables to avoid NSE (Non-Standard Evaluation) issues
  disp_in_patch <- dist_bw_patch <- dist_in_patch <- duration <- NULL
  nfixes <- patch <- tag <- . <- patchdata <- polygons <- NULL
  time_end <- time_start <- patch_summary <- NULL
  x_end <- x_start <- y_end <- y_start <- time_bw_patch <- NULL

  # Validate input
  assertthat::assert_that(is.data.frame(data),
    msg = glue::glue("Input is not a data.frame or data.table, it has class
                     {stringr::str_flatten(class(data), collapse = ' ')}")
  )

  # Check data structure
  required_columns <- c("tag", "x", "y", "time", "patch")
  atl_check_data(data, names_expected = required_columns)

  # Convert data to data.table if not already
  if (!is.data.table(data)) {
    data.table::setDT(data)
  }

  # Table with rows for each patch
  data <- data[!is.na(patch), list(list(.SD)), by = .(tag, patch)]
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
      cbind(dt2, dt3)
    } else {
      dt2
    }
  }))]

  # Create patch values
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
    p1 <- sf::st_as_sf(df, coords = c("x", "y"), crs = 32631)
    p2 <- sf::st_buffer(p1, dist = buffer)
    p2 <- sf::st_union(p2)
    p2 ## output polygons
  }))]
  
  # # Check for multipolygons and throw error if any
  # has_multipolygon <- any(sapply(data$polygons, function(poly) {
  #   any(st_geometry_type(poly) == "MULTIPOLYGON")
  # }))
  # 
  # if (has_multipolygon) {
  #   stop("Error: Some polygons are MULTIPOLYGONs, expected only single polygons.")
  # }

  return(data)

}










# load example data
data <- data_example

# select one individual
data <- data[tag == 3038]

# Calculate residency patches
data <- atl_res_patch(
  data[, .(tag, posID, time, datetime, x, y, speed_in, tideID)],
  max_speed = 3, lim_spat_indep = 50, lim_time_indep = 180,
  min_fixes = 3, min_duration = 180
)



atl_patch_summary2 <- function(data,
                              buffer = 15,
                              summary_variables = c(),
                              summary_functions = c()) {
  # Initialize necessary variables to avoid NSE (Non-Standard Evaluation) issues
  disp_in_patch <- dist_bw_patch <- dist_in_patch <- duration <- NULL
  nfixes <- patch <- tag <- . <- patchdata <- polygons <- NULL
  time_end <- time_start <- patch_summary <- NULL
  x_end <- x_start <- y_end <- y_start <- time_bw_patch <- NULL
  
  # Validate input
  assertthat::assert_that(is.data.frame(data),
    msg = glue::glue("Input is not a data.frame or data.table, it has class
                     {stringr::str_flatten(class(data), collapse = ' ')}")
  )
  
  # Check data structure
  required_columns <- c("tag", "x", "y", "time", "patch")
  atl_check_data(data, names_expected = required_columns)
  
  # Convert data to data.table if not already
  if (!is.data.table(data)) {
    data.table::setDT(data)
  }
  
  # Exclude NA
  d <- data[!is.na(patch)]
  
  # Basic summaries
  ds <- d[, .(
    nfixes = .N,
    x_mean = mean(x),
    x_median = median(x),
    x_start = first(x),
    x_end = last(x),
    y_mean = mean(y),
    y_median = median(y),
    y_start = first(y),
    y_end = last(y),
    time_mean = mean(time),
    time_median = median(time),
    time_start = first(time),
    time_end = last(time)
  ), by = .(tag, patch)]
  
  # Additional summaries dynamically if any
  if (length(summary_variables) > 0) {
    extra_summaries <- d[, lapply(summary_variables, function(var) {
      lapply(summary_functions, function(fn) {
        fun <- match.fun(fn)
        fun(get(var))
      })
    }), by = .(tag, patch)]
    ds <- merge(
      ds, extra_summaries,
      by = c("tag", "patch"), all.x = TRUE
    )
  }
  
  # Distances inside patch
  dist_in_patch_dt <- d[, .(
    dist_in_patch = sum(sqrt(diff(x)^2 + diff(y)^2), na.rm = TRUE)
  ), by = .(tag, patch)]
  ds[dist_in_patch_dt, on = .(tag, patch), dist_in_patch := i.dist_in_patch]
  
  # Distances between patches, time between patches
  setorder(ds, tag, time_start)
  ds[, dist_bw_patch := sqrt((x_start - shift(x_end))^2 +
    (y_start - shift(y_end))^2), by = tag]
  ds[, time_bw_patch := time_start - shift(time_end), by = tag]
  
  # Displacement and duration
  ds[, disp_in_patch := sqrt((x_end - x_start)^2 + (y_end - y_start)^2)]
  ds[, duration := time_end - time_start]
  
  # Polygons with buffer around points per patch
  polygons_list <- d[, {
    pts <- sf::st_as_sf(.SD, coords = c("x", "y"), crs = 32631)
    buffered <- sf::st_buffer(pts, dist = buffer)
    list(sf::st_union(buffered))
  }, by = .(tag, patch)]
  
  ds <- merge(ds, polygons_list, by = c("tag", "patch"), all.x = TRUE)
  setnames(ds, "V1", "polygons")
  
  return(ds)
  
  
  
  
  # # Check for multipolygons and throw error if any
  # has_multipolygon <- any(sapply(data$polygons, function(poly) {
  #   any(st_geometry_type(poly) == "MULTIPOLYGON")
  # }))
  # 
  # if (has_multipolygon) {
  #   stop("Error: Some polygons are MULTIPOLYGONs, expected only single polygons.")
  # }
  

}












