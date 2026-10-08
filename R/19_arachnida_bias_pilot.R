# R/19_arachnida_bias_pilot.R ----------------------------------------------
# Controlled one-seed Arachnida-effort background experiment for
# Stenochrus portoricensis. Not a correction to the original SDM;
# sensitive to 1980-2025 raster coverage vs 171 calibration dates.
# Performs 40 Maxnet candidate fits; WILL TAKE TIME.
# Source R/18_effort_feasibility_and_dates.R first.
#
# Original ENMevaluation object and climate rasters are READ ONLY.
# Outputs are in results/sampling_bias/Arachnida_pilot_seed123 only.

repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
stopifnot(dir.exists(repo))
for (p in c("terra","ENMeval","maxnet")) {
  if (!requireNamespace(p,quietly=TRUE)) stop("Missing package: ",p)
}
env_file <- file.path(repo,"data","WorldClim_2.5m_M200_6vars.tif")
enm_file <- file.path(repo,"data","ENMeval_Stenochrus_M200_SWD.rds")
eff_file <- file.path(repo,"results","sampling_bias",
                      "Arachnida_nobs_total_5km_WC2.5m.tif")
stopifnot(file.exists(env_file),file.exists(enm_file),file.exists(eff_file))
out <- file.path(repo,"results","sampling_bias","Arachnida_pilot_seed123")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
bio <- c("bio1","bio2","bio4","bio12","bio14","bio15")
env <- terra::rast(env_file)
stopifnot(terra::nlyr(env)==length(bio))
names(env) <- bio
eff <- terra::rast(eff_file)
stopifnot(terra::compareGeom(env[[1]],eff,stopOnError=FALSE))
orig <- readRDS(enm_file)
stopifnot(inherits(orig,"ENMevaluation"))
occs <- as.data.frame(ENMeval::eval.occs(orig))
bg_orig <- as.data.frame(ENMeval::eval.bg(orig))
stopifnot(nrow(occs)==171L,nrow(bg_orig)==9987L)
stopifnot(all(c("longitude","latitude",bio) %in% names(occs)))
stopifnot(all(c("longitude","latitude",bio) %in% names(bg_orig)))
occs <- occs[,c("longitude","latitude",bio),drop=FALSE]
bg_orig <- bg_orig[,c("longitude","latitude",bio),drop=FALSE]
valid <- which(rowSums(!is.na(terra::values(env,mat=TRUE)))==6L)
used <- unique(terra::cellFromXY(
  env[[1]],as.matrix(occs[,c("longitude","latitude")])))
stopifnot(length(used)==171L,!anyNA(used))
eligible <- setdiff(valid,used)
stopifnot(length(eligible)==135940L)
v <- terra::values(eff,mat=FALSE)[eligible]
stopifnot(!anyNA(v),all(v>=0),sum(v>0)==21552L)
w <- log1p(v)
epsilon <- .01 * median(w[w>0])
seed <- 123L
set.seed(seed)
chosen_cells <- sample(eligible,nrow(bg_orig),replace=FALSE,prob=w+epsilon)
stopifnot(!anyDuplicated(chosen_cells),
          !any(chosen_cells %in% used))
xy <- as.data.frame(terra::xyFromCell(env,chosen_cells))
names(xy) <- c("longitude","latitude")
climate <- terra::extract(env,as.matrix(xy))
bg <- cbind(xy,as.data.frame(climate))
stopifnot(nrow(bg)==9987L,all(stats::complete.cases(bg)))
stopifnot(identical(names(bg),names(occs)))
cat("\nArachnida pilot: seed=",seed,
    "; 9,987 distinct background cells; positive effort=",
    sum(v[match(chosen_cells,eligible)]>0),"\n",sep="")
write.csv(bg,file.path(out,"background_Arachnida_seed123.csv"),
          row.names=FALSE)
write.csv(data.frame(seed=seed,source="El-Gabbas (2026)",
  group="Arachnida",metric="n_obs",period="1980-2025",
  positive_cells=sum(v[match(chosen_cells,eligible)]>0),
  background_cells=nrow(bg),floor_fraction=0.01,
  positive_floor=epsilon),file.path(out,"pilot_metadata.csv"),
  row.names=FALSE)

# Preserve original block partitioning. The occurrence groups are checked
# directly after the pilot and must match the full 171-occurrence original.
old_groups <- as.integer(ENMeval::eval.occs.grp(orig))
stopifnot(length(old_groups)==171L)
ps <- ENMeval::eval.partition.settings(orig)
cat("Original block partition settings:\n")
print(ps)

cat("\nFitting 40 Arachnida-weighted Maxnet configurations...\n")
set.seed(seed)
pilot <- ENMeval::ENMevaluate(
  occs=occs,bg=bg,algorithm="maxnet",partitions="block",
  partition.settings=ps,
  tune.args=list(fc=c("L","LQ","H","LQH","LQHP"),
                 rm=seq(0.5,4,by=0.5)),
  other.settings=list(validation.bg="partition",abs.auc.diff=TRUE),
  raster.preds=FALSE,parallel=FALSE,quiet=FALSE
)
# Save results even if subsequent provenance comparison fails.
saveRDS(pilot,file.path(out,"ENMeval_Arachnida_seed123.rds"))
new_groups <- as.integer(ENMeval::eval.occs.grp(pilot))
write.csv(data.frame(occurrence=seq_along(old_groups),
                     original_group=old_groups,new_group=new_groups),
          file.path(out,"occurrence_fold_comparison.csv"),row.names=FALSE)
if(!identical(old_groups,new_groups)){
  stop("CRITICAL: Original and pilot occurrence spatial folds differ; ",
       "do not compare evaluation metrics until resolved.")
}
cat("\nVERIFICACIÓN DE FOLDS SUPERADA\n")

results <- as.data.frame(ENMeval::eval.results(pilot))
stopifnot(nrow(results)==40L)
write.csv(results,file.path(out,"ENMeval_40_candidates_Arachnida.csv"),
          row.names=FALSE)
r_ok <- results[is.finite(results$AICc),,drop=FALSE]
stopifnot(nrow(r_ok)>0)
best <- r_ok[which.min(r_ok$AICc),,drop=FALSE]
write.csv(best,file.path(out,"best_model_Arachnida.csv"),row.names=FALSE)

baseline <- as.data.frame(ENMeval::eval.results(orig))
stopifnot(nrow(baseline)==40L)
base_ok <- baseline[is.finite(baseline$AICc),,drop=FALSE]
basebest <- base_ok[which.min(base_ok$AICc),,drop=FALSE]
best$background <- "Arachnida_nobs_seed123"
basebest$background <- "original_uniform"
cols <- c("background","fc","rm","tune.args","auc.val.avg",
          "auc.diff.avg","or.10p.avg","AICc","delta.AICc","ncoef")
for(k in setdiff(cols,names(best))) best[[k]] <- NA
for(k in setdiff(cols,names(basebest))) basebest[[k]] <- NA
comparison <- rbind(basebest[,cols,drop=FALSE],best[,cols,drop=FALSE])
write.csv(comparison,file.path(out,"original_vs_Arachnida_selected.csv"),
          row.names=FALSE)
print(comparison,row.names=FALSE,digits=8)
writeLines(capture.output(sessionInfo()),
           file.path(out,"sessionInfo.txt"))
cat("\nPILOT COMPLETED. Send the selected-model comparison CSV and\n",
    "occurrence_fold_comparison.csv. Do not interpret absolute AICc\n",
    "differences ACROSS the original and weighted backgrounds.\n",sep="")
