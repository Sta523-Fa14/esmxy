source("setup.R")

earthR=6367444.7
coordCalc=function(lon,lat){
  r=earthR*(90-lat)/180*pi
  if(lon>=0){
    coordx=r*cos((90-abs(lon))/180*pi)
    coordy=0-r*sin((90-abs(lon))/180*pi)
  }else{
    coordx=0-r*cos((90-abs(lon))/180*pi)
    coordy=0-r*sin((90-abs(lon))/180*pi)
  }
  resultCoord=c(coordx,coordy)
  return(resultCoord)
}

load("Output/Rdas/finalData.rda")
#testLon=c(-170,-150,-130,-90,-20,10,50,85,135)
#testLat=c(72,77,78,77,71,85,88,90,75)
#testData=data.frame(Lon=testLon,Lat=testLat)
#testData=cbind(testData,Xcoord=NA,Ycoord=NA)
finalData=cbind(finalData,Xcoord=NA,Ycoord=NA)
XcoordVec=double()
YcoordVec=double()
for(i in 1:4896){
  result=coordCalc(finalData$longitude[i],finalData$latitude[i])
  XcoordVec=append(XcoordVec,result[1])
  YcoordVec=append(YcoordVec,result[2])
}
finalData$Xcoord=rep(XcoordVec,35)
finalData$Ycoord=rep(YcoordVec,35)
convertedTempData=finalData
save(convertedTempData,file="Output/Rdas/convertedTempData.rda")
