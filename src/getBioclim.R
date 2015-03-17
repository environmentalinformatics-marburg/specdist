getBioclim <- function(list){
  outpath <- paste0(dirname(list), "/")
  urls <- read.table(list)
  for(i in seq(nrow(urls))){
    print(as.character(urls[i,]))
    out <- paste0(outpath, basename(as.character(urls[i,])))
    download.file(as.character(urls[i,]), out)
  }
}
