library(rgeos)
library(raster)
library(rgdal)

shape=readOGR(paste0("Cache/Shapefiles/","extent_N_197901_polygon"), "extent_N_197901_polygon")
plot(shape)
segments(-5000000,-6000000,-5000000,6000000)
segments(5000000,-6000000,5000000,6000000)
segments(-5000000,-6000000,5000000,-6000000)
segments(-5000000,6000000,5000000,6000000)

