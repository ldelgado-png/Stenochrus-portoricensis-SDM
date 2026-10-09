# Our four-fold AUC audit — ENMeval and Wallace (LQHP/RM1)

## ENMeval audit

We recovered the original `ENMevaluation` object on 8 October 2026 from our local project at `data/ENMeval_Stenochrus_M200_SWD.rds`. We used `ENMeval::eval.results.partitions()` and `ENMeval::eval.results()` to inspect model `fc.LQHP_rm.1` and verify its four fold-level AUC summaries.

| Fold | auc.val | auc.diff |
|---:|---:|---:|
| 1 | 0.6734553461 | 0.20280467703 |
| 2 | 0.7476871806 | 0.11321366246 |
| 3 | 0.8132938936 | 0.03556824039 |
| 4 | 0.7315848214 | 0.09258864166 |

We reproduced mean `auc.val.avg = 0.7415053` and mean `auc.diff.avg = 0.1110438`. We successfully executed the R `stopifnot(..., isTRUE(all.equal(...)))` checks, which printed **VERIFICACIÓN SUPERADA**. The saved settings were `abs.auc.diff = TRUE` and `validation.bg = "partition"`.

We emphasize that `auc.diff.avg` is the **mean of fold-specific training–validation AUC differences**, not the subtraction of model-wide `auc.train` and mean validation AUC. We transcribed the original console values to [our ENMeval fold table](../results/model_selection/ENMeval_LQHP_RM1_auc_folds_verified_console.csv); displayed precision is limited by the original console printout. We provide [R/14_auc_fold_audit.R](../R/14_auc_fold_audit.R) as our reproducibility script. We did not refit ENMeval models during this numerical audit.

## Wallace audit

We also recovered the original Wallace **RunB** fold-export table from `data/Wallace/RunB/Wallace_RunB_groups_RM_1_2_3_4.csv.csv` and the selected-model summary from `data/Wallace/Final/Wallace_modelo_seleccionado_LQHP_RM1.csv`. We extracted the four `fc.LQHP_rm.1` folds and checked their AUC values.

| Fold | auc.val | auc.diff |
|---:|---:|---:|
| 1 | 0.696025467650 | 0.1849423816014 |
| 2 | 0.842931582549 | 0.0726510167412 |
| 3 | 0.765289582414 | 0.1027704193439 |
| 4 | 0.874017301237 | 0.0517225781282 |

We recovered mean validation AUC **0.7945659834625**, agreeing with the original `auc.val.avg = 0.794565983462471`, and mean fold-specific AUC difference **0.103021598953675**, agreeing with `auc.diff.avg = 0.103021598953662`. Our `all.equal(..., tolerance = 1e-6)` tests passed, yielding **VERIFICACIÓN WALLACE SUPERADA**. We distinguish these fold means from the full-data `auc.train = 0.8489026`.

We transcribed these results into the [Wallace four-fold CSV](../results/model_selection/Wallace_LQHP_RM1_auc_folds_verified_console.csv) and provide [R/15_wallace_auc_fold_audit.R](../R/15_wallace_auc_fold_audit.R) for numerical reproducibility. The original Wallace export files remain in our local project.

## Interpretation

We verified the arithmetic of both workflows independently. We do **not** infer from agreement in selected LQHP/RM1 that the workflows used identical spatial partitions, background realizations or likelihood normalizations. We therefore report their AICc values separately rather than comparing their absolute magnitudes across workflows. This numerical consistency is not an independent external validation of the model.
