# Our methodological record

## 1. Occurrence scope

We estimated climatic suitability for *Stenochrus portoricensis* in Colombia using occurrence data from the **Americas**. We excluded records from Europe and all other continents. We retained American records initially regardless of whether populations were native or introduced because we aimed to characterize the realised environmental space represented by the available American occurrences. We acknowledge this assumption when discussing geographic transferability and niche interpretation.

## 2. GBIF and coordinate quality control

We retrieved **398 georeferenced PRESENT** records and retained **369** after geographic filtering to the Americas. We applied the following CoordinateCleaner screening tests:

```r
c("capitals", "centroids", "equal", "gbif", "institutions", "zeros")
```

We obtained **358 TRUE** and **11 FALSE** records in the spatial validity summary. We reviewed flagged records rather than removing them automatically, since this synanthropic species can occur legitimately in cities and near institutions.

We excluded two categories of unsupported coordinates:

1. We excluded the coordinates for GBIF key `477927176` (MCZ IZ 102977), whose verbatim locality was "COLOMBIA, near Cali" but whose assigned coordinates placed it in Córdoba. The record's GEOLocate score (49), medium precision and unverified status did not support its modelled position.
2. We excluded all **29** USA records mapped to exactly `-96.33162, 38.82081`. They came from a GenBank-mined material-sample dataset without adequate locality or georeferencing support.

We retained **339** georeferenced records after these targeted exclusions.

## 3. Duplicate reduction

We reduced exact coordinate duplicates using a quality-priority ordering favoring preserved specimens, lower coordinate uncertainty, locality information and collection year. We retained **234 unique exact coordinates**.

## 4. Accessible calibration area (M)

We explored geodesic occurrence-buffer distances of 5, 100, 200 and 300 km and selected **M200** as our operational calibration hypothesis. We defined the area as the geodesic union of 200-km buffers around the 234 quality-controlled unique-coordinate records.

We preserved the native WorldClim ocean `NA` mask rather than imposing Natural Earth land polygons; preliminary land masking had discarded valid WorldClim cells on small islands and cays.

## 5. Environmental predictors

We sampled WorldClim 2.1 bioclimatic variables at 2.5 arc-min resolution. Following correlation screening and VIF reduction, we retained:

- BIO1 — annual mean temperature
- BIO2 — mean diurnal range
- BIO4 — temperature seasonality (SD × 100)
- BIO12 — annual precipitation
- BIO14 — precipitation of the driest month
- BIO15 — precipitation seasonality (coefficient of variation)

Our 234 unique-coordinate records occupied **172** WorldClim grid cells. We excluded GBIF key `4923620954` from the final model because its original WorldClim cell lacked complete predictors, leaving **171 effective calibration presences**.

## 6. Background

We identified **136,111 valid environmental cells** in M200. We drew 10,000 background cells and excluded 13 that coincided with presence cells, retaining **9,987** original uniform-background cells for direct ENMeval calibration.

## 7. ENMeval tuning

We fitted the original model using species-with-data (SWD) inputs and four spatial `block` folds:

```r
ENMeval::ENMevaluate(
  occs = occs_swd,
  bg = bg_swd,
  algorithm = "maxnet",
  partitions = "block",
  tune.args = list(
    fc = c("L", "LQ", "H", "LQH", "LQHP"),
    rm = seq(0.5, 4, by = 0.5)
  ),
  parallel = FALSE,
  raster.preds = FALSE,
  other.settings = list(validation.bg = "partition")
)
```

We evaluated **40 configurations** and selected **LQHP/RM1** by minimum AICc. The same configuration also had the highest mean validation AUC within the original direct-ENMeval candidate run.

## 8. Wallace replication

We reproduced parameter selection using **Wallace 2.2.1**, with 171 user-specified occurrences, the same six raster predictors, the same M200 polygon, 10,000 background points randomly sampled by Wallace, four block groups, Maxnet and clamping.

Because the Wallace interface allowed only integer RM stepping, we evaluated two complementary runs:

- RunA: 0.5, 1.5, 2.5 and 3.5
- RunB: 1, 2, 3 and 4

We combined the 40 evaluation rows and recalculated ΔAICc and Akaike weights across the complete set. We again selected **LQHP/RM1**. We treat this configuration agreement as workflow replication, not independent predictive validation.

## 9. Response curves and variable importance

We produced conditional response curves by varying one predictor across its presence-data range while holding all others at their medians. Because our model includes linear, quadratic, hinge and product features, we interpret the resulting curves as conditional model responses, not physiological tolerances.

We estimated permutation importance as the mean change in AUC after 50 permutations of each predictor, normalized to total 100%.

## 10. Colombia projection

We transferred the selected original Maxnet model to six WorldClim 2.1 predictors cropped and masked to Colombia, using cloglog output and clamping. We obtained prediction values ranging from **0.0004206 to 0.925758** (mean **0.1771955**).

## 11. Extrapolation and novelty

We assessed strict univariate extrapolation by comparing Colombian raster values with the min–max environmental ranges of all cells in M200. We found extrapolation beyond M200 for **BIO1 in 391** Colombian cells and **BIO4 in 11** cells, representing **402 unique cells** in total (approximately 0.74% of valid Colombian cells).

We also calculated multivariate mobility-oriented parity (MOP) using our **9,987** uniform-background environments as the calibration reference and the Colombian environmental raster stack as the projection space. We used centered and scaled Euclidean distances, including all-distance calculation and rescaling to 0–1.

| MOP statistic | Value |
|---|---:|
| Median | 0.1967223 |
| 90th percentile | 0.3900485 |
| 95th percentile | 0.4344312 |
| 99th percentile | 0.5585029 |
| Maximum | 1 |

Because the sampled reference spans narrower extrema than the complete M200 climate stack, we distinguish our reference-dependent strict non-analog count (**651 cells**, approximately 1.20%) from the complete-M200 univariate novelty assessment.

## 12. GBIF sampling-effort sensitivity

We used the taxon-stratified GBIF effort rasters of El-Gabbas (2026) to evaluate alternative background-sampling designs. We kept the original uniform treatment and calibrated two Arachnida-weighted sensitivity scenarios (floor fractions **0.10** and **0.20**, seed **125**). We evaluated 40 additional Maxnet configurations per weighted background and selected LQHP/RM1 in all treatments.

We then projected the three treatments to the same Colombia grid and compared continuous and 10TP-thresholded suitability. In a four-fold common-background validation (diagnostic 25), we obtained mean AUC values of **0.7417520** for uniform, **0.7077332** for Arachnida floor 0.10 and **0.7116284** for Arachnida floor 0.20. We interpret these results conditional on their shared uniform evaluation distribution. We provide the detailed design, source files and limitations in [sampling_bias_elgabbas.md](sampling_bias_elgabbas.md) and [common_background_validation_2026-10-09.md](common_background_validation_2026-10-09.md).
