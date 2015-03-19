# Identify individual polygon centroids ----------------------------------------
calcPolygonCentroids <- function(spatial_polygon){
  centroids <- lapply(seq(length(spatial_polygon@polygons[[1]]@Polygons)), 
                      function(x){
                        act_polygon <- spatial_polygon@polygons[[1]]@Polygons[[x]]
                        act_polygon <- SpatialPolygons(list(Polygons(list(act_polygon), 
                                                                     as.character(x))))
                        proj4string(act_polygon) <- proj4string(spatial_polygon)
                        data.frame(ID = x,
                                   HOLE = spatial_polygon@polygons[[1]]@Polygons[[x]]@hole,
                                   Centroid = gCentroid(act_polygon))
                      })
  centroids <- do.call("rbind", centroids)
  SpatialPointsDataFrame(centroids[, 3:4],
                         data.frame(centroids[, -(3:4)]),
                         proj4string = CRS(proj4string(spatial_polygon)))
}