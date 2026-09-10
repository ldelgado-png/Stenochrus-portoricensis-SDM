# 09_mop_extrapolation.R --------------------------------------------------
# Strict full-M200 range check + multivariate MOP using sampled background.

source("R/00_setup.R")
source("R/04_background_sampling.R")

m200_file <- file.path(paths$data_rasters, "WorldClim_2.5m_M200_6vars.tif")
col_file <- file.path(paths$data_rasters, "WorldClim_2.5m_Colombia_6vars.tif")

# If Colombia six-variable raster has not been saved separately, reconstruct it
# using the same code as R/08_projection_colombia.R before running this script.
if (!file.exists(col_file)) {
  stop("Save the six-layer Colombia environmental stack as data/rasters/WorldClim_2.5m_Colombia_6vars.tif first.")
}

bio_final_M200 <- terra::rast(m200_file)
bio_colombia <- terra::rast(col_file)
names(bio_final_M200) <- vars_final
names(bio_colombia) <- vars_final

# Strict univariate extrapolation against the FULL M200 raster.
rango_M200 <- terra::global(bio_final_M200, c("min", "max"), na.rm = TRUE)
novel_list <- lapply(vars_final, function(v) {
  r <- bio_colombia[[v]]
  (r < rango_M200[v, "min"]) | (r > rango_M200[v, "max"])
})
novel_stack <- terra::rast(novel_list)
names(novel_stack) <- vars_final
novel_count <- terra::app(novel_stack, sum, na.rm = FALSE)

# MOP reference based on the 9,987 direct-analysis background environments.
M_ref <- as.matrix(background_final[, vars_final])

mop_colombia <- mop::mop(
  m = M_ref,
  g = bio_colombia,
  type = "basic",
  calculate_distance = TRUE,
  where_distance = "all",
  distance = "euclidean",
  scale = TRUE,
  center = TRUE,
  fix_NA = TRUE,
  percentage = 1,
  comp_each = 250,
  rescale_distance = TRUE,
  parallel = FALSE,
  progress_bar = TRUE
)

saveRDS(mop_colombia, file.path(paths$results, "extrapolation", "MOP_Colombia_vs_M200_bg9987.rds"))
terra::writeRaster(
  mop_colombia$mop_distances,
  file.path(paths$data_rasters, "MOP_distance_Colombia.tif"),
  overwrite = TRUE
)

q <- quantile(
  terra::values(mop_colombia$mop_distances),
  probs = c(0, 0.50, 0.90, 0.95, 0.99, 1),
  na.rm = TRUE
)
print(q)
