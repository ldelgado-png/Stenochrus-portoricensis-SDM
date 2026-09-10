# Methodological record

## 1. Occurrence scope

The modelling objective is to estimate climatic suitability for *Stenochrus portoricensis* in Colombia using occurrence information from the Americas. Records from Europe and other continents were excluded from calibration. American records were initially retained regardless of whether populations were native or introduced because the project explicitly seeks the realized environmental space represented by American populations; this choice must be acknowledged when interpreting transferability and niche meaning.

## 2. GBIF and coordinate quality control

Initial retrieval: 398 georeferenced PRESENT records. Explicit country filtering retained 369 records in the Americas.

CoordinateCleaner tests used:

```r
c("capitals", "centroids", "equal", "gbif", "institutions", "zeros")
```

The spatial-valid summary was 358 TRUE and 11 FALSE. Flagged records were not removed automatically because this synanthropic species can legitimately occur in cities or near institutions.

Two coordinate problems were treated explicitly:

1. GBIF key `477927176` (MCZ IZ 102977), verbatim locality "COLOMBIA, near Cali", was georeferenced to Córdoba and marked GEOLocate score 49, medium precision, unverified / under review. The biological occurrence was retained conceptually but its coordinate was excluded from modelling.
2. Twenty-nine records at exactly -96.33162, 38.82081, USA, originated from a GenBank-mined material-sample dataset and lacked locality / georeferencing support. All 29 were excluded rather than retaining one duplicate.

After these exclusions, 339 records remained.

## 3. Duplicate reduction

Exact duplicate coordinates were reduced using a quality-priority ordering that favored preserved specimens, lower coordinate uncertainty, presence of locality information, and presence of year. This produced 234 unique exact coordinates.

## 4. Calibration area (M)

Alternative geodesic occurrence buffers of 5, 100, 200, and 300 km were explored. M200 was selected as the primary operational calibration hypothesis. The operational M200 is the geodesic union of 200 km buffers around the 234 quality-controlled unique coordinates.

Important: climate was not masked with Natural Earth land polygons in the final workflow because this erroneously removed valid WorldClim cells on small islands/cays. WorldClim's native ocean NA mask was retained instead.

## 5. Environmental predictors

WorldClim 2.1 bioclimatic variables at 2.5 arc-min resolution were used. After correlation screening and VIF reduction, the final predictors were:

- BIO1 Annual Mean Temperature
- BIO2 Mean Diurnal Range
- BIO4 Temperature Seasonality (SD × 100)
- BIO12 Annual Precipitation
- BIO14 Precipitation of Driest Month
- BIO15 Precipitation Seasonality (Coefficient of Variation)

The 234 exact-coordinate records occupied 172 unique WorldClim cells. One Florida record (GBIF key `4923620954`) fell in an original WorldClim NA cell and was excluded from ENMeval rather than imputed, yielding 171 effective presences.

## 6. Background

M200 contained 136,111 valid environmental cells. A random sample of 10,000 cells was drawn. Thirteen background cells coinciding with presence cells were removed, leaving 9,987 background points for the direct ENMeval analysis.

## 7. ENMeval tuning

The successful direct ENMeval run used SWD format:

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

Forty configurations were evaluated. LQHP / RM = 1 was selected by minimum AICc and also had the highest mean validation AUC in the direct run.

## 8. Wallace replication

Wallace 2.2.1 was run with:

- 171 user-specified occurrences
- the same six rasters
- the same user-specified M200 polygon
- 10,000 random background points sampled by Wallace
- Block (k = 4)
- maxnet
- feature classes L, LQ, H, LQH, LQHP
- clamping on

Because the Wallace UI accepted only an integer multiplier-step value, the eight RM values were evaluated in two complementary runs:

- RunA: 0.5, 1.5, 2.5, 3.5
- RunB: 1, 2, 3, 4

The 40 tables were combined and ΔAICc / Akaike weights recalculated across the full set. Wallace also selected LQHP / RM = 1.

## 9. Response curves and importance

Response curves were generated conditionally by varying one predictor across the observed presence range while holding the remaining predictors at their medians. Because the selected model contains L, Q, H and P features, these curves are conditional model responses and should not be interpreted as physiological tolerance curves.

Permutation importance was quantified as mean loss in AUC across 50 permutations of each predictor, then normalized to sum to 100%.

## 10. Colombia projection

The selected direct maxnet model was transferred to six WorldClim layers cropped/masked to Colombia, using cloglog output and clamping. The resulting prediction ranged from 0.0004206 to 0.925758 (mean 0.1771955).

## 11. Extrapolation / novelty

Strict univariate extrapolation was assessed by comparing every Colombian raster cell against the full min/max range of each predictor across M200. Only BIO1 and BIO4 exceeded M200 limits, affecting 391 and 11 cells respectively (402 total cells; ~0.74% of valid Colombia cells).

A multivariate MOP analysis was also run using the 9,987 sampled M200 background environments as the reference matrix and the Colombian raster stack as the transfer environment. MOP settings included Euclidean distance, scaling and centering, all-distance calculation, and rescaling to 0–1.

MOP distances:

- median: 0.1967223
- P90: 0.3900485
- P95: 0.4344312
- P99: 0.5585029
- maximum: 1

Because the sampled reference has narrower extrema than the full M200 raster, its strict NAC estimate (651 cells; ~1.20%) is expected to exceed the strict full-M200 estimate.
