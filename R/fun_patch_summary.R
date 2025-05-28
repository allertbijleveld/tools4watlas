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

atl_patch_summary <- function(data,
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
    p1 <- sf::st_as_sf(df, coords = c("x", "y"))
    p2 <- sf::st_buffer(p1, dist = buffer)
    p2 <- sf::st_union(p2)
    p2 ## output polygons
  }))]

  return(data)

}
