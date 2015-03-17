# Preprocessing of GBIF df ---------------------------------------------------
readGBIF <- function(infile, datapath_processed){
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
