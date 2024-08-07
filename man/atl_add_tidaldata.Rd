% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fun_add_tidaldata.r
\name{atl_add_tidaldata}
\alias{atl_add_tidaldata}
\title{Add tidal data to tracking data.}
\usage{
atl_add_tidaldata(
  data,
  tide_data,
  tide_data_highres,
  waterdata_resolution = "10 minute",
  Offset = 0
)
}
\arguments{
\item{data}{A dataframe with the tracking data with the timestamp column 'time' in UTC.}

\item{tide_data}{Data on the timing (in UTC) of low and high tides as output from the function \code{fread} of the package \code{data.table}.}

\item{tide_data_highres}{Data on the timing (in UTC) of the waterlevel in small intervals (e.g. every 10 min) as provided from Rijkwaterstaat as output from the function \code{fread} of the package \code{data.table}.}

\item{waterdata_resolution}{The resolution of the high resolution waterlevel data. This is used for matching the high resolution tidal data to the tracking data. Defaults to 10 minutes but can be set differently.}

\item{Offset}{The offset in minutes between the location of the tidal gauge and the tracking area. This value will be added to the timing of the waterdata.}
}
\value{
The input data but with three columns added: tideID (a unique number for the tidal periode between two consecutive high tides), tidaltime (time since high tide in minutes), time2lowtide (time to low tide in minutes), and waterlevel with reference to NAP (cm).
}
\description{
Adds a unique tide identifier, waterlevel, time from high tide and time to low tide for tracking data (both in minutes).
}
\author{
Pratik Gupte & Allert Bijleveld
}
