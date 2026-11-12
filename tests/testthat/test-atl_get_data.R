# 
# test_that("atl_get_data handles input validation correctly", {
#   # Check for valid tag input
#   expect_error(
#     atl_get_data(
#       tag = list(123),
#       tracking_time_start = "2023-01-01 00:00:00",
#       tracking_time_end = "2023-01-02 00:00:00"
#     ),
#     "tag provided must be numeric or character"
#   )
# 
#   # Check for tag length
#   expect_error(
#     atl_get_data(
#       tag = "12345678",
#       tracking_time_start = "2023-01-01 00:00:00",
#       tracking_time_end = "2023-01-02 00:00:00"
#     ),
#     "tag should be either < 7 digits or full 11 digits"
#   )
# 
#   # Check for valid start and end times
#   expect_error(
#     atl_get_data(
#       tag = "1234",
#       tracking_time_start = 20230101,
#       tracking_time_end = "2023-01-02 00:00:00"
#     ),
#     "start tracking time is not a character"
#   )
# 
#   expect_error(
#     atl_get_data(
#       tag = "1234",
#       tracking_time_start = "2023-01-01 00:00:00",
#       tracking_time_end = 20230102
#     ),
#     "end tracking time is not a character"
#   )
# 
#   # Check for timezone input
#   expect_error(
#     atl_get_data(
#       tag = "1234",
#       tracking_time_start = "2023-01-01 00:00:00",
#       tracking_time_end = "2023-01-02 00:00:00",
#       timezone = 123
#     ),
#     "timezone provided must be numeric or character"
#   )
# })
# # helper: fake database result (TIME in milliseconds, 11-digit TAG)
# mock_db_data <- function() {
#   data.frame(
#     TAG = "31001001234", TIME = 1672444800000,
#     X = 100, Y = 200, NBS = 4,
#     VARX = 1, VARY = 1, COVXY = 0
#   )
# }
# 
# test_that("atl_get_data handles database connections", {
#   # --- local SQLiteDB: stub connect, query and disconnect (all DBI) ---
#   disconnect <- mockery::mock(TRUE)
#   mockery::stub(atl_get_data, "DBI::dbConnect", "fake_connection")
#   mockery::stub(atl_get_data, "DBI::dbGetQuery", mock_db_data())
#   mockery::stub(atl_get_data, "DBI::dbDisconnect", disconnect)
#   
#   result <- atl_get_data(
#     tag = "1234",
#     tracking_time_start = "2023-01-01 00:00:00",
#     tracking_time_end = "2023-01-02 00:00:00",
#     SQLiteDB = "dummy_path.db"
#   )
#   expect_true(is.data.frame(result))
#   expect_equal(ncol(result), 10)
#   expect_equal(result$tag[1], "1234")
#   # connection opened by the function is closed again
#   mockery::expect_called(disconnect, 1)
#   
#   # --- existing connection: must be used and left open ---
#   disconnect_existing <- mockery::mock(TRUE)
#   mockery::stub(atl_get_data, "DBI::dbGetQuery", mock_db_data())
#   mockery::stub(atl_get_data, "DBI::dbDisconnect", disconnect_existing)
#   
#   result <- atl_get_data(
#     tag = "1234",
#     tracking_time_start = "2023-01-01 00:00:00",
#     tracking_time_end = "2023-01-02 00:00:00",
#     use_connection = "fake_connection"
#   )
#   expect_true(is.data.frame(result))
#   expect_equal(result$tag[1], "1234")
#   # caller's connection must not be closed by the function
#   mockery::expect_called(disconnect_existing, 0)
# })
# 
# test_that("atl_get_data retrieves and processes data correctly", {
#   mockery::stub(atl_get_data, "DBI::dbConnect", "fake_connection")
#   mockery::stub(atl_get_data, "DBI::dbGetQuery", mock_db_data())
#   mockery::stub(atl_get_data, "DBI::dbDisconnect", TRUE)
#   
#   result <- atl_get_data(
#     tag = "1234",
#     tracking_time_start = "2023-01-01 00:00:00",
#     tracking_time_end = "2023-01-02 00:00:00",
#     SQLiteDB = "dummy_path.db"
#   )
#   
#   # check result structure
#   expect_true(data.table::is.data.table(result))
#   expect_equal(ncol(result), 10)
#   expect_equal(names(result), c(
#     "posID", "tag", "time", "datetime",
#     "x", "y", "nbs", "varx", "vary", "covxy"
#   ))
#   
#   # check time conversion and tag formatting
#   expect_equal(result$time[1], 1672444800) # milliseconds to seconds
#   expect_equal(result$tag[1], "1234")      # short format
#   expect_equal(result$posID[1], 1L)
# })
# 
# test_that("atl_get_data gives correct warning", {
#   sqlite_db <- system.file(
#     "extdata", "watlas_example.SQLite", package = "tools4watlas"
#   )
#   con <- RSQLite::dbConnect(RSQLite::SQLite(), sqlite_db)
#   on.exit(DBI::dbDisconnect(con), add = TRUE)
#   
#   expect_warning(
#     result <- atl_get_data(
#       tag = "31001000001",
#       tracking_time_start = "2023-01-01 00:00:00",
#       tracking_time_end = "2023-01-02 00:00:00",
#       use_connection = con
#     ),
#     regexp = "No data available for tag 0001 in this time period."
#   )
#   
#   # result is an empty data.table with the correct columns
#   expected_cols <- c(
#     "posID", "tag", "time", "datetime",
#     "x", "y", "nbs", "varx", "vary", "covxy"
#   )
#   expect_true(data.table::is.data.table(result))
#   expect_equal(colnames(result), expected_cols)
#   expect_equal(nrow(result), 0)
# })

# ---- helpers ---------------------------------------------------------------

# ms timestamp for a UTC time string
ms <- function(x) as.numeric(as.POSIXct(x, tz = "UTC")) * 1000

# in-memory SQLite db with a LOCALIZATIONS table; closed automatically
local_watlas_con <- function(env = parent.frame()) {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  withr::defer(DBI::dbDisconnect(con), envir = env)
  DBI::dbWriteTable(con, "LOCALIZATIONS", data.frame(
    TAG = c(rep("31001001234", 3), rep("31001005678", 2)),
    TIME = ms(c(
      "2023-01-01 10:00:00", "2023-01-01 11:00:00", "2023-01-01 12:00:00",
      "2023-01-01 10:30:00", "2023-01-01 11:30:00"
    )),
    X = 1:5 * 10, Y = 1:5 * 20, NBS = 4L,
    VARX = 1, VARY = 1, COVXY = 0
  ))
  con
}

start <- "2023-01-01 00:00:00"
end <- "2023-01-02 00:00:00"
out_cols <- c(
  "posID", "tag", "time", "datetime", "x", "y",
  "nbs", "varx", "vary", "covxy"
)

# ---- input validation (additional) ----------------------------------------

test_that("atl_get_data validates database parameters", {
  expect_error(
    atl_get_data(
      tag = "1234", tracking_time_start = start, tracking_time_end = end,
      host = 123
    ),
    "host is not a character"
  )
})

# ---- connections -----------------------------------------------------------

test_that("atl_get_data opens and closes a SQLiteDB connection", {
  db_file <- withr::local_tempfile(fileext = ".sqlite")
  con <- DBI::dbConnect(RSQLite::SQLite(), db_file)
  DBI::dbWriteTable(con, "LOCALIZATIONS", DBI::dbReadTable(
    local_watlas_con(), "LOCALIZATIONS"
  ))
  DBI::dbDisconnect(con)
  
  result <- atl_get_data(
    tag = "1234", tracking_time_start = start, tracking_time_end = end,
    SQLiteDB = db_file
  )
  expect_equal(nrow(result), 3)
  expect_equal(unique(result$tag), "1234")
})

test_that("atl_get_data leaves a user-supplied connection open", {
  con <- local_watlas_con()
  atl_get_data(
    tag = "1234", tracking_time_start = start, tracking_time_end = end,
    use_connection = con
  )
  expect_true(DBI::dbIsValid(con))
})

test_that("atl_get_data uses MariaDB when no SQLiteDB is given", {
  connect <- mockery::mock("fake_connection")
  disconnect <- mockery::mock(TRUE)
  mockery::stub(atl_get_data, "RMariaDB::MariaDB", "fake_driver")
  mockery::stub(atl_get_data, "DBI::dbConnect", connect)
  mockery::stub(atl_get_data, "DBI::dbDisconnect", disconnect)
  mockery::stub(atl_get_data, "DBI::dbGetQuery", data.frame(
    TAG = character(), TIME = numeric(), X = numeric(), Y = numeric(),
    NBS = integer(), VARX = numeric(), VARY = numeric(), COVXY = numeric()
  ))
  
  expect_warning(
    atl_get_data(
      tag = "1234", tracking_time_start = start, tracking_time_end = end,
      username = "u", password = "p", database = "d", host = "h"
    ),
    "No data available"
  )
  mockery::expect_called(connect, 1)
  mockery::expect_args(
    connect, 1, "fake_driver",
    user = "u", password = "p", dbname = "d", host = "h"
  )
  mockery::expect_called(disconnect, 1)
})

# ---- data processing -------------------------------------------------------

test_that("atl_get_data returns correctly processed data", {
  con <- local_watlas_con()
  result <- atl_get_data(
    tag = c("1234", "5678"), tracking_time_start = start,
    tracking_time_end = end, use_connection = con
  )
  
  expect_true(data.table::is.data.table(result))
  expect_equal(names(result), out_cols)
  expect_equal(nrow(result), 5)
  expect_equal(unique(result$tag), c("1234", "5678"))
  # ordered by tag and time, posID restarts per tag
  expect_equal(result$posID, c(1L, 2L, 3L, 1L, 2L))
  expect_false(is.unsorted(result[tag == "1234", time]))
  # ms -> s, and datetime in UTC
  expect_equal(result$time[1], ms("2023-01-01 10:00:00") / 1000)
  expect_equal(
    result$datetime[1], as.POSIXct("2023-01-01 10:00:00", tz = "UTC")
  )
})

test_that("atl_get_data accepts full 11-digit tags", {
  con <- local_watlas_con()
  result <- atl_get_data(
    tag = "31001001234", tracking_time_start = start,
    tracking_time_end = end, use_connection = con
  )
  expect_equal(unique(result$tag), "1234")
})

test_that("atl_get_data respects the time window and timezone", {
  con <- local_watlas_con()
  # 11:15 CET == 10:15 UTC -> excludes the 10:00 UTC row of both tags
  result <- atl_get_data(
    tag = "1234", tracking_time_start = "2023-01-01 11:15:00",
    tracking_time_end = end, use_connection = con, timezone = "CET"
  )
  expect_equal(nrow(result), 2)
})

test_that("atl_get_data works across several chunks, some without data", {
  con <- local_watlas_con()
  # chunk_size = 1 -> one query per tag; tag 9999 gives a NULL chunk
  expect_warning(
    result <- atl_get_data(
      tag = c("1234", "9999", "5678"), tracking_time_start = start,
      tracking_time_end = end, use_connection = con, chunk_size = 1
    ),
    "No data available for tag 9999"
  )
  expect_equal(nrow(result), 5)
  expect_equal(unique(result$tag), c("1234", "5678"))
})

# ---- last_n ----------------------------------------------------------------

test_that("atl_get_data last_n returns the most recent fixes per tag", {
  con <- local_watlas_con()
  result <- atl_get_data(
    tag = c("1234", "5678"), tracking_time_start = start,
    tracking_time_end = end, use_connection = con, last_n = 2
  )
  expect_equal(result[, .N, by = tag]$N, c(2L, 2L))
  # the two latest fixes of tag 1234 are 11:00 and 12:00
  expect_equal(
    result[tag == "1234", time],
    ms(c("2023-01-01 11:00:00", "2023-01-01 12:00:00")) / 1000
  )
})

# ---- warnings --------------------------------------------------------------

test_that("atl_get_data warns for tags without data", {
  con <- local_watlas_con()
  expect_warning(
    result <- atl_get_data(
      tag = "31001000001", tracking_time_start = start,
      tracking_time_end = end, use_connection = con
    ),
    "No data available for tag 0001 in this time period."
  )
  expect_equal(colnames(result), out_cols)
  expect_equal(nrow(result), 0)
})

test_that("atl_get_data caps the list of missing tags at 50", {
  con <- local_watlas_con()
  expect_warning(
    atl_get_data(
      tag = 2001:2060, tracking_time_start = start,
      tracking_time_end = end, use_connection = con
    ),
    "and 10 more"
  )
})

# ---- errors ----------------------------------------------------------------

test_that("atl_get_data gives a helpful error when the query fails", {
  mockery::stub(atl_get_data, "DBI::dbGetQuery", function(...) stop("boom"))
  
  # default: suggests a smaller chunk_size
  expect_error(
    atl_get_data(
      tag = "1234", tracking_time_start = start, tracking_time_end = end,
      use_connection = "fake_connection"
    ),
    "chunk_size = 10.*boom"
  )
  
  # last_n: per-tag message
  expect_error(
    atl_get_data(
      tag = "1234", tracking_time_start = start, tracking_time_end = end,
      use_connection = "fake_connection", last_n = 5
    ),
    "query for this tag failed.*boom"
  )
})