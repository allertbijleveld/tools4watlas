#' Add residence patches to a plot.
#'
#' Adds residence pattch data in UTM 31N as points or polygons to a plot. 
#' 
#' @author Allert Bijleveld
#' @param d Either sfc_Polygon or a dataframe with the tracking data 
#' @param Pch Corresponding graphical argument passed on to the base plot function 
#' @param Cex Corresponding graphical argument passed on to the base plot function 
#' @param Lwd Corresponding graphical argument passed on to the base plot function 
#' @param Col Corresponding graphical argument passed on to the base plot function 
#' @param Bg Corresponding graphical argument passed on to the base plot function 
#' @param Lines Corresponding graphical argument passed on to the base plot function 
#' @return Nothing but an addition to the current plotting device.
#' @export
atl_plot_rpatches <- function(data, Pch=21, Cex=0.25, Lwd=1, Col=1, Bg=NULL, Lines=TRUE) {
	if("sfc_POLYGON"%in%class(data)){
		plot(data, add=TRUE, col=Bg, border=Col, lwd=1)
	}else{
		points(data$X, data$Y, col=Col, bg=Bg, pch=Pch, cex=Cex, lwd=Lwd)
		if(Lines){lines(data$X, data$Y, col=Col)}
		}
	}


#' Make a colour transparant.
#'
#' A functionm that will make the provided colour transparant.
#'
#' @author Allert Bijleveld
#' @param color The color to make transparant.
#' @param percent The percentage of transparancy to apply .
#' @param name The name argument as passed on to rgb. 
#' @return The transparant color will be returned.
#' @export
atl_t_col <- function(color, percent = 50, name = NULL) {
	rgb.val <- col2rgb(color)
	rgb(rgb.val[1,], rgb.val[2,], rgb.val[3,],max = 255,alpha = (100-percent)*255/100, names = name)
	}


#'  Make X,Y data spatial.
#'
#' A function that will use the library sp to convert to spatialdataframe.
#'
#' @author Allert Bijleveld
#' @param data A dataframe with the tracking data. 
#' @param crs The coordinate reference system (specified with \code{CRS()}) of the X,Y coordinates. The deafult is UTM 31N: \code{CRS("+init=epsg:32631")}.
#' @return The output as a Spatialpointsdataframe.
#' @export
atlas_make_spatialdataframe<-function(data, crs=sp::CRS("+init=epsg:32631")){
	assertthat::assert_that("data.frame"%in%class(data), msg = "Data is not a data.frame. Is it a data.table? Or already a SpatialPointsDataFrame?")
	sp::SpatialPointsDataFrame(coords = data[,c("X","Y")], data = data, proj4string = crs)
	}


#' Get spatial bounds for dataframe X,Y coordinates.
#'
#' Obtains the extent of the (localization) data within a dataframe that contains coordinates X and Y. 
#'
#' @author Allert Bijleveld
#' @param data A dataframe with the tracking data. 
#' @return Provides a matrix with the range in X and Y coordinates.
#' @export
atl_get_spatial_bounds<-function(data){
		matrix(cbind(range(data$X),range(data$Y)), nrow=2, byrow=FALSE, dimnames = list(c("min", "max"), c("X", "Y")))}		

#' Create bounding box in LatLong for downloading a map from OpenStreetMap.
#'
#' Transforms a bounding box obtained with \code{atl_get_spatial_bounds} to a bounding box in LongLat necesarry for plotting with \code{OpenStreetMap::openmap()} with the function \code{atl_plot_tag}. 
#'
#' @author Allert Bijleveld
#' @param bbox A matrix with the ranges in X and Y coordinates. The first column contains the range in X, and the second column the range in Y. The first row contains the minimum and the second row the maximum values. 
#' @param buffer The buffer (in meters) for extending the \code{bbox}.
#' @param from_crs The CRS() of the bbox. 
#' @return Provides a data.frame that can be used with \code{openmap()} where the first row provides the upperleft corner and the second row the lowerright corner of the extent, and the first column refers to the Y-coordinates and the second column to the X-coordinates.
#' @export
atlas_make_boundingbox_for_osm<-function(bbox, buffer=1000, from_crs=sp::CRS("+init=epsg:32631")){
		if(class(bbox)[1]=="matrix"){
					bbox<-as.data.frame(bbox)
					#make spatial 
					bbox<-sp::SpatialPointsDataFrame(coords = bbox[,c("X","Y")], data = bbox, proj4string = from_crs)
					}
		## check for LatLong
			if("+proj=longlat" %in% unlist(strsplit(sp::proj4string(bbox), " "))){
				bbox<-sp::spTransform(bbox, sp::CRS("+init=epsg:32631"))
				}
		## check whether utm in m 
			assertthat::assert_that("+units=m" %in% unlist(strsplit(sp::proj4string(bbox), " ")), msg ="make sure from_crs is either UTM or LL")
		## add buffer 
			bbox<-bbox@bbox + matrix(c(-buffer,buffer,-buffer,buffer), nrow=2, byrow=TRUE)
			bbox<-as.data.frame(t(bbox))
			bbox<-sp::SpatialPointsDataFrame(coords = bbox[,c("X","Y")], data = bbox, proj4string = sp::CRS("+init=epsg:32631"))
			bbox <- t(sp::spTransform(bbox, sp::CRS("+init=epsg:4326"))@bbox)
		# get right shape output for use with OSM map	
			matrix(c(bbox[2,2], bbox[1,2],bbox[1,1], bbox[2,1]), nrow=2, byrow=FALSE)
		}
	
#' Plot a map downloaded with OpenStreetMap.
#'
#' A function that is used in e.g. plotting multiple individuals. 
#'
#' @author Allert Bijleveld
#' @param map The map loaded with \code{OpenStreetMap::openmap()}.
#' @return Returns an OSM background plot for adding tracks. 
#' @export	
plot_map_osm<-function(map, ppi=96){
	## map=osm map; ppi=pixels per inch resolution for plot
	## get size of plot
		px_width  <- map$tiles[[1]]$yres[1]
		px_height <- map$tiles[[1]]$xres[1]
	## initiate plotting window 
		#win.graph(width=px_width/ppi, height=px_height/ppi)
		dev.new(width=px_width/ppi, height=px_height/ppi)
		par(bg="black")
		par(xpd=TRUE)		
	## make plot
		plot(map)
	}

#' Add tracks to plot from list.
#'
#' A function that is used for plotting multiple individuals on a map from a list of spatial data. 
#'
#' @author Allert Bijleveld
#' @param d The spatial data frame.
#' @param Pch The type of point to plot a localization
#' @param Cex The size of the point to plot a localization
#' @param Lwd The width of the line to connect localizations
#' @param col The colour of plotted localizations
#' @param Type The type of graph to make. For instance, "b" is both points and lines and "o" is simlar but places points on top of line (no gaps)
#' @param endpoint Whether to plot the last localization of an individual in magenta
#' @export	
atl_plot_add_track = function(d, Pch=19, Cex=0.25, Lwd=1, col, Type="o",endpoint=FALSE) {
	points(d, col=col, pch=Pch, cex=Cex, lwd=Lwd, type=Type)
	if(endpoint){points(d[nrow(d),], col="magenta", pch=Pch, cex=Cex*2)}
	}		