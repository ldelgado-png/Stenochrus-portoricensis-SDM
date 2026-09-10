# 00_setup.R ---------------------------------------------------------------
# Project paths and package checks

project_root <- normalizePath(".", winslash = "/", mustWork = FALSE)

paths <- list(
  data_raw = file.path(project_root, "data", "raw"),
  data_processed = file.path(project_root, "data", "processed"),
  data_rasters = file.path(project_root, "data", "rasters"),
  wallace = file.path(project_root, "wallace"),
  results = file.path(project_root, "results"),
  figures = file.path(project_root, "figures")
)

invisible(lapply(paths, dir.create, recursive = TRUE, showWarnings = FALSE))

pkgs <- c(
  "dplyr", "readr", "terra", "sf", "geodata", "maxnet", "ENMeval",
  "CoordinateCleaner", "mop"
)

status <- vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)
print(status)

if (any(!status)) {
  message("Missing packages: ", paste(names(status)[!status], collapse = ", "))
}

vars_final <- c("bio1", "bio2", "bio4", "bio12", "bio14", "bio15")

message("Project root: ", project_root)
