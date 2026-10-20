# R/27_multiseed_background_validation.R
# Five-seed sampling-background sensitivity with a single common evaluation background.
# We retain the original 171 occurrence folds and LQHP/RM1 configuration.
# We fit 2 Arachnida floors x 5 seeds x 4 folds = 40 fold-specific maxnet models.
# Output tables are new; no previous ENMeval or diagnostic-25 objects are overwritten.
#
# NOTE: We exclude all evaluation-background cells BEFORE resampling weighted
# training backgrounds. Consequently, even the new seed-125 draws differ from
# the original diagnostic-21 seed-125 backgrounds. This is deliberate.

suppressPackageStartupMessages({
  library(terra)
  library(ENMeval)
  library(maxnet)
})

repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
out <- file.path(repo, "results", "sampling_bias")
dir25 <- file.path(out, "common_background_spatial_validation")
dir27 <- file.path(out, "replicate_backgrounds_fixed_LQHP_RM1")
model_dir <- file.path(dir27, "models")
vars <- c("bio1", "bio2", "bio4", "bio12", "bio14", "bio15")
coords <- c("longitude", "latitude")
cols <- c(coords, vars)
seeds <- 123:127
floors <- c(0.10, 0.20)
n_bg <- 9987L

# 1. Read the original calibration and the completed diagnostic-25 reference.
required <- c(
  file.path(repo, "data", "WorldClim_2.5m_M200_6vars.tif"),
  file.path(repo, "data", "ENMeval_Stenochrus_M200_SWD.rds"),
  file.path(out, "Arachnida_nobs_total_5km_WC2.5m.tif"),
  file.path(dir25, "background_common_validation.csv"),
  file.path(dir25, "validation_by_fold.csv")
)
if (!all(file.exists(required))) {
  print(data.frame(file = required, exists = file.exists(required)),
        row.names = FALSE)
  stop("Missing inputs: complete diagnostic 26 (or verify diagnostic 25) first.")
}
env <- terra::rast(required[1]); stopifnot(nlyr(env) == length(vars))
names(env) <- vars
ara <- terra::rast(required[3]); stopifnot(nlyr(ara) == 1L)
stopifnot(terra::compareGeom(env[[1]], ara, stopOnError = FALSE))
orig <- readRDS(required[2])
occs <- as.data.frame(ENMeval::eval.occs(orig))
bg_uniform <- as.data.frame(ENMeval::eval.bg(orig))
common <- read.csv(required[4], stringsAsFactors = FALSE)
stopifnot(all(cols %in% names(occs)), all(cols %in% names(bg_uniform)),
          all(cols %in% names(common)))
occs <- occs[, cols, drop = FALSE]
bg_uniform <- bg_uniform[, cols, drop = FALSE]
common <- common[, cols, drop = FALSE]
stopifnot(nrow(occs) == 171L, nrow(bg_uniform) == n_bg,
          nrow(common) == n_bg,
          all(complete.cases(occs)), all(complete.cases(common)),
          all(complete.cases(bg_uniform)))
occs_fold <- as.integer(ENMeval::eval.occs.grp(orig))
stopifnot(length(occs_fold) == 171L,
          identical(sort(unique(occs_fold)), 1:4))
reference <- read.csv(required[5], stringsAsFactors = FALSE)
reference <- reference[reference$escenario == "uniform_original",
                       c("fold", "auc_comun", "omision_10tp"), drop = FALSE]
reference <- reference[order(reference$fold), ]
stopifnot(nrow(reference) == 4L,
          identical(as.integer(reference$fold), 1:4),
          all(is.finite(reference$auc_comun)))
ref_auc <- mean(reference$auc_comun)
if (abs(ref_auc - 0.7417520) > 1e-5)
  stop("Uniform-reference AUC differs from diagnostic 25: investigate.")

# 2. Check the common test sample is disjoint from all known original training cells.
cell_ids <- function(z) terra::cellFromXY(
  env[[1]], as.matrix(z[, coords, drop = FALSE])
)
id_occ <- cell_ids(occs)
id_common <- cell_ids(common)
id_uniform <- cell_ids(bg_uniform)
stopifnot(!anyNA(id_occ), !anyNA(id_common), !anyNA(id_uniform),
          !anyDuplicated(id_common), !anyDuplicated(id_occ),
          !any(id_common %in% c(id_occ, id_uniform)))
allvalid <- which(rowSums(!is.na(terra::values(env, mat = TRUE))) ==
                    length(vars))
eligible <- setdiff(allvalid, unique(c(id_occ, id_common)))
stopifnot(length(eligible) > n_bg)
effort <- as.numeric(terra::values(ara, mat = FALSE)[eligible])
stopifnot(length(effort) == length(eligible),
          all(is.finite(effort)), all(effort >= 0))
log_effort <- log1p(effort)
median_positive <- median(log_effort[log_effort > 0])
stopifnot(is.finite(median_positive), median_positive > 0)

part_eval <- ENMeval::get.block(
  occs[, coords], common[, coords], orientation = "lat_lon"
)
stopifnot(identical(as.integer(part_eval$occs.grp), occs_fold))
fold_eval_bg <- as.integer(part_eval$bg.grp)
stopifnot(identical(sort(unique(fold_eval_bg)), 1:4))
dir.create(model_dir, recursive = TRUE, showWarnings = FALSE)

auc_rank <- function(p, b) {
  np <- length(p); nb <- length(b)
  stopifnot(np > 0L, nb > 0L, all(is.finite(c(p, b))))
  (sum(rank(c(p, b), ties.method = "average")[seq_len(np)]) -
     np * (np + 1) / 2) / (np * nb)
}

# 3. Refit each seeded background within the same four held-out occurrence folds.
results <- list()
background_summary <- list()
k <- 0L; j <- 0L

for (seed in seeds) for (floor_fraction in floors) {
  set.seed(seed)
  selected <- sample.int(length(eligible), size = n_bg,
                         replace = FALSE,
                         prob = log_effort + floor_fraction * median_positive)
  chosen_cells <- eligible[selected]
  xy <- terra::xyFromCell(env[[1]], chosen_cells)
  climate <- as.data.frame(terra::extract(env, xy))
  bg <- data.frame(longitude = xy[, 1], latitude = xy[, 2],
                   climate[, vars, drop = FALSE])
  stopifnot(nrow(bg) == n_bg, !anyDuplicated(chosen_cells),
            all(complete.cases(bg)),
            !any(chosen_cells %in% id_common),
            !any(chosen_cells %in% id_occ))

  label <- sprintf("Arachnida_floor%02d_seed%d",
                   as.integer(floor_fraction * 100), seed)
  bg_file <- file.path(dir27, paste0("background_", label, ".csv"))
  if (file.exists(bg_file)) {
    previous_bg <- read.csv(bg_file)
    same <- identical(nrow(previous_bg), nrow(bg)) &&
      all(cols %in% names(previous_bg)) &&
      isTRUE(all.equal(previous_bg[, cols], bg[, cols],
                       check.attributes = FALSE, tolerance = 1e-7))
    if (!same) stop("Existing background differs from reproducible draw: ",
                    bg_file)
  } else {
    write.csv(bg, bg_file, row.names = FALSE)
  }

  blocks <- ENMeval::get.block(occs[, coords], bg[, coords],
                               orientation = "lat_lon")
  stopifnot(identical(as.integer(blocks$occs.grp), occs_fold))
  fold_train_bg <- as.integer(blocks$bg.grp)

  j <- j + 1L
  background_summary[[j]] <- data.frame(
    seed = seed,
    floor_fraction = floor_fraction,
    n_bg = n_bg,
    n_arachnida_effort_positive = sum(effort[selected] > 0),
    arachnida_effort_positive_pct = 100 * mean(effort[selected] > 0)
  )

  for (fold in 1:4) {
    pres_train <- occs[occs_fold != fold, vars, drop = FALSE]
    pres_test  <- occs[occs_fold == fold, vars, drop = FALSE]
    bg_train <- bg[fold_train_bg != fold, vars, drop = FALSE]
    bg_test  <- common[fold_eval_bg == fold, vars, drop = FALSE]
    stopifnot(nrow(pres_train) > 0L, nrow(pres_test) > 0L,
              nrow(bg_train) > 0L, nrow(bg_test) > 0L)

    model_file <- file.path(model_dir, paste0(label, "_fold", fold, ".rds"))
    if (file.exists(model_file)) {
      fit <- readRDS(model_file)
      if (!inherits(fit, "maxnet"))
        stop("Unexpected pre-existing model object: ", model_file)
    } else {
      x <- rbind(pres_train, bg_train)
      p <- c(rep(1L, nrow(pres_train)), rep(0L, nrow(bg_train)))
      fit <- maxnet::maxnet(
        p = p, data = x,
        f = maxnet::maxnet.formula(p, x, classes = "lqhp"),
        regmult = 1
      )
      saveRDS(fit, model_file)
    }
    score_presence <- as.numeric(predict(
      fit, pres_test, type = "cloglog", clamp = TRUE))
    score_background <- as.numeric(predict(
      fit, bg_test, type = "cloglog", clamp = TRUE))
    score_train <- as.numeric(predict(
      fit, pres_train, type = "cloglog", clamp = TRUE))
    threshold <- unname(quantile(score_train, 0.1, names = FALSE))
    k <- k + 1L
    auc_value <- auc_rank(score_presence, score_background)
    results[[k]] <- data.frame(
      seed = seed, floor_fraction = floor_fraction, fold = fold,
      n_presence_train = nrow(pres_train),
      n_presence_val = nrow(pres_test),
      n_background_train = nrow(bg_train),
      n_background_val = nrow(bg_test),
      auc_common = auc_value,
      auc_uniform_same_fold = reference$auc_comun[fold],
      delta_auc_vs_uniform = auc_value - reference$auc_comun[fold],
      omission_10tp = mean(score_presence < threshold)
    )
  }
  cat("Completed:", label, "(4 folds)\n")
}

# 4. Report seed-to-seed stability without treating folds as independent replicates.
by_fold <- do.call(rbind, results)
by_seed <- do.call(rbind, lapply(split(by_fold,
    interaction(by_fold$floor_fraction, by_fold$seed, drop = TRUE)),
    function(z) data.frame(
      seed = z$seed[1],
      floor_fraction = z$floor_fraction[1],
      mean_auc = mean(z$auc_common),
      mean_delta_auc_vs_uniform = mean(z$delta_auc_vs_uniform),
      mean_omission_10tp = mean(z$omission_10tp)
    )))
by_seed <- by_seed[order(by_seed$floor_fraction, by_seed$seed), ]
rownames(by_seed) <- NULL
by_floor <- do.call(rbind, lapply(split(by_seed, by_seed$floor_fraction),
  function(z) data.frame(
    floor_fraction = z$floor_fraction[1],
    n_seeds = nrow(z),
    auc_mean = mean(z$mean_auc),
    auc_sd = sd(z$mean_auc),
    auc_min = min(z$mean_auc),
    auc_max = max(z$mean_auc),
    delta_auc_mean = mean(z$mean_delta_auc_vs_uniform),
    delta_auc_min = min(z$mean_delta_auc_vs_uniform),
    delta_auc_max = max(z$mean_delta_auc_vs_uniform),
    seeds_higher_auc_than_uniform = sum(z$mean_delta_auc_vs_uniform > 0),
    omission_mean = mean(z$mean_omission_10tp)
  )))
rownames(by_floor) <- NULL
file_out <- list(
  validation_by_fold_and_seed = by_fold,
  validation_by_seed = by_seed,
  validation_seed_summary = by_floor,
  background_sampling_composition = do.call(rbind, background_summary)
)
for (name in names(file_out)) {
  write.csv(file_out[[name]],
            file.path(dir27, paste0(name, ".csv")),
            row.names = FALSE)
}
writeLines(capture.output(sessionInfo()), file.path(dir27, "sessionInfo.txt"))
cat("\n=== DIAGNOSTICO 27: AUC POR SEMILLA ===\n")
print(by_seed, row.names = FALSE)
cat("\n=== DIAGNOSTICO 27: SENSIBILIDAD ENTRE SEMILLAS ===\n")
print(by_floor, row.names = FALSE)
cat("\nUniform background mean fold AUC (diagnostic 25):", ref_auc, "\n")
cat("Saved 40 fold-model objects and five CSV/text diagnostics to:", dir27, "\n")
cat("Interpretation: four-fold internal cross-validation under one common\n",
    "uniform evaluation-background realization; no external test data.\n", sep = "")
