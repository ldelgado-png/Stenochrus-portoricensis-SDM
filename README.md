# Potential distribution of *Stenochrus portoricensis* in Colombia

We present our reproducible ecological niche modelling / species distribution modelling workflow for *Stenochrus portoricensis* (Schizomida: Hubbardiidae), calibrated with American occurrence records and transferred to Colombia.

## Current status

We document the following analytical components of our modelling workflow:

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

We retained **BIO1, BIO2, BIO4, BIO12, BIO14 and BIO15** as our six predictors.

## GBIF sampling-effort sensitivity (El-Gabbas 2026)

**Our sampling-effort sensitivity analysis (8–9 October 2026).** We compared the original uniform background with two Arachnida-weighted backgrounds (probability floors 0.10 and 0.20; seed 125). We fitted **80 additional Maxnet candidates** (40 per alternative), retained the original 40 candidates, and selected LQHP/RM1 within all three treatments. We projected the three full-data models to the same Colombian WorldClim grid. With their individual 10TP thresholds, we obtained suitable areas of **379,223.5 km²** (uniform), **422,979.4 km²** (Arachnida 0.10) and **445,692.1 km²** (Arachnida 0.20), or changes of **+11.54%** and **+17.53%**. We measured rank correlations with the uniform prediction of **0.9620** and **0.9757**, respectively. For **diagnostic 25**, we independently sampled one common 9,987-cell evaluation background and refitted LQHP/RM1 within the same four spatial folds. We found mean AUC values of **0.7417520** (uniform), **0.7077332** (Arachnida 0.10) and **0.7116284** (Arachnida 0.20); corresponding weighted-minus-uniform AUC differences were **−0.03401889** and **−0.03012365**. Mean 10TP omission was **0.1104651** in all treatments. We interpret these as comparisons under a shared **uniform evaluation reference**, not as evidence of universal predictive superiority. We archived the supplied original rasters, backgrounds and fitted models under [`results/sampling_bias/original_outputs_2026-10-08/`](results/sampling_bias/original_outputs_2026-10-08/). We used El-Gabbas's cumulative 1980–2025 effort rasters at 2.5-arc-min resolution and preserved the original uniform model as our baseline.

**Our effort-coverage audit.** We detected Schizomida-positive effort in **206/136,111** valid M200 climate cells (0.151%), overlapping **113/171** focal presence cells, and Arachnida-positive effort in **21,711/136,111** (15.951%), overlapping **159/171** presences. After excluding the 171 focal presence cells, we retained 135,940 eligible cells: **93** Schizomida-positive and **21,552** Arachnida-positive. In the original 9,987-cell uniform background, we observed just **3** Schizomida-positive cells and **1,499** Arachnida-positive. Across seeds 123–127, our exploratory draws yielded **93/9,987** Schizomida-positive cells for each 0.01-floor draw, **75–83** with a 0.05 floor, and **9,347–9,410** Arachnida-positive cells with a 0.01 floor. We recovered **136/171** focal records from 1980–2025, **27** from before 1980, four from 2026 and four with unknown years (including **97/171** from 2010–2025). We therefore acknowledge temporal mismatch and treat Schizomida-weighted draws as exploratory, Arachnida weighting as a broader-taxon contrast, and the uniform background as our reference. We archived our [console-derived coverage table](results/sampling_bias/effort_coverage_diagnostics_console_2026-10-08.csv) and the [original rasters](results/sampling_bias/original_outputs_2026-10-08/).

- **[Our sampling-effort results, diagnostics 18–25](docs/sampling_bias_results_2026-10-08.md)** — full interpretation, provenance, model comparisons and limitations.
- **[Our diagnostic 25 report](docs/common_background_validation_2026-10-09.md)** and [common-background evaluation summary](results/sampling_bias/common_background_validation_console_2026-10-08.csv).
- [Arachnida weighting diagnostics (five-seed means and selected seed 125)](results/sampling_bias/arachnida_floor_diagnostics_console_2026-10-08.csv), [Maxnet selected-model comparison](results/sampling_bias/maxnet_background_comparison_console_2026-10-08.csv), [Colombia suitability and overlap results](results/sampling_bias/colombia_background_comparison_console_2026-10-08.csv). We transcribed these summary CSVs from our R console; we distinguish them from the deposited original outputs.
- [Documented experimental design, sources and limitations](docs/sampling_bias_elgabbas.md)
- [Original positive-cell eligibility results](results/sampling_bias/effort_background_feasibility_console_2026-10-08.csv), [five-seed background draws](results/sampling_bias/background_draw_feasibility_seeds_console_2026-10-08.csv), and [171-record date audit](results/sampling_bias/occurrence_years_console_2026-10-08.csv)
- [R/16_preflight_sampling_bias.R](R/16_preflight_sampling_bias.R) — **run first**; read-only check of original RDS object, climate rasters, packages and prior downloads before starting an OSF download.
- [R/16_sampling_effort_prepare.R](R/16_sampling_effort_prepare.R) — downloads the Schizomida/Arachnida raster layers, aligns them to the original M200 grid and audits effort coverage.
- [R/18_effort_feasibility_and_dates.R](R/18_effort_feasibility_and_dates.R) — check eligible non-focal positive-effort cells, seeded weighted-background composition and focal occurrence dates **before fitting models**.
- [R/17_sampling_bias_models.R](R/17_sampling_bias_models.R) — prepares uniform and effort-weighted backgrounds and, after explicitly enabling model fitting, evaluates 40 Maxnet candidates per background and projected suitability in Colombia where original grids are available.
- [R/19_arachnida_bias_pilot.R](R/19_arachnida_bias_pilot.R) — we provide this independent one-seed Arachnida effort-pilot implementation for reproducibility; our completed diagnostic 22 instead used the floors 0.10 and 0.20.

**Interpretation.** We compare AICc only **within** individual background experiments. We do not treat validation AUC from treatment-specific backgrounds as cross-treatment performance evidence. On our common uniformly sampled evaluation background, the original uniform model produced the highest mean AUC; we refrain from claiming that this establishes optimal bias correction. Our CMIP6 future results below represent the **uniform-background** model rather than a comparison among all three training backgrounds.

## Selected model

We selected the same Maxnet configuration in our direct ENMeval and Wallace workflows:

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

**Four-fold AUC audit (verified 2026-10-08).** We recovered the original ENMeval object locally. Fold validation AUCs were 0.673455, 0.747687, 0.813294, and 0.731585; corresponding fold-specific absolute training–validation AUC differences were 0.202805, 0.113214, 0.035568, and 0.092589. Our R `all.equal()` checks confirmed the reported `auc.val.avg = 0.7415053` and `auc.diff.avg = 0.1110438`; `abs.auc.diff = TRUE` and `validation.bg = "partition"`. These figures are not obtained by subtracting the model-wide training AUC from the average validation AUC. The per-fold CSV is in [results/model_selection/](results/model_selection/ENMeval_LQHP_RM1_auc_folds_verified_console.csv), with [provenance and reproducibility notes](docs/auc_fold_audit.md) and an [audit script](R/14_auc_fold_audit.R). **We also verified the Wallace fold-by-fold aggregation** against the original RunB group-export CSV; the published summary statistics remain unchanged.

### Wallace replication

We combined the two Wallace runs and recalculated ΔAICc and Akaike weights across all 40 models:

- AUC train: 0.8489026
- Mean validation AUC: 0.7945660
- Mean AUC difference: 0.1030216
- Mean validation CBI: 0.6865
- Mean 10% omission rate: 0.09302326
- AICc: 3768.617
- ΔAICc: 0
- Akaike weight: 0.9934626
- Non-zero coefficients: 32

**Four-fold AUC audit (verified 2026-10-08).** Original Wallace RunB validation AUCs: 0.696025, 0.842932, 0.765290 and 0.874017. Corresponding fold-specific AUC differences: 0.184942, 0.072651, 0.102770 and 0.051723. We recovered means of `auc.val.avg = 0.794566` and `auc.diff.avg = 0.1030216`; our R `all.equal()` checks passed. See the [Wallace four-fold CSV](results/model_selection/Wallace_LQHP_RM1_auc_folds_verified_console.csv), [validation script](R/15_wallace_auc_fold_audit.R), and the [complete ENMeval–Wallace AUC audit record](docs/auc_fold_audit.md). We interpret this as verification of the fold-level averages, not equivalence of background realization or AICc between workflows.

We do not compare absolute AICc between the direct ENMeval and Wallace analyses because their background realizations and evaluation details differ. We emphasize the concordant selection of **LQHP / RM = 1** within each candidate set.

## Variable importance

We estimated permutation importance for the selected direct ENMeval model:

| Predictor | Relative importance (%) |
|---|---:|
| BIO14 – Precipitation of driest month | 31.84 |
| BIO1 – Annual mean temperature | 18.68 |
| BIO2 – Mean diurnal range | 18.18 |
| BIO4 – Temperature seasonality | 16.03 |
| BIO15 – Precipitation seasonality | 8.59 |
| BIO12 – Annual precipitation | 6.68 |

## Transfer to Colombia

We obtained a continuous cloglog prediction for Colombia ranging from **0.0004206 to 0.925758**, with a mean of **0.1771955**.

We found strict univariate extrapolation in approximately **0.74%** of valid Colombian cells, mainly because of BIO1. Under the standardized present/future MOP workflow, **684 of 54,539 cells (1.254%)** in Colombia were classified as strict non-analog conditions relative to the 9,987 sampled background environments.


## Future climate projections

We evaluated future climatic suitability with the uniform-background selected LQHP/RM1 model and WorldClim CMIP6 bioclimatic layers at 2.5 arc-min resolution. We used four GCMs: **HadGEM3-GC31-LL, MIROC6, CNRM-CM6-1, and MRI-ESM2-0**, under **SSP1-2.6** and **SSP5-8.5** for **2041–2060** and **2061–2080**. We produced 16 GCM–SSP–period projections.

We applied one fixed 10th-percentile training-presence threshold (**10TP = 0.2123639**) to the present and all future predictions. Present climatically suitable area was **379,223.5 km²**.

Using our primary consensus criterion of suitability supported by at least two of four GCMs (≥2/4), we estimated future suitable area as follows:

| SSP | Period | Future suitable area (km²) | Change from present | Persistence (km²) | Loss (km²) | Gain (km²) |
|---|---|---:|---:|---:|---:|---:|
| SSP1-2.6 | 2041–2060 | 144,294.6 | -61.95% | 119,735.4 | 259,488.1 | 24,559.2 |
| SSP5-8.5 | 2041–2060 | 138,796.7 | -63.40% | 93,387.8 | 285,835.7 | 45,408.9 |
| SSP1-2.6 | 2061–2080 | 143,206.2 | -62.24% | 113,141.4 | 266,082.2 | 30,064.8 |
| SSP5-8.5 | 2061–2080 | 143,995.9 | -62.03% | 77,549.1 | 301,674.4 | 66,446.8 |

We observed net contraction in all 16 individual GCM projections relative to the current suitable area.

### Future environmental novelty

We found that strict non-analog conditions increased substantially under stronger forcing and later periods. Under the ≥2/4 GCM NAC-consensus criterion, non-analog climates covered **28.26%**, **54.57%**, **32.09%**, and **76.50%** of Colombia for SSP1-2.6 2041–2060, SSP5-8.5 2041–2060, SSP1-2.6 2061–2080, and SSP5-8.5 2061–2080, respectively.

Unanimous 4/4 NAC agreement covered **9.22%**, **24.45%**, **10.75%**, and **45.99%** of the country across the same scenarios. Despite this increase in environmental novelty, overlap between multi-GCM suitable predictions and multi-GCM NAC was very limited: no ≥2-GCM overlap occurred in the first three scenarios, and only **1,324.2 km²** did so under SSP5-8.5 in 2061–2080, approximately **0.92%** of the ≥2/4 future suitable consensus area.


## Elevational redistribution of climatic suitability

We completed a **post hoc, area-weighted elevational analysis** for **171 American calibration occurrence cells**, **10 unique Colombian localities**, and the present/four future consensus suitability maps. Elevation is a descriptive spatial variable; it was **not included as an SDM predictor**.

- Observed occurrence median elevation: **168 m** across American calibration presences versus **990 m** for Colombian localities.
- Current Colombian suitable area: **379,223.5 km²**, area-weighted median elevation **242 m** (IQR 193–624 m); **70.90%** below 500 m.
- Future consensus (≥2/4 GCMs): area-weighted median elevation **1,031–1,416 m**, despite **61.95–63.40%** reductions in total suitable area.
- Change-class medians across future scenarios: **loss 211–220 m**, **persistence 968–1,191 m**, **gain 1,512–1,732 m**.
- Under SSP5-8.5 for 2061–2080: gain **66,446.8 km²** at median **1,732 m**, persistence **77,549.1 km²** at median **1,191 m**, and loss **301,674.4 km²** at median **220 m**.

We interpret these estimates as **an upslope redistribution of geographically suitable climates**, not evidence of observed upslope dispersal or intrinsic elevation preference.

**We archive analytical outputs in:** [results/altitude/](results/altitude/) holds four CSV tables, including observed-occurrence summaries, suitable-area elevation summaries, elevation-band areas, and gain/loss/persistence summaries.

**We provide reproducible R scripts:** [R/12_altitudinal_analysis.R](R/12_altitudinal_analysis.R) recomputes the area-weighted tables using the original rasters and occurrence data; [R/13_altitudinal_figure.R](R/13_altitudinal_figure.R) generates the two-panel Figure 6 as 400-dpi PNG, TIFF, and vector PDF. See [methodology, provenance and figure caption](docs/elevational_redistribution.md).

### Figure 6 — Elevational redistribution

![Figure 6. Elevational redistribution of climatic suitability in Colombia](figures/altitude/Figure_altitudinal_redistribution_FINAL.png?raw=true)

**Figure 6.** (A) Percentage of climatically suitable area across elevational bands in Colombia under current and future consensus projections. (B) Area-weighted median elevations and interquartile ranges of loss, persistence and gain under future scenarios. Suitability was defined by agreement of ≥2 of four CMIP6 GCMs at the fixed 10TP threshold (0.2123639). This is a shift in mapped climatic suitability, **not direct evidence of species migration**. [Full methodology and caption](docs/elevational_redistribution.md).

**Provenance:** The repository CSVs reflect the numerical precision of the R-console results generated in October 2026. We archived the Figure 6 PNG to `figures/altitude/`. We retain the original local occurrence-level inputs and climate/elevation rasters in our R project; the repository includes the deposited products described above.

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

We organize the scripts in `R/` in this sequence:

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

We developed the scripts using our local GBIF and WorldClim inputs. We provide selected sampled background, raster and RDS outputs in the sampling-bias archive; the full original climate input is managed separately.

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

We used ChatGPT (OpenAI) to assist with workflow development, code implementation, troubleshooting, data analysis and visualization. We retain responsibility for all methodological decisions, data interpretation and scientific conclusions.