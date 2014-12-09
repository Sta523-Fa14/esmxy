library(rgeos)
library(raster)
library(rgdal)

shape=readOGR(paste0("Cache/Shapefiles/","extent_N_201309_polygon"), "extent_N_201309_polygon")
shape1=shape[shape$INDEX==0,]
plot(shape1)
segments(-2200000,-2200000,-2200000,2200000)
segments(1500000,-2500000,1500000,2500000)
segments(-1500000,-2500000,1500000,-2500000)
segments(-1500000,2500000,1500000,2500000)

