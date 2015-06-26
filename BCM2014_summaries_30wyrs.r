########################################################################################
# Scripts to produce 30 year summaries from the 1 year summaries of BCM climate data
#  
# Output is across water years.
# 
# WARNING!!! tdir is specified for temporary output files. All files in folder are erased 
# in the loop, so careful when specifying!
# 
# Naia Morueta-Holme, June 2015
#########################################################################################

# clear workspace
rm(list=ls())

# set directories
# Input directory
idir <- '/Volumes/NMHTB/BCM/CA_2014/Summary/Water_years/' 
# Script directory
sdir <- '/Users/climchange/Documents/ClimateData/BCM_2014/'
# Output directory
odir <- '/Volumes/NMHTB/BCM/CA_2014/Summary/Water_years/'
# Temporary directory
tdir <- '/Volumes/ACKBACK/BCM/CA_2014/tmp/'

# load functions
source(paste(sdir, "BCM2014_summary_functions.r",sep=""))


# specify parameters
mod = "HST"
noyrs = 30
wyrstart=1951
vars<-c("tmn","tmx","ppt","run","rch","cwd","aet","pet","str", "jja", "djf")


# # Create 30 year summaries across historic water years from 1 year summaries

mm <- 1
for(mm in 1:length(vars)) {
  var <- vars[mm]
  print(Sys.time())
  aver <- onewyrtomulti(wyrstart, noyrs, mod, var, cdir=idir, tdir)
  
  #aver = readAll(aver)
  fname = paste("BCM2014_",var,wyrstart,"-",wyrstart+noyrs-1,"_wy_ave_",mod,".Rdata",sep="")
  fpath = paste(odir,fname,sep='')
  print('Writing raster to disk...')
  
  saveRDS(aver,fpath)
  rm(aver)
  # Erase the temporary files
  print("erasing temporary files")
  file.remove(paste(tdir,dir(tdir),sep=""))
}      
    
# Try reading file to check that they are ok
# test = raster(paste(odir,dir(odir)[80],sep=''))
# test
# plot(test)    

