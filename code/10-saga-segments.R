library(terra)
library(sf)
library(Rsagacmd)
library(tmap)

saga = saga_gis(raster_backend = "terra", vector_backend = "sf")
ndvi = rast(system.file("raster/ndvi.tif", package = "spDataLarge"))
sg = saga$imagery_segmentation$seed_generation

ndvi_seeds = sg(ndvi, band_width = 2)
plot(ndvi_seeds$seed_grid)

srg = saga$imagery_segmentation$seeded_region_growing
ndvi_srg = srg(ndvi_seeds$seed_grid, ndvi, method = 1)
plot(ndvi_srg$segments)

ndvi_segments = as.polygons(ndvi_srg$segments) |> 
  st_as_sf()

tms1 = tm_shape(ndvi) +
  tm_raster(col.scale = tm_scale_continuous(n = 7, values = "PRGn"),
            col.legend = tm_legend(title = "NDVI")) +
  tm_layout(frame = FALSE,
            legend.frame = TRUE, legend.position = c("LEFT", "BOTTOM"),
            legend.bg.color = "white")
tms2 = tms1 + 
  tm_shape(ndvi_segments) +
  tm_borders(col = "red", lwd = 0.5) +
  tm_layout(legend.show = FALSE)
tms = tmap_arrange(tms1, tms2)

tmap_save(tms, filename = "images/10-saga-segments.png", dpi = 150, width = 9,
          height = 4.75, units = "cm")
