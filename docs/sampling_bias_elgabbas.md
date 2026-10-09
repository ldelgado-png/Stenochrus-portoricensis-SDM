# GBIF sampling-effort sensitivity using El-Gabbas (2026)

## Study design and provenance

We investigated how alternative background-sampling schemes affect the Maxnet model of *Stenochrus portoricensis* calibrated from American occurrence records and transferred to Colombia. We used GBIF sampling-effort products published by El-Gabbas (2026), retaining the original uniform M200 background as the reference. We report completed experiments in [our results record](sampling_bias_results_2026-10-08.md) and [common-background validation](common_background_validation_2026-10-09.md).

**Original source:** El-Gabbas A (2026), *Diversity and Distributions* 32: e70205, https://doi.org/10.1111/ddi.70205. We obtained the taxon-stratified effort data using `ecokit::get_sampling_effort()` and the published [OSF archive](https://osf.io/hz4sy). Related resources include the [Zenodo record](https://zenodo.org/records/17591681), [source pipeline](https://github.com/elgabbas/global_sampling_efforts) and [ecokit implementation](https://github.com/elgabbas/ecokit).

We used observation counts (`n_obs`) for Schizomida and Arachnida and recorded-species richness (`n_sp`) for Schizomida as an ancillary coverage indicator. We used the cumulative 1980–2025 period. The nominal 5-km product is supplied on a WGS84/EPSG:4326 grid with 2.5-arc-min angular cells (0.04166667°). We checked raster geometry, alignment and environmental masking against WorldClim 2.1 rather than assuming that identical angular resolution guaranteed matching cell origins. We treated zero-effort cells as cells with no retained GBIF observations, **not** as ecological absences.

## Environmental and occurrence inputs

We kept 171 unique presence cells, a six-variable WorldClim 2.1 SWD predictor set (BIO1, BIO2, BIO4, BIO12, BIO14, BIO15), an accessible calibration region defined by 200-km buffers (M200) and 9,987 distinct background cells per treatment. We fitted Maxnet through ENMeval using four spatial `block` partitions with `validation.bg = "partition"`. We checked that the occurrence fold assignments were unchanged in the alternative-background experiments.

Our baseline evaluation comprised 40 candidate parameterizations: feature classes L, LQ, H, LQH and LQHP with regularization multipliers of 0.5–4 in increments of 0.5. We selected the minimum AICc **within** each background-defined candidate set. We do not treat raw AICc from different sampled backgrounds as an equivalent likelihood comparison.

## Sampling-effort coverage

We observed **136,111** climatically valid M200 raster cells. Positive-effort cells numbered **206** for Schizomida `n_obs` (0.151%), **21,711** for Arachnida `n_obs` (15.951%) and **160** for Schizomida `n_sp` (0.118%). We found positive-effort overlap with **113**, **159** and **112** of the 171 focal presence cells, respectively.

After we excluded all 171 focal presence cells, we retained **135,940** eligible background cells. Of these, **93** were positive for Schizomida `n_obs`, **21,552** for Arachnida `n_obs`, and **48** for Schizomida `n_sp`. The original uniform background contained only **three** Schizomida-positive cells and **1,499** Arachnida-positive cells. Thus, without replacement, a 9,987-cell Schizomida background could capture at most **93 positive-effort eligible cells** (0.931% of the background). We therefore treat the Schizomida-weighted draws as exploratory sensitivity experiments, not a validated taxon-specific bias correction.

We identified a potential circularity concern because the taxon-level Schizomida effort surface may count focal-species records. The broader Arachnida surface may also contain such records, and we cannot assume taxonomic independence of either proxy. We distinguish these observed-count surfaces from a target-group background composed of independently screened **non-focal** Schizomida localities.

## Temporal audit

We recovered usable collection years for **167** of the 171 calibration records, ranging from **1878 to 2026** (median 2011). We classified **27** records before 1980, **136** in the effort layer's 1980–2025 range, **four** in 2026 and **four** with no usable year; **97** records fell in 2010–2025. We retained the original 171-record calibration and explicitly acknowledge the temporal mismatch between the occurrences and 1980–2025 effort surfaces. We do not conflate the 136-record temporal subset with the original calibration.

## Background construction

We weighted eligible cells by

```r
w <- log1p(n_obs)
epsilon <- floor_fraction * median(w[w > 0])
weights <- w + epsilon
```

We sampled **9,987 unique climate cells without replacement**, excluded focal presence cells and recorded sampling seeds. This positive floor preserved the ability to sample cells with no recorded effort; the transformation is a modelling choice and does not estimate biological detection probability.

For Schizomida, our five-seed exploratory analysis selected all **93** positive-effort eligible cells with a floor of 0.01 and **75–83** with a floor of 0.05. For Arachnida, the 0.01 floor selected **9,347–9,410** positive-effort cells across five seeds. We compared additional Arachnida floors of **0.05, 0.10 and 0.20** over seeds 123–127. We selected the **0.10 and 0.20 floors with seed 125** as distinct sensitivity contrasts, and we retained the original uniform background as our primary reference.

Our selected seed-125 backgrounds comprised 9,987 unique cells each. Arachnida-positive proportions were **65.89%** (floor 0.10) and **52.85%** (floor 0.20), with effective numbers of occupied 1° spatial blocks of **189.5** and **223.5**, respectively (uniform **278.6**). We describe the 0.20 floor as a less spatially concentrated sensitivity contrast, not as an optimal correction of sampling bias.

## Model fitting and Colombian transfer

We evaluated **80 additional Maxnet configurations** in the two Arachnida-weighted backgrounds, alongside the original 40, holding the occurrence dataset, predictor variables, fold orientation and tuning grid constant. We selected **LQHP/RM1** in each of the three treatments, and we used the full-data fitted models to project present-day climatic suitability to the same Colombian WorldClim grid with cloglog output and clamping.

We derived an individual 10th-percentile training-presence (10TP) threshold from **all 171** calibration presences for each model. We quantified continuous rank correlation and mean absolute prediction differences and, after binary classification, suitable area, overlap, gain, loss and Jaccard index. We also applied the uniform model's **numerical** cutoff to alternative predictions as a threshold-scale sensitivity analysis, without assuming that different fitted models yield equally calibrated cloglog values.

In [diagnostic 25](common_background_validation_2026-10-09.md), we additionally refitted the common LQHP/RM1 configuration within four held-out occurrence folds using a **shared independent 9,987-cell evaluation background**. We obtained average fold AUC values of **0.7417520** (uniform), **0.7077332** (Arachnida floor 0.10) and **0.7116284** (Arachnida floor 0.20). We interpret this as internal spatial cross-validation under a common uniformly sampled evaluation distribution, not an external independent test. We do not infer universal superiority of the uniform training scheme from this single evaluation-background realization.

## Archived resources

We provide the following sources and data products:

- [Original received RAR outputs, including backgrounds, rasters, RDS models and CSV tables](../results/sampling_bias/original_outputs_2026-10-08/)
- [Coverage results](../results/sampling_bias/effort_coverage_diagnostics_console_2026-10-08.csv) and [eligible-cell feasibility](../results/sampling_bias/effort_background_feasibility_console_2026-10-08.csv)
- [Seed-based feasibility](../results/sampling_bias/background_draw_feasibility_seeds_console_2026-10-08.csv) and [temporal distribution](../results/sampling_bias/occurrence_years_console_2026-10-08.csv)
- [Sampling-intensity and model-comparison summary](sampling_bias_results_2026-10-08.md)
- [Our direct sampling-effort preparation and feasibility scripts](../R/18_effort_feasibility_and_dates.R), [model/background workflow](../R/17_sampling_bias_models.R) and [Arachnida pilot design](../R/19_arachnida_bias_pilot.R)

We identify the origin of each numeric dataset (original exported RStudio files versus console-transcribed CSVs) and do not equate a sampled raster footprint with independently screened target-group observations.
