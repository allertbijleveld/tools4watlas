#' Plot track for one individual on a OpenStreetMap satellite map.
#'
#' A function that plots the localization data of one individual. 
#'
#' @author Allert Bijleveld
#' @param data A dataframe with the tracking data. Can include multiple tags, but one tag is selected for plotting.  
#' @param tag The four-digit tag number as character to plot. Defaults to plotting the first tag in \code{data}.
#' @param mapID An map-object generated with the function \code{OpenStreetMap::openmap()}.  
#' @param color_by Either \code{"time"}, \code{"SD"}, or \code{"NBS"}, which are respectively used to colour the localization with the relative time (hours), variance in the localizations as the maximum of VARX and VARY, or the Number of Base Stations (NBS) used to calculate the localization. Defaults to "time".
#' @param fullname If specified the plot will be saved in this path with this name (include extension). Defaults to NULL and plotting in a graphics window.  
#' @param ppi The pixels per inch, which is used to calculate the dimensions of the plotting region from \code{mapID}. Deafults to 96.  
#' @param towers A dataframe with coordinates of receiver stations (named \code{X} and \code{Y}).
#' @param Legend Passed to the \code{legend} function and sets the location of the legend in the plot.
#' @param Scalebar Length of scalebar in km.  
#' @param cex_legend The size of the text in the legend. 
#' @return Returns nothing but a plot. 
#' @export
atl_plot_tag_osm<-function(data, tag=NULL, mapID=map, color_by="time", fullname=NULL, ppi=96, towers=NULL, Legend="topleft", Scalebar=5, cex_legend=1){
	
		assertthat::assert_that(nrow(data)>0,
			msg = "no data to plot"
		)
	
		assertthat::assert_that(!is.data.frame(data),
			msg = "Data is provided as a data.frame. First use atl_make_spatial() to transform to a spatial object with the osm() coordinate reference system."
		)
	
		# print("Make sure that data has the osm() coordinate reference system.")
		
	
	if(is.null(tag)){tag<-data$tag[1]}else{
			tag<-as.character(tag) # make sure tag is specified as a character 
		}

		data<-data[data$tag==tag,]
				
		assertthat::assert_that(nrow(data)>0,
			msg = "tag not found"
		)

		# process the colour scale as well as titles
		if(color_by=="NBS")	{ 
					color_by_values <- data$NBS
					color_by_title<-paste("NBS", '\n', "tag ",tag,sep="")
					}
		if(color_by=="SD")	{ 
					color_by_values <- log10(apply(cbind(data$VARX, data$VARY), 1, function(x) max(x)))
					color_by_title<-paste("log10(max(VARX,VARY))", '\n', "tag ",tag,sep="")
					}
		if(color_by=="time")	{ 
					color_by_values <-as.numeric(difftime(data$time, min(data$time)), unit="hours")
					color_by_title<-paste("time since start (h)", '\n', "tag ",tag,sep="")
					}
		
		## get size for plot window
			px_width  <- mapID$tiles[[1]]$yres[1]
			px_height <- mapID$tiles[[1]]$xres[1]
				
		### if fullname is NULL then plot in graphics device  
			if(is.null(fullname)){
					# win.graph(width=px_width/ppi, height=px_height/ppi)
					dev.new(width=px_width/ppi, height=px_height/ppi)
				}else{
					dir.create(file.path(dirname(fullname)), showWarnings = FALSE)
					png(filename = fullname, width = px_width, height = px_height, units = "px")
					}
	
	## specify plot 
			par(bg="black")
			par(xpd=TRUE)   
		
		## plot backgound map
			OpenStreetMap::plot.OpenStreetMap(mapID)
		
		# add title 
			mtext(paste("from ", min(data$time)," UTC\nto ", max(data$time), " UTC",sep=""), line = 1.7, cex=1, col="white")
		# add towers
			if(!is.null(towers)){points(towers$X,towers$Y,pch=23, cex=2,col=2,bg=1)}
		## make color scale
			rbPal <- colorRampPalette(c('white', 'light yellow', 'yellow', 'orange', 'dark orange','red', 'dark red'))
			n<-100 #number of color classes
			cuts<-cut(color_by_values,breaks = n)
			colramp<-rbPal(n)
			COLID <- colramp[as.numeric(cuts)]	
		# plot spatial sp object
			lines(x=sp::coordinates(data)[,1], y=sp::coordinates(data)[,2], lwd=0.5, col = "black")
			points(sp::coordinates(data)[,1], sp::coordinates(data)[,2], pch=3, cex=0.5, col = COLID)
		## add scalear
			fr=0.02	# custum position of scalebar (in fraction of plot width) 
			ydiff<-diff(par('usr')[3:4])
			xdiff<-diff(par('usr')[1:2])
			xy_scale<-c(par('usr')[1]+xdiff*fr, par('usr')[3] + ydiff*fr)
			raster::scalebar(Scalebar*1000, xy_scale,type='line', divs=4, lwd=3, col="white", label=paste0(Scalebar," km"))
		## add legend 
			legend_cuts<-pretty(color_by_values, n=5)
			legend_cuts_col<-colramp[seq(1,n, length=length(legend_cuts))]
			legend(Legend, legend=legend_cuts, col =legend_cuts_col, pch=15, bty="n", text.col = "white", title=color_by_title, inset=c(0.01, 0.02), y.intersp = 0.8, cex=cex_legend)
		
		if(!is.null(fullname)){dev.off()} # close grapichs device if saved to file
			
	}
