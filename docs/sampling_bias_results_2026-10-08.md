# Sampling-effort sensitivity: verified results from 8 October 2026

**Taxon:** *Stenochrus portoricensis* (Schizomida: Hubbardiidae). **Calibration:** Americas, M200, 171 unique occurrence cells, six WorldClim 2.1 variables (BIO1, BIO2, BIO4, BIO12, BIO14, BIO15), 9,987 unique background cells per treatment. **Software:** R 4.6.1, terra 1.9.46, ENMeval 2.0.5.2, maxnet 0.1.4. **Effort source:** El-Gabbas (2026), cumulative GBIF 1980–2025 sampling-effort products at 2.5 arc-min (approx. 5 km near the equator), doi:10.1111/ddi.70205.

> **Provenance:** The numerical results below are transcribed from the author's R console outputs (diagnostics 18–24) shared on 8 October 2026. The fitted ENMeval RDS objects, selected-background CSVs, prediction GeoTIFFs and original effort rasters are held in the author's local `D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis/results/sampling_bias` directory. This report is **not** a claim that those binaries were uploaded to GitHub. Re-run/independent comparison of the archived binaries remains outstanding.

## 1. Eligible calibration cells and effort coverage

The three source rasters aligned geometrically (1,525 × 1,777 cells, WGS84 EPSG:4326; 0.04166667°). Within the 136,111 environmentally valid M200 cells, counts of positive-effort cells were 21,711 for `Arachnida_nobs`, 206 for `Schizomida_nobs`, and 160 for `Schizomida_nsp`. After excluding 171 focal presence cells, 135,940 candidate background cells remained; their corresponding positive-effort counts were **21,552 (15.854%)**, **93 (0.0684%)**, and **48 (0.0353%)**. The original uniform background had positive effort in 1,499 Arachnida cells and only three Schizomida cells.

Because sampling 9,987 *distinct* cells without replacement can capture at most 93 eligible Schizomida-positive cells, Schizomida-weighted backgrounds are **exploratory** rather than an established bias correction. The published Arachnida surface may also include focal-species observations, so taxonomic independence has not been established; a true target-group background would require independently quality-controlled, non-focal Schizomida records.

The original dated-occurrence audit recovered 167 usable collection years among the 171 effective presences: 27 before 1980, 136 in 1980–2025, four in 2026 and four without a usable year (97 dated 2010–2025). This temporal mismatch with the effort rasters remains a limitation. These groups partition 171 source records and are not a temporal refit.

## 2. Background selection and sampling intensity

Sampling weights were defined as `log1p(n_obs) + floor_fraction * median(log1p(n_obs)[n_obs > 0])`; each sample contains 9,987 unique environmentally valid cells and excludes all focal presence cells. Schizomida sampling with a 1% floor selected all 93 eligible positive cells in each of five seeds; with a 5% floor, 75–83 positive cells. Arachnida with a 1% floor selected 9,347–9,410 positive cells in five seeds.

Spatial concentration was assessed as the inverse Simpson effective count over 1° blocks, plus the percentage of sampled points in the ten highest-count blocks; environmental shifts are means in units of baseline (uniform-background) SD.

| Treatment | Seed / summary | Arachnida-positive BG | Effective 1° blocks | Top ten blocks | BIO4 shift (SD) |
|---|---|---:|---:|---:|---:|
| Uniform original | existing baseline | 15.01% | 278.6 | 5.59% | 0.000 |
| Schizomida floor 0.01 | selected background | 17.09% | 280.6 | 5.33% | +0.040 |
| Schizomida floor 0.05 | selected background | 16.74% | 277.6 | 5.49% | +0.037 |
| Arachnida floor 0.01 | selected background | 94.01% | 133.5 | 17.44% | +0.482 |
| Arachnida floor 0.05 | five-seed mean (123–127) | 77.650% | 161.94 | 15.240% | +0.4026 |
| Arachnida floor 0.10 | five-seed mean (123–127) | 65.884% | 190.10 | 13.146% | +0.3386 |
| Arachnida floor 0.20 | five-seed mean (123–127) | 52.670% | 221.74 | 10.992% | +0.2686 |

Selected alternative backgrounds were **Arachnida floor 0.10** and **Arachnida floor 0.20**, using seed **125**, giving 9,987 unique cells each. Exact seed-125 diagnostics: 0.10, 65.89% positive, 189.5 effective blocks, top-ten 13.03%; 0.20, 52.85% positive, 223.5 effective blocks, top-ten 10.82%. The 0.20 floor is the preferred *descriptive sensitivity* scenario based on less concentration; it has **not** been validated as the optimal correction of sampling bias.

## 3. Model fitting: 40 candidates per scenario

The original uniform ENMeval object was reused; 40 new Maxnet candidate settings each were fitted for Arachnida floors 0.10 and 0.20 (**80 new fits; 120 candidates considered including the original 40**). Presences (171), six predictors, block orientation `lat_lon`, validation background mode `partition`, FC grid L/LQ/H/LQH/LQHP, and RM grid 0.5–4 in 0.5 steps were held consistent. The occurrence fold labels matched the original.

| Background | Best FC | RM | AICc within run | Mean validation AUC | Mean absolute fold AUC difference | Mean 10% omission | Non-zero coefficients |
|---|---|---:|---:|---:|---:|---:|---:|
| Uniform original | LQHP | 1 | 2912.104 | 0.7415053 | 0.1110438 | 0.1046512 | 31 |
| Arachnida floor 0.10 | LQHP | 1 | 2882.623 | 0.7519602 | 0.1124150 | 0.1104651 | 28 |
| Arachnida floor 0.20 | LQHP | 1 | 2894.033 | 0.7455467 | 0.1130777 | 0.1104651 | 27 |

**All three treatments selected LQHP/RM1.** The AICc values are provided for auditing **within each different-background candidate set only**, not for comparing AICc across treatments. Validation AUC values also use different background samples and do not by themselves establish predictive superiority.

## 4. Present-day projection to Colombia

The three selected full-data models were projected with cloglog output to the same six-variable WorldClim 2.1 Colombian grid (483 rows × 360 columns, WGS84, 2.5 arc-min). Each model's 10th-percentile training-presence (10TP) threshold was calculated from the **171 calibration presences**, not only the Colombian subset. Areas used latitude-adjusted cell areas in km².

| Background | Own 10TP | Suitable km² (own threshold) | Change vs uniform | Spearman vs uniform | Mean absolute cloglog difference | Suitable km² with uniform numerical threshold 0.21236 |
|---|---:|---:|---:|---:|---:|---:|
| Uniform original | 0.21236 | 379,223.5 | reference | 1.0000 | 0.00000 | 379,223.5 |
| Arachnida floor 0.10 | 0.19989 | 422,979.4 | +11.54% | 0.9620 | 0.03734 | 393,140.2 |
| Arachnida floor 0.20 | 0.18610 | 445,692.1 | +17.53% | 0.9757 | 0.03044 | 392,286.4 |

The own-threshold gains were +43,755.9 km² for floor 0.10 and +66,468.6 km² for floor 0.20. At the **fixed numerical baseline threshold**, increases were +3.67% and +3.44% respectively. Because cloglog scales need not be equally calibrated across backgrounds, the shared numeric threshold is a **sensitivity probe**, not a calibrated comparison of probability or occupancy.

## 5. Binary overlap at each model's own 10TP

| Alternative | Gain km² | Loss km² | Intersection km² | Jaccard |
|---|---:|---:|---:|---:|
| Arachnida floor 0.10 | 61,573.03 | 17,817.13 | 361,406.4 | 0.8199 |
| Arachnida floor 0.20 | 72,626.38 | 6,157.83 | 373,065.7 | 0.8256 |

The suitability rankings remain strongly concordant, while threshold-dependent area assignments are appreciably sensitive to the background treatment and 10TP definition. This is a descriptive spatial comparison, **not** evidence of spread, colonisation, or corrected ecological accuracy.

## 6. Common-background spatial validation (diagnostic 25)

A four-fold spatial-block comparison with a **single common evaluation background** was completed after the preceding analyses. Using the original 171 occurrences and spatial-fold assignments, 9,987 eligible and unique background cells were sampled with seed `20261008` after removing the presence and background training cells from all three background treatments. Twelve fold-specific Maxnet models were fitted (3 treatments × 4 folds), with the shared LQHP feature class and RM = 1. Evaluation used the same withheld occurrence fold and the same common background fold for all three treatments; training-presence predictions defined a fold-specific 10TP omission threshold. This is spatial cross-validation, not a new external presence test; the tuning choices had already been made on the focal dataset.

| Treatment | Mean AUC, shared evaluation BG | Mean omission at 10TP | Mean paired AUC difference vs uniform |
|---|---:|---:|---:|
| Uniform original | **0.7417520** | 0.1104651 | Reference |
| Arachnida floor 0.10 | 0.7077332 | 0.1104651 | **−0.03401889** |
| Arachnida floor 0.20 | 0.7116284 | 0.1104651 | **−0.03012365** |

Unlike the background-dependent mean validation AUCs in diagnostic 22, this shared-background comparison favors the **uniform** treatment. The lower mean AUC of both weighted backgrounds does not establish the universal superiority of a uniform background, because the study uses one shared background realization, four spatial folds, and an evaluation-background distribution that does not necessarily reproduce presence-recording effort. No formal significance test or completely independent external evaluation was undertaken. The three mean 10TP omission rates were identical.

**Source and reproducibility:** [Diagnostic-25 console-transcribed summary](../results/sampling_bias/common_background_validation_console_2026-10-08.csv) documents the user's completed local R console output. The RAR supplied in this conversation predates completion of the 25th diagnostic; it contains the common evaluation background and only eight stored fold-model objects (four uniform, four Arachnida 0.10), but not the four Arachnida 0.20 objects or the three final evaluation tables. Those are not yet present in the supplied archive. The diagnostic is **analytically complete** and its full artifact deposit is **pending**.

## 7. Open analyses (write-up checklist in Spanish)

- [COMPLETADO] Ejecutado el diagnóstico 25: validación espacial de cuatro pliegues con fondo de evaluación común, AUC uniforme 0,7417520; Arachnida 0,10 = 0,7077332; Arachnida 0,20 = 0,7116284. [PENDIENTE DE ARCHIVO] Incorporar CSV originales de resultados y los cuatro objetos RDS de Arachnida 0,20 que no estaban en el RAR anterior.
- [PENDIENTE] Evaluar independencia taxonómica de Arachnida y viabilidad de un *target-group background* de Schizomida sin *S. portoricensis*; evaluar sensibilidad temporal 1980–2025 por separado de los 171 registros originales.
- [PENDIENTE] Proyectar escenarios futuros con los modelos ponderados únicamente con los mismos GCM, SSP, periodos, máscaras y criterios empleados en el escenario uniforme.
- [PENDIENTE DE ARCHIVO] Depositar en GitHub los CSV originales, GeoTIFF y RDS aportados por el usuario, conservar sus checksums y completar los cuatro modelos de Arachnida 0,20 del diagnóstico 25; los resultados de consola siguen diferenciados de los archivos originales.
- [PENDIENTE] Examinar visualmente los mapas de ganancias/pérdidas y posible concentración geográfica del sesgo. No inferir relevancia regional específica sin inspección cartográfica.

## Files currently on the author's local machine

`results/sampling_bias/diagnostico20_arachnida_semillas.csv`, `diagnostico20_arachnida_resumen.csv`, `background_Arachnida_floor10.csv`, `background_Arachnida_floor20.csv`, `ENMeval_Arachnida_floor10_40models.rds`, `ENMeval_Arachnida_floor20_40models.rds`, `model_selection_Arachnida_new.csv`, `best_models_Arachnida_new.csv`, `fixed_LQHP_RM1_Arachnida_new.csv`, and `Colombia_comparison_3backgrounds/Colombia_projection_comparison.csv`, `Diagnostico24_solapamiento.csv`, three prediction rasters and four difference/change rasters.

**Associated methodology and reproducible partial scripts:** [sampling_bias_elgabbas.md](sampling_bias_elgabbas.md), [R/17_sampling_bias_models.R](../R/17_sampling_bias_models.R), [R/18_effort_feasibility_and_dates.R](../R/18_effort_feasibility_and_dates.R), [R/19_arachnida_bias_pilot.R](../R/19_arachnida_bias_pilot.R). Scripts 20–25 from the interactive session are not yet committed as standalone .R files and should not be presented as archived reproducible scripts.
