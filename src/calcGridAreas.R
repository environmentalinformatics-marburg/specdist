#' Calculates grid lat, lon and area
#' 
#' Generate three raster layers containing pixels longitude, latitude and
#' area information
#' 
#' @param grid a raster data set
#' 
#' @return nothing, just save the generated rasters as GeoTiff
#' 
#' 
require(raster)
calcGridAreas <- function(grid){
  #   bioclim  <- loadBioclim()
  lat <- grid
  lat_values <- matrix(rep(seq((extent(lat)@ymax - 1/60*1.25), 
                               extent(lat)@ymin, -1/60*2.5), ncol(lat)),
                       nrow = nrow(lat), ncol = ncol(lat))
  lat <- setValues(lat, lat_values)
  #   plot(lat)
  
  lon <- grid
  lon_values <- matrix(rep(seq((extent(lat)@xmin + 1/60*1.25), 
                               extent(lat)@xmax, 1/60*2.5), nrow(lon)),
                       nrow = nrow(lon), ncol = ncol(lon), byrow = TRUE)
  lon <- setValues(lon, lon_values)
  #   plot(lon)
  
  area_025 <- (2 * pi * 6371 / (360 * 60 / 2.5))**2
  
  area <- grid
  area_values <- area_025 * cos(getValues(lat) * pi / 180)
  area <- setValues(area, area_values)
  #   plot(area)
  
  writeRaster(lat, paste0(datapath_world, "grid_lat.tif"))
  writeRaster(lon, paste0(datapath_world, "grid_lon.tif"))
  writeRaster(area, paste0(datapath_world, "grid_area.tif"))
}
