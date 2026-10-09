# R/26_complete_diagnostic25_archive.R
# Reconstruct only absent fold models and final diagnostic-25 tables.
# Inputs: original ENMeval RDS, original/weighted BG CSV, pre-existing common BG.
# Never overwrites a previously saved fold model.
library(ENMeval)
library(maxnet)
repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
out <- file.path(repo, "results", "sampling_bias")
dir25 <- file.path(out, "common_background_spatial_validation")
vars <- c("bio1","bio2","bio4","bio12","bio14","bio15")
coords <- c("longitude","latitude")
cols <- c(coords,vars)
escenarios <- c("uniform_original","Arachnida_floor10","Arachnida_floor20")
source_rds <- file.path(repo,"data","ENMeval_Stenochrus_M200_SWD.rds")
stopifnot(file.exists(source_rds),dir.exists(dir25))
enm <- readRDS(source_rds)
occ <- as.data.frame(ENMeval::eval.occs(enm))[,cols,drop=FALSE]
groups <- as.integer(ENMeval::eval.occs.grp(enm))
stopifnot(nrow(occ)==171L, length(unique(groups))==4L)
commonfile <- file.path(dir25,"background_common_validation.csv")
stopifnot(file.exists(commonfile))
common <- read.csv(commonfile)[,cols,drop=FALSE]
stopifnot(nrow(common)==9987L,all(complete.cases(common)))
backgrounds <- setNames(lapply(escenarios,function(s) {
  if(s=="uniform_original") z <- as.data.frame(ENMeval::eval.bg(enm)) else
    z <- read.csv(file.path(out,paste0("background_",s,".csv")))
  stopifnot(nrow(z)==9987L,all(cols %in% names(z)))
  z[,cols,drop=FALSE]
}),escenarios)
blocks <- lapply(backgrounds, function(x) ENMeval::get.block(
  occ[,coords],x[,coords],orientation="lat_lon"))
eval_block <- ENMeval::get.block(occ[,coords],common[,coords],orientation="lat_lon")
stopifnot(identical(as.integer(eval_block$occs.grp),groups))
stopifnot(all(vapply(blocks,function(x)
  identical(as.integer(x$occs.grp),groups),logical(1))))
# Confirm the common evaluation background contains neither focal presences
# nor the training background cells for ANY treatment.
stopifnot(requireNamespace("terra",quietly=TRUE))
envfile <- file.path(repo,"data","WorldClim_2.5m_M200_6vars.tif")
stopifnot(file.exists(envfile))
ref <- terra::rast(envfile)[[1]]
cell_id <- function(z) terra::cellFromXY(ref,as.matrix(z[,coords]))
alltrain <- unique(c(cell_id(occ),unlist(lapply(backgrounds,cell_id))))
stopifnot(!anyNA(alltrain),!anyNA(cell_id(common)),
          !anyDuplicated(cell_id(common)),
          !any(cell_id(common) %in% alltrain))
auc_rank <- function(p,b) {
  n <- length(p); m <- length(b)
  stopifnot(n>0L,m>0L,all(is.finite(c(p,b))))
  (sum(rank(c(p,b),ties.method="average")[seq_len(n)])-n*(n+1)/2)/(n*m)
}
models_dir <- file.path(dir25,"models")
dir.create(models_dir,recursive=TRUE,showWarnings=FALSE)
result <- list()
k <- 1L
for(s in escenarios) for(fold in sort(unique(groups))) {
  bg <- backgrounds[[s]]
  gbg <- as.integer(blocks[[s]]$bg.grp)
  ge <- as.integer(eval_block$bg.grp)
  train_occ <- occ[groups!=fold,vars,drop=FALSE]
  val_occ <- occ[groups==fold,vars,drop=FALSE]
  train_bg <- bg[gbg!=fold,vars,drop=FALSE]
  val_bg <- common[ge==fold,vars,drop=FALSE]
  file <- file.path(models_dir,paste0(s,"_fold",fold,".rds"))
  if(file.exists(file)) {
    model <- readRDS(file)
    stopifnot(inherits(model,"maxnet"))
    cat("REUTILIZADO:",basename(file),"\n")
  } else {
    x <- rbind(train_occ,train_bg)
    p <- c(rep(1L,nrow(train_occ)),rep(0L,nrow(train_bg)))
    model <- maxnet::maxnet(p,x,maxnet::maxnet.formula(p,x,classes="lqhp"),regmult=1)
    saveRDS(model,file)
    cat("CREADO:",basename(file),"\n")
  }
  pp <- as.numeric(predict(model,val_occ,type="cloglog",clamp=TRUE))
  pb <- as.numeric(predict(model,val_bg,type="cloglog",clamp=TRUE))
  pt <- as.numeric(predict(model,train_occ,type="cloglog",clamp=TRUE))
  th <- unname(quantile(pt,0.1,names=FALSE))
  result[[k]] <- data.frame(escenario=s,fold=fold,
     n_pres_train=nrow(train_occ),n_pres_val=nrow(val_occ),
     n_bg_train=nrow(train_bg),n_bg_val=nrow(val_bg),
     auc_comun=auc_rank(pp,pb),omision_10tp=mean(pp<th))
  k <- k+1L
}
tabla25 <- do.call(rbind,result)
resumen25 <- aggregate(tabla25[,c("auc_comun","omision_10tp")],
  by=list(escenario=tabla25$escenario),FUN=mean)
ref_auc <- tabla25[tabla25$escenario=="uniform_original",c("fold","auc_comun")]
dif <- do.call(rbind,lapply(setdiff(escenarios,"uniform_original"),function(s){
  x <- merge(tabla25[tabla25$escenario==s,c("fold","auc_comun")],ref_auc,
    by="fold",suffixes=c("_alternativo","_uniforme"))
  data.frame(escenario=s,diferencia_auc_media=mean(x$auc_comun_alternativo-x$auc_comun_uniforme))
}))
# These values are cross-checked against the author's completed session.
expected <- c(uniform_original=0.7417520,Arachnida_floor10=0.7077332,
              Arachnida_floor20=0.7116284)
got <- setNames(resumen25$auc_comun,resumen25$escenario)
if(any(abs(got[names(expected)]-expected)>1e-5))
  stop("The validation AUC does not reproduce the reported original run. Investigate before export.")
write.csv(tabla25,file.path(dir25,"validation_by_fold.csv"),row.names=FALSE)
write.csv(resumen25,file.path(dir25,"validation_summary.csv"),row.names=FALSE)
write.csv(dif,file.path(dir25,"paired_auc_differences.csv"),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(dir25,"sessionInfo.txt"))
stopifnot(length(list.files(models_dir,pattern="\\.rds$"))>=12L)
cat("\n=== VALIDACION COMUN VERIFICADA ===\n");print(resumen25,row.names=FALSE)
cat("\n=== DIFERENCIAS PAREADAS ===\n");print(dif,row.names=FALSE)
cat("\nLISTO: 12 modelos RDS y 4 archivos de resumen/auditoria.\n")
