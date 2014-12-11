toLoad=c('dplyr','stringr','rgdal', 'rgeos','rnoaa','RNetCDF', 
         'ggplot2','alphahull','igraph','prevR','gridExtra')

for(lib in toLoad){
  if(!(lib %in% installed.packages()[,1])){ 
    install.packages(lib, repos='http://cran.rstudio.com/') }
  library(lib, character.only=TRUE)
}


dir.create("Cache")
dir.create("Cache/CDFfiles")
dir.create("Cache/Shapefiles")
dir.create("Output")
dir.create("Output/Figures")
dir.create("Output/Rdas")
dir.create("Output/Shapefiles")