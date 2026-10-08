# 17_sampling_bias_models.R ------------------------------------------------
# El-Gabbas (2026): uniform versus bias-weighted background sensitivity.
# RUN ONLY AFTER R/16_sampling_effort_prepare.R completed successfully.
# No original outputs are overwritten. Model fitting can take several minutes.
# Original model and focal presences stay unchanged, with 40 candidate settings.
# Additional temporal or target-group comparisons require an explicit data check.

repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
out <- file.path(repo, "results", "sampling_bias")
stopifnot(dir.exists(out))
for (p in c("terra", "ENMeval", "maxnet")) stopifnot(requireNamespace(p, quietly=TRUE))
set.seed(123L)
vars <- c("bio1", "bio2", "bio4", "bio12", "bio14", "bio15")
envfile <- list.files(
  file.path(repo, "data"),
  pattern = "^WorldClim_2\\.5m_M200_6vars\\.tif$",
  recursive = TRUE, full.names = TRUE
)
stopifnot(length(envfile) == 1L)
env <- terra::rast(envfile)
stopifnot(terra::nlyr(env) == 6L)
names(env) <- vars

enm <- readRDS(file.path(repo, "data", "ENMeval_Stenochrus_M200_SWD.rds"))
occs <- as.data.frame(ENMeval::eval.occs(enm))
bg_uniform <- as.data.frame(ENMeval::eval.bg(enm))
names(occs)[1:2] <- names(bg_uniform)[1:2] <- c("longitude","latitude")
stopifnot(nrow(occs)==171L, nrow(bg_uniform)==9987L)
stopifnot(all(vars %in% names(occs)), all(vars %in% names(bg_uniform)))
occs <- occs[, c("longitude","latitude",vars)]
bg_uniform <- bg_uniform[, c("longitude","latitude",vars)]
valid <- which(rowSums(!is.na(terra::values(env, mat=TRUE))) == 6L)
presence_cells <- unique(terra::cellFromXY(env[[1]],
                                          as.matrix(occs[, 1:2])))
eligible <- setdiff(valid, presence_cells)
stopifnot(length(eligible) >= nrow(bg_uniform))

read_effort <- function(label) {
  p <- file.path(out, paste0(label, "_total_5km_WC2.5m.tif"))
  stopifnot(file.exists(p))
  r <- terra::rast(p)
  stopifnot(terra::compareGeom(r,env[[1]],stopOnError=FALSE))
  x <- terra::values(r, mat=FALSE)[eligible]
  if(anyNA(x) || any(x < 0)) stop("Invalid effort values: ", label)
  if (!any(x > 0)) stop("No sampled effort in M200: ", label)
  x
}
make_swd <- function(cells) {
  xy <- as.data.frame(terra::xyFromCell(env, cells))
  names(xy) <- c("longitude","latitude")
  clim <- terra::extract(env, as.matrix(xy), ID=FALSE)
  z <- cbind(xy, as.data.frame(clim))
  stopifnot(all(stats::complete.cases(z)),
            !anyDuplicated(cells),
            nrow(z)==nrow(bg_uniform))
  z
}
draw_weighted <- function(effort, floor_fraction=0.01, seed=123L) {
  # Damped intensity reduces dominance of repeatedly sampled GBIF sites.
  w <- log1p(effort)
  epsilon <- floor_fraction * median(w[w>0])
  w <- w + epsilon
  set.seed(seed)
  chosen <- sample(eligible, size=nrow(bg_uniform),
                   replace=FALSE, prob=w)
  make_swd(chosen)
}

sch <- read_effort("Schizomida_nobs")
ara <- read_effort("Arachnida_nobs")
backgrounds <- list(
  uniform_original = bg_uniform,
  Schizomida_floor01 = draw_weighted(sch, 0.01, 123),
  Schizomida_floor05 = draw_weighted(sch, 0.05, 124),
  Arachnida_floor01 = draw_weighted(ara, 0.01, 125)
)
cov <- read.csv(file.path(out, "effort_coverage_diagnostics.csv"))
if (any(cov$layer == "Schizomida_nobs")) {
  sc <- cov[cov$layer=="Schizomida_nobs",]
  if (sc$share_M200_positive < .05) {
    warning("Schizomida positive-effort coverage <5% within M200: ",
            "treat weighted models as high-sensitivity, not confirmed correction.")
  }
}

# Strict target-group background (TGB) needs independent NON-FOCAL schizomid
# records with source dates and QC. Do NOT treat a Schizomida n_obs>0 footprint
# as an independent target-group occurrence dataset: that raster includes
# observations of the focal species itself.
tgbfile <- file.path(repo, "data", "sampling_bias",
                     "Schizomida_nonfocal_GBIF_QC.csv")
tgb_status <- "not available"
if(file.exists(tgbfile)) {
  tg <- read.csv(tgbfile)
  if(!all(c("decimalLongitude","decimalLatitude","scientificName") %in% names(tg))) {
    stop("TGB file needs decimalLongitude, decimalLatitude, scientificName")
  }
  tg <- tg[tolower(trimws(tg$scientificName)) != "stenochrus portoricensis",]
  tg_cells <- unique(terra::cellFromXY(
    env[[1]], as.matrix(tg[, c("decimalLongitude","decimalLatitude")])
  ))
  tg_cells <- intersect(tg_cells[!is.na(tg_cells)], eligible)
  write.csv(data.frame(cell=tg_cells),
            file.path(out,"TGB_schizomida_candidate_cells.csv"), row.names=FALSE)
  tgb_status <- paste(length(tg_cells), "non-focal target-group grid cells")
  # Only if there are >=9987 independent candidate cells can a same-size
  # sample be compared to the original 9987-point baseline without a
  # separate matched-size sensitivity experiment.
  if(length(tg_cells) >= nrow(bg_uniform)) {
    set.seed(126)
    backgrounds$TGB_nonfocal <- make_swd(sample(tg_cells,nrow(bg_uniform)))
  } else {
    warning("TGB has fewer distinct cells than baseline background. ",
            "Exploratory data only; matched-size redesign is required.")
  }
}
writeLines(tgb_status, file.path(out, "target_group_status.txt"))

for (n in names(backgrounds)) {
  write.csv(backgrounds[[n]],
            file.path(out, paste0("background_",n,".csv")),
            row.names=FALSE)
}
cat("\nBackground data prepared for scenarios:\n")
print(names(backgrounds))
cat("Target-group status: ", tgb_status, "\n")
cat("To run the 40 candidate configurations for each new background,\n",
    "set RUN_MODELS <- TRUE below. It is FALSE initially for safety.\n")

RUN_MODELS <- FALSE
if (!RUN_MODELS) {
  message("Preparation complete; no models were fitted. Set RUN_MODELS <- TRUE to fit.")
} else {

# Use identical occurrence coordinates, predictors, number of background
# cells, tuning grid, block partitions, and validation.bg setting. Background
# locations are the experimental treatment.
fc_set <- c("L","LQ","H","LQH","LQHP")
rm_set <- seq(0.5, 4, by=0.5)

# Baseline retained from ORIGINAL ENMeval object, not needlessly refitted.
baseline <- as.data.frame(ENMeval::eval.results(enm))
baseline <- baseline[order(baseline$AICc),]
baseline$background <- "uniform_original"
all_results <- list(baseline)

for(n in setdiff(names(backgrounds),"uniform_original")) {
  cat("\nFitting 40 Maxnet candidates, background:",n,"\n")
  set.seed(123L)
  fit <- ENMeval::ENMevaluate(
    occs=occs, bg=backgrounds[[n]], algorithm="maxnet",
    partitions="block",
    tune.args=list(fc=fc_set,rm=rm_set),
    other.settings=list(validation.bg="partition",
                        abs.auc.diff=TRUE),
    raster.preds=FALSE, parallel=FALSE, quiet=FALSE
  )
  stopifnot(identical(as.integer(ENMeval::eval.occs.grp(fit)),
                      as.integer(ENMeval::eval.occs.grp(enm))))
  r <- as.data.frame(ENMeval::eval.results(fit))
  r$background <- n
  all_results[[n]] <- r
  saveRDS(fit,file.path(out,paste0("ENMeval_",n,"_40models.rds")))
  write.csv(r,file.path(out,paste0("ENMeval_",n,"_40models.csv")),row.names=FALSE)
}

full <- do.call(rbind, all_results)
write.csv(full,file.path(out,"model_selection_all_backgrounds.csv"),
          row.names=FALSE)
selected <- do.call(rbind,lapply(split(full,full$background),function(x){
  x <- x[order(x$AICc),]
  x[1L,,drop=FALSE]
}))
write.csv(selected,file.path(out,"best_models_by_background.csv"),
          row.names=FALSE)
# Distinguish fixed-configuration LQHP/RM1 from independently retuned optima.
fixed_LQHP <- full[full$fc == "LQHP" & full$rm == 1,
                   ,drop=FALSE]
stopifnot(nrow(fixed_LQHP)==length(all_results))
write.csv(fixed_LQHP,
          file.path(out,"fixed_LQHP_RM1_by_background.csv"),
          row.names=FALSE)
print(selected[,c("background","fc","rm","AICc","auc.val.avg",
                  "auc.diff.avg","or.10p.avg","ncoef")],row.names=FALSE)
cat("\nAICc is used only WITHIN each background run, never to compare\n",
    "absolute AICc values across background treatments.\n")

# Optionally project all selected models to the SAME Colombian climate grid.
colfile <- list.files(file.path(repo,"data"),
  pattern="^WorldClim_2\\.5m_Colombia_6vars\\.tif$",
  recursive=TRUE,full.names=TRUE)
if(length(colfile)==1L) {
  co <- terra::rast(colfile)
  names(co) <- vars
  coldir <- file.path(out,"colombia_predictions")
  dir.create(coldir,recursive=TRUE,showWarnings=FALSE)
  predictions <- list()
  for(n in names(all_results)) {
    e <- if(n=="uniform_original") enm else readRDS(
      file.path(out,paste0("ENMeval_",n,"_40models.rds")))
    row <- selected[selected$background==n,,drop=FALSE]
    model <- ENMeval::eval.models(e)[[as.character(row$tune.args[[1]])]]
    if(is.null(model)) stop("Could not retrieve selected model for ",n)
    predictions[[n]] <- terra::predict(
      co, model, type="cloglog", clamp=TRUE, na.rm=TRUE,
      filename=file.path(coldir,paste0("Colombia_",n,".tif")),
      overwrite=TRUE)
  }
  ref <- predictions[["uniform_original"]]
  area <- terra::cellSize(ref,unit="km")
  # Training-presence 10TP MUST be computed from all 171 calibration
  # occurrences by predicting with each fitted model on training covariates.
  # Extracting from the Colombian raster would discard most occurrences and
  # mistakenly calculate 10TP on only the Colombian subset.
  predict_training_10tp <- function(model) {
    training_env <- as.data.frame(occs[, vars, drop=FALSE])
    training_cloglog <- stats::predict(
      model, newdata=training_env, type="cloglog", clamp=TRUE
    )
    stopifnot(length(training_cloglog)==nrow(occs),
              all(is.finite(training_cloglog)))
    as.numeric(stats::quantile(training_cloglog,
                              probs=0.10, na.rm=FALSE))
  }
  thresholds <- vapply(names(all_results),function(n) {
    e <- if(n=="uniform_original") enm else readRDS(
      file.path(out,paste0("ENMeval_",n,"_40models.rds")))
    row <- selected[selected$background==n,,drop=FALSE]
    model <- ENMeval::eval.models(e)[[as.character(row$tune.args[[1]])]]
    predict_training_10tp(model)
  }, numeric(1))
  threshold_ref <- thresholds[["uniform_original"]]
  metrics <- lapply(names(predictions),function(n){
    pred <- predictions[[n]]
    thr <- thresholds[[n]]
    area_suitable <- terra::global(terra::ifel(
      pred>=thr,area,NA),fun="sum",na.rm=TRUE)[1,1]
    area_fixed_reference <- terra::global(terra::ifel(
      pred>=threshold_ref,area,NA),fun="sum",na.rm=TRUE)[1,1]
    corr <- stats::cor(terra::values(pred,mat=FALSE),
                       terra::values(ref,mat=FALSE),
                       use="complete.obs",method="spearman")
    data.frame(background=n,threshold_10tp=thr,
      area_km2_own10tp=area_suitable,
      area_km2_reference_threshold=area_fixed_reference,
      spearman_with_original=corr)
  })
  write.csv(do.call(rbind,metrics),
    file.path(out,"Colombia_projection_sensitivity.csv"),row.names=FALSE)
  print(do.call(rbind,metrics))
} else {
  message("Projection comparison not run: provide the original ",
    "WorldClim_2.5m_Colombia_6vars.tif.")
}

cat("\nBias sensitivity model-comparison workflow complete.\n")

} # end if (RUN_MODELS)
