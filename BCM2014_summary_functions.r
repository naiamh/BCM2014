# Functions to summarize BCM2014 data
# Naia June 8 2015


# Function to get the file names of raster of interest to compute summaries
# can be used when only particular months of each year are wanted
# Multiple vars can be chosen (only meaningful for e.g. tmn and tmx!)
getBCMfilenames = function(models, vars, years, months) {
  require(raster)
    
  cmonths <- as.character(months)
  cmonths[nchar(cmonths)==1] <- paste('0',cmonths[nchar(cmonths)==1],sep='')
  
  gr = expand.grid(models,vars,years,cmonths)
  res = apply(gr,1,function(x) {
    paste('CA_BCM_',x[1],'_Monthly_',x[2],'_',x[3],'_',x[4],'.Rdata',sep='')
  })
  
  return(res)
}



# Function to get the mean across BCM .rdata layers. 
# A chunksize can be set to limit the number of layers read into memory at a time.
# Returns a raster layer
rMeanFromFiles = function(fv, chunksize=2) {
  require(raster)
  
  n = 1:length(fv)
  subs = split(n, ceiling(seq_along(n)/chunksize))
  for(i in 1:length(subs)) {
    slist = lapply(fv[subs[[i]]], function(x) {readRDS(x)[[1]]})
    tmpres = mean(stack(slist))
    res = ifelse(i == 1, tmpres, mean(res,tmpres)) 
  }   
  return(res)
}

water.year2 <- function(year) {
  wyear = c(rep(year-1,3),rep(year,8))
  wmonth = c(8:12,1:8)
  
  wyear <- year
  wmonth <- month
  wyear[month>9] <- year+1
  wmonth <- month+3
  wmonth[wmonth>12] <- wmonth-12
  wyear.month <- wyear + (wmonth-1)/12
  return(data.frame(wyear,wmonth,wyear.month))
}

multiwyrave = function(wyrstart, noyrs=30, m, v) {
  yrs = (wyrstart+1):(wyrstart+noyrs)
  l1 = getBCMfilenames(models=m, vars=v, years=yrs, months=1:12)
  head = getBCMfilenames(models=m,vars=v,years=yrs[1]-1, months=10:12)
  cutoff= getBCMfilenames(models=m,vars=v,years=yrs[length(yrs)], months=10:12)
  wf = c(head, l1[!l1%in%cutoff])
  
  p1 = rMeanFromFiles(fv=wf, chunksize=12)
  return(p1)
} 



# # Small function to calculate the mean across a given time series
# # reads in the relevant .rdata files and returns a summary raster
# MTmean = function(model='HST',var='ppt',mstart=1,mend=5,ystart=1920,yend=1920) {
#   require(raster)
#   
#   months <- as.character(mstart:mend)
#   months[nchar(months)==1] <- paste('0',months[nchar(months)==1],sep='')
#   
#   for(year in ystart:yend) {
#     tmp_list = list()
#     for(m in 1:length(months)) {
#       tmp_list[[m]] = readRDS(paste('CA_BCM_',model,'_Monthly_',var,'_',year,'_',months[m],'.Rdata',sep=''))[[1]]
#     }
#     tmp_mean = mean(stack(tmp_list))
#   }
#   if(year==ystart | ystart==yend) {
#     res=tmp_mean
#   } else {
#     res=mean(res,tmp_mean)
#   }  
#   return(res)
# }
