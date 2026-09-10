# 04_background_sampling.R -----------------------------------------------
# Prefer the saved 9,987-point background so that downstream scripts
# reproduce the direct ENMeval analysis exactly.

source("R/00_setup.R")
source("R/03_environmental_predictors.R")

bg_rds <- file.path(paths$data_processed, "Stenochrus_background_M200.rds")
bg_csv <- file.path(paths$data_processed, "Stenochrus_background_M200.csv")

if (file.exists(bg_rds)) {
  background_final <- readRDS(bg_rds)
} else if (file.exists(bg_csv)) {
  background_final <- read.csv(bg_csv, stringsAsFactors = FALSE)
} else {
  stop("Provide the saved Stenochrus_background_M200.rds or .csv file.")
}

bg_swd <- background_final[, c("decimalLongitude", "decimalLatitude", vars_final)]
names(bg_swd)[1:2] <- c("longitude", "latitude")

stopifnot(nrow(bg_swd) == 9987L)
stopifnot(all(stats::complete.cases(bg_swd)))

message("Background points: ", nrow(bg_swd))
