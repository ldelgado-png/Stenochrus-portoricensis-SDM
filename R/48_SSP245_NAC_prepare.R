# Prepare strict NAC for eight SSP245 environments, then plot Figure 5 (12 panels).
# Uses the exact saved 9,987-background reference; never samples a new background.
# Calculates MOP basic only. No continuous MOP-distance values are invented.
local({
  packages <- c("terra","geodata","mop")
  missing <- packages[!vapply(packages,requireNamespace,logical(1),quietly=TRUE)]
  if (length(missing)) stop("Install missing packages: ",paste(missing,collapse=", "))
  project <- Sys.getenv("STENOCHRU_SDM_PROJECT",unset=getwd())
  if (!dir.exists(project)) stop("Set STENOCHRU_SDM_PROJECT to the original project.")
  data_dir <- file.path(project,"data")
  future_dir <- file.path(data_dir,"WorldClim_CMIP6_future")
  mop_dir <- file.path(future_dir,"MOP")
  con_dir <- file.path(future_dir,"Consensus")
  out <- file.path(project,"results","SSP245_NAC")
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  dir.create(mop_dir,recursive=TRUE,showWarnings=FALSE)
  gcms <- c("HadGEM3-GC31-LL","MIROC6","CNRM-CM6-1","MRI-ESM2-0")
  periods <- c("2041-2060","2061-2080")
  vars <- c("bio1","bio2","bio4","bio12","bio14","bio15")
  bio_ids <- c(1,2,4,12,14,15)
  required <- c(file.path(mop_dir,"MOP_distance_CURRENT_Colombia.tif"),
    file.path(mop_dir,"MOP_basic_CURRENT_Colombia.tif"),
    file.path(con_dir,paste0("Consensus_2of4_SSP245_",periods,".tif")),
    file.path(con_dir,paste0("GCM_agreement_SSP245_",periods,".tif")),
    file.path(project,"R","40_fig_helpers.R"),
    file.path(project,"R","49_figure5_with_SSP245.R"))
  if (any(!file.exists(required))) stop("Required inputs missing. Complete script 47 and install scripts 40/49 first:\n",
    paste(required[!file.exists(required)],collapse="\n"))
  ref <- terra::rast(required[1]);old_basic <- terra::rast(required[2])
  terra::compareGeom(ref,old_basic,stopOnError=TRUE)
  total <- function(r) as.numeric(terra::global(r,"sum",na.rm=TRUE)[1,1])
  stopifnot(total(!is.na(ref))==54539L)
  area <- terra::cellSize(ref,unit="km")
  select_file <- function(files,prompt) {
    files <- unique(files[file.exists(files)])
    if (length(files)==1L) return(files)
    if (!interactive()) stop(prompt,"; original input not uniquely resolved.")
    message(prompt);file.choose()
  }
  bg_files <- c(file.path(data_dir,"processed","Stenochrus_background_M200.rds"),
                file.path(data_dir,"processed","Stenochrus_background_M200.csv"))
  # Prefer the original saved RDS, otherwise its corresponding saved CSV.
  bg_file <- if (file.exists(bg_files[1])) bg_files[1] else if (file.exists(bg_files[2])) bg_files[2] else {
    select_file(character(),"Seleccione el fondo ORIGINAL de 9.987 ambientes (CSV o RDS); también se admite el ENMeval uniforme original")
  }
  if (grepl("\\.csv$",bg_file,ignore.case=TRUE)) bg <- read.csv(bg_file) else bg <- readRDS(bg_file)
  if (inherits(bg,"ENMevaluation")) {
    if (!requireNamespace("ENMeval",quietly=TRUE)) stop("Install ENMeval to read the saved background.")
    bg <- as.data.frame(ENMeval::eval.bg(bg))
  }
  if (!is.data.frame(bg) && !is.matrix(bg)) stop("The selected file does not contain the saved background environments.")
  bg <- as.data.frame(bg)
  if (!all(vars%in%names(bg))) stop("Background lacks the six named original predictors.")
  M <- as.matrix(bg[,vars,drop=FALSE])
  stopifnot(nrow(M)==9987L,all(is.finite(M)),all(apply(M,2,sd)>0))
  env_file <- select_file(list.files(data_dir,
    pattern="^WorldClim_2\\.5m_Colombia_6vars\\.tif$",recursive=TRUE,full.names=TRUE),
    "Seleccione el raster ACTUAL de Colombia con seis predictores WorldClim")
  current <- terra::rast(env_file)
  stopifnot(terra::nlyr(current)==6L)
  ids <- as.integer(sub(".*?([0-9]+)$","\\1",names(current)))
  if (anyNA(ids)||!setequal(ids,bio_ids)) stop("Current layer names do not identify the six BIO predictors.")
  current <- current[[match(bio_ids,ids)]];names(current)<-vars
  terra::compareGeom(current,ref,stopOnError=TRUE)
  current <- terra::mask(current,ref)
  basic_mop <- function(env) {
    mop::mop(m=M,g=env,type="basic",calculate_distance=FALSE,
      scale=TRUE,center=TRUE,fix_NA=TRUE,parallel=FALSE,
      progress_bar=TRUE)$mop_basic
  }
  validmask <- function(env,label) {
    n_missing <- terra::app(is.na(env),"sum",na.rm=FALSE)
    valid <- terra::ifel(!is.na(ref)&n_missing==0,1,NA)
    if (total(!is.na(valid))!=54539L) stop("Environmental mask differs from 54,539 cells: ",label)
    valid
  }
  validmask(current,"current")
  message("Checking the saved background against the canonical current NAC...")
  check <- terra::mask(basic_mop(current),ref)
  terra::compareGeom(check,ref,stopOnError=TRUE)
  old_flags <- terra::ifel(is.na(ref),NA,terra::ifel(is.na(old_basic),0,1))
  new_flags <- terra::ifel(is.na(ref),NA,terra::ifel(is.na(check),0,1))
  mismatches <- total(old_flags!=new_flags)
  n_nac <- total(new_flags)
  if (mismatches!=0 || n_nac!=684L) stop("Selected background does not reproduce canonical current NAC: ",
    n_nac," cells, ",mismatches," mismatches. Use the original background, not a new draw.")
  md5 <- tools::md5sum(c(bg_file,env_file,required[1:2]))
  write.csv(data.frame(file=names(md5),md5=unname(md5)),file.path(out,"reference_checksums.csv"),row.names=FALSE)
  rows <- list();k <- 1L
  for (period in periods) for (gcm in gcms) {
    label <- paste(gcm,"SSP245",period,sep="_")
    message("Strict NAC: ",label)
    source_env <- geodata::cmip6_world(model=gcm,ssp="245",time=period,
      var="bioc",res=2.5,path=future_dir)
    if (!inherits(source_env,"SpatRaster") || terra::nlyr(source_env)!=19L) stop("Expected 19 WorldClim BIO layers.")
    sources <- paste(terra::sources(source_env),collapse=";")
    env <- source_env[[bio_ids]];names(env)<-vars
    if (!terra::same.crs(env,ref)) stop("Future CRS mismatch: ",label)
    env <- terra::crop(env,terra::ext(ref),snap="near")
    if (!isTRUE(terra::compareGeom(env,ref,stopOnError=FALSE))) env <- terra::resample(env,ref,method="bilinear")
    env <- terra::mask(env,ref)
    valid <- validmask(env,label)
    basic <- terra::mask(basic_mop(env),ref)
    stopifnot(inherits(basic,"SpatRaster"),terra::nlyr(basic)==1L)
    terra::compareGeom(basic,ref,stopOnError=TRUE)
    values <- unique(as.numeric(terra::values(basic,mat=FALSE)))
    if (!all(values[!is.na(values)]==1)) stop("Expected basic MOP 1/NA coding.")
    terra::writeRaster(basic,file.path(mop_dir,paste0("MOP_basic_",label,".tif")),overwrite=TRUE)
    terra::writeRaster(valid,file.path(mop_dir,paste0("NAC_validmask_",label,".tif")),overwrite=TRUE)
    flags <- terra::ifel(is.na(ref),NA,terra::ifel(is.na(basic),0,1))
    rows[[k]] <- data.frame(gcm=gcm,ssp="SSP245",period=period,n_valid=54539L,
      nac_cells=total(flags),nac_area_km2=total(terra::ifel(flags==1,area,NA)),
      reference_n=9987L,current_reference_nac_cells=684L,source=sources)
    k <- k+1L
    write.csv(do.call(rbind,rows),file.path(out,"SSP245_NAC_individual_GCM.csv"),row.names=FALSE)
  }
  writeLines(capture.output(sessionInfo()),file.path(out,"sessionInfo.txt"))
  source(file.path(project,"R","49_figure5_with_SSP245.R"),local=new.env(parent=globalenv()),encoding="UTF-8")
})
