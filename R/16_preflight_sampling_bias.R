# 16_preflight_sampling_bias.R ---------------------------------------------
# El-Gabbas (2026): inventory local prerequisites WITHOUT changing any files.
# Run from any RStudio working directory. This script does NOT download rasters
# or refit models; paste the console output into the ChatGPT conversation.

repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
cat("\n========= EL-GABBAS PREFLIGHT =========\n")
cat("Project root: ", repo, "\n", sep="")
cat("Directory exists: ", dir.exists(repo), "\n", sep="")
if (!dir.exists(repo)) stop("Project folder not found; adjust 'repo'.")

required_pkgs <- c("terra", "ENMeval", "maxnet", "ecokit", "osfr", "tidyr")
installed <- vapply(required_pkgs, requireNamespace, quietly=TRUE,
                    FUN.VALUE=logical(1))
cat("\n1. REQUIRED R PACKAGES\n")
print(data.frame(package=required_pkgs, installed=installed),
      row.names=FALSE)
if (!installed[["ecokit"]]) cat(
  "\nInstall ecokit using: install.packages('remotes'); ",
  "remotes::install_github('elgabbas/ecokit', dependencies=NA, upgrade='never')\n",
  sep=""
)

source_rds <- file.path(repo, "data", "ENMeval_Stenochrus_M200_SWD.rds")
cat("\n2. ORIGINAL ENMeval RDS\n")
cat("Path: ", source_rds, "\n", sep="")
cat("Exists: ", file.exists(source_rds), "\n", sep="")
if (file.exists(source_rds) && installed[["ENMeval"]]) {
  enm <- readRDS(source_rds)
  cat("Object class: ", paste(class(enm),collapse=", "), "\n", sep="")
  if(inherits(enm,"ENMevaluation")) {
    occs <- as.data.frame(ENMeval::eval.occs(enm))
    bg <- as.data.frame(ENMeval::eval.bg(enm))
    cat("Calibration occurrences: ", nrow(occs), "\n", sep="")
    cat("Original backgrounds: ", nrow(bg), "\n", sep="")
    cat("Occurrence columns: ", paste(names(occs),collapse=", "), "\n",sep="")
    cat("Background columns: ",paste(names(bg),collapse=", "), "\n",sep="")
    cat("Original ENMeval settings:\n")
    print(ENMeval::eval.other.settings(enm)[c("validation.bg","abs.auc.diff")])
  }
}

cat("\n3. LOCAL TIF FILES CONTAINING M200 / WORLDCLIM / COLOMBIA\n")
all_tif <- list.files(file.path(repo,"data"), pattern="\\.tif$",
                      recursive=TRUE, full.names=TRUE,
                      ignore.case=TRUE)
candidates <- all_tif[grepl(
  "M200|worldclim|Colombia|6vars|bioclim", basename(all_tif),
  ignore.case=TRUE)]
cat("TIF files found under data/: ", length(all_tif), "\n",sep="")
if(length(candidates)>30L) candidates<-candidates[1:30]
print(candidates)
m200_exact <- all_tif[grepl(
  "^WorldClim_2\\.5m_M200_6vars\\.tif$", basename(all_tif),
  ignore.case=TRUE)]
col_exact <- all_tif[grepl(
  "^WorldClim_2\\.5m_Colombia_6vars\\.tif$", basename(all_tif),
  ignore.case=TRUE)]
cat("Exact M200 six-variable raster count: ",length(m200_exact),"\n",sep="")
cat("Exact Colombian six-variable raster count: ",length(col_exact),"\n",sep="")
if(installed[["terra"]] && length(m200_exact)==1L) {
  e<-terra::rast(m200_exact[[1]])
  cat("M200 raster: layers=",terra::nlyr(e),
      "; resolution=",paste(terra::res(e),collapse=","),
      "; cells=",terra::ncell(e),
      "; CRS geographic=",terra::is.lonlat(e),"\n",sep="")
}
if (length(m200_exact)==0L) {
  cat("IMPORTANT: R/16 and R/17 require the original six-variable ",
      "M200 WorldClim raster. We must identify its existing local filename ",
      "before downloading or fitting alternatives.\n",sep="")
}

cat("\n4. EXISTING EL-GABBAS OUTPUTS\n")
biasdir <- file.path(repo,"results","sampling_bias")
if (dir.exists(biasdir)) {
  print(list.files(biasdir,recursive=TRUE,full.names=FALSE))
} else cat("No outputs yet in results/sampling_bias/.\n")

cat("\n5. AVAILABLE FOCAL OCCURRENCE FILES FOR YEAR AUDIT\n")
occ_files <- list.files(file.path(repo,"data"),
  pattern="stenochrus.*\\.(csv|rds)$",recursive=TRUE,full.names=TRUE,
  ignore.case=TRUE)
print(head(occ_files,25))
cat("\n========= END PREFLIGHT =========\n")
