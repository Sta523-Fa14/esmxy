library(RNetCDF)
library(stringr)

fillMissVar=function(myMatrix){
  naLoc=which(is.na(myMatrix[,,1]),arr.ind=T)
  for (i in 1:nrow(naLoc)){
    longi_index=naLoc[i,1]
    lati_index=naLoc[i,2]
    level_search=min(which(!is.na(myMatrix[longi_index,lati_index,])))
    myMatrix[longi_index,lati_index,1]=myMatrix[longi_index,lati_index,level_search]
  }
  surf_m=myMatrix[,,1]
  return(as.vector(surf_m))
}

CDFtoMatrix=function(fileNameCDF){
  nc = open.nc(fileNameCDF)
  long_coord=var.get.nc(nc,"longitude")
  lat_coord=var.get.nc(nc,"latitude")
  temp=var.get.nc(nc,"t")
  surf_temp=fillMissVar(temp)
  humid=var.get.nc(nc,"rh")
  surf_humid=fillMissVar(humid)
  final_m=cbind(rep(long_coord,length(lat_coord)),rep(lat_coord,each=length(long_coord)),surf_temp,surf_humid)
  colnames(final_m)=c("longitude","latitude","Temperature","RelativeHumidity")
  return(final_m)
}

#download files
dir.create("Cache")
dir.create("Cache/CDFfiles")
urlList=read.table("NetCDF_urlList",stringsAsFactors=FALSE)
urlList=cbind(urlList,str_extract(urlList[,1],"[0-9]+.SUB.nc"))
colnames(urlList)=c("URLs","fileNames")
for(i in 1:nrow(urlList)){
  if(urlList$fileNames[i] %in% list.files("Cache/CDFfiles/")){
    print("Target file already exists, moving to the next file")
  }else{
    download.file(urlList$URLs[i],paste0("Cache/CDFfiles/",urlList$fileNames[i]))
  }
}

#process files and combine to final dataframe
fileNameList=sort(paste0("Cache/CDFfiles/",urlList$fileNames))
dateList=str_extract(fileNameList,"[0-9]{6}")
finalData=do.call(rbind,lapply(fileNameList,CDFtoMatrix))
finalData=as.data.frame(finalData)
finalData=cbind(rep(dateList,each=4896L),finalData)
colnames(finalData)[1]="RecordDate"
save(finalData,file="finalData.rda")
