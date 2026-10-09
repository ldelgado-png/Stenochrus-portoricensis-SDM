# R/27_multiseed_background_validation.R
# Five-seed robustness: independent weighted training backgrounds, fixed LQHP/RM1,
# 4 spatial folds, one common held-out-background distribution per treatment.
# Does not replace/modify original fitted models or diagnostic 25.
library(terra)
library(ENMeval)
library(maxnet)
repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
out <- file.path(repo,"results","sampling_bias")
dir27 <- file.path(out,"replicate_backgrounds_fixed_LQHP_RM1")
mdir <- file.path(dir27,"models")
dir.create(mdir,recursive=TRUE,showWarnings=FALSE)
vars <- c("bio1","bio2","bio4","bio12","bio14","bio15")
coords <- c("longitude","latitude")
cols <- c(coords,vars)
env <- rast(file.path(repo,"data","WorldClim_2.5m_M200_6vars.tif"))
names(env) <- vars
ara <- rast(file.path(out,"Arachnida_nobs_total_5km_WC2.5m.tif"))
stopifnot(compareGeom(env[[1]],ara,stopOnError=FALSE))
original <- readRDS(file.path(repo,"data","ENMeval_Stenochrus_M200_SWD.rds"))
occ <- as.data.frame(ENMeval::eval.occs(original))[,cols,drop=FALSE]
original_bg <- as.data.frame(ENMeval::eval.bg(original))[,cols,drop=FALSE]
original_fold <- as.integer(ENMeval::eval.occs.grp(original))
common <- read.csv(file.path(out,"common_background_spatial_validation",
                                "background_common_validation.csv"))[,cols,drop=FALSE]
stopifnot(nrow(occ)==171L,nrow(original_bg)==9987L,nrow(common)==9987L)
allvalid <- which(rowSums(!is.na(terra::values(env,mat=TRUE)))==6L)
cell <- function(z) terra::cellFromXY(env[[1]],as.matrix(z[,coords]))
blocked <- unique(c(cell(occ),cell(common)))
stopifnot(!anyNA(blocked))
# For this NEW experiment, exclude evaluation cells from EVERY seeded training draw.
# Thus seed=125 is deliberately not identical to the earlier diagnostic-21 sample.
eligible <- setdiff(allvalid,blocked)
effort <- terra::values(ara,mat=FALSE)[eligible]
stopifnot(length(eligible)>=9987L,!anyNA(effort),all(effort>=0))
w <- log1p(effort);median_pos <- median(w[w>0])
eval_group <- as.integer(ENMeval::get.block(occ[,coords],common[,coords],
                                           orientation="lat_lon")$bg.grp)
base_group <- as.integer(ENMeval::get.block(occ[,coords],original_bg[,coords],
                                           orientation="lat_lon")$bg.grp)
auc <- function(p,b){n<-length(p);m<-length(b)
  (sum(rank(c(p,b),ties.method="average")[seq_len(n)])-n*(n+1)/2)/(n*m)}
result <- list();k<-1L
for(seed in 123:127) for(floor_fraction in c(0.10,0.20)) {
  set.seed(seed)
  ix <- sample.int(length(eligible),9987L,replace=FALSE,
                   prob=w+floor_fraction*median_pos)
  cells <- eligible[ix]
  xy <- xyFromCell(env[[1]],cells)
  clim <- as.data.frame(extract(env,xy))
  bg <- data.frame(longitude=xy[,1],latitude=xy[,2],clim[,vars,drop=FALSE])
  stopifnot(nrow(bg)==9987L,all(complete.cases(bg)),!anyDuplicated(cells),
            !any(cells%in%cell(common)))
  this_group <- as.integer(ENMeval::get.block(occ[,coords],bg[,coords],
                                              orientation="lat_lon")$bg.grp)
  # get.block returns bg.grp and occs.grp; verify both separately.
  part <- ENMeval::get.block(occ[,coords],bg[,coords],orientation="lat_lon")
  stopifnot(identical(as.integer(part$occs.grp),original_fold))
  # Save selected training coordinates for exact reproducibility.
  id <- sprintf("Arachnida_floor%02d_seed%d",as.integer(floor_fraction*100),seed)
  bg_file <- file.path(dir27,paste0("background_",id,".csv"))
  if(!file.exists(bg_file))write.csv(bg,bg_file,row.names=FALSE)
  for(fold in sort(unique(original_fold))) {
    trp <- occ[original_fold!=fold,vars,drop=FALSE]
    vap <- occ[original_fold==fold,vars,drop=FALSE]
    trb <- bg[this_group!=fold,vars,drop=FALSE]
    vab <- common[eval_group==fold,vars,drop=FALSE]
    file <- file.path(mdir,paste0(id,"_fold",fold,".rds"))
    if(file.exists(file)) fit <- readRDS(file) else {
      x <- rbind(trp,trb)
      p <- c(rep(1,nrow(trp)),rep(0,nrow(trb)))
      fit <- maxnet(p,x,maxnet.formula(p,x,classes="lqhp"),regmult=1)
      saveRDS(fit,file)
    }
    vp <- as.numeric(predict(fit,vap,type="cloglog",clamp=TRUE))
    vb <- as.numeric(predict(fit,vab,type="cloglog",clamp=TRUE))
    tp <- as.numeric(predict(fit,trp,type="cloglog",clamp=TRUE))
    result[[k]] <- data.frame(seed=seed,floor_fraction=floor_fraction,
      fold=fold,auc_common=auc(vp,vb),
      omission_10tp=mean(vp<quantile(tp,0.1,names=FALSE)),
      n_val_presence=nrow(vap),n_val_background=nrow(vab))
    k <- k+1L
  }
  cat("Verified",id,"\n")
}
by_fold <- do.call(rbind,result)
by_seed <- aggregate(by_fold[,c("auc_common","omission_10tp")],
          by=list(seed=by_fold$seed,floor_fraction=by_fold$floor_fraction),mean)
by_seed$delta_auc_vs_uniform_diag25 <- by_seed$auc_common - 0.7417520
summary <- aggregate(by_seed[,c("auc_common","omission_10tp")],
          by=list(floor_fraction=by_seed$floor_fraction),
          function(z)c(mean=mean(z),sd=sd(z),min=min(z),max=max(z)))
write.csv(by_fold,file.path(dir27,"validation_by_fold_and_seed.csv"),row.names=FALSE)
write.csv(by_seed,file.path(dir27,"validation_by_seed.csv"),row.names=FALSE)
write.csv(summary,file.path(dir27,"validation_seed_summary.csv"),row.names=FALSE)
cat("\n=== MULTISEED SUMMARIES ===\n");print(by_seed,row.names=FALSE)
cat("\nNOTA: validacion interna espacial; no constituye validacion externa.\n")
