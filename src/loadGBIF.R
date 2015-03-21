# Preprocessing of GBIF df ---------------------------------------------------
loadGBIF <- function(infile, datapath_processed, cntr){
  # Read GBIF dataset
  datapath_org <- paste0(dirname(infile), "/")
  f <- file(infile, "r")
  df <- data.frame()
  i <- 0
  while (length(l <- readLines(f, n = 100000, warn = FALSE)) > 0) {
    i <- i+1
    print(i)
    df_act <- do.call("rbind", lapply(l, function(x){
      act <- unlist(strsplit(x, "\t"))
      if(length(act) < 224){
        act[length(act):224] <- NA
      }
      act[grep(glob2rx(""), act)] <- NA
      return(act)
    }))
    write.table(df_act, paste0(datapath_org, 
                               sprintf("gbif_chunk_%02d", i), ".txt"))
    
    df <- rbind(df, df_act[, c(1, 63, 70, 71, 72, 78, 79, 93, 100, 157, 164, 
                               173, 182, 210, 213, 214, 215, 216, 217, 218, 
                               219, 220)])
  }
  close(f)
  colnames(df) <- unlist(c(df[1,]))
  save(df, file = paste0(datapath_processed, "df.Rdata"))
}
  
  
  # Clean GBIF dataset
  df <- df[-1,]
  df$Lat <- as.numeric(as.character(df$decimalLatitude))
  df$Lon <- as.numeric(as.character(df$decimalLongitude))
  df$decimalLatitude <- NULL
  df$decimalLongitude <- NULL
  df$fips104 <- countrycode(df$countryCode, "iso2c", "fips104")
  
  cntr_centroids <- calcPolygonCentroids(cntr)
  df$Centroid <- FALSE
  lat_id <- grep("Lat", colnames(df))
  lon_id <- grep("Lon", colnames(df))
  cent_id <- grep("Centroid", colnames(df))
  na_id <- which(is.na(df$Lat) & !is.na(df$countryCode)))
  replace_values <- lapply(na_id, function(x){
    c(cntr_centroids@coords[rownames(cntr_centroids@coords) == 
                              df$fips104[x],], TRUE)
  })
  
  df_clean <- df
  rm(df)
  save(df, file = paste0(datapath_processed, "df_clean.Rdata"))  
  return(df_clean)
}

