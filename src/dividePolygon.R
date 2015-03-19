# Divide spatial polygon into triangles ----------------------------------------
dividePolygon <- function(spatial_polygon){
  coords <- spatial_polygon@polygons[[1]]@Polygons[[1]]@coords
  
  coords_new <- lapply(seq(nrow(coords)-3), function(x){
    Polygons(list(Polygon(coords[c(1, x+1, x+2, nrow(coords)), ])), 
             as.character(x))
  })
  spatial_polygon_mp <- SpatialPolygons(coords_new)
  proj4string(spatial_polygon_mp) <- proj4string(spatial_polygon)
  return(spatial_polygon_mp)
}