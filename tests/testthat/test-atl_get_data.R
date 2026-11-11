
test_that("atl_get_data handles input validation correctly", {
  # Check for valid tag input
  expect_error(
    atl_get_data(
      tag = list(123),
      tracking_time_start = "2023-01-01 00:00:00",
      tracking_time_end = "2023-01-02 00:00:00"
    ),
    "tag provided must be numeric or character"
  )

  # Check for tag length
  expect_error(
    atl_get_data(
      tag = "12345678",
      tracking_time_start = "2023-01-01 00:00:00",
      tracking_time_end = "2023-01-02 00:00:00"
    ),
    "tag should be either < 7 digits or full 11 digits"
  )

  # Check for valid start and end times
  expect_error(
    atl_get_data(
      tag = "1234",
      tracking_time_start = 20230101,
      tracking_time_end = "2023-01-02 00:00:00"
    ),
    "start tracking time is not a character"
  )

  expect_error(
    atl_get_data(
      tag = "1234",
      tracking_time_start = "2023-01-01 00:00:00",
      tracking_time_end = 20230102
    ),
    "end tracking time is not a character"
  )

  # Check for timezone input
  expect_error(
    atl_get_data(
      tag = "1234",
      tracking_time_start = "2023-01-01 00:00:00",
      tracking_time_end = "2023-01-02 00:00:00",
      timezone = 123
    ),
    "timezone provided must be numeric or character"
  )
})
# helper: fake database result (TIME in milliseconds, 11-digit TAG)
mock_db_data <- function() {
  data.frame(
    TAG = "31001001234", TIME = 1672444800000,
    X = 100, Y = 200, NBS = 4,
    VARX = 1, VARY = 1, COVXY = 0
  )
}

test_that("atl_get_data handles database connections", {
  # --- local SQLiteDB: stub connect, query and disconnect (all DBI) ---
  disconnect <- mockery::mock(TRUE)
  mockery::stub(atl_get_data, "DBI::dbConnect", "fake_connection")
  mockery::stub(atl_get_data, "DBI::dbGetQuery", mock_db_data())
  mockery::stub(atl_get_data, "DBI::dbDisconnect", disconnect)
  
  result <- atl_get_data(
    tag = "1234",
    tracking_time_start = "2023-01-01 00:00:00",
    tracking_time_end = "2023-01-02 00:00:00",
    SQLiteDB = "dummy_path.db"
  )
  expect_true(is.data.frame(result))
  expect_equal(ncol(result), 10)
  expect_equal(result$tag[1], "1234")
  # connection opened by the function is closed again
  mockery::expect_called(disconnect, 1)
  
  # --- existing connection: must be used and left open ---
  disconnect_existing <- mockery::mock(TRUE)
  mockery::stub(atl_get_data, "DBI::dbGetQuery", mock_db_data())
  mockery::stub(atl_get_data, "DBI::dbDisconnect", disconnect_existing)
  
  result <- atl_get_data(
    tag = "1234",
    tracking_time_start = "2023-01-01 00:00:00",
    tracking_time_end = "2023-01-02 00:00:00",
    use_connection = "fake_connection"
  )
  expect_true(is.data.frame(result))
  expect_equal(result$tag[1], "1234")
  # caller's connection must not be closed by the function
  mockery::expect_called(disconnect_existing, 0)
})

test_that("atl_get_data retrieves and processes data correctly", {
  mockery::stub(atl_get_data, "DBI::dbConnect", "fake_connection")
  mockery::stub(atl_get_data, "DBI::dbGetQuery", mock_db_data())
  mockery::stub(atl_get_data, "DBI::dbDisconnect", TRUE)
  
  result <- atl_get_data(
    tag = "1234",
    tracking_time_start = "2023-01-01 00:00:00",
    tracking_time_end = "2023-01-02 00:00:00",
    SQLiteDB = "dummy_path.db"
  )
  
  # check result structure
  expect_true(data.table::is.data.table(result))
  expect_equal(ncol(result), 10)
  expect_equal(names(result), c(
    "posID", "tag", "time", "datetime",
    "x", "y", "nbs", "varx", "vary", "covxy"
  ))
  
  # check time conversion and tag formatting
  expect_equal(result$time[1], 1672444800) # milliseconds to seconds
  expect_equal(result$tag[1], "1234")      # short format
  expect_equal(result$posID[1], 1L)
})

test_that("atl_get_data gives correct warning", {
  sqlite_db <- system.file(
    "extdata", "watlas_example.SQLite", package = "tools4watlas"
  )
  con <- RSQLite::dbConnect(RSQLite::SQLite(), sqlite_db)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  
  expect_warning(
    result <- atl_get_data(
      tag = "31001000001",
      tracking_time_start = "2023-01-01 00:00:00",
      tracking_time_end = "2023-01-02 00:00:00",
      use_connection = con
    ),
    regexp = "No data available for tag 0001 in this time period."
  )
  
  # result is an empty data.table with the correct columns
  expected_cols <- c(
    "posID", "tag", "time", "datetime",
    "x", "y", "nbs", "varx", "vary", "covxy"
  )
  expect_true(data.table::is.data.table(result))
  expect_equal(colnames(result), expected_cols)
  expect_equal(nrow(result), 0)
})
