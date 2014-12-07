link_n = "http://processtrends.com/files/RClimate_NSIDC_sea_ice_extent.csv"
seaiceArea = read.table(link_n, skip = 1, sep = ",", header = F,
                  colClasses = rep("numeric", 5),
                  comment.char = "#", na.strings = c("NA",-9999),
                  col.names = c("yr_frac", "yr", "mo", "ext", "area"))
seaiceArea = subset(seaiceArea, seaiceArea$yr >1978 & seaiceArea$yr < 2014)
save(seaiceArea,file="seaiceArea.rda")