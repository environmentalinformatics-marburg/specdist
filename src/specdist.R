# General settings -------------------------------------------------------------
inpath <- "D:/active/juergen/"

modulepath <- paste0(inpath, "scripts/specdist/src/")
datapath <- paste0(inpath, "data/")
datapath_org <- paste0(datapath, "org/")
datapath_processed <- paste0(datapath, "processed/")
                   
src <- list.files(modulepath, full.name = TRUE)
src <- src[-grep("src/gbif.R", src)]
sapply(src, function(x){source(x)})


# Preprocessing of GBIF data ---------------------------------------------------
preprocess <- FALSE
if(preprocess){
  infile <- paste0(inpath, "gbif_PTERIDOPHYTA.txt")
  readGBIF(infile, datapath_processed)
} else {
  load(paste0(datapath_processed, "df.Rdata"))
}

# Processing can start below here ----------------------------------------------
str(df)
