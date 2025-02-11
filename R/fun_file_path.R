#' Get the file path for WATLAS or GIS data based on the user's name.
#'
#' This function returns a predefined file path based on the user's system
#' username and the selected data type.
#' Users must be predefined in the function.
#'
#' @param data_type A character string indicating the type of data. Options are:
#'   - `"watlas_teams"`: Path to WATLAS team data.
#'   - `"rasters"`: Path to raster GIS data.
#'   - `"shapefiles"`: Path to shapefile GIS data.
#'
#' @return A character string representing the full file path to the selected
#'   data type for the current user.
#' @export
#'
#' @examples
#' atl_file_path("watlas_teams")
#' atl_file_path("rasters")
#' atl_file_path("shapefiles")
atl_file_path <- function(data_type = c("watlas_teams",
                                          "rasters",
                                          "shapefiles")) {
  # get the username
  user_name <- Sys.info()[["user"]]

  # define the data type to be selected
  data_type <- match.arg(data_type)

  # use switch to select the file path based on the username
  path <- switch(user_name,
    "allert" = switch(data_type,
      "watlas_teams" = paste0(
        "C:/Users/allert/NIOZ/",
        "WATLAS_data/"
      ),
      "rasters" = paste0(
        "C:/Users/allert/NIOZ/",
        "Birds, fish 'n chips - Documenten/data/GIS/raster/"
      ),
      "shapefiles" = paste0(
        "C:/Users/allert/NIOZ/",
        "Birds, fish 'n chips - Documenten/data/GIS/shapefiles/"
      )
    ),
    "jkrietsch" = switch(data_type,
      "watlas_teams" = paste0(
        "C:/Users/jkrietsch/OneDrive - NIOZ/",
        "WATLAS_data/"
      ),
      "rasters" = paste0(
        "C:/Users/jkrietsch/OneDrive - NIOZ/",
        "Documents/map_data/"
      ),
      "shapefiles" = paste0(
        "C:/Users/jkrietsch/OneDrive - NIOZ/",
        "Documents/map_data/"
      )
    ),
    stop(
      "User not recognized, please add data for your user in this function ",
      "in tools4watlas or define the path to the folder directly."
    )
  )

  return(path)
}
