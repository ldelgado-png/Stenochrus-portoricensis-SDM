# Common publication-map helpers | Stenochrus portoricensis | 2026-10-23
# Geographic analyses remain in native rasters. Reprojection is FOR DISPLAY ONLY.

project_root <- Sys.getenv(
  "STENOCHRU_SDM_PROJECT",
  unset = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
)
if (!dir.exists(project_root)) stop("Project directory not found: ", project_root)
project_root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)

required_packages <- c("terra", "sf", "ggplot2", "geodata", "patchwork")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) {
  stop("Install missing packages with install.packages(c(",
       paste(sprintf("'%s'", missing_packages), collapse = ", "), "))")
}

out_root <- file.path(project_root, "figures", "publication_consistent")
dir.create(out_root, recursive = TRUE, showWarnings = FALSE)

# Mainland Colombia only. Longitude -79.5 excludes San Andres/Providencia.
mainland_xlim <- c(-79.5, -66.5)
mainland_ylim <- c(-4.9, 13.6)
mainland_crop <- terra::ext(mainland_xlim[1], mainland_xlim[2],
                           mainland_ylim[1], mainland_ylim[2])
mainland_crs <- "EPSG:9377" # MAGNA-SIRGAS / Origen-Nacional, metres

publication_theme <- function(base_size = 14) {
  ggplot2::theme_bw(base_size = base_size, base_family = "sans") +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = base_size + 1, hjust = 0.5),
      plot.subtitle = ggplot2::element_text(size = base_size - 1, hjust = 0.5),
      panel.grid = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(colour = "#383838", fill = NA, linewidth = 0.5),
      axis.title = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(size = base_size - 2),
      legend.title = ggplot2::element_text(size = base_size - 1, face = "bold"),
      legend.text = ggplot2::element_text(size = base_size - 2),
      plot.margin = ggplot2::margin(9, 9, 9, 9)
    )
}

save_publication <- function(fig, stem, width, height) {
  dir.create(dirname(stem), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(paste0(stem, ".png"), fig, width = width, height = height,
                  units = "in", dpi = 600, bg = "white")
  ggplot2::ggsave(paste0(stem, ".tif"), fig, width = width, height = height,
                  units = "in", dpi = 600, device = "tiff", compression = "lzw", bg = "white")
  ggplot2::ggsave(paste0(stem, ".pdf"), fig, width = width, height = height,
                  units = "in", device = "pdf", bg = "white")
  message("Saved PNG/TIFF/PDF: ", stem)
}

needed_file <- function(path) {
  if (!file.exists(path)) stop("Required file was not found: ", path)
  path
}

read_qc_records <- function() {
  f <- needed_file(file.path(project_root, "data", "Stenochrus_portoricensis_America_QC_unique.csv"))
  d <- utils::read.csv(f, stringsAsFactors = FALSE)
  keys <- c("decimalLongitude", "decimalLatitude")
  if (!all(keys %in% names(d))) stop("Occurrence CSV lacks longitude/latitude columns")
  d <- d[stats::complete.cases(d[, keys]), , drop = FALSE]
  d <- d[!duplicated(d[, keys]), , drop = FALSE]
  if (nrow(d) != 234L) stop("QC occurrence coordinate count differs from 234: ", nrow(d))
  d
}

# Only map boundaries are clipped using planar lon/lat geometry.
# This does not modify occurrences, M200 buffers, or model rasters.
safe_cartographic_crop <- function(x, bbox, label = "map boundaries") {
  prev_s2 <- sf::sf_use_s2()
  on.exit(suppressMessages(sf::sf_use_s2(prev_s2)), add = TRUE)
  suppressMessages(sf::sf_use_s2(FALSE))
  cropped <- tryCatch(
    suppressWarnings(sf::st_crop(x, bbox)),
    error = function(e) stop("Failed to crop ", label, ": ", conditionMessage(e))
  )
  if (!nrow(cropped)) stop("No polygons remain after crop: ", label)
  cropped
}

read_colombia_shapes <- function() {
  cache <- file.path(project_root, "data", "gadm")
  dir.create(cache, recursive = TRUE, showWarnings = FALSE)
  country <- sf::st_as_sf(geodata::gadm(country = "COL", level = 0, path = cache))
  departments <- sf::st_as_sf(geodata::gadm(country = "COL", level = 1, path = cache))
  bbox <- sf::st_bbox(c(xmin = mainland_xlim[1], xmax = mainland_xlim[2],
                        ymin = mainland_ylim[1], ymax = mainland_ylim[2]),
                      crs = sf::st_crs(4326))
  country <- safe_cartographic_crop(country, bbox, label = "GADM Colombia level 0")
  departments <- safe_cartographic_crop(departments, bbox, label = "GADM Colombia level 1")
  country <- sf::st_make_valid(sf::st_transform(country, mainland_crs))
  departments <- sf::st_make_valid(sf::st_transform(departments, mainland_crs))
  if (!nrow(country) || !nrow(departments)) stop("No mainland Colombia geometry after clipping")
  list(country = country, departments = departments)
}

map_limits <- function(country_sf) {
  bb <- sf::st_bbox(country_sf)
  xx <- as.numeric(bb[c("xmin", "xmax")]); yy <- as.numeric(bb[c("ymin", "ymax")])
  list(x = xx + c(-0.07, 0.07) * diff(xx),
       y = yy + c(-0.05, 0.05) * diff(yy))
}

# Reference bars are measured in the projected coordinate system (metres).
metric_annotations <- function(limits, km = 250, north = TRUE, text_size = 4.0) {
  x <- limits$x; y <- limits$y
  dx <- diff(x); dy <- diff(y)
  x0 <- x[1] + .08 * dx; y0 <- y[1] + .065 * dy
  length_m <- km * 1000
  if (length_m > .40 * dx) stop("Scale bar longer than 40% of map width")
  bar <- list(
    ggplot2::annotate("segment", x = x0, xend = x0 + length_m,
                      y = y0, yend = y0, linewidth = 1.1, colour = "black"),
    ggplot2::annotate("segment", x = c(x0, x0 + length_m),
                      xend = c(x0, x0 + length_m),
                      y = y0 - .008 * dy, yend = y0 + .008 * dy,
                      linewidth = 0.9, colour = "black"),
    ggplot2::annotate("text", x = x0, y = y0 + .022 * dy, label = "0",
                      size = text_size, family = "sans"),
    ggplot2::annotate("text", x = x0 + length_m, y = y0 + .022 * dy,
                      label = paste(km, "km"), size = text_size, family = "sans")
  )
  if (north) {
    xn <- x[2] - .08 * dx; yn <- y[2] - .15 * dy
    bar <- c(bar, list(
      ggplot2::annotate("segment", x = xn, xend = xn, y = yn, yend = yn + .055 * dy,
                        linewidth = 0.75, arrow = grid::arrow(length = grid::unit(0.20, "cm"))),
      ggplot2::annotate("text", x = xn, y = yn + .080 * dy,
                        label = "N", size = text_size + 0.3, fontface = "bold")
    ))
  }
  bar
}

plot_frame <- function(limits, crs = mainland_crs) {
  ggplot2::coord_sf(crs = sf::st_crs(crs), default_crs = sf::st_crs(crs),
                    xlim = limits$x, ylim = limits$y, datum = NA, expand = FALSE)
}

project_display_raster <- function(r, method = "near", country_sf = NULL) {
  if (terra::nlyr(r) != 1L) stop("Map raster must have exactly one layer")
  cropped <- terra::crop(r, mainland_crop)
  target <- terra::project(cropped, mainland_crs, method = method)
  if (!is.null(country_sf)) target <- terra::mask(target, terra::vect(country_sf))
  target
}

raster_df <- function(r) {
  if (terra::nlyr(r) != 1L) stop("Expected one raster band")
  d <- as.data.frame(r, xy = TRUE, na.rm = TRUE)
  names(d)[3] <- "value"
  d
}

colombia_occurrences_sf <- function() {
  occ <- read_qc_records()
  if (!"countryCode" %in% names(occ)) stop("Occurrence CSV lacks countryCode")
  co <- occ[occ$countryCode == "CO", , drop = FALSE]
  if (nrow(co) != 10L) stop("Expected 10 unique QC coordinates in Colombia, found ", nrow(co))
  sf::st_transform(sf::st_as_sf(co, coords = c("decimalLongitude", "decimalLatitude"),
                             crs = 4326), mainland_crs)
}
