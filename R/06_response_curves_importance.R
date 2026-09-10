# 06_response_curves_importance.R ----------------------------------------
# Conditional one-variable response curves + permutation importance.

source("R/00_setup.R")
source("R/03_environmental_predictors.R")
source("R/04_background_sampling.R")

mod_file <- file.path(paths$results, "model_selection", "maxnet_LQHP_RM1.rds")
stopifnot(file.exists(mod_file))
mod_best <- readRDS(mod_file)

medianas <- vapply(occs_swd[, vars_final], median, numeric(1), na.rm = TRUE)

labels <- c(
  bio1 = "BIO1 - Annual mean temperature (°C)",
  bio2 = "BIO2 - Mean diurnal range (°C)",
  bio4 = "BIO4 - Temperature seasonality (SD × 100)",
  bio12 = "BIO12 - Annual precipitation (mm)",
  bio14 = "BIO14 - Precipitation of driest month (mm)",
  bio15 = "BIO15 - Precipitation seasonality (CV)"
)

response_one <- function(variable) {
  rng <- seq(
    min(occs_swd[[variable]], na.rm = TRUE),
    max(occs_swd[[variable]], na.rm = TRUE),
    length.out = 200
  )
  nd <- as.data.frame(matrix(rep(medianas, each = length(rng)), nrow = length(rng)))
  names(nd) <- vars_final
  nd[[variable]] <- rng
  pred <- predict(mod_best, newdata = nd, type = "cloglog")
  data.frame(variable = variable, value = rng, suitability = pred)
}

responses <- do.call(rbind, lapply(vars_final, response_one))
write.csv(
  responses,
  file.path(paths$results, "variable_importance", "conditional_response_curves.csv"),
  row.names = FALSE
)

# Presence 5/50/95 percentiles.
percentiles <- t(vapply(
  occs_swd[, vars_final],
  quantile,
  numeric(3),
  probs = c(0.05, 0.50, 0.95),
  na.rm = TRUE
))
colnames(percentiles) <- c("P5", "P50", "P95")
write.csv(percentiles, file.path(paths$results, "tables", "presence_environment_percentiles.csv"))

# AUC implementation used for permutation importance.
auc_manual <- function(obs, pred) {
  pos <- pred[obs == 1]
  neg <- pred[obs == 0]
  r <- rank(c(pos, neg))
  n_pos <- length(pos)
  n_neg <- length(neg)
  (sum(r[seq_len(n_pos)]) - n_pos * (n_pos + 1) / 2) / (n_pos * n_neg)
}

datos_perm <- rbind(
  data.frame(presencia = 1, occs_swd[, vars_final]),
  data.frame(presencia = 0, bg_swd[, vars_final])
)

pred_original <- predict(mod_best, newdata = datos_perm[, vars_final], type = "cloglog")
auc_original <- auc_manual(datos_perm$presencia, pred_original)

set.seed(123)
n_perm <- 50
importance <- data.frame(
  variable = vars_final,
  mean_auc_loss = NA_real_,
  sd_auc_loss = NA_real_
)

for (v in vars_final) {
  losses <- numeric(n_perm)
  for (i in seq_len(n_perm)) {
    dat_i <- datos_perm[, vars_final]
    dat_i[[v]] <- sample(dat_i[[v]], replace = FALSE)
    pred_i <- predict(mod_best, newdata = dat_i, type = "cloglog")
    losses[i] <- auc_original - auc_manual(datos_perm$presencia, pred_i)
  }
  importance$mean_auc_loss[importance$variable == v] <- mean(losses)
  importance$sd_auc_loss[importance$variable == v] <- sd(losses)
}

importance$relative_importance <- 100 * importance$mean_auc_loss / sum(importance$mean_auc_loss)
importance <- importance[order(importance$relative_importance, decreasing = TRUE), ]

write.csv(
  importance,
  file.path(paths$results, "variable_importance", "permutation_importance_LQHP_RM1.csv"),
  row.names = FALSE
)

print(importance)
