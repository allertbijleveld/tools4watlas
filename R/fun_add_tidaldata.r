#' Add tidal data to tracking data.
#'
#' Adds a unique tide identifier, waterlevel, time from high tide and time to low tide for tracking data (both in minutes). 
#' 
#' @author Pratik Gupte & Allert Bijleveld
#' @param data A dataframe with the tracking data with the timestamp column 'time' in UTC. 
#' @param tide_data Data on the timing (in UTC) of low and high tides as output from the function \code{fread} of the package \code{data.table}.
#' @param tide_data_highres Data on the timing (in UTC) of the waterlevel in small intervals (e.g. every 10 min) as provided from Rijkwaterstaat as output from the function \code{fread} of the package \code{data.table}.
#' @param waterdata_resolution The resolution of the high resolution waterlevel data. This is used for matching the high resolution tidal data to the tracking data. Defaults to 10 minutes but can be set differently.   
#' @param Offset The offset in minutes between the location of the tidal gauge and the tracking area. This value will be added to the timing of the waterdata.
#' @return The input data but with three columns added: tideID (a unique number for the tidal periode between two consecutive high tides), tidaltime (time since high tide in minutes), time2lowtide (time to low tide in minutes), and waterlevel with reference to NAP (cm).
#' @import data.table
#' @export
atl_add_tidaldata<-function(data, tide_data, tide_data_highres, waterdata_resolution="10 minute", Offset=0){

	## check data format 
		assertthat::assert_that(class(data)[1]=="data.frame", msg = glue::glue("Input not a \\\n dataframe object, \\\n has class {stringr::str_flatten(class(data)[1],\n collapse = ' ')}"))
	## check data availability in tracking data 
		assertthat::assert_that(nrow(data)>0,
			msg = "Input doesn't have any rows"
		) 
	## setup function and make data.table
		time <- tide_number <- tidaltime <- X <- NULL
		setDT(data)
		 
	## check time order
		min_time_diff <- min(as.numeric(diff(data$TIME)))
		if (min_time_diff < 0) {
			warning("wat_add_tide: time not ordered, re-ordering")
		}
	## order tracking data
		data.table::setorder(data, TIME) # order data on time
		assertthat::assert_that("POSIXct" %in% class(data$time))
    
	## process tidal data 
		attributes(tide_data$high_start_time)$tzone<-"UTC"	
		tide_data$high_start_time<-tide_data$high_start_time + Offset*60 # times 60 becasue offset is in minutes
		tide_data$low_time<-tide_data$low_time + Offset*60 # times 60 becasue offset is in minutes
		high_tide_data <- tide_data[, .(high_start_time, tideID)]

	## merge tracking and tidal data to get time from high tide
    temp_data <- data.table::merge.data.table(data, high_tide_data, by.x = "time", by.y = "high_start_time", all = TRUE)
	data.table::setorder(temp_data, time)
    temp_data[, `:=`(tideID, data.table::nafill(tideID, "locf"))] ## expand tide ID to NA 
	temp_data[, `:=`(tidaltime, as.numeric(difftime(time, time[1], units = "mins"))), by = tideID]
    temp_data <- temp_data[stats::complete.cases(temp_data), ]
	## add time2lowtide
	temp_data$time2lowtide <- as.numeric(difftime(temp_data$time, tide_data$low_time[match(temp_data$tideID, tide_data$tideID)], units = "mins"))
	
   ## add waterlevel to tracking data 
	attributes(tide_data_highres$dateTime)$tzone<-"UTC"	
	tide_data_highres$dateTime<-tide_data_highres$dateTime + Offset*60 # times 60 becasue offset is in minutes	
	temp_data[, temp_time := lubridate::round_date(time, unit = waterdata_resolution)]
    temp_data <- base::merge(temp_data, tide_data_highres[, .(dateTime, waterlevel)], by.x = "temp_time", by.y = "dateTime")
    
	## clean data 
	temp_data[, `:=`(temp_time = NULL)]

    # export data, print msg, remove data
    return(as.data.frame(temp_data))
  }	
