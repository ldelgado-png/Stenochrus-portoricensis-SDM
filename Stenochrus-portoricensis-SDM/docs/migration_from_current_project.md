# Migration from the current Windows project

Current working project during development:

`D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis/`

Recommended copy/move targets for the GitHub repository:

| Current file | Repository destination | Commit to Git? |
|---|---|---|
| `data/Stenochrus_portoricensis_GBIF_America_raw.csv` | `data/processed/` | Yes, if licensing/size are acceptable |
| `data/Stenochrus_portoricensis_America_QC_unique.csv` | `data/processed/` | Yes |
| `data/Stenochrus_occ_final_172.csv` | `data/processed/` | Yes |
| `data/Stenochrus_background_M200.csv` | `data/processed/` | Usually yes if reasonably small |
| `data/Stenochrus_background_M200.rds` | `data/processed/` | No (ignored) |
| `data/WorldClim_2.5m_M200_6vars.tif` | `data/rasters/` | No (ignored) |
| `data/worldclim/.../*.tif` | local `data/worldclim/` | No (ignored) |
| Wallace RunA/RunB evaluation CSVs | `wallace/RunA`, `wallace/RunB` | Yes |
| Wallace session `.rds` | same folder locally | No (ignored) |
| Final model-selection CSVs | `results/model_selection/` | Yes |
| Permutation importance CSV | `results/variable_importance/` | Yes |
| Final PNG/PDF figures | `figures/` | Yes, if size is reasonable |

After copying files, run `R/00_setup.R` and then each numbered script. Adjust only local file paths when necessary; avoid changing analytical settings if the goal is exact reproducibility.
