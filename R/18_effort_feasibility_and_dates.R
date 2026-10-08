# R/18_effort_feasibility_and_dates.R ---------------------------------------
# Schizomida / Arachnida sampling-bias feasibility after successful OSF download
# Read-only for source datasets and model objects: DOES NOT fit SDMs, modify
# the original ENMevaluation RDS, or replace any climate surfaces.
# Writes diagnostics to results/sampling_bias/ only.
repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
outdir <- file.path(repo, "results", "sampling_bias")
stopifnot(dir.exists(outdir))
stopifnot(requireNamespace("terra", quietly=TRUE))
stopifnot(requireNamespace("ENMeval", quietly=TRUE))

enmpath <- file.path(repo,"data","ENMeval_Stenochrus_M200_SWD.rds")
envpath <- file.path(repo,"data","WorldClim_2.5m_M200_6vars.tif")
stopifnot(file.exists(enmpath),file.exists(envpath))
e <- readRDS(enmpath)
env <- terra::rast(envpath)
stopifnot(inherits(e,"ENMevaluation"),terra::nlyr(env)==6L)
occ <- as.data.frame(ENMeval::eval.occs(e))
bg <- as.data.frame(ENMeval::eval.bg(e))
stopifnot(nrow(occ)==171L,nrow(bg)==9987L)
stopifnot(all(c("longitude","latitude") %in% names(occ)),
          all(c("longitude","latitude") %in% names(bg)))

fullvals <- terra::values(env, mat=TRUE)
eligible_all <- which(rowSums(!is.na(fullvals))==6L)
rm(fullvals)
presence_cells <- unique(terra::cellFromXY(
  env[[1]],as.matrix(occ[,c("longitude","latitude")])))
presence_cells <- presence_cells[!is.na(presence_cells)]
eligible <- setdiff(eligible_all,presence_cells)
stopifnot(length(eligible)>=nrow(bg))

labels <- c("Schizomida_nobs","Arachnida_nobs","Schizomida_nsp")
cat("\n=== Diagnostic: compatible M200 cells and positive-effort scarcity ===\n")
tab <- do.call(rbind,lapply(labels,function(label){
  path <- file.path(outdir,paste0(label,"_total_5km_WC2.5m.tif"))
  stopifnot(file.exists(path))
  r <- terra::rast(path)
  stopifnot(terra::compareGeom(r,env[[1]],stopOnError=FALSE))
  values <- terra::values(r,mat=FALSE)
  stopifnot(!anyNA(values[eligible]),all(values[eligible]>=0))
  occ_values <- terra::extract(
    r, as.matrix(occ[,c("longitude","latitude")]))[,1]
  bg_values <- terra::extract(
    r, as.matrix(bg[,c("longitude","latitude")]))[,1]
  npos <- sum(values[eligible]>0)
  data.frame(
    layer=label, eligible_cells=length(eligible),
    positive_eligible=npos,
    positive_eligible_pct=100*npos/length(eligible),
    original_background_n=nrow(bg),
    max_positive_fraction_in_original_size_bg=npos/nrow(bg),
    n_occ_positive=sum(occ_values>0,na.rm=TRUE),
    n_bg_original_positive=sum(bg_values>0,na.rm=TRUE),
    potential_focal_self_inclusion=grepl("Schizomida",label),
    stringsAsFactors=FALSE
  )
}))
print(tab,row.names=FALSE,digits=6)
write.csv(tab,file.path(outdir,"effort_background_feasibility.csv"),
          row.names=FALSE)
cat("\nInterpretation: when drawing 9987 unique background cells without replacement,\n",
    "no more than positive_eligible of them can have positive effort.\n",
    "In particular, sparse Schizomida is an EXPLORATORY stress-test, not\n",
    "an automatically defensible replacement for uniform background.\n",sep="")

cat("\n=== Background sampling diagnostic only: NO models will be fitted ===\n")
simulate_bg <- function(label, floorfraction, seed) {
  r <- terra::rast(file.path(
    outdir,paste0(label,"_total_5km_WC2.5m.tif")))
  vals <- terra::values(r,mat=FALSE)
  eff <- vals[eligible]
  w <- log1p(eff)
  if(!any(w>0))stop("No positive effort for ",label)
  eps <- floorfraction*stats::median(w[w>0])
  set.seed(seed)
  chosen <- sample.int(
    length(eligible),size=nrow(bg),replace=FALSE,prob=w+eps)
  data.frame(layer=label,floor_fraction=floorfraction,seed=seed,
             selected_positive=sum(eff[chosen]>0),
             selected_zero=sum(eff[chosen]==0),
             selected_positive_pct=100*mean(eff[chosen]>0),
             eligible_positive=sum(eff>0))
}
scenarios <- rbind(
  do.call(rbind,lapply(123:127,function(z)
    simulate_bg("Schizomida_nobs",0.01,z))),
  do.call(rbind,lapply(123:127,function(z)
    simulate_bg("Schizomida_nobs",0.05,z))),
  do.call(rbind,lapply(123:127,function(z)
    simulate_bg("Arachnida_nobs",0.01,z)))
)
print(scenarios,row.names=FALSE,digits=5)
write.csv(scenarios,file.path(outdir,"background_draw_feasibility_seeds.csv"),
          row.names=FALSE)

cat("\n=== Temporal feasibility: ORIGINAL focal occurrence input ===\n")
occpath <- file.path(repo,"data","Stenochrus_occ_final_172.csv")
if(file.exists(occpath)) {
  x <- read.csv(occpath,stringsAsFactors=FALSE)
  cat("Source input rows: ",nrow(x),"\n",sep="")
  cat("Columns available: ",paste(names(x),collapse=", "),"\n",sep="")
  # The original environmental-exclusion key in the project pipeline is
  # 4923620954; remove it before interpreting date coverage.
  if("key" %in% names(x)) {
    x <- x[as.character(x$key)!="4923620954",,drop=FALSE]
  }
  cat("Date audit row count after documented exclusion: ",nrow(x),"\n",sep="")
  if(nrow(x)!=171L)warning("Rows do not equal 171; inspect deduplication provenance.")
  yearcol <- if("year" %in% names(x)) "year" else NA_character_
  datecol <- if("eventDate" %in% names(x)) "eventDate" else NA_character_
  yrs <- rep(NA_integer_,nrow(x))
  if(!is.na(yearcol))yrs <- suppressWarnings(as.integer(x[[yearcol]]))
  if(!is.na(datecol)) {
    guessed <- suppressWarnings(as.integer(substr(
      as.character(x[[datecol]]),1L,4L)))
    yrs[is.na(yrs)] <- guessed[is.na(yrs)]
  }
  valid <- !is.na(yrs)&yrs>=1800L&yrs<=2026L
  if(!any(valid)){
    cat("No usable year or eventDate found in the 171-cell source.\n",
        "Temporal-subset decision remains PENDING; inspect raw source.\n",sep="")
  }else{
    yrs <- yrs[valid]
    cat("Dated source rows: ",length(yrs),"/",nrow(x),"\n",sep="")
    print(summary(yrs))
    print(table(cut(yrs,c(1799,1979,1989,1999,2009,2019,2025,2026),
                    include.lowest=TRUE),useNA="ifany"))
  }
}else{
 cat("Date-source file not available; inspect the GBIF raw and QC CSVs.\n")
}
cat("\nSaved diagnostics in ",outdir,"\n",sep="")
