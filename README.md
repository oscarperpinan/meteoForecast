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
	
	## Available variables in Meteogalicia
	data(varsMG)
	varsMG$Name

    ## Raster data
	x <- getRaster(var='swflx', day='2014-01-14')
    x2 <- getRaster(var='temp', day='2014-01-14')

    ## Point forecast
    p1 <- getPoint(3, 35, day='2014-01-14', vars=c('temp', 'swflx'))
