meteoForecast
=====


[![DOI](https://zenodo.org/badge/1928/oscarperpinan/meteoForecast.png)](http://dx.doi.org/10.5281/zenodo.10781)

  The Weather Research and Forecasting (WRF) Model is a numerical
  weather prediction (NWP) system. NWP refers to the simulation and
  prediction of the atmosphere with a computer model, and WRF is a set
  of software for this.
  
  `meteoForecast` downloads data from the
  [Meteogalicia](http://www.meteogalicia.es/web/modelos/threddsIndex.action)
  and [OpenMeteo](https://openmeteoforecast.org/wiki/Data) NWP-WRF
  services using the NetCDF Subset Service.


# Installation #

The development version is available at GitHub:

    install.packages("devtools")
    devtools::install_github("meteoForecast", "oscarperpinan")

The stable version is available at CRAN:

    install.packages('meteoForecast')

