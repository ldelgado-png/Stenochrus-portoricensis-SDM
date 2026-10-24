# Figure 1 | 234 American QC coordinates and geodesic 200-km calibration area.
# Geographic buffer calculated by spherical/geodesic sf (s2), not degrees.
source(file.path(Sys.getenv("STENOCHRU_SDM_PROJECT",
                       unset = "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"),
                     "R", "40_fig_helpers.R"))

occ <- read_qc_records()
crs_americas <- "+proj=laea +lat_0=6 +lon_0=-80 +datum=WGS84 +units=m +no_defs"
pts <- sf::st_as_sf(occ, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

# Calculate individual 200-km spherical buffers in WGS84 with s2.
# Avoid an s2 polygon union: on some versions it raises
# "Loop ... edge ... crosses loop ... edge ...".
previous_s2 <- sf::sf_use_s2()
suppressMessages(sf::sf_use_s2(TRUE))
buffers_ll <- tryCatch(
  sf::st_buffer(sf::st_geometry(pts), dist = 200000),
  finally = suppressMessages(sf::sf_use_s2(previous_s2))
)
# Project the buffer polygons and dissolve for cartographic display only.
pts_map <- sf::st_transform(pts, crs_americas)
buffers_map <- sf::st_transform(sf::st_sf(geometry = buffers_ll), crs_americas)
buffers_map <- sf::st_make_valid(buffers_map)
m200_map <- sf::st_sf(geometry = sf::st_union(sf::st_geometry(buffers_map)))
m200_map <- sf::st_make_valid(m200_map)
if (any(!sf::st_is_valid(m200_map))) stop("M200 polygon invalid after projected union")
m200_ll <- sf::st_transform(m200_map, 4326)

# Country borders are clipped as cartographic layers, not calibration input.
b <- sf::st_bbox(m200_ll)
world_extent <- sf::st_bbox(c(xmin = min(-112, b["xmin"] - 3), xmax = max(-32, b["xmax"] + 3),
                              ymin = min(-32, b["ymin"] - 3), ymax = max(37, b["ymax"] + 3)),
                            crs = sf::st_crs(4326))
world_cache <- file.path(project_root, "data", "geodata_cache")
dir.create(world_cache, recursive = TRUE, showWarnings = FALSE)
world <- sf::st_as_sf(geodata::world(resolution = 5, level = 0, path = world_cache))
world <- safe_cartographic_crop(world, world_extent, label = "world country boundaries")
world <- sf::st_make_valid(sf::st_transform(world, crs_americas))

bb <- sf::st_bbox(m200_map)
rx <- as.numeric(bb[c("xmin", "xmax")]); ry <- as.numeric(bb[c("ymin", "ymax")])
limits <- list(x = rx + c(-.07, .07) * diff(rx),
               y = ry + c(-.08, .08) * diff(ry))

p <- ggplot2::ggplot() +
  ggplot2::geom_sf(data = world, fill = "#F4F4F4", colour = "#8E8E8E", linewidth = .25) +
  ggplot2::geom_sf(data = m200_map, fill = "#66A9CC", colour = "#2A6889",
                   linewidth = .40, alpha = .40) +
  ggplot2::geom_sf(data = pts_map, shape = 21, size = 1.5, stroke = .25,
                   fill = "#F5FAFC", colour = "#222222") +
  metric_annotations(limits, km = 1000, north = TRUE, text_size = 4) +
  plot_frame(limits, crs = crs_americas) +
  ggplot2::labs(title = "American occurrence records and M200 calibration area",
                subtitle = "234 quality-controlled unique coordinates; geodesic 200-km buffers") +
  publication_theme()

save_publication(p, file.path(out_root, "Figure_1", "Figure_1_consistent"), 11, 8)
cat("Figure 1 completed; 234 QC coordinates; 1,000-km projected reference bar\n")
