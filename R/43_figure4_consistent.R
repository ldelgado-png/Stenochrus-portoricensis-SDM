# Figure 4 | Current standardized MOP distance and strict non-analog conditions.
# MOP_basic: 1 = strict NAC; NA = analog where MOP_distance is valid.
source(file.path(Sys.getenv("STENOCHRU_SDM_PROJECT",
                       unset = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"),
                     "R", "40_fig_helpers.R"))

mop_dir <- file.path(project_root, "data", "WorldClim_CMIP6_future", "MOP")
dfile <- needed_file(file.path(mop_dir, "MOP_distance_CURRENT_Colombia.tif"))
bfile <- needed_file(file.path(mop_dir, "MOP_basic_CURRENT_Colombia.tif"))
distance <- terra::rast(dfile); basic <- terra::rast(bfile)
if (!isTRUE(terra::compareGeom(distance, basic, stopOnError = FALSE)))
  stop("MOP_basic and MOP_distance grid mismatch")
vals <- unique(terra::values(basic, mat = FALSE)); vals <- vals[!is.na(vals)]
if (any(!is.finite(vals)) || any(vals != 1)) stop("Expected MOP_basic 1/NA coding")
nvalid <- as.numeric(terra::global(terra::ifel(is.na(distance), 0, 1), "sum", na.rm = TRUE)[1, 1])
nnac <- as.numeric(terra::global(terra::ifel(!is.na(distance) & !is.na(basic), 1, 0), "sum", na.rm = TRUE)[1, 1])
# Definitive common-mask benchmark (the historical 651/54,165 run is separate).
if (nvalid != 54539 || nnac != 684)
  stop("Current MOP does not match the definitive 54,539 valid / 684 NAC cells: ",
       nvalid, "/", nnac)
cell_area <- terra::cellSize(distance, unit = "km")
total_area <- as.numeric(terra::global(
  terra::ifel(!is.na(distance), cell_area, NA),
  "sum", na.rm = TRUE
)[1, 1])
nac_area <- as.numeric(terra::global(
  terra::ifel(!is.na(distance) & !is.na(basic), cell_area, NA),
  "sum", na.rm = TRUE
)[1, 1])
if (!is.finite(total_area) || abs(total_area - 1160946) > 10)
  stop("Current MOP valid area differs from 1,160,946 km2: ", total_area)
cat(sprintf("Figure 4: valid = %d; NAC = %d (%.3f%% of cells).\n",
            nvalid, nnac, 100 * nnac / nvalid))
cat(sprintf("Area-weighted: NAC = %.2f km2 (%.3f%% of %.1f km2).\n",
            nac_area, 100 * nac_area / total_area, total_area))

layers <- read_colombia_shapes(); limits <- map_limits(layers$country)
pts <- colombia_occurrences_sf()
strict <- terra::ifel(is.na(distance), NA, terra::ifel(is.na(basic), NA, 1))
dist_visual <- project_display_raster(distance, method = "bilinear", country_sf = layers$country)
strict_visual <- project_display_raster(strict, method = "near", country_sf = layers$country)
df <- raster_df(dist_visual); overlay <- raster_df(strict_visual)

p <- ggplot2::ggplot() +
  ggplot2::geom_raster(data = df, ggplot2::aes(x, y, fill = value)) +
  ggplot2::scale_fill_viridis_c(name = "MOP dissimilarity", limits = c(0, 1),
                                 option = "D", na.value = "white") +
  ggplot2::geom_raster(data = overlay, ggplot2::aes(x, y), fill = "#C93636", alpha = .72) +
  ggplot2::geom_sf(data = layers$departments, fill = NA, colour = "#929292", linewidth = .24) +
  ggplot2::geom_sf(data = layers$country, fill = NA, colour = "#252525", linewidth = .60) +
  ggplot2::geom_sf(data = pts, shape = 21, size = 2, fill = "white", colour = "black", stroke = .45) +
  metric_annotations(limits, 250, TRUE) + plot_frame(limits) +
  ggplot2::labs(title = "Current environmental dissimilarity in mainland Colombia",
                subtitle = "Red overlay: strictly non-analog climatic conditions") +
  publication_theme()

save_publication(p, file.path(out_root, "Figure_4", "Figure_4_consistent"), 8.5, 10)
utils::write.csv(data.frame(valid_cells = nvalid, strict_nac_cells = nnac,
                            strict_nac_cell_percent = 100 * nnac / nvalid,
                            evaluated_area_km2 = total_area,
                            strict_nac_area_km2 = nac_area,
                            strict_nac_area_percent = 100 * nac_area / total_area),
                 file.path(out_root, "Figure_4", "Figure_4_diagnostics.csv"), row.names = FALSE)
