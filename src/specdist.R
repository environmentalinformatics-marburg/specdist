rm(list = ls(all = T))
# Script for analysing species distributions based on GBIF data dump
#
# The scripts analyse GBIF data along with environmental information.
# 
# Version: 0.0.0.9007
#
# Authors: J�rgen Kluge, Hanna Meyer, Thomas Nauss
# 
# License: GPL-3
# 
# Please send any comments, suggestions, criticism, or (for our sake) bug
# reports to admin@environmentalinformatics-marburg.de
# 
# General settings -------------------------------------------------------------

inpath <- "D:/active/juergen/"

preprocess <- FALSE

modulepath <- paste0(inpath, "scripts/specdist/src/")
datapath <- paste0(inpath, "data/")
datapath_gbif <- paste0(datapath, "gbif/")
# datapath_processed <- paste0(datapath, "processed/")
# datapath_climate <- paste0(datapath, "climate/")
# datapath_world <- paste0(datapath, "world/")

src <- list.files(modulepath, full.name = TRUE)
src <- src[-grep("src/specdist.R", src)]
sapply(src, function(x){source(x)})

library(countrycode)
library(maps)
library(maptools)
library(geosphere)
library(raster)
library(rgdal)
library(rgeos)
library(sp)


# Preprocessing of GBIF and other data -----------------------------------------
infile <- paste0(datapath_gbif, "gbif_PTERIDOPHYTA.txt")





if(preprocess){
  cntr <- readOGR(paste0(datapath_world, "world_boundaries.shp"), 
                  layer = "world_boundaries")
  infile <- paste0(datapath_org, "gbif_PTERIDOPHYTA.txt")
  df_clean <- loadGBIF(infile, datapath_processed, cntr)
  getBioclim(paste0(datapath_climate, "bioclim.txt"))
} else {
  #   load(paste0(datapath_processed, "df_clean.Rdata"))
  #   save(play_points, file = paste0(datapath_processed, "playground.Rdata"))
  #   bioclim <- loadBioclim()
  load(paste0(datapath_processed, "playground.Rdata"))
#   grid <- stack(paste0(datapath_world, "grid_area.tif"),
#                 paste0(datapath_world, "grid_lat.tif"), 
#                 paste0(datapath_world, "grid_lon.tif"))
}


# Playground -------------------------------------------------------------------

# # Define projection of gbif observations
# # prj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
# # coords_id <- c(grep("Lon", colnames(df)), grep("Lat", colnames(df)))
# 
# # Subset gbif for a certain species and convert to spatial points data frame
# # play <- df[df$speciesKey == "2650774", ]
# # play <- play[complete.cases(play[, coords_id]), ]
# # summary(play[, coords_id])
# # 
# # play_points <- SpatialPointsDataFrame(play[, coords_id],
# #                                       play[, -coords_id],
# #                                       proj4string = CRS(prj))
# 
# # Load country boundaries
# cntr <- readOGR(paste0(datapath_world, "world_boundaries.shp"), 
#                 layer = "world_boundaries")
# 
# str(play_points)
# plot(grid[[1]])
# plot(cntr, border = "black", add = TRUE)
# plot(play_points, col = "blue", add = TRUE)
# 
# # Extract grid values
# play_points_grid <- extract(grid, play_points, cellnumbers = TRUE)
# play_points_grid <- aggregate(play_points_grid, 
#                               by = list(play_points_grid[, 1]), FUN = "mean")
# distance <- calcPointDist(play_points_grid)
# 
# 
# # Load country boundaries
# cntr <- readOGR(paste0(datapath_world, "world_boundaries.shp"), 
#                        layer = "world_boundaries")
# cntr <- spTransform(cntr, CRS("+proj=moll +lon_0=0"))
# 
# # Define projection of gbif observations
# prj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
# coords_id <- c(grep("Lon", colnames(df)), grep("Lat", colnames(df)))
# 
# # Subset gbif for a certain species and convert to spatial points data frame
# play <- df[df$speciesKey == "2650774", ]
# play <- play[complete.cases(play[, coords_id]), ]
# summary(play[, coords_id])
# 
# play_points <- SpatialPointsDataFrame(play[, coords_id],
#                                       play[, -coords_id],
#                                       proj4string = CRS(prj))
# 
# play_points <- spTransform(play_points, CRS("+proj=moll +lon_0=0"))
# 
# # Compute some parameters (convex hul, area, intersect with countries)
# envelope <- gConvexHull(play_points, byid = FALSE)
# intersect <- gIntersection(cntr, envelope, byid = TRUE)
# 
# envelope_area <- gArea(envelope)
# intersect_area <- gArea(intersect)
# 
# metrics <- data.frame(ENVELOPE_AREA = envelope_area,
#                       LAND_AREA = intersect_area,
#                       SEA_AREA = envelope_area - intersect_area,
#                       LAND_ENVELOPE_RATIO = intersect_area / envelope_area,
#                       SEA_ENVELOPE_RATIO = (envelope_area - intersect_area) / 
#                         envelope_area,
#                       LAND_SEA_RATIO = intersect_area / 
#                         (envelope_area - intersect_area),
#                       ENVELOPE_EARTH_RATIO = envelope_area / (4 * pi * 6371**2))
# 
# # Plot some stuff
# plot(cntr)
# plot(play_points, col = "darkgreen", add = TRUE)
# plot(envelope, border = "green", add = TRUE)
# plot(intersect, border = "blue", add = TRUE)


# V2
cntr <- readOGR(paste0(datapath_world, "world_boundaries.shp"), 
                layer = "world_boundaries")
cntr_mw <- spTransform(cntr, CRS("+init=ESRI:54009"))


# # Subset gbif for a certain species and convert to spatial points data frame
# coords_id <- c(grep("Lon", colnames(df)), grep("Lat", colnames(df)))
# play <- df[df$speciesKey == "2650774", ]
# play <- play[complete.cases(play[, coords_id]), ]
# summary(play[, coords_id])
# play_points <- SpatialPointsDataFrame(play[, coords_id],
#                                       play[, -coords_id],
#                                       proj4string = CRS("+init=EPSG:4326"))
play_points_mw <- spTransform(play_points, CRS("+init=ESRI:54009"))

# Compute gbif metrics
gbif_metrics <- calcGBIFMetrics(play_points_mw)

plot(cntr_mw)
plot(play_points_mw, col = "darkgreen", add = TRUE)
plot(gbif_metrics$data$subareals$buffer_mw_union, border = "red", add = TRUE)
plot(gbif_metrics$data$centroids[gbif_metrics$data$centroids$HOLE==0,], 
     col = "blue", cex = 2, lwd = 1, add = TRUE)


