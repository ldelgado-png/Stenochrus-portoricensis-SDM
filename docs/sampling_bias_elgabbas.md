# El-Gabbas (2026): sampling-effort bias sensitivity protocol

**Status (2026-10-08): source and experimental decisions verified; scripts published, but original raster download, M200 diagnostics, background refits and Colombia projections have NOT been run here.** Do not report numerical differences in AICc, AUC, coefficients, suitable area, or maps until the original local project has run the experiments and exported results.

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
- Schizomida is comparatively sparse globally (~3,050 raw observations, 115 species retained after cleaning per Table 1). Whole-class Arachnida pools taxa with different observation processes and is **a control**, not a better default proxy.

## Prespecified experimental design

1. **Baseline:** preserve the saved ENMeval analysis `data/ENMeval_Stenochrus_M200_SWD.rds` with 171 spatially deduplicated American presences, six original WorldClim predictors, operational M200, and the original 9,987 uniform-background points. Never replace it silently.
2. **Spatial scale:** download cumulative 5 km Schizomida `n_obs`, Arachnida `n_obs` and Schizomida `n_sp`; align without interpolation of counts (nearest-neighbour only when pixel origins differ) to the original 2.5 arc-min WorldClim M200 raster, preserving the original environmental/sea mask. Examine the sampled-cell and presence-cell coverage. Rasters describe GBIF observation outcomes, **not probability of ecological absence**.
3. **Zero effort:** do not simply exclude all zero cells, because zero means no GBIF records and is not an unsuitable background cell. Use weights `log1p(n_obs) + epsilon`; `epsilon = 0.01 * median(log1p(n_obs[n_obs > 0]))` for the primary scenario and 0.05 for floor sensitivity, calculated over original eligible M200 cells. No zero cell has literally zero probability in these scenarios. This is an explicit modelling choice rather than a setting imposed by the author.
4. **Background treatments:** (a) saved uniform original; (b) Schizomida `n_obs` with 1% weight floor; (c) Schizomida with 5% floor; (d) Arachnida `n_obs` with 1% floor. All use 9,987 distinct eligible climate cells excluding occupied presences and reproducible random seeds. Inspect how many original presence cells lie at zero Schizomida effort before interpreting the correction. Beware that the published Schizomida raster may contain occurrences of the focal species itself (potential self-inclusion).
5. **Target-group background:** where possible obtain quality-controlled independent GBIF Schizomida occurrences **excluding Stenochrus portoricensis**, with 1980–2025 dates and provenance. Thin to one independent cell per WorldClim raster grid inside M200. Treat it as a strictly defined target-group treatment only if sufficient non-focal grid cells exist for a fair matched-size design; otherwise report it as infeasible rather than using focal points or equating sparse footprints to true independent background observations.
6. **Temporal control:** cumulative 1980–2025 is the primary analysis to maximise Schizomida coverage. Before defining a 2010–2025 secondary period, audit `year`/`eventDate` among the original 171 modelling presences. If the dated fraction and sampled footprint are adequate, sum **annual `n_obs` rasters** for 2010–2025; never treat the archive's “total” raster as the recent-period raster. The year choice is not evidence of the focal occurrence-year distribution until that distribution is checked.
7. **Model tuning:** retain 40 Maxnet candidates (FC = L, LQ, H, LQH, LQHP; RM = 0.5 to 4 in 0.5 increments), `partitions = "block"`, `validation.bg = "partition"`, same 171 presences, six predictors and M200. Verify that occurrence fold labels are unchanged. Record all sampling seeds. Compare minimum AICc, ΔAICc and Akaike weights **within each background treatment**. Do not compare raw AICc or uncalibrated AUC across different background realizations as if they shared one identical likelihood/reference distribution.
8. **Colombia transfer:** project best model of each treatment on the **same country raster grid** with `cloglog` and clamping; save full prediction rasters. Compare rank correlation, prediction difference, suitable-area extent, and overlaps. The primary binary comparison will use each treatment's own current 10TP threshold (fixed within treatment for future CMIP6 projections); a fixed-reference-threshold comparison is a distinct scale-sensitivity check, not biologically equivalent prevalence. Where future CMIP6 stacks are available, project each treatment under the same four GCMs, two SSPs and time periods and recompute gain, loss and persistence.
9. **Interpretation:** changing the sampling weights changes the environmental reference distribution and may alter Maxnet response, not just predictions. No direct causal claim that observed model changes arise uniquely from bias correction without accounting for differences among realized background samples and seed replicate variability. Spatial folds are shared, but the background points differ deliberately.

## Implementation

- [R/16_sampling_effort_prepare.R](../R/16_sampling_effort_prepare.R): retrieves three original GeoTIFF surfaces from OSF via `ecokit`, aligns to original M200, reports effort coverage and intersection with presences.
- [R/17_sampling_bias_models.R](../R/17_sampling_bias_models.R): builds four background treatments and optional independent target-group candidates; writes background CSVs; requires `RUN_MODELS <- TRUE` to execute the full 40-candidate tuning per alternative; if an original Colombia six-variable raster is available, projects selected models and computes basic metrics.
- The original local M200 raster expected by these scripts is `WorldClim_2.5m_M200_6vars.tif` somewhere inside the project's `data/` folder. The original selected model and old background are loaded from `data/ENMeval_Stenochrus_M200_SWD.rds` (the actual RDS filename confirmed by the author).

## Pendientes (español)

- [ ] Ejecutar las descargas OSF y documentar versiones, geometría, porcentaje de celdas con esfuerzo positivo y cobertura de presencias en M200 para Schizomida y Arachnida; conservar salidas.
- [ ] Auditar fechas de las 171 presencias; decidir si tiene sentido el análisis temporal secundario 2010–2025.
- [ ] Ajustar modelos alternativos y replicar muestreos ponderados con múltiples semillas; registrar las tablas de selección para cada background.
- [ ] Comprobar si existe un target-group background de Schizomida no focal con cobertura suficiente, o documentar su inviabilidad.
- [ ] Calcular y comparar mapas presentes y futuros de Colombia con los mismos GCMs, periodos, umbrales y máscaras; integrar resultados cuantitativos al manuscrito y depositarlos en GitHub.
