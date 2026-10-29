# Execute matching maps (Figures 1, 2, 4, 5) and post-run verification.
# Local source rasters are read-only; exports in figures/publication_consistent/.
project_root <- Sys.getenv("STENOCHRU_SDM_PROJECT",
  unset = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis")
if (!dir.exists(project_root)) stop("Project folder missing: ", project_root)
script_dir <- file.path(project_root, "R")
files <- c("40_fig_helpers.R", "41_figure1_consistent.R",
           "42_figure2_consistent.R", "43_figure4_consistent.R",
           "44_figure5_consistent.R", "46_verify_publication_maps.R")
missing <- files[!file.exists(file.path(script_dir, files))]
if (length(missing)) stop("Missing required scripts in project/R: ", paste(missing, collapse = ", "))
Sys.setenv(STENOCHRU_SDM_PROJECT = project_root)
for (script in files[-1]) {
  cat("\n========== ", script, " ==========\n", sep = "")
  tryCatch(
    source(file.path(script_dir, script), local = FALSE, echo = FALSE),
    error = function(e) {
      message("STOPPED IN: ", script)
      message("DETAIL: ", conditionMessage(e))
      stop(e)
    }
  )
}
cat("\nMaps and numeric/export audit finished. Output: ", file.path(project_root, "figures", "publication_consistent"), "\n", sep = "")
