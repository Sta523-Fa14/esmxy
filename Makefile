project.html: project.Rmd Output/Figures/iceAreaPrediction.png Output/Figures/meanTempRegression.png Output/Figures/predictShape_FiveYears.png Output/Figures/predictShape_TenYears.png Output/Figures/predictShape_FiftyYears.png Output/Figures/tempHisto_199309.png Output/Figures/tempHisto_200309.png Output/Figures/tempHisto_201309.png Output/Figures/thresholdTable.png
	Rscript -e "library(rmarkdown);render('project.Rmd')"

# Figures
Output/Figures/iceAreaPrediction.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R

Output/Figures/meanTempRegression.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R

Output/Figures/predictShape_FiveYears.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R

Output/Figures/predictShape_TenYears.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R

Output/Figures/predictShape_FiftyYears.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R

Output/Figures/tempHisto_199309.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R

Output/Figures/tempHisto_200309.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R

Output/Figures/tempHisto_201309.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R

Output/Figures/thresholdTable.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
	Rscript iceshapeModel.R


# Rda files
Output/Rdas/convertedTempData.rda: Output/Rdas/finalData.rda coordinateConversion.R
	Rscript coordinateConversion.R

Output/Rdas/finalData.rda: Cache/CDFfiles/%.nc CDFprocessing.R
	Rscript CDFprocessing.R

Output/Rdas/seaiceArea.rda: seaiceArea.R
	Rscript seaiceArea.R

# NetCDF files and Shape files
Cache/CDFfiles/%.nc: NetCDF_urlList CDFprocessing.R
	Rscript CDFprocessing.R

Cache/Shapefiles/%.zip: iceshapeProcessing.R
	Rscript iceshapeProcessing.R



