
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tools4watlas

<!-- badges: start -->
<!-- badges: end -->

The goal of *tools4watlas* is to provide tools for getting, processing
and plotting WATLAS-tracking data. More information on WATLAS can be
found in this article published in Animal Biotelemetry: [WATLAS:
high-throughput and real-time tracking of many small birds in the Dutch
Wadden Sea](https://doi.org/10.1186/s40317-022-00307-w).

You can also visit <https://www.nioz.nl/watlas> where you can follow the
tracked birds in realtime.

The package *tools4watlas* builts on the package
[*atlastools*](https://github.com/pratikunterwegs/atlastools). A
pipeline with coding examples for cleaning high-throughput tracking data
with *atlastools* is covered in this article in the Journal of Animal
Ecology: [A Guide to Pre-processing High-throughput Animal Tracking
Data](https://doi.org/10.1111/1365-2656.13610).

# Installation

You can install the latest version of *tools4watlas* from
[GitHub](https://github.com/allertbijleveld/tools4watlas) with:

``` r
# install.packages("devtools")
devtools::install_github("allertbijleveld/tools4watlas")
```

# Basic single-tag workflow

The basic workflow using *tools4watlas* for high-throughput WATLAS
tracking-data is getting data, basic filtering, processing, cleaning,
adding environmental data, selecting data, and plotting the data.

After installing the package, load the *tools4watlas* library.

``` r
library(tools4watlas)
```

## Getting data

You can get data from locally from a csv or SQLite file, or remotely
from the server.

#### Local csv file

The function atl_get_data_csv() is a convenient wrapper to load a csv
file as a data frame. By default it loads the csv file provided as
example data with tools4watlas.

``` r
data<-atl_get_data_csv()
```

#### Local SQLite file

First, the path and filename of the local SQLite database need to be
provided. Then, with the established connection, the database can be
queried for a particular tag and period.

``` r
SQLiteDB=paste0("path", "SQLite_db_name", ".sqlite")
MyDBconnection <- RSQLite::dbConnect(RSQLite::SQLite(),SQLiteDB)

data<- atl_get_data(
                    tag = 31001002707,
                    tracking_time_start = "2022-09-02 01:25:00",
                    tracking_time_end = "2022-09-03 13:47:00",
                    timezone = "CET",
                    SQLiteDB=SQLiteDB,
                    use_connection = MyDBconnection)
```

#### Remote SQL-database

It is also possible to connect directly to a remote host.

``` r
data<- atl_get_data(
                    tag = 31001002707,
                    tracking_time_start = "2022-09-02 01:25:00",
                    tracking_time_end = "2022-09-03 13:47:00",
                    timezone = "CET",
                    host= "host", 
                    database = "db",
                    username = "username",
                    password = "password")            
```

## Data explanation

Loading the WATLAS data will provide a data frame with different columns
representing:

*PosID* = Unique number for localizations  
*TAG* = 11 digit WATLAS tag ID  
*tag* = 4 digit tag number (character), i.e. last 4 digits of the column
‘TAG’  
*TIME* = UNIX time (seconds)  
*time* = Timestamp in POSIXct (UTC) *X* = X-ccordinates in meters (utm
31 N)  
*Y* = Y-ccordinates in meters (utm 31 N)  
*NBS* = Number of Base Stations used in calculating coordinates  
*VARX* = Variance in estimating X-coordinates  
*VARY* = Variance in estimating Y-coordinates  
*COVXY* = Co-variance between X- and Y-coordinates  

## Spatiotemporal filtering

After getting the data, a potential first step is applying basic
filtering to select certain areas of interest, or remove areas with
erroneous localizations.

Here, is an example of removing hypothesized erroneous localizations
from a rectangular area specified with the range in x and y coordinates,
but a spatial polygon could also be used (see *?atl_filter_bounds*).

``` r
data<-atl_filter_bounds(
                        data=data,
                        x_range = c(639470, 639471),
                        y_range = c(5887143, 5887144),
                        sf_polygon = NULL,
                        remove_inside = TRUE
                        )
```

For filtering data, the general *atl_filter_covariates* function can
also be used. For example, filtering on a range of coordinates and a
time period:

``` r
data<- atl_filter_covariates(
                        data = data,
                        filters = c(
                        "between(time, '2022-09-02 01:25:00', '2022-09-03 13:47:00')",
                        "between(X, 649686, 651938)") 
                        )               
```

## Basic processing

With the data of interest, some basic variables can be calculated, for
instance, calculating speeds and turning angles from consecutive
localizations. Speed can then later be used for filtering potentially
erroneous localizations.

``` r
#> calculate speed between consecutive localizations        
data$speed_in <- atl_get_speed(data=data, time="TIME", type = "in") 
data$speed_out <- atl_get_speed(data=data, time="TIME", type = "out") 

#> calculate angle between consecutive localizations        
data$angle <- atl_turning_angle(data=data, time="TIME") 
```

## Filtering

The next step is to remove localization errors, for instance, by
applying basic filtering on the variances in estimating x- and
y-coordinates and speed.

``` r
VARmax  <- 10000    # variance in meters squared
speed_max <- 35 # meters per second

data<- atl_filter_covariates(
                            data=data,
                            filters = c(
                                "VARX < VARmax", 
                                "VARY < VARmax",
                                "speed_in < speed_max",
                                "speed_out < speed_max"
                                )
                            )
```

## Smoothing

To further reduce error in the localization data, a basic smoother such
as a median filter can be applied.

``` r
med_filter <- 5 # window for smoothing localizations
data<- atl_median_smooth(data=data, time = "TIME", moving_window = med_filter)
```

After smoothing the data, the speeds and angles need to be recalculated.

``` r
data$speed_in <- atl_get_speed(data=data, time="TIME", type = "in") 
data$speed_out <- atl_get_speed(data=data, time="TIME", type = "out") 

#> Note that the distance between smooted localization can be zero, and 
#> therefore, the angle cannot be calculated and a warning and NaNs are returned    
data$angle <- atl_turning_angle(data=data, time="TIME") 
```

## Adding tidal data

After following the above basic steps, the data will be ready for adding
environmental data, such as waterlevels.

``` r
#> load the tidal data using the library data.table
tides_filename <- system.file("extdata", "example_tide_data_UTC.csv", 
                        package="tools4watlas")
tide_data_highres_filename <- system.file("extdata", 
                        "example_tide_data_highres_UTC.csv", 
                        package="tools4watlas")
tides <- data.table::fread(tides_filename)
tide_data_highres <- data.table::fread(tide_data_highres_filename)

#> add the tidal data to the tracking data. Note that we use an offset 
#> of 30 min becasue of the delay in water flow between the tidal gauge 
#> and the location of the example tracking data (the islet of Griend)

data<-atl_add_tidaldata(data=data, tide_data=tides, 
                    tide_data_highres=tide_data_highres, 
                    waterdata_resolution="10 minute", Offset=30)
```

## Data selection

For specific analyses, the cleaned data can be selected. To select
localizations when mudlfats are available for foraging, we can for
example select a low tide period from -2.5 hours to +2.5 hours around
low tide [(Bijleveld et
al. 2016)](https://royalsocietypublishing.org/doi/10.1098/rspb.2015.1557):

``` r
#> select the low tide periode for a particular tide as specified by tideID 
data<- atl_filter_covariates(
                        data = data,
                        filters = c(
                        "tideID == 2022472",
                        "between(time2lowtide, -2.5 * 60, 2.5 * 60)")
                        )
```

## Plotting

To catch potential errors in the above workflow, it is important to
always plot the intermediate steps. Initially, the data is a
*data.frame* object. For plotting, it is convenient to convert to a
spatial object, i.e. a *SpatialPointsDataFrame*.

``` r
#> UTM 31N is the the default coordinate reference system.
data_spatial_utm<-atlas_make_spatialdataframe(data)

#> plot locations only
sp::plot(data_spatial_utm) 

#> Plot the tracking data with a simple background 
atl_plot_tag(data=data_spatial_utm, tag=NULL, fullname=NULL, buffer=1, 
                color_by="time")
```

The plotting region can be extended by specifiying *buffer* (in meters),
and the scale of the scalebar (in kilometers) can be adjusted. To
inspect the localizations, *color_by* can be specified to colour the
localizations by time since first localization in plot (*“time”*),
standard deviation of the X- and Y-coordinate (*“SD”*), or the number of
base stations used for calculating the localization (*“NBS”*). By
specifiying the full path and file name (with extension) in *fullname*,
it is possible to save the plot as a *.png*. If necesarry, the legend
can also be located elsewhere on the plot with *Legend*.

With the function *atl_plot_tag_osm* it is possible to plot the track on
a satellite image with the library *OpenStreetMap*.

``` r
#> Obtain the extent of tracking data for retrieving the satellite imagery
bbox_utm<-atl_get_spatial_bounds(data_spatial_utm)

#> Transform the bounding box to the osm coordinate reference system
Bbox_osm<-atlas_make_boundingbox_for_osm(bbox_utm, buffer=300, 
                    from_crs= sp::CRS("+init=epsg:32631"))

#> Download the map from OpenStreetMap using the bounding box
map <- OpenStreetMap::openmap(Bbox_osm[1,],Bbox_osm[2,],type='bing')

#> Transform tracking data to the osm() coordinate reference system
data_spatial_osm<-sp::spTransform(data_spatial_utm, OpenStreetMap::osm()) # to osm()

#> plot the tracking data on the satellite image
atl_plot_tag_osm(data=data_spatial_osm, tag=NULL, mapID=map, color_by="time", 
            fullname=NULL, Scalebar=3)
```

The region of the the satellite image can be extended by specifiying
*buffer* (in meters) in the function *atlas_make_boundingbox_for_osm*.
The other options are similar to *atl_plot_tag* (see earlier).

# PLotting multiple individuals

Here is an example how to combine functions to plot in one graph all
selected tags that are received within a given period, and make an
animation.

### Install tools4watlas package.

``` r
library(tools4watlas)
```

### Select the time period and tags of interest

Set the tags and time period manually.

``` r
#> select time period 
    from="2022-09-02 12:00:00"; to="2022-09-02 12:30:00"
    
#> set tag numbers and species 
    tags <- c(2007,2008)
    species <- c("Red Knot", "Red Knot")
```

Alternatively, we can also get the most recent days of data from the
server and obtain the tag metadata from an Excel-file.

``` r
#> select number of days to get data for
    days<-2     # number of days 
    from=Sys.time()-86400*days; to=Sys.time() + 3600    # add a buffer at the end
    #> using Sys.time() makes vector a "POSIXct" that we need to 
    #> revert back to a character (for now) for using *atl_get_data()*  later 
    from=as.character(from); to=as.character(to)
    
#> load Excel file 
    # provide the correct path and file name, and sheet of the excel file. 
    library(readxl)
    alltags<-as.data.frame(
                    readxl::read_excel(
                            "C:\\path\\tags_watlas.xlsx", 
                            sheet="tags_watlas"
                            )
                        )

#> select tags 
    # select tags of particular species 
    tags<-alltags$tag[alltags$species=="islandica"] # select islandica red knots
    # or provide tag range
    tags <- 2007:2008 
    
#> depending on the tag selection, the species need to be taken from the metadata
    row_id<-match(tags, alltags$tag)    
    species<-alltags$species[row_id]    
```

Lastly, the vector with tags need to be in the right format.

``` r
#> specify format of tag numbers 
    tags<-stringr::str_pad(
                    as.character(tags), 
                    4, #> WATLAS tag string is four characters 
                    pad = "0"
                    )   
    # for collecting data from server, long tag format is used
    tags_long<-paste0(
                "3100100", 
                tags)   
```

### Load tracking data

You can load the data for each tag with a for-loop, but here we will
load the tagging data in a list where each entry is a dataframe.

The tracking data is obtained from a local SQLite file. You can also use
atl_get_data_csv() to load csv files, but this is less convenient for
large files because they are loaded into memory simultaneously. Also,
data selection for timing is more convenient within a SQL-database.

The SQL-database can be hosted locally or remotely:

#### Local SQL-database

``` r
#> First, the path and filename of the local SQLite database need to be provided. 
SQLiteDB=paste0("path", "SQLite_db_name", ".sqlite")
MyDBconnection <- RSQLite::dbConnect(RSQLite::SQLite(),SQLiteDB)

#> Second, with the established connection, the database can be queried 
#> for a particular tag and period and written in a list with lapply. 
#> Each entry of the list will contain the tracking data for the 
#> specified tag and period. 
ldf_raw <- lapply(
            tags_long, 
            atl_get_data, 
            tracking_time_start = from, 
            tracking_time_end = to, 
            timezone = "CET", 
            SQLiteDB = mydb, 
            use_connection = MyDBconnection
            )   
```

#### Remote SQL-database

``` r
ldf_raw<- lapply(
                tags_long, 
                atl_get_data,
                tracking_time_start = from,
                tracking_time_end = to,
                timezone = "CET",
                host= "host", 
                database = "db",
                username = "username",
                password = "password")            
```

### Filtering and Smoothing the data

Now we could calculate basic variables like speed to filter potentially
erroneous localizations. Here, we will not do that and only apply basic
filtering on the variances in estimated x- and y-coordinates. To further
reduce error in the localization data, we wil lalso apply a basic
smoother (median filter). For examples on how to do this for a single
tag, see the above section “Basic workflow” and the subsection “Basic
processing”. We will also filter individuals for a minimum number of
localizations.

``` r
#> First, filter potentially erroneous localizations 
VARmax  <- 5000 # variance limit in meters squared
ldf_clean <- lapply(
                ldf_raw, 
                atl_filter_covariates,
                filters = c(
                        "VARX < VARmax", 
                        "VARY < VARmax",
                            )
                )
                        
#> Second, apply a median smoother 
med_filter <- 5 # number of localizations within window for smoothing
ldf_smoothed <- lapply(
                ldf_clean,
                atl_median_smooth,
                time = "TIME", 
                moving_window = med_filter
                )
                
#> Third, filter list for minimum number of localizations per bird 
    min_locs <- 2                   # specify minimum 
    n <- lapply(ldf_smoothed, nrow) # count localizations per bird 
    ldf_n[lengths(ldf_n) == 0] <- 0 # replace NULL counts for 0
    n <- unlist(ldf_n)              # create vector of counts
    ldf <- ldf_smoothed[n>=min_locs]# filter number of localizations
    tags <- tags[n>=min_locs]       # clean tag vector 
    species<-species[n>=min_locs]   # clean species vector 
```

### Make data spatial and load map

The next step is to make the tracking data within the list spatial
objects, select the plotting area based on the tracking data, and load
the OSM-map for plotting.

``` r
#> convert to spatial data frames
    #> to utm for easy analyses 
    ldf_utm <- lapply(ldf, atlas_make_spatialdataframe) 
    #> to osm for easy plotting
    ldf_osm <- lapply(ldf_utm, sp::spTransform, OpenStreetMap::osm()) 
        
#> get bounding box from utm tracking data
    #> for each track
    bbox_utm<-lapply(ldf_utm, atl_get_spatial_bounds) 
    #> get extent of bounding box between tracks
    xrange<-range(unlist(lapply(bbox_utm, `[`,,1)))
    yrange<-range(unlist(lapply(bbox_utm, `[`,,2)))
    bbox_utm<-matrix(cbind(xrange, yrange), nrow = 2, byrow = FALSE, 
        dimnames = list(c("min", "max"), c("X", "Y")))
        
#> Transform the bounding box to the osm coordinate reference system 
#> for plotting with OpenStreetMap
    bbox_osm <- atlas_make_boundingbox_for_osm(
                            bbox_utm,
                            buffer=1000,
                            from_crs= sp::CRS("+init=epsg:32631")
                            )

#> Download the map from OpenStreetMap using the bounding box
    map <- OpenStreetMap::openmap(
            upperLeft = bbox_osm[1,],
            lowerRight = bbox_osm[2,],
            type='bing')
```

### Plot multiple individuals simultaneously

First, get the plotting colours for invidiuals or species.

``` r
#> create colours for different individuals     
    if(length(unique(species))==1){ #> colour by individual 
        COL=rainbow(length(ldf_osm))
        spec=NULL
    }else{  #> or colour by species 
        spec<-as.data.frame(unique(species))
        names(spec)<-"species"
        #> create colours for the different species 
        spec$COL<-brewer.pal(nrow(spec), "Accent") 
        COL<-spec$COL[match(species, spec$species)]
    }
```

Second, obtain additional information to be added to the plot. In this
case, the time range between individuals will be added to the map.

``` r
    #> get time range between birds 
    timerange <- range(dplyr::combine(lapply(ldf_osm, function(x) range(x$ts))))
```

Third, make the plot and add the tracks of all individuals as well as
additional information like the time range, legend and scale bar.

``` r
#> make plot
    plot_map_osm(map) 
    
#> add the timeframe of the underlying tracks 
    mtext(
        paste(timerange[1], " to ", timerange[2]," UTC",  sep=""), 
        col="white", 
        line=3, 
        font=2
    )
    
#> Add all tracks to map from list 
    mapply(
        atl_plot_add_track, 
        d = ldf_osm, 
        Pch=19, 
        Cex=0.4, 
        Lwd=1, 
        col = COL, 
        Type="o", 
        endpoint=TRUE
    ) 

#> Provide NAMES of the tagged individuals for the legend 
    NAMES <- NULL   # NULL if there are no names for individuals  
    
#> optionally collect metadata like the Colour Ring Combination (CRC) or
#> NAMES from the Excel-file with metadata
    CRC <- alltags$crc[match(tags, alltags$tag)]              
    NAMES <- alltags$bird_name[match(tags, alltags$tag)]     
    NAMES[is.na(NAMES)] <- CRC[is.na(NAMES)] # present CRC if NAMES is empty    

#> add legend   
    if(length(unique(species))==1){ #> legend coloured by individual tags
        legend("topleft", 
            c(paste(tags, NAMES, sep=" ")), 
            col=c(COL), 
            pt.bg=c(COL),
            pch=c(rep(21,length(COL))),
            text.col="white",
            cex=0.75,
            pt.cex=1.5,
            bty = "n",
            title=paste0(species[1]," (", length(tags),")"), 
            title.cex=1.5
            )           
    }else{ #> or else legend coloured by species
        legend(
            "topleft", 
            spec$species,
            col=spec$COL, 
            pt.bg=spec$COL,
            pch=rep(21,length(spec$COL)),
            text.col="white", 
            cex=0.75,
            pt.cex=1.5,
            bty = "n"
            )
        }
            
#> add scalebar
    fr=0.02 #> custum position of scalebar (in fraction of plot width) 
    ydiff<-diff(par('usr')[3:4])
    xdiff<-diff(par('usr')[1:2])
    xy_scale<-c(par('usr')[1]+xdiff*fr, par('usr')[3] + ydiff*fr)
    raster::scalebar(
        5000, #> length of scale bar in meters
        xy_scale,
        type='line', 
        divs=4, 
        lwd=3, 
        col="white", 
        label="5 km"    #> label that goes with the length of scale bar
        )
```

# Animating tracks

Using the data obtained and processed in the previous section *Plotting
multiple individuals*, we will make and animation.

- add water
- animate tracks

**WORK IN PROGRESS - **

More examples of workflows aimed at processing, plotting and adding
environmental data to WATLAS tracking data are being prepared. If you
have a request, please contact Allert Bijleveld.

Potential additions:  
-calculating residence times  
-resource selection analyses  
