# Scripts to produce summaries from the monthly BCM climate data

# clear workspace
rm(list=ls())

# set directories
wdir = 'C:/Users/morueta/Documents/Documents_share/Projects/100_Postdoc/Test_data'
setwd(wdir)

sdir = 'C:/Users/morueta/Documents/Documents_share/Projects/100_Postdoc/Scripts/'

# load functions
source(paste(sdir, "BCM2014_summary_functions.r",sep=""))

vars<-c('tmn',"tmx","ppt","run","rch","cwd","aet","pet","str")


# Create 30 year summary across water years
mod = "HST"
noyrs=30

wyrs = c(1921,1951,1981)

mm=1
for(mm in 1:length(vars)) {
  
  k=1
  for(k in 1:length(wyrs)) {
    aver = multiyrave(wyrs[k], noyrs=noyrs, m=mod, v=vars[mm])
    fname = paste("BCM2014_",vars[mm],wyrs[k],"_",wyrs[k]+noyrs,"_wy_ave_",mod,".rdata",sep="")
    saveRDS(aver,fname)
  }
}

