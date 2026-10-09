# Our ecological niche modelling workflow

We developed and documented the following workflow for estimating climatic suitability of *Stenochrus portoricensis* in Colombia. We report the analyses implemented in the project here; the manuscript in Google Drive is our working record for internal project coordination.

## Occurrence processing and calibration

We retrieved georeferenced GBIF records, restricted the study to the Americas, screened geographic validity, excluded records with unsupported georeferences and reduced exact coordinate duplicates. We defined candidate calibration regions using geodesic buffers and selected **M200** as our primary accessible-area hypothesis. We aligned WorldClim 2.1 predictors at 2.5 arc-min resolution, retained one presence per environmental grid cell and selected **BIO1, BIO2, BIO4, BIO12, BIO14 and BIO15**. Our final calibration comprised **171 presences** and **9,987 original uniform-background cells**.

## Model tuning, evaluation and transfer

We evaluated **40 Maxnet parameterizations** through ENMeval with four spatial `block` partitions and selected **LQHP/RM1** within the original uniform-background candidate set. We replicated configuration selection using Wallace, generated conditional response curves, quantified permutation importance and projected the selected model to Colombia. We also assessed strict univariate environmental extrapolation and multivariate MOP dissimilarity.

We transferred our original uniform-background model to 16 future CMIP6 GCM–SSP–period combinations, summarized agreement among four climate models and described suitable-area persistence, loss, gain and elevational redistribution. We distinguish projected climatic suitability from realised occurrence and geographic dispersal.

## Sampling-effort sensitivity

We retrieved and aligned three GBIF-derived effort rasters from El-Gabbas (2026), characterized sampling coverage and audited the original occurrence-year distribution. We compared five-seed background draws using Schizomida and Arachnida effort, then selected two Arachnida-weighted sensitivity backgrounds with floor fractions **0.10** and **0.20** and seed 125. We fitted **40 additional Maxnet candidates per alternative**, retaining the original uniform model, and compared Colombian suitability under the same projection climate raster.

We obtained the same selected configuration (**LQHP/RM1**) under all three treatments, highly concordant continuous suitability predictions and threshold-sensitive differences in mapped suitable area. We subsequently refitted LQHP/RM1 models for four spatial folds under one common uniformly sampled evaluation background (diagnostic 25). In that comparison, mean AUC was **0.7417520** for the uniform model versus **0.7077332** and **0.7116284** for Arachnida floors 0.10 and 0.20. We do not interpret these differences as evidence of universal predictive superiority.

We describe the model design, source files, quantitative results and limitations in [sampling-bias methodology](sampling_bias_elgabbas.md), [results from diagnostics 18–25](sampling_bias_results_2026-10-08.md) and [diagnostic 25](common_background_validation_2026-10-09.md). We provide original source files and reproducibility products under [results/sampling_bias](../results/sampling_bias/).
