# Figure 5 | Four SSP-periods x two indicators: NAC and suitability.
# MOP_basic: 1 = strict NAC, NA = analog on valid MOP_distance cells.
# Consensus_2of4: 0/1 with NA outside the Colombia study mask.
# All analytical checks are performed on original rasters, prior to DISPLAY reprojection.
source(file.path(Sys.getenv("STENOCHRU_SDM_PROJECT",
                       unset = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"),
                     "R", "40_fig_helpers.R"))

mop_dir <- file.path(project_root, "data", "WorldClim_CMIP6_future", "MOP")
consensus_dir <- file.path(project_root, "data", "WorldClim_CMIP6_future", "Consensus")
out <- file.path(out_root, "Figure_5")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

GCM <- c("HadGEM3-GC31-LL", "MIROC6", "CNRM-CM6-1", "MRI-ESM2-0")
scenarios <- data.frame(
  ssp = c("SSP126", "SSP585", "SSP126", "SSP585"),
  period = c("2041-2060", "2041-2060", "2061-2080", "2061-2080"),
  label = c("SSP1-2.6 | 2041–2060", "SSP5-8.5 | 2041–2060",
            "SSP1-2.6 | 2061–2080", "SSP5-8.5 | 2061–2080"),
  expected_2of4_km2 = c(144294.6, 138796.7, 143206.2, 143995.9),
  stringsAsFactors = FALSE
)

ref <- terra::rast(needed_file(file.path(mop_dir, "MOP_distance_CURRENT_Colombia.tif")))
if (terra::nlyr(ref) != 1L) stop("Current MOP reference is not a single layer")
read_aligned <- function(f) {
  r <- terra::rast(needed_file(f))
  if (terra::nlyr(r) != 1L ||
      !isTRUE(terra::compareGeom(r, ref, stopOnError = FALSE))) {
    stop("Grid geometry differs from canonical current MOP raster: ", f)
  }
  r
}
sum_raster <- function(r) as.numeric(terra::global(r, "sum", na.rm = TRUE)[1, 1])
area_km <- terra::cellSize(ref, unit = "km")
valid_cells <- sum_raster(terra::ifel(is.na(ref), 0, 1))

read_strict_nac <- function(gcm, ssp, period) {
  suffix <- paste(gcm, ssp, period, sep = "_")
  distance <- read_aligned(file.path(mop_dir, paste0("MOP_distance_", suffix, ".tif")))
  basic <- read_aligned(file.path(mop_dir, paste0("MOP_basic_", suffix, ".tif")))
  vals <- unique(as.numeric(terra::values(basic, mat = FALSE)))
  vals <- vals[!is.na(vals)]
  if (any(!is.finite(vals)) || any(vals != 1))
    stop("MOP_basic must contain only 1 / NA. Actual values: ",
         paste(vals, collapse = ", "), " | ", suffix)
  absent <- sum_raster(terra::ifel(!is.na(ref) & is.na(distance), 1, 0))
  if (absent > 0) stop("Future distance has missing cells inside Colombian mask: ", suffix)
  # NA in basic is analog only when distance is valid.
  terra::ifel(is.na(ref), NA, terra::ifel(is.na(basic), 0, 1))
}

count_files <- file.path(consensus_dir, paste0(
  "GCM_agreement_", scenarios$ssp, "_", scenarios$period, ".tif"))
has_detailed_counts <- all(file.exists(count_files))
if (any(file.exists(count_files)) && !has_detailed_counts)
  warning("Only some GCM_agreement files exist; use binary >=2/4 for all scenarios")

make_map <- function(r, panel, heading, type, layers, limits, detailed = FALSE) {
  visual <- project_display_raster(r, method = "near", country_sf = layers$country)
  df <- raster_df(visual)
  df$class <- factor(as.character(as.integer(round(df$value))))
  if (type == "nac") {
    colours <- c("0" = "#F2F2F2", "1" = "#FDD99C", "2" = "#FEB96B",
                 "3" = "#F26C4F", "4" = "#C02B35")
    legend_name <- "NAC agreement\n(number of GCMs)"
    levels_plot <- as.character(0:4)
  } else if (detailed) {
    colours <- c("0" = "#ECECEC", "2" = "#A2D7B5", "3" = "#51B4BA", "4" = "#245F9D")
    legend_name <- "Suitable climate\n(GCM agreement)"
    levels_plot <- c("0", "2", "3", "4")
  } else {
    colours <- c("0" = "#ECECEC", "2" = "#2673B6")
    legend_name <- "Suitable climate\n(0–1 vs ≥2 GCMs)"
    levels_plot <- c("0", "2")
  }
  ggplot2::ggplot() +
    ggplot2::geom_raster(data = df, ggplot2::aes(x, y, fill = class)) +
    ggplot2::scale_fill_manual(name = legend_name, values = colours,
                               limits = levels_plot, drop = FALSE, na.translate = FALSE) +
    ggplot2::geom_sf(data = layers$departments, fill = NA, colour = "#A0A0A0", linewidth = .16) +
    ggplot2::geom_sf(data = layers$country, fill = NA, colour = "#242424", linewidth = .42) +
    metric_annotations(limits, km = 250, north = TRUE, text_size = 2.9) +
    plot_frame(limits) +
    ggplot2::labs(title = paste(panel, heading)) +
    publication_theme(base_size = 11) +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 11.5),
                   legend.title = ggplot2::element_text(size = 10.2),
                   legend.text = ggplot2::element_text(size = 10))
}

layers <- read_colombia_shapes()
limits <- map_limits(layers$country)
charts_nac <- vector("list", nrow(scenarios))
charts_suit <- vector("list", nrow(scenarios))
checks <- vector("list", nrow(scenarios))

for (i in seq_len(nrow(scenarios))) {
  ssp <- scenarios$ssp[i]; period <- scenarios$period[i]
  heading <- scenarios$label[i]
  nac_layers <- lapply(GCM, read_strict_nac, ssp = ssp, period = period)
  nac_count <- terra::app(do.call(c, nac_layers), sum, na.rm = FALSE)
  suffix <- paste(ssp, period, sep = "_")
  terra::writeRaster(nac_count, file.path(out, paste0("NAC_agreement_", suffix, ".tif")),
                     overwrite = TRUE)

  suitable_bin <- read_aligned(file.path(consensus_dir, paste0("Consensus_2of4_", suffix, ".tif")))
  bvals <- unique(as.numeric(terra::values(suitable_bin, mat = FALSE)))
  bvals <- bvals[!is.na(bvals)]
  if (!all(bvals %in% c(0, 1))) stop("Suitability consensus must contain 0/1/NA: ", suffix)
  missing_in_mask <- sum_raster(terra::ifel(!is.na(ref) & is.na(suitable_bin), 1, 0))
  if (missing_in_mask > 0) stop("Suitability consensus has NA inside Colombian mask: ", suffix)
  pred <- terra::ifel(is.na(ref), NA, suitable_bin)
  area2 <- sum_raster(terra::ifel(pred == 1, area_km, NA))
  if (abs(area2 - scenarios$expected_2of4_km2[i]) > 10)
    stop("Suitable area differs from manuscript for ", suffix,
         ": expected ", scenarios$expected_2of4_km2[i],
         " km2, got ", round(area2, 2), " km2")

  if (has_detailed_counts) {
    cnt <- read_aligned(count_files[i])
    cv <- unique(as.numeric(terra::values(cnt, mat = FALSE)))
    cv <- cv[!is.na(cv)]
    if (!all(cv %in% 0:4)) stop("GCM counts must be integers 0–4: ", suffix)
    mismatch <- sum_raster(terra::ifel(!is.na(ref) &
                 ((cnt >= 2) != (pred == 1)), 1, 0))
    if (mismatch > 0) stop("GCM counts disagree with Consensus_2of4: ", suffix)
    suit_classes <- terra::ifel(is.na(ref), NA, terra::ifel(cnt < 2, 0, cnt))
  } else {
    suit_classes <- terra::ifel(is.na(ref), NA, terra::ifel(pred == 1, 2, 0))
  }

  charts_nac[[i]] <- make_map(nac_count, LETTERS[i], heading, "nac", layers, limits)
  charts_suit[[i]] <- make_map(suit_classes, LETTERS[i + 4L], heading, "suit",
                               layers, limits, detailed = has_detailed_counts)
  n_nac2 <- sum_raster(terra::ifel(nac_count >= 2, 1, NA))
  km_nac2 <- sum_raster(terra::ifel(nac_count >= 2, area_km, NA))
  checks[[i]] <- data.frame(
    ssp = ssp, period = period, n_valid = valid_cells,
    NAC_at_least_2_GCM_cells = n_nac2,
    NAC_at_least_2_GCM_percent = 100 * n_nac2 / valid_cells,
    NAC_at_least_2_GCM_area_km2 = km_nac2,
    Suitable_at_least_2_GCM_area_km2 = area2,
    detailed_suitability_counts = has_detailed_counts
  )
  message("Validated ", suffix, ": suitable ", round(area2, 1),
          " km2; NAC ", round(100 * n_nac2 / valid_cells, 2), "% of valid cells")
}

nac_row <- patchwork::wrap_plots(charts_nac, ncol = 4, guides = "collect") &
  ggplot2::theme(legend.position = "bottom")
suit_row <- patchwork::wrap_plots(charts_suit, ncol = 4, guides = "collect") &
  ggplot2::theme(legend.position = "bottom")
combined <- (nac_row / suit_row) +
  patchwork::plot_annotation(title = "Future climatic novelty and suitability across GCMs")
save_publication(combined, file.path(out, "Figure_5_consistent"), width = 18, height = 13)
checks_df <- do.call(rbind, checks)
utils::write.csv(checks_df, file.path(out, "Figure_5_validation.csv"), row.names = FALSE)
print(checks_df)
message("Figure 5 complete: shared Colombia mainland extent and projected reference bar")
