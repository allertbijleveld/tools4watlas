% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fun_get_data_csv.r
\name{atl_get_data_csv}
\alias{atl_get_data_csv}
\title{Get data from a local csv file.}
\usage{
atl_get_data_csv(
  fpath = system.file("extdata", "redknot_2707_WATLAS_exampledata.csv", package =
    "tools4watlas")
)
}
\arguments{
\item{fpath}{The full path (including path and file name) of the csv file. If left empty, the example data file supplied with \code{tools4watlas} will be used.}
}
\value{
A formatted dataframe of the csv file with the columns: \cr
PosID	=	Unique number for localizations \cr
TAG 		=	11 digit WATLAS tag ID (numeric) \cr
tag		=	4 digit tag number (character) \cr
TIME		=	UNIX time (seconds) \cr
time 	= 	Timestamp in POSIXct (UTC) \cr
X		=	X-ccordinates in meters (utm 31 N) 	 \cr
Y		=	Y-ccordinates in meters (utm 31 N) 	 \cr
NBS		=	Number of Base Stations used in calculating coordinates  \cr
VARX		=	Variance in estimating X-coordinates \cr
VARY		=	Variance in estimating Y-coordinates \cr
COVXY	=	Co-variance between X- and Y-coordinates \cr
}
\description{
Adjusted version of \code{read.csv()} to conveniently load WATLAS data from a csv file. To read large csv files efficiently, the functions uses the package \code{data.table} but the output is converted to a data frame.
}
\author{
Allert Bijleveld
}
