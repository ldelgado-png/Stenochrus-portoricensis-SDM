# Diagnostic 25 — common-background spatial-fold validation (9 October 2026)

**User-reported completed R run.** Model structure fixed to LQHP/RM1, three training backgrounds, 171 presence records, four original ENMeval spatial block folds (`lat_lon`), six WorldClim 2.1 predictors, and 9,987 evaluation-background cells sampled independently of all presence and training-background cells (seed 20261008). Direct `maxnet` fold-specific fits, `cloglog` predictions, rank-based AUC and 10th-percentile training-presence omission.

| Treatment | Mean common-background AUC | Mean 10TP omission | Δ AUC vs uniform |
|---|---:|---:|---:|
| Uniform original | **0.7417520** | 0.1104651 | 0 |
| Arachnida floor 0.10 | 0.7077332 | 0.1104651 | **−0.03401889** |
| Arachnida floor 0.20 | 0.7116284 | 0.1104651 | **−0.03012365** |

The weighted treatments exhibited **lower**, not higher, mean fold AUC than the uniform baseline when all three were evaluated against the same independent set of background cells. The former slightly higher native ENMeval validation AUCs for weighted treatments used treatment-dependent evaluation backgrounds and should not be treated as predictive superiority. Fold-wise omission averages were equal. This is a **shared-background, spatially partitioned, internal validation**, not a truly external test dataset; hyperparameters were previously selected using the occurrence dataset. No confidence interval or hypothesis test is claimed from the four folds. The evaluation background was sampled uniformly from eligible cells rather than effort-weighted; consequently the results characterize discrimination with respect to that common uniform reference, not necessarily a sampling-process-matched deployment objective.

**New information after the received RAR:** The earlier uploaded archive `sampling_bias.rar` contains `common_background_spatial_validation/background_common_validation.csv` and eight fitted fold RDS files (four uniform, four Arachnida floor 0.10), but **does not contain** the four Arachnida floor 0.20 fold RDS files or the final `validation_by_fold.csv`, `validation_summary.csv`, `paired_auc_differences.csv` and `sessionInfo.txt` generated after the archive snapshot. Those final outputs should be transferred from the local project for an exact independently audited reproduction.

**Source:** user R-console output, Oct 9 2026; see [full background-sensitivity results](sampling_bias_results_2026-10-08.md).

## Pendientes

- [PENDIENTE] Subir los archivos generados al final del diagnóstico 25 (CSV de validación por pliegue, resumen, diferencias pareadas, `sessionInfo.txt` y cuatro RDS de Arachnida_floor20).
- [PENDIENTE] Verificar la evaluación por cada pliegue y la comparabilidad de los modelos ajustados directamente con maxnet y ENMeval.
- [PENDIENTE] Evaluar replicación del fondo común y el alcance de la evaluación sobre fondo uniforme, evitando presentar sus AUC como validación externa o corrección confirmada del sesgo.
