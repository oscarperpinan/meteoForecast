\name{meteoForecast-package}
\alias{meteoForecast-package}
\alias{meteoForecast}
\encoding{UTF-8}

\docType{package}

\title{A package to retrieve WRF-NWP forecasts}

\description{

  The Weather Research and Forecasting (WRF) Model is a numerical
  weather prediction (NWP) system. NWP refers to the simulation and
  prediction of the atmosphere with a computer model, and WRF is a set
  of software for this.
  
  \code{meteoForecast} downloads data from the MeteoGalicia and
  OpenMeteo NWP-WRF services using the NetCDF Subset Service.

}

\details{

  \code{getRaster}, \code{getRasterDay}, and \code{getRasterDays} get
  data inside a bounding box and provide a multilayer raster data using
  the \code{RasterBrick} class defined in the package \code{raster}.

  \code{getPoint}, \code{getPointDays}, and \code{getPointRuns} get data
  for a certain location and produce a time series using the \code{zoo}
  class.

  %% The default service choice is MeteoGalicia. The use of the OpenMeteo
  %% service is still experimental, and some functions are not fully
  %% implemented for it.

  %% The MeteoGalicia service produces forecasts for the geographical area
  %% comprised approximately between 21.58W and 33.63E, 6.36N and 49.57N.
}

\author{
  Oscar Perpiñán, with contributions from Marcelo Almeida
}
\references{
  
  \url{http://www.wrf-model.org/index.php}

  \url{http://www.unidata.ucar.edu/software/thredds/current/tds/reference/NetcdfSubsetServiceReference.html}

  \url{http://www.meteogalicia.es/web/modelos/threddsIndex.action}

  \url{https://openmeteoforecast.org/wiki/Main_Page}

}

\keyword{ package }

\seealso{
  \code{\link{raster}}
  \code{\link{zoo}}
}

