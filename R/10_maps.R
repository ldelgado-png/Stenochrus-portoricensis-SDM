# 10_maps.R ---------------------------------------------------------------
# Draft cartographic outputs. Final publication scale bars should be made
# after projecting to an appropriate metric CRS for Colombia.

source("R/00_setup.R")

pred_file <- file.path(paths$data_rasters, "Stenochrus_prediction_Colombia_LQHP_RM1.tif")
mop_file <- file.path(paths$data_rasters, "MOP_distance_Colombia.tif")
occ_file <- file.path(paths$data_processed, "Stenochrus_portoricensis_America_QC_unique.csv")

stopifnot(file.exists(pred_file), file.exists(occ_file))
pred_colombia <- terra::rast(pred_file)
occ_unique <- read.csv(occ_file, stringsAsFactors = FALSE)
occ_colombia <- occ_unique[occ_unique$countryCode == "CO", c("decimalLongitude", "decimalLatitude")]
occ_colombia <- unique(occ_colombia[complete.cases(occ_colombia), ])

# Administrative boundaries.
gadm_dir <- file.path(project_root, "data", "gadm")
col_pais <- geodata::gadm(country = "COL", level = 0, path = gadm_dir)
col_dept <- geodata::gadm(country = "COL", level = 1, path = gadm_dir)

# High-resolution suitability PNG.
png(
  file.path(paths$figures, "colombia", "Stenochrus_Colombia_suitability_400dpi.png"),
  width = 8.5, height = 11, units = "in", res = 400, bg = "white"
)
par(mar = c(4.5, 4.5, 3.5, 7), bty = "n")
terra::plot(
  pred_colombia,
  col = hcl.colors(150, "viridis"),
  axes = TRUE, box = FALSE, main = "",
  plg = list(title = "Suitability\n(cloglog)", cex = 0.9)
)
terra::plot(col_dept, add = TRUE, col = NA, border = "gray65", lwd = 0.6)
terra::plot(col_pais, add = TRUE, col = NA, border = "black", lwd = 1.1)
graphics::points(
  occ_colombia$decimalLongitude, occ_colombia$decimalLatitude,
  pch = 21, bg = "white", col = "black", cex = 1.5, lwd = 0.9
)
graphics::title(
  main = expression(paste(italic("Stenochrus portoricensis"), " - climatic suitability in Colombia")),
  cex.main = 1.1
)
dev.off()

# MOP map, if available.
if (file.exists(mop_file)) {
  mop_dist <- terra::rast(mop_file)
  p95 <- quantile(terra::values(mop_dist), 0.95, na.rm = TRUE)
  mop_p95 <- terra::ifel(mop_dist >= p95, 1, NA)

  png(
    file.path(paths$figures, "mop", "MOP_Colombia_400dpi.png"),
    width = 8.5, height = 11, units = "in", res = 400, bg = "white"
  )
  par(mar = c(4.5, 4.5, 3.5, 7), bty = "n")
  terra::plot(
    mop_dist,
    col = hcl.colors(120, "viridis"),
    axes = TRUE, box = FALSE, main = "", range = c(0, 1),
    plg = list(title = "MOP\ndissimilarity", cex = 0.9)
  )
  terra::plot(mop_p95, add = TRUE, col = adjustcolor("yellow", alpha.f = 0.65), legend = FALSE)
  terra::plot(col_dept, add = TRUE, col = NA, border = "gray65", lwd = 0.6)
  terra::plot(col_pais, add = TRUE, col = NA, border = "black", lwd = 1.1)
  graphics::points(
    occ_colombia$decimalLongitude, occ_colombia$decimalLatitude,
    pch = 21, bg = "white", col = "black", cex = 1.5, lwd = 0.9
  )
  graphics::title(
    main = expression(paste(italic("Stenochrus portoricensis"), " - environmental dissimilarity in Colombia")),
    cex.main = 1.1
  )
  dev.off()
}
