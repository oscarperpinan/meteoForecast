\name{Forecast variables}
\alias{grepVar}

\docType{data}
\title{
Forecast Variables available in each model.
}

\description{ Variables available in each model. The \code{grepVar} function is a wrapper around \code{grep} to search for variables.}

\usage{
grepVar(x, service, day = Sys.Date() - 15, complete = FALSE)
}

\arguments{

  \item{x}{character string to be matched in the \code{description} column of the corresponding \code{vars*} file.}

\item{service}{Character, to choose from 'meteogalicia', 'gfs', 'nam', and 'rap'}

\item{day}{Date. Services change the variables availability over time.}

\item{complete}{Logical, if \code{FALSE} (default) only the \code{name} column is returned. If \code{TRUE} the three columns are provided.}  }

\value{ 
Each \code{data.frame} contains three columns, \code{name}, \code{label}, and \code{description}, with the information about the variables available in each service. Use the elements of the \code{name} column to choose a variable with the argument \code{var} of \code{\link{getRaster}} and \code{\link{getPoint}}.  }

\source{
  MeteoGalicia: \url{http://www.meteogalicia.es/web/modelos/threddsIndex.action}

  GFS: \url{http://nomads.ncdc.noaa.gov/thredds/catalog/gfs-004/catalog.html}

  NAM: \url{http://nomads.ncdc.noaa.gov/thredds/catalog/nam218/catalog.html}

  RAP: \url{http://nomads.ncdc.noaa.gov/thredds/catalog/rap130/catalog.html}
}

\examples{

\dontrun{
## Variables available recently
grepVar('cloud', service = 'gfs', complete = TRUE)

## Variables available some time ago
grepVar('cloud', service = 'gfs', day = as.Date('2014-07-15'),
        complete = TRUE)

}
}

\keyword{datasets}
