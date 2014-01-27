library(sp)
library(raster)
library(meteo)

## Define locations

st <- data.frame(name=c('Almeria','Granada','Huelva','Malaga','Caceres'),
               elev=c(42, 702, 38, 29, 448))

coordinates(st) <- cbind(c(-2.46, -3.60, -6.94, -4.42, -6.37),
                         c(36.84, 37.18, 37.26, 36.63, 39.47)
                         )
proj4string(st) <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0'

## Retrieve raster data
setwd('/path/to/my/folder/')
wrf <- getRaster('temp', '2014-01-25', '00', remote=FALSE)

## Extract values for some locations
vals <- extract(wrf, st)
vals <- zoo(t(vals), getZ(wrf))
names(vals) <- st$name
