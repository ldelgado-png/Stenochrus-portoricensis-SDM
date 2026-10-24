# Figure 2 | Present-day climatic suitability, mainland Colombia.
# Uses an explicitly named baseline raster, never the first matching tif.
source(file.path(Sys.getenv("STENOCHRU_SDM_PROJECT",
                       unset = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"),
                     "R", "40_fig_helpers.R"))

candidates <- file.path(project_root, c(
  "data/Stenochrus_prediction_Colombia_GADM_LQHP_RM1_current.tif",
  "data/rasters/Stenochrus_prediction_Colombia_LQHP_RM1.tif"
))
found <- candidates[file.exists(candidates)]
if (!length(found)) stop("Current suitability raster not found. Checked: ",
                         paste(candidates, collapse = " | "))
message("Figure 2 raster: ", found[1])
r <- terra::rast(found[1])
layers <- read_colombia_shapes()
limits <- map_limits(layers$country)
pts <- colombia_occurrences_sf()
projected <- project_display_raster(r, method = "bilinear", country_sf = layers$country)
if (terra::nlyr(projected) != 1L) stop("Raster not single-band")
v <- terra::global(projected, c("min", "max"), na.rm = TRUE)
if (v[1, 1] < -.001 || v[1, 2] > 1.001) stop("Cloglog prediction should have range 0-1")
df <- raster_df(projected)

p <- ggplot2::ggplot() +
  ggplot2::geom_raster(data = df, ggplot2::aes(x, y, fill = value)) +
  ggplot2::scale_fill_viridis_c(name = "Climatic suitability\n(cloglog)",
                                 limits = c(0, 1), option = "D", na.value = "white") +
  ggplot2::geom_sf(data = layers$departments, fill = NA, colour = "#929292", linewidth = .24) +
  ggplot2::geom_sf(data = layers$country, fill = NA, colour = "#252525", linewidth = .60) +
  ggplot2::geom_sf(data = pts, shape = 21, size = 2, fill = "white", colour = "black", stroke = .45) +
  metric_annotations(limits, 250, TRUE) + plot_frame(limits) +
  ggplot2::labs(title = "Current climatic suitability in mainland Colombia") + publication_theme()

save_publication(p, file.path(out_root, "Figure_2", "Figure_2_consistent"), 8.5, 10)
cat("Figure 2 completed; ten Colombian QC coordinates\n")
