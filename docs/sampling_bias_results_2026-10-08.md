# Sampling-effort sensitivity: our results from 8–9 October 2026

**Taxon:** *Stenochrus portoricensis* (Schizomida: Hubbardiidae). **Calibration:** Americas, M200, 171 unique occurrence cells, six WorldClim 2.1 variables (BIO1, BIO2, BIO4, BIO12, BIO14, BIO15), 9,987 unique background cells per treatment. **Software:** R 4.6.1, terra 1.9.46, ENMeval 2.0.5.2, maxnet 0.1.4. **Effort source:** El-Gabbas (2026), cumulative GBIF 1980–2025 sampling-effort products at 2.5 arc-min (approx. 5 km near the equator), doi:10.1111/ddi.70205.

> **Provenance:** We transcribed the quantitative results from our R-console outputs (diagnostics 18–25, 8–9 October 2026) and archived the supplied original RDS, CSV, and GeoTIFF outputs in [`results/sampling_bias/original_outputs_2026-10-08/`](../results/sampling_bias/original_outputs_2026-10-08/). The supplied RAR was created before the final diagnostic-25 exports. We distinguish R-console-derived numerical reporting from our archived original data products.

## 1. Eligible calibration cells and effort coverage

We confirmed that the three source rasters aligned geometrically (1,525 × 1,777 cells, WGS84 EPSG:4326; 0.04166667°). Within the 136,111 environmentally valid M200 cells, counts of positive-effort cells were 21,711 for `Arachnida_nobs`, 206 for `Schizomida_nobs`, and 160 for `Schizomida_nsp`. After excluding 171 focal presence cells, we retained 135,940 candidate background cells; their corresponding positive-effort counts were **21,552 (15.854%)**, **93 (0.0684%)**, and **48 (0.0353%)**. We observed positive effort in the original uniform background in 1,499 Arachnida cells and only three Schizomida cells.

Because our sample of 9,987 *distinct* cells without replacement could capture at most 93 eligible Schizomida-positive cells, we treat Schizomida-weighted backgrounds as **exploratory** rather than an established bias correction. We also recognise that the published Arachnida surface may include focal-species observations, so we cannot assume taxonomic independence; we distinguish this broader proxy from an independent non-focal target-group background.

In our original dated-occurrence audit, we recovered 167 usable collection years among the 171 effective presences: 27 before 1980, 136 in 1980–2025, four in 2026 and four without a usable year (97 dated 2010–2025). We acknowledge this temporal mismatch with the effort rasters as a limitation. We report these categories for the 171 original records, not as a separate temporal refit.

## 2. Background selection and sampling intensity

We defined sampling weights as `log1p(n_obs) + floor_fraction * median(log1p(n_obs)[n_obs > 0])`; each sample contains 9,987 unique environmentally valid cells and excludes all focal presence cells. Schizomida sampling with a 1% floor selected all 93 eligible positive cells in each of five seeds; with a 5% floor, 75–83 positive cells. Arachnida with a 1% floor selected 9,347–9,410 positive cells in five seeds.

We assessed spatial concentration as the inverse Simpson effective count over 1° blocks, plus the percentage of sampled points in the ten highest-count blocks; environmental shifts are means in units of baseline (uniform-background) SD.

| Treatment | Seed / summary | Arachnida-positive BG | Effective 1° blocks | Top ten blocks | BIO4 shift (SD) |
|---|---|---:|---:|---:|---:|
| Uniform original | existing baseline | 15.01% | 278.6 | 5.59% | 0.000 |
| Schizomida floor 0.01 | selected background | 17.09% | 280.6 | 5.33% | +0.040 |
| Schizomida floor 0.05 | selected background | 16.74% | 277.6 | 5.49% | +0.037 |
| Arachnida floor 0.01 | selected background | 94.01% | 133.5 | 17.44% | +0.482 |
| Arachnida floor 0.05 | five-seed mean (123–127) | 77.650% | 161.94 | 15.240% | +0.4026 |
| Arachnida floor 0.10 | five-seed mean (123–127) | 65.884% | 190.10 | 13.146% | +0.3386 |
| Arachnida floor 0.20 | five-seed mean (123–127) | 52.670% | 221.74 | 10.992% | +0.2686 |

We selected alternative backgrounds **Arachnida floor 0.10** and **Arachnida floor 0.20**, using seed **125**, giving 9,987 unique cells each. Exact seed-125 diagnostics: 0.10, 65.89% positive, 189.5 effective blocks, top-ten 13.03%; 0.20, 52.85% positive, 223.5 effective blocks, top-ten 10.82%. We treated the 0.20 floor as our principal *descriptive sensitivity* scenario because it reduced spatial concentration; we do not present it as the statistically optimal sampling-bias correction.

## 3. Model fitting: 40 candidates per scenario

We retained our original uniform ENMeval object and fitted 40 new Maxnet candidate configurations for each of the Arachnida floors 0.10 and 0.20 (**80 new fits; 120 candidates considered including the original 40**). Presences (171), six predictors, block orientation `lat_lon`, validation background mode `partition`, FC grid L/LQ/H/LQH/LQHP, and RM grid 0.5–4 in 0.5 steps were held consistent. We verified that the occurrence fold labels matched the original.

| Background | Best FC | RM | AICc within run | Mean validation AUC | Mean absolute fold AUC difference | Mean 10% omission | Non-zero coefficients |
|---|---|---:|---:|---:|---:|---:|---:|
| Uniform original | LQHP | 1 | 2912.104 | 0.7415053 | 0.1110438 | 0.1046512 | 31 |
| Arachnida floor 0.10 | LQHP | 1 | 2882.623 | 0.7519602 | 0.1124150 | 0.1104651 | 28 |
| Arachnida floor 0.20 | LQHP | 1 | 2894.033 | 0.7455467 | 0.1130777 | 0.1104651 | 27 |

**We selected LQHP/RM1 in all three treatments.** We use AICc to rank candidates **within each background treatment only**, not to compare AICc across treatments. We also note that these native validation AUCs use different background samples and therefore do not establish predictive superiority.

## 4. Present-day projection to Colombia

We projected the three selected full-data models with cloglog output to the same six-variable WorldClim 2.1 Colombian grid (483 rows × 360 columns, WGS84, 2.5 arc-min). We computed each model's 10th-percentile training-presence (10TP) threshold from the **171 calibration presences**, not only the Colombian subset. We measured areas using latitude-adjusted cell sizes in km².

| Background | Own 10TP | Suitable km² (own threshold) | Change vs uniform | Spearman vs uniform | Mean absolute cloglog difference | Suitable km² with uniform numerical threshold 0.21236 |
|---|---:|---:|---:|---:|---:|---:|
| Uniform original | 0.21236 | 379,223.5 | reference | 1.0000 | 0.00000 | 379,223.5 |
| Arachnida floor 0.10 | 0.19989 | 422,979.4 | +11.54% | 0.9620 | 0.03734 | 393,140.2 |
| Arachnida floor 0.20 | 0.18610 | 445,692.1 | +17.53% | 0.9757 | 0.03044 | 392,286.4 |

We obtained own-threshold gains of +43,755.9 km² for floor 0.10 and +66,468.6 km² for floor 0.20. At the **fixed numerical baseline threshold**, we obtained increases of +3.67% and +3.44% respectively. Because we cannot assume equivalent cloglog calibration across backgrounds, we interpret the shared numerical threshold as a **sensitivity probe**, not a calibrated comparison of occupancy probability.

## 5. Binary overlap at each model's own 10TP

| Alternative | Gain km² | Loss km² | Intersection km² | Jaccard |
|---|---:|---:|---:|---:|
| Arachnida floor 0.10 | 61,573.03 | 17,817.13 | 361,406.4 | 0.8199 |
| Arachnida floor 0.20 | 72,626.38 | 6,157.83 | 373,065.7 | 0.8256 |

We observed strongly concordant suitability rankings, but substantial sensitivity of threshold-defined suitable area to background treatment and the 10TP definition. We interpret this as a descriptive spatial comparison, **not** evidence of spread, colonisation, or corrected ecological accuracy.

## 6. Common-background spatial validation (diagnostic 25)

We completed a four-fold spatial-block comparison with a **single common evaluation background**. Using the original 171 occurrences and spatial-fold assignments, we sampled 9,987 eligible and unique background cells with seed `20261008` after removing the presence and background training cells from all three background treatments. We fitted twelve fold-specific Maxnet models (3 treatments × 4 folds), with the shared LQHP feature class and RM = 1. We evaluated all treatments using the same held-out occurrence and common-background fold, deriving each fold's 10TP omission threshold from its training-presence predictions. We classify the analysis as spatial cross-validation, not independent external testing; we had already selected tuning parameters using the focal dataset.

| Treatment | Mean AUC, shared evaluation BG | Mean omission at 10TP | Mean paired AUC difference vs uniform |
|---|---:|---:|---:|
| Uniform original | **0.7417520** | 0.1104651 | Reference |
| Arachnida floor 0.10 | 0.7077332 | 0.1104651 | **−0.03401889** |
| Arachnida floor 0.20 | 0.7116284 | 0.1104651 | **−0.03012365** |

Unlike the background-dependent mean validation AUCs in diagnostic 22, we observed the highest common-background mean AUC for the **uniform** treatment. We do not infer universal superiority of uniform-background training from the lower AUC of the two weighted treatments, because we evaluated one common-background realization over four spatial folds and did not reconstruct the original observation process. We did not perform a formal significance test or an entirely independent external evaluation. We obtained identical mean 10TP omission rates for all three treatments.

**Source and reproducibility:** We archived the [console-transcribed summary of diagnostic 25](../results/sampling_bias/common_background_validation_console_2026-10-08.csv) and preserved the supplied RAR's original background and model outputs in [original_outputs_2026-10-08](../results/sampling_bias/original_outputs_2026-10-08/). This archive represents an earlier snapshot with eight fold-model objects (four uniform and four Arachnida 0.10); the model-comparison values above come from the completed R console analysis on 9 October.

## Data and archived products

We deposited the supplied original files in [results/sampling_bias/original_outputs_2026-10-08](../results/sampling_bias/original_outputs_2026-10-08/), retaining background CSVs, fitted Maxnet RDS objects, model evaluation tables, effort surfaces and Colombian GeoTIFF projections and change rasters.

**We document associated methodology and scripts in:** [sampling_bias_elgabbas.md](sampling_bias_elgabbas.md), [R/17_sampling_bias_models.R](../R/17_sampling_bias_models.R), [R/18_effort_feasibility_and_dates.R](../R/18_effort_feasibility_and_dates.R) and [R/19_arachnida_bias_pilot.R](../R/19_arachnida_bias_pilot.R). We distinguish those deposited scripts from the interactive RStudio code used for diagnostics 20–25, whose results we document through console transcriptions and original archived outputs.
