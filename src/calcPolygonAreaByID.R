# Calculate individual surface of multiple polygons on a cartographic grid -----
calcPolygonAreaByID <- function(spatial_polygon){
  area <- lapply(
    seq(length(spatial_polygon@polygons[[1]]@Polygons)), function(x){
      act_polygon <- spatial_polygon@polygons[[1]]@Polygons[[x]]
      act_polygon <- SpatialPolygons(list(Polygons(list(act_polygon), 
                                                   as.character(x))))
      proj4string(act_polygon) <- proj4string(spatial_polygon)
      areas <- gArea(act_polygon)
      data.frame(ID = x,
                 AREA = areas,
                 AREA_REL = areas / (4*pi*6371000**2),
                 HOLE = spatial_polygon@polygons[[1]]@Polygons[[x]]@hole)
    })
  do.call("rbind", area)
}

