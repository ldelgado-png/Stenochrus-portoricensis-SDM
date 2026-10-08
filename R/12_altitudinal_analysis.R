# Post-hoc elevational analysis for Stenochrus portoricensis
# Source: WorldClim 2.1 elevation at 2.5 arc-min; area-weighted summaries
# Required: local GBIF/QC data, current prediction, future consensus and change rasters
# Example: Sys.setenv(STENOCHRU_SDM_PROJECT = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis")
# Run from the project root or define STENOCHRU_SDM_PROJECT.
#
# Elevation is NOT a predictor in the fitted Maxnet model.
# This script re-computes summary CSVs from local input files; large rasters
# and occurrence-level downloads are not included in the public repository.

suppressPackageStartupMessages({
  library(terra)
  library(geodata)
})

project_dir <- Sys.getenv("STENOCHRU_SDM_PROJECT", unset = getwd())
data_dir <- file.path(project_dir, "data")
consensus_dir <- file.path(data_dir, "WorldClim_CMIP6_future", "Consensus")
output_dir <- file.path(project_dir, "results", "altitude")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

occ_cal_file <- file.path(data_dir, "Stenochrus_occ_final_172.csv")
occ_qc_file <- file.path(data_dir, "Stenochrus_portoricensis_America_QC_unique.csv")
present_file <- file.path(data_dir, "Stenochrus_prediction_Colombia_GADM_LQHP_RM1_current.tif")

ids <- c("SSP126_2041", "SSP585_2041", "SSP126_2061", "SSP585_2061")
suffixes <- c("SSP126_2041-2060", "SSP585_2041-2060",
              "SSP126_2061-2080", "SSP585_2061-2080")
future_files <- setNames(
  file.path(consensus_dir, paste0("Consensus_2of4_", suffixes, ".tif")), ids
)
change_files <- setNames(
  file.path(consensus_dir, paste0("Change_consensus_2of4_", suffixes, ".tif")), ids
)

required <- c(occ_cal_file, occ_qc_file, present_file,
              unname(future_files), unname(change_files))
missing_files <- required[!file.exists(required)]
if (length(missing_files)) {
  stop("Missing local inputs. Set STENOCHRU_SDM_PROJECT to the original modelling folder:\n",
       paste(missing_files, collapse = "\n"))
}

dem_dir <- file.path(data_dir, "elevation")
gadm_dir <- file.path(data_dir, "gadm")
dir.create(dem_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(gadm_dir, recursive = TRUE, showWarnings = FALSE)

elev_global <- geodata::worldclim_global(var = "elev", res = 2.5, path = dem_dir)
colombia <- geodata::gadm("COL", level = 0, path = gadm_dir)
elev_col <- terra::mask(terra::crop(elev_global, colombia), colombia)

current <- terra::rast(present_file)
same_grid <- function(r, elev = elev_col) {
  isTRUE(terra::compareGeom(r, elev, stopOnError = FALSE))
}
if (!same_grid(current)) stop("The canonical current raster and DEM do not share geometry.")
if (!all(vapply(future_files, function(f) same_grid(terra::rast(f)), logical(1)))) {
  stop("One or more future consensus rasters do not align with the DEM.")
}
if (!all(vapply(change_files, function(f) same_grid(terra::rast(f)), logical(1)))) {
  stop("One or more change rasters do not align with the DEM.")
}

threshold_10tp <- 0.2123639
present_binary <- terra::ifel(current >= threshold_10tp, 1, 0)

# Occurrence elevations: 171 valid calibration cells and 10 Colombian localities
occ_cal <- read.csv(occ_cal_file, stringsAsFactors = FALSE)
occ_model <- subset(occ_cal, !is.na(climate_qc) & climate_qc == "direct extraction")
occ_unique <- read.csv(occ_qc_file, stringsAsFactors = FALSE)
occ_col <- subset(occ_unique, countryCode == "CO")
if (nrow(occ_model) != 171L || nrow(occ_col) != 10L) {
  stop("Occurrence counts differ from the analysed dataset (171 + 10); inspect QC first.")
}

extract_elevation <- function(d, elev) {
  pts <- terra::vect(d, geom = c("decimalLongitude", "decimalLatitude"),
                     crs = "EPSG:4326")
  terra::extract(elev, pts)[, 2]
}
occ_model$elevation_dem_m <- extract_elevation(occ_model, elev_global)
occ_col$elevation_dem_m <- extract_elevation(occ_col, elev_col)
if (anyNA(occ_model$elevation_dem_m) || anyNA(occ_col$elevation_dem_m)) {
  stop("NA elevations found in occurrence records.")
}

occ_summary <- function(d, label) {
  z <- d$elevation_dem_m
  data.frame(
    dataset = label, n = length(z), min_m = min(z),
    q1_m = unname(quantile(z, 0.25)), median_m = median(z),
    mean_m = mean(z), q3_m = unname(quantile(z, 0.75)),
    max_m = max(z), n_below_500m = sum(z < 500),
    n_below_1000m = sum(z < 1000)
  )
}
occ_results <- rbind(
  occ_summary(occ_model, "Americas_calibration_direct"),
  occ_summary(occ_col, "Colombia_QC_unique")
)

weighted_quantile <- function(x, w, probs = c(0.25, 0.5, 0.75)) {
  ok <- is.finite(x) & is.finite(w) & w > 0
  x <- x[ok]; w <- w[ok]
  if (!length(x)) stop("No valid elevation/area values.")
  ord <- order(x)
  x <- x[ord]; w <- w[ord]
  cw <- cumsum(w) / sum(w)
  vapply(probs, function(p) x[which(cw >= p)[1]], numeric(1))
}

breaks_alt <- c(-Inf, 500, 1000, 1500, 2000, 2500, 3000, Inf)
labels_alt <- c("<500", "500-1000", "1000-1500", "1500-2000",
                "2000-2500", "2500-3000", ">3000")
cell_area <- terra::cellSize(current, unit = "km")

extract_cell_data <- function(r, name) {
  if (!same_grid(r)) stop("Raster geometry mismatch: ", name)
  d <- as.data.frame(c(elev_col, r, cell_area), na.rm = TRUE)
  names(d) <- c("elevation_m", "class", "area_km2")
  d
}

summarise_group <- function(d, scenario, change = NULL) {
  if (!nrow(d)) stop("No cells for ", scenario, " ", change)
  q <- weighted_quantile(d$elevation_m, d$area_km2)
  row <- data.frame(
    scenario = scenario, n_cells = nrow(d),
    area_km2 = sum(d$area_km2), min_m = min(d$elevation_m),
    q1_m = q[1], median_m = q[2],
    mean_m = weighted.mean(d$elevation_m, d$area_km2),
    q3_m = q[3], max_m = max(d$elevation_m)
  )
  if (!is.null(change)) {
    row <- row[, c("scenario", "n_cells", "area_km2", "min_m", "q1_m",
                   "median_m", "mean_m", "q3_m", "max_m")]
    row <- data.frame(scenario = scenario, change = change, row[, -1],
                      check.names = FALSE)
  }
  row
}

summarise_suitable <- function(r, name) {
  d <- extract_cell_data(r, name)
  if (!all(d$class %in% 0:1)) stop("Suitability raster must contain only 0/1: ", name)
  d <- d[d$class == 1, , drop = FALSE]
  s <- summarise_group(d, name)
  cut_z <- cut(d$elevation_m, breaks_alt, labels = labels_alt, right = FALSE)
  by_band <- vapply(labels_alt, function(b) {
    sum(d$area_km2[as.character(cut_z) == b])
  }, numeric(1))
  bands <- data.frame(
    scenario = name, alt_band = labels_alt,
    area_km2 = as.numeric(by_band),
    percent = 100 * as.numeric(by_band) / sum(by_band)
  )
  list(summary = s, bands = bands)
}

all_suitable <- list(Current = summarise_suitable(present_binary, "Current"))
all_changes <- list()
for (nm in ids) {
  future <- terra::rast(future_files[[nm]])
  change <- terra::rast(change_files[[nm]])
  all_suitable[[nm]] <- summarise_suitable(future, nm)

  dc <- extract_cell_data(change, nm)
  if (!all(dc$class %in% 0:3)) stop("Change raster has invalid class codes: ", nm)

  # Validate coding against the two binary suitability rasters:
  # 0 = unchanged unsuitable, 1 = gain, 2 = loss, 3 = persistence.
  masks <- as.data.frame(c(present_binary, future, change), na.rm = TRUE)
  expected <- with(masks, ifelse(masks[, 1] == 0,
                                 ifelse(masks[, 2] == 1, 1, 0),
                                 ifelse(masks[, 2] == 1, 3, 2)))
  if (!all(masks[, 3] == expected)) {
    stop("Change-class codes inconsistent with present/future maps: ", nm)
  }
  classes <- c("Gain", "Loss", "Persistence")
  parts <- lapply(seq_along(classes), function(i) {
    tmp <- dc[dc$class == i, , drop = FALSE]
    summarise_group(tmp, nm, classes[i])
  })
  all_changes[[nm]] <- do.call(rbind, parts)
}

suitability_summary <- do.call(rbind, lapply(all_suitable, `[[`, "summary"))
suitability_bands <- do.call(rbind, lapply(all_suitable, `[[`, "bands"))
change_summary <- do.call(rbind, all_changes)
rownames(suitability_summary) <- NULL
rownames(suitability_bands) <- NULL
rownames(change_summary) <- NULL

area_present <- suitability_summary$area_km2[1]
if (abs(area_present - 379223.5) > 1) {
  stop("Present suitable area does not match the manuscript baseline: ", area_present)
}
expected_futures <- c(144294.6, 138796.7, 143206.2, 143995.9)
if (any(abs(suitability_summary$area_km2[-1] - expected_futures) > 1)) {
  stop("One or more future suitable areas differ from the analysed consensus.")
}

write.csv(occ_results, file.path(output_dir, "Altitude_occurrence_summary.csv"), row.names = FALSE)
write.csv(suitability_summary, file.path(output_dir, "Altitude_suitability_summary.csv"), row.names = FALSE)
write.csv(suitability_bands, file.path(output_dir, "Altitude_suitability_bands.csv"), row.names = FALSE)
write.csv(change_summary, file.path(output_dir, "Altitude_change_gain_loss_persistence.csv"), row.names = FALSE)
print(occ_results)
print(suitability_summary)
print(change_summary)
cat("\nArea-weighted elevational results saved in: ", output_dir, "\n", sep = "")
