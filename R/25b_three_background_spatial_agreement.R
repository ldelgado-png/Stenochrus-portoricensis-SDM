# R/25b_three_background_spatial_agreement.R
# We calculate area-weighted agreement among the three existing current
# Colombian cloglog rasters at their respective 10TP thresholds.
# This is a post-processing comparison; we do not refit any model.
suppressPackageStartupMessages(library(terra))

repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
dir_comp <- file.path(repo, "results", "sampling_bias",
                      "Colombia_comparison_3backgrounds")
scenarios <- c("uniform_original", "Arachnida_floor10", "Arachnida_floor20")
files <- file.path(dir_comp, paste0("Colombia_", scenarios, "_cloglog.tif"))
tabfile <- file.path(dir_comp, "Colombia_projection_comparison.csv")
stopifnot(all(file.exists(files)), file.exists(tabfile))

tab <- read.csv(tabfile, stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(tab$escenario), all(scenarios %in% tab$escenario))
thresholds <- setNames(tab$umbral_10tp, tab$escenario)
p <- setNames(lapply(files, terra::rast), scenarios)
ref <- p[["uniform_original"]]
stopifnot(all(vapply(p, function(z) terra::compareGeom(
  ref, z, stopOnError = FALSE), logical(1))))

valid <- Reduce(function(x, y) x & y, lapply(p, function(z) !is.na(z)))
binary <- lapply(scenarios, function(s) p[[s]] >= thresholds[s])
names(binary) <- scenarios
n_models <- (binary[[1]] * 1L) + (binary[[2]] * 1L) + (binary[[3]] * 1L)
n_models <- terra::ifel(valid, n_models, NA)
area_cells <- terra::cellSize(ref, unit = "km")
area_of <- function(condition) {
  as.numeric(terra::global(terra::ifel(valid & condition, area_cells, NA),
                           fun = "sum", na.rm = TRUE)[1, 1])
}

total <- area_of(valid)
any_suitable <- area_of(n_models > 0)
area_baseline <- area_of(binary[["uniform_original"]])
stopifnot(abs(area_baseline - 379223.5) < 0.2)

agreement <- do.call(rbind, lapply(0:3, function(n) {
  mask <- valid & (n_models == n)
  km2 <- area_of(mask)
  data.frame(n_models_suitable = n,
             n_cells = as.integer(terra::global(
               terra::ifel(mask, 1, NA), "sum", na.rm = TRUE)[1, 1]),
             area_km2 = km2,
             pct_study_mask = 100 * km2 / total,
             pct_any_model_suitable = if(n > 0) 100 * km2 / any_suitable else 0)
}))

b10 <- binary[["Arachnida_floor10"]]
b20 <- binary[["Arachnida_floor20"]]
intersection <- area_of(b10 & b20)
union <- area_of(b10 | b20)
comparison <- data.frame(
  comparison = "Arachnida_floor10_vs_Arachnida_floor20",
  area_floor10_km2 = area_of(b10),
  area_floor20_km2 = area_of(b20),
  intersection_km2 = intersection,
  union_km2 = union,
  area_only_floor10_km2 = area_of(b10 & !b20),
  area_only_floor20_km2 = area_of(!b10 & b20),
  jaccard = intersection / union,
  all_three_suitable_km2 = area_of(n_models == 3),
  any_three_suitable_km2 = any_suitable,
  fraction_3of3_among_any_suitable = area_of(n_models == 3) / any_suitable,
  study_mask_area_km2 = total
)

prefix <- file.path(dir_comp, "three_background_agreement")
raster_out <- paste0(prefix, "_own10tp.tif")
csv_out <- paste0(prefix, "_area.csv")
pair_out <- paste0(prefix, "_weighted_pair.csv")
if (any(file.exists(c(raster_out, csv_out, pair_out))))
  stop("An agreement output already exists. Verify before rerunning.")

terra::writeRaster(n_models, raster_out, datatype = "INT1U",
                   NAflag = 255, overwrite = FALSE)
write.csv(agreement, csv_out, row.names = FALSE)
write.csv(comparison, pair_out, row.names = FALSE)

cat("\n=== AGREEMENT BY NUMBER OF MODELS ===\n")
print(agreement, row.names = FALSE)
cat("\n=== ARACHNIDA-WEIGHTED OVERLAP ===\n")
print(comparison, row.names = FALSE)
cat("\nThe output describes thresholded climatic suitability,",
    "not occurrence or validated occupancy probability.\n")
