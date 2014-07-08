# meteoForecast

[![nil](//zenodo.org/badge/1928/oscarperpinan/meteoForecast.png)](http://dx.doi.org/10.5281/zenodo.10781)

The Weather Research and Forecasting (WRF) Model is a numerical
weather prediction (NWP) system. NWP refers to the simulation and
prediction of the atmosphere with a computer model, and WRF is a set
of software for this.

`meteoForecast` downloads data from the [Meteogalicia](http://www.meteogalicia.es/web/modelos/threddsIndex.action) and [OpenMeteo](https://openmeteoforecast.org/wiki/Main_Page)
NWP-WRF services using the NetCDF Subset Service.


## Installation

The development version is available at GitHub:

    ## install.packages("devtools")
    devtools::install_github("meteoForecast", "oscarperpinan")

The stable version is available at [CRAN](http://cran.r-project.org/web/packages/meteoForecast/):

    install.packages('meteoForecast')

## Usage

### Raster Data

-   `getRaster` gets a forecast output inside a bounding box and
    provides a multilayer raster data using the `RasterBrick` class
    defined in the package `raster`.
    
        wrf <- getRaster('temp', '2014-01-25', '00', remote=TRUE)
    
        library(rasterVis)
        levelplot(wrf, layers = 10:19)

-   `getRasterDays` uses `getRaster` to download the results
    cast each day comprised between `start` and `end` using the
    00UTC run. 
    
        wrfDays <- getRasterDays('cft',
                              start = '2014-01-01',
                              end = '2014-01-05',
                              box = c(-2, 35, 2, 40))
        
        levelplot(wrfDays, layout = c(1, 1), par.settings = BTCTheme)

### Point Data

`getPoint`, `getPointDays`, and `getPointRuns` get data for a
certain location and produce a time series using the `zoo` class.

-   `getPoint`
    
        ## temperature (Kelvin) forecast from meteogalicia
        tempK <- getPoint(c(0, 40), vars = 'temp')
        ## Cell does not coincide exactly with request
        attr(tempK, 'lat')
        attr(tempK, 'lon')
        ## Units conversion
        tempC <- tempK - 273
    
        library(lattice)
        xyplot(tempC)

-   `getPointDays`
    
        ## Time sequence
        radDays <- getPointDays(c(0, 40), start = '2013-01-01',
                                end = '2013-01-15')
        
        xyplot(radDays)

-   `getPointRuns`
    
        ## Variability between runs
        radRuns <- getPointRuns(c(0, 40), start = '2013-01-01',
                                end = '2013-01-15')
        xyplot(radRuns, superpose = TRUE)
        
        ## variability around the average
        radAv <- rowMeans(radRuns)
        radVar <- sweep(radRuns, 1, radAv)
        xyplot(radVar, superpose = TRUE)
