project.html: project.Rmd Output/Figures/%.png
	Rscript -e "library(rmarkdown);render('project.Rmd')"

# Figures
Output/Figures/%.png: Output/Rdas/convertedTempData.rda Output/Rdas/seaiceArea.rda iceshapeModel.R Cache/Shapefiles/%.zip
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

Output/Shapefiles/%.json: iceshapeModel.R
	Rscript iceshapeModel.R


