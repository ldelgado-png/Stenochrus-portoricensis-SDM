# 01_occurrence_qc.R -------------------------------------------------------
# Reconstruct the documented coordinate-QC decisions from the saved
# American GBIF CSV. This script does not re-download GBIF data.

source("R/00_setup.R")

raw_file <- file.path(paths$data_processed, "Stenochrus_portoricensis_GBIF_America_raw.csv")
stopifnot(file.exists(raw_file))

occ_america <- read.csv(raw_file, stringsAsFactors = FALSE)

# CoordinateCleaner diagnostic flags used during development.
# Do not remove flagged points automatically for this synanthropic species.
if (requireNamespace("CoordinateCleaner", quietly = TRUE)) {
  cc <- CoordinateCleaner::clean_coordinates(
    x = occ_america,
    lon = "decimalLongitude",
    lat = "decimalLatitude",
    species = "species",
    tests = c("capitals", "centroids", "equal", "gbif", "institutions", "zeros"),
    value = "spatialvalid"
  )
  print(table(cc$.summary, useNA = "ifany"))
}

# Explicit exclusions documented in the project.
# 1) Unverified GEOLocate coordinate inconsistent with "near Cali".
bad_key_cali <- "477927176"

# 2) 29 unsupported GenBank-mined records sharing the same exact coordinate.
genbank_lon <- -96.33162
genbank_lat <-  38.82081

occ_qc <- occ_america[
  as.character(occ_america$key) != bad_key_cali &
    !(abs(occ_america$decimalLongitude - genbank_lon) < 1e-8 &
      abs(occ_america$decimalLatitude  - genbank_lat) < 1e-8),
]

message("Records after explicit exclusions: ", nrow(occ_qc))

# Quality-priority exact-coordinate deduplication.
# Preserved specimen > material citation > human observation > other.
record_score <- dplyr::case_when(
  occ_qc$basisOfRecord == "PRESERVED_SPECIMEN" ~ 1,
  occ_qc$basisOfRecord == "MATERIAL_CITATION" ~ 2,
  occ_qc$basisOfRecord == "HUMAN_OBSERVATION" ~ 3,
  TRUE ~ 4
)

uncertainty_score <- ifelse(
  is.na(occ_qc$coordinateUncertaintyInMeters),
  Inf,
  occ_qc$coordinateUncertaintyInMeters
)

locality_score <- ifelse(
  (!is.na(occ_qc$locality) & nzchar(occ_qc$locality)) |
    (!is.na(occ_qc$verbatimLocality) & nzchar(occ_qc$verbatimLocality)),
  0, 1
)

year_score <- ifelse(!is.na(occ_qc$year), 0, 1)

occ_qc$record_score <- record_score
occ_qc$uncertainty_score <- uncertainty_score
occ_qc$locality_score <- locality_score
occ_qc$year_score <- year_score

occ_unique <- occ_qc |>
  dplyr::arrange(
    decimalLongitude, decimalLatitude,
    record_score, uncertainty_score, locality_score, year_score
  ) |>
  dplyr::distinct(decimalLongitude, decimalLatitude, .keep_all = TRUE)

message("Unique exact coordinates: ", nrow(occ_unique))

write.csv(
  occ_unique,
  file.path(paths$data_processed, "Stenochrus_portoricensis_America_QC_unique.csv"),
  row.names = FALSE
)
