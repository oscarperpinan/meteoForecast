\name{Forecast variables}
\alias{varsMG}
\alias{varsOM}
\alias{varsGFS}
\docType{data}
\title{
Forecast Variables
}
\description{
Variables available in the MeteoGalicia and OpenMeteo services.
}
\usage{
data(varsMG)
data(varsOM)
data(varsGFS)
}
\format{
  Each \code{data.frame} contains three columns with the information
  about the variables available in each service. Use the elements of the
  \code{name} column to choose a variable with the argument \code{var}
  of \code{\link{getRaster}} and \code{\link{getPoint}}.
}

\source{
  \url{http://www.meteogalicia.es/web/modelos/threddsIndex.action}

  \url{https://openmeteoforecast.org/wiki/Main_Page}

  \url{http://nomads.ncdc.noaa.gov/thredds/catalog/gfs-004/catalog.html}
}

\examples{
data(varsMG)
data(varsOM)
data(varsGFS)

\dontrun{
## This information has been extracted using this code

library(XML)

## GFS
wcs <- xmlParse('http://nomads.ncdc.noaa.gov/thredds/wcs/gfs-004/201407/20140715/gfs_4_20140715_1200_165.grb2?service=WCS&version=1.0.0&request=GetCapabilities')
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsGFS <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

## MeteoGalicia
wcs <- xmlParse('http://mandeo.meteogalicia.es/thredds/wcs/modelos/WRF_HIST/d02/2014/07/wrf_arw_det_history_d02_20140721_0000.nc4?service=WCS&version=1.0.0&request=GetCapabilities')
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsMG <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]
}
}

\keyword{datasets}
