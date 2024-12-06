library(testthat)
library(data.table)

test_that("atl_add_tidaldata adds tidal information correctly", {
  
  # Mock tracking data
  tracking_data <- data.frame(
    time = as.POSIXct(c("2023-01-01 10:00:00", "2023-01-01 10:10:00", 
                        "2023-01-01 10:20:00"), tz = "UTC"),
    x = c(100, 150, 200),
    y = c(200, 250, 300),
    datetime = as.POSIXct(c("2023-01-01 10:00:00", "2023-01-01 10:10:00", 
                            "2023-01-01 10:20:00"), tz = "UTC")
  )
  
  # Mock tidal data
  tide_data <- data.table(
    high_start_time = as.POSIXct(c("2023-01-01 09:00:00", 
                                   "2023-01-01 21:00:00"), tz = "UTC"),
    low_time = as.POSIXct(c("2023-01-01 15:00:00", 
                            "2023-01-02 03:00:00"), tz = "UTC"),
    tideID = c(1, 2)
  )
  
  # Mock high-resolution tidal data
  tide_data_highres <- data.table(
    dateTime = seq(from = as.POSIXct("2023-01-01 09:00:00", tz = "UTC"),
                   to = as.POSIXct("2023-01-01 15:00:00", tz = "UTC"),
                   by = "10 min"),
    waterlevel = seq(50, 150, length.out = 37) # Simulated water levels
  )
  
  # Run the function
  result <- tools4watlas::atl_add_tidaldata(
    data = tracking_data,
    tide_data = tide_data,
    tide_data_highres = tide_data_highres,
    waterdata_resolution = "10 minute",
    offset = 0
  )
  
  # Check the result has the expected columns
  expect_true(all(c("tideID", "tidaltime", "time2lowtide", "waterlevel") %in% 
                    colnames(result)))
  
  # Check the tideID is correctly assigned
  expect_equal(result$tideID, c(1, 1, 1)) # All points fall under tideID 1
  
  # Check tidaltime calculation
  expect_equal(result$tidaltime, c(60, 70, 80)) # Time since high tide in minutes
  
  # Check time2lowtide calculation
  expect_equal(result$time2lowtide, c(-300, -290, -280)) # Time to low tide in minutes
  
  # Check waterlevel mapping
  datetime_example <- result$datetime[1]
  expect_equal(result$waterlevel[1], 
               tide_data_highres[dateTime == datetime_example]$waterlevel[1]) # First 3 water levels match
})

test_that("atl_add_tidaldata handles empty input gracefully", {
  
  # Empty tracking data
  tracking_data <- data.frame(
    time = as.POSIXct(character(0)),
    x = numeric(0),
    y = numeric(0),
    datetime = as.POSIXct(character(0))
  )
  
  # Mock tidal data
  tide_data <- data.table(
    high_start_time = as.POSIXct(character(0)),
    low_time = as.POSIXct(character(0)),
    tideID = numeric(0)
  )
  
  # Mock high-resolution tidal data
  tide_data_highres <- data.table(
    dateTime = as.POSIXct(character(0)),
    waterlevel = numeric(0)
  )
  
  # Run the function
  expect_error(tools4watlas::atl_add_tidaldata(
    data = tracking_data,
    tide_data = tide_data,
    tide_data_highres = tide_data_highres,
    waterdata_resolution = "10 minute",
    offset = 0
  ), "Input doesn't have any rows"
  )
  
})

test_that("atl_add_tidaldata errors on incorrect inputs", {
  
  # Incorrect data type for `data`
  expect_error(
    tools4watlas::atl_add_tidaldata(
      data = list(),
      tide_data = data.table(),
      tide_data_highres = data.table(),
      waterdata_resolution = "10 minute",
      offset = 0
    ),
    "Data not a data.frame object!"
  )
  
  # Missing datetime column
  tracking_data <- data.frame(
    time = as.POSIXct(c("2023-01-01 10:00:00"), tz = "UTC"),
    x = c(100),
    y = c(200)
  )
  expect_error(
    tools4watlas::atl_add_tidaldata(
      data = tracking_data,
      tide_data = data.table(),
      tide_data_highres = data.table(),
      waterdata_resolution = "10 minute",
      offset = 0
    ),
    "POSIXct"
  )
})
