#' Calculates distance between points using distVincentyEllipsoid method
#' @param x A matrix with (at least) 3 columns: Lon,Lat,ID
#'  (names doesn't matter but order is important!)
#'  @return A Table object containing the distances between teh points in meter

calcPointDist <- function (x){
  id_pos <- grep("cells", names(x))
  lon_pos <- grep("lon", names(x))
  lat_pos <- grep("lat", names(x))
  dist <- table(x[ ,id_pos], x[ ,id_pos])
  for (i in 1:(nrow(x)-1)){
    for (k in i:nrow(x)){
      dist[i,k] <- geosphere::distVincentyEllipsoid(
        x[i,lon_pos:lat_pos], x[k,lon_pos:lat_pos])
    }
  }
  return (dist)
}