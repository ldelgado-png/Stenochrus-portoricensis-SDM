# Workflow checklist

## Completed

- [x] Retrieve georeferenced GBIF occurrences
- [x] Restrict calibration records to the Americas
- [x] Coordinate quality control
- [x] Exclude unsupported georeferences
- [x] Reduce exact duplicate coordinates
- [x] Build alternative calibration buffers and select M200
- [x] Download/load WorldClim 2.1 at 2.5 arc-min
- [x] Reduce to one occurrence per environmental cell
- [x] Select six low-collinearity predictors
- [x] Sample background in M200
- [x] Tune 40 maxnet models with ENMeval
- [x] Select LQHP / RM = 1
- [x] Generate response curves
- [x] Estimate permutation importance
- [x] Replicate tuning in Wallace
- [x] Project selected model to Colombia
- [x] Quantify strict univariate extrapolation
- [x] Run multivariate MOP analysis

## Next recommended analyses

- [ ] Finish publication-quality MOP map
- [ ] Reproject cartographic outputs to a metric Colombia CRS before final scale bars
- [ ] Produce final high-resolution PNG/PDF maps
- [ ] Map strict NAC and high-MOP (e.g. descriptive P95) separately
- [ ] Consider M sensitivity analyses (M100 / M300; optionally M5 exploratory)
- [x] Define a literature-grounded effort-bias sensitivity protocol from El-Gabbas (2026), 5 km/2.5 arc-min, Schizomida/Arachnida, 1980–2025, with documented non-zero probability for zero-count cells and scripts R/16–17
- [x] Download and align three original El-Gabbas effort rasters with WorldClim M200; document 206 positive Schizomida cells, 21,711 Arachnida cells and 160 Schizomida species-richness cells (table in results/sampling_bias/)
- [ ] Run the effort-feasibility and occurrence-year diagnostic in R/18 before fitting alternate models
- [ ] Run full candidate retuning under weighted backgrounds, evaluate seeds, and compare Colombian current/future predictions (R/17; requires original local rasters)
- [ ] Determine whether independent non-focal Schizomida occurrences support a fair target-group-background comparison
- [ ] Consider thresholded outputs only after choosing and justifying a threshold
- [ ] Archive exact package versions (`sessionInfo()` and/or `renv`)
- [ ] Add a formal repository license
- [ ] Add citation metadata (`CITATION.cff`) when authorship/release information is finalized
