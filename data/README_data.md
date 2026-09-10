# Data manifest

This repository intentionally does not version large WorldClim rasters or binary R/Wallace session files.

## Expected local input files

The scripts refer to the following files generated during the project. Place them under `data/processed/` (or adapt `R/00_setup.R` to your local layout):

- `Stenochrus_portoricensis_GBIF_America_raw.csv`
- `Stenochrus_portoricensis_America_QC_unique.csv`
- `Stenochrus_occ_final_172.csv`
- `Stenochrus_background_M200.csv`
- `WorldClim_2.5m_M200_6vars.tif` (ignored by Git)

WorldClim 2.1 2.5 arc-min global BIO TIFFs are expected under a local `data/worldclim/wc2.1_2.5m_bio/` directory and are ignored by Git.

## Important distinction

`Stenochrus_occ_final_172.csv` contains 172 unique environmental-cell records, but the effective modelling set is **171** because GBIF key `4923620954` falls in a WorldClim NA cell and is excluded from ENMeval.

## Wallace

Small exported CSV evaluation tables may be versioned under `wallace/RunA`, `wallace/RunB`, and `wallace/Final`. Wallace `.rds` session files are ignored because they can be large and machine-specific.
