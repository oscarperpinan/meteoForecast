\name{meteoForecast-package}
\alias{meteoForecast-package}
\alias{meteoForecast}
\encoding{UTF-8}

\docType{package}

\title{Access to several Numerical Weather Prediction services both in raster format and as a time series for a location.}

\description{

  \code{meteoForecast} is a package to access outputs from Numerical Weather Prediction models both in raster format and as a time series for a location. Currenty it works with GFS, MeteoGalicia, NAM, and RAP.
  }

\details{

  \code{getRaster}, \code{getRasterDay}, and \code{getRasterDays} get data inside a bounding box and provide a multilayer raster data using the \code{RasterBrick} class defined in the package \code{raster}.

  \code{getPoint}, \code{getPointDays}, and \code{getPointRuns} get data for a certain location and produce a time series using the \code{zoo} class.

}

\author{
  Oscar Perpiñán, with contributions from Marcelo Almeida
}

\references{
\url{https://www.meteogalicia.gal/web/modelos/threddsIndex.action?request_locale=es}

\url{https://www.ncei.noaa.gov/thredds/catalog/model-gfs-003-files/catalog.html}

\url{https://www.ncei.noaa.gov/thredds/catalog/model-nam218/catalog.html}

\url{https://www.ncei.noaa.gov/thredds/catalog/model-rap130/catalog.html}

}

\keyword{ package }

\seealso{
  \code{\link{raster}}
  \code{\link{zoo}}
}

