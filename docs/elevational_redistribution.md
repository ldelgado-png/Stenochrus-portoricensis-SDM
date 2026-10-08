# Elevational redistribution of climatic suitability (Figure 6)

## Scope and provenance

This is a post hoc, descriptive analysis of the elevation of occurrence cells and projected climatically suitable cells in Colombia. Elevation **was not used as a predictor** in the fitted Maxnet model.

The CSV tables in [results/altitude/](../results/altitude/) were transcribed from the **R console outputs of the completed local analysis (October 2026)**. Their published precision reflects the displayed results and may differ slightly from unrounded outputs. The original occurrence-level CSVs, WorldClim elevation raster and present/future GeoTIFFs remain local; they are not represented as publicly archived here. The supplied [R/12_altitudinal_analysis.R](../R/12_altitudinal_analysis.R) re-computes the CSVs from those inputs, and [R/13_altitudinal_figure.R](../R/13_altitudinal_figure.R) builds the two-panel figure. The author has deposited the [Figure 6 PNG](../figures/altitude/Figure_altitudinal_redistribution_FINAL.png) in the repository. The original TIFF/PDF exports remain local; print resolution and image metadata have not been independently audited.

## Inputs and workflow

- **Elevation:** WorldClim 2.1 elevation, 2.5 arc-min, EPSG:4326; Colombia boundary from GADM. The Colombian DEM matches the canonical current-prediction grid (483 × 360 cells).
- **Occurrences:** 171 American calibration cells marked "direct extraction" in the climatic quality-control field (excluding one Florida coastal record with nearest-neighbour climate values); 10 quality-controlled, unique Colombian occurrence localities.
- **Current prediction:** data/Stenochrus_prediction_Colombia_GADM_LQHP_RM1_current.tif, fixed 10TP = **0.2123639**. This canonical raster reproduces 379,223.5 km²; the separately cropped Stenochrus_prediction_Colombia_LQHP_RM1.tif is **not** equivalent.
- **Future:** Four 0/1 rasters Consensus_2of4_{SSP}_{period}.tif in data/WorldClim_CMIP6_future/Consensus/, with suitability supported by ≥2 of the four GCMs.
- **Change codes:** Change_consensus_2of4_*.tif contains 0 = unsuitable in both periods, **1 = gain**, **2 = loss**, **3 = persistence**, verified from the current/future cell-count identities.
- **Areas:** terra::cellSize(unit = "km") accounts for geographic cell area; elevation summary quantiles and means are **area-weighted**. Bands are <500, 500–999, 1,000–1,499, 1,500–1,999, 2,000–2,499, 2,500–2,999, and ≥3,000 m. Band percentages divide by total suitable area **within each scenario**.

## Verified outputs

### Occurrences

| Dataset | n | Min (m) | Q1 (m) | Median (m) | Mean (m) | Q3 (m) | Max (m) |
|---|---:|---:|---:|---:|---:|---:|---:|
| American calibration cells | 171 | 2 | 18 | 168 | 325.9 | 432.5 | 2,274 |
| Colombian quality-controlled localities | 10 | 892 | 963.2 | 990 | 1,078.8 | 1,116.2 | 1,609 |

136 of the 171 American calibration presences (79.5%) were below 500 m. No Colombian locality was below 500 m.

### Suitable climate under current and future scenarios

| Condition | Suitable area (km²) | Q1 (m) | Area-weighted median (m) | Q3 (m) | Mean (m) |
|---|---:|---:|---:|---:|---:|
| Current | 379,223.5 | 193 | 242 | 624 | 468.7 |
| SSP1-2.6, 2041–2060 | 144,294.6 | 695 | 1,031 | 1,428 | 1,052.2 |
| SSP5-8.5, 2041–2060 | 138,796.7 | 939 | 1,231 | 1,592 | 1,262.6 |
| SSP1-2.6, 2061–2080 | 143,206.2 | 763 | 1,088 | 1,482 | 1,109.6 |
| SSP5-8.5, 2061–2080 | 143,995.9 | 1,089 | 1,416 | 1,773 | 1,448.4 |

Present suitable area: **70.90% below 500 m** and **85.27% below 1,000 m**. Late-century SSP5-8.5: **1.24% below 500 m**, **44.23% at ≥1,500 m**.

### Elevation of changing suitability (area-weighted medians, m)

| Future scenario | Loss | Persistence | Gain |
|---|---:|---:|---:|
| SSP1-2.6, 2041–2060 | 211 | 968 | 1,512 |
| SSP5-8.5, 2041–2060 | 216 | 1,100 | 1,567 |
| SSP1-2.6, 2061–2080 | 212 | 993 | 1,544 |
| SSP5-8.5, 2061–2080 | 220 | 1,191 | 1,732 |

Under SSP5-8.5, 2061–2080, 301,674.4 km² are classified as lost suitable area, 77,549.1 km² as persistent, and 66,446.8 km² as gained.

## Reproducibility

On the computer holding the original modelling inputs, in RStudio, set the environment variable STENOCHRU_SDM_PROJECT to the Windows original modelling folder, then source R/12_altitudinal_analysis.R followed by R/13_altitudinal_figure.R from the cloned GitHub repository. The input GeoTIFFs and occurrence CSV files must exist in their original folder structure. Required R packages: terra, geodata, ggplot2, patchwork. The analysis script checks raster geometries, occurrence counts, change-class coding and suitable-area totals.

## Figure 6 caption

**Figure 6. Elevational redistribution of climatic suitability for *Stenochrus portoricensis* in Colombia under current and future climate scenarios.** (A) Proportional distribution of climatically suitable area across elevation bands under current conditions and four future scenario–period combinations (SSP1-2.6 and SSP5-8.5; 2041–2060 and 2061–2080). Percentages are calculated relative to total suitable area within each scenario. (B) Area-weighted median elevation (points) and interquartile range (vertical bars) of areas experiencing loss, persistence or gain of climatic suitability relative to present conditions. Future suitability required agreement by at least two of four CMIP6 GCMs using a fixed 10th-percentile training-presence threshold (0.2123639). Elevation was extracted from WorldClim 2.1 at 2.5 arc-min resolution. The figure shows the elevational redistribution of suitable climatic conditions, not observed upslope dispersal.

## Interpretation and cautions

This is an **upslope redistribution of the mapped climatic suitability footprint**, not evidence of observed migration, elevation preference, future establishment or population decline. Local microclimates and subterranean environments, spatial sampling bias and anthropogenic introductions were not modelled; changes in areas with novel future climates require particular caution. Band proportions are compositional (summing to 100% for each scenario); absolute loss/persistence/gain areas avoid confusing proportional increases with net increases in overall suitability.
