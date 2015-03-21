test <- read.table(paste0(datapath_org, "gbif_chunk_01.txt"))
cnames <- unlist(c(test[1,]))


test <- read.table(paste0(datapath_org, "gbif_chunk_03.txt"))
colnames(test) <- cnames

cid <- c(1, 63, 70, 71, 72, 78, 79, 93, 100, 157, 164, 
         173, 182, 210, 213, 214, 215, 216, 217, 218, 
         219, 220)

head(test[is.na(test$countryCode), cid])

which(is.na(test$countryCode))[1]
33292
which(test$countryCode == "NA")[1]

df <- test






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
  
  # Clean GBIF dataset
  df <- df[-1,]
  df$Lat <- as.numeric(as.character(df$decimalLatitude))
  df$Lon <- as.numeric(as.character(df$decimalLongitude))
  df$decimalLatitude <- NULL
  df$decimalLongitude <- NULL
  df$fips104 <- countrycode(df$countryCode, "iso2c", "fips104")
  
  #   df_test <- df[df$fips104 == "WA",]
  #   df_test <- rbind(df_test, df[df$fips104 == "NZ",])
  #   save(df_test, file = paste0(datapath_processed, "df_test.Rdata"))
  
  load(paste0(datapath_processed, "df_test.Rdata"))
  
  cntr_centroids <- calcPolygonCentroids(cntr)
  df$Centroid <- FALSE
  lat_id <- grep("Lat", colnames(df))
  lon_id <- grep("Lon", colnames(df))
  cent_id <- grep("Centroid", colnames(df))

  
  df_coords_avail <- df[!is.na(df$Lat),]
  save(df_coords_avail, file = paste0(datapath_processed, "df_coords_avail.Rdata"))
  
  df_coords_no_geo <- df[is.na(df$Lat) & is.na(df$countryCode), ]
  save(df_coords_no_geo, file = paste0(datapath_processed, "df_coords_no_geo.Rdata"))
  
  df_coords_no_lat <- df[is.na(df$Lat) & !is.na(df$fips104), ]
  save(df_coords_no_lat, file = paste0(datapath_processed, "df_coords_no_lat.Rdata"))
  
  str(df_coords_no_lat)
  
  
  replace_values <- lapply(seq(nrow(df_coords_no_lat)), function(x){
    print(x)
    if(any(rownames(cntr_centroids@coords) == df_coords_no_lat$fips104[x])){
      data.frame(Lat = cntr_centroids@coords[rownames(cntr_centroids@coords) == 
                                               df_coords_no_lat$fips104[x], 2],
                 Lon = cntr_centroids@coords[rownames(cntr_centroids@coords) == 
                                               df_coords_no_lat$fips104[x], 1],
                 Centroid = TRUE)
    }
  })
  replace_values <- do.call("rbind", replace_values)
  
  for(i in seq(nrow(df_coords_no_lat))){
    print(i)
    if(any(rownames(cntr_centroids@coords) == df_coords_no_lat$fips104[i])){
      df_coords_no_lat[i, c(lat_id, lon_id, cent_id)] <-   
        c(cntr_centroids@coords[rownames(cntr_centroids@coords) == df_coords_no_lat$fips104[i], 2],
          cntr_centroids@coords[rownames(cntr_centroids@coords) == df_coords_no_lat$fips104[i], 1],
          TRUE)
      
    }
  }
  
  