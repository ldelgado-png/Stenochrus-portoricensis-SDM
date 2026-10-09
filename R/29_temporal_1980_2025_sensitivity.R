# R/29_temporal_1980_2025_sensitivity.R
# 136-presence temporal sensitivity within the original American calibration.
# Uses the SAME three existing training background locations across treatments.
# New experiment, results CANNOT be pooled by absolute AICc with the 171-set.
library(terra)
library(ENMeval)
library(maxnet)
repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
out <- file.path(repo,"results","sampling_bias")
dir29 <- file.path(out,"temporal_1980_2025")
dir.create(dir29,recursive=TRUE,showWarnings=FALSE)
vars <- c("bio1","bio2","bio4","bio12","bio14","bio15")
coord <- c("longitude","latitude")
cols <- c(coord,vars)
e <- readRDS(file.path(repo,"data","ENMeval_Stenochrus_M200_SWD.rds"))
env <- rast(file.path(repo,"data","WorldClim_2.5m_M200_6vars.tif"))
occ <- as.data.frame(ENMeval::eval.occs(e))[,cols,drop=FALSE]
src <- read.csv(file.path(repo,"data","Stenochrus_occ_final_172.csv"),
                stringsAsFactors=FALSE)
if("key"%in%names(src))src <- src[as.character(src$key)!="4923620954",,drop=FALSE]
loncol <- intersect(c("decimalLongitude","longitude"),names(src))[1]
latcol <- intersect(c("decimalLatitude","latitude"),names(src))[1]
stopifnot(!is.na(loncol),!is.na(latcol),nrow(src)==171L)
# Use the same original-year priority rule as diagnostic 18.
y <- if("year"%in%names(src))suppressWarnings(as.integer(src$year)) else
  rep(NA_integer_,nrow(src))
if("eventDate"%in%names(src)){
  extra <- suppressWarnings(as.integer(substr(src$eventDate,1L,4L)))
  y[is.na(y)] <- extra[is.na(y)]
}
scell <- cellFromXY(env[[1]],as.matrix(src[,c(loncol,latcol)]))
ocell <- cellFromXY(env[[1]],as.matrix(occ[,coord]))
stopifnot(!anyNA(scell),!anyNA(ocell),
          !anyDuplicated(scell),!anyDuplicated(ocell),
          setequal(scell,ocell))
idx <- match(ocell,scell)
y <- y[idx]
keep <- !is.na(y)&y>=1980L&y<=2025L
stopifnot(sum(keep)==136L)
occ136 <- occ[keep,,drop=FALSE]
write.csv(data.frame(occ136,year=y[keep]),
          file.path(dir29,"occurrences_1980_2025_136.csv"),row.names=FALSE)
scenarios <- c("uniform_original","Arachnida_floor10","Arachnida_floor20")
fits <- list()
for(s in scenarios){
  bg <- if(s=="uniform_original")as.data.frame(ENMeval::eval.bg(e)) else
    read.csv(file.path(out,paste0("background_",s,".csv")))
  bg <- bg[,cols,drop=FALSE]
  stopifnot(nrow(bg)==9987L)
  dest <- file.path(dir29,paste0("ENMeval_136_",s,".rds"))
  if(file.exists(dest)){fit <- readRDS(dest)} else {
    fit <- ENMeval::ENMevaluate(occs=occ136,bg=bg,algorithm="maxnet",
      partitions="block",partition.settings=list(orientation="lat_lon"),
      tune.args=list(fc=c("L","LQ","H","LQH","LQHP"),rm=seq(.5,4,.5)),
      other.settings=list(validation.bg="partition",abs.auc.diff=TRUE),
      raster.preds=FALSE,parallel=FALSE,quiet=FALSE)
    saveRDS(fit,dest)
  }
  r <- as.data.frame(ENMeval::eval.results(fit))
  stopifnot(nrow(r)==40L)
  r$background <- s
  write.csv(r,file.path(dir29,paste0("ENMeval_136_",s,".csv")),row.names=FALSE)
  fits[[s]] <- r
}
all <- do.call(rbind,fits)
sel <- do.call(rbind,lapply(split(all,all$background),function(x){
  stopifnot(any(is.finite(x$AICc)))
  x[which.min(x$AICc),,drop=FALSE]
}))
write.csv(sel,file.path(dir29,"selected_136_within_treatment.csv"),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(dir29,"sessionInfo.txt"))
print(sel[,c("background","fc","rm","AICc","auc.val.avg","or.10p.avg")],row.names=FALSE)
cat("Temporal models complete. Do NOT compare AICc to the original 171-presence models.\n")
