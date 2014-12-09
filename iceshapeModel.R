library(rgeos)
library(raster)
library(rgdal)
library(prevR)

load("convertedTempData.rda")

modelData=data.frame(RecordDate=character(),noICE=double(),ICE=double())
shape=readOGR(paste0("Cache/Shapefiles/","extent_N_","198009","_polygon"), "extent_N_198009_polygon")
shape1=shape[shape$INDEX==0,]
TempData=convertedTempData[grep("198009",convertedTempData$RecordDate),]
ptsCheck=point.in.SpatialPolygons(TempData$Xcoord,TempData$Ycoord,shape1)
noICETemps=TempData$Temperature[which(ptsCheck==FALSE)]
ICETemps=TempData$Temperature[which(ptsCheck==TRUE)]
meanICETemps