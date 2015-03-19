# Calculate surface of triangular polygons on the earth sphere -----------------
calcPolygonAreaSphere <- function(spatial_polygon){
  area_by_id <- calcPolygonAreaSphereByID(spatial_polygon)
  sum(area_by_id$AREA)
}