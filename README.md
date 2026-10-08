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
- CMIP6 future projections for four GCMs, two SSPs, and two future periods.
- Inter-GCM climatic-suitability consensus and stable/gained/lost suitable-area summaries.
- Future MOP / strict non-analog climate (NAC) analyses and NAC consensus.
- Area-weighted post hoc elevational analysis of occurrences, suitable area, and loss/persistence/gain under future consensus scenarios.

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

Strict univariate extrapolation relative to the full M200 environmental range affected approximately **0.74%** of valid Colombian cells, mainly because of BIO1. Under the standardized present/future MOP workflow, **684 of 54,539 cells (1.254%)** in Colombia were classified as strict non-analog conditions relative to the 9,987 sampled background environments.


## Future climate projections

Future climatic suitability was evaluated with the selected LQHP / RM = 1 model using WorldClim CMIP6 bioclimatic layers at 2.5 arc-min resolution. Four GCMs were used: **HadGEM3-GC31-LL, MIROC6, CNRM-CM6-1, and MRI-ESM2-0**, under **SSP1-2.6** and **SSP5-8.5** for **2041–2060** and **2061–2080**. This yielded 16 GCM–SSP–period projections.

A fixed 10th-percentile training-presence threshold (**10TP = 0.2123639**) was applied to the present and all future predictions. Present climatically suitable area was **379,223.5 km²**.

Using the primary consensus criterion of suitability supported by at least two of four GCMs (≥2/4), future suitable area was:

| SSP | Period | Future suitable area (km²) | Change from present | Persistence (km²) | Loss (km²) | Gain (km²) |
|---|---|---:|---:|---:|---:|---:|
| SSP1-2.6 | 2041–2060 | 144,294.6 | -61.95% | 119,735.4 | 259,488.1 | 24,559.2 |
| SSP5-8.5 | 2041–2060 | 138,796.7 | -63.40% | 93,387.8 | 285,835.7 | 45,408.9 |
| SSP1-2.6 | 2061–2080 | 143,206.2 | -62.24% | 113,141.4 | 266,082.2 | 30,064.8 |
| SSP5-8.5 | 2061–2080 | 143,995.9 | -62.03% | 77,549.1 | 301,674.4 | 66,446.8 |

All 16 individual GCM projections showed net contraction relative to the current suitable area.

### Future environmental novelty

Strict non-analog conditions increased substantially under stronger forcing and later periods. Under the ≥2/4 GCM NAC-consensus criterion, non-analog climates covered **28.26%**, **54.57%**, **32.09%**, and **76.50%** of Colombia for SSP1-2.6 2041–2060, SSP5-8.5 2041–2060, SSP1-2.6 2061–2080, and SSP5-8.5 2061–2080, respectively.

Unanimous 4/4 NAC agreement covered **9.22%**, **24.45%**, **10.75%**, and **45.99%** of the country across the same scenarios. Despite this increase in environmental novelty, overlap between multi-GCM suitable predictions and multi-GCM NAC was very limited: no ≥2-GCM overlap occurred in the first three scenarios, and only **1,324.2 km²** did so under SSP5-8.5 in 2061–2080, approximately **0.92%** of the ≥2/4 future suitable consensus area.


## Elevational redistribution of climatic suitability

A **post hoc, area-weighted elevational analysis** has been completed for **171 American calibration occurrence cells**, **10 unique Colombian localities**, and the present/four future consensus suitability maps. Elevation is a descriptive spatial variable; it was **not included as an SDM predictor**.

- Observed occurrence median elevation: **168 m** across American calibration presences versus **990 m** for Colombian localities.
- Current Colombian suitable area: **379,223.5 km²**, area-weighted median elevation **242 m** (IQR 193–624 m); **70.90%** below 500 m.
- Future consensus (≥2/4 GCMs): area-weighted median elevation **1,031–1,416 m**, despite **61.95–63.40%** reductions in total suitable area.
- Change-class medians across future scenarios: **loss 211–220 m**, **persistence 968–1,191 m**, **gain 1,512–1,732 m**.
- Under SSP5-8.5 for 2061–2080: gain **66,446.8 km²** at median **1,732 m**, persistence **77,549.1 km²** at median **1,191 m**, and loss **301,674.4 km²** at median **220 m**.

These estimates describe **an upslope redistribution of geographically suitable climates**, not observed upslope dispersal or an intrinsic elevation preference.

**Analytical outputs:** [results/altitude/](results/altitude/) holds four CSV tables, including observed-occurrence summaries, suitable-area elevation summaries, elevation-band areas, and gain/loss/persistence summaries.

**Reproducible R scripts:** [R/12_altitudinal_analysis.R](R/12_altitudinal_analysis.R) recomputes the area-weighted tables using the original rasters and occurrence data; [R/13_altitudinal_figure.R](R/13_altitudinal_figure.R) generates the two-panel Figure 6 as 400-dpi PNG, TIFF, and vector PDF. See [methodology, provenance and figure caption](docs/elevational_redistribution.md).

### Figure 6 — Elevational redistribution

![Figure 6. Elevational redistribution of climatic suitability in Colombia](figures/altitude/Figure_altitudinal_redistribution_FINAL.png?raw=true)

**Figure 6.** (A) Percentage of climatically suitable area across elevational bands in Colombia under current and future consensus projections. (B) Area-weighted median elevations and interquartile ranges of loss, persistence and gain under future scenarios. Suitability was defined by agreement of ≥2 of four CMIP6 GCMs at the fixed 10TP threshold (0.2123639). This is a shift in mapped climatic suitability, **not direct evidence of species migration**. [Full methodology and caption](docs/elevational_redistribution.md).

**Provenance:** The repository CSVs reflect the numerical precision of the R-console results generated in October 2026. The Figure 6 PNG provided by the author has now been uploaded to `figures/altitude/`. The original local occurrence-level inputs, climate/elevation rasters, and TIFF/PDF figure exports are not yet deposited.

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
12. `11_future_consensus_maps.R` (future-consensus map template)
13. `12_altitudinal_analysis.R` (requires the original local rasters/occurrence CSVs)
14. `13_altitudinal_figure.R` (rebuilds Figure 6 from altitude CSVs)
15. `14_auc_fold_audit.R` (audits the four ENMeval LQHP/RM1 AUC validation-fold values and exports the verified fold table, if the original ENMeval object is available locally)

The scripts assume that the raw GBIF export and WorldClim rasters are available locally. Large environmental rasters and binary R objects are intentionally ignored by Git.

## Key figures

### Climatic suitability in Colombia

![Predicted climatic suitability of Stenochrus portoricensis in Colombia](figures/colombia/Stenochrus_Colombia_LQHP_RM1_FINAL_400dpi_fixed.png?raw=true)

Predicted climatic suitability in Colombia based on the selected Maxnet model
(feature class = LQHP, regularization multiplier = 1).

### Environmental dissimilarity (MOP) in Colombia

![Environmental dissimilarity in Colombia](figures/mop/mop_dissimilarity_colombia.png?raw=true)

Areas with higher dissimilarity indicate stronger environmental differences
relative to the conditions represented in the M200 calibration area.

### Response curves

![Response curves of the selected model](figures/response_curves/response_curves_lqhp_rm1.png?raw=true)

Conditional response curves for the six bioclimatic predictors included in the
selected LQHP / RM = 1 model.

### Future suitability and non-analog climate consensus

![Future climatic suitability and NAC consensus](figures/colombia/Figure_future_NAC_suitability_consensus.png?raw=true)

Panels A–D summarize agreement among four GCMs in strict non-analog climatic conditions (NAC). Panels E–H summarize agreement among GCMs in future climatic suitability using the fixed 10TP threshold. The reproducible mapping code is available in `R/11_future_consensus_maps.R`.

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