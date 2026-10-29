# R/46_verify_publication_maps.R
# Post-run verification for coordinated manuscript maps 1, 2, 4 and 5.
# This checks file presence and numerical audit results; it does not replace
# a visual review and does not claim any model or raster has been regenerated.
project_root <- Sys.getenv("STENOCHRU_SDM_PROJECT",
  unset = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis")
if (!dir.exists(project_root)) stop("Project directory missing: ", project_root)
out_dir <- file.path(project_root, "figures", "publication_consistent")
figure_numbers <- c("1", "2", "4", "5")
extensions <- c("png", "tif", "pdf")

audit_rows <- lapply(figure_numbers, function(number) {
  stem <- file.path(out_dir, paste0("Figure_", number),
                    paste0("Figure_", number, "_consistent"))
  paths <- paste0(stem, ".", extensions)
  if (!all(file.exists(paths))) {
    stop("Missing export for Figure ", number, ": ",
         paste(paths[!file.exists(paths)], collapse = ", "))
  }
  bytes <- file.info(paths)$size
  if (anyNA(bytes) || any(bytes <= 0))
    stop("At least one empty or unreadable export for Figure ", number)
  data.frame(figure = number, format = extensions,
             file_bytes = bytes, file_path = paths)
})
audit_table <- do.call(rbind, audit_rows)

d4 <- utils::read.csv(file.path(out_dir, "Figure_4", "Figure_4_diagnostics.csv"))
if (nrow(d4) != 1L || d4$valid_cells != 54539 ||
    d4$strict_nac_cells != 684 ||
    abs(d4$evaluated_area_km2 - 1160946) > 10)
  stop("Figure 4 numerical diagnostics do not match the definitive MOP assessment")

d5 <- utils::read.csv(file.path(out_dir, "Figure_5", "Figure_5_validation.csv"))
expected <- data.frame(
  ssp = c("SSP126", "SSP585", "SSP126", "SSP585"),
  period = c("2041-2060", "2041-2060", "2061-2080", "2061-2080"),
  suitability_km2 = c(144294.6, 138796.7, 143206.2, 143995.9),
  nac_area_pct = c(28.25873, 54.57361, 32.09328, 76.50254)
)
id <- paste(d5$ssp, d5$period)
expected_id <- paste(expected$ssp, expected$period)
ix <- match(expected_id, id)
if (nrow(d5) != 4L || anyNA(ix) || anyDuplicated(id) > 0 ||
    !all(d5$checks_passed) ||
    any(abs(d5$Suitable_at_least_2_GCM_area_km2[ix] -
            expected$suitability_km2) > 10) ||
    any(abs(d5$NAC_at_least_2_GCM_area_percent[ix] -
            expected$nac_area_pct) > 0.05)) {
  stop("Figure 5 four-scenario numerical audit is incomplete or inconsistent")
}
utils::write.csv(audit_table,
  file.path(out_dir, "publication_map_export_audit.csv"), row.names = FALSE)
message("PASS: 12 figure exports exist (PNG/TIFF/PDF for Figures 1, 2, 4 and 5).")
message("PASS: Figure 4 and Figure 5 numerical diagnostics agree with manuscript results.")
message("NOT TESTED: visual layout, colour fidelity and editorial resolution after upload.")
print(audit_table[, c("figure", "format", "file_bytes")], row.names = FALSE)
