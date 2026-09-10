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
- [ ] Assess occurrence sampling bias / target-group or thinning sensitivity
- [ ] Consider thresholded outputs only after choosing and justifying a threshold
- [ ] Archive exact package versions (`sessionInfo()` and/or `renv`)
- [ ] Add a formal repository license
- [ ] Add citation metadata (`CITATION.cff`) when authorship/release information is finalized
