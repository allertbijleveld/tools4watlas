#' Plot track for one individual on a simple background.
#'
#' A function that plots the localization data of one individual. 
#'
#' @author Allert Bijleveld
#' @param data A dataframe with the tracking data. Can include multiple tags, but one tag is selected for plotting.  
#' @param tag The four-digit tag number as character to plot. Defaults to plotting the first tag in \code{data}.
#' @param fullname If specified the plot will be saved in this path with this name (include extension). Defaults to NULL and plotting in a graphics window.  
#' @param color_by Either \code{"time"}, \code{"SD"}, or \code{"NBS"}, which are respectively used to colour the localization with the relative time (hours), variance in the localizations as the maximum of VARX and VARY, or the Number of Base Stations (NBS) used to calculate the localization. Defaults to "time". 
#' @param towers A dataframe with coordinates of receiver stations (named \code{X} and \code{Y}).
#' @param Legend Passed to the \code{legend} function and sets the location of the legend in the plot.
#' @param Scalebar Length of scalebar in km.  
#' @param cex_legend The size of the text in the legend. 
#' @return Returns nothing but a plot. 
#' @export	
atl_plot_tag<-function(data, tag=NULL, fullname=NULL, color_by="time", towers=NULL, h=7, w=7*(16/9), buffer=1, Legend="topleft", Scalebar=5, cex_legend=1){
		
		assertthat::assert_that(nrow(data)>0,
			msg = "no data to plot"
		)

		if(is.null(tag)){tag<-data$tag[1]}else{
			tag<-as.character(tag) # make sure tag is specified as a character 
		}

		data<-data[data$tag==tag,]
		
		assertthat::assert_that(nrow(data)>0,
			msg = "tag not found"
		)

		print("Make sure that data has the UTM 31N coordinate reference system.")
		
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

		## make color scale
			rbPal <- colorRampPalette(c('white', 'light yellow', 'yellow', 'orange', 'dark orange','red', 'dark red'))
			n<-100 #number of color classes
			cuts<-cut(color_by_values,breaks = n)
			colramp<-rbPal(n)
			COLID <- colramp[as.numeric(cuts)]	

		### if fullname is NULL then plot in graphics device  
			if(is.null(fullname)){
					dev.new(height=h, width=w)
				}else{
					dir.create(file.path(dirname(fullname)), showWarnings = FALSE)
					png(filename = fullname, height = h, width = w, units = "in", res=96)
				}
									
		# spatial bounds of all localizations
			xrange<-range(data$X)+c(-buffer*1000,buffer*1000)
			yrange<-range(data$Y)+c(-buffer*1000,buffer*1000)
				
		## calculate pretty axis labels
			prettyX<-pretty(xrange, n=3)
			prettyXkm<-prettyX/1000
			prettyY<-pretty(yrange, n=3)
			prettyYkm<-prettyY/1000
		## set colours
			COL_LAND<-c("grey49", "lightblue2", "lightblue2")
			COLlandborder<-1
			COLmud<-"grey90"
			COLmudborder<-"grey49"
		
		# plot map
			sp::plot(land, xlab="x (km)", ylab = "y (km)", asp=1, xaxt="n", yaxt="n", ylim=yrange, xlim=xrange, xaxs="i", cex.lab=1.5)	
			axis(1, at=prettyX, labels=prettyXkm)
			axis(2, at=prettyY, labels=prettyYkm)
			sp::plot(land, add=TRUE, col=COL_LAND[as.numeric(as.factor(land@data$SOORT))])		
			sp::plot(mudflats,add=TRUE, col=COLmud, border=COLmud)
			sp::plot(land, add=TRUE, col=c(COL_LAND[1], NA, NA)[as.numeric(as.factor(land@data$SOORT))])
			# add title 
			mtext(paste("tag ", tag ," \nfrom ", min(data$time)," UTC\nto ", max(data$time), " UTC", sep=""), line = 0.5, cex=1, col="black")
			# add towers
			if(!is.null(towers)){points(towers$X,towers$Y,pch=23, cex=2,col=2,bg=1)}
		# plot tracking data from raw coordinates in data frame or from spatial object
			if(is.data.frame(data)){
				lines(x=data$X, y=data$Y, lwd=0.5, col = "black")
				points(data$X, data$Y, pch=3, cex=0.5, col = COLID)
				}else{
				# plot spatial sp object
				lines(x=sp::coordinates(data)[,1], y=sp::coordinates(data)[,2], lwd=0.5, col = "black")
				points(sp::coordinates(data)[,1], sp::coordinates(data)[,2], pch=3, cex=0.5, col = COLID)
				}	
		## add scalear
			fr=0.02	# custum position of scalebar (in fraction of plot width) 
			ydiff<-diff(par('usr')[3:4])
			xdiff<-diff(par('usr')[1:2])
			xy_scale<-c(par('usr')[1]+xdiff*fr, par('usr')[3] + ydiff*fr)
			raster::scalebar(Scalebar*1000, xy_scale,type='line', divs=4, lwd=3, col="black", label=paste0(Scalebar," km"))
		## add legend 
			legend_cuts<-pretty(color_by_values, n=5)
			legend_cuts_col<-colramp[seq(1,n, length=length(legend_cuts))]
			legend(Legend, legend=legend_cuts, col =legend_cuts_col, pch=15, bty="n", text.col = "black", title=color_by_title, inset=c(0.01, 0.02), y.intersp = 0.8, cex=cex_legend)
		
		## add box for prettyness
			box(col = 1)
	
	# close grapichs device if saved to file		
		if(!is.null(fullname)){dev.off()} 			
	}
		