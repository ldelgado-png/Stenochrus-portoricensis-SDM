# 16_sampling_effort_prepare_v2.R ------------------------------------------
cat("\n[El-Gabbas] Running corrected sampling effort script v2 (no ID=FALSE).\n")
# Compatibility fix: terra::extract(SpatRaster, matrix) does not accept ID=FALSE.
# El-Gabbas (2026): bias surfaces for Stenochrus portoricensis.
# NOT YET EXECUTED in the local RStudio project. Run script from any working dir.
# DOI: 10.1111/ddi.70205; datasets: https://osf.io/hz4sy
# Data source years 1980-2025; n_obs; native 5 km = 2.5 arc-min; EPSG:4326.

repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
stopifnot(dir.exists(repo))
for (p in c("ENMeval", "terra", "ecokit", "osfr", "tidyr")) {
  if (!requireNamespace(p, quietly = TRUE)) {
    stop("Missing package ", p, ". Install osfr and tidyr with install.packages(c('osfr','tidyr')); ",
         "install ecokit with remotes::install_github('elgabbas/ecokit', dependencies=NA, upgrade='never').")
  }
}
out <- file.path(repo, "results", "sampling_bias")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
rawdir <- file.path(repo, "data", "sampling_bias", "original")
dir.create(rawdir, recursive = TRUE, showWarnings = FALSE)

original <- file.path(repo, "data", "ENMeval_Stenochrus_M200_SWD.rds")
stopifnot(file.exists(original))
enm <- readRDS(original)
stopifnot(inherits(enm, "ENMevaluation"))
occ <- as.data.frame(ENMeval::eval.occs(enm))
bg0 <- as.data.frame(ENMeval::eval.bg(enm))
stopifnot(nrow(occ) == 171L, nrow(bg0) == 9987L)
stopifnot(is.numeric(occ[[1]]), is.numeric(occ[[2]]))

# Use the SAME WorldClim M200 raster as the original analysis, including its
# water/availability mask. Do not extend M beyond the original calibration area.
env_candidates <- list.files(
  file.path(repo, "data"),
  pattern = "^WorldClim_2\\.5m_M200_6vars\\.tif$",
  recursive = TRUE, full.names = TRUE, ignore.case = TRUE
)
if (length(env_candidates) != 1L) {
  stop("Expected exactly one WorldClim_2.5m_M200_6vars.tif in data/. ",
       "Found: ", length(env_candidates),
       ". Please locate the ORIGINAL six-variable M200 raster.")
}
env <- terra::rast(env_candidates[[1]])
stopifnot(terra::nlyr(env) == 6L)
names(env) <- c("bio1", "bio2", "bio4", "bio12", "bio14", "bio15")
stopifnot(terra::same.crs(env, "EPSG:4326"))
if (any(abs(terra::res(env) - 2.5 / 60) > 1e-7)) {
  stop("Original WorldClim grid is not 2.5 arc-min: inspect resolution.")
}

get_one <- function(group, descendant, label, metric = "n_obs") {
  cat("\n[El-Gabbas v2] Retrieving ", label, "...\n", sep="")
  downloaded <- ecokit::get_sampling_effort(
    group = group, descendants = descendant, metric = metric,
    years = "total", resolution = 5, out_dir = rawdir,
    conflicts = "skip", verbose = TRUE
  )
  cat("[El-Gabbas v2] Download returned for ", label, ".\n", sep="")
  if (nrow(downloaded) != 1L ||
      !file.exists(downloaded$local_path[[1]])) {
    stop("The expected sampling-effort GeoTIFF was not downloaded: ", label)
  }
  src <- terra::rast(downloaded$local_path[[1]])
  stopifnot(terra::same.crs(src, env))
  if (any(abs(terra::res(src) - 2.5 / 60) > 1e-7)) {
    stop("Unexpected effort-raster resolution: ", label)
  }
  aligned <- terra::resample(
    terra::crop(src, terra::ext(env), snap = "out"),
    env[[1]], method = "near"
  )
  # Nearest neighbour keeps observed counts and ZERO values unchanged.
  # If grids are co-registered, resampling is an identity mapping.
  if (anyNA(terra::values(aligned)[!is.na(terra::values(env[[1]]))])) {
    stop("NA inside valid M200 grid: inspect source extent and alignment: ", label)
  }
  aligned <- terra::mask(aligned, env[[1]])
  names(aligned) <- label
  target <- file.path(out, paste0(label, "_total_5km_WC2.5m.tif"))
  terra::writeRaster(aligned, target, overwrite = TRUE)
  v <- terra::values(aligned, mat = FALSE)
  valid <- !is.na(v)
  cat("[El-Gabbas v2] Extracting 171 occurrence-cell effort values for ",label,"...\n",sep="")
  occ_v <- terra::extract(aligned, as.matrix(occ[, 1:2]))[, 1]
  cat("[El-Gabbas v2] Raster and extraction completed for ",label,".\n",sep="")
  data.frame(
    layer = label, archive_file = downloaded$name[[1]],
    local_file = target, n_valid = sum(valid),
    n_positive = sum(v[valid] > 0),
    share_M200_positive = mean(v[valid] > 0),
    share_occurrences_positive = mean(occ_v > 0, na.rm = TRUE),
    n_occurrences_nonNA = sum(!is.na(occ_v)),
    max_count = max(v[valid], na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}

summary <- do.call(rbind, list(
  get_one("arachnida", "schizomida", "Schizomida_nobs"),
  get_one("arachnida", "all", "Arachnida_nobs"),
  get_one("arachnida", "schizomida", "Schizomida_nsp", metric = "n_sp")
))
write.csv(summary, file.path(out, "effort_coverage_diagnostics.csv"),
          row.names = FALSE)
print(summary, row.names = FALSE)
cat("\nEffort rasters aligned. Next run R/17_sampling_bias_models.R\n")
cat("NOTE: the archived Schizomida raster may include the focal species;\n",
    "a strict target-group occurrence background must exclude it.\n", sep = "")
