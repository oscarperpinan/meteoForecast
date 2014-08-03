\name{Forecast variables}
\alias{varsMG}
\alias{varsOM}
\alias{varsGFS}
\alias{varsNAM}
\alias{varsRAP}

\docType{data}
\title{
Forecast Variables
}
\description{
Variables available in each model.
}
\usage{
data(varsMG)
data(varsOM)
data(varsGFS)
data(varsNAM)
data(varsRAP)
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

  \url{http://nomads.ncdc.noaa.gov/thredds/catalog/gfs-004/catalog.html}

  \url{http://nomads.ncdc.noaa.gov/thredds/catalog/gfs-004/catalog.html}
}

\examples{
data(varsMG)
head(varsMG)

data(varsOM)
head(varsOM)

data(varsGFS)
head(varsGFS)

data(varsNAM)
head(varsNAM)

data(varsRAP)
head(varsRAP)

\dontrun{
## This information has been extracted using this code

library(XML)

## MeteoGalicia
wcs <- xmlParse('http://mandeo.meteogalicia.es/thredds/wcs/modelos/WRF_HIST/d02/2014/07/wrf_arw_det_history_d02_20140721_0000.nc4?service=WCS&version=1.0.0&request=GetCapabilities')
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsMG <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

## GFS
wcs <- xmlParse('http://nomads.ncdc.noaa.gov/thredds/wcs/gfs-004/201407/20140715/gfs_4_20140715_1200_165.grb2?service=WCS&version=1.0.0&request=GetCapabilities')
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsGFS <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

## NAM
wcs <- xmlParse('http://nomads.ncdc.noaa.gov/thredds/wcs/nam218/201408/20140802/nam_218_20140802_0000_001.grb?service=WCS&version=1.0.0&request=GetCapabilities')
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsNAM <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

## RAP
wcs <- xmlParse('http://nomads.ncdc.noaa.gov/thredds/wcs/rap130/201408/20140802/rap_130_20140802_0000_001.grb2?service=WCS&version=1.0.0&request=GetCapabilities')
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsRAP <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]
}
}

\keyword{datasets}
