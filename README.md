meteo
=====

Retrieve NWP-WRF output from
[Meteogalicia](http://www.meteogalicia.es/web/modelos/threddsIndex.action)
and [OpenMeteo](https://openmeteoforecast.org/wiki/Data) services.

# Install from Github (not on CRAN yet) #

    install.packages("devtools")
	devtools::install_github("meteo", "oscarperpinan")

<!-- tmp <- paste0(tempdir(), '/meteo.zip') -->
<!-- download.file('https://github.com/oscarperpinan/meteo/archive/master.zip', -->
<!--           destfile=tmp, method='wget') -->
<!-- unzip(tmp, exdir=tempdir(), unzip=getOption('unzip')) -->

<!-- ## Install dependencies only if you don't have them already. -->
<!-- install.packages(c('raster', 'zoo') -->
<!-- install.packages('ncdf4') -->
<!-- ## ncdf4 is not available for Windows at CRAN. -->
<!-- ## Install ncdf4 from http://cirrus.ucsd.edu/~pierce/ncdf/ or use ncdf instead -->
<!-- ## install.packages('ncdf')  -->
<!-- install.packages(paste0(tempdir(), '/meteo-master'), repos=NULL, method='source') -->

    

# Usage #

    library(meteo)
    library(rasterVis)
    
    Sys.setenv(TZ='UTC')

	## Available variables in Meteogalicia
	data(varsMG)
	varsMG$Name

    ## Available variables in Meteogalicia
	data(varsOM)
	varsOM$Name

    ## Retrieve data from meteogalicia
    MGraster <- getRaster('temp', box=c(-7, -2, 35, 40), service='meteogalicia')
    levelplot(MGraster, layers=1:12)
    levelplot(MGraster, layout=c(1, 1))
    
    ## Retrieve data from openmeteo
    OMraster <- getRaster('temp2m', frames=1:12, service='openmeteo')
    levelplot(OMraster)
    
    ## Extract values for some locations
    st <- data.frame(name=c('Almeria','Granada','Huelva','Malaga','Caceres'),
                     elev=c(42, 702, 38, 29, 448))
    
    coordinates(st) <- cbind(c(-2.46, -3.60, -6.94, -4.42, -6.37),
                             c(36.84, 37.18, 37.26, 36.63, 39.47)
                             )
    proj4string(st) <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0'
    
    MGpoints <- extract(MGraster, st)
    MG <- zoo(t(MGpoints), getZ(MGraster))
    names(MG) <- st$name
    xyplot(MG, superpose=TRUE)
    
    OMpoints <- extract(OMraster, st)
    OM <- zoo(t(OMpoints), getZ(OMraster))
    names(OM) <- st$name
    xyplot(OM, superpose=TRUE)
    
    
    ## Retrieve point values from the services
    pts <- coordinates(st)
    
    ## Meteogalicia uses Kelvin degrees 
    MGpoint <- getPoint(pts[3, 1], pts[1, 2], vars='temp', service='meteogalicia')
    MGpoint <- MGpoint - 273
    ## Openmeteo uses Celsius degrees
    OMpoint <- getPoint(pts[3, 1], pts[1, 2], vars='temp', service='openmeteo')
    
    xyplot(cbind(MGpoint, OMpoint), superpose=TRUE)
    
    ## Compare services
    comp <- lapply(seq_len(nrow(pts)), function(i){
        myPoint <- pts[i,]
    
        MG <- getPoint(myPoint[1], myPoint[2], vars='temp', run='00', service='meteogalicia')
        MG <- MG - 273
    
        OM <- getPoint(myPoint[1], myPoint[2], vars='temp', service='openmeteo')
        
        merge(OM, MG)
    })
    
    xyplot(comp, superpose=TRUE)
