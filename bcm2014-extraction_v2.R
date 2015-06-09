#############################################################################################
# May 2015
# Script to download monthly BCM2014 data from USGS website
# Updated by David Ackerly and Naia Morueta-Holme based on script by Sam Veloz

# The script is set to download all monthly data, historic (1920-2009) and 18 future 
# scenarios (2010-2099). Change "myrange" to select a subset of scenarios

# The files downloaded have extension .nc (use package ncdf4 to open) and contain layers all
# calendar months for the given year
#############################################################################################

#---------------#
# Set variables #
#---------------#
#Select local folder where you want to download data to
wdir<-"H:/Climate/BCM_2014/ncdf/"

#Select which models to download (see below: "model")
myrange<-7:19


variable<-c('tmn_',"tmx_","ppt_","run_","rch_","cwd_","aet_","pet_","str_")
server<-"http://cida.usgs.gov/thredds/fileServer/CA-BCM-2014/"

#Historic model and 18 future scenarios
model<-c("HST","GFDL_B1","GFDL_A2","PCM_A2","CNRM_rcp85","CCSM4_rcp85","MIROC_rcp85",
         "PCM_B1","MIROC3_2_A2","csiro_A1B","GISS_AOM_A1B","MIROC5_rcp26","MIROC_rcp45",
         "MIROC_rcp60","GISS_rcp26","MRI_rcp26","MPI_rcp45","IPSL_rcp85","Fgoals_rcp85")

#----------------#
# Run the script #
#----------------#
#List of file names used to write to disk
fnames<-lapply(variable, function(a) {
  paste(sapply(model, function(x) {
    paste("CA_BCM",x,"Monthly",sep="_")
    }), a, sep="_")})


mm=5
for(mm in 1:9){ ###Based on which variables you want, valid numbers 1:9, or length(variable) above
  #Create vector of url names for all models
  mods<-as.character(sapply(model, function(x) {
    paste(server, x, "/Monthly/CA_BCM_", x, "_Monthly_", variable[mm],sep="")}))
    
  j=10
  for(j in myrange){
    year<-ifelse(j==1,as.data.frame(1920:2009),as.data.frame(2010:2099))
    tempmod<-mods[j]
    tempf<-fnames[[mm]][j]
        
    k=1
    for(k in 1:90){
      yr<-year[[1]][k]
      #get nc file web url
      url_grid <-paste(tempmod,yr,".nc",sep="")
            
      ff<-paste(wdir,tempf,yr,".nc",sep="")
            
      print(c(mm,j,k))
      print(Sys.time())
      w<-1
      options(timeout=600)
      while(inherits(w,"try-error") | w != 0){
        w<-try(download.file(url_grid, ff, method = "auto", quiet = FALSE, mode = "wb"),silent=F)
      }
      #This should download the file to the directory you specify above (ff).
    }
  }
}

