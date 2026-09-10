# 08_projection_colombia.R -----------------------------------------------
# Transfer the selected LQHP/RM1 direct maxnet model to Colombia.

source("R/00_setup.R")

mod_file <- file.path(paths$results, "model_selection", "maxnet_LQHP_RM1.rds")
stopifnot(file.exists(mod_file))
mod_best <- readRDS(mod_file)

# Local WorldClim directory; edit if needed.
wc_dir <- file.path(project_root, "data", "worldclim", "wc2.1_2.5m_bio")
bio_ids <- c(1, 2, 4, 12, 14, 15)
wc_files <- file.path(wc_dir, paste0("wc2.1_2.5m_bio_", bio_ids, ".tif"))
stopifnot(all(file.exists(wc_files)))

bio_global_6 <- terra::rast(wc_files)
names(bio_global_6) <- vars_final

# GADM or Natural Earth may be used for the country mask.
gadm_dir <- file.path(project_root, "data", "gadm")
dir.create(gadm_dir, recursive = TRUE, showWarnings = FALSE)
colombia <- geodata::gadm(country = "COL", level = 0, path = gadm_dir)

bio_colombia <- terra::crop(bio_global_6, colombia)
bio_colombia <- terra::mask(bio_colombia, colombia)

# Save the six-layer transfer environment for extrapolation/MOP scripts.
terra::writeRaster(
  bio_colombia,
  file.path(paths$data_rasters, "WorldClim_2.5m_Colombia_6vars.tif"),
  overwrite = TRUE
)

pred_file <- file.path(paths$data_rasters, "Stenochrus_prediction_Colombia_LQHP_RM1.tif")
pred_colombia <- terra::predict(
  bio_colombia,
  mod_best,
  type = "cloglog",
  clamp = TRUE,
  na.rm = TRUE,
  filename = pred_file,
  overwrite = TRUE
)

print(terra::global(pred_colombia, c("min", "max", "mean"), na.rm = TRUE))
