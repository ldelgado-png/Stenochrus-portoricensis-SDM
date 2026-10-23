# 03b_vif_diagnostic.R
# Recalculate VIF for the final six predictors without requiring env_vif.
# Existing environmental samples/correlation matrices are preferred. A new
# raster sample is explicitly labelled as a new diagnostic, not a recovered
# historical output. This script does not modify modelling inputs.

local({
  variables <- c("bio1", "bio2", "bio4", "bio12", "bio14", "bio15")
  candidates <- c("bio1", "bio2", "bio4", "bio5", "bio12", "bio14", "bio15")
  reference <- c(bio1 = 41.258879, bio2 = 8.026073, bio4 = 10.352137,
                 bio5 = 44.264905, bio12 = 4.671783,
                 bio14 = 4.672059, bio15 = 2.763944)

  calculate_vif <- function(values) {
    if (nrow(values) <= ncol(values) ||
        any(!is.finite(as.matrix(values))) ||
        any(vapply(values, stats::sd, numeric(1)) == 0)) {
      stop("The environmental sample has insufficient or invalid values.")
    }
    vapply(names(values), function(variable) {
      fit <- stats::lm(
        stats::reformulate(setdiff(names(values), variable),
                           response = variable),
        data = values
      )
      1 / (1 - summary(fit)$r.squared)
    }, numeric(1))
  }

  values <- NULL
  correlation <- NULL
  initial_vif <- NULL
  input_name <- NULL
  diagnostic_type <- NULL
  sample_n <- NA_integer_

  for (object_name in c("env_M200_sample", "env_vif")) {
    if (!exists(object_name, envir = .GlobalEnv, inherits = FALSE)) next
    candidate <- get(object_name, envir = .GlobalEnv)
    if (!(is.data.frame(candidate) || is.matrix(candidate))) next
    if (!all(variables %in% colnames(candidate))) next
    retained <- if (all(candidates %in% colnames(candidate))) candidates else variables
    candidate <- as.data.frame(candidate[, retained, drop = FALSE])
    if (!all(vapply(candidate, is.numeric, logical(1)))) next
    candidate <- stats::na.omit(candidate)
    if (ncol(candidate) == 7L) initial_vif <- calculate_vif(candidate)
    values <- candidate[, variables, drop = FALSE]
    input_name <- object_name
    diagnostic_type <- "recalculation_from_existing_environmental_sample"
    sample_n <- nrow(values)
    break
  }

  if (is.null(values) &&
      exists("cor_M200", envir = .GlobalEnv, inherits = FALSE)) {
    candidate <- get("cor_M200", envir = .GlobalEnv)
    if (is.matrix(candidate) && is.numeric(candidate) &&
        all(variables %in% rownames(candidate)) &&
        all(variables %in% colnames(candidate))) {
      correlation <- candidate[variables, variables, drop = FALSE]
      if (any(!is.finite(correlation)) ||
          !isTRUE(all.equal(correlation, t(correlation))) ||
          any(abs(diag(correlation) - 1) > 1e-8) ||
          min(eigen(correlation, symmetric = TRUE, only.values = TRUE)$values) <= 0) {
        stop("cor_M200 is not a valid, positive-definite correlation matrix.")
      }
      if (all(candidates %in% rownames(candidate)) &&
          all(candidates %in% colnames(candidate))) {
        initial_vif <- diag(solve(candidate[candidates, candidates, drop = FALSE]))
        names(initial_vif) <- candidates
      }
      input_name <- "cor_M200"
      diagnostic_type <- "recalculation_from_existing_correlation_matrix"
    }
  }

  if (is.null(values) && is.null(correlation)) {
    if (!requireNamespace("terra", quietly = TRUE)) {
      stop("Install terra first: install.packages('terra')")
    }
    raster_path <- getOption("stenochrus.vif.raster_file", NULL)
    known_path <- file.path("data", "rasters", "WorldClim_2.5m_M200_6vars.tif")
    if (is.null(raster_path) && file.exists(known_path)) raster_path <- known_path
    if (is.null(raster_path)) {
      if (!interactive()) {
        stop("Set options(stenochrus.vif.raster_file = 'path/to/WorldClim_2.5m_M200_6vars.tif').")
      }
      message("Select the final WorldClim_2.5m_M200_6vars.tif calibration raster.")
      raster_path <- file.choose()
    }
    raster <- terra::rast(raster_path)
    if (!all(variables %in% names(raster))) {
      # The deposited workflow specifies the band order of this exact file.
      if (basename(raster_path) == "WorldClim_2.5m_M200_6vars.tif" &&
          terra::nlyr(raster) == 6L) {
        names(raster) <- variables
      } else {
        stop("Select the final six-predictor M200 stack; its predictor names could not be verified.")
      }
    }
    raster <- raster[[variables]]
    set.seed(123)
    values <- terra::spatSample(
      raster, size = 10000, method = "random",
      na.rm = TRUE, values = TRUE, as.df = TRUE
    )
    values <- as.data.frame(stats::na.omit(values[, variables, drop = FALSE]))
    if (nrow(values) != 10000L) {
      stop("The raster did not supply 10,000 complete environments; check its mask and valid cells.")
    }
    sample_n <- nrow(values)
    input_name <- normalizePath(raster_path, winslash = "/", mustWork = TRUE)
    diagnostic_type <- "new_random_sample_from_supplied_final_calibration_raster"
  }

  final_vif <- if (!is.null(values)) calculate_vif(values) else diag(solve(correlation))
  names(final_vif) <- variables
  final_vif <- sort(final_vif, decreasing = TRUE)
  original_values_match <- !is.null(initial_vif) &&
    all(is.finite(initial_vif[candidates])) &&
    max(abs(initial_vif[candidates] - reference[candidates])) <= 1e-5

  output <- data.frame(
    variable = names(final_vif), VIF = unname(final_vif),
    sample_n = sample_n, diagnostic_type = diagnostic_type,
    seven_variable_VIF_matches_original = original_values_match
  )
  output_dir <- getOption("stenochrus.vif.output_dir",
                         file.path("results", "predictor_selection"))
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  run_dir <- tempfile(pattern = paste0("vif_", format(Sys.time(), "%Y%m%d_%H%M%S"), "_"),
                      tmpdir = output_dir)
  if (!dir.create(run_dir)) stop("Could not create the output directory.")
  utils::write.csv(output, file.path(run_dir, "VIF_final_6predictores.csv"),
                   row.names = FALSE)
  if (!is.null(initial_vif)) {
    utils::write.csv(
      data.frame(variable = names(initial_vif), VIF = unname(initial_vif)),
      file.path(run_dir, "VIF_initial_available_7predictores.csv"), row.names = FALSE
    )
  }
  saveRDS(list(values = values, correlation = correlation,
               input = input_name, diagnostic_type = diagnostic_type,
               seven_variable_VIF_matches_original = original_values_match,
               note = "New calculation; matching initial VIF values supports consistency with the historical diagnostic but is not an archived historical final output."),
          file.path(run_dir, "VIF_inputs_and_provenance.rds"))
  writeLines(capture.output(sessionInfo()), file.path(run_dir, "sessionInfo.txt"))

  assign("vif_final", final_vif, envir = .GlobalEnv)
  cat("\n=== VIF: SIX FINAL PREDICTORS ===\n")
  print(final_vif, digits = 8)
  cat("\nDiagnostic: ", diagnostic_type,
      "\nSeven-variable VIF matches the original: ", original_values_match,
      "\nOutput: ", normalizePath(run_dir, winslash = "/"), "\n", sep = "")
  if (!original_values_match) {
    message("Treat this output as a recalculated diagnostic; the historical environmental sample was not verified.")
  }
})
