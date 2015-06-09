## Script to convert all ncdf files to .Rdata objects
## David Ackerly, 20150602

# clear workspace
rm(list=ls())

#open libraries
require(raster)
require(ncdf4)
require(sp)
require(rgdal)

# set climate directory
cdir <- 'H:/Climate/BCM_2014/ncdf/'
odir <- 'H:/Climate/BCM_2014/Rdata/'
sdir <- 'J:/Scripts/'
ta.project = '+proj=aea +datum=NAD83 +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000'

#source functions
source(paste(sdir,'BCM2014_functions.R',sep=''))

# fnames <- dir(cdir)
# length(fnames)
# head(fnames)

# fname <- fnames[3241]
# 
# (fnc <- nchar(fname))
# (year <- substr(fname,(fnc-6),(fnc-3)))
# (var <- substr(fname,(fnc-10),(fnc-8)))
# (model <- substr(fname,8,(fnc-20)))
# 
# cstack <- ncdf2stack(model,var,year)
# Rname <- paste('CA_BCM_',model,'_Monthly_',var,'_',year,'.Rdata',sep='')
# saveRDS(cstack,file=paste(odir,var,'/',Rname,sep=''))

# now set up loop
model <- 'HST'
vars <- c('aet','cwd','pet','ppt','tmn','tmx','rch','run','str')
#years <- as.character(1920:2009)
#years = as.character(1992:2009)
years = as.character(c(1962,1965))
v=4
year <- '1920'
#for (v in 5:6) {
#for (v in 1:length(vars)) {
  var <- vars[v]
  for (year in years) {
    print(year)
    ncdf2ras(model,var,year,cdir=cdir)
    #Rname <- paste('CA_BCM_',model,'_Monthly_',var,'_',year,'_',mn,'.Rdata',sep='')
    #saveRDS(cstack,file=paste(odir,var,'/',Rname,sep=''))
  }
#}
