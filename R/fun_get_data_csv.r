#' Get data from a local csv file
#'
#' Adjusted version of \code{read.csv()} to conveniently load WATLAS data from
#' a csv file. To read large csv files efficiently, the functions uses the
#' package \code{data.table} but the output is converted to a data frame.
#'
#' @author Allert Bijleveld
#' @param fpath The full path (including path and file name) of the csv file.
#' If left empty, the example data file supplied with \code{tools4watlas} will
#' be used.
#' @returns A formatted dataframe of the csv file with the columns: \cr
#' PosID	=	Unique number for localizations \cr
#' TAG 		=	11 digit WATLAS tag ID (numeric) \cr
#' tag		=	4 digit tag number (character) \cr
#' TIME		=	UNIX time (seconds) \cr
#' time 	= 	Timestamp in POSIXct (UTC) \cr
#' X		=	X-ccordinates in meters (utm 31 N) 	 \cr
#' Y		=	Y-ccordinates in meters (utm 31 N) 	 \cr
#' NBS		=	Number of Base Stations used in calculating coordinates  \cr
#' VARX		=	Variance in estimating X-coordinates \cr
#' VARY		=	Variance in estimating Y-coordinates \cr
#' COVXY	=	Co-variance between X- and Y-coordinates \cr
#' @import data.table stringr
#' @export
atl_get_data_csv <-
  function(fpath = system.file(
    "extdata", "redknot_2707_WATLAS_exampledata.csv",
    package = "tools4watlas"
    )) {
    print(stringr::str_glue("Reading file: {fpath}"))

    # read data
    data <- data.table::fread(fpath)

    ## check required tag column
    names_req <- c("TAG", "tag")
    atl_check_data(data, names_expected = names_req)

    ## convert column data types
    data$TAG <- as.numeric(data$TAG)
    data$tag <- stringr::str_pad(data$tag, 4, pad = "0")

    ## check that the input has all the typical WATLAS-columns
    names_expected <- c(
      "posID", "TAG", "tag", "TIME", "time", "X", "Y", "NBS", "VARX", "VARY",
      "COVXY"
    )
    names_found <- names_expected %in% names(data)
    print(stringr::str_glue(
      "WARNING: Expected column {names_expected[!names_found]} not found in
      csv file"
    ))

    return(as.data.frame(data))
  }
