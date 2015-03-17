# Script for analysing species distributions based on GBIF data dump

# General settings -------------------------------------------------------------
inpath <- "D:/active/juergen/"

modulepath <- paste0(inpath, "scripts/specdist/src/")
datapath <- paste0(inpath, "data/")
datapath_org <- paste0(datapath, "org/")
datapath_processed <- paste0(datapath, "processed/")
datapath_climate <- paste0(datapath, "climate/")

src <- list.files(modulepath, full.name = TRUE)
src <- src[-grep("src/specdist.R", src)]
sapply(src, function(x){source(x)})


# Preprocessing of GBIF data ---------------------------------------------------
preprocess <- FALSE
if(preprocess){
  infile <- paste0(datapath_org, "gbif_PTERIDOPHYTA.txt")
  readGBIF(infile, datapath_processed)
} else {
  load(paste0(datapath_processed, "df.Rdata"))
}

# Get Bioclim data -------------------------------------------------------------
if(preprocess){
  getBioclim(paste0(datapath_climate, "bioclim.txt"))
}
# Processing can start below here ----------------------------------------------
str(df)
