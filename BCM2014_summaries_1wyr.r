#########################################################################
# Scripts to produce 1 year summaries from the monthly BCM climate data
# The script assumes that the input is in calendar years (true for all ascii derived
# files and for HST .nc derived files). Can be changed by setting wyrIn=T. 
# Output is across water years.
# 
# WARNING!!! tdir is specified for temporary output files. All files in folder are erased 
# in the loop, so careful when specifying!
# 
# Naia Morueta-Holme, June 2015

# clear workspace
rm(list=ls())

# set directories
# Input directory
idir <- '/Volumes/ACKBACK/BCM/CA_2014/Rdata/'
# Script directory
sdir <- '/Users/climchange/Documents/ClimateData/BCM_2014/'
# Output directory
odir <- '/Volumes/NMHTB/BCM/CA_2014/Summary/Water_years/'
# Temporary directory
tdir <- '/Volumes/ACKBACK/BCM/CA_2014/tmp/'

# load functions
source(paste(sdir, 'BCM2014_summary_functions.r',sep=''))
correctExt <- readRDS(paste(idir,'correctExtent.rdata',sep='')) #---- copy correctExtent.rdata to input dir


# Create 1 year summary across water years
vars <- c("tmn","tmx","ppt","run","rch","cwd","aet","pet","str")
mod <- "HST"
noyrs <- 1
wyrIn <- FALSE # is the input in water years? FALSE if historic, TRUE if futures
wyrs <- 1921:2009

mm=2
for(mm in 1:length(vars)) {
  
  k=1
  for(k in 1:length(wyrs)) {
    print(Sys.time())
    aver <- monthlytowyrave(wyrs[k], noyrs=noyrs, m=mod, v=vars[mm],
                       cdir=paste(idir,vars[mm],'/',sep=''), tdir=tdir, wyrIn=wyrIn)
    aver <- readAll(aver)
    extent(aver) <- correctExt
    fname <- paste("BCM2014_",vars[mm],wyrs[k],"_wy_ave_",mod,".Rdata",sep="")
    fpath <- paste(odir,fname,sep='')
    print('Writing raster to disk...')
    
    saveRDS(aver,fpath)
    rm(aver)
    # Erase the temporary files
    print("erasing temporary files")
    file.remove(paste(tdir,dir(tdir),sep=""))
  }
}

# Try reading file to check that they are ok
# test = raster(paste(odir,dir(odir)[80],sep=''))
# test
# plot(test)

#--------------------------------------------------------------#
# Create 1 year summaries across djf and jja
mod <- "HST"
vars <- c('tmn','tmx')
noyrs <- 1
wyrIn <- FALSE # is the input in water years?
wyrs <- 1921:2009


mm=1
for(mm in 1:length(vars)) {
  var <- vars[mm] 
  
  k=1
  for(k in 1:length(wyrs)) {
    print(Sys.time())
    
    if(var == 'tmn') {
      aver <- monthlytowyrave(wyrs[k], noyrs=noyrs, m=mod, v=var, #change to oneyrave
                       cdir=paste(idir,var,'/',sep=''), tdir=tdir, wyrIn=wyrIn, submonths=c(-1,1,2))
      fname <- paste('BCM2014_djf',wyrs[k],"_wy_ave_",mod,".Rdata",sep="")
    } else if(var == 'tmx') {
      aver <- monthlytowyrave(wyrs[k], noyrs=noyrs, m=mod, v=var, #change to oneyrave
                        cdir=paste(idir,var,'/',sep=''), tdir=tdir, wyrIn=wyrIn, submonths=c(6:8))
      fname <- paste('BCM2014_jjf',wyrs[k],"_wy_ave_",mod,".Rdata",sep="")
    }
    
    aver <- readAll(aver)
    extent(aver) <- correctExt
    fpath <- paste(odir,fname,sep='')
    
    print('Writing raster to disk...')
    
    saveRDS(aver,fpath)
    rm(aver)
    # Erase the temporary files
    print("erasing temporary files")
    file.remove(paste(tdir,dir(tdir),sep=""))
  }
}

