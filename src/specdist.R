rm(list = ls(all = T))
# Script for analysing species distributions based on GBIF data dump
#
# The scripts analyse GBIF data along with environmental information.
# 
# Version: 0.0.0.9006
#
# Authors: Jürgen Kluge, Hanna Meyer, Thomas Nauss
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
datapath_org <- paste0(datapath, "org/")
datapath_processed <- paste0(datapath, "processed/")
datapath_climate <- paste0(datapath, "climate/")
datapath_world <- paste0(datapath, "world/")

src <- list.files(modulepath, full.name = TRUE)
src <- src[-grep("src/specdist.R", src)]
sapply(src, function(x){source(x)})

library(maps)
library(maptools)
library(geosphere)
library(raster)
library(rgdal)
library(rgeos)
library(sp)


# Preprocessing of GBIF and other data -----------------------------------------
if(preprocess){
  infile <- paste0(datapath_org, "gbif_PTERIDOPHYTA.txt")
  readGBIF(infile, datapath_processed)

  load(paste0(datapath_processed, "df.Rdata"))
  df <- df[-1,]
  df$Lat <- as.numeric(as.character(df$decimalLatitude))
  df$Lon <- as.numeric(as.character(df$decimalLongitude))
  df$decimalLatitude <- NULL
  df$decimalLongitude <- NULL
  save(df, file = paste0(datapath_processed, "df_clean.Rdata"))
  
  getBioclim(paste0(datapath_climate, "bioclim.txt"))
} else {
  load(paste0(datapath_processed, "df_clean.Rdata"))
}


# Playground -------------------------------------------------------------------

# Load country boundaries
cntr <- readOGR(paste0(datapath_world, "wb.shp"), 
                       layer = "wb")

# Define projection of gbif observations
prj <- proj4string(cntr)
coords_id <- c(grep("Lon", colnames(df)), grep("Lat", colnames(df)))

# Subset gbif for a certain species and convert to spatial points data frame
play <- df[df$speciesKey == "2650774", ]
play <- play[complete.cases(play[, coords_id]), ]
summary(play[, coords_id])

play_points <- SpatialPointsDataFrame(play[, coords_id],
                                      play[, -coords_id],
                                      proj4string = CRS(prj))

# Compute some parameters (convex hul, area, intersect with countries)
envelope <- gConvexHull(play_points)
intersect <- gIntersection(cntr, envelope, byid = TRUE)

envelope_mp <- dividePolygon(envelope)
envelope_area <- sum(areaPolygon(envelope_mp)) / 1000**2
perimr <- sum(perimeter(envelope_mp)) / 1000

intersect_area <- sum(areaPolygon(intersect)) / 1000**2

metrics <- data.frame(ENVELOPE_AREA = envelope_area,
                      LAND_AREA = intersect_area,
                      SEA_AREA = envelope_area - intersect_area,
                      LAND_ENVELOPE_RATIO = intersect_area / envelope_area,
                      SEA_ENVELOPE_RATIO = (envelope_area - intersect_area) / 
                        envelope_area,
                      LAND_SEA_RATIO = intersect_area / 
                        (envelope_area - intersect_area))

# Plot some stuff
plot(cntr)
plot(play_points, col = "darkgreen", add = TRUE)
plot(envelope, border = "green", add = TRUE)
plot(envelope_mp, border = "darkgreen", add = TRUE)
plot(intersect, border = "blue", add = TRUE)
plot(testenv, border = "green", add = TRUE)


envelope_area_non_mp <- sum(areaPolygon(envelope)) / 1000**2
metrics_non_mp <- data.frame(envelope_area_non_mp = envelope_area_non_mp,
                             LAND_AREA = intersect_area,
                             SEA_AREA = envelope_area_non_mp - intersect_area,
                             LAND_ENVELOPE_RATIO = intersect_area / 
                               envelope_area_non_mp,
                             SEA_ENVELOPE_RATIO = (envelope_area_non_mp - 
                                                     intersect_area) / 
                               envelope_area_non_mp,
                             LAND_SEA_RATIO = intersect_area / 
                               (envelope_area_non_mp - intersect_area))