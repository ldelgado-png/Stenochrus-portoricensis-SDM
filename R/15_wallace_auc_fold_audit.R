# R/15_wallace_auc_fold_audit.R ---------------------------------------------
# Recheck Wallace RunB's original 4-fold AUC summary for LQHP / RM = 1.
# Does not fit, update, or modify models; uses original locally exported CSVs.
repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"

wallace_dir <- file.path(repo, "data", "Wallace")
folds_path <- list.files(
  wallace_dir,
  pattern = "^Wallace_RunB_groups_RM_1_2_3_4\\.csv\\.csv$",
  recursive = TRUE, full.names = TRUE
)
stopifnot(length(folds_path) == 1L)

summary_path <- file.path(
  wallace_dir, "Final", "Wallace_modelo_seleccionado_LQHP_RM1.csv"
)
stopifnot(file.exists(summary_path))

folds <- read.csv(folds_path)
selected <- read.csv(summary_path)
name <- "fc.LQHP_rm.1"

f <- folds[folds$tune.args == name, , drop = FALSE]
s <- selected[selected$tune.args == name, , drop = FALSE]
stopifnot(nrow(f) == 4L, nrow(s) == 1L)
stopifnot(
  all(c("fold", "auc.val", "auc.diff") %in% names(f)),
  all(c("auc.val.avg", "auc.diff.avg", "auc.train") %in% names(s))
)

f <- f[order(f$fold), , drop = FALSE]
stopifnot(identical(as.integer(f$fold), 1:4))
stopifnot(!anyNA(f[, c("auc.val", "auc.diff")]))

cat("\nWallace LQHP / RM=1: original RunB fold data\n")
print(f[, c("fold", "auc.val", "auc.diff")], row.names = FALSE, digits = 12)

means <- c(auc.val.avg = mean(f$auc.val), auc.diff.avg = mean(f$auc.diff))
reported <- c(auc.val.avg = s$auc.val.avg, auc.diff.avg = s$auc.diff.avg)

cat("\nComputed means:\n")
print(means, digits = 15)
cat("Reported means:\n")
print(reported, digits = 15)
cat("Full-data training AUC:", s$auc.train, "\n")

stopifnot(
  isTRUE(all.equal(unname(means["auc.val.avg"]),
                   unname(reported["auc.val.avg"]), tolerance = 1e-6)),
  isTRUE(all.equal(unname(means["auc.diff.avg"]),
                   unname(reported["auc.diff.avg"]), tolerance = 1e-6))
)
cat("\nVERIFICACIÓN WALLACE SUPERADA\n")

out_path <- file.path(
  wallace_dir, "Final", "Wallace_LQHP_RM1_auc_folds_verificados.csv"
)
write.csv(f, out_path, row.names = FALSE)
cat("Verified fold CSV saved to: ", out_path, "\n", sep = "")
