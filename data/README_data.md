# Data provenance and local inputs

We maintain our original GBIF export and large WorldClim source rasters in the local R project and provide the modelling scripts and selected analytical outputs in this GitHub repository.

## Original modelling inputs

We use the following local input names within our R workflow:

- `Stenochrus_portoricensis_GBIF_America_raw.csv`
- `Stenochrus_portoricensis_America_QC_unique.csv`
- `Stenochrus_occ_final_172.csv`
- `Stenochrus_background_M200.csv`
- `WorldClim_2.5m_M200_6vars.tif`

We keep the WorldClim 2.1 global BIO source TIFFs at 2.5 arc-min resolution under local `data/worldclim/wc2.1_2.5m_bio/`. We preserve their original grids and masks for reproducibility.

## Environmental-cell exclusion

We originally retained **172** unique occurrence grid-cell records in `Stenochrus_occ_final_172.csv`. We excluded GBIF key `4923620954` because its cell has missing WorldClim values, yielding **171** effective presences in ENMeval.

## Wallace and sampling-effort outputs

We provide exported Wallace evaluation tables under `wallace/RunA`, `wallace/RunB` and `wallace/Final` where included in the repository. We archived the original user-supplied sampling-effort GeoTIFF, CSV and RDS products under [results/sampling_bias/original_outputs_2026-10-08](../results/sampling_bias/original_outputs_2026-10-08/). This is a documented set of products from the local analysis, not a replacement for the complete WorldClim source dataset.
