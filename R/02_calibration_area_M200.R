# 02_calibration_area_M200.R ----------------------------------------------
# Reconstruct the operational geodesic 200-km calibration area from the
# 234 quality-controlled unique exact coordinates.

source("R/00_setup.R")

occ_file <- file.path(paths$data_processed, "Stenochrus_portoricensis_America_QC_unique.csv")
stopifnot(file.exists(occ_file))
occ_unique <- read.csv(occ_file, stringsAsFactors = FALSE)

sf::sf_use_s2(TRUE)

occ_unique_sf <- sf::st_as_sf(
  occ_unique,
  coords = c("decimalLongitude", "decimalLatitude"),
  crs = 4326,
  remove = FALSE
)

M200_geo <- occ_unique_sf |>
  sf::st_buffer(dist = 200000) |>
  sf::st_union()

M200_wallace <- sf::st_sf(id = 1, geometry = M200_geo)

out_shp <- file.path(paths$data_processed, "Stenochrus_M200_Wallace.shp")
sf::st_write(M200_wallace, out_shp, delete_layer = TRUE, quiet = TRUE)

message("M200 bbox:")
print(sf::st_bbox(M200_geo))
