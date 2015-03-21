# Identify individual polygon centroids ----------------------------------------
calcPolygonCentroids <- function(spatial_polygon){
  if(class(spatial_polygon) == "SpatialPolygonsDataFrame"){
    return(gCentroid(spatial_polygon, byid =TRUE, 
                     id =as.character(spatial_polygon@data[,1])))
  } else {
    np <- length(spatial_polygon@polygons[[1]]@Polygons)
    centroids <- lapply(seq(np), function(x){
      act_polygon <- spatial_polygon@polygons[[1]]@Polygons[[x]]
      act_polygon <- SpatialPolygons(list(Polygons(list(act_polygon), 
                                                   as.character(x))))
      proj4string(act_polygon) <- proj4string(spatial_polygon)
      data.frame(ID = x,
                 HOLE = spatial_polygon@polygons[[1]]@Polygons[[x]]@hole,
                 Centroid = gCentroid(act_polygon))
    })
    centroids <- do.call("rbind", centroids)
    return(SpatialPointsDataFrame(centroids[, 3:4], 
                                  data.frame(centroids[, -(3:4)]),
                                  proj4string = 
                                    CRS(proj4string(spatial_polygon))))
  }
}