# Test for polygon area
envelope_mp <- dividePolygon(envelope)

j <- envelope@polygons[[1]]@Polygons[[1]]@coords
k <- j[c(2:10, 1, 2),]

l <- SpatialPolygons(list(Polygons(list(Polygon(k)), as.character("TEST"))))
proj4string(l) <- proj4string(envelope)

m <- dividePolygon(l)

plot(cntr_mw)
plot(l, add = TRUE)
plot(envelope_mp, border = "red", add = TRUE)
plot(m, border = "green", add = TRUE)

envelope_mp
m

testarea <- function(testpoly){
  area <- lapply(seq(length(testpoly)), function(x){
    act_coords <- testpoly@polygons[[x]]@Polygons[[1]]@coords
    act_poly <- SpatialPolygons(list(Polygons(list(Polygon(act_coords)), as.character(x))))
    proj4string(act_poly) <- proj4string(testpoly)
    gArea(act_poly)
  })
}

m_area <- testarea(m)
sum(unlist(m_area))

envelope_mp_area <- testarea(envelope_mp)
sum(unlist(envelope_mp_area))


# Test for envelope
testcoords <- data.frame(LON = c(-179.0, 179.0, 178.0),
                         LAT = c(5, -5, 0))

testcoords <- data.frame(LON = c(180.0, 178.0, 177.0),
                         LAT = c(5, -5, 0))

testpoints <- SpatialPoints(testcoords)
proj4string(testpoints) <- prj
gConvexHull(testpoints)@polygons[[1]]@Polygons[[1]]@coords

testpoints_mw <- spTransform(testpoints, CRS("+proj=moll +lon_0=0"))
test_envelope <- gConvexHull(testpoints_mw, byid = FALSE)
plot(cntr)
plot(testpoints_mw, col = "green", add = TRUE)
plot(test_envelope, border = "red", add = TRUE)
gArea(test_envelope)/(2*pi*6371000**2)


testpoints_df <- SpatialPointsDataFrame(testpoints, data = data.frame(c(1,2,3)))
writeOGR(testpoints_df, paste0(datapath_world, "dreipunkt.shp"), "dreipunkt", driver="ESRI Shapefile")
