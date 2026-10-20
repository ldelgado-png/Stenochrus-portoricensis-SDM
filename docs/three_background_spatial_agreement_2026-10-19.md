# Spatial agreement among three present-day backgrounds (19 October 2026)

We compared three already fitted Maxnet LQHP/RM1 Colombia predictions using each model's **own tenth-percentile training-presence threshold (10TP)**. We extracted the original 360 × 483-cell EPSG:4326 GeoTIFFs and numerical thresholds from the author-supplied `sampling_bias.rar`. We applied the same finite raster mask of 54,539 Colombian cells and calculated latitude-adjusted geodesic cell areas on the WGS84 ellipsoid. We reproduced the original baseline suitable area **379,223.5 km²** and both weighted areas within 0.1 km² of their archived values.

| Number of models predicting suitable climate | Cells | Area (km²) | Percentage of the valid country mask |
|---|---:|---:|---:|
| 0 of 3 | 32,706 | 695,391.8 | 59.90% |
| 1 of 3 | 2,089 | 44,512.2 | 3.83% |
| 2 of 3 | 2,807 | 59,742.0 | 5.15% |
| 3 of 3 | 16,937 | **361,299.6** | **31.12%** |

We found that **77.61%** of the area classified as suitable by at least one model was classified as suitable by **all three**; this calculation uses the union of their own-threshold maps as its denominator.

The two Arachnida-weighted alternatives shared **409,168.7 km²** of suitable area, yielding a **Jaccard overlap of 0.89046**. Floor 0.10 alone classified 13,810.7 km² as suitable, whereas floor 0.20 alone classified 36,523.4 km² as suitable.

We interpret these results as **descriptive geographic agreement conditional on model-specific 10TP thresholds**, not confirmed occupied area, invasion probability or statistically validated performance. Different background-dependent 10TP values contribute to the differences among binary maps. We report the source values and new area summaries in [three-model agreement](../results/sampling_bias/three_background_agreement_10tp_console_2026-10-19.csv) and [weighted-model overlap](../results/sampling_bias/arachnida_pairwise_10tp_console_2026-10-19.csv). We supply [reproducible terra code](../R/25b_three_background_spatial_agreement.R) for recalculating these statistics from the original local GeoTIFFs.

*Computational cross-check:* We used `rasterio`, NumPy and WGS84 geodesic polygon areas for the independently derived summary CSVs. The R script implements the same procedure using `terra::cellSize(unit = "km")`. Source raster SHA-256 digests: uniform `da3594efe925774ca279f7176dd8d07412e4e5c5d96bc21a5cc671a8907c6ce7`; floor 0.10 `7b19c4ffa3b693104c48f70d7fce1e0e4fb211f57fb8160d392078d2e5f011df`; floor 0.20 `d54d644f8465671a9b2df38d44f31985bb14e40f4dc9224147c3407c2106ebe3`.
