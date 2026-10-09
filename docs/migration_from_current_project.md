# Local-project provenance and repository layout

We developed our analyses using the following local Windows working directory:

`D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis/`

We organize the project around these source and output relationships, which also indicate why some large input files are managed outside the Git repository.

| Local project file or asset | Repository location or documentation | Provenance convention |
|---|---|---|
| `data/Stenochrus_portoricensis_GBIF_America_raw.csv` | `data/processed/` | Original GBIF occurrence input |
| `data/Stenochrus_portoricensis_America_QC_unique.csv` | `data/processed/` | Filtered unique occurrence coordinates |
| `data/Stenochrus_occ_final_172.csv` | `data/processed/` | Environment-grid occurrence subset |
| `data/Stenochrus_background_M200.csv` | `data/processed/` | Original uniformly sampled calibration background |
| `data/Stenochrus_background_M200.rds` | Local original data | R binary working object |
| `data/WorldClim_2.5m_M200_6vars.tif` | Local environmental rasters | M200 WorldClim stack |
| `data/worldclim/.../*.tif` | Local `data/worldclim/` | Source global WorldClim rasters |
| Wallace RunA/RunB exports | `wallace/RunA/`, `wallace/RunB/` | Model evaluation CSV exports |
| Wallace session RDS | Local Wallace folders | Machine-specific session state |
| Model-selection tables | `results/model_selection/` | Selected configuration evaluations |
| Permutation-importance tables | `results/variable_importance/` | Predictor diagnostics |
| Figures | `figures/` | Visual analytical products |
| GBIF sampling-effort background, model and Colombia comparison outputs | `results/sampling_bias/original_outputs_2026-10-08/` | Archived original user-supplied RAR snapshot |

We distinguish the complete local R working environment from the subset of verified and deposited files in GitHub. We preserve analytical settings and spatial inputs when comparing reproductions of our model.
