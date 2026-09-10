# 07_wallace_inputs_and_comparison.R -------------------------------------
# Prepare Wallace inputs and combine the two exported Wallace evaluation runs.

source("R/00_setup.R")
source("R/03_environmental_predictors.R")
source("R/02_calibration_area_M200.R")

# Occurrence CSV expected by Wallace.
occs_wallace <- data.frame(
  scientific_name = "Stenochrus portoricensis",
  longitude = occs_enm_171$longitude,
  latitude = occs_enm_171$latitude
)
write.csv(
  occs_wallace,
  file.path(paths$data_processed, "Stenochrus_occ_Wallace_171.csv"),
  row.names = FALSE
)

# Export six single-band rasters for Wallace.
wallace_envs <- file.path(paths$data_rasters, "Wallace_envs")
dir.create(wallace_envs, recursive = TRUE, showWarnings = FALSE)
for (v in names(bio_final_M200)) {
  terra::writeRaster(
    bio_final_M200[[v]],
    file.path(wallace_envs, paste0(v, ".tif")),
    overwrite = TRUE
  )
}

# Wallace UI limitation during development required two runs:
# RunA: RM 0.5, 1.5, 2.5, 3.5
# RunB: RM 1, 2, 3, 4
# Place exported evaluation CSV files in wallace/RunA and wallace/RunB.

runA_file <- list.files(file.path(paths$wallace, "RunA"), pattern = "evaluation.*\\.csv", full.names = TRUE)[1]
runB_file <- list.files(file.path(paths$wallace, "RunB"), pattern = "evaluation.*\\.csv", full.names = TRUE)[1]

if (!is.na(runA_file) && !is.na(runB_file)) {
  runA <- read.csv(runA_file)
  runB <- read.csv(runB_file)
  wallace_40 <- rbind(runA, runB)

  stopifnot(nrow(wallace_40) == 40L)

  aicc_min <- min(wallace_40$AICc, na.rm = TRUE)
  wallace_40$delta.AICc_40 <- wallace_40$AICc - aicc_min
  w <- exp(-0.5 * wallace_40$delta.AICc_40)
  wallace_40$w.AIC_40 <- w / sum(w, na.rm = TRUE)
  wallace_40 <- wallace_40[order(wallace_40$AICc), ]

  write.csv(
    wallace_40,
    file.path(paths$wallace, "Final", "Wallace_40_models_AICc_recalculated.csv"),
    row.names = FALSE
  )

  selected_wallace <- subset(wallace_40, fc == "LQHP" & rm == 1)
  write.csv(
    selected_wallace,
    file.path(paths$wallace, "Final", "Wallace_selected_LQHP_RM1.csv"),
    row.names = FALSE
  )

  print(head(wallace_40, 10))
} else {
  message("Wallace evaluation CSVs not yet present; inputs were prepared successfully.")
}
