# Four-fold AUC audit — ENMeval and Wallace (LQHP / RM = 1)

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

## Wallace — numerically verified against original RunB exports

On 2026-10-08, the author extracted the selected model (`fc.LQHP_rm.1`) from the original local Wallace **RunB** fold-export file:

`data/Wallace/RunB/Wallace_RunB_groups_RM_1_2_3_4.csv.csv`

The four-fold output columns were `tune.args`, `fold`, `auc.val` and `auc.diff` (plus CBI/omission metrics). The matching original summary was read from:

`data/Wallace/Final/Wallace_modelo_seleccionado_LQHP_RM1.csv`

These local source files are not yet deposited in this repository; the values below were transcribed from the author's R console printed with `digits = 12`. The original session `.rds` primarily saved Wallace application settings, not these fold-level evaluation tables.

| Fold | auc.val | auc.diff |
|---:|---:|---:|
| 1 | 0.696025467650 | 0.1849423816014 |
| 2 | 0.842931582549 | 0.0726510167412 |
| 3 | 0.765289582414 | 0.1027704193439 |
| 4 | 0.874017301237 | 0.0517225781282 |

- The mean validation AUC was **0.7945659834625**, matching the original `auc.val.avg = 0.794565983462471` within printed precision.
- The mean fold-specific AUC difference was **0.103021598953675**, matching `auc.diff.avg = 0.103021598953662` within printed precision.
- The author's R check with `stopifnot(... all.equal(..., tolerance = 1e-6))` passed, reporting **VERIFICACIÓN WALLACE SUPERADA**.
- The full-data `auc.train = 0.8489026` is a different statistic and is not used to calculate the fold-mean AUC difference.

The [console-transcribed four-fold CSV](../results/model_selection/Wallace_LQHP_RM1_auc_folds_verified_console.csv) documents the fold values. Re-run [R/15_wallace_auc_fold_audit.R](../R/15_wallace_auc_fold_audit.R) against the original local CSVs to regenerate a full-precision CSV and repeat the checks.

## Interpretation and remaining methodological caveat

**The specific AUC arithmetic discrepancy is fully resolved in both workflows.** Both values (`auc.diff.avg = 0.1110438` for ENMeval and `0.1030216` for Wallace) are verified averages of fold-specific AUC differences, not simple differences between `auc.train` from the full fit and `auc.val.avg`.

This numerical verification does **not** establish that the two pipelines used identical spatial fold assignments, identical random background realizations, identical evaluation conventions, or commensurate AICc likelihood calculations. The two absolute AICc values should not be compared until those separately scoped assumptions have been tested. Model-selection agreement does not constitute independent out-of-sample validation.
