library(testthat)
library(data.table)
library(OpenStreetMap)
library(sf)

# Create example data
example_data <- data.table(
  posID = c(5234, 5235, 5236, 5237, 5238),
  tag = c(3040, 3040, 3040, 3040, 3040),
  time = c(1696218736, 1696220287, 1696220290, 1696220680, 1696220695),
  datetime = as.POSIXct(c("2023-10-02 03:52:16", "2023-10-02 04:18:07", 
                          "2023-10-02 04:18:10", "2023-10-02 04:24:40", 
                          "2023-10-02 04:24:55"), tz = "UTC"),
  x = c(650883.0, 650883.0, 650883.0, 650864.8, 650860.5),
  y = c(5901400, 5901352, 5901325, 5901324, 5901324),
  nbs = c(3, 3, 3, 3, 3),
  varx = c(126.079338, 53.718193, 98.299149, 110.037270, 87.682434),
  vary = c(987.14783, 415.46805, 759.16998, 605.43665, 642.07953),
  covxy = c(349.5716553, 144.3431396, 266.9374084, 182.1950989, 233.4496155),
  sd = c(42.571945, 27.529485, 37.300723, 32.861286, 34.592791),
  speed_in = c(0.02406698, 0.03068813, 9.21147648, 0.04669014, 0.28444992),
  speed_out = c(0.03068813, 9.21147648, 0.04669014, 0.28444992, 0.69418426)
)

# Define land, mudflats, rivers, and lakes sf objects
land_sf <- st_sf(geometry = st_sfc(st_polygon(list(matrix(c(650800, 5901200, 
                                                            650900, 5901200, 
                                                            650900, 5901400, 
                                                            650800, 5901400, 
                                                            650800, 5901200), 
                                                          ncol = 2, byrow = TRUE)))))
mudflats_sf <- land_sf
rivers_sf <- land_sf
lakes_sf <- land_sf

# Begin testing
test_that("atl_plot_tag handles empty data input gracefully", {
  empty_data <- example_data[0, ]
  expect_error(atl_plot_tag(empty_data), "No data to plot")
})

test_that("atl_plot_tag filters data correctly by tag", {
  filtered_data <- example_data[tag == 3040, ]
  expect_error(atl_plot_tag(example_data, tag = 9999), "Tag not found")
})

test_that("atl_plot_tag opens a graphics device", {
  # Close any existing devices to start clean
  while (dev.cur() > 1) dev.off()
  
  # Record the current number of open devices
  initial_devices <- dev.list()
  
  # Run the function
  atl_plot_tag(example_data, tag = 3040)
  
  # Check the number of open devices after the function call
  final_devices <- dev.list()
  
  # A new device should be opened
  expect_true(length(final_devices) > length(initial_devices), 
              info = "The function should open a new graphics device")
  
  # Cleanup: Close the new device
  while (dev.cur() > 1) dev.off()
})

test_that("atl_plot_tag opens a graphics device", {
  # Close any existing devices to start clean
  while (dev.cur() > 1) dev.off()
  
  # Record the current number of open devices
  initial_devices <- dev.list()
  
  # Run the function
  library(OpenStreetMap)
  library(sf)
  
  # Load example data
  data <- data_example[tag == data_example[1, tag]]
  
  # make data spatial and transform projection to WGS 84 (used in osm)
  d_sf <- atl_as_sf(data, additional_cols = names(data))
  d_sf <- st_transform(d_sf, crs = st_crs(4326)) 
  
  # get bounding box
  bbox <- atl_bbox(d_sf, buffer = 500)
  
  # extract openstreetmap 
  # other 'type' options are "osm", "maptoolkit-topo", "bing", "stamen-toner",
  # "stamen-watercolor", "esri", "esri-topo", "nps", "apple-iphoto", "skobbler";
  map <- openmap(c(bbox["ymax"], bbox["xmin"]),
                 c(bbox["ymin"], bbox["xmax"]),
                 type = "bing", mergeTiles = TRUE) 
  
  # Plot the tracking data on the satellite image
  atl_plot_tag_osm(data = d_sf, tag = NULL, mapID = map, color_by = "time", 
                   fullname = NULL, scalebar = 3)
  
  # Check the number of open devices after the function call
  final_devices <- dev.list()
  
  # A new device should be opened
  expect_true(length(final_devices) > length(initial_devices), 
              info = "The function should open a new graphics device")
  
  # Cleanup: Close the new device
  while (dev.cur() > 1) dev.off()
})


