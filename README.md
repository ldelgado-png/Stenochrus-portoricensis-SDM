# Potential distribution of *Stenochrus portoricensis* in Colombia

Reproducible ecological niche modelling / species distribution modelling workflow for *Stenochrus portoricensis* (Schizomida: Hubbardiidae), calibrated with American occurrence records and transferred to Colombia.

## Current status

The repository captures the modelling workflow developed to date:

- American GBIF occurrence quality control and geographic filtering.
- Construction of an operational 200 km calibration area (**M200**).
- WorldClim 2.1 bioclimatic predictors at 2.5 arc-min resolution.
- Environmental-cell filtering of occurrences.
- Maxnet tuning with ENMeval using spatial **block** partitioning.
- Independent replication in Wallace 2.2.1.
- Response curves and permutation-based variable importance.
- Continuous climatic suitability projection to Colombia.
- Univariate extrapolation checks and multivariate MOP analysis.

## Key numbers

| Stage | Result |
|---|---:|
| Georeferenced GBIF records initially retrieved | 398 |
| Records retained in the Americas | 369 |
| CoordinateCleaner summary TRUE / FALSE | 358 / 11 |
| Records excluded for unsupported coordinates | 30 |
| Records retained after QC | 339 |
| Unique exact coordinates | 234 |
| Unique WorldClim cells before final environmental exclusion | 172 |
| Effective presences used for modelling | **171** |
| Valid cells in M200 | 136,111 |
| Background points in direct ENMeval analysis | **9,987** |
| Predictors | **6** |
| Candidate Maxnet configurations | **40** |

The final predictor set is **BIO1, BIO2, BIO4, BIO12, BIO14, BIO15**.

## Selected model

Both the direct ENMeval analysis and the independent Wallace workflow selected the same Maxnet configuration:

**Feature classes = LQHP; regularization multiplier = 1.**

### Direct ENMeval

- AUC train: 0.8443321
- Mean validation AUC: 0.7415053
- Mean AUC difference: 0.1110438
- Mean validation CBI: 0.799
- Mean 10% omission rate: 0.1046512
- AICc: 2912.104
- ΔAICc: 0
- Akaike weight: 0.9595153
- Non-zero coefficients: 31

### Wallace replication

After combining the two Wallace runs and recalculating ΔAICc and Akaike weights across all 40 models:

- AUC train: 0.8489026
- Mean validation AUC: 0.7945660
- Mean AUC difference: 0.1030216
- Mean validation CBI: 0.6865
- Mean 10% omission rate: 0.09302326
- AICc: 3768.617
- ΔAICc: 0
- Akaike weight: 0.9934626
- Non-zero coefficients: 32

Absolute AICc values should not be compared between the direct ENMeval and Wallace runs because the background realization and evaluation details differ. The relevant result is the concordant selection of **LQHP / RM = 1** within each candidate set.

## Variable importance

Permutation importance of the selected direct ENMeval model:

| Predictor | Relative importance (%) |
|---|---:|
| BIO14 – Precipitation of driest month | 31.84 |
| BIO1 – Annual mean temperature | 18.68 |
| BIO2 – Mean diurnal range | 18.18 |
| BIO4 – Temperature seasonality | 16.03 |
| BIO15 – Precipitation seasonality | 8.59 |
| BIO12 – Annual precipitation | 6.68 |

## Transfer to Colombia

The continuous cloglog prediction for Colombia ranged from **0.0004206 to 0.925758**, with a mean of **0.1771955**.

Strict univariate extrapolation relative to the full M200 environmental range affected approximately **0.74%** of valid Colombian cells, mainly because of BIO1. A MOP analysis based on the 9,987 sampled M200 background environments returned a median distance of 0.1967, P95 = 0.4344, and P99 = 0.5585. Because the sampled reference has slightly narrower extrema than the full M200 raster, its strict non-analogous-condition percentage is expected to be larger than the full-M200 univariate estimate.

## Repository structure

```text
Stenochrus-portoricensis-SDM/
├── README.md
├── .gitignore
├── Stenochrus-portoricensis-SDM.Rproj
├── R/
├── data/
│   ├── raw/
│   ├── processed/
│   └── rasters/
├── wallace/
│   ├── RunA/
│   ├── RunB/
│   └── Final/
├── results/
├── figures/
└── docs/
```

## Reproducibility order

Run the scripts in `R/` sequentially:

1. `00_setup.R`
2. `01_occurrence_qc.R`
3. `02_calibration_area_M200.R`
4. `03_environmental_predictors.R`
5. `04_background_sampling.R`
6. `05_enmeval_tuning.R`
7. `06_response_curves_importance.R`
8. `07_wallace_inputs_and_comparison.R`
9. `08_projection_colombia.R`
10. `09_mop_extrapolation.R`
11. `10_maps.R`

The scripts assume that the raw GBIF export and WorldClim rasters are available locally. Large environmental rasters and binary R objects are intentionally ignored by Git.

## Key figures

### Climatic suitability in Colombia

Predicted climatic suitability in Colombia based on the selected Maxent model (feature class = LQHP, regularization multiplier = 1).

### Environmental dissimilarity (MOP) in Colombia

Areas with higher dissimilarity indicate stronger extrapolation risk relative to the environmental conditions represented in the accessible area (M200).

### Response curves

Univariate response curves for the six climatic variables used in model calibration.

## Software used during development

- R 4.6.1
- terra 1.9.x
- ENMeval 2.0.5.x
- maxnet 0.1.4
- geodata 0.6.9
- sf 1.1-2
- Wallace 2.2.1


## AI declaration

This project used ChatGPT (OpenAI) to assist with workflow development, code implementation, troubleshooting, data analysis, and visualization. All methodological decisions, data interpretation, and scientific conclusions remain the responsibility of the authors.