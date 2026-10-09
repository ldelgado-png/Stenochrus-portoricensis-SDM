# R/30_future_weighted_projections.R
# Future Colombian climate-sensitivity experiment, identical GCM/SSP/period
# grid and mask across uniform and both weighted Maxnet full-data models.
# Uses an explicit 16-row file manifest; never guesses future filenames.
# Requires data already downloaded by the author's WorldClim CMIP6 workflow.
library(terra)
library(ENMeval)
library(maxnet)
repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
out <- file.path(repo,"results","sampling_bias")
dir30 <- file.path(out,"future_weighted_projections")
dir.create(dir30,recursive=TRUE,showWarnings=FALSE)
vars <- c("bio1","bio2","bio4","bio12","bio14","bio15")
scenarios <- c("uniform_original","Arachnida_floor10","Arachnida_floor20")
models_file <- c(file.path(repo,"data","ENMeval_Stenochrus_M200_SWD.rds"),
  file.path(out,"ENMeval_Arachnida_floor10_40models.rds"),
  file.path(out,"ENMeval_Arachnida_floor20_40models.rds"))
stopifnot(all(file.exists(models_file)))
objs <- setNames(lapply(models_file,readRDS),scenarios)
fit <- lapply(objs,function(z) ENMeval::eval.models(z)[["fc.LQHP_rm.1"]])
stopifnot(all(vapply(fit,inherits,logical(1),"maxnet")))
cal <- as.data.frame(ENMeval::eval.occs(objs[["uniform_original"]]))
stopifnot(nrow(cal)==171L,all(vars%in%names(cal)))
threshold <- vapply(fit,function(m)unname(quantile(as.numeric(
  predict(m,cal[,vars,drop=FALSE],type="cloglog",clamp=TRUE)),0.10)),numeric(1))
# Get canonical current Colombian climate grid from the exact original output.
ras <- list.files(file.path(repo,"data"),pattern="^WorldClim_2\\.5m_Colombia_6vars\\.tif$",
  recursive=TRUE,full.names=TRUE)
stopifnot(length(ras)==1L)
current <- rast(ras);stopifnot(nlyr(current)==6L);names(current)<-vars
ids <- expand.grid(gcm=c("HadGEM3-GC31-LL","MIROC6","CNRM-CM6-1","MRI-ESM2-0"),
    ssp=c("SSP126","SSP585"),period=c("2041-2060","2061-2080"),
    stringsAsFactors=FALSE)
manifestfile <- file.path(dir30,"future_input_manifest.csv")
if(!file.exists(manifestfile)){
  ids$file <- ""; write.csv(ids,manifestfile,row.names=FALSE)
  cat("Manifest created:",manifestfile,"\n",
      "Fill the 'file' column with the 16 EXISTING source raster paths, then rerun.\n")
  # Give the user an inventory to identify actual input names.
  candidates <- list.files(file.path(repo,"data"),pattern="\\.tif$",
    recursive=TRUE,full.names=TRUE)
  writeLines(candidates,file.path(dir30,"available_tif_inventory.txt"))
  quit(save="no",status=0)
}
manifest <- read.csv(manifestfile,stringsAsFactors=FALSE)
stopifnot(nrow(manifest)==16L,all(c("gcm","ssp","period","file")%in%names(manifest)),
  !anyDuplicated(manifest[,c("gcm","ssp","period")]))
missing <- !nzchar(manifest$file)|!file.exists(manifest$file)
if(any(missing))stop("Manifest paths not yet resolved: ",paste(which(missing),collapse=", "),
  ". Check future_input_manifest.csv and available_tif_inventory.txt.")
# Canonical current suitability products from diagnostic 23.
cur_preds <- setNames(lapply(scenarios,function(s){
  f<-file.path(out,"Colombia_comparison_3backgrounds",
               paste0("Colombia_",s,"_cloglog.tif"))
  stopifnot(file.exists(f));z<-rast(f)
  stopifnot(compareGeom(z,current[[1]],stopOnError=FALSE));z
}),scenarios)
area <- cellSize(current[[1]],unit="km")
sumarea <- function(cond) as.numeric(global(ifel(cond,area,NA),"sum",na.rm=TRUE)[1,1])
# Source rasters may have 6 or 19 BIO layers. Enforce correct selections.
load_future <- function(filename){
  f<-rast(filename)
  if(nlyr(f)==19L) f <- f[[c(1,2,4,12,14,15)]]
  if(nlyr(f)!=6L)stop("Expected six or 19 bioclimatic layers: ",filename)
  names(f)<-vars
  # Bilinear resampling is for continuous climate, never for count/effort rasters.
  if(!same.crs(f,current))stop("CRS mismatch: ",filename)
  f <- crop(f,ext(current),snap="near")
  if(!compareGeom(f,current,stopOnError=FALSE))
    f <- resample(f,current,method="bilinear")
  f<-mask(f,!is.na(current[[1]]),maskvalues=0)
  stopifnot(compareGeom(f,current,stopOnError=FALSE))
  f
}
rows<-list(); k<-1L
for(i in seq_len(nrow(manifest))){
  z<-manifest[i,]; future<-load_future(z$file)
  label<-paste(z$gcm,z$ssp,z$period,sep="_")
  for(s in scenarios){
    dest<-file.path(dir30,paste0("pred_",s,"_",label,".tif"))
    if(file.exists(dest))p<-rast(dest) else {
      p<-terra::predict(future,fit[[s]],type="cloglog",clamp=TRUE,na.rm=TRUE,
                        filename=dest,overwrite=FALSE)
    }
    present<-cur_preds[[s]]>=threshold[s]
    future_bin<-p>=threshold[s]
    rows[[k]]<-data.frame(background=s,gcm=z$gcm,ssp=z$ssp,period=z$period,
       threshold_own_10tp=threshold[s],current_area_km2=sumarea(present),
       future_area_km2=sumarea(future_bin),persistence_km2=sumarea(present&future_bin),
       loss_km2=sumarea(present&!future_bin),gain_km2=sumarea(!present&future_bin))
    k<-k+1L
  }
  cat("Predictions complete:",label,"\n")
}
individual<-do.call(rbind,rows)
individual$pct_change <-100*(individual$future_area_km2/individual$current_area_km2-1)
write.csv(individual,file.path(dir30,"future_individual_gcm_results.csv"),row.names=FALSE)
# Four-GCM consensus per treatment, SSP and period. Same threshold per
# treatment for current and future and SAME valid grid across all GCMs.
consensus_rows<-list();k<-1L
for(s in scenarios)for(ssp in unique(manifest$ssp))for(period in unique(manifest$period)){
  r <- manifest[manifest$ssp==ssp&manifest$period==period,]
  stopifnot(nrow(r)==4L)
  rasters<-lapply(seq_len(4),function(i)rast(file.path(dir30,paste0(
    "pred_",s,"_",r$gcm[i],"_",ssp,"_",period,".tif"))))
  stopifnot(all(vapply(rasters,function(z) compareGeom(z,current[[1]],
                                       stopOnError=FALSE),logical(1))))
  # Compute consensus only where all GCMs are defined.
  binary<-do.call(c,lapply(rasters,function(z)ifel(is.na(z),NA,ifel(z>=threshold[s],1,0))))
  n_gcm<-app(binary,"sum",na.rm=FALSE)
  dest<-file.path(dir30,paste0("GCM_agreement_",s,"_",ssp,"_",period,".tif"))
  if(!file.exists(dest))writeRaster(n_gcm,dest,overwrite=FALSE)
  present<-cur_preds[[s]]>=threshold[s]
  fut<-n_gcm>=2
  consensus_rows[[k]]<-data.frame(background=s,ssp=ssp,period=period,
     n_gcmmodels=4L,consensus_rule="2of4",current_area_km2=sumarea(present),
     future_area_km2=sumarea(fut),persistence_km2=sumarea(present&fut),
     loss_km2=sumarea(present&!fut),gain_km2=sumarea(!present&fut))
  k<-k+1L
}
con<-do.call(rbind,consensus_rows)
con$pct_change<-100*(con$future_area_km2/con$current_area_km2-1)
write.csv(con,file.path(dir30,"future_consensus_2of4_results.csv"),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(dir30,"sessionInfo.txt"))
cat("\n=== FUTURE CONSENSUS BY BACKGROUND ===\n");print(con,row.names=FALSE)
