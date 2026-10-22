# Pre-submission editorial verification — NeoBiota — 21 October 2026

## Editorial scope and decision

The current Google Docs manuscript is **not submitted**. It reports the completed uniform M200 Maxnet model and 16 CMIP6 future projections, with two Arachnida effort-weighted background treatments tested on present-day Colombia and on a shared internal spatial-validation background. **No more exploratory modelling is necessary to state the current central conclusions**, provided the authors accept the uncertainty and study limitations already acknowledged. Scripts 27–30 remain optional ancillary analyses unless results are run, inspected, and explicitly incorporated into a revised hypothesis.

Manuscript: https://docs.google.com/document/d/1JC-1iCdGGdJp2VIWMzM2boqaT-S8CJDtTWrIlNlqjIs/edit

We corrected evident manuscript assembly errors (duplicated introductory/methodological sections, broken future-climate text, the ODMAP phrasing, coordinate-QC prose and model-tuning prose). We added the original implementation citation for MOP: Cobos et al. (2024), https://doi.org/10.21425/fob.17.132916. The previously hidden co-author contact chips were converted to five explicit author names, preserving their original order in the Google Doc. **Author approval of the five-author list and all affiliations remains essential.**

## Actual remaining blockers for a submission package

- [ ] **Authorship metadata:** confirm the five names and order, corresponding author and email, all five institutional affiliations, ORCID identifiers and contributions. The manuscript currently shows only one university affiliation; do not infer institutions for other authors from email addresses. The name "Victor Hugo Garcia Merchan" was transcribed from the embedded contact chip and its preferred accents/spelling need author confirmation.
- [ ] **Figure 1:** no public image is currently archived in `figures/calibration/` (only a `.gitkeep`). [R/31_figure1_calibration_map.R](../R/31_figure1_calibration_map.R) now generates PNG (400 dpi), LZW-compressed TIFF (600 dpi) and vector PDF from the original 234 quality-controlled American coordinates and 200-km accessible area. **The generated figure must be viewed and its exported files deposited/attached; do not mark complete until verified.**
- [ ] **Figures 2–6:** public PNG files are present, but do not equate their presence or filename with print-resolution quality. Inspect pixel dimensions and legends, check numbering, and retain/source editable originals. Figures 3 and 4 are comparatively small files and should be manually reviewed before submission.
- [ ] **Figure/caption correspondence:** manuscript currently provides legends for Figures 1–6 but only two embedded images. Ensure the review DOCX or the submission system includes all six figures in the intended order. Supplementary captions/tables should be attached separately as required.
- [ ] **Additional information:** finalise CRediT contributions, funding (including confirmation if none), conflicts of interest, correspondence, acknowledgements and all author permissions. Pensoft's current editorial policy requires declaration of AI assistance; the manuscript already includes one, but authors must verify its accuracy.
- [ ] **ODMAP:** verify/provide the promised completed supplementary ODMAP Table S1 if it is retained in the Methods. Cross-check access dates, GBIF download DOI, software versions, Maxnet fitting details, climate scenario provenance, MOP settings, backgrounds, validation folds, limitations and licenses.
- [ ] **Licenses/data:** review GBIF occurrence-level licensing and provenance plus the El-Gabbas CC BY 4.0 raster attribution. If an archived Zenodo DOI is desired, mint it for a frozen repository release rather than presenting a mutable branch as an immutable version.
- [ ] **Export:** export the Google Doc to Word DOCX, inspect equations/Unicode, names, superscripts, images, heading hierarchy, citation consistency and figure page fit; perform a final language and reference check.
- [ ] **Journal guidelines:** follow NeoBiota's current author-submission portal and final requirements (journal web page may be blocked to automated inspection), rather than assuming another Pensoft title has identical format/APC or supplementary instructions.
- [ ] **Cover letter:** prepare after author list is approved; emphasise the invasive Schizomida context, controlled background sensitivity, common-reference validation and cautious interpretation of future climate transfer.

## Figure inventory verified from the public repository

| Figure | Manuscript subject | GitHub status on 2026-10-21 |
|---|---|---|
| 1 | American occurrences and M200 | **Missing actual image**; new script `R/31_figure1_calibration_map.R` prepared |
| 2 | Current Colombian suitability | `figures/colombia/Stenochrus_Colombia_LQHP_RM1_FINAL_400dpi_fixed.png` present |
| 3 | Conditional response curves | `figures/response_curves/response_curves_lqhp_rm1.png` present (inspect small file) |
| 4 | Environmental dissimilarity/MOP | `figures/mop/mop_dissimilarity_colombia.png` present (inspect small file) |
| 5 | Four-GCM climate novelty/suitability consensus | `figures/colombia/Figure_future_NAC_suitability_consensus.png` present |
| 6 | Elevational redistribution | `figures/altitude/Figure_altitudinal_redistribution_FINAL.png` present |

## Key results retained without numerical change

- 171 American presence cells, 9,987 original M200 background cells; original selected feature classes LQHP, RM1.
- Uniform current suitable extent: **379,223.5 km²** of Colombia at original training 10TP.
- Arachnida-weighted current suitable extents: **422,979.4** and **445,692.1 km²** at their own 10TP thresholds; these are sensitivity contrasts.
- Four-fold common-background mean AUC: **0.7417520** uniform versus **0.7077332** (floor 0.10) and **0.7116284** (floor 0.20). These are internal fold results, not external validation.
- The original uniform-background future climate experiments (16 combinations) report ≥2/4 GCM consensus suitable-area contraction of **61.95–63.40%**; do not extrapolate that percentage to weighted models without performing their future projections.

**Release gate:** a submission-ready DOCX and full figure package should not be labelled final until the authorship/affiliation details and Figure 1/figure-quality checks above are complete.
