# Calculate individual surface of multiple triangular polygons on the earth ----
calcPolygonAreaSphereByID <- function(spatial_polygon){
  area <- lapply(seq(length(spatial_polygon)), function(x){
    act_coords <- spatial_polygon@polygons[[x]]@Polygons[[1]]@coords
    act_area <- earth.tri.reloaded(act_coords[1,1], act_coords[1,2], 
                                   act_coords[2,1], act_coords[2,2],
                                   act_coords[3,1], act_coords[3,2])
    data.frame(ID = x,
               AREA = act_area)
  })
  do.call("rbind", area)
}