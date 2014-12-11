source("setup.R")

load("Output/Rdas/convertedTempData.rda")
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
#plot histogram overlay of temperature distributions between ICE and noICE  
  if(i %in% c(15,25,35)){
    png(paste0("Output/Figures/tempHisto_",currentDate,".png"),width=800,height=300)
    plot(0,xlim=c(250,280),ylim=c(0,0.35),xlab="Temperature(K)",ylab="Density",main=currentDate)
    lines(noICE_density,col="red")
    lines(ICE_density,col="blue") 
    dev.off()
  }  
}



LMnoICE_mean=lm(modelData$noICE_mean~seq_along(modelData$RecordDate))
LMnoICE_sd=lm(modelData$noICE_sd~seq_along(modelData$RecordDate))
LMICE_mean=lm(modelData$ICE_mean~seq_along(modelData$RecordDate))
LMICE_sd=lm(modelData$ICE_sd~seq_along(modelData$RecordDate))

#Plot mean temperature regression with time
png("Output/Figures/meanTempRegression.png",width=500,height=300)
plot(0,xlim=c(0,36),ylim=c(262,272.5),xlab="Years",ylab="MeanTemp",main="mean ICE/noICE temperature change with time")
points(seq_along(modelData$RecordDate),modelData$noICE_mean,col="red")
abline(LMnoICE_mean,col="red")
points(seq_along(modelData$RecordDate),modelData$ICE_mean,col="blue")
abline(LMICE_mean,col="blue")
dev.off()

#predict mean and sd values 5, 10 and 50 years after 2013 (201809,202309,206309)
predictData=data.frame(PredictDate=c("201809","202309","206309"),noICE_mean=NA,noICE_sd=NA,ICE_mean=NA,ICE_sd=NA,ThresholdnoICE=NA,ThresholdICE=NA,stringsAsFactors=FALSE)
for (i in 1:nrow(predictData)){
  ThresholdQ=0.6
  yearSeq=(as.numeric(predictData$PredictDate[i])-197809)/100
  predictData$noICE_mean[i]=LMnoICE_mean[1]$coeff[1]+yearSeq*LMnoICE_mean[1]$coeff[2]
  predictData$noICE_sd[i]=LMnoICE_sd[1]$coeff[1]+yearSeq*LMnoICE_sd[1]$coeff[2]
  predictData$ICE_mean[i]=LMICE_mean[1]$coeff[1]+yearSeq*LMICE_mean[1]$coeff[2]
  predictData$ICE_sd[i]=LMICE_sd[1]$coeff[1]+yearSeq*LMICE_sd[1]$coeff[2]
  predictData$ThresholdnoICE[i]=qnorm(1-ThresholdQ,predictData$noICE_mean[i],predictData$noICE_sd[i])
  predictData$ThresholdICE[i]=qnorm(ThresholdQ,predictData$ICE_mean[i],predictData$ICE_sd[i])
}
png("Output/Figures/thresholdTable.png",width=800,height=200)
grid.table(predictData)
dev.off()

#predict temperature for each coordinate point 5, 10 and 50 years after 2013
sortTempData=arrange(convertedTempData,Xcoord,Ycoord,RecordDate)
coordSeq=seq(1,nrow(sortTempData),35)
predictTemp=data.frame(Xcoord=sortTempData$Xcoord[coordSeq],Ycoord=sortTempData$Ycoord[coordSeq],FiveYTemp=NA,TenYTemp=NA,FiftyYTemp=NA)

i=1L
while(nrow(sortTempData)>=35){
  TempData=sortTempData[1:35,]
  LMpointTemp=lm(TempData$Temperature~seq_along(TempData$RecordDate))
  predictTemp$FiveYTemp[i]=LMpointTemp[1]$coeff[1]+40*LMpointTemp[1]$coeff[2]
  predictTemp$TenYTemp[i]=LMpointTemp[1]$coeff[1]+45*LMpointTemp[1]$coeff[2]
  predictTemp$FiftyYTemp[i]=LMpointTemp[1]$coeff[1]+85*LMpointTemp[1]$coeff[2]
  i=i+1
  sortTempData=sortTempData[-(1:35),]
}

#predict whether point to have temperature below predicted ice-cap thresholds
predictPoints=data.frame(Xcoord=predictTemp$Xcoord,Ycoord=predictTemp$Ycoord,FiveYtight=NA,FiveYloose=NA,TenYtight=NA,TenYloose=NA,FiftyYtight=NA,FiftyYloose=NA)
predictPoints$FiveYtight=predictTemp$FiveYTemp<=predictData$ThresholdICE[1]
predictPoints$FiveYloose=predictTemp$FiveYTemp<=predictData$ThresholdnoICE[1]
predictPoints$TenYtight=predictTemp$FiveYTemp<=predictData$ThresholdICE[2]
predictPoints$TenYloose=predictTemp$FiveYTemp<=predictData$ThresholdnoICE[2]
predictPoints$FiftyYtight=predictTemp$FiveYTemp<=predictData$ThresholdICE[3]
predictPoints$FiftyYloose=predictTemp$FiveYTemp<=predictData$ThresholdnoICE[3]

#Generateing polygons from the alpha hull
polygonGen=function(predict_colnum){
  plotPoints=predictPoints[which(predictPoints[,predict_colnum]==TRUE),]
  t=ashape(plotPoints$Xcoord,plotPoints$Ycoord,200000)
  tg = graph.edgelist(cbind(as.character(t$edges[, "ind1"]), as.character(t$edges[,"ind2"])), directed = FALSE)
  cutg = tg-E(tg)[1]
  ends = names(which(degree(cutg) == 1))
  path = get.shortest.paths(cutg, ends[1], ends[2])[[1]]
  pathX = as.numeric(V(tg)[unlist(path)]$name)
  pathX = c(pathX, pathX[1])
  lineCoords=t$x[pathX, ]
  return(Polygon(lineCoords))
}

#Output spatial polygon data frame
polyDataFrameGen=function(input){
  if(grepl("five",tolower(input))){
    colNum=3
  }else if(grepl("ten",tolower(input))){
    colNum=5
  }else{
    colNum=7
  }
  polytight=polygonGen(colNum)
  polyloose=polygonGen(colNum+1)
  polystight = Polygons(list(polytight), "tight")
  polysloose = Polygons(list(polyloose), "loose")
  polyCombine=SpatialPolygons(list(polysloose,polystight),1:2)
  data=data.frame(c(polyloose@area,polytight@area),row.names=c("loose","tight"))
  SpDF=SpatialPolygonsDataFrame(polyCombine, data)
  
  png(paste0("Output/Figures/predictShape_",input,".png"),width=1000,height=800)
  plot(SpDF,col=c("lightgreen","blue"),main=input,xlim=c(-1500000,1500000),ylim=c(-2000000,1500000))
  points(predictPoints$Xcoord,predictPoints$Ycoord,pch=".")
  dev.off()
  
  writeOGR(SpDF, dsn = paste0("Output/Shapefiles/",input,".json"), layer = input, driver = "GeoJSON")
  return(SpDF)
}

polyFiveY=polyDataFrameGen("FiveYears")
polyTenY=polyDataFrameGen("TenYears")
polyFiftyY=polyDataFrameGen("FiftyYears")

load("Output/Rdas/seaiceArea.rda")
subsetArea=filter(seaiceArea,mo==9&yr %in% c(1983,2003,2008,2013))
predictArea=c(polyFiveY@data[[1]][2],polyTenY@data[[1]][2],polyFiftyY@data[[1]][2])
predictArea=predictArea/1e12
plotArea=c(subsetArea$ext,predictArea)
names(plotArea)=c("1983","2003","2008","2013","2018","2023","2063")

png("Output/Figures/iceAreaPrediction.png",width=800,height=400)
barplot(plotArea,col=c("grey","grey","grey","grey","blue","blue","blue"),ylab="x10^12 m2",main="Ice area predictions with tight threshold")
dev.off()
