library(rnoaa)
library(stringr)
library(rgeos)
library(rgdal)
library(maptools)

urls = seaiceeurls(mo="Sep", pole = "N")


dir.create("Cache")
dir.create("Cache/Shapefiles")

#download files in the url list
fileNameList=cbind(urls,str_extract(urls,"extent_N_[0-9]{6}_polygon.zip"))
folderNameList=str_replace(fileNameList[,2],".zip","")
for (i in 1:nrow(fileNameList)){
  if(fileNameList[i,2] %in% list.files("Cache/Shapefiles")){
    print("File already exits! Moving to the next file")
    next
  }else{
    download.file(fileNameList[i,1],paste0("Cache/Shapefiles/",fileNameList[i,2]))
    unzip(paste0("Cache/Shapefiles/",fileNameList[i,2]),exdir=paste0("Cache/Shapefiles/",folderNameList[i]))
    Sys.sleep(1)
  }
}

get_areas = function(p)
{
  sapply(p@polygons, function(x) x@area)
}

areaData=data.frame(RecordDate=character(),IceArea=double())
for(i in 1:length(folderNameList)){
  current_shape=readOGR(paste0("Cache/Shapefiles/",folderNameList[i]),folderNameList[i])
  areaSum=sum(get_areas(current_shape))
  current_date=str_extract(folderNameList[i],"[0-9]{6}")
  newData=data.frame(RecordDate=current_date,IceArea=areaSum,stringsAsFactors=FALSE)
  areaData=rbind(areaData,newData)
}

save(areaData, file="areaData.rda")