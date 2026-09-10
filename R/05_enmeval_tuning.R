# 05_enmeval_tuning.R -----------------------------------------------------
# Direct ENMeval tuning in SWD mode.

source("R/00_setup.R")
source("R/03_environmental_predictors.R")
source("R/04_background_sampling.R")

fc_set <- c("L", "LQ", "H", "LQH", "LQHP")
rm_set <- seq(0.5, 4, by = 0.5)

set.seed(123)

e_stenochrus <- ENMeval::ENMevaluate(
  occs = occs_swd,
  bg = bg_swd,
  algorithm = "maxnet",
  partitions = "block",
  tune.args = list(fc = fc_set, rm = rm_set),
  parallel = FALSE,
  raster.preds = FALSE,
  other.settings = list(validation.bg = "partition")
)

res_stenochrus <- ENMeval::eval.results(e_stenochrus)
res_stenochrus <- res_stenochrus[order(res_stenochrus$AICc), ]

selected <- subset(res_stenochrus, fc == "LQHP" & rm == 1)
stopifnot(nrow(selected) == 1L)

write.csv(
  res_stenochrus,
  file.path(paths$results, "model_selection", "ENMeval_40_models.csv"),
  row.names = FALSE
)

write.csv(
  selected,
  file.path(paths$results, "model_selection", "ENMeval_selected_LQHP_RM1.csv"),
  row.names = FALSE
)

saveRDS(
  e_stenochrus,
  file.path(paths$results, "model_selection", "ENMeval_object.rds")
)

mods <- ENMeval::eval.models(e_stenochrus)
model_name <- "fc.LQHP_rm.1"
if (!model_name %in% names(mods)) {
  hit <- grep("LQHP.*rm.*1$", names(mods), value = TRUE)
  if (length(hit) != 1L) stop("Could not uniquely identify LQHP / RM = 1 model.")
  model_name <- hit
}
mod_best <- mods[[model_name]]
saveRDS(mod_best, file.path(paths$results, "model_selection", "maxnet_LQHP_RM1.rds"))

print(selected)
