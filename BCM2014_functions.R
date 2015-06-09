## BCM 2014 query functions
## David Ackerly, 20150602

ncdf2ras <- function(model='HST',var='cwd',year='1920',mstart=1,mend=12,
                       cdir='/Volumes/ACKBACK/BCM/CA_2014/ncdf/',verbose=F) {
  # model: 'HST','CCSM_rcp8.5', etc.
  # var: 'tmx','tmn','cwd',etc.
  # mstart: start month
  # mend: start month
  
  # this function returns a list with two items
  # [[1]] raster stack with <m> layers from mstart to mend months (defaults 12)
  # [[2]] metadata from function call and from ncdf file; see variables included at end of function
  require(raster)
  require(ncdf4)
  fname <- paste('CA_BCM_',model,'_Monthly_',var,'_',year,'.nc',sep='')
  if (!fname %in% dir(cdir)) {
    stop('file does not exist')
  }
  fpath <- paste(cdir,fname,sep='')
  
  nmonths <- mend-mstart+1
  
  meta <- list()
  nc <- nc_open(fpath)
  
  # get x,y coordinates
  x <- ncvar_get(nc,'x')
  nx <- dim(x)
  xunits <- ncatt_get(nc,'x','units')
  
  y <- ncvar_get(nc,'y')
  ny <- dim(y)
  yunits <- ncatt_get(nc,'y','units')
  
  #get time coverage
  time <- ncvar_get(nc,'time')
  tunits <- ncatt_get(nc,'time','units')
  
  spref <- ncatt_get(nc,'albers_conical_equal_area')
  global <- ncatt_get(nc,0)
  
  #get variable
  ncv <- ncvar_get(nc,var)
  vlname <- ncatt_get(nc,var,'long_name')
  vunits <- ncatt_get(nc,var,'units')
  fillvalue <- ncatt_get(nc,var,'_FillValue')
  
  ras <- raster(nrows=ny,ncol=nx,xmn=min(x),xmx=max(x),ymn=min(y),ymx=max(y))
  proj4string(ras) <- CRS(ta.project)
  
  #     For the metadata, it'd be great to include:
  # - date of download (May 2015)
  # - version of the BCM
  # - url where we got the data from - I think we can just use the same for all: "http://cida.usgs.gov/thredds/fileServer/CA-BCM-2014"
  # 
  # We could potentially also include:
  # - "Terms of use" sentence like : "See http://climate.calcommons.org/article/featured-dataset-california-basin-characterization-model for terms of use and limitations. Please contact Deanne DiPietro (ddipietro@pointblue.org) when using the data for publications to inform them on data utilization"
  
  meta[[1]] <- model #climate model (HST or future)
  meta[[2]] <- var # climate variable
  meta[[3]] <- year # year
  meta[[4]] <- mstart #month start
  meta[[5]] <- 1 #number of months
  meta[[6]] <- dim(ncv) #dimensions of ncdf file
  meta[[7]] <- c(min(x),max(x)) #range of y variables (longitude)
  meta[[8]] <- xunits[[2]] #units of x variable
  meta[[9]] <- c(min(y),max(y)) #range of y variables (latitude)
  meta[[10]] <- yunits[[2]] #units of y variable
  meta[[11]] <- time # list of time points for 12 months in ncdf file
  meta[[12]] <- tunits[[2]] # units of time
  meta[[13]] <- vlname[[2]] # long name of variable
  meta[[14]] <- vunits[[2]] # variable units
  meta[[15]] <- fillvalue[[2]] # missing value
  meta[[16]] <- spref #ncdf spatial reference data
  meta[[17]] <- ta.project #teale alberts CRS projection string
  meta[[18]] <- global #global attribute data of ncdf file
  meta[[19]] <- list(data='This Rdata object was created from an ncdf file from the Basin Characterization Model 2014 data set.',
                     terms='For terms of use, see: http://climate.calcommons.org/article/featured-dataset-california-basin-characterization-model',
                     citation='For citation of the BCM model, see doi:10.1186/2192-1709-2-25',
                     archive='ncdf file was downloaded from http://cida.usgs.gov/thredds/fileServer/CA-BCM-2014, May 2015',
                     conversion='conversion to Rdata object by Ackerly Lab, UC Berkeley, June 2015')
  
  names(meta) <- c('model','var','year','mstart','nmonths','ncdf.dim','xrange','xunits','yrange','yunits',
                   'time','tunits','vlname','vunits','fillvalue','ncdf_spref','proj4string','ncdf_global_att','source')
  
  months <- as.character(mstart:mend)
  months[nchar(months)==1] <- paste('0',months[nchar(months)==1],sep='')
  
  m=1
  for (m in mstart:mend) {
    if (verbose) print(m)
    meta[[4]] <- m #update month
    #vmat <- as.vector(ncv[,,m],mode='numeric'),byrow=F,nrow=ny,ncol=nx)
    ras <- flip(setValues(ras,as.vector(ncv[,,m],mode='numeric')),'y')
    #rstack <- addLayer(rstack,ras)
    cras <- list(ras,meta)
    Rname <- paste('CA_BCM_',model,'_Monthly_',var,'_',year,'_',months[m],'.Rdata',sep='')
    saveRDS(cras,file=paste(odir,var,'/',Rname,sep=''))
  }
  nc_close(nc)
  #names(rstack) <- paste(var,'_',year,'_',months,sep='')
  #return(list(rstack,meta))
}

print('hey')

MTseries <- function(pts.ta,var='cwd',ystart=1920,yend=2009,model='HST',verbose=F) {
  # this function returns a matrix of the values of var by month from the start to end year
  # extracted at each of the points in pts.ta 
  # pts.ta is a SpatialPoints object in same projection as climate layers
  start.time <- Sys.time()
  npts <- length(pts.ta)
  years <- ystart:yend
  nyrs <- length(years)
  cvals <- matrix(NA,nrow = 12*length(years),ncol=(npts+4))
  cvals[,2] <- rep(years,each=12)
  cvals[,3] <- rep(1:12,nyrs)
  cvals[,4] <- cvals[,2] + (cvals[,3]-1)/12
  
  y=1
  for (y in 1:length(years)) {
    cyear <- as.character(years[y])
    if (verbose) print(cyear)
    cstack <- ncdf2stack(model,var,cyear)
    vals <- extract(cstack[[1]],pts.ta)
    cvals[(y*12-11):(y*12),c(5:(4+npts))] <- t(vals)
  }
  cvals <- data.frame(cvals)
  cvals[,1] <- var
  names(cvals) <- c('var','year','month','year.month',row.names(pts.ta@data))
  end.time <- Sys.time()
  print(end.time-start.time)
  return(cvals)
}

water.year <- function(year,month) {
  # takes two column matrix of year and month and returns two column matrix for water years,
  # starting from October
  
  wyear <- year
  wmonth <- month
  wyear[month>9] <- year+1
  wmonth <- month+3
  wmonth[wmonth>12] <- wmonth-12
  wyear.month <- wyear + (wmonth-1)/12
  return(data.frame(wyear,wmonth,wyear.month))
}
