#' Calculates distance between points using distVincentyEllipsoid method
#' @param x A matrix with (at least) 3 columns: Lon,Lat,ID
#'  (names doesn't matter but order is important!)
#'  @return A Table object containing the distances between teh points in meter

calcPointDist <- function (x){
  dist <- table(x[,3],x[,3])
  for (i in 1:(nrow(x)-1)){
    for (k in i:nrow(x)){
      dist[i,k] <- geosphere::distVincentyEllipsoid(x[i,1:2], x[k,1:2])
    }
  }
  return (dist)
}