# Four-fold AUC audit — selected ENMeval model (LQHP / RM = 1)

## Status: numerically verified from the original R object

On 2026-10-08, the author loaded the original `ENMevaluation` object from their local project at:

`data/ENMeval_Stenochrus_M200_SWD.rds`

The object was queried using `ENMeval::eval.results.partitions(enm)` and `ENMeval::eval.results(enm)` with tuning argument `fc.LQHP_rm.1`. The source object is stored locally and is **not** archived in this GitHub repository.

## Per-fold values

| Fold | auc.val | auc.diff |
|---:|---:|---:|
| 1 | 0.6734553461 | 0.20280467703 |
| 2 | 0.7476871806 | 0.11321366246 |
| 3 | 0.8132938936 | 0.03556824039 |
| 4 | 0.7315848214 | 0.09258864166 |

- `mean(auc.val)` = **0.7415053**, matching the published `auc.val.avg` = **0.7415053**.
- `mean(auc.diff)` = **0.1110438**, matching the published `auc.diff.avg` = **0.1110438**.
- The author executed `stopifnot(nrow(f) == 4, isTRUE(all.equal(mean(f$auc.val), s$auc.val.avg)), isTRUE(all.equal(mean(f$auc.diff), s$auc.diff.avg)))` successfully; R printed **VERIFICACIÓN SUPERADA**.
- Original object settings: `abs.auc.diff = TRUE`, `validation.bg = "partition"`.

This confirms that `auc.diff.avg` is a fold-level summary and **not** the full-data `auc.train` minus the mean fold-validation AUC.

The machine-readable table is [ENMeval_LQHP_RM1_auc_folds_verified_console.csv](../results/model_selection/ENMeval_LQHP_RM1_auc_folds_verified_console.csv). Values in the published CSV were **transcribed from the author's R-console output printed with `digits = 10`**; they therefore have limited displayed precision compared with the stored binary object, but agree with the reported means within the printed precision. To regenerate full-precision CSVs from the original local `.rds`, execute [R/14_auc_fold_audit.R](../R/14_auc_fold_audit.R). No ENMeval recalibration was performed for this audit.

## Wallace — separate remaining validation

The corresponding Wallace result is `auc.diff.avg = 0.103021598953662`, with `auc.val.avg = 0.794565983462471`. Unlike ENMeval, the Wallace per-fold results have **not yet been independently recovered**; do not claim their numerical aggregation has been verified.

Potential source sessions to inspect locally:

- `data/Wallace/RunA/Wallace_RunA_session.rds`
- `data/Wallace/RunB/Wallace_RunB_session.rds`

Confirm `mean(auc.diff)` and `mean(auc.val)` for four Wallace folds before closing that audit. The full-data AUC should not be used in place of a fold-specific training AUC in either workflow.
