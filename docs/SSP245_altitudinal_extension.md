# SSP2-4.5 extension of the elevational analysis

## Design

This extension adds SSP2-4.5 to the existing SSP1-2.6 and SSP5-8.5 comparison for 2041–2060 and 2061–2080. It uses the same uniform-background Maxnet LQHP/RM1 model, six predictors (BIO1, BIO2, BIO4, BIO12, BIO14, BIO15), WorldClim CMIP6 2.5-arc-minute grid and four GCMs: HadGEM3-GC31-LL, MIROC6, CNRM-CM6-1 and MRI-ESM2-0.

The eight additional GCM–period predictions use the fixed 10TP threshold 0.2123639. Suitability consensus requires at least two of four GCMs. The current Colombian grid and 379,223.5-km² suitable-area reference are preserved. Elevation remains a post-hoc descriptive variable, with area-weighted quartiles and area proportions in the original seven bands. No interpolation of results between SSP126 and SSP585 is used.

## Execution

Update these three files in the original local project:

- R/12_altitudinal_analysis.R
- R/13_altitudinal_figure.R
- R/47_SSP245_altitudinal_extension.R

Then run in RStudio:

```r
Sys.setenv(STENOCHRU_SDM_PROJECT = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis")
source(file.path(Sys.getenv("STENOCHRU_SDM_PROJECT"), "R", "47_SSP245_altitudinal_extension.R"), encoding = "UTF-8")
```

The extension checks the original occurrence files and four historical consensus/change pairs. It loads the saved uniform-background maxnet or ENMeval model, identifies the current six-predictor Colombian raster and verifies its predictions against the canonical current suitability raster (maximum absolute difference ≤1e-5). If an input is not uniquely found, an interactive file selector requests the original file. A successful present-day reproduction is required before future downloads/projections proceed.

WorldClim files are downloaded or reused in data/WorldClim_CMIP6_future/. Each execution records checksums, source raster paths, GCM-specific areas and session information in a new results/SSP245_extension/run_* folder. No model refitting occurs.

## Outputs

- Eight GCM-specific continuous suitability GeoTIFFs and an individual-GCM area table.
- Two SSP245 GCM-agreement, two binary ≥2/4-consensus and two change-class rasters under data/WorldClim_CMIP6_future/Consensus/.
- Change codes: 0 unchanged unsuitable; 1 gain; 2 loss; 3 persistence.
- A two-row SSP245 consensus summary with suitable area, loss, persistence, gain and percent change relative to present.
- Four recomputed elevational tables in results/altitude_with_SSP245/.
- Figure_6_altitudinal_with_SSP245 in PNG, TIFF and PDF: current plus six future conditions, retaining the established graphic style.

Existing historical results/altitude/ tables and figures are preserved. R/12 and R/13 retain their original two-SSP mode by default; the extension activates the three-SSP mode with STENOCHRU_INCLUDE_SSP245=TRUE. Historical area checks remain associated with their original scenario IDs rather than vector positions.

## Status and interpretation

The code extension is prepared for local execution; no SSP245 numerical results have been generated in this update. Existing manuscript numbers refer to the original SSP126/SSP585 analysis until the extension finishes and its outputs are checked. Future novelty/MOP calculations are a separate workflow: this script computes SSP245 suitability and elevational redistribution, not SSP245 MOP or NAC. Update the climate-suitability and elevational methods/results once the actual new outputs are available; keep novelty claims tied to scenarios for which novelty was calculated.

The figure describes redistribution of climatically suitable area by elevation. The literature-reported occurrence interval and DEM-extracted occurrence elevations remain distinct datasets, as documented in elevational_redistribution.md.

WorldClim download interface: https://rspatial.github.io/geodata/reference/cmip6.html
