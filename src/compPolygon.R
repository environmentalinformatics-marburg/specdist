# require(fossil)
# # Divide spatial polygon into triangles ----------------------------------------
# # Depricated
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
# # Depricated
# calcAreaPolygonByID <- function(spatial_polygon){
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
# # Depricated
# calcAreaPolygon <- function(spatial_polygon){
#   area_by_id <- calcAreaPolygonByID(spatial_polygon)
#   sum(area_by_id$AREA)
# }
