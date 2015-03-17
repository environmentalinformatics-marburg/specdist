# Script for analysing species distributions based on GBIF data dump

# General settings -------------------------------------------------------------
inpath <- "D:/active/juergen/"

preprocess <- FALSE
clean <- FALSE

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


# Preprocessing of GBIF data ---------------------------------------------------
if(preprocess){
  infile <- paste0(datapath_org, "gbif_PTERIDOPHYTA.txt")
  readGBIF(infile, datapath_processed)
} else {
  load(paste0(datapath_processed, "df.Rdata"))
}

# Get Bioclim data -------------------------------------------------------------
if(preprocess){
  getBioclim(paste0(datapath_climate, "bioclim.txt"))
}


# Clean up gbif data -----------------------------------------------------------
if(clean){
  df <- df[-1,]
  df$Lat <- as.numeric(as.character(df$decimalLatitude))
  df$Lon <- as.numeric(as.character(df$decimalLongitude))
  df$decimalLatitude <- NULL
  df$decimalLongitude <- NULL
  save(df, file = paste0(datapath_processed, "df_clean.Rdata"))
} else {
  load(paste0(datapath_processed, "df_clean.Rdata"))
}


# Playground -------------------------------------------------------------------

# Country boundaries

# Testing some cases since the geospherical area computation does not fit estimates
cntr <- readOGR(paste0(datapath_world, "wb.shp"), 
                       layer = "wb")

afrika <- readOGR(paste0(datapath_world, "afrika.shp"), 
                  layer = "afrika")
a <- areaPolygon(afrika)
sum(a/1000000)

sa <- readOGR(paste0(datapath_world, "sueamerika.shp"), 
                  layer = "sueamerika")
saa <- areaPolygon(sa)
sum(saa/1000000)

both <- readOGR(paste0(datapath_world, "both.shp"), 
              layer = "both")
botha <- areaPolygon(both)
sum(botha/1000000)

testenv <- readOGR(paste0(datapath_world, "testenv.shp"), 
                layer = "testenv")
testenva <- areaPolygon(testenv)
sum(testenva/1000000)


sum(botha/1000000) / sum(testenva/1000000)



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
convh <- gConvexHull(play_points)
area <- areaPolygon(convh) / 1000000

intersect <- gIntersection(cntr, convh, byid = TRUE)
intersect_areas <- areaPolygon(intersect) / 1000000

metrics <- data.frame(ENVELOPE_AREA = area,
                      LAND_AREA = sum(intersect_areas),
                      SEA_AREA = area - sum(intersect_areas),
                      LAND_ENVELOPE_RATIO = sum(intersect_areas) / area,
                      SEA_ENVELOPE_RATIO = (area - sum(intersect_areas)) / area,
                      LAND_SEA_RATIO = sum(intersect_areas) / 
                        (area - sum(intersect_areas)))

# Plot some stuff
plot(cntr)
plot(play_points, col = "darkgreen", add = TRUE)
plot(convh, border = "green", add = TRUE)
plot(intersect, border = "blue", add = TRUE)
plot(testenv, border = "green", add = TRUE)

