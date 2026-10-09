# Diagnostic 25 — shared-background spatial validation (9 October 2026)

We assessed the predictive discrimination of three *Stenochrus portoricensis* Maxnet treatments using the **same independent evaluation-background sample** for all treatments. We retained 171 calibration occurrences, six WorldClim 2.1 predictors, the original four spatial-block occurrence folds (`lat_lon`) and a fixed model specification (LQHP, regularization multiplier 1). We drew 9,987 environmentally valid background cells (seed `20261008`) outside all focal occurrence and model-training background cells. We fitted a separate Maxnet model for each treatment and fold (**12 fold-specific fits**) and calculated rank-based AUC against the common background validation fold and omission rates at the 10th-percentile training-presence (10TP) threshold.

## Results

| Training background | Mean AUC with shared evaluation background | Mean 10TP omission | Mean paired ΔAUC versus uniform |
|---|---:|---:|---:|
| Uniform original | **0.7417520** | 0.1104651 | Reference |
| Arachnida floor 0.10 | **0.7077332** | 0.1104651 | **−0.03401889** |
| Arachnida floor 0.20 | **0.7116284** | 0.1104651 | **−0.03012365** |

We obtained the highest mean AUC with the original uniform-background treatment. In contrast, both Arachnida-weighted treatments yielded lower mean AUC against the **common uniformly sampled evaluation background**, despite having shown slightly higher native ENMeval validation AUCs when each treatment used its own validation-background sample. We observed identical mean 10TP omission rates across treatments. Our results demonstrate that apparent between-treatment AUC contrasts are sensitive to the evaluation-background distribution; we do **not** interpret the weighted models as superior on this common reference.

## Interpretation and scope

We regard this procedure as **internal spatial-block cross-validation**, not independent external validation. We used the focal occurrence dataset previously to select hyperparameters, although we refitted models within each fold for this comparison. We evaluated one independent common-background realization over four folds without formal significance testing. Consequently, we interpret the observed AUC differences for the defined uniform evaluation reference, rather than as proof that uniform-background training is universally preferable or that Arachnida-wide effort is an ineffective sampling-bias proxy.

## Provenance and archived material

We reproduced the summary values from the investigator's R-console output for diagnostic 25 and deposited the [console-derived CSV summary](../results/sampling_bias/common_background_validation_console_2026-10-08.csv). We also preserved the supplied archive of original sampling-bias outputs under [original_outputs_2026-10-08](../results/sampling_bias/original_outputs_2026-10-08/), including the independent evaluation-background CSV and eight fold-model objects (four uniform and four Arachnida floor 0.10). The supplied archive is an earlier snapshot and does not include the four Arachnida floor 0.20 fold models or the diagnostic's three final local validation tables; we distinguish that archival scope from the completed numerical analysis.

We report the broader modelling and Colombian projection sensitivity findings in [Sampling-effort sensitivity results](sampling_bias_results_2026-10-08.md).
