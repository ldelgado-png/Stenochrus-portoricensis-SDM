# R/14_auc_fold_audit.R
# Audit the four ENMeval folds for the selected LQHP / RM = 1 model.
# Run in the ORIGINAL modelling project: reads the saved object in
# data/ENMeval_Stenochrus_M200_SWD.rds (or an in-memory ENMevaluation object).
# No refitting, no changes to fitted models.

if (!requireNamespace("ENMeval", quietly = TRUE)) {
  stop("Package ENMeval is required.")
}

if (!exists("repo", inherits = TRUE)) {
  repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
}
if (!dir.exists(repo)) stop("Project folder does not exist: ", repo)

outdir <- file.path(repo, "results", "model_selection")
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

if (exists("enm", inherits = TRUE) &&
    inherits(get("enm", inherits = TRUE), "ENMevaluation")) {
  e <- get("enm", inherits = TRUE)
  cat("Using enm in memory.\n")
} else if (exists("e_stenochrus", inherits = TRUE) &&
           inherits(get("e_stenochrus", inherits = TRUE), "ENMevaluation")) {
  e <- get("e_stenochrus", inherits = TRUE)
  cat("Using e_stenochrus in memory.\n")
} else {
  saved_object <- file.path(repo, "data", "ENMeval_Stenochrus_M200_SWD.rds")
  if (!file.exists(saved_object)) {
    stop("Original ENMeval object not found at: ", saved_object)
  }
  e <- readRDS(saved_object)
  cat("Loaded object: ", saved_object, "\n", sep = "")
}
if (!methods::is(e, "ENMevaluation")) {
  stop("Input is not an ENMevaluation object.")
}

part <- as.data.frame(ENMeval::eval.results.partitions(e))
summary_tab <- as.data.frame(ENMeval::eval.results(e))
cat("\nColumns in fold-level results:\n")
print(names(part))
cat("\nENMeval settings:\n")
settings <- ENMeval::eval.other.settings(e)
print(settings[c("abs.auc.diff", "validation.bg")])

needed_part <- c("tune.args", "fold", "auc.val", "auc.diff")
if (!all(needed_part %in% names(part))) {
  stop("Fold table missing expected columns: ",
       paste(setdiff(needed_part, names(part)), collapse = ", "))
}
needed_sum <- c("tune.args", "auc.train", "auc.val.avg", "auc.diff.avg")
if (!all(needed_sum %in% names(summary_tab))) {
  stop("Summary table missing expected columns.")
}
selected_name <- "fc.LQHP_rm.1"
fold_selected <- part[as.character(part$tune.args) == selected_name, ,
                      drop = FALSE]
sum_selected <- summary_tab[
  as.character(summary_tab$tune.args) == selected_name, , drop = FALSE
]
if (nrow(fold_selected) != 4L) {
  stop("Expected four validation folds; found ", nrow(fold_selected))
}
if (nrow(sum_selected) != 1L) {
  stop("Expected exactly one summary row for ", selected_name)
}
if (anyNA(fold_selected$auc.diff) || anyNA(fold_selected$auc.val)) {
  stop("Fold-level AUC results contain NA.")
}
fold_selected <- fold_selected[order(fold_selected$fold), , drop = FALSE]

auc_val_mean <- mean(fold_selected$auc.val)
auc_diff_mean <- mean(fold_selected$auc.diff)
reported_auc_val <- sum_selected$auc.val.avg[[1]]
reported_auc_diff <- sum_selected$auc.diff.avg[[1]]
reported_auc_full <- sum_selected$auc.train[[1]]
tolerance <- 1e-6

cat("\n========================================\n")
cat("FOUR VALIDATION FOLDS: LQHP / RM = 1\n")
cat("========================================\n")
print(fold_selected[, needed_part], row.names = FALSE, digits = 10)
cat(sprintf("\nmean(fold auc.val)       = %.10f\n", auc_val_mean))
cat(sprintf("reported auc.val.avg     = %.10f\n", reported_auc_val))
cat(sprintf("mean(fold auc.diff)      = %.10f\n", auc_diff_mean))
cat(sprintf("reported auc.diff.avg    = %.10f\n", reported_auc_diff))
cat(sprintf("full-data auc.train      = %.10f\n", reported_auc_full))
cat(sprintf("full-data AUC - mean val = %.10f\n",
            reported_auc_full - reported_auc_val))
cat(sprintf("validation mean matches  = %s\n",
            abs(auc_val_mean - reported_auc_val) < tolerance))
cat(sprintf("AUC diff mean matches    = %s\n",
            abs(auc_diff_mean - reported_auc_diff) < tolerance))

stopifnot(abs(auc_val_mean - reported_auc_val) < tolerance)
stopifnot(abs(auc_diff_mean - reported_auc_diff) < tolerance)

outfile <- file.path(outdir, "ENMeval_LQHP_RM1_auc_folds_VERIFIED.csv")
write.csv(fold_selected, outfile, row.names = FALSE)
cat("\nFold audit PASSED. CSV saved to: ", outfile, "\n", sep = "")

cat("\nOriginal Wallace fold-level exports (if present):\n")
wallace_dir <- file.path(repo, "wallace")
if (dir.exists(wallace_dir)) {
  print(list.files(wallace_dir, recursive = TRUE, full.names = FALSE,
                   pattern = "\\.(rds|csv)$", ignore.case = TRUE))
} else {
  cat("No local Wallace folder found.\n")
}
