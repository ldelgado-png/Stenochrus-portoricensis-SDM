# Figure 6: elevational redistribution of climatic suitability
# Uses summary CSV outputs from R/12_altitudinal_analysis.R.
# Run in the local modelling project after setting STENOCHRU_SDM_PROJECT,
# or from that project's root with R/12 inputs already available.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})

project_dir <- Sys.getenv("STENOCHRU_SDM_PROJECT", unset = getwd())
out_dir <- file.path(project_dir, "results", "altitude")
bands_file <- file.path(out_dir, "Altitude_suitability_bands.csv")
changes_file <- file.path(out_dir, "Altitude_change_gain_loss_persistence.csv")
if (!file.exists(bands_file) || !file.exists(changes_file)) {
  stop("Elevation summary CSVs not found. Run R/12_altitudinal_analysis.R first.")
}
bands <- read.csv(bands_file, stringsAsFactors = FALSE)
changes <- read.csv(changes_file, stringsAsFactors = FALSE)

ids <- c("Current", "SSP126_2041", "SSP585_2041",
         "SSP126_2061", "SSP585_2061")
scenario_labels <- c("Current", "SSP1-2.6\n2041-2060",
                     "SSP5-8.5\n2041-2060", "SSP1-2.6\n2061-2080",
                     "SSP5-8.5\n2061-2080")
if (!all(bands$scenario %in% ids) ||
    !all(changes$scenario %in% ids[-1])) {
  stop("Unexpected scenario IDs in the altitude summary tables.")
}
bands$scenario <- factor(bands$scenario, levels = ids, labels = scenario_labels)
changes$scenario <- factor(changes$scenario, levels = ids[-1],
                           labels = scenario_labels[-1])

alt_levels <- c("<500", "500-1000", "1000-1500", "1500-2000",
                "2000-2500", "2500-3000", ">3000")
bands$alt_band <- factor(bands$alt_band, levels = alt_levels)
changes$change <- factor(changes$change, levels = c("Loss", "Persistence", "Gain"))
if (anyNA(bands$alt_band) || anyNA(changes$change)) {
  stop("Unexpected elevation bands or change class.")
}

alt_cols <- c(
  "<500" = "#D6EAF8",
  "500-1000" = "#91C4DB",
  "1000-1500" = "#4B9FBA",
  "1500-2000" = "#39A891",
  "2000-2500" = "#8EBC73",
  "2500-3000" = "#C5A65C",
  ">3000" = "#8E6655"
)
change_cols <- c("Loss" = "#D55E00", "Persistence" = "#009E73",
                 "Gain" = "#0072B2")

paper_theme <- theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0,
                              margin = margin(b = 12)),
    axis.title = element_text(size = 11, colour = "black"),
    axis.text = element_text(size = 10, colour = "black"),
    axis.text.x = element_text(lineheight = 1.15, margin = margin(t = 7)),
    legend.title = element_text(face = "bold", size = 10),
    legend.text = element_text(size = 9),
    plot.margin = margin(12, 15, 12, 12)
  )

pA <- ggplot(bands, aes(x = scenario, y = percent, fill = alt_band)) +
  geom_col(position = position_stack(reverse = TRUE),
           width = 0.66, colour = "white", linewidth = 0.25) +
  scale_fill_manual(values = alt_cols, breaks = alt_levels, drop = FALSE) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20),
                     expand = expansion(mult = c(0, 0))) +
  labs(title = "A. Elevational distribution of suitable area",
       x = NULL, y = "Suitable area (%)", fill = "Elevation (m)") +
  paper_theme

dodge <- position_dodge(width = 0.6)
pB <- ggplot(changes, aes(x = scenario, y = median_m,
                         colour = change, group = change)) +
  geom_errorbar(aes(ymin = q1_m, ymax = q3_m),
                position = dodge, width = 0.16, linewidth = 0.85) +
  geom_point(position = dodge, size = 3.1) +
  scale_color_manual(values = change_cols, drop = FALSE) +
  scale_y_continuous(limits = c(0, 2250), breaks = seq(0, 2000, 500),
                     expand = expansion(mult = c(0, 0.01))) +
  labs(title = "B. Elevation of loss, persistence and gain",
       x = NULL, y = "Elevation (m a.s.l.)",
       colour = "Projected change") +
  paper_theme

fig <- (pA / pB) + plot_layout(heights = c(1, 1.05))
print(fig)

basename <- "Figure_altitudinal_redistribution_FINAL"
ggsave(file.path(out_dir, paste0(basename, ".png")), fig,
       width = 11, height = 9.5, units = "in", dpi = 400, bg = "white")
ggsave(file.path(out_dir, paste0(basename, ".tiff")), fig,
       device = "tiff", width = 11, height = 9.5, units = "in",
       dpi = 400, compression = "lzw", bg = "white")
ggsave(file.path(out_dir, paste0(basename, ".pdf")), fig,
       device = "pdf", width = 11, height = 9.5, units = "in",
       bg = "white")
cat("Figure 6 exports saved to ", out_dir, "\n", sep = "")
