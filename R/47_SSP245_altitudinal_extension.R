# SSP2-4.5 extension: eight CMIP6 transfers, two consensus rasters,
# gain/loss/persistence and the seven-condition elevational Figure 6.
# Execute in the ORIGINAL Stenochrus project in RStudio.
# This script transfers the saved uniform-background model; it does not refit it.
local({
  needed <- c("terra", "geodata", "maxnet", "ggplot2", "patchwork")
  missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly=TRUE)]
  if (length(missing)) stop("Install packages first: ", paste(missing, collapse=", "))
  project <- Sys.getenv("STENOCHRU_SDM_PROJECT", unset=getwd())
  if (!file.exists(file.path(project,"R","12_altitudinal_analysis.R"))) {
    if (.Platform$OS.type == "windows" && interactive()) {
      project <- utils::choose.dir(caption="Seleccione el proyecto ORIGINAL Stenochrus")
    } else stop("Set STENOCHRU_SDM_PROJECT to the original project folder.")
  }
  stopifnot(length(project)==1L, !is.na(project), dir.exists(project))
  Sys.setenv(STENOCHRU_SDM_PROJECT=normalizePath(project, winslash="/"))
  data_dir <- file.path(project,"data")
  out <- file.path(project,"results","SSP245_extension")
  cache <- file.path(data_dir,"WorldClim_CMIP6_future")
  consensus_dir <- file.path(cache,"Consensus")
  for (p in c(out, cache, consensus_dir)) dir.create(p, recursive=TRUE, showWarnings=FALSE)
  # A unique run folder prevents accidental reuse of predictions from another model.
  run_dir <- tempfile("run_", tmpdir=out)
  dir.create(run_dir)
  terra::terraOptions(memfrac=0.25, progress=1)
  threshold <- 0.2123639
  vars <- c("bio1","bio2","bio4","bio12","bio14","bio15")
  bio_ids <- c(1,2,4,12,14,15)
  gcms <- c("HadGEM3-GC31-LL","MIROC6","CNRM-CM6-1","MRI-ESM2-0")
  periods <- c("2041-2060","2061-2080")
  choose_input <- function(candidates, label) {
    candidates <- unique(candidates[file.exists(candidates)])
    if (length(candidates)==1L) return(candidates)
    if (!interactive()) stop(label, ": provide the original file; candidates found: ",length(candidates))
    message(label)
    f <- file.choose()
    if (!file.exists(f)) stop("Input does not exist.")
    f
  }
  current_file <- file.path(data_dir,"Stenochrus_prediction_Colombia_GADM_LQHP_RM1_current.tif")
  if (!file.exists(current_file)) stop("Canonical current prediction missing: ",current_file)
  old_suffixes <- c("SSP126_2041-2060","SSP585_2041-2060",
                    "SSP126_2061-2080","SSP585_2061-2080")
  inputs <- c(file.path(data_dir,"Stenochrus_occ_final_172.csv"),
    file.path(data_dir,"Stenochrus_portoricensis_America_QC_unique.csv"),
    file.path(project,"R","13_altitudinal_figure.R"),
    file.path(consensus_dir,paste0("Consensus_2of4_",old_suffixes,".tif")),
    file.path(consensus_dir,paste0("Change_consensus_2of4_",old_suffixes,".tif")))
  if (any(!file.exists(inputs))) stop("Required historical inputs missing:\n",
    paste(inputs[!file.exists(inputs)],collapse="\n"))
  current <- terra::rast(current_file)
  stopifnot(terra::nlyr(current)==1L, terra::is.lonlat(current))
  area <- terra::cellSize(current, unit="km")
  present <- current >= threshold
  sum_area <- function(z) as.numeric(terra::global(terra::ifel(z,area,NA),"sum",na.rm=TRUE)[1,1])
  present_area <- sum_area(present)
  if (!is.finite(present_area) || abs(present_area-379223.5)>1) stop("Current area does not reproduce 379223.5 km2.")
  model_file <- choose_input(c(
    file.path(project,"results","model_selection","maxnet_LQHP_RM1.rds"),
    file.path(data_dir,"ENMeval_Stenochrus_M200_SWD.rds")
  ), "Seleccione el modelo UNIFORME original LQHP/RM1 o su objeto ENMeval")
  obj <- readRDS(model_file)
  if (inherits(obj,"maxnet")) {
    model <- obj
  } else if (inherits(obj,"ENMevaluation")) {
    if (!requireNamespace("ENMeval",quietly=TRUE)) stop("Install ENMeval to read this object.")
    models <- ENMeval::eval.models(obj)
    if (!"fc.LQHP_rm.1" %in% names(models)) stop("Original selected model not found.")
    model <- models[["fc.LQHP_rm.1"]]
  } else stop("Expected a maxnet model or ENMevaluation object.")
  stopifnot(inherits(model,"maxnet"), setequal(names(model$varmin),vars))
  current_env_file <- choose_input(list.files(data_dir,
    pattern="^WorldClim_2\\.5m_Colombia_6vars\\.tif$", recursive=TRUE,full.names=TRUE),
    "Seleccione el raster ACTUAL de Colombia, seis predictores WorldClim 2.5 minutos")
  current_env <- terra::rast(current_env_file)
  stopifnot(terra::nlyr(current_env)==6L)
  parsed <- as.integer(sub(".*?([0-9]+)$","\\1",names(current_env)))
  if (anyNA(parsed) || !setequal(parsed,bio_ids)) stop("Layer names must identify BIO1,2,4,12,14,15; verify layer order.")
  current_env <- current_env[[match(bio_ids,parsed)]]
  names(current_env) <- vars
  terra::compareGeom(current_env,current,stopOnError=TRUE)
  predict_fun <- function(model,data,...) {
    as.numeric(predict(model,as.data.frame(data),type="cloglog",clamp=TRUE))
  }
  check <- terra::predict(current_env,model,fun=predict_fun,na.rm=TRUE,cores=1,
    filename=file.path(run_dir,"current_model_check.tif"),overwrite=FALSE)
  # Matching current predictions checks model identity and predictor units/order.
  diff <- abs(check-current)
  max_diff <- as.numeric(terra::global(diff,"max",na.rm=TRUE)[1,1])
  missing_check <- as.numeric(terra::global(!is.na(current)&is.na(check),"sum",na.rm=TRUE)[1,1])
  if (!is.finite(max_diff) || max_diff>1e-5 || missing_check!=0) {
    stop("Selected model/environment does not reproduce the canonical current raster. Maximum difference: ",max_diff)
  }
  md5 <- tools::md5sum(c(model_file,current_file,current_env_file))
  write.csv(data.frame(file=names(md5),md5=unname(md5)),file.path(run_dir,"input_checksums.csv"),row.names=FALSE)
  rows <- list(); manifest <- list(); consensus_rows <- list(); k <- 1L
  for (period in periods) {
    predictions <- list()
    for (gcm in gcms) {
      message("Downloading/reusing SSP245: ",gcm," / ",period)
      future <- geodata::cmip6_world(model=gcm,ssp="245",time=period,
        var="bioc",res=2.5,path=cache)
      if (!inherits(future,"SpatRaster") || terra::nlyr(future)!=19L) stop("Expected 19 WorldClim BIO layers.")
      manifest[[k]] <- data.frame(gcm=gcm,ssp="SSP245",period=period,
        source=paste(terra::sources(future),collapse=";"),threshold=threshold)
      future <- future[[bio_ids]]
      names(future) <- vars
      if (!terra::same.crs(future,current)) stop("Future CRS differs from canonical grid.")
      future <- terra::crop(future,terra::ext(current),snap="near")
      if (!isTRUE(terra::compareGeom(future,current,stopOnError=FALSE))) {
        future <- terra::resample(future,current,method="bilinear")
      }
      future <- terra::mask(future,current)
      dest <- file.path(run_dir,paste0("Prediction_",gcm,"_SSP245_",period,".tif"))
      p <- terra::predict(future,model,fun=predict_fun,na.rm=TRUE,cores=1,
        filename=dest,overwrite=FALSE,wopt=list(datatype="FLT4S",gdal="COMPRESS=LZW"))
      n_missing <- as.numeric(terra::global(!is.na(current)&is.na(p),"sum",na.rm=TRUE)[1,1])
      if (n_missing!=0) stop("Future data do not cover the canonical current mask: ",gcm," ",period)
      binary <- p>=threshold
      rows[[k]] <- data.frame(gcm=gcm,ssp="SSP245",period=period,
        current_area_km2=present_area,future_area_km2=sum_area(binary),
        persistence_km2=sum_area(present&binary),loss_km2=sum_area(present&!binary),
        gain_km2=sum_area(!present&binary))
      predictions[[gcm]] <- binary
      k <- k+1L
      write.csv(do.call(rbind,rows),file.path(run_dir,"SSP245_individual_gcm.csv"),row.names=FALSE)
      write.csv(do.call(rbind,manifest),file.path(run_dir,"future_source_manifest.csv"),row.names=FALSE)
    }
    binary_stack <- terra::rast(unname(predictions))
    stopifnot(inherits(binary_stack, "SpatRaster"), terra::nlyr(binary_stack) == 4L)
    agreement <- terra::app(binary_stack,"sum",na.rm=FALSE)
    consensus <- agreement>=2
    # 0 unchanged unsuitable; 1 gain; 2 loss; 3 persistence.
    change <- terra::ifel(present,terra::ifel(consensus,3,2),terra::ifel(consensus,1,0))
    suffix <- paste0("SSP245_",period,".tif")
    terra::writeRaster(agreement,file.path(consensus_dir,paste0("GCM_agreement_",suffix)),overwrite=TRUE)
    terra::writeRaster(consensus,file.path(consensus_dir,paste0("Consensus_2of4_",suffix)),overwrite=TRUE)
    terra::writeRaster(change,file.path(consensus_dir,paste0("Change_consensus_2of4_",suffix)),overwrite=TRUE)
    consensus_rows[[period]] <- data.frame(ssp="SSP245",period=period,
      current_area_km2=present_area,future_area_km2=sum_area(consensus),
      persistence_km2=sum_area(present&consensus),loss_km2=sum_area(present&!consensus),
      gain_km2=sum_area(!present&consensus))
  }
  summary <- do.call(rbind,consensus_rows)
  summary$pct_change <- 100*(summary$future_area_km2/summary$current_area_km2-1)
  stopifnot(all(abs(summary$persistence_km2+summary$loss_km2-present_area)<1e-6),
    all(abs(summary$persistence_km2+summary$gain_km2-summary$future_area_km2)<1e-6))
  write.csv(summary,file.path(run_dir,"SSP245_consensus_2of4.csv"),row.names=FALSE)
  print(summary)
  writeLines(capture.output(sessionInfo()),file.path(run_dir,"sessionInfo.txt"))
  # The updated analysis writes into a separate directory and checks the
  # four historical scenario areas against their archived reference values.
  Sys.setenv(STENOCHRU_INCLUDE_SSP245="TRUE")
  source(file.path(project,"R","12_altitudinal_analysis.R"),local=new.env(parent=globalenv()),encoding="UTF-8")
  source(file.path(project,"R","13_altitudinal_figure.R"),local=new.env(parent=globalenv()),encoding="UTF-8")
  message("SSP245 extension complete. Elevational tables/figure: ",
    file.path(project,"results","altitude_with_SSP245"),"; provenance: ",run_dir)
})
