# Analytical scope and ancillary diagnostics

The manuscript evaluates current and future climatic suitability for *Stenochrus portoricensis* in Colombia using American occurrence data. Its main questions concern changes in suitable area, the elevational distribution of loss, persistence and gain, and environmental novelty during projection. Present-day background sensitivity is a complementary check of the reference map used to estimate future change.

The primary calibration is the direct ENMeval/maxnet workflow with a uniform background. Future projections reported in the manuscript use that calibration. The Arachnida-weighted comparisons concern present-day predictions only.

## Main analysis and figure resources

| Question or output | Deposited resources |
| --- | --- |
| Selected reference model and spatial validation | [Selected-model table](../results/model_selection/ENMeval_modelo_seleccionado_LQHP_RM1.csv); [40-candidate evaluation](../results/model_selection/ENMeval_resultados_M200.csv) |
| Current suitability; manuscript Figure 2 | [Current Colombian suitability map](../figures/colombia/Stenochrus_Colombia_LQHP_RM1_FINAL_400dpi_fixed.png) |
| Future extent and loss/persistence/gain | [All individual projections](../results/future/Future_scenarios_all_models.csv); [SSP–period agreement summaries](../results/future/Consensus_future_summary.csv) |
| Future suitability and NAC agreement; manuscript Figure 3 | [Combined future map](../figures/colombia/Figure_future_NAC_suitability_consensus.png); [NAC agreement table](../results/extrapolation/NAC_consensus_summary.csv) |
| Elevational distribution; manuscript Figure 4 | [Elevation analysis](elevational_redistribution.md); [tables](../results/altitude/); [figure](../figures/altitude/Figure_altitudinal_redistribution_FINAL.png) |
| Environmental novelty | [Full-M200 univariate ranges check](../results/extrapolation/Univariate_extrapolation_Colombia_vs_M200.csv); [16 future MOP assessments](../results/extrapolation/MOP_future_all_16_scenarios.csv) |
| Complementary present-day background comparison | [Detailed results](sampling_bias_results_2026-10-08.md); [shared-background validation](common_background_validation_2026-10-09.md) |

The resource labels above follow the condensed manuscript figure sequence. Earlier records in this repository may retain the original figure numbers. Model outputs and numerical analyses have not been recalculated by this editorial separation.

## Ancillary resources

| Diagnostic | Location and purpose |
| --- | --- |
| Effort coverage, date overlap and eligible cells | [Experimental design and provenance](sampling_bias_elgabbas.md); [coverage table](../results/sampling_bias/effort_coverage_diagnostics_console_2026-10-08.csv); [eligibility](../results/sampling_bias/effort_background_feasibility_console_2026-10-08.csv); [date audit](../results/sampling_bias/occurrence_years_console_2026-10-08.csv) |
| Repeated background draws and floor/concentration diagnostics | [Five-seed draws](../results/sampling_bias/background_draw_feasibility_seeds_console_2026-10-08.csv); [Arachnida floor diagnostics](../results/sampling_bias/arachnida_floor_diagnostics_console_2026-10-08.csv) |
| Model-specific thresholds, continuous differences and spatial overlap | [Three-background comparison](../results/sampling_bias/colombia_background_comparison_console_2026-10-08.csv); [full results and interpretation](sampling_bias_results_2026-10-08.md) |
| Common-background fold validation | [Design, results and limitations](common_background_validation_2026-10-09.md); [summary table](../results/sampling_bias/common_background_validation_console_2026-10-08.csv) |
| AUC aggregation and workflow replication | [ENMeval/Wallace AUC audit](auc_fold_audit.md); [model tables](../results/model_selection/); [Wallace exports](../wallace/) |
| Conditional responses and permutation importance | [R implementation](../R/06_response_curves_importance.R); [importance table](../results/variable_importance/Permutation_importance_LQHP_RM1.csv); [response-curve figure](../figures/response_curves/response_curves_lqhp_rm1.png) |
| Additional present-day MOP visualization | [Mapping script](../R/10_maps.R); [deposited MOP image](../figures/mop/mop_dissimilarity_colombia.png) |

The following sections preserve the detailed diagnostic descriptions and numerical results available for inspection alongside the deposited tables.

## Sampling-effort coverage and temporal overlap

Across 136,111 valid M200 environmental cells, positive GBIF sampling effort occurred in 206 Schizomida n_obs cells (0.151%), 21,711 Arachnida n_obs cells (15.951%) and 160 Schizomida n_sp cells (0.118%). Positive-effort cells coincided with 113, 159 and 112 of the 171 calibration presences, respectively. Excluding all presence cells left 135,940 eligible background cells, including only 93 with Schizomida n_obs > 0, 21,552 with Arachnida n_obs > 0 and 48 with Schizomida n_sp > 0. The original uniform background intersected three Schizomida-positive and 1,499 Arachnida-positive cells. With 9,987 unique background cells sampled without replacement, the Schizomida-positive fraction could not exceed 93/9,987. In five draws (seeds 123–127), Schizomida weighting selected all 93 positive cells with a 0.01 floor and 75–83 with a 0.05 floor; Arachnida weighting with a 0.01 floor selected 9,347–9,410 positive cells. Of the 171 calibration records, 136 were dated 1980–2025, 27 predated 1980, four were dated 2026 and four lacked a usable collection year. These observed differences in coverage and date range informed our interpretation of the effort-weighting experiments.

The Schizomida and Arachnida layers are separate taxon-stratified products. Their counts describe retained GBIF observations, not detection probabilities or ecological absences. Sparse positive Schizomida coverage and the mismatch between occurrence dates and the 1980–2025 effort interval limit their interpretation as focal-species effort proxies.

## Background realization and sampling concentration

The two selected Arachnida-weighted backgrounds (floor fractions 0.10 and 0.20; seed 125) each contained 9,987 distinct cells, as did the uniform baseline. Positive Arachnida effort occurred in 65.89% and 52.85% of the weighted cells, respectively. Their effective numbers of occupied 1° blocks were 189.5 and 223.5, compared with 278.6 under uniform sampling. Across five seeds, the corresponding means were 190.10 and 221.74 blocks. Within each background treatment, the minimum-AICc Maxnet configuration was LQHP/RM1. The native spatial-fold validation AUCs were 0.741505 (uniform), 0.751960 (floor 0.10) and 0.745547 (floor 0.20), with 31, 28 and 27 nonzero coefficients. Because the validation backgrounds differed, those AUCs do not provide a controlled ranking of predictive performance.

The weights were defined as:

```r
w <- log1p(n_obs)
epsilon <- floor_fraction * median(w[w > 0])
weights <- w + epsilon
```

The 0.10 and 0.20 floors define distinct sensitivity contrasts, with the larger floor assigning more relative weight to zero-count cells. They were retained after the documented feasibility and concentration checks; they are not estimated optimal correction parameters. The selected models use seed 125. The five-seed feasibility exercise evaluates draw composition and does not constitute repeated fitted-model validation.

## Detailed present-day prediction and threshold comparison

Using each full-data model's own 10TP threshold (uniform 0.21236; Arachnida 0.10, 0.19989; Arachnida 0.20, 0.18610), we classified 379,223.5, 422,979.4 and 445,692.1 km² of Colombia as suitable, respectively. The weighted estimates were 11.54% and 17.53% larger than the uniform estimate. Continuous suitability remained strongly rank-correlated with the uniform model (Spearman 0.9620 and 0.9757), with mean absolute cloglog differences of 0.03734 and 0.03044. Compared with the uniform 10TP map, the two weighted maps gained 61,573.03 and 72,626.38 km² and lost 17,817.13 and 6,157.83 km²; Jaccard overlap was 0.8199 and 0.8256. Using the uniform model's numerical threshold in all maps reduced the weighted suitable areas to 393,140.2 and 392,286.4 km² (+3.67% and +3.44%). We therefore distinguish changes in continuous predictions from changes due to model-specific thresholds.

Changing a numerical threshold across fitted models is a scale diagnostic. Equal cloglog values from models with different backgrounds need not have equal calibration.

## Common-background validation

For a controlled internal comparison of training backgrounds, we refitted the parameterization selected in the uniform analysis within the same four spatial folds for all three treatments. We drew one common uniform evaluation background, equal in size to the reference training background, excluding all presence and training-background cells. We fitted 12 fold-specific models and calculated rank-based AUC against the same held-out presence and evaluation-background folds, with omission assessed against each fold's training-presence 10TP. The comparison used one shared evaluation-background realization. Alternative backgrounds were not projected to future climates.

Mean held-out AUC on the common evaluation background was 0.7417520 for uniform training, 0.7116284 for Arachnida floor 0.20 and 0.7077332 for floor 0.10. Mean paired AUC differences relative to uniform were −0.03012365 and −0.03401889, respectively; mean 10TP omission was identical across treatments (0.1104651).

This is internal spatial validation under one common uniform evaluation distribution, rather than an independent external test. The comparison does not establish universal superiority of uniform training. See the [complete validation report](common_background_validation_2026-10-09.md) for sampling seed and provenance.

## Predictor importance and conditional responses

We examined conditional response curves by varying one predictor across its presence-data range while holding the others at their presence-data medians. Permutation importance was calculated from mean training-AUC loss over 50 permutations per predictor and normalized to sum to 100%.

BIO14 (precipitation of the driest month) had the highest permutation importance (31.84%), followed by BIO1 (18.68%), BIO2 (18.18%), BIO4 (16.03%), BIO15 (8.59%), and BIO12 (6.68%). Conditional response curves indicated highest suitability near 24.5–25 °C for BIO1 within the well-supported range of the occurrence data, whereas suitability increased strongly across approximately 10–60 mm for BIO14. BIO12 showed lower suitability toward very high annual precipitation. Responses to BIO2 and BIO4 were more complex, particularly toward environmentally sparse extremes, and were therefore interpreted cautiously.

These are conditional model diagnostics, not physiological limits or a test of why the six predictors were originally selected. Their interpretation depends on the other variables being held at their specified values and on environmental coverage.

## Additional MOP visualization

The distance calculation compares Colombian climates with the sampled uniform-background environments from M200. The [mapping script](../R/10_maps.R) calculates the 95th percentile from the finite values of the Colombian distance raster and overlays cells at or above it. This highlights approximately the upper 5% of dissimilarity values, including possible ties, while preserving the continuous gradient. The cutoff is descriptive and does not define suitable climate, strict non-analog conditions, confidence or statistical significance.

The [older current-MOP summary CSV](../results/extrapolation/MOP_Colombia_vs_M200_summary.csv) is an archived run with a different valid-cell count from the standardized current–future assessment reported in the manuscript. Its numerical percentile and NAC count should not be substituted into the standardized assessment. The displayed map, percentile and mask must be matched when preparing final figures.

## Candidate-model tables and numerical audits

The full [ENMeval candidate table](../results/model_selection/ENMeval_resultados_M200.csv) and [selected-model table](../results/model_selection/ENMeval_modelo_seleccionado_LQHP_RM1.csv) retain training AUC, AICc, weights, coefficient counts and other evaluation fields. The [AUC audit](auc_fold_audit.md) documents fold-level aggregation.

Wallace is retained as an ancillary workflow replication with separately sampled backgrounds. It is not a second primary calibration, an external validation set, or a controlled basis for comparing absolute AICc values between the two workflows.

## Provenance

The linked diagnostic reports distinguish R-console-derived summary CSVs from the original deposited RDS and raster products. [Original supplied outputs](../results/sampling_bias/original_outputs_2026-10-08/) and their [checksum manifest](../results/sampling_bias/manifest_sampling_bias_originales_2026-10-08.sha256) are preserved. This guide indexes deposited material and records the ancillary descriptions; it does not imply that every original local input or later proposed analysis has been deposited or executed.
