# Functions to summarize BCM2014 data
# Naia June 8 2015


# Function to get the file names of raster of interest to compute summaries
# can be used when only particular months of each year are wanted
# Multiple vars can be chosen (only meaningful for e.g. tmn and tmx!)
getBCMfilenames = function(models, vars, years, months,cdir) {
  require(raster)
    
  cmonths <- as.character(months)
  cmonths[nchar(cmonths)==1] <- paste('0',cmonths[nchar(cmonths)==1],sep='')
  
  gr = expand.grid(models,vars,years,cmonths)
  res = apply(gr,1,function(x) {
    paste(cdir,'CA_BCM_',x[1],'_Monthly_',x[2],'_',x[3],'_',x[4],'.Rdata',sep='')
  })
  
  return(res)
}



# Function to get the mean across BCM .rdata layers. 
# A chunksize can be set to limit the number of layers read into memory at a time.
# Returns a raster layer. tdir sets the temporary directory
rMeanFromFiles = function(fv, chunksize=2, tdir) {
  require(raster)
  rasterOptions(tmpdir=tdir)
  
  n = 1:length(fv)
  subs = split(n, ceiling(seq_along(n)/chunksize))
  for(i in 1:length(subs)) {
    print(paste(i, 'of', length(subs)))
    slist = lapply(fv[subs[[i]]], function(x) {readRDS(x)[[1]]})
    tmpres = mean(stack(slist))
    if(i==1) {
      res = tmpres
    } else {
      res = mean(res, tmpres)
    }
  }
  rm(tmpres)
  return(res)
}



multiwyrave = function(wyrstart, noyrs=30, m, v, cdir, tdir, wyrIn) {
  print(paste(wyrstart,m,v))
  yrs = (wyrstart):(wyrstart+noyrs-1)
  l1 = getBCMfilenames(models=m, vars=v, years=yrs, cdir=cdir, months=1:12)
  if(wyrIn == F) {
    head = getBCMfilenames(models=m,vars=v,years=yrs[1]-1, cdir=cdir, months=10:12)
    cutoff= getBCMfilenames(models=m,vars=v,years=yrs[length(yrs)], cdir=cdir, months=10:12)
    wf = c(head, l1[!l1%in%cutoff])
  } else {
    wf = l1
  }
    
  p1 = rMeanFromFiles(fv=wf, chunksize=12, tdir=tdir)
  print(Sys.time())
  return(p1)
} 
