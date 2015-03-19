# Calculate surface of polygons on a cartographic grid -------------------------
calcPolygonArea <- function(spatial_polygon){
  area_by_id <- calcPolygonAreaByID(spatial_polygon)
  area <- data.frame(SUM = sum(area_by_id$AREA),
                     SUM_AREA = sum(area_by_id$AREA[area_by_id$HOLE == FALSE]),
                     SUM_AREA_REL = 
                       sum(area_by_id$AREA_REL[area_by_id$HOLE == FALSE]),
                     SUM_HOLES = sum(area_by_id$AREA[area_by_id$HOLE == TRUE]),
                     SUM_HOLES_REL = 
                       sum(area_by_id$AREA_REL[area_by_id$HOLE == TRUE]))
}