\name{Forecast variables}
\alias{varsMG}
\alias{varsOM}
\alias{varsGFS}
\alias{varsNAM}
\alias{varsRAP}
\alias{grepVar}

\docType{data}
\title{
Forecast Variables available in each model.
}
\description{
Variables available in each model. The \code{grepVar} function is a
wrapper around \code{grep} to search for variables.}

\usage{
grepVar(x, service, complete = FALSE)
data(varsMG)
data(varsOM)
data(varsGFS)
data(varsNAM)
data(varsRAP)
}

\arguments{


\item{x}{character string to be matched in the \code{description} column
  of the corresponding \code{vars*} file.}
\item{service}{Character, to choose from 'meteogalicia', 'openmeteo',
  'gfs', 'nam', and 'rap'}

\item{complete}{Logical, if \code{FALSE} (default) only the \code{name}
  column is returned. If \code{TRUE} the three columns are provided.}
}

\format{
  Each \code{data.frame} contains three columns, \code{name},
  \code{label}, and \code{description}, with the information
  about the variables available in each service. Use the elements of the
  \code{name} column to choose a variable with the argument \code{var}
  of \code{\link{getRaster}} and \code{\link{getPoint}}.
}

\source{
  varsMG: \url{http://www.meteogalicia.es/web/modelos/threddsIndex.action}

  varsOM: \url{https://openmeteoforecast.org/wiki/Main_Page}

  varsGFS: \url{http://nomads.ncdc.noaa.gov/thredds/catalog/gfs-004/catalog.html}

  varsNAM: \url{http://nomads.ncdc.noaa.gov/thredds/catalog/nam218/catalog.html}

  varsRAP: \url{http://nomads.ncdc.noaa.gov/thredds/catalog/rap130/catalog.html}
}

\examples{

grepVar('cloud', service = 'gfs', complete = TRUE)

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
wcs <- xmlParse(paste0(
    'http://mandeo.meteogalicia.es/thredds/wcs/modelos/WRF_HIST/d02/',
    '2014/07/wrf_arw_det_history_d02_20140721_0000.nc4',
    '?service=WCS&version=1.0.0&request=GetCapabilities'))
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsMG <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

## GFS
wcs <- xmlParse(paste0(
    'http://nomads.ncdc.noaa.gov/thredds/wcs/gfs-004/',
    '201407/20140715/gfs_4_20140715_1200_165.grb2',
    '?service=WCS&version=1.0.0&request=GetCapabilities'))
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsGFS <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

## NAM
wcs <- xmlParse(paste0(
    'http://nomads.ncdc.noaa.gov/thredds/wcs/nam218/',
    '201408/20140802/nam_218_20140802_0000_001.grb',
    '?service=WCS&version=1.0.0&request=GetCapabilities'))
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsNAM <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

## RAP
wcs <- xmlParse(paste0(
    'http://nomads.ncdc.noaa.gov/thredds/wcs/rap130/',
    '201408/20140802/rap_130_20140802_0000_001.grb2',
    '?service=WCS&version=1.0.0&request=GetCapabilities'))
doc <- xmlRoot(wcs)
content <- xmlChildren(doc)
meta <- content[["ContentMetadata"]]
xmlSize(meta)

varsRAP <- xmlToDataFrame(meta)[, c('description', 'name', 'label')]

}
}

\keyword{datasets}
