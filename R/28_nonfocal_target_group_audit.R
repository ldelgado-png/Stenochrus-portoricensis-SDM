# R/28_nonfocal_target_group_audit.R
# Download GBIF Schizomida occurrences, exclude focal S. portoricensis,
# georeference-QC and test whether a non-focal TGB can provide 9,987 cells.
# This is a feasibility audit; it NEVER silently creates a matched-size TGB.
library(terra)
library(rgbif)
repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
out <- file.path(repo,"results","sampling_bias","target_group_nonfocal")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
env <- terra::rast(file.path(repo,"data","WorldClim_2.5m_M200_6vars.tif"))
original <- readRDS(file.path(repo,"data","ENMeval_Stenochrus_M200_SWD.rds"))
occ <- as.data.frame(ENMeval::eval.occs(original))
stopifnot(nrow(occ)==171L)
# GBIF accepted higher-taxon name must be verified from name_backbone.
taxon <- rgbif::name_backbone(name="Schizomida",rank="order")
order_key <- if(!is.null(taxon$usageKey)) taxon$usageKey else taxon$taxonKey
stopifnot(length(order_key)==1L,!is.na(order_key),as.character(taxon$rank)=="ORDER")
print(taxon)
# Save unaltered GBIF snapshots to allow source traceability.
raw_path <- file.path(out,"GBIF_Schizomida_1980_2025_snapshot.csv")
if(file.exists(raw_path)) {
  raw <- read.csv(raw_path,stringsAsFactors=FALSE)
} else {
  page_size <- 300L
  pages <- list()
  offset <- 0L
  repeat {
    if(offset>=10000L)stop("GBIF paging cap reached; use occ_download for full data.")
    r <- rgbif::occ_search(taxonKey=order_key,hasCoordinate=TRUE,
       hasGeospatialIssue=FALSE,year="1980,2025",start=offset,
       limit=page_size,fields="all")
    batch <- as.data.frame(r$data)
    if(nrow(batch)==0L)break
    pages[[length(pages)+1L]] <- batch
    offset <- offset+nrow(batch)
    cat("Downloaded records:",offset,"\n")
    if(nrow(batch)<page_size)break
  }
  stopifnot(length(pages)>0L)
  all_cols <- unique(unlist(lapply(pages,names)))
  raw <- do.call(rbind,lapply(pages,function(z){
    z[setdiff(all_cols,names(z))] <- NA
    z[,all_cols,drop=FALSE]
  }))
  write.csv(raw,raw_path,row.names=FALSE)
}
needed <- c("decimalLongitude","decimalLatitude","scientificName")
stopifnot(all(needed%in%names(raw)))
pre <- nrow(raw)
# Exclude identifiable focal records by accepted or verbatim scientific name
# AND GBIF accepted species key where supplied. Unresolved taxonomic labels
# remain for manual review and are not classed as independent automatically.
normalize <- function(z) tolower(trimws(ifelse(is.na(z),"",as.character(z))))
scientific <- normalize(raw$scientificName)
accepted <- if("acceptedScientificName"%in%names(raw))
  normalize(raw$acceptedScientificName) else rep("",nrow(raw))
focal_regex <- "^stenochrus[[:space:]]+portoricensis([[:space:]]|$)"
is_focal <- grepl(focal_regex,scientific)|grepl(focal_regex,accepted)
if("speciesKey"%in%names(raw))is_focal <- is_focal|(!is.na(raw$speciesKey)&
  as.character(raw$speciesKey)=="2181646")
resolved <- (nzchar(scientific)|nzchar(accepted))
valid <- !is_focal & resolved &
  is.finite(as.numeric(raw$decimalLongitude)) &
  is.finite(as.numeric(raw$decimalLatitude))
if("year"%in%names(raw)){
  y <- suppressWarnings(as.integer(raw$year))
  valid <- valid & !is.na(y)&y>=1980L&y<=2025L
}
if("coordinateUncertaintyInMeters"%in%names(raw)){
  u <- suppressWarnings(as.numeric(raw$coordinateUncertaintyInMeters))
  valid <- valid & (is.na(u)|u<=5000)
}
sub <- raw[valid,,drop=FALSE]
xy <- as.matrix(sub[,c("decimalLongitude","decimalLatitude")])
cells <- terra::cellFromXY(env[[1]],xy)
# Limit to the six-variable M200 mask, excluding focal presence cells.
all_complete <- which(rowSums(!is.na(terra::values(env,mat=TRUE)))==6L)
occ_cells <- unique(terra::cellFromXY(env[[1]],
  as.matrix(occ[,c("longitude","latitude")])))
good <- !is.na(cells)&cells%in%setdiff(all_complete,occ_cells)
candidate <- sub[good,,drop=FALSE]
candidate$M200_cell <- cells[good]
candidate <- candidate[!duplicated(candidate$M200_cell),,drop=FALSE]
write.csv(candidate,file.path(out,"Schizomida_nonfocal_1980_2025_M200_cells_QC.csv"),
          row.names=FALSE)
n <- nrow(candidate)
summary <- data.frame(
  gbif_order_key=as.character(order_key),downloaded=pre,
  after_focal_date_coordinate_screening=nrow(sub),
  distinct_nonfocal_M200_cells=n,baseline_background_n=9987L,
  same_size_TGB_feasible=n>=9987L)
write.csv(summary,file.path(out,"target_group_feasibility_summary.csv"),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,"sessionInfo.txt"))
print(summary,row.names=FALSE)
if(n<9987L)cat("NOT FEASIBLE as 9,987 unique independent cells.\n",
               "Do not report a matched-size TGB; consider a separately-labelled",
               " smaller matched-size control if biologically justified.\n")
# Even if n>=9987, human review of IDs, synonyms, country and dataset provenance
# is required before this can be described as an independent target-group sample.
