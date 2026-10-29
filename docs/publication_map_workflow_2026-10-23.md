# Reproducible publication maps: Figures 1, 2, 4, 5

**Status: scripts updated 29 October 2026. Final local execution and visual audit are still pending.** This cartographic update does not refit Maxnet, modify original input rasters, or change numerical findings in the manuscript.

## Scripts

- [R/40_fig_helpers.R](../R/40_fig_helpers.R) — shared typography (sans), boundary styling, projected reference scale bars, mainland-only map frame, geographic safeguards, and PNG/TIFF 600 dpi/PDF exports.
- [R/41_figure1_consistent.R](../R/41_figure1_consistent.R) — 234 American QC coordinates and M200: individual 200-km s2 point buffers, polygon dissolve after projection to avoid spherical-loop crossing.
- [R/42_figure2_consistent.R](../R/42_figure2_consistent.R) — current Colombia cloglog suitability and 10 QC localities.
- [R/43_figure4_consistent.R](../R/43_figure4_consistent.R) — current MOP distance and strict NAC overlay.
- [R/44_figure5_consistent.R](../R/44_figure5_consistent.R) — eight future NAC / suitability panels and scenario-level checks.
- [R/45_run_consistent_maps.R](../R/45_run_consistent_maps.R) — run four map scripts and then the post-run audit.
- [R/46_verify_publication_maps.R](../R/46_verify_publication_maps.R) — confirm all twelve file exports and the standardised MOP and four-scenario NAC/suitability checks.
- [R/32_figure3_response_curves.R](../R/32_figure3_response_curves.R) — independent ENMeval-based Figure 3 curves (the original fitted model, 171 presence cells; no refit).

All six PNG figure previews were updated on 29 October 2026. The author retains the high-resolution originals for journal submission; no further image upload is necessary for this **code-only** audit.

## Local execution

From RStudio on the researcher's machine:

~~~r
project <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
Sys.setenv(STENOCHRU_SDM_PROJECT = project)
source(file.path(project, "R", "45_run_consistent_maps.R"))
~~~

R packages required: terra, sf, ggplot2, geodata, patchwork.

Input paths are relative to the private local modelling directory (not fully deposited here):

- data/Stenochrus_portoricensis_America_QC_unique.csv — expected 234 unique American QC coordinates, including 10 Colombian localities.
- data/Stenochrus_prediction_Colombia_GADM_LQHP_RM1_current.tif or data/rasters/Stenochrus_prediction_Colombia_LQHP_RM1.tif.
- data/WorldClim_CMIP6_future/MOP/MOP_basic_CURRENT_Colombia.tif and MOP_distance_CURRENT_Colombia.tif.
- For each GCM (HadGEM3-GC31-LL, MIROC6, CNRM-CM6-1, MRI-ESM2-0), paired future MOP_basic and MOP_distance GeoTIFFs across 2 SSPs and 2 periods.
- Four data/WorldClim_CMIP6_future/Consensus/Consensus_2of4_SSPxxx_period.tif rasters. Optional GCM_agreement rasters provide the full 2/3/4-model agreement.

Scripts read the original source files without overwriting them. Figure products go to figures/publication_consistent/Figure_1, Figure_2, Figure_4, and Figure_5.

## Mapping and verification choices

All Colombian maps use EPSG:9377 (MAGNA-SIRGAS / Origen Nacional) for visual display, focus on mainland Colombia (approximately 79.5–66.5°W and 4.9°S–13.6°N), omit San Andrés and Providencia from the map frame, and apply uniform typography and administrative boundaries. Reference scale segments are measured in projected metres and must be visually inspected; they are not new SDM estimates.

The continental Figure 1 uses Lambert azimuthal equal-area display geometry. The 200-km M200 buffers are computed geodesically using s2. The displayed 1,000-km bar is an approximate projected-distance guide at continental scale, not a uniform geodesic distance.

Strict NAC in MOP_basic is coded 1, whereas NA in that raster denotes analog conditions only when the paired MOP_distance cell is valid. The valid distance raster defines the environmental mask. Rasters are reprojected only for plot display; Figure 5 area checks use the original geographic rasters.

The original 10th-percentile presence threshold is 0.2123639. Expected areas with climatic suitability under agreement of at least 2 out of 4 GCMs:

| SSP | Period | Area (km²) |
|---|---|---:|
| SSP1-2.6 | 2041–2060 | 144,294.6 |
| SSP5-8.5 | 2041–2060 | 138,796.7 |
| SSP1-2.6 | 2061–2080 | 143,206.2 |
| SSP5-8.5 | 2061–2080 | 143,995.9 |

The Figure 5 script checks grid geometry and class coding plus the standardised evaluation extent (**54,539 cells**, **1,160,946 km²**). It audits suitable area (≥2/4 GCMs), **area-weighted NAC >=2/4, >=3/4 and 4/4 GCMs**, and suitable–NAC overlap in all four scenarios using a **10 km² area tolerance** and **0.05 percentage-point tolerance**. Its output Figure_5_validation.csv has distinct columns for NAC percentages **by number of cells** versus **by cell-area-weighted surface**. The percentages reported in the manuscript use surface, not cell counts. Figure 4 also verifies the reference 684 strictly non-analog cells. R/45 invokes R/46 to verify that all PNG/TIFF/PDF exports and both diagnostic CSVs exist and agree with manuscript benchmarks.

The author must still execute the updated scripts against the original local rasters; code inspection and a published manuscript figure are not proof that this exact code version completed successfully. Panel-by-panel visual review is also needed.

## Caveats

- The ≥2/4 agreement rule is NOT a strict majority. Keep this criterion explicit.
- Detailed suitability agreement classes 2/3/4 require all four local GCM_agreement rasters; otherwise maps correctly use a binary <2 vs ≥2 legend.
- Historical scripts R/10_maps.R, R/11_future_consensus_maps.R, and R/31_figure1_calibration_map.R are retained.
- No local QC occurrence CSV, high-resolution figure or unpublished climate raster was added in this update.
