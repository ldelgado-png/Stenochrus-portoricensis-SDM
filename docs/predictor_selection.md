# Predictor selection: recovered analytical record

## Scope and environmental sample

The final model uses BIO1, BIO2, BIO4, BIO12, BIO14 and BIO15 from WorldClim 2.1 at 2.5 arc-min resolution. The recovered R-console record starts with all 19 bioclimatic variables and distinguishes an initial occurrence-based correlation check from the subsequent environmental sample used for predictor screening.

For the M200 environmental check, the record shows a random sample of 10,000 climate-complete rows across all 19 variables, drawn with `terra::spatSample` and seed 123. The Pearson matrix and subsequent seven-variable VIF calculation both use this environmental sample. It should not be conflated with the 9,987 background cells retained for model fitting.

The sample was drawn during an earlier M200 masking stage. The same console record subsequently replaces the preliminary land mask with the geodesic buffer mask to restore valid coastal climate cells. The historical sample has not been regenerated on the final mask here, and no claim of a new diagnostic run is made.

## Pairwise correlation screening

Pairwise Pearson correlations were calculated with complete observations. The screening criterion was an absolute correlation of at least 0.80. The seven-variable shortlist was BIO1, BIO2, BIO4, BIO5, BIO12, BIO14 and BIO15. These represent annual mean temperature, diurnal range, temperature seasonality, maximum temperature of the warmest month, annual precipitation, precipitation of the driest month and precipitation seasonality.

The original command checking this shortlist returned:

```text
No hay pares con |r| >= 0.80
```

This check concerns pairwise correlations and does not rule out multivariate collinearity.

## VIF calculation

The record shows 10,000 complete rows and seven columns in `env_vif`. A custom R function fitted a linear model for each candidate using the remaining candidates as predictors, then calculated VIF = 1 / (1 - R²). The recorded calculation does not use an automated `vifstep` or `vifcor` elimination routine.

| Candidate | Recorded VIF in the seven-variable shortlist |
| --- | ---: |
| BIO5 | 44.264905 |
| BIO1 | 41.258879 |
| BIO4 | 10.352137 |
| BIO2 | 8.026073 |
| BIO14 | 4.672059 |
| BIO12 | 4.671783 |
| BIO15 | 2.763944 |

BIO5 had the highest VIF in the shortlist. It is absent from the final six-variable calibration set used by the deposited workflow. The recovered console fragment ends while the seven-variable list still contains BIO5; it does not contain the final removal command or a verified VIF table after that removal. Therefore, the table above must not be described as the final six-variable VIF result. No fixed VIF cutoff of 5 or 10 is asserted.

## Recovered implementation

The following code reproduces the operations documented in the console record, provided the original `bio_M200` object is available. It is an implementation record, not a claim that the diagnostics have been rerun.

```r
set.seed(123)

env_M200_sample <- terra::spatSample(
  bio_M200,
  size = 10000,
  method = "random",
  na.rm = TRUE,
  values = TRUE,
  as.df = TRUE
)

cor_M200 <- stats::cor(
  env_M200_sample,
  use = "complete.obs",
  method = "pearson"
)

candidates <- c("bio1", "bio2", "bio4", "bio5",
                "bio12", "bio14", "bio15")
cor_candidates <- cor_M200[candidates, candidates]
strong_pairs <- which(
  abs(cor_candidates) >= 0.80 & upper.tri(cor_candidates),
  arr.ind = TRUE
)

env_vif <- stats::na.omit(env_M200_sample[, candidates])

calc_vif <- function(values) {
  vapply(names(values), function(variable) {
    others <- setdiff(names(values), variable)
    fitted <- stats::lm(
      stats::reformulate(others, response = variable),
      data = values
    )
    1 / (1 - summary(fitted)$r.squared)
  }, numeric(1))
}

initial_vif <- calc_vif(env_vif)
sort(initial_vif, decreasing = TRUE)
```

## Final modelling inputs and provenance

The modelling record and [environmental-input script](../R/03_environmental_predictors.R) use the six-variable stack `WorldClim_2.5m_M200_6vars.tif`. The retained variables are BIO1, BIO2, BIO4, BIO12, BIO14 and BIO15.

The diagnostic settings and seven-variable values above were recovered from the original September 2026 R-console transcript. They are reported separately from later manuscript summaries and from the fixed six-predictor modelling inputs. Rechecking VIF after excluding BIO5, using the final calibration mask, would complete the numerical diagnostic record.
