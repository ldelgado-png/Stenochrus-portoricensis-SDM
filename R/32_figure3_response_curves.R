# Figure 3 | Conditional responses, Stenochrus portoricensis
# Directly reads the ORIGINAL saved ENMeval object. No refit, no change to data.
# Source: ENMeval::eval.models() model fc.LQHP_rm.1; n = 171 presences.

suppressPackageStartupMessages({
  library(ENMeval); library(maxnet); library(ggplot2)
})
project <- Sys.getenv("STENOCHRU_SDM_PROJECT",
                      unset = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis")
input <- file.path(project, "data", "ENMeval_Stenochrus_M200_SWD.rds")
out <- file.path(project, "figures", "response_curves")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
stopifnot(file.exists(input))
vars <- c("bio1", "bio2", "bio4", "bio12", "bio14", "bio15")
obj <- readRDS(input)
models <- ENMeval::eval.models(obj)
model_id <- "fc.LQHP_rm.1"
if (!(model_id %in% names(models))) {
  matches <- grep("^fc[.]LQHP_rm[.]1([.]0)?$", names(models), value=TRUE)
  if (length(matches) != 1L) stop("Model LQHP/RM1 not found uniquely: ", paste(names(models), collapse=", "))
  model_id <- matches
}
model <- models[[model_id]]
stopifnot(inherits(model, "maxnet"))
occ <- as.data.frame(ENMeval::eval.occs(obj))
if (!all(vars %in% names(occ))) stop("Original ENMeval object is not SWD with all six predictors")
occ <- occ[, vars, drop=FALSE]
stopifnot(nrow(occ) == 171L, all(complete.cases(occ)))

# WorldClim 2.1 values should be raw degrees C for BIO1 and BIO2.
# Do not silently rescale columns since the model expects the original units.
if (max(abs(occ$bio1)) > 90 || max(abs(occ$bio2)) > 90)
  stop("Unusual BIO1/BIO2 units: inspect saved ENMeval SWD predictors before plotting")

medians <- vapply(occ, median, numeric(1))
quantile_by_var <- lapply(vars, function(v) {
  z <- as.numeric(quantile(occ[[v]], probs=c(.05,.95), na.rm=TRUE))
  data.frame(variable=v, p05=z[1], p95=z[2])
})
q <- do.call(rbind, quantile_by_var)
responses <- do.call(rbind, lapply(vars, function(v) {
  x <- seq(min(occ[[v]]), max(occ[[v]]), length.out=250L)
  nd <- as.data.frame(matrix(rep(medians, each=length(x)), nrow=length(x)))
  names(nd) <- vars
  nd[[v]] <- x
  z <- as.numeric(predict(model, newdata=nd, type="cloglog"))
  stopifnot(length(z)==length(x), all(is.finite(z)))
  data.frame(variable=v, predictor_value=x, suitability_cloglog=z)
}))
responses$variable <- factor(responses$variable, levels=vars)
q$variable <- factor(q$variable, levels=vars)
labels <- c(
  bio1="BIO1 | Annual mean temperature (°C)",
  bio2="BIO2 | Mean diurnal range (°C)",
  bio4="BIO4 | Temperature seasonality (SD × 100)",
  bio12="BIO12 | Annual precipitation (mm)",
  bio14="BIO14 | Precipitation of driest month (mm)",
  bio15="BIO15 | Precipitation seasonality (CV)"
)

fig <- ggplot(responses, aes(x=predictor_value, y=suitability_cloglog)) +
  geom_rect(data=q, aes(xmin=p05,xmax=p95,ymin=0,ymax=1),
            inherit.aes=FALSE, fill="#b6d4e6", alpha=.37) +
  geom_line(colour="#144d74", linewidth=.85) +
  facet_wrap(~variable, ncol=3, scales="free_x",
             labeller=labeller(variable=as_labeller(labels))) +
  scale_y_continuous(limits=c(0,1), breaks=seq(0,1,.25), expand=expansion(mult=c(0,.02))) +
  labs(x="Predictor value", y="Cloglog suitability") +
  theme_bw(base_size=11) +
  theme(strip.text=element_text(face="bold",size=9), strip.background=element_rect(fill="#eef3f6"),
        panel.grid.minor=element_blank(), panel.grid.major.x=element_blank(),
        axis.text=element_text(colour="black"), plot.margin=margin(12,12,12,12))

# Save the actual evaluated response values as an audit trail.
write.csv(responses, file.path(out,"Figure_3_conditional_response_values.csv"), row.names=FALSE)
write.csv(q, file.path(out,"Figure_3_presence_P05_P95.csv"), row.names=FALSE)
base <- file.path(out,"Figure_3_conditional_responses_ENMeval_LQHP_RM1")
ggsave(paste0(base,".png"),fig,width=11,height=7,units="in",dpi=400,bg="white")
ggsave(paste0(base,".tif"),fig,width=11,height=7,units="in",dpi=600,
       device="tiff",compression="lzw",bg="white")
ggsave(paste0(base,".pdf"),fig,width=11,height=7,units="in",device="pdf",bg="white")
cat("Figure 3: six conditional curves; shaded bands = presence P5–P95.\n",
    "These curves are conditional associations, not physiological tolerances.\n",
    "Exports: ", base, ".[png,tif,pdf]\n", sep="")
