# 03_environmental_predictors.R ------------------------------------------
# Load the final six-predictor M200 raster and reconstruct the effective
# 171 presence SWD table.

source("R/00_setup.R")

raster_file <- file.path(paths$data_rasters, "WorldClim_2.5m_M200_6vars.tif")
if (!file.exists(raster_file)) {
  stop("Place WorldClim_2.5m_M200_6vars.tif in data/rasters/ or edit raster_file.")
}

bio_final_M200 <- terra::rast(raster_file)
names(bio_final_M200) <- vars_final

occ_file <- file.path(paths$data_processed, "Stenochrus_occ_final_172.csv")
stopifnot(file.exists(occ_file))
occ_env_unique <- read.csv(occ_file, stringsAsFactors = FALSE)

# WorldClim original raster cell is NA for this record; exclude from ENMeval.
occ_env_171 <- occ_env_unique[as.character(occ_env_unique$key) != "4923620954", ]

occs_enm_171 <- occ_env_171[, c("decimalLongitude", "decimalLatitude")]
names(occs_enm_171) <- c("longitude", "latitude")

occ_env_values <- terra::extract(
  bio_final_M200,
  as.matrix(occs_enm_171),
  ID = FALSE
)

occs_swd <- cbind(occs_enm_171, occ_env_values)
stopifnot(nrow(occs_swd) == 171L)
stopifnot(all(stats::complete.cases(occs_swd)))

message("Effective model presences: ", nrow(occs_swd))
print(names(bio_final_M200))
