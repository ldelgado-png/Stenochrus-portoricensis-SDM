# El-Gabbas (2026): sampling-effort bias sensitivity protocol

**Status (2026-10-08): three original OSF raster products downloaded, aligned and evaluated in the author's local RStudio project. Coverage values were reproduced from the user's R-console output and archived as a provenance-labelled CSV. New weighted-background fitting and Colombia projection comparisons have NOT yet been executed.** Do not report differences in selected Maxnet configurations, AICc, AUC, coefficients, suitable area or future maps until the original project has run the experiments and validated their outputs.

## Original data source

El-Gabbas A (2026). A global, taxon-stratified, high-resolution sampling-effort dataset from GBIF for bias-aware ecological modelling. *Diversity and Distributions* 32(5): e70205. https://doi.org/10.1111/ddi.70205.

- Open Science Framework archive: https://osf.io/hz4sy
- Zenodo dataset: https://zenodo.org/records/17591681
- Author's pipeline: https://github.com/elgabbas/global_sampling_efforts
- Programmatic access: https://github.com/elgabbas/ecokit ; `ecokit::get_sampling_effort()`.
- Version selection: published 2026 global datasets; archive and raster file names should be retained and logged by the local scripts.
- Published rasters are WGS84 / EPSG:4326. The nominal **5 km grid is exactly 2.5 arc-min (0.0416667°)**, matching the native angular resolution of WorldClim 2.1 at 2.5 arc-min. Verify pixel origins/alignment explicitly rather than assuming every grid aligns.
- Taxonomic data: `group="arachnida", descendants="schizomida"` (order-level), and `group="arachnida", descendants="all"` (whole class).
- Metrics: observation count `n_obs` (primary effort proxy) and species count `n_sp` (secondary coverage diagnostic).
- Cumulative `years="total"` spans 1980–2025. The source excluded records before 1980, used coordinate-quality checks distinct from the focal-species pipeline, and assigned true zero for cells without retained GBIF records.
- Schizomida is comparatively sparse globally (~3,050 records reported for Schizomida after the study's data screening (verify counts against Table 1 before quantitative comparison), 115 recorded species per Table 1). Whole-class Arachnida pools taxa with different observation processes and is **a control**, not a better default proxy.

## Observed empirical coverage in the original M200 (2026-10-08)

Original 5-km rasters were retrieved through `ecokit::get_sampling_effort()` and aligned with the six-variable WorldClim 2.5-arc-min M200 template; all three datasets had **136,111 valid M200 climate cells** and valid effort values at **all 171 focal presence coordinates**. This is the actual result of the user's successful `R/16_sampling_effort_prepare_v2.R` console run, not a fitted-model comparison.

| Effort surface | Cells > 0 / 136,111 | Fraction of M200 cells | Focal presence cells > 0 / 171 | Maximum cell count |
|---|---:|---:|---:|---:|
| Schizomida `n_obs` | **206** | **0.1513471%** | **113 (66.08%)** | 21 |
| Arachnida `n_obs` | **21,711** | **15.9509518%** | **159 (92.98%)** | 12,712 |
| Schizomida `n_sp` | **160** | **0.1175511%** | **112 (65.50%)** | 4 |

Original filenames: `n_obs_Schizomida_total_res_5.tif`, `n_obs_Arachnida_res_5.tif`, and `n_sp_Schizomida_total_res_5.tif`. Provenance: the author's R console, 2026-10-08. The machine-readable numbers are recorded in [effort_coverage_diagnostics_console_2026-10-08.csv](../results/sampling_bias/effort_coverage_diagnostics_console_2026-10-08.csv), transcribed from console output; the three original TIFFs remain in the local project.

**Crucial identifiability/feasibility issue.** The original modelling dataset has 171 distinct WorldClim presence cells, 113 of which overlap Schizomida positive-effort cells. The intended weighted-background method draws 9,987 **distinct cells excluding those presence cells**. Accordingly, at most **206 − 113 = 93** eligible Schizomida-positive cells remain, or **0.93% of the proposed 9,987 backgrounds** (if every eligible positive cell were selected). Such an almost entirely zero-effort background would not closely match the observed taxon-specific sampling process. This bound should be checked against the original raster directly using [R/18_effort_feasibility_and_dates.R](../R/18_effort_feasibility_and_dates.R) and must not be misinterpreted as zero species occurrence.

**Decision following diagnostic:** retain the original uniform background as primary analysis; treat Schizomida effort-weighted sampling with 1% and 5% probability floors as *exploratory stress tests only*, clearly labelling focal-species self-inclusion/circularity risk. Use the more spatially extensive but taxonomically heterogeneous Arachnida surface as a complementary bias sensitivity analysis, not as a definitive correction. Investigate a non-focal Schizomida target-group set independently before using it for confirmatory inference.

## Prespecified experimental design

1. **Baseline:** preserve the saved ENMeval analysis `data/ENMeval_Stenochrus_M200_SWD.rds` with 171 spatially deduplicated American presences, six original WorldClim predictors, operational M200, and the original 9,987 uniform-background points. Never replace it silently.
2. **Spatial scale:** download cumulative 5 km Schizomida `n_obs`, Arachnida `n_obs` and Schizomida `n_sp`; align without interpolation of counts (nearest-neighbour only when pixel origins differ) to the original 2.5 arc-min WorldClim M200 raster, preserving the original environmental/sea mask. Examine the sampled-cell and presence-cell coverage. Rasters describe GBIF observation outcomes, **not probability of ecological absence**.
3. **Zero effort:** do not simply exclude all zero cells, because zero means no GBIF records and is not an unsuitable background cell. Use weights `log1p(n_obs) + epsilon`; `epsilon = 0.01 * median(log1p(n_obs[n_obs > 0]))` for the primary scenario and 0.05 for floor sensitivity, calculated over original eligible M200 cells. No zero cell has literally zero probability in these scenarios. This is an explicit modelling choice rather than a setting imposed by the author.
4. **Background treatments:** (a) saved uniform original (**retained primary inference**); (b) Schizomida `n_obs` with 1% weight floor; (c) Schizomida with 5% floor; (d) Arachnida `n_obs` with 1% floor. All use 9,987 distinct eligible climate cells excluding occupied presences and reproducible random seeds. **At the observed coverage level, at most ~93 of the 9,987 Schizomida-weighted background cells can have positive effort after removing focal presence cells; consequently this is an exploratory stress test, not an automatically valid bias correction.** Beware that the published Schizomida raster may contain occurrences of the focal species itself (potential self-inclusion).
5. **Target-group background:** where possible obtain quality-controlled independent GBIF Schizomida occurrences **excluding Stenochrus portoricensis**, with 1980–2025 dates and provenance. Thin to one independent cell per WorldClim raster grid inside M200. Treat it as a strictly defined target-group treatment only if sufficient non-focal grid cells exist for a fair matched-size design; otherwise report it as infeasible rather than using focal points or equating sparse footprints to true independent background observations.
6. **Temporal control:** cumulative 1980–2025 is the primary analysis to maximise Schizomida coverage. Before defining a 2010–2025 secondary period, audit `year`/`eventDate` among the original 171 modelling presences. If the dated fraction and sampled footprint are adequate, sum **annual `n_obs` rasters** for 2010–2025; never treat the archive's “total” raster as the recent-period raster. The year choice is not evidence of the focal occurrence-year distribution until that distribution is checked.
7. **Model tuning:** retain 40 Maxnet candidates (FC = L, LQ, H, LQH, LQHP; RM = 0.5 to 4 in 0.5 increments), `partitions = "block"`, `validation.bg = "partition"`, same 171 presences, six predictors and M200. Verify that occurrence fold labels are unchanged. Record all sampling seeds. Compare minimum AICc, ΔAICc and Akaike weights **within each background treatment**. Do not compare raw AICc or uncalibrated AUC across different background realizations as if they shared one identical likelihood/reference distribution.
8. **Colombia transfer:** project best model of each treatment on the **same country raster grid** with `cloglog` and clamping; save full prediction rasters. Compare rank correlation, prediction difference, suitable-area extent, and overlaps. The primary binary comparison will use each treatment's own current 10TP threshold (fixed within treatment for future CMIP6 projections); a fixed-reference-threshold comparison is a distinct scale-sensitivity check, not biologically equivalent prevalence. Where future CMIP6 stacks are available, project each treatment under the same four GCMs, two SSPs and time periods and recompute gain, loss and persistence.
9. **Interpretation:** changing the sampling weights changes the environmental reference distribution and may alter Maxnet response, not just predictions. No direct causal claim that observed model changes arise uniquely from bias correction without accounting for differences among realized background samples and seed replicate variability. Spatial folds are shared, but the background points differ deliberately.

## Implementation

- [R/16_preflight_sampling_bias.R](../R/16_preflight_sampling_bias.R): **read-only local preflight**, confirms exact original ENMeval RDS, required packages, filenames of existing M200/Colombia climate rasters and any existing effort outputs; run this before attempting downloads.
- [R/16_sampling_effort_prepare.R](../R/16_sampling_effort_prepare.R): retrieves three original GeoTIFF surfaces from OSF via `ecokit`, aligns to original M200, reports effort coverage and intersection with presences.
- [R/17_sampling_bias_models.R](../R/17_sampling_bias_models.R): builds four background treatments and optional independent target-group candidates; writes background CSVs; requires `RUN_MODELS <- TRUE` to execute the full 40-candidate tuning per alternative; if an original Colombia six-variable raster is available, projects selected models and computes basic metrics.
- Important: the repository's original R/17 script previously calculated a training 10TP by extracting only from the Colombian prediction raster; this has been **corrected** to model predictions at all 171 calibration points to avoid regional subset bias.
- The original local M200 raster expected by these scripts is `WorldClim_2.5m_M200_6vars.tif` somewhere inside the project's `data/` folder. The original selected model and old background are loaded from `data/ENMeval_Stenochrus_M200_SWD.rds` (the actual RDS filename confirmed by the author).

## Pendientes (español)

- [x] Descargar los tres rásteres originales OSF, alinearlos a WorldClim M200 y documentar proporciones de celdas positivas y cobertura de las 171 presencias, con nombres de archivo; resultados de consola archivados en GitHub. [PENDIENTE] Depositar rásteres o un manifiesto de checksums y confirmar versión exacta del archivo OSF.
- [ ] Ejecutar [R/18_effort_feasibility_and_dates.R](../R/18_effort_feasibility_and_dates.R) y comprobar los recuentos de celdas positivas elegibles por background tras excluir presencias; auditar las fechas de 171 presencias para evaluar si procede 2010–2025.
- [ ] Tras revisar viabilidad y circularidad, decidir qué ajustes alternativos son defendibles, replicar muestreos con varias semillas, conservar la referencia uniforme, evaluar las 40 configuraciones por tratamiento y registrar resultados. No ejecutar automáticamente el script 17 sin revisar antes los diagnósticos.
- [ ] Comprobar si existe un target-group background de Schizomida no focal con cobertura suficiente, o documentar su inviabilidad.
- [ ] Calcular y comparar mapas presentes y futuros de Colombia con los mismos GCMs, periodos, umbrales y máscaras; integrar resultados cuantitativos al manuscrito y depositarlos en GitHub.
