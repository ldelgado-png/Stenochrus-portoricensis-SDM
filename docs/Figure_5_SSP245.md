# Figure 5: three SSPs, two periods and two indicators

This extension preserves the established Figure 5 palettes, Colombia mainland framing, GADM boundaries, north arrows and 250-km scale bars. It adds SSP2-4.5 for both periods with genuine environmental data.

## Panel order

The six columns are SSP126/245/585 for 2041–2060, followed by SSP126/245/585 for 2061–2080. Panels A–F show strict NAC agreement among four GCMs; panels G–L show climatic-suitability agreement. In the suitability legend, 0–1 denotes fewer than two agreeing GCMs; colours retain classes 2, 3 and 4. The NAC legend retains counts 0–4.

## Prerequisites and execution

Run the corrected R/47_SSP245_altitudinal_extension.R first so both SSP245 consensus rasters and GCM counts exist. Then install these files in the original project:

- R/40_fig_helpers.R (existing shared helpers)
- R/48_SSP245_NAC_prepare.R
- R/49_figure5_with_SSP245.R

Run R/48_SSP245_NAC_prepare.R in RStudio, with STENOCHRU_SDM_PROJECT set to the original project. It computes strict NAC and automatically runs R/49. Existing R/44 and previous Figure 5 exports are preserved.

## Strict NAC calculation and audit

The script uses the saved original 9,987-environment reference from Stenochrus_background_M200.rds/CSV, or from the original uniform-background ENMeval object. It never samples new background points. The six predictors and layer order match the existing analysis. Before calculating future NAC, the script requires exact cell-level agreement with the archived current MOP-basic raster: 684 NAC cells within the 54,539-cell valid Colombian mask.

The eight SSP245 WorldClim CMIP6 inputs are reused from the download cache. With mop::mop(type="basic", calculate_distance=FALSE), the script identifies conditions outside one or more reference-variable ranges. This is the strict NAC indicator required for the map, rather than a new continuous MOP-distance analysis. It exports MOP_basic_* rasters with 1/NA coding and separately named NAC_validmask_* rasters to distinguish analog NA values from missing environmental coverage. Validity masks are explicitly not distance rasters.

Historical SSP126/SSP585 panels continue reading their original MOP-basic and distance files. All historical numerical checks from R/44 are retained, including area-weighted NAC percentages and ≥2/4, ≥3/4, 4/4 and overlap areas. New SSP245 results are computed without assigning historical benchmark values. Raster analyses occur before display reprojection.

## Outputs

- data/WorldClim_CMIP6_future/MOP/MOP_basic_*SSP245*.tif
- data/WorldClim_CMIP6_future/MOP/NAC_validmask_*SSP245*.tif
- results/SSP245_NAC/SSP245_NAC_individual_GCM.csv, input checksums and session information.
- figures/publication_consistent/Figure_5_with_SSP245/: 12-panel Figure_5_with_SSP245.png/.tif/.pdf, NAC agreement rasters and Figure_5_validation.csv.

Figure dimensions are 27 × 13 inches, preserving the original per-panel dimensions across six columns; PNG/TIFF are exported at 600 dpi and PDF through the existing publication helper.

The deposited extension is code prepared for local execution. New SSP245 NAC results and the updated image require the original local inputs; the uploaded original PNG is a graphic reference, not a source of new scenario values.

## Caption for the completed figure

Figure 5. Future climatic novelty and suitability for Stenochrus portoricensis in Colombia across four general circulation models (GCMs). Columns show SSP1-2.6, SSP2-4.5 and SSP5-8.5 for 2041–2060, followed by the same scenarios for 2061–2080. (A–F) Number of GCMs indicating strictly non-analog climatic conditions relative to the original 9,987 reference environments. (G–L) GCM agreement in climatic suitability at the fixed tenth-percentile training-presence threshold (0.2123639); 0–1 denotes fewer than two agreeing GCMs and colours distinguish agreement by two, three or four GCMs. Geographic calculations use the common original raster mask; reprojection is used for display. Scale bars: 250 km.

Definition of MOP basic: https://cran.r-project.org/web/packages/mop/refman/mop.html
