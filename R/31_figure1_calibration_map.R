# R/31_figure1_calibration_map.R --------------------------------------------
# Manuscript Figure 1: verified American occurrence localities and
# operational geodesic M200 calibration region.
# INPUT: original quality-controlled 234 distinct coordinates.
# OUTPUTS: PNG 400 dpi; TIFF 600 dpi (LZW); vector PDF.
# No model refitting; no original data files modified.
# NOTE: Requires geodata::world() borders to be downloaded/cached locally.
suppressPackageStartupMessages({
  library(sf)
  library(ggplot2)
  library(geodata)
})
repo <- "D:/Usuario/Documents/EcdysisSDM/Stenochrus_portoricensis"
source_csv <- file.path(repo,"data","Stenochrus_portoricensis_America_QC_unique.csv")
stopifnot(file.exists(source_csv))
xy <- read.csv(source_csv, stringsAsFactors=FALSE)
stopifnot(all(c("decimalLongitude","decimalLatitude")%in%names(xy)))
xy <- xy[is.finite(xy$decimalLongitude)&is.finite(xy$decimalLatitude),]
stopifnot(nrow(xy)==234L)
stopifnot(nrow(unique(xy[,c("decimalLongitude","decimalLatitude")]))==234L)
stopifnot(all(xy$decimalLongitude>=-180 & xy$decimalLongitude<=180),
          all(xy$decimalLatitude>=-90 & xy$decimalLatitude<=90))

sf::sf_use_s2(TRUE)
pts <- sf::st_as_sf(xy, coords=c("decimalLongitude","decimalLatitude"),
                    crs=4326,remove=FALSE)
m200 <- sf::st_sf(
  calibration="M200",
  geometry=sf::st_union(sf::st_buffer(sf::st_geometry(pts),dist=200000))
)
stopifnot(sf::st_is_valid(m200), sf::st_crs(m200)$epsg == 4326)

cache <- file.path(repo,"data","geodata_cache")
dir.create(cache,recursive=TRUE,showWarnings=FALSE)
borders <- tryCatch(
  sf::st_as_sf(geodata::world(resolution=5, level=0, path=cache)),
  error=function(e)stop("Unable to load/download world country borders: ",
                        conditionMessage(e))
)
stopifnot(sf::st_crs(borders)$epsg==4326)

xlim <- pmax(-179,pmin(179,range(xy$decimalLongitude)+c(-5,5)))
ylim <- pmax(-85,pmin(85,range(xy$decimalLatitude)+c(-5,5)))
# Explicitly include the 200 km buffer around extreme localities.
box <- sf::st_bbox(m200)
xlim <- range(c(xlim,as.numeric(box[c("xmin","xmax")])))
ylim <- range(c(ylim,as.numeric(box[c("ymin","ymax")])))

p <- ggplot()+
  geom_sf(data=borders,fill="#F6F6F6",colour="#B0B0B0",
          linewidth=0.16)+
  geom_sf(data=m200,aes(fill="M200 calibration area"),
          colour="#14547B",linewidth=0.24,alpha=0.30)+
  geom_sf(data=pts,aes(shape="QC occurrence coordinates"),
          size=1.00,fill="#E34F2B",colour="#252525",stroke=0.17)+
  scale_fill_manual(name=NULL,values=c("M200 calibration area"="#3B98CA"))+
  scale_shape_manual(name=NULL,values=c("QC occurrence coordinates"=21))+
  coord_sf(xlim=xlim,ylim=ylim,expand=FALSE,datum=sf::st_crs(4326))+
  labs(title=expression(paste(italic("Stenochrus portoricensis"),
                              ": American occurrence localities and M200")),
       subtitle="234 quality-controlled unique coordinates; geodesic 200-km union",
       x="Longitude",y="Latitude")+
  theme_bw(base_size=10)+
  theme(
    panel.grid.major=element_line(linewidth=0.15,colour="#DADADA"),
    panel.background=element_rect(fill="white",colour=NA),
    legend.position="bottom",
    legend.box="horizontal",
    plot.title=element_text(size=12,face="bold"),
    plot.subtitle=element_text(size=9),
    plot.margin=margin(8,12,8,12)
  )

out <- file.path(repo,"figures","calibration")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
png_path <- file.path(out,"Figure_1_M200_occurrences_400dpi.png")
tiff_path <- file.path(out,"Figure_1_M200_occurrences_600dpi.tiff")
pdf_path <- file.path(out,"Figure_1_M200_occurrences_vector.pdf")
ggsave(png_path,plot=p,width=11,height=7.3,units="in",
       dpi=400,bg="white")
ggsave(tiff_path,plot=p,width=11,height=7.3,units="in",
       dpi=600,device="tiff",compression="lzw",bg="white")
ggsave(pdf_path,plot=p,width=11,height=7.3,units="in",
       device="pdf",bg="white")

cat("\nFigure 1 generated; inspect against 234 input coordinates:\n")
print(data.frame(
  file=c(png_path,tiff_path,pdf_path),
  bytes=file.info(c(png_path,tiff_path,pdf_path))$size
),row.names=FALSE)
cat("\nFor manuscript: the points show 234 QC unique exact coordinates;\n",
    "171 environmental cells were used for model calibration.\n",sep="")
