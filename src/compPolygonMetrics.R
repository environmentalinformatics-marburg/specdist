# # Calculate individual surface of multiple polygons on a cartographic grid -----
# calcPolygonAreaByID <- function(spatial_polygon){
#   area <- lapply(
#     seq(length(spatial_polygon@polygons[[1]]@Polygons)), function(x){
#         act_polygon <- spatial_polygon@polygons[[1]]@Polygons[[x]]
#         act_polygon <- SpatialPolygons(list(Polygons(list(act_polygon), 
#                                                      as.character(x))))
#         proj4string(act_polygon) <- proj4string(spatial_polygon)
#         data.frame(ID = x,
#                    AREA = gArea(act_polygon),
#                    HOLE = spatial_polygon@polygons[[1]]@Polygons[[x]]@hole)
#     })
#   do.call("rbind", area)
# }
# 
# 
# # Calculate surface of polygons on a cartographic grid -------------------------
# calcPolygonArea <- function(spatial_polygon){
#   area_by_id <- calcPolygonAreaByID(spatial_polygon)
#   area <- data.frame(SUM = sum(area_by_id$AREA),
#                      SUM_AREA = sum(area_by_id$AREA[area_by_id$HOLE == FALSE]),
#                      SUM_HOLES = sum(area_by_id$AREA[area_by_id$HOLE == TRUE]))
# }
# 
# 
# # Identify individual polygon centroids ----------------------------------------
# calcPolygonCentroids <- function(spatial_polygon){
#   centroids <- lapply(seq(length(spatial_polygon@polygons[[1]]@Polygons)), 
#                  function(x){
#                    act_polygon <- spatial_polygon@polygons[[1]]@Polygons[[x]]
#                    act_polygon <- SpatialPolygons(list(Polygons(list(act_polygon), 
#                                                                 as.character(x))))
#                    proj4string(act_polygon) <- proj4string(spatial_polygon)
#                    data.frame(ID = x,
#                               HOLE = spatial_polygon@polygons[[1]]@Polygons[[x]]@hole,
#                               Centroid = gCentroid(act_polygon))
#                  })
#   centroids <- do.call("rbind", centroids)
#   SpatialPointsDataFrame(centroids[, 3:4],
#                          data.frame(centroids[, -(3:4)]),
#                          proj4string = CRS(proj4string(spatial_polygon)))
# }
# 
# 
# # Divide spatial polygon into triangles ----------------------------------------
# dividePolygon <- function(spatial_polygon){
#   coords <- spatial_polygon@polygons[[1]]@Polygons[[1]]@coords
#   
#   coords_new <- lapply(seq(nrow(coords)-3), function(x){
#     Polygons(list(Polygon(coords[c(1, x+1, x+2, nrow(coords)), ])), 
#              as.character(x))
#   })
#   spatial_polygon_mp <- SpatialPolygons(coords_new)
#   proj4string(spatial_polygon_mp) <- proj4string(spatial_polygon)
#   return(spatial_polygon_mp)
# }
# 
# 
# # Calculate individual surface of multiple triangular polygons on the earth ----
# calcPolygonAreaSphereByID <- function(spatial_polygon){
#   area <- lapply(seq(length(spatial_polygon)), function(x){
#     act_coords <- spatial_polygon@polygons[[x]]@Polygons[[1]]@coords
#     act_area <- earth.tri.reloaded(act_coords[1,1], act_coords[1,2], 
#                                    act_coords[2,1], act_coords[2,2],
#                                    act_coords[3,1], act_coords[3,2])
#     data.frame(ID = x,
#                AREA = act_area)
#   })
#   do.call("rbind", area)
# }
# 
# 
# # Calculate surface of triangular polygons on the earth sphere -----------------
# calcPolygonAreaSphere <- function(spatial_polygon){
#   area_by_id <- calcPolygonAreaSphereByID(spatial_polygon)
#   sum(area_by_id$AREA)
# }
