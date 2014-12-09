library(dplyr)
library(rgeos)
library(raster)
library(rgdal)
library(prevR)

load("convertedTempData.rda")
RecordDateList=unique(as.character(convertedTempData$RecordDate))

modelData=data.frame(RecordDate=RecordDateList,noICE_mean=NA,noICE_sd=NA,ICE_mean=NA,ICE_sd=NA)
for( i in 1:length(RecordDateList)){
  currentDate=RecordDateList[i]
  shape=readOGR(paste0("Cache/Shapefiles/","extent_N_",currentDate,"_polygon"), paste0("extent_N_",currentDate,"_polygon"))
  shape1=shape[shape$INDEX==0,]
  TempData=convertedTempData[grep(currentDate,convertedTempData$RecordDate),]
  ptsCheck=point.in.SpatialPolygons(TempData$Xcoord,TempData$Ycoord,shape1)
  noICETemps=TempData$Temperature[which(ptsCheck==FALSE)]
  ICETemps=TempData$Temperature[which(ptsCheck==TRUE)]
  
  modelData$noICE_mean[i]=mean(noICETemps)
  modelData$noICE_sd[i]=sd(noICETemps)
  modelData$ICE_mean[i]=mean(ICETemps)
  modelData$ICE_sd[i]=sd(ICETemps)
  
  noICE_density=density(noICETemps)
  ICE_density=density(ICETemps)
  
}

LMnoICE_mean=lm(modelData$noICE_mean~seq_along(modelData$RecordDate))
LMnoICE_sd=lm(modelData$noICE_sd~seq_along(modelData$RecordDate))
LMICE_mean=lm(modelData$ICE_mean~seq_along(modelData$RecordDate))
LMICE_sd=lm(modelData$ICE_sd~seq_along(modelData$RecordDate))

#predict mean and sd values 5, 10 and 50 years after 2013 (201809,202309,206309)
predictData=data.frame(PredictDate=c("201809","202309","206309"),noICE_mean=NA,noICE_sd=NA,ICE_mean=NA,ICE_sd=NA,ThresholdnoICE=NA,ThresholdICE=NA,stringsAsFactors=FALSE)
for (i in 1:nrow(predictData)){
  ThresholdQ=0.7
  yearSeq=(as.numeric(predictData$PredictDate[i])-197809)/100
  predictData$noICE_mean[i]=LMnoICE_mean[1]$coeff[1]+yearSeq*LMnoICE_mean[1]$coeff[2]
  predictData$noICE_sd[i]=LMnoICE_sd[1]$coeff[1]+yearSeq*LMnoICE_sd[1]$coeff[2]
  predictData$ICE_mean[i]=LMICE_mean[1]$coeff[1]+yearSeq*LMICE_mean[1]$coeff[2]
  predictData$ICE_sd[i]=LMICE_sd[1]$coeff[1]+yearSeq*LMICE_sd[1]$coeff[2]
  predictData$ThresholdnoICE[i]=qnorm(1-ThresholdQ,predictData$noICE_mean[i],predictData$noICE_sd[i])
  predictData$ThresholdICE[i]=qnorm(ThresholdQ,predictData$ICE_mean[i],predictData$ICE_sd[i])
}

#predict temperature for each coordinate point 5, 10 and 50 years after 2013
sortTempData=arrange(convertedTempData,Xcoord,Ycoord,RecordDate)
