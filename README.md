meteo
=====

Retrieve NWP-WRF output from
[Meteogalicia](http://www.meteogalicia.es/web/modelos/threddsIndex.action)
and [OpenMeteo](https://openmeteoforecast.org/wiki/Data) services.



# Usage #

(Only first time or for updating) Install from Github (not on CRAN yet). 

    install.packages("devtools")
    devtools::install_github("meteo", "oscarperpinan")


Load `meteo` (and `rasterVis` for graphics)

    library(meteo)
    library(rasterVis)

Set time zone to UTC

    Sys.setenv(TZ='UTC')

## Variables

### Meteogalicia

    data(varsMG)
    varsMG$Name

### OpenMeteo

    data(varsOM)
    varsOM$Name

# Raster Data

## Raster Data from Meteogalicia

    MGraster <- getRaster('temp',
                          box=c(-7, -2, 35, 40),
                          service='meteogalicia')

    levelplot(MGraster, layers=1:12)


## Raster Data from OpenMeteo

    OMraster <- getRaster('temp2m',
                          frames=12,
                          service='openmeteo')

    levelplot(OMraster)


## Extract Values for Some Locations

### Define Locations

    st <- data.frame(name=c('Almeria','Granada','Huelva','Malaga','Caceres'),
                     elev=c(42, 702, 38, 29, 448))
    
    coordinates(st) <- cbind(c(-2.46, -3.60, -6.94, -4.42, -6.37),
                             c(36.84, 37.18, 37.26, 36.63, 39.47)
                             )
    proj4string(st) <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0'

### Meteogalicia

    MGpoints <- extract(MGraster, st)
    MG <- zoo(t(MGpoints), getZ(MGraster))
    names(MG) <- st$name

    xyplot(MG, superpose=TRUE)


### OpenMeteo

    OMpoints <- extract(OMraster, st)
    OM <- zoo(t(OMpoints), getZ(OMraster))
    names(OM) <- st$name

    xyplot(OM, superpose=TRUE)


# Point Data

## Only one location

### Retrieve Point Data from Meteogalicia

    pts <- coordinates(st)

    MGpoint <- getPoint(pts[3, 1], pts[3, 2],
                        vars='temp',
                        service='meteogalicia')
    ## Meteogalicia uses Kelvin degrees 
    MGpoint <- MGpoint - 273

### Retrieve Point Data from OpenMeteo

    OMpoint <- getPoint(pts[3, 1], pts[3, 2],
                        vars='temp',
                        service='openmeteo')

### Comparison

    xyplot(cbind(MGpoint, OMpoint), superpose=TRUE)


## A set of locations

    comp <- lapply(seq_len(nrow(pts)), function(i){
        myPoint <- pts[i,]
    
        MG <- getPoint(myPoint[1], myPoint[2],
                       vars='temp', run='00',
                       service='meteogalicia')
        MG <- MG - 273
    
        OM <- getPoint(myPoint[1], myPoint[2],
                       vars='temp',
                       service='openmeteo')
    
        merge(OM, MG)
    })

### Comparison

    xyplot(comp, superpose=TRUE)


