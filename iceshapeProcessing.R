source("setup.R")

urls = seaiceeurls(mo="Sep", pole = "N")

#download files in the url list
fileNameList=cbind(urls,str_extract(urls,"extent_N_[0-9]{6}_polygon.zip"))
folderNameList=str_replace(fileNameList[,2],".zip","")
for (i in 1:nrow(fileNameList)){
  if(fileNameList[i,2] %in% list.files("Cache/Shapefiles")){
    print("File already exits! Moving to the next file")
    next
  }else{
    download.file(fileNameList[i,1],paste0("Cache/Shapefiles/",fileNameList[i,2]))
    Sys.sleep(2)
  }
}
for (i in 1:nrow(fileNameList)){
  unzip(paste0("Cache/Shapefiles/",fileNameList[i,2]),exdir=paste0("Cache/Shapefiles/",folderNameList[i]))
}
